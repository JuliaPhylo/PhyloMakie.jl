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

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Surface | Return contract |",
    "| --- | --- |",
]
for surface in foundation.target_public_surfaces
    push!(rows, "| `$(surface.public_name)` | `$(surface.return_contract)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Capability mapping

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Capability | Makie-native surface | Migration note | Docs proof surface |",
    "| --- | --- | --- | --- |",
]
for (scenario_id, scenario) in pairs(foundation.accepted_design_scenarios)
    push!(
        rows,
        "| $(scenario.migration_label) | `$(scenario.public_surface)` | $(scenario.migration_guidance) | `$(scenario.docs_proof_surface)` |",
    )
end
Markdown.parse(join(rows, "\n"))
```

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
for migration in getfield(PhyloMakie, :PHYLOPLOT_ATTRIBUTE_MIGRATIONS)
    if !isnothing(migration.public)
        push!(rows, "| `$(migration.legacy)` | `$(migration.public)` |")
    end
end
push!(rows, "| `preorder` | internal only |")
push!(rows, "| `edgenumbercolor` | governed render-owner default for `show_edge_numbers=true` |")
Markdown.parse(join(rows, "\n"))
```

## Where to look next

- Use [Public API](public-api.md) for the live first-use and composition examples.
- Use [Render verification](render-verification.md) for CairoMakie-backed capability artifacts.
- Use [Verification foundation](verification-foundation.md) for the source-backed proof inventory.
