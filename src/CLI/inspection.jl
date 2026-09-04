function record_statistics(record::SourceRecord)::RecordStatistics
    phylogeny = record.phylogeny
    lengths = collect(skipmissing(PhyloMakie.branch_length.(PhyloMakie.edges(phylogeny))))
    edge_total = PhyloMakie.edge_count(phylogeny)
    coverage = if isempty(lengths)
        :none
    elseif length(lengths) == edge_total
        :complete
    else
        :partial
    end
    length_sum = isempty(lengths) ? nothing : sum(lengths)
    length_minimum = isempty(lengths) ? nothing : minimum(lengths)
    length_mean = isempty(lengths) ? nothing : sum(lengths) / length(lengths)
    length_maximum = isempty(lengths) ? nothing : maximum(lengths)
    return RecordStatistics(
        record.source,
        record.record_index,
        PhyloMakie.is_tree(phylogeny),
        PhyloMakie.is_rooted(phylogeny),
        PhyloMakie.node_count(phylogeny),
        edge_total,
        sort!(PhyloMakie.tip_labels(phylogeny)),
        count(PhyloMakie.is_hybrid, PhyloMakie.nodes(phylogeny)),
        coverage,
        length(lengths),
        length_sum,
        length_minimum,
        length_mean,
        length_maximum,
    )
end

function collection_statistics(records::AbstractVector{SourceRecord})::CollectionStatistics
    statistics = record_statistics.(records)
    sources = unique(record.source for record in records)
    taxa = sort!(unique(Iterators.flatten(statistic.tip_labels for statistic in statistics)))
    return CollectionStatistics(collect(sources), statistics, collect(taxa))
end

function _range_summary(values::AbstractVector{<:Real})::String
    isempty(values) && return "not available"
    average = sum(values) / length(values)
    return "min $(_format_number(minimum(values))), mean $(_format_number(average)), max $(_format_number(maximum(values)))"
end

function _format_number(value::Real)::String
    integer_value = round(Int, value)
    isapprox(value, integer_value; atol = eps(Float64) * 8) && return string(integer_value)
    return string(round(Float64(value); digits = 6))
end

function _format_optional_number(value::Union{Nothing, Real})::String
    return isnothing(value) ? "not available" : _format_number(value)
end

function _write_summary(io::IO, statistics::CollectionStatistics)::Nothing
    records = statistics.records
    tip_counts = Int[length(record.tip_labels) for record in records]
    tree_count = count(record -> record.tree, records)
    rooted_count = count(record -> record.rooted, records)
    complete_count = count(record -> record.branch_length_coverage === :complete, records)
    partial_count = count(record -> record.branch_length_coverage === :partial, records)
    none_count = count(record -> record.branch_length_coverage === :none, records)
    complete_lengths = Float64[
        record.branch_length_sum for record in records
            if record.branch_length_coverage === :complete && !isnothing(record.branch_length_sum)
    ]
    observed_edge_count = sum(record.branch_length_count for record in records)

    println(io, "Sources: $(length(statistics.sources))")
    println(io, "Phylogenies: $(length(records))")
    println(io, "Trees: $(tree_count)")
    println(io, "Networks: $(length(records) - tree_count)")
    println(io, "Rooted: $(rooted_count)")
    println(io, "Unrooted: $(length(records) - rooted_count)")
    println(io, "Unique taxa: $(length(statistics.taxa))")
    println(io, "Tips per phylogeny: $(_range_summary(tip_counts))")
    println(
        io,
        "Branch-length coverage: $(complete_count) complete, $(partial_count) partial, $(none_count) absent",
    )
    println(io, "Complete tree length: $(_range_summary(complete_lengths))")
    if observed_edge_count > 0
        edge_minima = Float64[
            record.branch_length_minimum for record in records
                if !isnothing(record.branch_length_minimum)
        ]
        edge_maxima = Float64[
            record.branch_length_maximum for record in records
                if !isnothing(record.branch_length_maximum)
        ]
        observed_length_sum = sum(
            record.branch_length_sum for record in records if !isnothing(record.branch_length_sum)
        )
        println(
            io,
            "Observed edge lengths: min $(_format_number(minimum(edge_minima))), " *
                "mean $(_format_number(observed_length_sum / observed_edge_count)), " *
                "max $(_format_number(maximum(edge_maxima)))",
        )
    else
        println(io, "Observed edge lengths: not available")
    end
    return nothing
end

function _write_record_details(
        io::IO,
        statistics::CollectionStatistics;
        list_taxa::Bool,
    )::Nothing
    println(io, "Records:")
    for (index, record) in enumerate(statistics.records)
        topology = record.tree ? "tree" : "network"
        rootedness = record.rooted ? "rooted" : "unrooted"
        source = display_source_label(record.source)
        println(
            io,
            "  $(index). $(source) [record $(record.record_index)]: $(topology), $(rootedness), " *
                "$(length(record.tip_labels)) tips, $(record.node_count) nodes, $(record.edge_count) edges, " *
                "$(record.hybrid_node_count) hybrid nodes, branch lengths $(record.branch_length_coverage)",
        )
        println(io, "     Branch-length sum: $(_format_optional_number(record.branch_length_sum))")
        if record.branch_length_count > 0
            println(
                io,
                "     Observed edge lengths: min $(_format_optional_number(record.branch_length_minimum)), " *
                    "mean $(_format_optional_number(record.branch_length_mean)), " *
                    "max $(_format_optional_number(record.branch_length_maximum))",
            )
        end
        if list_taxa
            println(io, "     Taxa: $(join(record.tip_labels, ", "))")
        end
    end
    return nothing
end

function write_inspection(
        io::IO,
        statistics::CollectionStatistics;
        verbosity::Integer = 0,
        taxa_only::Bool = false,
    )::Nothing
    if taxa_only
        foreach(taxon -> println(io, taxon), statistics.taxa)
        return nothing
    end
    _write_summary(io, statistics)
    verbosity > 0 && _write_record_details(io, statistics; list_taxa = verbosity > 1)
    return nothing
end
