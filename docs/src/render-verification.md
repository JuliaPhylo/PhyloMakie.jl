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

function build_render_case(
    newick::AbstractString;
    figure_size::Tuple{Int, Int}=(640, 400),
    kwargs...,
)
    resolve_phylo_plot_attributes = getfield(PhyloMakie, :resolve_phylo_plot_attributes)
    prepare_plot_layout = getfield(PhyloMakie, :prepare_plot_layout)
    render_plot! = getfield(PhyloMakie, :render_plot!)

    network = PhyloNetworks.readnewick(newick)
    attributes = resolve_phylo_plot_attributes(; kwargs...)
    layout = prepare_plot_layout(network, attributes; preorder=true)
    figure = Figure(size=figure_size)
    axis = Axis(figure[1, 1])
    hidedecorations!(axis)
    hidespines!(axis)
    layers = render_plot!(axis, network, attributes, layout)
    return (; network, attributes, layout, figure, axis, layers)
end

function render_into_axis!(axis, newick::AbstractString; kwargs...)
    resolve_phylo_plot_attributes = getfield(PhyloMakie, :resolve_phylo_plot_attributes)
    prepare_plot_layout = getfield(PhyloMakie, :prepare_plot_layout)
    render_plot! = getfield(PhyloMakie, :render_plot!)

    network = PhyloNetworks.readnewick(newick)
    attributes = resolve_phylo_plot_attributes(; kwargs...)
    layout = prepare_plot_layout(network, attributes; preorder=true)
    layers = render_plot!(axis, network, attributes, layout)
    return (; network, attributes, layout, layers)
end
```

## Style distinction artifact

This live artifact renders the accepted reticulate network through the same
internal owner under the governed `:fulltree` and `:majortree` style branches.

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
    | Full-tree | `$(fulltree_case.layers.resolved_style)` | `$(fulltree_case.layers.minor_edge_shafts.linestyle)` |
    | Major-tree | `$(majortree_case.layers.resolved_style)` | `$(majortree_case.layers.minor_edge_shafts.linestyle)` |
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
    | Default edge fallback | `$(unique(color_case.layers.node_bars.colors))` |
    | Minor edge colors | `$(unique(color_case.layers.minor_edge_shafts.colors))` |
    | Minor gamma text colors | `$(unique(color_case.layers.minor_gamma_labels.colors))` |
    | Major gamma text colors | `$(unique(color_case.layers.major_gamma_labels.colors))` |
    | Edge widths | `$(color_case.layers.edge_segments.linewidths)` |
    """,
)
```

## Text-layer and explicit-limit artifact

This artifact proves that text layers and final limits are consumed from
`PlotLayout.annotations` and `PlotBounds` rather than recomputed inside the
render owner.

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
    | Applied x limits | `$(annotation_case.layers.applied_xlim)` |
    | Applied y limits | `$(annotation_case.layers.applied_ylim)` |
    | Tip labels | `$(annotation_case.layers.tip_labels.strings)` |
    | Internal node names | `$(annotation_case.layers.internal_node_names.strings)` |
    | Node numbers | `$(annotation_case.layers.node_numbers.strings)` |
    | Edge numbers | `$(annotation_case.layers.edge_numbers.strings)` |
    | Edge lengths | `$(annotation_case.layers.edge_lengths.strings)` |
    | Minor gamma labels | `$(annotation_case.layers.minor_gamma_labels.strings)` |
    | Major gamma labels | `$(annotation_case.layers.major_gamma_labels.strings)` |
    """,
)
```
