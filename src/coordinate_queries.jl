import DataFrames

"""
    node_positions(plot::PhyloPlot)::DataFrames.DataFrame

Return one row per node in the phylogeny currently rendered by `plot`, with
columns `number::Int`, `name::String`, `isleaf::Bool`, `x::Float64`,
`y::Float64`.

The table always covers every node in the phylogeny, regardless of
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
figaxisplot = plot(phylogeny; useedgelength = true)
node_positions(figaxisplot.plot)
```
"""
function node_positions(plot::PhyloPlot)::DataFrames.DataFrame
    table = _plot_output_value(plot, NODE_POSITION_TABLE_OUTPUT)::DataFrames.DataFrame
    return copy(table)
end

"""
    node_positions_observable(plot::PhyloPlot)::Makie.Observable{DataFrames.DataFrame}

Return a live node-position table for the phylogeny rendered by `plot`.

The observable has the same columns and row order as [`node_positions`](@ref).
The `number` column is the stable node key within the current phylogeny. Layout
updates such as `Makie.update!(plot; useedgelength = true)` preserve the
identity columns (`number`, `name`, and `isleaf`) and update `x` and `y`.

Replacing `arg1` may change every identity column. Consumers that associate
external data with taxa must inspect the updated identity columns and update
that data when the phylogeny changes. PhyloMakie does not resolve external data.

The returned `Observable` is backed by the plot's public node-position output
and remains the same object for the lifetime of `plot`.

# Examples
```julia
figaxisplot = plot(phylogeny; useedgelength = false)
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

Return one row per edge in the phylogeny currently rendered by `plot`, with
columns `number::Int`, `ishybrid::Bool`, `ismajor::Bool`,
`gamma::Union{Float64,Missing}` (`missing` when the phylogeny stores no
inheritance probability for that edge), `x::Float64`, `y::Float64`.

The anchor `x`/`y` matches the same point PhyloMakie itself uses to place
gamma-value and edge-number text: a minor hybrid edge under
`style = :majortree` anchors at the rendered arrowhead midpoint, not the
phylogeny's zero-length collapsed trunk segment for that edge.

# Examples
```julia
figaxisplot = plot(phylogeny; useedgelength = true, style = :majortree)
edge_positions(figaxisplot.plot)
```
"""
function edge_positions(plot::PhyloPlot)::DataFrames.DataFrame
    prepared_phylogeny = _plot_output_value(plot, :prepared_phylogeny)::PreparedPhylogeny
    layout = _plot_output_value(plot, :layout_computation)::LayoutComputation
    phylogeny = prepared_phylogeny.phylogeny
    phylogeny_edges = edges(phylogeny)
    edge_data = layout.annotations.edge_data
    return DataFrames.DataFrame(
        number = Int[edge_id(current_edge) for current_edge in phylogeny_edges],
        ishybrid = Bool[is_hybrid(current_edge) for current_edge in phylogeny_edges],
        ismajor = Bool[is_major(current_edge) for current_edge in phylogeny_edges],
        gamma = Union{Float64, Missing}[
            inheritance_probability(current_edge) for current_edge in phylogeny_edges
        ],
        x = copy(edge_data[!, :x]),
        y = copy(edge_data[!, :y]),
    )
end
