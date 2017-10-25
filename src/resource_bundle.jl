using Base.Filesystem

const DEFAULT_LOCALE = Locales.default_locale(:LC_MESSAGES)
const CURRENT_LOCALE = DEFAULT_LOCALE

"""
    set_locale!(locale)

Set current locale of module ResourceBundles. If locale is not given, reset to initial default. 
"""
set_locale!(loc::Locales.Locale) = CURRENT_LOCALE = loc
set_locale!() = CURRENT_LOCALE = DEFAULT_LOCALE 

"""
    get_locale() -> Local

Return current locale of module ResourceBundles.
"""
get_locale() = CURRENT_LOCALE

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
    ResourceBundle{T}(path::Pathname, name::AbstractString, typ::Type{T}) where T = 
        new(path, string(name), typ, Dict{Locale,Cache{T}}())
end

ResourceBundle(mod::Module, name::AbstractString) = ResourceBundle{String}(resource_path(mod), name, String)
ResourceBundle(mod::Module, name::AbstractString, T::Type) = ResourceBundle{T}(resource_path(mod), name, T)

SEP = '_'
SEP2 = '-'
JEND = ".jl"
JENDL = length(JEND)

"""
    resource_path(module) -> String

Return absolute path name of resource directory for a module.
If no module directory is found, return `"$JULIA_HOME/../../resources"`.
"""
function resource_path(mod::Module)
    source = Base.find_in_path(string(module_name(mod)))
    normpath(joinpath(source == nothing ? JULIA_HOME : source, "..", "..", "resources"))
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
    if isa(d, Dict)
        el = eltype(d).parameters
        if el[1] <: String && el[2] <: T
            dict = d
        else
            warn("Wrong type $el of dictionary loaded from '$f'")
        end
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
        dict = ensure_dict!(cache, locpa, path, T, rlist)
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
    if !isempty(rlist)
        cache.list = setdiff(flist, rlist)
    end
    if val == nothing && isa(default,T)
        val = default
    end
    val
end

function get(bundle::ResourceBundle{T}, loc::Locale, key::String, default::T) where {T}
    x = get(bundle, loc, key)
    ifelse(x == nothing, default, key)
end

get(bundle::ResourceBundle, key::String) = get(bundle, get_locale(), key)
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
        dict = ensure_dict!(cache, locpa, path, T, rlist)
        if dict != nothing
            push!(dlist, keys(dict))
        end
    end
    if !isempty(rlist)
        cache.list = setdiff(flist, rlist)
    end
    unique(Iterators.flatten(dlist))
end

Base.keys(bundle::ResourceBundle{T}) where {T} = keys(bundle, Locale())

# select all potential source dictionaries for given locale. 
function initcache!(bundle::ResourceBundle, loc::Locale)
    get!(bundle.cache, loc) do
        findfiles!(bundle, loc)
    end
end

# load all entries from one dictionary file-
function ensure_dict!(cache::Cache, locpa::LocalePattern, path::String, T::Type, rlist::Vector)
    if haskey(cache.dict, locpa)
        dict = cache.dict[locpa]
    else
        dict = load_file(path, T)
        if dict != nothing
            cache.dict[locpa] = dict
        else
            push!(rlist, locpa)
        end
    end
    dict
end

