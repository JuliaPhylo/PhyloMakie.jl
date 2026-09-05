@testset "Node display-name files" begin
    records = PhyloMakieCLI.load_records(
        PhyloMakieCLI.InputOptions(
            ["-"],
            :newick,
            PhyloMakieCLI.SelectionOptions(nothing, nothing, nothing, 0, 1),
        );
        stdin_io = IOBuffer("(A,(B,C)Inner)Root;"),
    ).records

    mktempdir() do directory
        csv_path = joinpath(directory, "labels.csv")
        write(csv_path, "name,display\nA,Canis lupus\nInner,Focal clade\nRoot,Ancestor\n")
        csv_labels = PhyloMakieCLI.load_node_labels(csv_path)
        @test csv_labels == Dict(
            "A" => "Canis lupus",
            "Inner" => "Focal clade",
            "Root" => "Ancestor",
        )

        tsv_path = joinpath(directory, "labels.tsv")
        write(tsv_path, "name\tdisplay\nB\tTip B\nC\tTip C\n")
        tsv_labels = PhyloMakieCLI.load_node_labels(tsv_path)
        @test tsv_labels == Dict("B" => "Tip B", "C" => "Tip C")

        original_options = Dict{Symbol, Any}(
            :showtiplabel => true,
            :nodeimages => Dict("A" => "a.png"),
            :edgeimages => Dict(("Root", "Inner") => "inner.png"),
        )
        loaded = PhyloMakieCLI.load_display_inputs(records, original_options, csv_path)
        original_names = PhyloMakie.node_label.(PhyloMakie.nodes(only(records).phylogeny))
        display_names = PhyloMakie.node_label.(
            PhyloMakie.nodes(only(loaded.records).phylogeny),
        )
        @test original_names == ["A", "B", "C", "Inner", "Root"]
        @test display_names == ["Canis lupus", "B", "C", "Focal clade", "Ancestor"]
        @test loaded.plot_options[:showtiplabel] === true
        @test loaded.plot_options[:nodeimages] == Dict("Canis lupus" => "a.png")
        @test loaded.plot_options[:edgeimages] ==
            Dict(("Ancestor", "Focal clade") => "inner.png")
        @test original_options[:nodeimages] == Dict("A" => "a.png")

        wrong_extension = joinpath(directory, "labels.txt")
        write(wrong_extension, "name,display\nA,Canis lupus\n")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
            wrong_extension,
        )

        wrong_header = joinpath(directory, "wrong.csv")
        write(wrong_header, "number,label\n1,Ancestor\n")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
            wrong_header,
        )

        empty_name = joinpath(directory, "empty.csv")
        write(empty_name, "name,display\n,Ancestor\n")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
            empty_name,
        )

        duplicate_name = joinpath(directory, "duplicate.tsv")
        write(duplicate_name, "name\tdisplay\nA\tFirst\nA\tSecond\n")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
            duplicate_name,
        )

        ambiguous_images = Dict{Symbol, Any}(
            :nodeimages => Dict("A" => "a.png", "B" => "b.png"),
        )
        ambiguous_path = joinpath(directory, "ambiguous.csv")
        write(ambiguous_path, "name,display\nA,Same\nB,Same\n")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_display_inputs(
            records,
            ambiguous_images,
            ambiguous_path,
        )
    end

    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.load_node_labels(
        "/path/that/does/not/exist.csv",
    )
end
