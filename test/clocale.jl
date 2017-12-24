
using .CLocales
using .LC

set_locale!(LocaleId("C"), LC.ALL)
const cl = locale()
const ALLCAT = collect(LC.ALL)

@test cl != Ptr{Nothing}(0)

@testset "clocale identifiers C for $sym"  for sym in ALLCAT
    @test clocale_id(sym) == "C"
end

for cat in ALLCAT
    ENV[string("LC_", cat)] = ""
end

clocid = "fr_FR.utf8"
ENV["LANG"] = clocid
ENV["LC_ALL"] = ""

set_locale!(LocaleId(""), LC.ALL)

@testset "clocale identifiers from envionment for $sym" for sym in ALLCAT
    @test clocale_id(sym) == clocid
end

@testset "clocale codesets from environment for $sym" for sym in ALLCAT
    try
        nli = eval(CLocales, Meta.parse(string(sym, "_CODESET")))
        @test nl_langinfo(nli) == "UTF-8"
    end
end

@testset "setting and querying clocalesi prog" begin
    @test clocale_id(LC.NUMERIC) == "fr_FR.utf8"
    set_locale!(LocaleId("C"))
    set_locale!(LocaleId("tr_TR"), LC.MESSAGES)
    set_locale!(LocaleId("en-us"), LC.MONETARY)
    @test clocale_id(LC.CTYPE) == "C"
    @test clocale_id(LC.NUMERIC) == "C"
    @test clocale_id(LC.MESSAGES) == "tr_TR.utf8"
    @test clocale_id(LC.MONETARY) == "en_US.utf8"
end

ENV["LC_ALL"] = "de_DE.utf8"
set_locale!(LocaleId(""), LC.MESSAGES | LC.NAME)

@testset "setting and querying clocales ENV" begin
    @test clocale_id(LC.NUMERIC) == "C"
    @test clocale_id(LC.MESSAGES) == "de_DE.utf8"
    @test clocale_id(LC.NAME) == "de_DE.utf8"
    @test clocale_id(LC.MONETARY) == "en_US.utf8"
end

import .CLocales:

CTYPE_CODESET,

RADIXCHAR, THOUSEP, THOUSANDS_SEP, GROUPING, NUMERIC_CODESET, 

ABDAY, DAY, ABMON, MON, AM_STR, PM_STR, D_T_FMT, D_FMT, T_FMT, T_FMT_AMPM, ERA,
ERA_YEAR, ERA_D_FMT, ALT_DIGITS, ERA_D_T_FMT, ERA_T_FMT, TIME_CODESET,

COLLATE_CODESET,

YESEXPR, NOEXPR, YESSTR, NOSTR, MESSAGES_CODESET,

INT_CURR_SYMBOL, CURRENCY_SYMBOL, MON_DECIMAL_POINT, MON_THOUSANDS_SEP, MON_GROUPING,
POSITIVE_SIGN, NEGATIVE_SIGN, INT_FRAC_DIGITS, FRAC_DIGITS, P_CS_PRECEDES, P_SEP_BY_SPACE,
N_CS_PRECEDES, N_SEP_BY_SPACE, P_SIGN_POSN, N_SIGN_POSN, CRNCYSTR, INT_P_CS_PRECEDES,
INT_P_SEP_BY_SPACE, INT_N_CS_PRECEDES, INT_N_SEP_BY_SPACE, INT_P_SIGN_POSN, INT_N_SIGN_POSN,
MONETARY_CODESET,

PAPER_HEIGHT, PAPER_WIDTH, PAPER_CODESET,

NAME_FMT, NAME_GEN, NAME_MR, NAME_MRS, NAME_MISS, NAME_MS, NAME_CODESET,

ADDRESS_POSTAL_FMT, ADDRESS_COUNTRY_NAME, ADDRESS_COUNTRY_POST, ADDRESS_COUNTRY_AB2,
ADDRESS_COUNTRY_AB3, ADDRESS_COUNTRY_CAR, ADDRESS_COUNTRY_NUM, ADDRESS_COUNTRY_ISBN,
ADDRESS_LANG_NAME, ADDRESS_LANG_AB, ADDRESS_LANG_LIB, ADDRESS_LANG_TERM, ADDRESS_CODESET,

TELEPHONE_TEL_INT_FMT, TELEPHONE_TEL_DOM_FMT, TELEPHONE_INT_SELECT, TELEPHONE_INT_PREFIX,
TELEPHONE_CODESET,

MEASUREMENT, MEASUREMENT_CODESET,

IDENTIFICATION_TITLE, IDENTIFICATION_SOURCE, IDENTIFICATION_ADDRESS, IDENTIFICATION_CONTACT,
IDENTIFICATION_EMAIL, IDENTIFICATION_TEL, IDENTIFICATION_FAX, IDENTIFICATION_LANGUAGE,
IDENTIFICATION_TERRITORY, IDENTIFICATION_AUDIENCE, IDENTIFICATION_APPLICATION, IDENTIFICATION_ABBREVIATION,
IDENTIFICATION_REVISION, IDENTIFICATION_DATE, IDENTIFICATION_CATEGORY, IDENTIFICATION_CODESET

