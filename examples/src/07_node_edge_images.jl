using CairoMakie
using PhyloMakie
CairoMakie.activate!()

phylogeny = newick"((red_1,blue)warm,(green,(yellow,(orange,red_2)citrus)mixed)cool)root;"
circle_directory = normpath(joinpath(@__DIR__, "..", "assets", "circles"))
circle_paths = Dict(
    "red_1" => joinpath(circle_directory, "red.png"),
    "blue" => joinpath(circle_directory, "blue.png"),
    "green" => joinpath(circle_directory, "green.png"),
    "yellow" => joinpath(circle_directory, "yellow.png"),
    "orange" => joinpath(circle_directory, "orange.png"),
    "red_2" => joinpath(circle_directory, "red.png"),
)

function tip_circle(node)
    source = get(circle_paths, node_label(node), nothing)
    isnothing(source) && return nothing
    return ImageAnnotation(source; height = 0.8)
end

function selected_edge_circle(phylogeny, current_edge)
    child = child_node(phylogeny, current_edge)
    node_label(child) == "citrus" || return nothing
    return ImageAnnotation(
        joinpath(circle_directory, "blue.png");
        height = 0.5,
        align = (:center, :bottom),
        offset = (0, 4),
    )
end

figure = Figure(size = (980, 600))
axis = Axis(
    figure[1, 1];
    title = "Native node and edge images",
    xautolimitmargin = (0.06, 0.18),
    yautolimitmargin = (0.1, 0.1),
)
hidedecorations!(axis)
hidespines!(axis)

plot!(
    axis,
    phylogeny;
    nodeimages = tip_circle,
    edgeimages = selected_edge_circle,
    tipoffset = 0.3,
)

figure
