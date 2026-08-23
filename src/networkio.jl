
import PhyloNetworks: readnewick, readnexus_treeblock

"""
    readnewick(input)

Parse a Newick representation and return a `PhyloNetworks.HybridNetwork`.

PhyloMakie re-exports `PhyloNetworks.readnewick`.
"""
readnewick

"""
    readnexus_treeblock(filename, args...; kwargs...)

Read the first trees block in a NEXUS file and return
`PhyloNetworks.HybridNetwork` values.

PhyloMakie re-exports `PhyloNetworks.readnexus_treeblock`.
"""
readnexus_treeblock

export readnewick,
    readnexus_treeblock