const DE_ITEMS = [
    RADIXCHAR => ",",
    THOUSEP => ".",
    THOUSANDS_SEP => ".",
    GROUPING => 3,

    ABDAY(2) => "Mo",
    DAY(1) => "Sonntag",
    DAY(7) => "Samstag",
    ABMON(6) => "Jun",
    MON(6) => "Juni",
    AM_STR => "",
    PM_STR => "",
    D_T_FMT => "%a %d %b %Y %T %Z",
    D_FMT => "%d.%m.%Y",
    T_FMT => "%T",
    T_FMT_AMPM => "",
    ERA => "",
    ERA_YEAR => "",
    ERA_D_FMT => "",
    ALT_DIGITS => "",
    ERA_D_T_FMT => "",
    ERA_T_FMT => "",

    YESEXPR => "^[jJyY].*",
    NOEXPR => "^[nN].*",

    INT_CURR_SYMBOL => "EUR ",
    CURRENCY_SYMBOL => "€" ,
    MON_DECIMAL_POINT => ",",
    MON_THOUSANDS_SEP => ".",
    MON_GROUPING => 3,
    POSITIVE_SIGN => "",
    NEGATIVE_SIGN => "-",
    INT_FRAC_DIGITS => 2,
    FRAC_DIGITS => 2,
    P_CS_PRECEDES => 0,
    P_SEP_BY_SPACE => 1,
    N_CS_PRECEDES => 0,
    N_SEP_BY_SPACE => 1,
    P_SIGN_POSN => 1 ,
    N_SIGN_POSN => 1,
    CRNCYSTR => "+€",
    INT_P_CS_PRECEDES => 0,
    INT_P_SEP_BY_SPACE => 1,
    INT_N_CS_PRECEDES => 0,
    INT_N_SEP_BY_SPACE => 1,
    INT_P_SIGN_POSN => 1,
    INT_N_SIGN_POSN => 1,

    PAPER_HEIGHT => 297,
    PAPER_WIDTH => 210,

    NAME_FMT => "%d%t%g%t%m%t%f",
    NAME_GEN => "",
    NAME_MR => "Herr",
    NAME_MRS => "Frau",
    NAME_MISS => "Fräulein",
    NAME_MS  => "Frau",

    ADDRESS_POSTAL_FMT => "%f%N%a%N%d%N%b%N%s %h %e %r%N%z %T%N%c%N",
    ADDRESS_COUNTRY_NAME => "Deutschland",
    ADDRESS_COUNTRY_POST => "D",
    ADDRESS_COUNTRY_AB2 => "DE",
    ADDRESS_COUNTRY_AB3 => "DEU",
    ADDRESS_COUNTRY_CAR => "D",
    ADDRESS_COUNTRY_NUM => 276,
    ADDRESS_COUNTRY_ISBN => "3",
    ADDRESS_LANG_NAME => "Deutsch",
    ADDRESS_LANG_AB => "de",
    ADDRESS_LANG_LIB => "deu",
    ADDRESS_LANG_TERM => "ger",

    TELEPHONE_TEL_INT_FMT => "+%c %a %l",
    TELEPHONE_TEL_DOM_FMT => "%A %l",
    TELEPHONE_INT_SELECT => "00",
    TELEPHONE_INT_PREFIX => "49",

    MEASUREMENT => 1,

    IDENTIFICATION_TITLE => "German locale for Germany",
    IDENTIFICATION_SOURCE => "Free Software Foundation, Inc.",
    IDENTIFICATION_ADDRESS => "http://www.gnu.org/software/libc/",
    IDENTIFICATION_CONTACT => "",
    IDENTIFICATION_EMAIL => "bug-glibc-locales@gnu.org",
    IDENTIFICATION_TEL => "",
    IDENTIFICATION_FAX => "",
    IDENTIFICATION_LANGUAGE => "German",
    IDENTIFICATION_TERRITORY => "Germany",
    IDENTIFICATION_AUDIENCE => "",
    IDENTIFICATION_APPLICATION => "",
    IDENTIFICATION_ABBREVIATION => "",
    IDENTIFICATION_REVISION => "1.0",
    IDENTIFICATION_DATE => "2000-06-24",
    IDENTIFICATION_CATEGORY => "de_DE:2000",

]

set_locale!(LocaleId("de-de")) # set all categories
@testset "nl_langinfo queries $(category(p.first))-$(offset(p.first)) => '$(p.second)'" for p in DE_ITEMS
    item, res = p
    @test nl_langinfo(item) == res    
end

