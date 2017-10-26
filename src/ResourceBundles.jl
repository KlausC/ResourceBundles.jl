module ResourceBundles

export Locales, Locale
#export ParserCombinator
export ResourceBundles, ResourceBundle

# include("locale_iso_data.jl")
include("locale.jl")

const Locale = Locales.Locale

# include("parser_combinator.jl")
# include("parse_langtag.jl")
include("resource_bundle.jl")

include("string.jl")

end # module ResourceBundles
