import DataFrames
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
    node_annotations::TNodeAnnotations
    edge_annotations::TEdgeAnnotations
    edge_lengths::TEdgeLengths
    minor_gamma_labels::TMinorGamma
    major_gamma_labels::TMajorGamma
    edge_numbers::TEdgeNumbers
    resolved_style::Symbol
    applied_xlim::NTuple{2, Float64}
    applied_ylim::NTuple{2, Float64}
end

const DEFAULT_NODE_BAR_WIDTH = 1.0
const DEFAULT_TEXT_SIZE = 16.0
const DEFAULT_ARROW_PIXEL_SCALE = 80.0
const DEFAULT_ARROW_WIDTH_RATIO = 0.8

function _resolve_color(value)::Makie.RGBAf
    return convert(Makie.RGBAf, Makie.to_color(value))
end

function _resolve_edge_colors(
    net::PhyloNetworks.HybridNetwork,
    spec::PlotKeywordSpec,
)::Tuple{Vector{Makie.RGBAf}, Vector{Makie.RGBAf}, Makie.RGBAf}
    default_edge_color = _resolve_color(spec.colors.defaultedgecolor)
    edge_colors = Vector{Makie.RGBAf}(undef, net.numedges)
    minor_edge_colors = Makie.RGBAf[]

    if spec.colors.edgecolor_mode == :by_edge
        for (edge_index, edge) in enumerate(net.edge)
            edge_color = _resolve_color(
                get(spec.colors.edgecolor, edge.number, spec.colors.defaultedgecolor),
            )
            edge_colors[edge_index] = edge_color
            !edge.ismajor && push!(minor_edge_colors, edge_color)
        end
        return edge_colors, minor_edge_colors, default_edge_color
    end

    uniform_edge_color = _resolve_color(spec.colors.edgecolor)
    major_hybrid_edge_color = _resolve_color(spec.colors.majorhybridedgecolor)
    minor_hybrid_edge_color = _resolve_color(spec.colors.minorhybridedgecolor)

    for (edge_index, edge) in enumerate(net.edge)
        edge_color = uniform_edge_color
        edge.hybrid && (edge_color = major_hybrid_edge_color)
        !edge.ismajor && (edge_color = minor_hybrid_edge_color)
        edge_colors[edge_index] = edge_color
        !edge.ismajor && push!(minor_edge_colors, edge_color)
    end
    return edge_colors, minor_edge_colors, default_edge_color
end

function _resolve_edge_widths(
    net::PhyloNetworks.HybridNetwork,
    spec::PlotKeywordSpec,
)::Tuple{Vector{Float64}, Vector{Float64}}
    edge_widths = Float64[]
    minor_edge_widths = Float64[]

    if spec.strokes.edgewidth_mode == :uniform
        resolved_width = Float64(spec.strokes.edgewidth)
        for edge in net.edge
            push!(edge_widths, resolved_width)
            !edge.ismajor && push!(minor_edge_widths, resolved_width)
        end
        return edge_widths, minor_edge_widths
    end

    for edge in net.edge
        resolved_width = haskey(spec.strokes.edgewidth, edge.number) ?
            Float64(spec.strokes.edgewidth[edge.number]) : 1.0
        push!(edge_widths, resolved_width)
        !edge.ismajor && push!(minor_edge_widths, resolved_width)
    end
    return edge_widths, minor_edge_widths
end

function _collect_segment_coordinates(
    x_lo::AbstractVector{<:Real},
    x_hi::AbstractVector{<:Real},
    y_lo::AbstractVector{<:Real},
    y_hi::AbstractVector{<:Real},
)::Tuple{Vector{Tuple{Float64, Float64}}, Vector{Tuple{Float64, Float64}}}
    startpoints = Tuple{Float64, Float64}[]
    endpoints = Tuple{Float64, Float64}[]
    for index in eachindex(x_lo)
        push!(startpoints, (Float64(x_lo[index]), Float64(y_lo[index])))
        push!(endpoints, (Float64(x_hi[index]), Float64(y_hi[index])))
    end
    return startpoints, endpoints
end

function _point2f(point::Tuple{Float64, Float64})::Makie.Point2f
    return Makie.Point2f(Float32(point[1]), Float32(point[2]))
end

