
### accessing libc functions (XOPEN_SOURCE >= 700, POSIX_C_SOURCE >= 200809L glibc>=2.24)

if Sys.isunix() && get(Base.ENV, "NO_CLOCALE", "") != "1"

    function newlocale_c(mask::Cint, clocale::AbstractString, base::CLocaleType)
        ccall(:newlocale, CLocaleType, (Cint, Cstring, CLocaleType), mask, clocale, base)
    end

    function duplocale(ploc::CLocaleType)
        ccall(:duplocale, CLocaleType, (CLocaleType,), ploc)
    end

    function freelocale(ploc::CLocaleType)
        ccall(:freelocale, Nothing, (CLocaleType,), ploc)
    end

    function uselocale(newloc::CLocaleType)
        ccall(:uselocale, CLocaleType, (CLocaleType,), newloc)
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

else # for the non case provide dummy methods

    newlocale_c(mask::Cint, clocale::AbstractString, base::CLocaleType) = CL0
    duplocale(ploc::CLocaleType) = CL0
    freelocale(ploc::CLocaleType) = nothing
    uselocale(newloc::CLocaleType) = CL0
    function strcoll_c(s1::AbstractString, s2::AbstractString, ploc::CLocaleType)
        s1 == s2 ? 0 : s1 < s2 ? -1 : 1
    end
    nl_langinfo_c(nlitem::Cint, ploc::CLocaleType) = Ptr{UInt8}(0)

end
#################################
