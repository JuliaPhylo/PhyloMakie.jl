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

const DEFAULT_NODE_BAR_WIDTH = 1.0
const DEFAULT_TEXT_SIZE = 16.0
const DEFAULT_ARROW_PIXEL_SCALE = 80.0
const DEFAULT_ARROW_WIDTH_RATIO = 0.8

function _resolve_color(value)::Makie.RGBAf
    return convert(Makie.RGBAf, Makie.to_color(value))
end

function _resolve_edgecolors(
    net::PhyloNetworks.HybridNetwork,
    attributes::PhyloPlotAttributes,
)::Tuple{Vector{Makie.RGBAf}, Vector{Makie.RGBAf}, Makie.RGBAf}
    edgecolor_mode = attributes.edgecolor isa AbstractDict ? :by_edge : :uniform
    defaultedgecolor = _resolve_color(
        _resolve_defaultedgecolor(
            attributes.edgecolor,
            attributes.defaultedgecolor,
            edgecolor_mode,
        ),
    )
    edgecolors = Vector{Makie.RGBAf}(undef, net.numedges)
    minor_edgecolors = Makie.RGBAf[]

    if edgecolor_mode == :by_edge
        for (edge_index, edge) in enumerate(net.edge)
            edgecolor = _resolve_color(
                get(
                    attributes.edgecolor,
                    edge.number,
                    _resolve_defaultedgecolor(
                        attributes.edgecolor,
                        attributes.defaultedgecolor,
                        edgecolor_mode,
                    ),
                ),
            )
            edgecolors[edge_index] = edgecolor
            !edge.ismajor && push!(minor_edgecolors, edgecolor)
        end
        return edgecolors, minor_edgecolors, defaultedgecolor
    end

    uniform_edgecolor = _resolve_color(attributes.edgecolor)
    majorhybridedgecolor = _resolve_color(attributes.majorhybridedgecolor)
    minorhybridedgecolor = _resolve_color(attributes.minorhybridedgecolor)

    for (edge_index, edge) in enumerate(net.edge)
        edgecolor = uniform_edgecolor
        edge.hybrid && (edgecolor = majorhybridedgecolor)
        !edge.ismajor && (edgecolor = minorhybridedgecolor)
        edgecolors[edge_index] = edgecolor
        !edge.ismajor && push!(minor_edgecolors, edgecolor)
    end
    return edgecolors, minor_edgecolors, defaultedgecolor
end

function _resolve_edgewidths(
    net::PhyloNetworks.HybridNetwork,
    attributes::PhyloPlotAttributes,
)::Tuple{Vector{Float64}, Vector{Float64}}
    edgewidths = Float64[]
    minor_edgewidths = Float64[]

    if _resolve_edgewidth_mode(attributes.edgewidth) == :uniform
        resolved_width = Float64(attributes.edgewidth)
        for edge in net.edge
            push!(edgewidths, resolved_width)
            !edge.ismajor && push!(minor_edgewidths, resolved_width)
        end
        return edgewidths, minor_edgewidths
    end

    for edge in net.edge
        resolved_width = haskey(attributes.edgewidth, edge.number) ?
            Float64(attributes.edgewidth[edge.number]) : 1.0
        push!(edgewidths, resolved_width)
        !edge.ismajor && push!(minor_edgewidths, resolved_width)
    end
    return edgewidths, minor_edgewidths
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
            minshaftlength=0.0,
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

