
using .Constants
using .LocaleIdTranslations
using .LC

export LocaleId, Locales, default_locale, locale_id, locale, set_locale!

import Base: ==, hash


"""

    LocaleId(languagetag::String))
    LocaleId(lang, region)
    LocaleId(lang, script, region)
    LocaleId(lang, script, region, variant)
    LocaleId("") -> DEFAULT
    LocaleId() -> BOTTOM

Return `LocaleId` object from cache or create new one and register in cache.
"""
LocaleId() = BOTTOM
LocaleId(langtag::AS) = langtag == "" ? DEFAULT : create_locid(splitlangtag(langtag)...)
LocaleId(lang::AS, region::AS) = create_locid(lang, EMPTYV, "", region, EMPTYV, nothing)
LocaleId(lang::AS, script::AS, region::AS) = create_locid(lang, EMPTYV, script, region, EMPTYV, nothing)
LocaleId(lang::AS, script::AS, region::AS, variant::AS) = create_locid(lang, EMPTYV, script, region, [variant], nothing)


# utilities


# create instance and register in global cache.
function create_locid(language::AS, extlang::Vector{String}, script::AS, region::AS, variant::Vector{String}, extension::Union{ExtensionDict,Nothing})

    lang = check_language(language, extlang)
    scri = check_script(titlecase(script))
    regi = check_region(uppercase(region))
    vari = check_variant(variant)
    if lang == S0
        lex = extension == nothing ? 0 : length(extension)
        if !(scri == S0 && regi == S0 && length(vari) == 0 &&
             (lex == 1 && first(keys(extension)) == 'x' || lex == 0 ) )
            throw(ArgumentError("missing language prefix"))
        end
    end
    key = tuple(lang, scri, regi, vari, extension)
    try
        lock(CACHE_LOCK)
        get!(CACHE, key) do
            LocaleId(key...)
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
        len <= 1 || throw(ArgumentError("only one language extension allowed '$x$SEP2$(join(extlang, SEP2))'")) 
        if length(extlang) >= 1
            x = extlang[1]
        end
        if length(x) == 3
            x = LANGUAGE3_DICT[x] # replace 3-char code by preferred 2-char code
        end
    else
        len == 0 || throw(ArgumentError("no language exensions allowed '$x$SEP2$(join(extlang, SEP2))'"))
    end
    Symbol(x)
end

function is_language(x::AS)
    len = length(x)
    (2 <= len <= 8 && is_alpha(x)) || len == 1 && x == "C"
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
    all(is_variant, x) || throw(ArgumentError("no variants '$(join(x, SEP2))'")) 
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
    x = replace(x, SEP => SEP2) # normalize input
    x = get(GRANDFATHERED, x, x) # replace some old-fashioned language tags
    token = split(x, SEP2, keep=true)
    lang = ""
    langex = String[]
    scri = ""
    regi = ""
    vari = String[]
    exte = nothing
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
        if exte == nothing
            exte = ExtensionDict()
        end
        if haskey(exte, sing)
            throw(ArgumentError("multiple occurrence of singleton '$sing'"))
        end
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
is_alnum(x::AS) = all(is_alnum, x)
is_alnumsep(x::AS) = all(c->isascii(c) && ( is_alnum(c) || c in "-_.@" ), x)

# equality
function ==(x::LocaleId, y::LocaleId)
    x === y && return true
    x.language == y.language &&
    x.script == y.script &&
    x.region == y.region &&
    x.variants == y.variants &&
    x.extensions == y.extensions
end

function hash(x::LocaleId, h::UInt)
    hash(x.extensions, hash(x.variants, hash(x.region, hash(x.script, hash(x.language, h)))))
end

function Base.issubset(x::LocaleId, y::LocaleId)
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
function issubext(x::ExtensionDict, y::ExtensionDict)
    ky = keys(y)
    issubset(ky, keys(x)) &&
    all(k-> issubset(y[k], x[k]), ky)
end
issubext(x::Nothing, y::ExtensionDict) = false
issubext(x, y::Nothing) = true

Base.isless(x::LocaleId, y::LocaleId) = issubset(x, y) || (!issubset(y,x) && islexless(x, y))
islexless(x::LocaleId, y::LocaleId) = string(x) < string(y)

function Base.show(io2::IO, x::LocaleId)
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
    if x.extensions != nothing
        for k in sort(collect(keys(x.extensions)), lt=ltx)
            print(io, sep, k); sep = SEP2
            for v in x.extensions[k]
                print(io, sep, v)
            end
        end
    end
    out = String(take!(io))
    print(io2, out)
end

const CACHE = Dict{Key, LocaleId}()
const CACHE_LOCK = Threads.RecursiveSpinLock()


"""

    locale_id([gloc::Locale, ]category)

Determine current locale id for given category as stored in locale variable.
If gloc is not given, use task specific locale variable.
Throw exception, if no valid category name.
Valid categories are
:CTYPE, :COLLATE, :MESSAGES, :MONETARY, :NUMERIC, :TIME
"""
locale_id(cat::Category) = locale().locids[cat.id+1]
locale_id(gloc::Locale, cat::Category) = gloc.locids[cat.id+1]

