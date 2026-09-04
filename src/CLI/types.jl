const CLIPhylogeny = PhyloMakie.LineageNetwork{Nothing, Nothing, Nothing}
const PlotOptions = Dict{Symbol, Any}

struct CLIUsageError <: Exception
    message::String
end

Base.showerror(io::IO, error::CLIUsageError)::Nothing = print(io, error.message)

struct SourceRecord
    phylogeny::CLIPhylogeny
    source::String
    record_index::Int
end

struct LoadWarning
    source::String
    message::String
end

const LoadResult = NamedTuple{
    (:records, :warnings),
    Tuple{Vector{SourceRecord}, Vector{LoadWarning}},
}

struct SelectionOptions
    indices::Union{Nothing, String}
    head::Union{Nothing, Int}
    tail::Union{Nothing, Int}
    skip::Int
end

struct InputOptions
    sources::Vector{String}
    format::Symbol
    selection::SelectionOptions
end

abstract type AbstractCLICommand end

struct HelpCommand <: AbstractCLICommand
    topic::Symbol
end

struct ViewCommand{TOptions <: AbstractDict{Symbol}} <: AbstractCLICommand
    input::InputOptions
    plot_options::TOptions
    size::Tuple{Int, Int}
end

struct InspectCommand <: AbstractCLICommand
    input::InputOptions
    verbosity::Int
    taxa_only::Bool
end

struct RenderCommand{TOptions <: AbstractDict{Symbol}} <: AbstractCLICommand
    input::InputOptions
    plot_options::TOptions
    outputs::Vector{String}
    output_format::Symbol
    multiple::Symbol
    columns::Union{Nothing, Int}
    panel_size::Tuple{Int, Int}
    show_titles::Bool
    force::Bool
end

struct RecordStatistics
    source::String
    record_index::Int
    tree::Bool
    rooted::Bool
    node_count::Int
    edge_count::Int
    tip_labels::Vector{String}
    hybrid_node_count::Int
    branch_length_coverage::Symbol
    branch_length_count::Int
    branch_length_sum::Union{Nothing, Float64}
    branch_length_minimum::Union{Nothing, Float64}
    branch_length_mean::Union{Nothing, Float64}
    branch_length_maximum::Union{Nothing, Float64}
end

struct CollectionStatistics
    sources::Vector{String}
    records::Vector{RecordStatistics}
    taxa::Vector{String}
end

# GLMakie callbacks update this local state as users manipulate controls.
mutable struct ViewerState
    current_index::Int
    useedgelength::Bool
    showtiplabel::Bool
    shownodelabel::Bool
    shownodenumber::Bool
    showedgelength::Bool
    showedgenumber::Bool
    showgamma::Bool
    edgecolor::String
    defaultedgecolor::Union{Nothing, String}
    majorhybridedgecolor::String
    minorhybridedgecolor::String
    edgewidth::Float64
    minorlinetype::Union{Nothing, String}
    arrowlen::Union{Nothing, Float64}
    nodecex::Float64
    edgecex::Float64
    nodelabelcolor::String
    edgelabelcolor::String
    edgenumbercolor::String
    style::Symbol
end

struct Viewer{TFigure, TAxis, TPlot, TLabel}
    figure::TFigure
    axis::TAxis
    plot::TPlot
    state::ViewerState
    current_label::TLabel
    status_label::TLabel
end
