const DEFAULT_IMAGE_DATA_HEIGHT = 0.8f0
const DEFAULT_IMAGE_PIXEL_HEIGHT = 32.0f0
const DEFAULT_IMAGE_DOWNLOAD_TIMEOUT = 30.0
const MAX_IMAGE_DOWNLOAD_BYTES = 25 * 1024 * 1024
const SUPPORTED_IMAGE_SIZE_SPACES = (:data, :pixel)
const SUPPORTED_IMAGE_POSITIONS = (
    :center,
    :left,
    :right,
    :above,
    :below,
    :upperleft,
    :upperright,
    :lowerleft,
    :lowerright,
)
const SUPPORTED_IMAGE_ASPECTS = (:preserve, :stretch)
const NormalizedImageMatrix = Matrix{Makie.RGBA{Makie.N0f8}}

"""
    ImageAnnotation(source; kwargs...)

Configure an image rendered at a node or edge annotation anchor.

`source` may be a color or real-valued matrix, a local raster-image path, or an
HTTP(S) URL. `height` is the full rendered height and `scale` multiplies it.
`size_space = :data` interprets the height in plot y units and defaults to
`0.8`, leaving a gutter between adjacent 1-unit tip rows. `size_space = :pixel`
defaults to 32 pixels.

`position` places the image relative to its anchor. Supported values are
`:center`, `:left`, `:right`, `:above`, `:below`, and the 4 diagonal forms.
Set `align = (horizontal, vertical)` for direct control of the point in the
image aligned with the anchor. Horizontal values are `:left`, `:center`, or
`:right`; vertical values are `:bottom`, `:center`, or `:top`. Numeric values
from 0 to 1 are also accepted. `offset` adds a `(x, y)` displacement in pixels.

`aspect = :preserve` retains the source image's screen-space aspect ratio;
`:stretch` renders it as a square.

# Examples

```julia
ImageAnnotation("tip.png"; position = :right, offset = (6, 0))
ImageAnnotation("https://example.org/image.png"; scale = 1.25)
ImageAnnotation(image_matrix; size_space = :pixel, height = 48)
```
"""
struct ImageAnnotation{TSource}
    source::TSource
    height::Float32
    scale::Float32
    size_space::Symbol
    position::Symbol
    align::Tuple{Float32, Float32}
    aspect::Symbol
    offset::Makie.Vec2f
end

function _image_position_alignment(position::Symbol)::Tuple{Float32, Float32}
    position === :center && return (0.5f0, 0.5f0)
    position === :left && return (1.0f0, 0.5f0)
    position === :right && return (0.0f0, 0.5f0)
    position === :above && return (0.5f0, 0.0f0)
    position === :below && return (0.5f0, 1.0f0)
    position === :upperleft && return (1.0f0, 0.0f0)
    position === :upperright && return (0.0f0, 0.0f0)
    position === :lowerleft && return (1.0f0, 1.0f0)
    position === :lowerright && return (0.0f0, 1.0f0)
    throw(
        ArgumentError(
            "unknown image position `$position`; supported values are " *
                join(string.(SUPPORTED_IMAGE_POSITIONS), ", "),
        ),
    )
end

function _image_horizontal_alignment(value)::Float32
    value === :left && return 0.0f0
    value === :center && return 0.5f0
    value === :right && return 1.0f0
    value isa Real || throw(
        ArgumentError("horizontal image alignment must be :left, :center, :right, or a number"),
    )
    resolved = Float32(value)
    0.0f0 <= resolved <= 1.0f0 || throw(
        ArgumentError("numeric image alignment values must be between 0 and 1"),
    )
    return resolved
end

function _image_vertical_alignment(value)::Float32
    value === :bottom && return 0.0f0
    value === :center && return 0.5f0
    value === :top && return 1.0f0
    value isa Real || throw(
        ArgumentError("vertical image alignment must be :bottom, :center, :top, or a number"),
    )
    resolved = Float32(value)
    0.0f0 <= resolved <= 1.0f0 || throw(
        ArgumentError("numeric image alignment values must be between 0 and 1"),
    )
    return resolved
end

