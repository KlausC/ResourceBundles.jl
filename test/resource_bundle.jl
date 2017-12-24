using Logging

bundle = ResourceBundle(@__MODULE__, "messages2")
@test bundle.path == abspath("resources")

bundle2 = ResourceBundle(ResourceBundles, "bundle")
@test realpath(bundle2.path) == realpath(normpath(pwd(), "resources"))

bundle3 = ResourceBundle(ResourceBundles, "does1not2exist")
@test bundle3.path == "."

bundle4 = ResourceBundle(Test, "XXX")
@test bundle4.path == "."

@test_throws ArgumentError ResourceBundle(Main, "")
@test_throws ArgumentError ResourceBundle(Main, "d_n_e")

const results = Dict(
    (LocaleId("C"), "T0") => "T0",
    (LocaleId("C"), "T1") => "T1 - empty",
    (LocaleId("C"), "T2") => "T2 - empty",
    (LocaleId("C"), "T3") => "T3 - empty",
    (LocaleId("C"), "T4") => "T4 - empty",
    (LocaleId("C"), "T5") => "T5 - empty",
    (LocaleId("C"), "T6") => "T6",
    (LocaleId("C"), "T7") => "T7",

    (LocaleId("en"), "T0") => "T0",
    (LocaleId("en"), "T1") => "T1 - empty",
    (LocaleId("en"), "T2") => "T2 - en",
    (LocaleId("en"), "T3") => "T3 - en",
    (LocaleId("en"), "T4") => "T4 - en",
    (LocaleId("en"), "T5") => "T5 - en",
    (LocaleId("en"), "T6") => "T6",
    (LocaleId("en"), "T7") => "T7",

    (LocaleId("en-US"), "T0") => "T0",
    (LocaleId("en-US"), "T1") => "T1 - empty",
    (LocaleId("en-US"), "T2") => "T2 - en",
    (LocaleId("en-US"), "T3") => "T3 - en_US",
    (LocaleId("en-US"), "T4") => "T4 - en",
    (LocaleId("en-US"), "T5") => "T5 - en_US",
    (LocaleId("en-US"), "T6") => "T6 - en_US",
    (LocaleId("en-US"), "T7") => "T7 - en_US",

    (LocaleId("en-Latn"), "T0") => "T0",
    (LocaleId("en-Latn"), "T1") => "T1 - empty",
    (LocaleId("en-Latn"), "T2") => "T2 - en",
    (LocaleId("en-Latn"), "T3") => "T3 - en",
    (LocaleId("en-Latn"), "T4") => "T4 - en_Latn",
    (LocaleId("en-Latn"), "T5") => "T5 - en_Latn",
    (LocaleId("en-Latn"), "T6") => "T6 - en_Latn",
    (LocaleId("en-Latn"), "T7") => "T7",

    (LocaleId("en-Latn-US"), "T0") => "T0",
    (LocaleId("en-Latn-US"), "T1") => "T1 - empty",
    (LocaleId("en-Latn-US"), "T2") => "T2 - en",
    (LocaleId("en-Latn-US"), "T3") => "T3 - en_US",
    (LocaleId("en-Latn-US"), "T4") => "T4 - en_Latn",
    (LocaleId("en-Latn-US"), "T5") => "T5 - en_Latn_US",
    (LocaleId("en-Latn-US"), "T6") => ("T6 - en_Latn", "Ambiguous"),
    (LocaleId("en-Latn-US"), "T7") => "T7 - en_US",

    (LocaleId("en-x-1"), "T0") => "T0",
    (LocaleId("en-x-1"), "T1") => "T1 - empty",
    (LocaleId("en-x-1"), "T2") => "T2 - en",
    (LocaleId("en-x-1"), "T3") => "T3 - en",
    (LocaleId("en-x-1"), "T4") => "T4 - en",
    (LocaleId("en-x-1"), "T5") => "T5 - en",
    (LocaleId("en-x-1"), "T6") => "T6",
    (LocaleId("en-x-1"), "T7") => "T7",
)

