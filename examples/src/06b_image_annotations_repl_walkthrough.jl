using CairoMakie
using PhyloMakie

CairoMakie.activate!()

# Image annotations: a REPL walkthrough
#
# Run this file one section at a time. Each section constructs its own tree,
# image dictionary, and plot so that the complete operation remains visible.

red_image = normpath(joinpath(@__DIR__, "..", "assets", "circles", "red.png"))
blue_image = normpath(joinpath(@__DIR__, "..", "assets", "circles", "blue.png"))
green_image = normpath(joinpath(@__DIR__, "..", "assets", "circles", "green.png"))
yellow_image = normpath(joinpath(@__DIR__, "..", "assets", "circles", "yellow.png"))
orange_image = normpath(joinpath(@__DIR__, "..", "assets", "circles", "orange.png"))

# Exact node labels
#
# A `nodeimages` dictionary maps node labels to images. A bare image path uses
# the default size and centers the image on the node. `ImageAnnotation` adds
# placement and sizing options. No node indices are needed.

exact_node_tree = newick"(cat,dog,bear);"

exact_node_images = Dict(
    "cat" => red_image,
    "dog" => ImageAnnotation(blue_image; position = :right, height = 0.6),
)

exact_node_result = plot(
    exact_node_tree;
    nodeimages = exact_node_images,
    tipoffset = 0.8,
    xlim = (0.5, 4.0),
)

exact_node_result.figure

# Repeated node labels
#
# An exact label selects every node with that label. Both `mouse` tips receive
# the same green image. Repeated labels are not an error.

repeated_node_tree = newick"((mouse,mouse),cat);"

repeated_node_images = Dict(
    "mouse" => ImageAnnotation(green_image; position = :left, height = 0.6),
)

repeated_node_result = plot(
    repeated_node_tree;
    nodeimages = repeated_node_images,
    tipoffset = 0.8,
    xlim = (0.5, 4.5),
)

repeated_node_result.figure

# Regular-expression node labels
#
# A `Regex` key selects every node label that contains a match. Anchors make
# this expression match complete labels beginning with `cat_`.

regexp_node_tree = newick"(cat_1,cat_2,dog,bear);"

regexp_node_images = Dict(
    r"^cat_" => ImageAnnotation(yellow_image; position = :above, height = 0.5),
)

regexp_node_result = plot(
    regexp_node_tree;
    nodeimages = regexp_node_images,
    tipoffset = 0.8,
    xlim = (0.5, 4.0),
    ylim = (0.25, 4.75),
)

regexp_node_result.figure

# Exact edge endpoint labels
#
# An edge key is `parent_label => child_label`. Every edge whose endpoints
# have those labels receives the image. This tree contains two `group => cat`
# edges, so both edges receive an orange image.

exact_edge_tree = newick"((cat,dog)group,(cat,bear)group)root;"

exact_edge_images = Dict(
    ("group" => "cat") =>
        ImageAnnotation(orange_image; position = :above, height = 0.45),
)

exact_edge_result = plot(
    exact_edge_tree;
    edgeimages = exact_edge_images,
    shownodelabel = true,
    tipoffset = 0.5,
    xlim = (0.5, 4.0),
)

exact_edge_result.figure

# Regular-expression edge endpoint labels
#
# Either endpoint may be a `Regex`. This selector matches the `pet_clade` to
# `cat` edge and the `large_clade` to `horse` edge.

regexp_edge_tree =
    newick"((cat,dog)pet_clade,(bear,horse)large_clade,mouse)root;"

regexp_edge_images = Dict(
    (r"_clade$" => r"^(cat|horse)$") =>
        ImageAnnotation(red_image; position = :below, height = 0.45),
)

regexp_edge_result = plot(
    regexp_edge_tree;
    edgeimages = regexp_edge_images,
    shownodelabel = true,
    tipoffset = 0.5,
    xlim = (0.5, 4.0),
)

regexp_edge_result.figure
