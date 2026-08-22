function _plot_data_limits_value(rect::Makie.Rect3d)
    rect_min = minimum(rect)
    rect_max = maximum(rect)
    return (
        (Float64(rect_min[1]), Float64(rect_max[1])),
        (Float64(rect_min[2]), Float64(rect_max[2])),
    )
end

@testset "Primitive channel computation" begin
    SegmentChannel = getfield(PhyloMakie, :SegmentChannel)
    TextChannel = getfield(PhyloMakie, :TextChannel)
    ArrowheadSpecChannel = getfield(PhyloMakie, :ArrowheadSpecChannel)
    PrimitiveChannels = getfield(PhyloMakie, :PrimitiveChannels)
    prepare_plot_network = getfield(PhyloMakie, :prepare_plot_network)
    compute_network_geometry = getfield(PhyloMakie, :compute_network_geometry)
    compute_layout = getfield(PhyloMakie, :compute_layout)
    compute_arrowhead_channel = getfield(PhyloMakie, :compute_arrowhead_channel)
    compute_primitive_channels = getfield(PhyloMakie, :compute_primitive_channels)
    resolve_plot_config = getfield(PhyloMakie, :resolve_plot_config)

    function primitive_channels_for(newick::AbstractString; kwargs...)
        plot_network = prepare_plot_network(PhyloMakie.readnewick(newick))
        config = resolve_plot_config(; kwargs...)
        geometry = compute_network_geometry(plot_network, config)
        layout = compute_layout(plot_network, config, geometry)
        return compute_primitive_channels(plot_network, config, layout)
    end

    @testset "Segment, text, and data-limit channels are typed" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.annotation_and_limits
        channels = primitive_channels_for(
            render_case.newick;
            render_case.attribute_kwargs...,
            xlim=render_case.xlim,
            ylim=render_case.ylim,
        )

        @test channels isa PrimitiveChannels
        @test channels.edge_segments isa SegmentChannel
        @test channels.tip_labels isa TextChannel
        @test channels.minor_arrowheads isa ArrowheadSpecChannel
        @test eltype(channels.edge_segments.points) == Makie.Point2f
        @test eltype(channels.edge_segments.colors) == Makie.RGBAf
        @test eltype(channels.edge_segments.linewidths) == Float32
        @test eltype(channels.tip_labels.positions) == Makie.Point2f
        @test eltype(channels.tip_labels.strings) == String
        @test eltype(channels.tip_labels.colors) == Makie.RGBAf
        @test eltype(channels.tip_labels.fontsizes) == Float32
        @test _plot_data_limits_value(channels.data_limits)[1] == render_case.xlim
        @test _plot_data_limits_value(channels.data_limits)[2] == render_case.ylim
    end

    @testset "Hidden channels use typed empty vectors" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.style_fulltree
        channels = primitive_channels_for(
            render_case.newick;
            render_case.attribute_kwargs...,
            showtiplabel=false,
            minorlinetype="blank",
        )

        @test channels.minor_edge_shafts.points == Makie.Point2f[]
        @test channels.minor_edge_shafts.colors == Makie.RGBAf[]
        @test channels.minor_edge_shafts.linewidths == Float32[]
        @test channels.minor_arrowheads.startpoints == Makie.Point2f[]
        @test channels.minor_arrowheads.endpoints == Makie.Point2f[]
        @test channels.minor_arrowheads.tiplengths == Float32[]
        @test channels.minor_arrowheads.tipwidths == Float32[]
        @test channels.minor_arrowheads.colors == Makie.RGBAf[]
        @test channels.minor_arrowheads.source_indices == Int[]
        @test channels.tip_labels.positions == Makie.Point2f[]
        @test channels.tip_labels.strings == String[]
        @test channels.tip_labels.colors == Makie.RGBAf[]
        @test channels.tip_labels.fontsizes == Float32[]
    end

    @testset "Hybrid arrowheads are computed as pixel-metric specs" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.style_fulltree
        channels = primitive_channels_for(
            render_case.newick;
            render_case.attribute_kwargs...,
        )

        @test !isempty(channels.minor_arrowheads.startpoints)
        @test eltype(channels.minor_arrowheads.startpoints) == Makie.Point2f
        @test eltype(channels.minor_arrowheads.endpoints) == Makie.Point2f
        @test length(channels.minor_arrowheads.colors) ==
            length(channels.minor_arrowheads.startpoints)
        @test length(channels.minor_arrowheads.strokecolors) ==
            length(channels.minor_arrowheads.startpoints)
        @test length(channels.minor_arrowheads.source_indices) ==
            length(channels.minor_arrowheads.startpoints)
        @test channels.minor_arrowheads.tiplengths ==
            fill(8.0f0, length(channels.minor_arrowheads.startpoints))
        @test channels.minor_arrowheads.tipwidths ==
            fill(6.4f0, length(channels.minor_arrowheads.startpoints))
    end

    @testset "Suppressed arrowheads keep channel arrays aligned" begin
        points = Makie.Point2f[(0, 0), (1, 0), (0, 1), (1, 1)]
        shaft_channel = SegmentChannel(
            points,
            fill(Makie.RGBAf(0, 0, 0, 1), length(points)),
            fill(1.0f0, length(points)),
            :dash,
        )
        input_colors = Makie.RGBAf[
            Makie.RGBAf(1, 0, 0, 1),
            Makie.RGBAf(0, 1, 0, 1),
        ]
        arrowheads = compute_arrowhead_channel(
            shaft_channel,
            input_colors,
            Float32[0, 8],
            Float32[4, 4],
            true,
        )

        @test arrowheads.source_indices == [2]
        @test arrowheads.startpoints == Makie.Point2f[points[3]]
        @test arrowheads.endpoints == Makie.Point2f[points[4]]
        @test arrowheads.colors == Makie.RGBAf[input_colors[2]]
        @test arrowheads.strokecolors == Makie.RGBAf[input_colors[2]]
        @test arrowheads.tiplengths == Float32[8]
        @test arrowheads.tipwidths == Float32[4]
        @test length(arrowheads.colors) == length(arrowheads.startpoints)
        @test length(arrowheads.colors) == length(arrowheads.endpoints)
        @test length(arrowheads.colors) == length(arrowheads.tiplengths)
        @test length(arrowheads.colors) == length(arrowheads.tipwidths)
    end
end
