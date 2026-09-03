node_count(phylogeny::AbstractPhylogeny)::Int = length(nodes(phylogeny))
edge_count(phylogeny::AbstractPhylogeny)::Int = length(edges(phylogeny))
taxon_count(phylogeny::AbstractPhylogeny)::Int = count(current_node -> is_leaf(phylogeny, current_node), nodes(phylogeny))

function nodes(
        phylogeny::LineageNetwork{TNodeData},
    )::Vector{LineageNode{TNodeData}} where {TNodeData}
    return phylogeny.nodes
end

function edges(
        phylogeny::LineageNetwork{TNodeData, TEdgeData},
    )::Vector{LineageEdge{TEdgeData}} where {TNodeData, TEdgeData}
    return phylogeny.edges
end
node(phylogeny::AbstractPhylogeny, index::Integer) = nodes(phylogeny)[index]
edge(phylogeny::AbstractPhylogeny, index::Integer) = edges(phylogeny)[index]

root_index(phylogeny::LineageNetwork)::Int = phylogeny.root_index
root(phylogeny::AbstractPhylogeny) = node(phylogeny, root_index(phylogeny))
is_rooted(phylogeny::LineageNetwork)::Bool = phylogeny.rooted

function node_index(phylogeny::LineageNetwork, current_node::LineageNode)::Int
    index = get(phylogeny.node_object_indices, current_node, 0)
    index > 0 || throw(ArgumentError("node $(current_node.id) is not part of the phylogeny"))
    return index
end

function edge_index(phylogeny::LineageNetwork, current_edge::LineageEdge)::Int
    index = get(phylogeny.edge_object_indices, current_edge, 0)
    index > 0 || throw(ArgumentError("edge $(current_edge.id) is not part of the phylogeny"))
    return index
end

function node(
        phylogeny::LineageNetwork{TNodeData},
        id::Integer,
        ::Val{:id},
    )::LineageNode{TNodeData} where {TNodeData}
    index = get(phylogeny.node_id_indices, Int(id), 0)
    index > 0 || throw(KeyError(id))
    return phylogeny.nodes[index]
end

function edge(
        phylogeny::LineageNetwork{TNodeData, TEdgeData},
        id::Integer,
        ::Val{:id},
    )::LineageEdge{TEdgeData} where {TNodeData, TEdgeData}
    index = get(phylogeny.edge_id_indices, Int(id), 0)
    index > 0 || throw(KeyError(id))
    return phylogeny.edges[index]
end

node_id(current_node::LineageNode)::Int = current_node.id
edge_id(current_edge::LineageEdge)::Int = current_edge.id
node_label(current_node::LineageNode)::String = current_node.label
node_data(current_node::LineageNode) = current_node.data
edge_data(current_edge::LineageEdge) = current_edge.data
phylogeny_data(phylogeny::LineageNetwork) = phylogeny.data

is_hybrid(current_node::LineageNode)::Bool = current_node.hybrid
is_hybrid(current_edge::LineageEdge)::Bool = current_edge.hybrid
is_major(current_edge::LineageEdge)::Bool = current_edge.major
branch_length(current_edge::LineageEdge)::OptionalPhylogenyFloat = current_edge.length
inheritance_probability(current_edge::LineageEdge)::OptionalPhylogenyFloat = current_edge.gamma

is_leaf(phylogeny::AbstractPhylogeny, current_node)::Bool =
    isempty(outgoing_edges(phylogeny, current_node))

function incoming_edges(phylogeny::LineageNetwork, current_node::LineageNode)
    index = node_index(phylogeny, current_node)
    return view(phylogeny.edges, phylogeny.incoming_edge_indices[index])
end

function outgoing_edges(phylogeny::LineageNetwork, current_node::LineageNode)
    index = node_index(phylogeny, current_node)
    return view(phylogeny.edges, phylogeny.outgoing_edge_indices[index])
end

function incident_edges(phylogeny::LineageNetwork, current_node::LineageNode)
    index = node_index(phylogeny, current_node)
    return view(phylogeny.edges, phylogeny.incident_edge_indices[index])
end

function parent_node(phylogeny::LineageNetwork, current_edge::LineageEdge)
    edge_index(phylogeny, current_edge)
    return phylogeny.nodes[current_edge.parent_index]
end

function child_node(phylogeny::LineageNetwork, current_edge::LineageEdge)
    edge_index(phylogeny, current_edge)
    return phylogeny.nodes[current_edge.child_index]
end

function parents(phylogeny::AbstractPhylogeny, current_node)::Vector
    return [parent_node(phylogeny, current_edge) for current_edge in incoming_edges(phylogeny, current_node)]
end

function children(phylogeny::AbstractPhylogeny, current_node)::Vector
    return [child_node(phylogeny, current_edge) for current_edge in outgoing_edges(phylogeny, current_node)]
end

function major_parent_edge(phylogeny::AbstractPhylogeny, current_node)
    for current_edge in incoming_edges(phylogeny, current_node)
        is_major(current_edge) && return current_edge
    end
    throw(ArgumentError("node $(node_id(current_node)) has no major parent edge"))
end

function tip_labels(phylogeny::AbstractPhylogeny)::Vector{String}
    return String[
        node_label(current_node) for current_node in nodes(phylogeny)
            if is_leaf(phylogeny, current_node)
    ]
end

function is_tree(phylogeny::AbstractPhylogeny)::Bool
    all(current_node -> !is_hybrid(current_node), nodes(phylogeny)) || return false
    all(current_edge -> !is_hybrid(current_edge), edges(phylogeny)) || return false
    for current_node in nodes(phylogeny)
        current_node === root(phylogeny) && continue
        length(incoming_edges(phylogeny, current_node)) == 1 || return false
    end
    return true
end
