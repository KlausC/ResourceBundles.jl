"""
    Parser Combinator as describen in Scala book (Programming in Scala - Martin Odersky et. al.
"""
module ParserCombinator


export Input, ParseResult, Parser, Success, Failure
export apply, opt, rep, repsep, success, failure
export token_parser

export TokenList, example

import Base:  %, <<, >>, >>>, |, copy, eof, next

"""
    `Input` is a reader providing tokens of type `Element`
"""
abstract type Input end

eof(x::Input) = true
copy(x::Input) = error("`copy` not implemented for type $(typeof(x))")
next(x::Input) = error("`next` not implemented for type $(typeof(x))")

"""
    `ParseResult` is either success or failure.
"""
abstract type ParseResult{T} end

struct Success{T} <: ParseResult{T}
    result::T
    inp::Input
    Success{T}(r::T, inp::Input) where T = new(r, copy(inp))
end
Success(r::T, inp::Input) where T = Success{T}(r, inp)

struct Failure <: ParseResult{Void}
    msg::String
    inp::Input
    Failure(m::String, inp::Input) = new(m, copy(inp))
end

"""
    The parser maps an input to a parse result.
"""
abstract type Parser end

apply(p::Parser, inp::Input) = Failure("apply not implemented for type $(typeof(p))", inp)

const ValueOrName{T} = Union{T, Tuple{Function,T}}

"""
    `p % f`

    Generate sequencing parser, which accepts `p` followed by `q`.
    Result is a tuple with the results of `p` and `q`.
"""
%(p::Parser, q::Parser) = ParserSeq(p, q)

"""
    `p % (f, q)`

    Generate sequencing parser, which accepts `p` followed by `q`.
    Result is a tuple with the results of `p` and `q`.
    This variant is useful to break recurring loops if `f` is involved in production.
"""
%(p::Parser, pf::Tuple{Function,Parser}) = ParserSeq(p, pf)

struct ParserSeq <: Parser
    p::Parser
    q::ValueOrName{Parser}
end

function apply(pseq::ParserSeq, inp::Input)::ParseResult
    s = apply(pseq.p, inp)
    if isa(s, Success)
        t = apply(callp(pseq.q), s.inp)
        if isa(t, Success)
            Success((s.result, t.result), t.inp)
        else
            t
        end
    else
        s
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
|(p::Parser, pf::Tuple{Function,Parser}) = ParserAlt(p, pf)
struct ParserAlt <: Parser
    p::Parser
    q::ValueOrName{Parser}
end

function apply(palt::ParserAlt, inp::Input)::ParseResult
    s = apply(palt.p, inp)
    if isa(s, Success)
        s
    else
        apply(callp(palt.q), s.inp)
    end
end

"""
    >>>(p::Parser, f::Function)::Parser

    Generate a converting parser. Does no consume any input.
    Result is `Success(f(x), inp)` when `x` is the result of `p` when successful.
    Result is failure result of `p` if not successful.
"""
>>>(p::Parser, f::Function) = ParserConv(p, f)
struct ParserConv <: Parser
    p::Parser
    f::Function
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
    while i < p.hi
        s = apply(p.p, inp)
        if isa(s, Success)
            i += 1
            push!(res, s.result)
        else
            inp = s.inp
            break
        end
    end

    if i >= p.low
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
opt(p::Parser) = rep(p, 0, 1) >>> (x->isempty(x) ? nothing : length(x) == 1 ? x[1] : x)
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
repsep(p::Parser, q::Parser) = p % rep(q >> p, 0, INF) >>> tupvec

"""
    `EOF::Parser`

    Parser accepting only end of input stream.
    Result type is `Void`.
"""
struct ParserEof <: Parser end
const EOF = ParserEof()
apply(p::ParserEof, inp::Input) = eof(inp) ? Success(Void, inp) : Failure("missing eof", inp)

"""
    `success(v::Any)::Parser`

    Parser always resulting in success, does not consume any input.
    Result is `v`.
"""
success(v) = ParserSuccess(v)
struct ParserSuccess <: Parser
    v::Any
end
apply(p::ParserSuccess, inp::Input) = Success(p.v, inp)

"""
    `failure(msg::AbstractString)::Parser`

    Parser always resulting in failure, does not consume any input.
    Result is `Failure(msg, input)`.
"""
failure(msg::AbstractString) = ParserFailure(msg)
struct ParserFailure
    msg::AbstractString
end
apply(p::ParserFailure, inp::Input) = Failure(p.msg, inp)

# call-by-value
callp(x::Parser) = x
# simulate call-by-name
callp(t::ValueOrName{Parser}) = t[1](t[2])

const INF = typemax(Int)

# convert tuple of value and vector into new vector
tupvec(t::Tuple{T,Vector{S}}) where {S,T} = [t[1]; t[2]]
tupvec(t::Tuple{T,S}) where {S,T} = [t[1]; t[2]]
tupvec(t::Tuple{T,Void}) where {T} = t[1]
tupvec(t::Tuple{Void,T}) where {T} = t[2]

token_parser(check::Function, low::Int, high::Int) = ParserToken(check, low, high)
struct ParserToken <: Parser
    check::Function
    low::Int
    high::Int
end

function apply(p::ParserToken, inp::Input)::ParseResult
    in2 = copy(inp)
    if !eof(inp)
        s = next(inp)
        if p.low <= length(s) <= p.high && p.check(s) 
            Success(s, inp)
        else
            Failure("not well formed '$s'", in2)
        end
    else
        Failure("end of input", in2)
    end
end

# example code

mutable struct TokenList <: Input
    pos::Int
    data::Vector{AbstractString}
end
TokenList(x::AbstractString) = TokenList(0, x)

eof(inp::TokenList) = inp.pos >= endof(inp.data)
next(inp::TokenList) = begin inp.pos = nextind(inp.data, inp.pos); inp.data[inp.pos] end
copy(x::TokenList) = TokenList(x.pos, x.data)

function example()
    s13 = token_parser(x->!isempty(x), 1, 3)
    re1 = rep(s13)
    re2 = rep(s13, 1, 2) << EOF
    s13, re1, re2
end

end # module
