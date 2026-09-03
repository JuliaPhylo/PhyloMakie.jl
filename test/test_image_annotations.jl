const IMAGE_ANNOTATION_NEWICK = "((A,B)AB,C)Root;"
const IMAGE_ASSET_DIRECTORY =
    normpath(joinpath(@__DIR__, "..", "examples", "assets", "circles"))

function _image_annotation_layout(phylogeny::AbstractPhylogeny; style = :fulltree)
    config = getfield(PhyloMakie, :resolve_plot_config)(; style)
    prepared_phylogeny = getfield(PhyloMakie, :prepare_for_layout)(phylogeny)
    geometry = getfield(PhyloMakie, :compute_phylogeny_geometry)(prepared_phylogeny, config)
    layout = getfield(PhyloMakie, :compute_layout)(prepared_phylogeny, config, geometry)
    return prepared_phylogeny, layout
end

function _solid_image(color)::Matrix{RGBAf}
    return fill(convert(RGBAf, Makie.to_color(color)), 4, 8)
end

function _is_red_image_pixel(pixel)::Bool
    color = convert(RGBAf, pixel)
    return color.r > 0.75 && color.g < 0.45
end

function _is_blue_image_pixel(pixel)::Bool
    color = convert(RGBAf, pixel)
    return color.b > 0.65 && color.r < 0.35
end

