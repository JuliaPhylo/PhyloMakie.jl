@testset "Pixel arrowhead geometry" begin
    ArrowheadPixelPolygon = getfield(PhyloMakie, :ArrowheadPixelPolygon)
    compute_arrowhead_pixel_meshes = getfield(PhyloMakie, :compute_arrowhead_pixel_meshes)

    @testset "requested pixel metrics are preserved" begin
        startpoint = Makie.Point2f(0, 0)
        endpoint = Makie.Point2f(10, 0)
        tiplength = 8.0f0
        tipwidth = 6.4f0
        polygon = only(
            compute_arrowhead_pixel_meshes(
                Makie.Point2f[startpoint],
                Makie.Point2f[endpoint],
                Float32[tiplength],
                Float32[tipwidth],
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
        _assert_arrowhead_matches_projected_shaft(
            polygon,
            startpoint,
            endpoint,
            tiplength,
            tipwidth,
        )
    end

    @testset "vertical pixel segments use vertical axis and horizontal wing" begin
        startpoint = Makie.Point2f(0, 0)
        endpoint = Makie.Point2f(0, 10)
        tiplength = 8.0f0
        tipwidth = 6.4f0
        polygon = only(
            compute_arrowhead_pixel_meshes(
                Makie.Point2f[startpoint],
                Makie.Point2f[endpoint],
                Float32[tiplength],
                Float32[tipwidth],
            ),
        )
        vertices = _arrowhead_vertices(polygon)
        base_center = _arrowhead_base_center(vertices)
        axis = vertices[1] - base_center
        wing = vertices[2] - vertices[3]
        metrics = _arrowhead_pixel_metrics(polygon)

        @test length(vertices) == 3
        @test vertices[1] == Makie.Point2f(0, 10)
        @test base_center == Makie.Point2f(0, 2)
        @test isapprox(metrics.length, 8.0f0; atol=1.0f-4)
        @test isapprox(metrics.width, 6.4f0; atol=1.0f-4)
        @test isapprox(axis[1], 0.0f0; atol=1.0f-4)
        @test isapprox(axis[2], 8.0f0; atol=1.0f-4)
        @test isapprox(wing[2], 0.0f0; atol=1.0f-4)
        @test isapprox(abs(wing[1]), 6.4f0; atol=1.0f-4)
        _assert_arrowhead_matches_projected_shaft(
            polygon,
            startpoint,
            endpoint,
            tiplength,
            tipwidth,
        )
    end

    @testset "diagonal and 3D projected points use screen-space direction" begin
        startpoint = Makie.Point3f(100, 50, 0)
        endpoint = Makie.Point3f(106, 58, 0)
        tiplength = 8.0f0
        tipwidth = 6.4f0
        polygon = only(
            compute_arrowhead_pixel_meshes(
                Makie.Point3f[startpoint],
                Makie.Point3f[endpoint],
                Float32[tiplength],
                Float32[tipwidth],
            ),
        )
        metrics = _arrowhead_pixel_metrics(polygon)

        @test isapprox(metrics.length, 8.0f0; atol=1.0f-4)
        @test isapprox(metrics.width, 6.4f0; atol=1.0f-4)
        @test isapprox(_arrowhead_axis_wing_dot(polygon), 0.0f0; atol=1.0f-3)
        _assert_arrowhead_matches_projected_shaft(
            polygon,
            startpoint,
            endpoint,
            tiplength,
            tipwidth,
        )
    end

    @testset "short pixel segments scale length and width together" begin
        startpoint = Makie.Point2f(0, 0)
        endpoint = Makie.Point2f(4, 0)
        tiplength = 8.0f0
        tipwidth = 6.4f0
        polygon = only(
            compute_arrowhead_pixel_meshes(
                Makie.Point2f[startpoint],
                Makie.Point2f[endpoint],
                Float32[tiplength],
                Float32[tipwidth],
            ),
        )
        metrics = _arrowhead_pixel_metrics(polygon)

        @test isapprox(metrics.length, 4.0f0; atol=1.0f-4)
        @test isapprox(metrics.width, 3.2f0; atol=1.0f-4)
        _assert_arrowhead_matches_projected_shaft(
            polygon,
            startpoint,
            endpoint,
            tiplength,
            tipwidth,
        )
    end

    @testset "zero-length pixel segments return degenerate polygons" begin
        startpoint = Makie.Point2f(5, 7)
        endpoint = Makie.Point2f(5, 7)
        tiplength = 8.0f0
        tipwidth = 6.4f0
        polygon = only(
            compute_arrowhead_pixel_meshes(
                Makie.Point2f[startpoint],
                Makie.Point2f[endpoint],
                Float32[tiplength],
                Float32[tipwidth],
            ),
        )
        vertices = _arrowhead_vertices(polygon)
        metrics = _arrowhead_pixel_metrics(polygon)

        @test length(vertices) == 3
        @test all(vertex -> vertex == endpoint, vertices)
        @test metrics.length == 0.0f0
        @test metrics.width == 0.0f0
        _assert_arrowhead_matches_projected_shaft(
            polygon,
            startpoint,
            endpoint,
            tiplength,
            tipwidth,
        )
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
