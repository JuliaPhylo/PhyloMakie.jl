function _next_node_id(phylogeny::LineageNetwork)::Int
    isempty(nodes(phylogeny)) && return 1
    return maximum(node_id, nodes(phylogeny)) + 1
end

function _next_edge_id(phylogeny::LineageNetwork)::Int
    isempty(edges(phylogeny)) && return 1
    return maximum(edge_id, edges(phylogeny)) + 1
end

function add_node!(
        phylogeny::LineageNetwork{TNodeData},
        label::AbstractString = "";
        id::Integer = _next_node_id(phylogeny),
        hybrid::Bool = false,
        data = nothing,
    ) where {TNodeData}
    data isa TNodeData || throw(
        ArgumentError("node data must have type $TNodeData for this phylogeny"),
    )
    haskey(phylogeny.node_id_indices, Int(id)) &&
        throw(ArgumentError("duplicate node identifier $(Int(id))"))
    current_node = LineageNode{TNodeData}(Int(id), String(label), hybrid, data)
    push!(phylogeny.nodes, current_node)
    push!(phylogeny.incident_edge_indices, Int[])
    push!(phylogeny.incoming_edge_indices, Int[])
    push!(phylogeny.outgoing_edge_indices, Int[])
    phylogeny.node_object_indices[current_node] = length(phylogeny.nodes)
    phylogeny.node_id_indices[current_node.id] = length(phylogeny.nodes)
    if phylogeny.root_index == 0
        phylogeny.root_index = 1
    end
    return current_node
end

function add_edge!(
        phylogeny::LineageNetwork{TNodeData, TEdgeData},
        parent::LineageNode{TNodeData},
        child::LineageNode{TNodeData};
        id::Integer = _next_edge_id(phylogeny),
        length = missing,
        gamma = missing,
        hybrid::Bool = false,
        major::Bool = true,
        data = nothing,
        validate::Bool = true,
    ) where {TNodeData, TEdgeData}
    data isa TEdgeData || throw(
        ArgumentError("edge data must have type $TEdgeData for this phylogeny"),
    )
    parent_index = node_index(phylogeny, parent)
    child_index = node_index(phylogeny, child)
    haskey(phylogeny.edge_id_indices, Int(id)) &&
        throw(ArgumentError("duplicate edge identifier $(Int(id))"))
    current_edge = LineageEdge{TEdgeData}(
        Int(id),
        parent_index,
        child_index,
        _optional_float(length, "branch length"),
        _optional_float(gamma, "inheritance probability"),
        hybrid,
        major,
        data,
    )
    push!(phylogeny.edges, current_edge)
    current_edge_index = Base.length(phylogeny.edges)
    push!(phylogeny.incident_edge_indices[parent_index], current_edge_index)
    push!(phylogeny.incident_edge_indices[child_index], current_edge_index)
    push!(phylogeny.outgoing_edge_indices[parent_index], current_edge_index)
    push!(phylogeny.incoming_edge_indices[child_index], current_edge_index)
    phylogeny.edge_object_indices[current_edge] = current_edge_index
    phylogeny.edge_id_indices[current_edge.id] = current_edge_index
    validate && validate_phylogeny(phylogeny)
    return current_edge
end

function rename_node!(current_node::LineageNode, label::AbstractString)
    current_node.label = String(label)
    return current_node
end

function set_branch_length!(current_edge::LineageEdge, value)
    current_edge.length = _optional_float(value, "branch length")
    return current_edge
end

function set_inheritance_probability!(current_edge::LineageEdge, value)
    resolved = _optional_float(value, "inheritance probability")
    if !ismissing(resolved)
        0.0 <= resolved <= 1.0 || throw(
            ArgumentError("inheritance probability must be between 0 and 1"),
        )
    end
    current_edge.gamma = resolved
    return current_edge
end

function set_major_edge!(
        phylogeny::LineageNetwork,
        current_edge::LineageEdge,
    )::LineageEdge
    is_hybrid(current_edge) || throw(ArgumentError("only hybrid edges have major/minor status"))
    child = child_node(phylogeny, current_edge)
    for parent_edge in incoming_edges(phylogeny, child)
        is_hybrid(parent_edge) && (parent_edge.major = parent_edge === current_edge)
    end
    validate_phylogeny(phylogeny)
    return current_edge
end

"""
    rotate_children!(phylogeny, node; ordered_edge_ids=Int[])

Change the stored order of `node`'s outgoing edges. With two children, or when
`ordered_edge_ids` is empty, the first two child edges are exchanged. For a
polytomy, provide every child edge identifier in the desired order.
"""
function rotate_children!(
        phylogeny::LineageNetwork,
        current_node::LineageNode;
        ordered_edge_ids::AbstractVector{<:Integer} = Int[],
    )::LineageNetwork
    current_node_index = node_index(phylogeny, current_node)
    incident_indices = phylogeny.incident_edge_indices[current_node_index]
    child_positions = findall(incident_indices) do current_edge_index
        return phylogeny.edges[current_edge_index].parent_index == current_node_index
    end

    if length(child_positions) < 2
        @warn "no edge to rotate: node $(node_id(current_node)) has $(length(child_positions)) child edge(s)"
        return phylogeny
    elseif length(child_positions) == 2 || isempty(ordered_edge_ids)
        first_position, second_position = child_positions[1:2]
        incident_indices[first_position], incident_indices[second_position] =
            incident_indices[second_position], incident_indices[first_position]
    else
        length(ordered_edge_ids) == length(child_positions) || throw(
            ArgumentError(
                "ordered_edge_ids must contain one identifier for each child edge",
            ),
        )
        length(unique(ordered_edge_ids)) == length(ordered_edge_ids) ||
            throw(ArgumentError("ordered_edge_ids must not contain duplicates"))
        child_indices_by_id = Dict(
            edge_id(phylogeny.edges[incident_indices[position]]) =>
                incident_indices[position] for position in child_positions
        )
        Set(Int.(ordered_edge_ids)) == Set(keys(child_indices_by_id)) || throw(
            ArgumentError(
                "ordered_edge_ids must identify exactly the child edges of node $(node_id(current_node))",
            ),
        )
        for (position, current_edge_id) in zip(child_positions, ordered_edge_ids)
            incident_indices[position] = child_indices_by_id[Int(current_edge_id)]
        end
    end

    _rebuild_topology_indices!(phylogeny)
    validate_phylogeny(phylogeny)
    return phylogeny
