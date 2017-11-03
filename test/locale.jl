using ResourceBundles.Locales

# Construct Locale from language tags
@test Locale("") === Locales.ROOT
@test Locale("en") === Locales.ENGLISH
@test Locale("en-US") === Locales.US
@test string(Locale("de")) == "de"
@test string(Locale("de_latn")) == "de-Latn"
@test string(Locale("de-de")) == "de-DE"
@test string(Locale("de-111")) == "de-111"
@test string(Locale("de-variAnt1")) == "de-variant1"
@test string(Locale("de-variAnt1-varia2")) == "de-variant1-varia2"
@test string(Locale("de-1erw-varia2")) == "de-1erw-varia2"
@test string(Locale("de-a_aB")) == "de-a-ab"
@test string(Locale("DE_X_1_UZ_A_B")) == "de-x-1-uz-a-b"
@test string(Locale("DE_latn_de")) == "de-Latn-DE"
@test string(Locale("DE_latn_de-variant1")) == "de-Latn-DE-variant1"
@test string(Locale("DE_latn_de-a-uu-11")) == "de-Latn-DE-a-uu-11"
@test string(Locale("DE_latn_de-varia-a-uu-11")) == "de-Latn-DE-varia-a-uu-11"
@test string(Locale("DE_latn_de-varia-a-uu-11")) == "de-Latn-DE-varia-a-uu-11"
@test string(Locale("DE_latn_de-1var-a-uu-11")) == "de-Latn-DE-1var-a-uu-11"
@test string(Locale("DE_latn_de-1va2-a-uu-11")) == "de-Latn-DE-1va2-a-uu-11"
@test string(Locale("DE_latn_de-x-11-a-uu-11")) == "de-Latn-DE-x-11-a-uu-11"
@test string(Locale("DE_latn_de-b-22-a-uu-11")) == "de-Latn-DE-a-uu-11-b-22"
@test string(Locale("DE_latn_de-z-22-a-uu-11")) == "de-Latn-DE-a-uu-11-z-22"

@test string(Locale("zh-han")) == "han"
@test string(Locale("deu")) == "de"

@test Locale("en-a-aa-b-bb") ⊆ Locale("en-b-bb")
@test hash(Locale("is-a-aa-b-bb")) == hash(Locale("is-b-bb-a-aa"))
@test Locale("is-a-aa-b-bb") === Locale("is-b-bb-a-aa")
@test Locale("C") === Locale("")

# exceptions
create2(l="", lex=String[], s="", r="", v=String[], d=Dict{Char,Vector{Symbol}}()) =
    Locales.create(l, lex, s, r, v, d)

@test_throws ArgumentError#=("missing language prefix")=# Locale("a-ab")
@test_throws ArgumentError#=("no language prefix 'a'")=# Locale("a", "")
@test_throws ArgumentError#=("only one language extension allowed 'de-abc-def'")=# Locale("de-abc-def")
@test_throws ArgumentError#=("no language exensions allowed 'abcd-def'")=# create2("abcd", ["def"])
@test_throws ArgumentError#=("no script 'Abc'")=# Locale("ab", "abc", "de")
@test_throws ArgumentError#=("no region 'DEF'")=# Locale("ab", "abcd", "def")
@test_throws ArgumentError#=("no variants 'vari'")=# create2("ab", String[], "", "", ["vari"])
@test_throws ArgumentError#=("no variants '1va'")=# create2("ab", String[], "", "", ["1va"])
@test_throws ArgumentError#=("no variants 'asdfghjkl'")=# create2("ab", String[], "", "", ["asdfghjkl"])
@test_throws ArgumentError#=("no variants '1990-asdfghjkl'")=# create2("ab", String[], "", "", ["1990", "asdfghjkl"])
@test_throws ArgumentError#=("language tag contains invalid characters: 'Ä'")=# Locale("Ä")
@test_throws ArgumentError#=("multiple occurrence of singleton 'u'")=# Locale("en-u-u1-u-u2")
@test_throws ArgumentError#=("no language tag: 'en-asdfghjkl' after 1")=# Locale("en-asdfghjkl")
@test_throws ArgumentError#=("no language tag: 'asdfghjkl' after 0")=# Locale("asdfghjkl")
@test_throws ArgumentError#=("no language tag: 'x-asdfghjkl' after 1")=# Locale("x-asdfghjkl")
@test_throws ArgumentError#=("too many language extensions 'en-abc-def-ghi-jkl'")=# Locale("en-abc-def-ghi-jkl")

