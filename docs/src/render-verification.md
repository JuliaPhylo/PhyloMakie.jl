```@meta
CurrentModule = PhyloMakie
```

# Render verification

Tranche 4 closed the internal render owner
`render_plot!(target, net, spec, layout)::PlotRenderLayers`, and tranche 5 now
reuses that same owner directly from the Makie-native public recipe layer.
The artifacts below still exercise the internal compatibility, helper, and
render owners directly from live CairoMakie code and the repo-owned fixture
corpus. The public entry surfaces themselves are documented on
[Public API](public-api.md).

## Render owner summary

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
owner = foundation.render_owner
rows = [
    "| Field | Live value |",
    "| --- | --- |",
    "| Typed layer bundle | `$(owner.typed_layer_bundle)` |",
    "| Primitive entrypoints | $(join(["`$(primitive)`" for primitive in owner.primitive_entrypoints], ", ")) |",
    "| Regression suites | $(join(["`$(suite)`" for suite in owner.regression_suites], ", ")) |",
]
Markdown.parse(join(rows, "\n"))
```

```@setup render_docs
using CairoMakie
using Makie
using Markdown
using PhyloMakie

CairoMakie.activate!()

const DataFrames = getfield(PhyloMakie, :DataFrames)
const PhyloNetworks = getfield(PhyloMakie, :PhyloNetworks)

include(joinpath(dirname(pathof(PhyloMakie)), "..", "test", "support", "fixture_corpus.jl"))

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
    normalize_plot_keywords = getfield(PhyloMakie, :normalize_plot_keywords)
    prepare_plot_layout = getfield(PhyloMakie, :prepare_plot_layout)
    render_plot! = getfield(PhyloMakie, :render_plot!)

    network = PhyloNetworks.readnewick(newick)
    spec = normalize_plot_keywords(; kwargs...)
    layout = prepare_plot_layout(network, spec)
    figure = Figure(size=figure_size)
    axis = Axis(figure[1, 1])
    hidedecorations!(axis)
    hidespines!(axis)
    layers = render_plot!(axis, network, spec, layout)
    return (; network, spec, layout, figure, axis, layers)
end

function render_into_axis!(axis, newick::AbstractString; kwargs...)
    normalize_plot_keywords = getfield(PhyloMakie, :normalize_plot_keywords)
    prepare_plot_layout = getfield(PhyloMakie, :prepare_plot_layout)
    render_plot! = getfield(PhyloMakie, :render_plot!)

    network = PhyloNetworks.readnewick(newick)
    spec = normalize_plot_keywords(; kwargs...)
    layout = prepare_plot_layout(network, spec)
    layers = render_plot!(axis, network, spec, layout)
    return (; network, spec, layout, layers)
end
```

## Style distinction artifact

This live artifact renders the accepted reticulate network through the same
internal owner under the governed `:fulltree` and `:majortree` style branches.

```@example render_docs
style_fixture = FIXTURE_CORPUS.render_regression_cases # hide
style_figure = Figure(size=(900, 360)) # hide
fulltree_axis = Axis(style_figure[1, 1], title="Full-tree style") # hide
hidedecorations!(fulltree_axis) # hide
hidespines!(fulltree_axis) # hide
fulltree_case = render_into_axis!( # hide
    fulltree_axis, # hide
    style_fixture.style_fulltree.newick; # hide
    style_fixture.style_fulltree.keyword_args..., # hide
) # hide
majortree_axis = Axis(style_figure[1, 2], title="Major-tree style") # hide
hidedecorations!(majortree_axis) # hide
hidespines!(majortree_axis) # hide
majortree_case = render_into_axis!( # hide
    majortree_axis, # hide
    style_fixture.style_majortree.newick; # hide
    style_fixture.style_majortree.keyword_args..., # hide
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
color_fixture = FIXTURE_CORPUS.render_regression_cases.gamma_and_edgecolor # hide
color_case = build_render_case( # hide
    color_fixture.newick; # hide
    color_fixture.keyword_args..., # hide
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
annotation_fixture = FIXTURE_CORPUS.render_regression_cases.annotation_and_limits # hide
node_labels = render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows) # hide
edge_labels = render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows) # hide
annotation_case = build_render_case( # hide
    annotation_fixture.newick; # hide
    annotation_fixture.keyword_args..., # hide
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
