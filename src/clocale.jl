
module CLocales

using ResourceBundles
using ResourceBundles.LocaleIdTranslations
import ResourceBundles: LocaleId, S0, locale, CLocaleType

export current_locale, newlocale, duplocale, freelocale, nl_langinfo, clocale_id
export NlItem, category, offset, typ
export strcoll, strxfrm, LC_NUMBER, LC_GLOBAL_LOCALE, LC_ALL_MASK
export LC_CTYPE, LC_NUMERIC, LC_TIME, LC_COLLATE, LC_MONETARY, LC_MESSAGES, LC_ALL
export LC_PAPER, LC_NAME, LC_ADDRESS, LC_TELEPHONE, LC_MEASUREMENT, LC_IDENTIFICATION

"""
    newlocale(loc::LocaleId[, base::CLocaleType], categories...)::CLocaleType

Return a pointer to an opaque locale-object of glibc.
Modifies and invalidate the previously returned `base`.
`categories` may be on or a tuple of symbols `:CTYPE, :NUMERIC, :TIME, :COLLATE, :MONETARY,
:MESSAGES, :ALL, :PAPER, :NAME, :ADDRESS, :TELEPHONE, :MEASUREMENT, :IDENTIFICATION`.
The locale id is converted to a string of a locale name in POSIX-form.
This name must exist in the output of `locale -a` on a system using glibc.
If no such object exists, return `Ptr{Nothing}(0)`.
"""
newlocale(loc::LocaleId, syms::Symbol...) = newlocale(loc, CL0, syms...)

function newlocale(loc::LocaleId, base::CLocaleType, syms::Symbol...)
    cloc = loc_to_cloc(loc)
    mask = sym2mask(syms...)
    newlocale_c(mask, cloc, base)
end

"""
    current_locale()

Return the task-specific current glibc-locale.
Any call to `set_locale!` or `newlocale` invalidates the returned pointer.
"""
function current_clocale()
    locale().cloc
end

"""
    strcoll(a::AbstractString, b::AbstractString[, loc::LocaleId]) -> -1, 0, 1

Compare two strings a and b using the locale specified by `loc` or the default-locale
for category `:MESSAGES`.
Return `a < b ? -1 : a > b ? 1 : 0`.
"""
strcoll(a::AbstractString, b::AbstractString) = strcoll_c(a, b, current_clocale())
function strcoll(a::AbstractString, b::AbstractString, loc::LocaleId)
    ploc = newlocale(LC_COLLATE_MASK, loc)
    if ploc != CL0
        res = strcoll(a, b, loc_to_cloc(loc))
        freelocale(ploc)
        return res
    end
    error("no posix locale found for $loc")
end


fixmask(mask::Int) = Cint(mask & LC_ALL_MASK == 0 ? mask : LC_ALL_MASK)

struct NlItem
    mask::Cint
end

"""
    nl_item(cat, offset, typ=0) -> NlItem(::Cint)

Create an NlItem object, which wraps Cint mask.
Result is:
typ == 0: char*
typ == 1: int of same size as pointer
typ == 2: *uint8
"""
function nl_item(cat::Integer, offset::Integer, typ::Integer=0)
    NlItem(Cint(cat&0x0fff)<<16 + Cint(offset) & 0xffff + Cint(typ)<<28)
end
nl_item(cat::Symbol, offset::Integer, typ::Integer=0) = nl_item(LC_NUMBER[cat], offset, typ)

category(nli::NlItem) = Int((nli.mask>>16) & 0x0fff)
offset(nli::NlItem) = Int(nli.mask & 0xffff)
typ(nli::NlItem) = Int((nli.mask>>>28) & 0xffff)

nl_cmask(cat::NlItem) = cat.mask & Cint(0x0ffffff)
nl_ctype(cat::NlItem) = Int(cat.mask>>>28)

lc_mask(cat::Int) = 1 << cat

"""
    nl_langinfo(cat::NlItem[, loc::CLocaleType] )
        -> string value | integer value

Provide information about the locale as stored in the glibc implementation.
"""
function nl_langinfo(cat::NlItem, loc::CLocaleType=current_clocale())
    res = nl_langinfo_c(nl_cmask(cat), loc)
    nl_convert(Val(nl_ctype(cat)), res)
end

