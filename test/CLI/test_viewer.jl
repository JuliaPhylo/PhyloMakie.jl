@testset "Interactive viewer construction" begin
    CairoMakie.activate!()
    records = cli_fixture_records()
    viewer = PhyloMakieCLI.build_viewer(
        records,
        PhyloMakieCLI.LoadWarning[],
        Dict{Symbol, Any}(
            :showgamma => true,
            :style => :majortree,
            :edgewidth => 9.0,
            :arrowlen => 3.5,
        );
        size = (800, 500),
    )
    @test viewer isa PhyloMakieCLI.Viewer
    @test viewer.state.showgamma
    @test viewer.state.style === :majortree
    @test viewer.state.edgewidth == 9.0
    @test viewer.state.arrowlen == 3.5
    @test viewer.plot[:showgamma][]

    PhyloMakieCLI.select_record!(viewer, records, 2)
    @test viewer.state.current_index == 2
    @test occursin("standard input", viewer.current_label.text[])
    buffer = Makie.colorbuffer(viewer.figure; backend = CairoMakie)
    @test size(viewer.figure.scene) == (800, 500)
    @test size(buffer, 2) > size(buffer, 1) > 0
end

@testset "GLMakie displays a viewer without image annotations" begin
    GLMakie.activate!()
    try
        records = cli_fixture_records()[1:1]
        viewer = PhyloMakieCLI.build_viewer(
            records,
            PhyloMakieCLI.LoadWarning[],
            Dict{Symbol, Any}();
            size = (320, 240),
        )
        @test isempty(viewer.plot[:edge_image_markers][])
        @test isempty(viewer.plot[:node_image_markers][])
        buffer = Makie.colorbuffer(viewer.figure; backend = GLMakie)
        @test size(buffer) == (240, 320)
    finally
        CairoMakie.activate!()
    end
end
