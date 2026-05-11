using CairoMakie
using PhyloMakie
using PhyloNetworks: readnewick

net = readnewick("(A,((B,#H1),(C,(D)#H1)));")

plot(net)

# net = readnewick(
#     "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
# )

# plot(
#     net;
#     use_edge_lengths = true,
#     show_gamma = true,
#     show_tip_labels = true,
#     style = :fulltree,
# )