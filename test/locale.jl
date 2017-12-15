using .Locales

# Construct LocaleId from language tags
@test LocaleId("") === ROOT
@test LocaleId("en") === ENGLISH
@test LocaleId("en-US") === US
@test string(LocaleId("de")) == "de"
@test string(LocaleId("de_latn")) == "de-Latn"
@test string(LocaleId("de-de")) == "de-DE"
@test string(LocaleId("de-111")) == "de-111"
@test string(LocaleId("de-variAnt1")) == "de-variant1"
@test string(LocaleId("de-variAnt1-varia2")) == "de-variant1-varia2"
@test string(LocaleId("de-1erw-varia2")) == "de-1erw-varia2"
@test string(LocaleId("de-a_aB")) == "de-a-ab"
@test string(LocaleId("DE_X_1_UZ_A_B")) == "de-x-1-uz-a-b"
@test string(LocaleId("DE_latn_de")) == "de-Latn-DE"
@test string(LocaleId("DE_latn_de-variant1")) == "de-Latn-DE-variant1"
@test string(LocaleId("DE_latn_de-a-uu-11")) == "de-Latn-DE-a-uu-11"
@test string(LocaleId("DE_latn_de-varia-a-uu-11")) == "de-Latn-DE-varia-a-uu-11"
@test string(LocaleId("DE_latn_de-varia-a-uu-11")) == "de-Latn-DE-varia-a-uu-11"
@test string(LocaleId("DE_latn_de-1var-a-uu-11")) == "de-Latn-DE-1var-a-uu-11"
@test string(LocaleId("DE_latn_de-1va2-a-uu-11")) == "de-Latn-DE-1va2-a-uu-11"
@test string(LocaleId("DE_latn_de-x-11-a-uu-11")) == "de-Latn-DE-x-11-a-uu-11"
@test string(LocaleId("DE_latn_de-b-22-a-uu-11")) == "de-Latn-DE-a-uu-11-b-22"
@test string(LocaleId("DE_latn_de-z-22-a-uu-11")) == "de-Latn-DE-a-uu-11-z-22"

@test string(LocaleId("zh-han")) == "han"
@test string(LocaleId("deu")) == "de"

@test LocaleId("en-a-aa-b-bb") ⊆ LocaleId("en-b-bb")
@test hash(LocaleId("is-a-aa-b-bb")) == hash(LocaleId("is-b-bb-a-aa"))
@test LocaleId("is-a-aa-b-bb") === LocaleId("is-b-bb-a-aa")
@test LocaleId("C") === LocaleId("")

# exceptions
create2(l="", lex=String[], s="", r="", v=String[], d=Dict{Char,Vector{Symbol}}()) =
    create_locale(l, lex, s, r, v, d)

@test_throws ArgumentError#=("missing language prefix")=# LocaleId("a-ab")
@test_throws ArgumentError#=("no language prefix 'a'")=# LocaleId("a", "")
@test_throws ArgumentError#=("only one language extension allowed 'de-abc-def'")=# LocaleId("de-abc-def")
@test_throws ArgumentError#=("no language exensions allowed 'abcd-def'")=# create2("abcd", ["def"])
@test_throws ArgumentError#=("no script 'Abc'")=# LocaleId("ab", "abc", "de")
@test_throws ArgumentError#=("no region 'DEF'")=# LocaleId("ab", "abcd", "def")
@test_throws ArgumentError#=("no variants 'vari'")=# create2("ab", String[], "", "", ["vari"])
@test_throws ArgumentError#=("no variants '1va'")=# create2("ab", String[], "", "", ["1va"])
@test_throws ArgumentError#=("no variants 'asdfghjkl'")=# create2("ab", String[], "", "", ["asdfghjkl"])
@test_throws ArgumentError#=("no variants '1990-asdfghjkl'")=# create2("ab", String[], "", "", ["1990", "asdfghjkl"])
@test_throws ArgumentError#=("language tag contains invalid characters: 'Ä'")=# LocaleId("Ä")
@test_throws ArgumentError#=("multiple occurrence of singleton 'u'")=# LocaleId("en-u-u1-u-u2")
@test_throws ArgumentError#=("no language tag: 'en-asdfghjkl' after 1")=# LocaleId("en-asdfghjkl")
@test_throws ArgumentError#=("no language tag: 'asdfghjkl' after 0")=# LocaleId("asdfghjkl")
@test_throws ArgumentError#=("no language tag: 'x-asdfghjkl' after 1")=# LocaleId("x-asdfghjkl")
@test_throws ArgumentError#=("too many language extensions 'en-abc-def-ghi-jkl'")=# LocaleId("en-abc-def-ghi-jkl")

