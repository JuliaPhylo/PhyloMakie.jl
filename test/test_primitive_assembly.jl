using CairoMakie
using Makie
using PhyloNetworks

const PRIMITIVE_ASSEMBLY_NEWICK =
    "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"
const PRIMITIVE_ASSEMBLY_ALT_NEWICK =
    "((A:1,(B:0.5)#H1:0.5):1,(#H1:0.5,C:1):1);"

function _primitive_assembly_plot(; kwargs...)
    CairoMakie.activate!()
    surface = Makie.plot(
        readnewick(PRIMITIVE_ASSEMBLY_NEWICK);
        useedgelength = true,
        showgamma = true,
        style = :fulltree,
        kwargs...,
    )
    return surface.plot
end

function _primitive_assembly_outputs(plot)
    return getfield(PhyloMakie, :register_phylo_graph!)(plot)
end

function _primitive_assembly_children(plot)::NamedTuple
    @test length(plot.plots) == 13
    return (
        edge_segments = plot.plots[1],
        node_bars = plot.plots[2],
        minor_edge_shafts = plot.plots[3],
        minor_arrowheads = plot.plots[4],
        tip_labels = plot.plots[5],
        internal_node_names = plot.plots[6],
        node_numbers = plot.plots[7],
        node_labels = plot.plots[8],
        edge_labels = plot.plots[9],
        edge_lengths = plot.plots[10],
        minor_gamma_labels = plot.plots[11],
        major_gamma_labels = plot.plots[12],
        edge_numbers = plot.plots[13],
    )
end

function _primitive_child_ids(plot)::Vector{UInt}
    return objectid.(plot.plots)
end

function _assert_segment_child_matches_outputs(plot, child, outputs)::Nothing
    @test child[1][] == plot[outputs.points][]
    @test child.color[] == plot[outputs.colors][]
    @test child.linewidth[] == plot[outputs.linewidths][]
    return nothing
end

function _assert_arrowhead_child_matches_outputs(plot, child, outputs)::Nothing
    @test child[1][] == plot[outputs.meshes][]
    @test child.color[] == plot[outputs.colors][]
    @test child.strokecolor[] == plot[outputs.strokecolors][]
    @test child.strokewidth[] == plot[outputs.strokewidth][]
    return nothing
end

function _assert_text_child_matches_outputs(plot, child, outputs)::Nothing
    @test child[1][] == plot[outputs.positions][]
    @test child.text[] == plot[outputs.strings][]
    @test child.color[] == plot[outputs.colors][]
    @test child.fontsize[] == plot[outputs.fontsizes][]
    @test child.align[] == plot[outputs.align][]
    return nothing
end

function _assert_children_match_outputs(plot, outputs)::Nothing
    children = _primitive_assembly_children(plot)
    primitive_outputs = outputs.primitive_outputs
    text_outputs = outputs.text_outputs

    _assert_segment_child_matches_outputs(
        plot,
        children.edge_segments,
        primitive_outputs.edge_segments,
    )
    _assert_segment_child_matches_outputs(plot, children.node_bars, primitive_outputs.node_bars)
    _assert_segment_child_matches_outputs(
        plot,
        children.minor_edge_shafts,
        primitive_outputs.minor_edge_shafts,
    )
    _assert_arrowhead_child_matches_outputs(
        plot,
        children.minor_arrowheads,
        primitive_outputs.minor_arrowheads,
    )

    _assert_text_child_matches_outputs(plot, children.tip_labels, text_outputs.tip_labels)
    _assert_text_child_matches_outputs(
        plot,
        children.internal_node_names,
        text_outputs.internal_node_names,
    )
    _assert_text_child_matches_outputs(plot, children.node_numbers, text_outputs.node_numbers)
    _assert_text_child_matches_outputs(plot, children.node_labels, text_outputs.node_labels)
    _assert_text_child_matches_outputs(plot, children.edge_labels, text_outputs.edge_labels)
    _assert_text_child_matches_outputs(plot, children.edge_lengths, text_outputs.edge_lengths)
    _assert_text_child_matches_outputs(
        plot,
        children.minor_gamma_labels,
        text_outputs.minor_gamma_labels,
    )
    _assert_text_child_matches_outputs(
        plot,
        children.major_gamma_labels,
        text_outputs.major_gamma_labels,
    )
    _assert_text_child_matches_outputs(plot, children.edge_numbers, text_outputs.edge_numbers)
    return nothing
end