@testset "Image annotations" begin
    ImageAssetCache = getfield(PhyloMakie, :ImageAssetCache)
    load_image_source! = getfield(PhyloMakie, :_load_image_source!)
    resolve_node_values = getfield(PhyloMakie, :_resolve_node_image_values)
    resolve_edge_values = getfield(PhyloMakie, :_resolve_edge_image_values)
    build_image_channel! = getfield(PhyloMakie, :_build_image_channel!)
    image_probe_positions = getfield(PhyloMakie, :image_probe_positions)
    compute_image_marker_geometry =
        getfield(PhyloMakie, :compute_image_marker_geometry)

    @testset "public value defaults and validation" begin
        annotation = ImageAnnotation(_solid_image(:red))
        @test annotation.height == 0.8f0
        @test annotation.scale == 1.0f0
        @test annotation.size_space === :data
        @test annotation.position === :center
        @test annotation.align == (0.5f0, 0.5f0)
        @test annotation.aspect === :preserve
        @test annotation.offset == Vec2f(0, 0)

        right = ImageAnnotation(_solid_image(:red); position = :right)
        above = ImageAnnotation(_solid_image(:red); position = :above)
        exact = ImageAnnotation(
            _solid_image(:red);
            size_space = :pixel,
            align = (:right, :top),
            offset = (3, -2),
        )
        @test right.align == (0.0f0, 0.5f0)
        @test above.align == (0.5f0, 0.0f0)
        @test exact.height == 32.0f0
        @test exact.align == (1.0f0, 1.0f0)
        @test exact.offset == Vec2f(3, -2)

        @test_throws ArgumentError ImageAnnotation(_solid_image(:red); height = 0)
        @test_throws ArgumentError ImageAnnotation(_solid_image(:red); scale = Inf)
        @test_throws ArgumentError ImageAnnotation(_solid_image(:red); size_space = :screen)
        @test_throws ArgumentError ImageAnnotation(_solid_image(:red); position = :near)
        @test_throws ArgumentError ImageAnnotation(_solid_image(:red); aspect = :crop)
        @test_throws ArgumentError ImageAnnotation(
            _solid_image(:red);
            align = (:middle, :center),
        )
    end

    @testset "matrix, file, URL, and per-plot cache resolution" begin
        cache = ImageAssetCache()
        numeric = load_image_source!(cache, fill(0.25, 2, 3))
        @test numeric isa Matrix{Makie.RGBA{Makie.N0f8}}
        @test size(numeric) == (2, 3)

        red_path = joinpath(IMAGE_ASSET_DIRECTORY, "red.png")
        first_file_image = load_image_source!(cache, red_path)
        second_file_image = load_image_source!(cache, red_path)
        @test first_file_image === second_file_image
        @test size(first_file_image) == (64, 64)
        @test length(cache.assets) == 1

        download_calls = Ref(0)
        function fake_download(url, path; timeout, progress)
            download_calls[] += 1
            open(path, "w") do io
                write(io, "image fixture")
            end
            progress(13, 13)
            return path
        end
        fake_loader(path) = _solid_image(:blue)
        url = "https://example.test/circle.png"
        first_url_image = load_image_source!(
            cache,
            url;
            downloader = fake_download,
            file_loader = fake_loader,
        )
        second_url_image = load_image_source!(
            cache,
            url;
            downloader = fake_download,
            file_loader = fake_loader,
        )
        @test first_url_image === second_url_image
        @test download_calls[] == 1
        @test length(cache.assets) == 2

        @test_throws ArgumentError load_image_source!(cache, "ftp://example.test/a.png")
        @test_throws ArgumentError load_image_source!(cache, "missing-image.png")
        @test_throws ArgumentError load_image_source!(cache, ["not" "pixels"])
    end

    @testset "semantic node and edge mappings" begin
        phylogeny = parsephylogeny(NewickFormat(), IMAGE_ANNOTATION_NEWICK)
        red = _solid_image(:red)
        blue = _solid_image(:blue)
        phylogeny_nodes = nodes(phylogeny)
        phylogeny_edges = edges(phylogeny)

        node_values = resolve_node_values(
            Dict("A" => red, phylogeny_nodes[2] => blue),
            phylogeny_nodes,
        )
        @test count(!isnothing, node_values) == 2
        @test node_values[findfirst(node -> node_label(node) == "A", phylogeny_nodes)] === red
        @test node_values[2] === blue

        callback_values = resolve_node_values(
            node -> node_label(node) == "C" ? ImageAnnotation(red; scale = 1.25) : nothing,
            phylogeny_nodes,
        )
        @test count(!isnothing, callback_values) == 1
        @test only(filter(!isnothing, callback_values)).scale == 1.25f0

        @test_throws ArgumentError resolve_node_values(Dict(1 => red), phylogeny_nodes)
        @test_throws ArgumentError resolve_node_values(Dict("absent" => red), phylogeny_nodes)
        stale_phylogeny = parsephylogeny(NewickFormat(), IMAGE_ANNOTATION_NEWICK)
        @test_throws ArgumentError resolve_node_values(
            Dict(nodes(stale_phylogeny)[1] => red),
            phylogeny_nodes,
        )

        duplicate_names = parsephylogeny(NewickFormat(), "((A,A),B);")
        duplicate_nodes = nodes(duplicate_names)
        duplicate_node_values = resolve_node_values(Dict("A" => red), duplicate_nodes)
        @test count(value -> value === red, duplicate_node_values) == 2
        @test all(
            duplicate_node_values[index] === red for
                index in findall(node -> node_label(node) == "A", duplicate_nodes)
        )

        regex_node_values = resolve_node_values(
            Dict(r"^[AB]$" => blue),
            duplicate_nodes,
        )
        @test count(value -> value === blue, regex_node_values) == 3
        @test_throws ArgumentError resolve_node_values(Dict(r"^missing$" => red), phylogeny_nodes)
        @test_throws ArgumentError resolve_node_values(
            Dict{Any, Any}("A" => red, r"^A$" => blue),
            phylogeny_nodes,
        )

        edge_values = resolve_edge_values(
            Dict(("Root" => "AB") => red),
            phylogeny,
            phylogeny_edges,
        )
        @test count(!isnothing, edge_values) == 1

        object_edge_values = resolve_edge_values(
            Dict(first(phylogeny_edges) => blue),
            phylogeny,
            phylogeny_edges,
        )
        @test object_edge_values[1] === blue
        @test_throws ArgumentError resolve_edge_values(
            Dict(1 => red),
            phylogeny,
            phylogeny_edges,
        )
        @test_throws ArgumentError resolve_edge_values(
            Dict(("missing" => "C") => red),
            phylogeny,
            phylogeny_edges,
        )
        @test_throws ArgumentError resolve_edge_values(
            Dict(first(edges(stale_phylogeny)) => red),
            phylogeny,
            phylogeny_edges,
        )

        duplicate_endpoints = parsephylogeny(
            NewickFormat(),
            "((A,B)group,(A,C)group)Root;",
        )
        duplicate_edges = edges(duplicate_endpoints)
        duplicate_edge_values = resolve_edge_values(
            Dict(("group" => "A") => red),
            duplicate_endpoints,
            duplicate_edges,
        )
        @test count(value -> value === red, duplicate_edge_values) == 2

        regex_edge_values = resolve_edge_values(
            Dict((r"^group$" => r"^[AB]$") => blue),
            duplicate_endpoints,
            duplicate_edges,
        )
        @test count(value -> value === blue, regex_edge_values) == 3
        @test_throws ArgumentError resolve_edge_values(
            Dict((r"^missing$" => r"^A$") => red),
            duplicate_endpoints,
            duplicate_edges,
        )
        @test_throws ArgumentError resolve_edge_values(
            Dict{Any, Any}(
                ("group" => "A") => red,
                (r"^group$" => r"^A$") => blue,
            ),
            duplicate_endpoints,
            duplicate_edges,
        )
    end

    @testset "row-relative and pixel marker geometry" begin
        data_annotation = ImageAnnotation(
            _solid_image(:red);
            height = 0.8,
            position = :right,
            offset = (3, 0),
        )
        pixel_annotation = ImageAnnotation(
            _solid_image(:blue);
            size_space = :pixel,
            height = 32,
            align = (:right, :top),
        )
        channel = build_image_channel!(
            ImageAssetCache(),
            Any[data_annotation, pixel_annotation],
            Point2f[Point2f(1, 1), Point2f(2, 2)],
        )
        upper, lower = image_probe_positions(channel)
        @test upper[1][2] - lower[1][2] ≈ 0.8f0
        @test upper[2] == lower[2] == Point2f(2, 2)

        upper_pixels = Point3f[Point3f(0, 40, 0), Point3f(0, 0, 0)]
        lower_pixels = Point3f[Point3f(0, 0, 0), Point3f(0, 0, 0)]
        marker_sizes, marker_offsets = compute_image_marker_geometry(
            channel,
            upper_pixels,
            lower_pixels,
        )
        @test marker_sizes[1] == Vec2f(80, 40)
        @test marker_offsets[1] == Vec3f(43, 0, 0)
        @test marker_sizes[2] == Vec2f(64, 32)
        @test marker_offsets[2] == Vec3f(-32, -16, 0)
    end

    @testset "native rendering and reactive cache reuse" begin
        CairoMakie.activate!()
        phylogeny = parsephylogeny(NewickFormat(), IMAGE_ANNOTATION_NEWICK)
        red_path = joinpath(IMAGE_ASSET_DIRECTORY, "red.png")
        blue_path = joinpath(IMAGE_ASSET_DIRECTORY, "blue.png")
        node_mapping = node -> node_label(node) == "A" ? red_path : nothing
        edge_mapping = (current_phylogeny, edge) -> begin
            child = child_node(current_phylogeny, edge)
            return node_label(child) == "AB" ?
                ImageAnnotation(blue_path; size_space = :pixel, height = 24) : nothing
        end
        surface = plot(
            phylogeny;
            nodeimages = node_mapping,
            edgeimages = edge_mapping,
            showtiplabel = false,
        )
        plot_handle = surface.plot
        child_ids = objectid.(plot_handle.plots)
        @test length(plot_handle.plots) == 15
        @test length(plot_handle[:node_image_markers][]) == 1
        @test length(plot_handle[:edge_image_markers][]) == 1
        @test only(plot_handle[:edge_image_markersizes][])[2] == 24.0f0
        @test length(plot_handle[:image_asset_cache][].assets) == 2

        before = _render_colorbuffer(surface.figure)
        red_pixels = count(_is_red_image_pixel, before)
        blue_pixels = count(_is_blue_image_pixel, before)
        @test red_pixels > 100
        @test blue_pixels > 25

        repeated_phylogeny = parsephylogeny(
            NewickFormat(),
            "((A,B)group,(A,C)group)Root;",
        )
        repeated_surface = plot(
            repeated_phylogeny;
            nodeimages = Dict(r"^A$" => red_path),
            edgeimages = Dict(("group" => "A") => blue_path),
            showtiplabel = false,
        )
        @test length(repeated_surface.plot[:node_image_markers][]) == 2
        @test length(repeated_surface.plot[:edge_image_markers][]) == 2

        Makie.update!(plot_handle; edgecolor = "firebrick")
        @test objectid.(plot_handle.plots) == child_ids
        @test length(plot_handle[:image_asset_cache][].assets) == 2

        replacement = parsephylogeny(NewickFormat(), "(A,(B,D)AB)Root;")
        Makie.update!(plot_handle; arg1 = replacement)
        @test objectid.(plot_handle.plots) == child_ids
        @test length(plot_handle[:node_image_markers][]) == 1
        @test length(plot_handle[:edge_image_markers][]) == 1
        @test length(plot_handle[:image_asset_cache][].assets) == 2
    end
end
