import CairoMakie
import DataFrames
import PhyloMakie
using Documenter: DocMeta, HTML, deploydocs, makedocs

CairoMakie.activate!()

DocMeta.setdocmeta!(
    PhyloMakie,
    :DocTestSetup,
    :(using CairoMakie, DataFrames, PhyloMakie);
    recursive = true,
)

makedocs(
    sitename = "PhyloMakie.jl",
    authors = "Cecile Ane, Jeet Sukumaran, and Matthew Andres Moreno",
    modules = [PhyloMakie],
    format = HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "Installation" => "man/installation.md",
            "Getting started" => "man/getting_started.md",
            "Untangling edges" => "man/untangling_edges.md",
            "Better edges" => "man/better_edges.md",
            "Adding data" => "man/adding_data.md",
        ],
        "Library" => [
            "Public API" => "lib/public.md",
            "Internal API" => "lib/internals.md",
        ],
    ],
)

deploydocs(
    repo = "github.com/JuliaPhylo/PhyloMakie.jl.git",
    push_preview = true,
    devbranch = "main",
)
