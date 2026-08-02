## PhyloMakie.jl

PhyloMakie is a Makie-native plotting package for phylogenetic trees and
networks represented as `PhyloNetworks.HybridNetwork`.

It is a ground-up Julia and Makie design. It is not a compatibility shell
around `PhyloPlots.jl`, and it does not need to make users feel that they are
calling the same package through a different backend.

The package must preserve the plotting capabilities that make
`PhyloPlots.plot` useful:

- tree and network layout for `HybridNetwork`
- full-tree and major-tree render styles
- major and minor hybrid edge rendering
- edge-length scaling, annotation placement, and gamma display
- text, color, width, and linestyle control
- plotting into new or existing Makie figures and axes
- pure Julia implementation with no R dependency

The package may redesign the public API when a Makie-native surface is
clearer, more composable, or more idiomatic. Legacy keyword names, defaults,
warnings, and wrapper structure are reference material. They are not the
product goal.

The primary user experience must feel native to Makie:

- a real Makie plot type or recipe
- support for `plot(net)` and plotting into existing axes
- package-specific helper entrypoints only as thin convenience surfaces
- documentation and examples that teach Makie-native usage first

The current internal layout and render owners may be reused when they fit this
goal. Compatibility-first structures are transitional only and must not remain
part of the accepted end-state runtime architecture.

A user-facing sketch:

```julia
using CairoMakie
using PhyloNetworks: readnewick
using PhyloMakie

net = readnewick(
    "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
)

fig = Figure()
ax = Axis(fig[1, 1], title = "Makie-native phylogenetic network")
plot!(ax, net; style = :fulltree, showtiplabel = true)
fig
```

Package-specific convenience entrypoints may also exist:

```julia
fig, ax, plt = phyloplot(net; style = :majortree)
```

but the package should still read as Makie-native rather than as a wrapped
legacy surface.
