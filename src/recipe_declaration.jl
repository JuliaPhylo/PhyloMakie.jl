import PhyloNetworks

Makie.@recipe PhyloPlot (net,) begin
    clip_planes = @inherit clip_planes Makie.automatic
    useedgelength = false
    showtiplabel = true
    shownodelabel = false
    shownodenumber = false
    showedgelength = false
    showedgenumber = false
    showgamma = false
    edgecolor = "black"
    defaultedgecolor = nothing
    majorhybridedgecolor = "deepskyblue4"
    minorhybridedgecolor = "deepskyblue"
    edgewidth = 1
    minorlinetype = nothing
    arrowlen = nothing
    nodelabel = DataFrame()
    edgelabel = DataFrame()
    nodecex = 1
    edgecex = 1
    nodelabelcolor = "black"
    edgelabelcolor = "black"
    edgenumbercolor = "grey"
    nodelabeladj = 1
    edgelabeladj = [0.5, 0]
    tipoffset = 0
    tipcex = 1
    xlim = nothing
    ylim = nothing
    style = :fulltree
end

Makie.plottype(::PhyloNetworks.HybridNetwork) = PhyloPlot
