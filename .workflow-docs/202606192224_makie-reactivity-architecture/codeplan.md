---
date-created: 2026-06-20T18:12:11-07:00
workflow-instrument: codeplan
workflow-status: Proposed
workflow-agent-thread-id: codex/019ee2c5-3f99-73c1-ab0e-d938e2241d4e
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
---

# Codeplan: Makie reactive graph architecture

## Purpose

This codeplan turns `01_prd.md` into an implementation-facing architecture map.
It is written for tranche authors, task authors, implementation agents, and
review agents. It does not approve implementation by itself. The parent PRD
still has `workflow-status: Proposed`.

Read the updated notes in the PRD as follows:

- The current computations, annotation preparation, render channels, and
  accepted visible behavior are correct.
- The current ownership and scaffold names are wrong.
- The refactor must mine the current logic into a computation layer.
- The graph layer must call the computation layer and map input nodes to named
  output nodes.
- `Makie.plot!` must assemble the graph and create child primitives once.

## Required reading and active authorities

Downstream agents must read these project-local governance files line by line:

- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-makie.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-workflow-vocabulary.md`
- `STYLE-writing.md`

The bundled development-policy depot remains baseline authority where it does
not conflict with project-local governance.

Downstream agents must also read these parent and upstream primary sources:

- `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`
- `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`

## Architecture diagram

```text
Public Makie entrypoints
    Makie.plot(net; kwargs...)
    Makie.plot!(axis, net; kwargs...)
    phyloplot(net; kwargs...)
    phyloplot!(axis, net; kwargs...)
        |
        | Makie owns non-mutating and mutating entrypoint behavior.
        v
Makie-native public plot owner
    @recipe PhyloPlot (net,)
    public attributes remain unchanged
    direct dynamic entrypoint is Makie.update!(plot; ...)
        |
        | plot.attributes is the ComputeGraph.
        | Public inputs are :arg1/:net plus public attribute inputs.
        v
Makie.plot!(plot::PhyloPlot)
    1. register_phylo_graph!(plot)
    2. create_phylo_primitives!(plot, graph_outputs)
    3. return plot
        |
        | Makie.plot! does not compute layout.
        | Makie.plot! does not delete children for normal updates.
        | Makie.plot! does not dereference output nodes for primitive args.
        v
Reactive graph layer
    register input-to-output computations with map! or register_computation!
    call computation-layer functions inside graph callbacks
    expose one final output node per reactive primitive argument
        |
        | Intermediate nodes hold config, geometry, and channel structs.
        | Final primitive nodes must be separate and directly consumable.
        v
Computation layer
    resolve public inputs into a config value
    copy and prepare HybridNetwork for traversal
    compute geometry
    compute annotation tables
    compute primitive channels
    compute Rect3d data limits
        |
        | Pure or narrowly effect-free functions.
        | No ComputeGraph registration.
        | No Makie child primitive creation.
        | No caller-owned network mutation.
        v
Primitive output nodes
    :edge_segment_points
    :edge_segment_colors
    :edge_segment_linewidths
    :edge_segment_linestyle
    :node_bar_points
    :node_bar_colors
    :node_bar_linewidths
    :node_bar_linestyle
    :minor_edge_shaft_points
    :minor_edge_shaft_colors
    :minor_edge_shaft_linewidths
    :minor_edge_shaft_linestyle
    :minor_arrowhead_meshes
    :minor_arrowhead_colors
    :minor_arrowhead_strokecolors
    :minor_arrowhead_strokewidth
    :tip_label_positions / :tip_label_strings / ...
    :internal_node_name_positions / :internal_node_name_strings / ...
    :node_number_positions / :node_number_strings / ...
    :node_label_positions / :node_label_strings / ...
    :edge_label_positions / :edge_label_strings / ...
    :edge_length_positions / :edge_length_strings / ...
    :minor_gamma_label_positions / :minor_gamma_label_strings / ...
    :major_gamma_label_positions / :major_gamma_label_strings / ...
    :edge_number_positions / :edge_number_strings / ...
    :data_limits
        |
        | Direct computed nodes pass into child primitives.
        v
