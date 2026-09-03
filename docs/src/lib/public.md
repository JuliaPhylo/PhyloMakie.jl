# Public API

PhyloMakie extends Makie plotting for `PhyloNetworks.HybridNetwork` and exports
the package-specific convenience aliases, coordinate-query helpers, and the
singular `PhyloMakie.parsephylogeny` and `PhyloMakie.readphylogeny` readers and
plural `PhyloMakie.parsephylogenies` and `PhyloMakie.readphylogenies` readers.
The `newick"..."` and `nexustreeblock"..."` string literals parse exactly one
phylogeny for direct use with the plotting entry points.

## Plotting entry points

| Function | Return value | Description |
| --- | --- | --- |
| `plot(net)` | `Makie.FigureAxisPlot` | Create a new figure, axis, and `PhyloPlot`. |
| `plot!(axis, net)` | `PhyloPlot` | Draw a network into an existing Makie axis. |
| `phyloplot(net)` | `Makie.FigureAxisPlot` | Alias for `plot(net)`. |
| `phyloplot!(axis, net)` | `PhyloPlot` | Alias for `plot!(axis, net)`. |

## Reading phylogenies

All 4 reader functions dispatch on a format tag (`NewickFormat()` or
`NexusFormat()`). `parsephylogeny` and `parsephylogenies` take literal format
content as a string or an `IO` stream. `readphylogeny` and `readphylogenies`
take a file path. The singular functions require exactly one phylogeny; the
plural functions return every phylogeny in a `Vector`.

| Function | Return value | Description |
| --- | --- | --- |
| `parsephylogeny(format, source)` | `LineageNetwork` | Parse exactly one phylogeny from literal content or an `IO` stream. |
| `parsephylogenies(format, source)` | `Vector{LineageNetwork}` | Parse every phylogeny from literal content or an `IO` stream. |
| `readphylogeny(format, path)` | `LineageNetwork` | Read exactly one phylogeny from a file. |
| `readphylogenies(format, path)` | `Vector{LineageNetwork}` | Read every phylogeny from a file. |
| `newick"..."` | `LineageNetwork` | Parse exactly one Newick topology. |
| `nexustreeblock"..."` | `LineageNetwork` | Parse exactly one phylogeny from a NEXUS trees block. |

The singular readers throw `ArgumentError` when the source contains zero or
multiple phylogenies.

The singular string literals reject content containing zero or multiple
phylogenies. Keep multiple phylogenies explicit and plot them individually:

```julia
phylogenies = parsephylogenies(NewickFormat(), "(A,B); (C,D);")
plots = phyloplot.(phylogenies)
```

For a single literal phylogeny, pass the parsed value directly:

```julia
phyloplot(newick"(A, (B, C));")
```

```@docs
PhyloMakie.PhyloPlot
PhyloMakie.ImageAnnotation
PhyloMakie.phyloplot
PhyloMakie.phyloplot!
PhyloMakie.LineageNetwork
PhyloMakie.AbstractPhylogenyFormat
PhyloMakie.NewickFormat
PhyloMakie.NexusFormat
PhyloMakie.parsephylogeny
PhyloMakie.parsephylogenies
PhyloMakie.readphylogeny
PhyloMakie.readphylogenies
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
| `nodeimages` | Map node labels, regular expressions, or objects to images. |
| `edgeimages` | Map edge endpoint selectors or objects to images. |
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

[`node_positions`](@ref PhyloMakie.node_positions) returns an independent
snapshot. [`node_positions_observable`](@ref
PhyloMakie.node_positions_observable) returns one persistent
`Observable{DataFrame}` for a live overlay. Both surfaces use `number` as the
node key within the current network and report `name` and `isleaf` alongside
the coordinates.

Layout updates preserve the identity columns and update `x` and `y`. Replacing
`arg1` may change the identities; consumers that associate external data with
taxa must inspect the new table and refresh that data.

```@docs
PhyloMakie.node_positions
PhyloMakie.node_positions_observable
PhyloMakie.edge_positions
```

## Index

```@index
Pages = ["public.md"]
```
