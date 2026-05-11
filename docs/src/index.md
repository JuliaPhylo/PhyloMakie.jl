```@meta
CurrentModule = PhyloMakie
```

# PhyloMakie

`PhyloMakie.jl` is rebuilding the `PhyloPlots.plot(::PhyloNetworks.HybridNetwork; ...)`
user surface on a Makie-native stack.

This repository snapshot now contains the tranche-1 verification foundation,
the tranche-3 layout and annotation owners, the tranche-4 Makie render owner,
the tranche-5 Makie-native public recipe owner, and the tranche-6 runtime
carrier realignment that removed the old compatibility shell. The package now
exposes one public Makie recipe path that drives:

- `plot(net)`
- `plot!(ax, net)`
- `phyloplot(net)`
- `phyloplot!(ax, net)`

## What the current snapshot establishes

- a thin `PhyloMakie` module shell with a minimal `Makie` import
- a canonical tranche-6 public attribute owner in `src/public_attribute_model.jl`
- canonical tranche-3 helper owners in `src/layout_engine.jl` and `src/annotation_data.jl`
- a canonical tranche-4 render owner in `src/render_adapter.jl`
- a canonical tranche-5 public recipe owner in `src/public_plot_owner.jl`
- a canonical source-side verification owner in `VERIFICATION_FOUNDATION`
- a canonical test-side fixture corpus and direct local regression suites for helper behavior
- a repo-owned tranche-4 Makie source-set note and live public/render verification docs

## Public surface

The tranche-5 public attribute surface is the exact snake_case set recorded in
`VERIFICATION_FOUNDATION.public_attribute_owner.supported_public_attributes`.
Legacy public spellings such as `showtiplabel`, `xlim`, and `preorder` are
rejected at the recipe boundary.

The public owner deep-copies the caller-owned `HybridNetwork`, computes one
`PlotLayout`, passes the resulting `PhyloPlotAttributes` payload directly into
the internal `render_plot!` owner, and stores `resolved_attributes`,
`resolved_layout`, `render_layers`, and `data_limits` as live artifacts on the
returned `PhyloPlot`.

## Verification pages

- [Public API](public-api.md)
- [Verification foundation](verification-foundation.md)
- [Render verification](render-verification.md)
