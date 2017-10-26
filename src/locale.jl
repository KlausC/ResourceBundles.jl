module Locales

export Locale
export ENGLISH, FRENCH, GERMAN, ITALIAN, JAPANESE, KOREAN, CHINESE,
        SIMPLIFIED_CHINESE, TRADITIONAL_CHINESE
export FRANCE, GERMANY, ITALY, JAPAN, KOREA, CHINA, TAIWAN, PRC, UK, US, CANADA

import Base: ==, hash
"""

    Locale

See: https://tools.ietf.org/html/bcp47
"""
struct Locale
    language::Symbol
    script::Symbol
    region::Symbol
    variants::Vector{Symbol}
    extensions::Dict{Char,Vector{Symbol}}
end

const AS = AbstractString
const VariantVector = Vector{Symbol}
const ExtensionDict = Dict{Char,VariantVector}
const Key = Tuple{Symbol, Symbol, Symbol, VariantVector, ExtensionDict}

"""

    Locale(languagetag::String))
    Locale(lang, region)
    Locale(lang, region, variant)
    Locale(lang, script, region, variant)
    Locale("") -> ROOT
    Locale() -> BOTTOM

Return `Locale` object from cache or create new one and register in cache.
"""
Locale() = BOTTOM
Locale(langtag::AS) = langtag == "" ? ROOT : Locale(splitlangtag(langtag)...)
Locale(lang::AS, region::AS) = Locale(lang, "", region, "", "")
Locale(lang::AS, region::AS, variant::AS) = Locale(lang, "", region, variant, "")
Locale(lang::AS, script::AS, region::AS, variant::AS) = Locale(lang, script, region, variant, "")

function Locale(language::AS, script::AS, region::AS, variant::AS, extension::AS)
    lang = check_language(language)
    scri = check_script(script)
    regi = check_region(region)
    vari = check_variant(variant)
    exte = check_extension(extension)
    key = tuple(lang, scri, regi, vari, exte)
    get!(CACHE, key) do
       Locale(key...)
    end
end

# utilities

const SEPS = ['_', '-']
const NOSYM = Symbol('-')
const NOKEY = '\0'
const S0 = Symbol("")
const EMPTY_VECTOR = Symbol[]
const EMPTY_DICT = Dict{Char,Vector{Symbol}}()

function check_language(x::AS)
    lang = can_language(x)
    lang == NOSYM && throw(ArgumentError("Invalid language $x"))
    lang
end

function can_language(x::AS)
    len = length(x)
    ( len == 0 || 2 <= len <= 8 && is_alpha(x) ) || return NOSYM
    x = lowercase(x)
    # using deprecated ISO639.1 language codes for he, yi and id
    x === "he" ? "iw" : x === "yi" ? "ji" : x === "id" ? "in" : x
    Symbol(x)
end

function check_script(x::AS)
    scri = can_script(x)
    scri == NOSYM && throw(ArgumentError("Invalid script $x"))
    scri
end

function can_script(x::AS)
    len = length(x)
    ( len == 0 || len == 4 && is_alpha(x) ) || return NOSYM
    x = ucfirst(x)
    Symbol(x)
end

function check_region(x::AS)
    regi = can_region(x)
    regi == NOSYM && throw(ArgumentError("Invalid country/region $x"))
    regi
end

function can_region(x::AS)
    len = length(x)
    ( len == 0 || ( len == 2 && is_alpha(x) ) || ( len == 3 && is_digit(x) ) ) || return NOSYM
    x = uppercase(x)
    Symbol(x)
end

function check_variant(x::AS)
    vari = can_variant(x)
    vari == NOSYM && throw(ArgumentError("Invalid variant string $x"))
    vari
end

function can_variant(x::AS)
    len = length(x)
    varis = split(x, SEPS)
    len == 0 || all(is_variant_subtag, varis) || return NOSYM
    len == 0 ? Symbol[] : Symbol.(varis)
end

function is_variant_subtag(x::AS)
    len = length(x)
    is_alnum(x) && ( ( 4 <= len <= 8 && isdigit(x[1]) ) || ( 5 <= len <= 8 ))
end

NOKEY = '\0'

function check_extension(x::AS)
    ext = can_extension(x)
    isa(ext, String) && throw(ArgumentError(ext))
    ext
end

function can_extension(x::AS)
    len = length(x)
    x = lowercase(x)
    ext = Dict{Char,Vector{Symbol}}()
    len == 0 && return ext
    varis = split(x, SEPS)
    all(is_alnum, varis) || return "invalid chars in extension '$x'"
    key = NOKEY
    extv = Symbol[]
    err = ""
    function insert!()
        if key != NOKEY
            haskey(ext, key) && ( err = "multiple extension key $key" )
            length(extv) == 0 && ( err = "missing extension subtags for key $key" )
            ext[key] = extv
            extv = Symbol[]
        end
        ""
    end

    for c in varis
        lenc = length(c)
        if lenc == 1 && key != 'x'
            insert!()
            err == "" || return err
            key = c[1]
        else
            ( lenc >= 1 && is_extension_subtag(c) ) || return "wrong extension subtag '$c'"
            push!(extv, Symbol(c))
        end
    end
    if key != NOKEY
        insert!()
        err == "" || return err
    end
    ext
