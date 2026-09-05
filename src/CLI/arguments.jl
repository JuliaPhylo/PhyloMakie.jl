const SUPPORTED_INPUT_FORMATS = (:newick, :nexus, :auto)
const SUPPORTED_OUTPUT_FORMATS = (:auto, :png, :svg, :pdf)
const SUPPORTED_SELECTED_OUTPUT_FORMATS = (:newick, :nexus)
const SUPPORTED_MULTIPLE_MODES = (:grid, :files)
const SUPPORTED_CLI_PLOT_ATTRIBUTES = (
    :useedgelength,
    :showtiplabel,
    :shownodelabel,
    :shownodenumber,
    :showedgelength,
    :showedgenumber,
    :showgamma,
    :edgecolor,
    :defaultedgecolor,
    :majorhybridedgecolor,
    :minorhybridedgecolor,
    :edgewidth,
    :minorlinetype,
    :arrowlen,
    :nodeimages,
    :edgeimages,
    :edgenumbercolor,
    :tipoffset,
    :tipcex,
    :xlim,
    :ylim,
    :style,
)

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

function _parse_nonnegative_integer(value::AbstractString, option::AbstractString)::Int
    parsed = tryparse(Int, value)
    isnothing(parsed) && throw(
        CLIUsageError("Option $(option) requires a nonnegative integer; received $(repr(value))."),
    )
    parsed >= 0 || throw(
        CLIUsageError("Option $(option) requires a nonnegative integer; received $(repr(value))."),
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

function _is_cli_node_image_mapping(value)::Bool
    isnothing(value) && return true
    value isa AbstractDict || return false
    return all(pairs(value)) do (selector, image)
        selector isa Union{AbstractString, Symbol} &&
            (image isa AbstractString || isnothing(image) || ismissing(image))
    end
end

function _is_cli_edge_image_selector(selector)::Bool
    endpoints = if selector isa Pair
        (first(selector), last(selector))
    elseif selector isa Tuple && length(selector) == 2
        selector
    else
        return false
    end
    return all(endpoint -> endpoint isa Union{AbstractString, Symbol}, endpoints)
end

function _is_cli_edge_image_mapping(value)::Bool
    isnothing(value) && return true
    value isa AbstractDict || return false
    return all(pairs(value)) do (selector, image)
        _is_cli_edge_image_selector(selector) &&
            (image isa AbstractString || isnothing(image) || ismissing(image))
    end
end

function _validate_cli_plot_value(name::Symbol, value)
    if name === :nodeimages && !_is_cli_node_image_mapping(value)
        throw(
            CLIUsageError(
                "nodeimages requires Dict(\"NODE\" => \"PATH_OR_URL\", ...), or nothing.",
            ),
        )
    elseif name === :edgeimages && !_is_cli_edge_image_mapping(value)
        throw(
            CLIUsageError(
                "edgeimages requires Dict((\"PARENT\", \"CHILD\") => \"PATH_OR_URL\", ...), or nothing.",
            ),
        )
    end
    return value
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
    name in SUPPORTED_CLI_PLOT_ATTRIBUTES || throw(
        CLIUsageError(
            "Unknown or unsupported CLI plot attribute $(name_text). Supported attributes: " *
                join(string.(SUPPORTED_CLI_PLOT_ATTRIBUTES), ", ") * ".",
        ),
    )
    expression = try
        Meta.parse(value_text)
    catch error
        throw(CLIUsageError("Cannot parse value for plot option $(name_text): $(sprint(showerror, error))."))
    end
    return name => _validate_cli_plot_value(name, _decode_plot_literal(expression))
end

function _build_input_options(
        sources::Vector{String},
        format::Symbol,
        indices::Union{Nothing, String},
        head::Union{Nothing, Int},
        tail::Union{Nothing, Int},
        skip::Int,
        stride::Int,
    )::InputOptions
    selection = SelectionOptions(indices, head, tail, skip, stride)
    return InputOptions(sources, format, selection)
end

function parse_command(args::AbstractVector{<:AbstractString})::AbstractCLICommand
    isempty(args) && throw(
        CLIUsageError("Input is required. Run `phylomakie --help` for usage."),
    )
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
    head = nothing
    tail = nothing
    skip = 0
    stride = 1
    selected_output_path = nothing
    selected_output_format = :newick
    selected_output_format_set = false
    plot_options = PlotOptions()
    node_label_path = nothing
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
        elseif argument == "--head"
            head = _parse_nonnegative_integer(_option_value(args, index, argument), argument)
            index += 1
        elseif argument == "--tail"
            tail = _parse_nonnegative_integer(_option_value(args, index, argument), argument)
            index += 1
        elseif argument == "--skip"
            skip = _parse_nonnegative_integer(_option_value(args, index, argument), argument)
            index += 1
        elseif argument == "--stride"
            stride = _parse_positive_integer(_option_value(args, index, argument), argument)
            index += 1
        elseif argument == "--selected-output-file"
            selected_output_path = _option_value(args, index, argument)
            index += 1
        elseif argument == "--selected-output-format"
            value = _option_value(args, index, argument)
            selected_output_format = _parse_choice(
                value,
                SUPPORTED_SELECTED_OUTPUT_FORMATS,
                argument,
            )
            selected_output_format_set = true
            index += 1
        elseif argument in ("-p", "--plot")
            command in (:view, :render) || throw(
                CLIUsageError("Option $(argument) is only valid for view and render."),
            )
            assignment = parse_plot_assignment(_option_value(args, index, argument))
            plot_options[first(assignment)] = last(assignment)
            index += 1
        elseif argument == "--node-labels"
            command in (:view, :render) || throw(
                CLIUsageError("Option --node-labels is only valid for view and render."),
            )
            node_label_path = _option_value(args, index, argument)
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

    isempty(sources) && throw(
        CLIUsageError("Input is required; use `-` for standard input."),
    )
    input = _build_input_options(
        sources,
        format,
        indices,
        head,
        tail,
        skip,
        stride,
    )
    isnothing(selected_output_path) && selected_output_format_set && throw(
        CLIUsageError("--selected-output-format requires --selected-output-file PATH."),
    )
    selected_output = SelectedOutputOptions(selected_output_path, selected_output_format)
    command === :view && return ViewCommand(
        input,
        selected_output,
        plot_options,
        node_label_path,
        size,
    )
    command === :inspect && return InspectCommand(
        input,
        selected_output,
        min(verbosity, 2),
        taxa_only,
    )
    isempty(outputs) && throw(CLIUsageError("render requires at least one --output PATH."))
    return RenderCommand(
        input,
        selected_output,
        plot_options,
        node_label_path,
        outputs,
        output_format,
        multiple,
        columns,
        size,
        show_titles,
        force,
    )
end
