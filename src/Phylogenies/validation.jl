struct PhylogenyValidationError <: Exception
    message::String
end

Base.showerror(io::IO, error::PhylogenyValidationError) = print(io, error.message)

function _validation_error(message::AbstractString)
    throw(PhylogenyValidationError(String(message)))
end

"""
    validate_phylogeny(phylogeny) -> nothing

Validate identifier uniqueness, endpoint and adjacency consistency, root
placement, reticulation semantics, acyclicity, and root reachability.
"""
function validate_phylogeny(phylogeny::LineageNetwork)::Nothing
    node_total = node_count(phylogeny)
    edge_total = edge_count(phylogeny)
    if node_total == 0
        phylogeny.root_index == 0 || _validation_error("an empty phylogeny must use root index 0")
        edge_total == 0 || _validation_error("an empty phylogeny cannot contain edges")
        return nothing
    end
    1 <= phylogeny.root_index <= node_total || _validation_error("root index is out of bounds")

    node_identifiers = node_id.(nodes(phylogeny))
    length(unique(node_identifiers)) == node_total ||
        _validation_error("node identifiers must be unique")
    edge_identifiers = edge_id.(edges(phylogeny))
    length(unique(edge_identifiers)) == edge_total ||
        _validation_error("edge identifiers must be unique")
    for (current_node_index, current_node) in enumerate(nodes(phylogeny))
        get(phylogeny.node_object_indices, current_node, 0) == current_node_index ||
            _validation_error("node object index is inconsistent")
        get(phylogeny.node_id_indices, node_id(current_node), 0) == current_node_index ||
            _validation_error("node identifier index is inconsistent")
    end
    for (current_edge_index, current_edge) in enumerate(edges(phylogeny))
        get(phylogeny.edge_object_indices, current_edge, 0) == current_edge_index ||
            _validation_error("edge object index is inconsistent")
        get(phylogeny.edge_id_indices, edge_id(current_edge), 0) == current_edge_index ||
            _validation_error("edge identifier index is inconsistent")
        1 <= current_edge.parent_index <= node_total ||
            _validation_error("edge $(edge_id(current_edge)) parent index is out of bounds")
        1 <= current_edge.child_index <= node_total ||
            _validation_error("edge $(edge_id(current_edge)) child index is out of bounds")
    end

    length(phylogeny.incident_edge_indices) == node_total ||
        _validation_error("incident adjacency does not match the node count")
    length(phylogeny.incoming_edge_indices) == node_total ||
        _validation_error("incoming adjacency does not match the node count")
    length(phylogeny.outgoing_edge_indices) == node_total ||
        _validation_error("outgoing adjacency does not match the node count")

    incident_counts = zeros(Int, edge_total)
    for (current_node_index, edge_indices) in enumerate(phylogeny.incident_edge_indices)
        length(unique(edge_indices)) == length(edge_indices) ||
            _validation_error("node adjacency contains a duplicate edge")
        for current_edge_index in edge_indices
            1 <= current_edge_index <= edge_total ||
                _validation_error("node adjacency contains an out-of-bounds edge index")
            current_edge = phylogeny.edges[current_edge_index]
            current_node_index in (current_edge.parent_index, current_edge.child_index) ||
                _validation_error("node adjacency contains a non-incident edge")
            incident_counts[current_edge_index] += 1
        end
    end
    for (current_edge_index, count) in enumerate(incident_counts)
        expected = phylogeny.edges[current_edge_index].parent_index ==
            phylogeny.edges[current_edge_index].child_index ? 1 : 2
        count == expected || _validation_error(
            "edge $(edge_id(phylogeny.edges[current_edge_index])) must occur in each endpoint adjacency exactly once",
        )
    end

    for current_node_index in eachindex(phylogeny.nodes)
        expected_incoming = Int[
            current_edge_index for current_edge_index in
                phylogeny.incident_edge_indices[current_node_index]
                if phylogeny.edges[current_edge_index].child_index == current_node_index
        ]
        expected_outgoing = Int[
            current_edge_index for current_edge_index in
                phylogeny.incident_edge_indices[current_node_index]
                if phylogeny.edges[current_edge_index].parent_index == current_node_index
        ]
        phylogeny.incoming_edge_indices[current_node_index] == expected_incoming ||
            _validation_error("incoming adjacency is inconsistent")
        phylogeny.outgoing_edge_indices[current_node_index] == expected_outgoing ||
            _validation_error("outgoing adjacency is inconsistent")
    end

    isempty(incoming_edges(phylogeny, root(phylogeny))) ||
        _validation_error("the root must not have incoming edges")
    is_hybrid(root(phylogeny)) && _validation_error("the root cannot be a hybrid node")

    for current_edge in edges(phylogeny)
        current_edge.parent_index != current_edge.child_index ||
            _validation_error("self-loop edge $(edge_id(current_edge)) is not allowed")
        if !ismissing(inheritance_probability(current_edge))
            gamma = inheritance_probability(current_edge)
            0.0 <= gamma <= 1.0 || _validation_error(
                "edge $(edge_id(current_edge)) inheritance probability must be between 0 and 1",
            )
        end
        !is_hybrid(current_edge) && !is_major(current_edge) && _validation_error(
            "tree edge $(edge_id(current_edge)) cannot be a minor edge",
        )
    end

    for current_node in nodes(phylogeny)
        incoming = incoming_edges(phylogeny, current_node)
        hybrid_incoming = count(is_hybrid, incoming)
        if is_hybrid(current_node)
            length(incoming) >= 2 || _validation_error(
                "hybrid node $(node_id(current_node)) must have at least two hybrid parent edges",
            )
            hybrid_incoming == length(incoming) || _validation_error(
                "every parent edge of hybrid node $(node_id(current_node)) must be hybrid",
            )
            count(is_major, incoming) == 1 || _validation_error(
                "hybrid node $(node_id(current_node)) must have exactly one major parent edge",
            )
        elseif current_node !== root(phylogeny)
            hybrid_incoming == 0 || _validation_error(
                "non-hybrid node $(node_id(current_node)) cannot have hybrid parent edges",
            )
            length(incoming) == 1 || _validation_error(
                "non-hybrid node $(node_id(current_node)) must have exactly one parent edge",
            )
        end
    end

    preorder(phylogeny)
    return nothing
end

function is_valid(phylogeny::AbstractPhylogeny)::Bool
    try
        validate_phylogeny(phylogeny)
        return true
    catch error
        error isa PhylogenyValidationError || rethrow()
        return false
    end
end
