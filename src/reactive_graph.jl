struct SegmentGraphOutputs
    points::Symbol
    colors::Symbol
    linewidths::Symbol
    linestyle::Symbol
end

struct ArrowheadGraphOutputs
    startpoints::Symbol
    endpoints::Symbol
    tiplengths::Symbol
    tipwidths::Symbol
    meshes::Symbol
    colors::Symbol
    strokecolors::Symbol
    strokewidth::Symbol
end

struct ImageGraphOutputs
    positions::Symbol
    images::Symbol
    render_markers::Symbol
    markersizes::Symbol
    marker_offsets::Symbol
end

struct PhyloGraphOutputs
    edge_segments::SegmentGraphOutputs
    node_bars::SegmentGraphOutputs
    minor_edge_shafts::SegmentGraphOutputs
    minor_arrowheads::ArrowheadGraphOutputs
    edge_images::ImageGraphOutputs
    node_images::ImageGraphOutputs
    data_limits::Symbol
end

struct TextGraphOutputs
    positions::Symbol
    strings::Symbol
    colors::Symbol
    fontsizes::Symbol
    align::Symbol
    font::Symbol
end

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

const PLOT_CONFIG_INPUT_SYMBOLS = (
    :useedgelength,
    :showtiplabel,
    :shownodelabel,
    :shownodenumber,
    :showedgelength,
    :showedgenumber,
    :showgamma,
    :edgecolor,
    :defaultedgecolor,
    :majorhybridedgecolor,
    :minorhybridedgecolor,
    :edgewidth,
    :minorlinetype,
    :arrowlen,
    :nodelabel,
    :edgelabel,
    :nodecex,
    :edgecex,
    :nodelabelcolor,
    :edgelabelcolor,
    :edgenumbercolor,
    :nodelabeladj,
    :edgelabeladj,
    :tipoffset,
    :tipcex,
    :xlim,
    :ylim,
    :style,
)

const EDGE_SEGMENT_GRAPH_OUTPUTS = SegmentGraphOutputs(
    :edge_segment_points,
    :edge_segment_colors,
    :edge_segment_linewidths,
    :edge_segment_linestyle,
)
const NODE_BAR_GRAPH_OUTPUTS = SegmentGraphOutputs(
    :node_bar_points,
    :node_bar_colors,
    :node_bar_linewidths,
    :node_bar_linestyle,
)
const MINOR_EDGE_SHAFT_GRAPH_OUTPUTS = SegmentGraphOutputs(
    :minor_edge_shaft_points,
    :minor_edge_shaft_colors,
    :minor_edge_shaft_linewidths,
    :minor_edge_shaft_linestyle,
)
const MINOR_ARROWHEAD_GRAPH_OUTPUTS = ArrowheadGraphOutputs(
    :minor_arrowhead_startpoints,
    :minor_arrowhead_endpoints,
    :minor_arrowhead_tiplengths,
    :minor_arrowhead_tipwidths,
    :minor_arrowhead_pixel_meshes,
    :minor_arrowhead_colors,
    :minor_arrowhead_strokecolors,
    :minor_arrowhead_strokewidth,
)
const EDGE_IMAGE_GRAPH_OUTPUTS = ImageGraphOutputs(
    :edge_image_positions,
    :edge_image_markers,
    :edge_image_render_markers,
    :edge_image_markersizes,
    :edge_image_marker_offsets,
)
const NODE_IMAGE_GRAPH_OUTPUTS = ImageGraphOutputs(
    :node_image_positions,
    :node_image_markers,
    :node_image_render_markers,
    :node_image_markersizes,
    :node_image_marker_offsets,
)