function _resolve_minorlinetype(minorlinetype)
    if minorlinetype isa Symbol &&
       minorlinetype in (:solid, :dash, :dot, :dashdot, :dashdotdot)
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
    attributes::PhyloPlotAttributes,
    bounds::PlotBounds,
)::Tuple{NTuple{2, Float64}, NTuple{2, Float64}}
    xlim = isnothing(attributes.xlim) ?
        (bounds.xmin, bounds.xmax) :
        (Float64(attributes.xlim[1]), Float64(attributes.xlim[2]))
    ylim = isnothing(attributes.ylim) ?
        (bounds.ymin, bounds.ymax) :
        (Float64(attributes.ylim[1]), Float64(attributes.ylim[2]))
    return xlim, ylim
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
    xlim::NTuple{2, Float64},
    ylim::NTuple{2, Float64},
)::Makie.Rect3d
    return Makie.Rect3d(
        Makie.Point3d(xlim[1], ylim[1], 0.0),
        Makie.Vec3d(xlim[2] - xlim[1], ylim[2] - ylim[1], 0.0),
    )
end

function _apply_plot_limits!(target, xlim::NTuple{2, Float64}, ylim::NTuple{2, Float64})
    if target isa Makie.AbstractAxis
        Makie.xlims!(target, xlim...)
        Makie.ylims!(target, ylim...)
        return nothing
    end
    if target isa Makie.AbstractPlot
        target[:data_limits] = _rect3d_from_limits(xlim, ylim)
        return nothing
    end
    error("Unsupported render target $(typeof(target))")
end

