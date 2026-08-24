@testset "networkio" begin
    elength = getfield(PhyloMakie, :elength)
    egamma = getfield(PhyloMakie, :egamma)
    ishybrid = getfield(PhyloMakie, :ishybrid)

    @testset "Newick: single tree from text" begin
        newick = "(A:1.0,(B:1.0,C:1.0):1.0);"
        nets = parsenetwork(NewickFormat(), newick)
        @test nets isa Vector{LineageNetwork}
        @test length(nets) == 1

        net = only(nets)
        @test Set(PhyloNetworks.tiplabels(net)) == Set(["A", "B", "C"])
        @test all(==(1.0), elength.(net.edge))
    end

    @testset "Newick: reticulate network with gamma from text" begin
        newick = "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"
        net = only(parsenetwork(NewickFormat(), newick))

        @test Set(PhyloNetworks.tiplabels(net)) == Set(["A", "B", "C", "D"])
        hybrid_edges = filter(ishybrid, net.edge)
        @test length(hybrid_edges) == 2
        @test sort(collect(skipmissing(egamma.(hybrid_edges)))) ≈ [0.1, 0.9]
    end

    @testset "Newick: IO and file sources agree with text source" begin
        newick = "(A:1.0,(B:1.0,C:1.0):1.0);"
        from_text = only(parsenetwork(NewickFormat(), newick))
        from_io = only(parsenetwork(NewickFormat(), IOBuffer(newick)))
        @test PhyloNetworks.tiplabels(from_text) == PhyloNetworks.tiplabels(from_io)

        mktemp() do path, io
            write(io, newick)
            close(io)
            from_file = only(readnetwork(NewickFormat(), path))
            @test Set(PhyloNetworks.tiplabels(from_file)) == Set(PhyloNetworks.tiplabels(from_text))
        end
    end

    nexus_treeblock = """
    #NEXUS
    begin trees;
      translate
        1 A,
        2 B,
        3 C;
      tree tree1 = (1,(2,3));
      tree tree2 = (1,(3,2));
    end;
    """

    @testset "Nexus: treeblock from text" begin
        nets = parsenetwork(NexusFormat(), nexus_treeblock)
        @test nets isa Vector{LineageNetwork}
        @test length(nets) == 2
        @test all(net -> Set(PhyloNetworks.tiplabels(net)) == Set(["A", "B", "C"]), nets)
    end

    @testset "Nexus: IO and file sources agree with text source" begin
        from_text = parsenetwork(NexusFormat(), nexus_treeblock)
        from_io = parsenetwork(NexusFormat(), IOBuffer(nexus_treeblock))
        @test length(from_io) == length(from_text)

        mktemp() do path, io
            write(io, nexus_treeblock)
            close(io)
            from_file = readnetwork(NexusFormat(), path)
            @test length(from_file) == length(from_text)
            @test PhyloNetworks.tiplabels(first(from_file)) == PhyloNetworks.tiplabels(first(from_text))
        end
    end
end