"""

    set_locale!([gloc::Locale, ]locale::LocaleId[, category::CategorySet])

Set contents of locale in selected categories.
Missing category or :ALL sets all defined categories to the same locale.
If `gloc` is not given, the current task-specific locale is used.
Throw exception if category is not :ALL or one of the supported categories of `locale`.
"""
set_locale!(loc::LocaleId, cats::CategorySet = LC.ALL) = set_locale!(locale(), loc, cats)

function set_locale!(gloc::Locale, loc::LocaleId, cats::CategorySet = LC.ALL)
    cld = gloc.locids
    for cat in cats
        cld[cat.id+1] = loc == DEFAULT ? default_locale(cat) : loc
    end
    gloc.cloc = CLocales.newlocale(cats, loc, gloc.cloc)
    nothing
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
function default_locale(category::Category)
    LocaleId(localeid_from_env(category))
end

"""

    localeid_from_env(category)

Read posix environment variable for category.
"""
function localeid_from_env(category)
    s = uppercase(string(category))
    if !startswith(s, "LC_")
        s = s == "LANG" ? s : "LC_" * s
    end
    if s == "LC_ALL"
        get(ENV, s, "")
    else
        get2("LC_ALL") do
            get2(s) do
                get(ENV, "LANG", "C")
            end
        end
    end
end

# treat empty value 
function get2(f::Function, k::Any)
    v = get(ENV, k, "")
    v == "" ? f() : v
end

"""
    Locale()

Create and initialize a new `Locale` object.
"""
function Locale()
    gloc = Locale(Ptr{Nothing}(0))
    for cat in LC.ALL_CATS
        set_locale!(gloc, default_locale(cat), cat)
    end
    gloc
end

"""
    locale()

Return task specific locale object.
Create and initialize from environment at first access within a task.
"""
function locale()
    tld = task_local_storage()
    if !haskey(tld, :CURRENT_LOCALES)
        gloc = Locale() # create and fill with default values from ENV
        finalizer(finalize_gloc, gloc)
        task_local_storage(:CURRENT_LOCALES, gloc)
    else
        task_local_storage(:CURRENT_LOCALES)
    end
end

# finalizer required to free the associated clib object.
function finalize_gloc(gloc::Locale)
    if gloc.cloc != Ptr{Nothing}(0)
        CLocales.freelocale(gloc.cloc)
    end
end


"""

    DEFAULT

Useful constant for the default locale identifier. It is used to indicate,
that the actual value for concrete locale category (different form :ALL) has to
be determined from the global environment variables `LC_...` and `LANG`.
"""
const DEFAULT = LocaleId("", "")
"""

    ROOT

Useful constant for the root locale.  The root locale is the locale whose
language is "C", country, and variant are empty ("") strings.  This is regarded
as the base locale of all locales, and is used as the language/country
neutral locale for the locale sensitive operations. 
"""
const ROOT = LocaleId("C", "")

const BOTTOM = LocaleId(:Bot, S0, S0, EMPTY_VECTOR, nothing) 

"""
    Provide a set of commonly used LocaleId with language- and country names
    in uppercase. e.g. `FRENCH`, `UK`. See also `names(Locales)`.
"""
module Locales

    import ResourceBundles: LocaleId, ROOT, DEFAULT, BOTTOM

    export ROOT, DEFAULT, BOTTOM
    export ENGLISH, FRENCH, GERMAN, ITALIAN, JAPANESE, KOREAN, CHINESE,
        SIMPLIFIED_CHINESE, TRADITIONAL_CHINESE
    export FRANCE, GERMANY, ITALY, JAPAN, KOREA, CHINA, TAIWAN, PRC, UK, US, CANADA

    # Languages
    const ENGLISH = LocaleId("en", "")
    const FRENCH = LocaleId("fr", "")
    const GERMAN = LocaleId("de", "")
    const ITALIAN = LocaleId("it", "")
    const JAPANESE = LocaleId("ja", "")
    const KOREAN = LocaleId("ko", "")
    const CHINESE = LocaleId("zh", "")
    const SIMPLIFIED_CHINESE = LocaleId("zh", "CN")
    const TRADITIONAL_CHINESE = LocaleId("zh", "TW")

    # Countries
    const FRANCE = LocaleId("fr", "FR")
    const GERMANY = LocaleId("de", "DE")
    const ITALY = LocaleId("it", "IT")
    const JAPAN = LocaleId("ja", "JP")
    const KOREA = LocaleId("ko", "KR")
    const PRC = SIMPLIFIED_CHINESE
    const CHINA = PRC
    const TAIWAN = TRADITIONAL_CHINESE
    const UK = LocaleId("en", "GB")
    const US = LocaleId("en", "US")
    const CANADA = LocaleId("en", "CA")

end # module LocaleTag

