function _output_format(path::AbstractString, requested::Symbol)::Symbol
    extension = lowercase(last(splitext(path)))
    inferred = isempty(extension) ? :png : Symbol(extension[2:end])
    if requested === :auto
        inferred in SUPPORTED_OUTPUT_FORMATS || throw(
            CLIUsageError(
                "Cannot infer a supported output format from $(repr(path)); use --output-format.",
            ),
        )
        return inferred
    end
    if !isempty(extension) && inferred !== requested
        throw(
            CLIUsageError(
                "Output path $(repr(path)) conflicts with --output-format $(requested).",
            ),
        )
    end
    return requested
end

function _normalized_output_path(path::AbstractString, requested::Symbol)::String
    format = _output_format(path, requested)
    extension = lowercase(last(splitext(path)))
    return isempty(extension) ? "$(path).$(format)" : String(path)
end

function _derived_output_paths(
        template::AbstractString,
        count::Int,
        requested::Symbol,
    )::Vector{String}
    if occursin("{index}", template)
        return [
            _normalized_output_path(replace(template, "{index}" => string(index)), requested)
                for index in 1:count
        ]
    elseif isdir(template) || endswith(template, Base.Filesystem.path_separator)
        return [
            _normalized_output_path(
                    joinpath(template, "phylogeny-$(lpad(index, 3, '0'))"),
                    requested,
                ) for index in 1:count
        ]
    end
    stem, extension = splitext(template)
    format = _output_format(template, requested)
    suffix = isempty(extension) ? ".$(format)" : extension
    return ["$(stem)-$(lpad(index, 3, '0'))$(suffix)" for index in 1:count]
end

function output_paths(command::RenderCommand, record_count::Int)::Vector{String}
    if command.multiple === :grid
        length(command.outputs) == 1 || throw(
            CLIUsageError("Grid rendering requires exactly one --output path."),
        )
        return [_normalized_output_path(only(command.outputs), command.output_format)]
    end
    if length(command.outputs) == record_count
        return [_normalized_output_path(path, command.output_format) for path in command.outputs]
    elseif length(command.outputs) == 1
        return _derived_output_paths(only(command.outputs), record_count, command.output_format)
    end
    throw(
        CLIUsageError(
            "File rendering requires either one output template or $(record_count) exact output paths.",
        ),
    )
end

function _record_title(record::SourceRecord)::String
    return "$(display_source_label(record.source)) [record $(record.record_index)]"
end

function build_render_figure(
        records::AbstractVector{SourceRecord},
        plot_options::AbstractDict{Symbol};
        columns::Union{Nothing, Int} = nothing,
        panel_size::Tuple{Int, Int} = (900, 700),
        show_titles::Bool = true,
    )::Makie.Figure
    isempty(records) && throw(ArgumentError("Cannot render an empty record collection."))
    column_count = isnothing(columns) ? ceil(Int, sqrt(length(records))) : columns
    column_count = min(column_count, length(records))
    row_count = cld(length(records), column_count)
    figure = Makie.Figure(
        size = (panel_size[1] * column_count, panel_size[2] * row_count),
    )
    for (index, record) in enumerate(records)
        row = cld(index, column_count)
        column = mod1(index, column_count)
        title = show_titles ? _record_title(record) : ""
        axis = Makie.Axis(figure[row, column]; title)
        PhyloMakie.phyloplot!(axis, record.phylogeny; plot_options...)
    end
    return figure
end

function _check_output_paths(paths::AbstractVector{<:AbstractString}, force::Bool)::Nothing
    duplicate = findfirst(path -> count(==(path), paths) > 1, paths)
    isnothing(duplicate) || throw(CLIUsageError("Output paths must be distinct: $(paths[duplicate])."))
    if !force
        existing = filter(ispath, paths)
        isempty(existing) || throw(
            CLIUsageError(
                "Output already exists: $(first(existing)). Pass --force to replace it.",
            ),
        )
    end
    return nothing
end

function _save_figure(
        path::AbstractString,
        figure::Makie.Figure,
        backend::Module,
    )::Nothing
    parent = dirname(path)
    isempty(parent) || mkpath(parent)
    Makie.save(String(path), figure; backend)
    return nothing
end

function render_records(
        records::AbstractVector{SourceRecord},
        command::RenderCommand,
        backend::Module,
    )::Vector{String}
    paths = output_paths(command, length(records))
    _check_output_paths(paths, command.force)
    if command.multiple === :grid
        figure = build_render_figure(
            records,
            command.plot_options;
            columns = command.columns,
            panel_size = command.panel_size,
            show_titles = command.show_titles,
        )
        _save_figure(only(paths), figure, backend)
        return paths
    end
    for (record, path) in zip(records, paths)
        figure = build_render_figure(
            [record],
            command.plot_options;
            columns = 1,
            panel_size = command.panel_size,
            show_titles = command.show_titles,
        )
        _save_figure(path, figure, backend)
    end
    return paths
end
