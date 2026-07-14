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

function PlotGeometry(geometry::NetworkGeometry)::PlotGeometry
    return PlotGeometry(
        geometry.edge_x_lo,
        geometry.edge_x_hi,
        geometry.edge_y_lo,
        geometry.edge_y_hi,
        geometry.node_x,
        geometry.node_y,
        geometry.node_y_lo,
        geometry.node_y_hi,
        geometry.arrow_x_lo,
        geometry.arrow_x_hi,
        geometry.arrow_y_lo,
        geometry.arrow_y_hi,
        geometry.xmin,
        geometry.xmax,
        geometry.ymin,
        geometry.ymax,
    )
end

function NetworkGeometry(geometry::PlotGeometry)::NetworkGeometry
    return NetworkGeometry(
        geometry.edge_x_lo,
        geometry.edge_x_hi,
        geometry.edge_y_lo,
        geometry.edge_y_hi,
        geometry.node_x,
        geometry.node_y,
        geometry.node_y_lo,
        geometry.node_y_hi,
        geometry.arrow_x_lo,
        geometry.arrow_x_hi,
        geometry.arrow_y_lo,
        geometry.arrow_y_hi,
        geometry.xmin,
        geometry.xmax,
        geometry.ymin,
        geometry.ymax,
    )
end

function layout_plot_geometry(
        net::PhyloNetworks.HybridNetwork,
        attributes::PhyloPlotAttributes;
        preorder::Bool = true,
    )::PlotGeometry
    config = PhyloPlotConfig(attributes)
    plot_network = preorder ? prepare_plot_network(net) : PlotNetwork(net)
    return PlotGeometry(compute_network_geometry(plot_network, config))
end
