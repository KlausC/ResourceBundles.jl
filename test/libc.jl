

### accessing libc functions (XOPEN_SOURCE >= 700, POSIX_C_SOURCE >= 200809L glibc>=2.24)
using ResourceBundles.CLocales
using .LC

import .CLocales: newlocale_c, strcoll_c, nl_langinfo_c

const P0 = Ptr{Nothing}(0)

if Sys.isunix() && get(Base.ENV, "NO_CLOCALE", "") != "1"

@test newlocale_c(LC._MASK_ALL, "invalidxxx", P0)  == P0
@test newlocale_c(LC._MASK_ALL, "en_US.utf8", P0)  != P0

test_locale_C = newlocale_c(LC._MASK_ALL, "C", P0)
test_locale_ca = newlocale_c(LC._MASK_ALL, "en_US.utf8", P0)
@test duplocale(test_locale_ca) != P0

@test unsafe_string(nl_langinfo_c(Cint(0xffff), test_locale_ca)) == "en_US.utf8"

COLL_TESTS_C = [
    ( "a", "b", -1 ),
    ( "A", "b", -1 ),
    ( "a", "B", +1 ),
]

COLL_TESTS_FR = [
    ( "a", "b", -1 ),
    ( "A", "b", -1 ),
    ( "a", "B", -1 ),
]

@testset "string comparisons '$a' ~ '$b'" for (a, b, r) in COLL_TESTS_C
    @test sign(strcoll_c(a, b, test_locale_C)) == r
end

@testset "string comparisons '$a' ~ '$b'" for (a, b, r) in COLL_TESTS_FR
    @test sign(strcoll_c(a, b, test_locale_ca)) == r
end

@test freelocale(test_locale_ca) == nothing
freelocale(test_locale_C)
end # isunix
#################################