Stable child primitives
    linesegments!(plot, plot.edge_segment_points; ...)
    linesegments!(plot, plot.node_bar_points; ...)
    linesegments!(plot, plot.minor_edge_shaft_points; ...)
    poly!(plot, plot.minor_arrowhead_meshes; ...)
    text!(plot, plot.tip_label_positions; text = plot.tip_label_strings, ...)
    text!(plot, plot.internal_node_name_positions; text = ..., ...)
    text!(plot, plot.node_number_positions; text = ..., ...)
    text!(plot, plot.node_label_positions; text = ..., ...)
    text!(plot, plot.edge_label_positions; text = ..., ...)
    text!(plot, plot.edge_length_positions; text = ..., ...)
    text!(plot, plot.minor_gamma_label_positions; text = ..., ...)
    text!(plot, plot.major_gamma_label_positions; text = ..., ...)
    text!(plot, plot.edge_number_positions; text = ..., ...)
        |
        | Current scope has no child primitive update! reactions.
        | Hidden layers are typed empty outputs, not deleted children.
        v
Makie/ComputePipeline propagation
    Makie.update!(plot; edgecolor = ..., style = ..., arg1 = new_net, ...)
    updates graph inputs
    recomputes output nodes
    child primitives update through their connected computed inputs
```

## Responsibility map

| Target owner | Old scaffold mined for logic | Responsibility | Forbidden responsibility |
| --- | --- | --- | --- |
| `plot_config.jl` | `attribute_schema.jl`, limit validation in `recipe.jl` | Resolve public inputs into a config value and validate public limits. | Creating Makie child plots or registering graph nodes. |
| `network_layout.jl` | `layout_engine.jl` | Copy and prepare the network, compute node, edge, minor hybrid edge, and bound geometry. | Mutating the caller-owned `HybridNetwork`. |
| `annotation_tables.jl` | `plot_layout.jl` | Build node and edge annotation tables from the prepared network and geometry. | Creating text primitives. |
| `primitive_channels.jl` | `render_adapter.jl` | Compute segment, text, arrowhead, color, width, style, and limit payloads. | Calling `linesegments!`, `text!`, `poly!`, or `arrows2d!`. |
| `reactive_graph.jl` | no current owner | Register graph nodes and map public inputs to primitive outputs. | Dereferencing output nodes to construct primitives. |
| `recipe.jl` | `recipe.jl`, `render_adapter.jl` primitive calls only | Declare public recipe defaults, dispatch, create stable child primitives from graph outputs, and perform final `Makie.plot!` orchestration. | Broad `onany`, child deletion, layout calculation, render adapter ownership, replacing child primitives on update. |

## Naming decisions

Public names that survive:

- `PhyloPlot`
- `phyloplot`
- `phyloplot!`
- `plot`
- `plot!`
- all public attributes in the current public attribute surface
- public style symbols `:fulltree` and `:majortree`

Old internal scaffold names that must not survive as target architecture:

- `PhyloPlotAttributes`
- `PlotLayout`
- `PlotRenderLayers`
- `render_plot!`

These target names are normative for this PRD unless a future approved PRD or
tranche document amends them. A downstream agent must not keep old internal
names merely to reduce internal test churn.

## Computation layer type signatures

```julia
# Internal resolved config for public plot semantics.
# Replaces PhyloPlotAttributes.
# Owns normalized defaults, validated style, copied annotation DataFrames, and
# raw xlim/ylim inputs before final bound resolution.
struct PhyloPlotConfig{
        TXLimits,
        TYLimits,
        TTipOffset,
        TTipScale,
        TNodeScale,
        TEdgeScale,
        TNodeColor,
        TEdgeColor,
        TEdgeNumberColor,
        TNodeAlign,
        TEdgeAlign,
        TEdgeColorInput,
        TDefaultEdgeColor,
        TMajorHybridColor,
        TMinorHybridColor,
        TMinorLineType,
        TArrowLength,
        TEdgeWidthInput,
    }
    useedgelength::Bool
    showtiplabel::Bool
    shownodelabel::Bool
    shownodenumber::Bool
    showedgelength::Bool
    showedgenumber::Bool
    showgamma::Bool
    edgecolor::TEdgeColorInput
    defaultedgecolor::TDefaultEdgeColor
    majorhybridedgecolor::TMajorHybridColor
    minorhybridedgecolor::TMinorHybridColor
    edgewidth::TEdgeWidthInput
    minorlinetype::TMinorLineType
    arrowlen::TArrowLength
    nodelabel::DataFrames.DataFrame
    edgelabel::DataFrames.DataFrame
    nodecex::TNodeScale
    edgecex::TEdgeScale
    nodelabelcolor::TNodeColor
    edgelabelcolor::TEdgeColor
    edgenumbercolor::TEdgeNumberColor
    nodelabeladj::TNodeAlign
    edgelabeladj::TEdgeAlign
    tipoffset::TTipOffset
    tipcex::TTipScale
    xlim::TXLimits
    ylim::TYLimits
    style::Symbol
