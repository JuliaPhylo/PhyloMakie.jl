const SUPPORTED_PHYLOPLOT_ATTRIBUTES = (
    :use_edge_lengths,
    :show_tip_labels,
    :show_internal_node_names,
    :show_node_numbers,
    :show_edge_lengths,
    :show_edge_numbers,
    :show_gamma,
    :edge_color,
    :default_edge_color,
    :major_hybrid_edge_color,
    :minor_hybrid_edge_color,
    :edge_width,
    :minor_edge_linestyle,
    :minor_edge_arrow_length,
    :node_annotations,
    :edge_annotations,
    :node_annotation_scale,
    :edge_annotation_scale,
    :node_annotation_color,
    :edge_annotation_color,
    :node_annotation_align,
    :edge_annotation_align,
    :tip_label_offset,
    :tip_label_scale,
    :x_limits,
    :y_limits,
    :style,
)

const PHYLOPLOT_ATTRIBUTE_MIGRATIONS = (
    (legacy = :useedgelength, public = :use_edge_lengths),
    (legacy = :showtiplabel, public = :show_tip_labels),
    (legacy = :shownodelabel, public = :show_internal_node_names),
    (legacy = :shownodenumber, public = :show_node_numbers),
    (legacy = :showedgelength, public = :show_edge_lengths),
    (legacy = :showedgenumber, public = :show_edge_numbers),
    (legacy = :showgamma, public = :show_gamma),
    (legacy = :edgecolor, public = :edge_color),
    (legacy = :defaultedgecolor, public = :default_edge_color),
    (legacy = :majorhybridedgecolor, public = :major_hybrid_edge_color),
    (legacy = :minorhybridedgecolor, public = :minor_hybrid_edge_color),
    (legacy = :edgewidth, public = :edge_width),
    (legacy = :minorlinetype, public = :minor_edge_linestyle),
    (legacy = :arrowlen, public = :minor_edge_arrow_length),
    (legacy = :nodelabel, public = :node_annotations),
    (legacy = :edgelabel, public = :edge_annotations),
    (legacy = :nodecex, public = :node_annotation_scale),
    (legacy = :edgecex, public = :edge_annotation_scale),
    (legacy = :nodelabelcolor, public = :node_annotation_color),
    (legacy = :edgelabelcolor, public = :edge_annotation_color),
    (legacy = :nodelabeladj, public = :node_annotation_align),
    (legacy = :edgelabeladj, public = :edge_annotation_align),
    (legacy = :tipoffset, public = :tip_label_offset),
    (legacy = :tipcex, public = :tip_label_scale),
    (legacy = :xlim, public = :x_limits),
    (legacy = :ylim, public = :y_limits),
    (legacy = :edgenumbercolor, public = nothing),
    (legacy = :preorder, public = nothing),
)

struct PhyloPlotAttributes{
    TXLimits,
    TYLimits,
    TTipLabelOffset,
    TTipLabelScale,
    TNodeAnnotationScale,
    TEdgeAnnotationScale,
    TNodeAnnotationColor,
    TEdgeAnnotationColor,
    TNodeAnnotationAlign,
    TEdgeAnnotationAlign,
    TEdgeColor,
    TDefaultEdgeColor,
    TMajorHybridEdgeColor,
    TMinorHybridEdgeColor,
    TMinorEdgeLineStyle,
    TMinorEdgeArrowLength,
    TEdgeWidth,
}
    use_edge_lengths::Bool
    show_tip_labels::Bool
    show_internal_node_names::Bool
    show_node_numbers::Bool
    show_edge_lengths::Bool
    show_edge_numbers::Bool
    show_gamma::Bool
    edge_color::TEdgeColor
    default_edge_color::TDefaultEdgeColor
    major_hybrid_edge_color::TMajorHybridEdgeColor
    minor_hybrid_edge_color::TMinorHybridEdgeColor
    edge_width::TEdgeWidth
    minor_edge_linestyle::TMinorEdgeLineStyle
    minor_edge_arrow_length::TMinorEdgeArrowLength
    node_annotations::DataFrame
    edge_annotations::DataFrame
    node_annotation_scale::TNodeAnnotationScale
    edge_annotation_scale::TEdgeAnnotationScale
    node_annotation_color::TNodeAnnotationColor
    edge_annotation_color::TEdgeAnnotationColor
    node_annotation_align::TNodeAnnotationAlign
    edge_annotation_align::TEdgeAnnotationAlign
    tip_label_offset::TTipLabelOffset
    tip_label_scale::TTipLabelScale
    x_limits::TXLimits
    y_limits::TYLimits
    style::Symbol
end

function _resolve_default_edge_color(edge_color, default_edge_color, edge_color_mode::Symbol)
    if edge_color_mode == :by_edge
        return isnothing(default_edge_color) ? "black" : string(default_edge_color)
    end
    return isnothing(default_edge_color) ? edge_color : default_edge_color
