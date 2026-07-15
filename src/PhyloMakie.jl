module PhyloMakie

import Makie

include("plot_config.jl")
include("attribute_schema.jl")
include("network_layout.jl")
include("layout_engine.jl")
include("annotation_tables.jl")
include("plot_layout.jl")
include("primitive_channels.jl")
include("reactive_graph.jl")
include("render_adapter.jl")
include("recipe.jl")

export phyloplot, phyloplot!, PhyloPlot

end
