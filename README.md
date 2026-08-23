# PhyloMakie

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPhylo.github.io/PhyloMakie.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/)
[![Build Status](https://github.com/JuliaPhylo/PhyloMakie.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaPhylo/PhyloMakie.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

PhyloMakie is a Makie-native plotting package for phylogenetic trees and
networks stored as `PhyloNetworks.HybridNetwork`, using the standard Makie
`plot` / `plot!` interface.

## Features

- `plot(net)` and `plot!(ax, net)` follow standard Makie conventions
- `phyloplot` and `phyloplot!` as convenience aliases
- Full-tree and major-tree layout styles
- Edge-length scaling, gamma display, tip labels, colors, and widths
- Composable with any Makie layout

## API

| Function | Returns | Notes |
| --- | --- | --- |
| `plot(net)` | `Makie.FigureAxisPlot` | Creates a new figure |
| `plot!(ax, net)` | `PhyloPlot` | Draws into an existing axis |
| `phyloplot(net)` | `Makie.FigureAxisPlot` | Alias for `plot(net)` |
| `phyloplot!(ax, net)` | `PhyloPlot` | Alias for `plot!(ax, net)` |

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

net = only(parsenetwork(NewickFormat(), 
    "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
))

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
- [Public API](docs/src/lib/public.md)
