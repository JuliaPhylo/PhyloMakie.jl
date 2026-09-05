@testset "Input records and slicing" begin
    record_options = PhyloMakieCLI.SelectionOptions(nothing, nothing, nothing, 0, 1)
    input_options = PhyloMakieCLI.InputOptions(["-"], :newick, record_options)
    result = PhyloMakieCLI.load_records(
        input_options;
        stdin_io = IOBuffer("(A:1,B:1); ((A,C),D); (E,F); (G,H); (I,J); (K,L);"),
    )
    @test isempty(result.warnings)
    @test length(result.records) == 6
    @test result.records[2].record_index == 2

    indices = PhyloMakieCLI.selected_indices("1,2-3,2", 3)
    @test indices == [1, 2, 3]
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.selected_indices("3-2", 3)
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.selected_indices("4", 3)

    head = PhyloMakieCLI.SelectionOptions(nothing, 2, nothing, 0, 1)
    @test getfield.(PhyloMakieCLI.select_records(result.records, head), :record_index) == [1, 2]

    tail = PhyloMakieCLI.SelectionOptions(nothing, nothing, 2, 0, 1)
    @test getfield.(PhyloMakieCLI.select_records(result.records, tail), :record_index) == [5, 6]

    skip = PhyloMakieCLI.SelectionOptions(nothing, nothing, nothing, 2, 1)
    @test getfield.(PhyloMakieCLI.select_records(result.records, skip), :record_index) == [3, 4, 5, 6]

    selected_then_sliced = PhyloMakieCLI.SelectionOptions("1,3-4", 1, nothing, 1, 1)
    chosen = PhyloMakieCLI.select_records(result.records, selected_then_sliced)
    @test getfield.(chosen, :record_index) == [3]

    stride = PhyloMakieCLI.SelectionOptions(nothing, nothing, nothing, 0, 2)
    @test getfield.(PhyloMakieCLI.select_records(result.records, stride), :record_index) == [1, 3, 5]

    both_ends = PhyloMakieCLI.SelectionOptions(nothing, 2, 2, 0, 1)
    @test getfield.(PhyloMakieCLI.select_records(result.records, both_ends), :record_index) == [1, 2, 5, 6]

    overlapping_ends = PhyloMakieCLI.SelectionOptions(nothing, 4, 4, 0, 1)
    @test getfield.(PhyloMakieCLI.select_records(result.records, overlapping_ends), :record_index) == collect(1:6)

    full_pipeline = PhyloMakieCLI.SelectionOptions("1-6", 1, 1, 1, 2)
    @test getfield.(PhyloMakieCLI.select_records(result.records, full_pipeline), :record_index) == [2, 6]

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
