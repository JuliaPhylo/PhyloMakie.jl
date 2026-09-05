@testset "Selected-record serialization" begin
    records = PhyloMakieCLI.load_records(
        PhyloMakieCLI.InputOptions(
            ["-"],
            :newick,
            PhyloMakieCLI.SelectionOptions(nothing, nothing, nothing, 0, 1),
        );
        stdin_io = IOBuffer("(A1,B1)Root1; (A2,B2)Root2;"),
    ).records

    newick_text = PhyloMakieCLI.selected_records_text(records, :newick)
    newick_records = PhyloMakie.parsephylogenies(PhyloMakie.NewickFormat(), newick_text)
    @test length(newick_records) == 2
    @test tip_labels.(newick_records) == [["A1", "B1"], ["A2", "B2"]]

    nexus_text = PhyloMakieCLI.selected_records_text(records, :nexus)
    @test startswith(nexus_text, "#NEXUS\n\nbegin trees;")
    nexus_records = PhyloMakie.parsephylogenies(PhyloMakie.NexusFormat(), nexus_text)
    @test length(nexus_records) == 2
    @test tip_labels.(nexus_records) == [["A1", "B1"], ["A2", "B2"]]

    @test_throws ArgumentError PhyloMakieCLI.selected_records_text(records, :json)
end
