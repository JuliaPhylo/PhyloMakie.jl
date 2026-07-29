struct PlotNetwork{TNet}
    net::TNet
end

struct NetworkGeometry
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

function prepare_plot_network(
        net::PhyloNetworks.HybridNetwork,
    )::PlotNetwork{PhyloNetworks.HybridNetwork}
    prepared = deepcopy(net)
    _prepare_traversal!(prepared)
    return PlotNetwork(prepared)
end

function _resolve_edge_lengths(
        net::PhyloNetworks.HybridNetwork,
        useedgelength::Bool,
    )::Tuple{Bool, Vector{Float64}}
    calculate_edge_lengths = !useedgelength
    if useedgelength
        all_edge_lengths_missing = true
        no_edge_lengths_missing = true
        for edge in getedges(net)
            if no_edge_lengths_missing && ismissing(elength(edge))
                no_edge_lengths_missing = false
            end
            if all_edge_lengths_missing && !ismissing(elength(edge))
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
        node_age = zeros(Float64, numnodes(net))
        for preorder_index in numnodes(net):-1:1
            current_node = getnode_preorder(net, preorder_index)
            isleaf(current_node) && continue
            node_index = _node_index(net, current_node)
            for edge in current_node.edge
                if isparentof(current_node, edge)
                    child_index = _node_index(net, getchild(edge))
                    node_age[node_index] = max(node_age[node_index], 1 + node_age[child_index])
                end
            end
        end
        for preorder_index in 2:numnodes(net)
            current_node = getnode_preorder(net, preorder_index)
            node_index = _node_index(net, current_node)
            major_parent_edge = getmajorparentedge(current_node)
            edge_index = _edge_index(net, major_parent_edge)
            parent_index = _node_index(net, getparent(getedge(net, edge_index)))
            edge_lengths[edge_index] = node_age[parent_index] - node_age[node_index]
        end
    else
        for edge in getedges(net)
            len = elength(edge)
            push!(edge_lengths, ismissing(len) ? 1.0 : len)
        end
    end
    return calculate_edge_lengths, edge_lengths
end

function compute_network_geometry(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
    )::NetworkGeometry
    net = plot_network.net
    usedirecthybridline = config.style == :majortree

    ymin = 1.0
    ymax = Float64(numtaxa(net))
    if !usedirecthybridline
        ymax += sum(!ismajor(edge) for edge in getedges(net))
    end

    node_y = zeros(Float64, numnodes(net))
    node_y_lo = zeros(Float64, numnodes(net))
    node_y_hi = zeros(Float64, numnodes(net))
    edge_y_lo = zeros(Float64, net.numedges)

    nexty = ymax
    cladewise_queue = copy(getroot(net).edge)
    while !isempty(cladewise_queue)
        current_edge = pop!(cladewise_queue)
        current_child = getchild(current_edge)
        if isleaf(current_child)
            node_index = _node_index(net, current_child)
            node_y[node_index] = nexty
            node_y_lo[node_index] = nexty
            node_y_hi[node_index] = nexty
            nexty -= 1
        end

        if !ismajor(current_edge) && !usedirecthybridline
            edge_y_lo[_edge_index(net, current_edge)] = nexty
            nexty -= 1
        end

        if ismajor(current_edge)
            for child_edge in current_child.edge
                if isparentof(current_child, child_edge)
                    push!(cladewise_queue, child_edge)
                end
            end
        end
    end

    for preorder_index in numnodes(net):-1:1
        current_node = getnode_preorder(net, preorder_index)
        isleaf(current_node) && continue
        node_index = _node_index(net, current_node)
        node_y_lo[node_index] = ymax
        node_y_hi[node_index] = ymin
        minor_y_lo = ymax
        minor_y_hi = ymin
        no_major_child = usedirecthybridline
        for edge in current_node.edge
            if isparentof(current_node, edge)
                if usedirecthybridline
                    if ismajor(edge)
                        child_index = _node_index(net, getchild(edge))
                        child_y = node_y[child_index]
                        no_major_child = false
                        node_y_lo[node_index] = min(node_y_lo[node_index], child_y)
                        node_y_hi[node_index] = max(node_y_hi[node_index], child_y)
                    elseif no_major_child
                        child_index = _node_index(net, getchild(edge))
                        child_y = node_y[child_index]
                        minor_y_lo = min(minor_y_lo, child_y)
                        minor_y_hi = max(minor_y_hi, child_y)
                    end
                else
                    child_y = if ismajor(edge)
                        child_index = _node_index(net, getchild(edge))
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

    _, edge_lengths = _resolve_edge_lengths(net, config.useedgelength)

    xmin = 1.0
    xmax = xmin
    node_x = zeros(Float64, numnodes(net))
    edge_x_lo = zeros(Float64, net.numedges)
    edge_x_hi = zeros(Float64, net.numedges)
    node_x[rootindex(net)] = xmin
    for preorder_index in 2:numnodes(net)
        current_node = getnode_preorder(net, preorder_index)
        node_index = _node_index(net, current_node)
        major_parent_edge = getmajorparentedge(current_node)
        edge_index = _edge_index(net, major_parent_edge)
        edge_y_lo[edge_index] = node_y[node_index]
        parent_index = _node_index(net, getparent(major_parent_edge))
        edge_x_lo[edge_index] = node_x[parent_index]
        edge_x_hi[edge_index] = edge_x_lo[edge_index] + edge_lengths[edge_index]
        node_x[node_index] = edge_x_hi[edge_index]
    end
    edge_y_hi = copy(edge_y_lo)

    arrow_x_lo = Float64[]
    arrow_x_hi = Float64[]
    arrow_y_lo = Float64[]
    arrow_y_hi = Float64[]
    for (edge_index, edge) in enumerate(getedges(net))
        ismajor(edge) && continue
        child_index = _node_index(net, getchild(edge))
        parent_index = _node_index(net, getparent(edge))

        edge_x_lo[edge_index] = node_x[parent_index]
        edge_x_hi[edge_index] = usedirecthybridline ?
            edge_x_lo[edge_index] :
            (
                config.useedgelength ?
                edge_x_lo[edge_index] + edge_lengths[edge_index] :
                node_x[child_index]
            )

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
    return NetworkGeometry(
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
