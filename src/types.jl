
"""

    struct LocaleId

Represent a Languange Tag, also known as Locale Identifier as defined by BCP47.
See: https://tools.ietf.org/html/bcp47
"""
struct LocaleId
    language::Symbol
    script::Symbol
    region::Symbol
    variants::Vector{Symbol}
    extensions::Union{Dict{Char,Vector{Symbol}},Nothing}
end

"""
    mutable struct Locale

Keeps a locale identifier for each locale category.
The locale categories are defined like in GNU (see `man 7 locale`).
Parallel to that the libc implementation of locale is kept as a cache.
It is maintained by the libc functions `newlocale` / `freelocale`.
"""
mutable struct Locale
    dict::Dict{Symbol,LocaleId}
    cloc::Ptr{Nothing}
    Locale(ptr::Ptr{Nothing}) = new(all_default_categories(), ptr)
end

module LC

export Category, CategorySet

"""
    Locale category.

Constants for each of the LC_xxxxxx categories of the GNU locale definition
are provided. The implementation class shall not be visible.
"""
abstract type CategorySet end
abstract type Category <: CategorySet end

struct _CategoryImplementation <: Category
    name::Symbol
    id::Int8
    mask::Cint
    _CategoryImplementation(n::Symbol, nr::Integer) = new(n, nr, 1<<nr)
end

const CTYPE = _CategoryImplementation(:CTYPE, 0)
const NUMERIC = _CategoryImplementation(:NUMERIC, 1)
const TIME = _CategoryImplementation(:TIME, 2)
const COLLATE = _CategoryImplementation(:COLLATE, 3)
const MONETARY = _CategoryImplementation(:MONETARY, 4)
const MESSAGES = _CategoryImplementation(:MESSAGES, 5)
const ALL = _CategoryImplementation(:ALL, 6)
const PAPER = _CategoryImplementation(:PAPER, 7)
const NAME = _CategoryImplementation(:NAME, 8)
const ADDRESS = _CategoryImplementation(:ADDRESS, 9)
const TELEPHONE = _CategoryImplementation(:TELEPHONE, 10)
const MEASUREMENT = _CategoryImplementation(:MEASUREMENT, 11)
const IDENTIFICATION = _CategoryImplementation(:IDENTIFICATION, 12)

const _ALL_CATS = [CTYPE, NUMERIC, TIME, COLLATE, MONETARY, MESSAGES, ALL,
                   PAPER, NAME, ADDRESS, TELEPHONE, MEASUREMENT, IDENTIFICATION]

const _MASK_ALL = Cint(64)

struct _CategorySetImplementation <: CategorySet
    mask::Cint
    _CategorySetImplementation(m::Cint) = new(m & _MASK_ALL == 0 ? m : _MASK_ALL)  
end 

mask(cat::CategorySet) = cat.mask
import Base: show, issubset, |

show(io::IO, cat::Category) = print(io, string(cat.name))
function show(io::IO, cs::CategorySet)
    mcs = mask(cs)
    suc = false
    for cat in _ALL_CATS
        if mcs & mask(cat) != 0
            suc && print(io, '|')
            show(io, cat)
            suc = true
        end
    end
end

function issubset(a::CategorySet,b::CategorySet)
    ma, mb = mask(a), mask(b)
    ( ma | mb == mb ) || (mb & _MASK_ALL != 0)
end

function |(a::CategorySet, b::CategorySet)
    ma, mb = mask(a), mask(b)
    mab = ma | mb
    mab & _MASK_ALL != 0 ? ALL :
    mab == ma ? a :
    mab == mb ? b :
    _CategorySetImplementation(mab)
end

end # module LC


### unexported types

const CLocaleType = Ptr{Nothing}
const AS = AbstractString
const VariantVector = Vector{Symbol}
const ExtensionDict = Dict{Char,VariantVector}
const Key = Tuple{Symbol, Symbol, Symbol, VariantVector, Union{ExtensionDict,Nothing}}
