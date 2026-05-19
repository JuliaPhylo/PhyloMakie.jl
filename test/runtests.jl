using Aqua
using DataFrames: DataFrame
using JET
using Makie
using PhyloMakie
using PhyloNetworks
using Test

include("support/fixture_corpus.jl")
include("support/public_surface_cases.jl")
include("support/render_test_helpers.jl")

@testset "PhyloMakie.jl" begin
    include("test_PhyloMakie.jl")
    include("test_attribute_schema.jl")
    include("test_layout_engine.jl")
    include("test_plot_layout.jl")
    include("test_render_adapter.jl")
    include("test_recipe.jl")

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
