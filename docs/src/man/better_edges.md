```@setup better_edges
using CairoMakie
using DataFrames
using PhyloMakie
using PhyloNetworks: readnewick
CairoMakie.activate!()
```

# Better edges

## Different hybrid edge styles

We can use the `style` option to visualize minor hybrid edges as simple lines,
unlike the [icytree](https://icytree.org/) style visualization. `style` is by
default `:fulltree`, but by switching it to `:majortree`, we can draw minor
hybrid edges as diagonal lines.

```@example better_edges
net = readnewick("(A,((B,#H1),(C,(D)#H1)));")
plot(net; style = :majortree)
```

## Using edge lengths

We can use `useedgelength = true` to draw a plot that uses the network's edge
lengths to determine the lengths of the lines. For this, we'll use a network
that has edge lengths:

```@example better_edges
net = readnewick(
    "(A:3.3,((B:1.5,#H1:0.5):1.5,((C:1)#H1:1.8,D:1.1):0.2):0.3);",
)
df = DataFrame(number = [-3, 3], label = ["N", "H1"])

figure = Figure(size = (760, 320))
length_axis = Axis(figure[1, 1], title = "useedgelength = true")
level_axis = Axis(figure[1, 2], title = "useedgelength = false")
hidedecorations!(length_axis)
hidedecorations!(level_axis)
hidespines!(length_axis)
hidespines!(level_axis)
plot!(length_axis, net; useedgelength = true, ylim = (-1.0, 5.5), nodelabel = df)
plot!(level_axis, net; useedgelength = false, ylim = (-1.0, 5.5), nodelabel = df)
figure
```

!!! note
    I used a DataFrame to add the label "N" to the plot.
    For more on this, see the [Adding labels](@ref) section.

If edge lengths represent time, D could represent a fossil, or a virus strain
sequenced a year before the others. Seeing this visually is the advantage of
`useedgelength = true`.

This network happens to be time consistent, because the distance along the time
(x) axis from node `N` to the hybrid node `H1` is the same both ways.

!!! note "Time consistency"
    A network is time-consistent if all the paths between 2 given nodes all
    have the same length.
    Time inconsistency can occur when edge lengths are not measured in
    calendar time, such as if edge lengths are in substitutions per site
    (some paths might evolve with more substitutions than others), or in
    number of generations (some lineages might have 1 generation per year,
    others more or fewer generations per year), or in coalescent units
    (number of generations / effective population size).

    A time-consistent network may be ultrametric (the distance
    between the root and the tips is the same across all tips),
    or not like the network above.

Time-inconsistent networks like these ones below might cause confusion:

```@example better_edges
net1 = readnewick(
    "(A:3.3,((B:1.5,#H1:1.2):1.5,((C:1.8)#H1:1,D:1.1):0.2):0.3);",
)
net2 = readnewick(
    "(A:3.3,((B:1.5,#H1:0.2):1.5,((C:1)#H1:1.8,D:1.1):0.2):0.3);",
)

figure = Figure(size = (760, 320))
left_axis = Axis(figure[1, 1])
right_axis = Axis(figure[1, 2])
hidedecorations!(left_axis)
hidedecorations!(right_axis)
hidespines!(left_axis)
hidespines!(right_axis)
plot!(left_axis, net1; useedgelength = true)
plot!(right_axis, net2; useedgelength = true)
figure
```

It may be useful to consider using `style = :majortree` if it causes too much
confusion, since the `:majortree` style doesn't visually represent minor edge
lengths. Because of this, I used the `showedgelength = true` option to see the
information anyway.

```@example better_edges
figure = Figure(size = (760, 320))
left_axis = Axis(figure[1, 1])
right_axis = Axis(figure[1, 2])
hidedecorations!(left_axis)
hidedecorations!(right_axis)
hidespines!(left_axis)
hidespines!(right_axis)
plot!(
    left_axis,
    net1;
    useedgelength = true,
    style = :majortree,
    showedgelength = true,
    arrowlen = 0.1,
)
plot!(
    right_axis,
    net2;
    useedgelength = true,
    style = :majortree,
    showedgelength = true,
    arrowlen = 0.1,
)
figure
```

I also used the `arrowlen = 0.1` option to show the arrow tips to show the
direction of minor edges, which are hidden by default when using the
`style = :majortree` option.

## Varying edge widths

We can vary edge widths to show population sizes for example.
First we need to map each edge number to the desired width for that edge.
We do this with a dictionary.

```@repl better_edges
log_populationsize = Dict(edge.number => log10(1_000) for edge in net1.edge);
log_populationsize[9] = log10(100_000); # larger populations on edge 9
log_populationsize[1] = log10(100_000); #                and on edge 1
log_populationsize
```

```@example better_edges
figure = Figure(size = (760, 320))
number_axis = Axis(figure[1, 1], title = "Edge numbers")
width_axis = Axis(figure[1, 2], title = "Edge widths")
hidedecorations!(number_axis)
hidedecorations!(width_axis)
hidespines!(number_axis)
hidespines!(width_axis)
plot!(number_axis, net1; showedgenumber = true)
plot!(width_axis, net1; edgewidth = log_populationsize)
figure
```

## Customization

Check out the list of `PhyloPlot` attributes in the [Public API](@ref).

In the example below, we first highlight in orange the edges on the 2 paths from
the root to C. Then we change the type of the minor edge (to hide it).

```@repl better_edges
ecols = Dict(i => "black" for i in 1:9); # make all black
for i in [9, 8, 6, 5, 4, 3] # except for edges ancestral to C
    ecols[i] = "orangered"
end
ecols
```

```@example better_edges
figure = Figure(size = (760, 320))
color_axis = Axis(figure[1, 1])
hidden_axis = Axis(figure[1, 2], title = "Minor hybrid edge hidden")
hidedecorations!(color_axis)
hidedecorations!(hidden_axis)
hidespines!(color_axis)
hidespines!(hidden_axis)
plot!(
    color_axis,
    net1;
    edgecolor = ecols,
    defaultedgecolor = "grey80",
    minorlinetype = "solid",
)
plot!(
    hidden_axis,
    net1;
    style = :majortree,
    majorhybridedgecolor = "red",
    minorlinetype = "blank",
)
figure
```
