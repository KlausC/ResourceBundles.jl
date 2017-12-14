using .Locales

# Construct LangTag from language tags
@test LangTag("") === ROOT
@test LangTag("en") === ENGLISH
@test LangTag("en-US") === US
@test string(LangTag("de")) == "de"
@test string(LangTag("de_latn")) == "de-Latn"
@test string(LangTag("de-de")) == "de-DE"
@test string(LangTag("de-111")) == "de-111"
@test string(LangTag("de-variAnt1")) == "de-variant1"
@test string(LangTag("de-variAnt1-varia2")) == "de-variant1-varia2"
@test string(LangTag("de-1erw-varia2")) == "de-1erw-varia2"
@test string(LangTag("de-a_aB")) == "de-a-ab"
@test string(LangTag("DE_X_1_UZ_A_B")) == "de-x-1-uz-a-b"
@test string(LangTag("DE_latn_de")) == "de-Latn-DE"
@test string(LangTag("DE_latn_de-variant1")) == "de-Latn-DE-variant1"
@test string(LangTag("DE_latn_de-a-uu-11")) == "de-Latn-DE-a-uu-11"
@test string(LangTag("DE_latn_de-varia-a-uu-11")) == "de-Latn-DE-varia-a-uu-11"
@test string(LangTag("DE_latn_de-varia-a-uu-11")) == "de-Latn-DE-varia-a-uu-11"
@test string(LangTag("DE_latn_de-1var-a-uu-11")) == "de-Latn-DE-1var-a-uu-11"
@test string(LangTag("DE_latn_de-1va2-a-uu-11")) == "de-Latn-DE-1va2-a-uu-11"
@test string(LangTag("DE_latn_de-x-11-a-uu-11")) == "de-Latn-DE-x-11-a-uu-11"
@test string(LangTag("DE_latn_de-b-22-a-uu-11")) == "de-Latn-DE-a-uu-11-b-22"
@test string(LangTag("DE_latn_de-z-22-a-uu-11")) == "de-Latn-DE-a-uu-11-z-22"

@test string(LangTag("zh-han")) == "han"
@test string(LangTag("deu")) == "de"

@test LangTag("en-a-aa-b-bb") ⊆ LangTag("en-b-bb")
@test hash(LangTag("is-a-aa-b-bb")) == hash(LangTag("is-b-bb-a-aa"))
@test LangTag("is-a-aa-b-bb") === LangTag("is-b-bb-a-aa")
@test LangTag("C") === LangTag("")

# exceptions
create2(l="", lex=String[], s="", r="", v=String[], d=Dict{Char,Vector{Symbol}}()) =
    create_locale(l, lex, s, r, v, d)

@test_throws ArgumentError#=("missing language prefix")=# LangTag("a-ab")
@test_throws ArgumentError#=("no language prefix 'a'")=# LangTag("a", "")
@test_throws ArgumentError#=("only one language extension allowed 'de-abc-def'")=# LangTag("de-abc-def")
@test_throws ArgumentError#=("no language exensions allowed 'abcd-def'")=# create2("abcd", ["def"])
@test_throws ArgumentError#=("no script 'Abc'")=# LangTag("ab", "abc", "de")
@test_throws ArgumentError#=("no region 'DEF'")=# LangTag("ab", "abcd", "def")
@test_throws ArgumentError#=("no variants 'vari'")=# create2("ab", String[], "", "", ["vari"])
@test_throws ArgumentError#=("no variants '1va'")=# create2("ab", String[], "", "", ["1va"])
@test_throws ArgumentError#=("no variants 'asdfghjkl'")=# create2("ab", String[], "", "", ["asdfghjkl"])
@test_throws ArgumentError#=("no variants '1990-asdfghjkl'")=# create2("ab", String[], "", "", ["1990", "asdfghjkl"])
@test_throws ArgumentError#=("language tag contains invalid characters: 'Ä'")=# LangTag("Ä")
@test_throws ArgumentError#=("multiple occurrence of singleton 'u'")=# LangTag("en-u-u1-u-u2")
@test_throws ArgumentError#=("no language tag: 'en-asdfghjkl' after 1")=# LangTag("en-asdfghjkl")
@test_throws ArgumentError#=("no language tag: 'asdfghjkl' after 0")=# LangTag("asdfghjkl")
@test_throws ArgumentError#=("no language tag: 'x-asdfghjkl' after 1")=# LangTag("x-asdfghjkl")
@test_throws ArgumentError#=("too many language extensions 'en-abc-def-ghi-jkl'")=# LangTag("en-abc-def-ghi-jkl")

