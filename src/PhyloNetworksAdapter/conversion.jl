"""
    from_hybridnetwork(hybrid_phylogeny) -> LineageNetwork

Convert a PhyloNetworks `HybridNetwork` into the independent native model.
The input is never mutated. PhyloNetworks traversal caches, work arrays,
partitions, and scores are intentionally not copied.
"""
function from_hybridnetwork(
        hybrid_phylogeny::PhyloNetworks.HybridNetwork,
    )::LineageNetwork{Nothing, Nothing, Nothing}
    original_rooted = _hybrid_is_rooted(hybrid_phylogeny)
    directed = deepcopy(hybrid_phylogeny)
    PhyloNetworks.directedges!(directed)

    hybrid_nodes = _hybrid_nodes(directed)
    hybrid_edges = _hybrid_edges(directed)
    hybrid_node_indices = IdDict(
        current_node => index for (index, current_node) in enumerate(hybrid_nodes)
    )
    hybrid_edge_indices = IdDict(
        current_edge => index for (index, current_edge) in enumerate(hybrid_edges)
    )

    lineage_nodes = [
        LineageNode(
                _hybrid_node_id(current_node),
                _hybrid_node_label(current_node);
                hybrid = _hybrid_node_is_hybrid(current_node),
            ) for current_node in hybrid_nodes
    ]
    lineage_edges = [
        LineageEdge(
                _hybrid_edge_id(current_edge),
                hybrid_node_indices[_hybrid_edge_parent(current_edge)],
                hybrid_node_indices[_hybrid_edge_child(current_edge)];
                length = _hybrid_edge_length(current_edge),
                gamma = _hybrid_edge_gamma(current_edge),
                hybrid = _hybrid_edge_is_hybrid(current_edge),
                major = _hybrid_edge_is_major(current_edge),
            ) for current_edge in hybrid_edges
    ]
    incident_edge_order = Vector{Vector{Int}}(
        undef,
        length(hybrid_nodes),
    )
    for (node_index, current_node) in enumerate(hybrid_nodes)
        incident_edge_order[node_index] = Int[
            hybrid_edge_indices[current_edge]
                for current_edge in _hybrid_incident_edges(current_node)
        ]
    end

    return LineageNetwork(
        lineage_nodes,
        lineage_edges;
        root = _hybrid_root_index(directed),
        rooted = original_rooted,
        incident_edge_order,
    )
end

"""
    to_hybridnetwork(phylogeny) -> PhyloNetworks.HybridNetwork

Construct a fresh PhyloNetworks network from any phylogeny implementing the
native accessor interface. Derived PhyloNetworks state is rebuilt rather than
copied from the native model.
"""
function to_hybridnetwork(
        phylogeny::AbstractPhylogeny,
    )::PhyloNetworks.HybridNetwork
    validate_phylogeny(phylogeny)
    lineage_nodes = nodes(phylogeny)
    lineage_edges = edges(phylogeny)
    hybrid_nodes = PhyloNetworks.Node[
        _new_hybrid_node(
                node_id(current_node),
                is_leaf(phylogeny, current_node),
                is_hybrid(current_node),
                node_label(current_node),
            ) for current_node in lineage_nodes
    ]
    hybrid_edges = PhyloNetworks.Edge[
        _new_hybrid_edge(
                edge_id(current_edge),
                hybrid_nodes[node_index(phylogeny, parent_node(phylogeny, current_edge))],
                hybrid_nodes[node_index(phylogeny, child_node(phylogeny, current_edge))],
                branch_length(current_edge),
                inheritance_probability(current_edge),
                is_hybrid(current_edge),
                is_major(current_edge),
            ) for current_edge in lineage_edges
    ]

    for (lineage_node_index, current_node) in enumerate(lineage_nodes)
        hybrid_incident = PhyloNetworks.Edge[
            hybrid_edges[edge_index(phylogeny, current_edge)]
                for current_edge in incident_edges(phylogeny, current_node)
        ]
        _set_hybrid_node_edges!(hybrid_nodes[lineage_node_index], hybrid_incident)
    end

    hybrid_phylogeny = _new_hybrid_network(hybrid_nodes, hybrid_edges)
    _set_hybrid_root_index!(hybrid_phylogeny, root_index(phylogeny))
    _set_hybrid_names!(
        hybrid_phylogeny,
        String[node_label(current_node) for current_node in lineage_nodes if !isempty(node_label(current_node))],
    )
    PhyloNetworks.directedges!(hybrid_phylogeny)
    _set_hybrid_rooted!(hybrid_phylogeny, is_rooted(phylogeny))
    return hybrid_phylogeny
end

Base.convert(
    ::Type{LineageNetwork},
    hybrid_phylogeny::PhyloNetworks.HybridNetwork,
) = from_hybridnetwork(hybrid_phylogeny)

Base.convert(
    ::Type{PhyloNetworks.HybridNetwork},
    phylogeny::AbstractPhylogeny,
) = to_hybridnetwork(phylogeny)
