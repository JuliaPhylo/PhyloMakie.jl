@testset "phylogeny I/O" begin
    elength = getfield(PhyloMakie, :elength)
    egamma = getfield(PhyloMakie, :egamma)
    ishybrid = getfield(PhyloMakie, :ishybrid)

    @testset "Newick: single tree from text" begin
        newick = "(A:1.0,(B:1.0,C:1.0):1.0);"
        net = parsephylogeny(NewickFormat(), newick)
        @test net isa LineageNetwork
        @test Set(PhyloNetworks.tiplabels(net)) == Set(["A", "B", "C"])
        @test all(==(1.0), elength.(net.edge))
    end

    @testset "Newick: multiple trees from text" begin
        newick = """
        (A, B);
        (C, (D, E));
        """
        nets = parsephylogenies(NewickFormat(), newick)

        @test nets isa Vector{LineageNetwork}
        @test length(nets) == 2
        @test Set(PhyloNetworks.tiplabels(nets[1])) == Set(["A", "B"])
        @test Set(PhyloNetworks.tiplabels(nets[2])) == Set(["C", "D", "E"])

        from_io = parsephylogenies(NewickFormat(), IOBuffer(newick))
        @test PhyloNetworks.tiplabels.(from_io) == PhyloNetworks.tiplabels.(nets)

        mktemp() do path, io
            write(io, newick)
            close(io)
            from_file = readphylogenies(NewickFormat(), path)
            @test PhyloNetworks.tiplabels.(from_file) == PhyloNetworks.tiplabels.(nets)
            @test_throws ArgumentError readphylogeny(NewickFormat(), path)
        end
    end

    @testset "Newick: malformed topology collections are rejected" begin
        @test_throws ArgumentError parsephylogenies(NewickFormat(), "(A, B)")
        @test_throws ArgumentError parsephylogenies(NewickFormat(), "(A, B);; (C, D);")
    end

    @testset "Newick: singular parsing requires exactly one tree" begin
        @test_throws ArgumentError parsephylogeny(NewickFormat(), "")
        @test_throws ArgumentError parsephylogeny(NewickFormat(), "(A, B); (C, D);")
    end

    @testset "Newick: reticulate network with gamma from text" begin
        newick = "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"
        net = parsephylogeny(NewickFormat(), newick)

        @test Set(PhyloNetworks.tiplabels(net)) == Set(["A", "B", "C", "D"])
        hybrid_edges = filter(ishybrid, net.edge)
        @test length(hybrid_edges) == 2
        @test sort(collect(skipmissing(egamma.(hybrid_edges)))) ≈ [0.1, 0.9]
    end

    @testset "Newick: IO and file sources agree with text source" begin
        newick = "(A:1.0,(B:1.0,C:1.0):1.0);"
        from_text = parsephylogeny(NewickFormat(), newick)
        from_io = parsephylogeny(NewickFormat(), IOBuffer(newick))
        @test PhyloNetworks.tiplabels(from_text) == PhyloNetworks.tiplabels(from_io)

        mktemp() do path, io
            write(io, newick)
            close(io)
            from_file = readphylogeny(NewickFormat(), path)
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
        nets = parsephylogenies(NexusFormat(), nexus_treeblock)
        @test nets isa Vector{LineageNetwork}
        @test length(nets) == 2
        @test all(net -> Set(PhyloNetworks.tiplabels(net)) == Set(["A", "B", "C"]), nets)
        @test_throws ArgumentError parsephylogeny(NexusFormat(), nexus_treeblock)
    end

    @testset "Nexus: IO and file sources agree with text source" begin
        from_text = parsephylogenies(NexusFormat(), nexus_treeblock)
        from_io = parsephylogenies(NexusFormat(), IOBuffer(nexus_treeblock))
        @test length(from_io) == length(from_text)

        mktemp() do path, io
            write(io, nexus_treeblock)
            close(io)
            from_file = readphylogenies(NexusFormat(), path)
            @test length(from_file) == length(from_text)
            @test PhyloNetworks.tiplabels(first(from_file)) == PhyloNetworks.tiplabels(first(from_text))
            @test_throws ArgumentError readphylogeny(NexusFormat(), path)
        end
    end

    @testset "Nexus: singular text, IO, and file sources agree" begin
        single_treeblock = """
        #NEXUS
        begin trees;
          tree tree1 = (A,(B,C));
        end;
        """
        from_text = parsephylogeny(NexusFormat(), single_treeblock)
        from_io = parsephylogeny(NexusFormat(), IOBuffer(single_treeblock))
        @test from_text isa LineageNetwork
        @test PhyloNetworks.tiplabels(from_io) == PhyloNetworks.tiplabels(from_text)

        mktemp() do path, io
            write(io, single_treeblock)
            close(io)
            from_file = readphylogeny(NexusFormat(), path)
            @test PhyloNetworks.tiplabels(from_file) == PhyloNetworks.tiplabels(from_text)
        end
    end

    @testset "String literals: singular parsing and fresh values" begin
        newick_literal() = newick"(A, (B, C));"
        first_newick = newick_literal()
        second_newick = newick_literal()

        @test first_newick isa LineageNetwork
        @test first_newick !== second_newick
        first(first_newick.leaf).name = "changed"
        @test "changed" in PhyloNetworks.tiplabels(first_newick)
        @test !("changed" in PhyloNetworks.tiplabels(second_newick))

        nexustreeblock_literal() = nexustreeblock"""
        #NEXUS
        begin trees;
          tree tree1 = (A,(B,C));
        end;
        """
        first_nexus = nexustreeblock_literal()
        second_nexus = nexustreeblock_literal()
        @test first_nexus isa LineageNetwork
        @test first_nexus !== second_nexus
        @test Set(PhyloNetworks.tiplabels(first_nexus)) == Set(["A", "B", "C"])

        @test_throws ArgumentError newick""
        @test_throws ArgumentError newick"(A, B); (C, D);"
        @test_throws ArgumentError nexustreeblock""
        @test_throws ArgumentError nexustreeblock"""
        #NEXUS
        begin trees;
          tree tree1 = (A,(B,C));
          tree tree2 = (D,(E,F));
        end;
        """
    end
end