@testset "Stable primitive assembly" begin
    CairoMakie.activate!()

    @testset "child primitive inventory and graph-node wiring" begin
        plot = _primitive_assembly_plot()
        outputs = _primitive_assembly_outputs(plot)
        children = _primitive_assembly_children(plot)

        @test children.edge_segments isa Makie.LineSegments
        @test children.node_bars isa Makie.LineSegments
        @test children.minor_edge_shafts isa Makie.LineSegments
        @test children.minor_arrowheads isa Makie.Poly
        @test all(child -> child isa Makie.Text, plot.plots[5:13])
        @test !any(child -> child isa Makie.Arrows2D, plot.plots)

        _assert_children_match_outputs(plot, outputs)
        @test children.tip_labels.font[] == plot[outputs.text_outputs.tip_labels.font][]
        @test children.internal_node_names.font[] ==
            plot[outputs.text_outputs.internal_node_names.font][]
        @test plot[outputs.text_outputs.node_numbers.font][] === nothing
        @test !isnothing(children.node_numbers.font[])
    end

    @testset "Makie.update! keeps child identity and updates graph-driven arguments" begin
        plot = _primitive_assembly_plot()
        outputs = _primitive_assembly_outputs(plot)
        children = _primitive_assembly_children(plot)
        original_child_ids = _primitive_child_ids(plot)

        before_colors = copy(children.edge_segments.color[])
        Makie.update!(plot; edgecolor = "firebrick")
        @test _primitive_child_ids(plot) == original_child_ids
        @test children.edge_segments.color[] != before_colors
        _assert_children_match_outputs(plot, outputs)

        before_arrowheads = copy(children.minor_arrowheads[1][])
        Makie.update!(plot; style = :majortree)
        @test _primitive_child_ids(plot) == original_child_ids
        @test children.minor_arrowheads[1][] != before_arrowheads
        @test isempty(children.minor_arrowheads[1][])
        _assert_children_match_outputs(plot, outputs)

        before_points = copy(children.edge_segments[1][])
        Makie.update!(plot; arg1 = readnewick(PRIMITIVE_ASSEMBLY_ALT_NEWICK))
        @test _primitive_child_ids(plot) == original_child_ids
        @test children.edge_segments[1][] != before_points
        _assert_children_match_outputs(plot, outputs)

        Makie.update!(plot; xlim = (0.0, 5.0), ylim = (-1.0, 4.0))
        @test _primitive_child_ids(plot) == original_child_ids
        @test Makie.data_limits(plot) == plot[outputs.primitive_outputs.data_limits][]
    end

    @testset "hidden layers remain stable empty primitives" begin
        plot = _primitive_assembly_plot(
            showtiplabel = false,
            shownodelabel = false,
            minorlinetype = "blank",
        )
        outputs = _primitive_assembly_outputs(plot)
        children = _primitive_assembly_children(plot)
        original_child_ids = _primitive_child_ids(plot)

        @test isempty(children.minor_edge_shafts[1][])
        @test isempty(children.minor_arrowheads[1][])
        @test isempty(children.tip_labels[1][])
        @test isempty(children.internal_node_names[1][])
        @test plot[outputs.text_outputs.tip_labels.font][] == :italic
        @test plot[outputs.text_outputs.internal_node_names.font][] == :italic
        @test children.tip_labels.font[] == :italic
        @test children.internal_node_names.font[] == :italic

        Makie.update!(plot; showtiplabel = true, shownodelabel = true, minorlinetype = :dash)
        @test _primitive_child_ids(plot) == original_child_ids
        @test !isempty(children.minor_edge_shafts[1][])
        @test !isempty(children.minor_arrowheads[1][])
        @test !isempty(children.tip_labels[1][])
        @test !isempty(children.internal_node_names[1][])
        _assert_children_match_outputs(plot, outputs)
    end

    @testset "recipe and primitive assembly bypass old render scaffold" begin
        recipe_source = read(joinpath(@__DIR__, "..", "src", "recipe.jl"), String)
        assembly_source =
            read(joinpath(@__DIR__, "..", "src", "primitive_assembly.jl"), String)
        onany_call = "Makie" * ".onany"
        rebuild_guard = "is" * "_rebuilding"
        empty_children = "empty!" * "(plot.plots)"
        delete_call = "delete" * "!("
        render_call = "render" * "_plot!"
        render_layers = "Plot" * "RenderLayers"
        arrows_call = "arrows" * "2d!"

        @test !occursin(onany_call, recipe_source)
        @test !occursin(rebuild_guard, recipe_source)
        @test !occursin(empty_children, recipe_source)
        @test !occursin(delete_call, recipe_source)
        @test !occursin(render_call, recipe_source)
        @test !occursin(render_layers, assembly_source)
        @test !occursin(render_call, assembly_source)
        @test !occursin(arrows_call, assembly_source)
    end
end
