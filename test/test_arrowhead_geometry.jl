using Makie

@testset "Pixel arrowhead geometry" begin
    ArrowheadPixelPolygon = getfield(PhyloMakie, :ArrowheadPixelPolygon)
    compute_arrowhead_pixel_meshes = getfield(PhyloMakie, :compute_arrowhead_pixel_meshes)

    @testset "requested pixel metrics are preserved" begin
        polygon = only(
            compute_arrowhead_pixel_meshes(
                Makie.Point2f[(0, 0)],
                Makie.Point2f[(10, 0)],
                Float32[8],
                Float32[6.4],
            ),
        )
        vertices = _arrowhead_vertices(polygon)
        metrics = _arrowhead_pixel_metrics(polygon)

        @test polygon isa ArrowheadPixelPolygon
        @test length(vertices) == 3
        @test vertices[1] == Makie.Point2f(10, 0)
        @test isapprox(metrics.length, 8.0f0; atol=1.0f-4)
        @test isapprox(metrics.width, 6.4f0; atol=1.0f-4)
        @test isapprox(_arrowhead_axis_wing_dot(polygon), 0.0f0; atol=1.0f-4)
    end

    @testset "diagonal and 3D projected points use screen-space direction" begin
        polygon = only(
            compute_arrowhead_pixel_meshes(
                Makie.Point3f[(100, 50, 0)],
                Makie.Point3f[(106, 58, 0)],
                Float32[8],
                Float32[6.4],
            ),
        )
        metrics = _arrowhead_pixel_metrics(polygon)

        @test isapprox(metrics.length, 8.0f0; atol=1.0f-4)
        @test isapprox(metrics.width, 6.4f0; atol=1.0f-4)
        @test isapprox(_arrowhead_axis_wing_dot(polygon), 0.0f0; atol=1.0f-3)
    end

    @testset "short pixel segments scale length and width together" begin
        polygon = only(
            compute_arrowhead_pixel_meshes(
                Makie.Point2f[(0, 0)],
                Makie.Point2f[(4, 0)],
                Float32[8],
                Float32[6.4],
            ),
        )
        metrics = _arrowhead_pixel_metrics(polygon)

        @test isapprox(metrics.length, 4.0f0; atol=1.0f-4)
        @test isapprox(metrics.width, 3.2f0; atol=1.0f-4)
    end

    @testset "empty and mismatched inputs keep concrete failure modes" begin
        @test compute_arrowhead_pixel_meshes(
            Makie.Point2f[],
            Makie.Point2f[],
            Float32[],
            Float32[],
        ) == ArrowheadPixelPolygon[]
        @test_throws DimensionMismatch compute_arrowhead_pixel_meshes(
            Makie.Point2f[(0, 0)],
            Makie.Point2f[],
            Float32[8],
            Float32[6.4],
        )
    end
end
