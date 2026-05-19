import PhyloNetworks


function _validate_public_limits(limit, helper_message::String)
    if isnothing(limit)
        return nothing
    end
    if !applicable(length, limit) || length(limit) != 2
        error(helper_message)
    end
    return limit
end

Makie.@recipe PhyloPlot (net,) begin
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


function Makie.plot!(plot::PhyloPlot)
    attributes = resolve_phylo_plot_attributes(
        useedgelength = Makie.to_value(plot[:useedgelength]),
        showtiplabel = Makie.to_value(plot[:showtiplabel]),
        shownodelabel = Makie.to_value(plot[:shownodelabel]),
        shownodenumber = Makie.to_value(plot[:shownodenumber]),
        showedgelength = Makie.to_value(plot[:showedgelength]),
        showedgenumber = Makie.to_value(plot[:showedgenumber]),
        showgamma = Makie.to_value(plot[:showgamma]),
        edgecolor = Makie.to_value(plot[:edgecolor]),
        defaultedgecolor = Makie.to_value(plot[:defaultedgecolor]),
        majorhybridedgecolor = Makie.to_value(plot[:majorhybridedgecolor]),
        minorhybridedgecolor = Makie.to_value(plot[:minorhybridedgecolor]),
        edgewidth = Makie.to_value(plot[:edgewidth]),
        minorlinetype = Makie.to_value(plot[:minorlinetype]),
        arrowlen = Makie.to_value(plot[:arrowlen]),
        nodelabel = Makie.to_value(plot[:nodelabel]),
        edgelabel = Makie.to_value(plot[:edgelabel]),
        nodecex = Makie.to_value(plot[:nodecex]),
        edgecex = Makie.to_value(plot[:edgecex]),
        nodelabelcolor = Makie.to_value(plot[:nodelabelcolor]),
        edgelabelcolor = Makie.to_value(plot[:edgelabelcolor]),
        edgenumbercolor = Makie.to_value(plot[:edgenumbercolor]),
        nodelabeladj = Makie.to_value(plot[:nodelabeladj]),
        edgelabeladj = Makie.to_value(plot[:edgelabeladj]),
        tipoffset = Makie.to_value(plot[:tipoffset]),
        tipcex = Makie.to_value(plot[:tipcex]),
        xlim = Makie.to_value(plot[:xlim]),
        ylim = Makie.to_value(plot[:ylim]),
        style = Makie.to_value(plot[:style]),
    )

    # deepcopy prevents the user's network from being mutated by directedges!/preorder!
    net = deepcopy(Makie.to_value(plot[:net]))
    layout = prepare_plot_layout(net, attributes; preorder = true)
    validated_xlim = _validate_public_limits(
        attributes.xlim,
        layout.bounds.xlim_error_message,
    )
    validated_ylim = _validate_public_limits(
        attributes.ylim,
        layout.bounds.ylim_error_message,
    )
    resolved_attributes = with_phylo_plot_limits(
        attributes,
        validated_xlim,
        validated_ylim,
    )
    render_plot!(plot, net, resolved_attributes, layout)
    return plot
end
