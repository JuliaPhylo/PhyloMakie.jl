using CairoMakie
using PhyloMakie
using PhyloPicMakie: augment_phylopic!

network = newick"(Ailuropoda_melanoleuca:1.0,(Ursus_americanus:1.0,(Ursus_arctos:0.5,Ursus_maritimus:0.5):0.5):1.0);"
for node in network.node
    node.name = replace(node.name, "_" => " ")
end

figure = Figure(size = (980, 600))
axis = Axis(
    figure[1, 1];
    title = "Selected living bears",
    xautolimitmargin = (0.06, 0.18),
    yautolimitmargin = (0.12, 0.12),
)
hidedecorations!(axis)
hidespines!(axis)

tree_plot = plot!(
    axis,
    network;
    useedgelength = true,
    showtiplabel = true,
    tipoffset = 0.1,
)

tip_rows = [
    row for row in eachrow(node_positions(tree_plot)) if row.isleaf
]
tip_positions = Point2f[Point2f(row.x, row.y) for row in tip_rows]
tip_taxa = String[row.name for row in tip_rows]

glyph_plot = augment_phylopic!(
    axis,
    first.(tip_positions),
    last.(tip_positions);
    taxon = tip_taxa,
    image_rendering = :thumbnail,
    glyph_size = 0.24,
    placement = :left,
    xoffset = 1.65,
    on_missing = :error,
)

figure