end

function is_extension_subtag(x::AS)
    len = length(x)
    1 <= len <= 8 || return false
    is_alnum(x)
end


function search2(x::AS, sep, start)
    ip = search(x, sep, start)
    eox = endof(x)
    ip == 0 ? (start, eox, nextind(x, eox)) : (start, prevind(x, ip), nextind(x, ip))
end

function splitlangtag(x::AS)
    is_alnumsep(x) || throw(ArgumentError("language tag contains non-ascii '$x'"))
    lang = ""
    scri = ""
    regi = ""
    vari = ""
    exte = ""
    eox = endof(x)
    k = 1
    i, j, k = search2(x, SEPS, k)
    test = x[i:j]
    if can_language(test) != NOSYM
        lang = test
        i, j, k = search2(x, SEPS, k)
        test = x[i:j]
    end
    if can_script(test) != NOSYM
        scri = test
        i, j, k = search2(x, SEPS, k)
        test = x[i:j]
    end
    if can_region(test) != NOSYM
        regi = test
        i, j, k = search2(x, SEPS, k)
        test = x[i:j]
    end
    if can_variant(test) != NOSYM
        iv = i
        while k <= eox && ! (nextind(x, k) <= eox && x[nextind(x, k)] in SEPS)
            i, j, k = search2(x, SEPS, k)
        end
        vari = x[iv:j]
    else
        k = i
    end
    exte = x[k:end]
    err = can_extension(exte)
    isa(err, String) && throw(ArgumentError(err))
    [lang, scri, regi, vari, exte]
end

function is_category(x::AS, test::Function)
    for c in x
        test(c) && isascii(c) || return false
    end
    true
end

is_alpha(x::AS) = is_category(x, isalpha)
is_digit(x::AS) = is_category(x, isdigit)
is_alnum(x::AS) = is_category(x, isalnum)
is_ascii(x::AS) = is_category(x, y->true)
function is_alnumsep(x::AS)
    for c in x
        isascii(c) && ( isalnum(c) || c in SEPS ) || return false
    end
    true
end 

function ==(x::Locale, y::Locale)
    x === y && return true
    x.language == y.language &&
    x.script == y.script &&
    x.region == y.region &&
    x.variants == y.variants &&
    x.extensions == y.extensions
end

function hash(x::Locale, h::Int)
    hash(x.extensions, hash(x.variants, hash(x.region, hash(x.script, hash(x.language, h)))))
end

function Base.issubset(x::Locale, y::Locale)
    ( x == y || x == BOTTOM || y == ROOT ) && return true
    y == BOTTOM && return false
    issublang(x.language, y.language) &&
    issubscript(x.script, y.script) &&
    issubregion(x.region, y.region) &&
    issubvar(x.variants, y.variants) &&
    issubext(x.extensions, y.extensions)
end

issublang(x::Symbol, y::Symbol) = startswith(string(x), string(y))
issubscript(x::Symbol, y::Symbol) = startswith(string(x), string(y))
issubregion(x::Symbol, y::Symbol) = startswith(string(x), string(y))
issubvar(x::Vector{Symbol}, y::Vector{Symbol}) = issubset(y, x)
function issubext(x::Dict{Char,Vector{Symbol}}, y::Dict{Char,Vector{Symbol}})
    ky = keys(y)
    issubset(ky, keys(x)) &&
    all(k-> issubset(y[k], x[k]), ky)
end

Base.isless(x::Locale, y::Locale) = issubset(x, y) || (!issubset(y,x) && islexless(x, y))
islexless(x::Locale, y::Locale) = string(x) < string(y)

function Base.show(io::IO, x::Locale)
    ES = Symbol("")
    SEP = "-"
    sep = ""
    x.language !== ES && ( print(io, x.language); sep = SEP )
    x.script != ES &&  ( print(io, sep, x.script); sep = SEP )
    x.region != ES && ( print(io, sep, x.region); sep = SEP )
    for v in x.variants
        v != ES && ( print(io, sep, v); sep = SEP )
    end
    ltx(a::Char, b::Char) = ( a != 'x' && a < b ) || b == 'x'
    SEP = '-'
    for k in sort(collect(keys(x.extensions)), lt=ltx)
        print(io, SEP, k)
        for v in x.extensions[k]
            print(io, SEP, v)
        end
    end
end

