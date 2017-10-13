"""
    Parser Combinator as describen in Scala book (Programming in Scala - Martin Odersky et. al.
"""
module ParserCombinator


export Input, ParseResult, Parser, Success, Failure, EOF
export apply, opt, rep, repsep, succeed, fail
export copy_state, set_state!
export token_parser
export ParserSeq, ParserAlt, ParserToken, ParserLiteral, ParserRegex

export TokenList, example

import Base:  %, <<, >>, >>>, |, eof, next

"""
    `Input` is a reader providing tokens of type `Element`
"""
abstract type Input end

eof(x::Input) = true
next(x::Input) = error("`next` not implemented for type $(typeof(x))")
copy_state(x::Input) = error("`copy_state` not implemented for type $(typeof(x))")
set_state!(x::Input, s::Any) = error("`set_state!` not implemented for type $(typeof(x))")

"""
    `ParseResult` is either success or failure.
"""
abstract type ParseResult{T} end

struct Success{T} <: ParseResult{T}
    result::T
    inp::Input
    Success{T}(r::T, inp::Input) where T = new(r, inp)
end
Success(r::T, inp::Input) where T = Success{T}(r, inp)

struct Failure <: ParseResult{Void}
    msg::String
    inp::Input
    Failure(m::String, inp::Input) = new(m, inp)
end

"""
    The parser maps an input to a parse result.
    The parser generators create a parser from elementary parts.
"""
abstract type Parser end
"""
    Apply a parser to the given input and produce a success result or a failure message.
"""
apply(p::Parser, inp::Input) = Failure("apply not implemented for type $(typeof(p))", inp)

const DelayedFunction{T} = Tuple{Function,T} # Function must have return type T
const ValueOrName = Union{Parser,DelayedFunction{Parser}}

"""
    `p % f`

    Generate sequencing parser, which accepts `p` followed by `q`.
    Result is a tuple with the results of `p` and `q`.
"""
%(p::Parser, q::Parser) = ParserSeq(p, [q])

"""
    `p % (f, q)`

    Generate sequencing parser, which accepts `p` followed by `q`.
    Result is a tuple with the results of `p` and `q`.
    This variant is useful to break recurring loops if `f` is involved in production.
"""
%(p::Parser, pf::ValueOrName) = ParserSeq(p, pf)

struct ParserSeq <: Parser
    p::Parser
    qlist::Vector{ValueOrName}
end
ParserSeq(p::Parser, qa::ValueOrName...) = ParserSeq(p, qa)

%(p::ParserSeq, qf::ValueOrName) = begin push!(p.qlist, qf); p end
%(p::ParserSeq, q::Parser) = begin push!(p.qlist, q); p end

function apply(pseq::ParserSeq, inp::Input)
    state = copy_state(inp)
    n = length(pseq.qlist) + 1
    i = 0
    res = []
    sizehint!(res, n)
    s = apply(pseq.p, inp)
    if isa(s, Success)
        push!(res, s.result)
        for q in pseq.qlist
            s = apply(parser(q), inp)
            if isa(s, Success)
                push!(res, s.result)
            else
                break
            end
        end
    end
    if length(res) == n
        R = promote_type(typeof.(res)...)
        res = Vector{R}(res)
        Success(res, inp)
    else
        fstate = inp.state
        set_state!(inp, state)
        Failure("incomplete sequence at $fstate", inp)
    end
end


"""
    `p >> q`

    Same as `p % q` but the result is the result of `q`.
"""
>>(p::Parser, q::Parser) = p % q >>> (tup -> tup[2])
"""
    `p << q`

    Same as `p % q` but the result is the result of `p`.
"""
<<(p::Parser, q::Parser) = p % q >>> (tup -> tup[1])

"""
    `p | q`

    Generate altenative parser, which first tries `p` and return its result if successful.
    Otherwise try `q` and return result of `q`.
"""
|(p::Parser, q::Parser) = ParserAlt(p, q)

"""
    `p | (f, q)`

    Generate altenative parser, which first tries `p` and return its result if successful.
    Otherwise try `f(q)` and return result that. `f` is a function returning a parser.
    This variant is useful to break recurring loops if `f` is involved in production.
"""
|(p::Parser, q::DelayedFunction{Parser}) = ParserAlt(p, q)
struct ParserAlt <: Parser
    p::Parser
    q::ValueOrName
end

function apply(palt::ParserAlt, inp::Input)::ParseResult
    s = apply(palt.p, inp)
    if isa(s, Success)
        s
    else
        apply(parser(palt.q), s.inp)
    end
end

"""
    >>>(p::Parser, f::Function)::Parser

    Generate a converting parser. Does no consume any input.
    Result is `Success(f(x), inp)` when `x` is the result of `p` when successful.
    Result is failure result of `p` if not successful.
"""
>>>(p::Parser, f::Union{Function,Type}) = ParserConv(p, f)
struct ParserConv <: Parser
    p::Parser
    f::Union{Function,Type}
end

