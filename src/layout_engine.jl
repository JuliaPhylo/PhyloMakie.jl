import PhyloNetworks

struct PlotGeometry
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

function _node_index(
    net::PhyloNetworks.HybridNetwork,
    node::PhyloNetworks.Node,
)::Int
    node_index = findfirst(candidate -> candidate === node, net.node)
    isnothing(node_index) && error("node $(node.number) is not part of the network")
    return node_index
end

function _edge_index(
    net::PhyloNetworks.HybridNetwork,
    edge::PhyloNetworks.Edge,
)::Int
    edge_index = findfirst(candidate -> candidate === edge, net.edge)
    isnothing(edge_index) && error("edge $(edge.number) is not part of the network")
    return edge_index
end

function _prepare_traversal!(net::PhyloNetworks.HybridNetwork)::Nothing
    try
        PhyloNetworks.directedges!(net)
    catch err
        if err isa PhyloNetworks.RootMismatch
            throw(
                PhyloNetworks.RootMismatch(
                    err.msg *
                    "\nPlease change the root, perhaps using rootatnode! or rootatedge!",
                ),
            )
        end
        rethrow()
    end
    PhyloNetworks.preorder!(net)
    return nothing
end

function _resolve_edge_lengths(
    net::PhyloNetworks.HybridNetwork,
    useedgelength::Bool,
)::Tuple{Bool, Vector{Float64}}
    calculate_edge_lengths = !useedgelength
    if useedgelength
        all_edge_lengths_missing = true
        no_edge_lengths_missing = true
        for edge in net.edge
            if no_edge_lengths_missing && edge.length == -1.0
                no_edge_lengths_missing = false
            end
            if all_edge_lengths_missing && edge.length != -1.0
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
        edge_lengths = zeros(Float64, net.numedges)
        node_age = zeros(Float64, net.numnodes)
        for preorder_index in length(net.node):-1:1
            current_node = net.vec_node[preorder_index]
            current_node.leaf && continue
            node_index = _node_index(net, current_node)
            for edge in current_node.edge
                if current_node === PhyloNetworks.getparent(edge)
                    child_index = _node_index(net, PhyloNetworks.getchild(edge))
                    node_age[node_index] = max(node_age[node_index], 1 + node_age[child_index])
                end
            end
        end
        for preorder_index in 2:length(net.node)
            current_node = net.vec_node[preorder_index]
            node_index = _node_index(net, current_node)
            major_parent_edge_index = findfirst(
                edge -> edge.ismajor && current_node === PhyloNetworks.getchild(edge),
                current_node.edge,
            )
            isnothing(major_parent_edge_index) &&
                error("oops, could not find major parent edge of node number $node_index.")
            edge_index = _edge_index(net, current_node.edge[major_parent_edge_index])
            parent_index = _node_index(net, PhyloNetworks.getparent(net.edge[edge_index]))
            edge_lengths[edge_index] = node_age[parent_index] - node_age[node_index]
        end
    else
        for edge in net.edge
            push!(edge_lengths, edge.length == -1.0 ? 1.0 : edge.length)
        end
    end
    return calculate_edge_lengths, edge_lengths
end

