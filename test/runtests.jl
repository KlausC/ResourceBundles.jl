using ResourceBundles
test = VERSION >= v"0.7-DEV" ? :(using Test) : :(using Base.Test)
eval(test)

cd(Pkg.dir("ResourceBundles"))

# @testset "locale" begin include("locale.jl") end
# @testset "resource_bundle" begin include("resource_bundle.jl") end
@testset "string" begin include("string.jl") end