end

function _resolve_edge_width_mode(edge_width)::Symbol
    if edge_width isa Number
        return :uniform
    elseif edge_width isa AbstractDict
        valtype(edge_width) <: Number || error("edgewidth should be numerical")
        return :by_edge
    else
        throw(
            ArgumentError(
                "edgewidth should be a number or an AbstractDict with numerical values.",
            ),
        )
    end
end

function resolve_phylo_plot_attributes(;
    use_edge_lengths::Bool=false,
    show_tip_labels::Bool=true,
    show_internal_node_names::Bool=false,
    show_node_numbers::Bool=false,
    show_edge_lengths::Bool=false,
    show_edge_numbers::Bool=false,
    show_gamma::Bool=false,
    edge_color="black",
    default_edge_color=nothing,
    major_hybrid_edge_color::AbstractString="deepskyblue4",
    minor_hybrid_edge_color::AbstractString="deepskyblue",
    edge_width=1,
    minor_edge_linestyle=nothing,
    minor_edge_arrow_length=nothing,
    node_annotations::AbstractDataFrame=DataFrame(),
    edge_annotations::AbstractDataFrame=DataFrame(),
    node_annotation_scale=1,
    edge_annotation_scale=1,
    node_annotation_color="black",
    edge_annotation_color="black",
    node_annotation_align=1,
    edge_annotation_align=[0.5, 0],
    tip_label_offset=0,
    tip_label_scale=1,
    x_limits=nothing,
    y_limits=nothing,
    style::Symbol=:fulltree,
)::PhyloPlotAttributes
    _resolve_edge_width_mode(edge_width)
    resolved_style = _normalize_style(style)
    resolved_minor_edge_arrow_length =
        isnothing(minor_edge_arrow_length) ? (style == :majortree ? 0 : 0.1) : minor_edge_arrow_length
    resolved_minor_edge_linestyle =
        isnothing(minor_edge_linestyle) ? (style == :majortree ? "solid" : "longdash") : minor_edge_linestyle

    return PhyloPlotAttributes(
        use_edge_lengths,
        show_tip_labels,
        show_internal_node_names,
        show_node_numbers,
        show_edge_lengths,
        show_edge_numbers,
        show_gamma,
        edge_color,
        default_edge_color,
        major_hybrid_edge_color,
        minor_hybrid_edge_color,
        edge_width,
        resolved_minor_edge_linestyle,
        resolved_minor_edge_arrow_length,
        _normalize_dataframe(node_annotations),
        _normalize_dataframe(edge_annotations),
        node_annotation_scale,
        edge_annotation_scale,
        node_annotation_color,
        edge_annotation_color,
        node_annotation_align,
        edge_annotation_align,
        tip_label_offset,
        tip_label_scale,
        x_limits,
        y_limits,
        resolved_style,
    )
end

function bridge_phylo_plot_attributes(
    attributes::PhyloPlotAttributes;
    x_limits=attributes.x_limits,
    y_limits=attributes.y_limits,
)::PlotKeywordSpec
    edge_color_mode = attributes.edge_color isa AbstractDict ? :by_edge : :uniform
    default_edge_color = _resolve_default_edge_color(
        attributes.edge_color,
        attributes.default_edge_color,
        edge_color_mode,
    )
    edge_width_mode = _resolve_edge_width_mode(attributes.edge_width)

    layout = PlotKeywordLayout(
        attributes.use_edge_lengths,
        attributes.style,
        x_limits,
        y_limits,
        attributes.tip_label_offset,
        true,
    )
    visibility = PlotKeywordVisibility(
        attributes.show_tip_labels,
        attributes.show_node_numbers,
        attributes.show_edge_lengths,
        attributes.show_gamma,
        attributes.show_edge_numbers,
        attributes.show_internal_node_names,
    )
    annotations = PlotKeywordAnnotations(
        attributes.edge_annotations,
        attributes.node_annotations,
        attributes.tip_label_scale,
        attributes.node_annotation_scale,
        attributes.edge_annotation_scale,
        attributes.edge_annotation_align,
        attributes.node_annotation_align,
    )
    colors = PlotKeywordColors(
        edge_color_mode,
        attributes.edge_color,
        default_edge_color,
        attributes.major_hybrid_edge_color,
        attributes.minor_hybrid_edge_color,
        "grey",
        attributes.edge_annotation_color,
        attributes.node_annotation_color,
    )
    strokes = PlotKeywordStrokes(
        attributes.minor_edge_arrow_length,
        attributes.minor_edge_linestyle,
        edge_width_mode,
        attributes.edge_width,
    )

    return PlotKeywordSpec(layout, visibility, annotations, colors, strokes, ())
end
