
module CLocales
import ResourceBundles: LangTag, S0, current_locales

export newlocale, duplocale, freelocale, nl_langinfo
export strcoll, strxfrm, LC_NUMBER, LC_GLOBAL_LOCALE

const CLocaleType = Ptr{Void}

function newlocale(mask::Int, loc::LangTag, base::CLocaleType = CL0)
    cloc = Clocale(loc)
    cmask = fixmask(mask)
    newlocale_c(cmask, cloc, base)
end

function newlocale(sym::Symbol, loc::LangTag, base::CLocaleType) where N
    cloc = Clocale(loc)
    mask = sym2mask(sym)
    newlocale_c(mask, cloc, base)
end

function newlocale(syms::NTuple{N,Symbol}, loc::LangTag, base::CLocaleType) where N
    cloc = Clocale(loc)
    mask = sym2mask(syms...)
    newlocale_c(mask, cloc, base)
end

strcoll(a::AbstractString, b::AbstractString) = strcoll_c(a, b, current_clocale())
function strcoll(a::AbstractString, b::AbstractString, loc::LangTag)
    ploc = newlocale(LC_COLLATE_MASK, loc)
    if ploc != CL0
        res = strcoll(a, b, Clocale(loc))
        freelocale(ploc)
        return res
    end
    error("no posix locale found for $loc")
end

nl_langinfo(nlitem::Cint) = nl_langinfo(nlitem, current_clocale())
function nl_langinfo(nlitem::Cint, ploc::CLocaleType)
    res = nl_langinfo_c(nlitem, ploc::CLocaleType)
    unsafe_string(res)
end
    
### accessing libc functions (XOPEN_SOURCE >= 700, POSIX_C_SOURCE >= 200809L glibc>=2.24)

function newlocale_c(mask::Int, clocale::AbstractString, base::CLocaleType)
    cmask = fixmask(mask)
    ccall(:newlocale, CLocaleType, (Cint, Cstring, CLocaleType), cmask, clocale, base)
end

function duplocale(ploc::CLocaleType)
    ccall(:duplocale, CLocaleType, (CLocaleType,), ploc)
end

function freelocale(ploc::CLocaleType)
    ccall(:freelocale, Void, (CLocaleType,), ploc)
end

function strcoll_c(s1::AbstractString, s2::AbstractString, ploc::CLocaleType)
    res = 0
    if ploc == CL0
        ploc = current_clocale()
    end
    if ploc != CL0
        res = ccall(:strcoll_l, Cint, (Cstring, Cstring, CLocaleType), s1, s2, ploc)
        freelocale(ploc)
    end
    Int(res)
end

function nl_langinfo_c(nlitem::Cint, ploc::CLocaleType)
    ccall(:nl_langinfo_l, Ptr{UInt8}, (Cint, CLocaleType), nlitem, ploc)
end

#################################

function current_clocale()
    current_locales().cloc
end

fixmask(mask::Int) = Cint(mask & LC_ALL_MASK == 0 ? mask : LC_ALL_MASK)

nl_item(cat::Integer, offset::Integer) = Cint(cat)<<16 + Cint(offset) & 0xffff

function nl_langinfo(category::Integer, offset::Integer, loc::CLocaleType)
    res = nl_langinfo_call(nl_item(category, offset), loc)
    res == Ptr{UInt8}(0) ? "" : unsafe_string(res)
end

nl_langinfo(category::Integer, loc::CLocaleType) = nl_langinfo(category, -1, loc)


function sym2mask(syms::Symbol...)
    mask = 0
    for s in syms
        ms = lc_mask(get(LC_NUMBER, s, 0))
        mask |= ms
    end
    mask = mask & LC_ALL_MASK == 0 ? mask : LC_ALL_MASK
    mask
end

# translations from LangTag to String in POSIX Format

function Clocale(loc::LangTag)
    s = string(loc)
    if s == "C" || s == "POSIX"
        return s
    end
    reg = loc.region
    allo = all_locales()
    if reg != S0
        su = locale_name(loc.language, reg)
        if findfirst(x -> x == su, allo) != 0
            return su
        else
            s = loc.language
        end
    else
        s = loc.language
    end

    s = string(s)
    su = locale_name(s, uppercase(s))
    if findfirst( x ->x == su, allo) != 0
        return su
    end

    dict = Dict("en" => "US", "zh" => "CN", "sv" => "SE")
    reg = get(dict, s, "")
    if reg != ""
        su = locale_name(s, reg)
        if findfirst( x ->x == su, allo) != 0
            return su
        end
    end

    ix = findfirst(x -> x == s || startswith(x, s * '_'), allo)
    return ix != 0 ? allo[ix] : "C"
end

locale_name(lang, reg) = string(lang, '_', reg, UTF8)

allloc = String[]

function all_locales()
    global allloc
    if isempty(allloc)
        list = String[]
        push!(list, "C", "POSIX")
        for loc in eachline(`locale -a`)
            loca, ext = splitext(loc)
            simple = ext == "" && '_' ∉ loca
            standard = loca == "C" || loca == "POSIX"
            if ( simple || ext == UTF8 ) && !standard
                push!(list, loc)
            end
        end
        allloc = list
    end
    allloc