const NON_TEXT_PHYLO_GRAPH_OUTPUT_SYMBOLS = (
    EDGE_SEGMENT_GRAPH_OUTPUTS.points,
    EDGE_SEGMENT_GRAPH_OUTPUTS.colors,
    EDGE_SEGMENT_GRAPH_OUTPUTS.linewidths,
    EDGE_SEGMENT_GRAPH_OUTPUTS.linestyle,
    NODE_BAR_GRAPH_OUTPUTS.points,
    NODE_BAR_GRAPH_OUTPUTS.colors,
    NODE_BAR_GRAPH_OUTPUTS.linewidths,
    NODE_BAR_GRAPH_OUTPUTS.linestyle,
    MINOR_EDGE_SHAFT_GRAPH_OUTPUTS.points,
    MINOR_EDGE_SHAFT_GRAPH_OUTPUTS.colors,
    MINOR_EDGE_SHAFT_GRAPH_OUTPUTS.linewidths,
    MINOR_EDGE_SHAFT_GRAPH_OUTPUTS.linestyle,
    MINOR_ARROWHEAD_GRAPH_OUTPUTS.startpoints,
    MINOR_ARROWHEAD_GRAPH_OUTPUTS.endpoints,
    MINOR_ARROWHEAD_GRAPH_OUTPUTS.tiplengths,
    MINOR_ARROWHEAD_GRAPH_OUTPUTS.tipwidths,
    MINOR_ARROWHEAD_GRAPH_OUTPUTS.meshes,
    MINOR_ARROWHEAD_GRAPH_OUTPUTS.colors,
    MINOR_ARROWHEAD_GRAPH_OUTPUTS.strokecolors,
    MINOR_ARROWHEAD_GRAPH_OUTPUTS.strokewidth,
    EDGE_IMAGE_GRAPH_OUTPUTS.positions,
    EDGE_IMAGE_GRAPH_OUTPUTS.images,
    EDGE_IMAGE_GRAPH_OUTPUTS.render_markers,
    EDGE_IMAGE_GRAPH_OUTPUTS.markersizes,
    EDGE_IMAGE_GRAPH_OUTPUTS.marker_offsets,
    NODE_IMAGE_GRAPH_OUTPUTS.positions,
    NODE_IMAGE_GRAPH_OUTPUTS.images,
    NODE_IMAGE_GRAPH_OUTPUTS.render_markers,
    NODE_IMAGE_GRAPH_OUTPUTS.markersizes,
    NODE_IMAGE_GRAPH_OUTPUTS.marker_offsets,
    :data_limits,
)

const TEXT_GRAPH_OUTPUT_PREFIXES = (
    :tip_label,
    :internal_node_name,
    :node_number,
    :node_label,
    :edge_label,
    :edge_length,
    :minor_gamma_label,
    :major_gamma_label,
    :edge_number,
)
const TEXT_GRAPH_OUTPUT_SUFFIXES = (
    "_positions",
    "_strings",
    "_colors",
    "_fontsizes",
    "_align",
    "_font",
)
const TEXT_PHYLO_GRAPH_OUTPUT_SYMBOLS = Tuple(
    Symbol(prefix, suffix) for prefix in TEXT_GRAPH_OUTPUT_PREFIXES for
        suffix in TEXT_GRAPH_OUTPUT_SUFFIXES
)
const PHYLO_GRAPH_OUTPUT_SYMBOLS = (
    NON_TEXT_PHYLO_GRAPH_OUTPUT_SYMBOLS...,
    TEXT_PHYLO_GRAPH_OUTPUT_SYMBOLS...,
)
const NODE_POSITION_TABLE_OUTPUT = :node_position_table

function phylo_graph_output_symbols()::Tuple{Vararg{Symbol}}
    return PHYLO_GRAPH_OUTPUT_SYMBOLS
end

function _segment_output_symbols(outputs::SegmentGraphOutputs)::NTuple{4, Symbol}
    return (outputs.points, outputs.colors, outputs.linewidths, outputs.linestyle)
end

function _arrowhead_spec_output_symbols(outputs::ArrowheadGraphOutputs)::NTuple{7, Symbol}
    return (
        outputs.startpoints,
        outputs.endpoints,
        outputs.tiplengths,
        outputs.tipwidths,
        outputs.colors,
        outputs.strokecolors,
        outputs.strokewidth,
    )
end

function _arrowhead_output_symbols(outputs::ArrowheadGraphOutputs)::NTuple{8, Symbol}
    return (
        outputs.startpoints,
        outputs.endpoints,
        outputs.tiplengths,
        outputs.tipwidths,
        outputs.meshes,
        outputs.colors,
        outputs.strokecolors,
        outputs.strokewidth,
    )
end

function _image_output_symbols(outputs::ImageGraphOutputs)::NTuple{5, Symbol}
    return (
        outputs.positions,
        outputs.images,
        outputs.render_markers,
        outputs.markersizes,
        outputs.marker_offsets,
    )
end

function _text_output_symbols(outputs::TextGraphOutputs)::NTuple{6, Symbol}
    return (
        outputs.positions,
        outputs.strings,
        outputs.colors,
        outputs.fontsizes,
        outputs.align,
        outputs.font,
    )
end

