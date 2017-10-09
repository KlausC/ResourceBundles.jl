
import Base: ==, hash
"""
https://tools.ietf.org/html/bcp47
"""
struct BaseLocale
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
    return BaseLocale object
"""
BaseLocale(langtag::AS) = BaseLocale(splitlangtag(langtag)...)
BaseLocale(lang::AS, region::AS) = BaseLocale(lang, "", region, "", "", "")
BaseLocale(lang::AS, region::AS, variant::AS) = BaseLocale(lang, "", region, variant, "")
BaseLocale(lang::AS, script::AS, region::AS, variant::AS) = BaseLocale(lang, script, region, variant, "")

function BaseLocale(language::AS, script::AS, region::AS, variant::AS, extension::AS)
    lang = check_language(language)
    scri = check_script(script)
    regi = check_region(region)
    vari = check_variant(variant)
    exte = check_extension(extension)
    key = tuple(lang, scri, regi, vari, exte)
    get!(CACHE, key) do
       BaseLocale(key...)
    end
end

const SEPS = ['_', '-']
const NOSYM = Symbol('-')
const NOKEY = '\0'

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

function ==(x::BaseLocale, y::BaseLocale)
    x === y && return true
    x.language == y.language &&
    x.script == y.script &&
    x.region == y.region &&
    x.variants == y.variants &&
    x.extensions == y.extensions
end

function hash(x::BaseLocale, h::Int)
    hash(x.extensions, hash(x.variants, hash(x.region, hash(x.script, hash(x.language, h)))))
end


function Base.show(io::IO, x::BaseLocale)
    ES = Symbol("")
    SEP = "_"
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

const CACHE = Dict{Key, BaseLocale}()

