# Installation

PhyloMakie is a Julia package. Install Julia first, then install PhyloMakie in
the Julia package manager.

PhyloMakie is not currently registered in the Julia General registry. Install
it directly from GitHub:

```julia
using Pkg
Pkg.add(url = "https://github.com/JuliaPhylo/PhyloMakie.jl")
```

Julia 1.12 can install PhyloMakie's command-line app into the first Julia
depot:

```julia
using Pkg
Pkg.Apps.add(url = "https://github.com/JuliaPhylo/PhyloMakie.jl")
```

The app executable is named `phylomakie`. Add the first Julia depot's `bin`
directory, normally `~/.julia/bin`, to `PATH`. Pkg app support is experimental
and is not available in Julia 1.11, although the PhyloMakie library remains
compatible with Julia 1.11.

Load the packages needed for most examples with:

```julia
using CairoMakie
using PhyloMakie
```
