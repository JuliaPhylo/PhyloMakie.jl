"""
    preorder(phylogeny) -> Vector

Return a topological preorder in which every parent precedes its children.
Sibling order follows the phylogeny's stored incident-edge order, matching the
cladewise ordering used when the graph was constructed.
"""
function preorder(phylogeny::AbstractPhylogeny)::Vector
    node_total = node_count(phylogeny)
    node_total == 0 && return collect(nodes(phylogeny))

    visited = falses(node_total)
    queued = falses(node_total)
    result = Vector{typeof(root(phylogeny))}()
    queue = [root(phylogeny)]
    queued[root_index(phylogeny)] = true

    while !isempty(queue)
        current_node = pop!(queue)
        current_index = node_index(phylogeny, current_node)
        visited[current_index] && continue
        all(parent -> visited[node_index(phylogeny, parent)], parents(phylogeny, current_node)) ||
            continue
        visited[current_index] = true
        push!(result, current_node)

        for current_edge in outgoing_edges(phylogeny, current_node)
            child = child_node(phylogeny, current_edge)
            child_index = node_index(phylogeny, child)
            if !visited[child_index] && !queued[child_index]
                if all(parent -> visited[node_index(phylogeny, parent)], parents(phylogeny, child))
                    push!(queue, child)
                    queued[child_index] = true
                end
            elseif !visited[child_index] &&
                    all(parent -> visited[node_index(phylogeny, parent)], parents(phylogeny, child))
                push!(queue, child)
            end
        end
    end

    length(result) == node_total || throw(
        PhylogenyValidationError(
            "phylogeny is cyclic, disconnected from its root, or contains an unreachable reticulation",
        ),
    )
    return result
end

"""
    postorder(phylogeny) -> Vector

Return the reverse of [`preorder`](@ref), suitable for bottom-up dynamic
programming when parent contributions are not needed before all children.
"""
postorder(phylogeny::AbstractPhylogeny)::Vector = reverse(preorder(phylogeny))
