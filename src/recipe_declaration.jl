"""
    phyloplot(net; kwargs...) -> Makie.FigureAxisPlot
    phyloplot!(axis, net; kwargs...) -> PhyloPlot

Plot a `PhyloNetworks.HybridNetwork` with the PhyloMakie Makie recipe.

Use `plot(net; kwargs...)` and `plot!(axis, net; kwargs...)` for the standard
Makie API. `phyloplot` and `phyloplot!` are package-specific aliases generated
by the recipe. Supported attributes control layout style, edge lengths, tip
labels, node labels, edge labels, colors, widths, hybrid-edge arrows, and data
limits. Use `nodeimages` and `edgeimages` to attach image annotations without
depending on implementation-assigned node or edge indices.
"""
Makie.@recipe PhyloPlot (net,) begin
    "Inherited Makie clip planes for the rendered primitives."
    clip_planes = @inherit clip_planes Makie.automatic
    "Use network edge lengths on the x axis."
    useedgelength = false
    "Show tip labels."
    showtiplabel = true
    "Show internal node names."
    shownodelabel = false
    "Show node numbers."
    shownodenumber = false
    "Show edge lengths."
    showedgelength = false
    "Show edge numbers."
    showedgenumber = false
    "Show hybrid-edge inheritance probabilities."
    showgamma = false
    "Set one edge color or a dictionary keyed by edge number."
    edgecolor = "black"
    "Set the fallback edge color when `edgecolor` is a dictionary."
    defaultedgecolor = nothing
    "Set the color for major hybrid edges."
    majorhybridedgecolor = "deepskyblue4"
    "Set the color for minor hybrid edges."
    minorhybridedgecolor = "deepskyblue"
    "Set one edge width or a dictionary keyed by edge number."
    edgewidth = 1
    "Set the line style for minor hybrid edges, or `\"blank\"` to hide them."
    minorlinetype = nothing
    "Set the minor hybrid edge arrow length."
    arrowlen = nothing
    "Supply a node label table."
    nodelabel = DataFrame()
    "Supply an edge label table."
    edgelabel = DataFrame()
    "Map node labels, regular expressions, or objects to images."
    nodeimages = nothing
    "Map edge endpoints or objects to images."
    edgeimages = nothing
    "Scale node label text."
    nodecex = 1
    "Scale edge label text."
    edgecex = 1
    "Set node label color."
    nodelabelcolor = "black"
    "Set edge label color."
    edgelabelcolor = "black"
    "Set edge number color."
    edgenumbercolor = "grey"
    "Set node label alignment."
    nodelabeladj = 1
    "Set edge label alignment."
    edgelabeladj = [0.5, 0]
    "Move tip labels away from tip positions."
    tipoffset = 0
    "Scale tip label text."
    tipcex = 1
    "Set x data limits."
    xlim = nothing
    "Set y data limits."
    ylim = nothing
    "Choose `:fulltree` or `:majortree` layout style."
    style = :fulltree
end

Makie.plottype(::PhyloNetworks.HybridNetwork) = PhyloPlot
