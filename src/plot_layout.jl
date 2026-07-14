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

function PlotBounds(extent::PlotExtent)::PlotBounds
    return PlotBounds(
        extent.xmin,
        extent.xmax,
        extent.ymin,
        extent.ymax,
        extent.xlim_error_message,
        extent.ylim_error_message,
    )
end

function PlotExtent(bounds::PlotBounds)::PlotExtent
    return PlotExtent(
        bounds.xmin,
        bounds.xmax,
        bounds.ymin,
        bounds.ymax,
        bounds.xlim_error_message,
        bounds.ylim_error_message,
    )
end

function PlotAnnotationData(tables::AnnotationTables)::PlotAnnotationData
    return PlotAnnotationData(
        tables.labelnodes,
        tables.labeledges,
        tables.node_data,
        tables.edge_data,
    )
end

function AnnotationTables(data::PlotAnnotationData)::AnnotationTables
    return AnnotationTables(
        data.labelnodes,
        data.labeledges,
        data.node_data,
        data.edge_data,
    )
end

function PlotLayout(layout::LayoutComputation)::PlotLayout
    return PlotLayout(
        PlotGeometry(layout.geometry),
        PlotBounds(layout.extent),
        PlotAnnotationData(layout.annotations),
    )
end

function LayoutComputation(layout::PlotLayout)::LayoutComputation
    return LayoutComputation(
        NetworkGeometry(layout.geometry),
        PlotExtent(layout.bounds),
        AnnotationTables(layout.annotations),
    )
end

function prepare_plot_layout(
        net::PhyloNetworks.HybridNetwork,
        attributes::PhyloPlotAttributes;
        preorder::Bool = true,
    )::PlotLayout
    config = PhyloPlotConfig(attributes)
    plot_network = preorder ? prepare_plot_network(net) : PlotNetwork(net)
    geometry = compute_network_geometry(plot_network, config)
    return PlotLayout(compute_layout(plot_network, config, geometry))
end
