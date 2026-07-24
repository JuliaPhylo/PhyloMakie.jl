function _audit_token(parts::AbstractString...)
    return join(parts)
end

function _audit_source(relative_path::AbstractString)
    return read(joinpath(@__DIR__, "..", relative_path), String)
end

function _audit_test_sources()
    sources = Pair{String, String}[]
    for (root, _, files) in walkdir(@__DIR__)
        for file in files
            endswith(file, ".jl") || continue
            path = joinpath(root, file)
            push!(sources, path => read(path, String))
        end
    end
    return sources
end

function _audit_package_sources()
    repo_root = joinpath(@__DIR__, "..")
    sources = Pair{String, String}[]
    for relative_root in ("src",)
        root = joinpath(repo_root, relative_root)
        for (walk_root, _, files) in walkdir(root)
            for file in files
                endswith(file, ".jl") || continue
                path = joinpath(walk_root, file)
                relative_path = relpath(path, repo_root)
                push!(sources, relative_path => read(path, String))
            end
        end
    end
    return sources
end

function _audit_docs_sources()
    repo_root = joinpath(@__DIR__, "..")
    sources = Pair{String, String}[]
    for relative_root in ("docs/src", "README.md", "examples")
        root = joinpath(repo_root, relative_root)
        if isfile(root)
            push!(sources, relative_root => read(root, String))
            continue
        end
        for (walk_root, _, files) in walkdir(root)
            for file in files
                if !(endswith(file, ".md") || endswith(file, ".jl"))
                    continue
                end
                path = joinpath(walk_root, file)
                relative_path = relpath(path, repo_root)
                push!(sources, relative_path => read(path, String))
            end
        end
    end
    return sources
end

@testset "Architecture docs audits" begin
    docs_sources = _audit_docs_sources()
    legacy_docs_tokens = (
        _audit_token("render", "_", "plot", "!"),
        _audit_token("Plot", "Render", "Layers"),
        _audit_token("Segment", "Render", "Layer"),
        _audit_token("Arrow", "Tip", "Render", "Layer"),
        _audit_token("Text", "Render", "Layer"),
        _audit_token("Phylo", "Plot", "Attributes"),
        _audit_token("resolve", "_", "phylo", "_", "plot", "_", "attributes"),
        _audit_token("with", "_", "phylo", "_", "plot", "_", "limits"),
        _audit_token("Plot", "Bounds"),
        _audit_token("Plot", "Annotation", "Data"),
        _audit_token("Plot", "Layout"),
        _audit_token("prepare", "_", "plot", "_", "layout"),
        _audit_token(".", "layers"),
        _audit_token("getfield", "(", "Phylo", "Makie"),
        _audit_token("arrows", "2d", "!"),
    )

    for (path, source) in docs_sources
        for token in legacy_docs_tokens
            @test !occursin(token, source)
        end
    end

    public_api_source = _audit_source(joinpath("docs", "src", "public-api.md"))
    for token in (
            "SUPPORTED_PHYLOPLOT_ATTRIBUTES",
            "Makie.update!",
            "arg1",
            "showtiplabel",
            "shownodelabel",
            "showgamma",
            "xlim",
            "ylim",
        )
        @test occursin(token, public_api_source)
    end
    @test occursin("private `HybridNetwork` copy", public_api_source)

    render_verification_source =
        _audit_source(joinpath("docs", "src", "render-verification.md"))
    for token in (
            "Makie.plot!",
            "plot[:plot_config][]",
            "plot[:plot_network][]",
            "plot[:layout_computation][]",
            "plot[:primitive_channels][]",
            "Makie.data_limits",
        )
        @test occursin(token, render_verification_source)
    end

    extending_source = _audit_source(joinpath("docs", "src", "extending-plots.md"))
    for token in (
            "resolve_plot_config",
            "prepare_plot_network",
            "compute_network_geometry",
            "compute_layout",
            "stable public layout-query surface",
            "public attribute surface",
        )
        @test occursin(token, extending_source)
    end
end

