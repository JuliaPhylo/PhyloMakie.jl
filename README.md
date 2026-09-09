# PhyloMakie

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaPhylo.github.io/PhyloMakie.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaPhylo.github.io/PhyloMakie.jl/dev/)
[![Build Status](https://github.com/JuliaPhylo/PhyloMakie.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaPhylo/PhyloMakie.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

PhyloMakie.jl 
is a 
[Julia programming language](https://julialang.org/) package 
providing a [Makie](https://docs.makie.org/stable/)-based
visualization of phylogenetic trees and networks. 

## Features

### Library

- `plot(phylogeny)` and `plot!(axis, phylogeny)` follow standard Makie conventions
- `phyloplot` and `phyloplot!` as convenience aliases
- Full-tree and major-tree layout styles
- Edge-length scaling, gamma display, tip labels, colors, and widths
- Native node and edge images from matrices, local files, or HTTP(S) URLs
- Snapshot and reactive node-position queries for independently owned overlays
- Composable with any Makie layout
- Library provides both analysis-friendly as well as developer-friendly approaches for data parsing:
    - String literals for REPL-based or instructional context: 
        - `plot(newick"(A, (B,C))")`.
        - `plot(nexustreeblock"...")`.
    - Standard string and filepath sources:
        - `phylos = parsephylogenies(NewickFormat(), "...")` 
        - `phylos = parsephylogenies(NexusTreeFormat(), "...")` 
        - `phylos = readphylogenies(NewickFormat(), "/path/to/datafile.newick")` 
        - `phylos = readphylogenies(NexusTreeFormat(), "/path/to/datafile.nexus")` 
    - Native interoperability with:
        - `PhyloNetworks.HybridNetwork`.


### Application

PhyloMakie.jl also provides an installable `phylomakie` app for interactive viewing, metadata inspection
  and static rendering.
After installation, open a shell and run:

```bash
phylomakie view /path/to/treefile.newick
```

to open the interactive viewer or

```bash
phylomake --help
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

```julia
using GLMakie
using PhyloMakie

phylogeny = newick"(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"

plot(
    phylogeny;
    useedgelength = true,
    showgamma = true,
    showtiplabel = true,
    style = :fulltree,
)
```

## Documentation

- [Home](docs/src/index.md)
- [Public API](docs/src/lib/public.md)
