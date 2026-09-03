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
    geometry::PhylogenyGeometry
    extent::PlotExtent
    annotations::AnnotationTables
end

function _validate_node_data(
        phylogeny::AbstractPhylogeny,
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
        missing_nodes = setdiff(
            nodelabel[!, 1],
            [node_id(current_node) for current_node in nodes(phylogeny)],
        )
        if !isempty(missing_nodes)
            message =
                "Some node numbers in the nodelabel data frame are not found in the phylogeny:\n"
            for node_number in missing_nodes
                message *= string(" ", node_number)
            end
            @warn message
        end
    end
    return labelnodes, nodelabel
end

function _prepare_node_annotation_data(
        phylogeny::AbstractPhylogeny,
        nodelabel::DataFrames.AbstractDataFrame,
        shownodenumber::Bool,
        shownodelabel::Bool,
        labelnodes::Bool,
        geometry::PhylogenyGeometry,
    )::DataFrames.DataFrame
    row_count = if shownodenumber || shownodelabel || labelnodes
        node_count(phylogeny)
    else
        taxon_count(phylogeny)
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
    for (current_node_index, current_node) in enumerate(nodes(phylogeny))
        if is_leaf(phylogeny, current_node) || shownodenumber || shownodelabel || labelnodes
            node_data[row_index, :name] = node_label(current_node)
            node_data[row_index, :num] = string(node_id(current_node))
            if labelnodes
                label_index = findfirst(isequal(node_id(current_node)), nodelabel[!, 1])
                node_data[row_index, :lab] =
                    isnothing(label_index) ? "" : _format_sig3(nodelabel[label_index, 2])
            end
            node_data[row_index, :lea] = is_leaf(phylogeny, current_node)
            node_data[row_index, :x] = geometry.node_x[current_node_index]
            node_data[row_index, :y] = geometry.node_y[current_node_index]
            row_index += 1
        end
    end
    return node_data
end

function _prepare_edge_annotation_data(
        phylogeny::AbstractPhylogeny,
        edgelabel::DataFrames.AbstractDataFrame,
        style::Symbol,
        geometry::PhylogenyGeometry,
    )::Tuple{Bool, DataFrames.DataFrame}
    edge_total = edge_count(phylogeny)
    edge_data = DataFrames.DataFrame(
        :len => Vector{String}(undef, edge_total),
        :gam => Vector{String}(undef, edge_total),
        :num => Vector{String}(undef, edge_total),
        :lab => fill(""::String, edge_total),
        :hyb => Vector{Bool}(undef, edge_total),
        :min => Vector{Bool}(undef, edge_total),
        :x => Vector{Float64}(undef, edge_total),
        :y => Vector{Float64}(undef, edge_total);
        copycols = false,
    )

    annotation_positions = compute_edge_annotation_positions(phylogeny, style, geometry)

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
        missing_edges = setdiff(
            edgelabel[!, 1],
            [edge_id(current_edge) for current_edge in edges(phylogeny)],
        )
        if !isempty(missing_edges)
            message =
                "Some edge numbers in the edgelabel data frame are not found in the phylogeny:\n"
            for edge_number in missing_edges
                message *= string(" ", edge_number)
            end
            @warn message
        end
    end

    for (current_edge_index, current_edge) in enumerate(edges(phylogeny))
        edge_data[current_edge_index, :len] = _format_sig3(branch_length(current_edge))
        edge_data[current_edge_index, :gam] =
            _format_sig3(inheritance_probability(current_edge))
        edge_data[current_edge_index, :num] = string(edge_id(current_edge))
        if labeledges
            label_index = findfirst(isequal(edge_id(current_edge)), edgelabel[!, 1])
            edge_data[current_edge_index, :lab] =
                isnothing(label_index) ? "" : _format_sig3(edgelabel[label_index, 2])
        end
        edge_data[current_edge_index, :hyb] = is_hybrid(current_edge)
        edge_data[current_edge_index, :min] = !is_major(current_edge)
        edge_data[current_edge_index, :x] = annotation_positions[current_edge_index][1]
        edge_data[current_edge_index, :y] = annotation_positions[current_edge_index][2]
    end
    return labeledges, edge_data
end

function compute_edge_annotation_positions(
        phylogeny::AbstractPhylogeny,
        style::Symbol,
        geometry::PhylogenyGeometry,
    )::Vector{Makie.Point2f}
    positions = Vector{Makie.Point2f}(undef, edge_count(phylogeny))
    minor_edge_index = 1
    for (current_edge_index, current_edge) in enumerate(edges(phylogeny))
        x = (geometry.edge_x_lo[current_edge_index] + geometry.edge_x_hi[current_edge_index]) / 2
        y = (geometry.edge_y_lo[current_edge_index] + geometry.edge_y_hi[current_edge_index]) / 2
        if style === :majortree && !is_major(current_edge)
            x = (geometry.arrow_x_lo[minor_edge_index] + geometry.arrow_x_hi[minor_edge_index]) / 2
            y = (geometry.arrow_y_lo[minor_edge_index] + geometry.arrow_y_hi[minor_edge_index]) / 2
            minor_edge_index += 1
        end
        positions[current_edge_index] = Makie.Point2f(x, y)
    end
    return positions
end

function _resolve_plot_extent(
        config::PhyloPlotConfig,
        geometry::PhylogenyGeometry,
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
        prepared_phylogeny::PreparedPhylogeny,
        config::PhyloPlotConfig,
        geometry::PhylogenyGeometry,
    )::LayoutComputation
    phylogeny = prepared_phylogeny.phylogeny
    labelnodes, nodelabel = _validate_node_data(phylogeny, config.nodelabel)
    node_data = _prepare_node_annotation_data(
        phylogeny,
        nodelabel,
        config.shownodenumber,
        config.shownodelabel,
        labelnodes,
        geometry,
    )
    labeledges, edge_data = _prepare_edge_annotation_data(
        phylogeny,
        config.edgelabel,
        config.style,
        geometry,
    )
    extent = _resolve_plot_extent(config, geometry, labelnodes)
    annotations = AnnotationTables(labelnodes, labeledges, node_data, edge_data)
    return LayoutComputation(geometry, extent, annotations)
end
