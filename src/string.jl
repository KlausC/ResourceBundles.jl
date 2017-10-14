

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

function string2ex(p::AbstractString)
    ex = parse(string('"', p, '"'))
    args = isa(ex, Expr) ? ex.args : [ex]
    io = IOBuffer()
    i = 0
    ea = []
    for j in 1:length(args)
        a = args[j]
        if isa(a, String)
            print(io, a)
        elseif isa(a, Int)
            print(io, "\$(", a, ")")
            args[j] = a
            push!(ea, a)
        else
            i += 1
            print(io, "\$(", i, ")")
            args[j] = i
            push!(ea, eval(a))
        end
    end
    ex, ea, String(take!(io))
end

function eval_string(ex::Expr, arg::Vector)
    io = IOBuffer()
    for a in ex.args
        if isa(a, Int)
            print(io, string(arg[a]))
        else
            print(io, a)
        end
    end
    String(take!(io))
end
eval_string(ex::AbstractString, arg::Vector) = ex

function translate(p::AbstractString, locale::Any)
    ex1, arg, s1 = string2ex(p)
    s2 = lookup(locale, s1)
    ex2, ind2, dummy2 = string2ex(s2)
    if length(ind2) > 0
        m1, m2 = extrema(ind2)
        m1 >= 1 && m2 <= length(arg) || return eval_string(ex1, arg)
    end
    eval_string(ex2, arg)
end

translate(p::AbstractString) = translate(p, default_locale_messages())

macro tr_str(p)
    :(translate($p))
end



