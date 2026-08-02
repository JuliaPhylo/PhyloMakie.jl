# ---
# title: "Creating reactive recipes"
# author: Jeet Sukumaran
# order: 40
# engine: julia
# ---

# ## The plot as a directed graph

# A Makie plot is modeled as a directed graph, implemented using `ComputePipeline.ComputeGraph`, with nodes representing states of attributes and edges representing computations on a set of input nodes resulting in a set of output nodes.

# The input nodes represent any values by which we want
# to determine or inform the plot appearance.
# This includes the data itself as well as various parameters of the visualization aesthetics.
# Each distinct positional argument and keyword argument passed to the plotting function or defined in the plot `@recipe` is mapped to a distinct node in the compute graph.
# Our plotting functions can "consume" these directly by dereferencing them:

# ::: {.callout-note title="Non-reactive Recipe uses dereferenced `ComputeNode` values"}
#
# ```julia
#
# @recipe FooPlot (a1, a2)
#   b1 = 0.1
#   b2 = 0.2
# end
#
# function Makie.plot(plt)
#    ...
#    geom = create_geom(plt.a1[], plt.a2[]; kw1 = plt.b1[], ...)
#    options = create_aesthetics(; kw1 = plt.a1[], kw2 = plt.b1[], ...)
#    poly(plt, geom; options...)
#    ...
# end
# ```
# :::

# This plot works, but will not be reactive to changes in any of the
# inputs when called with `update!(plt; ...)`.
# Our plotting function is not responding to changes in inputs
# because when
# we used the `[]`/`getindex` function to dereference the
# value of the of the attributes in the plotting function,
# we took a "snapshot" of the static values currently wrapped
# by the node.

# ## Reactive recipes use `ComputeNode` objects rather than values

# To construct reactivity into our plot, we need our plotting instructions
# to use the compute graph *nodes* (`ComputePipeline.ComputeNode` objects)
# rather than the compute graph node *values*.
# Specifically, we need to create nodes that update based on input changes, and our plotting functions
# have to, ultimately, use these nodes or other nodes derived from these nodes as arguments to
# other Makie plotting functions that actually render the graphical elements.
# We do this by
# adding a new directed edge to the plot's underlying compute graph
# (given by the plot `attributes::ComputePipeline.ComputeGraph`
# property) that will connect, as source nodes,
# the nodes parameters, variables, or data to which we are reacting
# to, as destination nodes, the values used in
# by our primitive calls in ourplotting algorithm.

# We can add a compute edge to our plot using `map!`.
# `ComputePipeline.register_computation!()` a  `map!` function.

# We can also use the full `ComputePipeline.register_computation!()`, of which `map!`
# is a convenience wrapper.
# `ComputePipeline.register_computation!` exposes
# information about which of the inputs has changed as well
# as the cached value of the previous output.
# It has a bulkier signature and requires input nodes be dereferenced
# by the `[]` function.

# If we are fine on unconditionally recomputing the output any time
# *any* of the inputs changes, `map!` provides a cleaner syntax.
# `ComputePipeline.register_computation!` is preferered
# if we can and want to economize the computation
# depending on which inputs of the input set have change.


# ::: {.panel-tabset}

# #### `map!`

# The compute function passed to the `map!` function should support this signature pattern:
#
# Positional arguments, one for each input nodes, in order.
# Returns:
# - A tuple with equal size to the output names set in map!(::ComputeGraph),
#   or a single value in only a single output node specified, or nothing if the result is the same as the previous
#
# In addition, note how the positional arguments do NOT have to be
# dereferenced, which makes for much cleaner syntax.
#
# ::: {.callout-note title="Adding a compute edge with `map!`"}
#
# ```julia
#   map!(
#       plt.attributes,
#       [:r, :g, :b, :opacity],
#       [:color_r, :color_g, :color_b],
#   ) do r, g, b, opacity
#       return (
#           RGBA(r, 0.0, 0.0, opacity),
#           RGBA(0.0, g, 0.0, opacity),
#           RGBA(0.0, 0.0, b, opacity),
#       )
#   end
# ```
#
# :::

# #### `register_computation`

