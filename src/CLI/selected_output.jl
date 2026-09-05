function _selected_newick(record::SourceRecord)::String
    converted = PhyloMakie.to_hybridnetwork(record.phylogeny)
    return PhyloNetworks.writenewick(converted)
end

function selected_records_text(
        records::AbstractVector{SourceRecord},
        format::Symbol,
    )::String
    format in SUPPORTED_SELECTED_OUTPUT_FORMATS || throw(
        ArgumentError("Unsupported selected output format: $(format)."),
    )
    newicks = _selected_newick.(records)
    format === :newick && return string(join(newicks, '\n'), '\n')

    lines = String["#NEXUS", "", "begin trees;"]
    for (index, newick) in enumerate(newicks)
        push!(lines, "  tree selected_$(index) = $(newick)")
    end
    append!(lines, ["end;", ""])
    return join(lines, '\n')
end

function write_selected_records(
        records::AbstractVector{SourceRecord},
        options::SelectedOutputOptions,
    )::Nothing
    isnothing(options.path) && return nothing
    output_text = selected_records_text(records, options.format)
    try
        mkpath(dirname(abspath(options.path)))
        open(options.path, "w") do io
            write(io, output_text)
        end
    catch error
        error isa InterruptException && rethrow()
        throw(
            CLIUsageError(
                "Cannot write selected records to $(repr(options.path)): " *
                    sprint(showerror, error),
            ),
        )
    end
    return nothing
end
