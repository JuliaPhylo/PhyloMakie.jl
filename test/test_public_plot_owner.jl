using CairoMakie
using Makie
using PhyloNetworks

function _capture_network_snapshot(net::HybridNetwork)
    return (
        rooti=net.rooti,
        node_numbers=[node.number for node in net.node],
        preorder_numbers=[node.number for node in net.vec_node],
        edge_state=[
            (
                number=edge.number,
                parent=PhyloNetworks.getparent(edge).number,
                child=PhyloNetworks.getchild(edge).number,
                ischild1=edge.ischild1,
                containroot=hasfield(typeof(edge), :containroot) ? getfield(edge, :containroot) : nothing,
                hybrid=edge.hybrid,
                ismajor=edge.ismajor,
                length=edge.length,
                gamma=edge.gamma,
            ) for edge in net.edge
        ],
    )
end

function _plot_data_limits(plot)
    limits = Makie.data_limits(plot)
    return (
        (Float64(minimum(limits)[1]), Float64(maximum(limits)[1])),
        (Float64(minimum(limits)[2]), Float64(maximum(limits)[2])),
    )
end

function _plot_colorbuffer(figure)
    CairoMakie.activate!()
    return Makie.colorbuffer(figure; backend=CairoMakie)
end

function _resolved_layout(plot)
    return Makie.to_value(plot[:resolved_layout])
end

function _render_layers(plot)
    return Makie.to_value(plot[:render_layers])
end

