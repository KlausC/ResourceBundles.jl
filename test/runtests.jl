test = VERSION >= v"0.7-DEV" ? :(using Test) : :(using Base.Test)
eval(test)

using Logging

using ResourceBundles
import ResourceBundles: ROOT, BOTTOM, create_locid
import ResourceBundles: set_locale!, load_file

cd(Pkg.dir("ResourceBundles"))

# test if logger contains text in a message; finally with:clear logger.
function test_log(log::Test.TestLogger, text::AbstractString)
    try
        isempty(text) && return test_log(log)
        conmess(x::Test.LogRecord) = contains(x.message, text)
        any(conmess.(test_log_filter(log)))
    finally
        empty!(log.logs)
    end
end

test_log(log::Test.TestLogger) = isempty(test_log_filter(log))
# ignore messages from Core module
test_log_filter(log::Test.TestLogger) = filter(lr->lr._module != Core, log.logs)


@testset "types" begin include("types.jl") end
@testset "locale" begin include("locale.jl") end
@testset "resource_bundle" begin include("resource_bundle.jl") end
@testset "string" begin include("string.jl") end
@testset "libc" begin include("libc.jl") end
@testset "clocale" begin include("clocale.jl") end
@testset "localetrans" begin include("localetrans.jl") end

