"""

transformation between locale identifiers in differnet forms
1. form used by POSIX:  <lang>_<region>[.<charset>][@<cextension>]
2. form used by BCP47:  <lang>[_<script>][_<region>][-<variant>][-lextensions]
"""
module LocaleIdTranslations

using ResourceBundles
using Unicode
import ResourceBundles: SEP

export cloc_to_loc, loc_to_cloc, all_locales

"""

    cloc_to_loc(posix::String) -> unicode-locale-id-string

Posix string has the general form `<lang>[_<country>][.<charset>][@<extension>]`.
We transform this to the following string:
`<lang[_<script>][_country>][_<variant>][-x-posix-<extension>]`.
The `@extension` may be transformed to a <script>, a variant, or a private extension.
The charset is ignored. The extension is optional in input and output.
"""
function cloc_to_loc(cloc::String)
    cloc == "" && return cloc
    if cloc == "C" || uppercase(cloc) == "POSIX"
        return "C"
    end
    cloc = lowercase(cloc)
    m = match(REG_POSIX, cloc)
    if m == nothing
        return cloc
    end
    mc = m.captures
    lang = mc[1]
    reg = nostring(mc[3])
    charset = nostring(mc[5])
    ext = nostring(mc[7])
    script = ""
    var = ""
    if !isempty(ext)
        langext = string(lang, mc[6])
        if haskey(EXTENSION_TO_SCRIPT, ext)
            script = EXTENSION_TO_SCRIPT[ext]
            ext = ""
        elseif haskey(LANGEXT_TO_VAR, langext)
            var = LANGEXT_TO_VAR[langext]
            ext = ""
        elseif haskey(LANGEXT_TO_NEW, langext)
            lang = LANGEXT_TO_NEW[key]
            ext = ""
        elseif ext in EXTENSIONS_IGNORE
            ext = ""
        end
    end
    io = IOBuffer()
    write(io, lang)
    isempty(script) || write(io, SEP, script)
    isempty(reg) || write(io, SEP, reg)
    isempty(var) || write(io, SEP, var)
    isempty(ext) || write(io, "-x-posix-", ext)
    String(take!(io))
end

nostring(s::AbstractString) = s
nostring(::Nothing) = ""

const REG_POSIX = r"(^[[:alpha:]]+)([_-]([[:alpha:]]+))?(\.([[:alnum:]_-]+))?(@([[:alnum:]]+))?$"

const EXTENSION_TO_SCRIPT = Dict(
        "cyrillic" => "Cyrl",
        "latin" => "Latn",
        "devanagari" => "Deva")

const LANGEXT_TO_VAR = Dict(
        "es@valencia" => "valencia"
)

const LANGEXT_TO_NEW = Dict(
        "aa@saaho" => "ssy",
        "gez@abegede" => "aa")

const EXTENSIONS_IGNORE = ["euro"]

const S0 = Symbol("")

"""
    loc_to_cloc(loc::LocaleId) -> POSIX string

Translate from LocaleId to String in POSIX Format.
Comparable with cloc_to_loc.
"""
function loc_to_cloc(loc::LocaleId)
    s = string(loc)
    ( s == "C" || uppercase(s) == "POSIX" ) && return "C"
    s == "" && return s
    lang = loc.language
    reg = loc.region
    script = loc.script
    # only interested in extensions of the form "-x-posix-<ext>"
    extd = loc.extensions === nothing ? Symbol[] : get(loc.extensions, 'x', Symbol[])
    ext = length(extd) == 2 && extd[1] == :posix ? extd[2] : S0 
    
    pext = get(LANG_TO_EXT, string(lang), "")

    allo = all_locales() # in the operating system storage (locale -a)
    if reg != S0 # all posix locales have a region
        if script != S0
            key = string(script)
            if haskey(SCRIPT_TO_EXT, key)
                pext = SCRIPT_TO_EXT[key]
            end
        end
        if ext != S0 && isempty(pext)
            pext = string(ext)
        end
        su = locale_name(lang, reg, pext)
        if findfirst(x -> x == su, allo) != 0
            return su
        end
        su = locale_name(loc.language, reg)
        if findfirst(x -> x == su, allo) != 0
            return su
        else
            s = loc.language
        end
    else
        s = loc.language
    end

    s = string(s)
    su = locale_name(s, uppercase(s)) # check the case, when lang and reg are the same
    if findfirst( x ->x == su, allo) != 0
        return su
    end

    reg = get(PROBABLE_SUBTAGS, s, "")
    if reg != ""
        su = locale_name(s, reg)
        if findfirst( x ->x == su, allo) != 0
            return su
        end
    end

    ix = findfirst(x -> x == s || startswith(x, s * '_'), allo)
    return ix != 0 ? allo[ix] : "C"
end

locale_name(lang, reg) = string(lang, '_', reg, UTF8)
locale_name(lang, reg, ext) = isempty(ext) ? locale_name(lang, reg) : string(lang, '_', reg, UTF8, '@', ext)

const PROBABLE_SUBTAGS = Dict("en" => "US", "zh" => "CN", "sv" => "SE")
const SCRIPT_TO_EXT = Dict("Deva" => "devanagari", "Latn" => "latin", "Cyrl" => "cyrillic")
const LANG_TO_EXT = Dict("ssy" => "saaho")

allloc = String[]

function all_locales()
    global allloc
    if isempty(allloc)
        list = String[]
        push!(list, "C", "POSIX")
        for loc in eachline(`locale -a`)
            loca, ext = splitext(loc)
            simple = ext == "" && '_' ∉ loca
            standard = loca == "C" || loca == "POSIX"
            if ( simple || ext == UTF8 ) && !standard
                push!(list, loc)
            end
        end
        allloc = list
    end
    allloc
end

const UTF8 = ".utf8"

end # module
