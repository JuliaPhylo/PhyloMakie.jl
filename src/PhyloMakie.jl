module PhyloMakie

import DataFrames
using DataFrames: AbstractDataFrame, DataFrame
import Downloads
import FileIO
import ImageIO
import Makie
import PhyloNetworks

include("Phylogenies/Phylogenies.jl")
using .Phylogenies
include("PhyloNetworksAdapter/PhyloNetworksAdapter.jl")
using .PhyloNetworksAdapter
include("phylogenyio.jl")
include("plot_config.jl")
include("phylogeny_layout.jl")
include("annotation_tables.jl")
include("image_annotations.jl")
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
    ImageAnnotation,
    Phylogenies,
    AbstractPhylogeny,
    AbstractPhylogeneticNetwork,
    AbstractPhylogeneticTree,
    LineageNode,
    LineageEdge,
    LineageNetwork,
    PhylogenyValidationError,
    nodes,
    edges,
    node,
    edge,
    root,
    node_count,
    edge_count,
    taxon_count,
    node_id,
    edge_id,
    node_label,
    node_data,
    edge_data,
    phylogeny_data,
    node_index,
    edge_index,
    root_index,
    parent_node,
    child_node,
    parents,
    children,
    incoming_edges,
    outgoing_edges,
    incident_edges,
    major_parent_edge,
    is_leaf,
    is_hybrid,
    is_major,
    is_rooted,
    is_tree,
    branch_length,
    inheritance_probability,
    tip_labels,
    preorder,
    postorder,
    validate_phylogeny,
    is_valid,
    add_node!,
    add_edge!,
    delete_node!,
    delete_edge!,
    rename_node!,
    rotate_children!,
    set_branch_length!,
    set_inheritance_probability!,
    set_major_edge!,
    reroot!,
    from_hybridnetwork,
    to_hybridnetwork,
    node_positions,
    node_positions_observable,
    edge_positions

end
