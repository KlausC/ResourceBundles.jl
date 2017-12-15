module ResourceBundles

export ResourceBundles, ResourceBundle, resource_bundle, @resource_bundle
export LocaleId
export @tr_str, string_to_key

if VERSION < v"0.7-DEV"
    macro __MODULE__()
        current_module()
    end
    export @__MODULE__
end

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
