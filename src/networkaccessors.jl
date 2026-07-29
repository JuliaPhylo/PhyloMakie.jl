# accessors for PhyloNetworks networks, nodes & edges

numtaxa(net::PhyloNetworks.HybridNetwork) = net.numtaxa
numnodes(net::PhyloNetworks.HybridNetwork) = net.numnodes
numedges(net::PhyloNetworks.HybridNetwork) = net.numedges
getroot(net::PhyloNetworks.HybridNetwork) = PhyloNetworks.getroot(net)

# iterable vectors, not lazy iterators
getedges(net::PhyloNetworks.HybridNetwork) = net.edge
getnodes(net::PhyloNetworks.HybridNetwork) = net.node
getnodes_preorder(net::PhyloNetworks.HybridNetwork) = net.vec_node
getedge(net::PhyloNetworks.HybridNetwork, i) = net.edge[i]
getnode(net::PhyloNetworks.HybridNetwork, i) = net.node[i]
getnode_preorder(net::PhyloNetworks.HybridNetwork, i) = net.vec_node[i]
# edge and node indices, in getedges() and getnodes() iterables
rootindex(net::PhyloNetworks.HybridNetwork) = net.rooti
function _node_index(
    net::PhyloNetworks.HybridNetwork,
    node::PhyloNetworks.Node,
)::Int
    node_index = findfirst(x -> x === node, net.node)
    isnothing(node_index) && error("node $(node.number) is not part of the network")
    return node_index
end
function _edge_index(
    net::PhyloNetworks.HybridNetwork,
    edge::PhyloNetworks.Edge,
)::Int
    edge_index = findfirst(x -> x === edge, net.edge)
    isnothing(edge_index) && error("edge $(edge.number) is not part of the network")
    return edge_index
end

# get from a node/edge to its neighbors
getchild(e::PhyloNetworks.Edge) = PhyloNetworks.getchild(e)
getparent(e::PhyloNetworks.Edge) = PhyloNetworks.getparent(e)
getmajorparentedge(n::PhyloNetworks.Node) = PhyloNetworks.getparentedge(n)
ischildof(n::PhyloNetworks.Node, e::PhyloNetworks.Edge) = PhyloNetworks.ischildof(n,e)
isparentof(n::PhyloNetworks.Node, e::PhyloNetworks.Edge) = PhyloNetworks.isparentof(n,e)

# edge and node attributes
isleaf(n::PhyloNetworks.Node) = n.leaf
ishybrid(n::PhyloNetworks.Node) = n.hybrid
ishybrid(e::PhyloNetworks.Edge) = e.hybrid
ismajor(e::PhyloNetworks.Edge) = e.ismajor
elength(e::PhyloNetworks.Edge) = (e.length == -1 ? missing : e.length)
# γ: inheritance probability, admixture weight
egamma(e::PhyloNetworks.Edge) = (e.gamma == -1 ? missing : e.gamma)
uniqueid(n::PhyloNetworks.Node) = n.number
uniqueid(e::PhyloNetworks.Edge) = e.number
namelabel(n::PhyloNetworks.Node) = n.name

# last step to abstract out:
# lazy iterator over a node's children edges, used in _resolve_edge_lengths()