function render_plot!(
    target,
    net::PhyloNetworks.HybridNetwork,
    attributes::PhyloPlotAttributes,
    layout::PlotLayout,
)::PlotRenderLayers
    geometry = layout.geometry
    node_table = layout.annotations.node_data
    edge_table = layout.annotations.edge_data

    edgecolors, minor_edgecolors, defaultedgecolor = _resolve_edgecolors(net, attributes)
    edgewidths, minor_edgewidths = _resolve_edgewidths(net, attributes)

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
        edgecolors,
        edgewidths,
        :solid,
    )
    node_bars = _render_segment_layer!(
        target,
        node_bar_startpoints,
        node_bar_endpoints,
        _repeat_color(defaultedgecolor, length(node_bar_startpoints)),
        fill(DEFAULT_NODE_BAR_WIDTH, length(node_bar_startpoints)),
        :solid,
    )
    minor_edge_style = _resolve_minorlinetype(attributes.minorlinetype)
    minor_edge_shafts = _render_segment_layer!(
        target,
        minor_edge_startpoints,
        minor_edge_endpoints,
        minor_edgecolors,
        minor_edgewidths,
        minor_edge_style.linestyle,
        minor_edge_style.render_visible,
    )
    minor_edge_tiplengths, minor_edge_tipwidths =
        _resolve_arrow_metrics(attributes.arrowlen, minor_edgewidths)
    if !minor_edge_style.render_visible
        minor_edge_tiplengths = fill(0.0, length(minor_edgewidths))
        minor_edge_tipwidths = fill(0.0, length(minor_edgewidths))
    end
    minor_edge_tips = _render_arrow_tip_layer!(
        target,
        minor_edge_startpoints,
        minor_edge_endpoints,
        minor_edgecolors,
        minor_edgewidths,
        minor_edge_style.linestyle,
        minor_edge_tiplengths,
        minor_edge_tipwidths,
    )

    leaf_rows = findall(node_table.lea)
    internal_rows = findall(.!node_table.lea)
    tip_labels = attributes.showtiplabel ? _render_text_layer!(
        target,
        _table_strings(node_table, leaf_rows, :name),
        _table_positions(node_table, leaf_rows, attributes.tipoffset),
        _repeat_color(_resolve_color("black"), length(leaf_rows)),
        _resolve_text_sizes(attributes.tipcex, length(leaf_rows)),
        (:left, :center);
        font=:italic,
    ) : _empty_text_layer((:left, :center))
    internal_node_names = attributes.shownodelabel ? _render_text_layer!(
        target,
        _table_strings(node_table, internal_rows, :name),
        _table_positions(node_table, internal_rows),
        _repeat_color(_resolve_color("black"), length(internal_rows)),
        _resolve_text_sizes(attributes.tipcex, length(internal_rows)),
        (0.5, 0.0);
        font=:italic,
    ) : _empty_text_layer((0.5, 0.0))
    node_number_align = _adj_to_align(1)
    node_numbers = attributes.shownodenumber ? _render_text_layer!(
        target,
        _table_strings(node_table, axes(node_table, 1), :num),
        _table_positions(node_table, axes(node_table, 1)),
        _repeat_color(_resolve_color("black"), size(node_table, 1)),
        _default_text_sizes(size(node_table, 1)),
        node_number_align,
    ) : _empty_text_layer(node_number_align)
    nodelabeladj = _adj_to_align(attributes.nodelabeladj)
    nodelabel = layout.annotations.labelnodes ? _render_text_layer!(
        target,
        _table_strings(node_table, axes(node_table, 1), :lab),
        _table_positions(node_table, axes(node_table, 1)),
        _repeat_color(_resolve_color(attributes.nodelabelcolor), size(node_table, 1)),
        _resolve_text_sizes(attributes.nodecex, size(node_table, 1)),
        nodelabeladj,
    ) : _empty_text_layer(nodelabeladj)
    edgelabeladj = _adj_to_align(attributes.edgelabeladj)
    edgelabel = layout.annotations.labeledges ? _render_text_layer!(
        target,
        _table_strings(edge_table, axes(edge_table, 1), :lab),
        _table_positions(edge_table, axes(edge_table, 1)),
        _repeat_color(_resolve_color(attributes.edgelabelcolor), size(edge_table, 1)),
        _resolve_text_sizes(attributes.edgecex, size(edge_table, 1)),
        edgelabeladj,
    ) : _empty_text_layer(edgelabeladj)
    edge_lengths = attributes.showedgelength ? _render_text_layer!(
        target,
        _table_strings(edge_table, axes(edge_table, 1), :len),
        _table_positions(edge_table, axes(edge_table, 1)),
        _repeat_color(_resolve_color("black"), size(edge_table, 1)),
        _default_text_sizes(size(edge_table, 1)),
        (0.5, 1.0),
    ) : _empty_text_layer((0.5, 1.0))

    minor_gamma_rows = findall(edge_table.hyb .& edge_table.min)
    major_gamma_rows = findall(edge_table.hyb .& .!edge_table.min)
    minor_gamma_labels = attributes.showgamma ? _render_text_layer!(
        target,
        _table_strings(edge_table, minor_gamma_rows, :gam),
        _table_positions(edge_table, minor_gamma_rows),
        _repeat_color(
            _resolve_color(attributes.minorhybridedgecolor),
            length(minor_gamma_rows),
        ),
        _default_text_sizes(length(minor_gamma_rows)),
        (0.5, 1.0),
    ) : _empty_text_layer((0.5, 1.0))
    major_gamma_labels = attributes.showgamma ? _render_text_layer!(
        target,
        _table_strings(edge_table, major_gamma_rows, :gam),
        _table_positions(edge_table, major_gamma_rows),
        _repeat_color(
            _resolve_color(attributes.majorhybridedgecolor),
            length(major_gamma_rows),
        ),
        _default_text_sizes(length(major_gamma_rows)),
        (0.5, 1.0),
    ) : _empty_text_layer((0.5, 1.0))
    edge_numbers = attributes.showedgenumber ? _render_text_layer!(
        target,
        _table_strings(edge_table, axes(edge_table, 1), :num),
        _table_positions(edge_table, axes(edge_table, 1)),
        _repeat_color(_resolve_color(attributes.edgenumbercolor), size(edge_table, 1)),
        _default_text_sizes(size(edge_table, 1)),
        (0.5, 0.0),
    ) : _empty_text_layer((0.5, 0.0))

    xlim, ylim = _resolve_limits(attributes, layout.bounds)
    _apply_plot_limits!(target, xlim, ylim)

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
        attributes.style,
        xlim,
        ylim,
    )
end
