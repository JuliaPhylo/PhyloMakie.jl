# Installation

PhyloMakie is a Julia package. Install Julia first, then install PhyloMakie in
the Julia package manager.

Install PhyloMakie from the Julia General registry:

```julia
using Pkg
Pkg.add("PhyloMakie")
```

## Choose a Makie backend

Makie backends render and display the plots. This manual uses CairoMakie for
static figures and PNG, SVG, or PDF files. Add it to the same Julia environment
as PhyloMakie:

```julia
using Pkg
Pkg.add("CairoMakie")
```

Load the packages needed for the manual examples with:

```julia
using CairoMakie
using PhyloMakie
```

For interactive desktop windows, install `GLMakie` with `Pkg.add("GLMakie")`
and use `using GLMakie` in place of `using CairoMakie`. Both backends make
Makie's plotting functions and types available. Makie's
[backend guide](https://docs.makie.org/stable/explanations/backends/backends)
describes their display requirements and output formats.

Continue with [Getting started](@ref) for a first plot and an introduction to
Makie's figures and axes. To run the repository's complete scripts, follow
the environment setup in [Example scripts](@ref).
