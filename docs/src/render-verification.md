```@meta
CurrentModule = PhyloMakie
```

# Render verification

The artifacts below exercise the live CairoMakie rendering path used by
PhyloMakie. They render directly from package code and docs-local case data so
the page stays live without depending on test support files. The public entry
surfaces themselves are documented on [Public API](public-api.md).

```@setup render_docs
using CairoMakie
using Makie
using Markdown
using PhyloMakie

CairoMakie.activate!()

const DataFrames = PhyloMakie.DataFrames
const PhyloNetworks = PhyloMakie.PhyloNetworks

const RENDER_CASES = (
    style_fulltree = (
        newick = "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
        attribute_kwargs = (useedgelength = true, style = :fulltree),
    ),
    style_majortree = (
        newick = "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
        attribute_kwargs = (useedgelength = true, style = :majortree),
    ),
    gamma_and_edgecolor = (
        newick = "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
        edgecolor_overrides = ((1, "tomato4"), (3, "tan"), (7, "skyblue")),
        edgewidth_overrides = ((1, 2.0), (3, 3.0), (7, 4.0)),
        defaultedgecolor = "black",
        attribute_kwargs = (useedgelength = true, style = :fulltree, showgamma = true),
    ),
    annotation_and_limits = (
        newick = "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
        xlim = (0.0, 6.5),
        ylim = (0.0, 5.5),
        attribute_kwargs = (
            useedgelength = true,
            style = :majortree,
            shownodelabel = true,
            shownodenumber = true,
            showedgenumber = true,
            showedgelength = true,
            showgamma = true,
        ),
    ),
)

const ANNOTATION_ROWS = (
    nodelabel_render_rows = (
        columns = (:node, :bs),
        rows = (
            (node = -5, bs = "90"),
            (node = -3, bs = "95"),
            (node = -4, bs = "99"),
            (node = 5, bs = "mytips"),
        ),
    ),
    edgelabel_filtered_rows = (
        columns = (:edge, :bs),
        rows = (
            (edge = 8, bs = missing),
            (edge = 9, bs = "95"),
            (edge = 4, bs = "99"),
            (edge = 6, bs = "mytips"),
        ),
    ),
)

function render_fixture_dataframe(table_fixture)
    return DataFrames.DataFrame(
        [column => [row[column] for row in table_fixture.rows] for column in table_fixture.columns]...,
    )
end

function render_limits_tuple(rect::Makie.Rect3d)
    rect_min = minimum(rect)
    rect_max = maximum(rect)
    return (
        (Float64(rect_min[1]), Float64(rect_max[1])),
        (Float64(rect_min[2]), Float64(rect_max[2])),
    )
end

function render_children(plot)
    return (
        edge_segments = plot.plots[1],
        node_bars = plot.plots[2],
        minor_edge_shafts = plot.plots[3],
        minor_arrowheads = plot.plots[4],
        tip_labels = plot.plots[5],
        internal_node_names = plot.plots[6],
        node_numbers = plot.plots[7],
        node_labels = plot.plots[8],
        edge_labels = plot.plots[9],
        edge_lengths = plot.plots[10],
        minor_gamma_labels = plot.plots[11],
        major_gamma_labels = plot.plots[12],
        edge_numbers = plot.plots[13],
    )
end

function render_snapshot(network, figure, axis, plot)
    return (;
        network,
        figure,
        axis,
        plot,
        config = plot[:plot_config][],
        prepared_network = plot[:plot_network][].net,
        layout = plot[:layout_computation][],
        channels = plot[:primitive_channels][],
        children = render_children(plot),
        child_count = length(plot.plots),
        child_ids = objectid.(plot.plots),
    )
end

function build_render_case(
    newick::AbstractString;
    figure_size::Tuple{Int, Int}=(640, 400),
    kwargs...,
)
    network = PhyloNetworks.readnewick(newick)
    figure = Figure(size=figure_size)
    axis = Axis(figure[1, 1])
    hidedecorations!(axis)
    hidespines!(axis)
    plot = Makie.plot!(axis, network; kwargs...)
    return render_snapshot(network, figure, axis, plot)
end

function render_into_axis!(axis, newick::AbstractString; kwargs...)
    network = PhyloNetworks.readnewick(newick)
    plot = Makie.plot!(axis, network; kwargs...)
    return render_snapshot(network, nothing, axis, plot)
end
```

## Style distinction artifact

This live artifact renders the accepted reticulate network through the public
Makie path under the governed `:fulltree` and `:majortree` style branches.

