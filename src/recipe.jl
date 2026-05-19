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


function Makie.plot!(plot::PhyloPlot)
    # Guards against ComputePipeline re-entry: adding child plots fires bounding-box
    # updates that re-trigger this callback before the current rebuild has finished.
    is_rebuilding = Ref(false)

    Makie.onany(
        plot[:net],
        plot[:useedgelength],
        plot[:showtiplabel],
        plot[:shownodelabel],
        plot[:shownodenumber],
        plot[:showedgelength],
        plot[:showedgenumber],
        plot[:showgamma],
        plot[:edgecolor],
        plot[:defaultedgecolor],
        plot[:majorhybridedgecolor],
        plot[:minorhybridedgecolor],
        plot[:edgewidth],
        plot[:minorlinetype],
        plot[:arrowlen],
        plot[:nodelabel],
        plot[:edgelabel],
        plot[:nodecex],
        plot[:edgecex],
        plot[:nodelabelcolor],
        plot[:edgelabelcolor],
        plot[:edgenumbercolor],
        plot[:nodelabeladj],
        plot[:edgelabeladj],
        plot[:tipoffset],
        plot[:tipcex],
        plot[:xlim],
        plot[:ylim],
        plot[:style];
        update = true,
    ) do net,
            useedgelength, showtiplabel, shownodelabel, shownodenumber,
            showedgelength, showedgenumber, showgamma,
            edgecolor, defaultedgecolor, majorhybridedgecolor, minorhybridedgecolor,
            edgewidth, minorlinetype, arrowlen,
            nodelabel, edgelabel,
            nodecex, edgecex,
            nodelabelcolor, edgelabelcolor, edgenumbercolor,
            nodelabeladj, edgelabeladj,
            tipoffset, tipcex,
            xlim, ylim, style
        is_rebuilding[] && return nothing
        is_rebuilding[] = true
        try
            # delete!(recipe_plot, child) dispatches to attribute deletion — use the scene instead
            scene = Makie.get_scene(plot)
            foreach(child -> delete!(scene, child), copy(plot.plots))
            empty!(plot.plots)
            # deepcopy prevents the user's network from being mutated by directedges!/preorder!
            net_copy = deepcopy(net)
            attributes = resolve_phylo_plot_attributes(;
                useedgelength, showtiplabel, shownodelabel, shownodenumber,
                showedgelength, showedgenumber, showgamma,
                edgecolor, defaultedgecolor, majorhybridedgecolor, minorhybridedgecolor,
                edgewidth, minorlinetype, arrowlen,
                nodelabel, edgelabel,
                nodecex, edgecex,
                nodelabelcolor, edgelabelcolor, edgenumbercolor,
                nodelabeladj, edgelabeladj,
                tipoffset, tipcex,
                xlim, ylim, style,
            )
            layout = prepare_plot_layout(net_copy, attributes; preorder = true)
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
            render_plot!(plot, net_copy, resolved_attributes, layout)
        finally
            is_rebuilding[] = false
        end
        return nothing
    end

    return plot
end