const CACHE = Dict{Key, Locale}()

    # Useful constant for language.
    const ENGLISH = Locale("en", "");

    # Useful constant for language.
    const FRENCH = Locale("fr", "");

    # Useful constant for language.
    const GERMAN = Locale("de", "");

    # Useful constant for language.
    const ITALIAN = Locale("it", "");

    # Useful constant for language.
    const JAPANESE = Locale("ja", "");

    # Useful constant for language.
    const KOREAN = Locale("ko", "");

    # Useful constant for language.
    const CHINESE = Locale("zh", "");

    # Useful constant for language.
    const SIMPLIFIED_CHINESE = Locale("zh", "CN");

    # Useful constant for language.
    const TRADITIONAL_CHINESE = Locale("zh", "TW");

    # Useful constant for country.
    const FRANCE = Locale("fr", "FR");

    # Useful constant for country.
    const GERMANY = Locale("de", "DE");

    # Useful constant for country.
    const ITALY = Locale("it", "IT");

    # Useful constant for country.
    const JAPAN = Locale("ja", "JP");

    # Useful constant for country.
    const KOREA = Locale("ko", "KR");

    # Useful constant for country.
    const CHINA = SIMPLIFIED_CHINESE;

    # Useful constant for country.
    const PRC = SIMPLIFIED_CHINESE;

    # Useful constant for country.
    const TAIWAN = TRADITIONAL_CHINESE;

    # Useful constant for country.
    const UK = Locale("en", "GB");

    # Useful constant for country.
    const US = Locale("en", "US");

    # Useful constant for country.
    const CANADA = Locale("en", "CA");

"""

    ROOT

Useful constant for the root locale.  The root locale is the locale whose
language, country, and variant are empty ("") strings.  This is regarded
as the base locale of all locales, and is used as the language/country
neutral locale for the locale sensitive operations. 
"""
const ROOT = Locale("", "");
const BOTTOM = Locale(:Bot, S0, S0, EMPTY_VECTOR, EMPTY_DICT) 

"""

    locale(category)

Determine current locale as stored in global variable.
Throw exception, if no valid category name.
Valid categories are
:CTYPE, :COLLATE, :MESSAGES, :MONETARY, :NUMERIC, :TIME
"""
function locale(category::Symbol)
    get(CURRENT_LOCALES, category)
end

"""

    set_locale!(category, locale)

Set current locale as stored in global variable.
Category :ALL sets all defined categories to the same locale.
Throw exception if category is not :ALL or one of the
supported categories of `locale`.
"""
function set_locale!(category::Symbol, loc::Locale)
    for cat in keys(CURRENT_LOCALES.dict)
        if cat == category || category == :ALL
            CURRENT_LOCALES[cat] = loc
        end
    end
    category == :ALL ? loc : locale(category)
end

"""
    default_locale(category)

Determine default locale from posix environment variables:

LANG default if specific category not defined
LC_* specific category
LC_ALL  overides all other settings

* may be one of
MESSAGES    message catalogs
COLLATE     ordering of strings
NUMERIC     number formats
MONETARY    format of monetary values
TIME        date/time formats
"""
function default_locale(category::Union{Symbol,AbstractString})
    ploc = posix_locale(string(category))
    Locale(transform_posix_to_iso(ploc))
end

"""

    posix_locale(category)

Read posix environment variable for category.
"""
function posix_locale(category::String)
    s = uppercase(string(category))
    if ! startswith(s, "LC_")
        s = s == "LANG" ? s : "LC_" * s
    end
    get(ENV, "LC_ALL", get(ENV, string(category), get(ENV, "LANG", "")))
end

"""

    transform_posix_to_iso(posix::String) -> iso-string

Posix string has the general form `<lang_country>][.<charset>][@<extension>]`.
We transform this to the following string:
`<lang_country>][-x-posix-<extension>]`.
The charset is ignored. The extension is optional in input and output.
"""
function transform_posix_to_iso(ploc::String)
    a = split(ploc, '.')
    if length(a) <= 1
        b = split(a[1], '@')
        if length(b) > 1
            a[1] = b[1]
        end
    else
        b = split(a[2], '@')
    end
    length(b) <= 1 && return a[1]
    return a[1] * "-x-posix-" * join(b[2:end], '-')
end

struct GlobalLocaleSet
    dict::Dict{Symbol,Locale}
    GlobalLocaleSet() = new(all_default_categories())
end

"""

"""
const CURRENT_LOCALES = GlobalLocaleSet()

function all_default_categories()
    dict = Dict{Symbol,Locale}(
                :COLLATE => default_locale(:COLLATE)
                :CTYPE => default_locale(:CTYPE)
                :TIME => default_locale(:TIME)
                :MESSAGES => default_locale(:MESSAGES)
                :MONETARY => default_locale(:MONETARY)
                :NUMERIC  => default_locale(:NUMERIC)
                :TIME => default_locale(:TIME)
            )

end

end # module Locales
