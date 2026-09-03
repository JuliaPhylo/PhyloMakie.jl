function _native_phylogeny_snapshot(phylogeny::AbstractPhylogeny)
    return (
        root = node_id(root(phylogeny)),
        rooted = is_rooted(phylogeny),
        nodes = [
            (
                    id = node_id(current_node),
                    label = node_label(current_node),
                    hybrid = is_hybrid(current_node),
                    leaf = is_leaf(phylogeny, current_node),
                ) for current_node in nodes(phylogeny)
        ],
        edges = [
            (
                    id = edge_id(current_edge),
                    parent = node_id(parent_node(phylogeny, current_edge)),
                    child = node_id(child_node(phylogeny, current_edge)),
                    length = branch_length(current_edge),
                    gamma = inheritance_probability(current_edge),
                    hybrid = is_hybrid(current_edge),
                    major = is_major(current_edge),
                ) for current_edge in edges(phylogeny)
        ],
        incident_order = [
            edge_id.(incident_edges(phylogeny, current_node))
                for current_node in nodes(phylogeny)
        ],
        preorder = node_id.(preorder(phylogeny)),
    )
end

# A deliberately small second implementation proves that generic algorithms
# depend on the public interface instead of `LineageNetwork` fields.
struct InterfaceTestTree{TPhylogeny <: LineageNetwork} <: AbstractPhylogeneticTree
    phylogeny::TPhylogeny
end

PhyloMakie.Phylogenies.nodes(tree::InterfaceTestTree) = nodes(tree.phylogeny)
PhyloMakie.Phylogenies.edges(tree::InterfaceTestTree) = edges(tree.phylogeny)
PhyloMakie.Phylogenies.root_index(tree::InterfaceTestTree) = root_index(tree.phylogeny)
PhyloMakie.Phylogenies.is_rooted(tree::InterfaceTestTree) = is_rooted(tree.phylogeny)
PhyloMakie.Phylogenies.node_index(tree::InterfaceTestTree, current_node) =
    node_index(tree.phylogeny, current_node)
PhyloMakie.Phylogenies.edge_index(tree::InterfaceTestTree, current_edge) =
    edge_index(tree.phylogeny, current_edge)
PhyloMakie.Phylogenies.incoming_edges(tree::InterfaceTestTree, current_node) =
    incoming_edges(tree.phylogeny, current_node)
PhyloMakie.Phylogenies.outgoing_edges(tree::InterfaceTestTree, current_node) =
    outgoing_edges(tree.phylogeny, current_node)
PhyloMakie.Phylogenies.incident_edges(tree::InterfaceTestTree, current_node) =
    incident_edges(tree.phylogeny, current_node)
PhyloMakie.Phylogenies.parent_node(tree::InterfaceTestTree, current_edge) =
    parent_node(tree.phylogeny, current_edge)
PhyloMakie.Phylogenies.child_node(tree::InterfaceTestTree, current_edge) =
    child_node(tree.phylogeny, current_edge)
PhyloMakie.Phylogenies.phylogeny_data(tree::InterfaceTestTree) =
    phylogeny_data(tree.phylogeny)
PhyloMakie.Phylogenies.validate_phylogeny(tree::InterfaceTestTree) =
    validate_phylogeny(tree.phylogeny)