end

# Prepared plotting network.
# Owns the copied network that traversal helpers are allowed to mutate.
struct PlotNetwork{TNet}
    net::TNet
end

# Geometry computed from the prepared network.
# Successor to the current coordinate calculation logic; do not retain
# PlotGeometry as the target architecture name.
struct NetworkGeometry
    edge_x_lo::Vector{Float64}
    edge_x_hi::Vector{Float64}
    edge_y_lo::Vector{Float64}
    edge_y_hi::Vector{Float64}
    node_x::Vector{Float64}
    node_y::Vector{Float64}
    node_y_lo::Vector{Float64}
    node_y_hi::Vector{Float64}
    arrow_x_lo::Vector{Float64}
    arrow_x_hi::Vector{Float64}
    arrow_y_lo::Vector{Float64}
    arrow_y_hi::Vector{Float64}
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
end

# Bounds plus public limit validation messages.
# Successor to current bounds logic; do not retain PlotBounds as the target
# architecture name.
struct PlotExtent
    xmin::Float64
    xmax::Float64
    ymin::Float64
    ymax::Float64
    xlim_error_message::String
    ylim_error_message::String
end

# Annotation tables derived from geometry and the prepared network.
# Replaces PlotAnnotationData.
struct AnnotationTables
    labelnodes::Bool
    labeledges::Bool
    node_data::DataFrames.DataFrame
    edge_data::DataFrames.DataFrame
end

# Combined layout computation product.
# Replaces PlotLayout.
struct LayoutComputation
    geometry::NetworkGeometry
    extent::PlotExtent
    annotations::AnnotationTables
end

# Segment payload consumed by a single linesegments! child.
struct SegmentChannel{TLineStyle}
    points::Vector{Makie.Point2f}
    colors::Vector{Makie.RGBAf}
    linewidths::Vector{Float32}
    linestyle::TLineStyle
end

# Text payload consumed by a single text! child.
struct TextChannel{TAlign, TFont}
    positions::Vector{Makie.Point2f}
    strings::Vector{String}
    colors::Vector{Makie.RGBAf}
    fontsizes::Vector{Float32}
    align::TAlign
    font::TFont
end

# Arrowhead payload consumed by a single poly! child.
# TMesh must be concrete for typed empty mesh-vector outputs.
struct ArrowheadChannel{TMesh}
    meshes::Vector{TMesh}
    colors::Vector{Makie.RGBAf}
    strokecolors::Vector{Makie.RGBAf}
    strokewidth::Float32
end

# Final pure computation product for all primitive channels and data limits.
struct PrimitiveChannels{
        TEdgeSegments,
        TNodeBars,
        TMinorShafts,
        TArrowheads,
        TTipLabels,
        TInternalNames,
        TNodeNumbers,
        TNodeLabels,
        TEdgeLabels,
        TEdgeLengths,
        TMinorGamma,
        TMajorGamma,
        TEdgeNumbers,
    }
    edge_segments::TEdgeSegments
    node_bars::TNodeBars
    minor_edge_shafts::TMinorShafts
    minor_arrowheads::TArrowheads
    tip_labels::TTipLabels
    internal_node_names::TInternalNames
    node_numbers::TNodeNumbers
    node_labels::TNodeLabels
    edge_labels::TEdgeLabels
    edge_lengths::TEdgeLengths
    minor_gamma_labels::TMinorGamma
    major_gamma_labels::TMajorGamma
    edge_numbers::TEdgeNumbers
    data_limits::Makie.Rect3d
