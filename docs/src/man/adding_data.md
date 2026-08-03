```@setup adding_data
using CairoMakie
using DataFrames
using PhyloMakie
using PhyloNetworks: readnewick
CairoMakie.activate!()
```

# Adding data

In this section, we look over ways of adding extra information or data to a plot.

## Adding labels

!!! note
    For demonstration purposes, we walk through the process of adding labels to edges,
    with notes on how to do the same for nodes in parentheses.

To add labels on edges (or nodes), we need to know their numbers. We can use the
`showedgenumber = true` option for this. (Use `shownodenumber = true` to see node numbers).

```@example adding_data
net = readnewick("(A,((B,#H1),((C)#H1,D)));")

figure = Figure(size = (760, 320))
default_axis = Axis(figure[1, 1], title = "Default edge number color")
red_axis = Axis(figure[1, 2], title = "Red edge numbers")
hidedecorations!(default_axis)
hidedecorations!(red_axis)
hidespines!(default_axis)
hidespines!(red_axis)
plot!(default_axis, net; showedgenumber = true)
plot!(red_axis, net; showedgenumber = true, edgenumbercolor = "red4")
figure
```

Edge numbers are shown in grey by default (to avoid mistaking them for edge
lengths), but their color can be adjusted as shown above.

We then need to define a DataFrame with 2 columns of information: the number of
the edge (or node), and the label that goes on it, like this:

| number | label |
|--------|-------|
| 1 | "edge number 1" |
| 2 | "edge # 2" |

After including the DataFrames package, we can define it as so:

```@repl adding_data
using DataFrames
DataFrame(number = [1, 2], label = ["edge number 1", "edge # 2"])
```

Using this data frame as input to the `edgelabel` option (`nodelabel` for nodes)
puts the text on the correct edges:

```@example adding_data
plot(
    net;
    edgelabel = DataFrame(
        number = [1, 2],
        label = ["edge number 1", "edge # 2"],
    ),
    edgelabelcolor = "orangered",
    edgecex = [0.9, 1.1],
    edgelabeladj = [0.5, -0.3],
)
```

## Adding other annotations using Makie

We can use the return value of `plot` and the coordinate query functions to get
information on the coordinates of different elements of the plot. Using this,
we can add any other information we want.

The `plot` function returns a `Makie.FigureAxisPlot` with these fields:

```julia
figaxisplot.figure
figaxisplot.axis
figaxisplot.plot
```

Use `.figure` to display the figure, `.axis` to add more Makie annotations, and
`.plot` with [`node_positions`](@ref PhyloMakie.node_positions) or
[`edge_positions`](@ref PhyloMakie.edge_positions) to query the coordinates used
by the live `PhyloPlot`.

## Side clade bars example

Here's example code that adds bars to denote clades in the margin:

```@example adding_data
tree = readnewick("(((((((t1,t2),t3),t4),t5),(t6,t7)),(t8,t9)),t10);")
plot_result = plot(tree; xlim = (1.0, 10.0))
axis = plot_result.axis

lines!(axis, [9.0, 9.0], [0.8, 7.2]; color = :gray30, linewidth = 3)
lines!(axis, [9.0, 9.0], [7.8, 9.2]; color = :gray30, linewidth = 3)
lines!(axis, [9.0, 9.0], [9.8, 10.2]; color = :gray30, linewidth = 3)
text!(axis, 9.3, 4.0; text = "C", align = (:left, :center), fontsize = 16)
text!(axis, 9.3, 8.5; text = "B", align = (:left, :center), fontsize = 16)
text!(axis, 9.3, 10.0; text = "A", align = (:left, :center), fontsize = 16)

plot_result.figure
```

Let's break this down step by step.
First, we read the topology, and plot the graph normally. `plot` actually returns
a value, from which we can get useful information.
Below, we store the plot output in `plot_result`, then check the node x
coordinates because they contain the default range of the x axis.

```@example adding_data
plot_result = plot(tree)
extrema(node_positions(plot_result.plot).x)
```

Looking at the x coordinates returned by default, we can see that the x range is
`(1.0, 8.0)`. To give us extra space to work with, we can set `xlim` to
`(1.0, 10.0)`, forcing the range to be wider on the right, for annotations.

```julia
plot(tree; xlim = (1.0, 10.0))
```

Knowing the coordinates, we can now add more information to the plot through
Makie. For this, use the Makie functions `lines!` and `text!` to add side bars
with text on them.

```julia
axis = plot_result.axis
lines!(axis, [9.0, 9.0], [0.8, 7.2]; color = :gray30, linewidth = 3)
text!(axis, 9.3, 4.0; text = "C", align = (:left, :center), fontsize = 16)
```

# Beyond

To go beyond, we can access data on the nodes and edges to use them as we wish.
We can access the coordinates of points and segments and more data like this:

```@repl adding_data
node_table = node_positions(plot_result.plot)
node_table.x # x coordinate. similarly try node_table.y
hcat(node_table.x, node_table.y)
edge_positions(plot_result.plot)
node_table
```
