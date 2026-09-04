@testset "Node label files" begin
    mktempdir() do directory
        csv_path = joinpath(directory, "labels.csv")
        write(csv_path, "number,label\n1,Ancestor\n4,Focal clade\n")
        csv_labels = PhyloMakieCLI.load_node_labels(csv_path)
        @test names(csv_labels) == ["number", "label"]
        @test csv_labels.number == [1, 4]
        @test csv_labels.label == ["Ancestor", "Focal clade"]

        tsv_path = joinpath(directory, "labels.tsv")
        write(tsv_path, "number\tlabel\n2\tTip A\n3\tTip B\n")
        tsv_labels = PhyloMakieCLI.load_node_labels(tsv_path)
        @test tsv_labels.number == [2, 3]
        @test tsv_labels.label == ["Tip A", "Tip B"]

        original = Dict{Symbol, Any}(:showtiplabel => false)
        loaded = PhyloMakieCLI.load_plot_options(original, csv_path)
        @test loaded[:showtiplabel] === false
        @test loaded[:nodelabel] == csv_labels
        @test !haskey(original, :nodelabel)

        wrong_extension = joinpath(directory, "labels.txt")
        write(wrong_extension, "number,label\n1,Ancestor\n")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
            wrong_extension,
        )

        wrong_header = joinpath(directory, "wrong.csv")
        write(wrong_header, "node,text\n1,Ancestor\n")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
            wrong_header,
        )

        invalid_number = joinpath(directory, "invalid.csv")
        write(invalid_number, "number,label\nroot,Ancestor\n")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
            invalid_number,
        )

        duplicate_number = joinpath(directory, "duplicate.tsv")
        write(duplicate_number, "number\tlabel\n1\tFirst\n1\tSecond\n")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
            duplicate_number,
        )
    end

    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
        "/path/that/does/not/exist.csv",
    )
end
