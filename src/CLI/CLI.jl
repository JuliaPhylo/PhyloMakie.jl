module CLI

import CSV
import DataFrames
import Makie
import ..PhyloMakie

include("types.jl")
include("arguments.jl")
include("help.jl")
include("records.jl")
include("node_label_files.jl")
include("inspection.jl")
include("viewer.jl")
include("rendering.jl")
include("commands.jl")

function (@main)(args::Vector{String})::Cint
    return Cint(run(args))
end

end
