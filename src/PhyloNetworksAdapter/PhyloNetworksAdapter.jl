module PhyloNetworksAdapter

import PhyloNetworks
using ..Phylogenies

include("hybridnetwork_accessors.jl")
include("conversion.jl")

export from_hybridnetwork, to_hybridnetwork

end
