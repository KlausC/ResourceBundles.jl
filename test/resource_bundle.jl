using ResourceBundles

bundle = ResourceBundle(@__MODULE__, "messages")

const results = Dict(
    (Locale(""), "T0") => "T0",
    (Locale(""), "T1") => "T1 - empty",
    (Locale(""), "T2") => "T2 - empty",
    (Locale(""), "T3") => "T3 - empty",
    (Locale(""), "T4") => "T4 - empty",
    (Locale(""), "T5") => "T5 - empty",
    (Locale(""), "T6") => "T6",
    (Locale(""), "T7") => "T7",

    (Locale("en"), "T0") => "T0",
    (Locale("en"), "T1") => "T1 - empty",
    (Locale("en"), "T2") => "T2 - en",
    (Locale("en"), "T3") => "T3 - en",
    (Locale("en"), "T4") => "T4 - en",
    (Locale("en"), "T5") => "T5 - en",
    (Locale("en"), "T6") => "T6",
    (Locale("en"), "T7") => "T7",

    (Locale("en-US"), "T0") => "T0",
    (Locale("en-US"), "T1") => "T1 - empty",
    (Locale("en-US"), "T2") => "T2 - en",
    (Locale("en-US"), "T3") => "T3 - en_US",
    (Locale("en-US"), "T4") => "T4 - en",
    (Locale("en-US"), "T5") => "T5 - en_US",
    (Locale("en-US"), "T6") => "T6 - en_US",
    (Locale("en-US"), "T7") => "T7 - en_US",

    (Locale("en-Latn"), "T0") => "T0",
    (Locale("en-Latn"), "T1") => "T1 - empty",
    (Locale("en-Latn"), "T2") => "T2 - en",
    (Locale("en-Latn"), "T3") => "T3 - en",
    (Locale("en-Latn"), "T4") => "T4 - en_Latn",
    (Locale("en-Latn"), "T5") => "T5 - en_Latn",
    (Locale("en-Latn"), "T6") => "T6 - en_Latn",
    (Locale("en-Latn"), "T7") => "T7",

    (Locale("en-Latn-US"), "T0") => "T0",
    (Locale("en-Latn-US"), "T1") => "T1 - empty",
    (Locale("en-Latn-US"), "T2") => "T2 - en",
    (Locale("en-Latn-US"), "T3") => "T3 - en_US",
    (Locale("en-Latn-US"), "T4") => "T4 - en_Latn",
    (Locale("en-Latn-US"), "T5") => "T5 - en_Latn_US",
    (Locale("en-Latn-US"), "T6") => ("T6 - en_Latn", "Ambiguous"),
    (Locale("en-Latn-US"), "T7") => "T7 - en_US",

    (Locale("en-x-1"), "T0") => "T0",
    (Locale("en-x-1"), "T1") => "T1 - empty",
    (Locale("en-x-1"), "T2") => "T2 - en",
    (Locale("en-x-1"), "T3") => "T3 - en",
    (Locale("en-x-1"), "T4") => "T4 - en",
    (Locale("en-x-1"), "T5") => "T5 - en",
    (Locale("en-x-1"), "T6") => "T6",
    (Locale("en-x-1"), "T7") => "T7",
)

locs = Locale.(("", "en", "en-US", "en-Latn", "en-Latn-US", "en-x-1"))
keya = ((x->"T" * string(x)).(0:7))

io = IOBuffer()
logging(io, kind = :warn)

@testset "message lookup for locale $loc and key $key" for loc in locs, key in keya
    res = results[loc, key]
    if isa(res, Tuple)
        r, w = res
    else
        r, w = res, ""
    end
    @test get(bundle, loc, key, key) == r
    warn = String(take!(io))
    @test contains(warn, w)
end

take!(io)
@test sort(keys(bundle, Locale(""))) == ["T1", "T2", "T3", "T4", "T5"]
@test String(take!(io)) == ""
@test sort(keys(bundle, Locale("de-us"))) == ["T1", "T2", "T3", "T4", "T5"]
@test contains(String(take!(io)), "Wrong type 'Dict{Int64,Int64}'")
@test sort(keys(bundle, Locale("de-us-america"))) == ["T1", "T2", "T3", "T4", "T5"]
@test contains(String(take!(io)), "Wrong type 'String'")
@test sort(keys(bundle, Locale("de-us-america-x-1"))) == ["T1", "T2", "T3", "T4", "T5"]
@test contains(String(take!(io)), "Wrong type 'Void'")


