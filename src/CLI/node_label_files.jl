const NODE_LABEL_DELIMITERS = Dict(
    ".csv" => ',',
    ".tsv" => '\t',
)
const NodeDisplayNames = Dict{String, String}
const DisplayInputs = NamedTuple{
    (:records, :plot_options),
    Tuple{Vector{SourceRecord}, PlotOptions},
}

function _node_label_delimiter(path::AbstractString)::Char
    extension = lowercase(last(splitext(path)))
    haskey(NODE_LABEL_DELIMITERS, extension) || throw(
        CLIUsageError(
            "Node label file $(repr(path)) must have a .csv or .tsv extension.",
        ),
    )
    return NODE_LABEL_DELIMITERS[extension]
end

function load_node_labels(path::AbstractString)::NodeDisplayNames
    isfile(path) || throw(CLIUsageError("Node label file does not exist: $(path)."))
    delimiter = _node_label_delimiter(path)
    table = try
        CSV.File(
            String(path);
            delim = delimiter,
            strict = true,
            missingstring = nothing,
            types = (index, _) -> index <= 2 ? String : nothing,
        )
    catch error
        error isa InterruptException && rethrow()
        throw(
            CLIUsageError(
                "Cannot read node label file $(repr(path)): $(sprint(showerror, error))",
            ),
        )
    end

    column_names = String.(propertynames(table))
    column_names == ["name", "display"] || throw(
        CLIUsageError(
            "Node label file $(repr(path)) must have exactly the columns name,display; " *
                "found $(join(column_names, ",")).",
        ),
    )

    display_names = NodeDisplayNames()
    for row in table
        name = String(row.name)
        isempty(name) && throw(
            CLIUsageError("Node label file $(repr(path)) contains an empty node name."),
        )
        haskey(display_names, name) && throw(
            CLIUsageError(
                "Node label file $(repr(path)) contains duplicate node name $(repr(name)).",
            ),
        )
        display_names[name] = String(row.display)
    end
    return display_names
end

function records_with_display_names(
        records::AbstractVector{SourceRecord},
        display_names::AbstractDict{<:AbstractString, <:AbstractString},
    )::Vector{SourceRecord}
    displayed_records = SourceRecord[]
    for record in records
        displayed_phylogeny = deepcopy(record.phylogeny)
        for current_node in PhyloMakie.nodes(displayed_phylogeny)
            current_name = PhyloMakie.node_label(current_node)
            haskey(display_names, current_name) || continue
            PhyloMakie.rename_node!(current_node, display_names[current_name])
        end
        push!(
            displayed_records,
            SourceRecord(displayed_phylogeny, record.source, record.record_index),
        )
    end
    return displayed_records
end

function _display_name(
        name::Union{AbstractString, Symbol},
        display_names::AbstractDict{<:AbstractString, <:AbstractString},
    )::String
    original = string(name)
    return String(get(display_names, original, original))
end

function _remap_node_images(
        node_images,
        display_names::AbstractDict{<:AbstractString, <:AbstractString},
    )::Any
    isnothing(node_images) && return nothing
    remapped = Dict{String, Any}()
    for (selector, image) in pairs(node_images)
        displayed_selector = _display_name(selector, display_names)
        haskey(remapped, displayed_selector) && throw(
            CLIUsageError(
                "Node image selectors become ambiguous after applying --nodelabels: " *
                    "multiple names display as $(repr(displayed_selector)).",
            ),
        )
        remapped[displayed_selector] = image
    end
    return remapped
end

function _remap_edge_images(
        edge_images,
        display_names::AbstractDict{<:AbstractString, <:AbstractString},
    )::Any
    isnothing(edge_images) && return nothing
    remapped = Dict{Tuple{String, String}, Any}()
    for (selector, image) in pairs(edge_images)
        endpoints = selector isa Pair ? (first(selector), last(selector)) : selector
        displayed_selector = (
            _display_name(first(endpoints), display_names),
            _display_name(last(endpoints), display_names),
        )
        haskey(remapped, displayed_selector) && throw(
            CLIUsageError(
                "Edge image selectors become ambiguous after applying --nodelabels: " *
                    "multiple edges display as $(repr(displayed_selector)).",
            ),
        )
        remapped[displayed_selector] = image
    end
    return remapped
end

function _plot_options_with_display_names(
        plot_options::AbstractDict{Symbol},
        display_names::AbstractDict{<:AbstractString, <:AbstractString},
    )::PlotOptions
    displayed_options = PlotOptions(pairs(plot_options))
    if haskey(displayed_options, :nodeimages)
        displayed_options[:nodeimages] =
            _remap_node_images(displayed_options[:nodeimages], display_names)
    end
    if haskey(displayed_options, :edgeimages)
        displayed_options[:edgeimages] =
            _remap_edge_images(displayed_options[:edgeimages], display_names)
    end
    return displayed_options
end

function load_display_inputs(
        records::AbstractVector{SourceRecord},
        plot_options::AbstractDict{Symbol},
        node_label_path::Union{Nothing, AbstractString},
    )::DisplayInputs
    loaded_records = collect(records)
    loaded_options = PlotOptions(pairs(plot_options))
    isnothing(node_label_path) && return (
        records = loaded_records,
        plot_options = loaded_options,
    )

    display_names = load_node_labels(node_label_path)
    return (
        records = records_with_display_names(loaded_records, display_names),
        plot_options = _plot_options_with_display_names(loaded_options, display_names),
    )
end
