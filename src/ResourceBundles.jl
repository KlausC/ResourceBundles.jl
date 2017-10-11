module ResourceBundles

export ResourceBundle, PropertyResourceBundle, ListResourceBundle
export get_locale, set_locale!, get_String

export Locales, Locale
export ParserCombinator

include("locale_iso_data.jl")
include("base_locale.jl")
include("parser_combinator.jl")
include("parse_langtag.jl")

const Locale = Locales.Locale

abstract type AbstractResourceBundle end

const DEFAULT_LOCALE = Locales.ROOT
const CURRENT_LOCALE = DEFAULT_LOCALE

set_locale!(loc::Locales.Locale) = CURRENT_LOCALE = loc
get_locale() = CURRENT_LOCALE

struct PropertyResourceBundle <: AbstractResourceBundle
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

function get_ListResourceBundle(loc::Union{Locale,Void}, name::String...)
    path = Pkg.Dir.path(name...)
end

end # module ResourceBundles
