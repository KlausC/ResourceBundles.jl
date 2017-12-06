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
        elseif key == "msgctx"
            in_ti == 3 && process_translation_item(ti)
            in_ti == 0 || error("unexpected $key '$text'")
            in_ti = 1
            isempty(ti.context) || error("several msgctx in line ('$ti.context', '$text')") 
            ti.context = text
        end
    end

    function process_translation_item(ti::TranslationItem)
        key = isempty(ti.plural) ? ti.id : ti.plural
        val = map(p->p.second, sort(collect(ti.strings)))
        if length(val) == 1 && isempty(ti.plural)
            val = val[1]
        end
        push!(dict, key => val)
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
            break
        end
    end
    translate_plural_data("")
end

function translate_plural_data(str::AbstractString)
    nplurals = 2
    plural = n -> n != 0
    str = replace(str, r"[:?]", s->" "*s*" ") # surround ? and : by blanks
    for st in split(str, ';', keep = false)
        m = match(r"^\s*(\w+)\s*=\s*(.+)\s*$", st)
        if m != nothing && length(m.captures) == 2
            if m.captures[1] == "nplurals"
                ex = Meta.parse(m.captures[2])
                nplurals = Int(eval(ex)) # evaluate right hand side
            elseif m.captures[1] == "plural"
                ex = Meta.parse("n -> " * m.captures[2])
                f = n::Int -> Base.invokelatest(eval(ex), n)
# avoid the following error when calling f:
# MethodError: no method matching (::getfield(ResourceBundles, Symbol("...")))(::Int64)
# The applicable method may be too new: running in world age ~3, while current world is ~4.
                plural = n -> max(min(f(n), nplurals-1), 0)
            end
        end
    end
    nplurals, plural 
end

const REG_KEYWORD = r"""^\s*([a-zA-Z_]+)(\[(\d+)\])?\s+"(.*)"\s*$"""
const REG_STRING = r"""^\s*"(.*)"\s*$"""
const REG_COMMENT = r"""^\s*#"""

const REG_PLURAL = r"""^\s*Plural-Forms:(.*)$"""