function apply(pconv::ParserConv, inp::Input)::ParseResult
    s = apply(pconv.p, inp)
    if isa(s, Success)
        Success(pconv.f(s.result), s.inp)
    else
        s
    end
end

"""
    `rep(p::Parser, low::Integer, hi::Integer)::Parser`

    Generate repeating parser, which accepts `low` to `hi` repetitions of parser `p`.
    Result type is `Vector{T}` where `T` is result type of `p`.
"""
rep(p::Parser, low::Int, hi::Int) = ParserRep(p, low, hi)
struct ParserRep <: Parser
    p::Parser
    low::Int
    hi::Int
end

function apply(p::ParserRep, inp::Input)
    i = 0
    res = []
    sizehint!(res, max(p.low, min(p.hi, 8)))
    while i < p.hi
        s = apply(p.p, inp)
        if isa(s, Success)
            i += 1
            push!(res, s.result)
        else
            break
        end
    end

    if i >= p.low
        R = promote_type(typeof.(res)...)
        res = Vector{R}(res)
        Success(res, inp)
    else
        Failure("only $i repetitions, but $(p.low) required", inp)
    end
end

"""
    `opt(p::Parser)::Parser`

    Parser accepting same as `p` or empty input.
    Result same as `p` if `p` was successful, otherwise `Success(nothing, inp)`.
"""
opt(p::Parser) = rep(p, 0, 1)
"""
    `rep(p::Parser)::Parser`

    Same as rep(p, 0, ∞)`
"""
rep(p::Parser) = rep(p, 0, INF)

"""
    `repsep(p::Parser, q::Parser)::Parser`

    Repetitions of `p`, which are separated by `q`. For example: `p q p q p` ).
    Result is vector of results of the various `p`.
"""
repsep(p::Parser, q::Parser) = p % rep(q >> p, 0, INF)

"""
    `EOF::Parser`

    Parser accepting only end of input stream.
    Result type is `Void`.
"""
struct ParserEof <: Parser end
const EOF = ParserEof()
apply(p::ParserEof, inp::Input) = eof(inp) ? Success(Void, inp) : Failure("missing eof", inp)

"""
    `succeed(v::Any)::Parser`

    Parser always resulting in success, does not consume any input.
    Result is `v`.
"""
succeed(v) = ParserSuccess(v)
struct ParserSuccess <: Parser
    v::Any
end
apply(p::ParserSuccess, inp::Input) = Success(p.v, inp)

"""
    `fail(msg::AbstractString)::Parser`

    Parser always resulting in failure, does not consume any input.
    Result is `Failure(msg, input)`.
"""
fail(msg::AbstractString) = ParserFailure(msg)
struct ParserFailure
    msg::AbstractString
end
apply(p::ParserFailure, inp::Input) = Failure(p.msg, inp)

# call-by-value
parser(x::Parser) = x
# simulate call-by-name
parser(t::ValueOrName) = t[1](t[2])

const INF = typemax(Int)

token_parser(check::Function, low::Int, high::Int) = ParserPredicate(check, low, high)
struct ParserPredicate <: Parser
    check::Function
    low::Int
    high::Int
end

function apply(p::ParserPredicate, inp::Input)::ParseResult
    state = copy_state(inp)
    if !eof(inp)
        s = next(inp)
        if p.low <= length(s) <= p.high && p.check(s) 
            Success(s, inp)
        else
            set_state!(inp, state)
            Failure("not well formed '$s'", inp)
        end
    else
        Failure("end of input", inp)
    end
end

token_parser(literal) = ParserLiteral(literal)
struct ParserLiteral <: Parser
    literal::Any
end

function apply(p::ParserLiteral, inp::Input)
    state = copy_state(inp)
    if !eof(inp)
        s = next(inp)
        if s == p.literal
            Success(s, inp)
        else
            set_state!(inp, state)
            Failure("expected $p.literal but got $s", inp)
        end
    else
        Failure("end of input")
    end
end

token_parser(regex::Regex) = ParserRegex(regex)
struct ParserRegex <: Parser
    regex::Regex
end

function apply(p::ParserRegex, inp::Input)
    state = copy_state(inp)
    if !eof(inp)
        s = next(inp)
        if search(s, p.regex) == 1:endof(s)
            Success(s, inp)
        else
            set_state!(inp, state)
            Failure("expected $p.literal but got $s", inp)
        end
    else
        Failure("end of input")
    end
end

# example code

mutable struct TokenList <: Input
    state::Int
    data::Vector{AbstractString}
end
function TokenList(x::Any)
    state = start(x)
    TokenList(state, x)
end

eof(inp::TokenList) = done(inp.data, inp.state)
next(inp::TokenList) = begin item, inp.state = next(inp.data, inp.state); item end
copy_state(inp::TokenList) = copy(inp.state)
set_state!(inp::TokenList, x::Any) = begin inp.state = x end

function example()
    s13 = token_parser(x->!isempty(x), 1, 3)
    re1 = rep(s13)
    re2 = rep(s13, 1, 2) << EOF
    s13, re1, re2
end

end # module
