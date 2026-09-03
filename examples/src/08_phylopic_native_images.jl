using CairoMakie
using PhyloMakie
using PhyloPicMakie

const PhyloPicDB = PhyloPicMakie.PhyloPicDB

CairoMakie.activate!()

network = newick"(Ailuropoda_melanoleuca:1.0,(Ursus_americanus:1.0,(Ursus_arctos:0.5,Ursus_maritimus:0.5):0.5):1.0);"
for node in network.node
    node.name = replace(node.name, "_" => " ")
end

tip_names = String[node.name for node in network.node if node.leaf]
thumbnail_urls = Dict{String, String}()
for name in tip_names
    resolution = PhyloPicDB.resolve_taxon(name)
    image_record = PhyloPicDB.primary_image(resolution)
    isnothing(image_record) && error("No primary PhyloPic image for $name")
    ismissing(image_record.thumbnail_url) && error("No PhyloPic thumbnail URL for $name")
    thumbnail_urls[name] = image_record.thumbnail_url
end

function phylopic_tip_image(node)
    url = get(thumbnail_urls, node.name, nothing)
    isnothing(url) && return nothing
    return ImageAnnotation(url; height = 0.75, position = :right, offset = (6, 0))
end

figure = Figure(size = (980, 600))
axis = Axis(
    figure[1, 1];
    title = "PhyloPic URLs through PhyloMakie nodeimages",
    xautolimitmargin = (0.06, 0.24),
    yautolimitmargin = (0.14, 0.14),
)
hidedecorations!(axis)
hidespines!(axis)

plot!(
    axis,
    network;
    useedgelength = true,
    nodeimages = phylopic_tip_image,
    showtiplabel = false,
)

figure