end
```

## Computation layer function signatures

```julia
# Normalize public attribute inputs into an internal config value.
# This function owns defaults such as style-dependent arrowlen and minorlinetype.
function resolve_plot_config(;
        useedgelength::Bool = false,
        showtiplabel::Bool = true,
        shownodelabel::Bool = false,
        shownodenumber::Bool = false,
        showedgelength::Bool = false,
        showedgenumber::Bool = false,
        showgamma::Bool = false,
        edgecolor = "black",
        defaultedgecolor = nothing,
        majorhybridedgecolor::AbstractString = "deepskyblue4",
        minorhybridedgecolor::AbstractString = "deepskyblue",
        edgewidth = 1,
        minorlinetype = nothing,
        arrowlen = nothing,
        nodelabel::DataFrames.AbstractDataFrame = DataFrames.DataFrame(),
        edgelabel::DataFrames.AbstractDataFrame = DataFrames.DataFrame(),
        nodecex = 1,
        edgecex = 1,
        nodelabelcolor = "black",
        edgelabelcolor = "black",
        edgenumbercolor = "grey",
        nodelabeladj = 1,
        edgelabeladj = [0.5, 0],
        tipoffset = 0,
        tipcex = 1,
        xlim = nothing,
        ylim = nothing,
        style::Symbol = :fulltree,
    )::PhyloPlotConfig
end

# Validate a public limit pair after default bounds are known.
# The returned value remains nothing or a 2-value limit accepted by resolve_data_limits.
function validate_limit_pair(limit, helper_message::AbstractString)
end

# Produce a caller-safe network copy for layout traversal.
# This function is allowed to mutate only the copied network stored in
# PlotNetwork.
function prepare_plot_network(
        net::PhyloNetworks.HybridNetwork,
    )::PlotNetwork{PhyloNetworks.HybridNetwork}
end

# Compute x/y geometry for nodes, edges, and minor hybrid edge arrows.
# This mines the current layout_engine.jl algorithm.
function compute_network_geometry(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
    )::NetworkGeometry
end

# Compute annotation tables and default bounds from the prepared network,
# normalized config, and geometry.
function compute_layout(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
        geometry::NetworkGeometry,
    )::LayoutComputation
end

# Resolve final x/y limits and convert them to a Makie Rect3d data limit.
function compute_data_limits(
        config::PhyloPlotConfig,
        extent::PlotExtent,
    )::Makie.Rect3d
end

# Resolve edge and minor-edge colors.
# This mines _resolve_edgecolors but returns primitive-ready RGBA values.
function compute_edge_colors(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
    )::NamedTuple{(:edgecolors, :minor_edgecolors, :defaultedgecolor)}
end

# Resolve edge and minor-edge widths.
# This mines _resolve_edgewidths but returns primitive-ready Float32 vectors.
function compute_edge_widths(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
    )::NamedTuple{(:edgewidths, :minor_edgewidths)}
end

# Convert segment coordinate vectors into a linesegments! point vector.
function compute_segment_points(
        x_lo::AbstractVector{<:Real},
        x_hi::AbstractVector{<:Real},
        y_lo::AbstractVector{<:Real},
        y_hi::AbstractVector{<:Real},
    )::Vector{Makie.Point2f}
end

# Resolve the current minorlinetype policy.
function compute_minor_edge_style(minorlinetype)
end

# Compute edge, node-bar, and minor-edge shaft segment channels.
function compute_segment_channels(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
        layout::LayoutComputation,
    )::NamedTuple{(:edge_segments, :node_bars, :minor_edge_shafts)}
end

# Compute arrowhead metrics from arrowlen and minor edge widths.
# This preserves current arrow length and width behavior.
function compute_arrowhead_metrics(
        arrowlen::Real,
        minor_edgewidths::AbstractVector{<:Real},
    )::NamedTuple{(:tiplengths, :tipwidths)}
