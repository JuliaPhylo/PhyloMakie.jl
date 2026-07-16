using CairoMakie
using DataFrames: DataFrame
using Makie
using PhyloNetworks

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
    surface = Makie.plot(readnewick(newick); kwargs...)
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
