using GLMakie
using PhyloMakie

phylogeny = newick"(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"
surface = plot(
    phylogeny;
    useedgelength = false,
    showtiplabel = true,
    showgamma = true,
)
plot_handle = surface.plot

live_positions = node_positions_observable(plot_handle)
tip_positions = map(plot_handle, live_positions) do table
    Point2f[
        Point2f(row.x, row.y) for row in eachrow(table) if row.isleaf
    ]
end
tip_overlay = scatter!(
    surface.axis,
    tip_positions;
    color = :orangered,
    markersize = 14,
)

positions_before = copy(tip_positions[])
update!(
    plot_handle;
    useedgelength = true,
    edgecolor = "firebrick",
    edgewidth = 2.0,
    tipoffset = 0.05,
)
@assert tip_positions[] != positions_before

# Plotting never mutates a caller-owned phylogeny. Replace arg1 explicitly when
# the phylogeny changes; the same live_positions and tip_overlay handles update.
replacement = newick"((A:1.0,B:0.5):1.0,(C:0.75,D:1.25):1.0);"
update!(plot_handle; arg1 = replacement)
@assert live_positions[] == node_positions(plot_handle)

surface.figure
