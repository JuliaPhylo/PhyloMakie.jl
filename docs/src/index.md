# PhyloMakie.jl

PhyloMakie is a Makie-native plotting package for phylogenetic trees and
networks implementing its `AbstractPhylogeny` interface. Its current native
concrete model is the independent `LineageNetwork`.

PhyloMakie registers a Makie recipe for `AbstractPhylogeny`, so the standard
Makie entry points work directly:

```julia
plot(phylogeny)
plot!(axis, phylogeny)
```

The package also exports `phyloplot` and `phyloplot!` as package-specific
aliases for the same plotting behavior.

![PhyloMakie logo](assets/logo.png)

## Manual outline

```@contents
Pages = [
    "man/installation.md",
    "man/getting_started.md",
    "man/untangling_edges.md",
    "man/better_edges.md",
    "man/adding_data.md"
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
