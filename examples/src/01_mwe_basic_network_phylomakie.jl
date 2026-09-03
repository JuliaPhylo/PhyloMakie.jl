using PhyloMakie
using GLMakie

# Phylogenies can be instantiated and visualized from string representations using
# `parsephylogenies`.
# Note that this always returns a collection of phylogenies (`Vector{<:LineageNetwork}`),
# even if only one phylogeny is defined in the source.

newick_phylogenies = parsephylogenies(NewickFormat(), "(A,((B,#H1),(C,(D)#H1)));")
plot(first(newick_phylogenies))

nexus_phylogenies = parsephylogenies(
    NexusFormat(), """
    #NEXUS
    begin trees;
        tree tree1 = (A,(B,C));
        tree tree2 = (D,(E,F));
    end;
    """
)
foreach(n -> plot(n), nexus_phylogenies)

# For convenience, format-specific string macros are provided.
# These result in a single phylogeny when they are evaluated.

plot(newick"(A,((B,#H1),(C,(D)#H1)));")

plot(
    nexustreeblock"""
    #NEXUS
    begin trees;
      tree tree1 = (A,(B,C));
    end;
    """
)
