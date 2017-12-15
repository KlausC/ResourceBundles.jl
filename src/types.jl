
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
    extensions::Dict{Char,Vector{Symbol}}
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
    cloc::Ptr{Void}
    Locale(ptr::Ptr{Void}) = new(all_default_categories(), ptr)
end

### unexported types

const CLocaleType = Ptr{Void}
const AS = AbstractString
const VariantVector = Vector{Symbol}
const ExtensionDict = Dict{Char,VariantVector}
const Key = Tuple{Symbol, Symbol, Symbol, VariantVector, ExtensionDict}
