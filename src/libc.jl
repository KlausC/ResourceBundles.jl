
### accessing libc functions (XOPEN_SOURCE >= 700, POSIX_C_SOURCE >= 200809L glibc>=2.24)

function newlocale_c(mask::Int, clocale::AbstractString, base::CLocaleType)
    cmask = fixmask(mask)
    ccall(:newlocale, CLocaleType, (Cint, Cstring, CLocaleType), cmask, clocale, base)
end

function duplocale(ploc::CLocaleType)
    ccall(:duplocale, CLocaleType, (CLocaleType,), ploc)
end

function freelocale(ploc::CLocaleType)
    ccall(:freelocale, Void, (CLocaleType,), ploc)
end

function strcoll_c(s1::AbstractString, s2::AbstractString, ploc::CLocaleType)
    res = 0
    if ploc == CL0
        ploc = current_clocale()
        res = ccall(:strcoll_l, Cint, (Cstring, Cstring, CLocaleType), s1, s2, ploc)
        freelocale(ploc)
    else
        res = ccall(:strcoll_l, Cint, (Cstring, Cstring, CLocaleType), s1, s2, ploc)
    end
    Int(res)
end

function nl_langinfo_c(nlitem::Cint, ploc::CLocaleType)
    ccall(:nl_langinfo_l, Ptr{UInt8}, (Cint, CLocaleType), nlitem, ploc)
end

#################################
