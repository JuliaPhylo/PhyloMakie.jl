using PhyloMakie
using Test
using Aqua
using JET

@testset "PhyloMakie.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(PhyloMakie)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(PhyloMakie; target_defined_modules = true)
    end
    # Write your tests here.
end
