using PhyloMakie
using Documenter

DocMeta.setdocmeta!(PhyloMakie, :DocTestSetup, :(using PhyloMakie); recursive=true)

makedocs(;
    modules=[PhyloMakie],
    authors="Jeet Sukumaran <jeetsukumaran@gmail.com>",
    sitename="PhyloMakie.jl",
    format=Documenter.HTML(;
        canonical="https://jeetsukumaran.github.io/PhyloMakie.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Public API" => "public-api.md",
        "Migration guide" => "migration-guide.md",
        "Verification foundation" => "verification-foundation.md",
        "Render verification" => "render-verification.md",
    ],
)

deploydocs(;
    repo="github.com/jeetsukumaran/PhyloMakie.jl",
    devbranch="main",
)
