module PhyloMakie

import Makie

include("plot_config.jl")
include("network_layout.jl")
include("annotation_tables.jl")
include("primitive_channels.jl")
include("arrowhead_geometry.jl")
include("recipe_declaration.jl")
include("reactive_graph.jl")
include("primitive_assembly.jl")
include("recipe.jl")
include("coordinate_queries.jl")

export phyloplot, phyloplot!, PhyloPlot, node_positions, edge_positions

end
