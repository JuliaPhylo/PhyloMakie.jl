using PhyloNetworks
using PhyloMakie
using CairoMakie

net = readnewick("(A,((B,#H1),(C,(D)#H1)));")

plot(net)