function layout_plot_geometry(
    net::PhyloNetworks.HybridNetwork,
    spec::PlotKeywordSpec,
)::PlotGeometry
    usedirecthybridline = spec.layout.style == :majortree
    spec.layout.preorder && _prepare_traversal!(net)

    ymin = 1.0
    ymax = Float64(net.numtaxa)
    if !usedirecthybridline
        ymax += sum(!edge.ismajor for edge in net.edge)
    end

    node_y = zeros(Float64, net.numnodes)
    node_y_lo = zeros(Float64, net.numnodes)
    node_y_hi = zeros(Float64, net.numnodes)
    edge_y_lo = zeros(Float64, net.numedges)

    nexty = ymax
    cladewise_queue = copy(PhyloNetworks.getroot(net).edge)
    while !isempty(cladewise_queue)
        current_edge = pop!(cladewise_queue)
        current_child = PhyloNetworks.getchild(current_edge)
        if current_child.leaf
            node_index = _node_index(net, current_child)
            node_y[node_index] = nexty
            node_y_lo[node_index] = nexty
            node_y_hi[node_index] = nexty
            nexty -= 1
        end

        if !current_edge.ismajor && !usedirecthybridline
            edge_y_lo[_edge_index(net, current_edge)] = nexty
            nexty -= 1
        end

        if current_edge.ismajor
            for child_edge in current_child.edge
                if PhyloNetworks.getparent(child_edge) === current_child
                    push!(cladewise_queue, child_edge)
                end
            end
        end
    end

    for preorder_index in length(net.node):-1:1
        current_node = net.vec_node[preorder_index]
        current_node.leaf && continue
        node_index = _node_index(net, current_node)
        node_y_lo[node_index] = ymax
        node_y_hi[node_index] = ymin
        minor_y_lo = ymax
        minor_y_hi = ymin
        no_major_child = usedirecthybridline
        for edge in current_node.edge
            if current_node === PhyloNetworks.getparent(edge)
                if usedirecthybridline
                    if edge.ismajor || no_major_child
                        child_index = _node_index(net, PhyloNetworks.getchild(edge))
                        child_y = node_y[child_index]
                    end
                    if edge.ismajor
                        no_major_child = false
                        node_y_lo[node_index] = min(node_y_lo[node_index], child_y)
                        node_y_hi[node_index] = max(node_y_hi[node_index], child_y)
                    elseif no_major_child
                        minor_y_lo = min(minor_y_lo, child_y)
                        minor_y_hi = max(minor_y_hi, child_y)
                    end
                else
                    child_y = if edge.ismajor
                        child_index = _node_index(net, PhyloNetworks.getchild(edge))
                        node_y[child_index]
                    else
                        edge_y_lo[_edge_index(net, edge)]
                    end
                    node_y_lo[node_index] = min(node_y_lo[node_index], child_y)
                    node_y_hi[node_index] = max(node_y_hi[node_index], child_y)
                end
            end
        end
        if no_major_child
            if minor_y_lo == minor_y_hi
                minor_y_lo += minor_y_lo < (ymax + ymin) / 2 ? 0.1 : -0.1
                minor_y_hi = minor_y_lo
            end
            node_y_lo[node_index] = minor_y_lo
            node_y_hi[node_index] = minor_y_hi
        end
        node_y[node_index] = (node_y_lo[node_index] + node_y_hi[node_index]) / 2
        if no_major_child
            node_y_lo[node_index] = node_y[node_index]
            node_y_hi[node_index] = node_y[node_index]
        end
    end

    _, edge_lengths = _resolve_edge_lengths(net, spec.layout.useedgelength)

    xmin = 1.0
    xmax = xmin
    node_x = zeros(Float64, net.numnodes)
    edge_x_lo = zeros(Float64, net.numedges)
    edge_x_hi = zeros(Float64, net.numedges)
    node_x[net.rooti] = xmin
    for preorder_index in 2:length(net.node)
        current_node = net.vec_node[preorder_index]
        node_index = _node_index(net, current_node)
        major_parent_edge = findfirst(
            edge -> edge.ismajor && current_node === PhyloNetworks.getchild(edge),
            current_node.edge,
        )
        isnothing(major_parent_edge) &&
            error("oops, could not find major parent edge of node number $node_index.")
        edge_index = _edge_index(net, current_node.edge[major_parent_edge])
        edge_y_lo[edge_index] = node_y[node_index]
        parent_index = _node_index(net, PhyloNetworks.getparent(net.edge[edge_index]))
        edge_x_lo[edge_index] = node_x[parent_index]
        edge_x_hi[edge_index] = edge_x_lo[edge_index] + edge_lengths[edge_index]
        node_x[node_index] = edge_x_hi[edge_index]
    end
    edge_y_hi = copy(edge_y_lo)

    arrow_x_lo = Float64[]
    arrow_x_hi = Float64[]
    arrow_y_lo = Float64[]
    arrow_y_hi = Float64[]
    for edge_index in 1:net.numedges
        edge = net.edge[edge_index]
        edge.ismajor && continue
        child_index = _node_index(net, PhyloNetworks.getchild(edge))
        parent_index = _node_index(net, PhyloNetworks.getparent(edge))

        edge_x_lo[edge_index] = node_x[parent_index]
        edge_x_hi[edge_index] = usedirecthybridline ?
            edge_x_lo[edge_index] :
            (spec.layout.useedgelength ? edge_x_lo[edge_index] + edge_lengths[edge_index] : node_x[child_index])

        if usedirecthybridline
            edge_y_lo[edge_index] = node_y[parent_index]
        end
        edge_y_hi[edge_index] = edge_y_lo[edge_index]

        push!(arrow_x_lo, edge_x_hi[edge_index])
        push!(arrow_y_lo, edge_y_hi[edge_index])
        push!(arrow_x_hi, node_x[child_index])
        push!(arrow_y_hi, node_y[child_index])
    end

    xmax = max(xmax, edge_x_hi...)
    return PlotGeometry(
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
