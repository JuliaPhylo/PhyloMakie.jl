# Installation

PhyloMakie is a Julia package. Install Julia first, then install PhyloMakie in
the Julia package manager.

PhyloMakie is not currently registered in the Julia General registry. Install
it directly from GitHub:

```julia
using Pkg
Pkg.add(url = "https://github.com/JuliaPhylo/PhyloMakie.jl")
```

PhyloMakie depends on Makie and PhyloNetworks. Examples in this manual also use
CairoMakie for static rendering:

```julia
using Pkg
Pkg.add([
    "CairoMakie",
])
```

Load the packages needed for most examples with:

```julia
using CairoMakie
using PhyloMakie
```
