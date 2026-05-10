using CairoMakie
using DataFrames: DataFrame
using Makie
using PhyloNetworks

function _render_fixture_dataframe(table_fixture)
    return DataFrame(
        [column => [row[column] for row in table_fixture.rows] for column in table_fixture.columns]...,
    )
end

function _render_case(
    newick::AbstractString;
    figure_size::Tuple{Int, Int}=(640, 400),
    kwargs...,
)
    CairoMakie.activate!()
    normalize_plot_keywords = getfield(PhyloMakie, :normalize_plot_keywords)
    prepare_plot_layout = getfield(PhyloMakie, :prepare_plot_layout)
    render_plot! = getfield(PhyloMakie, :render_plot!)

    network = readnewick(newick)
    spec = normalize_plot_keywords(; kwargs...)
    layout = prepare_plot_layout(network, spec)
    figure = Figure(size=figure_size)
    axis = Axis(figure[1, 1])
    hidedecorations!(axis)
    hidespines!(axis)
    layers = render_plot!(axis, network, spec, layout)
    return (; network, spec, layout, figure, axis, layers)
end

function _render_colorbuffer(figure)
    CairoMakie.activate!()
    return Makie.colorbuffer(figure; backend=CairoMakie)
end

function _rgba(value)
    return convert(Makie.RGBAf, Makie.to_color(value))
end

function _rows_with_flag(flags::AbstractVector{Bool})
    return findall(flags)
end

function _node_channel_positions(layout, rows; x_offset::Real=0.0)
    node_data = layout.annotations.node_data
    return [
        (Float64(node_data[row, :x]) + Float64(x_offset), Float64(node_data[row, :y])) for row in rows
    ]
end

function _edge_channel_positions(layout, rows)
    edge_data = layout.annotations.edge_data
    return [(Float64(edge_data[row, :x]), Float64(edge_data[row, :y])) for row in rows]
end