@testset "Public plot owner" begin
    CairoMakie.activate!()

    PhyloPlot = getfield(PhyloMakie, :PhyloPlot)
    PlotLayout = getfield(PhyloMakie, :PlotLayout)
    PlotRenderLayers = getfield(PhyloMakie, :PlotRenderLayers)

    render_case = FIXTURE_CORPUS.render_regression_cases.gamma_and_edgecolor
    render_kwargs = (
        use_edge_lengths=true,
        show_gamma=true,
        edge_color=Dict(render_case.edgecolor_overrides),
        default_edge_color=render_case.defaultedgecolor,
        edge_width=Dict(render_case.edgewidth_overrides),
        style=:fulltree,
    )

    @testset "Surface registration and non-mutating parity" begin
        plot_surface = Makie.plot(readnewick(render_case.newick); render_kwargs...)
        convenience_surface = phyloplot(readnewick(render_case.newick); render_kwargs...)

        @test plot_surface isa Makie.FigureAxisPlot
        @test convenience_surface isa Makie.FigureAxisPlot
        @test plot_surface.plot isa PhyloPlot
        @test convenience_surface.plot isa PhyloPlot
        @test _resolved_layout(plot_surface.plot) isa PlotLayout
        @test _resolved_layout(convenience_surface.plot) isa PlotLayout
        @test _render_layers(plot_surface.plot) isa PlotRenderLayers
        @test _render_layers(convenience_surface.plot) isa PlotRenderLayers
        @test _plot_colorbuffer(plot_surface.figure) ==
            _plot_colorbuffer(convenience_surface.figure)
    end

    @testset "Mutating parity and stored artifacts" begin
        plot_figure = Figure(size=(640, 400))
        plot_axis = Axis(plot_figure[1, 1])
        hidedecorations!(plot_axis)
        hidespines!(plot_axis)
        plot_surface = Makie.plot!(plot_axis, readnewick(render_case.newick); render_kwargs...)

        convenience_figure = Figure(size=(640, 400))
        convenience_axis = Axis(convenience_figure[1, 1])
        hidedecorations!(convenience_axis)
        hidespines!(convenience_axis)
        convenience_surface = phyloplot!(convenience_axis, readnewick(render_case.newick); render_kwargs...)

        @test plot_surface isa PhyloPlot
        @test convenience_surface isa PhyloPlot
        @test _resolved_layout(plot_surface) isa PlotLayout
        @test _resolved_layout(convenience_surface) isa PlotLayout
        @test _render_layers(plot_surface) isa PlotRenderLayers
        @test _render_layers(convenience_surface) isa PlotRenderLayers
        @test _plot_colorbuffer(plot_figure) == _plot_colorbuffer(convenience_figure)
    end

    @testset "Caller-owned network boundary" begin
        surfaces = (
            net -> Makie.plot(net; use_edge_lengths=true, style=:fulltree),
            net -> phyloplot(net; use_edge_lengths=true, style=:fulltree),
            net -> begin
                figure = Figure()
                axis = Axis(figure[1, 1])
                Makie.plot!(axis, net; use_edge_lengths=true, style=:fulltree)
            end,
            net -> begin
                figure = Figure()
                axis = Axis(figure[1, 1])
                phyloplot!(axis, net; use_edge_lengths=true, style=:fulltree)
            end,
        )

        for surface in surfaces
            network = readnewick(render_case.newick)
            before = _capture_network_snapshot(network)
            surface(network)
            @test _capture_network_snapshot(network) == before
        end
    end

    @testset "Public limit validation and direct limit proof" begin
        annotation_case = FIXTURE_CORPUS.render_regression_cases.annotation_and_limits
        node_annotations =
            _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows)
        edge_annotations =
            _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows)
        limit_surface = Makie.plot(
            readnewick(annotation_case.newick);
            use_edge_lengths=true,
            show_internal_node_names=true,
            show_node_numbers=true,
            show_edge_lengths=true,
            show_edge_numbers=true,
            show_gamma=true,
            node_annotations=node_annotations,
            edge_annotations=edge_annotations,
            x_limits=annotation_case.xlim,
            y_limits=annotation_case.ylim,
            style=:majortree,
        )
        layers = _render_layers(limit_surface.plot)
        @test layers.applied_xlim == annotation_case.xlim
        @test layers.applied_ylim == annotation_case.ylim

        x_limit_error = try
            Makie.plot(readnewick(annotation_case.newick); x_limits=[1.0, 2.0, 3.0])
            nothing
        catch err
            err
        end
        @test x_limit_error isa ErrorException
        @test occursin("x_limits needs to contain 2 values", sprint(showerror, x_limit_error))
        @test occursin("defaults: [", sprint(showerror, x_limit_error))

        y_limit_error = try
            phyloplot(readnewick(annotation_case.newick); y_limits=(1.0,))
            nothing
        catch err
            err
        end
        @test y_limit_error isa ErrorException
        @test occursin("y_limits needs to contain 2 values", sprint(showerror, y_limit_error))
        @test occursin("defaults: [", sprint(showerror, y_limit_error))
    end

    @testset "Legacy keyword rejection" begin
        network = readnewick(render_case.newick)

        legacy_name_error = try
            Makie.plot(network; showtiplabel=true)
            nothing
        catch err
            err
        end
        @test legacy_name_error isa ArgumentError
        @test occursin("showtiplabel", sprint(showerror, legacy_name_error))
        @test occursin("show_tip_labels", sprint(showerror, legacy_name_error))

        legacy_limit_error = try
            phyloplot(readnewick(render_case.newick); xlim=(0.0, 1.0))
            nothing
        catch err
            err
        end
        @test legacy_limit_error isa ArgumentError
        @test occursin("xlim", sprint(showerror, legacy_limit_error))
        @test occursin("x_limits", sprint(showerror, legacy_limit_error))

        preorder_error = try
            Makie.plot(readnewick(render_case.newick); preorder=false)
            nothing
        catch err
            err
        end
        @test preorder_error isa ArgumentError
        @test occursin("preorder", sprint(showerror, preorder_error))
        @test occursin("not accepted", sprint(showerror, preorder_error))
    end

    @testset "Dual-axis composition proof" begin
        scenario = FIXTURE_CORPUS.accepted_design_scenarios.composable_dual_axes

        figure = Figure(size=(900, 360))
        left_axis = Axis(figure[1, 1])
        right_axis = Axis(figure[1, 2])
        hidedecorations!(left_axis)
        hidespines!(left_axis)
        hidedecorations!(right_axis)
        hidespines!(right_axis)

        left_plot = Makie.plot!(
            left_axis,
            readnewick(scenario.newicks[1]);
            use_edge_lengths=true,
            show_gamma=true,
            style=:fulltree,
        )
        right_plot = phyloplot!(
            right_axis,
            readnewick(scenario.newicks[2]);
            use_edge_lengths=true,
            show_edge_numbers=true,
            style=:majortree,
        )

        left_limits = _plot_data_limits(left_plot)
        right_limits = _plot_data_limits(right_plot)
        left_layers = _render_layers(left_plot)
        right_layers = _render_layers(right_plot)

        @test left_limits[1] == left_layers.applied_xlim
        @test left_limits[2] == left_layers.applied_ylim
        @test right_limits[1] == right_layers.applied_xlim
        @test right_limits[2] == right_layers.applied_ylim
        @test left_plot.parent !== right_plot.parent
        @test left_limits != right_limits
        @test !isempty(_plot_colorbuffer(figure))
    end
end
