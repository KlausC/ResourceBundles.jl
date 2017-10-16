
function stringeval(ex::Expr)
    if ex.head === :string
        io = IOBuffer()
        i = 0; ea = []
        for a in ex.args
            if isa(a, String)
                print(io, a)
            else
                i += 1
                print(io, "{", i, "}")
                push!(ea, eval(a))
            end
        end
        return String(take!(io)), ea
    else
        eval(ex), []
    end
end

macro Y_str(p)
    :(stringeval(parse(string('"', $p, '"'))))
end

function stringevalloc(ex::Expr)
    if ex.head === :string
        io = IOBuffer()
        i = 0; ea = []
        for j in 1:length(ex.args)
            a = ex.args[j]
            if isa(a, String)
                print(io, a)
            else
                i += 1
                print(io, "{", i, "}")
                ex.args[j] = :(ea[$i])
                push!(ea, eval(a))
            end
        end
        s = String(take!(io))
        ex, ea, s 
    else
        eval(ex)
    end
end

macro loc_str(p)
    :(stringevalloc(parse(string('"', $p, '"'))))
end

function string2ex(p::AbstractString, oldargs = nothing)
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

function translate(p::AbstractString, locale::Any)
    ex1, arg, s1 = string2ex(p)
    translate2(s1, locale, ex1, arg)
end

function translate2(s1::AbstractString, locale::Any, ex1::Any, arg)    
    s2 = lookup(locale, s1)
    ex2, ind2, dummy2 = string2ex(s2, arg)
    if length(ind2) > 0
        m1, m2 = extrema(ind2)
        m1 >= 1 && m2 <= length(arg) || return ex1
    end
    ex2
end

translate(p::AbstractString) = translate(p, default_locale_messages())

macro tr_str(p)
    #esc(translate(p))
    ex1, arg, s1 = string2ex(p)
    arg = Expr(:tuple, arg...)
    :(eval(translate2($s1, default_locale_messages(), $ex1, $(esc(arg)))))
end