function _text_graph_outputs(prefix::Symbol)::TextGraphOutputs
    return TextGraphOutputs(
        Symbol(prefix, "_positions"),
        Symbol(prefix, "_strings"),
        Symbol(prefix, "_colors"),
        Symbol(prefix, "_fontsizes"),
        Symbol(prefix, "_align"),
        Symbol(prefix, "_font"),
    )
end

function _ref_any(value)::Base.RefValue{Any}
    # ComputePipeline stores a typed RefValue on first resolution; these graph
    # outputs can legitimately change concrete type after public keyword updates.
    return Ref{Any}(value)
end

function _edge_callback_function(edge)::Function
    callback = getfield(edge, :callback)
    if :user_func in propertynames(callback)
        return getfield(callback, :user_func)
    end
    return callback
end

function _edge_input_symbols(edge)::Vector{Symbol}
    return Symbol[getfield(input, :name) for input in getfield(edge, :inputs)]
end

function _input_conflict_symbols(plot::PhyloPlot, outputs::Tuple{Vararg{Symbol}})::Vector{Symbol}
    attr = plot.attributes
    return Symbol[output for output in outputs if haskey(attr.inputs, output)]
end

function _ensure_plot_space_node!(plot::PhyloPlot)::Nothing
    haskey(plot.attributes, :space) && return nothing
    Makie.ComputePipeline.add_constant!(plot.attributes, :space, :data)
    return nothing
end

function _release_initial_data_limits_output!(plot::PhyloPlot)::Nothing
    attr = plot.attributes
    if !haskey(attr.inputs, :data_limits) || !haskey(attr.outputs, :data_limits)
        return nothing
    end

    input = attr.inputs[:data_limits]
    output = attr.outputs[:data_limits]
    input_output = getfield(input, :output)
    if input_output !== output || !isempty(getfield(input, :dependents))
        return nothing
    end

    delete!(attr, :data_limits)
    return nothing
end

function _register_outputs_once!(
        callback::Function,
        plot::PhyloPlot,
        inputs::Tuple{Vararg{Symbol}},
        outputs::Tuple{Vararg{Symbol}},
    )::Nothing
    attr = plot.attributes
    if :data_limits in outputs
        _release_initial_data_limits_output!(plot)
    end

    conflicts = _input_conflict_symbols(plot, outputs)
    isempty(conflicts) || error("Cannot register graph outputs that are already inputs: $conflicts")

    existing_outputs = Symbol[output for output in outputs if haskey(attr.outputs, output)]
    if isempty(existing_outputs)
        map!(callback, attr, Symbol[inputs...], Symbol[outputs...])
        return nothing
    end
    length(existing_outputs) == length(outputs) ||
        error("Cannot register partial graph output set: $existing_outputs")

    nodes = [attr.outputs[output] for output in outputs]
    if any(node -> !isdefined(node, :parent), nodes)
        error("Cannot register graph outputs without parent compute edges: $outputs")
    end

    parent_edge = getfield(first(nodes), :parent)
    all(node -> getfield(node, :parent) === parent_edge, nodes) ||
        error("Cannot register graph outputs with different parent compute edges: $outputs")
    _edge_input_symbols(parent_edge) == Symbol[inputs...] ||
        error("Cannot register graph outputs with different input nodes: $outputs")
    _edge_callback_function(parent_edge) === callback ||
        error("Cannot register graph outputs with a different callback: $outputs")
    return nothing
end

function _compute_plot_config(
        useedgelength,
        showtiplabel,
        shownodelabel,
        shownodenumber,
        showedgelength,
        showedgenumber,
        showgamma,
        edgecolor,
        defaultedgecolor,
        majorhybridedgecolor,
        minorhybridedgecolor,
        edgewidth,
        minorlinetype,
        arrowlen,
        nodelabel,
        edgelabel,
        nodecex,
        edgecex,
        nodelabelcolor,
        edgelabelcolor,
        edgenumbercolor,
        nodelabeladj,
        edgelabeladj,
        tipoffset,
        tipcex,
        xlim,
        ylim,
        style,
    )::Tuple{Base.RefValue{Any}}
    config = resolve_plot_config(;
        useedgelength,
        showtiplabel,
        shownodelabel,
        shownodenumber,
        showedgelength,
        showedgenumber,
        showgamma,
        edgecolor,
        defaultedgecolor,
        majorhybridedgecolor,
        minorhybridedgecolor,
        edgewidth,
        minorlinetype,
        arrowlen,
        nodelabel,
        edgelabel,
        nodecex,
        edgecex,
        nodelabelcolor,
        edgelabelcolor,
        edgenumbercolor,
        nodelabeladj,
        edgelabeladj,
        tipoffset,
        tipcex,
        xlim,
        ylim,
        style,
    )
    return (_ref_any(config),)
