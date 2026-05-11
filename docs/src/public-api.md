```@meta
CurrentModule = PhyloMakie
```

# Public API

PhyloMakie exposes one Makie-native public owner for
`PhyloNetworks.HybridNetwork` plotting. `plot(net)` and `plot!(ax, net)` are
the primary Makie surfaces, while `phyloplot` and `phyloplot!` remain thin
generated convenience surfaces over the same owner.

Legacy public spellings such as `showtiplabel`, `xlim`, and `preorder` are
rejected at the recipe boundary. Internally, the public owner resolves one
`PhyloPlotAttributes` payload and passes it directly to the helper and render
owners. The supported attribute set below is rendered from the live package
constant `SUPPORTED_PHYLOPLOT_ATTRIBUTES`.

Use the [Migration guide](migration-guide.md) if you are mapping older
`PhyloPlots` tasks to the Makie-native surface.

## Supported entry surfaces

| Surface | Return contract | Notes |
| --- | --- | --- |
| `plot(net)` | `Makie.FigureAxisPlot` | Primary non-mutating Makie surface |
| `plot!(ax, net)` | `PhyloPlot` on an existing Makie axis | Primary mutating Makie surface |
| `phyloplot(net)` | `Makie.FigureAxisPlot` | Thin convenience surface over the same owner |
| `phyloplot!(ax, net)` | `PhyloPlot` on an existing Makie axis | Thin convenience surface over the same owner |

## Live public attribute set

```@eval
using Markdown
using PhyloMakie

rows = [
    "| Public attribute |",
    "| --- |",
]
for keyword in PhyloMakie.SUPPORTED_PHYLOPLOT_ATTRIBUTES
    push!(rows, "| `$(keyword)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Intentional boundary

- `plot(net)` returns a `Makie.FigureAxisPlot`.
- `plot!(ax, net)` plots into an existing axis and preserves Makie bang semantics.
- `phyloplot` and `phyloplot!` are convenience surfaces over the same owner.
- `preorder` stays internal to the package and is not part of the public surface.

```@setup public_api
using CairoMakie
using Makie
using PhyloMakie

CairoMakie.activate!()

const DataFrames = PhyloMakie.DataFrames
const PhyloNetworks = PhyloMakie.PhyloNetworks
```

## `plot(net)` pure-tree example

This is the primary non-mutating Makie entry surface on a tree-only network.

```@example public_api
tree_net = PhyloNetworks.readnewick(
    "((A:0.3,B:0.25):0.2,(C:0.18,D:0.22):0.35);",
)

plot(
    tree_net;
    useedgelength = true,
    showtiplabel = true,
    style = :fulltree,
)
```

## `plot(net)` reticulate example

This is the same primary non-mutating Makie entry surface on a network with a
hybrid edge.

```@example public_api
net = PhyloNetworks.readnewick(
    "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
)

plot(
    net;
    useedgelength = true,
    showgamma = true,
    shownodelabel = true,
    tipoffset = 0.15,
    style = :fulltree,
)
```

## `plot!(ax, net)` example

This mutating Makie surface plots into an existing axis and accepts the same
snake_case attribute set. The second axis uses the convenience surface
`phyloplot!` to show that both public paths share the same owner and remain
composable.

```@example public_api
annotation_net = PhyloNetworks.readnewick(
    "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
)
nodelabel = DataFrames.DataFrame(
    node=[-5, -3, -4, 5],
    label=["90", "95", "99", "tip"],
)
edgelabel = DataFrames.DataFrame(
    edge=[8, 9, 4, 6],
    label=["90", "95", "99", "tip"],
)

figure = Figure(size=(920, 360))
left_axis = Axis(figure[1, 1], title="plot!(ax, net)")
right_axis = Axis(figure[1, 2], title="phyloplot!(ax, net)")
hidedecorations!(left_axis)
hidespines!(left_axis)
hidedecorations!(right_axis)
hidespines!(right_axis)

plot!(
    left_axis,
    annotation_net;
    useedgelength = true,
    shownodelabel = true,
    shownodenumber = true,
    showedgelength = true,
    showedgenumber = true,
    showgamma = true,
    nodelabel = nodelabel,
    edgelabel = edgelabel,
    nodecex = 1.2,
    edgecex = 1.0,
    xlim = (0.0, 6.5),
    ylim = (0.0, 5.5),
    style = :majortree,
)

phyloplot!(
    right_axis,
    PhyloNetworks.readnewick("(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);");
    useedgelength = true,
    showgamma = true,
    arrowlen = 0.12,
    style = :fulltree,
)

figure
```

## Next steps

- Use the [Migration guide](migration-guide.md) for capability mapping and intentional differences.
- Use [Render verification](render-verification.md) for live CairoMakie-backed capability artifacts.

## API docs

```@docs
phyloplot
phyloplot!
PhyloPlot
```
