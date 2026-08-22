```@setup untangling
using CairoMakie
using PhyloMakie
import PhyloNetworks
CairoMakie.activate!()
```

# Untangling the network

This plot may not be the easiest to read, as the hybrid edge crosses over C's
edge:

```@example untangling
net = PhyloMakie.readnewick("(A,((B,#H1),(C,(D)#H1)));")
plot(net)
```

To fix this, we can rotate C and D's edges around their parent node.

First we need to know the number of this parent node. By showing node numbers
with the `shownodenumber = true` option, we can find the number of the node
whose child edges we should rotate.

```@example untangling
plot(net; shownodenumber = true)
```

As we can see, rotating edges around node `-5` will make for a prettier network.

```@example untangling
PhyloNetworks.rotate!(net, -5)
plot(net)
```

This may seem unnecessary for a small network as shown, but it is a useful tool
for plotting large networks.