function _normalize_image_alignment(align)::Tuple{Float32, Float32}
    applicable(length, align) && length(align) == 2 || throw(
        ArgumentError("image align must contain exactly 2 values"),
    )
    return (
        _image_horizontal_alignment(align[1]),
        _image_vertical_alignment(align[2]),
    )
end

function _normalize_image_offset(offset)::Makie.Vec2f
    applicable(length, offset) && length(offset) == 2 || throw(
        ArgumentError("image offset must contain exactly 2 numeric values"),
    )
    all(value -> value isa Real && isfinite(value), offset) || throw(
        ArgumentError("image offset must contain exactly 2 finite numeric values"),
    )
    return Makie.Vec2f(Float32(offset[1]), Float32(offset[2]))
end

function ImageAnnotation(
        source;
        height = nothing,
        scale::Real = 1,
        size_space::Symbol = :data,
        position::Symbol = :center,
        align = nothing,
        aspect::Symbol = :preserve,
        offset = (0, 0),
    )
    size_space in SUPPORTED_IMAGE_SIZE_SPACES || throw(
        ArgumentError("image size_space must be :data or :pixel"),
    )
    position in SUPPORTED_IMAGE_POSITIONS || _image_position_alignment(position)
    aspect in SUPPORTED_IMAGE_ASPECTS || throw(
        ArgumentError("image aspect must be :preserve or :stretch"),
    )
    resolved_height = if isnothing(height)
        size_space === :data ? DEFAULT_IMAGE_DATA_HEIGHT : DEFAULT_IMAGE_PIXEL_HEIGHT
    else
        Float32(height)
    end
    isfinite(resolved_height) && resolved_height > 0 || throw(
        ArgumentError("image height must be a positive finite number"),
    )
    resolved_scale = Float32(scale)
    isfinite(resolved_scale) && resolved_scale > 0 || throw(
        ArgumentError("image scale must be a positive finite number"),
    )
    resolved_align = isnothing(align) ?
        _image_position_alignment(position) : _normalize_image_alignment(align)
    return ImageAnnotation(
        source,
        resolved_height,
        resolved_scale,
        size_space,
        position,
        resolved_align,
        aspect,
        _normalize_image_offset(offset),
    )
end

mutable struct ImageAssetCache
    assets::Dict{Any, NormalizedImageMatrix}
end

ImageAssetCache() = ImageAssetCache(Dict{Any, NormalizedImageMatrix}())

struct ImageChannel
    positions::Vector{Makie.Point2f}
    images::Vector{NormalizedImageMatrix}
    image_sizes::Vector{Tuple{Int, Int}}
    half_heights::Vector{Float32}
    size_spaces::Vector{Symbol}
    alignments::Vector{Tuple{Float32, Float32}}
    aspects::Vector{Symbol}
    offsets::Vector{Makie.Vec2f}
end

struct PhyloImageChannels
    edge_images::ImageChannel
    node_images::ImageChannel
end

function _empty_image_channel()::ImageChannel
    return ImageChannel(
        Makie.Point2f[],
        NormalizedImageMatrix[],
        Tuple{Int, Int}[],
        Float32[],
        Symbol[],
        Tuple{Float32, Float32}[],
        Symbol[],
        Makie.Vec2f[],
    )
end

function _normalize_image_matrix(
        image::AbstractMatrix{<:Makie.Colorant},
    )::NormalizedImageMatrix
    return Makie.RGBA{Makie.N0f8}.(image)
end

function _normalize_image_matrix(
        image::AbstractMatrix{<:Real},
    )::NormalizedImageMatrix
    return map(image) do value
        channel = clamp(Float64(value), 0.0, 1.0)
        Makie.RGBA{Makie.N0f8}(channel, channel, channel, 1.0)
    end
end

function _normalize_image_matrix(image::AbstractMatrix)::NormalizedImageMatrix
    throw(
        ArgumentError(
            "image matrices must contain color or real-valued pixels; received $(eltype(image))",
        ),
    )
end

