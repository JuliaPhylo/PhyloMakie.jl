@testset "App module and value types" begin
    @test isdefined(PhyloMakie, :CLI)
    @test isdefined(PhyloMakieCLI, :main)
    @test !isdefined(PhyloMakieCLI, :GLMakie)
    @test !isdefined(PhyloMakieCLI, :CairoMakie)

    project_text = read(joinpath(@__DIR__, "..", "..", "Project.toml"), String)
    @test occursin("[apps]", project_text)
    @test occursin("phylomakie = {submodule = \"CLI\"}", project_text)
end
