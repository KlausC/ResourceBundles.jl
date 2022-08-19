

### accessing libc functions (XOPEN_SOURCE >= 700, POSIX_C_SOURCE >= 200809L glibc>=2.24)
using ResourceBundles.CLocales
using .LC

import .CLocales: newlocale_c, strcoll_c, nl_langinfo_c

const P0 = Ptr{Nothing}(0)

@test newlocale_c(LC._MASK_ALL, "invalidxxx", P0) == P0

COLL_C = [
    ("a", "b", -1),
    ("A", "b", -1),
    ("a", "B", +1),
]

COLL_en = [
    ("a", "b", -1),
    ("A", "b", -1),
    ("a", "B", -1),
]

@testset "C-locale for $loc" for (loc, COLL) in (("C", COLL_C), ("en_US.utf8", COLL_en))
    test_locale = newlocale_c(LC._MASK_ALL, loc, P0)
    if test_locale != P0
        @test duplocale(test_locale) != P0
        @test unsafe_string(nl_langinfo_c(Cint(0xffff), test_locale)) == loc

        @testset "string comparisons '$a' ~ '$b'" for (a, b, r) in COLL
            @test sign(strcoll_c(a, b, test_locale)) == r
        end

        @test freelocale(test_locale) === nothing
    else
        @info "no C-locale defined for '$loc'"
    end
end
#################################
