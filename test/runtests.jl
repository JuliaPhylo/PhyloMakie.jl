using Aqua
using JET
using PhyloMakie
using Test

include("support/fixture_corpus.jl")

@testset "PhyloMakie.jl" begin
    include("test_PhyloMakie.jl")
    include("test_verification_foundation.jl")

    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(PhyloMakie)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(PhyloMakie; target_defined_modules = true)
    end
end
