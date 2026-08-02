using CairoMakie
using DataFrames: DataFrame, nrow
using Makie
using PhyloNetworks

@testset "Coordinate queries" begin
    CairoMakie.activate!()

    @testset "Row counts are complete regardless of display toggles" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.style_fulltree
        case = _public_render_case(
            render_case.newick;
            render_case.attribute_kwargs...,
        )

        node_table = node_positions(case.plot)
        edge_table = edge_positions(case.plot)
        @test nrow(node_table) == case.network.numnodes
        @test nrow(edge_table) == case.network.numedges

        # The historical gap: the display-facing annotation table under this
        # config (no shownodenumber/shownodelabel/nodelabel) only ever covers
        # tips, so it must not be the source for a coordinate query.
        @test nrow(case.layout.annotations.node_data) == case.network.numtaxa
        @test case.network.numtaxa < case.network.numnodes
    end

    @testset "Tip rows match rendered tip label positions" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.style_fulltree
        case = _public_render_case(
            render_case.newick;
            render_case.attribute_kwargs...,
        )

        tip_rows = filter(:isleaf => identity, node_positions(case.plot))
        actual_positions = Makie.Point2f[
            Makie.Point2f(Float32(row.x), Float32(row.y)) for row in eachrow(tip_rows)
        ]
        @test actual_positions == case.channels.tip_labels.positions
    end

    @testset "Minor hybrid edge anchors at arrowhead midpoint under style=:majortree" begin
        layout_case = FIXTURE_CORPUS.layout_regression_cases.without_lengths_majortree
        case = _public_render_case(
            layout_case.newick;
            layout_case.attribute_kwargs...,
        )
        edge_table = edge_positions(case.plot)

        expected = FIXTURE_CORPUS.table_expectations.major_tree_minor_edge_midpoint
        minor_row = only(filter(:number => ==(parse(Int, expected.edge_number)), edge_table))
        @test minor_row.ishybrid
        @test !minor_row.ismajor
        @test minor_row.x == expected.x
        @test minor_row.y == expected.y

        # A major hybrid edge under the same style is not subject to the
        # arrowhead-midpoint branch and keeps its ordinary segment midpoint.
        major_hybrid_row = only(
            filter(row -> row.ishybrid && row.ismajor, edge_table),
        )
        @test !ismissing(major_hybrid_row.gamma)
    end

    @testset "Gamma reflects assigned inheritance probability; missing only when unset" begin
        # Non-hybrid edges carry gamma = 1.0 (full inheritance), not missing ---
        # PhyloNetworks' own default, confirmed directly on a hybrid-free network.
        no_hybrid_case = FIXTURE_CORPUS.accepted_design_scenarios.simple_tree_no_hybrid
        case = _public_render_case(no_hybrid_case.newick)
        edge_table = edge_positions(case.plot)
        @test all(!, edge_table.ishybrid)
        @test all(==(1.0), edge_table.gamma)

        # A hybrid edge only becomes `missing` when the network itself leaves its
        # gamma unset (PhyloNetworks' own -1.0 sentinel), not merely by being hybrid.
        with_gamma_case = FIXTURE_CORPUS.upstream_helper_regressions.level2_network_with_gamma
        without_gamma_case =
            FIXTURE_CORPUS.upstream_helper_regressions.level2_network_without_gamma

        with_gamma_table = edge_positions(
            _public_render_case(with_gamma_case.newick; showgamma=with_gamma_case.showgamma).plot,
        )
        without_gamma_table = edge_positions(
            _public_render_case(
                without_gamma_case.newick;
                showgamma=without_gamma_case.showgamma,
            ).plot,
        )

        with_gamma_hybrid_rows = filter(:ishybrid => identity, with_gamma_table)
        without_gamma_hybrid_rows = filter(:ishybrid => identity, without_gamma_table)
        @test !isempty(with_gamma_hybrid_rows)
        @test all(!ismissing, with_gamma_hybrid_rows.gamma)
        @test any(ismissing, without_gamma_hybrid_rows.gamma)
    end

    @testset "Returned tables do not alias live compute-graph state" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.style_fulltree
        case = _public_render_case(
            render_case.newick;
            render_case.attribute_kwargs...,
        )

        before_image = _render_colorbuffer(case.figure)
        first_nodes = node_positions(case.plot)
        first_nodes.x[1] = -999.0
        second_nodes = node_positions(case.plot)
        @test second_nodes.x[1] != -999.0
        @test _render_colorbuffer(case.figure) == before_image

        first_edges = edge_positions(case.plot)
        first_edges.x[1] = -999.0
        second_edges = edge_positions(case.plot)
        @test second_edges.x[1] != -999.0
    end

    @testset "Positions update after Makie.update!" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.style_fulltree
        surface = Makie.plot(readnewick(render_case.newick); useedgelength=false, style=:fulltree)
        plot = surface.plot

        before_x = node_positions(plot).x
        Makie.update!(plot; useedgelength=true)
        after_x = node_positions(plot).x
        @test before_x != after_x
    end
end
