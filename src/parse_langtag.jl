
function is_category(x::AbstractString, test::Function)
    for c in x
        test(c) && isascii(c) || return false
    end
    true
end

is_alpha(x::AbstractString) = is_category(x, isalpha)
is_digit(x::AbstractString) = is_category(x, isdigit)
is_alnum(x::AbstractString) = is_category(x, isalnum)
is_ascii(x::AbstractString) = is_category(x, y->true)
function is_alnumsep(x::AbstractString)
    for c in x
        isascii(c) && ( isalnum(c) || c in SEPS ) || return false
    end
    true
end 


using .ParserCombinator

SEP = '-'
SEPS = [SEP, '_']

ALPHA23 = token_parser(is_alpha, 2, 3) >>> lowercase
ALPHA3 = token_parser(is_alpha, 3, 3) >>> lowercase
ALPHA4 = token_parser(is_alpha, 4, 4)
ALPHA2 = token_parser(is_alpha, 2, 2) >>> uppercase
DIGIT3 = token_parser(is_digit, 3, 3)
DIGIT1 = token_parser(is_digit, 1, 1)
ALNUM58 = token_parser(is_alnum, 5, 8)
ALNUM18 = token_parser(is_alnum, 1, 8) >>> lowercase
ALNUM28 = token_parser(is_alnum, 2, 8) >>> lowercase
ALNUM3 = token_parser(is_alnum, 3, 3) >>> lowercase

singleton = token_parser(x-> is_alnum(x) && lowercase(x) != "x", 1, 1) >>> t->lowercase(t[1])
letterx = token_parser(x-> lowercase(x) == "x", 1, 1) >>> t-> 'x'

privateuse =  letterx % rep(ALNUM18 >>> Symbol, 1, 999) >>> (t-> t[1] => t[2])
extension = singleton % rep(ALNUM28 >>> Symbol, 1, 999) >>> (t-> t[1] => t[2])
extprivate = rep(extension) % opt(privateuse) >>> Iterators.flatten

variant =   ALNUM58 |
            DIGIT1 % ALNUM3 >>> join
region =    ALPHA2 |
            DIGIT3
script =    ALPHA4 >>> (t-> t |> lowercase |> titlecase)
extlang =   rep(ALPHA3, 1, 3) >>> (t-> join(String.(t), SEP))
language =  ALPHA23 % opt(extlang) >>> (t-> isempty(t[2]) ? t[1] : t[1] * SEP * t[2][1])

flatstring(x::Vector) = isempty(x) ? "" : join(x)

langtag =   ( language >>> Symbol ) %
            ( opt(script) >>> flatstring >>> Symbol ) %
            ( opt(region) >>> flatstring >>> Symbol ) %
            ( rep(variant) >>> t-> isempty(t) ? Symbol[] : Symbol.(t) ) %
            (extprivate >>> Dict) |
            privateuse >>> t-> [Symbol(""), Symbol(""), Symbol(""), Symbol[], Dict(t)]
                        
export parse_langtag

function parse_langtag(str::AbstractString)
    input = TokenList(split(str, SEPS))
    res = apply(langtag << EOF >>> (t-> Locale(t...)), input)
    res
end


