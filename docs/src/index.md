```@meta
CurrentModule = PhyloMakie
```

# PhyloMakie

`PhyloMakie.jl` is rebuilding the `PhyloPlots.plot(::PhyloNetworks.HybridNetwork; ...)`
user surface on a Makie-native stack.

This repository snapshot now contains the tranche-1 verification foundation,
the tranche-2 keyword owner, and the tranche-3 layout and annotation owners.
The package owns a thin include-only module shell, source-backed verification
metadata, a repo-owned fixture corpus, a Makie-independent `PlotLayout`
payload, and direct regression suites for geometry, annotation validation, and
helper-level bounds messages. It still does not implement `phyloplot`,
`phyloplot!`, or Makie `plot(net)` dispatch.

## What the current snapshot establishes

- a thin include-only `PhyloMakie` module shell
- a canonical keyword owner in `src/keyword_contract.jl` and `src/keyword_normalization.jl`
- canonical tranche-3 helper owners in `src/layout_engine.jl` and `src/annotation_data.jl`
- a canonical source-side verification owner in `VERIFICATION_FOUNDATION`
- a canonical test-side fixture corpus and direct local regression suites for helper behavior
- docs pages that render the deferred proof boundary from source-owned data

## Deferred proof boundary

All 3 target public surfaces remain recorded as target APIs with
`implemented = false`:

- `phyloplot`
- `phyloplot!`
- `plot(net)`

Render-level proof for those surfaces remains deferred to tranche 4. Direct
public entry-surface proof, including public `xlim` and `ylim` error paths,
remains deferred to tranche 5.

## Verification pages

- [Verification foundation](verification-foundation.md)
