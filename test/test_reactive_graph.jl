using CairoMakie
using DataFrames: DataFrame
using Makie
using PhyloNetworks

const REACTIVE_GRAPH_NEWICK =
    "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"
const REACTIVE_GRAPH_ALT_NEWICK =
    "((A:1,(B:0.5)#H1:0.5):1,(#H1:0.5,C:1):1);"

function _reactive_plot(; kwargs...)
    CairoMakie.activate!()
    surface = Makie.plot(
        readnewick(REACTIVE_GRAPH_NEWICK);
        useedgelength = true,
        showgamma = true,
        style = :fulltree,
        kwargs...,
    )
    return surface.plot
end

function _registered_reactive_plot(; kwargs...)
    plot = _reactive_plot(; kwargs...)
    outputs = getfield(PhyloMakie, :register_phylo_graph!)(plot)
    return plot, outputs
end

function _reactive_network_snapshot(net::PhyloNetworks.HybridNetwork)
    return (
        rooti = net.rooti,
        isrooted = net.isrooted,
        node_numbers = [node.number for node in net.node],
        preorder_numbers = [node.number for node in net.vec_node],
        edge_state = [
            (
                number = edge.number,
                parent = PhyloNetworks.getparent(edge).number,
                child = PhyloNetworks.getchild(edge).number,
                ischild1 = edge.ischild1,
                containroot = hasfield(typeof(edge), :containroot) ?
                    getfield(edge, :containroot) : nothing,
                hybrid = edge.hybrid,
                ismajor = edge.ismajor,
                length = edge.length,
                gamma = edge.gamma,
            ) for edge in net.edge
        ],
    )
end

function _reactive_limits_tuple(rect::Makie.Rect3d)
    rect_min = minimum(rect)
    rect_max = maximum(rect)
    return (
        (Float64(rect_min[1]), Float64(rect_max[1])),
        (Float64(rect_min[2]), Float64(rect_max[2])),
    )
end

function _assert_segment_outputs_match_channel(plot, outputs, channel)::Nothing
    @test plot[outputs.points][] == channel.points
    @test plot[outputs.colors][] == channel.colors
    @test plot[outputs.linewidths][] == channel.linewidths
    @test plot[outputs.linestyle][] == channel.linestyle
    return nothing
end

function _assert_arrowhead_outputs_match_channel(plot, outputs, channel)::Nothing
    compute_arrowhead_pixel_meshes = getfield(PhyloMakie, :compute_arrowhead_pixel_meshes)
    @test plot[outputs.startpoints][] == channel.startpoints
    @test plot[outputs.endpoints][] == channel.endpoints
    @test plot[outputs.tiplengths][] == channel.tiplengths
    @test plot[outputs.tipwidths][] == channel.tipwidths
    @test plot[outputs.colors][] == channel.colors
    @test plot[outputs.strokecolors][] == channel.strokecolors
    @test plot[outputs.strokewidth][] == channel.strokewidth
    @test plot[outputs.meshes][] == compute_arrowhead_pixel_meshes(
        plot[:minor_arrowhead_pixel_startpoints][],
        plot[:minor_arrowhead_pixel_endpoints][],
        channel.tiplengths,
        channel.tipwidths,
    )
    return nothing
end

function _assert_text_outputs_match_channel(plot, outputs, channel)::Nothing
    @test plot[outputs.positions][] == channel.positions
    @test plot[outputs.strings][] == channel.strings
    @test plot[outputs.colors][] == channel.colors
    @test plot[outputs.fontsizes][] == channel.fontsizes
    @test plot[outputs.align][] == channel.align
    @test plot[outputs.font][] == channel.font
    return nothing
end

function _assert_text_outputs_empty(plot, outputs)::Nothing
    @test plot[outputs.positions][] == Makie.Point2f[]
    @test plot[outputs.strings][] == String[]
    @test plot[outputs.colors][] == Makie.RGBAf[]
    @test plot[outputs.fontsizes][] == Float32[]
    return nothing
end

