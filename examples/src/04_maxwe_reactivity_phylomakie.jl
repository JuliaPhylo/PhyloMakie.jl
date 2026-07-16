using CairoMakie
using PhyloMakie
using PhyloNetworks: readnewick

net1 = readnewick("(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);")
net2 = readnewick("(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);")

fig = Figure(size = (1200, 760))
before_axis = Axis(fig[1, 1], title = "Initial full-tree plot")
after_axis = Axis(fig[1, 2], title = "Updated plot")
majortree_axis = Axis(fig[2, 1], title = "Updated network and major-tree style")
hidden_axis = Axis(fig[2, 2], title = "Hidden labels and minor hybrid edges")

plot!(
    before_axis,
    net1;
    useedgelength = true,
    showtiplabel = true,
    showgamma = true,
    minorlinetype = :dash,
)

after_plot = plot!(
    after_axis,
    net1;
    useedgelength = true,
    showtiplabel = true,
    showgamma = true,
    minorlinetype = :dash,
)

majortree_plot = phyloplot!(
    majortree_axis,
    net1;
    useedgelength = true,
    showtiplabel = true,
    showgamma = true,
    minorlinetype = :dash,
)

hidden_plot = phyloplot!(
    hidden_axis,
    net1;
    useedgelength = true,
    showtiplabel = true,
    showgamma = true,
    minorlinetype = :dash,
)

update!(
    after_plot;
    edgecolor = "firebrick",
    edgewidth = 3.0,
    majorhybridedgecolor = "darkgreen",
    minorhybridedgecolor = "goldenrod",
    xlim = (0.0, 1.0),
    ylim = (0.0, 4.0),
)

update!(
    majortree_plot;
    arg1 = net2,
    style = :majortree,
    edgecolor = "navy",
    edgewidth = 2.5,
    xlim = (0.0, 3.2),
    ylim = (0.0, 4.0),
)

update!(
    hidden_plot;
    showtiplabel = false,
    showgamma = false,
    minorlinetype = "blank",
    edgecolor = "gray25",
    edgewidth = 2.0,
)

fig
