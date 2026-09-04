@testset "Command arguments" begin
    @test PhyloMakieCLI.parse_command(String[]) isa PhyloMakieCLI.HelpCommand
    @test PhyloMakieCLI.parse_command(["view", "--help"]).topic === :view
    @test occursin("render", PhyloMakieCLI.help_text(:general))
    @test !occursin("compose", PhyloMakieCLI.help_text(:general))

    view_command = PhyloMakieCLI.parse_command(
        [
            "view",
            "--input-format",
            "auto",
            "--taxon",
            "A",
            "--min-tips",
            "2",
            "--size",
            "800x600",
            "-p",
            "useedgelength = true",
            "-p",
            "style = :majortree",
            "trees.nwk",
        ]
    )
    @test view_command isa PhyloMakieCLI.ViewCommand
    @test view_command.input.format === :auto
    @test view_command.input.sources == ["trees.nwk"]
    @test view_command.size == (800, 600)
    @test view_command.plot_options[:useedgelength] === true
    @test view_command.plot_options[:style] === :majortree

    @test PhyloMakieCLI.parse_plot_assignment("ylim = (-1, 5.5)") == (:ylim => (-1, 5.5))
    colors = last(
        PhyloMakieCLI.parse_plot_assignment(
            "edgecolor = Dict(1 => \"red\", 2 => \"blue\")",
        ),
    )
    @test colors == Dict(1 => "red", 2 => "blue")

    inspect_command = PhyloMakieCLI.parse_command(["inspect", "-vv", "--taxa-only", "-"])
    @test inspect_command.verbosity == 2
    @test inspect_command.taxa_only

    render_command = PhyloMakieCLI.parse_command(["render", "--output", "tree.svg", "-"])
    @test render_command isa PhyloMakieCLI.RenderCommand

    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_command(["compose"])
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_command(["unknown"])
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_command(
        [
            "inspect",
            "--min-tips",
            "4",
            "--max-tips",
            "2",
            "-",
        ]
    )
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_plot_assignment(
        "unknownattribute = true",
    )
end
