const ArrowheadPixelPolygon = Makie.GeometryBasics.Polygon{2, Float32}

function _pixel_point2(point)::Makie.Point2f
    return Makie.Point2f(Float32(point[1]), Float32(point[2]))
end

function _arrowhead_pixel_polygon(
        startpoint::Makie.Point2f,
        endpoint::Makie.Point2f,
        tiplength::Real,
        tipwidth::Real,
    )::ArrowheadPixelPolygon
    direction = endpoint - startpoint
    segment_length = sqrt(direction[1]^2 + direction[2]^2)
    if segment_length <= 0 || tiplength <= 0 || tipwidth <= 0
        return Makie.Polygon(Makie.Point2f[endpoint, endpoint, endpoint])
    end

    requested_length = Float32(tiplength)
    requested_width = Float32(tipwidth)
    scale = min(1.0f0, Float32(segment_length) / requested_length)
    effective_length = requested_length * scale
    half_width = 0.5f0 * requested_width * scale

    unit_direction = direction / segment_length
    unit_perpendicular = Makie.Vec2f(-unit_direction[2], unit_direction[1])
    base = endpoint - effective_length * unit_direction
    return Makie.Polygon(
        Makie.Point2f[
            endpoint,
            base + half_width * unit_perpendicular,
            base - half_width * unit_perpendicular,
        ],
    )
end

function compute_arrowhead_pixel_meshes(
        pixel_startpoints::AbstractVector,
        pixel_endpoints::AbstractVector,
        tiplengths::AbstractVector{<:Real},
        tipwidths::AbstractVector{<:Real},
    )::Vector{ArrowheadPixelPolygon}
    count = length(pixel_startpoints)
    if length(pixel_endpoints) != count ||
            length(tiplengths) != count ||
            length(tipwidths) != count
        throw(DimensionMismatch("arrowhead pixel mesh inputs must have matching lengths"))
    end

    polygons = Vector{ArrowheadPixelPolygon}(undef, count)
    for index in 1:count
        polygons[index] = _arrowhead_pixel_polygon(
            _pixel_point2(pixel_startpoints[index]),
            _pixel_point2(pixel_endpoints[index]),
            tiplengths[index],
            tipwidths[index],
        )
    end
    return polygons
end
