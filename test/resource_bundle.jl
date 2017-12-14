
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
    (LangTag(""), "T0") => "T0",
    (LangTag(""), "T1") => "T1 - empty",
    (LangTag(""), "T2") => "T2 - empty",
    (LangTag(""), "T3") => "T3 - empty",
    (LangTag(""), "T4") => "T4 - empty",
    (LangTag(""), "T5") => "T5 - empty",
    (LangTag(""), "T6") => "T6",
    (LangTag(""), "T7") => "T7",

    (LangTag("en"), "T0") => "T0",
    (LangTag("en"), "T1") => "T1 - empty",
    (LangTag("en"), "T2") => "T2 - en",
    (LangTag("en"), "T3") => "T3 - en",
    (LangTag("en"), "T4") => "T4 - en",
    (LangTag("en"), "T5") => "T5 - en",
    (LangTag("en"), "T6") => "T6",
    (LangTag("en"), "T7") => "T7",

    (LangTag("en-US"), "T0") => "T0",
    (LangTag("en-US"), "T1") => "T1 - empty",
    (LangTag("en-US"), "T2") => "T2 - en",
    (LangTag("en-US"), "T3") => "T3 - en_US",
    (LangTag("en-US"), "T4") => "T4 - en",
    (LangTag("en-US"), "T5") => "T5 - en_US",
    (LangTag("en-US"), "T6") => "T6 - en_US",
    (LangTag("en-US"), "T7") => "T7 - en_US",

    (LangTag("en-Latn"), "T0") => "T0",
    (LangTag("en-Latn"), "T1") => "T1 - empty",
    (LangTag("en-Latn"), "T2") => "T2 - en",
    (LangTag("en-Latn"), "T3") => "T3 - en",
    (LangTag("en-Latn"), "T4") => "T4 - en_Latn",
    (LangTag("en-Latn"), "T5") => "T5 - en_Latn",
    (LangTag("en-Latn"), "T6") => "T6 - en_Latn",
    (LangTag("en-Latn"), "T7") => "T7",

    (LangTag("en-Latn-US"), "T0") => "T0",
    (LangTag("en-Latn-US"), "T1") => "T1 - empty",
    (LangTag("en-Latn-US"), "T2") => "T2 - en",
    (LangTag("en-Latn-US"), "T3") => "T3 - en_US",
    (LangTag("en-Latn-US"), "T4") => "T4 - en_Latn",
    (LangTag("en-Latn-US"), "T5") => "T5 - en_Latn_US",
    (LangTag("en-Latn-US"), "T6") => ("T6 - en_Latn", "Ambiguous"),
    (LangTag("en-Latn-US"), "T7") => "T7 - en_US",

    (LangTag("en-x-1"), "T0") => "T0",
    (LangTag("en-x-1"), "T1") => "T1 - empty",
    (LangTag("en-x-1"), "T2") => "T2 - en",
    (LangTag("en-x-1"), "T3") => "T3 - en",
    (LangTag("en-x-1"), "T4") => "T4 - en",
    (LangTag("en-x-1"), "T5") => "T5 - en",
    (LangTag("en-x-1"), "T6") => "T6",
    (LangTag("en-x-1"), "T7") => "T7",
)

locs = LangTag.(("", "en", "en-US", "en-Latn", "en-Latn-US", "en-x-1"))
keya = ((x->"T" * string(x)).(0:7))

io = IOBuffer()
logging(io, kind = :warn)

locm = locale(:MESSAGES)

@testset "message lookup for locale $loc and key $key" for loc in locs, key in keya
    res = results[loc, key]
    if isa(res, Tuple)
        r, w = res
    else
        r, w = res, ""
    end
    @test get(bundle, loc, key, key) == r

    set_locale!(:MESSAGES, loc)
    @test get(bundle, key, key) == r

    warn = String(take!(io))
    @test contains(warn, w)
end

set_locale!(:MESSAGES, locm)

take!(io)
@test keys(bundle, LangTag("")) == ["T1", "T2", "T3", "T4", "T5"]
@test keys(bundle, LangTag("de")) == ["T1", "T2", "T3", "T4", "T5"]
@test keys(bundle2) == []
@test String(take!(io)) == ""

@test keys(bundle, LangTag("de-us")) == ["T1", "T2", "T3", "T4", "T5"]
@test contains(String(take!(io)), "Wrong type 'Dict{Int64,Int64}'")
@test keys(bundle, LangTag("de-us-america")) == ["T1", "T2", "T3", "T4", "T5"]
@test contains(String(take!(io)), "Wrong type 'String'")
@test keys(bundle, LangTag("de-us-america-x-1")) == ["T1", "T2", "T3", "T4", "T5"]
@test contains(String(take!(io)), "Wrong type 'Void'")
@test keys(bundle3, LangTag("")) == String[]
@test keys(bundle) == ["T1", "T2", "T3", "T4", "T5", "T6", "T7", "hello"]

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

@test lpa(".jl") == LangTag("")
@test lpa("-en.jl") == LangTag("en")
@test lpa("_en.jl") == LangTag("en")
@test lpa("/en.jl") == LangTag("en")
@test lpa("-en/.jl") == LangTag("en")
@test lpa("/en/.jl") == LangTag("en")
@test lpa("/en./jl") == nothing