#various constructors
@test Locale() === Locales.BOTTOM
@test Locale("") === Locales.ROOT
@test Locale("de", "de") == Locale("de-de")
@test Locale("de", "latn", "de") == Locale("de-Latn-de")
@test Locale("de", "latn", "de", "bavarian") == Locale("de-Latn-de-bavarian")
@test Locale("de", "de") == Locale("de-de")
@test Locale("de", "de") == Locale("de-de")
@test Locale("de", "de") == Locale("de-de")
@test Locale("de", "de") == Locale("de-de")

# predefined locales
@test ENGLISH === Locale("en")
@test FRENCH === Locale("fr")
@test GERMAN === Locale("de")
@test ITALIAN === Locale("it")
@test JAPANESE === Locale("ja")
@test KOREAN === Locale("ko")
@test CHINESE === Locale("zh")
@test SIMPLIFIED_CHINESE === Locale("zh_CN")
@test TRADITIONAL_CHINESE === Locale("zh_TW")
@test FRANCE === Locale("fr_FR")
@test GERMANY === Locale("de_DE")
@test ITALY === Locale("it_IT")
@test JAPAN === Locale("ja_JP")
@test KOREA === Locale("ko_KR")
@test CHINA === Locale("zh_CN")
@test PRC === Locale("zh_CN")
@test TAIWAN === Locale("zh_TW")
@test UK === Locale("en_GB")
@test US === Locale("en_US")
@test CANADA === Locale("en_CA")

# inclusion and ordering
@test Locale() ⊆ Locale("en-Latf-gb-variant-variant2-a-123-26-x-1-2-23a-bv")
@test Locale("en-Latf-gb-variant-variant2-a-123-26-x-1-2-23a-bv") ⊆ Locale("")
@test !(Locale("fr-Latn") ⊆ Locale("fr-CA"))
@test !(Locale("fr-CA") ⊆ Locale("fr-Latn"))
@test !(Locale("fr-Latn") < Locale("fr-CA"))
@test Locale("fr-Latn") ≥ Locale("fr-CA")

# loading initail values from environment variables
delete!(ENV, "LANG")
delete!(ENV, "LC_MESSAGES")
delete!(ENV, "LC_COLLATE")
delete!(ENV, "LC_TIME")
delete!(ENV, "LC_NUMERIC")
delete!(ENV, "LC_MONETARY")

ENV["LC_ALL"] = "en_GB"
@test Locales.default_locale(:MESSAGES) === Locale("en-GB")
ENV["LC_ALL"] = "en_GB.utf8"
@test Locales.default_locale(:COLLATE) === Locale("en-GB")
ENV["LC_ALL"] = "en_GB.utf8@oed"
@test Locales.default_locale(:TIME) === Locale("en-GB-x-posix-oed")
ENV["LC_ALL"] = "en_GB@oed"
@test Locales.default_locale(:NUMERIC) === Locale("en-GB-x-posix-oed")

delete!(ENV, "LC_ALL")
ENV["LC_MONETARY"] = "en_US.utf8"
@test Locales.default_locale(:MONETARY) === Locale("en-US")
ENV["LC_TIME"] = "en_CA"
@test Locales.default_locale(:TIME) === Locales.default_locale(:LC_TIME)

ENV["LC_TIME"] = ""
delete!(ENV, "LC_MONETARY")
ENV["LANG"] = "fr_FR@guadelo"
@test Locales.default_locale(:TIME) === Locale("fr-FR-x-posix-guadelo")
ENV["LANG"] = "C"
@test Locales.default_locale(:TIME) === Locale("C")

