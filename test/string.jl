module X
module ResourceBundles
using ResourceBundles
using Test

const a1 = "arg1"
const a2 = "arg2"
const a3 = 4711

Locales.set_locale!(:MESSAGES, Locale("en-us"))
@test tr"original $a1($a2) : $(a3*2)" == "US version $(a3*2) / $a2 $a1"

Locales.set_locale!(:MESSAGES, Locale("fr"))
@test tr"original $a1($a2) : $(a3*2)" == "original $a1($a2) : $(a3*2)"



end # module
end # module
