_format_sig3(v) = string(v) # default
_format_sig3(::Missing)::String = ""
function _format_sig3(value::Real)::String
    rounded_value = round(Float64(value); sigdigits = 3)
    if isinteger(rounded_value)
        return string(Int(rounded_value))
    end
    return string(rounded_value)
end

struct PlotExtent
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
    xlim_error_message::String
    ylim_error_message::String
end

struct AnnotationTables
    labelnodes::Bool
    labeledges::Bool
    node_data::DataFrames.DataFrame
    edge_data::DataFrames.DataFrame
end

struct LayoutComputation
    geometry::NetworkGeometry
    extent::PlotExtent
    annotations::AnnotationTables
end

function _validate_node_data(
        net::PhyloNetworks.HybridNetwork,
        nodelabel::DataFrames.DataFrame,
    )::Tuple{Bool, DataFrames.DataFrame}
    labelnodes = size(nodelabel, 1) > 0
    if labelnodes &&
            (size(nodelabel, 2) < 2 || !(nonmissingtype(eltype(nodelabel[!, 1])) <: Integer))
        @warn "nodelabel should have 2+ columns, the first one giving the node numbers (Integer)"
        labelnodes = false
    end
    if labelnodes
        nodelabel = filter(row -> !ismissing(row[1]), nodelabel)
        labelnodes = size(nodelabel, 1) > 0
    end
    if labelnodes
        missing_nodes = setdiff(nodelabel[!, 1], [uniqueid(node) for node in getnodes(net)])
        if !isempty(missing_nodes)
            message =
                "Some node numbers in the nodelabel data frame are not found in the network:\n"
            for node_number in missing_nodes
                message *= string(" ", node_number)
            end
            @warn message
        end
    end
    return labelnodes, nodelabel
end

function _prepare_node_annotation_data(
        net::PhyloNetworks.HybridNetwork,
        nodelabel::DataFrames.AbstractDataFrame,
        shownodenumber::Bool,
        shownodelabel::Bool,
        labelnodes::Bool,
        geometry::NetworkGeometry,
    )::DataFrames.DataFrame
    row_count = if shownodenumber || shownodelabel || labelnodes
        numnodes(net)
    else
        numtaxa(net)
    end
    node_data = DataFrames.DataFrame(
        :name => Vector{String}(undef, row_count),
        :num => Vector{String}(undef, row_count),
        :lab => fill(""::String, row_count),
        :lea => Vector{Bool}(undef, row_count),
        :x => Vector{Float64}(undef, row_count),
        :y => Vector{Float64}(undef, row_count);
        copycols = false,
    )

    row_index = 1
    for (node_index, current_node) in enumerate(getnodes(net))
        if isleaf(current_node) || shownodenumber || shownodelabel || labelnodes
            node_data[row_index, :name] = namelabel(current_node)
            node_data[row_index, :num] = string(uniqueid(current_node))
            if labelnodes
                label_index = findfirst(isequal(uniqueid(current_node)), nodelabel[!, 1])
                node_data[row_index, :lab] =
                    isnothing(label_index) ? "" : _format_sig3(nodelabel[label_index, 2])
            end
            node_data[row_index, :lea] = isleaf(current_node)
            node_data[row_index, :x] = geometry.node_x[node_index]
            node_data[row_index, :y] = geometry.node_y[node_index]
            row_index += 1
        end
    end
    return node_data
end

