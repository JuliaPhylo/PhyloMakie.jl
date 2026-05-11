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
`PhyloPlotAttributes` payload, passes it directly to the helper and render
owners, and stores it on the returned plot as `resolved_attributes`. The live
supported attribute set is rendered below from `VERIFICATION_FOUNDATION`.

Use the [Migration guide](migration-guide.md) if you are mapping older
`PhyloPlots` tasks to the Makie-native surface.

## Supported entry surfaces

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Surface | Return contract | Docs visibility |",
    "| --- | --- | --- |",
]
for surface in foundation.target_public_surfaces
    push!(
        rows,
        "| `$(surface.public_name)` | `$(surface.return_contract)` | `$(surface.docs_visibility)` |",
    )
end
Markdown.parse(join(rows, "\n"))
```

## Live public attribute set

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Public attribute |",
    "| --- |",
]
for keyword in foundation.public_attribute_owner.supported_public_attributes
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

const DataFrames = getfield(PhyloMakie, :DataFrames)
const PhyloNetworks = getfield(PhyloMakie, :PhyloNetworks)
```

## `plot(net)` pure-tree example

This is the primary non-mutating Makie entry surface on a tree-only network.

```@example public_api
tree_net = PhyloNetworks.readnewick(
    "((A:0.3,B:0.25):0.2,(C:0.18,D:0.22):0.35);",
)

plot(
    tree_net;
    use_edge_lengths = true,
    show_tip_labels = true,
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
    use_edge_lengths = true,
    show_gamma = true,
    show_internal_node_names = true,
    tip_label_offset = 0.15,
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
node_annotations = DataFrames.DataFrame(
    node=[-5, -3, -4, 5],
    label=["90", "95", "99", "tip"],
)
edge_annotations = DataFrames.DataFrame(
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
    use_edge_lengths = true,
    show_internal_node_names = true,
    show_node_numbers = true,
    show_edge_lengths = true,
    show_edge_numbers = true,
    show_gamma = true,
    node_annotations = node_annotations,
    edge_annotations = edge_annotations,
    node_annotation_scale = 1.2,
    edge_annotation_scale = 1.0,
    x_limits = (0.0, 6.5),
    y_limits = (0.0, 5.5),
    style = :majortree,
)

phyloplot!(
    right_axis,
    PhyloNetworks.readnewick("(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);");
    use_edge_lengths = true,
    show_gamma = true,
    minor_edge_arrow_length = 0.12,
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
