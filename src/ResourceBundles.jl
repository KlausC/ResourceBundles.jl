module ResourceBundles

export ResourceBundle, PropertyResourceBundle, ListResourceBundle
export get_locale, set_locale!, get_String

export Locales, Locale
export ParserCombinator

include("locale_iso_data.jl")
include("locale.jl")

const Locale = Locales.Locale

include("parser_combinator.jl")
include("parse_langtag.jl")
include("resource_bundle.jl")
end # module ResourceBundles
