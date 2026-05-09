@testset "Shell owner" begin
    @test isdefined(PhyloMakie, :VERIFICATION_FOUNDATION)
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
    @test length(top_level_forms) == 1

    include_expr = only(top_level_forms)
    @test include_expr isa Expr
    @test include_expr.head == :call
    @test length(include_expr.args) == 2
    @test include_expr.args[1] == :include
    @test include_expr.args[2] == "verification_foundation.jl"
end
