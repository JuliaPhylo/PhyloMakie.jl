@testset "Input records and filters" begin
    demo = PhyloMakieCLI.demo_records()
    @test getfield.(demo, :record_index) == [1, 2]

    filter_options = PhyloMakieCLI.SelectionOptions(nothing, String[], :any, :any, nothing, nothing)
    input_options = PhyloMakieCLI.InputOptions(["-"], :newick, filter_options)
    result = PhyloMakieCLI.load_records(
        input_options;
        stdin_io = IOBuffer("(A:1,B:1); ((A,C),D);"),
    )
    @test isempty(result.warnings)
    @test length(result.records) == 2
    @test result.records[2].record_index == 2

    indices = PhyloMakieCLI.selected_indices("1,2-3,2", 3)
    @test indices == [1, 2, 3]
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.selected_indices("3-2", 3)
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.selected_indices("4", 3)

    taxon_filter = PhyloMakieCLI.SelectionOptions(nothing, ["C"], :tree, :rooted, 3, 3)
    chosen = PhyloMakieCLI.select_records(result.records, taxon_filter)
    @test length(chosen) == 1
    @test Set(tip_labels(only(chosen).phylogeny)) == Set(["A", "C", "D"])

    nexus = """
    #NEXUS
    begin trees;
      tree first = (A,(B,C));
    end;
    """
    automatic_input = PhyloMakieCLI.InputOptions(["-"], :auto, filter_options)
    automatic_result = PhyloMakieCLI.load_records(
        automatic_input;
        stdin_io = IOBuffer(nexus),
    )
    @test length(automatic_result.records) == 1
    @test Set(tip_labels(only(automatic_result.records).phylogeny)) == Set(["A", "B", "C"])

    demonstrations = PhyloMakieCLI.load_records(
        PhyloMakieCLI.InputOptions(String[], :newick, filter_options);
        allow_demo = true,
    )
    @test length(demonstrations.records) == 2
end
