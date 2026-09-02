using CairoMakie
using DataFrames: DataFrame
using LinearAlgebra: dot, norm
using Makie

function _render_fixture_dataframe(table_fixture)
    return DataFrame(
        [column => [row[column] for row in table_fixture.rows] for column in table_fixture.columns]...,
    )
end

function _public_render_case(
    newick::AbstractString;
    kwargs...,
)
    CairoMakie.activate!()
    surface = Makie.plot(parsephylogeny(NewickFormat(), newick); kwargs...)
    plot = surface.plot
    return (
        surface=surface,
        figure=surface.figure,
        axis=surface.axis,
        plot=plot,
        config=plot[:plot_config][],
        network=plot[:plot_network][].net,
        layout=plot[:layout_computation][],
        channels=plot[:primitive_channels][],
    )
end

function _render_colorbuffer(figure)
    CairoMakie.activate!()
    return copy(Makie.colorbuffer(figure; backend=CairoMakie))
end

function _rgba(value)
    return convert(Makie.RGBAf, Makie.to_color(value))
end

function _arrowhead_vertices(polygon)
    return collect(polygon.exterior)
end

function _point_distance(first_point, second_point)::Float32
    dx = Float32(first_point[1]) - Float32(second_point[1])
    dy = Float32(first_point[2]) - Float32(second_point[2])
    return sqrt(dx^2 + dy^2)
end

function _arrowhead_base_center(vertices::AbstractVector)::Makie.Point2f
    return Makie.Point2f(
        0.5f0 * (Float32(vertices[2][1]) + Float32(vertices[3][1])),
        0.5f0 * (Float32(vertices[2][2]) + Float32(vertices[3][2])),
    )
end

function _arrowhead_pixel_metrics(polygon)::NamedTuple{(:length, :width), Tuple{Float32, Float32}}
    vertices = _arrowhead_vertices(polygon)
    base_center = _arrowhead_base_center(vertices)
    return (
        length = _point_distance(vertices[1], base_center),
        width = _point_distance(vertices[2], vertices[3]),
    )
end

function _arrowhead_axis_wing_dot(polygon)::Float32
    vertices = _arrowhead_vertices(polygon)
    base_center = _arrowhead_base_center(vertices)
    axis = vertices[1] - base_center
    wing = vertices[2] - vertices[3]
    return axis[1] * wing[1] + axis[2] * wing[2]
end

function _projected_point2(point)::Makie.Point2f
    return Makie.Point2f(Float32(point[1]), Float32(point[2]))
end

function _assert_arrowhead_matches_projected_shaft(
        polygon,
        pixel_startpoint,
        pixel_endpoint,
        requested_tiplength,
        requested_tipwidth;
        atol::Float32 = 0.75f0,
        unit_atol::Float32 = 0.03f0,
    )::Nothing
    vertices = _arrowhead_vertices(polygon)
    @test length(vertices) == 3

    startpoint = _projected_point2(pixel_startpoint)
    endpoint = _projected_point2(pixel_endpoint)
    tip = _projected_point2(vertices[1])
    wing_start = _projected_point2(vertices[2])
    wing_end = _projected_point2(vertices[3])
    base_center = _arrowhead_base_center(vertices)

    shaft = endpoint - startpoint
    axis = tip - base_center
    wing = wing_start - wing_end
    shaft_length = Float32(norm(shaft))
    measured_length = Float32(norm(axis))
    measured_width = Float32(norm(wing))
    requested_length = Float32(requested_tiplength)
    requested_width = Float32(requested_tipwidth)

    if shaft_length <= 0.0f0 || requested_length <= 0.0f0 || requested_width <= 0.0f0
        @test measured_length <= atol
        @test measured_width <= atol
        @test all(vertex -> norm(_projected_point2(vertex) - endpoint) <= atol, vertices)
        return nothing
    end

    scale = min(1.0f0, shaft_length / requested_length)
    expected_length = requested_length * scale
    expected_width = requested_width * scale

    @test norm(tip - endpoint) <= atol
    @test isapprox(measured_length, expected_length; atol = atol)
    @test isapprox(measured_width, expected_width; atol = atol)
    @test isapprox(dot(axis / measured_length, shaft / shaft_length), 1.0f0; atol = unit_atol)
    @test isapprox(
        abs(dot(wing / measured_width, shaft / shaft_length)),
        0.0f0;
        atol = unit_atol,
    )
    return nothing
end

function _rows_with_flag(flags::AbstractVector{Bool})
    return findall(flags)
end

function _node_channel_positions(layout, rows; x_offset::Real=0.0)
    node_data = layout.annotations.node_data
    return Makie.Point2f[
        Makie.Point2f(Float32(node_data[row, :x]) + Float32(x_offset), Float32(node_data[row, :y])) for row in rows
    ]
end

function _edge_channel_positions(layout, rows)
    edge_data = layout.annotations.edge_data
    return Makie.Point2f[
        Makie.Point2f(Float32(edge_data[row, :x]), Float32(edge_data[row, :y])) for row in rows
    ]
end
