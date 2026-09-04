const PhyloMakieCLI = PhyloMakie.CLI

function cli_fixture_records()::Vector{PhyloMakieCLI.SourceRecord}
    network = FIXTURE_CORPUS.accepted_design_scenarios.single_reticulation_gamma.newick
    tree = FIXTURE_CORPUS.accepted_design_scenarios.simple_tree_no_hybrid.newick
    input = PhyloMakieCLI.InputOptions(
        ["-"],
        :newick,
        PhyloMakieCLI.SelectionOptions(nothing, nothing, nothing, 0),
    )
    return PhyloMakieCLI.load_records(
        input;
        stdin_io = IOBuffer("$(network) $(tree)"),
    ).records
end

@testset "Command-line app" begin
    include("CLI/test_types.jl")
    include("CLI/test_arguments.jl")
    include("CLI/test_records.jl")
    include("CLI/test_inspection.jl")
    include("CLI/test_viewer.jl")
    include("CLI/test_rendering.jl")
    include("CLI/test_commands.jl")
end
