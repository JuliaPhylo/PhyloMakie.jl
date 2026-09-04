module CLI

import Makie
import ..PhyloMakie

include("types.jl")
include("arguments.jl")
include("records.jl")
include("inspection.jl")
include("viewer.jl")
include("rendering.jl")
include("commands.jl")

function (@main)(args::Vector{String})::Cint
    return Cint(run(args))
end

end
