using Base.Filesystem
using Unicode

const LocalePattern = LocaleId
const Pathname = String

struct Resource
    file::String
    locale::LocaleId
    nplurals::Int
    plural::Function
    dict::Dict{String,<:Any}
end

mutable struct Cache
    list::Vector{Pair{LocalePattern,Pathname}}
    dict::Dict{LocalePattern,Resource}
end

#function Resource(f::AbstractString, res::Dict{String,T}) where T
#    Resource(f, BOTTOM, 1, (n)->0, res)
#end

struct ResourceBundle
    path::Pathname
    name::String
    cache::Dict{LocaleId,Cache}
    lock::Threads.RecursiveSpinLock
    function ResourceBundle(path::Pathname, name::AbstractString)
        ( !isempty(name) && all(isalnum, name) ) ||
            throw(ArgumentError("resource names require alphanumeric but is `$name`"))
        new(path, string(name), Dict{LocaleId,Cache}(), Threads.RecursiveSpinLock())
    end
end

function ResourceBundle(mod::Module, name::AbstractString)
    ResourceBundle(resource_path(mod, name), name)
end

const Empty = ResourceBundle("", "empty")

const SEP = '_'
const SEP2 = '-'
const JEND = ".jl"          # extension of Julia resource file
const PEND = ".po"          # extension of PO resource file
const MEND = ".mo"          # extension of MO resource file

const RESOURCES = "resources"   # name of subdirectory
const JRB = "JULIA_RESOURCE_BASE" # enviroment variable

"""
    resource_path(module, name) -> String

Return path name of resource directory for a module containing data for `name`.
If top module is `Main` the path is derived from enviroment `JULIA_RESOURCE_BASE`.
If `Sys.BINDIR/../../stdlib/<module>/resources` is a directory, we assume
the resources of a module in the standard library.
Otherwise the directory `Pkg.dir()/<module>/resources` is selected; that is
the usual case for user defined modules.
Submodules may have specific resource files. They are located in subdirectories
of the `resources` directory with path names corresponding to submodule name.
example: Module `MyModule.X.Y` can store specific resource files in
`.../MyModule/resources/X/Y`. If for a given name, no resources are found in the
deepest directory, fallback to previous directory happens. In the example, the
resources are searched first in `resources/X/Y`, then in `resources/X`, then in `resources`.
Nevertheless the resources for one name are always taken from only one subdirectory.
"""
function resource_path(mod::Module, name::AbstractString)
    mp = module_split(mod)
    
    if isempty(mp) || mp[1] == :Main
        base = get(ENV, JRB, pwd())
    else
        base = normpath(package_path(mp[1]), string(mp[1]))
    end
    path = "."
    prefix = normpath(base, RESOURCES)
    if is_resourcepath(prefix, name)
        n = length(mp)
        path = prefix
        for i = 2:n
            prefix = joinpath(prefix, mod2file(mp[i]))
            if is_resourcepath(prefix, name)
                path = prefix
            end
        end         
    end
    path
end

"""
    package_path(mod)

Return installation directory for module `mod`.
"""
function package_path(name)
    name = string(name)
    path1 = normpath(Sys.BINDIR, "..", "..", "stdlib", name)
    path2 = Pkg.dir(name)
    is1 = isdir(path1)
    is2 = isdir(path2)
    is1 && is2 && @warn("module '$name' has same name as stdlib module")
    splitdir(is2 ? path2 : is1 ? path1 : name)[1]
end


"""
    is_resourcepath(path, name)

Check if directory `path` contains subdirectory `name` or a file `name_*` or `name.jl`.
Path may be relative or absolute. Name may be string or symbol.
"""
function is_resourcepath(path::AbstractString, name::AbstractString)
    isdir(path) || return false
    isdir(joinpath(path, string(name))) && return true
    stp = name * string(SEP)
    function resind(f::AbstractString)
        fname, fext = splitext(f)
        startswith(f, stp) || ( fname == name && ( fext == JEND || fext == PEND || fext == MEND ) )
    end
    any(resind, readdir(path))
end

"""
    module_split(mod::Module)

Return the list of module names of a module hierarchy.
Example: `Base.Iterators -> [:Main,:Base,:Iterators]`.
"""
function module_split(mod::Module)
    fn = fullname(mod)
    VERSION >= v"0.7-DEV" ? fn :
    isempty(fn) || !isdir(Pkg.dir(string(fn[1]))) ? (:Main, fn...) : fn
end

