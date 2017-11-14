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
    lock::Threads.RecursiveSpinLock
    function ResourceBundle{T}(path::Pathname, name::AbstractString, typ::Type{T}) where T
        ( !isempty(name) && all(isalnum, name) ) ||
            throw(ArgumentError("resource names require alphanumeric but is `$name`"))
        new(path, string(name), typ, Dict{Locale,Cache{T}}(), Threads.RecursiveSpinLock())
    end
end

function ResourceBundle(mod::Module, name::AbstractString)
    ResourceBundle{Any}(resource_path(mod, name), name, Any)
end

function ResourceBundle(mod::Module, name::AbstractString, T::Type) 
    ResourceBundle{T}(resource_path(mod, name), name, T)
end

const Empty = ResourceBundle{Any}("", "empty", Any)

const SEP = '_'
const SEP2 = '-'
const JEND = ".jl"          # extension of resource file
const JENDL = length(JEND)
const RESOURCES = "resources"   # name of subdirectory
const JRB = "JULIA_RESOURCE_BASE" # enviroment variable
const LOCALE_ID = ".LOCALE_ID"  # invisible key in resource dictionaries

"""
    resource_path(module, name) -> String

Return path name of resource directory for a module containing data for `name`.
If top module is `Main` the path is derived from enviroment `JULIA_RESOURCE_BASE`.
If `JULIA_HOME/../../stdlib/<module>/resources` is a directory, we assume
the resources of a module in the standard library.
Otherwise the directory `Pkg.dir()/<module>/resources` is selected; that is
the usual case for user defined modules.
Submodules may have specific resource files. They are located in subdirectories
of the `resources` directory with path names corresponding to submodule name.
example: Module `MyModule.X.Y` can store specific resource files in
`.../MyModule/resources/X/Y`. If for a given name, no resources are found in the
deepest directory, fallback to previous directory happens. In the example, the
resources are searched first in `resources/X/Y`, then in `resources/X`, then in `resources`.
Nevertheless the resources for one name are always taken from only one subdirectory.
"""
function resource_path(mod::Module, name::AbstractString)
    mp = module_split(mod)
    
    if isempty(mp) || mp[1] == :Main
        base = get(ENV, JRB, pwd())
    else
        base = normpath(package_path(mp[1]), string(mp[1]))
    end
    path = "."
    prefix = normpath(base, RESOURCES)
    if is_resourcepath(prefix, name)
        n = length(mp)
        path = prefix
        for i = 2:n
            prefix = joinpath(prefix, mod2file(mp[i]))
            if is_resourcepath(prefix, name)
                path = prefix
            end
        end         
    end
    path
end

"""
    package_path(mod)

Return installation directory for module `mod`.
"""
function package_path(name)
    name = string(name)
    path1 = normpath(JULIA_HOME, "..", "..", "stdlib", name)
    path2 = Pkg.dir(name)
    is1 = isdir(path1)
    is2 = isdir(path2)
    is1 && is2 && warn("module '$name' has same name as stdlib module")
    splitdir(is2 ? path2 : is1 ? path1 : name)[1]
end


"""
    is_resourcepath(path, name)

Check if directory `path` contains subdirectory `name` or a file `name_*` or `name.jl`.
Path may be relative or absolute. Name may be string or symbol.
"""
function is_resourcepath(path::AbstractString, name::AbstractString)
    isdir(path) || return false
    isdir(joinpath(path, string(name))) && return true
    stp = name * string(SEP)
    res = any(f -> ( startswith(f, stp) || splitext(f) == (name, JEND) ), readdir(path))
    res
end

"""
    module_split(mod::Module)

Return the list of module names of a module hierarchy.
Example: `Base.Iterators -> [:Main,:Base,:Iterators]`.
"""
function module_split(mod::Module)
    fn = fullname(mod)
    VERSION >= v"0.7-DEV" && return fn
    isempty(fn) || !isdir(Pkg.dir(string(fn[1]))) ? (:Main, fn...) : fn
end

function module_root(mod::Module)
    p = module_parent(mod)
    p === mod && return mod
    module_root(p)
end

"""
    findfiles(bundle, locale) -> Cache 

Produce cache object, which contains list of pairs of locale patterns and pathnames of
potential resource file, restricted to the given locale. The file names are all of the form
`absfilename(path, name) * locstring * ".jl"`
where `locstring` is in the form of a locale-pattern, with locale-separators replaced by
characters `_` or `/`.
The list is sorted with most specific locale-pattern first. The list needs not be totally
ordered (with respect to `⊆`, which allows ambiguous

Example: for `Locale("de-DE")`, the resource files could be `name_de_DE.jl` or 
`name_de/DE.jl` or `name/de_DE.jl` or `name/de/DE.jl`. If more than one of those files exist,
only the first one (in topdown-order of `walkdir`) is used.
"""
function findfiles(bundle::ResourceBundle{T}, loc::Locale) where {T}
    dir = normpath(bundle.path)
    name = bundle.name
    flist = Dict{LocalePattern,Pathname}() # 
    prefix = joinpath(dir, name)
    if dir != "."
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

If no default value is given, return `nothing`.
"""
function get(bundle::ResourceBundle{T}, loc::Locale, key::String) where {T}
  try
    lock(bundle.lock)    
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
  finally
    unlock(bundle.lock)
  end
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
  try
    lock(bundle.lock)    
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
    if isempty(dlist)
        String[]
    else
        sort!(unique(Iterators.filter(x -> x != LOCALE_ID, Iterators.flatten(dlist))))
    end
  finally
    unlock(bundle.lock)
  end
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
        findfiles(bundle, loc)
    end
end

# load all entries from one dictionary file.
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
            dict[LOCALE_ID] = string(locpa)
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

mod2file(name::Symbol) = string("M-", name)

is_module_specific(mod::Module, path) = is_module_specific(module_split(mod), path)

function is_module_specific(mp::NTuple{N,Symbol}, path::AbstractString) where N
    dir, file = splitdir(path)
    isrootmod = length(mp) <= 1
    isabspath(dir) &&
    (( isrootmod && file == RESOURCES ) ||
     (!isrootmod && file == mod2file(mp[end]) && is_module_specific(mp[1:end-1], dir) )) 
end

const LOCK = Threads.RecursiveSpinLock()
function define_resource_variable(mod::Module, varname::Symbol, bundlename::AbstractString)
  try
    lock(LOCK)
    if !isdefined(mod, varname)
        path = resource_path(mod, bundlename)
        if is_module_specific(mod, path)
            eval(mod, :(const $varname = ResourceBundle($mod, $bundlename, Any)))
        elseif isabspath(path)
            parent = module_parent(mod)
            prev = define_resource_variable(parent, varname, bundlename)
            eval(mod, :(const $varname = $parent.$varname))
        else
            eval(mod, :(const $varname = ResourceBundles.Empty))
        end
    else
        eval(mod, varname)
    end
  finally
    unlock(LOCK)
  end
end

"""
    resource_bundle(module, name) 
    @resource_bundle name

Create global variable named `RB_<name>` in module `mod`, which contains corresponding
resource bundle. If the variable preexists, just return it. The macro envocation is
equivalent to calling `resource_bundle(@__MODULE__, name)`.
"""

function resource_bundle(mod::Module, name::AbstractString)
    define_resource_variable(mod, Symbol("RB_", name), name)
end

macro resource_bundle(name::AbstractString)
    mod = VERSION < v"0.7-DEV" ? current_module() : __module__
    :(resource_bundle($mod, $name))
end

