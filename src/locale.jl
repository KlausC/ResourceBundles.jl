module Locales

export Locale
export ENGLISH, FRENCH, GERMAN, ITALIAN, JAPANESE, KOREAN, CHINESE,
        SIMPLIFIED_CHINESE, TRADITIONAL_CHINESE
export FRANCE, GERMANY, ITALY, JAPAN, KOREA, CHINA, TAIWAN, PRC, UK, US, CANADA

import Base: ==, hash

include("locale_iso_data.jl")

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

const EMPTYV = String[]
const EMPTYD = ExtensionDict()

"""

    Locale(languagetag::String))
    Locale(lang, region)
    Locale(lang, script, region)
    Locale(lang, script, region, variant)
    Locale("") -> ROOT
    Locale() -> BOTTOM

Return `Locale` object from cache or create new one and register in cache.
"""
Locale() = BOTTOM
Locale(langtag::AS) = langtag == "" ? ROOT : create(splitlangtag(langtag)...)
Locale(lang::AS, region::AS) = create(lang, EMPTYV, "", region, EMPTYV, EMPTYD)
Locale(lang::AS, script::AS, region::AS) = create(lang, EMPTYV, script, region, EMPTYV, EMPTYD)
Locale(lang::AS, script::AS, region::AS, variant::AS) = create(lang, EMPTYV, script, region, [variant], EMPTYD)

# create instance and register in global cache.
function create(language::AS, extlang::Vector{String}, script::AS, region::AS, variant::Vector{String}, extension::Dict{Char,Vector{Symbol}})

    lang = check_language(language, extlang)
    scri = check_script(titlecase(script))
    regi = check_region(uppercase(region))
    vari = check_variant(variant)
    if lang == S0
        lex = length(extension)
        if !(scri == S0 && regi == S0 && length(vari) == 0 &&
             (lex == 1 && first(keys(extension)) == 'x' || lex == 0 ) )
            throw(ArgumentError("missing language prefix"))
        end
    end
    key = tuple(lang, scri, regi, vari, extension)
    get!(CACHE, key) do
       Locale(key...)
    end
end

# utilities

const SEP = '-'
const S0 = Symbol("")
const EMPTY_VECTOR = Symbol[]
const EMPTY_DICT = Dict{Char,Vector{Symbol}}()

function check_language(x::AS, extlang::Vector{String})
    is_language(x) || length(x) == 0 || throw(ArgumentError("no language prefix '$x'"))
    x = get(OLD_TO_NEW_LANG, x, x)
    len = length(extlang)
    if length(x) <= 3
        len <= 1 || throw(ArgumentError("only one language extension allowed '$x-$(join(extlang, '-'))'")) 
        if length(extlang) >= 1
            x = extlang[1]
        end
        if length(x) == 3
            x = LANGUAGE3_DICT[x] # replace 3-char code by preferred 2-char code
        end
    else
        len == 0 || throw(ArgumentError("no language exensions allowed '$x-$(join(extlang, '-'))'"))
    end
    Symbol(x)
end

function is_language(x::AS)
    len = length(x)
    2 <= len <= 8 && is_alpha(x)
end

function is_langext(x::AS)
    len = length(x)
    len == 3 && is_alpha(x)
end

function check_script(x::AS)
    is_script(x) || length(x) == 0 || throw(ArgumentError("no script '$x'")) 
    Symbol(x)
end

function is_script(x::AS)
    len = length(x)
    len == 4 && is_alpha(x)
end

function check_region(x::AS)
    is_region(x) || length(x) == 0 || throw(ArgumentError("no region '$x'"))
    Symbol(x)
end

function is_region(x::AS)
    len = length(x)
    ( len == 2 && is_alpha(x) ) || ( len == 3 && is_digit(x) )
end

function check_variant(x::Vector{String})
    all(is_variant, x) || throw(ArgumentError("no variants '$(join(x, '-'))'")) 
    Symbol.(x)
end

function is_variant(x::AS)
    len = length(x)
    is_alnum(x) && ( ( 4 <= len <= 8 && isdigit(x[1]) ) || ( 5 <= len <= 8 ))
end

function is_single(x::AS)
    length(x) == 1 && is_alpha(x)
end

"""

Parse language tag and convert to Symbols and collections of Symbols.
"""
function splitlangtag(x::AS)
    is_alnumsep(x) || throw(ArgumentError("language tag contains invalid characters: '$x'"))
    if x == "C"
        x = ""
    end
    x = replace(lowercase(x), '_', SEP) # normalize input
    x = transform_posix_to_iso(x) # handle and replace '.' and '@'.
    x = get(GRANDFATHERED, x, x) # replace some old-fashioned language tags
    token = split(x, SEP, keep=true)
    lang = ""
    langex = String[]
    scri = ""
    regi = ""
    vari = String[]
    exte = ExtensionDict()
    langlen = 0
    k = 1
    n = length(token)
    if k <= n && is_language(token[k])
        lang = token[k]
        langlen = length(lang)
        k += 1
    end
    while k <= n && 2 <= langlen <= 3 && is_langext(token[k])
        push!(langex, token[k])
        k += 1
    end
    if k <= n && is_script(token[k])
        scri = token[k]
        k += 1
    end
    while k <= n && is_region(token[k])
        regi = token[k]
        k += 1
    end
    while k <= n && is_variant(token[k])
        push!(vari, token[k])
        k += 1
    end
    while k <= n && is_single(token[k])
        sing = token[k][1]
        haskey(exte, sing) && throw(ArgumentError("multiple occurrence of singleton '$sing'"))
        m = sing == 'x' ? 1 : 2
        k += 1
        ext = Symbol[]
        while k <= n && m <= length(token[k]) <= 8
            push!(ext, Symbol(token[k]))
            k += 1
        end
        exte[sing] = ext
    end

    k > n || x == "" || throw(ArgumentError("no language tag: '$x' after $(k-1)"))
    length(langex) <= 3 || throw(ArgumentError("too many language extensions '$x'"))

    lang, langex, scri, regi, vari, exte