# The compute function passed to `register_computation!` function should support this signature:
#
# Arguments:
#
# - `inputs::NamedTuple{input_names, Ref)`: `Ref`s to the data held by the inputs of the computation.
#   The order always matches the order of the input names given to register_computation!().
# - `changed::NamedTuple{input_names, Bool}`: inputs have changed since the computation was last triggered.
# - `cached::Union{Nothing, Tuple}` the data of the previous output(s) in order, or nothing if no previous output exists.
#
# Returns:
# - A tuple with equal size to the output names set in register_computations!(), or nothing if the result is the same as the previous
#
#
# ::: {.callout-note title="Adding a compute edge with `register_computation!`"}
#
# ```julia
# register_computation!(
#     plt.attributes,         ## The plot's `ComputeGraph` object: the graph to which we are adding a compute edge
#     [:r, :g, :b, :opacity], ## Source node(s) of the new compute edge
#     [:circle_colors],       ## Destination node(s) of the compute edge
# ) do inputs, changed, cached
#     r, g, b, opacity = inputs
#     color_values = [
#         RGBA(r[], 0.0, 0.0, opacity[]),
#         RGBA(0.0, g[], 0.0, opacity[]),
#         RGBA(0.0, 0.0, b[], opacity[]),
#     ]
#     return [color_values]
# end
# ```
#
# :::


# :::

# ## Basic example
# ### Definition

using GLMakie
using Colors

@recipe RGBDiscs (x, y) begin
    r = 1.0
    g = 1.0
    b = 1.0
    opacity = 0.5
    size = 1.0
    overlap = 0.5
end

function Makie.plot!(plt::RGBDiscs)

    map!(
        plt.attributes,
        [:r, :g, :b, :opacity],
        [:color_r, :color_g, :color_b],
    ) do r, g, b, opacity
        return (
            RGBA(r, 0.0, 0.0, opacity),
            RGBA(0.0, g, 0.0, opacity),
            RGBA(0.0, 0.0, b, opacity),
        )
    end

    map!(
        plt.attributes,
        [:x, :y, :size, :overlap],
        [:geom_r, :geom_g, :geom_b],
    ) do x, y, size, overlap
        offset_size = size * (1.0 - overlap)
        return (
            Circle(Point(x, y + offset_size), size),
            Circle(Point(x + offset_size, y), size),
            Circle(Point(x - offset_size, y), size),
        )
    end

    poly!(plt, plt.geom_r; color = plt.color_r)
    poly!(plt, plt.geom_g; color = plt.color_g)
    poly!(plt, plt.geom_b; color = plt.color_b)

    return plt
end

# ### Application

# #### Plot creation

fig = Figure()
ax = Axis(
    fig[1, 1];
    limits = (0, 10, 0, 10),
    aspect = DataAspect(),
    xticks = 1:10,
    yticks = 1:10,
    xgridcolor = :grey25,
    ygridcolor = :grey25
)

plt = rgbdiscs!(ax, 5, 5)

#-
#| echo: false
fig


# #### Plot reactivity

# Reactivity is executed by calling the `Makie.update!` function
# on the plot.
# This function has a method that takes the plot as its
# sole positional argument, followed by a set of keyword arguments
# that provide the new values for the states of the input nodes.
#
# Input nodes corresponding to positional arguments
# are referenced by `arg1`, `arg2`, etc. keywords,
# while, the keyword argument input nodes
# are referenced by their respective keyword labels.

# Here, the $x$ and $y$ coordinates are given by positional arguments,
# and so are referenced by `arg1` and `arg2`, respectively, while the remaining
# nodes are referenced by the given keyword names: `r`, `g`, `b`, `opacity`, `size`, and `overlap`.

# So, for example, the $x$-coordinate of the centroid of plot is determined by the
# first positional argument to the plotting function call (`rgbdiscs(x, y; ...)`
# and so is referenced as `arg1`.

update!(plt; arg1 = 7)

#-
#| echo: false
fig

# Similarly, updating `arg2` will result in the recomputation of the $y$-coordinate node, as this is determined by the second argument to the plotting function call:

update!(plt; arg2 = 7)

#-
#| echo: false
fig

# Keyword arguments are updated using their original names:


