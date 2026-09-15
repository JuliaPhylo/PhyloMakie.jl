using GLMakie
using PhyloMakie
using PhyloPicMakie: augment_phylopic!

phylogeny = newick"(Ailuropoda_melanoleuca:1.0,(Ursus_americanus:1.0,(Ursus_arctos:0.5,Ursus_maritimus:0.5):0.5):1.0);"
for current_node in nodes(phylogeny)
    rename_node!(current_node, replace(node_label(current_node), "_" => " "))
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
    phylogeny;
    useedgelength = true,
    showleaflabel = true,
    leafoffset = 0.1,
)

leaf_rows = [
    row for row in eachrow(node_positions(tree_plot)) if row.isleaf
]
leaf_positions = Point2f[Point2f(row.x, row.y) for row in leaf_rows]
leaf_taxa = String[row.name for row in leaf_rows]

glyph_plot = augment_phylopic!(
    axis,
    first.(leaf_positions),
    last.(leaf_positions);
    taxon = leaf_taxa,
    image_rendering = :thumbnail,
    glyph_size = 0.24,
    placement = :left,
    xoffset = 0.3,
    on_missing = :error,
)

figure
