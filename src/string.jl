
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
        elseif isa(a, Int)
            print(io, "\$(", a, ")")
            args[j] = 0 < a <= n ? oldargs[a] : a
            push!(ea, a)
        else
            i += 1
            print(io, "\$(", i, ")")
            args[j] = i
            push!(ea, a)
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

macro tr_str(p)
    if !isdefined(__module__, :MESSAGE_BUNDLE)
        mb = eval(__module__, :(MESSAGE_BUNDLE = ResourceBundle($__module__, "messages")))
    else
        mb = __module__.MESSAGE_BUNDLE
    end
    ex1, arg, s1 = _string2ex(p)
    arg = Expr(:tuple, arg...)
    :(eval(_translate($s1, $mb, $ex1, $(esc(arg)))))
end