end

function _compute_prepared_phylogeny(
        phylogeny::AbstractPhylogeny,
    )::Tuple{Base.RefValue{Any}}
    return (_ref_any(prepare_for_layout(phylogeny)),)
end

function _compute_phylogeny_geometry(
        prepared_phylogeny::PreparedPhylogeny,
        config::PhyloPlotConfig,
    )::Tuple{Base.RefValue{Any}}
    return (_ref_any(compute_phylogeny_geometry(prepared_phylogeny, config)),)
end

function _compute_node_position_table(
        prepared_phylogeny::PreparedPhylogeny,
        geometry::PhylogenyGeometry,
    )::Tuple{DataFrames.DataFrame}
    phylogeny = prepared_phylogeny.phylogeny
    return (
        DataFrames.DataFrame(
            number = Int[node_id(current_node) for current_node in nodes(phylogeny)],
            name = String[node_label(current_node) for current_node in nodes(phylogeny)],
            isleaf = Bool[
                is_leaf(phylogeny, current_node) for current_node in nodes(phylogeny)
            ],
            x = copy(geometry.node_x),
            y = copy(geometry.node_y),
        ),
    )
end

function _compute_layout(
        prepared_phylogeny::PreparedPhylogeny,
        config::PhyloPlotConfig,
        geometry::PhylogenyGeometry,
    )::Tuple{Base.RefValue{Any}}
    return (_ref_any(compute_layout(prepared_phylogeny, config, geometry)),)
end

function _compute_primitive_channels(
        prepared_phylogeny::PreparedPhylogeny,
        config::PhyloPlotConfig,
        layout::LayoutComputation,
    )::Tuple{Base.RefValue{Any}}
    return (_ref_any(compute_primitive_channels(prepared_phylogeny, config, layout)),)
end

function _resolve_image_channels_graph!(
        input_phylogeny::AbstractPhylogeny,
        prepared_phylogeny::PreparedPhylogeny,
        layout::LayoutComputation,
        nodeimages,
        edgeimages,
        cache::ImageAssetCache,
    )::Tuple{Base.RefValue{Any}, Base.RefValue{Any}}
    channels = resolve_image_channels!(
        cache,
        input_phylogeny,
        prepared_phylogeny,
        layout,
        nodeimages,
        edgeimages,
    )
    return (_ref_any(channels.edge_images), _ref_any(channels.node_images))
end

function _image_channel_base_outputs(
        channel::ImageChannel,
    )::NTuple{4, Base.RefValue{Any}}
    upper, lower = image_probe_positions(channel)
    return (
        _ref_any(channel.positions),
        _ref_any(channel.images),
        _ref_any(upper),
        _ref_any(lower),
    )
end

const EMPTY_IMAGE_RENDER_MARKER = fill(
    Makie.RGBA{Makie.N0f8}(0, 0, 0, 0),
    1,
    1,
)

function image_render_markers(
        images::Vector{NormalizedImageMatrix},
    )::Vector{NormalizedImageMatrix}
    # GLMakie treats a typed vector of image markers as a texture-atlas input
    # and rejects an empty vector. An empty positions vector means this
    # transparent marker is never drawn, while retaining the marker input's
    # concrete type for reactive updates.
    isempty(images) && return NormalizedImageMatrix[EMPTY_IMAGE_RENDER_MARKER]
    return images
end

function _compute_image_render_markers(
        images::Vector{NormalizedImageMatrix},
    )::Tuple{Base.RefValue{Any}}
    return (_ref_any(image_render_markers(images)),)
end

function _compute_image_marker_geometry_outputs(
        channel::ImageChannel,
        upper_pixel_positions::AbstractVector,
        lower_pixel_positions::AbstractVector,
    )::Tuple{Base.RefValue{Any}, Base.RefValue{Any}}
    marker_sizes, marker_offsets = compute_image_marker_geometry(
        channel,
        upper_pixel_positions,
        lower_pixel_positions,
    )
    return (_ref_any(marker_sizes), _ref_any(marker_offsets))
end

function _compute_data_limits(channels::PrimitiveChannels)::Tuple{Base.RefValue{Any}}
    return (_ref_any(channels.data_limits),)
end

