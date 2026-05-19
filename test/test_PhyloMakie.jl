using Makie
using PhyloNetworks: HybridNetwork, readnewick

@testset "PhyloMakie module" begin
    @test !isdefined(PhyloMakie, :VERIFICATION_FOUNDATION)
    @test isdefined(PhyloMakie, :PhyloPlotAttributes)
    @test isdefined(PhyloMakie, :PlotGeometry)
    @test isdefined(PhyloMakie, :PlotBounds)
    @test isdefined(PhyloMakie, :PlotLayout)
    @test isdefined(PhyloMakie, :render_plot!)
    @test isdefined(PhyloMakie, :PlotRenderLayers)
    @test isdefined(PhyloMakie, :phyloplot)
    @test isdefined(PhyloMakie, Symbol("phyloplot!"))
    @test isdefined(PhyloMakie, :PhyloPlot)
    @test !isdefined(PhyloMakie, :PlotKeywordSpec)
    @test !isdefined(PhyloMakie, :normalize_plot_keywords)
    @test !isdefined(PhyloMakie, :bridge_phylo_plot_attributes)

    net = readnewick("(A,B);")
    @test which(Makie.plottype, (HybridNetwork,)) != which(Makie.plottype, (Any,))
    @test Makie.plottype(net) == getfield(PhyloMakie, :PhyloPlot)
end
