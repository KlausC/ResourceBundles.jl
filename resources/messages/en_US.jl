
Dict(
     "T3" => "T3 - en_US",
     "T5" => "T5 - en_US",
     "T6" => "T6 - en_US",
     "T7" => "T7 - en_US",
     raw"original $(1)($(2)) : $(3)" => raw"US version $(3) / $(2) $(1)",
     raw"This is $(1) house" => [raw"""This is $(1 => "a") house""",
                                 raw"""This is not a house $(0=>"!")""",
                                 raw"""These are $(Any) houses""",]

    )
