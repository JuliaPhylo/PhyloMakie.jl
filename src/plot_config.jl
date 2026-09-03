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
    :nodeimages,
    :edgeimages,
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

struct PhyloPlotConfig{
        TXLimits,
        TYLimits,
        TTipOffset,
        TTipScale,
        TNodeScale,
        TEdgeScale,
        TNodeColor,
        TEdgeColor,
        TEdgeNumberColor,
        TNodeAlign,
        TEdgeAlign,
        TEdgeColorInput,
        TDefaultEdgeColor,
        TMajorHybridColor,
        TMinorHybridColor,
        TMinorLineType,
        TArrowLength,
        TEdgeWidthInput,
    }
    useedgelength::Bool
    showtiplabel::Bool
    shownodelabel::Bool
    shownodenumber::Bool
    showedgelength::Bool
    showedgenumber::Bool
    showgamma::Bool
    edgecolor::TEdgeColorInput
    defaultedgecolor::TDefaultEdgeColor
    majorhybridedgecolor::TMajorHybridColor
    minorhybridedgecolor::TMinorHybridColor
    edgewidth::TEdgeWidthInput
    minorlinetype::TMinorLineType
    arrowlen::TArrowLength
    nodelabel::DataFrame
    edgelabel::DataFrame
    nodecex::TNodeScale
    edgecex::TEdgeScale
    nodelabelcolor::TNodeColor
    edgelabelcolor::TEdgeColor
    edgenumbercolor::TEdgeNumberColor
    nodelabeladj::TNodeAlign
    edgelabeladj::TEdgeAlign
    tipoffset::TTipOffset
    tipcex::TTipScale
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

function resolve_plot_config(;
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
    )::PhyloPlotConfig
    _resolve_edgewidth_mode(edgewidth)
    resolved_style = _normalize_style(style)
    resolved_arrowlen =
        isnothing(arrowlen) ? (style == :majortree ? 0 : 0.1) : arrowlen
    resolved_minorlinetype =
        isnothing(minorlinetype) ? (style == :majortree ? "solid" : "longdash") : minorlinetype

    return PhyloPlotConfig(
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

function validate_limit_pair(limit, helper_message::AbstractString)
    if !applicable(length, limit) || length(limit) != 2
        error(helper_message)
    end
    return limit
end

function with_plot_config_limits(config::PhyloPlotConfig, xlim, ylim)::PhyloPlotConfig
    return PhyloPlotConfig(
        config.useedgelength,
        config.showtiplabel,
        config.shownodelabel,
        config.shownodenumber,
        config.showedgelength,
        config.showedgenumber,
        config.showgamma,
        config.edgecolor,
        config.defaultedgecolor,
        config.majorhybridedgecolor,
        config.minorhybridedgecolor,
        config.edgewidth,
        config.minorlinetype,
        config.arrowlen,
        config.nodelabel,
        config.edgelabel,
        config.nodecex,
        config.edgecex,
        config.nodelabelcolor,
        config.edgelabelcolor,
        config.edgenumbercolor,
        config.nodelabeladj,
        config.edgelabeladj,
        config.tipoffset,
        config.tipcex,
        xlim,
        ylim,
        config.style,
    )
end
