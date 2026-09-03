"""
    AbstractPhylogeny

Common supertype for native and third-party phylogeny representations that
implement the `Phylogenies` accessor interface.

An implementation supplies `nodes`, `edges`, `root_index`, `is_rooted`,
`node_index`, `edge_index`, `incoming_edges`, `outgoing_edges`,
`incident_edges`, `parent_node`, `child_node`, and `validate_phylogeny` for its
container and element types, plus `phylogeny_data` when graph-level payloads
are supported. Its node type supplies `node_id`, `node_label`, `node_data`, and
`is_hybrid`; its edge type supplies `edge_id`, `edge_data`,
`branch_length`, `inheritance_probability`, `is_hybrid`, and `is_major`.
Generic traversal, classification, conversion, layout, and rendering build on
those operations. Extend the functions in this module rather than defining
same-named functions in a client module.
"""
abstract type AbstractPhylogeny end

"""
    AbstractPhylogeneticTree <: AbstractPhylogeny

Common supertype for phylogenies whose topology is guaranteed to be a tree.
Concrete subtypes implement the complete [`AbstractPhylogeny`](@ref) contract
and must reject or make unrepresentable nodes with multiple parents.
"""
abstract type AbstractPhylogeneticTree <: AbstractPhylogeny end

"""
    AbstractPhylogeneticNetwork <: AbstractPhylogeny

Common supertype for phylogenies that may contain reticulation events. Concrete
subtypes implement the complete [`AbstractPhylogeny`](@ref) contract and
represent major/minor parent-edge semantics for each reticulation.
"""
abstract type AbstractPhylogeneticNetwork <: AbstractPhylogeny end

"""
    LineageNode(id, label=""; hybrid=false, data=nothing)

A node owned by a [`LineageNetwork`](@ref). `id` is the stable external key;
the network's dense node index is an implementation detail. `data` is an
arbitrary, concretely typed payload shared by all nodes in a network.
"""
mutable struct LineageNode{TData}
    id::Int
    label::String
    hybrid::Bool
    data::TData
end

function LineageNode(
        id::Integer,
        label::AbstractString = "";
        hybrid::Bool = false,
        data = nothing,
    )::LineageNode{typeof(data)}
    return LineageNode{typeof(data)}(Int(id), String(label), hybrid, data)
end

const OptionalPhylogenyFloat = Union{Missing, Float64}

function _optional_float(value, name::AbstractString)::OptionalPhylogenyFloat
    ismissing(value) && return missing
    value isa Real || throw(ArgumentError("$name must be a real number or `missing`"))
    converted = Float64(value)
    isfinite(converted) || throw(ArgumentError("$name must be finite or `missing`"))
    return converted
end

"""
    LineageEdge(id, parent_index, child_index; kwargs...)

A directed edge owned by a [`LineageNetwork`](@ref). Endpoints are stored as
dense node indices for efficient traversal; use `parent_node` and `child_node`
instead of depending on those indices.
"""
mutable struct LineageEdge{TData}
    id::Int
    parent_index::Int
    child_index::Int
    length::OptionalPhylogenyFloat
    gamma::OptionalPhylogenyFloat
    hybrid::Bool
    major::Bool
    data::TData
end

function LineageEdge(
        id::Integer,
        parent_index::Integer,
        child_index::Integer;
        length = missing,
        gamma = missing,
        hybrid::Bool = false,
        major::Bool = true,
        data = nothing,
    )::LineageEdge{typeof(data)}
    return LineageEdge{typeof(data)}(
        Int(id),
        Int(parent_index),
        Int(child_index),
        _optional_float(length, "branch length"),
        _optional_float(gamma, "inheritance probability"),
        hybrid,
        major,
        data,
    )
end

"""
    LineageNetwork(nodes, edges; root, rooted=true, data=nothing)

An independent, directed phylogenetic-network representation. The structure
stores durable topology and biological metadata only. Traversal orders and
algorithm workspaces are computed on demand rather than cached in the model.

Node and edge identifiers are stable keys and must be unique. Endpoint indices,
adjacency vectors, and lookup dictionaries are internal acceleration data.
"""
mutable struct LineageNetwork{TNodeData, TEdgeData, TGraphData} <:
    AbstractPhylogeneticNetwork
    nodes::Vector{LineageNode{TNodeData}}
    edges::Vector{LineageEdge{TEdgeData}}
    root_index::Int
    rooted::Bool
    incident_edge_indices::Vector{Vector{Int}}
    incoming_edge_indices::Vector{Vector{Int}}
    outgoing_edge_indices::Vector{Vector{Int}}
    node_object_indices::IdDict{LineageNode{TNodeData}, Int}
    edge_object_indices::IdDict{LineageEdge{TEdgeData}, Int}
    node_id_indices::Dict{Int, Int}
    edge_id_indices::Dict{Int, Int}
    data::TGraphData
