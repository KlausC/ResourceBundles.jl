module ResourceBundles

export ResourceBundles
export ResourceBundle, resource_bundle, @resource_bundle
export LocaleId, LC
export @tr_str, string_to_key

if VERSION < v"0.7-DEV"
    macro __MODULE__()
        current_module()
    end
    export @__MODULE__
end

if VERSION < v"0.7-DEV.3176"
    const Nothing = Void
    const Cvoid = Void
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
