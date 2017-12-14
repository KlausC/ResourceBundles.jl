
using .Constants
using .LangTagTranslations

export LangTag, Locales, default_locale, locale, set_locale!, current_locales

import Base: ==, hash


"""

    LangTag(languagetag::String))
    LangTag(lang, region)
    LangTag(lang, script, region)
    LangTag(lang, script, region, variant)
    LangTag("") -> ROOT
    LangTag() -> BOTTOM

Return `LangTag` object from cache or create new one and register in cache.
"""
LangTag() = BOTTOM
LangTag(langtag::AS) = langtag == "" ? ROOT : create_locale(splitlangtag(langtag)...)
LangTag(lang::AS, region::AS) = create_locale(lang, EMPTYV, "", region, EMPTYV, EMPTYD)
LangTag(lang::AS, script::AS, region::AS) = create_locale(lang, EMPTYV, script, region, EMPTYV, EMPTYD)
LangTag(lang::AS, script::AS, region::AS, variant::AS) = create_locale(lang, EMPTYV, script, region, [variant], EMPTYD)


# utilities


# create instance and register in global cache.
function create_locale(language::AS, extlang::Vector{String}, script::AS, region::AS, variant::Vector{String}, extension::ExtensionDict)

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
    try
        lock(CACHE_LOCK)
        get!(CACHE, key) do
            LangTag(key...)
        end
    finally
        unlock(CACHE_LOCK)
    end
end
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
    x = cloc_to_loc(x) # handle and replace '.' and '@'.
    x = replace(lowercase(x), SEP, SEP2) # normalize input
    x = get(GRANDFATHERED, x, x) # replace some old-fashioned language tags
    token = split(x, SEP2, keep=true)
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
is_alnumsep(x::AS) = all(c->isascii(c) && ( isalnum(c) || c in "-_.@" ), x)

# equality
function ==(x::LangTag, y::LangTag)
    x === y && return true
    x.language == y.language &&
    x.script == y.script &&
    x.region == y.region &&
    x.variants == y.variants &&
    x.extensions == y.extensions
end

function hash(x::LangTag, h::UInt)
    hash(x.extensions, hash(x.variants, hash(x.region, hash(x.script, hash(x.language, h)))))
end

function Base.issubset(x::LangTag, y::LangTag)
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

Base.isless(x::LangTag, y::LangTag) = issubset(x, y) || (!issubset(y,x) && islexless(x, y))
islexless(x::LangTag, y::LangTag) = string(x) < string(y)

function Base.show(io2::IO, x::LangTag)
    ES = Symbol("")
    sep = ""
    io = IOBuffer()
    x.language !== ES && ( print(io, x.language); sep = SEP2 )
    x.script != ES &&  ( print(io, sep, x.script); sep = SEP2 )
    x.region != ES && ( print(io, sep, x.region); sep = SEP2 )
    for v in x.variants
        v != ES && ( print(io, sep, v); sep = SEP2 )
    end
    ltx(a::Char, b::Char) = ( a != 'x' && a < b ) || b == 'x'
    for k in sort(collect(keys(x.extensions)), lt=ltx)
        print(io, sep, k); sep = SEP2
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

const CACHE = Dict{Key, LangTag}()
const CACHE_LOCK = Threads.RecursiveSpinLock()


"""

    locale(category)

Determine current locale as stored in global variable.
Throw exception, if no valid category name.
Valid categories are
:CTYPE, :COLLATE, :MESSAGES, :MONETARY, :NUMERIC, :TIME
"""
function locale(category::Symbol)
    current_locales().dict[category]
end

"""

    set_locale!(category, locale)

Set current locale as stored in task-local variable.
Category :ALL sets all defined categories to the same locale.
Throw exception if category is not :ALL or one of the
supported categories of `locale`.
"""
set_locale!(cat::Symbol, loc::LangTag) = set_locale!(current_locales(), cat, loc)
function set_locale!(gloc::Locale, cat::Symbol, loc::LangTag)
    cld = gloc.dict
    valid = keys(cld)
    cat in valid || error("unsupported category: $cat")
    if cat == :ALL
        for c in valid
            cld[c] = loc
        end
    end
    cld[cat] = loc
    gloc.cloc = CLocales.newlocale(cat, loc, gloc.cloc)
    loc
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
    LangTag(posix_locale(string(category)))
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

function Locale()
    gloc = Locale(Ptr{Void}(0))
    for cat in ALL_CATEGORIES
        set_locale!(gloc, cat, default_locale(cat))
    end
    gloc
end

function all_default_categories()
    Dict{Symbol,LangTag}([x => ROOT for x in ALL_CATEGORIES])
end

function current_locales()
    tld = task_local_storage()
    if !haskey(tld, :CURRENT_LOCALES)
        gloc = Locale() # create and fill with default values from ENV
        finalizer(finalize_gloc, gloc)
        task_local_storage(:CURRENT_LOCALES, gloc)
    else
        task_local_storage(:CURRENT_LOCALES)
    end
end

function finalize_gloc(gloc::Locale)
    empty!(gloc.dict)
    if gloc.cloc != Ptr{Void}(0)
        CLocales.freelocale(gloc.cloc)
    end
end


"""

    ROOT

Useful constant for the root locale.  The root locale is the locale whose
language, country, and variant are empty ("") strings.  This is regarded
as the base locale of all locales, and is used as the language/country
neutral locale for the locale sensitive operations. 
"""
const ROOT = LangTag("", "")
const BOTTOM = LangTag(:Bot, S0, S0, EMPTY_VECTOR, EMPTYD) 

"""
    Provide a set of commonly used LangTag with language- and country names
    in uppercase. e.g. `FRENCH`, `UK`. See also `names(Locales)`.
"""
module Locales

    import ResourceBundles: LangTag

    export ENGLISH, FRENCH, GERMAN, ITALIAN, JAPANESE, KOREAN, CHINESE,
        SIMPLIFIED_CHINESE, TRADITIONAL_CHINESE
    export FRANCE, GERMANY, ITALY, JAPAN, KOREA, CHINA, TAIWAN, PRC, UK, US, CANADA

    # Languages
    const ENGLISH = LangTag("en", "")
    const FRENCH = LangTag("fr", "")
    const GERMAN = LangTag("de", "")
    const ITALIAN = LangTag("it", "")
    const JAPANESE = LangTag("ja", "")
    const KOREAN = LangTag("ko", "")
    const CHINESE = LangTag("zh", "")
    const SIMPLIFIED_CHINESE = LangTag("zh", "CN")
    const TRADITIONAL_CHINESE = LangTag("zh", "TW")

    # Countries
    const FRANCE = LangTag("fr", "FR")
    const GERMANY = LangTag("de", "DE")
    const ITALY = LangTag("it", "IT")
    const JAPAN = LangTag("ja", "JP")
    const KOREA = LangTag("ko", "KR")
    const PRC = SIMPLIFIED_CHINESE
    const CHINA = PRC
    const TAIWAN = TRADITIONAL_CHINESE
    const UK = LangTag("en", "GB")
    const US = LangTag("en", "US")
    const CANADA = LangTag("en", "CA")

end # module LocaleTag

