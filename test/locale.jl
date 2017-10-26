using ResourceBundles.Locales


@test Locale() === Locales.BOTTOM
@test Locale("") === Locales.ROOT
@test Locale("en") === Locales.ENGLISH
@test Locale("en-US") === Locales.US
@test string(Locale("de")) == "de"
@test string(Locale("de_latn")) == "de-Latn"
@test string(Locale("de-de")) == "de-DE"
@test string(Locale("de-111")) == "de-111"
@test string(Locale("de-variAnt1")) == "de-variAnt1"
@test string(Locale("de-variAnt1-varia2")) == "de-variAnt1-varia2"
@test string(Locale("de-1erw-varia2")) == "de-1erw-varia2"
@test string(Locale("de-a_aB")) == "de-a-ab"
@test string(Locale("DE_X_1_UZ_A_B")) == "de-x-1-uz-a-b"
@test string(Locale("DE_latn_de")) == "de-Latn-DE"
@test string(Locale("DE_latn_de-variant1")) == "de-Latn-DE-variant1"
@test string(Locale("DE_latn_de-a-uu-11")) == "de-Latn-DE-a-uu-11"
@test_broken string(Locale("DE_latn_de-vari-a-uu-11")) == "de-Latn-DE-vari-a-uu-11"
@test string(Locale("DE_latn_de-varia-a-uu-11")) == "de-Latn-DE-varia-a-uu-11"
@test string(Locale("DE_latn_de-1var-a-uu-11")) == "de-Latn-DE-1var-a-uu-11"
@test_broken string(Locale("DE_latn_de-1va-a-uu-11")) == "de-Latn-DE-1va-a-uu-11"
@test string(Locale("DE_latn_de-x-11-a-uu-11")) == "de-Latn-DE-x-11-a-uu-11"
@test string(Locale("DE_latn_de-b-22-a-uu-11")) == "de-Latn-DE-a-uu-11-b-22"
@test string(Locale("DE_latn_de-z-22-a-uu-11")) == "de-Latn-DE-a-uu-11-z-22"


@test Locale() ⊆ Locale("en-Latf-gb-variant-variant2-a-123-26-x-1-2-23a-bv")
@test Locale("en-Latf-gb-variant-variant2-a-123-26-x-1-2-23a-bv") ⊆ Locale("")
@test !(Locale("fr-Latn") ⊆ Locale("fr-CA"))
@test !(Locale("fr-CA") ⊆ Locale("fr-Latn"))
@test !(Locale("fr-Latn") < Locale("fr-CA"))
@test Locale("fr-Latn") ≥ Locale("fr-CA")


ENV["LANG"] = ""
ENV["LC_MESSAGES"] = ""
ENV["LC_COLLATE"] = ""
ENV["LC_TIME"] = ""
ENV["LC_NUMERIC"] = ""
ENV["LC_MONETARY"] = ""

ENV["LC_ALL"] = "en_GB"
@test Locales.default_locale(:MESSAGES) == Locale("en-GB")
ENV["LC_ALL"] = "en_GB.utf8"
@test Locales.default_locale(:COLLATE) == Locale("en-GB")
ENV["LC_ALL"] = "en_GB.utf8@oed"
@test Locales.default_locale(:TIME) == Locale("en-GB-x-posix-oed")
ENV["LC_ALL"] = "en_GB@oed"
@test Locales.default_locale(:NUMERIC) == Locale("en-GB-x-posix-oed")

ENV["LC_ALL"] = ""
ENV["LC_MONETARY"] = "en_US.utf8"
@test_broken Locales.default_locale(:MONETARY) == Locale("en-US")
ENV["LC_TIME"] = "en_CA"
@test Locales.default_locale(:TIME) === Locales.default_locale(:LC_TIME)

ENV["LC_MONETARY"] = ""
ENV["LC_TIME"] = ""
ENV["LANG"] = "fr_FR@guadelo"
@test_broken Locales.default_locale(:TIME) === Locale("fr-FR-x-posix-gouadelo")

