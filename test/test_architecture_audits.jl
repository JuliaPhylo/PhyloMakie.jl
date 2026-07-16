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

@testset "Architecture source audits" begin
    legacy_test_tokens = (
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
    )

    for (path, source) in _audit_test_sources()
        for token in legacy_test_tokens
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

    graph_source = accepted_runtime["graph"]
    @test occursin(_audit_token("register", "_", "data", "_", "limits", "_", "node!"), graph_source)
    @test occursin(_audit_token("_", "compute", "_", "data", "_", "limits"), graph_source)
end