function _interleave_segment_points(
    startpoints::Vector{Tuple{Float64, Float64}},
    endpoints::Vector{Tuple{Float64, Float64}},
)::Vector{Makie.Point2f}
    points = Vector{Makie.Point2f}(undef, 2 * length(startpoints))
    for index in eachindex(startpoints)
        points[(2 * index) - 1] = _point2f(startpoints[index])
        points[2 * index] = _point2f(endpoints[index])
    end
    return points
end

function _render_segment_layer!(
    ax,
    startpoints::Vector{Tuple{Float64, Float64}},
    endpoints::Vector{Tuple{Float64, Float64}},
    colors::Vector{Makie.RGBAf},
    linewidths::Vector{Float64},
    linestyle,
    render_visible::Bool=true,
)::SegmentRenderLayer
    plot = if isempty(startpoints) || !render_visible
        nothing
    else
        Makie.linesegments!(
            ax,
            _interleave_segment_points(startpoints, endpoints);
            color=repeat(colors; inner=2),
            linewidth=repeat(linewidths; inner=2),
            linestyle=linestyle,
        )
    end
    return SegmentRenderLayer(plot, startpoints, endpoints, colors, linewidths, linestyle)
end

function _resolve_arrow_metrics(
    arrowlen::Real,
    linewidths::Vector{Float64},
)::Tuple{Vector{Float64}, Vector{Float64}}
    base_tiplength = max(0.0, DEFAULT_ARROW_PIXEL_SCALE * Float64(arrowlen))
    tiplengths = Float64[]
    tipwidths = Float64[]
    for linewidth in linewidths
        width_scale = max(1.0, sqrt(linewidth))
        push!(tiplengths, base_tiplength * width_scale)
        push!(tipwidths, base_tiplength * DEFAULT_ARROW_WIDTH_RATIO * width_scale)
    end
    return tiplengths, tipwidths
end

function _render_arrow_tip_layer!(
    ax,
    startpoints::Vector{Tuple{Float64, Float64}},
    endpoints::Vector{Tuple{Float64, Float64}},
    colors::Vector{Makie.RGBAf},
    linewidths::Vector{Float64},
    linestyle,
    tiplengths::Vector{Float64},
    tipwidths::Vector{Float64},
)::ArrowTipRenderLayer
    plots = Makie.AbstractPlot[
        Makie.arrows2d!(
            ax,
            Makie.Point2f[_point2f(startpoints[index])],
            Makie.Point2f[_point2f(endpoints[index])];
            argmode=:endpoint,
            align=:tip,
            taillength=0.0,
            tailwidth=0.0,
            shaftlength=0.0,
            minshaftlength=0.0,
            maxshaftlength=0.0,
            shaftwidth=0.0,
            tiplength=tiplengths[index],
            tipwidth=tipwidths[index],
            shaftcolor=colors[index],
            tipcolor=colors[index],
            markerspace=:pixel,
        ) for index in eachindex(startpoints) if tiplengths[index] > 0
    ]
    return ArrowTipRenderLayer(
        plots,
        startpoints,
        endpoints,
        colors,
        linewidths,
        linestyle,
        tiplengths,
        tipwidths,
    )
end

function _resolve_minor_edge_linestyle(minorlinetype)
    if minorlinetype isa Symbol && minorlinetype in (:solid, :dash, :dot, :dashdot, :dashdotdot)
        return (linestyle=minorlinetype, render_visible=true)
    end

    normalized = if minorlinetype isa Symbol
        lowercase(String(minorlinetype))
    elseif minorlinetype isa AbstractString
        lowercase(String(minorlinetype))
    else
        minorlinetype
    end

    normalized in (0, "0", "blank") && return (linestyle=nothing, render_visible=false)
    normalized in (1, "1", "solid") && return (linestyle=:solid, render_visible=true)
    normalized in (2, "2", "dash", "dashed") && return (linestyle=:dash, render_visible=true)
    normalized in (3, "3", "dot", "dotted") && return (linestyle=:dot, render_visible=true)
    normalized in (4, "4", "dotdash", "dashdot") &&
        return (linestyle=:dashdot, render_visible=true)
    normalized in (5, "5", "longdash") && return (linestyle=:dash, render_visible=true)
    normalized in (6, "6", "twodash", "dashdotdot") &&
        return (linestyle=:dashdotdot, render_visible=true)

    return (linestyle=minorlinetype, render_visible=true)
