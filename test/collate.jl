
using Test
using ResourceBundles
using ResourceBundles.CLocales

function localized_isless(loc::LocaleId)
    function lt(a::AbstractString, b::AbstractString)
        strcollate(a, b, loc) < 0
    end
end

