using Base.Filesystem

abstract type AbstractResourceBundle end

const DEFAULT_LOCALE = Locales.ROOT
const CURRENT_LOCALE = DEFAULT_LOCALE

set_locale!(loc::Locales.Locale) = CURRENT_LOCALE = loc
get_locale() = CURRENT_LOCALE

const LocalePattern = Locale
const Pathname = String

mutable struct Cache{T}
    list::Vector{Pair{LocalePattern,Pathname}}
    dict::Dict{LocalePattern,Dict{String,T}}
end

struct ResourceBundle{T} <: AbstractResourceBundle
    path::Pathname
    name::String
    typ::Type
    cache::Dict{Locale,Cache{T}}
    ResourceBundle{T}(path::Pathname, name::AbstractString, typ::Type{T}) where T = 
        new(path, string(name), typ, Dict{Locale,Cache{T}}())
end

ResourceBundle(mod::Module, name::AbstractString) = ResourceBundle{String}(resource_path(mod), name, String)

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
    findfiles!(bundle, locale)

Produce list of file pathnames of potential resource file, optionally restricted to the
given locale. The file names are all of the form
`absfilename(path, name) * locpart * ".jl"`
where `locstring` is in the form of a locale-string, with locale-separators replaced by
characters `_` or `/`.

Example: for `Locale("de-DE")`, the resource files could be `name_de_DE.jl` or 
`name_de/DE.jl` or `name/de_DE.jl` or `name/de/DE.jl`. If more than one of those files exist,
only the first one (in topdown-order of `walkdir`) is used.
"""
function findfiles!(bundle::ResourceBundle{T}, for_loc::Locale) where {T}
    dir = bundle.path
    name = bundle.name
    flist = Dict{LocalePattern,Pathname}() # 
    prefix = joinpath(dir, name)
    for (root, dirs, files) in walkdir(dir)
        for f in files
            file = joinpath(root, f)
            if startswith(file, prefix)
                loc = locale_pattern(file, prefix)
                if loc != nothing && !haskey(flist, loc) && for_loc ⊆ loc
                    push!(flist, loc => file)
                end
            end
        end
    end
    locs = sort(collect(keys(flist)))
    ca = Cache(collect(loc => flist[loc] for loc in locs), Dict{LocalePattern,Dict{String,T}}())
end

function locale_pattern(f::AbstractString, name::AbstractString)
    if startswith(f, name) && endswith(f, JEND)
        n = sizeof(name)
        m = sizeof(f)

        x = replace(f, Filesystem.path_separator, SEP)
        x = replace(x, SEP2, SEP)
        Locale(String(x[nextind(x, n, 2):prevind(x, m, JENDL)]))
    else
        nothing
    end
end

function load_file(f::AbstractString, T::Type)
    dict = nothing
    d = nothing
    try
        d = include(f)
    end
    if isa(d, Dict)
        el = eltype(d).parameters
        if el[1] <: String && el[2] <: T
            dict = d
        end
    end
    dict
end

function lookup_resource!(bundle::ResourceBundle{T}, loc::Locale, key::String) where {T}
    cache = get!(bundle.cache, loc) do
        findfiles!(bundle, loc)
    end
    flist = cache.list
    rlist = Vector()
    xloc = Locale("")
    val = nothing
    for (loc, path) in flist
        if haskey(cache.dict, loc)
            dict = cache.dict[loc]
        else
            dict = load_file(path, T)
            if dict != nothing
                cache.dict[loc] = dict
            else
                push!(rlist, loc)
            end
        end
        if dict != nothing && haskey(dict, key)
            if val == nothing
                xloc = loc
                val = dict[key]
            else
                if xloc ⊆ loc
                    break
                else
                    error("ambiguous key '", key, "' locales ", xloc, " and ", loc)
                end
            end
        end
    end
    if !isempty(rlist)
        cache.list = setdiff(flist, rlist)
    end
    if val == nothing && isa(key,T)
        val = key
    end
    val
end

