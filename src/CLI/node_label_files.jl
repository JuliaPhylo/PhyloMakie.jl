const NODE_LABEL_DELIMITERS = Dict(
    ".csv" => ',',
    ".tsv" => '\t',
)

function _node_label_delimiter(path::AbstractString)::Char
    extension = lowercase(last(splitext(path)))
    haskey(NODE_LABEL_DELIMITERS, extension) || throw(
        CLIUsageError(
            "Node label file $(repr(path)) must have a .csv or .tsv extension.",
        ),
    )
    return NODE_LABEL_DELIMITERS[extension]
end

function load_node_labels(path::AbstractString)::DataFrames.DataFrame
    isfile(path) || throw(CLIUsageError("Node label file does not exist: $(path)."))
    delimiter = _node_label_delimiter(path)
    table = try
        CSV.read(
            String(path),
            DataFrames.DataFrame;
            delim = delimiter,
            strict = true,
            types = (index, _) -> index == 1 ? Int : index == 2 ? String : nothing,
        )
    catch error
        error isa InterruptException && rethrow()
        throw(
            CLIUsageError(
                "Cannot read node label file $(repr(path)): $(sprint(showerror, error))",
            ),
        )
    end

    column_names = DataFrames.names(table)
    column_names == ["number", "label"] || throw(
        CLIUsageError(
            "Node label file $(repr(path)) must have exactly the columns number,label; " *
                "found $(join(column_names, ",")).",
        ),
    )
    numbers = table[!, :number]
    any(ismissing, numbers) && throw(
        CLIUsageError("Node label file $(repr(path)) contains a missing node number."),
    )
    allunique(numbers) || throw(
        CLIUsageError("Node label file $(repr(path)) contains duplicate node numbers."),
    )
    return table
end

function load_plot_options(
        plot_options::AbstractDict{Symbol},
        node_label_path::Union{Nothing, AbstractString},
    )::PlotOptions
    loaded = PlotOptions(pairs(plot_options))
    if !isnothing(node_label_path)
        loaded[:nodelabel] = load_node_labels(node_label_path)
    end
    return loaded
end