end
const UTF8 = ".utf8"

## Interface constants 
const LC_CTYPE = 0
const LC_NUMERIC = 1
const LC_TIME = 2
const LC_COLLATE = 3
const LC_MONETARY = 4
const LC_MESSAGES = 5
const LC_ALL = 6
const LC_PAPER = 7
const LC_NAME = 8
const LC_ADDRESS = 9
const LC_TELEPHONE = 10
const LC_MEASUREMENT = 11
const LC_IDENTIFICATION = 12

NAME(cat::Int) = nl_item(cat, -1)
NAME(s::Symbol) = NAME(LC_NUMBER[s])

const CODESET = nl_item(LC_CTYPE, 14)
const NUM_LC_CTYPE = 86 

ABDAY(i::Int) = nl_item(LC_TIME, i-1)
DAY(i::Int) = nl_item(LC_TIME, i+6)
ABMON(i::Int) = nl_item(LC_TIME, 13+i)
MON(i::Int) = nl_item(LC_TIME, 25+i)
const AM_STR = nl_item(LC_TIME, 38)
const PM_STR = nl_item(LC_TIME, 39)
const D_T_FMT = nl_item(LC_TIME, 40)
const D_FMT = nl_item(LC_TIME, 41)
const T_FMT = nl_item(LC_TIME, 42)
const T_FMT_AMPM = nl_item(LC_TIME, 43)
const ERA = nl_item(LC_TIME, 44) 
const ERA_YEAR = nl_item(LC_TIME, 45) 
const ERA_D_FMT = nl_item(LC_TIME, 46) 
const ALT_DIGITS = nl_item(LC_TIME, 47) 
const ERA_D_T_FMT = nl_item(LC_TIME, 48) 
const ERA_T_FMT = nl_item(LC_TIME, 49) 
const TIME_CODESET = nl_item(LC_TIME, 110) 
const NUM_LC_TIME = 111 

const RADIXCHAR = nl_item(LC_NUMERIC, 0)
const THOUSEP = nl_item(LC_NUMERIC, 1)
const THOUSANDS_SEP = nl_item(LC_NUMERIC, 1)
const GROUPING = nl_item(LC_NUMERIC, 2)
const NUMERIC_CODESET = nl_item(LC_NUMERIC, 5)
const NUM_LC_NUMERIC = 6 

const YESEXPR = nl_item(LC_MESSAGES, 0)
const NOEXPR = nl_item(LC_MESSAGES, 1)
const YESSTR = nl_item(LC_MESSAGES, 2)
const NOSTR = nl_item(LC_MESSAGES, 3)
const MESSAGES_CODESET = nl_item(LC_MESSAGES, 4)
const NUM_LC_MESSAGES = 5 

const INT_CURR_SYMBOL = nl_item(LC_MONETARY, 0)
const CURRENCY_SYMBOL = nl_item(LC_MONETARY, 1)
const MON_DECIMAL_POINT = nl_item(LC_MONETARY, 2)
const MON_THOUSANDS_SEP = nl_item(LC_MONETARY, 3)
const MON_GROUPING = nl_item(LC_MONETARY, 4)
const POSITIVE_SIGN = nl_item(LC_MONETARY, 5)
const NEGATIVE_SIGN = nl_item(LC_MONETARY, 6)
const INT_FRAC_DIGITS = nl_item(LC_MONETARY, 7)
const FRAC_DIGITS = nl_item(LC_MONETARY, 8)
const P_CS_PRECEDES = nl_item(LC_MONETARY, 9)
const P_SEP_BY_SPACE = nl_item(LC_MONETARY, 10)
const N_CS_PRECEDES = nl_item(LC_MONETARY, 11)
const N_SEP_BY_SPACE = nl_item(LC_MONETARY, 12)
const P_SIGN_POSN = nl_item(LC_MONETARY, 13)
const N_SIGN_POSN = nl_item(LC_MONETARY, 14)
const CRNCYSTR = nl_item(LC_MONETARY, 15)
const INT_P_CS_PRECEDES = nl_item(LC_MONETARY, 16)
const INT_P_SEP_BY_SPACE = nl_item(LC_MONETARY, 17)
const INT_N_CS_PRECEDES = nl_item(LC_MONETARY, 18)
const INT_N_SEP_BY_SPACE = nl_item(LC_MONETARY, 19)
const INT_P_SIGN_POSN = nl_item(LC_MONETARY, 20)
const INT_N_SIGN_POSN = nl_item(LC_MONETARY, 21)
const MONETARY_CODESET = nl_item(LC_MONETARY, 45)
const NUM_LC_MONETARY = 46 

const PAPER_HEIGHT = nl_item(LC_PAPER, 0)
const PAPER_WIDTH = nl_item(LC_PAPER, 1)
const PAPER = nl_item(LC_PAPER, 2)
const NUM_LC_PAPER = 3 

