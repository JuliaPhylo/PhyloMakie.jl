struct PreparedPhylogeny{TPhylogeny <: AbstractPhylogeny, TNode}
    phylogeny::TPhylogeny
    preorder::Vector{TNode}
end

struct PhylogenyGeometry
    edge_x_lo::Vector{Float64}
    edge_x_hi::Vector{Float64}
    edge_y_lo::Vector{Float64}
    edge_y_hi::Vector{Float64}
    node_x::Vector{Float64}
    node_y::Vector{Float64}
    node_y_lo::Vector{Float64}
    node_y_hi::Vector{Float64}
    arrow_x_lo::Vector{Float64}
    arrow_x_hi::Vector{Float64}
    arrow_y_lo::Vector{Float64}
    arrow_y_hi::Vector{Float64}
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
end

"""
    prepare_for_layout(phylogeny::AbstractPhylogeny) -> PreparedPhylogeny

Compute layout preparation state without copying or mutating the caller-owned
phylogeny. Concrete implementations participate through the `Phylogenies`
accessor and traversal interface.
"""
function prepare_for_layout(
        phylogeny::TPhylogeny,
    ) where {TPhylogeny <: AbstractPhylogeny}
    validate_phylogeny(phylogeny)
    ordered_nodes = preorder(phylogeny)
    return PreparedPhylogeny{TPhylogeny, eltype(ordered_nodes)}(phylogeny, ordered_nodes)
end

function _resolve_edge_lengths(
        prepared_phylogeny::PreparedPhylogeny,
        useedgelength::Bool,
    )::Tuple{Bool, Vector{Float64}}
    phylogeny = prepared_phylogeny.phylogeny
    calculate_edge_lengths = !useedgelength
    if useedgelength
        all_edge_lengths_missing = true
        no_edge_lengths_missing = true
        for current_edge in edges(phylogeny)
            if no_edge_lengths_missing && ismissing(branch_length(current_edge))
                no_edge_lengths_missing = false
            end
            if all_edge_lengths_missing && !ismissing(branch_length(current_edge))
                all_edge_lengths_missing = false
            end
        end
        if all_edge_lengths_missing
            println("All edge lengths are missing, won't be used for plotting.")
            calculate_edge_lengths = true
        end
        if !no_edge_lengths_missing && !all_edge_lengths_missing
            @warn "At least one non-missing edge length: plotting any missing length as 1.0"
        end
    end

    edge_lengths = Float64[]
    if calculate_edge_lengths
        edge_lengths = zeros(Float64, edge_count(phylogeny))
        node_age = zeros(Float64, node_count(phylogeny))
        for current_node in Iterators.reverse(prepared_phylogeny.preorder)
            is_leaf(phylogeny, current_node) && continue
            current_node_index = node_index(phylogeny, current_node)
            for current_edge in outgoing_edges(phylogeny, current_node)
                child_index = node_index(phylogeny, child_node(phylogeny, current_edge))
                node_age[current_node_index] =
                    max(node_age[current_node_index], 1 + node_age[child_index])
            end
        end
        for current_node in @view(prepared_phylogeny.preorder[2:end])
            current_node_index = node_index(phylogeny, current_node)
            parent_edge = major_parent_edge(phylogeny, current_node)
            current_edge_index = edge_index(phylogeny, parent_edge)
            parent_index = node_index(phylogeny, parent_node(phylogeny, parent_edge))
            edge_lengths[current_edge_index] =
                node_age[parent_index] - node_age[current_node_index]
        end
    else
        for current_edge in edges(phylogeny)
            length_value = branch_length(current_edge)
            push!(edge_lengths, ismissing(length_value) ? 1.0 : length_value)
        end
    end
    return calculate_edge_lengths, edge_lengths
end

