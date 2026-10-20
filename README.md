# PhyloMakie

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPhylo.github.io/PhyloMakie.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/)
[![Build Status](https://github.com/JuliaPhylo/PhyloMakie.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaPhylo/PhyloMakie.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![coverage](https://codecov.io/gh/juliaphylo/PhyloMakie.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/juliaphylo/PhyloMakie.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

PhyloMakie.jl 
is a 
[Julia programming language](https://julialang.org/) package 
providing a [Makie](https://docs.makie.org/stable/)-based
visualization of phylogenetic trees and networks. 

## Features

### Library

- `plot(phylogeny)` and `plot!(axis, phylogeny)` follow standard Makie conventions
- `phylogenyplot` and `phylogenyplot!` as convenience aliases
- Full-tree and major-tree layout styles
- Edge-length scaling, gamma display, leaf labels, colors, and widths
- Native node and edge images from matrices, local files, or HTTP(S) URLs
- Snapshot and reactive node-position queries for independently owned overlays
- Composable with any Makie layout
- Library provides both analysis-friendly as well as developer-friendly approaches for data parsing:
    - String literals for REPL-based or instructional context: 
        - `plot(newick"(A, (B,C))")`.
        - `plot(nexustreeblock"...")`.
    - Standard string and filepath sources:
        - `phylos = parsephylogenies(NewickFormat(), "...")` 
        - `phylos = parsephylogenies(NexusFormat(), "...")`
        - `phylos = readphylogenies(NewickFormat(), "/path/to/datafile.newick")` 
        - `phylos = readphylogenies(NexusFormat(), "/path/to/datafile.nexus")`
    - Conversion to and from `PhyloNetworks.HybridNetwork` with
      `from_hybridnetwork` and `to_hybridnetwork`; see the
      [PhyloNetworks guide](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/man/phylonetworks/).


### Application

PhyloMakie.jl also provides an installable `phylomakie` app for interactive viewing, metadata inspection
  and static rendering.
After installation, open a shell and run:

```bash
phylomakie view /path/to/treefile.newick
```

to open the interactive viewer or

```bash
phylomakie --help
```

for other options.

## Installation

Install PhyloMakie from the Julia General registry:

```julia
using Pkg
Pkg.add("PhyloMakie")
```

Julia 1.12 can install the command-line app separately:

```julia
using Pkg
Pkg.Apps.add("PhyloMakie")
```

Ensure that the first Julia depot's `bin` directory, normally `~/.julia/bin`,
is on `PATH`. See the [command-line app guide](docs/src/man/command_line_app.md)
for input formats, filters, plot attributes, inspection levels, and output
modes.

## Quickstart

Install `GLMakie` with `Pkg.add("GLMakie")` for the interactive example below.
For static figures, install and load `CairoMakie` instead. These backends
provide Makie's plotting functions; PhyloMakie adds support for phylogenies.
The [getting started guide](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/man/getting_started/)
introduces the phylogeny types and the figure, axis, and plot result.

```julia
using GLMakie
using PhyloMakie

phylogeny = newick"(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"

plot(
    phylogeny;
    useedgelength = true,
    showgamma = true,
    showleaflabel = true,
    style = :fulltree,
)
```

## Documentation

- [Manual](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/)
- [Getting started, including Makie basics](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/man/getting_started/)
- [Working with PhyloNetworks](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/man/phylonetworks/)
- [Example scripts and how to run them](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/man/examples/)
- [Public API](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/lib/public/)

The [examples directory](examples) contains complete scripts for basic plotting,
reactive updates, layouts, and image annotations. Start with the
[basic network example](examples/src/01_mwe_basic_network_phylomakie.jl) or the
[offline image walkthrough](examples/src/06b_image_annotations_repl_walkthrough.jl).