#various constructors
@test LangTag() === BOTTOM
@test LangTag("") === ROOT
@test LangTag("de", "de") == LangTag("de-de")
@test LangTag("de", "latn", "de") == LangTag("de-Latn-de")
@test LangTag("de", "latn", "de", "bavarian") == LangTag("de-Latn-de-bavarian")
@test LangTag("de", "de") == LangTag("de-de")
@test LangTag("de", "de") == LangTag("de-de")
@test LangTag("de", "de") == LangTag("de-de")
@test LangTag("de", "de") == LangTag("de-de")

# predefined locales
@test ENGLISH === LangTag("en")
@test FRENCH === LangTag("fr")
@test GERMAN === LangTag("de")
@test ITALIAN === LangTag("it")
@test JAPANESE === LangTag("ja")
@test KOREAN === LangTag("ko")
@test CHINESE === LangTag("zh")
@test SIMPLIFIED_CHINESE === LangTag("zh_CN")
@test TRADITIONAL_CHINESE === LangTag("zh_TW")
@test FRANCE === LangTag("fr_FR")
@test GERMANY === LangTag("de_DE")
@test ITALY === LangTag("it_IT")
@test JAPAN === LangTag("ja_JP")
@test KOREA === LangTag("ko_KR")
@test CHINA === LangTag("zh_CN")
@test PRC === LangTag("zh_CN")
@test TAIWAN === LangTag("zh_TW")
@test UK === LangTag("en_GB")
@test US === LangTag("en_US")
@test CANADA === LangTag("en_CA")

# inclusion and ordering
@test LangTag() ⊆ LangTag("en-Latf-gb-variant-variant2-a-123-26-x-1-2-23a-bv")
@test LangTag("en-Latf-gb-variant-variant2-a-123-26-x-1-2-23a-bv") ⊆ LangTag("")
@test !(LangTag("fr-Latn") ⊆ LangTag("fr-CA"))
@test !(LangTag("fr-CA") ⊆ LangTag("fr-Latn"))
@test !(LangTag("fr-Latn") < LangTag("fr-CA"))
@test LangTag("fr-Latn") ≥ LangTag("fr-CA")

# loading initial values from environment variables
delete!(ENV, "LANG")
delete!(ENV, "LC_MESSAGES")
delete!(ENV, "LC_COLLATE")
delete!(ENV, "LC_TIME")
delete!(ENV, "LC_NUMERIC")
delete!(ENV, "LC_MONETARY")

ENV["LC_ALL"] = "en_GB"
@test default_locale(:MESSAGES) === LangTag("en-GB")
ENV["LC_ALL"] = "en_GB.utf8"
@test default_locale(:COLLATE) === LangTag("en-GB")
ENV["LC_ALL"] = "en_GB.utf8@oed"
@test default_locale(:TIME) === LangTag("en-GB-x-posix-oed")
ENV["LC_ALL"] = "en_GB@oed"
@test default_locale(:NUMERIC) === LangTag("en-GB-x-posix-oed")

delete!(ENV, "LC_ALL")
ENV["LC_MONETARY"] = "en_US.utf8"
@test default_locale(:MONETARY) === LangTag("en-US")
ENV["LC_TIME"] = "en_CA"
@test default_locale(:TIME) === default_locale(:LC_TIME)

ENV["LC_TIME"] = ""
delete!(ENV, "LC_MONETARY")
ENV["LANG"] = "fr_FR@guadelo"
@test default_locale(:TIME) === LangTag("fr-FR-x-posix-guadelo")
ENV["LANG"] = "C"
@test default_locale(:TIME) === LangTag("C")

