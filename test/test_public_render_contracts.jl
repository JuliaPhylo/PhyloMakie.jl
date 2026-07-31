function _render_limits_tuple(rect::Makie.Rect3d)
    rect_min = minimum(rect)
    rect_max = maximum(rect)
    return (
        (Float64(rect_min[1]), Float64(rect_max[1])),
        (Float64(rect_min[2]), Float64(rect_max[2])),
    )
end

function _contract_child_ids(plot)::Vector{UInt}
    return objectid.(plot.plots)
end

function _contract_children(plot)::NamedTuple
    @test length(plot.plots) == 13
    return (
        edge_segments=plot.plots[1],
        node_bars=plot.plots[2],
        minor_edge_shafts=plot.plots[3],
        minor_arrowheads=plot.plots[4],
        tip_labels=plot.plots[5],
        internal_node_names=plot.plots[6],
        node_numbers=plot.plots[7],
        node_labels=plot.plots[8],
        edge_labels=plot.plots[9],
        edge_lengths=plot.plots[10],
        minor_gamma_labels=plot.plots[11],
        major_gamma_labels=plot.plots[12],
        edge_numbers=plot.plots[13],
    )
end

function _contract_network_snapshot(net::PhyloNetworks.HybridNetwork)
    return (
        rooti=net.rooti,
        isrooted=net.isrooted,
        preorder_numbers=[node.number for node in net.vec_node],
        edge_state=[
            (
                number=edge.number,
                parent=PhyloNetworks.getparent(edge).number,
                child=PhyloNetworks.getchild(edge).number,
                ischild1=edge.ischild1,
                containroot=hasfield(typeof(edge), :containroot) ?
                    getfield(edge, :containroot) : nothing,
            ) for edge in net.edge
        ],
    )
end

function _repeat_each(values::AbstractVector{T})::Vector{T} where {T}
    repeated = Vector{T}(undef, 2 * length(values))
    for index in eachindex(values)
        repeated[(2 * index) - 1] = values[index]
        repeated[2 * index] = values[index]
    end
    return repeated
end

function _expected_contract_fontsizes(scale::Real, count::Integer)
    return fill(getfield(PhyloMakie, :DEFAULT_TEXT_SIZE) * Float32(scale), count)
end

function _expected_contract_fontsizes(scales::AbstractVector, count::Integer)
    text_size = getfield(PhyloMakie, :DEFAULT_TEXT_SIZE)
    return Float32[text_size * Float32(scales[mod1(index, length(scales))]) for index in 1:count]
end

function _expected_default_contract_fontsizes(count::Integer)
    return fill(getfield(PhyloMakie, :DEFAULT_TEXT_SIZE), count)
end

function _assert_public_surface_rendered(surface)
    @test surface isa Makie.FigureAxisPlot
    @test isa(surface.plot, getfield(PhyloMakie, :PhyloPlot))
    @test !isempty(_render_colorbuffer(surface.figure))
    return nothing
end

