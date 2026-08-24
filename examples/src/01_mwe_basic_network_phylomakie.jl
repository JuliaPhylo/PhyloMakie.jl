using PhyloMakie
using CairoMakie

# Parse literal content. Both format tags return a vector of networks.
newick_networks = parsenetwork(
    NewickFormat(),
    "(A,((B,#H1),(C,(D)#H1))); (E,(F,G));",
)

nexus_networks = parsenetwork(
    NexusFormat(),
    """
    #NEXUS
    begin trees;
      tree tree1 = (A,(B,C));
      tree tree2 = (D,(E,F));
    end;
    """,
)

# Read format-specific content from a file path.
file_networks = mktemp() do path, io
    write(io, "(A,(B,C)); (D,(E,F));")
    close(io)
    readnetwork(NewickFormat(), path)
end

# Parse exactly one network with a format-specific string literal.
newick_network = newick"(A,((B,#H1),(C,(D)#H1)));"

nexus_network = nexus"""
#NEXUS
begin trees;
  tree tree1 = (A,(B,C));
end;
"""

plot(newick_network)
