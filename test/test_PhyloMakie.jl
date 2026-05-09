@testset "Shell owner" begin
    @test isdefined(PhyloMakie, :VERIFICATION_FOUNDATION)
    @test !isdefined(PhyloMakie, :phyloplot)
    @test !isdefined(PhyloMakie, Symbol("phyloplot!"))
    @test !isdefined(PhyloMakie, :PhyloPlot)

    module_file = joinpath(dirname(pathof(PhyloMakie)), "PhyloMakie.jl")
    module_source = read(module_file, String)

    @test occursin("include(\"verification_foundation.jl\")", module_source)
    @test !occursin("Write your package code here.", module_source)

    for forbidden in (
        "function ",
        "struct ",
        "mutable struct ",
        "abstract type ",
        "const VERIFICATION_FOUNDATION",
    )
        @test !occursin(forbidden, module_source)
    end
end
