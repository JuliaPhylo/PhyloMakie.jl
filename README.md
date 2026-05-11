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

## Installation

PhyloMakie is currently documented through GitHub-based installation. This
repository does not currently claim General-registry installation.

```julia
using Pkg
Pkg.add(url = "https://github.com/jeetsukumaran/PhyloMakie.jl")
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
    use_edge_lengths = true,
    show_gamma = true,
    show_tip_labels = true,
    style = :fulltree,
)
```

## Migration

PhyloMakie does not present itself as a drop-in recreation of the old public
keyword shell. Use the [Migration guide](docs/src/migration-guide.md) to map
legacy `PhyloPlots` tasks to the supported Makie-native surfaces, and use the
[Public API](docs/src/public-api.md) page for the live examples that define the
current package surface.

## Documentation

- [Home](docs/src/index.md)
- [Public API](docs/src/public-api.md)
- [Migration guide](docs/src/migration-guide.md)
- [Render verification](docs/src/render-verification.md)
- [Verification foundation](docs/src/verification-foundation.md)
