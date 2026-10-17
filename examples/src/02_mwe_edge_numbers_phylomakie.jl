using PhyloMakie
using CairoMakie

phylogeny = parsephylogeny(NewickFormat(), "(A,((B,#H1),((C)#H1, D)));")

fig = Figure();
plot(fig[1, 1], phylogeny, showedgenumber = true)
plot(fig[2, 2], phylogeny, showedgenumber = true, edgenumbercolor = "red4")
fig
