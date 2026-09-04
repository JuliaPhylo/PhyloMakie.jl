const DEMO_NEWICKS = (
    (
        "Demo network",
        "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
    ),
    ("Demo tree", "(A:1,(B:1,C:1):1);"),
)

function demo_records()::Vector{SourceRecord}
    return [
        SourceRecord(
                PhyloMakie.parsephylogeny(PhyloMakie.NewickFormat(), newick),
                source,
                record_index,
            ) for (record_index, (source, newick)) in enumerate(DEMO_NEWICKS)
    ]
end

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
        allow_demo::Bool = false,
        stdin_io::IO = stdin,
    )::LoadResult
    if isempty(input.sources)
        allow_demo && return (records = demo_records(), warnings = LoadWarning[])
        throw(CLIUsageError("At least one input path is required; use `-` for standard input."))
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

function _matches_selection(record::SourceRecord, selection::SelectionOptions)::Bool
    phylogeny = record.phylogeny
    labels = Set(PhyloMakie.tip_labels(phylogeny))
    all(taxon -> taxon in labels, selection.taxa) || return false

    tree = PhyloMakie.is_tree(phylogeny)
    selection.tree_type === :tree && !tree && return false
    selection.tree_type === :network && tree && return false

    rooted = PhyloMakie.is_rooted(phylogeny)
    selection.rootedness === :rooted && !rooted && return false
    selection.rootedness === :unrooted && rooted && return false

    tips = PhyloMakie.taxon_count(phylogeny)
    !isnothing(selection.minimum_tips) && tips < selection.minimum_tips && return false
    !isnothing(selection.maximum_tips) && tips > selection.maximum_tips && return false
    return true
end

function select_records(
        records::AbstractVector{SourceRecord},
        selection::SelectionOptions,
    )::Vector{SourceRecord}
    indices = selected_indices(selection.indices, length(records))
    return [records[index] for index in indices if _matches_selection(records[index], selection)]
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