locs = LocaleId.(("C", "en", "en-US", "en-Latn", "en-Latn-US", "en-x-1"))
keya = ((x->"T" * string(x)).(0:7))

log = Test.TestLogger(min_level=Logging.Warn)

locm = locale_id(LC.MESSAGES)

@testset "message lookup for locale $loc and key $key" for loc in locs, key in keya
    res = results[loc, key]
    if isa(res, Tuple)
        r, w = res
    else
        r, w = res, ""
    end
    with_logger(log) do
        @test get(bundle, loc, key, key) == r
        @test test_log(log, w)
    
        set_locale!(loc, LC.MESSAGES)
        @test get(bundle, key, key) == r
        test_log(log, w)
    end
end

set_locale!(locm, LC.MESSAGES)

with_logger(log) do
    @test keys(bundle, LocaleId("")) == ["T1", "T2", "T3", "T4", "T5"]
    @test keys(bundle, LocaleId("de")) == ["T1", "T2", "T3", "T4", "T5"]
    @test keys(bundle2) == []
    @test test_log(log)

    @test keys(bundle, LocaleId("de-us")) == ["T1", "T2", "T3", "T4", "T5"]
    @test test_log(log, "Wrong type 'Dict{Int64,Int64}'")

    @test keys(bundle, LocaleId("de-us-america")) == ["T1", "T2", "T3", "T4", "T5"]
    @test test_log(log, "Wrong type 'String'")

    @test keys(bundle, LocaleId("de-us-america-x-1")) == ["T1", "T2", "T3", "T4", "T5"]
    @test test_log(log, "Wrong type 'Nothing'")

    @test keys(bundle3, LocaleId("")) == String[]
    @test keys(bundle) == ["T1", "T2", "T3", "T4", "T5", "T6", "T7", "hello"]
end
@test resource_bundle(@__MODULE__, "messages2") === RB_messages2
@test resource_bundle(@__MODULE__, "bundle") === RB_bundle
@test @resource_bundle("d1n2e").path == ""

bundlea = @resource_bundle("bundle")
@test bundlea === RB_bundle

# Test in submodule Main.XXX
module XXX
    using ResourceBundles
    eval(Main.test)
    @test @resource_bundle("messages2") === RB_messages2
    @test Main.XXX.RB_messages2 === Main.RB_messages2
    @test @resource_bundle("bundle") === RB_bundle
    @test Main.XXX.RB_bundle !== Main.RB_bundle
    # Test in submodule Main.XXX.YYY
    module YYY
    using ResourceBundles
    eval(Main.test)
        @test @resource_bundle("bundle") === RB_bundle
        @test Main.XXX.YYY.RB_bundle === Main.XXX.RB_bundle
    end
end

@test resource_bundle(ResourceBundles, "messages2") === ResourceBundles.RB_messages2
@test resource_bundle(ResourceBundles, "bundle") === ResourceBundles.RB_bundle

bundlea = eval(ResourceBundles, :(@resource_bundle("bundle")))
@test bundlea === ResourceBundles.RB_bundle

# test in submodule ResourceBundles.XXX
eval(ResourceBundles, :(module XXX
        using ResourceBundles
        eval(Main.test)
        
        @test string(@__MODULE__) == "ResourceBundles.XXX" 
        @test @resource_bundle("messages2") === RB_messages2
        @test ResourceBundles.XXX.RB_messages2 === ResourceBundles.RB_messages2
        @test @resource_bundle("bundle") === RB_bundle
        @test ResourceBundles.XXX.RB_bundle !== ResourceBundles.RB_bundle
    end )
)

lpa = ResourceBundles.locale_pattern

@test lpa(".jl") == LocaleId("C")
@test lpa("-en.jl") == LocaleId("en")
@test lpa("_en.jl") == LocaleId("en")
@test lpa("/en.jl") == LocaleId("en")
@test lpa("-en/.jl") == LocaleId("en")
@test lpa("/en/.jl") == LocaleId("en")
@test lpa("/en./jl") == nothing

