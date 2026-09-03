```@setup untangling
using CairoMakie
using PhyloMakie
CairoMakie.activate!()
```

# Untangling the network

This plot may not be the easiest to read, as the hybrid edge crosses over C's
edge:

```@example untangling
phylogeny = parsephylogeny(NewickFormat(), "(A,((B,#H1),(C,(D)#H1)));")
plot(phylogeny)
```

To fix this, we can rotate C and D's edges around their parent node.

First we need to know the number of this parent node. By showing node numbers
with the `shownodenumber = true` option, we can find the number of the node
whose child edges we should rotate.

```@example untangling
plot(phylogeny; shownodenumber = true)
```

As we can see, rotating edges around node `-5` will make for a prettier network.

```@example untangling
rotate_children!(phylogeny, -5)
plot(phylogeny)
```

This may seem unnecessary for a small network as shown, but it is a useful tool
for plotting large networks.
