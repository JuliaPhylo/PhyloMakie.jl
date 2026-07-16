```@meta
CurrentModule = PhyloMakie
```

# Extending plots

```@setup extending
using CairoMakie
using Makie
using PhyloMakie

CairoMakie.activate!()

const PhyloNetworks = PhyloMakie.PhyloNetworks
```

## Axis-based extension

`plot!(ax, net; ...)` renders the network into an existing Makie `Axis` and returns a
`PhyloPlot`.  After the call, `ax` is a standard Makie axis.  Any Makie primitive ---
`lines!`, `text!`, `scatter!`, `hlines!`, `vlines!`, `poly!` --- can be added to it
directly.  No coordinate lookup from a return value is required.

```julia
figure = Figure()
ax = Axis(figure[1, 1])
hidedecorations!(ax)
hidespines!(ax)

plot!(ax, net; useedgelength = true, style = :fulltree, showtiplabel = true)

# Add a horizontal reference line at the midpoint of the y-axis
hlines!(ax, [3.0]; color = :grey70, linestyle = :dot)

figure
```

## Y-axis layout convention

PhyloMakie places taxa at consecutive integer y-positions determined by a cladewise
traversal of the network.  The traversal visits child edges of each node from right to
left (last-in, first-out), so the topmost clade in the Newick string occupies the highest
y-positions and the bottommost clade occupies y = 1.

For a network with n taxa and no minor hybrid edges (`style = :majortree`), taxon
y-positions run from 1 to n.  When `style = :fulltree`, each minor hybrid edge claims
one additional integer y-position above n, so the full y-range extends to
n + (number of minor hybrid edges).

The exact y-position of each taxon depends on the traversal order, which is determined
by the network topology and the order of edges stored internally.  Use
`shownodenumber = true` on an exploratory plot to confirm which taxon lands at which
y-position before composing manual annotations.  `PhyloNetworks.rotate!` reorders child
edges and therefore changes the traversal order (see [Annotations](annotations.md)).

## Side clade bars example

The example below adds labeled margin bars to denote clades on a 10-taxon pure-tree
network.  The tree has 10 taxa at y-positions 1–10.  Three clades are annotated:

- A: taxa t1 and t2 at y = 10 and y = 9
- B: taxa t6 and t7 at y = 5 and y = 4
- C: taxa t8–t10 at y = 3, 2, 1

`xlim` is widened on the right to create margin space for the bars and labels.

```@example extending
tree = PhyloNetworks.readnewick(
    "(((((((t1,t2),t3),t4),t5),(t6,t7)),(t8,t9)),t10);",
)

figure = Figure(size = (640, 480))
ax = Axis(figure[1, 1])
hidedecorations!(ax)
hidespines!(ax)

plot!(ax, tree; xlim = (1, 12), showtiplabel = true)

bar_x = 10.2
label_x = 10.6

# Clade A: t1 (y=10) and t2 (y=9)
lines!(ax, [bar_x, bar_x], [9.8, 10.2]; color = :black)
text!(ax, label_x, 10.0; text = "A", align = (:left, :center))

# Clade B: t6 (y=5) and t7 (y=4)
lines!(ax, [bar_x, bar_x], [3.8, 5.2]; color = :black)
text!(ax, label_x, 4.5; text = "B", align = (:left, :center))

# Clade C: t8 (y=3), t9 (y=2), t10 (y=1)
lines!(ax, [bar_x, bar_x], [0.8, 3.2]; color = :black)
text!(ax, label_x, 2.0; text = "C", align = (:left, :center))

figure
```

## Design boundary

PhyloMakie does not currently expose node or edge coordinates through a public return
value.  When taxon y-positions must be determined programmatically --- for example, to
anchor annotations on a named taxon without knowing its position in advance --- use the
public plot attributes to make an exploratory plot first.  The current internal
computation path can be useful for package-development experiments, but it is not a
stable public layout-query surface:

```julia
config = PhyloMakie.resolve_plot_config(; useedgelength = true, style = :fulltree)
plot_network = PhyloMakie.prepare_plot_network(net)
geometry = PhyloMakie.compute_network_geometry(plot_network, config)
layout = PhyloMakie.compute_layout(plot_network, config, geometry)

# layout.geometry.node_x, layout.geometry.node_y
# layout.annotations.node_data
```

The [Render verification](render-verification.md) page uses current graph outputs for
docs-internal proof.  A stable public layout-query surface is not part of the current
public attribute surface.