end

function _resolve_limits(
    spec::PlotKeywordSpec,
    bounds::PlotBounds,
)::Tuple{NTuple{2, Float64}, NTuple{2, Float64}}
    x_limits = isnothing(spec.layout.xlim) ?
        (bounds.xmin, bounds.xmax) :
        (Float64(spec.layout.xlim[1]), Float64(spec.layout.xlim[2]))
    y_limits = isnothing(spec.layout.ylim) ?
        (bounds.ymin, bounds.ymax) :
        (Float64(spec.layout.ylim[1]), Float64(spec.layout.ylim[2]))
    return x_limits, y_limits
end

function _repeat_color(color::Makie.RGBAf, count::Integer)::Vector{Makie.RGBAf}
    return fill(color, count)
end

function _coerce_align_value(value)
    return value isa Integer ? Float64(value) : value
end

function _adj_to_align(adjustment)
    if adjustment isa AbstractVector
        length(adjustment) == 2 || error("adjustment vectors must contain exactly 2 values")
        return (_coerce_align_value(adjustment[1]), _coerce_align_value(adjustment[2]))
    end
    if adjustment isa Tuple
        length(adjustment) == 2 || error("adjustment tuples must contain exactly 2 values")
        return (_coerce_align_value(adjustment[1]), _coerce_align_value(adjustment[2]))
    end
    return (_coerce_align_value(adjustment), 0.5)
end

function _table_positions(
    table::DataFrames.AbstractDataFrame,
    rows,
    x_offset::Real=0.0,
)::Vector{Tuple{Float64, Float64}}
    positions = Tuple{Float64, Float64}[]
    for row in rows
        push!(
            positions,
            (Float64(table[row, :x]) + Float64(x_offset), Float64(table[row, :y])),
        )
    end
    return positions
end

function _table_strings(
    table::DataFrames.AbstractDataFrame,
    rows,
    column::Symbol,
)::Vector{String}
    return [String(table[row, column]) for row in rows]
end

function _resolve_text_sizes(text_cex, count::Integer)::Vector{Float64}
    count == 0 && return Float64[]

    if text_cex isa Union{AbstractVector, Tuple}
        length(text_cex) > 0 ||
            throw(ArgumentError("text size vectors must contain at least 1 value"))
        return [
            DEFAULT_TEXT_SIZE * Float64(text_cex[mod1(index, length(text_cex))]) for
            index in 1:count
        ]
    end

    return fill(DEFAULT_TEXT_SIZE * Float64(text_cex), count)
end

function _default_text_sizes(count::Integer)::Vector{Float64}
    count == 0 && return Float64[]
    return fill(DEFAULT_TEXT_SIZE, count)
end

function _render_text_layer!(
    ax,
    strings::Vector{String},
    positions::Vector{Tuple{Float64, Float64}},
    colors::Vector{Makie.RGBAf},
    fontsize::Vector{Float64},
    align;
    font=nothing,
)::TextRenderLayer
    length(strings) == length(fontsize) ||
        error("fontsize must provide exactly 1 value per rendered text entry")
    plot = if isempty(strings)
        nothing
    elseif isnothing(font)
        Makie.text!(
            ax,
            [_point2f(position) for position in positions];
            text=strings,
            color=colors,
            fontsize=fontsize,
            align=align,
        )
    else
        Makie.text!(
            ax,
            [_point2f(position) for position in positions];
            text=strings,
            color=colors,
            fontsize=fontsize,
            align=align,
            font=font,
        )
    end
    return TextRenderLayer(plot, strings, positions, colors, align, fontsize)
end

function _empty_text_layer(align)::TextRenderLayer
    return TextRenderLayer(
        nothing,
        String[],
        Tuple{Float64, Float64}[],
        Makie.RGBAf[],
        align,
        Float64[],
    )
end

function _rect3d_from_limits(
    x_limits::NTuple{2, Float64},
    y_limits::NTuple{2, Float64},
)::Makie.Rect3d
    return Makie.Rect3d(
        Makie.Point3d(x_limits[1], y_limits[1], 0.0),
        Makie.Vec3d(x_limits[2] - x_limits[1], y_limits[2] - y_limits[1], 0.0),
    )
