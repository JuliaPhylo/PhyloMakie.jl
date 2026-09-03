function _hybridnetwork_snapshot(hybrid_phylogeny::PhyloNetworks.HybridNetwork)
    return (
        root_index = hybrid_phylogeny.rooti,
        rooted = hybrid_phylogeny.isrooted,
        node_ids = [current_node.number for current_node in hybrid_phylogeny.node],
        node_labels = String[current_node.name for current_node in hybrid_phylogeny.node],
        incident_order = [
            [current_edge.number for current_edge in current_node.edge]
                for current_node in hybrid_phylogeny.node
        ],
        edges = [
            (
                    id = current_edge.number,
                    parent = PhyloNetworks.getparent(current_edge).number,
                    child = PhyloNetworks.getchild(current_edge).number,
                    length = current_edge.length,
                    gamma = current_edge.gamma,
                    hybrid = current_edge.hybrid,
                    major = current_edge.ismajor,
                ) for current_edge in hybrid_phylogeny.edge
        ],
    )
end

@testset "PhyloNetworks adapter" begin
    newicks = (
        "(A:1,(B:2,C:3):4);",
        "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
        "((((B)#H1:::0.2)#H2,((D,C,#H2)S1,(#H1,A)S2)S3)S4);",
    )

    for newick in newicks
        hybrid_phylogeny = PhyloNetworks.readnewick(newick)
        before = _hybridnetwork_snapshot(hybrid_phylogeny)
        phylogeny = from_hybridnetwork(hybrid_phylogeny)
        @test _hybridnetwork_snapshot(hybrid_phylogeny) == before
        @test convert(LineageNetwork, hybrid_phylogeny) isa LineageNetwork

        roundtripped_hybrid = to_hybridnetwork(phylogeny)
        roundtripped_phylogeny = from_hybridnetwork(roundtripped_hybrid)
        @test isequal(
            _native_phylogeny_snapshot(roundtripped_phylogeny),
            _native_phylogeny_snapshot(phylogeny),
        )
        @test convert(PhyloNetworks.HybridNetwork, phylogeny) isa
            PhyloNetworks.HybridNetwork
    end

    semidirected = PhyloNetworks.readnewick("(A,(B,C));")
    semidirected.isrooted = false
    converted = from_hybridnetwork(semidirected)
    @test !is_rooted(converted)
    @test !to_hybridnetwork(converted).isrooted

    interface_tree = InterfaceTestTree(
        parsephylogeny(NewickFormat(), "(A:1,(B:2,C:3):4);"),
    )
    converted_interface_tree = from_hybridnetwork(to_hybridnetwork(interface_tree))
    @test node_id.(preorder(converted_interface_tree)) ==
        node_id.(preorder(interface_tree))
end
