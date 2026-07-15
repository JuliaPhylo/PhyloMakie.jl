import PhyloNetworks


function _validate_public_limits(limit, helper_message::String)
    return validate_limit_pair(limit, helper_message)
end


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
            scene = Makie.get_scene(plot)
            foreach(child -> delete!(scene, child), copy(plot.plots))
            empty!(plot.plots)
            config = resolve_plot_config(;
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
            plot_network = prepare_plot_network(net)
            geometry = compute_network_geometry(plot_network, config)
            layout = compute_layout(plot_network, config, geometry)
            render_plot!(plot, plot_network, config, layout)
        finally
            is_rebuilding[] = false
        end
        return nothing
    end

    return plot
end
