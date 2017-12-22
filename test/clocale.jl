
using .CLocales


set_locale!(LocaleId("C"), :ALL)
cl = locale()

@test cl != Ptr{Nothing}(0)

@testset "clocale names C"  for sym in keys(locale().dict)
    @test clocale_name(sym) == "C"
end

