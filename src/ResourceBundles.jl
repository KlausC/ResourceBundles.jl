module ResourceBundles

export ResourceBundles, ResourceBundle, resource_bundle, @resource_bundle
export @tr_str, string_to_key

if VERSION < v"0.7-DEV"
    macro __MODULE__()
        current_module()
    end
    export @__MODULE__
end

include("locale.jl")

include("resource_bundle.jl")
include("string.jl")
include("poreader.jl")

include("libc.jl")

end # module ResourceBundles
