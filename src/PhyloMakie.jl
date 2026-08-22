module PhyloMakie

import DataFrames
using DataFrames: AbstractDataFrame, DataFrame
import Makie
import PhyloNetworks
import PhyloNetworks: readnewick, readnexus_treeblock

"""
    readnewick(input)

Parse a Newick representation and return a `PhyloNetworks.HybridNetwork`.

PhyloMakie re-exports `PhyloNetworks.readnewick`.
"""
readnewick

"""
    readnexus_treeblock(filename, args...; kwargs...)

Read the first trees block in a NEXUS file and return
`PhyloNetworks.HybridNetwork` values.

PhyloMakie re-exports `PhyloNetworks.readnexus_treeblock`.
"""
readnexus_treeblock

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

export phyloplot,
    phyloplot!,
    PhyloPlot,
    node_positions,
    edge_positions,
    readnewick,
    readnexus_treeblock

end
