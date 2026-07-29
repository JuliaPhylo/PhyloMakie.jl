using Aqua
using DataFrames: DataFrame
using JET
using Makie
using CairoMakie
using PhyloMakie
import PhyloNetworks # not "using" to avoid importing accessor names
using PhyloNetworks: HybridNetwork, readnewick
using Test

include("support/fixture_corpus.jl")
include("support/public_surface_cases.jl")
include("support/render_test_helpers.jl")

@testset "PhyloMakie.jl" begin
    include("test_PhyloMakie.jl")
    include("test_plot_config.jl")
    include("test_network_layout.jl")
    include("test_annotation_tables.jl")
    include("test_primitive_channels.jl")
    include("test_arrowhead_geometry.jl")
    include("test_reactive_graph.jl")
    include("test_primitive_assembly.jl")
    include("test_public_render_contracts.jl")
    include("test_recipe.jl")
    include("test_architecture_audits.jl")

    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(
            PhyloMakie;
            piracies=(treat_as_own=[Makie.plottype, PhyloNetworks.HybridNetwork],),
        )
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(PhyloMakie; target_modules = (PhyloMakie,))
    end
end