const NAME_FMT = nl_item(LC_NAME, 0)
const NAME_GEN = nl_item(LC_NAME, 1)
const NAME_MR = nl_item(LC_NAME, 2)
const NAME_MRS = nl_item(LC_NAME, 3)
const NAME_MISS = nl_item(LC_NAME, 4)
const NAME_MS = nl_item(LC_NAME, 5)
const NAME_CODESET = nl_item(LC_NAME, 6)
const NUM_LC_NAME = 7 

const ADDRESS_POSTAL_FMT = nl_item(LC_ADDRESS, 0)
const ADDRESS_COUNTRY_NAME = nl_item(LC_ADDRESS, 1)
const ADDRESS_COUNTRY_POST = nl_item(LC_ADDRESS, 2)
const ADDRESS_COUNTRY_AB2 = nl_item(LC_ADDRESS, 3)
const ADDRESS_COUNTRY_AB3 = nl_item(LC_ADDRESS, 4)
const ADDRESS_COUNTRY_CAR = nl_item(LC_ADDRESS, 5)
const ADDRESS_COUNTRY_NUM = nl_item(LC_ADDRESS, 6)
const ADDRESS_COUNTRY_ISBN = nl_item(LC_ADDRESS, 7)
const ADDRESS_LANG_NAME = nl_item(LC_ADDRESS, 8)
const ADDRESS_LANG_AB = nl_item(LC_ADDRESS, 9)
const ADDRESS_LANG_LIB = nl_item(LC_ADDRESS, 10)
const ADDRESS_LANG_TERM = nl_item(LC_ADDRESS, 11)
const ADDRESS_CODESET = nl_item(LC_ADDRESS, 12)
const NUM_LC_ADDRESS = 13 

const TELEPHONE_TEL_INT_FMT = nl_item(LC_TELEPHONE, 0)
const TELEPHONE_TEL_DOM_FMT = nl_item(LC_TELEPHONE, 1)
const TELEPHONE_INT_SELECT = nl_item(LC_TELEPHONE, 2)
const TELEPHONE_INT_PREFIX = nl_item(LC_TELEPHONE, 3)
const TELEPHONE_CODESET = nl_item(LC_TELEPHONE, 4)
const NUM_LC_TELEPHONE = 5 

const MEASUREMENT = nl_item(LC_MEASUREMENT, 0)
const MEASUREMENT_CODESET = nl_item(LC_MEASUREMENT, 1)
const NUM_LC_MEASUREMENT = 2 

const IDENTIFICATION_TITLE = nl_item(LC_IDENTIFICATION, 0)
const IDENTIFICATION_SOURCE = nl_item(LC_IDENTIFICATION, 1)
const IDENTIFICATION_ADDRESS = nl_item(LC_IDENTIFICATION, 2)
const IDENTIFICATION_CONTACT = nl_item(LC_IDENTIFICATION, 3)
const IDENTIFICATION_EMAIL = nl_item(LC_IDENTIFICATION, 4)
const IDENTIFICATION_TEL = nl_item(LC_IDENTIFICATION, 5)
const IDENTIFICATION_FAX = nl_item(LC_IDENTIFICATION, 6)
const IDENTIFICATION_LANGUAGE = nl_item(LC_IDENTIFICATION, 7)
const IDENTIFICATION_TERRITORY = nl_item(LC_IDENTIFICATION, 8)
const IDENTIFICATION_AUDIENCE = nl_item(LC_IDENTIFICATION, 9)
const IDENTIFICATION_APPLICATION = nl_item(LC_IDENTIFICATION, 10)
const IDENTIFICATION_ABBREVIATION = nl_item(LC_IDENTIFICATION, 11)
const IDENTIFICATION_REVISION = nl_item(LC_IDENTIFICATION, 12)
const IDENTIFICATION_DATE = nl_item(LC_IDENTIFICATION, 13)
const IDENTIFICATION_CATEGORY = nl_item(LC_IDENTIFICATION, 14)
const IDENTIFICATION_CODESET = nl_item(LC_IDENTIFICATION, 15)
const NUM_LC_IDENTIFICATION = 16 

lc_mask(cat::Int) = 1 << cat

const LC_NUMBER = Dict(
      :CTYPE => (LC_CTYPE),
      :NUMERIC => (LC_NUMERIC),
      :TIME => (LC_TIME),
      :COLLATE => (LC_COLLATE),
      :MONETARY => (LC_MONETARY),
      :MESSAGES => (LC_MESSAGES),
      :ALL => (LC_ALL),
      :PAPER => (LC_PAPER),
      :NAME => (LC_NAME),
      :ADDRESS => (LC_ADDRESS),
      :TELEPHONE => (LC_TELEPHONE),
      :MEASUREMENT => (LC_MEASUREMENT),
      :IDENTIFICATION => (LC_IDENTIFICATION),
)

LC_GLOBAL_LOCALE = CLocaleType(-1)
LC_ALL_MASK = lc_mask(LC_ALL)
CL0 = CLocaleType(0)

end # module
