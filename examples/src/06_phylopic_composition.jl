using CairoMakie
using PhyloMakie
using PhyloPicMakie: phylopicglyphs!

function example_glyph(
        color::RGBAf;
        width::Integer = 48,
        height::Integer = 32,
    )::Matrix{RGBAf}
    image = fill(RGBAf(0, 0, 0, 0), Int(height), Int(width))
    for row in axes(image, 1), column in axes(image, 2)
        x = (Float64(column) - 0.5 * (Float64(width) + 1.0)) / (0.42 * Float64(width))
        y = (Float64(row) - 0.5 * (Float64(height) + 1.0)) / (0.34 * Float64(height))
        body = x^2 + y^2 <= 1.0
        tail = x < -0.65 && abs(y) <= 0.75 * (x + 1.25)
        if body || tail
            image[row, column] = color
        end
    end
    return image
end

function tip_identity(table)::Vector{NamedTuple{(:number, :name), Tuple{Int, String}}}
    return [
        (number = row.number, name = row.name)
            for row in eachrow(table) if row.isleaf
    ]
end

function tip_points(table)::Vector{Point2f}
    return Point2f[
        Point2f(row.x, row.y) for row in eachrow(table) if row.isleaf
    ]
end

function phylopic_composition_example()::NamedTuple
    network = newick"((Canis:1.0,Felis:2.0):1.0,(Ursus:1.5,Vulpes:1.0):2.0);"
    figure = Figure(size = (820, 420))
    axis = Axis(
        figure[1, 1];
        title = "Reactive PhyloPic composition",
        xautolimitmargin = (0.05, 0.12),
    )
    hidedecorations!(axis)
    hidespines!(axis)

    tree_plot = plot!(
        axis,
        network;
        useedgelength = false,
        showtiplabel = true,
        tipoffset = 0.12,
    )
    live_positions = node_positions_observable(tree_plot)

    # Giving the tree plot to map registers the callback with the tree's
    # lifecycle. The derived Observable stops listening when the tree is deleted.
    identities = map(tip_identity, tree_plot, live_positions)
    positions = map(tip_points, tree_plot, live_positions)
    images = Matrix{RGBAf}[
        example_glyph(RGBAf(0.14, 0.26, 0.42, 1.0)),
        example_glyph(RGBAf(0.42, 0.2, 0.15, 1.0)),
        example_glyph(RGBAf(0.2, 0.36, 0.18, 1.0)),
        example_glyph(RGBAf(0.34, 0.22, 0.4, 1.0)),
    ]
    glyph_plot = phylopicglyphs!(
        axis,
        positions,
        images;
        glyph_size = 0.22,
        placement = :left,
        xoffset = 0.72,
    )

    return (;
        figure,
        axis,
        tree_plot,
        glyph_plot,
        live_positions,
        identities,
        positions,
    )
end

composition = phylopic_composition_example()
@assert composition.tree_plot in composition.axis.scene.plots
@assert composition.glyph_plot in composition.axis.scene.plots
identity_before = copy(composition.identities[])
positions_before = copy(composition.positions[])

# This relayout preserves node identity. The existing PhyloPicGlyphs handle
# follows the new coordinates without rebuilding either plot.
update!(composition.tree_plot; useedgelength = true)
@assert composition.identities[] == identity_before
@assert composition.positions[] != positions_before

# If arg1 is replaced with a network containing different taxa, inspect the
# updated identity table and re-resolve the glyphs. Update both PhyloPicGlyphs
# arguments together with Makie.update!(glyph_plot; arg1 = ..., arg2 = ...).
if isempty(ARGS) && isinteractive()
    display(composition.figure)
else
    output_path = abspath(get(ARGS, 1, "phylopic_composition.png"))
    save(output_path, composition.figure)
    println("Saved reactive PhyloPic composition example to $(output_path)")
end
