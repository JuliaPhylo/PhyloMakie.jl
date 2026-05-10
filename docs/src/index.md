```@meta
CurrentModule = PhyloMakie
```

# PhyloMakie

`PhyloMakie.jl` is rebuilding the `PhyloPlots.plot(::PhyloNetworks.HybridNetwork; ...)`
user surface on a Makie-native stack.

This repository snapshot now contains the tranche-1 verification foundation,
the tranche-2 keyword owner, the tranche-3 layout and annotation owners, and
the tranche-4 Makie render owner. The package owns a thin module shell with a
minimal `Makie` import, source-backed verification metadata, a repo-owned
fixture corpus, a Makie-independent `PlotLayout` payload, one internal
`render_plot!(ax, net, spec, layout)::PlotRenderLayers` owner, and direct
regression suites for helper behavior and CairoMakie-backed render proof. It
still does not implement `phyloplot`, `phyloplot!`, or Makie `plot(net)`
dispatch.

## What the current snapshot establishes

- a thin `PhyloMakie` module shell with a minimal `Makie` import
- a canonical keyword owner in `src/keyword_contract.jl` and `src/keyword_normalization.jl`
- canonical tranche-3 helper owners in `src/layout_engine.jl` and `src/annotation_data.jl`
- a canonical tranche-4 render owner in `src/render_adapter.jl`
- a canonical source-side verification owner in `VERIFICATION_FOUNDATION`
- a canonical test-side fixture corpus and direct local regression suites for helper behavior
- a repo-owned tranche-4 Makie source-set note and live render-verification docs

## Deferred proof boundary

All 3 target public surfaces remain recorded as target APIs with
`implemented = false`:

- `phyloplot`
- `phyloplot!`
- `plot(net)`

Tranche 4 closes the shared internal render owner only. Direct public
entry-surface proof, including public `xlim` and `ylim` error paths and
Makie public-surface integration, remains deferred to tranche 5.

## Verification pages

- [Verification foundation](verification-foundation.md)
- [Render verification](render-verification.md)