function _plot_output_value(plot::PhyloPlot, symbol::Symbol)
    return plot.attributes.outputs[symbol][]
end

function current_plot_config(plot::PhyloPlot)::PhyloPlotConfig
    input_values = map(symbol -> _plot_output_value(plot, symbol), PLOT_CONFIG_INPUT_SYMBOLS)
    return resolve_plot_config(; NamedTuple{PLOT_CONFIG_INPUT_SYMBOLS}(input_values)...)
end

function validate_public_plot_limits(plot::PhyloPlot)::Nothing
    xlim = _plot_output_value(plot, :xlim)
    ylim = _plot_output_value(plot, :ylim)
    if isnothing(xlim) && isnothing(ylim)
        return nothing
    end

    config = current_plot_config(plot)
    prepared_phylogeny = prepare_for_layout(_plot_output_value(plot, :phylogeny))
    geometry = compute_phylogeny_geometry(prepared_phylogeny, config)
    layout = compute_layout(prepared_phylogeny, config, geometry)
    compute_data_limits(config, layout.extent)
    return nothing
end

function Makie.boundingbox(plot::PhyloPlot, space::Symbol = :data)::Makie.Rect3d
    return Makie.data_limits(plot)
end

function _segment_channel_outputs(channel::SegmentChannel)::NTuple{4, Base.RefValue{Any}}
    return (
        _ref_any(channel.points),
        _ref_any(channel.colors),
        _ref_any(channel.linewidths),
        _ref_any(channel.linestyle),
    )
end

function _edge_segment_outputs(channels::PrimitiveChannels)::NTuple{4, Base.RefValue{Any}}
    return _segment_channel_outputs(channels.edge_segments)
end

function _node_bar_outputs(channels::PrimitiveChannels)::NTuple{4, Base.RefValue{Any}}
    return _segment_channel_outputs(channels.node_bars)
end

function _minor_edge_shaft_outputs(channels::PrimitiveChannels)::NTuple{4, Base.RefValue{Any}}
    return _segment_channel_outputs(channels.minor_edge_shafts)
end

function _minor_arrowhead_outputs(channels::PrimitiveChannels)::NTuple{7, Base.RefValue{Any}}
    arrowheads = channels.minor_arrowheads
    return (
        _ref_any(arrowheads.startpoints),
        _ref_any(arrowheads.endpoints),
        _ref_any(arrowheads.tiplengths),
        _ref_any(arrowheads.tipwidths),
        _ref_any(arrowheads.colors),
        _ref_any(arrowheads.strokecolors),
        _ref_any(arrowheads.strokewidth),
    )
end

function _compute_minor_arrowhead_pixel_meshes(
        pixel_startpoints::AbstractVector,
        pixel_endpoints::AbstractVector,
        tiplengths::AbstractVector{<:Real},
        tipwidths::AbstractVector{<:Real},
    )::Tuple{Base.RefValue{Any}}
    return (
        _ref_any(
            compute_arrowhead_pixel_meshes(
                pixel_startpoints,
                pixel_endpoints,
                tiplengths,
                tipwidths,
            ),
        ),
    )
end

function _text_channel_outputs(channel::TextChannel)::NTuple{6, Base.RefValue{Any}}
    return (
        _ref_any(channel.positions),
        _ref_any(channel.strings),
        _ref_any(channel.colors),
        _ref_any(channel.fontsizes),
        _ref_any(channel.align),
        _ref_any(channel.font),
    )
end

function _tip_label_outputs(channels::PrimitiveChannels)::NTuple{6, Base.RefValue{Any}}
    return _text_channel_outputs(channels.tip_labels)
end

function _internal_node_name_outputs(channels::PrimitiveChannels)::NTuple{6, Base.RefValue{Any}}
    return _text_channel_outputs(channels.internal_node_names)
end

function _node_number_outputs(channels::PrimitiveChannels)::NTuple{6, Base.RefValue{Any}}
    return _text_channel_outputs(channels.node_numbers)
end

function _node_label_outputs(channels::PrimitiveChannels)::NTuple{6, Base.RefValue{Any}}
    return _text_channel_outputs(channels.node_labels)
end

function _edge_label_outputs(channels::PrimitiveChannels)::NTuple{6, Base.RefValue{Any}}
    return _text_channel_outputs(channels.edge_labels)
end

function _edge_length_outputs(channels::PrimitiveChannels)::NTuple{6, Base.RefValue{Any}}
    return _text_channel_outputs(channels.edge_lengths)
end

