function Makie.plot!(plot::PhyloPlot)
    validate_public_plot_limits(plot)
    outputs = register_phylo_graph!(plot)
    create_phylo_primitives!(plot, outputs.primitive_outputs, outputs.text_outputs)
    return plot
end