@testset "Architecture source audits" begin
    legacy_package_tokens = (
        _audit_token("render", "_", "plot", "!"),
        _audit_token("Plot", "Render", "Layers"),
        _audit_token("Segment", "Render", "Layer"),
        _audit_token("Arrow", "Tip", "Render", "Layer"),
        _audit_token("Text", "Render", "Layer"),
        _audit_token("_", "render", "_", "arrow", "_", "tip", "_", "layer", "!"),
        _audit_token("Phylo", "Plot", "Attributes"),
        _audit_token("resolve", "_", "phylo", "_", "plot", "_", "attributes"),
        _audit_token("with", "_", "phylo", "_", "plot", "_", "limits"),
        _audit_token("Plot", "Geometry"),
        _audit_token("layout", "_", "plot", "_", "geometry"),
        _audit_token("Plot", "Bounds"),
        _audit_token("Plot", "Annotation", "Data"),
        _audit_token("Plot", "Layout"),
        _audit_token("prepare", "_", "plot", "_", "layout"),
        _audit_token("arrows", "2d", "!"),
    )

    for (path, source) in _audit_package_sources()
        for token in legacy_package_tokens
            @test !occursin(token, source)
        end
    end

    for (path, source) in _audit_test_sources()
        for token in legacy_package_tokens
            @test !occursin(token, source)
        end
    end

    public_input_names = (
        "edgecolor",
        "edgewidth",
        "style",
        "net",
        "arg1",
        "showtiplabel",
        "shownodelabel",
        "showgamma",
        "xlim",
        "ylim",
    )
    direct_input_assignment = Regex(
        "\\[:($(join(public_input_names, "|")))\\]\\[\\]\\s*=",
    )
    pointer_scope_tokens = (
        _audit_token("hov", "er"),
        _audit_token("cli", "ck"),
        _audit_token("dr", "ag"),
        _audit_token("select", "ion"),
        _audit_token("Data", "Inspector"),
    )

    for (_, source) in _audit_test_sources()
        @test !occursin(direct_input_assignment, source)
        for token in pointer_scope_tokens
            @test !occursin(token, source)
        end
    end

    accepted_runtime = Dict(
        "recipe" => _audit_source(joinpath("src", "recipe.jl")),
        "graph" => _audit_source(joinpath("src", "reactive_graph.jl")),
        "channels" => _audit_source(joinpath("src", "primitive_channels.jl")),
        "assembly" => _audit_source(joinpath("src", "primitive_assembly.jl")),
    )

    forbidden_runtime_tokens = (
        _audit_token("Makie", ".", "onany"),
        _audit_token("empty", "!(plot.plots)"),
        _audit_token("is", "_", "rebuilding"),
        _audit_token("render", "_", "plot", "!"),
        _audit_token("Plot", "Render", "Layers"),
        _audit_token("arrows", "2d", "!"),
        _audit_token("_apply", "_", "plot", "_", "limits", "!"),
        _audit_token("x", "lims", "!"),
        _audit_token("y", "lims", "!"),
    )

    for (_, source) in accepted_runtime
        for token in forbidden_runtime_tokens
            @test !occursin(token, source)
        end
        for token in pointer_scope_tokens
            @test !occursin(token, source)
        end
    end

    assembly_source = accepted_runtime["assembly"]
    @test occursin(_audit_token("plot[outputs.points]"), assembly_source)
    @test occursin(_audit_token("plot[outputs.meshes]"), assembly_source)
    @test occursin(_audit_token("plot[outputs.strings]"), assembly_source)
    @test !occursin(_audit_token("plot[outputs.points][]"), assembly_source)
    @test !occursin(_audit_token("plot[outputs.meshes][]"), assembly_source)
    @test !occursin(_audit_token("plot[outputs.strings][]"), assembly_source)
    @test occursin("space = :pixel", assembly_source)
    @test occursin("transformation = :nothing", assembly_source)
    @test occursin("xautolimits = false", assembly_source)
    @test occursin("yautolimits = false", assembly_source)

    graph_source = accepted_runtime["graph"]
    @test occursin(_audit_token("register", "_", "data", "_", "limits", "_", "node!"), graph_source)
    @test occursin(_audit_token("_", "compute", "_", "data", "_", "limits"), graph_source)
    @test occursin("function Makie.boundingbox", graph_source)
    @test occursin("register_projected_positions!", graph_source)
    @test occursin("compute_arrowhead_pixel_meshes", graph_source)
    @test occursin(":minor_arrowhead_pixel_meshes", graph_source)

    channels_source = accepted_runtime["channels"]
    @test occursin("struct ArrowheadSpecChannel", channels_source)
    @test !occursin("struct ArrowheadChannel", channels_source)
    @test !occursin("meshes::", channels_source)
    @test !occursin(_audit_token("_", "arrowhead", "_", "polygon"), channels_source)
    @test !occursin(_audit_token("data", "_", "length"), channels_source)
    @test !occursin(Regex("/\\s*(?:\\([^\\)]*)?DEFAULT_ARROW_PIXEL_SCALE"), channels_source)
end
