
const a1 = "arg1"
const a2 = "arg2"
const a3 = 4711

const h0 = 0
const h1 = 1
const hmany = 13

city = "Frankfurt"
temp = 29.0
ndhi = 15

logging()

set_locale!(:MESSAGES, Locale("en-us"))
@test tr"T3" == "T3 - en_US"
@test tr"original $a1($a2) : $(a3*2)" == "US version $(a3*2) / $a2 $a1"

# test with invalid plural forms
@test_throws ArgumentError tr"error1"
@test tr"error2 $h1" == "error2a"

# attention: en-US defines a non-standard plurals rule
@test tr"missing argument value $(99)" == "missing argument value 99"
@test tr"These are $h1 houses" == "This is a house"
@test tr"These are $hmany houses" == "These are at least $(hmany) houses"
@test tr"These are $(0) houses" == "This is not a house"
@test tr"These are $(hmany-hmany) houses" == "This is not a house"

set_locale!(:MESSAGES, Locale("fr"))
@test tr"original $a1($a2) : $(a3*2)" == "original $a1($a2) : $(a3*2)"

@test tr"These are $(1) houses" == "C'est 1 maison"
@test tr"These are $(hmany*3+3) houses" == "Ce sont beaucoup(42) de maisons"
@test tr"These are $(10) houses" == "Ce sont beaucoup(10) de maisons"
@test tr"These are $h0 houses" == "C'est 0 maison"

set_locale!(:MESSAGES, Locale("de-AT"))
@test tr"These are $(1) houses" == "Das ist ein Haus"
@test tr"These are $(hmany*3+3) houses" == "Das sind 42 Häuser"
@test tr"These are $(10) houses" == "Das sind 10 Häuser"
@test tr"These are $h0 houses" == "Das sind 0 Häuser"
@test tr"In $(city) the temperature was above $(temp) °C" == "Die Temperatur von $(temp) °C wurde in $(city) überschritten"
@test tr"In $(city) the temperature was above $(temp) °C at $(!ndhi) days" == "In $(city) war die Temperatur an $(ndhi) Tagen über $(temp) °C"
@test tr"In $(city) the temperature was above $(temp) °C at $(!h1) days" == "In $(city) war die Temperatur an einem \"Tag\" über $(temp) °C"

# Permutations
@test tr"123 $(1) $(2) $(3)" == "123 1 2 3"
@test tr"132 $(1) $(2) $(3)" == "132 1 3 2"
@test tr"213 $(1) $(2) $(3)" == "213 2 1 3"
@test tr"213 $(1) $(2) $(3)" == "213 2 1 3"
@test tr"312 $(1) $(2) $(3)" == "312 3 1 2"
@test tr"321 $(1) $(2) $(3)" == "321 3 2 1"

# Primary Forms
@test tr"123 $(1) $(!2) $(3)" == "123 1 2 3"
@test tr"132 $(1) $(!2) $(3)" == "132 1 3 2" #
@test tr"213 $(1) $(!2) $(3)" == "213 2 1 3" 
@test tr"213 $(1) $(!2) $(3)" == "213 2 1 3"
@test tr"312 $(1) $(!2) $(3)" == "312 3 1 2" #
@test tr"321 $(1) $(!2) $(3)" == "321 3 2 1" #
@test tr"123 $(1) $(2) $(!3)" == "123 1 2 3" #
@test tr"132 $(1) $(2) $(!3)" == "132 1 3 2" #
@test tr"213 $(1) $(2) $(!3)" == "213 2 1 3" #
@test tr"213 $(1) $(2) $(!3)" == "213 2 1 3" #
@test tr"312 $(1) $(2) $(!3)" == "312 3 1 2" #
@test tr"321 $(1) $(2) $(!3)" == "321 3 2 1" #

# Context
@test tr"§testctx§original" == "O r i g i n a l"

# evoke warnings when reading files
io = IOBuffer()
logging(io)
load_file(joinpath("resources", "messages.pox"))
mess = String(take!(io))
@test contains(mess, "invalid extension of file name")

load_file(joinpath("resources", "messages_tv.po"))
mess = String(take!(io))
@test contains(mess, "unexpected msgid")