function _minor_gamma_label_outputs(channels::PrimitiveChannels)::NTuple{6, Base.RefValue{Any}}
    return _text_channel_outputs(channels.minor_gamma_labels)
end

function _major_gamma_label_outputs(channels::PrimitiveChannels)::NTuple{6, Base.RefValue{Any}}
    return _text_channel_outputs(channels.major_gamma_labels)
end

function _edge_number_outputs(channels::PrimitiveChannels)::NTuple{6, Base.RefValue{Any}}
    return _text_channel_outputs(channels.edge_numbers)
end

function register_plot_config_node!(plot::PhyloPlot)::Symbol
    _register_outputs_once!(_compute_plot_config, plot, PLOT_CONFIG_INPUT_SYMBOLS, (:plot_config,))
    return :plot_config
end

function register_prepared_phylogeny_node!(plot::PhyloPlot)::Symbol
    _register_outputs_once!(_compute_prepared_phylogeny, plot, (:phylogeny,), (:prepared_phylogeny,))
    return :prepared_phylogeny
end

function register_image_asset_cache_node!(plot::PhyloPlot)::Symbol
    cache_node = :image_asset_cache
    haskey(plot.attributes, cache_node) ||
        Makie.ComputePipeline.add_constant!(plot.attributes, cache_node, ImageAssetCache())
    return cache_node
end

function register_layout_nodes!(
        plot::PhyloPlot,
        config_node::Symbol,
        prepared_phylogeny_node::Symbol,
    )::NamedTuple{(:geometry, :layout), Tuple{Symbol, Symbol}}
    _register_outputs_once!(
        _compute_phylogeny_geometry,
        plot,
        (prepared_phylogeny_node, config_node),
        (:phylogeny_geometry,),
    )
    _register_outputs_once!(
        _compute_layout,
        plot,
        (prepared_phylogeny_node, config_node, :phylogeny_geometry),
        (:layout_computation,),
    )
    return (geometry = :phylogeny_geometry, layout = :layout_computation)
end

function register_node_position_table_node!(
        plot::PhyloPlot,
        prepared_phylogeny_node::Symbol,
        geometry_node::Symbol,
    )::Symbol
    _register_outputs_once!(
        _compute_node_position_table,
        plot,
        (prepared_phylogeny_node, geometry_node),
        (NODE_POSITION_TABLE_OUTPUT,),
    )
    return NODE_POSITION_TABLE_OUTPUT
end

function register_primitive_channel_node!(
        plot::PhyloPlot,
        prepared_phylogeny_node::Symbol,
        config_node::Symbol,
        layout_node::Symbol,
    )::Symbol
    _register_outputs_once!(
        _compute_primitive_channels,
        plot,
        (prepared_phylogeny_node, config_node, layout_node),
        (:primitive_channels,),
    )
    return :primitive_channels
end

function register_image_channel_nodes!(
        plot::PhyloPlot,
        prepared_phylogeny_node::Symbol,
        layout_node::Symbol,
    )::NamedTuple{(:edge_images, :node_images), Tuple{Symbol, Symbol}}
    cache_node = register_image_asset_cache_node!(plot)
    _register_outputs_once!(
        _resolve_image_channels_graph!,
        plot,
        (:phylogeny, prepared_phylogeny_node, layout_node, :nodeimages, :edgeimages, cache_node),
        (:edge_image_channel, :node_image_channel),
    )
    return (edge_images = :edge_image_channel, node_images = :node_image_channel)
end

function register_data_limits_node!(
        plot::PhyloPlot,
        primitive_channels_node::Symbol,
    )::Symbol
    _register_outputs_once!(
        _compute_data_limits,
        plot,
        (primitive_channels_node,),
        (:data_limits,),
    )
    return :data_limits
end

function _register_phylo_intermediate_nodes!(
        plot::PhyloPlot,
    )::NamedTuple{
        (
            :config,
            :phylogeny,
            :geometry,
            :layout,
            :node_positions,
            :primitive_channels,
            :edge_images,
            :node_images,
            :data_limits,
        ),
        NTuple{9, Symbol},
    }
    config_node = register_plot_config_node!(plot)
    prepared_phylogeny_node = register_prepared_phylogeny_node!(plot)
    layout_nodes = register_layout_nodes!(plot, config_node, prepared_phylogeny_node)
    node_position_table_node = register_node_position_table_node!(
        plot,
        prepared_phylogeny_node,
        layout_nodes.geometry,
    )
    primitive_channels_node = register_primitive_channel_node!(
        plot,
        prepared_phylogeny_node,
        config_node,
        layout_nodes.layout,
    )
    image_channel_nodes = register_image_channel_nodes!(
        plot,
        prepared_phylogeny_node,
        layout_nodes.layout,
    )
    data_limits_node = register_data_limits_node!(plot, primitive_channels_node)
    return (
        config = config_node,
        phylogeny = prepared_phylogeny_node,
        geometry = layout_nodes.geometry,
        layout = layout_nodes.layout,
        node_positions = node_position_table_node,
        primitive_channels = primitive_channels_node,
        edge_images = image_channel_nodes.edge_images,
        node_images = image_channel_nodes.node_images,
        data_limits = data_limits_node,
    )
