## PhyloMakie.jl

A ground-up reimplementation of "PhyloPlots.jl" in a full native Julia stack, using Makie for its visualization framework.

---

PhyloPlots.jl currently calls base R. 
This needs to be swapped out for Makie. 
Its sophisticated layout and other busniess layer logic adapted to plot onto Makie surfaces with Makie abstractions rather than R.
The internal API and architecture can be designed from the ground up for idiomatic Makie conventions or program design to support the new build, but full visualization capacity and layout objectives and correctness of the key user surface plotting function in PhyloPlots, `PhyloPlots.plot`, should be replicated completely by the key visualization function/recipes of PhyloMakie.

The main function from PhyloMakie that we are redelivering here is: `PhyloPlots.plot(::PhyloNetworks.HybridNetwork; ...)`.
(The remainder of the public user surface consists of R interoperability functions `PhyloPlots.sexp` and `PhyloPlots.rexport`, and as *NO* R interoperability support will be required or retained, these can be ignored as out of scope for this production run).

The function PhyloMakie will provide as the Makie-based counter-part to `PhyloPlots.plot(::PhyloNetworks.HybridNetwork; ...)` is `phyloplot`, which takes one positional argument of type `PhyloNetworks.HybridNetwork` and returns the result as a `Makie.FigureAxisPlot` object.

```julia
PhyloMakie.phyloplot(::PhyloNetworks.HybridNetwork; ...)::Makie.FigureAxisPlot
```

A user-facing MWE:

```julia
using PhyloNetworks: readnewick
using CairoMakie                  # or GLMakie / WGLMakie
using PhyloMakie: phyloplot

# 4-taxon reticulate network with one hybrid node (H1).
# Extended Newick field order: branch-length :: gamma :: is-major-edge
net  = readnewick("(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);")

# A second reticulate network for the composable example below.
net2 = readnewick("(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);")

# --- standalone figure (returns Figure, Axis, plot object) ---
fig, ax, plt = phyloplot(net)

# --- same thing via Makie.plottype dispatch ---
fig, ax, plt = plot(net)

# --- composable: two networks side by side in one Figure ---
fig = Figure()
phyloplot!(Axis(fig[1, 1], title = "net"),  net)
phyloplot!(Axis(fig[1, 2], title = "net2"), net2)
fig
```

Sketch of Makie scaffold:


```julia
@recipe(PhyloPlot, net) do scene
    Attributes(useedgelength=false, showtiplabel=true, style=:fulltree, ...)
end

function Makie.plot!(p::PhyloPlot)
    net = p[:net][]
    #....
end

Makie.plottype(::HybridNetwork) = PhyloPlot

```