end

# Compute concrete arrowhead meshes from minor hybrid edge endpoints and metrics.
# This replaces per-edge arrows2d! children with vectorized poly! geometry.
function compute_arrowhead_channel(
        minor_edge_points::SegmentChannel,
        colors::AbstractVector{Makie.RGBAf},
        tiplengths::AbstractVector{<:Real},
        tipwidths::AbstractVector{<:Real},
        render_visible::Bool,
    )::ArrowheadChannel
end

# Compute text sizes from current cex behavior.
function compute_text_sizes(text_cex, count::Integer)::Vector{Float32}
end

# Normalize nodelabeladj and edgelabeladj values for Makie text align.
function compute_text_align(adjustment)
end

# Compute one semantic text channel.
# Hidden text layers return typed empty positions, strings, colors, and sizes.
function compute_text_channel(
        table::DataFrames.AbstractDataFrame,
        rows,
        text_column::Symbol,
        color::Makie.RGBAf,
        fontsize::AbstractVector{<:Real},
        align,
        font,
        x_offset::Real = 0.0,
    )::TextChannel
end

# Compute all text channels that the current render adapter renders.
function compute_text_channels(
        config::PhyloPlotConfig,
        layout::LayoutComputation,
    )::NamedTuple{
        (
            :tip_labels,
            :internal_node_names,
            :node_numbers,
            :node_labels,
            :edge_labels,
            :edge_lengths,
            :minor_gamma_labels,
            :major_gamma_labels,
            :edge_numbers,
        )
    }
end

# Compute the full primitive payload.
# Unit tests for this function must not construct a Makie figure.
function compute_primitive_channels(
        plot_network::PlotNetwork{<:PhyloNetworks.HybridNetwork},
        config::PhyloPlotConfig,
        layout::LayoutComputation,
    )::PrimitiveChannels
end
```

## Reactive graph layer type signatures

```julia
# Names for one linesegments! layer's primitive arguments.
# Fields are Symbols so tests can audit node existence without inspecting
# plot.plots.
struct SegmentGraphOutputs
    points::Symbol
    colors::Symbol
    linewidths::Symbol
    linestyle::Symbol
end

# Names for the single poly! arrowhead layer's primitive arguments.
struct ArrowheadGraphOutputs
    meshes::Symbol
    colors::Symbol
    strokecolors::Symbol
    strokewidth::Symbol
end

# Names of final non-text output groups used by Makie.plot! to create
# primitives and expose data limits.
struct PhyloGraphOutputs
    edge_segments::SegmentGraphOutputs
    node_bars::SegmentGraphOutputs
    minor_edge_shafts::SegmentGraphOutputs
    minor_arrowheads::ArrowheadGraphOutputs
    data_limits::Symbol
end

# Names for one text layer's primitive arguments.
struct TextGraphOutputs
    positions::Symbol
    strings::Symbol
    colors::Symbol
    fontsizes::Symbol
    align::Symbol
    font::Symbol
end

# Names of all text-layer output groups.
struct PhyloTextGraphOutputs
    tip_labels::TextGraphOutputs
    internal_node_names::TextGraphOutputs
    node_numbers::TextGraphOutputs
    node_labels::TextGraphOutputs
    edge_labels::TextGraphOutputs
    edge_lengths::TextGraphOutputs
    minor_gamma_labels::TextGraphOutputs
    major_gamma_labels::TextGraphOutputs
    edge_numbers::TextGraphOutputs
end
```

## Reactive graph layer function signatures

```julia
# Register all computations needed by PhyloPlot.
# This function is idempotent for a plot graph and owns the node map.
function register_phylo_graph!(plot::PhyloPlot)::NamedTuple{
        (:primitive_outputs, :text_outputs),
        Tuple{PhyloGraphOutputs, PhyloTextGraphOutputs},
    }
end

# Register the normalized config node from public attribute inputs.
# Output node: :plot_config.
function register_plot_config_node!(plot::PhyloPlot)::Symbol
end

