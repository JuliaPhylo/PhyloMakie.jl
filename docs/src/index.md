```@meta
CurrentModule = PhyloMakie
```

# PhyloMakie

`PhyloMakie.jl` is rebuilding the `PhyloPlots.plot(::PhyloNetworks.HybridNetwork; ...)`
user surface on a Makie-native stack.

This repository snapshot contains tranche-1 foundation work only. The package
now owns a thin module shell, a source-backed verification matrix, and a
repo-owned fixture corpus. It does not yet implement `phyloplot`,
`phyloplot!`, or Makie `plot(net)` dispatch.

Project-owner approval for the tranche-1 `Tasks -> Execute` run was recorded on
2026-05-09. This code snapshot captures that implemented verification
foundation; it does not widen the plotting API surface to match the later
tranches.

## What tranche 1 establishes

- a thin include-only `PhyloMakie` module shell
- a canonical source-side verification owner in `VERIFICATION_FOUNDATION`
- a canonical test-side fixture corpus for design scenarios and upstream helper regressions
- a docs page that renders the deferred proof boundary from source-owned data

## Deferred proof boundary

All 3 target public surfaces remain recorded as target APIs with
`implemented = false` in tranche 1:

- `phyloplot`
- `phyloplot!`
- `plot(net)`

## Verification pages

- [Verification foundation](verification-foundation.md)
