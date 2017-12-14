
module Constants

export EMPTYV, EMPTYD, EMPTY_VECTOR, S0
export ALL_CATEGORIES

import ResourceBundles: ExtensionDict

const EMPTYV = String[]
const EMPTYD = ExtensionDict()
const S0 = Symbol("")
const EMPTY_VECTOR = Symbol[]

const ALL_CATEGORIES = [ :CTYPE, :NUMERIC, :TIME, :COLLATE, :MONETARY, :MESSAGES, :ALL,
                    :PAPER, :NAME, :ADDRESS, :TELEPHONE, :MEASUREMENTS, :IDENTIFICATION ]


end
