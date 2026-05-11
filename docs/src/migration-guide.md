```@meta
CurrentModule = PhyloMakie
```

# Migration guide

PhyloMakie preserves capability parity with `PhyloPlots.plot`, but it does not
present itself as a drop-in recreation of the old public keyword shell. The
Makie-native public owner is `plot(net)` and `plot!(ax, net)`, with
`phyloplot` and `phyloplot!` retained only as thin convenience surfaces over
the same implementation.

## Supported entry surfaces

| Surface | Return contract |
| --- | --- |
| `plot(net)` | `Makie.FigureAxisPlot` |
| `plot!(ax, net)` | `PhyloPlot` on an existing Makie axis |
| `phyloplot(net)` | `Makie.FigureAxisPlot` |
| `phyloplot!(ax, net)` | `PhyloPlot` on an existing Makie axis |

## Capability mapping

| Capability | Makie-native surface | Migration note | Live example |
| --- | --- | --- | --- |
| Pure tree plotting | `plot(net)` or `phyloplot(net)` | Tree-only inputs use the same Makie-native surface as reticulate networks. No separate legacy wrapper is required. | [Public API](public-api.md#plotnet-pure-tree-example) |
| Reticulate plotting with gamma display | `plot(net; showgamma = true, style = :fulltree)` | Turn on gamma explicitly on the public surface rather than relying on a legacy plotting shell. | [Public API](public-api.md#plotnet-reticulate-example) |
| Style distinction | `plot!(ax, net; style = :fulltree)` or `plot!(ax, net; style = :majortree)` | Choose the style explicitly to switch between separate minor branches and overlay-style rendering. | [Render verification](render-verification.md#style-distinction-artifact) |
| Edge-length scaling | `plot(net; useedgelength = true)` | Edge-length-aware x placement lives on the supported public surface instead of behind a separate legacy mode. | [Public API](public-api.md#plotnet-reticulate-example) |
| Data-frame annotations | `plot!(ax, net; nodelabel = ..., edgelabel = ...)` | Pass node and edge annotation tables directly instead of using legacy label keywords. | [Public API](public-api.md#plotax-net-example) |
| Edge color and width control with fallback | `plot(net; edgecolor = Dict(...), defaultedgecolor = ..., edgewidth = ...)` | Dict overrides and default fallbacks stay on the supported public attribute surface. | [Render verification](render-verification.md#edge-color-gamma-color-and-width-artifact) |
| Dual-axis composition | `plot!(ax, net)` and `phyloplot!(ax, net)` | Compose into explicit axes instead of relying on hidden current-axis state. | [Public API](public-api.md#plotax-net-example) |

## Intentional differences

- The supported public attribute surface uses snake_case Makie-native names.
- `plot(net)` and `plot!(ax, net)` are the primary plotting surfaces.
- `phyloplot` and `phyloplot!` remain convenience surfaces over the same owner.
- `preorder` remains internal and is not accepted on the public surface.
- The package does not claim General-registry installation in this repository state.

## Rejected legacy spellings

```@eval
using Markdown
using PhyloMakie

rows = [
    "| Legacy spelling | Use instead |",
    "| --- | --- |",
]
for migration in PhyloMakie.PHYLOPLOT_ATTRIBUTE_MIGRATIONS
    if !isnothing(migration.public)
        push!(rows, "| `$(migration.legacy)` | `$(migration.public)` |")
    end
end
push!(rows, "| `preorder` | internal only |")
push!(rows, "| `edgenumbercolor` | governed render-owner default for `showedgenumber=true` |")
Markdown.parse(join(rows, "\n"))
```

## Where to look next

- Use [Public API](public-api.md) for the live first-use and composition examples.
- Use [Render verification](render-verification.md) for CairoMakie-backed capability artifacts.
