import DataFrames
import PhyloNetworks

const DEFAULT_NODE_BAR_WIDTH = 1.0f0
const DEFAULT_TEXT_SIZE = 16.0f0
const DEFAULT_ARROW_PIXEL_SCALE = 80.0f0
const DEFAULT_ARROW_WIDTH_RATIO = 0.8f0
const DEFAULT_INVISIBLE_ARROW_SHAFT_WIDTH = 1.0f0
const DEFAULT_ARROW_STROKEWIDTH = 0.75f0
const ArrowheadPolygon = Makie.GeometryBasics.Polygon{2, Float32}

struct SegmentChannel{TLineStyle}
    points::Vector{Makie.Point2f}
    colors::Vector{Makie.RGBAf}
    linewidths::Vector{Float32}
    linestyle::TLineStyle
end

struct TextChannel{TAlign, TFont}
    positions::Vector{Makie.Point2f}
    strings::Vector{String}
    colors::Vector{Makie.RGBAf}
    fontsizes::Vector{Float32}
    align::TAlign
    font::TFont
end

struct ArrowheadChannel{TMesh}
    meshes::Vector{TMesh}
    colors::Vector{Makie.RGBAf}
    strokecolors::Vector{Makie.RGBAf}
    strokewidth::Float32
    startpoints::Vector{Makie.Point2f}
    endpoints::Vector{Makie.Point2f}
    tiplengths::Vector{Float32}
    tipwidths::Vector{Float32}
end

struct PrimitiveChannels{
        TEdgeSegments,
        TNodeBars,
        TMinorShafts,
        TArrowheads,
        TTipLabels,
        TInternalNames,
        TNodeNumbers,
        TNodeLabels,
        TEdgeLabels,
        TEdgeLengths,
        TMinorGamma,
        TMajorGamma,
        TEdgeNumbers,
    }
    edge_segments::TEdgeSegments
    node_bars::TNodeBars
    minor_edge_shafts::TMinorShafts
    minor_arrowheads::TArrowheads
    tip_labels::TTipLabels
    internal_node_names::TInternalNames
    node_numbers::TNodeNumbers
    node_labels::TNodeLabels
    edge_labels::TEdgeLabels
    edge_lengths::TEdgeLengths
    minor_gamma_labels::TMinorGamma
    major_gamma_labels::TMajorGamma
    edge_numbers::TEdgeNumbers
    data_limits::Makie.Rect3d
end

function _resolve_color(value)::Makie.RGBAf
    return convert(Makie.RGBAf, Makie.to_color(value))
end

function _transparent_color(color::Makie.RGBAf)::Makie.RGBAf
    return Makie.RGBAf(color.r, color.g, color.b, 0.0f0)
end

function _repeat_color(color::Makie.RGBAf, count::Integer)::Vector{Makie.RGBAf}
    return fill(color, count)
end

function compute_edge_colors(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
    )::NamedTuple{(:edgecolors, :minor_edgecolors, :defaultedgecolor)}
    net = plot_network.net
    edgecolor_mode = config.edgecolor isa AbstractDict ? :by_edge : :uniform
    defaultedgecolor = _resolve_color(
        _resolve_defaultedgecolor(
            config.edgecolor,
            config.defaultedgecolor,
            edgecolor_mode,
        ),
    )
    edgecolors = Vector{Makie.RGBAf}(undef, net.numedges)
    minor_edgecolors = Makie.RGBAf[]

    if edgecolor_mode == :by_edge
        for (edge_index, edge) in enumerate(net.edge)
            edgecolor = _resolve_color(
                get(
                    config.edgecolor,
                    edge.number,
                    _resolve_defaultedgecolor(
                        config.edgecolor,
                        config.defaultedgecolor,
                        edgecolor_mode,
                    ),
                ),
            )
            edgecolors[edge_index] = edgecolor
            !edge.ismajor && push!(minor_edgecolors, edgecolor)
        end
        return (edgecolors = edgecolors, minor_edgecolors = minor_edgecolors, defaultedgecolor = defaultedgecolor)
    end

    uniform_edgecolor = _resolve_color(config.edgecolor)
    majorhybridedgecolor = _resolve_color(config.majorhybridedgecolor)
    minorhybridedgecolor = _resolve_color(config.minorhybridedgecolor)

    for (edge_index, edge) in enumerate(net.edge)
        edgecolor = uniform_edgecolor
        edge.hybrid && (edgecolor = majorhybridedgecolor)
        !edge.ismajor && (edgecolor = minorhybridedgecolor)
        edgecolors[edge_index] = edgecolor
        !edge.ismajor && push!(minor_edgecolors, edgecolor)
    end
    return (edgecolors = edgecolors, minor_edgecolors = minor_edgecolors, defaultedgecolor = defaultedgecolor)