function compute_phylogeny_geometry(
        prepared_phylogeny::PreparedPhylogeny,
        config::PhyloPlotConfig,
    )::PhylogenyGeometry
    phylogeny = prepared_phylogeny.phylogeny
    use_direct_hybrid_line = config.style == :majortree

    ymin = 1.0
    ymax = Float64(taxon_count(phylogeny))
    if !use_direct_hybrid_line
        ymax += sum(!is_major(current_edge) for current_edge in edges(phylogeny))
    end

    node_y = zeros(Float64, node_count(phylogeny))
    node_y_lo = zeros(Float64, node_count(phylogeny))
    node_y_hi = zeros(Float64, node_count(phylogeny))
    edge_y_lo = zeros(Float64, edge_count(phylogeny))

    next_y = ymax
    cladewise_queue = collect(outgoing_edges(phylogeny, root(phylogeny)))
    while !isempty(cladewise_queue)
        current_edge = pop!(cladewise_queue)
        current_child = child_node(phylogeny, current_edge)
        if is_leaf(phylogeny, current_child)
            current_node_index = node_index(phylogeny, current_child)
            node_y[current_node_index] = next_y
            node_y_lo[current_node_index] = next_y
            node_y_hi[current_node_index] = next_y
            next_y -= 1
        end

        if !is_major(current_edge) && !use_direct_hybrid_line
            edge_y_lo[edge_index(phylogeny, current_edge)] = next_y
            next_y -= 1
        end

        if is_major(current_edge)
            append!(cladewise_queue, outgoing_edges(phylogeny, current_child))
        end
    end

    for current_node in Iterators.reverse(prepared_phylogeny.preorder)
        is_leaf(phylogeny, current_node) && continue
        current_node_index = node_index(phylogeny, current_node)
        node_y_lo[current_node_index] = ymax
        node_y_hi[current_node_index] = ymin
        minor_y_lo = ymax
        minor_y_hi = ymin
        no_major_child = use_direct_hybrid_line
        for current_edge in outgoing_edges(phylogeny, current_node)
            if use_direct_hybrid_line
                if is_major(current_edge)
                    child_index = node_index(
                        phylogeny,
                        child_node(phylogeny, current_edge),
                    )
                    child_y = node_y[child_index]
                    no_major_child = false
                    node_y_lo[current_node_index] = min(node_y_lo[current_node_index], child_y)
                    node_y_hi[current_node_index] = max(node_y_hi[current_node_index], child_y)
                elseif no_major_child
                    child_index = node_index(
                        phylogeny,
                        child_node(phylogeny, current_edge),
                    )
                    child_y = node_y[child_index]
                    minor_y_lo = min(minor_y_lo, child_y)
                    minor_y_hi = max(minor_y_hi, child_y)
                end
            else
                child_y = if is_major(current_edge)
                    child_index = node_index(
                        phylogeny,
                        child_node(phylogeny, current_edge),
                    )
                    node_y[child_index]
                else
                    edge_y_lo[edge_index(phylogeny, current_edge)]
                end
                node_y_lo[current_node_index] = min(node_y_lo[current_node_index], child_y)
                node_y_hi[current_node_index] = max(node_y_hi[current_node_index], child_y)
            end
        end
        if no_major_child
            if minor_y_lo == minor_y_hi
                minor_y_lo += minor_y_lo < (ymax + ymin) / 2 ? 0.1 : -0.1
                minor_y_hi = minor_y_lo
            end
            node_y_lo[current_node_index] = minor_y_lo
            node_y_hi[current_node_index] = minor_y_hi
        end
        node_y[current_node_index] =
            (node_y_lo[current_node_index] + node_y_hi[current_node_index]) / 2
        if no_major_child
            node_y_lo[current_node_index] = node_y[current_node_index]
            node_y_hi[current_node_index] = node_y[current_node_index]
        end
    end

    _, edge_lengths = _resolve_edge_lengths(prepared_phylogeny, config.useedgelength)

    xmin = 1.0
    node_x = zeros(Float64, node_count(phylogeny))
    edge_x_lo = zeros(Float64, edge_count(phylogeny))
    edge_x_hi = zeros(Float64, edge_count(phylogeny))
    node_x[root_index(phylogeny)] = xmin
    for current_node in @view(prepared_phylogeny.preorder[2:end])
        current_node_index = node_index(phylogeny, current_node)
        parent_edge = major_parent_edge(phylogeny, current_node)
        current_edge_index = edge_index(phylogeny, parent_edge)
        edge_y_lo[current_edge_index] = node_y[current_node_index]
        parent_index = node_index(phylogeny, parent_node(phylogeny, parent_edge))
        edge_x_lo[current_edge_index] = node_x[parent_index]
        edge_x_hi[current_edge_index] =
            edge_x_lo[current_edge_index] + edge_lengths[current_edge_index]
        node_x[current_node_index] = edge_x_hi[current_edge_index]
    end
    edge_y_hi = copy(edge_y_lo)

    arrow_x_lo = Float64[]
    arrow_x_hi = Float64[]
    arrow_y_lo = Float64[]
    arrow_y_hi = Float64[]
    for (current_edge_index, current_edge) in enumerate(edges(phylogeny))
        is_major(current_edge) && continue
        child_index = node_index(phylogeny, child_node(phylogeny, current_edge))
        parent_index = node_index(phylogeny, parent_node(phylogeny, current_edge))

        edge_x_lo[current_edge_index] = node_x[parent_index]
        edge_x_hi[current_edge_index] = use_direct_hybrid_line ?
            edge_x_lo[current_edge_index] :
            (
                config.useedgelength ?
                edge_x_lo[current_edge_index] + edge_lengths[current_edge_index] :
                node_x[child_index]
            )

        if use_direct_hybrid_line
            edge_y_lo[current_edge_index] = node_y[parent_index]
        end
        edge_y_hi[current_edge_index] = edge_y_lo[current_edge_index]

        push!(arrow_x_lo, edge_x_hi[current_edge_index])
        push!(arrow_y_lo, edge_y_hi[current_edge_index])
        push!(arrow_x_hi, node_x[child_index])
        push!(arrow_y_hi, node_y[child_index])
    end

    xmax = maximum(edge_x_hi; init = xmin)
    return PhylogenyGeometry(
        edge_x_lo,
        edge_x_hi,
        edge_y_lo,
        edge_y_hi,
        node_x,
        node_y,
        node_y_lo,
        node_y_hi,
        arrow_x_lo,
        arrow_x_hi,
        arrow_y_lo,
        arrow_y_hi,
        xmin,
        xmax,
        ymin,
        ymax,
    )
end
