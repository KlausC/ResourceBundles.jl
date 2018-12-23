module ResourceBundles

export ResourceBundles
export ResourceBundle, resource_bundle, @resource_bundle
export LocaleId, LC
export @tr_str, string_to_key

include("types.jl")
include("constants.jl")
include("locale_iso_data.jl")
include("resource_bundle.jl")
include("localetrans.jl")
include("locale.jl")

include("string.jl")
include("poreader.jl")

include("clocale.jl")

end # module ResourceBundles