end

function register_segment_output_nodes!(
        plot::PhyloPlot,
        primitive_channels_node::Symbol,
    )::NamedTuple{
        (:edge_segments, :node_bars, :minor_edge_shafts),
        Tuple{SegmentGraphOutputs, SegmentGraphOutputs, SegmentGraphOutputs},
    }
    _register_outputs_once!(
        _edge_segment_outputs,
        plot,
        (primitive_channels_node,),
        _segment_output_symbols(EDGE_SEGMENT_GRAPH_OUTPUTS),
    )
    _register_outputs_once!(
        _node_bar_outputs,
        plot,
        (primitive_channels_node,),
        _segment_output_symbols(NODE_BAR_GRAPH_OUTPUTS),
    )
    _register_outputs_once!(
        _minor_edge_shaft_outputs,
        plot,
        (primitive_channels_node,),
        _segment_output_symbols(MINOR_EDGE_SHAFT_GRAPH_OUTPUTS),
    )
    return (
        edge_segments = EDGE_SEGMENT_GRAPH_OUTPUTS,
        node_bars = NODE_BAR_GRAPH_OUTPUTS,
        minor_edge_shafts = MINOR_EDGE_SHAFT_GRAPH_OUTPUTS,
    )
end

function register_arrowhead_output_nodes!(
        plot::PhyloPlot,
        primitive_channels_node::Symbol,
    )::ArrowheadGraphOutputs
    _register_outputs_once!(
        _minor_arrowhead_outputs,
        plot,
        (primitive_channels_node,),
        _arrowhead_spec_output_symbols(MINOR_ARROWHEAD_GRAPH_OUTPUTS),
    )
    _ensure_plot_space_node!(plot)
    Makie.register_projected_positions!(
        plot,
        Makie.Point3f;
        input_space = :space,
        input_name = :minor_arrowhead_startpoints,
        output_name = :minor_arrowhead_pixel_startpoints,
        output_space = :pixel,
    )
    Makie.register_projected_positions!(
        plot,
        Makie.Point3f;
        input_space = :space,
        input_name = :minor_arrowhead_endpoints,
        output_name = :minor_arrowhead_pixel_endpoints,
        output_space = :pixel,
    )
    _register_outputs_once!(
        _compute_minor_arrowhead_pixel_meshes,
        plot,
        (
            :minor_arrowhead_pixel_startpoints,
            :minor_arrowhead_pixel_endpoints,
            :minor_arrowhead_tiplengths,
            :minor_arrowhead_tipwidths,
        ),
        (MINOR_ARROWHEAD_GRAPH_OUTPUTS.meshes,),
    )
    return MINOR_ARROWHEAD_GRAPH_OUTPUTS
end


function register_image_output_nodes!(
        plot::PhyloPlot,
        channel_node::Symbol,
        outputs::ImageGraphOutputs,
        prefix::Symbol,
    )::ImageGraphOutputs
    upper_positions = Symbol(prefix, "_upper_positions")
    lower_positions = Symbol(prefix, "_lower_positions")
    upper_pixel_positions = Symbol(prefix, "_upper_pixel_positions")
    lower_pixel_positions = Symbol(prefix, "_lower_pixel_positions")
    _register_outputs_once!(
        _image_channel_base_outputs,
        plot,
        (channel_node,),
        (outputs.positions, outputs.images, upper_positions, lower_positions),
    )
    _register_outputs_once!(
        _compute_image_render_markers,
        plot,
        (outputs.images,),
        (outputs.render_markers,),
    )
    _ensure_plot_space_node!(plot)
    Makie.register_projected_positions!(
        plot,
        Makie.Point3f;
        input_space = :space,
        input_name = upper_positions,
        output_name = upper_pixel_positions,
        output_space = :pixel,
    )
    Makie.register_projected_positions!(
        plot,
        Makie.Point3f;
        input_space = :space,
        input_name = lower_positions,
        output_name = lower_pixel_positions,
        output_space = :pixel,
    )
    _register_outputs_once!(
        _compute_image_marker_geometry_outputs,
        plot,
        (channel_node, upper_pixel_positions, lower_pixel_positions),
        (outputs.markersizes, outputs.marker_offsets),
    )
    return outputs