end

function _apply_plot_limits!(target, x_limits::NTuple{2, Float64}, y_limits::NTuple{2, Float64})
    if target isa Makie.AbstractAxis
        Makie.xlims!(target, x_limits...)
        Makie.ylims!(target, y_limits...)
        return nothing
    end
    if target isa Makie.AbstractPlot
        target[:data_limits] = _rect3d_from_limits(x_limits, y_limits)
        return nothing
    end
    error("Unsupported render target $(typeof(target))")
end

function render_plot!(
    target,
    net::PhyloNetworks.HybridNetwork,
    spec::PlotKeywordSpec,
    layout::PlotLayout,
)::PlotRenderLayers
    geometry = layout.geometry
    node_table = layout.annotations.node_data
    edge_table = layout.annotations.edge_data

    edge_colors, minor_edge_colors, default_edge_color = _resolve_edge_colors(net, spec)
    edge_widths, minor_edge_widths = _resolve_edge_widths(net, spec)

    edge_startpoints, edge_endpoints = _collect_segment_coordinates(
        geometry.edge_x_lo,
        geometry.edge_x_hi,
        geometry.edge_y_lo,
        geometry.edge_y_hi,
    )
    node_bar_startpoints, node_bar_endpoints = _collect_segment_coordinates(
        geometry.node_x,
        geometry.node_x,
        geometry.node_y_lo,
        geometry.node_y_hi,
    )
    minor_edge_startpoints, minor_edge_endpoints = _collect_segment_coordinates(
        geometry.arrow_x_lo,
        geometry.arrow_x_hi,
        geometry.arrow_y_lo,
        geometry.arrow_y_hi,
    )

    edge_segments = _render_segment_layer!(
        target,
        edge_startpoints,
        edge_endpoints,
        edge_colors,
        edge_widths,
        :solid,
    )
    node_bars = _render_segment_layer!(
        target,
        node_bar_startpoints,
        node_bar_endpoints,
        _repeat_color(default_edge_color, length(node_bar_startpoints)),
        fill(DEFAULT_NODE_BAR_WIDTH, length(node_bar_startpoints)),
        :solid,
    )
    minor_edge_style = _resolve_minor_edge_linestyle(spec.strokes.minorlinetype)
    minor_edge_shafts = _render_segment_layer!(
        target,
        minor_edge_startpoints,
        minor_edge_endpoints,
        minor_edge_colors,
        minor_edge_widths,
        minor_edge_style.linestyle,
        minor_edge_style.render_visible,
    )
    minor_edge_tiplengths, minor_edge_tipwidths =
        _resolve_arrow_metrics(spec.strokes.arrowlen, minor_edge_widths)
    if !minor_edge_style.render_visible
        minor_edge_tiplengths = fill(0.0, length(minor_edge_widths))
        minor_edge_tipwidths = fill(0.0, length(minor_edge_widths))
    end
    minor_edge_tips = _render_arrow_tip_layer!(
        target,
        minor_edge_startpoints,
        minor_edge_endpoints,
        minor_edge_colors,
        minor_edge_widths,
        minor_edge_style.linestyle,
        minor_edge_tiplengths,
        minor_edge_tipwidths,
    )

    leaf_rows = findall(node_table.lea)
    internal_rows = findall(.!node_table.lea)
    tip_labels = spec.visibility.showtiplabel ? _render_text_layer!(
        target,
        _table_strings(node_table, leaf_rows, :name),
        _table_positions(node_table, leaf_rows, spec.layout.tipoffset),
        _repeat_color(_resolve_color("black"), length(leaf_rows)),
        _resolve_text_sizes(spec.annotations.tipcex, length(leaf_rows)),
        (:left, :center);
        font=:italic,
    ) : _empty_text_layer((:left, :center))
    internal_node_names = spec.visibility.shownodelabel ? _render_text_layer!(
        target,
        _table_strings(node_table, internal_rows, :name),
        _table_positions(node_table, internal_rows),
        _repeat_color(_resolve_color("black"), length(internal_rows)),
        _resolve_text_sizes(spec.annotations.tipcex, length(internal_rows)),
        (0.5, 0.0);
        font=:italic,
    ) : _empty_text_layer((0.5, 0.0))
    node_number_align = _adj_to_align(1)
    node_numbers = spec.visibility.shownodenumber ? _render_text_layer!(
        target,
        _table_strings(node_table, axes(node_table, 1), :num),
        _table_positions(node_table, axes(node_table, 1)),
        _repeat_color(_resolve_color("black"), size(node_table, 1)),
        _default_text_sizes(size(node_table, 1)),
        node_number_align,
    ) : _empty_text_layer(node_number_align)
    node_annotation_align = _adj_to_align(spec.annotations.nodelabeladj)
    node_annotations = layout.annotations.labelnodes ? _render_text_layer!(
        target,
        _table_strings(node_table, axes(node_table, 1), :lab),
        _table_positions(node_table, axes(node_table, 1)),
        _repeat_color(_resolve_color(spec.colors.nodelabelcolor), size(node_table, 1)),
        _resolve_text_sizes(spec.annotations.nodecex, size(node_table, 1)),
        node_annotation_align,
    ) : _empty_text_layer(node_annotation_align)
    edge_annotation_align = _adj_to_align(spec.annotations.edgelabeladj)
    edge_annotations = layout.annotations.labeledges ? _render_text_layer!(
        target,
        _table_strings(edge_table, axes(edge_table, 1), :lab),
        _table_positions(edge_table, axes(edge_table, 1)),
        _repeat_color(_resolve_color(spec.colors.edgelabelcolor), size(edge_table, 1)),
        _resolve_text_sizes(spec.annotations.edgecex, size(edge_table, 1)),
        edge_annotation_align,
    ) : _empty_text_layer(edge_annotation_align)
    edge_lengths = spec.visibility.showedgelength ? _render_text_layer!(
        target,
        _table_strings(edge_table, axes(edge_table, 1), :len),
        _table_positions(edge_table, axes(edge_table, 1)),
        _repeat_color(_resolve_color("black"), size(edge_table, 1)),
        _default_text_sizes(size(edge_table, 1)),
        (0.5, 1.0),
    ) : _empty_text_layer((0.5, 1.0))

    minor_gamma_rows = findall(edge_table.hyb .& edge_table.min)
    major_gamma_rows = findall(edge_table.hyb .& .!edge_table.min)
    minor_gamma_labels = spec.visibility.showgamma ? _render_text_layer!(
        target,
        _table_strings(edge_table, minor_gamma_rows, :gam),
        _table_positions(edge_table, minor_gamma_rows),
        _repeat_color(
            _resolve_color(spec.colors.minorhybridedgecolor),
            length(minor_gamma_rows),
        ),
        _default_text_sizes(length(minor_gamma_rows)),
        (0.5, 1.0),
    ) : _empty_text_layer((0.5, 1.0))
    major_gamma_labels = spec.visibility.showgamma ? _render_text_layer!(
        target,
        _table_strings(edge_table, major_gamma_rows, :gam),
        _table_positions(edge_table, major_gamma_rows),
        _repeat_color(
            _resolve_color(spec.colors.majorhybridedgecolor),
            length(major_gamma_rows),
        ),
        _default_text_sizes(length(major_gamma_rows)),
        (0.5, 1.0),
    ) : _empty_text_layer((0.5, 1.0))
    edge_numbers = spec.visibility.showedgenumber ? _render_text_layer!(
        target,
        _table_strings(edge_table, axes(edge_table, 1), :num),
        _table_positions(edge_table, axes(edge_table, 1)),
        _repeat_color(_resolve_color(spec.colors.edgenumbercolor), size(edge_table, 1)),
        _default_text_sizes(size(edge_table, 1)),
        (0.5, 0.0),
    ) : _empty_text_layer((0.5, 0.0))

    x_limits, y_limits = _resolve_limits(spec, layout.bounds)
    _apply_plot_limits!(target, x_limits, y_limits)

    return PlotRenderLayers(
        edge_segments,
        node_bars,
        minor_edge_shafts,
        minor_edge_tips,
        tip_labels,
        internal_node_names,
        node_numbers,
        node_annotations,
        edge_annotations,
        edge_lengths,
        minor_gamma_labels,
        major_gamma_labels,
        edge_numbers,
        spec.layout.style,
        x_limits,
        y_limits,
    )
end
