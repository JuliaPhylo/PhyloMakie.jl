```@meta
CurrentModule = PhyloMakie
```

# PhyloMakie

PhyloMakie is a Makie-native plotting package for phylogenetic trees and
networks stored as `PhyloNetworks.HybridNetwork`. It preserves the plotting
capabilities that make `PhyloPlots.plot` useful, but it teaches Makie-native
entry surfaces first:

- `plot(net)`
- `plot!(ax, net)`
- `phyloplot(net)`
- `phyloplot!(ax, net)`

## What PhyloMakie provides

- full-tree and major-tree styles
- edge-length-aware layout
- gamma display for hybrid edges
- node and edge annotations through the supported public attribute surface
- color, width, linestyle, and explicit limit controls
- plotting into a new figure or an existing axis without hidden current-axis state

## Installation

This repository currently documents GitHub-based installation only. It does
not claim General-registry installation. The first plot example below uses
CairoMakie as the backend, so install it in the same environment before
running that example.

```julia
using Pkg
Pkg.add(url = "https://github.com/jeetsukumaran/PhyloMakie.jl")
Pkg.add("CairoMakie")
```

## First plot

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


## Learn more

- [Public API](public-api.md)
- [Render verification](render-verification.md)
