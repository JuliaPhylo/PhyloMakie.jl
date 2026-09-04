using Aqua
using DataFrames: DataFrame
using JET
using Makie
using CairoMakie
using GLMakie
using PhyloMakie
import PhyloNetworks # not "using" to avoid importing accessor names
using Test
using TOML: parsefile

include("support/fixture_corpus.jl")
include("support/public_surface_cases.jl")
include("support/render_test_helpers.jl")

@testset "PhyloMakie.jl" begin
    include("test_PhyloMakie.jl")
    include("test_phylogenies.jl")
    include("test_phylonetworks_adapter.jl")
    include("test_phylogenyio.jl")
    include("test_plot_config.jl")
    include("test_phylogeny_layout.jl")
    include("test_annotation_tables.jl")
    include("test_image_annotations.jl")
    include("test_primitive_channels.jl")
    include("test_arrowhead_geometry.jl")
    include("test_reactive_graph.jl")
    include("test_primitive_assembly.jl")
    include("test_public_render_contracts.jl")
    include("test_recipe.jl")
    include("test_coordinate_queries.jl")
    include("test_cli.jl")
    include("test_architecture_audits.jl")

    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(
            PhyloMakie;
            piracies = false,
            # App-only renderers are loaded when their subcommands run, not with the library.
            stale_deps = (; ignore = [:CairoMakie, :GLMakie]),
            # Fresh app environments may still be precompiling both renderers after load.
            persistent_tasks = (; tmax = 300),
        )
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(PhyloMakie; target_modules = (PhyloMakie,))
    end
end