end

# character properties for all characters in string
is_alpha(x::AS) = all(isalpha, x)
is_digit(x::AS) = all(isdigit, x)
is_alnum(x::AS) = all(isalnum, x)
is_ascii(x::AS) = all(isascii, x)
is_alnumsep(x::AS) = all(c->isascii(c) && ( isalnum(c) || c in "-_.@" ), x)

# equality
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

function Base.show(io2::IO, x::Locale)
    ES = Symbol("")
    sep = ""
    io = IOBuffer()
    x.language !== ES && ( print(io, x.language); sep = SEP )
    x.script != ES &&  ( print(io, sep, x.script); sep = SEP )
    x.region != ES && ( print(io, sep, x.region); sep = SEP )
    for v in x.variants
        v != ES && ( print(io, sep, v); sep = SEP )
    end
    ltx(a::Char, b::Char) = ( a != 'x' && a < b ) || b == 'x'
    for k in sort(collect(keys(x.extensions)), lt=ltx)
        print(io, sep, k); sep = SEP
        for v in x.extensions[k]
            print(io, sep, v)
        end
    end
    out = String(take!(io))
    if out == ""
        out = "C"
    end
    print(io2, out)
end

const CACHE = Dict{Key, Locale}()

    # Useful constant for language.
    const ENGLISH = Locale("en", "")

    # Useful constant for language.
    const FRENCH = Locale("fr", "")

    # Useful constant for language.
    const GERMAN = Locale("de", "")

    # Useful constant for language.
    const ITALIAN = Locale("it", "")

    # Useful constant for language.
    const JAPANESE = Locale("ja", "")

    # Useful constant for language.
    const KOREAN = Locale("ko", "")

    # Useful constant for language.
    const CHINESE = Locale("zh", "")

    # Useful constant for language.
    const SIMPLIFIED_CHINESE = Locale("zh", "CN")

    # Useful constant for language.
    const TRADITIONAL_CHINESE = Locale("zh", "TW")

    # Useful constant for country.
    const FRANCE = Locale("fr", "FR")

    # Useful constant for country.
    const GERMANY = Locale("de", "DE")

    # Useful constant for country.
    const ITALY = Locale("it", "IT")

    # Useful constant for country.
    const JAPAN = Locale("ja", "JP")

    # Useful constant for country.
    const KOREA = Locale("ko", "KR")

    # Useful constant for country.
    const CHINA = SIMPLIFIED_CHINESE

    # Useful constant for country.
    const PRC = SIMPLIFIED_CHINESE

    # Useful constant for country.
    const TAIWAN = TRADITIONAL_CHINESE

    # Useful constant for country.
    const UK = Locale("en", "GB")

    # Useful constant for country.
    const US = Locale("en", "US")

    # Useful constant for country.
    const CANADA = Locale("en", "CA")

"""

    ROOT

Useful constant for the root locale.  The root locale is the locale whose
language, country, and variant are empty ("") strings.  This is regarded
as the base locale of all locales, and is used as the language/country
neutral locale for the locale sensitive operations. 
"""
const ROOT = Locale("", "")
const BOTTOM = Locale(:Bot, S0, S0, EMPTY_VECTOR, EMPTY_DICT) 

"""

    locale(category)

Determine current locale as stored in global variable.
Throw exception, if no valid category name.
Valid categories are
:CTYPE, :COLLATE, :MESSAGES, :MONETARY, :NUMERIC, :TIME
"""
function locale(category::Symbol)
    CURRENT_LOCALES.dict[category]
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
            CURRENT_LOCALES.dict[cat] = loc
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
    Locale(posix_locale(string(category)))
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
    get2("LC_ALL") do
        get2(s) do
            get(ENV, "LANG", "")
        end
    end
end

# treat empty value 
function get2(f::Function, k::Any)
    v = get(ENV, k, "")
    v == "" ? f() : v
end

"""

    transform_posix_to_iso(posix::String) -> iso-string

Posix string has the general form `<lang_country>][.<charset>][@<extension>]`.
We transform this to the following string:
`<lang_country>][-x-posix-<extension>]`.
The charset is ignored. The extension is optional in input and output.
"""
function transform_posix_to_iso(ploc::String)
    if ploc == "C"
        return ""
    end
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

function all_default_categories()
    dict = Dict{Symbol,Locale}(
                :COLLATE => default_locale(:COLLATE),
                :CTYPE => default_locale(:CTYPE),
                :TIME => default_locale(:TIME),
                :MESSAGES => default_locale(:MESSAGES),
                :MONETARY => default_locale(:MONETARY),
                :NUMERIC  => default_locale(:NUMERIC),
                :TIME => default_locale(:TIME),
            )

end

const CURRENT_LOCALES = GlobalLocaleSet()

end # module Locales
