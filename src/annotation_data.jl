import DataFrames
import PhyloNetworks

function _format_sig3(value::Real)::String
    rounded_value = round(Float64(value); sigdigits = 3)
    if isinteger(rounded_value)
        return string(Int(rounded_value))
    end
    return string(rounded_value)
end

struct PlotBounds
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
    xlim_error_message::String
    ylim_error_message::String
end

struct PlotAnnotationData
    labelnodes::Bool
    labeledges::Bool
    node_data::DataFrames.DataFrame
    edge_data::DataFrames.DataFrame
end

struct PlotLayout
    geometry::PlotGeometry
    bounds::PlotBounds
    annotations::PlotAnnotationData
end

function _format_annotation_value(
        table::DataFrames.AbstractDataFrame,
        row_index::Int,
    )::String
    if ismissing(table[row_index, 2])
        return ""
    end
    if nonmissingtype(eltype(table[!, 2])) <: AbstractFloat
        return _format_sig3(table[row_index, 2])
    end
    return string(table[row_index, 2])
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
        missing_nodes = setdiff(nodelabel[!, 1], [node.number for node in net.node])
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
        geometry::PlotGeometry,
    )::DataFrames.DataFrame
    row_count = if shownodenumber || shownodelabel || labelnodes
        net.numnodes
    else
        net.numtaxa
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
    for node_index in 1:net.numnodes
        current_node = net.node[node_index]
        if current_node.leaf || shownodenumber || shownodelabel || labelnodes
            node_data[row_index, :name] = current_node.name
            node_data[row_index, :num] = string(current_node.number)
            if labelnodes
                label_index = findfirst(isequal(current_node.number), nodelabel[!, 1])
                node_data[row_index, :lab] =
                    isnothing(label_index) ? "" : _format_annotation_value(nodelabel, label_index)
            end
            node_data[row_index, :lea] = current_node.leaf
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
        geometry::PlotGeometry,
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
        missing_edges = setdiff(edgelabel[!, 1], [edge.number for edge in net.edge])
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
    for edge_index in eachindex(net.edge)
        current_edge = net.edge[edge_index]
        edge_data[edge_index, :len] =
            current_edge.length == -1.0 ? "" : _format_sig3(current_edge.length)
        edge_data[edge_index, :gam] =
            current_edge.gamma == -1.0 ? "" : _format_sig3(current_edge.gamma)
        edge_data[edge_index, :num] = string(current_edge.number)
        if labeledges
            label_index = findfirst(isequal(current_edge.number), edgelabel[!, 1])
            edge_data[edge_index, :lab] =
                isnothing(label_index) ? "" : _format_annotation_value(edgelabel, label_index)
        end
        edge_data[edge_index, :hyb] = current_edge.hybrid
        edge_data[edge_index, :min] = !current_edge.ismajor
        edge_data[edge_index, :x] =
            (geometry.edge_x_lo[edge_index] + geometry.edge_x_hi[edge_index]) / 2
        edge_data[edge_index, :y] =
            (geometry.edge_y_lo[edge_index] + geometry.edge_y_hi[edge_index]) / 2
        if style == :majortree && !current_edge.ismajor
            edge_data[edge_index, :x] =
                (geometry.arrow_x_lo[minor_edge_index] + geometry.arrow_x_hi[minor_edge_index]) / 2
            edge_data[edge_index, :y] =
                (geometry.arrow_y_lo[minor_edge_index] + geometry.arrow_y_hi[minor_edge_index]) / 2
            minor_edge_index += 1
        end
    end
    return labeledges, edge_data
end

function _resolve_plot_bounds(
        attributes::PhyloPlotAttributes,
        geometry::PlotGeometry,
        labelnodes::Bool,
    )::PlotBounds
    xmin = geometry.xmin
    xmax = geometry.xmax
    ymin = geometry.ymin
    ymax = geometry.ymax
    if attributes.showtiplabel ||
            attributes.shownodenumber ||
            attributes.shownodelabel ||
            labelnodes
        expansion_factor = 0.1
        y_expansion = 0.5
        xmin -= (xmax - xmin) * expansion_factor
        xmax += (xmax - xmin) * expansion_factor
        ymin -= y_expansion
        ymax += y_expansion
    end
    xmax += attributes.tipoffset
    xlim_error_message =
        "xlim needs to contain 2 values: lower and upper limits. defaults: [$xmin,$xmax]"
    ylim_error_message =
        "ylim needs to contain 2 values: lower and upper limits. defaults: [$ymin,$ymax]"
    return PlotBounds(xmin, xmax, ymin, ymax, xlim_error_message, ylim_error_message)
end

function prepare_plot_layout(
        net::PhyloNetworks.HybridNetwork,
        attributes::PhyloPlotAttributes;
        preorder::Bool = true,
    )::PlotLayout
    geometry = layout_plot_geometry(net, attributes; preorder = preorder)
    labelnodes, nodelabel = _validate_node_data(net, attributes.nodelabel)
    node_data = _prepare_node_annotation_data(
        net,
        nodelabel,
        attributes.shownodenumber,
        attributes.shownodelabel,
        labelnodes,
        geometry,
    )
    labeledges, edge_data = _prepare_edge_annotation_data(
        net,
        attributes.edgelabel,
        attributes.style,
        geometry,
    )
    bounds = _resolve_plot_bounds(attributes, geometry, labelnodes)
    annotations = PlotAnnotationData(labelnodes, labeledges, node_data, edge_data)
    return PlotLayout(geometry, bounds, annotations)
end
