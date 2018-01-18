
module CLocales

using ResourceBundles
using ResourceBundles.LocaleIdTranslations
using ResourceBundles.LC

import ResourceBundles: LocaleId, S0, locale, CLocaleType

export current_locale, newlocale, duplocale, freelocale, nl_langinfo, clocale_id
export NlItem, category, offset, typ
export strcoll, localize_isless
export LC_GLOBAL_LOCALE

"""
    newlocale(cat::LC.CategorySet, loc::LocaleId[, base::CLocaleType])::CLocaleType

Return a pointer to an opaque locale-object of glibc.
Modifies and invalidate the previously returned `base`.
`categories` may be on or a tuple of symbols `:CTYPE, :NUMERIC, :TIME, :COLLATE, :MONETARY,
:MESSAGES, :ALL, :PAPER, :NAME, :ADDRESS, :TELEPHONE, :MEASUREMENT, :IDENTIFICATION`.
The locale id is converted to a string of a locale name in POSIX-form.
This name must exist in the output of `locale -a` on a system using glibc.
If no such object exists, return `Ptr{Nothing}(0)`.
"""
newlocale(cat::CategorySet, loc::LocaleId) = newlocale(cat, loc, CL0)

function newlocale(cat::CategorySet, loc::LocaleId, base::CLocaleType)
    cloc = loc_to_cloc(loc)
    newlocale_c(LC.mask(cat), cloc, base)
end

"""
    current_clocale()

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
    ploc = newlocale(LC.ALL, loc)
    if ploc != CL0
        res = strcoll_c(a, b, ploc)
        freelocale(ploc)
        res
    else
        error("no posix locale found for $loc")
    end
end

"""
    localized_isless([loc::LocaleId])

Return isless function comparing two strings accoding to locale specific collation rules. 
If loc is not specified, use category `COLLATE` of current locale.
"""
localized_isless() = (a::AbstractString, b::AbstractString) -> strcoll(a, b) < 0
localized_isless(loc::LocaleId) = (a::AbstractString, b::AbstractString) -> strcoll(a, b, loc) < 0

"""
Mask composed of output-type, category, and offset
"""
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
function nl_item(cat::Category, offset::Integer, typ::Integer=0)
    NlItem(Cint(cat.id & 0x00fff)<<16 + Cint(offset) & 0xffff + Cint(typ)<<28)
end

category(nli::NlItem) = LC.ALL_CATS[((nli.mask>>16) & 0x0fff)+1]
offset(nli::NlItem) = Int(nli.mask & 0xffff)
typ(nli::NlItem) = Int((nli.mask>>>28) & 0xffff)

nl_cmask(cat::NlItem) = cat.mask & Cint(0x0ffffff)
nl_ctype(cat::NlItem) = Int(cat.mask>>>28)

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

err_day(i::Integer) = throw(ArgumentError("day of week ($i) not between 1 and 7"))
err_month(i::Integer) = throw(ArgumentError("month number ($i) not between 1 and 12"))

"""
    clocale_id(category[, cloc::CLocaleType])