function _download_image(
        url::AbstractString;
        downloader = Downloads.download,
        file_loader = FileIO.load,
    )
    progress = function (total, downloaded)
        if total > MAX_IMAGE_DOWNLOAD_BYTES || downloaded > MAX_IMAGE_DOWNLOAD_BYTES
            throw(
                ArgumentError(
                    "remote image exceeds the $(MAX_IMAGE_DOWNLOAD_BYTES)-byte download limit: $url",
                ),
            )
        end
        return nothing
    end
    return mktemp() do path, io
        close(io)
        downloader(
            String(url),
            path;
            timeout = DEFAULT_IMAGE_DOWNLOAD_TIMEOUT,
            progress,
        )
        filesize(path) <= MAX_IMAGE_DOWNLOAD_BYTES || throw(
            ArgumentError(
                "remote image exceeds the $(MAX_IMAGE_DOWNLOAD_BYTES)-byte download limit: $url",
            ),
        )
        return file_loader(path)
    end
end

function _is_remote_image_source(source::AbstractString)::Bool
    normalized = lowercase(String(source))
    return startswith(normalized, "https://") || startswith(normalized, "http://")
end

function _image_source_cache_key(source::AbstractString)
    if _is_remote_image_source(source)
        return (:url, String(source))
    end
    occursin("://", source) && throw(
        ArgumentError("image URLs must use the http or https scheme: $source"),
    )
    path = abspath(expanduser(String(source)))
    isfile(path) || throw(ArgumentError("image file does not exist: $path"))
    metadata = stat(path)
    return (:file, path, metadata.size, metadata.mtime)
end

function _load_image_source!(
        cache::ImageAssetCache,
        source::AbstractMatrix;
        downloader = Downloads.download,
        file_loader = FileIO.load,
    )::NormalizedImageMatrix
    return _normalize_image_matrix(source)
end

function _load_image_source!(
        cache::ImageAssetCache,
        source::AbstractString;
        downloader = Downloads.download,
        file_loader = FileIO.load,
    )::NormalizedImageMatrix
    key = _image_source_cache_key(source)
    return get!(cache.assets, key) do
        raw_image = if first(key) === :url
            _download_image(source; downloader, file_loader)
        else
            file_loader(key[2])
        end
        raw_image isa AbstractMatrix || throw(
            ArgumentError(
                "image source must decode to a two-dimensional matrix; received $(typeof(raw_image))",
            ),
        )
        return _normalize_image_matrix(raw_image)
    end
end

function _load_image_source!(cache::ImageAssetCache, source; kwargs...)
    throw(
        ArgumentError(
            "image source must be a pixel matrix, local file path, or HTTP(S) URL; " *
                "received $(typeof(source))",
        ),
    )
end

function _as_image_annotation(value)::ImageAnnotation
    value isa ImageAnnotation && return value
    if value isa AbstractMatrix || value isa AbstractString
        return ImageAnnotation(value)
    end
    throw(
        ArgumentError(
            "image mappings must return nothing, an ImageAnnotation, a pixel matrix, " *
                "a local file path, or an HTTP(S) URL; received $(typeof(value))",
        ),
    )
end

function _image_label_matches(
        selector::Union{AbstractString, Symbol, Regex},
        label::AbstractString,
    )::Bool
    selector isa Regex && return occursin(selector, label)
    return String(selector) == label
end

function _named_node_indices(
        nodes::AbstractVector,
        selector::Union{AbstractString, Symbol, Regex},
    )::Vector{Int}
    matches = findall(node -> _image_label_matches(selector, node_label(node)), nodes)
    isempty(matches) && throw(
        ArgumentError(
            "node image selector matches no node label: $(repr(selector))",
        ),
    )
    return matches
end

function _node_object_index(nodes::AbstractVector, selector)::Int
    index = findfirst(node -> node === selector, nodes)
    isnothing(index) && throw(
        ArgumentError("node image selector is not a node object from the plotted phylogeny"),
    )
    return index
end

function _resolve_node_image_values(mapping, nodes::AbstractVector)::Vector{Any}
    isnothing(mapping) && return Any[nothing for _ in nodes]
    if mapping isa AbstractDict
        values = Any[nothing for _ in nodes]
        for (selector, value) in pairs(mapping)
            indices = if selector isa Union{AbstractString, Symbol, Regex}
                _named_node_indices(nodes, selector)
            elseif selector isa Integer
                throw(
                    ArgumentError(
                        "numeric node image selectors are not supported; use a node name, " *
                            "regular expression, node object, or callable mapping",
                    ),
                )
            else
                [_node_object_index(nodes, selector)]
            end
            for index in indices
                isnothing(values[index]) || throw(
                    ArgumentError("multiple node image selectors target the same node"),
                )
                values[index] = value
            end
        end
        return values
    end
    if isempty(nodes) || applicable(mapping, first(nodes))
        return Any[mapping(node) for node in nodes]
    end
    throw(ArgumentError("nodeimages must be nothing, a dictionary, or a callable mapping"))
