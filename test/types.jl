
using ResourceBundles.LC

lca = LC.ALL
lct = LC.TIME
lci = LC.IDENTIFICATION
lcc = LC.CTYPE

@test lca ⊆ lca
@test lct ⊆ lca
@test !(lca ⊆ lct)
@test lct ⊆ lct
@test lci ⊆ lct | lci
@test lca | lct === lca
@test lci | lci === lci
@test lci | lct === lct | lci
@test lci | lct ⊆ lct | lci
@test lci | lct ⊆ lca
@test lcc | lci | lct | lci === lci | lct | lcc

@test collect(lci) == [lci]
@test collect(lci | lct) == [lct, lci]
@test length(collect(lca )) == 12


