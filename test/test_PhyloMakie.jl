_module_symbol(parts::AbstractString...) = Symbol(join(parts))

@testset "PhyloMakie module" begin
    @test !isdefined(PhyloMakie, :VERIFICATION_FOUNDATION)
    @test isdefined(PhyloMakie, :PhyloPlotConfig)
    @test isdefined(PhyloMakie, :resolve_plot_config)
    @test isdefined(PhyloMakie, :PlotNetwork)
    @test isdefined(PhyloMakie, :prepare_plot_network)
    @test isdefined(PhyloMakie, :NetworkGeometry)
    @test isdefined(PhyloMakie, :compute_network_geometry)
    @test isdefined(PhyloMakie, :PlotExtent)
    @test isdefined(PhyloMakie, :AnnotationTables)
    @test isdefined(PhyloMakie, :LayoutComputation)
    @test isdefined(PhyloMakie, :compute_layout)
    @test isdefined(PhyloMakie, :SegmentChannel)
    @test isdefined(PhyloMakie, :TextChannel)
    @test isdefined(PhyloMakie, :ArrowheadSpecChannel)
    @test isdefined(PhyloMakie, :ArrowheadPixelPolygon)
    @test isdefined(PhyloMakie, :compute_arrowhead_pixel_meshes)
    @test isdefined(PhyloMakie, :PrimitiveChannels)
    @test isdefined(PhyloMakie, :compute_data_limits)
    @test isdefined(PhyloMakie, :compute_primitive_channels)
    @test isdefined(PhyloMakie, :SegmentGraphOutputs)
    @test isdefined(PhyloMakie, :ArrowheadGraphOutputs)
    @test isdefined(PhyloMakie, :PhyloGraphOutputs)
    @test isdefined(PhyloMakie, :TextGraphOutputs)
    @test isdefined(PhyloMakie, :PhyloTextGraphOutputs)
    @test isdefined(PhyloMakie, :phylo_graph_output_symbols)
    @test isdefined(PhyloMakie, :register_phylo_graph!)
    @test isdefined(PhyloMakie, :register_primitive_graph_outputs!)
    @test isdefined(PhyloMakie, :register_text_graph_outputs!)
    @test isdefined(PhyloMakie, :PhyloPrimitiveHandles)
    @test isdefined(PhyloMakie, :create_segment_primitive!)
    @test isdefined(PhyloMakie, :create_arrowhead_primitive!)
    @test isdefined(PhyloMakie, :create_text_primitive!)
    @test isdefined(PhyloMakie, :create_phylo_primitives!)
    @test isdefined(PhyloMakie, :phyloplot)
    @test isdefined(PhyloMakie, Symbol("phyloplot!"))
    @test isdefined(PhyloMakie, :PhyloPlot)
    @test isdefined(PhyloMakie, :node_positions)
    @test isdefined(PhyloMakie, :edge_positions)
    @test :readnewick in names(PhyloMakie)
    @test PhyloMakie.readnewick === PhyloNetworks.readnewick
    @test !isdefined(PhyloMakie, :PlotKeywordSpec)
    @test !isdefined(PhyloMakie, :normalize_plot_keywords)
    @test !isdefined(PhyloMakie, :bridge_phylo_plot_attributes)
    retired_internal_names = (
        _module_symbol("render", "_", "plot", "!"),
        _module_symbol("Phylo", "Plot", "Attributes"),
        _module_symbol("Plot", "Geometry"),
        _module_symbol("Plot", "Bounds"),
        _module_symbol("Plot", "Annotation", "Data"),
        _module_symbol("Plot", "Layout"),
        _module_symbol("Plot", "Render", "Layers"),
        _module_symbol("Segment", "Render", "Layer"),
        _module_symbol("Arrow", "Tip", "Render", "Layer"),
        _module_symbol("Text", "Render", "Layer"),
        _module_symbol("resolve", "_", "phylo", "_", "plot", "_", "attributes"),
        _module_symbol("with", "_", "phylo", "_", "plot", "_", "limits"),
        _module_symbol("layout", "_", "plot", "_", "geometry"),
        _module_symbol("prepare", "_", "plot", "_", "layout"),
    )
    for name in retired_internal_names
        @test !isdefined(PhyloMakie, name)
    end

    net = PhyloMakie.readnewick("(A,B);")
    @test which(Makie.plottype, (HybridNetwork,)) != which(Makie.plottype, (Any,))
    @test Makie.plottype(net) == getfield(PhyloMakie, :PhyloPlot)
end
