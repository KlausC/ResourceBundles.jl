using Base.Filesystem

const LocalePattern = Locale
const Pathname = String

mutable struct Cache{T}
    list::Vector{Pair{LocalePattern,Pathname}}
    dict::Dict{LocalePattern,Dict{String,T}}
end

struct ResourceBundle{T}
    path::Pathname
    name::String
    typ::Type
    cache::Dict{Locale,Cache{T}}
    function ResourceBundle{T}(path::Pathname, name::AbstractString, typ::Type{T}) where T
        new(path, string(name), typ, Dict{Locale,Cache{T}}())
    end
end

function ResourceBundle(mod::Module, name::AbstractString)
    ResourceBundle{Any}(resource_path(mod, name), name, Any)
end

function ResourceBundle(mod::Module, name::AbstractString, T::Type) 
    ResourceBundle{T}(resource_path(mod, name), name, T)
end

SEP = '_'
SEP2 = '-'
JEND = ".jl"
JENDL = length(JEND)
RESOURCES = "resources"

basefind = VERSION >= v"0.7.0-DEV.2385" ? Base.find_package : Base.find_in_path

"""
    resource_path(module) -> String

Return path name of resource directory for a module.
If top module is `Main` the path is relative to the current working directory.
If `JULIA_HOME/../../stdlib/<module-names>/resources` is a directory, we assume
the resources of a module in the standard library.
Otherwise the directory `Pkg.dir()/<module-names>/resources` is selected; that is
the usual case for user defined modules.
"""
function resource_path(mod::Module, name::AbstractString)
    mp = module_path(mod)
    mp1 = string(mp[1])
    idx, base = mp[1] == :Main ? (2, pwd()) : (1, module_path(mp1))
    n = length(mp)
    path = "."
    modpart = idx <= n ? string(mp[idx]) : ""
    prefix = normpath(base, modpart, RESOURCES)
    if is_resourcepath(prefix, name)
        path = prefix
        for i = idx+1:n
            prefix = joinpath(prefix, string(mp[i]))
            if is_resourcepath(prefix, name)
                path = prefix
            end
        end         
    end
    path
end

"""
    module_path(mod)

Return installation directory for module `mod`.
"""

function module_path(name)
    name = string(name)
    path1 = normpath(JULIA_HOME, "..", "..", "stdlib", name)
    path2 = Pkg.dir(name)
    is1 = isdir(path1)
    is2 = isdir(path2)
    if is1 && is2
        warn("module '$name' has same name as stdlib module")
    end
    if !is1 && !is2
        warn("module '$name' not found in '$path1' or '$path2'")
    end
    splitdir(is2 ? path2 : path1)[1]
end


"""
    is_resource_dir(path, name)

Check if directory `path` contains subdirectory `name` or a file `name_*` or `name.jl`.
Path may be relative or absolute. Name may be string or symbol.
"""
function is_resourcepath(path::AbstractString, name::AbstractString)
    isdir(path) || return false
    isdir(joinpath(path, string(name))) && return true
    stp = name * SEP
    stq = name * JEND
    res = any(f -> ( startswith(f, stp) || f == stq ), readdir(path))
    res
end

"""
    module_path(mod::Module)

Return the list of module names of a module hierarchy.
Example: `Base.Iterators -> [:Main,:Base,:Iterators]`.
"""
module_path(mod::Module) = module_path(mod, Symbol[])
function module_path(mod::Module, list::Vector{Symbol})
    mn = module_name(mod)
    if isempty(list) || mn != first(list)
        unshift!(list, mn)
        module_path(module_parent(mod), list)
    end
    list
end

"""
    findfiles(bundle, locale) -> Locale => pathname

Produce list of pairs of locale patterns and pathnames of potential resource file,
restricted to the given locale. The file names are all of the form
`absfilename(path, name) * locpart * ".jl"`
where `locstring` is in the form of a locale-pattern, with locale-separators replaced by
characters `_` or `/`.
The list is sorted with most specific locale-pattern first. The list needs not be totally
ordered (with respect to `⊆`, which allows ambiguous

Example: for `Locale("de-DE")`, the resource files could be `name_de_DE.jl` or 
`name_de/DE.jl` or `name/de_DE.jl` or `name/de/DE.jl`. If more than one of those files exist,
only the first one (in topdown-order of `walkdir`) is used.
"""
function findfiles!(bundle::ResourceBundle{T}, loc::Locale) where {T}
    dir = bundle.path
    name = bundle.name
    flist = Dict{LocalePattern,Pathname}() # 
    prefix = joinpath(dir, name)
    for (root, dirs, files) in walkdir(dir)
        for f in files
            file = joinpath(root, f)
            if startswith(file, prefix)
                locpa = locale_pattern(file, prefix)
                if locpa != nothing && !haskey(flist, locpa) && loc ⊆ locpa
                    push!(flist, locpa => file)
                end
            end
        end
    end
    locs = sort(collect(keys(flist)))
    Cache(collect(loc => flist[loc] for loc in locs), Dict{LocalePattern,Dict{String,T}}())
