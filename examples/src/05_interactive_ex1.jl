using GLMakie
using PhyloMakie: phyloplot!
using PhyloNetworks: HybridNetwork, readmultinewick, readnewick, readnexus_treeblock

struct ViewerRecord
    network::HybridNetwork
    source::String
    record_index::Int
end

struct LoadWarning
    path::String
    message::String
end

const LoadResult = NamedTuple{
    (:records, :warnings),
    Tuple{Vector{ViewerRecord}, Vector{LoadWarning}},
}

# This state is owned by GLMakie callbacks, so localized mutation keeps widget
# handlers small while public plot updates still go through Makie.update!.
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
    defaultedgecolor::Union{Nothing,String}
    majorhybridedgecolor::String
    minorhybridedgecolor::String
    edgewidth::Float64
    minorlinetype::Union{Nothing,String}
    arrowlen::Union{Nothing,Float64}
    nodecex::Float64
    edgecex::Float64
    nodelabelcolor::String
    edgelabelcolor::String
    edgenumbercolor::String
    style::Symbol
end

function default_viewer_state()::ViewerState
    return ViewerState(
        1,
        false,
        true,
        false,
        false,
        false,
        false,
        false,
        "black",
        nothing,
        "deepskyblue4",
        "deepskyblue",
        1.0,
        nothing,
        nothing,
        1.0,
        1.0,
        "black",
        "black",
        "grey",
        :fulltree,
    )
end

function viewer_attributes(state::ViewerState)
    return (
        useedgelength = state.useedgelength,
        showtiplabel = state.showtiplabel,
        shownodelabel = state.shownodelabel,
        shownodenumber = state.shownodenumber,
        showedgelength = state.showedgelength,
        showedgenumber = state.showedgenumber,
        showgamma = state.showgamma,
        edgecolor = state.edgecolor,
        defaultedgecolor = state.defaultedgecolor,
        majorhybridedgecolor = state.majorhybridedgecolor,
        minorhybridedgecolor = state.minorhybridedgecolor,
        edgewidth = state.edgewidth,
        minorlinetype = state.minorlinetype,
        arrowlen = state.arrowlen,
        nodecex = state.nodecex,
        edgecex = state.edgecex,
        nodelabelcolor = state.nodelabelcolor,
        edgelabelcolor = state.edgelabelcolor,
        edgenumbercolor = state.edgenumbercolor,
        style = state.style,
    )
end

function apply_viewer_state!(plot_handle, state::ViewerState)::Nothing
    Makie.update!(plot_handle; viewer_attributes(state)...)
    return nothing
end

function parse_positive_float(text::AbstractString, field_label::AbstractString)::Float64
    value = tryparse(Float64, strip(text))
    if isnothing(value) || !isfinite(value) || value <= 0
        throw(ArgumentError("$(field_label) must be a finite positive number."))
    end
    return value
end

function parse_optional_positive_float(
    text::AbstractString,
    field_label::AbstractString,
)::Union{Nothing,Float64}
    stripped = strip(text)
    isempty(stripped) && return nothing
    return parse_positive_float(stripped, field_label)
end

function parse_color_text(
    text::AbstractString,
    allow_nothing::Bool,
)::Union{Nothing,String}
    stripped = String(strip(text))
    if isempty(stripped)
        allow_nothing && return nothing
        throw(ArgumentError("Color text cannot be empty."))
    end

    try
        Makie.to_color(stripped)
    catch
        throw(ArgumentError("Invalid color text: $(stripped)."))
    end
    return stripped
end

function demo_records()::Vector{ViewerRecord}
    demo_newicks = (
        ("Demo tree", "(A:1,(B:1,C:1):1);"),
        (
            "Demo network",
            "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
        ),
    )
    return [
        ViewerRecord(readnewick(newick), source, index) for
            (index, (source, newick)) in enumerate(demo_newicks)
    ]
end

function contains_nexus_treeblock(path::AbstractString)::Bool
    treeblock_marker = r"^\s*begin\s+trees\s*;"i
    return open(path, "r") do input
        for line in eachline(input)
            occursin(treeblock_marker, line) && return true
        end
        return false
    end
end

function load_records_from_file(path::AbstractString)::Vector{HybridNetwork}
    isfile(path) || throw(ArgumentError("File does not exist: $(path)"))

    if contains_nexus_treeblock(path)
        return collect(readnexus_treeblock(path))
    end

    records = collect(readmultinewick(path, false))
    isempty(records) || return records
    return HybridNetwork[readnewick(path)]