"""
    findfiles(bundle, locale) -> Cache 

Produce cache object, which contains list of pairs of locale patterns and pathnames of
potential resource file, restricted to the given locale. The file names are all of the form
`absfilename(path, name) * locstring * ".jl"`
where `locstring` is in the form of a locale-pattern, with locale-separators replaced by
characters `_` or `/`.
The list is sorted with most specific locale-pattern first. The list needs not be totally
ordered (with respect to `⊆`, which allows ambiguous

Example: for `LocaleId("de-DE")`, the resource files could be `name_de_DE.jl` or 
`name_de/DE.jl` or `name/de_DE.jl` or `name/de/DE.jl`. If more than one of those files exist,
only the first one (in topdown-order of `walkdir`) is used.
"""
function findfiles(bundle::ResourceBundle, loc::LocaleId)
    dir = normpath(bundle.path)
    name = bundle.name
    flist = Dict{LocalePattern,Pathname}() # 
    prefix = joinpath(dir, name)
    np = sizeof(prefix)
    if dir != "."
        for (root, dirs, files) in walkdir(dir)
            for f in files
                file = joinpath(root, f)
                if startswith(file, prefix)
                    locpa = locale_pattern(file[nextind(file,np):end])
                    if locpa != nothing && !haskey(flist, locpa) && loc ⊆ locpa
                        push!(flist, locpa => file)
                    end
                end
            end
        end
    end
    locs = sort(collect(keys(flist)))
    Cache(collect(loc => flist[loc] for loc in locs), Dict{LocalePattern,Resource}())
end

# derive locale pattern from file path
function locale_pattern(f::AbstractString)
    d, f = splitdir(f)
    f, fext = splitext(f)
    if isempty(fext) && startswith(f, ".")
        f, fext = "", f
    end
    ( fext == JEND || fext == PEND || fext == MEND ) || return nothing
    f = isempty(f) ? d : joinpath(d, f)
    f = replace(f, Filesystem.path_separator, SEP)
    f = replace(f, SEP2, SEP)
    if isempty(f)
        LocaleId("")
    elseif f[1] == SEP
        LocaleId(f[nextind(f, 1):end])
    else
        nothing
    end
end

"""
    load_file(path)

Load file and create an object of type Resource.
The loaded file must contain valid julia code returning a dictionary object of the
requested type, or an array of pairs, which can be used to construct one. 

Alternatively, if the value type is `String`, in the case of message resource files,
The file content may be formattet as a gettext po file.

In case of errors, a warning is printed to logging device and `nothing` is returned.
"""
function load_file(f::AbstractString, locpa::LocaleId=BOTTOM)
    d = nothing
    dict = nothing
    _, fext = splitext(f)
    if fext == JEND
        d = load_file_jl(f)
    elseif fext == MEND
        d = load_file_mo(f)
    elseif fext == PEND
        d = load_file_po(f)
    else
        @warn("invalid extension of file name '$f'")
    end
    
    if isa(d, Union{Vector{T},NTuple{N,Pair},T} where {T<:Pair,N})
        d = Dict(d)
    end

    if isa(d, Dict)
        el = eltype(d).parameters
        if el[1] <: String
            dict = d
        else
            @warn("Wrong type 'Dict{$(el[1]),$(el[2])}' loaded from '$f'")
        end
    else
        @warn("Wrong type '$(typeof(d))' loaded from '$f' is not a dictionary")
    end
    
    if dict != nothing
        hdr = get(dict, "", "")
        nplurals, plural = read_header(hdr)
        return Resource(f, locpa, nplurals, plural, dict)
    end
    nothing
end

function load_file_typed(f::AbstractString, readf::Function)
    d = nothing
    try
        d = readf(f)
        @debug("loaded resource file $f")
    catch ex
        @warn("loading resource file '$f': $ex")
    end
    d
end

load_file_jl(f::AbstractString) = load_file_typed(f, include)
load_file_po(f::AbstractString) = load_file_typed(f, read_po_file)
load_file_mo(f::AbstractString) = load_file_typed(f, read_mo_file)

import Base.get
"""
    get(bundle::ResourceBundle[, locale], key::String [,default]) -> Any

Return value associated with the locale and key.
If the locale is not given, use the ResourceBundles current locale for messages. 
If no default value is given, return `nothing`.
"""
function get(bundle::ResourceBundle, loc::LocaleId, key::AbstractString, default=nothing)
    resource = get_resource_by_key(bundle, loc, key)
    resource != nothing ? get(resource.dict, key, default) : default
end

"""
    get_resource_by_key(bundle[, locale], key) -> Resource

Get resource object which contains key. It also provides multiplicity information.
If the key is not found in any resource file, return `nothing`.
"""
function get_resource_by_key(bundle::ResourceBundle, loc::LocaleId, key::AbstractString)
  try
    lock(bundle.lock)    
    cache =  initcache!(bundle, loc)
    flist = cache.list
    rlist = Vector()
    xloc = LocaleId("")
    val = nothing
    for (locpa, path) in flist
        resource = ensure_resource!(bundle, cache, locpa, path, rlist)
        if resource != nothing && haskey(resource.dict, key)
            if val == nothing
                xloc = locpa
                val = resource
            else
                if xloc ⊆ locpa
                    break
                else
                    @warn string("Ambiguous key '", key, "' for ", loc, " in patterns ", xloc, " and ", locpa)
                end
            end
        end
    end
    clean_cache_list(cache, rlist)
    val
  finally
    unlock(bundle.lock)
  end
