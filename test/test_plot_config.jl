using DataFrames: DataFrame

@testset "Plot config computation" begin
    PhyloPlotConfig = getfield(PhyloMakie, :PhyloPlotConfig)
    PhyloPlotAttributes = getfield(PhyloMakie, :PhyloPlotAttributes)
    resolve_plot_config = getfield(PhyloMakie, :resolve_plot_config)
    resolve_phylo_plot_attributes = getfield(PhyloMakie, :resolve_phylo_plot_attributes)
    with_phylo_plot_limits = getfield(PhyloMakie, :with_phylo_plot_limits)
    with_plot_config_limits = getfield(PhyloMakie, :with_plot_config_limits)
    validate_limit_pair = getfield(PhyloMakie, :validate_limit_pair)

    @testset "Defaults and compatibility adapter" begin
        config = resolve_plot_config()
        attributes = resolve_phylo_plot_attributes()

        @test config isa PhyloPlotConfig
        @test attributes isa PhyloPlotAttributes
        @test PhyloPlotAttributes(config).style == attributes.style
        @test getfield(PhyloMakie, :PhyloPlotConfig)(attributes).style == config.style
        @test config.useedgelength === false
        @test config.showtiplabel === true
        @test config.minorlinetype == "longdash"
        @test config.arrowlen == 0.1
        @test config.edgenumbercolor == "grey"
        @test config.xlim === nothing
        @test config.ylim === nothing

        resolved_config = with_plot_config_limits(config, (0.0, 5.0), (1.0, 4.0))
        resolved_attributes = with_phylo_plot_limits(attributes, (0.0, 5.0), (1.0, 4.0))
        @test resolved_config isa PhyloPlotConfig
        @test resolved_config !== config
        @test resolved_config.xlim == (0.0, 5.0)
        @test resolved_config.ylim == (1.0, 4.0)
        @test resolved_attributes isa PhyloPlotAttributes
        @test resolved_attributes.xlim == resolved_config.xlim
        @test resolved_attributes.ylim == resolved_config.ylim
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