end

function _edge_object_index(edges::AbstractVector, selector)::Int
    index = findfirst(edge -> edge === selector, edges)
    isnothing(index) && throw(
        ArgumentError("edge image selector is not an edge object from the plotted phylogeny"),
    )
    return index
end

function _edge_endpoint_selectors(selector)
    endpoints = if selector isa Pair
        (first(selector), last(selector))
    elseif selector isa Tuple && length(selector) == 2
        selector
    else
        return nothing
    end
    all(endpoint -> endpoint isa Union{AbstractString, Symbol, Regex}, endpoints) ||
        return nothing
    return endpoints
end

function _endpoint_edge_indices(
        phylogeny::AbstractPhylogeny,
        prepared_edges::AbstractVector,
        selector,
    )::Vector{Int}
    endpoint_selectors = _edge_endpoint_selectors(selector)
    isnothing(endpoint_selectors) && throw(
        ArgumentError(
            "edge endpoint selectors must be parent => child or (parent, child), " *
                "with each endpoint given as a name or regular expression",
        ),
    )
    parent_selector, child_selector = endpoint_selectors
    matches = findall(prepared_edges) do edge
        return _image_label_matches(
            parent_selector,
            node_label(parent_node(phylogeny, edge)),
        ) && _image_label_matches(
            child_selector,
            node_label(child_node(phylogeny, edge)),
        )
    end
    isempty(matches) && throw(
        ArgumentError(
            "edge image selector matches no plotted edge: " *
                "$(repr(parent_selector)) => $(repr(child_selector))",
        ),
    )
    return matches
end

function _resolve_edge_image_values(
        mapping,
        phylogeny::AbstractPhylogeny,
        edges::AbstractVector,
    )::Vector{Any}
    isnothing(mapping) && return Any[nothing for _ in edges]
    if mapping isa AbstractDict
        values = Any[nothing for _ in edges]
        for (selector, value) in pairs(mapping)
            indices = if selector isa Integer
                throw(
                    ArgumentError(
                        "numeric edge image selectors are not supported; use an edge object, " *
                            "endpoint names or regular expressions, or callable mapping",
                    ),
                )
            elseif !isnothing(_edge_endpoint_selectors(selector))
                _endpoint_edge_indices(phylogeny, edges, selector)
            else
                [_edge_object_index(edges, selector)]
            end
            for index in indices
                isnothing(values[index]) || throw(
                    ArgumentError("multiple edge image selectors target the same edge"),
                )
                values[index] = value
            end
        end
        return values
    end
    isempty(edges) && return Any[]
    if applicable(mapping, phylogeny, first(edges))
        return Any[mapping(phylogeny, current_edge) for current_edge in edges]
    end
    if applicable(mapping, first(edges))
        return Any[mapping(edge) for edge in edges]
    end
    throw(
        ArgumentError(
            "edgeimages must be nothing, a dictionary, or a callable mapping accepting " *
                "an edge or `(phylogeny, edge)`",
        ),
    )
end

function _build_image_channel!(
        cache::ImageAssetCache,
        values::AbstractVector,
        anchors::AbstractVector{<:Makie.Point2f},
    )::ImageChannel
    length(values) == length(anchors) || error("image values and anchors must have equal length")
    isempty(values) && return _empty_image_channel()

    positions = Makie.Point2f[]
    images = NormalizedImageMatrix[]
    image_sizes = Tuple{Int, Int}[]
    half_heights = Float32[]
    size_spaces = Symbol[]
    alignments = Tuple{Float32, Float32}[]
    aspects = Symbol[]
    offsets = Makie.Vec2f[]

    for (value, anchor) in zip(values, anchors)
        (isnothing(value) || ismissing(value)) && continue
        annotation = _as_image_annotation(value)
        image = _load_image_source!(cache, annotation.source)
        push!(positions, anchor)
        push!(images, image)
        push!(image_sizes, (size(image, 2), size(image, 1)))
        push!(half_heights, annotation.height * annotation.scale / 2.0f0)
        push!(size_spaces, annotation.size_space)
        push!(alignments, annotation.align)
        push!(aspects, annotation.aspect)
        push!(offsets, annotation.offset)
    end
    return ImageChannel(
        positions,
        images,
        image_sizes,
        half_heights,
        size_spaces,
        alignments,
        aspects,
        offsets,
    )
