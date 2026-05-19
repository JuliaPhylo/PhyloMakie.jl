using DataFrames: AbstractDataFrame, DataFrame

const SUPPORTED_STYLE_SYMBOLS = (:fulltree, :majortree)

const SUPPORTED_PHYLOPLOT_ATTRIBUTES = (
    :clip_planes,
    :useedgelength,
    :showtiplabel,
    :shownodelabel,
    :shownodenumber,
    :showedgelength,
    :showedgenumber,
    :showgamma,
    :edgecolor,
    :defaultedgecolor,
    :majorhybridedgecolor,
    :minorhybridedgecolor,
    :edgewidth,
    :minorlinetype,
    :arrowlen,
    :nodelabel,
    :edgelabel,
    :nodecex,
    :edgecex,
    :nodelabelcolor,
    :edgelabelcolor,
    :edgenumbercolor,
    :nodelabeladj,
    :edgelabeladj,
    :tipoffset,
    :tipcex,
    :xlim,
    :ylim,
    :style,
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
        TEdgeNumberColor,
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
    useedgelength::Bool
    showtiplabel::Bool
    shownodelabel::Bool
    shownodenumber::Bool
    showedgelength::Bool
    showedgenumber::Bool
    showgamma::Bool
    edgecolor::TEdgeColor
    defaultedgecolor::TDefaultEdgeColor
    majorhybridedgecolor::TMajorHybridEdgeColor
    minorhybridedgecolor::TMinorHybridEdgeColor
    edgewidth::TEdgeWidth
    minorlinetype::TMinorEdgeLineStyle
    arrowlen::TMinorEdgeArrowLength
    nodelabel::DataFrame
    edgelabel::DataFrame
    nodecex::TNodeAnnotationScale
    edgecex::TEdgeAnnotationScale
    nodelabelcolor::TNodeAnnotationColor
    edgelabelcolor::TEdgeAnnotationColor
    edgenumbercolor::TEdgeNumberColor
    nodelabeladj::TNodeAnnotationAlign
    edgelabeladj::TEdgeAnnotationAlign
    tipoffset::TTipLabelOffset
    tipcex::TTipLabelScale
    xlim::TXLimits
    ylim::TYLimits
    style::Symbol
end

function _normalize_dataframe(table::AbstractDataFrame)::DataFrame
    return DataFrame(table; copycols = true)
end

function _normalize_style(style::Symbol)::Symbol
    if style in SUPPORTED_STYLE_SYMBOLS
        return style
    end
    @warn "Style $style is unknown. Defaulted to :fulltree."
    return :fulltree
end

function _resolve_defaultedgecolor(edgecolor, defaultedgecolor, edgecolor_mode::Symbol)
    if edgecolor_mode == :by_edge
        return isnothing(defaultedgecolor) ? "black" : string(defaultedgecolor)
    end
    return isnothing(defaultedgecolor) ? edgecolor : defaultedgecolor
end

function _resolve_edgewidth_mode(edgewidth)::Symbol
    if edgewidth isa Number
        return :uniform
    elseif edgewidth isa AbstractDict
        valtype(edgewidth) <: Number || error("edgewidth should be numerical")
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
        useedgelength::Bool = false,
        showtiplabel::Bool = true,
        shownodelabel::Bool = false,
        shownodenumber::Bool = false,
        showedgelength::Bool = false,
        showedgenumber::Bool = false,
        showgamma::Bool = false,
        edgecolor = "black",
        defaultedgecolor = nothing,
        majorhybridedgecolor::AbstractString = "deepskyblue4",
        minorhybridedgecolor::AbstractString = "deepskyblue",
        edgewidth = 1,
        minorlinetype = nothing,
        arrowlen = nothing,
        nodelabel::AbstractDataFrame = DataFrame(),
        edgelabel::AbstractDataFrame = DataFrame(),
        nodecex = 1,
        edgecex = 1,
        nodelabelcolor = "black",
        edgelabelcolor = "black",
        edgenumbercolor = "grey",
        nodelabeladj = 1,
        edgelabeladj = [0.5, 0],
        tipoffset = 0,
        tipcex = 1,
        xlim = nothing,
        ylim = nothing,
        style::Symbol = :fulltree,
    )::PhyloPlotAttributes
    _resolve_edgewidth_mode(edgewidth)
    resolved_style = _normalize_style(style)
    resolved_arrowlen =
        isnothing(arrowlen) ? (style == :majortree ? 0 : 0.1) : arrowlen
    resolved_minorlinetype =
        isnothing(minorlinetype) ? (style == :majortree ? "solid" : "longdash") : minorlinetype

    return PhyloPlotAttributes(
        useedgelength,
        showtiplabel,
        shownodelabel,
        shownodenumber,
        showedgelength,
        showedgenumber,
        showgamma,
        edgecolor,
        defaultedgecolor,
        majorhybridedgecolor,
        minorhybridedgecolor,
        edgewidth,
        resolved_minorlinetype,
        resolved_arrowlen,
        _normalize_dataframe(nodelabel),
        _normalize_dataframe(edgelabel),
        nodecex,
        edgecex,
        nodelabelcolor,
        edgelabelcolor,
        edgenumbercolor,
        nodelabeladj,
        edgelabeladj,
        tipoffset,
        tipcex,
        xlim,
        ylim,
        resolved_style,
    )
end

function with_phylo_plot_limits(
        attributes::PhyloPlotAttributes,
        xlim,
        ylim,
    )::PhyloPlotAttributes
    return PhyloPlotAttributes(
        attributes.useedgelength,
        attributes.showtiplabel,
        attributes.shownodelabel,
        attributes.shownodenumber,
        attributes.showedgelength,
        attributes.showedgenumber,
        attributes.showgamma,
        attributes.edgecolor,
        attributes.defaultedgecolor,
        attributes.majorhybridedgecolor,
        attributes.minorhybridedgecolor,
        attributes.edgewidth,
        attributes.minorlinetype,
        attributes.arrowlen,
        attributes.nodelabel,
        attributes.edgelabel,
        attributes.nodecex,
        attributes.edgecex,
        attributes.nodelabelcolor,
        attributes.edgelabelcolor,
        attributes.edgenumbercolor,
        attributes.nodelabeladj,
        attributes.edgelabeladj,
        attributes.tipoffset,
        attributes.tipcex,
        xlim,
        ylim,
        attributes.style,
    )
end
