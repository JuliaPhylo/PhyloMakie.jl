using PhyloMakie
using CairoMakie

net = only(parsenetwork(NewickFormat(), "(A,((B,#H1),(C,(D)#H1)));"))

plot(net)
