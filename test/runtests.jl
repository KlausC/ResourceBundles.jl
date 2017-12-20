test = VERSION >= v"0.7-DEV" ? :(using Test) : :(using Base.Test)
eval(test)

using Logging

using ResourceBundles
import ResourceBundles: ROOT, BOTTOM, create_locid
import ResourceBundles: set_locale!, load_file

cd(Pkg.dir("ResourceBundles"))

# test if logger contains text in a message
function test_log(log::Test.TestLogger)
    res = isempty(log.logs)
    empty!(log.logs)
    res
end
function test_log(log::Test.TestLogger, text::AbstractString)
    isempty(text) && return test_log(log)
    conmess(x::Test.LogRecord) = contains(x.message, text)
    res = any(conmess.(log.logs))
    empty!(log.logs)
    res
end

@testset "locale" begin include("locale.jl") end
@testset "resource_bundle" begin include("resource_bundle.jl") end
@testset "string" begin include("string.jl") end
@testset "libc" begin include("libc.jl") end
@testset "clocale" begin include("clocale.jl") end
@testset "localetrans" begin include("localetrans.jl") end

