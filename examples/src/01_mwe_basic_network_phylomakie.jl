using PhyloMakie
using CairoMakie

net = PhyloMakie.readnewick("(A,((B,#H1),(C,(D)#H1)));")

plot(net)