end

function load_records(paths::AbstractVector{<:AbstractString})::LoadResult
    if isempty(paths)
        return (records = demo_records(), warnings = LoadWarning[])
    end

    records = ViewerRecord[]
    warnings = LoadWarning[]
    for path in paths
        try
            loaded = load_records_from_file(path)
            if isempty(loaded)
                push!(warnings, LoadWarning(String(path), "No tree or network records found."))
                continue
            end
            for (record_index, network) in enumerate(loaded)
                push!(records, ViewerRecord(network, String(path), record_index))
            end
        catch err
            push!(warnings, LoadWarning(String(path), sprint(showerror, err)))
        end
    end
    return (records = records, warnings = warnings)
end

function emit_load_warnings(warnings::AbstractVector{LoadWarning}; io::IO = stderr)::Nothing
    for warning in warnings
        println(io, "Skipped $(warning.path): $(warning.message)")
    end
    return nothing
end

function initial_status_text(warnings::AbstractVector{LoadWarning})::String
    if isempty(warnings)
        return "Loaded without warnings."
    end
    skipped = length(warnings)
    noun = skipped == 1 ? "path" : "paths"
    return "Loaded with $(skipped) skipped $(noun). See stderr for details."
end

function record_label(records::AbstractVector{ViewerRecord}, index::Integer)::String
    record = records[index]
    return "$(index) / $(length(records)): $(record.source) [record $(record.record_index)]"
end

function set_status!(status_label, message::AbstractString)::Nothing
    status_label.text[] = String(message)
    return nothing
end

function try_update_numeric_state!(
    plot_handle,
    state::ViewerState,
    field::Symbol,
    text::AbstractString,
    status_label;
    optional::Bool = false,
)::Bool
    try
        value = if optional
            parse_optional_positive_float(text, String(field))
        else
            parse_positive_float(text, String(field))
        end
        setproperty!(state, field, value)
        apply_viewer_state!(plot_handle, state)
        set_status!(status_label, "$(field) updated.")
        return true
    catch err
        set_status!(status_label, sprint(showerror, err))
        return false
    end
end

function try_update_color_state!(
    plot_handle,
    state::ViewerState,
    field::Symbol,
    text::AbstractString,
    allow_nothing::Bool,
    status_label,
)::Bool
    try
        value = parse_color_text(text, allow_nothing)
        setproperty!(state, field, value)
        apply_viewer_state!(plot_handle, state)
        set_status!(status_label, "$(field) updated.")
        return true
    catch err
        set_status!(status_label, sprint(showerror, err))
        return false
    end
end

function select_record!(
    plot_handle,
    state::ViewerState,
    records::AbstractVector{ViewerRecord},
    index::Integer,
    current_label,
    status_label,
)::Nothing
    selected_index = mod1(index, length(records))
    selected_network = records[selected_index].network
    Makie.update!(plot_handle; arg1 = selected_network)
    state.current_index = selected_index
    current_label.text[] = record_label(records, selected_index)
    status_label.text[] = "Showing $(record_label(records, selected_index))."
    return nothing
end

function add_boolean_control!(
    controls,
    row::Integer,
    label::AbstractString,
    plot_handle,
    state::ViewerState,
    field::Symbol,
    status_label,
)::Int
    Label(controls[row, 1], label; halign = :left, tellwidth = false)
    checkbox = Checkbox(controls[row, 2], checked = getproperty(state, field))
    on(checkbox.checked) do checked
        setproperty!(state, field, checked)
        apply_viewer_state!(plot_handle, state)
        set_status!(status_label, "$(label) updated.")
    end
    return row + 1
end

function add_menu_control!(
    controls,
    row::Integer,
    label::AbstractString,
    plot_handle,
    state::ViewerState,
    field::Symbol,
    options,
    default_label::AbstractString,
    status_label,
)::Int
    Label(controls[row, 1], label; halign = :left, tellwidth = false)
    menu = Menu(controls[row, 2:3], options = options, default = default_label)
    on(menu.selection) do selection
        setproperty!(state, field, selection)
        apply_viewer_state!(plot_handle, state)
        set_status!(status_label, "$(label) updated.")
    end
    return row + 1
end

function format_slider_value(value::Real)::String
    return string(round(Float64(value); digits = 2))
end

