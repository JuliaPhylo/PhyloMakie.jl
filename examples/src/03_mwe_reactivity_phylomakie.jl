using GLMakie
using PhyloMakie
import PhyloNetworks

net = only(parsenetwork(NewickFormat(), "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"))

surface = plot(
    net;
    useedgelength = true,
    showtiplabel = true,
    showgamma = true,
)
plot_handle = surface.plot

update!(
    plot_handle;
    edgecolor = "firebrick",
    edgewidth = 2.0,
    # xlim = (0.0, 1.0),
    # ylim = (0.0, 4.0),
)

PhyloNetworks.rootonedge!(net, 4) # nothing happens
PhyloNetworks.preorder!(net)

surface.figure

PhyloNetworks.writenewick(plot_handle.attributes.inputs[:arg1].value) # was modified
# "((A:0.2,(B:0.1)#H1:0.1::0.9):0.05,((C:0.11,#H1:0.01::0.1):0.19,D:0.5):0.05);"
update!(plot_handle) # but the viz didn't change
PhyloNetworks.writenewick(plot_handle.attributes.outputs[:plot_network].value[].net) # did *not* change
# "(((A:0.2,(B:0.1)#H1:0.1::0.9):0.1,(C:0.11,#H1:0.01::0.1):0.19):0.1,D:0.4);"
# yet its parent has changed:
PhyloNetworks.writenewick(plot_handle.attributes.outputs[:plot_network].parent.inputs[1].value[])
# "((A:0.2,(B:0.1)#H1:0.1::0.9):0.05,((C:0.11,#H1:0.01::0.1):0.19,D:0.5):0.05);"
# and is marked as not dirty:
plot_handle.attributes.outputs[:plot_network].parent.inputs_dirty[1] # false

xlims!(surface.axis, 0.9, 2) # works
update!(plot_handle; xlim=(0.9, 1.6)) # changes nothing: does not work
surface.figure # even after re-plotting

xlims!(surface.axis, 2, 0) # beautiful: flips the network, time from right to left
update!(plot_handle, tipoffset = 0.05)
