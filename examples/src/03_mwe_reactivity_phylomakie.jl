using GLMakie
using PhyloMakie
using PhyloNetworks: readnewick

net = readnewick("(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);")

surface = plot(
    net;
    useedgelength = true,
    showtiplabel = true,
    showgamma = true,
)
plot_handle = surface.plot

update!(
    plot_handle;
    edgecolor = "firebrick",
    edgewidth = 2.0,
    # xlim = (0.0, 1.0),
    # ylim = (0.0, 4.0),
)

rootonedge!(net, 4) # nothing happens
preorder!(net)

surface.figure
