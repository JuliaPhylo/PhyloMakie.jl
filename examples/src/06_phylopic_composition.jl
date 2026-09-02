using CairoMakie
using PhyloMakie
using PhyloPicMakie: PhyloPicDB, augment_phylopic!

const BEAR_TAXA = [
    "Ailuropoda melanoleuca",
    "Ursus americanus",
    "Ursus arctos",
    "Ursus maritimus",
]

function bear_phylogeny()
    network = newick"(Ailuropoda_melanoleuca:1.0,(Ursus_americanus:1.0,(Ursus_arctos:0.5,Ursus_maritimus:0.5):0.5):1.0);"
    for node in network.node
        node.name = replace(node.name, "_" => " ")
    end
    return network
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

function resolve_bear_phylopics(taxa::Vector{String})::NamedTuple
    resolutions = PhyloPicDB.resolve_taxa(taxa)
    unresolved = filter(resolution -> !PhyloPicDB.isresolved(resolution), resolutions)
    isempty(unresolved) || error(
        "Could not resolve all bear taxa through PhyloPic: " *
            join(["$(resolution.query) ($(resolution.status))" for resolution in unresolved], ", ")
    )

    nodes = PhyloPicDB.require_node.(resolutions)
    builds = unique(node.build for node in nodes)
    length(builds) == 1 || error("PhyloPic resolutions did not share one build.")

    image_records = PhyloPicDB.PhyloPicImage[]
    for resolution in resolutions
        image = PhyloPicDB.primary_image(resolution; add_node_name = true)
        isnothing(image) && error(
            "PhyloPic has no primary image for $(resolution.query)."
        )
        push!(image_records, image)
    end

    return (;
        resolutions,
        node_uuids = String[node.uuid for node in nodes],
        image_records,
        build = only(builds),
    )
end

function credit_value(value, fallback::String)::String
    ismissing(value) && return fallback
    text = strip(replace(String(value), '\n' => ' '))
    return isempty(text) ? fallback : text
end

function image_credit_lines(
        taxa::Vector{String},
        images::Vector{PhyloPicDB.PhyloPicImage},
    )::Vector{String}
    return [
        "$(taxon) — " *
            "$(credit_value(image.attribution, "creator not listed")); " *
            credit_value(image.license, "license unavailable")
            for (taxon, image) in zip(taxa, images)
    ]
end

function phylopic_composition_example()::NamedTuple
    figure = Figure(size = (980, 600), backgroundcolor = RGBf(0.985, 0.98, 0.965))
    axis = Axis(
        figure[1, 1];
        title = "Selected living bears",
        titlesize = 20,
        backgroundcolor = RGBf(0.985, 0.98, 0.965),
        xautolimitmargin = (0.06, 0.18),
        yautolimitmargin = (0.12, 0.12),
    )
    hidedecorations!(axis)
    hidespines!(axis)

    tree_plot = plot!(
        axis,
        bear_phylogeny();
        useedgelength = false,
        showtiplabel = true,
        tipoffset = 0.1,
    )
    live_positions = node_positions_observable(tree_plot)

    # Giving the tree plot to map registers these derived Observables with the
    # tree's lifecycle.
    identities = map(tip_identity, tree_plot, live_positions)
    positions = map(tip_points, tree_plot, live_positions)
    taxa = String[identity.name for identity in identities[]]
    Set(taxa) == Set(BEAR_TAXA) || error(
        "The rendered tree tips do not match the expected bear taxa."
    )

    discovery = resolve_bear_phylopics(taxa)
    initial_positions = positions[]
    glyph_plot = augment_phylopic!(
        axis,
        first.(initial_positions),
        last.(initial_positions);
        node_uuid = discovery.node_uuids,
        build = discovery.build,
        image_rendering = :thumbnail,
        glyph_size = 0.24,
        placement = :left,
        xoffset = 1.65,
        on_missing = :error,
    )

    # Discovery runs once. Later layouts update the existing PhyloPicGlyphs
    # recipe rather than resolving images or reconstructing the plot.
    position_binding = map(glyph_plot, positions) do updated_positions
        update!(glyph_plot; arg1 = updated_positions)
        return nothing
    end

    credit_lines = image_credit_lines(taxa, discovery.image_records)
    Label(
        figure[2, 1],
        "PhyloPic image credits\n" * join(credit_lines, "\n");
        fontsize = 9,
        color = RGBf(0.28, 0.28, 0.26),
        justification = :left,
        halign = :left,
        tellwidth = false,
        padding = (8, 8, 4, 6),
    )
    rowgap!(figure.layout, 6)

    return (;
        figure,
        axis,
        tree_plot,
        glyph_plot,
        live_positions,
        identities,
        positions,
        position_binding,
        taxa,
        resolutions = discovery.resolutions,
        image_records = discovery.image_records,
        credit_lines,
    )
end

composition = phylopic_composition_example()
@assert composition.tree_plot in composition.axis.scene.plots
@assert composition.glyph_plot in composition.axis.scene.plots
identity_before = copy(composition.identities[])
positions_before = copy(composition.positions[])

# This relayout preserves node identity. The existing PhyloPicGlyphs handle
# follows the new coordinates without repeating discovery or rebuilding.
update!(composition.tree_plot; useedgelength = true)
@assert composition.identities[] == identity_before
@assert composition.positions[] != positions_before
@assert composition.glyph_plot[1][] == composition.positions[]

# If arg1 is replaced with a network containing different taxa, inspect the
# updated identity table, resolve the new taxa, and update both PhyloPicGlyphs
# arguments together.
if isempty(ARGS) && isinteractive()
    display(composition.figure)
else
    output_path = abspath(get(ARGS, 1, "phylopic_composition.png"))
    save(output_path, composition.figure)
    println("Saved reactive PhyloPic composition example to $(output_path)")
    println("PhyloPic image credits:")
    foreach(line -> println("  $(line)"), composition.credit_lines)
end
