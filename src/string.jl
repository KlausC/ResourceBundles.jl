
"""
Name of resource bundle used for string messages.
"""
const MESSAGES = "messages"

"""
    tr"string_with_interpolation"

Return translated string accoring to string database and a default locale.
The interpolated values are embedded into the translated string.
Multiple plural forms are supported. The multiplicity is determined by the primary
interpolation value, which must be an integer.
"""
macro tr_str(p)
    src, mod = VERSION < v"0.7-DEV" ?
        (LineNumberNode(0),  current_module()) : (__source__, __module__)
    tr_macro_impl(src, mod, p)
end

"""
    string_to_key(text::AbstractString)

Convert text to key. Replace interpolation syntax with standardized interpoleated integers.
Example without explicit primarity:
    `string_to_key("text\$var \$(expr) \$(77)") == "text$(1) $(2) $(3)"`
Example with explicit primarity:
    `string_to_key("text\$var \$(!(expr)) \$(77)") == "text$(2) $(1) $(3)"`
(The first interpolation annotated with '`!`' gets number 1).
The interpolation must not be a literal string.
"""
string_to_key(p::AbstractString) = _string2ex1(p)[3]

function tr_macro_impl(::LineNumberNode, mod::Module, p::Any)
    ex1, arg, s1 = _string2ex1(p)
    arg = Expr(:tuple, arg...)
    :(eval(translate($s1, $mod, $ex1, $(esc(arg)))))
end

#  
function translate(s1::AbstractString, mod::Module, ex1, arg)
    mb = resource_bundle(mod, MESSAGES)
    resource = get_resource_by_key(mb, s1)
    s2 = resource != nothing ? get(resource.dict, s1, s1) : s1
    _translate(s1, s2, resource, ex1, arg)
end

# translate in case of single translation text
function _translate(s1::AbstractString, s2::AbstractString, resource, ex1::Any, arg)    
    ex2, ind2 = _string2ex(s2, arg)
    if length(ind2) > 0
        m1, m2 = extrema(ind2)
        m1 >= 1 && m2 <= length(arg) || return ex1
    end
    ex2
end

#translate in case of multiple translation texts (plural forms)
function _translate(s1::AbstractString, s2::Vector{S}, resource, ex1::Any, arg) where S<:AbstractString
    length(arg) >= 1 || throw(ArgumentError("tr needs at least one argument: '$s1'"))
    mp = arg[1]
    n = isinteger(mp) ? abs(Int(mp)) : 999 # if arg not integer numerically use plural form
    ix = resource != nothing ? resource.plural(n) + 1 : 1
    m = length(s2)
    ix = ifelse(ix <= m, ix, m)
    str = ix > 0 ? s2[ix] : s1 # fall back to key if vector is empty
    _translate(s1, str, resource, ex1, arg)
end

# produce modified Expr, list of interpolation arguments, and key string
function _string2ex1(p::AbstractString)
    ex = Meta.parse(string(TQ, p, TQ)) # parsing text argument of str_tr
    args = isa(ex, Expr) ? ex.args : [ex]
    ea = []
    i = 1
    multi = false
    for j in 1:length(args)
        a = args[j]
        if ! ( a isa String )
            if !multi && a isa Expr && a.head == :call && a.args[1] == SPRIME
                multi = true
                pushfirst!(ea, a.args[2]) # this argument goes to index 1
                args[j] = 1
                for k = 1:j-1
                    if args[k] isa Int  # previous arguments shift index
                        args[k] += 1
                    end
                end
                i += 1
            else
                args[j] = i
                push!(ea, a)
                i += 1
            end
        end
    end

    io = IOBuffer()
    for j in 1:length(args)
        a = args[j]
        if a isa String
            print(io, a)
        else
            print(io, "\$(", a, ")")
        end
    end
    ex, ea, String(take!(io))
end

# produce Expr with interpolation arguments replaced, and original list of positions
function _string2ex(p::AbstractString, oldargs)
    ex = Meta.parse(string(TQ, p, TQ)) # parsing translated text
    args = isa(ex, Expr) ? ex.args : [ex]
    i = 0
    ea = Int[]
    n = oldargs == nothing ? 0 : length(oldargs)
    for j in 1:length(args)
        a = args[j]
        if a isa Int
            i += 1
            args[j] = 0 < a <= n ? oldargs[a] : a
            push!(ea, a)
        end
    end
    ex, ea
end

TQ = "\"\"\""   # three quote characters in a string
SPRIME = :!     # multiplicity indicator in tr-string    tr"... $(!count) ..."
SCONTEXT = "§"  # context separator in tr-string         tr"§ctxname§..."
