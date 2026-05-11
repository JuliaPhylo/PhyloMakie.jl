# PhyloMakie

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jeetsukumaran.github.io/PhyloMakie.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jeetsukumaran.github.io/PhyloMakie.jl/dev/)
[![Build Status](https://github.com/jeetsukumaran/PhyloMakie.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jeetsukumaran/PhyloMakie.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

PhyloMakie is a Makie-native plotting package for phylogenetic trees and
networks stored as `PhyloNetworks.HybridNetwork`. It preserves the plotting
tasks that make `PhyloPlots.plot` useful, but it teaches a Makie-first public
surface instead of keeping the legacy keyword shell as the package contract.

## What PhyloMakie provides

- `plot(net)` and `plot!(ax, net)` for Makie-native plotting
- `phyloplot` and `phyloplot!` as thin convenience surfaces over the same owner
- full-tree and major-tree styles
- edge-length scaling, gamma display, annotations, colors, widths, and axis composition
- a pure Julia plotting path with no R dependency

## Supported entry surfaces

| Surface | Return contract | Notes |
| --- | --- | --- |
| `plot(net)` | `Makie.FigureAxisPlot` | Primary non-mutating Makie surface |
| `plot!(ax, net)` | `PhyloPlot` on an existing Makie axis | Primary mutating Makie surface |
| `phyloplot(net)` | `Makie.FigureAxisPlot` | Thin convenience surface over the same owner |
| `phyloplot!(ax, net)` | `PhyloPlot` on an existing Makie axis | Thin convenience surface over the same owner |

## Installation

PhyloMakie is currently documented through GitHub-based installation. This
repository does not currently claim General-registry installation.

```julia
using Pkg
Pkg.add(url = "https://github.com/jeetsukumaran/PhyloMakie.jl")
```

The quickstart example below uses CairoMakie as the backend and needs
PhyloNetworks for the types and data parser, so install these in the same
environment before running that example.

```julia
Pkg.add([
    "CairoMakie",
    "PhyloNetworks",
])
```

## Quickstart

```julia
using CairoMakie
using PhyloMakie
using PhyloNetworks: readnewick

net = readnewick(
    "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
)

plot(
    net;
    useedgelength = true,
    showgamma = true,
    showtiplabel = true,
    style = :fulltree,
)
```


## Documentation

- [Home](docs/src/index.md)
- [Public API](docs/src/public-api.md)
- [Render verification](docs/src/render-verification.md)
