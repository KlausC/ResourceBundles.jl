

struct ParseState
    input::Vector{String}
    pos::Int
    output::Vector{Any}
end

function langtag(x::ParseState)
    language(x) && 
    option(script, x) && 
    option(region, x) && 
    multiple(variant, x) &&
    multiple(extension, x) &&
    option(privateuse, x)
end

function option(sub::Function, x::ParseState)
    y = copy(x)
    sub(x) || copy!(y, x)
    true
end

function string(x::ParseState, p::Function, low::Int, high::Int)
    str = x.input[i]
    len = length(str)
    if low <= len <= high && p(str)
        x.pos += 1
        push!(x.output, str)
        true
    else
        false
    end
end

const INF = 999

function multiple(sub::Function, x::ParseState, low::Int=0, high::Int=INF)
    push!(x.output, Vector{Any}())
    xp = ParseState(x.input, x.pos, x.output[end])
    while xp.pos <= length(xp.input)
        !sub(xp) && break
    end
    len = length(xp.output)
    if low <= len <= high
        x.pos = xp.pos
        true
    else
        pop!(x.output)
        false
    end
end

function and(x::ParseState, sub::Function...)
    xp = ParseState(x.input, x.pos, Vector{Any}())
    if and(map(s->s(x), sub))
        push!(x.output, *(xp.output...))
        x.pos = xp.pos
        true
    else
        false
    end
end

alpha23(x::ParseState) = string(x, is_alpha, 2, 3)
alpha4(x::ParseState) = string(x, is_alpha, 4, 4)
alpha3(x::ParseState) = string(x, is_alpha, 3, 3)
alpha2(x::ParseState) = string(x, is_alpha, 2, 2)
alpha58(x::ParseState) = string(x, is_alpha, 5, 8)
digit3(x::ParseState) = string(x, is_digit, 3, 3)
alnum3(x::ParseState) = string(x, is_alnum, 3, 3)
alnum58(x::ParseState) = string(x, is_alnum, 5, 8)
digit1alnum3(x::ParseState) = and(x, digit1, alnum3)

function language(x::ParseState)
    ( alpha23(x) && option(extlang, x) ) ||
    alpha4(x) ||
    alpha58(x)
end

function extlang(x::ParseState)
    multiple(alpha3, x, 1, 3)
end

script = alpha4

function region(x::ParseState)
    alpha2(x) ||
    digit3()
end

function variant(x::ParseState)
    alpha58(x) ||
    digit1alnum3(x)
end

function extension(x::ParseState)
    xp = ParseState(x.input, x.pos, Vector{Any})
    if singleton(x) && multiple(alnum28, x, 1, INF)
        Pair(xp.output[1], xp.putput[2:end])
        x.pos = xp.pos
        true
    else
        false
    end
end

function singleton(x::ParseState)
    opos = x.pos
    if alnum1(x) && x.output[end] != "x"
        true
    else
        x.pos = opos
        false
    end
end

function privateuse(x::ParseState)
    opos = x.pos
    if alpha1(x) && x.output == "x" && 
        multiple(x, alnum18)
        true
    else
        x.pos = opos
        false
    end
end


