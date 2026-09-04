const SUPPORTED_INPUT_FORMATS = (:newick, :nexus, :auto)
const SUPPORTED_TREE_TYPES = (:any, :tree, :network)
const SUPPORTED_ROOTEDNESS = (:any, :rooted, :unrooted)
const SUPPORTED_OUTPUT_FORMATS = (:auto, :png, :svg, :pdf)
const SUPPORTED_MULTIPLE_MODES = (:grid, :files)

const GENERAL_HELP = """
Usage: phylomakie <command> [options] [INPUT ...]

Commands:
  view       Display selected phylogenies in an interactive viewer.
  inspect    Summarize source and phylogeny metadata.
  render     Render selected phylogenies to one or more files.

Run `phylomakie <command> --help` for command-specific options.
"""

const COMMON_HELP = """
Input and selection options:
  -f, --input-format FORMAT   newick (default), nexus, or auto.
  -s, --select SPEC           Global record indices, for example 1,3-5.
      --taxon NAME            Keep records containing NAME; repeatable.
      --tree-type TYPE        any (default), tree, or network.
      --rootedness VALUE      any (default), rooted, or unrooted.
      --min-tips N            Keep records with at least N tips.
      --max-tips N            Keep records with at most N tips.

Use `-` as an input path to read from standard input.
"""

const VIEW_HELP = """
Usage: phylomakie view [options] [INPUT ...]

Display selected phylogenies in the interactive viewer. With no input, the
viewer opens two built-in demonstrations.

  -p, --plot NAME=VALUE       Set a PhyloPlot attribute; repeatable.
      --size WIDTHxHEIGHT     Window size (default: 1700x950).
  -h, --help                  Show this help.

$(COMMON_HELP)
"""

const INSPECT_HELP = """
Usage: phylomakie inspect [options] INPUT ...

  -v, --verbose               Add record detail; repeat for full listings.
      --taxa-only             Print sorted unique taxon names only.
  -h, --help                  Show this help.

$(COMMON_HELP)
"""

const RENDER_HELP = """
Usage: phylomakie render [options] INPUT ...

  -o, --output PATH           Output path; repeat for exact per-record paths.
      --output-format FORMAT  auto (default), png, svg, or pdf.
      --multiple MODE         grid (default) or files.
      --columns N             Grid column count.
      --size WIDTHxHEIGHT     Per-panel size (default: 900x700).
      --no-titles             Omit source and record titles.
      --force                 Replace existing output files.
  -p, --plot NAME=VALUE       Set a PhyloPlot attribute; repeatable.
  -h, --help                  Show this help.

$(COMMON_HELP)
"""

help_text(::Val{:general})::String = GENERAL_HELP
help_text(::Val{:view})::String = VIEW_HELP
help_text(::Val{:inspect})::String = INSPECT_HELP
help_text(::Val{:render})::String = RENDER_HELP

function help_text(topic::Symbol)::String
    topic in (:general, :view, :inspect, :render) || return GENERAL_HELP
    return help_text(Val(topic))
end

function _option_value(args::AbstractVector{<:AbstractString}, index::Int, option::AbstractString)::String
    index < length(args) || throw(CLIUsageError("Option $(option) requires a value."))
    return String(args[index + 1])
end

function _parse_choice(value::AbstractString, choices::Tuple, option::AbstractString)::Symbol
    choice = Symbol(lowercase(strip(value)))
    choice in choices || throw(
        CLIUsageError(
            "Option $(option) must be one of $(join(string.(choices), ", ")); received $(repr(value)).",
        ),
    )
    return choice
end

function _parse_positive_integer(value::AbstractString, option::AbstractString)::Int
    parsed = tryparse(Int, value)
    isnothing(parsed) && throw(
        CLIUsageError("Option $(option) requires a positive integer; received $(repr(value))."),
    )
    parsed > 0 || throw(
        CLIUsageError("Option $(option) requires a positive integer; received $(repr(value))."),
    )
    return parsed
end

function _parse_size(value::AbstractString, option::AbstractString)::Tuple{Int, Int}
    parts = split(lowercase(strip(value)), 'x')
    length(parts) == 2 || throw(
        CLIUsageError("Option $(option) requires WIDTHxHEIGHT; received $(repr(value))."),
    )
    width = _parse_positive_integer(parts[1], option)
    height = _parse_positive_integer(parts[2], option)
    return (width, height)
end