function add_slider_control!(
    controls,
    row::Integer,
    label::AbstractString,
    plot_handle,
    state::ViewerState,
    field::Symbol,
    values,
    status_label,
)::Int
    Label(controls[row, 1], label; halign = :left, tellwidth = false)
    slider = Slider(controls[row, 2], range = values, startvalue = getproperty(state, field))
    value_label = Label(
        controls[row, 3],
        format_slider_value(slider.value[]);
        halign = :right,
        tellwidth = false,
    )
    on(slider.value) do value
        value_label.text[] = format_slider_value(value)
        try_update_numeric_state!(plot_handle, state, field, string(value), status_label)
    end
    return row + 1
end

function add_arrow_controls!(
    controls,
    row::Integer,
    plot_handle,
    state::ViewerState,
    status_label,
)::Int
    Label(controls[row, 1], "Arrow auto"; halign = :left, tellwidth = false)
    automatic = Checkbox(controls[row, 2], checked = isnothing(state.arrowlen))
    row += 1

    Label(controls[row, 1], "Arrow length"; halign = :left, tellwidth = false)
    slider = Slider(controls[row, 2], range = 0.05:0.05:2.0, startvalue = 0.2)
    value_label = Label(
        controls[row, 3],
        format_slider_value(slider.value[]);
        halign = :right,
        tellwidth = false,
    )

    on(automatic.checked) do isautomatic
        if isautomatic
            try_update_numeric_state!(
                plot_handle,
                state,
                :arrowlen,
                "",
                status_label;
                optional = true,
            )
        else
            try_update_numeric_state!(
                plot_handle,
                state,
                :arrowlen,
                string(slider.value[]),
                status_label,
            )
        end
    end
    on(slider.value) do value
        value_label.text[] = format_slider_value(value)
        automatic.checked[] || try_update_numeric_state!(
            plot_handle,
            state,
            :arrowlen,
            string(value),
            status_label,
        )
    end
    return row + 1
end

function color_text(state::ViewerState, field::Symbol)::String
    value = getproperty(state, field)
    return isnothing(value) ? "" : value
end

function add_color_control!(
    controls,
    row::Integer,
    label::AbstractString,
    plot_handle,
    state::ViewerState,
    field::Symbol,
    allow_nothing::Bool,
    status_label,
)::Int
    Label(controls[row, 1], label; halign = :left, tellwidth = false)
    textbox = Textbox(
        controls[row, 2:3],
        stored_string = color_text(state, field),
        placeholder = allow_nothing ? "automatic" : "color",
    )
    on(textbox.stored_string) do text
        next_text = isnothing(text) ? "" : text
        try_update_color_state!(
            plot_handle,
            state,
            field,
            next_text,
            allow_nothing,
            status_label,
        )
    end
    return row + 1
end

