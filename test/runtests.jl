using Aqua
using DataFrames: DataFrame
using JET
using PhyloMakie
using Test

include("support/fixture_corpus.jl")
include("support/keyword_surface_cases.jl")
include("support/render_test_helpers.jl")

@testset "PhyloMakie.jl" begin
    include("test_PhyloMakie.jl")
    include("test_keyword_contract.jl")
    include("test_keyword_normalization.jl")
    include("test_layout_engine.jl")
    include("test_annotation_data.jl")
    include("test_render_adapter.jl")
    include("test_verification_foundation.jl")

    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(PhyloMakie)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(PhyloMakie; target_modules = (PhyloMakie,))
    end
end
