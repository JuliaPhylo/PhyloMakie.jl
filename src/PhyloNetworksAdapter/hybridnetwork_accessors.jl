# This file is the complete anti-corruption boundary around PhyloNetworks'
# HybridNetwork representation. Prefer exported upstream functions. Qualified
# field access is intentionally confined here when PhyloNetworks 1.3.1 does not
# expose the required enumeration, ordering, metadata, or construction API.

_hybrid_nodes(hybrid_phylogeny::PhyloNetworks.HybridNetwork) = hybrid_phylogeny.node
_hybrid_edges(hybrid_phylogeny::PhyloNetworks.HybridNetwork) = hybrid_phylogeny.edge
_hybrid_root_index(hybrid_phylogeny::PhyloNetworks.HybridNetwork)::Int = hybrid_phylogeny.rooti
_hybrid_is_rooted(hybrid_phylogeny::PhyloNetworks.HybridNetwork)::Bool = hybrid_phylogeny.isrooted
_hybrid_incident_edges(current_node::PhyloNetworks.Node) = current_node.edge

_hybrid_node_id(current_node::PhyloNetworks.Node)::Int = current_node.number
_hybrid_node_label(current_node::PhyloNetworks.Node)::String = String(current_node.name)
_hybrid_node_is_leaf(current_node::PhyloNetworks.Node)::Bool = current_node.leaf
_hybrid_node_is_hybrid(current_node::PhyloNetworks.Node)::Bool = current_node.hybrid

_hybrid_edge_id(current_edge::PhyloNetworks.Edge)::Int = current_edge.number
_hybrid_edge_parent(current_edge::PhyloNetworks.Edge) = PhyloNetworks.getparent(current_edge)
_hybrid_edge_child(current_edge::PhyloNetworks.Edge) = PhyloNetworks.getchild(current_edge)
_hybrid_edge_is_hybrid(current_edge::PhyloNetworks.Edge)::Bool = current_edge.hybrid
_hybrid_edge_is_major(current_edge::PhyloNetworks.Edge)::Bool = current_edge.ismajor

function _hybrid_edge_length(current_edge::PhyloNetworks.Edge)::Union{Missing, Float64}
    return current_edge.length == -1.0 ? missing : current_edge.length
end

function _hybrid_edge_gamma(current_edge::PhyloNetworks.Edge)::Union{Missing, Float64}
    return current_edge.gamma == -1.0 ? missing : current_edge.gamma
end

function _set_hybrid_node_label!(
        current_node::PhyloNetworks.Node,
        label::AbstractString,
    )::Nothing
    current_node.name = String(label)
    return nothing
end

function _set_hybrid_node_edges!(
        current_node::PhyloNetworks.Node,
        incident::Vector{PhyloNetworks.Edge},
    )::Nothing
    current_node.edge = incident
    current_node.booln1 = any(current_edge -> current_edge.hybrid, incident)
    return nothing
end

function _set_hybrid_edge_major!(
        current_edge::PhyloNetworks.Edge,
        major::Bool,
    )::Nothing
    current_edge.ismajor = major
    return nothing
end

function _set_hybrid_root_index!(
        hybrid_phylogeny::PhyloNetworks.HybridNetwork,
        index::Int,
    )::Nothing
    hybrid_phylogeny.rooti = index
    return nothing
end

function _set_hybrid_names!(
        hybrid_phylogeny::PhyloNetworks.HybridNetwork,
        names::Vector{String},
    )::Nothing
    hybrid_phylogeny.names = names
    return nothing
end

function _set_hybrid_rooted!(
        hybrid_phylogeny::PhyloNetworks.HybridNetwork,
        rooted::Bool,
    )::Nothing
    hybrid_phylogeny.isrooted = rooted
    return nothing
end

function _new_hybrid_node(
        id::Int,
        leaf::Bool,
        hybrid::Bool,
        label::AbstractString,
    )::PhyloNetworks.Node
    current_node = PhyloNetworks.Node(id, leaf, hybrid)
    _set_hybrid_node_label!(current_node, label)
    return current_node
end

function _new_hybrid_edge(
        id::Int,
        parent::PhyloNetworks.Node,
        child::PhyloNetworks.Node,
        length::Union{Missing, Float64},
        gamma::Union{Missing, Float64},
        hybrid::Bool,
        major::Bool,
    )::PhyloNetworks.Edge
    stored_length = ismissing(length) ? -1.0 : length
    stored_gamma = ismissing(gamma) ? -1.0 : gamma
    current_edge = PhyloNetworks.Edge(
        id,
        stored_length,
        hybrid,
        stored_gamma,
        PhyloNetworks.Node[child, parent],
    )
    _set_hybrid_edge_major!(current_edge, major)
    return current_edge
end

function _new_hybrid_network(
        network_nodes::Vector{PhyloNetworks.Node},
        network_edges::Vector{PhyloNetworks.Edge},
    )::PhyloNetworks.HybridNetwork
    return PhyloNetworks.HybridNetwork(network_nodes, network_edges)
end