end

function compute_edge_widths(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
    )::NamedTuple{(:edgewidths, :minor_edgewidths)}
    net = plot_network.net
    edgewidths = Float32[]
    minor_edgewidths = Float32[]

    if _resolve_edgewidth_mode(config.edgewidth) == :uniform
        resolved_width = Float32(config.edgewidth)
        for edge in net.edge
            push!(edgewidths, resolved_width)
            !edge.ismajor && push!(minor_edgewidths, resolved_width)
        end
        return (edgewidths = edgewidths, minor_edgewidths = minor_edgewidths)
    end

    for edge in net.edge
        resolved_width = haskey(config.edgewidth, edge.number) ?
            Float32(config.edgewidth[edge.number]) : 1.0f0
        push!(edgewidths, resolved_width)
        !edge.ismajor && push!(minor_edgewidths, resolved_width)
    end
    return (edgewidths = edgewidths, minor_edgewidths = minor_edgewidths)
end

function compute_segment_points(
        x_lo::AbstractVector{<:Real},
        x_hi::AbstractVector{<:Real},
        y_lo::AbstractVector{<:Real},
        y_hi::AbstractVector{<:Real},
    )::Vector{Makie.Point2f}
    points = Vector{Makie.Point2f}(undef, 2 * length(x_lo))
    for index in eachindex(x_lo)
        points[(2 * index) - 1] = Makie.Point2f(Float32(x_lo[index]), Float32(y_lo[index]))
        points[2 * index] = Makie.Point2f(Float32(x_hi[index]), Float32(y_hi[index]))
    end
    return points
end

function compute_minor_edge_style(minorlinetype)
    if minorlinetype isa Symbol &&
            minorlinetype in (:solid, :dash, :dot, :dashdot, :dashdotdot)
        return (linestyle = minorlinetype, render_visible = true)
    end

    normalized = if minorlinetype isa Symbol
        lowercase(String(minorlinetype))
    elseif minorlinetype isa AbstractString
        lowercase(String(minorlinetype))
    else
        minorlinetype
    end

    normalized in (0, "0", "blank") && return (linestyle = nothing, render_visible = false)
    normalized in (1, "1", "solid") && return (linestyle = :solid, render_visible = true)
    normalized in (2, "2", "dash", "dashed") && return (linestyle = :dash, render_visible = true)
    normalized in (3, "3", "dot", "dotted") && return (linestyle = :dot, render_visible = true)
    normalized in (4, "4", "dotdash", "dashdot") &&
        return (linestyle = :dashdot, render_visible = true)
    normalized in (5, "5", "longdash") && return (linestyle = :dash, render_visible = true)
    normalized in (6, "6", "twodash", "dashdotdot") &&
        return (linestyle = :dashdotdot, render_visible = true)

    return (linestyle = minorlinetype, render_visible = true)
end

function _repeat_payload(values::AbstractVector{T})::Vector{T} where {T}
    repeated = Vector{T}(undef, 2 * length(values))
    for index in eachindex(values)
        repeated[(2 * index) - 1] = values[index]
        repeated[2 * index] = values[index]
    end
    return repeated
end

function _segment_channel(
        points::Vector{Makie.Point2f},
        colors::Vector{Makie.RGBAf},
        linewidths::Vector{Float32},
        linestyle,
        render_visible::Bool = true,
    )::SegmentChannel
    if !render_visible || isempty(points)
        return SegmentChannel(Makie.Point2f[], Makie.RGBAf[], Float32[], linestyle)
    end
    return SegmentChannel(points, _repeat_payload(colors), _repeat_payload(linewidths), linestyle)
end