function _decode_plot_literal(expression)
    if expression isa Number || expression isa AbstractString || expression isa Bool
        return expression
    elseif expression isa QuoteNode
        expression.value isa Symbol || throw(CLIUsageError("Only symbol quote literals are supported."))
        return expression.value
    elseif expression isa Symbol
        expression === :nothing && return nothing
        expression === :missing && return missing
        return String(expression)
    elseif expression isa Expr && expression.head === :tuple
        return tuple((_decode_plot_literal(argument) for argument in expression.args)...)
    elseif expression isa Expr && expression.head === :vect
        return [_decode_plot_literal(argument) for argument in expression.args]
    elseif expression isa Expr && expression.head === :call && expression.args[1] === :- && length(expression.args) == 2
        value = _decode_plot_literal(expression.args[2])
        value isa Number || throw(CLIUsageError("Unary minus requires a numeric literal."))
        return -value
    elseif expression isa Expr && expression.head === :call && expression.args[1] === Symbol("=>") && length(expression.args) == 3
        return _decode_plot_literal(expression.args[2]) => _decode_plot_literal(expression.args[3])
    elseif expression isa Expr && expression.head === :call && expression.args[1] === :Dict
        pairs = [_decode_plot_literal(argument) for argument in expression.args[2:end]]
        all(pair -> pair isa Pair, pairs) || throw(
            CLIUsageError("Dict plot values must contain `key => value` pairs."),
        )
        return Dict(pairs)
    end
    throw(
        CLIUsageError(
            "Plot values must be literals, symbols, arrays, tuples, or Dict(key => value, ...).",
        ),
    )
end

# Makie plot attributes are intentionally heterogeneous. This dictionary is
# confined to the CLI boundary and is splatted directly into the public recipe.
function parse_plot_assignment(text::AbstractString)::Pair{Symbol, Any}
    delimiter = findfirst(==('='), text)
    isnothing(delimiter) && throw(
        CLIUsageError("Plot option $(repr(text)) must use NAME=VALUE syntax."),
    )
    name_text = strip(text[firstindex(text):prevind(text, delimiter)])
    value_text = strip(text[nextind(text, delimiter):lastindex(text)])
    isempty(name_text) && throw(CLIUsageError("A plot option name cannot be empty."))
    isempty(value_text) && throw(CLIUsageError("Plot option $(name_text) requires a value."))
    name = Symbol(name_text)
    name in PhyloMakie.SUPPORTED_PHYLOPLOT_ATTRIBUTES || throw(
        CLIUsageError(
            "Unknown PhyloPlot attribute $(name_text). Supported attributes: " *
                join(string.(PhyloMakie.SUPPORTED_PHYLOPLOT_ATTRIBUTES), ", ") * ".",
        ),
    )
    expression = try
        Meta.parse(value_text)
    catch error
        throw(CLIUsageError("Cannot parse value for plot option $(name_text): $(sprint(showerror, error))."))
    end
    return name => _decode_plot_literal(expression)
end

function _build_input_options(
        sources::Vector{String},
        format::Symbol,
        indices::Union{Nothing, String},
        taxa::Vector{String},
        tree_type::Symbol,
        rootedness::Symbol,
        minimum_tips::Union{Nothing, Int},
        maximum_tips::Union{Nothing, Int},
    )::InputOptions
    if !isnothing(minimum_tips) && !isnothing(maximum_tips) && minimum_tips > maximum_tips
        throw(CLIUsageError("--min-tips cannot exceed --max-tips."))
    end
    selection = SelectionOptions(
        indices,
        taxa,
        tree_type,
        rootedness,
        minimum_tips,
        maximum_tips,
    )
    return InputOptions(sources, format, selection)
end

function parse_command(args::AbstractVector{<:AbstractString})::AbstractCLICommand
    isempty(args) && return HelpCommand(:general)
    first_argument = String(first(args))
    first_argument in ("-h", "--help", "help") && return HelpCommand(:general)
    command = Symbol(lowercase(first_argument))
    command in (:view, :inspect, :render) || throw(
        CLIUsageError("Unknown command $(repr(first_argument)).\n\n$(GENERAL_HELP)"),
    )
    return _parse_command_options(command, args[2:end])
end

