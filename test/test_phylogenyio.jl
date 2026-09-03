@testset "phylogeny I/O" begin
    @testset "Newick: single tree from text" begin
        newick = "(A:1.0,(B:1.0,C:1.0):1.0);"
        phylogeny = parsephylogeny(NewickFormat(), newick)
        @test phylogeny isa LineageNetwork
        @test Set(tip_labels(phylogeny)) == Set(["A", "B", "C"])
        @test all(==(1.0), branch_length.(edges(phylogeny)))
    end

    @testset "Newick: multiple trees from text" begin
        newick = """
        (A, B);
        (C, (D, E));
        """
        phylogenies = parsephylogenies(NewickFormat(), newick)

        @test phylogenies isa Vector{LineageNetwork{Nothing, Nothing, Nothing}}
        @test length(phylogenies) == 2
        @test Set(tip_labels(phylogenies[1])) == Set(["A", "B"])
        @test Set(tip_labels(phylogenies[2])) == Set(["C", "D", "E"])

        from_io = parsephylogenies(NewickFormat(), IOBuffer(newick))
        @test tip_labels.(from_io) == tip_labels.(phylogenies)

        mktemp() do path, io
            write(io, newick)
            close(io)
            from_file = readphylogenies(NewickFormat(), path)
            @test tip_labels.(from_file) == tip_labels.(phylogenies)
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
        phylogeny = parsephylogeny(NewickFormat(), newick)

        @test Set(tip_labels(phylogeny)) == Set(["A", "B", "C", "D"])
        hybrid_edges = filter(is_hybrid, edges(phylogeny))
        @test length(hybrid_edges) == 2
        @test sort(collect(skipmissing(inheritance_probability.(hybrid_edges)))) ≈ [0.1, 0.9]
    end

    @testset "Newick: IO and file sources agree with text source" begin
        newick = "(A:1.0,(B:1.0,C:1.0):1.0);"
        from_text = parsephylogeny(NewickFormat(), newick)
        from_io = parsephylogeny(NewickFormat(), IOBuffer(newick))
        @test tip_labels(from_text) == tip_labels(from_io)

        mktemp() do path, io
            write(io, newick)
            close(io)
            from_file = readphylogeny(NewickFormat(), path)
            @test Set(tip_labels(from_file)) == Set(tip_labels(from_text))
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
        phylogenies = parsephylogenies(NexusFormat(), nexus_treeblock)
        @test phylogenies isa Vector{LineageNetwork{Nothing, Nothing, Nothing}}
        @test length(phylogenies) == 2
        @test all(phylogeny -> Set(tip_labels(phylogeny)) == Set(["A", "B", "C"]), phylogenies)
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
            @test tip_labels(first(from_file)) == tip_labels(first(from_text))
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
        @test tip_labels(from_io) == tip_labels(from_text)

        mktemp() do path, io
            write(io, single_treeblock)
            close(io)
            from_file = readphylogeny(NexusFormat(), path)
            @test tip_labels(from_file) == tip_labels(from_text)
        end
    end

    @testset "String literals: singular parsing and fresh values" begin
        newick_literal() = newick"(A, (B, C));"
        first_newick = newick_literal()
        second_newick = newick_literal()

        @test first_newick isa LineageNetwork
        @test first_newick !== second_newick
        first_tip = first(filter(current_node -> is_leaf(first_newick, current_node), nodes(first_newick)))
        rename_node!(first_tip, "changed")
        @test "changed" in tip_labels(first_newick)
        @test !("changed" in tip_labels(second_newick))

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
        @test Set(tip_labels(first_nexus)) == Set(["A", "B", "C"])

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
