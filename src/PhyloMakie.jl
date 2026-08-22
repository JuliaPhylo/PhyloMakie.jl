module PhyloMakie

import DataFrames
using DataFrames: AbstractDataFrame, DataFrame
import Makie
import PhyloNetworks
import PhyloNetworks: readnewick

"""
    readnewick(input)

Parse a Newick representation and return a `PhyloNetworks.HybridNetwork`.

PhyloMakie re-exports `PhyloNetworks.readnewick`.
"""
readnewick

include("networkaccessors.jl")
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

export phyloplot, phyloplot!, PhyloPlot, node_positions, edge_positions, readnewick

end
