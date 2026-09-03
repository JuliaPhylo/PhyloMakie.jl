```@setup getting_started
using CairoMakie
using PhyloMakie
CairoMakie.activate!()
```

# Getting started

Start with a `LineageNetwork`. This example reads a small network from an
extended Newick string. Parsing delegates to PhyloNetworks, then converts the
result to the independent native model:

```@repl getting_started
phylogeny = parsephylogeny(NewickFormat(), "(A,((B,#H1),(C,(D)#H1)));")
```

For literal content containing exactly one phylogeny, use the corresponding
format-specific string literal:

```@example getting_started
literal_plot = phyloplot(newick"(A, (B, C));")
literal_plot
```

Both `newick"..."` and `nexustreeblock"..."` require exactly one parsed
phylogeny. Use `parsephylogenies` when the content may contain multiple
phylogenies, then select or plot each returned value explicitly.

Call `plot` to create a new Makie figure, axis, and PhyloMakie plot object:

```@example getting_started
figaxisplot = plot(phylogeny)
figaxisplot.figure
```

The returned value is a `Makie.FigureAxisPlot`. Its `plot` field is the live
`PhyloPlot` object. Use that object when you want to update attributes or query
the rendered coordinates.

```@example getting_started
plot_handle = figaxisplot.plot
typeof(plot_handle)
```

PhyloMakie also provides `phyloplot` as a package-specific alias for `plot`:

```@example getting_started
alias_figaxisplot = phyloplot(
    phylogeny;
    showgamma = true,
    showtiplabel = true,
)
alias_figaxisplot.figure
```

To draw into an existing Makie axis, use `plot!` or `phyloplot!`:

```@example getting_started
figure = Figure(size = (700, 320))
axis = Axis(figure[1, 1])
hidedecorations!(axis)
hidespines!(axis)
phyloplot!(
    axis,
    phylogeny;
    showgamma = true,
    useedgelength = false,
)
figure
```
