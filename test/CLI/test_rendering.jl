@testset "File rendering" begin
    CairoMakie.activate!()
    records = cli_fixture_records()
    figure = PhyloMakieCLI.build_render_figure(
        records,
        Dict{Symbol, Any}(:showtiplabel => true);
        columns = 2,
        panel_size = (300, 220),
    )
    buffer = Makie.colorbuffer(figure; backend = CairoMakie)
    @test size(figure.scene) == (600, 220)
    @test size(buffer, 2) > size(buffer, 1) > 0

    common = PhyloMakieCLI.InputOptions(
        ["-"],
        :newick,
        PhyloMakieCLI.SelectionOptions(nothing, nothing, nothing, 0),
    )
    mktempdir() do directory
        template = joinpath(directory, "tree.svg")
        command = PhyloMakieCLI.RenderCommand(
            common,
            Dict{Symbol, Any}(:useedgelength => false),
            nothing,
            [template],
            :auto,
            :files,
            nothing,
            (300, 220),
            true,
            false,
        )
        paths = PhyloMakieCLI.output_paths(command, 2)
        @test basename.(paths) == ["tree-001.svg", "tree-002.svg"]
        written = PhyloMakieCLI.render_records(records, command, CairoMakie)
        @test written == paths
        @test all(path -> isfile(path) && filesize(path) > 0, paths)
        @test_throws PhyloMakieCLI.CLIUsageError PhyloMakieCLI.render_records(
            records,
            command,
            CairoMakie,
        )

        for extension in ("png", "pdf")
            grid_path = joinpath(directory, "grid.$(extension)")
            grid_command = PhyloMakieCLI.RenderCommand(
                common,
                Dict{Symbol, Any}(),
                nothing,
                [grid_path],
                :auto,
                :grid,
                2,
                (240, 180),
                false,
                false,
            )
            @test PhyloMakieCLI.render_records(records, grid_command, CairoMakie) == [grid_path]
            @test isfile(grid_path) && filesize(grid_path) > 0
        end
    end
end