end

# variants using default locale for messages
msg_loc() = locale(:MESSAGES)
get(bundle::ResourceBundle, key::String, default=nothing) = get(bundle, msg_loc(), key, default)
get_resource_by_key(bundle::ResourceBundle, key::String) =  get_resource_by_key(bundle, msg_loc(), key)

import Base.keys
"""
    keys(bundle, locale)
    keys(bundle)

Return array of all defined keys for a specific locale or all possible locales.
"""
function Base.keys(bundle::ResourceBundle, loc::LocaleId)
  try
    lock(bundle.lock)    
    cache = initcache!(bundle, loc)
    flist = cache.list
    dlist = Vector()
    rlist = Vector()
    val = nothing
    for (locpa, path) in flist
        resource = ensure_resource!(bundle, cache, locpa, path, rlist)
        if resource != nothing
            push!(dlist, keys(resource.dict))
        end
    end
    clean_cache_list(cache, rlist)
    if isempty(dlist)
        String[]
    else
        sort!(unique(Iterators.flatten(dlist)))
    end
  finally
    unlock(bundle.lock)
  end
end

Base.keys(bundle::ResourceBundle) = keys(bundle, BOTTOM)

#remove unused files from cache list
function clean_cache_list(cache::Cache, rlist::Vector)
    if !isempty(rlist)
        cache.list = setdiff(cache.list, rlist)
    end
end

# select all potential source dictionaries for given locale. 
function initcache!(bundle::ResourceBundle, loc::LocaleId)
    get!(bundle.cache, loc) do
        findfiles(bundle, loc)
    end
end

# load all entries from one dictionary file.
function ensure_resource!(bundle::ResourceBundle, cache::Cache, locpa::LocalePattern, path::String, rlist::Vector)
    if haskey(cache.dict, locpa)
        resource = cache.dict[locpa]
    else
        resource = get_resource_by_pattern(bundle, locpa)
        if resource == nothing
            resource = load_file(path, locpa)
        end
        if resource != nothing
            cache.dict[locpa] = resource
        else
            push!(rlist, locpa)
        end
    end
    resource
end

"""
    get_resource_by_pattern(bundle, locale_pattern)

Obtain resource object of a bundle, which is identified by a locale pattern.
That is commonly constructed of the contents of one resource file, that has the
locale pattern as part of its name.
"""
function get_resource_by_pattern(bundle::ResourceBundle, locpa::LocalePattern)
    for cache in values(bundle.cache)
        if haskey(cache.dict, locpa)
            return cache.dict[locpa]
        end
    end
    nothing
end

mod2file(name::Symbol) = string("M-", name)

is_module_specific(mod::Module, path) = is_module_specific(module_split(mod), path)

function is_module_specific(mp::NTuple{N,Symbol}, path::AbstractString) where N
    dir, file = splitdir(path)
    isrootmod = length(mp) <= 1
    isabspath(dir) &&
    (( isrootmod && file == RESOURCES ) ||
     (!isrootmod && file == mod2file(mp[end]) && is_module_specific(mp[1:end-1], dir) )) 
end

const LOCK = Threads.RecursiveSpinLock()
function define_resource_variable(mod::Module, varname::Symbol, bundlename::AbstractString)
  try
    lock(LOCK)
    if !isdefined(mod, varname)
        path = resource_path(mod, bundlename)
        if is_module_specific(mod, path)
            eval(mod, :(const $varname = ResourceBundle($mod, $bundlename)))
        elseif isabspath(path)
            parent = module_parent(mod)
            prev = define_resource_variable(parent, varname, bundlename)
            eval(mod, :(const $varname = $parent.$varname))
        else
            eval(mod, :(const $varname = ResourceBundles.Empty))
        end
    else
        eval(mod, varname)
    end
  finally
    unlock(LOCK)
  end
end

"""
    resource_bundle(module, name) 
    @resource_bundle name

Create global variable named `RB_<name>` in module `mod`, which contains corresponding
resource bundle. If the variable preexists, just return it. The macro envocation is
equivalent to calling `resource_bundle(@__MODULE__, name)`.
"""

function resource_bundle(mod::Module, name::AbstractString)
    define_resource_variable(mod, Symbol("RB_", name), name)
end

macro resource_bundle(name::AbstractString)
    mod = VERSION < v"0.7-DEV" ? current_module() : __module__
    :(resource_bundle($mod, $name))
end