#various constructors
@test LocaleId() === BOTTOM
@test LocaleId("") === ROOT
@test LocaleId("de", "de") == LocaleId("de-de")
@test LocaleId("de", "latn", "de") == LocaleId("de-Latn-de")
@test LocaleId("de", "latn", "de", "bavarian") == LocaleId("de-Latn-de-bavarian")
@test LocaleId("de", "de") == LocaleId("de-de")
@test LocaleId("de", "de") == LocaleId("de-de")
@test LocaleId("de", "de") == LocaleId("de-de")
@test LocaleId("de", "de") == LocaleId("de-de")

# predefined locales
@test ENGLISH === LocaleId("en")
@test FRENCH === LocaleId("fr")
@test GERMAN === LocaleId("de")
@test ITALIAN === LocaleId("it")
@test JAPANESE === LocaleId("ja")
@test KOREAN === LocaleId("ko")
@test CHINESE === LocaleId("zh")
@test SIMPLIFIED_CHINESE === LocaleId("zh_CN")
@test TRADITIONAL_CHINESE === LocaleId("zh_TW")
@test FRANCE === LocaleId("fr_FR")
@test GERMANY === LocaleId("de_DE")
@test ITALY === LocaleId("it_IT")
@test JAPAN === LocaleId("ja_JP")
@test KOREA === LocaleId("ko_KR")
@test CHINA === LocaleId("zh_CN")
@test PRC === LocaleId("zh_CN")
@test TAIWAN === LocaleId("zh_TW")
@test UK === LocaleId("en_GB")
@test US === LocaleId("en_US")
@test CANADA === LocaleId("en_CA")

# inclusion and ordering
@test LocaleId() ⊆ LocaleId("en-Latf-gb-variant-variant2-a-123-26-x-1-2-23a-bv")
@test LocaleId("en-Latf-gb-variant-variant2-a-123-26-x-1-2-23a-bv") ⊆ LocaleId("")
@test !(LocaleId("fr-Latn") ⊆ LocaleId("fr-CA"))
@test !(LocaleId("fr-CA") ⊆ LocaleId("fr-Latn"))
@test !(LocaleId("fr-Latn") < LocaleId("fr-CA"))
@test LocaleId("fr-Latn") ≥ LocaleId("fr-CA")

# loading initial values from environment variables
delete!(ENV, "LANG")
delete!(ENV, "LC_MESSAGES")
delete!(ENV, "LC_COLLATE")
delete!(ENV, "LC_TIME")
delete!(ENV, "LC_NUMERIC")
delete!(ENV, "LC_MONETARY")

ENV["LC_ALL"] = "en_GB"
@test default_locale(:MESSAGES) === LocaleId("en-GB")
ENV["LC_ALL"] = "en_GB.utf8"
@test default_locale(:COLLATE) === LocaleId("en-GB")
ENV["LC_ALL"] = "en_GB.utf8@oed"
@test default_locale(:TIME) === LocaleId("en-GB-x-posix-oed")
ENV["LC_ALL"] = "en_GB@oed"
@test default_locale(:NUMERIC) === LocaleId("en-GB-x-posix-oed")

delete!(ENV, "LC_ALL")
ENV["LC_MONETARY"] = "en_US.utf8"
@test default_locale(:MONETARY) === LocaleId("en-US")
ENV["LC_TIME"] = "en_CA"
@test default_locale(:TIME) === default_locale(:LC_TIME)

ENV["LC_TIME"] = ""
delete!(ENV, "LC_MONETARY")
ENV["LANG"] = "fr_FR@guadelo"
@test default_locale(:TIME) === LocaleId("fr-FR-x-posix-guadelo")
ENV["LANG"] = "C"
@test default_locale(:TIME) === LocaleId("C")

