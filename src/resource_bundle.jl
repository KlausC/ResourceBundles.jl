abstract type AbstractResourceBundle end

const DEFAULT_LOCALE = Locales.ROOT
const CURRENT_LOCALE = DEFAULT_LOCALE

set_locale!(loc::Locales.Locale) = CURRENT_LOCALE = loc
get_locale() = CURRENT_LOCALE

struct PropertyResourceBundle <: AbstractResourceBundle
    path::String
    name::String
    locale::Locale
end

struct ListResourceBundle <: AbstractResourceBundle
    name::String
    locale::String
end

ResourceBundle(name::String...) = ResourceBundle(nothing, name...)
function ResourceBundle(loc::Union{Locale,Void}, name::String...)
    b = get_ListResourceBundle(loc, name...)
    b == nothing && (b = get_PropertyResourceBundle(loc, name...))
    b == nothing && loc !== nothing && (b = ResourceBundle(nothing, name...))
    b == nothing && throw(ArgumentError("no resource bundle for $n - $loc found"))
    b
end

name(rb::AbstractResourceBundle) = rb.name
locale(rb::AbstractResourceBundle) = rb.loc

function get_ListResourceBundle(loc::Locale, m::Module, name::String)
    path = Pkg.Dir.path(name)
end

SEP = '_'
SEP2 = '-'
JEND = ".jl"
JENDL = length(JEND)

using Base.Filesystem

const NULLDICT = Dict()

function findfiles(dir::AbstractString, name::AbstractString, for_loc::Locale=Locale(""))
    flist = Dict{Locale,String}()
    prefix = joinpath(dir, name)
    for (root, dirs, files) in walkdir(dir)
        for f in files
            file = joinpath(root, f)
            if startswith(file, prefix)
                loc = locale_pattern(file, prefix)
                if loc != nothing && !haskey(flist, loc) && loc ⊆ for_loc
                    push!(flist, loc => file)
                end
            end
        end
    end
    locs = sort(collect(keys(flist)))
    res = collect((loc, flist[loc], NULLDICT) for loc in locs)
    Vector{Tuple{Locale,String,Dict}}(res)
end

const LocalePathDict{T} = Tuple{Locale,String,Union{Void,Dict{String,T}}}

function locale_pattern(f::AbstractString, name::AbstractString)
    if startswith(f, name) && endswith(f, JEND)
        n = sizeof(name)
        m = sizeof(f)

        x = replace(f, Filesystem.path_separator, SEP)
        x = replace(f, '-', SEP)
        Locale(String(x[nextind(x, n, 2):prevind(x, m, JENDL)]))
    else
        nothing
    end
end

function load_file(f::AbstractString, T::Type)
    try
        #str = read(f, String)
        #ex = parse(replace(str, r"\n+", "\n"))
        #dict = eval(ex)
        dict = include(f)
    catch exc
        dict = Dict{String, T}()
    end
    if isa(dict, Dict)
        el = eltype(dict).parameters
        if !(el[1] <: String && el[2] <: T)
            dict = Dict{String,T}()
        end
    else
        dict = Dict{String,T}()
    end
    dict
end

function lookup_resource!(flist::Vector{X}, key::String,::Type{T}) where {T,X<:Tuple}
    i = 0
    noloc = Locale("und-nolocale")
    xloc = noloc
    val = nothing
    for (loc, path, dict) in flist
        i += 1
        if dict === NULLDICT
            dict = load_file(path, T)
            flist[i] = (loc, path, dict)
        end
        if haskey(dict, key)
            if xloc == noloc
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
    if xloc == noloc && isa(key,T)
        val = key
    end
    val
end

