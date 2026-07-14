import PhyloNetworks

struct SegmentRenderLayer{TPlot, TLineStyle}
    plot::TPlot
    startpoints::Vector{Tuple{Float64, Float64}}
    endpoints::Vector{Tuple{Float64, Float64}}
    colors::Vector{Makie.RGBAf}
    linewidths::Vector{Float64}
    linestyle::TLineStyle
end

struct ArrowTipRenderLayer{TPlots, TLineStyle}
    plots::TPlots
    startpoints::Vector{Tuple{Float64, Float64}}
    endpoints::Vector{Tuple{Float64, Float64}}
    colors::Vector{Makie.RGBAf}
    linewidths::Vector{Float64}
    linestyle::TLineStyle
    tiplengths::Vector{Float64}
    tipwidths::Vector{Float64}
end

struct TextRenderLayer{TPlot, TAlign}
    plot::TPlot
    strings::Vector{String}
    positions::Vector{Tuple{Float64, Float64}}
    colors::Vector{Makie.RGBAf}
    align::TAlign
    fontsize::Vector{Float64}
end

struct PlotRenderLayers{
        TEdgeSegments,
        TNodeBars,
        TMinorEdgeShafts,
        TMinorEdgeTips,
        TTipLabels,
        TInternalNodeNames,
        TNodeNumbers,
        TNodeAnnotations,
        TEdgeAnnotations,
        TEdgeLengths,
        TMinorGamma,
        TMajorGamma,
        TEdgeNumbers,
    }
    edge_segments::TEdgeSegments
    node_bars::TNodeBars
    minor_edge_shafts::TMinorEdgeShafts
    minor_edge_tips::TMinorEdgeTips
    tip_labels::TTipLabels
    internal_node_names::TInternalNodeNames
    node_numbers::TNodeNumbers
    nodelabel::TNodeAnnotations
    edgelabel::TEdgeAnnotations
    edge_lengths::TEdgeLengths
    minor_gamma_labels::TMinorGamma
    major_gamma_labels::TMajorGamma
    edge_numbers::TEdgeNumbers
    resolved_style::Symbol
    applied_xlim::NTuple{2, Float64}
    applied_ylim::NTuple{2, Float64}
end

function _tuple_point(point::Makie.Point2f)::Tuple{Float64, Float64}
    return (Float64(point[1]), Float64(point[2]))
end

function _render_segment_startpoints(channel::SegmentChannel)::Vector{Tuple{Float64, Float64}}
    return [_tuple_point(channel.points[index]) for index in 1:2:length(channel.points)]
end

function _render_segment_endpoints(channel::SegmentChannel)::Vector{Tuple{Float64, Float64}}
    return [_tuple_point(channel.points[index]) for index in 2:2:length(channel.points)]
end

function _render_segment_colors(channel::SegmentChannel)::Vector{Makie.RGBAf}
    return Makie.RGBAf[channel.colors[index] for index in 1:2:length(channel.colors)]
end

function _render_segment_linewidths(channel::SegmentChannel)::Vector{Float64}
    return [Float64(channel.linewidths[index]) for index in 1:2:length(channel.linewidths)]
end

function _render_segment_layer!(target, channel::SegmentChannel)::SegmentRenderLayer
    startpoints = _render_segment_startpoints(channel)
    endpoints = _render_segment_endpoints(channel)
    colors = _render_segment_colors(channel)
    linewidths = _render_segment_linewidths(channel)
    plot = isempty(channel.points) ? nothing : Makie.linesegments!(
        target,
        channel.points;
        color = channel.colors,
        linewidth = Float64.(channel.linewidths),
        linestyle = channel.linestyle,
    )
    return SegmentRenderLayer(plot, startpoints, endpoints, colors, linewidths, channel.linestyle)
end

