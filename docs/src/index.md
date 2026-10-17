# PhyloMakie.jl

PhyloMakie is a Makie-native plotting package for phylogenetic trees and
networks implementing its [`AbstractPhylogeny`](@ref PhyloMakie.AbstractPhylogeny)
interface. Its current native concrete model is
[`LineageNetwork`](@ref PhyloMakie.LineageNetwork).

PhyloMakie registers a Makie recipe for `AbstractPhylogeny`, so the standard
Makie entry points work directly:

```julia
plot(phylogeny)
plot!(axis, phylogeny)
```

The package also exports `phylogenyplot` and `phylogenyplot!` as package-specific
aliases for the same plotting behavior.

![PhyloMakie logo](assets/logo.png)

## Where to start

- [Getting started](@ref) introduces the phylogeny model and Makie's figures,
  axes, plot results, and formatting tools.
- [Working with PhyloNetworks](@ref) shows how to plot an existing
  `HybridNetwork` and convert between representations.
- [Example scripts](@ref) lists runnable scripts by topic, with setup
  instructions and links to the relevant manual sections.

## Manual outline

```@contents
Pages = [
    "man/installation.md",
    "man/command_line_app.md",
    "man/getting_started.md",
    "man/phylonetworks.md",
    "man/untangling_edges.md",
    "man/better_edges.md",
    "man/adding_data.md",
    "man/examples.md"
]
Depth = 3
```

## Library outline

```@contents
Pages = ["lib/public.md", "lib/internals.md"]
Depth = 1
```

## Function index

```@index
Pages = ["lib/public.md", "lib/internals.md"]
Order = [:function]
```
