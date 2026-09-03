struct PhyloPrimitiveHandles{
        TEdgeSegments,
        TNodeBars,
        TMinorEdgeShafts,
        TMinorArrowheads,
        TEdgeImages,
        TNodeImages,
        TTipLabels,
        TInternalNodeNames,
        TNodeNumbers,
        TNodeLabels,
        TEdgeLabels,
        TEdgeLengths,
        TMinorGammaLabels,
        TMajorGammaLabels,
        TEdgeNumbers,
    }
    edge_segments::TEdgeSegments
    node_bars::TNodeBars
    minor_edge_shafts::TMinorEdgeShafts
    minor_arrowheads::TMinorArrowheads
    edge_images::TEdgeImages
    node_images::TNodeImages
    tip_labels::TTipLabels
    internal_node_names::TInternalNodeNames
    node_numbers::TNodeNumbers
    node_labels::TNodeLabels
    edge_labels::TEdgeLabels
    edge_lengths::TEdgeLengths
    minor_gamma_labels::TMinorGammaLabels
    major_gamma_labels::TMajorGammaLabels
    edge_numbers::TEdgeNumbers
end

function create_image_primitive!(
        plot::PhyloPlot,
        outputs::ImageGraphOutputs,
    )::Makie.Plot
    return Makie.scatter!(
        plot,
        plot[outputs.positions];
        marker = plot[outputs.images],
        markersize = plot[outputs.markersizes],
        marker_offset = plot[outputs.marker_offsets],
        markerspace = :pixel,
        space = :data,
    )
end

function create_segment_primitive!(
        plot::PhyloPlot,
        outputs::SegmentGraphOutputs,
    )::Makie.Plot
    return Makie.linesegments!(
        plot,
        plot[outputs.points];
        color = plot[outputs.colors],
        linewidth = plot[outputs.linewidths],
        linestyle = plot[outputs.linestyle],
    )
end

function create_arrowhead_primitive!(
        plot::PhyloPlot,
        outputs::ArrowheadGraphOutputs,
    )::Makie.Plot
    return Makie.poly!(
        plot,
        plot[outputs.meshes];
        color = plot[outputs.colors],
        strokecolor = plot[outputs.strokecolors],
        strokewidth = plot[outputs.strokewidth],
        space = :pixel,
        transformation = :nothing,
        xautolimits = false,
        yautolimits = false,
    )
end

function create_text_primitive!(
        plot::PhyloPlot,
        outputs::TextGraphOutputs,
    )::Makie.Plot
    return Makie.text!(
        plot,
        plot[outputs.positions];
        text = plot[outputs.strings],
        color = plot[outputs.colors],
        fontsize = plot[outputs.fontsizes],
        align = plot[outputs.align],
    )
end

function create_fonted_text_primitive!(
        plot::PhyloPlot,
        outputs::TextGraphOutputs,
    )::Makie.Plot
    return Makie.text!(
        plot,
        plot[outputs.positions];
        text = plot[outputs.strings],
        color = plot[outputs.colors],
        fontsize = plot[outputs.fontsizes],
        align = plot[outputs.align],
        font = plot[outputs.font],
    )
end

function create_phylo_primitives!(
        plot::PhyloPlot,
        primitive_outputs::PhyloGraphOutputs,
        text_outputs::PhyloTextGraphOutputs,
    )::PhyloPrimitiveHandles
    return PhyloPrimitiveHandles(
        create_segment_primitive!(plot, primitive_outputs.edge_segments),
        create_segment_primitive!(plot, primitive_outputs.node_bars),
        create_segment_primitive!(plot, primitive_outputs.minor_edge_shafts),
        create_arrowhead_primitive!(plot, primitive_outputs.minor_arrowheads),
        create_image_primitive!(plot, primitive_outputs.edge_images),
        create_image_primitive!(plot, primitive_outputs.node_images),
        create_fonted_text_primitive!(plot, text_outputs.tip_labels),
        create_fonted_text_primitive!(plot, text_outputs.internal_node_names),
        create_text_primitive!(plot, text_outputs.node_numbers),
        create_text_primitive!(plot, text_outputs.node_labels),
        create_text_primitive!(plot, text_outputs.edge_labels),
        create_text_primitive!(plot, text_outputs.edge_lengths),
        create_text_primitive!(plot, text_outputs.minor_gamma_labels),
        create_text_primitive!(plot, text_outputs.major_gamma_labels),
        create_text_primitive!(plot, text_outputs.edge_numbers),
    )
end