update!(plt; r = 0.0, g = 0.8, b = 1.0)

#-
#| echo: false
fig

#-
update!(plt; r = 0.8, overlap = 0.8, opacity = 0.15)

#-
#| echo: false
fig

#-
update!(
    plt;
    arg1 = 5,
    arg2 = 5,
    r = 0.6,
    g = 0.8,
    b = 0.8,
    overlap = 0.4,
    opacity = 0.4,
    size = 3
)

#-
#| echo: false
fig


# ## Architectural considerations

# Each and every argument passed to the a Makie plot
# function (`scatter!`, `lines!`, `linesegments!`, `text!` etc.) must correspond to a single output
#  node if that argument is meant to be reactive.
#
# Design should not build up visual complexity in terms of a series of plotting instructions.
# Design should focus on the transformations required to
# map the various input data to arguments passed to primitive plotting functions.
#
# Note that we cannot package the arguments into more complex structures, such as `tuple`, `struct`s or `dict`s.
#
#
# For example given:


using GLMakie
using Colors

struct AnnulusData
    n_segments::Int
end

struct AnnulusPlotConfiguration
    radius::Float64
    inner_radius::Float64
end

@recipe AnnulusPlot (
    annulus_data::AnnulusData,
    annulus_plot_configuration::AnnulusPlotConfiguration
) begin
end

# The following will not work:

# ::: {.callout-note title="`ComputeNodes` are not wrapped-values-by-proxy"}
#
# ```julia
# function Makie.plot!(plt::AnnulusPlot)
#     map!(
#         plt.attributes,
#         [:annulus_data, :annulus_plot_configuration],
#         [:plot_data, :plot_kwargs],
#     ) do annulus_data, annulus_configuration
#         plot_data = repeat([1.0], annulus_data.n_segments)
#         plot_kwargs = (;
#             color = 1:length(plot_data),
#             radius = annulus_plot_configuration.radius,
#             inner_radius = annulus_plot_configuration.inner_radius,
#         )
#         return (plot_data, plot_kwargs)
#     end
#     plot_data = plt.plot_data
#     plot_kwargs = plt.plot_kwargs
#     pie!(plt, 5, 5, plot_data;
#         color = plot_kwargs.color,  ## WILL NOT WORK!
#         radius = plot_kwargs.radius,  ## WILL NOT WORK!
#         inner_radius = plot_kwargs.inner_radius,
#     )
#     return plt
# end
# ```
# :::

# because `plot_kwargs`, is a `ComputeNode` and not a `AnnulusPlotConfiguratiuon` instance,
# and cannot be dereferenced in this way `plot_kwargs.color`, `plot_kwargs.radius`.

# Instead, each of the Makie plotting function argument that needs to be reactive has to
# be mapped to its own distinct `ComputeNode` object representing a distinct (output) node
# on the compute graph.


function Makie.plot!(plt::AnnulusPlot)
    map!(
        plt.attributes,
        [:annulus_data, :annulus_plot_configuration],
        [:plot_data, :plot_color, :plot_radius, :plot_inner_radius],
    ) do annulus_data, annulus_configuration
        plot_data = repeat([1.0], annulus_data.n_segments)
        return (
            plot_data,
            1:length(plot_data),
            annulus_configuration.radius,
            annulus_configuration.inner_radius,
        )
    end

    pie!(plt, 5, 5, plt.plot_data;
        color        = plt.plot_color,
        radius       = plt.plot_radius,
        inner_radius = plt.plot_inner_radius,
    )

    return plt
end


annulus_fig = Figure()
annulus_ax = Axis(
    annulus_fig[1, 1];
    limits = (0, 10, 0, 10),
    aspect = DataAspect(),
)

annulus_data = AnnulusData(6)
annulus_plot_configuration = AnnulusPlotConfiguration(2, 1)
annulus_plt = annulusplot!(annulus_ax, annulus_data, annulus_plot_configuration)

#-
#| echo: false
annulus_fig


# Reactivity through `Makie.update!`:

#-
#| echo: true
update!(annulus_plt; arg1 = AnnulusData(36), arg2 = AnnulusPlotConfiguration(3, 2))

#-
#| echo: false
annulus_fig