end

function _default_incident_edge_order(
        node_total::Int,
        network_edges::AbstractVector{<:LineageEdge},
    )::Vector{Vector{Int}}
    incident = [Int[] for _ in 1:node_total]
    for (edge_index, current_edge) in enumerate(network_edges)
        push!(incident[current_edge.parent_index], edge_index)
        current_edge.child_index == current_edge.parent_index ||
            push!(incident[current_edge.child_index], edge_index)
    end
    return incident
end

function _rebuild_topology_indices!(phylogeny::LineageNetwork)::Nothing
    empty!(phylogeny.node_object_indices)
    empty!(phylogeny.edge_object_indices)
    empty!(phylogeny.node_id_indices)
    empty!(phylogeny.edge_id_indices)

    for (index, current_node) in enumerate(phylogeny.nodes)
        phylogeny.node_object_indices[current_node] = index
        haskey(phylogeny.node_id_indices, current_node.id) && throw(
            ArgumentError("duplicate node identifier $(current_node.id)"),
        )
        phylogeny.node_id_indices[current_node.id] = index
    end
    for (index, current_edge) in enumerate(phylogeny.edges)
        phylogeny.edge_object_indices[current_edge] = index
        haskey(phylogeny.edge_id_indices, current_edge.id) && throw(
            ArgumentError("duplicate edge identifier $(current_edge.id)"),
        )
        phylogeny.edge_id_indices[current_edge.id] = index
    end

    phylogeny.incoming_edge_indices = [Int[] for _ in phylogeny.nodes]
    phylogeny.outgoing_edge_indices = [Int[] for _ in phylogeny.nodes]
    for node_index in eachindex(phylogeny.nodes)
        for current_edge_index in phylogeny.incident_edge_indices[node_index]
            current_edge = phylogeny.edges[current_edge_index]
            current_edge.parent_index == node_index &&
                push!(phylogeny.outgoing_edge_indices[node_index], current_edge_index)
            current_edge.child_index == node_index &&
                push!(phylogeny.incoming_edge_indices[node_index], current_edge_index)
        end
    end
    return nothing
end

function LineageNetwork(
        network_nodes::Vector{LineageNode{TNodeData}},
        network_edges::Vector{LineageEdge{TEdgeData}};
        root::Integer = isempty(network_nodes) ? 0 : 1,
        rooted::Bool = true,
        incident_edge_order = nothing,
        data = nothing,
        validate::Bool = true,
    )::LineageNetwork{TNodeData, TEdgeData, typeof(data)} where {TNodeData, TEdgeData}
    node_total = length(network_nodes)
    for current_edge in network_edges
        1 <= current_edge.parent_index <= node_total || throw(
            ArgumentError(
                "edge $(current_edge.id) parent index $(current_edge.parent_index) is out of bounds",
            ),
        )
        1 <= current_edge.child_index <= node_total || throw(
            ArgumentError(
                "edge $(current_edge.id) child index $(current_edge.child_index) is out of bounds",
            ),
        )
    end
    resolved_incident_order = if isnothing(incident_edge_order)
        _default_incident_edge_order(node_total, network_edges)
    else
        [Int[index for index in edge_indices] for edge_indices in incident_edge_order]
    end
    length(resolved_incident_order) == node_total || throw(
        ArgumentError("incident edge order must contain one vector per node"),
    )
    phylogeny = LineageNetwork{TNodeData, TEdgeData, typeof(data)}(
        copy(network_nodes),
        copy(network_edges),
        Int(root),
        rooted,
        resolved_incident_order,
        [Int[] for _ in network_nodes],
        [Int[] for _ in network_nodes],
        IdDict{LineageNode{TNodeData}, Int}(),
        IdDict{LineageEdge{TEdgeData}, Int}(),
        Dict{Int, Int}(),
        Dict{Int, Int}(),
        data,
    )
    _rebuild_topology_indices!(phylogeny)
    validate && validate_phylogeny(phylogeny)
    return phylogeny
end

function LineageNetwork(; data = nothing)::LineageNetwork{Nothing, Nothing, typeof(data)}
    return LineageNetwork(LineageNode{Nothing}[], LineageEdge{Nothing}[]; root = 0, data)
end

function Base.show(io::IO, phylogeny::LineageNetwork)::Nothing
    rooted_description = phylogeny.rooted ? "rooted" : "semidirected"
    print(
        io,
        "LineageNetwork($(node_count(phylogeny)) nodes, ",
        "$(edge_count(phylogeny)) edges, $(taxon_count(phylogeny)) tips, ",
        "$(count(current_node -> current_node.hybrid, phylogeny.nodes)) hybrid nodes, ",
        rooted_description,
        ")",
    )
    return nothing
end