@testset "Native phylogeny data model" begin
    @test AbstractPhylogeneticTree <: AbstractPhylogeny
    @test AbstractPhylogeneticNetwork <: AbstractPhylogeny
    @test LineageNetwork <: AbstractPhylogeneticNetwork

    phylogeny = parsephylogeny(
        NewickFormat(),
        "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
    )
    @test phylogeny isa LineageNetwork{Nothing, Nothing, Nothing}
    @test node_count(phylogeny) == 9
    @test edge_count(phylogeny) == 9
    @test taxon_count(phylogeny) == 4
    @test tip_labels(phylogeny) == ["A", "B", "C", "D"]
    @test is_valid(phylogeny)
    @test !is_tree(phylogeny)
    @test root_index(phylogeny) == node_index(phylogeny, root(phylogeny))
    @test first(preorder(phylogeny)) === root(phylogeny)
    @test postorder(phylogeny) == reverse(preorder(phylogeny))

    hybrid_node = only(filter(is_hybrid, nodes(phylogeny)))
    @test length(parents(phylogeny, hybrid_node)) == 2
    @test length(incoming_edges(phylogeny, hybrid_node)) == 2
    @test count(is_major, incoming_edges(phylogeny, hybrid_node)) == 1
    @test major_parent_edge(phylogeny, hybrid_node) ===
        only(filter(is_major, incoming_edges(phylogeny, hybrid_node)))
    original_major_edge = major_parent_edge(phylogeny, hybrid_node)
    original_minor_edge = only(filter(!is_major, incoming_edges(phylogeny, hybrid_node)))
    @test set_major_edge!(phylogeny, original_minor_edge) === original_minor_edge
    @test major_parent_edge(phylogeny, hybrid_node) === original_minor_edge
    set_major_edge!(phylogeny, original_major_edge)

    tree = parsephylogeny(NewickFormat(), "(A:1,(B:2,C:3):4);")
    @test is_tree(tree)
    @test all(!is_hybrid(current_edge) for current_edge in edges(tree))
    @test branch_length.(edges(tree)) == [1.0, 2.0, 3.0, 4.0]

    branching_node = first(
        current_node for current_node in nodes(tree)
            if length(outgoing_edges(tree, current_node)) == 2
    )
    original_child_order = edge_id.(outgoing_edges(tree, branching_node))
    @test rotate_children!(tree, branching_node) === tree
    @test edge_id.(outgoing_edges(tree, branching_node)) == reverse(original_child_order)
    @test rotate_children!(tree, node_id(branching_node)) === tree
    @test edge_id.(outgoing_edges(tree, branching_node)) == original_child_order

    interface_tree = InterfaceTestTree(tree)
    @test interface_tree isa AbstractPhylogeny
    @test is_tree(interface_tree)
    @test tip_labels(interface_tree) == tip_labels(tree)
    @test node_id.(preorder(interface_tree)) == node_id.(preorder(tree))
    @test Makie.plottype(interface_tree) === PhyloPlot

    payload_nodes = [
        LineageNode(101, "ancestor"; data = :ancestral),
        LineageNode(102, "tip"; data = :sampled),
    ]
    payload_edges = [
        LineageEdge(201, 1, 2; length = 0.5, data = :observed),
    ]
    payload_phylogeny = LineageNetwork(
        payload_nodes,
        payload_edges;
        root = 1,
        data = (source = "manual",),
    )
    @test node(payload_phylogeny, 102, Val(:id)) === payload_nodes[2]
    @test edge(payload_phylogeny, 201, Val(:id)) === payload_edges[1]
    @test node_data(payload_nodes[1]) === :ancestral
    @test edge_data(payload_edges[1]) === :observed
    @test phylogeny_data(payload_phylogeny) == (source = "manual",)
    @test children(payload_phylogeny, payload_nodes[1]) == [payload_nodes[2]]
    @test parents(payload_phylogeny, payload_nodes[2]) == [payload_nodes[1]]
    @test collect(incident_edges(payload_phylogeny, payload_nodes[1])) == payload_edges

    empty_phylogeny = LineageNetwork()
    ancestor = add_node!(empty_phylogeny, "ancestor")
    descendant = add_node!(empty_phylogeny, "descendant")
    lineage_edge = add_edge!(
        empty_phylogeny,
        ancestor,
        descendant;
        length = 2.5,
        gamma = 1.0,
    )
    @test validate_phylogeny(empty_phylogeny) === nothing
    @test root(empty_phylogeny) === ancestor
    @test child_node(empty_phylogeny, lineage_edge) === descendant
    @test parent_node(empty_phylogeny, lineage_edge) === ancestor
    @test tip_labels(empty_phylogeny) == ["descendant"]

    rename_node!(descendant, "tip")
    set_branch_length!(lineage_edge, missing)
    set_inheritance_probability!(lineage_edge, 1)
    @test node_label(descendant) == "tip"
    @test ismissing(branch_length(lineage_edge))
    @test inheritance_probability(lineage_edge) == 1.0
    @test_throws ArgumentError set_inheritance_probability!(lineage_edge, 1.1)

    copied = deepcopy(empty_phylogeny)
    @test_throws ArgumentError node_index(empty_phylogeny, first(nodes(copied)))
    @test_throws ArgumentError edge_index(empty_phylogeny, first(edges(copied)))

    @test delete_edge!(empty_phylogeny, lineage_edge; validate = false) === empty_phylogeny
    @test delete_node!(empty_phylogeny, descendant) === empty_phylogeny
    @test node_count(empty_phylogeny) == 1
    @test edge_count(empty_phylogeny) == 0
end
