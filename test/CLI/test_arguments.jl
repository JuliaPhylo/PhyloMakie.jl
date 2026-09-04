@testset "Command arguments" begin
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_command(String[])
    @test PhyloMakieCLI.parse_command(["view", "--help"]).topic === :view
    @test occursin("render", PhyloMakieCLI.help_text(:general))
    @test !occursin("compose", PhyloMakieCLI.help_text(:general))
    for topic in (:view, :render)
        help = PhyloMakieCLI.help_text(topic)
        for attribute in getfield(PhyloMakie, :SUPPORTED_PHYLOPLOT_ATTRIBUTES)
            @test occursin("  $(attribute) ", help)
        end
    end
    for topic in (:view, :inspect, :render)
        help = PhyloMakieCLI.help_text(topic)
        for removed in ("--taxon", "--tree-type", "--rootedness", "--min-tips", "--max-tips")
            @test !occursin(removed, help)
        end
    end

    view_command = PhyloMakieCLI.parse_command(
        [
            "view",
            "--input-format",
            "auto",
            "--skip",
            "2",
            "--head",
            "3",
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
    record_options = getfield(view_command.input, Symbol("selec", "tion"))
    @test record_options.skip == 2
    @test record_options.head == 3
    @test isnothing(record_options.tail)
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
    zero_head_command = PhyloMakieCLI.parse_command(["inspect", "--head", "0", "-"])
    zero_head_options = getfield(zero_head_command.input, Symbol("selec", "tion"))
    @test zero_head_options.head == 0

    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_command(["compose"])
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_command(["unknown"])
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_command(
        ["inspect", "--head", "4", "--tail", "2", "-"]
    )
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_command(
        ["inspect", "--skip", "-1", "-"]
    )
    for removed in ("--taxon", "--tree-type", "--rootedness", "--min-tips", "--max-tips")
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_command(
            ["inspect", removed, "value", "-"],
        )
    end
    @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.parse_plot_assignment(
        "unknownattribute = true",
    )
end