function compute_segment_channels(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
        layout::LayoutComputation,
    )::NamedTuple{(:edge_segments, :node_bars, :minor_edge_shafts)}
    geometry = layout.geometry
    colors = compute_edge_colors(plot_network, config)
    widths = compute_edge_widths(plot_network, config)
    edge_points = compute_segment_points(
        geometry.edge_x_lo,
        geometry.edge_x_hi,
        geometry.edge_y_lo,
        geometry.edge_y_hi,
    )
    node_bar_points = compute_segment_points(
        geometry.node_x,
        geometry.node_x,
        geometry.node_y_lo,
        geometry.node_y_hi,
    )
    minor_edge_points = compute_segment_points(
        geometry.arrow_x_lo,
        geometry.arrow_x_hi,
        geometry.arrow_y_lo,
        geometry.arrow_y_hi,
    )
    minor_edge_style = compute_minor_edge_style(config.minorlinetype)
    return (
        edge_segments = _segment_channel(edge_points, colors.edgecolors, widths.edgewidths, :solid),
        node_bars = _segment_channel(
            node_bar_points,
            _repeat_color(colors.defaultedgecolor, length(geometry.node_x)),
            fill(DEFAULT_NODE_BAR_WIDTH, length(geometry.node_x)),
            :solid,
        ),
        minor_edge_shafts = _segment_channel(
            minor_edge_points,
            colors.minor_edgecolors,
            widths.minor_edgewidths,
            minor_edge_style.linestyle,
            minor_edge_style.render_visible,
        ),
    )
end

function compute_arrowhead_metrics(
        arrowlen::Real,
        minor_edgewidths::AbstractVector{<:Real},
    )::NamedTuple{(:tiplengths, :tipwidths)}
    base_tiplength = max(0.0f0, DEFAULT_ARROW_PIXEL_SCALE * Float32(arrowlen))
    tiplengths = Float32[]
    tipwidths = Float32[]
    for linewidth in minor_edgewidths
        width_scale = max(1.0f0, sqrt(Float32(linewidth)))
        push!(tiplengths, base_tiplength * width_scale)
        push!(tipwidths, base_tiplength * DEFAULT_ARROW_WIDTH_RATIO * width_scale)
    end
    return (tiplengths = tiplengths, tipwidths = tipwidths)
end

function _segment_startpoints(channel::SegmentChannel)::Vector{Makie.Point2f}
    return Makie.Point2f[channel.points[index] for index in 1:2:length(channel.points)]
end

function _segment_endpoints(channel::SegmentChannel)::Vector{Makie.Point2f}
    return Makie.Point2f[channel.points[index] for index in 2:2:length(channel.points)]
end

function _arrowhead_polygon(
        startpoint::Makie.Point2f,
        endpoint::Makie.Point2f,
        tiplength::Real,
        tipwidth::Real,
    )::ArrowheadPolygon
    direction = endpoint - startpoint
    segment_length = sqrt(direction[1]^2 + direction[2]^2)
    if segment_length <= 0
        return Makie.Polygon(Makie.Point2f[endpoint, endpoint, endpoint])
    end
    unit_direction = direction / segment_length
    unit_perpendicular = Makie.Vec2f(-unit_direction[2], unit_direction[1])
    data_length = min(Float32(tiplength) / DEFAULT_ARROW_PIXEL_SCALE, segment_length)
    half_width = Float32(tipwidth) / (2.0f0 * DEFAULT_ARROW_PIXEL_SCALE)
    base = endpoint - data_length * unit_direction
    return Makie.Polygon(Makie.Point2f[
        endpoint,
        base + half_width * unit_perpendicular,
        base - half_width * unit_perpendicular,
    ])
end

function compute_arrowhead_channel(
        minor_edge_points::SegmentChannel,
        colors::AbstractVector{Makie.RGBAf},
        tiplengths::AbstractVector{<:Real},
        tipwidths::AbstractVector{<:Real},
        render_visible::Bool,
    )::ArrowheadChannel
    startpoints = _segment_startpoints(minor_edge_points)
    endpoints = _segment_endpoints(minor_edge_points)
    typed_tiplengths = Float32.(tiplengths)
    typed_tipwidths = Float32.(tipwidths)
    if !render_visible || isempty(startpoints)
        return ArrowheadChannel(
            ArrowheadPolygon[],
            Makie.RGBAf[],
            Makie.RGBAf[],
            DEFAULT_ARROW_STROKEWIDTH,
            Makie.Point2f[],
            Makie.Point2f[],
            Float32[],
            Float32[],
        )
    end

    meshes = ArrowheadPolygon[]
    mesh_colors = Makie.RGBAf[]
    for index in eachindex(startpoints)
        if typed_tiplengths[index] <= 0 || typed_tipwidths[index] <= 0
            continue
        end
        push!(
            meshes,
            _arrowhead_polygon(
                startpoints[index],
                endpoints[index],
                typed_tiplengths[index],
                typed_tipwidths[index],
            ),
        )
        push!(mesh_colors, colors[index])
    end
    return ArrowheadChannel(
        meshes,
        mesh_colors,
        copy(mesh_colors),
        DEFAULT_ARROW_STROKEWIDTH,
        startpoints,
        endpoints,
        typed_tiplengths,
        typed_tipwidths,
    )
