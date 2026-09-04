@testset "App module and value types" begin
    @test isdefined(PhyloMakie, :CLI)
    @test isdefined(PhyloMakieCLI, :main)
    @test !isdefined(PhyloMakieCLI, :GLMakie)
    @test !isdefined(PhyloMakieCLI, :CairoMakie)

    project = parsefile(joinpath(@__DIR__, "..", "..", "Project.toml"))
    @test project["apps"]["phylomakie"]["submodule"] == "CLI"
end
