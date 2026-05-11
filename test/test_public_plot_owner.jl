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

@testset "Public plot owner" begin
    CairoMakie.activate!()

    PhyloPlot = getfield(PhyloMakie, :PhyloPlot)

    render_case = FIXTURE_CORPUS.render_regression_cases.gamma_and_edgecolor
    render_kwargs = (
        useedgelength=true,
        showgamma=true,
        edgecolor=Dict(render_case.edgecolor_overrides),
        defaultedgecolor=render_case.defaultedgecolor,
        edgewidth=Dict(render_case.edgewidth_overrides),
        style=:fulltree,
    )

    @testset "Surface registration and non-mutating parity" begin
        plot_surface = Makie.plot(readnewick(render_case.newick); render_kwargs...)
        convenience_surface = phyloplot(readnewick(render_case.newick); render_kwargs...)

        @test plot_surface isa Makie.FigureAxisPlot
        @test convenience_surface isa Makie.FigureAxisPlot
        @test plot_surface.plot isa PhyloPlot
        @test convenience_surface.plot isa PhyloPlot
        @test :resolved_attributes ∉ propertynames(plot_surface.plot.attributes)
        @test :resolved_layout ∉ propertynames(plot_surface.plot.attributes)
        @test :render_layers ∉ propertynames(plot_surface.plot.attributes)
        @test :resolved_attributes ∉ propertynames(convenience_surface.plot.attributes)
        @test :resolved_layout ∉ propertynames(convenience_surface.plot.attributes)
        @test :render_layers ∉ propertynames(convenience_surface.plot.attributes)
        @test _plot_colorbuffer(plot_surface.figure) ==
            _plot_colorbuffer(convenience_surface.figure)
    end

    @testset "Mutating parity and public-surface cleanliness" begin
        plot_figure = Figure(size=(640, 400))
        plot_axis = Axis(plot_figure[1, 1])
        hidedecorations!(plot_axis)
        hidespines!(plot_axis)
        plot_surface = Makie.plot!(plot_axis, readnewick(render_case.newick); render_kwargs...)

        convenience_figure = Figure(size=(640, 400))
        convenience_axis = Axis(convenience_figure[1, 1])
        hidedecorations!(convenience_axis)
        hidespines!(convenience_axis)
        convenience_surface = phyloplot!(
            convenience_axis,
            readnewick(render_case.newick);
            render_kwargs...,
        )

        @test plot_surface isa PhyloPlot
        @test convenience_surface isa PhyloPlot
        @test :resolved_attributes ∉ propertynames(plot_surface.attributes)
        @test :resolved_layout ∉ propertynames(plot_surface.attributes)
        @test :render_layers ∉ propertynames(plot_surface.attributes)
        @test :resolved_attributes ∉ propertynames(convenience_surface.attributes)
        @test :resolved_layout ∉ propertynames(convenience_surface.attributes)
        @test :render_layers ∉ propertynames(convenience_surface.attributes)
        @test _plot_colorbuffer(plot_figure) == _plot_colorbuffer(convenience_figure)
    end

    @testset "Caller-owned network boundary" begin
        surfaces = (
            net -> Makie.plot(net; useedgelength=true, style=:fulltree),
            net -> phyloplot(net; useedgelength=true, style=:fulltree),
            net -> begin
                figure = Figure()
                axis = Axis(figure[1, 1])
                Makie.plot!(axis, net; useedgelength=true, style=:fulltree)
            end,
            net -> begin
                figure = Figure()
                axis = Axis(figure[1, 1])
                phyloplot!(axis, net; useedgelength=true, style=:fulltree)
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
        nodelabel =
            _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows)
        edgelabel =
            _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows)
        limit_surface = Makie.plot(
            readnewick(annotation_case.newick);
            useedgelength=true,
            shownodelabel=true,
            shownodenumber=true,
            showedgelength=true,
            showedgenumber=true,
            showgamma=true,
            nodelabel=nodelabel,
            edgelabel=edgelabel,
            xlim=annotation_case.xlim,
            ylim=annotation_case.ylim,
            style=:majortree,
        )

        @test _plot_data_limits(limit_surface.plot)[1] == annotation_case.xlim
        @test _plot_data_limits(limit_surface.plot)[2] == annotation_case.ylim
        @test !isempty(_plot_colorbuffer(limit_surface.figure))

        x_limit_error = try
            Makie.plot(readnewick(annotation_case.newick); xlim=[1.0, 2.0, 3.0])
            nothing
        catch err
            err
        end
        @test x_limit_error isa ErrorException
        @test occursin("xlim needs to contain 2 values", sprint(showerror, x_limit_error))
        @test occursin("defaults: [", sprint(showerror, x_limit_error))

        y_limit_error = try
            phyloplot(readnewick(annotation_case.newick); ylim=(1.0,))
            nothing
        catch err
            err
        end
        @test y_limit_error isa ErrorException
        @test occursin("ylim needs to contain 2 values", sprint(showerror, y_limit_error))
        @test occursin("defaults: [", sprint(showerror, y_limit_error))
    end

    @testset "Accepted design scenario public proof" begin
        @testset ":simple_tree_no_hybrid" begin
            scenario = FIXTURE_CORPUS.accepted_design_scenarios.simple_tree_no_hybrid
            surface = Makie.plot(readnewick(scenario.newick); style=:fulltree)

            @test surface isa Makie.FigureAxisPlot
            @test !isempty(_plot_colorbuffer(surface.figure))
        end

        @testset ":single_reticulation_gamma and :showgamma_rendering" begin
            scenario = FIXTURE_CORPUS.accepted_design_scenarios.single_reticulation_gamma
            surface = Makie.plot(
                readnewick(scenario.newick);
                useedgelength=true,
                showgamma=true,
                style=:fulltree,
            )

            @test surface isa Makie.FigureAxisPlot
            @test !isempty(_plot_colorbuffer(surface.figure))
        end

        @testset ":style_distinction_fulltree_vs_majortree" begin
            scenario = FIXTURE_CORPUS.accepted_design_scenarios.style_distinction_fulltree_vs_majortree
            fulltree_surface =
                Makie.plot(readnewick(scenario.newick); useedgelength=true, style=:fulltree)
            majortree_surface =
                Makie.plot(readnewick(scenario.newick); useedgelength=true, style=:majortree)

            @test _plot_colorbuffer(fulltree_surface.figure) !=
                _plot_colorbuffer(majortree_surface.figure)
        end

        @testset ":dataframe_label_rendering" begin
            annotation_case = FIXTURE_CORPUS.render_regression_cases.annotation_and_limits
            nodelabel =
                _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows)
            edgelabel =
                _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows)
            surface = Makie.plot(
                readnewick(annotation_case.newick);
                annotation_case.attribute_kwargs...,
                nodelabel=nodelabel,
                edgelabel=edgelabel,
                xlim=annotation_case.xlim,
                ylim=annotation_case.ylim,
            )

            @test _plot_data_limits(surface.plot)[1] == annotation_case.xlim
            @test _plot_data_limits(surface.plot)[2] == annotation_case.ylim
            @test !isempty(_plot_colorbuffer(surface.figure))
        end
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
            useedgelength=true,
            showgamma=true,
            style=:fulltree,
        )
        right_plot = phyloplot!(
            right_axis,
            readnewick(scenario.newicks[2]);
            useedgelength=true,
            showedgenumber=true,
            style=:majortree,
        )

        left_limits = _plot_data_limits(left_plot)
        right_limits = _plot_data_limits(right_plot)

        @test left_plot.parent !== right_plot.parent
        @test left_limits != right_limits
        @test !isempty(_plot_colorbuffer(figure))
    end
end
