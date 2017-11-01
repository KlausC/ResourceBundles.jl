module X
module ResourceBundles
using ResourceBundles
using Test

const a1 = "arg1"
const a2 = "arg2"
const a3 = 4711

const h0 = 0
const h1 = 1
const hmany = 13

logging()

Locales.set_locale!(:MESSAGES, Locale("en-us"))
@test tr"original $a1($a2) : $(a3*2)" == "US version $(a3*2) / $a2 $a1"


@test trn"This is $h1 house" == "This is 1 house"
@test trn"This is $hmany house" == "These are $(hmany) houses"
@test trn"This is $(0) house" == "This is no house"

Locales.set_locale!(:MESSAGES, Locale("fr"))
@test tr"original $a1($a2) : $(a3*2)" == "original $a1($a2) : $(a3*2)"

@test trn"This is $(1) house" == "C'est une maison"
@test trn"This is $(42) house" == "Ce sont beaucoup($hmany) de maisons"
@test trn"This is $h0 house" == "Ce n'est pas une maison"

end # module
end # module
