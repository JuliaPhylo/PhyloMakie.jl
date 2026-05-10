using Logging: Warn

@testset "Keyword normalization" begin
    PlotKeywordSpec = getfield(PhyloMakie, :PlotKeywordSpec)
    normalize_plot_keywords = getfield(PhyloMakie, :normalize_plot_keywords)

    @test fieldnames(typeof(normalize_plot_keywords())) == EXPECTED_PLOT_KEYWORD_SPEC_FIELDS

    @testset "Defaults" begin
        spec = normalize_plot_keywords()

        @test spec isa PlotKeywordSpec
        @test spec.layout.useedgelength === false
        @test spec.layout.style == :fulltree
        @test spec.layout.xlim === nothing
        @test spec.layout.ylim === nothing
        @test spec.layout.tipoffset == 0
        @test spec.layout.preorder === true

        @test spec.visibility.showtiplabel === true
        @test spec.visibility.shownodelabel === false
        @test spec.visibility.shownodenumber === false
        @test spec.visibility.showedgelength === false
        @test spec.visibility.showgamma === false
        @test spec.visibility.showedgenumber === false

        @test isempty(spec.annotations.edgelabel)
        @test isempty(spec.annotations.nodelabel)
        @test spec.annotations.tipcex == 1
        @test spec.annotations.nodecex == 1
        @test spec.annotations.edgecex == 1
        @test spec.annotations.edgelabeladj == [0.5, 0]
        @test spec.annotations.nodelabeladj == 1

        @test spec.colors.edgecolor_mode == :uniform
        @test spec.colors.edgecolor == "black"
        @test spec.colors.defaultedgecolor == "black"
        @test spec.colors.majorhybridedgecolor == "deepskyblue4"
        @test spec.colors.minorhybridedgecolor == "deepskyblue"
        @test spec.colors.edgenumbercolor == "grey"
        @test spec.colors.edgelabelcolor == "black"
        @test spec.colors.nodelabelcolor == "black"

        @test spec.strokes.arrowlen == 0.1
        @test spec.strokes.minorlinetype == "longdash"
        @test spec.strokes.edgewidth_mode == :uniform
        @test spec.strokes.edgewidth == 1

        @test [contract.id for contract in spec.deferred_contracts] ==
            collect(EXPECTED_DEFERRED_PLOT_CONTRACT_IDS)
    end

    @testset "Style-dependent defaults" begin
        spec = normalize_plot_keywords(style=:majortree)
        @test spec.layout.style == :majortree
        @test spec.strokes.arrowlen == 0
        @test spec.strokes.minorlinetype == "solid"

        @test_logs (:warn, "Style weird is unknown. Defaulted to :fulltree.") begin
            unknown_style_spec = normalize_plot_keywords(style=:weird)
            @test unknown_style_spec.layout.style == :fulltree
            @test unknown_style_spec.strokes.arrowlen == 0.1
            @test unknown_style_spec.strokes.minorlinetype == "longdash"
        end

        xlim_error = @test_logs min_level=Warn try
            normalize_plot_keywords(style=:weird, xlim=[1.0, 2.0, 3.0])
            nothing
        catch err
            err
        end
        @test xlim_error isa ErrorException
        @test occursin("xlim", xlim_error.msg)
        @test occursin("exactly 2 values", xlim_error.msg)
    end

    @testset "Color and width policy" begin
        scalar_spec = normalize_plot_keywords(
            edgecolor="tomato4",
            majorhybridedgecolor="tan",
            minorhybridedgecolor="skyblue",
        )
        @test scalar_spec.colors.edgecolor_mode == :uniform
        @test scalar_spec.colors.edgecolor == "tomato4"
        @test scalar_spec.colors.defaultedgecolor == "tomato4"
        @test scalar_spec.colors.majorhybridedgecolor == "tan"
        @test scalar_spec.colors.minorhybridedgecolor == "skyblue"

        dict_spec = normalize_plot_keywords(
            edgecolor=Dict(1 => "tomato4", 3 => "tan"),
            defaultedgecolor=nothing,
            majorhybridedgecolor="ignored-major",
            minorhybridedgecolor="ignored-minor",
            edgewidth=Dict(1 => 2.0, 3 => 4.5),
        )
        @test dict_spec.colors.edgecolor_mode == :by_edge
        @test dict_spec.colors.edgecolor == Dict(1 => "tomato4", 3 => "tan")
        @test dict_spec.colors.defaultedgecolor == "black"
        @test dict_spec.colors.majorhybridedgecolor == "ignored-major"
        @test dict_spec.colors.minorhybridedgecolor == "ignored-minor"
        @test dict_spec.strokes.edgewidth_mode == :by_edge
        @test dict_spec.strokes.edgewidth == Dict(1 => 2.0, 3 => 4.5)

        custom_default_spec = normalize_plot_keywords(
            edgecolor=Dict(1 => "tomato4"),
            defaultedgecolor="grey20",
        )
        @test custom_default_spec.colors.defaultedgecolor == "grey20"

        error = try
            normalize_plot_keywords(edgewidth=Dict(1 => "wide"))
            nothing
        catch err
            err
        end
        @test error isa ErrorException
        @test error.msg == "edgewidth should be numerical"

        unknown_style_error = @test_logs min_level=Warn try
            normalize_plot_keywords(style=:weird, edgewidth=Dict(1 => "wide"))
            nothing
        catch err
            err
        end
        @test unknown_style_error isa ErrorException
        @test unknown_style_error.msg == "edgewidth should be numerical"
    end

    @testset "Explicit limit validation" begin
        xlim = (1.0, 2.0)
        ylim = [3.0, 4.0]
        spec = normalize_plot_keywords(xlim=xlim, ylim=ylim)
        @test spec.layout.xlim === xlim
        @test spec.layout.ylim === ylim

        xlim_error = try
            normalize_plot_keywords(xlim=[1.0, 2.0, 3.0])
            nothing
        catch err
            err
        end
        @test xlim_error isa ErrorException
        @test occursin("xlim", xlim_error.msg)
        @test occursin("exactly 2 values", xlim_error.msg)

        ylim_error = try
            normalize_plot_keywords(ylim=(1.0,))
            nothing
        catch err
            err
        end
        @test ylim_error isa ErrorException
        @test occursin("ylim", ylim_error.msg)
        @test occursin("exactly 2 values", ylim_error.msg)
    end

    @testset "DataFrame ownership and deferral boundary" begin
        nodelabel = DataFrame(node=[-5, missing, 100], label=["90", "99", "bogus"])
        edgelabel = DataFrame(edge=[8, missing, 200], label=["95", "99", "bogus"])

        @test_logs min_level=Warn begin
            spec = normalize_plot_keywords(nodelabel=nodelabel, edgelabel=edgelabel)
            @test spec.annotations.nodelabel isa DataFrame
            @test spec.annotations.edgelabel isa DataFrame
            @test isequal(spec.annotations.nodelabel, nodelabel)
            @test isequal(spec.annotations.edgelabel, edgelabel)
            @test spec.annotations.nodelabel !== nodelabel
            @test spec.annotations.edgelabel !== edgelabel
            @test size(spec.annotations.nodelabel, 1) == 3
            @test size(spec.annotations.edgelabel, 1) == 3
            @test [contract.id for contract in spec.deferred_contracts] ==
                collect(EXPECTED_DEFERRED_PLOT_CONTRACT_IDS)
        end
    end
end
