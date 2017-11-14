module ResourceBundles

export Locales, Locale
export ResourceBundles, ResourceBundle, resource_bundle, @resource_bundle
export @tr_str, @trn_str

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

const Locale = Locales.Locale

include("resource_bundle.jl")

include("string.jl")

end # module ResourceBundles
