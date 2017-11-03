using ResourceBundles
if VERSION >= v"0.7-DEV" using Test else using Base.Test end

@testset "locale" begin include("locale.jl") end
@testset "resource_bundle" begin include("resource_bundle.jl") end
@testset "string" begin include("string.jl") end