end

function rotate_children!(
        phylogeny::LineageNetwork,
        node_identifier::Integer;
        kwargs...,
    )::LineageNetwork
    return rotate_children!(
        phylogeny,
        node(phylogeny, node_identifier, Val(:id));
        kwargs...,
    )
end

function delete_edge!(
        phylogeny::LineageNetwork,
        current_edge::LineageEdge;
        validate::Bool = true,
    )::LineageNetwork
    removed_index = edge_index(phylogeny, current_edge)
    deleteat!(phylogeny.edges, removed_index)
    for edge_indices in phylogeny.incident_edge_indices
        filter!(index -> index != removed_index, edge_indices)
        for position in eachindex(edge_indices)
            edge_indices[position] > removed_index && (edge_indices[position] -= 1)
        end
    end
    _rebuild_topology_indices!(phylogeny)
    validate && validate_phylogeny(phylogeny)
    return phylogeny
end

function delete_node!(
        phylogeny::LineageNetwork,
        current_node::LineageNode;
        validate::Bool = true,
    )::LineageNetwork
    removed_index = node_index(phylogeny, current_node)
    isempty(incident_edges(phylogeny, current_node)) || throw(
        ArgumentError("delete incident edges before deleting node $(node_id(current_node))"),
    )
    removed_index == root_index(phylogeny) && node_count(phylogeny) > 1 && throw(
        ArgumentError("choose another root before deleting the root node"),
    )
    deleteat!(phylogeny.nodes, removed_index)
    deleteat!(phylogeny.incident_edge_indices, removed_index)
    for current_edge in phylogeny.edges
        current_edge.parent_index > removed_index && (current_edge.parent_index -= 1)
        current_edge.child_index > removed_index && (current_edge.child_index -= 1)
    end
    if isempty(phylogeny.nodes)
        phylogeny.root_index = 0
    elseif phylogeny.root_index > removed_index
        phylogeny.root_index -= 1
    end
    _rebuild_topology_indices!(phylogeny)
    validate && validate_phylogeny(phylogeny)
    return phylogeny
end

function _orient_from_root!(phylogeny::LineageNetwork, new_root_index::Int)::Nothing
    visited_edges = falses(edge_count(phylogeny))

    function visit(current_node_index::Int)::Nothing
        child_count = 0
        for current_edge_index in phylogeny.incident_edge_indices[current_node_index]
            visited_edges[current_edge_index] && continue
            current_edge = phylogeny.edges[current_edge_index]
            if is_hybrid(current_edge) && current_edge.child_index == current_node_index
                continue
            end
            visited_edges[current_edge_index] = true
            other_index = current_edge.parent_index == current_node_index ?
                current_edge.child_index : current_edge.parent_index
            current_edge.parent_index = current_node_index
            current_edge.child_index = other_index
            child_count += 1
            (!is_hybrid(current_edge) || is_major(current_edge)) && visit(other_index)
        end
        if child_count == 0 && !isempty(phylogeny.incident_edge_indices[current_node_index])
            current_node = phylogeny.nodes[current_node_index]
            current_node.hybrid || isempty(phylogeny.outgoing_edge_indices[current_node_index]) ||
                _validation_error("root placement leaves node $(node_id(current_node)) unreachable")
        end
        return nothing
    end

    visit(new_root_index)
    all(visited_edges) || _validation_error(
        "root placement conflicts with the fixed direction of one or more hybrid edges",
    )
    return nothing
end

"""
    reroot!(phylogeny, new_root)

Reorient tree edges away from `new_root` while preserving the direction of
hybrid parent edges. The operation is transactional: an inadmissible root
leaves the original phylogeny unchanged.
"""
function reroot!(
        phylogeny::LineageNetwork,
        new_root::LineageNode;
        rooted::Bool = true,
    )::LineageNetwork
    new_root_index = node_index(phylogeny, new_root)
    old_root_index = phylogeny.root_index
    old_rooted = phylogeny.rooted
    old_endpoints = [(current_edge.parent_index, current_edge.child_index) for current_edge in edges(phylogeny)]
    try
        phylogeny.root_index = new_root_index
        _orient_from_root!(phylogeny, new_root_index)
        _rebuild_topology_indices!(phylogeny)
        phylogeny.rooted = rooted
        validate_phylogeny(phylogeny)
    catch
        for (current_edge, (parent_index, child_index)) in zip(edges(phylogeny), old_endpoints)
            current_edge.parent_index = parent_index
            current_edge.child_index = child_index
        end
        phylogeny.root_index = old_root_index
        phylogeny.rooted = old_rooted
        _rebuild_topology_indices!(phylogeny)
        rethrow()
    end
    return phylogeny
end
