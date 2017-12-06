
(
    "" => "Plural-Forms: nplurals=3; plural = n == 1 ? 0 : n == 0 ? 1 : 2",

    "T3" => "T3 - en_US",
    "T5" => "T5 - en_US",
    "T6" => "T6 - en_US",
    "T7" => "T7 - en_US",
    raw"original $(1)($(2)) : $(3)" => raw"US version $(3) / $(2) $(1)",
    raw"These are $(1) houses" => [raw"""This is a house""",
                                   raw"""This is not a house""",
                                   raw"""These are at least $(1) houses""",],

    "error1" => ["error1 $(1)"],
    raw"error2 $(1)" => ["error2a", "error2b"],
    raw"missing argument value $(1)" => String[],
)