@testset "Public render contracts" begin
    CairoMakie.activate!()
    PhyloPlot = getfield(PhyloMakie, :PhyloPlot)

    @testset "Public surface matrix returns live PhyloPlot handles" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.gamma_and_edgecolor
        render_kwargs = (
            useedgelength=true,
            showgamma=true,
            edgecolor=Dict(render_case.edgecolor_overrides),
            defaultedgecolor=render_case.defaultedgecolor,
            edgewidth=Dict(render_case.edgewidth_overrides),
            style=:fulltree,
        )

        plot_surface = Makie.plot(readnewick(render_case.newick); render_kwargs...)
        convenience_surface = phyloplot(readnewick(render_case.newick); render_kwargs...)
        _assert_public_surface_rendered(plot_surface)
        _assert_public_surface_rendered(convenience_surface)
        @test _render_colorbuffer(plot_surface.figure) ==
            _render_colorbuffer(convenience_surface.figure)

        plot_figure = Figure(size=(640, 400))
        plot_axis = Axis(plot_figure[1, 1])
        hidedecorations!(plot_axis)
        hidespines!(plot_axis)
        plot_handle = Makie.plot!(plot_axis, readnewick(render_case.newick); render_kwargs...)

        convenience_figure = Figure(size=(640, 400))
        convenience_axis = Axis(convenience_figure[1, 1])
        hidedecorations!(convenience_axis)
        hidespines!(convenience_axis)
        convenience_handle =
            phyloplot!(convenience_axis, readnewick(render_case.newick); render_kwargs...)

        @test plot_handle isa PhyloPlot
        @test convenience_handle isa PhyloPlot
        @test !isempty(_render_colorbuffer(plot_figure))
        @test _render_colorbuffer(plot_figure) == _render_colorbuffer(convenience_figure)
    end

    @testset "Style and minor-edge linestyle reach public primitive state" begin
        render_cases = FIXTURE_CORPUS.render_regression_cases
        fulltree_case = _public_render_case(
            render_cases.style_fulltree.newick;
            render_cases.style_fulltree.attribute_kwargs...,
        )
        majortree_case = _public_render_case(
            render_cases.style_majortree.newick;
            render_cases.style_majortree.attribute_kwargs...,
        )
        dotted_case = _public_render_case(
            render_cases.style_fulltree.newick;
            render_cases.style_fulltree.attribute_kwargs...,
            minorlinetype=3,
        )
        blank_case = _public_render_case(
            render_cases.style_fulltree.newick;
            render_cases.style_fulltree.attribute_kwargs...,
            minorlinetype="blank",
        )

        @test fulltree_case.config.style == :fulltree
        @test majortree_case.config.style == :majortree
        @test fulltree_case.channels.minor_edge_shafts.linestyle == :dash
        @test majortree_case.channels.minor_edge_shafts.linestyle == :solid
        @test _render_colorbuffer(fulltree_case.figure) !=
            _render_colorbuffer(majortree_case.figure)

        dotted_children = _contract_children(dotted_case.plot)
        @test dotted_case.channels.minor_edge_shafts.linestyle == :dot
        @test !isnothing(dotted_children.minor_edge_shafts.linestyle[])
        @test !isempty(dotted_case.channels.minor_edge_shafts.points)
        @test !isempty(dotted_case.channels.minor_arrowheads.startpoints)
        @test dotted_children.minor_arrowheads.space[] == :pixel
        dotted_arrowhead_meshes = dotted_children.minor_arrowheads[1][]
        @test dotted_arrowhead_meshes == dotted_case.plot[:minor_arrowhead_pixel_meshes][]
        @test any(dotted_arrowhead_meshes) do polygon
            metrics = _arrowhead_pixel_metrics(polygon)
            return isapprox(metrics.length, 8.0f0; atol=0.25f0) &&
                isapprox(metrics.width, 6.4f0; atol=0.25f0)
        end

        blank_children = _contract_children(blank_case.plot)
        @test blank_case.channels.minor_edge_shafts.points == Makie.Point2f[]
        @test blank_case.channels.minor_edge_shafts.colors == Makie.RGBAf[]
        @test blank_case.channels.minor_edge_shafts.linewidths == Float32[]
        @test blank_case.channels.minor_arrowheads.startpoints == Makie.Point2f[]
        @test blank_case.channels.minor_arrowheads.tiplengths == Float32[]
        @test blank_case.plot[:minor_arrowhead_pixel_meshes][] ==
            getfield(PhyloMakie, :ArrowheadPixelPolygon)[]
        @test isempty(blank_children.minor_edge_shafts[1][])
        @test isempty(blank_children.minor_arrowheads[1][])
    end

    @testset "Color, width, arrowhead, and gamma text policy" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.gamma_and_edgecolor
        edgecolor = Dict(render_case.edgecolor_overrides)
        edgewidth = Dict(render_case.edgewidth_overrides)
        case = _public_render_case(
            render_case.newick;
            render_case.attribute_kwargs...,
            edgecolor=edgecolor,
            defaultedgecolor=render_case.defaultedgecolor,
            edgewidth=edgewidth,
        )

        expected_edgecolors = Makie.RGBAf[]
        expected_minor_edgecolors = Makie.RGBAf[]
        expected_edgewidths = Float32[]
        expected_minor_edgewidths = Float32[]
        fallback_color = _rgba(render_case.defaultedgecolor)
        for edge in case.network.edge
            resolved_color = _rgba(get(edgecolor, edge.number, render_case.defaultedgecolor))
            resolved_width = Float32(get(edgewidth, edge.number, 1.0))
            push!(expected_edgecolors, resolved_color)
            push!(expected_edgewidths, resolved_width)
            if !edge.ismajor
                push!(expected_minor_edgecolors, resolved_color)
                push!(expected_minor_edgewidths, resolved_width)
            end
        end

        @test case.channels.edge_segments.colors == _repeat_each(expected_edgecolors)
        @test case.channels.edge_segments.linewidths == _repeat_each(expected_edgewidths)
        @test case.channels.minor_edge_shafts.colors ==
            _repeat_each(expected_minor_edgecolors)
        @test case.channels.minor_edge_shafts.linewidths ==
            _repeat_each(expected_minor_edgewidths)
        @test case.channels.node_bars.colors ==
            _repeat_each(fill(fallback_color, case.network.numnodes))

        expected_minor_gamma_color = fill(
            _rgba(case.config.minorhybridedgecolor),
            length(case.channels.minor_gamma_labels.strings),
        )
        expected_major_gamma_color = fill(
            _rgba(case.config.majorhybridedgecolor),
            length(case.channels.major_gamma_labels.strings),
        )
        @test case.channels.minor_gamma_labels.colors == expected_minor_gamma_color
        @test case.channels.major_gamma_labels.colors == expected_major_gamma_color

        children = _contract_children(case.plot)
        @test children.edge_segments.color[] == case.channels.edge_segments.colors
        @test children.edge_segments.linewidth[] == case.channels.edge_segments.linewidths
        @test children.minor_arrowheads.color[] == case.channels.minor_arrowheads.colors
        @test children.minor_arrowheads[1][] == case.plot[:minor_arrowhead_pixel_meshes][]
    end

    @testset "Text size, position, and limit channels match accepted tables" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.annotation_and_limits
        node_labels =
            _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows)
        edge_labels =
            _render_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows)
        scalar_case = _public_render_case(
            render_case.newick;
            render_case.attribute_kwargs...,
            nodelabel=node_labels,
            edgelabel=edge_labels,
            xlim=render_case.xlim,
            ylim=render_case.ylim,
            tipcex=4.0,
            nodecex=3.0,
            edgecex=2.0,
        )

        node_data = scalar_case.layout.annotations.node_data
        edge_data = scalar_case.layout.annotations.edge_data
        leaf_rows = _rows_with_flag(node_data.lea)
        internal_rows = _rows_with_flag(.!node_data.lea)
        minor_gamma_rows = _rows_with_flag(edge_data.hyb .& edge_data.min)
        major_gamma_rows = _rows_with_flag(edge_data.hyb .& .!edge_data.min)

        @test _render_limits_tuple(Makie.data_limits(scalar_case.plot))[1] == render_case.xlim
        @test _render_limits_tuple(Makie.data_limits(scalar_case.plot))[2] == render_case.ylim
        @test Makie.data_limits(scalar_case.plot) == scalar_case.channels.data_limits

        @test scalar_case.channels.tip_labels.fontsizes ==
            _expected_contract_fontsizes(4.0, length(scalar_case.channels.tip_labels.strings))
        @test scalar_case.channels.internal_node_names.fontsizes ==
            _expected_contract_fontsizes(
                4.0,
                length(scalar_case.channels.internal_node_names.strings),
            )
        @test scalar_case.channels.node_numbers.fontsizes ==
            _expected_default_contract_fontsizes(
                length(scalar_case.channels.node_numbers.strings),
            )
        @test scalar_case.channels.node_labels.fontsizes ==
            _expected_contract_fontsizes(3.0, length(scalar_case.channels.node_labels.strings))
        @test scalar_case.channels.edge_labels.fontsizes ==
            _expected_contract_fontsizes(2.0, length(scalar_case.channels.edge_labels.strings))
        @test scalar_case.channels.edge_lengths.fontsizes ==
            _expected_default_contract_fontsizes(
                length(scalar_case.channels.edge_lengths.strings),
            )
        @test scalar_case.channels.minor_gamma_labels.fontsizes ==
            _expected_default_contract_fontsizes(
                length(scalar_case.channels.minor_gamma_labels.strings),
            )
        @test scalar_case.channels.major_gamma_labels.fontsizes ==
            _expected_default_contract_fontsizes(
                length(scalar_case.channels.major_gamma_labels.strings),
            )
        @test scalar_case.channels.edge_numbers.fontsizes ==
            _expected_default_contract_fontsizes(
                length(scalar_case.channels.edge_numbers.strings),
            )

        @test scalar_case.channels.tip_labels.strings == String.(node_data[leaf_rows, :name])
        @test scalar_case.channels.tip_labels.positions ==
            _node_channel_positions(
                scalar_case.layout,
                leaf_rows;
                x_offset=scalar_case.config.tipoffset,
            )
        @test scalar_case.channels.internal_node_names.strings ==
            String.(node_data[internal_rows, :name])
        @test scalar_case.channels.internal_node_names.positions ==
            _node_channel_positions(scalar_case.layout, internal_rows)
        @test scalar_case.channels.node_numbers.strings == String.(node_data[!, :num])
        @test scalar_case.channels.node_numbers.positions ==
            _node_channel_positions(scalar_case.layout, axes(node_data, 1))
        @test scalar_case.channels.node_labels.strings == String.(node_data[!, :lab])
        @test scalar_case.channels.node_labels.positions ==
            _node_channel_positions(scalar_case.layout, axes(node_data, 1))
        @test scalar_case.channels.edge_labels.strings == String.(edge_data[!, :lab])
        @test scalar_case.channels.edge_labels.positions ==
            _edge_channel_positions(scalar_case.layout, axes(edge_data, 1))
        @test scalar_case.channels.edge_lengths.strings == String.(edge_data[!, :len])
        @test scalar_case.channels.edge_lengths.positions ==
            _edge_channel_positions(scalar_case.layout, axes(edge_data, 1))
        @test scalar_case.channels.edge_numbers.strings == String.(edge_data[!, :num])
        @test scalar_case.channels.edge_numbers.positions ==
            _edge_channel_positions(scalar_case.layout, axes(edge_data, 1))
        @test scalar_case.channels.minor_gamma_labels.strings ==
            String.(edge_data[minor_gamma_rows, :gam])
        @test scalar_case.channels.minor_gamma_labels.positions ==
            _edge_channel_positions(scalar_case.layout, minor_gamma_rows)
        @test scalar_case.channels.major_gamma_labels.strings ==
            String.(edge_data[major_gamma_rows, :gam])
        @test scalar_case.channels.major_gamma_labels.positions ==
            _edge_channel_positions(scalar_case.layout, major_gamma_rows)

        vector_case = _public_render_case(
            render_case.newick;
            render_case.attribute_kwargs...,
            nodelabel=node_labels,
            tipcex=[0.5, 1.0, 1.5],
            nodecex=[0.75, 1.25],
        )
        @test vector_case.channels.tip_labels.fontsizes ==
            _expected_contract_fontsizes(
                [0.5, 1.0, 1.5],
                length(vector_case.channels.tip_labels.strings),
            )
        @test vector_case.channels.internal_node_names.fontsizes ==
            _expected_contract_fontsizes(
                [0.5, 1.0, 1.5],
                length(vector_case.channels.internal_node_names.strings),
            )
        @test vector_case.channels.node_labels.fontsizes ==
            _expected_contract_fontsizes(
                [0.75, 1.25],
                length(vector_case.channels.node_labels.strings),
            )

        documented_edgecex_case = _public_render_case(
            "(A,((B,#H1),(C,(D)#H1)));";
            edgelabel=DataFrame(edge=[1, 2], label=["edge number 1", "edge # 2"]),
            edgecex=[0.9, 1.1],
        )
        @test documented_edgecex_case.channels.edge_labels.fontsizes ==
            _expected_contract_fontsizes(
                [0.9, 1.1],
                length(documented_edgecex_case.channels.edge_labels.strings),
            )
    end

    @testset "Coordinate query functions agree with rendered channels" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.annotation_and_limits
        case = _public_render_case(
            render_case.newick;
            render_case.attribute_kwargs...,
            xlim=render_case.xlim,
            ylim=render_case.ylim,
        )

        node_table = node_positions(case.plot)
        edge_table = edge_positions(case.plot)
        node_data = case.layout.annotations.node_data
        edge_data = case.layout.annotations.edge_data

        @test size(node_table, 1) == size(node_data, 1)
        @test node_table.x == node_data.x
        @test node_table.y == node_data.y
        @test edge_table.x == edge_data.x
        @test edge_table.y == edge_data.y

        internal_node_positions = Makie.Point2f[
            Makie.Point2f(Float32(row.x), Float32(row.y))
            for row in eachrow(node_table) if !row.isleaf
        ]
        @test internal_node_positions == case.channels.internal_node_names.positions

        minor_gamma_positions = Makie.Point2f[
            Makie.Point2f(Float32(row.x), Float32(row.y))
            for row in eachrow(edge_table) if row.ishybrid && !row.ismajor
        ]
        @test minor_gamma_positions == case.channels.minor_gamma_labels.positions

        major_gamma_positions = Makie.Point2f[
            Makie.Point2f(Float32(row.x), Float32(row.y))
            for row in eachrow(edge_table) if row.ishybrid && row.ismajor
        ]
        @test major_gamma_positions == case.channels.major_gamma_labels.positions
    end

    @testset "Public updates preserve child identity and caller-owned networks" begin
        render_case = FIXTURE_CORPUS.render_regression_cases.style_fulltree
        surface = Makie.plot(readnewick(render_case.newick); render_case.attribute_kwargs...)
        plot = surface.plot
        children = _contract_children(plot)
        original_child_ids = _contract_child_ids(plot)

        before_color = _render_colorbuffer(surface.figure)
        Makie.update!(plot; edgecolor="firebrick")
        after_color = _render_colorbuffer(surface.figure)
        @test after_color != before_color
        @test _contract_child_ids(plot) == original_child_ids
        @test children.edge_segments.color[] == plot[:edge_segment_colors][]

        before_widths = copy(children.edge_segments.linewidth[])
        Makie.update!(plot; edgewidth=4.0)
        @test _contract_child_ids(plot) == original_child_ids
        @test children.edge_segments.linewidth[] != before_widths
        @test children.edge_segments.linewidth[] == plot[:edge_segment_linewidths][]

        new_net = readnewick(FIXTURE_CORPUS.render_regression_cases.style_majortree.newick)
        before_network = _contract_network_snapshot(new_net)
        Makie.update!(plot; arg1=new_net)
        @test _contract_child_ids(plot) == original_child_ids
        @test _contract_network_snapshot(new_net) == before_network
        @test plot[:plot_network][].net !== new_net

        Makie.update!(plot; showtiplabel=false, minorlinetype="blank")
        @test _contract_child_ids(plot) == original_child_ids
        @test children.tip_labels[1][] == Makie.Point2f[]
        @test children.minor_edge_shafts[1][] == Makie.Point2f[]
        @test children.minor_arrowheads[1][] == getfield(PhyloMakie, :ArrowheadPixelPolygon)[]
    end
end