function _assert_all_outputs_match_channels(plot, outputs)::Nothing
    channels = plot[:primitive_channels][]
    primitive_outputs = outputs.primitive_outputs
    text_outputs = outputs.text_outputs

    _assert_segment_outputs_match_channel(
        plot,
        primitive_outputs.edge_segments,
        channels.edge_segments,
    )
    _assert_segment_outputs_match_channel(plot, primitive_outputs.node_bars, channels.node_bars)
    _assert_segment_outputs_match_channel(
        plot,
        primitive_outputs.minor_edge_shafts,
        channels.minor_edge_shafts,
    )
    _assert_arrowhead_outputs_match_channel(
        plot,
        primitive_outputs.minor_arrowheads,
        channels.minor_arrowheads,
    )
    @test plot[primitive_outputs.data_limits][] == channels.data_limits

    _assert_text_outputs_match_channel(plot, text_outputs.tip_labels, channels.tip_labels)
    _assert_text_outputs_match_channel(
        plot,
        text_outputs.internal_node_names,
        channels.internal_node_names,
    )
    _assert_text_outputs_match_channel(plot, text_outputs.node_numbers, channels.node_numbers)
    _assert_text_outputs_match_channel(plot, text_outputs.node_labels, channels.node_labels)
    _assert_text_outputs_match_channel(plot, text_outputs.edge_labels, channels.edge_labels)
    _assert_text_outputs_match_channel(plot, text_outputs.edge_lengths, channels.edge_lengths)
    _assert_text_outputs_match_channel(
        plot,
        text_outputs.minor_gamma_labels,
        channels.minor_gamma_labels,
    )
    _assert_text_outputs_match_channel(
        plot,
        text_outputs.major_gamma_labels,
        channels.major_gamma_labels,
    )
    _assert_text_outputs_match_channel(plot, text_outputs.edge_numbers, channels.edge_numbers)
    return nothing
end

function _reactive_annotation_inputs()
    net = readnewick(REACTIVE_GRAPH_NEWICK)
    return (
        nodelabel = DataFrame(node = [first(net.node).number], label = ["node label"]),
        edgelabel = DataFrame(edge = [first(net.edge).number], label = ["edge label"]),
    )
end

