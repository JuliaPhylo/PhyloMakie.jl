# Example scripts

The repository's
[examples directory](https://github.com/JuliaPhylo/PhyloMakie.jl/tree/main/examples)
contains complete Julia scripts for the topics covered in the manual. Follow
[Getting started](@ref) for an introduction to the phylogeny types and Makie
objects, then choose a script below to explore or adapt.

## Run a script

Clone or download the
[PhyloMakie repository](https://github.com/JuliaPhylo/PhyloMakie.jl), then open
a terminal in its root directory. Instantiate the examples environment once:

```sh
julia --project=examples -e 'using Pkg; Pkg.instantiate()'
```

This environment uses the local PhyloMakie checkout and installs the example
dependencies, including PhyloPicMakie for the optional PhyloPic examples.
Package installation requires internet access.

Start Julia in that environment:

```sh
julia --project=examples
```

For example, run the node and edge image script, which uses image files included
in the repository:

```julia
figure = include("examples/src/07_node_edge_images.jl")
display(figure)
save("node_edge_images.png", figure)
```

That script loads CairoMakie, which supplies `save`. CairoMakie scripts can
render files without a desktop display. GLMakie scripts open interactive
windows and need a graphical display with OpenGL support. Run a walkthrough
one section at a time in the Julia REPL or editor to see intermediate figures
and updates; `include` executes the entire file and returns its last value.

## Basic plotting and updates

| Script | What it demonstrates | Related manual section |
| --- | --- | --- |
| [01_mwe_basic_network_phylomakie.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/01_mwe_basic_network_phylomakie.jl) | Newick and NEXUS strings, multiple phylogenies, and string literals using GLMakie. | [Getting started](@ref) |
| [02_mwe_edge_numbers_phylomakie.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/02_mwe_edge_numbers_phylomakie.jl) | Edge numbers and colors in a CairoMakie figure layout. | [Adding labels](@ref) |
| [03_mwe_reactivity_phylomakie.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/03_mwe_reactivity_phylomakie.jl) | Attribute updates, replacement phylogenies, and a point overlay that follows layout changes using GLMakie. | [Adding other annotations using Makie](@ref) |
| [04_maxwe_reactivity_phylomakie.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/04_maxwe_reactivity_phylomakie.jl) | Multiple panels comparing style, color, label, and limit updates using GLMakie. | [Better edges](@ref) |

## Images and other annotations

The first 2 scripts below use local assets and run without internet access after
package installation. The PhyloPic scripts fetch images or taxon information
over the internet. Scripts 06 and 09 also use PhyloPicMakie; script 08 supplies
image URLs directly to PhyloMakie.

| Script | What it demonstrates | Related manual section |
| --- | --- | --- |
| [06b_image_annotations_repl_walkthrough.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/06b_image_annotations_repl_walkthrough.jl) | Exact labels, repeated labels, and regular expressions for node and edge images using CairoMakie. | [Adding images to nodes and edges](@ref) |
| [07_node_edge_images.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/07_node_edge_images.jl) | Functions that select local images for nodes and edges using CairoMakie. | [Adding images to nodes and edges](@ref) |
| [08_phylopic_image_placement_recipe.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/08_phylopic_image_placement_recipe.jl) | Image placement around named leaves using CairoMakie and PhyloPic URLs. | [Adding images to nodes and edges](@ref) |
| [09_phylopic_native_images.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/09_phylopic_native_images.jl) | Taxon lookup with PhyloPicMakie, followed by PhyloMakie node images using CairoMakie. | [Adding images to nodes and edges](@ref) |
| [06_phylopic_composition.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/06_phylopic_composition.jl) | A separate PhyloPicMakie silhouette overlay placed at leaf coordinates using GLMakie. | [Adding other annotations using Makie](@ref) |

## Command-line viewer

[05_interactive_ex1.jl](https://github.com/JuliaPhylo/PhyloMakie.jl/blob/main/examples/src/05_interactive_ex1.jl)
launches the interactive viewer described in the [Command-line app](@ref)
guide. Run it as a separate process, with a path to a Newick or NEXUS file:

```sh
julia --project=examples examples/src/05_interactive_ex1.jl /path/to/tree.newick
```

This script calls `exit` when the viewer finishes, so run it from a terminal
instead of including it in a working REPL session. It requires a graphical
display.
