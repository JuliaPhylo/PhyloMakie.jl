# Public API

PhyloMakie extends Makie plotting for `PhyloNetworks.HybridNetwork` and exports
the package-specific convenience aliases, coordinate-query helpers, and the
`PhyloMakie.parsephylogeny` and `PhyloMakie.readphylogeny` phylogeny readers. The
`newick"..."` and `nexustreeblock"..."` string literals parse exactly one
phylogeny for direct use with the plotting entry points.

## Plotting entry points

| Function | Return value | Description |
| --- | --- | --- |
| `plot(net)` | `Makie.FigureAxisPlot` | Create a new figure, axis, and `PhyloPlot`. |
| `plot!(axis, net)` | `PhyloPlot` | Draw a network into an existing Makie axis. |
| `phyloplot(net)` | `Makie.FigureAxisPlot` | Alias for `plot(net)`. |
| `phyloplot!(axis, net)` | `PhyloPlot` | Alias for `plot!(axis, net)`. |

## Reading phylogenies

`parsephylogeny`/`readphylogeny` dispatch on a format tag
(`NewickFormat()`, `NexusFormat()`) and always return
`Vector{PhyloMakie.LineageNetwork}`. `parsephylogeny` takes literal format
content (a string or an `IO` stream); `readphylogeny` takes a file path.

| Function | Return value | Description |
| --- | --- | --- |
| `parsephylogeny(NewickFormat(), text)` | `Vector{LineageNetwork}` | Parse literal Newick text or an `IO` stream. |
| `readphylogeny(NewickFormat(), path)` | `Vector{LineageNetwork}` | Read Newick content from a file. |
| `readphylogeny(NexusFormat(), path)` | `Vector{LineageNetwork}` | Read the first trees block from a NEXUS file. |
| `newick"..."` | `LineageNetwork` | Parse exactly one Newick topology. |
| `nexustreeblock"..."` | `LineageNetwork` | Parse exactly one phylogeny from a NEXUS trees block. |

Use `only(...)` at the call site when a source is known to hold exactly one
phylogeny, e.g. `only(parsephylogeny(NewickFormat(), "(A,B);"))`.

The singular string literals reject content containing zero or multiple
phylogenies. Keep multiple phylogenies explicit and plot them individually:

```julia
phylogenies = parsephylogeny(NewickFormat(), "(A,B); (C,D);")
plots = phyloplot.(phylogenies)
```

For a single literal phylogeny, pass the parsed value directly:

```julia
phyloplot(newick"(A, (B, C));")
```

```@docs
PhyloMakie.PhyloPlot
PhyloMakie.phyloplot
PhyloMakie.phyloplot!
PhyloMakie.LineageNetwork
PhyloMakie.AbstractPhylogenyFormat
PhyloMakie.NewickFormat
PhyloMakie.NexusFormat
PhyloMakie.parsephylogeny
PhyloMakie.readphylogeny
PhyloMakie.@newick_str
PhyloMakie.@nexustreeblock_str
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