end

# derive locale pattern from file path
function locale_pattern(f::AbstractString, name::AbstractString)
    if startswith(f, name) && endswith(f, JEND)
        n = sizeof(name)
        m = sizeof(f)
        x = String(f[nextind(f, n, 2):prevind(f, m, JENDL)])

        x = replace(x, Filesystem.path_separator, SEP)
        x = replace(x, SEP2, SEP)
        Locale(String(x))
    else
        nothing
    end
end

"""
    load_file(path, T) -> Dict{String,T}

Load file and create an object of type Dict{String,T}.
The loaded file must contain valid julia code returning a dictionary object of the
requested type.

In case of errors, a warning is printed to logging device and `nothing` is returned.
"""
function load_file(f::AbstractString, T::Type)
    dict = nothing
    d = nothing
    try
        d = include(f)
    catch ex
        warn(ex)
    end

    if isa(d, Union{Vector{T},NTuple{N,Pair},T} where {T<:Pair,N})
        d = Dict(d)
    end
    if isa(d, Dict)
        el = eltype(d).parameters
        if el[1] <: String && el[2] <: T
            dict = d
        else
            warn("Wrong type 'Dict{$(el[1]),$(el[2])}' loaded from '$f'")
        end
    else
        warn("Wrong type '$(typeof(d))' loaded from '$f' is not a dictionary")
    end
    dict
end

import Base.get
"""
    get(bundle::ResourceBundle{T}[, locale], key::String[, default::T]) -> T

Return value associated with the locale and key.

If the locale is not given, use the ResourceBundles current locale. 

If no default value is iven, reutnr `nothing`.
"""
function get(bundle::ResourceBundle{T}, loc::Locale, key::String) where {T}
    cache =  initcache!(bundle, loc)
    flist = cache.list
    rlist = Vector()
    xloc = Locale("")
    val = nothing
    for (locpa, path) in flist
        dict = ensure_dict!(bundle, cache, locpa, path, T, rlist)
        if dict != nothing && haskey(dict, key)
            if val == nothing
                xloc = locpa
                val = dict[key]
            else
                if xloc ⊆ locpa
                    break
                else
                    warn("Ambiguous key '", key, "' for ", loc, " in patterns ", xloc, " and ", locpa)
                end
            end
        end
    end
    clean_cache_list(cache, rlist)
    val
end

function get(bundle::ResourceBundle{T}, loc::Locale, key::String, default::T) where {T}
    x = get(bundle, loc, key)
    ifelse(x == nothing, default, x)
end

get_locale() = Locales.locale(:MESSAGES)
get(bundle::ResourceBundle{T}, key::String, default::T) where {T} = get(bundle, get_locale(), key, default)

import Base.keys
"""
    keys(bundle, locale)
    keys(bundle)

Return array of all defined keys for a specific locale or all possible locales.
"""
function Base.keys(bundle::ResourceBundle{T}, loc::Locale) where {T}
    cache = initcache!(bundle, loc)
    flist = cache.list
    dlist = Vector()
    rlist = Vector()
    val = nothing
    for (locpa, path) in flist
        dict = ensure_dict!(bundle, cache, locpa, path, T, rlist)
        if dict != nothing
            push!(dlist, keys(dict))
        end
    end
    clean_cache_list(cache, rlist)
    unique(Iterators.flatten(dlist))
end

Base.keys(bundle::ResourceBundle{T}) where {T} = keys(bundle, Locales.BOTTOM)

#remove unused files from cache list
function clean_cache_list(cache::Cache, rlist::Vector)
    if !isempty(rlist)
        cache.list = setdiff(cache.list, rlist)
    end
end

# select all potential source dictionaries for given locale. 
function initcache!(bundle::ResourceBundle, loc::Locale)
    get!(bundle.cache, loc) do
        findfiles!(bundle, loc)
    end
end

# load all entries from one dictionary file-
function ensure_dict!(bundle::ResourceBundle, cache::Cache, locpa::LocalePattern, path::String, T::Type, rlist::Vector)
    if haskey(cache.dict, locpa)
        dict = cache.dict[locpa]
    else
        dict = get_dict(bundle, locpa)
        if dict == nothing
            dict = load_file(path, T)
        end
        if dict != nothing
            cache.dict[locpa] = dict
        else
            push!(rlist, locpa)
        end
    end
    dict
end

function get_dict(bundle::ResourceBundle, locpa::LocalePattern)
    for cache in values(bundle.cache)
        if haskey(cache.dict, locpa)
            return cache.dict[locpa]
        end
    end
    nothing
end

