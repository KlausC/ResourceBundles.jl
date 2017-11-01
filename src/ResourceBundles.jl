module ResourceBundles

export Locales, Locale
export ResourceBundles, ResourceBundle
export @tr_str, @trn_str

include("locale.jl")

const Locale = Locales.Locale

include("resource_bundle.jl")

include("string.jl")

end # module ResourceBundles