function add_sidebar_controls!(controls, plot_handle, state::ViewerState, status_label)::Nothing
    row = 6
    Label(controls[row, 1:3], "Display"; halign = :left, tellwidth = false)
    row += 1
    row = add_boolean_control!(
        controls,
        row,
        "Edge lengths",
        plot_handle,
        state,
        :useedgelength,
        status_label,
    )
    row = add_boolean_control!(
        controls,
        row,
        "Tip labels",
        plot_handle,
        state,
        :showtiplabel,
        status_label,
    )
    row = add_boolean_control!(
        controls,
        row,
        "Node labels",
        plot_handle,
        state,
        :shownodelabel,
        status_label,
    )
    row = add_boolean_control!(
        controls,
        row,
        "Node numbers",
        plot_handle,
        state,
        :shownodenumber,
        status_label,
    )
    row = add_boolean_control!(
        controls,
        row,
        "Length labels",
        plot_handle,
        state,
        :showedgelength,
        status_label,
    )
    row = add_boolean_control!(
        controls,
        row,
        "Edge numbers",
        plot_handle,
        state,
        :showedgenumber,
        status_label,
    )
    row = add_boolean_control!(
        controls,
        row,
        "Gamma labels",
        plot_handle,
        state,
        :showgamma,
        status_label,
    )

    row += 1
    Label(controls[row, 1:3], "Topology"; halign = :left, tellwidth = false)
    row += 1
    row = add_menu_control!(
        controls,
        row,
        "Style",
        plot_handle,
        state,
        :style,
        [("fulltree", :fulltree), ("majortree", :majortree)],
        "fulltree",
        status_label,
    )
    row = add_menu_control!(
        controls,
        row,
        "Minor line",
        plot_handle,
        state,
        :minorlinetype,
        [
            ("nothing", nothing),
            ("solid", "solid"),
            ("dash", "dash"),
            ("dot", "dot"),
            ("dashdot", "dashdot"),
            ("longdash", "longdash"),
            ("blank", "blank"),
        ],
        "nothing",
        status_label,
    )

    row += 1
    Label(controls[row, 1:3], "Scale"; halign = :left, tellwidth = false)
    row += 1
    row = add_slider_control!(
        controls,
        row,
        "Edge width",
        plot_handle,
        state,
        :edgewidth,
        0.25:0.25:5.0,
        status_label,
    )
    row = add_slider_control!(
        controls,
        row,
        "Node scale",
        plot_handle,
        state,
        :nodecex,
        0.5:0.1:3.0,
        status_label,
    )
    row = add_slider_control!(
        controls,
        row,
        "Edge scale",
        plot_handle,
        state,
        :edgecex,
        0.5:0.1:3.0,
        status_label,
    )
    row = add_arrow_controls!(controls, row, plot_handle, state, status_label)

    row += 1
    Label(controls[row, 1:3], "Colors"; halign = :left, tellwidth = false)
    row += 1
    row = add_color_control!(
        controls,
        row,
        "Edges",
        plot_handle,
        state,
        :edgecolor,
        false,
        status_label,
    )
    row = add_color_control!(
        controls,
        row,
        "Default edge",
        plot_handle,
        state,
        :defaultedgecolor,
        true,
        status_label,
    )
    row = add_color_control!(
        controls,
        row,
        "Major hybrid",
        plot_handle,
        state,
        :majorhybridedgecolor,
        false,
        status_label,
    )
    row = add_color_control!(
        controls,
        row,
        "Minor hybrid",
        plot_handle,
        state,
        :minorhybridedgecolor,
        false,
        status_label,
    )
    row = add_color_control!(
        controls,
        row,
        "Node label",
        plot_handle,
        state,
        :nodelabelcolor,
        false,
        status_label,
    )
    row = add_color_control!(
        controls,
        row,
        "Edge label",
        plot_handle,
        state,
        :edgelabelcolor,
        false,
        status_label,
    )
    add_color_control!(
        controls,
        row,
        "Edge number",
        plot_handle,
        state,
        :edgenumbercolor,
        false,
        status_label,
    )
    return nothing
end

function build_viewer(
    records::AbstractVector{ViewerRecord},
    warnings::AbstractVector{LoadWarning} = LoadWarning[],
)
    isempty(records) && throw(ArgumentError("Cannot build viewer without records."))

    GLMakie.activate!()
    state = default_viewer_state()
    fig = Figure(size = (1400, 900))
    controls = GridLayout(fig[1, 1])
    axis = Axis(fig[1, 2])
    colsize!(fig.layout, 1, Fixed(360))
    colsize!(fig.layout, 2, Relative(1))
    rowgap!(controls, 8)
    colgap!(controls, 8)

    Label(controls[1, 1:3], "PhyloMakie viewer"; halign = :left, tellwidth = false)
    current_label = Label(
        controls[2, 1:3],
        record_label(records, state.current_index);
        halign = :left,
        tellwidth = false,
    )
    previous_button = Button(controls[3, 1], label = "Previous")
    next_button = Button(controls[3, 2:3], label = "Next")
    status_label = Label(
        controls[4, 1:3],
        initial_status_text(warnings);
        halign = :left,
        tellwidth = false,
    )

    plot_handle = phyloplot!(axis, records[state.current_index].network; viewer_attributes(state)...)
    add_sidebar_controls!(controls, plot_handle, state, status_label)
    colsize!(controls, 1, Fixed(150))
    colsize!(controls, 2, Fixed(120))
    colsize!(controls, 3, Fixed(60))

    on(previous_button.clicks) do _
        select_record!(
            plot_handle,
            state,
            records,
            state.current_index - 1,
            current_label,
            status_label,
        )
    end
    on(next_button.clicks) do _
        select_record!(
            plot_handle,
            state,
            records,
            state.current_index + 1,
            current_label,
            status_label,
        )
    end

    return (
        figure = fig,
        axis = axis,
        plot_handle = plot_handle,
        state = state,
        current_label = current_label,
        status_label = status_label,
    )
end

function main(args::AbstractVector{<:AbstractString} = ARGS)::Int
    result = load_records(args)
    emit_load_warnings(result.warnings)
    if isempty(result.records)
        println(stderr, "No tree or network records could be loaded.")
        return 1
    end

    viewer = build_viewer(result.records, result.warnings)
    screen = display(viewer.figure)
    wait(screen)
    return 0
end

if abspath(PROGRAM_FILE) == @__FILE__
    exit(main())
end
