module ResourceBundles

export Locale
export ResourceBundles, ResourceBundle, resource_bundle, @resource_bundle
export @tr_str, @trn_str
export read_po_file

if VERSION < v"0.7-DEV"
    macro __MODULE__()
        current_module()
    end
    export @__MODULE__

    function Base.nextind(s::AbstractString, i::Int, k::Int)
        while k > 0
            i = nextind(s, i)
            k -= 1
        end
        i
    end
    function Base.prevind(s::AbstractString, i::Int, k::Int)
        while k > 0
            i = prevind(s, i)
            k -= 1
        end
        i
    end
end

include("locale.jl")

include("resource_bundle.jl")
include("string.jl")
include("poreader.jl")

end # module ResourceBundles
