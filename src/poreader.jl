"""
    Represent one text item consisting of original text, translated texts
"""
mutable struct TranslationItem
    id::String
    plural::String
    context::String
    strings::Dict{Int,String}
    TranslationItem() = new("", "", "", Dict{Int,String}())
end

function init_ti!(ti::TranslationItem)
    ti.id = ""; ti.plural = ""; ti.context = ""
    empty!(ti.strings)
end

"""
    read_po_file'('f::AbstractString')'

Read a file, which contains text data according to the PO format of gettext 
ref: //https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html
Format is strictly line separated.
A line staring with '#' is a comment line and ignored.
A line starting with a keyword '(msg.*)' has to be followed by a string, enclosed
in '"' in the same line, optionally followed by string continuations in the
following lines. Those strings are concatenated. Characters '"' and '\\' have
to be escaped by a preceding '\\'. The usual C-escape sequences are honored.
Only keywords 'msgid', 'msgid_plural', 'msgstr', and 'msgstr[.*]' are supported.
The "msgid_plural" is used synonymous to the "msgid". If both entries are present,
two separate key-value pairs are generated, with identical '('typical array')' value.
"""
function read_po_file(file::Union{AbstractString,IO})

    in_sequence = false;
    in_keyword = false;
    dict = Vector{Pair{String,Union{String,Vector{String}}}}()
    buffer = IOBuffer()
    keyword = ""
    index = 0
    ti = TranslationItem()
    in_ti = 0

    function begin_sequence(str::AbstractString)
        truncate(buffer, 0)
        write(buffer, str)
        in_sequence = true
    end

    function continue_sequence(str::AbstractString)
        in_sequence || error("no continuation string expected")
        write(buffer, str)
    end

    function end_sequence()
        str = unescape_string(String(take!(buffer)))
        in_sequence = false
        in_keyword && end_keyword(str)
    end

    function begin_keyword(key::AbstractString, ix::Any, str::AbstractString)
        in_keyword = true
        keyword = key
        index = ix != nothing ? Meta.parse(ix) : -1
        begin_sequence(str)
    end

    function end_keyword(line::AbstractString)
        in_keyword = false
        process_keyword(keyword, index, line)
    end
    
    function process_keyword(key::AbstractString, index::Int, text::AbstractString)
        index == -1 || key == "msgstr" || error("not allowed $key[$index]")
        if key == "msgid"
            in_ti == 3 && process_translation_item(ti)
            in_ti <= 1 || error("unexpected $key '$text'")
            in_ti = 2
            isempty(ti.id) || error("several msgids in line ('$ti.id', '$text')") 
            ti.id = text
        elseif key == "msgstr"
            in_ti != 0 || error("unexpected $key '$text'")
            in_ti = 3
            ti.strings[max(index,0)] = text
        elseif key == "msgid_plural"
            in_ti == 2 || error("unexpected $key '$text'")
            isempty(ti.plural) || error("several msgid_plural in line ('$ti.plural', '$text')") 
            ti.plural = text
        elseif key == "msgctxt"
            in_ti == 3 && process_translation_item(ti)
            in_ti == 0 || error("unexpected $key '$text'")
            in_ti = 1
            isempty(ti.context) || error("several msgctx in line ('$ti.context', '$text')") 
            ti.context = text
        end
    end

    key(ctx, id) = isempty(id) || isempty(ctx) ? id : string(SCONTEXT, ctx, SCONTEXT, id)
    skey(ti::TranslationItem) = key(ti.context, ti.id)
    pkey(ti::TranslationItem) = key(ti.context, ti.plural)

    function process_translation_item(ti::TranslationItem)
        val = map(p->p.second, sort(collect(ti.strings)))
        if length(val) == 1 && isempty(ti.plural)
            val = val[1]
        end
        !isempty(ti.id) && push!(dict, skey(ti) => val)
        !isempty(ti.plural) && ti.plural != ti.id && push!(dict, pkey(ti) => val)
        isempty(ti.id) && isempty(ti.plural) && push!(dict, "" => val)
        init_ti!(ti)
        in_ti = 0
    end

    for line in eachline(file)
        if ( m = match(REG_KEYWORD, line) ) != nothing
            in_sequence && end_sequence()
            begin_keyword(m.captures[1], m.captures[3], m.captures[4])
        elseif ( m = match(REG_STRING, line) ) != nothing
            continue_sequence(m.captures[1])
        end
    end
    in_sequence && end_sequence()
    in_ti == 3 && process_translation_item(ti)

    dict
end

function read_header(str::AbstractString)
    io = IOBuffer(str)
    for line in eachline(io)
        if ( m = match(REG_PLURAL, line) ) != nothing
            return translate_plural_data(m.captures[1])
        end
    end
    translate_plural_data("")
end

module Sandbox end
# clip output of eval(ex(n)) to interval [0, m)
create_plural(ex::Expr, m) = n -> max(min(Base.invokelatest(eval(Sandbox, ex), n), m-1), 0)

# avoid the following error when calling f by invokelatest:
# "MethodError: no method matching (::getfield(ResourceBundles, Symbol("...")))(::Int64)
# The applicable method may be too new: running in world age ~3, while current world is ~4."
# This is maybe an undesirable hack - looking for more elegant work around.

"""
    translate_plural_data(string)

Parses a string of form `"nplurals = expr1; plural = expr(n)"`.
`expr1` must be a constant integer expression.
`expr(n) must be an integer arthmetic expression with a variable `n`.

Outputs the evaluation of `Int(expr1)` and of `n::Int -> expr(n)`.
"""
function translate_plural_data(str::AbstractString)
    nplurals = 2
    plural = n -> n != 0
    str = replace(str, ':', " : ") # surround : by blanks
    str = replace(str, '?', " ? ") # surround ? by blanks
    str = replace(str, "/", "÷") # use Julia integer division for / 
    top = Meta.parse(str)
    isa(top, Expr) || return nplurals, plural
    for a in top.args
        if isa(a, Expr) && a.head == :(=)
            var, ex = a.args
            if var == :nplurals
                nplurals = Int(eval(Sandbox, ex)) # evaluate right hand side
            elseif var == :plural
                ex2 = Expr(:(->), :n, ex)
                plural = create_plural(ex2, nplurals)
                @assert plural(1) == 0 string(ex, " not 0 for n == 1")
            end
        end
    end
    nplurals, plural 
end

const REG_KEYWORD = r"""^\s*([a-zA-Z_]+)(\[(\d+)\])?\s+"(.*)"\s*$"""
const REG_STRING = r"""^\s*"(.*)"\s*$"""
const REG_COMMENT = r"""^\s*#"""

const REG_PLURAL = r"""^\s*Plural-Forms:(.*)$"""

