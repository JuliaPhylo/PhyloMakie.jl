module PhyloMakie

import Makie

include("attribute_schema.jl")
include("layout_engine.jl")
include("plot_layout.jl")
include("render_adapter.jl")
include("recipe.jl")

export phyloplot, phyloplot!, PhyloPlot

end
