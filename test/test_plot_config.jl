using DataFrames: DataFrame
using Makie

@testset "Plot config computation" begin
    PhyloPlot = getfield(PhyloMakie, :PhyloPlot)
    PhyloPlotConfig = getfield(PhyloMakie, :PhyloPlotConfig)
    resolve_plot_config = getfield(PhyloMakie, :resolve_plot_config)
    with_plot_config_limits = getfield(PhyloMakie, :with_plot_config_limits)
    validate_limit_pair = getfield(PhyloMakie, :validate_limit_pair)
    resolve_defaultedgecolor = getfield(PhyloMakie, :_resolve_defaultedgecolor)
    resolve_edgewidth_mode = getfield(PhyloMakie, :_resolve_edgewidth_mode)
    supported_attributes = getfield(PhyloMakie, :SUPPORTED_PHYLOPLOT_ATTRIBUTES)

    @test supported_attributes == EXPECTED_SUPPORTED_PHYLOPLOT_ATTRIBUTES
    @test sort(collect(Makie.attribute_names(PhyloPlot))) ==
        sort(collect(EXPECTED_SUPPORTED_PHYLOPLOT_ATTRIBUTES))

    @testset "Defaults and stored payload" begin
        config = resolve_plot_config()

        @test config isa PhyloPlotConfig
        @test config.useedgelength === false
        @test config.showtiplabel === true
        @test config.shownodelabel === false
        @test config.shownodenumber === false
        @test config.showedgelength === false
        @test config.showedgenumber === false
        @test config.showgamma === false
        @test config.edgecolor == "black"
        @test config.defaultedgecolor === nothing
        @test config.majorhybridedgecolor == "deepskyblue4"
        @test config.minorhybridedgecolor == "deepskyblue"
        @test config.edgewidth == 1
        @test config.minorlinetype == "longdash"
        @test config.arrowlen == 0.1
        @test isempty(config.nodelabel)
        @test isempty(config.edgelabel)
        @test config.nodecex == 1
        @test config.edgecex == 1
        @test config.nodelabelcolor == "black"
        @test config.edgelabelcolor == "black"
        @test config.edgenumbercolor == "grey"
        @test config.nodelabeladj == 1
        @test config.edgelabeladj == [0.5, 0]
        @test config.tipoffset == 0
        @test config.tipcex == 1
        @test config.xlim === nothing
        @test config.ylim === nothing
        @test config.style == :fulltree

        resolved_config = with_plot_config_limits(config, (0.0, 5.0), (1.0, 4.0))
        @test resolved_config isa PhyloPlotConfig
        @test resolved_config !== config
        @test resolved_config.xlim == (0.0, 5.0)
        @test resolved_config.ylim == (1.0, 4.0)
        @test resolved_config.edgecolor == config.edgecolor
        @test resolved_config.nodelabel === config.nodelabel
        @test resolved_config.edgelabel === config.edgelabel
    end

    @testset "Style-dependent defaults" begin
        majortree_config = resolve_plot_config(style=:majortree)
        @test majortree_config.style == :majortree
        @test majortree_config.arrowlen == 0
        @test majortree_config.minorlinetype == "solid"

        @test_logs (:warn, "Style weird is unknown. Defaulted to :fulltree.") begin
            unknown_style_config = resolve_plot_config(style=:weird)
            @test unknown_style_config.style == :fulltree
            @test unknown_style_config.arrowlen == 0.1
            @test unknown_style_config.minorlinetype == "longdash"
        end
    end

    @testset "Color and width policy" begin
        scalar_config = resolve_plot_config(
            edgecolor="tomato4",
            majorhybridedgecolor="tan",
            minorhybridedgecolor="skyblue",
        )
        @test scalar_config.edgecolor == "tomato4"
        @test scalar_config.majorhybridedgecolor == "tan"
        @test scalar_config.minorhybridedgecolor == "skyblue"
        @test resolve_defaultedgecolor(
            scalar_config.edgecolor,
            scalar_config.defaultedgecolor,
            :uniform,
        ) == "tomato4"
        @test resolve_edgewidth_mode(scalar_config.edgewidth) == :uniform

        dict_config = resolve_plot_config(
            edgecolor=Dict(1 => "tomato4", 3 => "tan"),
            defaultedgecolor=nothing,
            edgewidth=Dict(1 => 2.0, 3 => 4.5),
        )
        @test dict_config.edgecolor == Dict(1 => "tomato4", 3 => "tan")
        @test dict_config.defaultedgecolor === nothing
        @test dict_config.edgewidth == Dict(1 => 2.0, 3 => 4.5)
        @test resolve_defaultedgecolor(
            dict_config.edgecolor,
            dict_config.defaultedgecolor,
            :by_edge,
        ) == "black"
        @test resolve_edgewidth_mode(dict_config.edgewidth) == :by_edge

        custom_default_config = resolve_plot_config(
            edgecolor=Dict(1 => "tomato4"),
            defaultedgecolor="grey20",
        )
        @test custom_default_config.defaultedgecolor == "grey20"
        @test resolve_defaultedgecolor(
            custom_default_config.edgecolor,
            custom_default_config.defaultedgecolor,
            :by_edge,
        ) == "grey20"

        invalid_width_error = try
            resolve_plot_config(edgewidth=Dict(1 => "wide"))
            nothing
        catch err
            err
        end
        @test invalid_width_error isa ErrorException
        @test invalid_width_error.msg == "edgewidth should be numerical"

        invalid_width_type = try
            resolve_plot_config(edgewidth="wide")
            nothing
        catch err
            err
        end
        @test invalid_width_type isa ArgumentError
        @test occursin("edgewidth should be a number", sprint(showerror, invalid_width_type))
    end

    @testset "Validation and copied inputs" begin
        nodelabel = DataFrame(node=[-5, missing, 100], label=["90", "99", "bogus"])
        edgelabel = DataFrame(edge=[8, missing, 200], label=["95", "99", "bogus"])
        xlim = [1.0, 2.0, 3.0]
        config = resolve_plot_config(
            nodelabel=nodelabel,
            edgelabel=edgelabel,
            xlim=xlim,
            style=:majortree,
        )

        @test config.style == :majortree
        @test config.arrowlen == 0
        @test config.minorlinetype == "solid"
        @test isequal(config.nodelabel, nodelabel)
        @test isequal(config.edgelabel, edgelabel)
        @test config.nodelabel !== nodelabel
        @test config.edgelabel !== edgelabel
        @test config.xlim === xlim
        @test validate_limit_pair((1.0, 2.0), "bad limits") == (1.0, 2.0)
        @test_throws ErrorException validate_limit_pair((1.0,), "bad limits")
    end
end
