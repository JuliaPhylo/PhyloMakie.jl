import PhyloNetworks

function _deprecated_phylo_plot_attribute_message(legacy::Symbol, public_name)
    if isnothing(public_name)
        if legacy == :edgenumbercolor
            return "The tranche-5 public surface does not expose a separate edge-number color control; `show_edge_numbers=true` uses the governed render-owner default `grey`."
        end
        return "`$(legacy)` is internal to the Makie recipe owner and is not accepted on the public surface."
    end
    return "Use `$(public_name)`."
end

function _validate_public_limits(limit, helper_message::String)
    if isnothing(limit)
        return nothing
    end
    if !applicable(length, limit) || length(limit) != 2
        error(helper_message)
    end
    return limit
end

Makie.@recipe PhyloPlot (net,) begin
    use_edge_lengths = false
    show_tip_labels = true
    show_internal_node_names = false
    show_node_numbers = false
    show_edge_lengths = false
    show_edge_numbers = false
    show_gamma = false
    edge_color = "black"
    default_edge_color = nothing
    major_hybrid_edge_color = "deepskyblue4"
    minor_hybrid_edge_color = "deepskyblue"
    edge_width = 1
    minor_edge_linestyle = nothing
    minor_edge_arrow_length = nothing
    node_annotations = DataFrame()
    edge_annotations = DataFrame()
    node_annotation_scale = 1
    edge_annotation_scale = 1
    node_annotation_color = "black"
    edge_annotation_color = "black"
    node_annotation_align = 1
    edge_annotation_align = [0.5, 0]
    tip_label_offset = 0
    tip_label_scale = 1
    x_limits = nothing
    y_limits = nothing
    style = :fulltree
end

Makie.plottype(::PhyloNetworks.HybridNetwork) = PhyloPlot

function Makie.deprecated_attributes(::Type{<:PhyloPlot})
    return Tuple(
        (
            attribute = migration.legacy,
            message = _deprecated_phylo_plot_attribute_message(
                migration.legacy,
                migration.public,
            ),
            error = true,
        ) for migration in PHYLOPLOT_ATTRIBUTE_MIGRATIONS
    )
end

function Makie.plot!(plot::PhyloPlot)
    attributes = resolve_phylo_plot_attributes(
        use_edge_lengths=Makie.to_value(plot[:use_edge_lengths]),
        show_tip_labels=Makie.to_value(plot[:show_tip_labels]),
        show_internal_node_names=Makie.to_value(plot[:show_internal_node_names]),
        show_node_numbers=Makie.to_value(plot[:show_node_numbers]),
        show_edge_lengths=Makie.to_value(plot[:show_edge_lengths]),
        show_edge_numbers=Makie.to_value(plot[:show_edge_numbers]),
        show_gamma=Makie.to_value(plot[:show_gamma]),
        edge_color=Makie.to_value(plot[:edge_color]),
        default_edge_color=Makie.to_value(plot[:default_edge_color]),
        major_hybrid_edge_color=Makie.to_value(plot[:major_hybrid_edge_color]),
        minor_hybrid_edge_color=Makie.to_value(plot[:minor_hybrid_edge_color]),
        edge_width=Makie.to_value(plot[:edge_width]),
        minor_edge_linestyle=Makie.to_value(plot[:minor_edge_linestyle]),
        minor_edge_arrow_length=Makie.to_value(plot[:minor_edge_arrow_length]),
        node_annotations=Makie.to_value(plot[:node_annotations]),
        edge_annotations=Makie.to_value(plot[:edge_annotations]),
        node_annotation_scale=Makie.to_value(plot[:node_annotation_scale]),
        edge_annotation_scale=Makie.to_value(plot[:edge_annotation_scale]),
        node_annotation_color=Makie.to_value(plot[:node_annotation_color]),
        edge_annotation_color=Makie.to_value(plot[:edge_annotation_color]),
        node_annotation_align=Makie.to_value(plot[:node_annotation_align]),
        edge_annotation_align=Makie.to_value(plot[:edge_annotation_align]),
        tip_label_offset=Makie.to_value(plot[:tip_label_offset]),
        tip_label_scale=Makie.to_value(plot[:tip_label_scale]),
        x_limits=Makie.to_value(plot[:x_limits]),
        y_limits=Makie.to_value(plot[:y_limits]),
        style=Makie.to_value(plot[:style]),
    )

    net = deepcopy(Makie.to_value(plot[:net]))
    layout = prepare_plot_layout(net, attributes; preorder=true)
    validated_x_limits = _validate_public_limits(
        attributes.x_limits,
        layout.bounds.x_limits_error_message,
    )
    validated_y_limits = _validate_public_limits(
        attributes.y_limits,
        layout.bounds.y_limits_error_message,
    )
    resolved_attributes = with_phylo_plot_limits(
        attributes,
        validated_x_limits,
        validated_y_limits,
    )
    layers = render_plot!(plot, net, resolved_attributes, layout)
    plot[:resolved_attributes] = resolved_attributes
    plot[:resolved_layout] = layout
    plot[:render_layers] = layers
    return plot
end