function _render_arrow_tip_layer!(
        target,
        channel::ArrowheadChannel,
        shaft_channel::SegmentChannel,
    )::ArrowTipRenderLayer
    shaft_widths = _render_segment_linewidths(shaft_channel)
    # Transitional Tranche 1 render shell: arrowhead geometry is calculated by
    # ArrowheadChannel, while current public rendering still uses Arrows2D until
    # the stable poly! primitive assembly tranche replaces this child shape.
    plots = Makie.AbstractPlot[
        Makie.arrows2d!(
                target,
                Makie.Point2f[channel.startpoints[index]],
                Makie.Point2f[channel.endpoints[index]];
                argmode = :endpoint,
                align = :tip,
                taillength = 0.0,
                tailwidth = 0.0,
                minshaftlength = 0.0,
                shaftwidth = DEFAULT_INVISIBLE_ARROW_SHAFT_WIDTH,
                tiplength = Float64(channel.tiplengths[index]),
                tipwidth = Float64(channel.tipwidths[index]),
                shaftcolor = _transparent_color(channel.colors[index]),
                tipcolor = channel.colors[index],
                markerspace = :pixel,
            ) for index in eachindex(channel.startpoints) if channel.tiplengths[index] > 0
    ]
    return ArrowTipRenderLayer(
        plots,
        _tuple_point.(channel.startpoints),
        _tuple_point.(channel.endpoints),
        copy(channel.colors),
        shaft_widths,
        shaft_channel.linestyle,
        Float64.(channel.tiplengths),
        Float64.(channel.tipwidths),
    )
end

function _render_text_layer!(target, channel::TextChannel)::TextRenderLayer
    positions = _tuple_point.(channel.positions)
    fontsize = [round(Float64(size); digits = 6) for size in channel.fontsizes]
    plot = if isempty(channel.strings)
        nothing
    elseif isnothing(channel.font)
        Makie.text!(
            target,
            channel.positions;
            text = channel.strings,
            color = channel.colors,
            fontsize = fontsize,
            align = channel.align,
        )
    else
        Makie.text!(
            target,
            channel.positions;
            text = channel.strings,
            color = channel.colors,
            fontsize = fontsize,
            align = channel.align,
            font = channel.font,
        )
    end
    return TextRenderLayer(
        plot,
        channel.strings,
        positions,
        channel.colors,
        channel.align,
        fontsize,
    )
end

function _limits_tuple(rect::Makie.Rect3d)::Tuple{NTuple{2, Float64}, NTuple{2, Float64}}
    rect_min = minimum(rect)
    rect_max = maximum(rect)
    return (
        (Float64(rect_min[1]), Float64(rect_max[1])),
        (Float64(rect_min[2]), Float64(rect_max[2])),
    )
end

function _apply_plot_limits!(target, data_limits::Makie.Rect3d)::Nothing
    xlim, ylim = _limits_tuple(data_limits)
    if target isa Makie.AbstractAxis
        Makie.xlims!(target, xlim...)
        Makie.ylims!(target, ylim...)
        return nothing
    end
    if target isa Makie.AbstractPlot
        target[:data_limits] = data_limits
        return nothing
    end
    error("Unsupported render target $(typeof(target))")
end

function render_plot!(
        target,
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
        layout::LayoutComputation,
    )::PlotRenderLayers
    channels = compute_primitive_channels(plot_network, config, layout)

    edge_segments = _render_segment_layer!(target, channels.edge_segments)
    node_bars = _render_segment_layer!(target, channels.node_bars)
    minor_edge_shafts = _render_segment_layer!(target, channels.minor_edge_shafts)
    minor_edge_tips = _render_arrow_tip_layer!(
        target,
        channels.minor_arrowheads,
        channels.minor_edge_shafts,
    )

    tip_labels = _render_text_layer!(target, channels.tip_labels)
    internal_node_names = _render_text_layer!(target, channels.internal_node_names)
    node_numbers = _render_text_layer!(target, channels.node_numbers)
    nodelabel = _render_text_layer!(target, channels.node_labels)
    edgelabel = _render_text_layer!(target, channels.edge_labels)
    edge_lengths = _render_text_layer!(target, channels.edge_lengths)
    minor_gamma_labels = _render_text_layer!(target, channels.minor_gamma_labels)
    major_gamma_labels = _render_text_layer!(target, channels.major_gamma_labels)
    edge_numbers = _render_text_layer!(target, channels.edge_numbers)

    _apply_plot_limits!(target, channels.data_limits)
    xlim, ylim = _limits_tuple(channels.data_limits)

    return PlotRenderLayers(
        edge_segments,
        node_bars,
        minor_edge_shafts,
        minor_edge_tips,
        tip_labels,
        internal_node_names,
        node_numbers,
        nodelabel,
        edgelabel,
        edge_lengths,
        minor_gamma_labels,
        major_gamma_labels,
        edge_numbers,
        config.style,
        xlim,
        ylim,
    )
end

function render_plot!(
        target,
        net::PhyloNetworks.HybridNetwork,
        attributes::PhyloPlotAttributes,
        layout::PlotLayout,
    )::PlotRenderLayers
    return render_plot!(
        target,
        PlotNetwork(net),
        PhyloPlotConfig(attributes),
        LayoutComputation(layout),
    )
end
