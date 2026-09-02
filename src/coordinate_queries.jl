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

Coordinates are read from the plot's live node-position output rather than
recomputed, so they match what is on screen and reflect the effect of any prior
`Makie.update!` call. The returned `DataFrame` is an independent snapshot; use
[`node_positions_observable`](@ref) when an overlay must follow later updates.

# Examples
```julia
figaxisplot = plot(net; useedgelength = true)
node_positions(figaxisplot.plot)
```
"""
function node_positions(plot::PhyloPlot)::DataFrames.DataFrame
    table = _plot_output_value(plot, NODE_POSITION_TABLE_OUTPUT)::DataFrames.DataFrame
    return copy(table)
end

"""
    node_positions_observable(plot::PhyloPlot)::Makie.Observable{DataFrames.DataFrame}

Return a live node-position table for the network rendered by `plot`.

The observable has the same columns and row order as [`node_positions`](@ref).
The `number` column is the stable node key within the current network. Layout
updates such as `Makie.update!(plot; useedgelength = true)` preserve the
identity columns (`number`, `name`, and `isleaf`) and update `x` and `y`.

Replacing `arg1` may change every identity column. Consumers that associate
external data with taxa must inspect the updated identity columns and update
that data when the network changes. PhyloMakie does not resolve external data.

The returned `Observable` is backed by the plot's public node-position output
and remains the same object for the lifetime of `plot`.

# Examples
```julia
figaxisplot = plot(net; useedgelength = false)
live_positions = node_positions_observable(figaxisplot.plot)
tip_points = map(live_positions) do table
    Point2f[Point2f(row.x, row.y) for row in eachrow(table) if row.isleaf]
end
scatter!(figaxisplot.axis, tip_points)
Makie.update!(figaxisplot.plot; useedgelength = true)
```
"""
function node_positions_observable(
        plot::PhyloPlot,
    )::Makie.Observable{DataFrames.DataFrame}
    return Makie.ComputePipeline.get_observable!(
        plot.attributes,
        NODE_POSITION_TABLE_OUTPUT,
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
