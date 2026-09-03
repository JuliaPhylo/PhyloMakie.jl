using CairoMakie
using PhyloMakie

CairoMakie.activate!()

# 1. Make a tree whose tip names will identify the images.
tree = newick"(cat,dog,bear,horse,mouse);"

# 2. Supply one image URL for each named tip.
urls = Dict(
    "cat" => "https://images.phylopic.org/images/e9f41f59-d708-47aa-a705-ba9b8826ebc6/thumbnail/192x192.png",
    "dog" => "https://images.phylopic.org/images/4d83a0cd-cf06-4a32-9a5a-0a6b644158c1/thumbnail/192x192.png",
    "bear" => "https://images.phylopic.org/images/43e82541-0f4a-467c-864e-f7f44c38b5af/thumbnail/192x192.png",
    "horse" => "https://images.phylopic.org/images/9f550f9e-b8df-43c4-9f00-396548507424/thumbnail/192x192.png",
    "mouse" => "https://images.phylopic.org/images/6b2b98f6-f879-445f-9ac2-2c2563157025/thumbnail/192x192.png",
)

# 3. Choose where each image sits relative to its tip node.
# Tip rows are 1 data unit apart, so 0.55 leaves space between images.
image_height = 0.55
nodeimages = Dict(
    "cat" => ImageAnnotation(urls["cat"]; position = :left, height = image_height),
    "dog" => ImageAnnotation(urls["dog"]; position = :above, height = image_height),
    "bear" => ImageAnnotation(urls["bear"]; position = :center, height = image_height),
    "horse" => ImageAnnotation(urls["horse"]; position = :below, height = image_height),
    "mouse" => ImageAnnotation(urls["mouse"]; position = :right, height = image_height),
)

# 4. Plot. Extra x space keeps the right image and tip labels visible.
result = plot(
    tree;
    nodeimages,
    tipoffset = 0.8,
    xlim = (0.5, 4.0),
    ylim = (0.25, 5.75),
)

result.figure

# PhyloPic credits (CC0 1.0): Steven Traver, David Orr,
# Tracy A. Heath, Andy Wilson, and Madeleine Price Ball.