# Register the copied and traversal-prepared network node.
# Output node: :plot_network.
function register_plot_network_node!(plot::PhyloPlot)::Symbol
end

# Register layout geometry and annotation products.
# Output nodes: :network_geometry, :layout_computation.
function register_layout_nodes!(
        plot::PhyloPlot,
        config_node::Symbol,
        network_node::Symbol,
    )::NamedTuple{(:geometry, :layout)}
end

# Register all primitive channels as an intermediate computation node.
# Output node: :primitive_channels.
function register_primitive_channel_node!(
        plot::PhyloPlot,
        network_node::Symbol,
        config_node::Symbol,
        layout_node::Symbol,
    )::Symbol
end

# Split segment channels into one output node per linesegments! argument.
function register_segment_output_nodes!(
        plot::PhyloPlot,
        primitive_channels_node::Symbol,
    )::NamedTuple{
        (:edge_segments, :node_bars, :minor_edge_shafts),
        Tuple{SegmentGraphOutputs, SegmentGraphOutputs, SegmentGraphOutputs},
    }
end

# Split text channels into one output node per text! argument.
function register_text_output_nodes!(
        plot::PhyloPlot,
        primitive_channels_node::Symbol,
    )::PhyloTextGraphOutputs
end

# Split arrowhead channels into one output node per poly! argument.
function register_arrowhead_output_nodes!(
        plot::PhyloPlot,
        primitive_channels_node::Symbol,
    )::ArrowheadGraphOutputs
end

# Register the top-level data_limits output.
# Makie.data_limits(plot) must read this node through plot.data_limits[].
function register_data_limits_node!(
        plot::PhyloPlot,
        primitive_channels_node::Symbol,
    )::Symbol
end
```

## Graph mapping sketch

```julia
function register_phylo_graph!(plot::PhyloPlot)
    config_node = register_plot_config_node!(plot)
    network_node = register_plot_network_node!(plot)
    layout_nodes = register_layout_nodes!(plot, config_node, network_node)
    channels_node = register_primitive_channel_node!(
        plot,
        network_node,
        config_node,
        layout_nodes.layout,
    )

    segment_outputs = register_segment_output_nodes!(plot, channels_node)
    text_outputs = register_text_output_nodes!(plot, channels_node)
    arrowhead_outputs = register_arrowhead_output_nodes!(plot, channels_node)
    data_limits = register_data_limits_node!(plot, channels_node)

    primitive_outputs = PhyloGraphOutputs(
        segment_outputs.edge_segments,
        segment_outputs.node_bars,
        segment_outputs.minor_edge_shafts,
        arrowhead_outputs,
        data_limits,
    )

    # No output node should be dereferenced here for primitive construction.
    return (primitive_outputs = primitive_outputs, text_outputs = text_outputs)
end
```

## Makie.plot assembly type signatures

```julia
# Child plot handles only.
# Replaces PlotRenderLayers, which mixed handles and snapshot values.
struct PhyloPrimitiveHandles{
        TEdgeSegments,
        TNodeBars,
        TMinorShafts,
        TArrowheads,
        TTipLabels,
        TInternalNames,
        TNodeNumbers,
        TNodeLabels,
        TEdgeLabels,
        TEdgeLengths,
        TMinorGamma,
        TMajorGamma,
        TEdgeNumbers,
    }
    edge_segments::TEdgeSegments
    node_bars::TNodeBars
    minor_edge_shafts::TMinorShafts
    minor_arrowheads::TArrowheads
    tip_labels::TTipLabels
    internal_node_names::TInternalNames
    node_numbers::TNodeNumbers
    node_labels::TNodeLabels
    edge_labels::TEdgeLabels
    edge_lengths::TEdgeLengths
    minor_gamma_labels::TMinorGamma
    major_gamma_labels::TMajorGamma
    edge_numbers::TEdgeNumbers
end
```

## Makie.plot assembly function signatures

```julia
# Create all stable child primitives once.
# This function must pass computed nodes directly to primitive calls.
function create_phylo_primitives!(
        plot::PhyloPlot,
        primitive_outputs::PhyloGraphOutputs,
        text_outputs::PhyloTextGraphOutputs,
    )::PhyloPrimitiveHandles