end

function register_primitive_graph_outputs!(plot::PhyloPlot)::PhyloGraphOutputs
    intermediate_nodes = _register_phylo_intermediate_nodes!(plot)
    segment_outputs = register_segment_output_nodes!(plot, intermediate_nodes.primitive_channels)
    arrowhead_outputs = register_arrowhead_output_nodes!(plot, intermediate_nodes.primitive_channels)
    edge_image_outputs = register_image_output_nodes!(
        plot,
        intermediate_nodes.edge_images,
        EDGE_IMAGE_GRAPH_OUTPUTS,
        :edge_image,
    )
    node_image_outputs = register_image_output_nodes!(
        plot,
        intermediate_nodes.node_images,
        NODE_IMAGE_GRAPH_OUTPUTS,
        :node_image,
    )
    return PhyloGraphOutputs(
        segment_outputs.edge_segments,
        segment_outputs.node_bars,
        segment_outputs.minor_edge_shafts,
        arrowhead_outputs,
        edge_image_outputs,
        node_image_outputs,
        intermediate_nodes.data_limits,
    )
end

function register_text_output_nodes!(
        plot::PhyloPlot,
        primitive_channels_node::Symbol,
    )::PhyloTextGraphOutputs
    tip_labels = _text_graph_outputs(:tip_label)
    internal_node_names = _text_graph_outputs(:internal_node_name)
    node_numbers = _text_graph_outputs(:node_number)
    node_labels = _text_graph_outputs(:node_label)
    edge_labels = _text_graph_outputs(:edge_label)
    edge_lengths = _text_graph_outputs(:edge_length)
    minor_gamma_labels = _text_graph_outputs(:minor_gamma_label)
    major_gamma_labels = _text_graph_outputs(:major_gamma_label)
    edge_numbers = _text_graph_outputs(:edge_number)

    _register_outputs_once!(
        _tip_label_outputs,
        plot,
        (primitive_channels_node,),
        _text_output_symbols(tip_labels),
    )
    _register_outputs_once!(
        _internal_node_name_outputs,
        plot,
        (primitive_channels_node,),
        _text_output_symbols(internal_node_names),
    )
    _register_outputs_once!(
        _node_number_outputs,
        plot,
        (primitive_channels_node,),
        _text_output_symbols(node_numbers),
    )
    _register_outputs_once!(
        _node_label_outputs,
        plot,
        (primitive_channels_node,),
        _text_output_symbols(node_labels),
    )
    _register_outputs_once!(
        _edge_label_outputs,
        plot,
        (primitive_channels_node,),
        _text_output_symbols(edge_labels),
    )
    _register_outputs_once!(
        _edge_length_outputs,
        plot,
        (primitive_channels_node,),
        _text_output_symbols(edge_lengths),
    )
    _register_outputs_once!(
        _minor_gamma_label_outputs,
        plot,
        (primitive_channels_node,),
        _text_output_symbols(minor_gamma_labels),
    )
    _register_outputs_once!(
        _major_gamma_label_outputs,
        plot,
        (primitive_channels_node,),
        _text_output_symbols(major_gamma_labels),
    )
    _register_outputs_once!(
        _edge_number_outputs,
        plot,
        (primitive_channels_node,),
        _text_output_symbols(edge_numbers),
    )

    return PhyloTextGraphOutputs(
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

function register_text_graph_outputs!(plot::PhyloPlot)::PhyloTextGraphOutputs
    intermediate_nodes = _register_phylo_intermediate_nodes!(plot)
    return register_text_output_nodes!(plot, intermediate_nodes.primitive_channels)
end

function register_phylo_graph!(plot::PhyloPlot)::NamedTuple{
        (:primitive_outputs, :text_outputs),
        Tuple{PhyloGraphOutputs, PhyloTextGraphOutputs},
    }
    primitive_outputs = register_primitive_graph_outputs!(plot)
    text_outputs = register_text_graph_outputs!(plot)
    return (primitive_outputs = primitive_outputs, text_outputs = text_outputs)
end
