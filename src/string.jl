function _messages_variable(__module__::Module)
    if !isdefined(__module__, :MESSAGE_BUNDLE)
        eval(__module__, :(MESSAGE_BUNDLE = ResourceBundle($__module__, "messages")))
    else
        __module__.MESSAGE_BUNDLE
    end
end

function _string2ex(p::AbstractString, oldargs = nothing)
    ex = parse(string('"', p, '"'))
    args = isa(ex, Expr) ? ex.args : [ex]
    io = IOBuffer()
    i = 0
    ea = []
    n = oldargs == nothing ? 0 : length(oldargs)
    for j in 1:length(args)
        a = args[j]
        if isa(a, String)
            print(io, a)
        else
            i += 1
            print(io, "\$(", i, ")")
            if isa(a, Int)
                args[j] = 0 < a <= n ? oldargs[a] : a
                push!(ea, a)
            else
                args[j] = i
                push!(ea, a)
            end
        end
    end
    ex, ea, String(take!(io))
end

function _translate(s1::AbstractString, mb::ResourceBundle, ex1::Any, arg)    
    s2 = get(mb, s1, s1)
    ex2, ind2, dummy2 = _string2ex(s2, arg)
    if length(ind2) > 0
        m1, m2 = extrema(ind2)
        m1 >= 1 && m2 <= length(arg) || return ex1
    end
    ex2
end

function tr_macro_impl(::LineNumberNode, __module__::Module, p::Any)
    mb = _messages_variable(__module__)
    ex1, arg, s1 = _string2ex(p)
    arg = Expr(:tuple, arg...)
    :(eval(_translate($s1, $mb, $ex1, $(esc(arg)))))
end

macro tr_str(p)
    tr_macro_impl(__source__, __module__, p)
end

function _translaten(s1::AbstractString, mb::ResourceBundle, ex1::Any, arg)
    length(arg) == 1 || throw(ArgumentError("trn needs exactly one argument: '$s1'"))
    n = Int(arg[1])
    s2 = get(mb, s1, s1)
    a = split(s2, r"(\\n|\n)")
    println("a: '$a'")
    for s2 in a
        ex2, arg2, dummy2 = _string2ex(s2)
        println("ex2-args: ", arg2...)
        length(arg2) == 1 || throw(ArgumentError("trn replacement texts need exactly one argument: '$s2'"))
        valid, value = _verify_multiplicity(n, arg2[1])
        if valid
            k = _searchindex(ex2.args, 1)
            ex2.args[k] = string(value)
            return ex2
        end
    end
    ex1
end

function _searchindex(a::Vector, n::Integer)
    k = 1
    while k <= length(a)
        a[k] == n && return k
        k += 1
    end
    0
end

function _verify_multiplicity(n::Integer, ex::Any)
    println("n = $n - ex = '$ex'")
    if isa(ex, Integer)
        println("Int")
        return ex == n, n
    elseif ex == :Any
        println("Any")
        return true, n
    elseif isa(ex, Expr) && ex.head == :call && ex.args[1] == :(=>)
        println("=>")
        if ( ex.args[2] == n || ex.args[2] == :Any )
            return true, ex.args[3]
        end
    end
    false, ""
end
            
function trn_macro_impl(::LineNumberNode, __module__::Module, p::Any)
    mb = _messages_variable(__module__)
    ex1, arg, s1 = _string2ex(p)
    arg = Expr(:tuple, arg...)
    :(eval(_translaten($s1, $mb, $ex1, $(esc(arg)))))
end

macro trn_str(p)
    trn_macro_impl(__source__, __module__, p)    
end