Return the name string of a clocale or current clocale. 
"""
clocale_id(cat::Category, loc::CLocaleType) = nl_langinfo(nl_item(cat, -1), loc)
clocale_id(cat::Category) = nl_langinfo(nl_item(cat, -1), current_clocale())

include("libc.jl")

## Interface constants derived from /usr/include/langinfo.h 

const CTYPE_CODESET = nl_item(LC.CTYPE, 14)
const NUM_LC_CTYPE = 86 

const RADIXCHAR = nl_item(LC.NUMERIC, 0)
const THOUSEP = nl_item(LC.NUMERIC, 1)
const THOUSANDS_SEP = nl_item(LC.NUMERIC, 1)
const GROUPING = nl_item(LC.NUMERIC, 2, 2)
const NUMERIC_CODESET = nl_item(LC.NUMERIC, 5)
const NUM_LC_NUMERIC = 6 

ABDAY(i::Integer) = 1 <= i <= 7 ? nl_item(LC.TIME, i-1) : err_day(i)
DAY(i::Integer) = 1 <= i <= 7 ? nl_item(LC.TIME, i+6) : err_day(i)
ABMON(i::Integer) = 1 <= i <= 12 ? nl_item(LC.TIME, 13+i) : err_month(i)
MON(i::Integer) = 1 <= i <= 12 ? nl_item(LC.TIME, 25+i) : err_month(i)
const AM_STR = nl_item(LC.TIME, 38)
const PM_STR = nl_item(LC.TIME, 39)
const D_T_FMT = nl_item(LC.TIME, 40)
const D_FMT = nl_item(LC.TIME, 41)
const T_FMT = nl_item(LC.TIME, 42)
const T_FMT_AMPM = nl_item(LC.TIME, 43)
const ERA = nl_item(LC.TIME, 44) 
const ERA_YEAR = nl_item(LC.TIME, 45) 
const ERA_D_FMT = nl_item(LC.TIME, 46) 
const ALT_DIGITS = nl_item(LC.TIME, 47) 
const ERA_D_T_FMT = nl_item(LC.TIME, 48) 
const ERA_T_FMT = nl_item(LC.TIME, 49) 
const NUM_ERA_ENTRIES = nl_item(LC.TIME, 50, 1) 
const WEEK_NDAYS = nl_item(LC.TIME, 101, 2)
const WEEK_1STDAY = nl_item(LC.TIME, 102, 1)
const WEEK_1STWEEK = nl_item(LC.TIME, 103, 2)
const FIRST_WEEKDAY = nl_item(LC.TIME, 104, 2)
const FIRST_WORKDAY = nl_item(LC.TIME, 105, 2)
const CAL_DIRECTION = nl_item(LC.TIME, 106, 2)
const TIMEZONE = nl_item(LC.TIME, 107)
const DATE_FMT = nl_item(LC.TIME, 108)
const TIME_CODESET = nl_item(LC.TIME, 110) 
const NUM_LC_TIME = 111 

const COLLATE_CODESET = nl_item(LC.COLLATE, 18)
const NUM_LC_COLLATE = 19

const YESEXPR = nl_item(LC.MESSAGES, 0)
const NOEXPR = nl_item(LC.MESSAGES, 1)
const YESSTR = nl_item(LC.MESSAGES, 2)
const NOSTR = nl_item(LC.MESSAGES, 3)
const MESSAGES_CODESET = nl_item(LC.MESSAGES, 4)
const NUM_LC_MESSAGES = 5 

const INT_CURR_SYMBOL = nl_item(LC.MONETARY, 0)
const CURRENCY_SYMBOL = nl_item(LC.MONETARY, 1)
const MON_DECIMAL_POINT = nl_item(LC.MONETARY, 2)
const MON_THOUSANDS_SEP = nl_item(LC.MONETARY, 3)
const MON_GROUPING = nl_item(LC.MONETARY, 4, 2)
const POSITIVE_SIGN = nl_item(LC.MONETARY, 5)
const NEGATIVE_SIGN = nl_item(LC.MONETARY, 6)
const INT_FRAC_DIGITS = nl_item(LC.MONETARY, 7, 2)
const FRAC_DIGITS = nl_item(LC.MONETARY, 8, 2)
const P_CS_PRECEDES = nl_item(LC.MONETARY, 9, 2)
const P_SEP_BY_SPACE = nl_item(LC.MONETARY, 10, 2)
const N_CS_PRECEDES = nl_item(LC.MONETARY, 11, 2)
const N_SEP_BY_SPACE = nl_item(LC.MONETARY, 12, 2)
const P_SIGN_POSN = nl_item(LC.MONETARY, 13, 2)
const N_SIGN_POSN = nl_item(LC.MONETARY, 14, 2)
const CRNCYSTR = nl_item(LC.MONETARY, 15)
const INT_P_CS_PRECEDES = nl_item(LC.MONETARY, 16, 2)
const INT_P_SEP_BY_SPACE = nl_item(LC.MONETARY, 17, 2)
const INT_N_CS_PRECEDES = nl_item(LC.MONETARY, 18, 2)
const INT_N_SEP_BY_SPACE = nl_item(LC.MONETARY, 19, 2)
const INT_P_SIGN_POSN = nl_item(LC.MONETARY, 20, 2)
const INT_N_SIGN_POSN = nl_item(LC.MONETARY, 21, 2)
const MONETARY_CODESET = nl_item(LC.MONETARY, 45)
const NUM_LC_MONETARY = 46 

const PAPER_HEIGHT = nl_item(LC.PAPER, 0, 1)
const PAPER_WIDTH = nl_item(LC.PAPER, 1, 1)
const PAPER_CODESET = nl_item(LC.PAPER, 2)
const NUM_LC_PAPER = 3 

const NAME_FMT = nl_item(LC.NAME, 0)
const NAME_GEN = nl_item(LC.NAME, 1)
const NAME_MR = nl_item(LC.NAME, 2)
const NAME_MRS = nl_item(LC.NAME, 3)
const NAME_MISS = nl_item(LC.NAME, 4)
const NAME_MS = nl_item(LC.NAME, 5)
const NAME_CODESET = nl_item(LC.NAME, 6)
const NUM_LC_NAME = 7 

const ADDRESS_POSTAL_FMT = nl_item(LC.ADDRESS, 0)
const ADDRESS_COUNTRY_NAME = nl_item(LC.ADDRESS, 1)
const ADDRESS_COUNTRY_POST = nl_item(LC.ADDRESS, 2)
const ADDRESS_COUNTRY_AB2 = nl_item(LC.ADDRESS, 3)
const ADDRESS_COUNTRY_AB3 = nl_item(LC.ADDRESS, 4)
const ADDRESS_COUNTRY_CAR = nl_item(LC.ADDRESS, 5)
const ADDRESS_COUNTRY_NUM = nl_item(LC.ADDRESS, 6, 1)
const ADDRESS_COUNTRY_ISBN = nl_item(LC.ADDRESS, 7)
const ADDRESS_LANG_NAME = nl_item(LC.ADDRESS, 8)
const ADDRESS_LANG_AB = nl_item(LC.ADDRESS, 9)
const ADDRESS_LANG_LIB = nl_item(LC.ADDRESS, 10)
const ADDRESS_LANG_TERM = nl_item(LC.ADDRESS, 11)
const ADDRESS_CODESET = nl_item(LC.ADDRESS, 12)
const NUM_LC_ADDRESS = 13 

const TELEPHONE_TEL_INT_FMT = nl_item(LC.TELEPHONE, 0)
const TELEPHONE_TEL_DOM_FMT = nl_item(LC.TELEPHONE, 1)
const TELEPHONE_INT_SELECT = nl_item(LC.TELEPHONE, 2)
const TELEPHONE_INT_PREFIX = nl_item(LC.TELEPHONE, 3)
const TELEPHONE_CODESET = nl_item(LC.TELEPHONE, 4)
const NUM_LC_TELEPHONE = 5 

const MEASUREMENT = nl_item(LC.MEASUREMENT, 0, 2)
const MEASUREMENT_CODESET = nl_item(LC.MEASUREMENT, 1)
const NUM_LC_MEASUREMENT = 2 

const IDENTIFICATION_TITLE = nl_item(LC.IDENTIFICATION, 0)
const IDENTIFICATION_SOURCE = nl_item(LC.IDENTIFICATION, 1)
const IDENTIFICATION_ADDRESS = nl_item(LC.IDENTIFICATION, 2)
const IDENTIFICATION_CONTACT = nl_item(LC.IDENTIFICATION, 3)
const IDENTIFICATION_EMAIL = nl_item(LC.IDENTIFICATION, 4)
const IDENTIFICATION_TEL = nl_item(LC.IDENTIFICATION, 5)
const IDENTIFICATION_FAX = nl_item(LC.IDENTIFICATION, 6)
const IDENTIFICATION_LANGUAGE = nl_item(LC.IDENTIFICATION, 7)
const IDENTIFICATION_TERRITORY = nl_item(LC.IDENTIFICATION, 8)
const IDENTIFICATION_AUDIENCE = nl_item(LC.IDENTIFICATION, 9)
const IDENTIFICATION_APPLICATION = nl_item(LC.IDENTIFICATION, 10)
const IDENTIFICATION_ABBREVIATION = nl_item(LC.IDENTIFICATION, 11)
const IDENTIFICATION_REVISION = nl_item(LC.IDENTIFICATION, 12)
const IDENTIFICATION_DATE = nl_item(LC.IDENTIFICATION, 13)
const IDENTIFICATION_CATEGORY = nl_item(LC.IDENTIFICATION, 14)
const IDENTIFICATION_CODESET = nl_item(LC.IDENTIFICATION, 15)
const NUM_LC_IDENTIFICATION = 16 

LC_GLOBAL_LOCALE = CLocaleType(-1)
CL0 = CLocaleType(0)

end # module