end

function resolve_image_channels!(
        cache::ImageAssetCache,
        input_phylogeny::AbstractPhylogeny,
        prepared_phylogeny::PreparedPhylogeny,
        layout::LayoutComputation,
        nodeimages,
        edgeimages,
    )::PhyloImageChannels
    prepared_phylogeny.phylogeny === input_phylogeny ||
        error("prepared phylogeny does not reference the plotted input phylogeny")
    phylogeny_nodes = nodes(input_phylogeny)
    phylogeny_edges = edges(input_phylogeny)
    node_values = _resolve_node_image_values(nodeimages, phylogeny_nodes)
    edge_values =
        _resolve_edge_image_values(edgeimages, input_phylogeny, phylogeny_edges)
    node_anchors = Makie.Point2f[
        Makie.Point2f(layout.geometry.node_x[index], layout.geometry.node_y[index]) for
            index in eachindex(phylogeny_nodes)
    ]
    edge_anchors = Makie.Point2f[
        Makie.Point2f(row.x, row.y) for row in eachrow(layout.annotations.edge_data)
    ]
    return PhyloImageChannels(
        _build_image_channel!(cache, edge_values, edge_anchors),
        _build_image_channel!(cache, node_values, node_anchors),
    )
end

function image_probe_positions(
        channel::ImageChannel,
    )::Tuple{Vector{Makie.Point2f}, Vector{Makie.Point2f}}
    upper = Makie.Point2f[]
    lower = Makie.Point2f[]
    sizehint!(upper, length(channel.positions))
    sizehint!(lower, length(channel.positions))
    for index in eachindex(channel.positions)
        position = channel.positions[index]
        delta = channel.size_spaces[index] === :data ? channel.half_heights[index] : 0.0f0
        push!(upper, Makie.Point2f(position[1], position[2] + delta))
        push!(lower, Makie.Point2f(position[1], position[2] - delta))
    end
    return upper, lower
end

function compute_image_marker_geometry(
        channel::ImageChannel,
        upper_pixel_positions::AbstractVector,
        lower_pixel_positions::AbstractVector,
    )::Tuple{Vector{Makie.Vec2f}, Vector{Makie.Vec3f}}
    length(upper_pixel_positions) == length(channel.positions) ||
        error("upper image probes must match the image channel")
    length(lower_pixel_positions) == length(channel.positions) ||
        error("lower image probes must match the image channel")

    marker_sizes = Makie.Vec2f[]
    marker_offsets = Makie.Vec3f[]
    sizehint!(marker_sizes, length(channel.positions))
    sizehint!(marker_offsets, length(channel.positions))
    for index in eachindex(channel.positions)
        half_height = if channel.size_spaces[index] === :data
            upper = upper_pixel_positions[index]
            lower = lower_pixel_positions[index]
            hypot(upper[1] - lower[1], upper[2] - lower[2]) / 2.0f0
        else
            channel.half_heights[index]
        end
        image_width, image_height = channel.image_sizes[index]
        full_height = 2.0f0 * Float32(half_height)
        full_width = if channel.aspects[index] === :preserve && image_height != 0
            full_height * Float32(image_width) / Float32(image_height)
        else
            full_height
        end
        marker_size = Makie.Vec2f(full_width, full_height)
        align_x, align_y = channel.alignments[index]
        offset = channel.offsets[index]
        marker_offset = Makie.Vec3f(
            (0.5f0 - align_x) * full_width + offset[1],
            (0.5f0 - align_y) * full_height + offset[2],
            0.0f0,
        )
        push!(marker_sizes, marker_size)
        push!(marker_offsets, marker_offset)
    end
    return marker_sizes, marker_offsets
end