end

# Create one linesegments! child.
function create_segment_primitive!(
        plot::PhyloPlot,
        outputs::SegmentGraphOutputs,
    )
end

# Create the single poly! child for all current hybrid arrowheads.
function create_arrowhead_primitive!(
        plot::PhyloPlot,
        outputs::ArrowheadGraphOutputs,
    )
end

# Create one text! child.
function create_text_primitive!(
        plot::PhyloPlot,
        outputs::TextGraphOutputs,
    )
end

```

## Makie.plot integration signature

```julia
function Makie.plot!(plot::PhyloPlot)
    outputs = register_phylo_graph!(plot)
    create_phylo_primitives!(
        plot,
        outputs.primitive_outputs,
        outputs.text_outputs,
    )
    return plot
end
```

The final `Makie.plot!` body must not contain:

- `Makie.onany` over all public attributes
- child deletion for normal updates
- `empty!(plot.plots)` for normal updates
- `deepcopy(net)` directly in `Makie.plot!`
- `prepare_plot_layout(...)` directly in `Makie.plot!`
- `render_plot!(...)`
- dereferencing output nodes to pass snapshots into primitives

## Required primitive calls

```julia
function create_phylo_primitives!(
        plot::PhyloPlot,
        primitive_outputs::PhyloGraphOutputs,
        text_outputs::PhyloTextGraphOutputs,
    )::PhyloPrimitiveHandles

    edge_segments = Makie.linesegments!(
        plot,
        plot[primitive_outputs.edge_segments.points];
        color = plot[primitive_outputs.edge_segments.colors],
        linewidth = plot[primitive_outputs.edge_segments.linewidths],
        linestyle = plot[primitive_outputs.edge_segments.linestyle],
    )

    node_bars = Makie.linesegments!(
        plot,
        plot[primitive_outputs.node_bars.points];
        color = plot[primitive_outputs.node_bars.colors],
        linewidth = plot[primitive_outputs.node_bars.linewidths],
        linestyle = plot[primitive_outputs.node_bars.linestyle],
    )

    minor_edge_shafts = Makie.linesegments!(
        plot,
        plot[primitive_outputs.minor_edge_shafts.points];
        color = plot[primitive_outputs.minor_edge_shafts.colors],
        linewidth = plot[primitive_outputs.minor_edge_shafts.linewidths],
        linestyle = plot[primitive_outputs.minor_edge_shafts.linestyle],
    )

    minor_arrowheads = Makie.poly!(
        plot,
        plot[primitive_outputs.minor_arrowheads.meshes];
        color = plot[primitive_outputs.minor_arrowheads.colors],
        strokecolor = plot[primitive_outputs.minor_arrowheads.strokecolors],
        strokewidth = plot[primitive_outputs.minor_arrowheads.strokewidth],
    )

    tip_labels = create_text_primitive!(plot, text_outputs.tip_labels)
    internal_node_names = create_text_primitive!(plot, text_outputs.internal_node_names)
    node_numbers = create_text_primitive!(plot, text_outputs.node_numbers)
    node_labels = create_text_primitive!(plot, text_outputs.node_labels)
    edge_labels = create_text_primitive!(plot, text_outputs.edge_labels)
    edge_lengths = create_text_primitive!(plot, text_outputs.edge_lengths)
    minor_gamma_labels = create_text_primitive!(plot, text_outputs.minor_gamma_labels)
    major_gamma_labels = create_text_primitive!(plot, text_outputs.major_gamma_labels)
    edge_numbers = create_text_primitive!(plot, text_outputs.edge_numbers)

    return PhyloPrimitiveHandles(
        edge_segments,
        node_bars,
        minor_edge_shafts,
        minor_arrowheads,
        tip_labels,
        internal_node_names,
        node_numbers,
        node_labels,
        edge_labels,
        edge_lengths,
        minor_gamma_labels,
        major_gamma_labels,
        edge_numbers,
    )
end

