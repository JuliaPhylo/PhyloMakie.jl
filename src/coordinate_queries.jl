import DataFrames

"""
    node_positions(plot::PhyloPlot)::DataFrames.DataFrame

Return one row per node in the network currently rendered by `plot`, with
columns `number::Int`, `name::String`, `isleaf::Bool`, `x::Float64`,
`y::Float64`.

The table always covers every node in the network, regardless of
`shownodenumber`, `shownodelabel`, or `nodelabel` — those attributes control
which nodes receive on-plot text, not which nodes this query reports.  Filter
to tips with `filter(:isleaf => identity, node_positions(plot))`, or to
internal/ancestral nodes with `filter(:isleaf => !, node_positions(plot))`.

Coordinates are read from the plot's live compute graph rather than
recomputed, so they always match what is on screen and reflect the effect of
any prior `Makie.update!` call.

# Examples
```julia
figaxisplot = plot(net; useedgelength = true)
node_positions(figaxisplot.plot)
```
"""
function node_positions(plot::PhyloPlot)::DataFrames.DataFrame
    plot_network = _plot_output_value(plot, :plot_network)::PlotNetwork
    geometry = _plot_output_value(plot, :network_geometry)::NetworkGeometry
    net = plot_network.net
    return DataFrames.DataFrame(
        number = Int[node.number for node in net.node],
        name = String[node.name for node in net.node],
        isleaf = Bool[node.leaf for node in net.node],
        x = copy(geometry.node_x),
        y = copy(geometry.node_y),
    )
end

"""
    edge_positions(plot::PhyloPlot)::DataFrames.DataFrame

Return one row per edge in the network currently rendered by `plot`, with
columns `number::Int`, `ishybrid::Bool`, `ismajor::Bool`,
`gamma::Union{Float64,Missing}` (`missing` when the network stores no
inheritance probability for that edge), `x::Float64`, `y::Float64`.

The anchor `x`/`y` matches the same point PhyloMakie itself uses to place
gamma-value and edge-number text: a minor hybrid edge under
`style = :majortree` anchors at the rendered arrowhead midpoint, not the
network's zero-length collapsed trunk segment for that edge.

# Examples
```julia
figaxisplot = plot(net; useedgelength = true, style = :majortree)
edge_positions(figaxisplot.plot)
```
"""
function edge_positions(plot::PhyloPlot)::DataFrames.DataFrame
    plot_network = _plot_output_value(plot, :plot_network)::PlotNetwork
    layout = _plot_output_value(plot, :layout_computation)::LayoutComputation
    net = plot_network.net
    edge_data = layout.annotations.edge_data
    return DataFrames.DataFrame(
        number = Int[edge.number for edge in net.edge],
        ishybrid = Bool[edge.hybrid for edge in net.edge],
        ismajor = Bool[edge.ismajor for edge in net.edge],
        gamma = Union{Float64, Missing}[
            edge.gamma == -1.0 ? missing : edge.gamma for edge in net.edge
        ],
        x = copy(edge_data[!, :x]),
        y = copy(edge_data[!, :y]),
    )
end
