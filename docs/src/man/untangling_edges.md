```@setup untangling
using CairoMakie
using PhyloMakie
using PhyloNetworks
CairoMakie.activate!()
```

# Untangling edges

PhyloMakie plots the node order stored in the `HybridNetwork`. When a network
is hard to read, rotate edges in the `PhyloNetworks` object and plot the
updated network.

Show node numbers to identify the internal node to rotate:

```@example untangling
net = readnewick("(A,((B,#H1),(C,(D)#H1)));")
surface = plot(net; shownodenumber = true)
surface.figure
```

Rotate around node `-5` and render the result next to the original network:

```@example untangling
original = readnewick("(A,((B,#H1),(C,(D)#H1)));")
rotated = readnewick("(A,((B,#H1),(C,(D)#H1)));")
PhyloNetworks.rotate!(rotated, -5)

figure = Figure(size = (760, 320))
left_axis = Axis(figure[1, 1], title = "Original")
right_axis = Axis(figure[1, 2], title = "Rotated")
hidedecorations!(left_axis)
hidedecorations!(right_axis)
hidespines!(left_axis)
hidespines!(right_axis)
plot!(left_axis, original)
plot!(right_axis, rotated)
figure
```

PhyloMakie does not mutate the network passed to `plot` or `plot!`. Rotation is
a deliberate `PhyloNetworks` operation on the network value that you pass in.
