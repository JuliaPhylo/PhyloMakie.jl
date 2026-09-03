# PhyloMakie

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPhylo.github.io/PhyloMakie.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/)
[![Build Status](https://github.com/JuliaPhylo/PhyloMakie.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaPhylo/PhyloMakie.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

PhyloMakie is a Makie-native plotting package for phylogenetic trees and
networks. Its independent `LineageNetwork` model implements the
`AbstractPhylogeny` interface without carrying parser or inference caches, and
the standard Makie `plot` / `plot!` interface accepts any implementation of
that interface.

## Features

- `plot(phylogeny)` and `plot!(axis, phylogeny)` follow standard Makie conventions
- `phyloplot` and `phyloplot!` as convenience aliases
- `newick"..."` and `nexustreeblock"..."` literals for exactly one network
- Full-tree and major-tree layout styles
- Edge-length scaling, gamma display, tip labels, colors, and widths
- Native node and edge images from matrices, local files, or HTTP(S) URLs
- Snapshot and reactive node-position queries for independently owned overlays
- Composable with any Makie layout

## API

| Function | Returns | Notes |
| --- | --- | --- |
| `plot(phylogeny)` | `Makie.FigureAxisPlot` | Creates a new figure |
| `plot!(axis, phylogeny)` | `PhyloPlot` | Draws into an existing axis |
| `phyloplot(phylogeny)` | `Makie.FigureAxisPlot` | Alias for `plot(phylogeny)` |
| `phyloplot!(axis, phylogeny)` | `PhyloPlot` | Alias for `plot!(axis, phylogeny)` |
| `node_positions(plot)` | `DataFrame` | Independent node-coordinate snapshot |
| `node_positions_observable(plot)` | `Observable{DataFrame}` | Live identity-plus-position table |

## Installation

PhyloMakie is not yet registered in the Julia General registry. Install
directly from GitHub:

```julia
using Pkg
Pkg.add(url = "https://github.com/JuliaPhylo/PhyloMakie.jl")
```

The quickstart example below also requires CairoMakie:

```julia
Pkg.add([
    "CairoMakie",
])
```

## Quickstart

```julia
using CairoMakie
using PhyloMakie

phylogeny = newick"(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"

plot(
    phylogeny;
    useedgelength = true,
    showgamma = true,
    showtiplabel = true,
    style = :fulltree,
)
```

Newick and NEXUS parsing currently delegates to PhyloNetworks and immediately
converts the result to `LineageNetwork`. Use `from_hybridnetwork`,
`to_hybridnetwork`, or `convert` when explicitly crossing that adapter boundary.

## Documentation

- [Home](docs/src/index.md)
- [Public API](docs/src/lib/public.md)
