# Working with PhyloNetworks

PhyloMakie can plot a network produced by
[PhyloNetworks.jl](https://juliaphylo.github.io/PhyloNetworks.jl/stable/)
after converting it to a [`LineageNetwork`](@ref PhyloMakie.LineageNetwork).
`PhyloNetworks.HybridNetwork` is a separate type, outside PhyloMakie's
[`AbstractPhylogeny`](@ref PhyloMakie.AbstractPhylogeny) hierarchy. Convert it
with [`from_hybridnetwork`](@ref PhyloMakie.from_hybridnetwork) before calling
`plot` or `plot!`.

## Plot an existing network

This example uses CairoMakie and PhyloMakie from the [installation guide](@ref
Installation), plus PhyloNetworks. If PhyloNetworks is not already in the
active environment, add it with `using Pkg; Pkg.add("PhyloNetworks")`.

Load the packages and create a `HybridNetwork`. In an analysis workflow,
`hybrid_network` could instead be a result already obtained from PhyloNetworks:

```@example phylonetworks
using CairoMakie
using PhyloMakie
import PhyloNetworks
CairoMakie.activate!()

hybrid_network = PhyloNetworks.readnewick(
    "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
)
phylogeny = from_hybridnetwork(hybrid_network)
```

The converted phylogeny supports the same plotting options as one read directly
by PhyloMakie:

```@example phylonetworks
result = plot(phylogeny; useedgelength = true, showgamma = true)
result.figure
```

See [The figure, axis, and plot result](@ref) for the meaning of `.figure`,
`.axis`, and `.plot`. The same converted phylogeny can be passed to
`plot!(axis, phylogeny)` in an existing Makie layout.

## Convert back to PhyloNetworks

Use [`to_hybridnetwork`](@ref PhyloMakie.to_hybridnetwork) when a subsequent
PhyloNetworks operation needs a `HybridNetwork`. For example, serialize the
converted network to extended Newick with PhyloNetworks' `writenewick`:

```@repl phylonetworks
exported_network = to_hybridnetwork(phylogeny);
typeof(exported_network)
PhyloNetworks.writenewick(exported_network)
```

Julia's `convert` also supports both directions:

```@repl phylonetworks
native_copy = convert(LineageNetwork, hybrid_network);
hybrid_copy = convert(PhyloNetworks.HybridNetwork, native_copy);
native_copy isa LineageNetwork
hybrid_copy isa PhyloNetworks.HybridNetwork
```

## What conversion preserves

Conversion transfers the topology, root, node and edge identifiers, node
labels, edge lengths, inheritance probabilities, and major/minor hybrid-edge
classifications. Each call creates independent nodes and edges. Conversion
does not modify the input, and later changes to one representation do not
automatically update the other.

PhyloNetworks traversal caches, work arrays, partitions, and inference scores
are not copied into `LineageNetwork`. Conversion back constructs a fresh
`HybridNetwork` and rebuilds its derived state. Custom `LineageNetwork` node,
edge, and graph data payloads are not transferred to `HybridNetwork`.

For workflows starting with a file or string, PhyloMakie's
[readers](@ref "Reading phylogenies") already return `LineageNetwork` values.
They use PhyloNetworks to parse Newick and NEXUS content and perform the
conversion automatically; no explicit conversion is needed in those workflows.
