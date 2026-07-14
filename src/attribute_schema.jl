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

function PhyloPlotAttributes(config::PhyloPlotConfig)::PhyloPlotAttributes
    return PhyloPlotAttributes(
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
        config.xlim,
        config.ylim,
        config.style,
    )
end

function PhyloPlotConfig(attributes::PhyloPlotAttributes)::PhyloPlotConfig
    return PhyloPlotConfig(
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
        attributes.xlim,
        attributes.ylim,
        attributes.style,
    )
end

function resolve_phylo_plot_attributes(; kwargs...)::PhyloPlotAttributes
    return PhyloPlotAttributes(resolve_plot_config(; kwargs...))
end

function with_phylo_plot_limits(
        attributes::PhyloPlotAttributes,
        xlim,
        ylim,
    )::PhyloPlotAttributes
    return PhyloPlotAttributes(with_plot_config_limits(PhyloPlotConfig(attributes), xlim, ylim))
end