const PTYPE = sizeof(Ptr) == 8 ? Int64 : Int32
const PU0 = Ptr{UInt8}(0)

nl_convert(::Val{0}, res::Ptr{UInt8}) = res === PU0 ? "" : unsafe_string(res)
nl_convert(::Val{1}, res::Ptr{UInt8}) = Int(Base.bitcast(PTYPE, res))
nl_convert(::Val{2}, res::Ptr{UInt8}) = res === PU0 ? 0 : Int(unsafe_wrap(Array, res, 1)[1])

"""
    clocale_id(category[, cloc::CLocaleType])

Return the name string of a clocale or current clocale. 
"""
clocale_id(cat::Union{Integer,Symbol}, loc::CLocaleType) = nl_langinfo(nl_item(cat, -1), loc)
clocale_id(cat::Union{Integer,Symbol}) = nl_langinfo(nl_item(cat, -1), current_clocale())

"""
    sym2mask(s::Symbol...)

Convert a category symbol or a list of symbols to a category mask.
If one of the symbols is `:ALL`, return `LC_ALL_MASK`.
Invalid symbols are silently ignored.
"""
function sym2mask(syms::Symbol...)
    mask = 0
    for s in syms
        ms = lc_mask(get(LC_NUMBER, s, 0))
        mask |= ms
    end
    mask = mask & LC_ALL_MASK == 0 ? mask : LC_ALL_MASK
    mask
end

include("libc.jl")

## Interface constants derived from /usr/include/langinfo.h 
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

const CTYPE_CODESET = nl_item(LC_CTYPE, 14)
const NUM_LC_CTYPE = 86 

const RADIXCHAR = nl_item(LC_NUMERIC, 0)
const THOUSEP = nl_item(LC_NUMERIC, 1)
const THOUSANDS_SEP = nl_item(LC_NUMERIC, 1)
const GROUPING = nl_item(LC_NUMERIC, 2, 2)
const NUMERIC_CODESET = nl_item(LC_NUMERIC, 5)
const NUM_LC_NUMERIC = 6 

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

const COLLATE_CODESET = nl_item(LC_COLLATE, 18)
const NUM_LC_COLLATE = 19

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
const MON_GROUPING = nl_item(LC_MONETARY, 4, 2)
const POSITIVE_SIGN = nl_item(LC_MONETARY, 5)
const NEGATIVE_SIGN = nl_item(LC_MONETARY, 6)
const INT_FRAC_DIGITS = nl_item(LC_MONETARY, 7, 2)
const FRAC_DIGITS = nl_item(LC_MONETARY, 8, 2)
const P_CS_PRECEDES = nl_item(LC_MONETARY, 9, 2)
const P_SEP_BY_SPACE = nl_item(LC_MONETARY, 10, 2)
const N_CS_PRECEDES = nl_item(LC_MONETARY, 11, 2)
const N_SEP_BY_SPACE = nl_item(LC_MONETARY, 12, 2)
const P_SIGN_POSN = nl_item(LC_MONETARY, 13, 2)
const N_SIGN_POSN = nl_item(LC_MONETARY, 14, 2)
const CRNCYSTR = nl_item(LC_MONETARY, 15)
const INT_P_CS_PRECEDES = nl_item(LC_MONETARY, 16, 2)
const INT_P_SEP_BY_SPACE = nl_item(LC_MONETARY, 17, 2)
const INT_N_CS_PRECEDES = nl_item(LC_MONETARY, 18, 2)
const INT_N_SEP_BY_SPACE = nl_item(LC_MONETARY, 19, 2)
const INT_P_SIGN_POSN = nl_item(LC_MONETARY, 20, 2)
const INT_N_SIGN_POSN = nl_item(LC_MONETARY, 21, 2)
const MONETARY_CODESET = nl_item(LC_MONETARY, 45)
const NUM_LC_MONETARY = 46 

const PAPER_HEIGHT = nl_item(LC_PAPER, 0, 1)
const PAPER_WIDTH = nl_item(LC_PAPER, 1, 1)
const PAPER_CODESET = nl_item(LC_PAPER, 2)
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
const ADDRESS_COUNTRY_NUM = nl_item(LC_ADDRESS, 6, 1)
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

const MEASUREMENT = nl_item(LC_MEASUREMENT, 0, 2)
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
