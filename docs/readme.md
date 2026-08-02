# PhyloMakie documentation

This directory contains the Documenter.jl project for the PhyloMakie manual.
The documentation renders examples with CairoMakie and imports the local
PhyloMakie checkout through the `[sources]` entry in `Project.toml`.

## Local build

Instantiate the docs environment once:

```sh
julia --project=docs -e 'using Pkg; Pkg.instantiate()'
```

Build the manual from the repository root:

```sh
julia --project=docs docs/make.jl
```

The generated site is written to `docs/build`.

## Plot examples

Documentation examples should use CairoMakie directly. Keep each example small,
return the `Figure` or `FigureAxisPlot.figure` as the final expression, and
avoid pre-generated image files unless an example needs a fixed external asset.

Use named `@setup` blocks for shared imports:

````
```@setup example_name
using CairoMakie
using DataFrames
using PhyloMakie
using PhyloNetworks
CairoMakie.activate!()
```
````

Then render native Makie output:

````
```@example example_name
net = readnewick("(A,((B,#H1),(C,(D)#H1)));")
figaxisplot = plot(net; showgamma = true)
figaxisplot.figure
```
````
