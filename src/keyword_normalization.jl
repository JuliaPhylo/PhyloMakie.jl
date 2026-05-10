using DataFrames: AbstractDataFrame, DataFrame

struct PlotKeywordLayout{TXLim, TYLim, TTipOffset}
    useedgelength::Bool
    style::Symbol
    xlim::TXLim
    ylim::TYLim
    tipoffset::TTipOffset
    preorder::Bool
end

struct PlotKeywordVisibility
    showtiplabel::Bool
    shownodenumber::Bool
    showedgelength::Bool
    showgamma::Bool
    showedgenumber::Bool
    shownodelabel::Bool
end

struct PlotKeywordAnnotations{TTipCex, TNodeCex, TEdgeCex, TEdgeLabelAdj, TNodeLabelAdj}
    edgelabel::DataFrame
    nodelabel::DataFrame
    tipcex::TTipCex
    nodecex::TNodeCex
    edgecex::TEdgeCex
    edgelabeladj::TEdgeLabelAdj
    nodelabeladj::TNodeLabelAdj
end

struct PlotKeywordColors{
    TEdgeColor,
    TDefaultEdgeColor,
    TMajorHybridEdgeColor,
    TMinorHybridEdgeColor,
    TEdgeNumberColor,
    TEdgeLabelColor,
    TNodeLabelColor,
}
    edgecolor_mode::Symbol
    edgecolor::TEdgeColor
    defaultedgecolor::TDefaultEdgeColor
    majorhybridedgecolor::TMajorHybridEdgeColor
    minorhybridedgecolor::TMinorHybridEdgeColor
    edgenumbercolor::TEdgeNumberColor
    edgelabelcolor::TEdgeLabelColor
    nodelabelcolor::TNodeLabelColor
end

struct PlotKeywordStrokes{TArrowLen<:Real, TMinorLineType, TEdgeWidth}
    arrowlen::TArrowLen
    minorlinetype::TMinorLineType
    edgewidth_mode::Symbol
    edgewidth::TEdgeWidth
end

struct PlotKeywordSpec{
    TLayout,
    TVisibility,
    TAnnotations,
    TColors,
    TStrokes,
    TDeferredContracts,
}
    layout::TLayout
    visibility::TVisibility
    annotations::TAnnotations
    colors::TColors
    strokes::TStrokes
    deferred_contracts::TDeferredContracts
end

const SUPPORTED_STYLE_SYMBOLS = (:fulltree, :majortree)

function _normalize_dataframe(table::AbstractDataFrame)::DataFrame
    return DataFrame(table; copycols=true)
end

function _normalize_style(style::Symbol)::Symbol
    if style in SUPPORTED_STYLE_SYMBOLS
        return style
    end
    @warn "Style $style is unknown. Defaulted to :fulltree."
    return :fulltree
end

function _validate_explicit_limit(limit::T, keyword_name::Symbol) where {T}
    if isnothing(limit)
        return limit
    end
    if !applicable(length, limit) || length(limit) != 2
        error("$(keyword_name) must contain exactly 2 values when explicitly provided.")
    end
    return limit
end

function normalize_plot_keywords(;
    useedgelength::Bool=false,
    showtiplabel::Bool=true,
    shownodenumber::Bool=false,
    showedgelength::Bool=false,
    showgamma::Bool=false,
    edgecolor="black",
    majorhybridedgecolor::AbstractString="deepskyblue4",
    minorhybridedgecolor::AbstractString="deepskyblue",
    defaultedgecolor=nothing,
    showedgenumber::Bool=false,
    shownodelabel::Bool=false,
    edgelabel::AbstractDataFrame=DataFrame(),
    nodelabel::AbstractDataFrame=DataFrame(),
    xlim=nothing,
    ylim=nothing,
    tipoffset=0,
    tipcex=1,
    nodecex=1,
    edgecex=1,
    style::Symbol=:fulltree,
    arrowlen::Real=(style == :majortree ? 0 : 0.1),
    minorlinetype=nothing,
    edgewidth=1,
    edgenumbercolor="grey",
    edgelabelcolor="black",
    nodelabelcolor="black",
    edgelabeladj=[0.5, 0],
    nodelabeladj=1,
    preorder::Bool=true,
)::PlotKeywordSpec
    resolved_arrowlen = arrowlen
    resolved_minorlinetype =
        isnothing(minorlinetype) ? (style == :majortree ? "solid" : "longdash") : minorlinetype
    resolved_style = _normalize_style(style)
    resolved_xlim = _validate_explicit_limit(xlim, :xlim)
    resolved_ylim = _validate_explicit_limit(ylim, :ylim)
    resolved_edgelabel = _normalize_dataframe(edgelabel)
    resolved_nodelabel = _normalize_dataframe(nodelabel)

    edgecolor_mode = edgecolor isa AbstractDict ? :by_edge : :uniform
    resolved_defaultedgecolor = if edgecolor_mode == :by_edge
        isnothing(defaultedgecolor) ? "black" : string(defaultedgecolor)
    else
        isnothing(defaultedgecolor) ? edgecolor : defaultedgecolor
    end

    edgewidth_mode = if edgewidth isa Number
        :uniform
    elseif edgewidth isa AbstractDict
        valtype(edgewidth) <: Number || error("edgewidth should be numerical")
        :by_edge
    else
        throw(
            ArgumentError(
                "edgewidth should be a number or an AbstractDict with numerical values.",
            ),
        )
    end

    layout = PlotKeywordLayout(
        useedgelength,
        resolved_style,
        resolved_xlim,
        resolved_ylim,
        tipoffset,
        preorder,
    )
    visibility = PlotKeywordVisibility(
        showtiplabel,
        shownodenumber,
        showedgelength,
        showgamma,
        showedgenumber,
        shownodelabel,
    )
    annotations = PlotKeywordAnnotations(
        resolved_edgelabel,
        resolved_nodelabel,
        tipcex,
        nodecex,
        edgecex,
        edgelabeladj,
        nodelabeladj,
    )
    colors = PlotKeywordColors(
        edgecolor_mode,
        edgecolor,
        resolved_defaultedgecolor,
        majorhybridedgecolor,
        minorhybridedgecolor,
        edgenumbercolor,
        edgelabelcolor,
        nodelabelcolor,
    )
    strokes = PlotKeywordStrokes(
        resolved_arrowlen,
        resolved_minorlinetype,
        edgewidth_mode,
        edgewidth,
    )

    return PlotKeywordSpec(
        layout,
        visibility,
        annotations,
        colors,
        strokes,
        DEFERRED_PLOT_KEYWORD_CONTRACTS,
    )
end
