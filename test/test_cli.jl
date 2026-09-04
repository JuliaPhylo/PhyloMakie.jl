const PhyloMakieCLI = PhyloMakie.CLI

@testset "Command-line app" begin
    include("CLI/test_types.jl")
    include("CLI/test_arguments.jl")
    include("CLI/test_records.jl")
    include("CLI/test_inspection.jl")
    include("CLI/test_viewer.jl")
    include("CLI/test_rendering.jl")
    include("CLI/test_commands.jl")
end