function create_text_primitive!(plot::PhyloPlot, outputs::TextGraphOutputs)
    return Makie.text!(
        plot,
        plot[outputs.positions];
        text = plot[outputs.strings],
        color = plot[outputs.colors],
        fontsize = plot[outputs.fontsizes],
        align = plot[outputs.align],
        font = plot[outputs.font],
    )
end
```

## Testing signatures

```julia
# Computation tests: no Figure, Axis, ComputeGraph, or child primitives.
function test_resolve_plot_config_defaults()::Nothing end
function test_compute_network_geometry_preserves_current_coordinates()::Nothing end
function test_compute_annotation_tables_preserves_current_labels()::Nothing end
function test_compute_primitive_channels_preserves_render_channels()::Nothing end
function test_compute_arrowhead_channel_returns_concrete_typed_empty_meshes()::Nothing end

# Graph tests: create a PhyloPlot and inspect graph nodes after registration.
function test_register_phylo_graph_names_all_required_outputs()::Nothing end
function test_makie_update_recomputes_segment_outputs()::Nothing end
function test_makie_update_recomputes_text_outputs_atomically()::Nothing end
function test_makie_update_recomputes_data_limits()::Nothing end

# Integration tests: create figures and verify visible behavior.
function test_plot_update_does_not_recreate_child_primitives()::Nothing end
function test_arrowheads_use_one_poly_child_not_per_edge_arrows2d()::Nothing end
function test_hidden_layers_use_empty_outputs_not_deleted_children()::Nothing end
function test_public_surfaces_preserve_existing_render_behavior()::Nothing end
```

## Suggested tranche reading

This is not a tranche file, but a tranche author should read the architecture
in this order:

1. Computation foundation: introduce target computation types and functions,
   migrate tests away from old scaffold names, and prove current values match.
2. Reactive graph foundation: register graph nodes and prove recomputation
   through `Makie.update!` without primitive construction changes.
3. Primitive assembly integration: replace `render_plot!` and broad rebuild
   `Makie.plot!` with stable primitives using direct computed nodes.
4. Verification and docs alignment: update public docs, render verification,
   source audits, and visual artifacts.

Every tranche must begin green and end green for its declared scope. If a
tranche cannot preserve green state, split it before implementation.

## Handoff packet

- **Active authorities**: project-local governance files listed above, bundled
  development-policy baseline, parent PRD after approval, this codeplan after
  approval.
- **Parent documents**: `01_prd.md`, Makie interactivity tutorial, current
  source files under `src/`, current tests under `test/`.
- **Settled decisions**: keep public plot surfaces and attributes; purge old
  internal scaffold names; use direct computed primitive arguments; use
  `poly!` for hybrid arrowheads; do not implement pointer interactions.
- **Authorization boundary**: deep internal redesign is authorized; public
  surface renames and external breaking changes are not authorized.
- **Current-state diagnosis**: current `Makie.plot!` uses broad rebuild
  reactivity and `render_plot!` owns too many responsibilities.
- **Owner and invariant under repair**: repair the ownership boundary between
  computation, graph registration, Makie.plot assembly, and public recipe
  orchestration.
- **Direct red-state repros**: broad `onany`, child deletion on update,
  direct compute-node mutation tests without `Makie.update!`, dynamic per-edge
  `arrows2d!` children for current arrowheads, old scaffold names as target
  architecture.
- **Exact scope in**: architecture planning and implementation signatures for
  the reactive graph refactor.
- **Exact scope out**: pointer interactions, public attribute renaming, R
  interoperability, non-`HybridNetwork` inputs, performance optimization
  beyond avoiding full rebuild architecture.
- **Required upstream primary sources**: Makie and ComputePipeline sources
  listed above.
- **Green-state gates**: full tests, docs build, computation-layer tests,
  graph-layer tests, direct `Makie.update!` tests, visual/render checks, and
  source audits for forbidden old shapes.
- **Stop conditions**: stop if a downstream plan preserves old scaffold names
  as target architecture; stop if it reintroduces broad rebuild callbacks;
  stop if it dereferences graph outputs before primitive construction; stop if
  it implements pointer interactions under this PRD; stop if upstream Makie
  contract verification contradicts this codeplan.
