using ResourceBundles

const a1 = "arg1"
const a2 = "arg2"
const a3 = 4711

const h0 = 0
const h1 = 1
const hmany = 13

logging()

Locales.set_locale!(:MESSAGES, Locale("en-us"))
@test tr"T3" == "T3 - en_US"
@test tr"original $a1($a2) : $(a3*2)" == "US version $(a3*2) / $a2 $a1"

# test with plural forms
@test_throws ArgumentError tr"error1"
@test_throws ArgumentError tr"error2 $(1)"

@test tr"missing argument value $(99)" == "missing argument value 99"
@test tr"This is $h1 house" == "This is a house"
@test tr"This is $hmany house" == "These are $(hmany) houses"
@test tr"This is $(0) house" == "This is not a house !"
@test tr"This is $(hmany-hmany) house" == "This is not a house !"

Locales.set_locale!(:MESSAGES, Locale("fr"))
@test tr"original $a1($a2) : $(a3*2)" == "original $a1($a2) : $(a3*2)"

@test tr"This is $(1) house" == "C'est une maison"
@test tr"This is $(hmany*3+3) house" == "Ce sont beaucoup(42) de maisons"
@test tr"This is $(10) house" == "Ce sont beaucoup(10) de maisons"
@test tr"This is $h0 house" == "Ce n'est pas une maison"

