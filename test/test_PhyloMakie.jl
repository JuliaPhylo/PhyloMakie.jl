@testset "Shell owner" begin
    @test isdefined(PhyloMakie, :VERIFICATION_FOUNDATION)
    @test isdefined(PhyloMakie, :PlotGeometry)
    @test isdefined(PhyloMakie, :PlotBounds)
    @test isdefined(PhyloMakie, :PlotLayout)
    @test isdefined(PhyloMakie, :render_plot!)
    @test isdefined(PhyloMakie, :PlotRenderLayers)
    @test !isdefined(PhyloMakie, :phyloplot)
    @test !isdefined(PhyloMakie, Symbol("phyloplot!"))
    @test !isdefined(PhyloMakie, :PhyloPlot)

    module_file = joinpath(dirname(pathof(PhyloMakie)), "PhyloMakie.jl")
    module_source = read(module_file, String)
    module_expr = Meta.parse(module_source)

    @test !occursin("Write your package code here.", module_source)
    @test module_expr isa Expr
    @test module_expr.head == :module
    @test module_expr.args[1] === true
    @test module_expr.args[2] == :PhyloMakie

    module_body = module_expr.args[3]
    @test module_body isa Expr
    @test module_body.head == :block

    top_level_forms = [form for form in module_body.args if !(form isa LineNumberNode)]
    @test length(top_level_forms) == 7

    @test top_level_forms[1] isa Expr
    @test top_level_forms[1].head == :import
    @test length(top_level_forms[1].args) == 1
    @test top_level_forms[1].args[1] == Expr(:., :Makie)

    include_paths = String[]
    for include_expr in top_level_forms[2:end]
        @test include_expr isa Expr
        @test include_expr.head == :call
        @test length(include_expr.args) == 2
        @test include_expr.args[1] == :include
        push!(include_paths, include_expr.args[2])
    end
    @test include_paths == [
        "keyword_contract.jl",
        "keyword_normalization.jl",
        "layout_engine.jl",
        "annotation_data.jl",
        "render_adapter.jl",
        "verification_foundation.jl",
    ]
end
