function _format_tag(format::Symbol)::PhyloMakie.AbstractPhylogenyFormat
    format === :newick && return PhyloMakie.NewickFormat()
    format === :nexus && return PhyloMakie.NexusFormat()
    throw(ArgumentError("Cannot create a format tag for $(format)."))
end

function _detected_format(text::AbstractString)::Symbol
    tree_block = r"(?im)^\s*begin\s+trees\s*;"
    return occursin(tree_block, text) ? :nexus : :newick
end

function _read_source(
        source::AbstractString,
        format::Symbol;
        stdin_io::IO = stdin,
    )::Vector{CLIPhylogeny}
    if source == "-"
        text = read(stdin_io, String)
        resolved_format = format === :auto ? _detected_format(text) : format
        return PhyloMakie.parsephylogenies(_format_tag(resolved_format), text)
    end

    isfile(source) || throw(ArgumentError("Input file does not exist: $(source)"))
    if format === :auto
        text = read(source, String)
        return PhyloMakie.parsephylogenies(_format_tag(_detected_format(text)), text)
    end
    return PhyloMakie.readphylogenies(_format_tag(format), source)
end

function load_records(
        input::InputOptions;
        stdin_io::IO = stdin,
    )::LoadResult
    if isempty(input.sources)
        throw(CLIUsageError("Input is required; use `-` for standard input."))
    end
    count(==("-"), input.sources) <= 1 || throw(
        CLIUsageError("Standard input (`-`) may be specified only once."),
    )

    records = SourceRecord[]
    warnings = LoadWarning[]
    for source in input.sources
        try
            loaded = _read_source(source, input.format; stdin_io)
            if isempty(loaded)
                push!(warnings, LoadWarning(source, "No phylogeny records found."))
                continue
            end
            append!(
                records,
                [
                    SourceRecord(phylogeny, String(source), record_index) for
                        (record_index, phylogeny) in enumerate(loaded)
                ],
            )
        catch error
            error isa InterruptException && rethrow()
            push!(warnings, LoadWarning(source, sprint(showerror, error)))
        end
    end
    return (records = records, warnings = warnings)
end

function emit_load_warnings(
        warnings::AbstractVector{LoadWarning};
        io::IO = stderr,
    )::Nothing
    for warning in warnings
        println(io, "Skipped $(warning.source): $(warning.message)")
    end
    return nothing
end

function _parse_index_token(token::AbstractString, record_count::Int)::UnitRange{Int}
    stripped = strip(token)
    isempty(stripped) && throw(CLIUsageError("Selection specifications cannot contain empty items."))
    range_parts = split(stripped, '-'; limit = 2)
    if length(range_parts) == 1
        index = _parse_positive_integer(first(range_parts), "--select")
        index <= record_count || throw(
            CLIUsageError("Selected record index $(index) exceeds the $(record_count) loaded records."),
        )
        return index:index
    end
    first_index = _parse_positive_integer(range_parts[1], "--select")
    last_index = _parse_positive_integer(range_parts[2], "--select")
    first_index <= last_index || throw(
        CLIUsageError("Selection range $(repr(stripped)) must be ascending."),
    )
    last_index <= record_count || throw(
        CLIUsageError("Selected record index $(last_index) exceeds the $(record_count) loaded records."),
    )
    return first_index:last_index
end

function selected_indices(specification::Union{Nothing, AbstractString}, record_count::Int)::Vector{Int}
    isnothing(specification) && return collect(1:record_count)
    lowercase(strip(specification)) == "all" && return collect(1:record_count)
    selected = Set{Int}()
    for token in split(specification, ',')
        union!(selected, _parse_index_token(token, record_count))
    end
    return sort!(collect(selected))
end

function select_records(
        records::AbstractVector{SourceRecord},
        selection::SelectionOptions,
    )::Vector{SourceRecord}
    indices = selected_indices(selection.indices, length(records))
    first_index = min(selection.skip, length(indices)) + 1
    indices = indices[first_index:end]
    if !isnothing(selection.head)
        indices = indices[begin:min(selection.head, length(indices))]
    elseif !isnothing(selection.tail)
        first_tail_index = max(length(indices) - selection.tail + 1, 1)
        indices = indices[first_tail_index:end]
    end
    return [records[index] for index in indices]
end

function display_source_label(source::AbstractString)::String
    source == "-" && return "standard input"
    basename_value = basename(source)
    return isempty(basename_value) ? String(source) : basename_value
end

function record_label(
        records::AbstractVector{SourceRecord},
        index::Integer,
    )::String
    record = records[index]
    source_label = display_source_label(record.source)
    return "$(index) / $(length(records)): $(source_label) [record $(record.record_index)]"
end
