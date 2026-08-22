# Public API

PhyloMakie extends Makie plotting for `PhyloNetworks.HybridNetwork` and exports
the package-specific convenience aliases, coordinate-query helpers, and the
`PhyloMakie.readnewick` and `PhyloMakie.readnexus_treeblock` readers.

## Plotting entry points

| Function | Return value | Description |
| --- | --- | --- |
| `plot(net)` | `Makie.FigureAxisPlot` | Create a new figure, axis, and `PhyloPlot`. |
| `plot!(axis, net)` | `PhyloPlot` | Draw a network into an existing Makie axis. |
| `phyloplot(net)` | `Makie.FigureAxisPlot` | Alias for `plot(net)`. |
| `phyloplot!(axis, net)` | `PhyloPlot` | Alias for `plot!(axis, net)`. |
| `PhyloMakie.readnewick(input)` | `PhyloNetworks.HybridNetwork` | Parse a Newick network. |
| `PhyloMakie.readnexus_treeblock(filename)` | `Vector{PhyloNetworks.HybridNetwork}` | Read the first trees block in a NEXUS file. |

```@docs
PhyloMakie.PhyloPlot
PhyloMakie.phyloplot
PhyloMakie.phyloplot!
PhyloMakie.readnewick
PhyloMakie.readnexus_treeblock
```

## Plot attributes

`PhyloPlot` accepts the following public attributes:

| Attribute | Purpose |
| --- | --- |
| `useedgelength` | Use edge lengths on the x axis. |
| `showtiplabel` | Show tip labels. |
| `shownodelabel` | Show internal node names. |
| `shownodenumber` | Show node numbers. |
| `showedgelength` | Show edge lengths. |
| `showedgenumber` | Show edge numbers. |
| `showgamma` | Show hybrid-edge inheritance probabilities. |
| `edgecolor` | Set one color or a dictionary keyed by edge number. |
| `defaultedgecolor` | Set the fallback edge color when `edgecolor` is a dictionary. |
| `majorhybridedgecolor` | Set the color for major hybrid edges. |
| `minorhybridedgecolor` | Set the color for minor hybrid edges. |
| `edgewidth` | Set one width or a dictionary keyed by edge number. |
| `minorlinetype` | Set the line style for minor hybrid edges, or `"blank"` to hide them. |
| `arrowlen` | Set minor hybrid edge arrow length. |
| `nodelabel` | Supply a node label table. |
| `edgelabel` | Supply an edge label table. |
| `nodecex` | Scale node label text. |
| `edgecex` | Scale edge label text. |
| `nodelabelcolor` | Set node label color. |
| `edgelabelcolor` | Set edge label color. |
| `edgenumbercolor` | Set edge number color. |
| `nodelabeladj` | Set node label alignment. |
| `edgelabeladj` | Set edge label alignment. |
| `tipoffset` | Move tip labels away from tip positions. |
| `tipcex` | Scale tip label text. |
| `xlim` | Set x data limits. |
| `ylim` | Set y data limits. |
| `style` | Choose `:fulltree` or `:majortree`. |

## Coordinate queries

```@docs
PhyloMakie.node_positions
PhyloMakie.edge_positions
```

## Index

```@index
Pages = ["public.md"]
```
