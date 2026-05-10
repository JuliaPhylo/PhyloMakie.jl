@testset "Render adapter owner" begin
    DEFAULT_TEXT_SIZE = getfield(PhyloMakie, :DEFAULT_TEXT_SIZE)
    PlotRenderLayers = getfield(PhyloMakie, :PlotRenderLayers)

    _expected_fontsizes(scale::Real, count::Integer) =
        fill(DEFAULT_TEXT_SIZE * Float64(scale), count)
    _expected_fontsizes(scales::AbstractVector, count::Integer) =
        [DEFAULT_TEXT_SIZE * Float64(scales[mod1(index, length(scales))]) for index in 1:count]
    _expected_default_fontsizes(count::Integer) = fill(DEFAULT_TEXT_SIZE, count)

    @testset "Style distinction and internal owner typing" begin
        render_cases = FIXTURE_CORPUS.render_regression_cases
        fulltree_case = _render_case(
            render_cases.style_fulltree.newick;
            render_cases.style_fulltree.keyword_args...,
        )
        majortree_case = _render_case(
            render_cases.style_majortree.newick;
            render_cases.style_majortree.keyword_args...,
        )

        @test fulltree_case.layers isa PlotRenderLayers
        @test majortree_case.layers isa PlotRenderLayers
        @test fulltree_case.layers.resolved_style == :fulltree
        @test majortree_case.layers.resolved_style == :majortree
        @test fulltree_case.layers.minor_edge_shafts.linestyle == :dash
        @test majortree_case.layers.minor_edge_shafts.linestyle == :solid
        @test _render_colorbuffer(fulltree_case.figure) != _render_colorbuffer(majortree_case.figure)
    end

    @testset "Minor edge linestyle surface" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.style_fulltree
        dotted_case = _render_case(
            render_case.newick;
            render_case.keyword_args...,
            minorlinetype=3,
        )
        blank_case = _render_case(
            render_case.newick;
            render_case.keyword_args...,
            minorlinetype="blank",
        )

        @test dotted_case.layers.minor_edge_shafts.linestyle == :dot
        @test dotted_case.layers.minor_edge_shafts.plot !== nothing
        @test length(dotted_case.layers.minor_edge_tips.plots) ==
            length(dotted_case.layers.minor_edge_tips.startpoints)

        @test blank_case.layers.minor_edge_shafts.plot === nothing
        @test isempty(blank_case.layers.minor_edge_tips.plots)
        @test all(iszero, blank_case.layers.minor_edge_tips.tiplengths)
        @test all(iszero, blank_case.layers.minor_edge_tips.tipwidths)
    end

    @testset "Color and width policy" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.gamma_and_edgecolor
        edgecolor = Dict(render_case.edgecolor_overrides)
        edgewidth = Dict(render_case.edgewidth_overrides)
        case = _render_case(
            render_case.newick;
            render_case.keyword_args...,
            edgecolor=edgecolor,
            defaultedgecolor=render_case.defaultedgecolor,
            edgewidth=edgewidth,
        )

        expected_edge_colors = Makie.RGBAf[]
        expected_minor_edge_colors = Makie.RGBAf[]
        expected_edge_widths = Float64[]
        expected_minor_edge_widths = Float64[]
        fallback_color = _rgba(render_case.defaultedgecolor)
        for edge in case.network.edge
            resolved_color = _rgba(get(edgecolor, edge.number, render_case.defaultedgecolor))
            resolved_width = Float64(get(edgewidth, edge.number, 1.0))
            push!(expected_edge_colors, resolved_color)
            push!(expected_edge_widths, resolved_width)
            if !edge.ismajor
                push!(expected_minor_edge_colors, resolved_color)
                push!(expected_minor_edge_widths, resolved_width)
            end
        end

        @test case.layers.edge_segments.colors == expected_edge_colors
        @test case.layers.edge_segments.linewidths == expected_edge_widths
        @test case.layers.minor_edge_shafts.colors == expected_minor_edge_colors
        @test case.layers.minor_edge_shafts.linewidths == expected_minor_edge_widths
        @test case.layers.node_bars.colors == fill(fallback_color, case.network.numnodes)

        expected_minor_gamma_color = fill(
            _rgba(case.spec.colors.minorhybridedgecolor),
            length(case.layers.minor_gamma_labels.strings),
        )
        expected_major_gamma_color = fill(
            _rgba(case.spec.colors.majorhybridedgecolor),
            length(case.layers.major_gamma_labels.strings),
        )
        @test case.layers.minor_gamma_labels.colors == expected_minor_gamma_color
        @test case.layers.major_gamma_labels.colors == expected_major_gamma_color
    end

    @testset "Text size policy" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.annotation_and_limits
        node_labels = _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows)
        edge_labels = _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows)
        scalar_case = _render_case(
            render_case.newick;
            render_case.keyword_args...,
            nodelabel=node_labels,
            edgelabel=edge_labels,
            tipcex=4.0,
            nodecex=3.0,
            edgecex=2.0,
        )

        @test scalar_case.layers.tip_labels.fontsize ==
            _expected_fontsizes(4.0, length(scalar_case.layers.tip_labels.strings))
        @test scalar_case.layers.internal_node_names.fontsize ==
            _expected_fontsizes(4.0, length(scalar_case.layers.internal_node_names.strings))
        @test scalar_case.layers.node_numbers.fontsize ==
            _expected_default_fontsizes(length(scalar_case.layers.node_numbers.strings))
        @test scalar_case.layers.node_annotations.fontsize ==
            _expected_fontsizes(3.0, length(scalar_case.layers.node_annotations.strings))
        @test scalar_case.layers.edge_annotations.fontsize ==
            _expected_fontsizes(2.0, length(scalar_case.layers.edge_annotations.strings))
        @test scalar_case.layers.edge_lengths.fontsize ==
            _expected_default_fontsizes(length(scalar_case.layers.edge_lengths.strings))
        @test scalar_case.layers.minor_gamma_labels.fontsize ==
            _expected_default_fontsizes(length(scalar_case.layers.minor_gamma_labels.strings))
        @test scalar_case.layers.major_gamma_labels.fontsize ==
            _expected_default_fontsizes(length(scalar_case.layers.major_gamma_labels.strings))
        @test scalar_case.layers.edge_numbers.fontsize ==
            _expected_default_fontsizes(length(scalar_case.layers.edge_numbers.strings))

        vector_case = _render_case(
            render_case.newick;
            render_case.keyword_args...,
            nodelabel=node_labels,
            tipcex=[0.5, 1.0, 1.5],
            nodecex=[0.75, 1.25],
        )

        @test vector_case.layers.tip_labels.fontsize ==
            _expected_fontsizes([0.5, 1.0, 1.5], length(vector_case.layers.tip_labels.strings))
        @test vector_case.layers.internal_node_names.fontsize ==
            _expected_fontsizes(
                [0.5, 1.0, 1.5],
                length(vector_case.layers.internal_node_names.strings),
            )
        @test vector_case.layers.node_annotations.fontsize ==
            _expected_fontsizes([0.75, 1.25], length(vector_case.layers.node_annotations.strings))

        documented_edgecex_case = _render_case(
            "(A,((B,#H1),(C,(D)#H1)));";
            edgelabel=DataFrame(number=[1, 2], label=["edge number 1", "edge # 2"]),
            edgecex=[0.9, 1.1],
        )

        @test documented_edgecex_case.layers.edge_annotations.fontsize ==
            _expected_fontsizes(
                [0.9, 1.1],
                length(documented_edgecex_case.layers.edge_annotations.strings),
            )
    end

    @testset "Text channels and applied limits" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.annotation_and_limits
        node_labels = _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows)
        edge_labels = _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows)
        case = _render_case(
            render_case.newick;
            render_case.keyword_args...,
            nodelabel=node_labels,
            edgelabel=edge_labels,
            xlim=render_case.xlim,
            ylim=render_case.ylim,
        )

        node_data = case.layout.annotations.node_data
        edge_data = case.layout.annotations.edge_data
        leaf_rows = _rows_with_flag(node_data.lea)
        internal_rows = _rows_with_flag(.!node_data.lea)
        minor_gamma_rows = _rows_with_flag(edge_data.hyb .& edge_data.min)
        major_gamma_rows = _rows_with_flag(edge_data.hyb .& .!edge_data.min)

        @test case.layers.applied_xlim == render_case.xlim
        @test case.layers.applied_ylim == render_case.ylim

        @test case.layers.tip_labels.strings == String.(node_data[leaf_rows, :name])
        @test case.layers.tip_labels.positions ==
            _node_channel_positions(case.layout, leaf_rows; x_offset=case.spec.layout.tipoffset)

        @test case.layers.internal_node_names.strings == String.(node_data[internal_rows, :name])
        @test case.layers.internal_node_names.positions ==
            _node_channel_positions(case.layout, internal_rows)

        @test case.layers.node_numbers.strings == String.(node_data[!, :num])
        @test case.layers.node_numbers.positions ==
            _node_channel_positions(case.layout, axes(node_data, 1))

        @test case.layers.node_annotations.strings == String.(node_data[!, :lab])
        @test case.layers.node_annotations.positions ==
            _node_channel_positions(case.layout, axes(node_data, 1))

        @test case.layers.edge_annotations.strings == String.(edge_data[!, :lab])
        @test case.layers.edge_annotations.positions ==
            _edge_channel_positions(case.layout, axes(edge_data, 1))

        @test case.layers.edge_lengths.strings == String.(edge_data[!, :len])
        @test case.layers.edge_lengths.positions ==
            _edge_channel_positions(case.layout, axes(edge_data, 1))

        @test case.layers.edge_numbers.strings == String.(edge_data[!, :num])
        @test case.layers.edge_numbers.positions ==
            _edge_channel_positions(case.layout, axes(edge_data, 1))

        @test case.layers.minor_gamma_labels.strings == String.(edge_data[minor_gamma_rows, :gam])
        @test case.layers.minor_gamma_labels.positions ==
            _edge_channel_positions(case.layout, minor_gamma_rows)

        @test case.layers.major_gamma_labels.strings == String.(edge_data[major_gamma_rows, :gam])
        @test case.layers.major_gamma_labels.positions ==
            _edge_channel_positions(case.layout, major_gamma_rows)
    end
end
