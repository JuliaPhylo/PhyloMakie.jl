using Makie

@testset "Attribute schema" begin
    PhyloPlot = getfield(PhyloMakie, :PhyloPlot)
    PhyloPlotAttributes = getfield(PhyloMakie, :PhyloPlotAttributes)
    resolve_phylo_plot_attributes = getfield(PhyloMakie, :resolve_phylo_plot_attributes)
    with_phylo_plot_limits = getfield(PhyloMakie, :with_phylo_plot_limits)
    resolve_defaultedgecolor = getfield(PhyloMakie, :_resolve_defaultedgecolor)
    resolve_edgewidth_mode = getfield(PhyloMakie, :_resolve_edgewidth_mode)
    supported_attributes = getfield(PhyloMakie, :SUPPORTED_PHYLOPLOT_ATTRIBUTES)
    @test supported_attributes == EXPECTED_SUPPORTED_PHYLOPLOT_ATTRIBUTES
    @test sort(collect(Makie.attribute_names(PhyloPlot))) ==
        sort(collect(EXPECTED_SUPPORTED_PHYLOPLOT_ATTRIBUTES))

    @testset "Defaults and stored payload" begin
        attributes = resolve_phylo_plot_attributes()

        @test attributes isa PhyloPlotAttributes
        @test attributes.useedgelength === false
        @test attributes.showtiplabel === true
        @test attributes.shownodelabel === false
        @test attributes.shownodenumber === false
        @test attributes.showedgelength === false
        @test attributes.showedgenumber === false
        @test attributes.showgamma === false
        @test attributes.edgecolor == "black"
        @test attributes.defaultedgecolor === nothing
        @test attributes.majorhybridedgecolor == "deepskyblue4"
        @test attributes.minorhybridedgecolor == "deepskyblue"
        @test attributes.edgewidth == 1
        @test attributes.minorlinetype == "longdash"
        @test attributes.arrowlen == 0.1
        @test isempty(attributes.nodelabel)
        @test isempty(attributes.edgelabel)
        @test attributes.nodecex == 1
        @test attributes.edgecex == 1
        @test attributes.nodelabelcolor == "black"
        @test attributes.edgelabelcolor == "black"
        @test attributes.nodelabeladj == 1
        @test attributes.edgelabeladj == [0.5, 0]
        @test attributes.tipoffset == 0
        @test attributes.tipcex == 1
        @test attributes.xlim === nothing
        @test attributes.ylim === nothing
        @test attributes.style == :fulltree

        resolved_limits = with_phylo_plot_limits(attributes, (0.0, 5.0), (1.0, 4.0))
        @test resolved_limits isa PhyloPlotAttributes
        @test resolved_limits !== attributes
        @test resolved_limits.xlim == (0.0, 5.0)
        @test resolved_limits.ylim == (1.0, 4.0)
        @test resolved_limits.edgecolor == attributes.edgecolor
        @test resolved_limits.nodelabel === attributes.nodelabel
        @test resolved_limits.edgelabel === attributes.edgelabel
    end

    @testset "Style-dependent defaults" begin
        majortree_attributes = resolve_phylo_plot_attributes(style=:majortree)
        @test majortree_attributes.style == :majortree
        @test majortree_attributes.arrowlen == 0
        @test majortree_attributes.minorlinetype == "solid"

        @test_logs (:warn, "Style weird is unknown. Defaulted to :fulltree.") begin
            unknown_style_attributes = resolve_phylo_plot_attributes(style=:weird)
            @test unknown_style_attributes.style == :fulltree
            @test unknown_style_attributes.arrowlen == 0.1
            @test unknown_style_attributes.minorlinetype == "longdash"
        end
    end

    @testset "Color and width policy" begin
        scalar_attributes = resolve_phylo_plot_attributes(
            edgecolor="tomato4",
            majorhybridedgecolor="tan",
            minorhybridedgecolor="skyblue",
        )
        @test scalar_attributes.edgecolor == "tomato4"
        @test scalar_attributes.majorhybridedgecolor == "tan"
        @test scalar_attributes.minorhybridedgecolor == "skyblue"
        @test resolve_defaultedgecolor(
            scalar_attributes.edgecolor,
            scalar_attributes.defaultedgecolor,
            :uniform,
        ) == "tomato4"
        @test resolve_edgewidth_mode(scalar_attributes.edgewidth) == :uniform

        dict_attributes = resolve_phylo_plot_attributes(
            edgecolor=Dict(1 => "tomato4", 3 => "tan"),
            defaultedgecolor=nothing,
            edgewidth=Dict(1 => 2.0, 3 => 4.5),
        )
        @test dict_attributes.edgecolor == Dict(1 => "tomato4", 3 => "tan")
        @test dict_attributes.defaultedgecolor === nothing
        @test dict_attributes.edgewidth == Dict(1 => 2.0, 3 => 4.5)
        @test resolve_defaultedgecolor(
            dict_attributes.edgecolor,
            dict_attributes.defaultedgecolor,
            :by_edge,
        ) == "black"
        @test resolve_edgewidth_mode(dict_attributes.edgewidth) == :by_edge

        custom_default_attributes = resolve_phylo_plot_attributes(
            edgecolor=Dict(1 => "tomato4"),
            defaultedgecolor="grey20",
        )
        @test custom_default_attributes.defaultedgecolor == "grey20"
        @test resolve_defaultedgecolor(
            custom_default_attributes.edgecolor,
            custom_default_attributes.defaultedgecolor,
            :by_edge,
        ) == "grey20"

        invalid_width_error = try
            resolve_phylo_plot_attributes(edgewidth=Dict(1 => "wide"))
            nothing
        catch err
            err
        end
        @test invalid_width_error isa ErrorException
        @test invalid_width_error.msg == "edgewidth should be numerical"

        invalid_width_type = try
            resolve_phylo_plot_attributes(edgewidth="wide")
            nothing
        catch err
            err
        end
        @test invalid_width_type isa ArgumentError
        @test occursin("edgewidth should be a number", sprint(showerror, invalid_width_type))
    end

    @testset "DataFrame ownership" begin
        nodelabel = DataFrame(
            node=[-5, missing, 100],
            label=["90", "99", "bogus"],
        )
        edgelabel = DataFrame(
            edge=[8, missing, 200],
            label=["95", "99", "bogus"],
        )
        xlim = [1.0, 2.0, 3.0]

        attributes = resolve_phylo_plot_attributes(
            nodelabel=nodelabel,
            edgelabel=edgelabel,
            xlim=xlim,
        )
        @test attributes.nodelabel isa DataFrame
        @test attributes.edgelabel isa DataFrame
        @test isequal(attributes.nodelabel, nodelabel)
        @test isequal(attributes.edgelabel, edgelabel)
        @test attributes.nodelabel !== nodelabel
        @test attributes.edgelabel !== edgelabel
        @test attributes.xlim === xlim
    end
end
