@testset "Input records and slicing" begin
    record_options = PhyloMakieCLI.SelectionOptions(nothing, nothing, nothing, 0)
    input_options = PhyloMakieCLI.InputOptions(["-"], :newick, record_options)
    result = PhyloMakieCLI.load_records(
        input_options;
        stdin_io = IOBuffer("(A:1,B:1); ((A,C),D); (E,F); (G,H);"),
    )
    @test isempty(result.warnings)
    @test length(result.records) == 4
    @test result.records[2].record_index == 2

    indices = PhyloMakieCLI.selected_indices("1,2-3,2", 3)
    @test indices == [1, 2, 3]
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.selected_indices("3-2", 3)
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.selected_indices("4", 3)

    head = PhyloMakieCLI.SelectionOptions(nothing, 2, nothing, 0)
    @test getfield.(PhyloMakieCLI.select_records(result.records, head), :record_index) == [1, 2]

    tail = PhyloMakieCLI.SelectionOptions(nothing, nothing, 2, 0)
    @test getfield.(PhyloMakieCLI.select_records(result.records, tail), :record_index) == [3, 4]

    skip = PhyloMakieCLI.SelectionOptions(nothing, nothing, nothing, 2)
    @test getfield.(PhyloMakieCLI.select_records(result.records, skip), :record_index) == [3, 4]

    selected_then_sliced = PhyloMakieCLI.SelectionOptions("1,3-4", 1, nothing, 1)
    chosen = PhyloMakieCLI.select_records(result.records, selected_then_sliced)
    @test getfield.(chosen, :record_index) == [3]

    nexus = """
    #NEXUS
    begin trees;
      tree first = (A,(B,C));
    end;
    """
    automatic_input = PhyloMakieCLI.InputOptions(["-"], :auto, record_options)
    automatic_result = PhyloMakieCLI.load_records(
        automatic_input;
        stdin_io = IOBuffer(nexus),
    )
    @test length(automatic_result.records) == 1
    @test Set(tip_labels(only(automatic_result.records).phylogeny)) == Set(["A", "B", "C"])

    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_records(
        PhyloMakieCLI.InputOptions(String[], :newick, record_options),
    )
end