function _parse_command_options(
        command::Symbol,
        args::AbstractVector{<:AbstractString},
    )::AbstractCLICommand
    sources = String[]
    format = :newick
    indices = nothing
    taxa = String[]
    tree_type = :any
    rootedness = :any
    minimum_tips = nothing
    maximum_tips = nothing
    plot_options = PlotOptions()
    size = command === :view ? (1700, 950) : (900, 700)
    verbosity = 0
    taxa_only = false
    outputs = String[]
    output_format = :auto
    multiple = :grid
    columns = nothing
    show_titles = true
    force = false
    positional_only = false

    index = 1
    while index <= length(args)
        argument = String(args[index])
        if positional_only
            push!(sources, argument)
        elseif argument == "--"
            positional_only = true
        elseif argument in ("-h", "--help")
            return HelpCommand(command)
        elseif argument in ("-f", "--input-format")
            value = _option_value(args, index, argument)
            format = _parse_choice(value, SUPPORTED_INPUT_FORMATS, argument)
            index += 1
        elseif argument in ("-s", "--select")
            indices = _option_value(args, index, argument)
            index += 1
        elseif argument == "--taxon"
            push!(taxa, _option_value(args, index, argument))
            index += 1
        elseif argument == "--tree-type"
            value = _option_value(args, index, argument)
            tree_type = _parse_choice(value, SUPPORTED_TREE_TYPES, argument)
            index += 1
        elseif argument == "--rootedness"
            value = _option_value(args, index, argument)
            rootedness = _parse_choice(value, SUPPORTED_ROOTEDNESS, argument)
            index += 1
        elseif argument == "--min-tips"
            minimum_tips = _parse_positive_integer(_option_value(args, index, argument), argument)
            index += 1
        elseif argument == "--max-tips"
            maximum_tips = _parse_positive_integer(_option_value(args, index, argument), argument)
            index += 1
        elseif argument in ("-p", "--plot")
            command in (:view, :render) || throw(
                CLIUsageError("Option $(argument) is only valid for view and render."),
            )
            assignment = parse_plot_assignment(_option_value(args, index, argument))
            plot_options[first(assignment)] = last(assignment)
            index += 1
        elseif argument == "--size"
            command in (:view, :render) || throw(
                CLIUsageError("Option --size is only valid for view and render."),
            )
            size = _parse_size(_option_value(args, index, argument), argument)
            index += 1
        elseif argument in ("-v", "--verbose")
            command === :inspect || throw(CLIUsageError("Option $(argument) is only valid for inspect."))
            verbosity += 1
        elseif startswith(argument, "-vv") && all(==('v'), argument[2:end])
            command === :inspect || throw(CLIUsageError("Option $(argument) is only valid for inspect."))
            verbosity += length(argument) - 1
        elseif argument == "--taxa-only"
            command === :inspect || throw(CLIUsageError("Option --taxa-only is only valid for inspect."))
            taxa_only = true
        elseif argument in ("-o", "--output")
            command === :render || throw(CLIUsageError("Option $(argument) is only valid for render."))
            push!(outputs, _option_value(args, index, argument))
            index += 1
        elseif argument == "--output-format"
            command === :render || throw(CLIUsageError("Option --output-format is only valid for render."))
            value = _option_value(args, index, argument)
            output_format = _parse_choice(value, SUPPORTED_OUTPUT_FORMATS, argument)
            index += 1
        elseif argument == "--multiple"
            command === :render || throw(CLIUsageError("Option --multiple is only valid for render."))
            value = _option_value(args, index, argument)
            multiple = _parse_choice(value, SUPPORTED_MULTIPLE_MODES, argument)
            index += 1
        elseif argument == "--columns"
            command === :render || throw(CLIUsageError("Option --columns is only valid for render."))
            columns = _parse_positive_integer(_option_value(args, index, argument), argument)
            index += 1
        elseif argument == "--no-titles"
            command === :render || throw(CLIUsageError("Option --no-titles is only valid for render."))
            show_titles = false
        elseif argument == "--force"
            command === :render || throw(CLIUsageError("Option --force is only valid for render."))
            force = true
        elseif startswith(argument, '-') && argument != "-"
            throw(CLIUsageError("Unknown option $(repr(argument)) for $(command)."))
        else
            push!(sources, argument)
        end
        index += 1
    end

    input = _build_input_options(
        sources,
        format,
        indices,
        taxa,
        tree_type,
        rootedness,
        minimum_tips,
        maximum_tips,
    )
    command === :view && return ViewCommand(input, plot_options, size)
    command === :inspect && return InspectCommand(input, min(verbosity, 2), taxa_only)
    isempty(outputs) && throw(CLIUsageError("render requires at least one --output PATH."))
    return RenderCommand(
        input,
        plot_options,
        outputs,
        output_format,
        multiple,
        columns,
        size,
        show_titles,
        force,
    )
end
