using PhyloMakie
using GLMakie

# Networks can be instantiated and visualized from string representations using
# `parsenetwork`.
# Note that this always returns a collection of networks (`Vector{PhyloNetwork}`),
# even if only one network is defined in the source.

newick_nets = parsenetwork(NewickFormat(), "(A,((B,#H1),(C,(D)#H1)));")
plot(only(newick_nets))

nexus_nets = parsenetwork(
    NexusFormat(), """
    #NEXUS
    begin trees;
        tree tree1 = (A,(B,C));
        tree tree2 = (D,(E,F));
    end;
    """
)
foreach(n -> plot(n), nexus_nets)

# For convenience, format-specific string macros are provided.
# These result in a single network when they are evaluated.

plot(newick"(A,((B,#H1),(C,(D)#H1)));")

plot(
    nexus"""
    #NEXUS
    begin trees;
      tree tree1 = (A,(B,C));
    end;
    """
)
