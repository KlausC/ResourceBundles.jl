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

function findfiles(dir::AbstractString, name::AbstractString)
    flist = Dict{String,String}()
    prefix = joinpath(dir, name)
    for (root, dirs, files) in walkdir(dir)
        for f in files
            file = joinpath(root, f)
            if startswith(file, prefix)
                loc = location_part(file, prefix)
                if loc != nothing && !haskey(flist, loc)
                    push!(flist, loc => file)
                end
            end
        end
    end
    flist
end

function location_part(f::AbstractString, name::AbstractString)
    if startswith(f, name) && endswith(f, JEND)
        n = sizeof(name)
        m = sizeof(f)

        x = replace(f, Filesystem.path_separator, SEP)
        x = replace(f, '-', SEP)
        String(x[nextind(x, n, 2):prevind(x, m, JENDL)])
    else
        nothing
    end
end




