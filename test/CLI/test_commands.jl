@testset "Command execution" begin
    output_io = IOBuffer()
    error_io = IOBuffer()
    @test PhyloMakieCLI.run(["--help"]; output_io, error_io) == 0
    @test occursin("Usage: phylomakie", String(take!(output_io)))
    @test isempty(String(take!(error_io)))

    @test PhyloMakieCLI.run(String[]; output_io, error_io) == 2
    @test isempty(String(take!(output_io)))
    @test occursin("usage error: Input is required", String(take!(error_io)))

    for command in ("view", "inspect", "render")
        @test PhyloMakieCLI.run([command]; output_io, error_io) == 2
        @test isempty(String(take!(output_io)))
        @test occursin("usage error: Input is required", String(take!(error_io)))
    end

    @test PhyloMakieCLI.run(
        ["inspect", "--taxa-only", "-"],
        output_io = output_io,
        error_io = error_io,
        stdin_io = IOBuffer("(C,A); (B,A);"),
    ) == 0
    @test String(take!(output_io)) == "A\nB\nC\n"
    @test isempty(String(take!(error_io)))

    @test PhyloMakieCLI.run(["view", "--unknown"]; output_io, error_io) == 2
    @test occursin("usage error: Unknown option", String(take!(error_io)))

    @test PhyloMakieCLI.run(
        ["inspect", "--skip", "1", "-"],
        output_io = output_io,
        error_io = error_io,
        stdin_io = IOBuffer("(A,B);"),
    ) == 1
    @test occursin("No phylogeny records matched", String(take!(error_io)))

    mktempdir() do directory
        selected_path = joinpath(directory, "selected.nwk")
        @test PhyloMakieCLI.run(
            [
                "inspect",
                "--skip",
                "1",
                "--stride",
                "2",
                "--head",
                "1",
                "--tail",
                "1",
                "--selected-output-file",
                selected_path,
                "-",
            ],
            output_io = output_io,
            error_io = error_io,
            stdin_io = IOBuffer(
                "(A1,B1); (A2,B2); (A3,B3); (A4,B4); (A5,B5); (A6,B6);",
            ),
        ) == 0
        take!(output_io)
        @test isempty(String(take!(error_io)))
        selected_records = PhyloMakie.readphylogenies(
            PhyloMakie.NewickFormat(),
            selected_path,
        )
        @test tip_labels.(selected_records) == [["A2", "B2"], ["A6", "B6"]]

        output = joinpath(directory, "tree.svg")
        @test PhyloMakieCLI.run(
            ["render", "--output", output, "-"],
            output_io = output_io,
            error_io = error_io,
            stdin_io = IOBuffer("(A:1,(B:2,C:3):4);"),
        ) == 0
        @test String(take!(output_io)) == "$(output)\n"
        @test isempty(String(take!(error_io)))
        @test isfile(output) && filesize(output) > 0

        labels = joinpath(directory, "labels.tsv")
        write(labels, "name\tdisplay\nA\tFirst tip\nRoot\tAncestor\n")
        labeled_output = joinpath(directory, "labeled.svg")
        original_output = joinpath(directory, "original.nwk")
        @test PhyloMakieCLI.run(
            [
                "render",
                "--output",
                labeled_output,
                "--node-labels",
                labels,
                "--selected-output-file",
                original_output,
                "-",
            ],
            output_io = output_io,
            error_io = error_io,
            stdin_io = IOBuffer("(A:1,(B:2,C:3):4)Root;"),
        ) == 0
        @test String(take!(output_io)) == "$(labeled_output)\n"
        @test isempty(String(take!(error_io)))
        @test isfile(labeled_output) && filesize(labeled_output) > 0
        original_names = PhyloMakie.node_label.(
            PhyloMakie.nodes(
                only(
                    PhyloMakie.readphylogenies(
                        PhyloMakie.NewickFormat(),
                        original_output,
                    ),
                ),
            ),
        )
        @test "A" in original_names
        @test "Root" in original_names
        @test !("First tip" in original_names)
        @test !("Ancestor" in original_names)
    end
end
