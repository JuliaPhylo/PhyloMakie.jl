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
not claim General-registry installation.

```julia
using Pkg
Pkg.add(url = "https://github.com/jeetsukumaran/PhyloMakie.jl")
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
    use_edge_lengths = true,
    show_gamma = true,
    show_tip_labels = true,
    style = :fulltree,
)
```

## What changes for migrating PhyloPlots users

PhyloMakie does not keep the legacy keyword shell as its public contract.
Migration support lives in package-owned docs instead:

- [Migration guide](migration-guide.md)
- [Public API](public-api.md)

The supported public attribute surface is the exact snake_case set recorded in
`VERIFICATION_FOUNDATION.public_attribute_owner.supported_public_attributes`.
Legacy spellings such as `showtiplabel`, `xlim`, `ylim`, `nodelabel`,
`edgelabel`, `edgecolor`, and `preorder` are rejected at the recipe boundary.

## Learn more

- [Public API](public-api.md)
- [Migration guide](migration-guide.md)
- [Verification foundation](verification-foundation.md)
- [Render verification](render-verification.md)