end

function _coerce_align_value(value)
    return value isa Integer ? Float64(value) : value
end

function compute_text_align(adjustment)
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

function compute_text_sizes(text_cex, count::Integer)::Vector{Float32}
    count == 0 && return Float32[]

    if text_cex isa Union{AbstractVector, Tuple}
        length(text_cex) > 0 ||
            throw(ArgumentError("text size vectors must contain at least 1 value"))
        return [
            DEFAULT_TEXT_SIZE * Float32(text_cex[mod1(index, length(text_cex))]) for
                index in 1:count
        ]
    end

    return fill(DEFAULT_TEXT_SIZE * Float32(text_cex), count)
end

function _default_text_sizes(count::Integer)::Vector{Float32}
    count == 0 && return Float32[]
    return fill(DEFAULT_TEXT_SIZE, count)
end

function _table_positions(
        table::DataFrames.AbstractDataFrame,
        rows,
        x_offset::Real = 0.0,
    )::Vector{Makie.Point2f}
    positions = Makie.Point2f[]
    for row in rows
        push!(
            positions,
            Makie.Point2f(
                Float32(table[row, :x]) + Float32(x_offset),
                Float32(table[row, :y]),
            ),
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

function compute_text_channel(
        table::DataFrames.AbstractDataFrame,
        rows,
        text_column::Symbol,
        color::Makie.RGBAf,
        fontsize::AbstractVector{<:Real},
        align,
        font,
        x_offset::Real = 0.0,
    )::TextChannel
    strings = _table_strings(table, rows, text_column)
    length(strings) == length(fontsize) ||
        error("fontsize must provide exactly 1 value per rendered text entry")
    return TextChannel(
        _table_positions(table, rows, x_offset),
        strings,
        _repeat_color(color, length(strings)),
        Float32.(fontsize),
        align,
        font,
    )
end

function _empty_text_channel(align)::TextChannel
    return TextChannel(
        Makie.Point2f[],
        String[],
        Makie.RGBAf[],
        Float32[],
        align,
        nothing,
    )
end

function compute_text_channels(
        config::PhyloPlotConfig,
        layout::LayoutComputation,
    )::NamedTuple{
        (
            :tip_labels,
            :internal_node_names,
            :node_numbers,
            :node_labels,
            :edge_labels,
            :edge_lengths,
            :minor_gamma_labels,
            :major_gamma_labels,
            :edge_numbers,
        )
    }
    node_table = layout.annotations.node_data
    edge_table = layout.annotations.edge_data
    leaf_rows = findall(node_table.lea)
    internal_rows = findall(.!node_table.lea)
    tip_labels = config.showtiplabel ? compute_text_channel(
        node_table,
        leaf_rows,
        :name,
        _resolve_color("black"),
        compute_text_sizes(config.tipcex, length(leaf_rows)),
        (:left, :center),
        :italic,
        config.tipoffset,
    ) : _empty_text_channel((:left, :center))

    internal_node_names = config.shownodelabel ? compute_text_channel(
        node_table,
        internal_rows,
        :name,
        _resolve_color("black"),
        compute_text_sizes(config.tipcex, length(internal_rows)),
        (0.5, 0.0),
        :italic,
    ) : _empty_text_channel((0.5, 0.0))

    node_number_align = compute_text_align(1)
    node_numbers = config.shownodenumber ? compute_text_channel(
        node_table,
        axes(node_table, 1),
        :num,
        _resolve_color("black"),
        _default_text_sizes(size(node_table, 1)),
        node_number_align,
        nothing,
    ) : _empty_text_channel(node_number_align)

    nodelabeladj = compute_text_align(config.nodelabeladj)
    node_labels = layout.annotations.labelnodes ? compute_text_channel(
        node_table,
        axes(node_table, 1),
        :lab,
        _resolve_color(config.nodelabelcolor),
        compute_text_sizes(config.nodecex, size(node_table, 1)),
        nodelabeladj,
        nothing,
    ) : _empty_text_channel(nodelabeladj)

    edgelabeladj = compute_text_align(config.edgelabeladj)
    edge_labels = layout.annotations.labeledges ? compute_text_channel(
        edge_table,
        axes(edge_table, 1),
        :lab,
        _resolve_color(config.edgelabelcolor),
        compute_text_sizes(config.edgecex, size(edge_table, 1)),
        edgelabeladj,
        nothing,
    ) : _empty_text_channel(edgelabeladj)

    edge_lengths = config.showedgelength ? compute_text_channel(
        edge_table,
        axes(edge_table, 1),
        :len,
        _resolve_color("black"),
        _default_text_sizes(size(edge_table, 1)),
        (0.5, 1.0),
        nothing,
    ) : _empty_text_channel((0.5, 1.0))

    minor_gamma_rows = findall(edge_table.hyb .& edge_table.min)
    major_gamma_rows = findall(edge_table.hyb .& .!edge_table.min)
    minor_gamma_labels = config.showgamma ? compute_text_channel(
        edge_table,
        minor_gamma_rows,
        :gam,
        _resolve_color(config.minorhybridedgecolor),
        _default_text_sizes(length(minor_gamma_rows)),
        (0.5, 1.0),
        nothing,
    ) : _empty_text_channel((0.5, 1.0))
    major_gamma_labels = config.showgamma ? compute_text_channel(
        edge_table,
        major_gamma_rows,
        :gam,
        _resolve_color(config.majorhybridedgecolor),
        _default_text_sizes(length(major_gamma_rows)),
        (0.5, 1.0),
        nothing,
    ) : _empty_text_channel((0.5, 1.0))
    edge_numbers = config.showedgenumber ? compute_text_channel(
        edge_table,
        axes(edge_table, 1),
        :num,
        _resolve_color(config.edgenumbercolor),
        _default_text_sizes(size(edge_table, 1)),
        (0.5, 0.0),
        nothing,
    ) : _empty_text_channel((0.5, 0.0))

    return (
        tip_labels = tip_labels,
        internal_node_names = internal_node_names,
        node_numbers = node_numbers,
        node_labels = node_labels,
        edge_labels = edge_labels,
        edge_lengths = edge_lengths,
        minor_gamma_labels = minor_gamma_labels,
        major_gamma_labels = major_gamma_labels,
        edge_numbers = edge_numbers,
    )
end

function compute_data_limits(
        config::PhyloPlotConfig,
        extent::PlotExtent,
    )::Makie.Rect3d
    xlim = isnothing(config.xlim) ?
        (extent.xmin, extent.xmax) :
        (
            Float64(validate_limit_pair(config.xlim, extent.xlim_error_message)[1]),
            Float64(validate_limit_pair(config.xlim, extent.xlim_error_message)[2]),
        )
    ylim = isnothing(config.ylim) ?
        (extent.ymin, extent.ymax) :
        (
            Float64(validate_limit_pair(config.ylim, extent.ylim_error_message)[1]),
            Float64(validate_limit_pair(config.ylim, extent.ylim_error_message)[2]),
        )
    return Makie.Rect3d(
        Makie.Point3d(xlim[1], ylim[1], 0.0),
        Makie.Vec3d(xlim[2] - xlim[1], ylim[2] - ylim[1], 0.0),
    )
end

function compute_primitive_channels(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
        layout::LayoutComputation,
    )::PrimitiveChannels
    segment_channels = compute_segment_channels(plot_network, config, layout)
    colors = compute_edge_colors(plot_network, config)
    widths = compute_edge_widths(plot_network, config)
    minor_edge_style = compute_minor_edge_style(config.minorlinetype)
    arrow_metrics = compute_arrowhead_metrics(config.arrowlen, widths.minor_edgewidths)
    arrowheads = compute_arrowhead_channel(
        segment_channels.minor_edge_shafts,
        colors.minor_edgecolors,
        arrow_metrics.tiplengths,
        arrow_metrics.tipwidths,
        minor_edge_style.render_visible,
    )
    text_channels = compute_text_channels(config, layout)
    return PrimitiveChannels(
        segment_channels.edge_segments,
        segment_channels.node_bars,
        segment_channels.minor_edge_shafts,
        arrowheads,
        text_channels.tip_labels,
        text_channels.internal_node_names,
        text_channels.node_numbers,
        text_channels.node_labels,
        text_channels.edge_labels,
        text_channels.edge_lengths,
        text_channels.minor_gamma_labels,
        text_channels.major_gamma_labels,
        text_channels.edge_numbers,
        compute_data_limits(config, layout.extent),
    )
end
