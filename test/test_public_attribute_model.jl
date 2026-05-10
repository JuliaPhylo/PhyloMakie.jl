using Logging: Warn
using Makie

@testset "Public attribute model" begin
    PhyloPlot = getfield(PhyloMakie, :PhyloPlot)
    PhyloPlotAttributes = getfield(PhyloMakie, :PhyloPlotAttributes)
    resolve_phylo_plot_attributes = getfield(PhyloMakie, :resolve_phylo_plot_attributes)
    bridge_phylo_plot_attributes = getfield(PhyloMakie, :bridge_phylo_plot_attributes)
    supported_attributes = getfield(PhyloMakie, :SUPPORTED_PHYLOPLOT_ATTRIBUTES)
    attribute_migrations = getfield(PhyloMakie, :PHYLOPLOT_ATTRIBUTE_MIGRATIONS)

    @test supported_attributes == EXPECTED_SUPPORTED_PHYLOPLOT_ATTRIBUTES
    @test sort(collect(Makie.attribute_names(PhyloPlot))) ==
        sort(collect(EXPECTED_SUPPORTED_PHYLOPLOT_ATTRIBUTES))
    @test Tuple(migration.legacy for migration in attribute_migrations) ==
        EXPECTED_DEPRECATED_PHYLOPLOT_ATTRIBUTES
    @test Tuple(entry.attribute for entry in Makie.deprecated_attributes(PhyloPlot)) ==
        EXPECTED_DEPRECATED_PHYLOPLOT_ATTRIBUTES

    @testset "Defaults and bridge payload" begin
        attributes = resolve_phylo_plot_attributes()
        spec = bridge_phylo_plot_attributes(attributes)

        @test attributes isa PhyloPlotAttributes
        @test attributes.use_edge_lengths === false
        @test attributes.show_tip_labels === true
        @test attributes.show_internal_node_names === false
        @test attributes.show_node_numbers === false
        @test attributes.show_edge_lengths === false
        @test attributes.show_edge_numbers === false
        @test attributes.show_gamma === false
        @test attributes.edge_color == "black"
        @test attributes.default_edge_color === nothing
        @test attributes.major_hybrid_edge_color == "deepskyblue4"
        @test attributes.minor_hybrid_edge_color == "deepskyblue"
        @test attributes.edge_width == 1
        @test attributes.minor_edge_linestyle == "longdash"
        @test attributes.minor_edge_arrow_length == 0.1
        @test isempty(attributes.node_annotations)
        @test isempty(attributes.edge_annotations)
        @test attributes.node_annotation_scale == 1
        @test attributes.edge_annotation_scale == 1
        @test attributes.node_annotation_color == "black"
        @test attributes.edge_annotation_color == "black"
        @test attributes.node_annotation_align == 1
        @test attributes.edge_annotation_align == [0.5, 0]
        @test attributes.tip_label_offset == 0
        @test attributes.tip_label_scale == 1
        @test attributes.x_limits === nothing
        @test attributes.y_limits === nothing
        @test attributes.style == :fulltree

        @test spec.layout.useedgelength === false
        @test spec.layout.xlim === nothing
        @test spec.layout.ylim === nothing
        @test spec.layout.preorder === true
        @test spec.visibility.showtiplabel === true
        @test spec.visibility.shownodelabel === false
        @test spec.colors.edgecolor_mode == :uniform
        @test spec.colors.defaultedgecolor == "black"
        @test spec.colors.edgenumbercolor == "grey"
        @test spec.strokes.arrowlen == 0.1
        @test spec.strokes.minorlinetype == "longdash"
        @test spec.deferred_contracts == ()
    end

    @testset "Style-dependent defaults" begin
        majortree_attributes = resolve_phylo_plot_attributes(style=:majortree)
        @test majortree_attributes.style == :majortree
        @test majortree_attributes.minor_edge_arrow_length == 0
        @test majortree_attributes.minor_edge_linestyle == "solid"

        @test_logs (:warn, "Style weird is unknown. Defaulted to :fulltree.") begin
            unknown_style_attributes = resolve_phylo_plot_attributes(style=:weird)
            @test unknown_style_attributes.style == :fulltree
            @test unknown_style_attributes.minor_edge_arrow_length == 0.1
            @test unknown_style_attributes.minor_edge_linestyle == "longdash"
        end
    end

    @testset "Color and width policy" begin
        scalar_spec = bridge_phylo_plot_attributes(
            resolve_phylo_plot_attributes(
                edge_color="tomato4",
                major_hybrid_edge_color="tan",
                minor_hybrid_edge_color="skyblue",
            ),
        )
        @test scalar_spec.colors.edgecolor_mode == :uniform
        @test scalar_spec.colors.edgecolor == "tomato4"
        @test scalar_spec.colors.defaultedgecolor == "tomato4"
        @test scalar_spec.colors.majorhybridedgecolor == "tan"
        @test scalar_spec.colors.minorhybridedgecolor == "skyblue"

        dict_spec = bridge_phylo_plot_attributes(
            resolve_phylo_plot_attributes(
                edge_color=Dict(1 => "tomato4", 3 => "tan"),
                default_edge_color=nothing,
                edge_width=Dict(1 => 2.0, 3 => 4.5),
            ),
        )
        @test dict_spec.colors.edgecolor_mode == :by_edge
        @test dict_spec.colors.edgecolor == Dict(1 => "tomato4", 3 => "tan")
        @test dict_spec.colors.defaultedgecolor == "black"
        @test dict_spec.strokes.edgewidth_mode == :by_edge
        @test dict_spec.strokes.edgewidth == Dict(1 => 2.0, 3 => 4.5)

        custom_default_spec = bridge_phylo_plot_attributes(
            resolve_phylo_plot_attributes(
                edge_color=Dict(1 => "tomato4"),
                default_edge_color="grey20",
            ),
        )
        @test custom_default_spec.colors.defaultedgecolor == "grey20"

        invalid_width_error = try
            resolve_phylo_plot_attributes(edge_width=Dict(1 => "wide"))
            nothing
        catch err
            err
        end
        @test invalid_width_error isa ErrorException
        @test invalid_width_error.msg == "edgewidth should be numerical"
    end

    @testset "DataFrame ownership and deferred limit validation" begin
        node_annotations = DataFrame(
            node=[-5, missing, 100],
            label=["90", "99", "bogus"],
        )
        edge_annotations = DataFrame(
            edge=[8, missing, 200],
            label=["95", "99", "bogus"],
        )
        x_limits = [1.0, 2.0, 3.0]

        @test_logs min_level=Warn begin
            attributes = resolve_phylo_plot_attributes(
                node_annotations=node_annotations,
                edge_annotations=edge_annotations,
                x_limits=x_limits,
            )
            @test attributes.node_annotations isa DataFrame
            @test attributes.edge_annotations isa DataFrame
            @test isequal(attributes.node_annotations, node_annotations)
            @test isequal(attributes.edge_annotations, edge_annotations)
            @test attributes.node_annotations !== node_annotations
            @test attributes.edge_annotations !== edge_annotations
            @test attributes.x_limits === x_limits

            spec = bridge_phylo_plot_attributes(attributes)
            @test spec.annotations.nodelabel === attributes.node_annotations
            @test spec.annotations.edgelabel === attributes.edge_annotations
            @test spec.layout.xlim === x_limits
        end
    end
end
