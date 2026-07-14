using Makie
using PhyloNetworks

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
    ArrowheadChannel = getfield(PhyloMakie, :ArrowheadChannel)
    PrimitiveChannels = getfield(PhyloMakie, :PrimitiveChannels)
    prepare_plot_network = getfield(PhyloMakie, :prepare_plot_network)
    compute_network_geometry = getfield(PhyloMakie, :compute_network_geometry)
    compute_layout = getfield(PhyloMakie, :compute_layout)
    compute_primitive_channels = getfield(PhyloMakie, :compute_primitive_channels)
    resolve_plot_config = getfield(PhyloMakie, :resolve_plot_config)

    function primitive_channels_for(newick::AbstractString; kwargs...)
        plot_network = prepare_plot_network(readnewick(newick))
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
        @test channels.minor_arrowheads isa ArrowheadChannel
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
        @test channels.minor_arrowheads.meshes == getfield(PhyloMakie, :ArrowheadPolygon)[]
        @test channels.minor_arrowheads.colors == Makie.RGBAf[]
        @test channels.tip_labels.positions == Makie.Point2f[]
        @test channels.tip_labels.strings == String[]
        @test channels.tip_labels.colors == Makie.RGBAf[]
        @test channels.tip_labels.fontsizes == Float32[]
    end

    @testset "Hybrid arrowheads are computed polygon payloads" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.style_fulltree
        channels = primitive_channels_for(
            render_case.newick;
            render_case.attribute_kwargs...,
        )

        @test !isempty(channels.minor_arrowheads.meshes)
        @test eltype(channels.minor_arrowheads.meshes) == getfield(PhyloMakie, :ArrowheadPolygon)
        @test length(channels.minor_arrowheads.colors) == length(channels.minor_arrowheads.meshes)
        @test length(channels.minor_arrowheads.strokecolors) == length(channels.minor_arrowheads.meshes)
        @test all(>(0), channels.minor_arrowheads.tiplengths)
        @test all(>(0), channels.minor_arrowheads.tipwidths)
        converted = Makie.convert_arguments(Makie.Poly, channels.minor_arrowheads.meshes)
        @test only(converted) == channels.minor_arrowheads.meshes
    end
end
