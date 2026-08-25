using PhyloMakie
using CairoMakie

net = only(parsephylogeny(NewickFormat(), "(A,((B,#H1),((C)#H1, D)));"))

# R"layout"([1 2])
fig = Figure();
plot(fig[1, 1], net, showedgenumber = true)
plot(fig[2, 2], net, showedgenumber = true, edgenumbercolor = "red4")
fig