```@example render_docs
style_fixture = RENDER_CASES # hide
style_figure = Figure(size=(900, 360)) # hide
fulltree_axis = Axis(style_figure[1, 1], title="Full-tree style") # hide
hidedecorations!(fulltree_axis) # hide
hidespines!(fulltree_axis) # hide
fulltree_case = render_into_axis!( # hide
    fulltree_axis, # hide
    style_fixture.style_fulltree.newick; # hide
    style_fixture.style_fulltree.attribute_kwargs..., # hide
) # hide
majortree_axis = Axis(style_figure[1, 2], title="Major-tree style") # hide
hidedecorations!(majortree_axis) # hide
hidespines!(majortree_axis) # hide
majortree_case = render_into_axis!( # hide
    majortree_axis, # hide
    style_fixture.style_majortree.newick; # hide
    style_fixture.style_majortree.attribute_kwargs..., # hide
) # hide
style_figure
```

```@example render_docs
Markdown.parse(
    """
    | Style | Resolved style | Minor-edge shaft linestyle |
    | --- | --- | --- |
    | Full-tree | `$(fulltree_case.config.style)` | `$(fulltree_case.channels.minor_edge_shafts.linestyle)` |
    | Major-tree | `$(majortree_case.config.style)` | `$(majortree_case.channels.minor_edge_shafts.linestyle)` |
    """,
)
```

## Edge-color, gamma-color, and width artifact

This artifact exercises dict-driven `edgecolor`, `defaultedgecolor`,
major/minor hybrid colors, scalar-versus-dict width handling, and gamma text
color independence in one live render.

```@example render_docs
color_fixture = RENDER_CASES.gamma_and_edgecolor # hide
color_case = build_render_case( # hide
    color_fixture.newick; # hide
    color_fixture.attribute_kwargs..., # hide
    edgecolor=Dict(color_fixture.edgecolor_overrides), # hide
    defaultedgecolor=color_fixture.defaultedgecolor, # hide
    edgewidth=Dict(color_fixture.edgewidth_overrides), # hide
) # hide
color_case.figure
```

```@example render_docs
Markdown.parse(
    """
    | Proof surface | Live value |
    | --- | --- |
    | Dict override edges | `$(collect(keys(Dict(color_fixture.edgecolor_overrides))))` |
    | Stable child count | `$(color_case.child_count)` |
    | Default edge fallback | `$(unique(color_case.channels.node_bars.colors))` |
    | Minor edge colors | `$(unique(color_case.channels.minor_edge_shafts.colors))` |
    | Minor gamma text colors | `$(unique(color_case.channels.minor_gamma_labels.colors))` |
    | Major gamma text colors | `$(unique(color_case.channels.major_gamma_labels.colors))` |
    | Edge widths | `$(color_case.channels.edge_segments.linewidths)` |
    """,
)
```

## Text-layer and explicit-limit artifact

This artifact proves that text channels and final limits are consumed from the
registered layout, primitive-channel, and data-limit graph outputs.

```@example render_docs
annotation_fixture = RENDER_CASES.annotation_and_limits # hide
node_labels = render_fixture_dataframe(ANNOTATION_ROWS.nodelabel_render_rows) # hide
edge_labels = render_fixture_dataframe(ANNOTATION_ROWS.edgelabel_filtered_rows) # hide
annotation_case = build_render_case( # hide
    annotation_fixture.newick; # hide
    annotation_fixture.attribute_kwargs..., # hide
    nodelabel=node_labels, # hide
    edgelabel=edge_labels, # hide
    xlim=annotation_fixture.xlim, # hide
    ylim=annotation_fixture.ylim, # hide
) # hide
annotation_case.figure
```

```@example render_docs
Markdown.parse(
    """
    | Proof surface | Live value |
    | --- | --- |
    | Applied x limits | `$(render_limits_tuple(Makie.data_limits(annotation_case.plot))[1])` |
    | Applied y limits | `$(render_limits_tuple(Makie.data_limits(annotation_case.plot))[2])` |
    | Graph data limits match Makie | `$(annotation_case.channels.data_limits == Makie.data_limits(annotation_case.plot))` |
    | Tip labels | `$(annotation_case.channels.tip_labels.strings)` |
    | Internal node names | `$(annotation_case.channels.internal_node_names.strings)` |
    | Node numbers | `$(annotation_case.channels.node_numbers.strings)` |
    | Edge numbers | `$(annotation_case.channels.edge_numbers.strings)` |
    | Edge lengths | `$(annotation_case.channels.edge_lengths.strings)` |
    | Minor gamma labels | `$(annotation_case.channels.minor_gamma_labels.strings)` |
    | Major gamma labels | `$(annotation_case.channels.major_gamma_labels.strings)` |
    """,
)
```