function _prepare_edge_annotation_data(
        net::PhyloNetworks.HybridNetwork,
        edgelabel::DataFrames.AbstractDataFrame,
        style::Symbol,
        geometry::NetworkGeometry,
    )::Tuple{Bool, DataFrames.DataFrame}
    edge_data = DataFrames.DataFrame(
        :len => Vector{String}(undef, net.numedges),
        :gam => Vector{String}(undef, net.numedges),
        :num => Vector{String}(undef, net.numedges),
        :lab => fill(""::String, net.numedges),
        :hyb => Vector{Bool}(undef, net.numedges),
        :min => Vector{Bool}(undef, net.numedges),
        :x => Vector{Float64}(undef, net.numedges),
        :y => Vector{Float64}(undef, net.numedges);
        copycols = false,
    )

    labeledges = size(edgelabel, 1) > 0
    if labeledges &&
            (size(edgelabel, 2) < 2 || !(nonmissingtype(eltype(edgelabel[!, 1])) <: Integer))
        @warn "edgelabel should have 2+ columns, the first one giving the edge numbers (Integer)"
        labeledges = false
    end
    if labeledges
        edgelabel = filter(row -> !ismissing(row[1]), edgelabel)
        labeledges = size(edgelabel, 1) > 0
    end
    if labeledges
        missing_edges = setdiff(edgelabel[!, 1], [uniqueid(edge) for edge in getedges(net)])
        if !isempty(missing_edges)
            message =
                "Some edge numbers in the edgelabel data frame are not found in the network:\n"
            for edge_number in missing_edges
                message *= string(" ", edge_number)
            end
            @warn message
        end
    end

    minor_edge_index = 1
    for (edge_index, current_edge) in enumerate(getedges(net))
        edge_data[edge_index, :len] = _format_sig3(elength(current_edge))
        edge_data[edge_index, :gam] = _format_sig3(egamma(current_edge))
        edge_data[edge_index, :num] = string(uniqueid(current_edge))
        if labeledges
            label_index = findfirst(isequal(uniqueid(current_edge)), edgelabel[!, 1])
            edge_data[edge_index, :lab] =
                isnothing(label_index) ? "" : _format_sig3(edgelabel[label_index, 2])
        end
        edge_data[edge_index, :hyb] = ishybrid(current_edge)
        edge_data[edge_index, :min] = !ismajor(current_edge)
        edge_data[edge_index, :x] =
            (geometry.edge_x_lo[edge_index] + geometry.edge_x_hi[edge_index]) / 2
        edge_data[edge_index, :y] =
            (geometry.edge_y_lo[edge_index] + geometry.edge_y_hi[edge_index]) / 2
        if style == :majortree && !ismajor(current_edge)
            edge_data[edge_index, :x] =
                (geometry.arrow_x_lo[minor_edge_index] + geometry.arrow_x_hi[minor_edge_index]) / 2
            edge_data[edge_index, :y] =
                (geometry.arrow_y_lo[minor_edge_index] + geometry.arrow_y_hi[minor_edge_index]) / 2
            minor_edge_index += 1
        end
    end
    return labeledges, edge_data
end

function _resolve_plot_extent(
        config::PhyloPlotConfig,
        geometry::NetworkGeometry,
        labelnodes::Bool,
    )::PlotExtent
    xmin = geometry.xmin
    xmax = geometry.xmax
    ymin = geometry.ymin
    ymax = geometry.ymax
    if config.showtiplabel ||
            config.shownodenumber ||
            config.shownodelabel ||
            labelnodes
        expansion_factor = 0.1
        y_expansion = 0.5
        xmin -= (xmax - xmin) * expansion_factor
        xmax += (xmax - xmin) * expansion_factor
        ymin -= y_expansion
        ymax += y_expansion
    end
    xmax += config.tipoffset
    xlim_error_message =
        "xlim needs to contain 2 values: lower and upper limits. defaults: [$xmin,$xmax]"
    ylim_error_message =
        "ylim needs to contain 2 values: lower and upper limits. defaults: [$ymin,$ymax]"
    return PlotExtent(xmin, xmax, ymin, ymax, xlim_error_message, ylim_error_message)
end

function compute_layout(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
        geometry::NetworkGeometry,
    )::LayoutComputation
    net = plot_network.net
    labelnodes, nodelabel = _validate_node_data(net, config.nodelabel)
    node_data = _prepare_node_annotation_data(
        net,
        nodelabel,
        config.shownodenumber,
        config.shownodelabel,
        labelnodes,
        geometry,
    )
    labeledges, edge_data = _prepare_edge_annotation_data(
        net,
        config.edgelabel,
        config.style,
        geometry,
    )
    extent = _resolve_plot_extent(config, geometry, labelnodes)
    annotations = AnnotationTables(labelnodes, labeledges, node_data, edge_data)
    return LayoutComputation(geometry, extent, annotations)
end