@testset "Reactive graph registration" begin
    SegmentGraphOutputs = getfield(PhyloMakie, :SegmentGraphOutputs)
    ArrowheadGraphOutputs = getfield(PhyloMakie, :ArrowheadGraphOutputs)
    PhyloGraphOutputs = getfield(PhyloMakie, :PhyloGraphOutputs)
    TextGraphOutputs = getfield(PhyloMakie, :TextGraphOutputs)
    PhyloTextGraphOutputs = getfield(PhyloMakie, :PhyloTextGraphOutputs)
    phylo_graph_output_symbols = getfield(PhyloMakie, :phylo_graph_output_symbols)
    register_phylo_graph! = getfield(PhyloMakie, :register_phylo_graph!)
    _register_phylo_intermediate_nodes! =
        getfield(PhyloMakie, :_register_phylo_intermediate_nodes!)
    PhyloPlot = getfield(PhyloMakie, :PhyloPlot)

    @testset "output-node inventory and channel field mapping" begin
        plot, outputs = _registered_reactive_plot()
        repeated_outputs = register_phylo_graph!(plot)

        @test hasmethod(register_phylo_graph!, Tuple{PhyloPlot})
        @test hasmethod(_register_phylo_intermediate_nodes!, Tuple{PhyloPlot})
        @test !hasmethod(register_phylo_graph!, Tuple{Makie.Plot})
        @test !hasmethod(_register_phylo_intermediate_nodes!, Tuple{Makie.Plot})
        @test outputs == repeated_outputs
        @test outputs.primitive_outputs isa PhyloGraphOutputs
        @test outputs.primitive_outputs.edge_segments isa SegmentGraphOutputs
        @test outputs.primitive_outputs.minor_arrowheads isa ArrowheadGraphOutputs
        @test outputs.text_outputs isa PhyloTextGraphOutputs
        @test outputs.text_outputs.tip_labels isa TextGraphOutputs

        required_symbols = phylo_graph_output_symbols()
        @test length(required_symbols) == 75
        @test allunique(required_symbols)
        @test all(symbol -> haskey(plot.attributes.outputs, symbol), required_symbols)
        @test !(:minor_arrowhead_pixel_startpoints in required_symbols)
        @test !(:minor_arrowhead_pixel_endpoints in required_symbols)
        @test outputs.primitive_outputs.minor_arrowheads.meshes ==
            :minor_arrowhead_pixel_meshes
        @test all(
            symbol -> haskey(plot.attributes.outputs, symbol),
            (
                :plot_config,
                :plot_network,
                :network_geometry,
                :layout_computation,
                :primitive_channels,
                :data_limits,
                :minor_arrowhead_pixel_startpoints,
                :minor_arrowhead_pixel_endpoints,
            ),
        )

        @test !haskey(plot.attributes.inputs, :data_limits)
        data_limits_update_error = try
            Makie.update!(plot; data_limits = Makie.Rect3d())
            nothing
        catch err
            err
        end
        @test data_limits_update_error isa ErrorException
        @test occursin(
            "Attribute data_limits not found",
            sprint(showerror, data_limits_update_error),
        )

        _assert_all_outputs_match_channels(plot, outputs)
    end

    @testset "hidden layers keep typed empty final nodes" begin
        plot, outputs = _registered_reactive_plot(
            showtiplabel = false,
            shownodelabel = false,
            minorlinetype = "blank",
        )

        @test plot[outputs.primitive_outputs.minor_edge_shafts.points][] == Makie.Point2f[]
        @test plot[outputs.primitive_outputs.minor_edge_shafts.colors][] == Makie.RGBAf[]
        @test plot[outputs.primitive_outputs.minor_edge_shafts.linewidths][] == Float32[]
        @test plot[outputs.primitive_outputs.minor_arrowheads.startpoints][] == Makie.Point2f[]
        @test plot[outputs.primitive_outputs.minor_arrowheads.endpoints][] == Makie.Point2f[]
        @test plot[outputs.primitive_outputs.minor_arrowheads.tiplengths][] == Float32[]
        @test plot[outputs.primitive_outputs.minor_arrowheads.tipwidths][] == Float32[]
        @test plot[outputs.primitive_outputs.minor_arrowheads.meshes][] ==
            getfield(PhyloMakie, :ArrowheadPixelPolygon)[]
        @test plot[outputs.primitive_outputs.minor_arrowheads.colors][] == Makie.RGBAf[]
        _assert_text_outputs_empty(plot, outputs.text_outputs.tip_labels)
        _assert_text_outputs_empty(plot, outputs.text_outputs.internal_node_names)
    end

    @testset "arrowhead meshes follow projected pixel positions" begin
        figure = Figure(size=(900, 300))
        axis = Axis(figure[1, 1])
        plot = Makie.plot!(
            axis,
            readnewick(REACTIVE_GRAPH_NEWICK);
            useedgelength=true,
            showgamma=true,
            style=:fulltree,
        )
        outputs = register_phylo_graph!(plot).primitive_outputs.minor_arrowheads

        @test !isempty(_render_colorbuffer(figure))
        startpoints_before = copy(plot[:minor_arrowhead_pixel_startpoints][])
        meshes_before = copy(plot[outputs.meshes][])
        @test !isempty(meshes_before)
        @test meshes_before == getfield(PhyloMakie, :compute_arrowhead_pixel_meshes)(
            startpoints_before,
            plot[:minor_arrowhead_pixel_endpoints][],
            plot[outputs.tiplengths][],
            plot[outputs.tipwidths][],
        )
        @test any(meshes_before) do polygon
            metrics = _arrowhead_pixel_metrics(polygon)
            return isapprox(metrics.length, 8.0f0; atol=0.25f0) &&
                isapprox(metrics.width, 6.4f0; atol=0.25f0)
        end
        @test all(meshes_before) do polygon
            return isapprox(_arrowhead_axis_wing_dot(polygon), 0.0f0; atol=0.25f0)
        end

        Makie.resize!(figure, 300, 900)
        @test !isempty(_render_colorbuffer(figure))
        startpoints_after = plot[:minor_arrowhead_pixel_startpoints][]
        meshes_after = plot[outputs.meshes][]
        @test startpoints_after != startpoints_before
        @test meshes_after != meshes_before
        @test any(meshes_after) do polygon
            metrics = _arrowhead_pixel_metrics(polygon)
            return isapprox(metrics.length, 8.0f0; atol=0.25f0) &&
                isapprox(metrics.width, 6.4f0; atol=0.25f0)
        end
        @test all(meshes_after) do polygon
            return isapprox(_arrowhead_axis_wing_dot(polygon), 0.0f0; atol=0.25f0)
        end
    end

    @testset "hidden text groups keep typed empty final nodes" begin
        annotations = _reactive_annotation_inputs()
        base_kwargs = (
            shownodelabel = true,
            shownodenumber = true,
            showedgelength = true,
            showedgenumber = true,
            showgamma = true,
            nodelabel = annotations.nodelabel,
            edgelabel = annotations.edgelabel,
        )

        single_group_cases = (
            (
                label = "tip labels",
                update = (showtiplabel = false,),
                select = text_outputs -> text_outputs.tip_labels,
            ),
            (
                label = "internal node names",
                update = (shownodelabel = false,),
                select = text_outputs -> text_outputs.internal_node_names,
            ),
            (
                label = "node numbers",
                update = (shownodenumber = false,),
                select = text_outputs -> text_outputs.node_numbers,
            ),
            (
                label = "node labels",
                update = (nodelabel = DataFrame(),),
                select = text_outputs -> text_outputs.node_labels,
            ),
            (
                label = "edge labels",
                update = (edgelabel = DataFrame(),),
                select = text_outputs -> text_outputs.edge_labels,
            ),
            (
                label = "edge lengths",
                update = (showedgelength = false,),
                select = text_outputs -> text_outputs.edge_lengths,
            ),
            (
                label = "edge numbers",
                update = (showedgenumber = false,),
                select = text_outputs -> text_outputs.edge_numbers,
            ),
        )

        for case in single_group_cases
            @testset "$(case.label)" begin
                plot, outputs = _registered_reactive_plot(; base_kwargs...)
                graph_outputs = case.select(outputs.text_outputs)
                @test !isempty(plot[graph_outputs.positions][])
                Makie.update!(plot; case.update...)
                _assert_text_outputs_empty(plot, graph_outputs)
            end
        end

        @testset "gamma labels" begin
            plot, outputs = _registered_reactive_plot(; base_kwargs...)
            minor_outputs = outputs.text_outputs.minor_gamma_labels
            major_outputs = outputs.text_outputs.major_gamma_labels
            @test !isempty(plot[minor_outputs.positions][])
            @test !isempty(plot[major_outputs.positions][])
            Makie.update!(plot; showgamma = false)
            _assert_text_outputs_empty(plot, minor_outputs)
            _assert_text_outputs_empty(plot, major_outputs)
        end
    end

    @testset "Makie.update! recomputes public attribute and style outputs" begin
        plot, outputs = _registered_reactive_plot()
        primitive_outputs = outputs.primitive_outputs

        before_colors = copy(plot[primitive_outputs.edge_segments.colors][])
        Makie.update!(plot; edgecolor = "firebrick")
        after_colors = plot[primitive_outputs.edge_segments.colors][]
        @test after_colors != before_colors
        @test length(after_colors) == length(plot[primitive_outputs.edge_segments.points][])

        before_widths = copy(plot[primitive_outputs.edge_segments.linewidths][])
        Makie.update!(plot; edgewidth = 4.0)
        after_widths = plot[primitive_outputs.edge_segments.linewidths][]
        @test after_widths != before_widths
        @test all(==(4.0f0), after_widths)

        before_arrowheads = copy(plot[primitive_outputs.minor_arrowheads.meshes][])
        @test !isempty(before_arrowheads)
        Makie.update!(plot; style = :majortree)
        after_arrowheads = plot[primitive_outputs.minor_arrowheads.meshes][]
        @test after_arrowheads != before_arrowheads
        @test isempty(after_arrowheads)
    end

    @testset "Makie.update! recomputes limits and text outputs" begin
        plot, outputs = _registered_reactive_plot()

        before_limits = plot[outputs.primitive_outputs.data_limits][]
        Makie.update!(plot; xlim = (0.0, 5.0), ylim = (-1.0, 4.0))
        after_limits = plot[outputs.primitive_outputs.data_limits][]
        @test after_limits != before_limits
        @test _reactive_limits_tuple(after_limits) == ((0.0, 5.0), (-1.0, 4.0))

        Makie.update!(plot; showtiplabel = false)
        @test plot[outputs.text_outputs.tip_labels.positions][] == Makie.Point2f[]
        @test plot[outputs.text_outputs.tip_labels.strings][] == String[]
        @test plot[outputs.text_outputs.tip_labels.colors][] == Makie.RGBAf[]
        @test plot[outputs.text_outputs.tip_labels.fontsizes][] == Float32[]
    end

    @testset "Makie.update! with arg1 preserves caller-owned networks" begin
        plot, outputs = _registered_reactive_plot()
        before_points = copy(plot[outputs.primitive_outputs.edge_segments.points][])

        new_net = readnewick(REACTIVE_GRAPH_ALT_NEWICK)
        before_snapshot = _reactive_network_snapshot(new_net)
        Makie.update!(plot; arg1 = new_net)

        after_points = plot[outputs.primitive_outputs.edge_segments.points][]
        prepared_network = plot[:plot_network][]
        @test after_points != before_points
        @test _reactive_network_snapshot(new_net) == before_snapshot
        @test prepared_network.net !== new_net
        @test !isempty(prepared_network.net.vec_node)
    end
end
