const VIEWER_BOOLEAN_CONTROLS = (
    ("Edge lengths", :useedgelength),
    ("Tip labels", :showtiplabel),
    ("Node labels", :shownodelabel),
    ("Node numbers", :shownodenumber),
    ("Length labels", :showedgelength),
    ("Edge numbers", :showedgenumber),
    ("Gamma labels", :showgamma),
)

const VIEWER_COLOR_CONTROLS = (
    ("Edges", :edgecolor, false),
    ("Default edge", :defaultedgecolor, true),
    ("Major hybrid", :majorhybridedgecolor, false),
    ("Minor hybrid", :minorhybridedgecolor, false),
    ("Node label", :nodelabelcolor, false),
    ("Edge label", :edgelabelcolor, false),
    ("Edge number", :edgenumbercolor, false),
)

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

function _apply_viewer_override!(state::ViewerState, name::Symbol, value)::Nothing
    if name in last.(VIEWER_BOOLEAN_CONTROLS)
        value isa Bool && setproperty!(state, name, value)
    elseif name in (:edgewidth, :nodecex, :edgecex)
        value isa Real && setproperty!(state, name, Float64(value))
    elseif name === :arrowlen
        (isnothing(value) || value isa Real) &&
            setproperty!(state, name, isnothing(value) ? nothing : Float64(value))
    elseif name === :minorlinetype
        (isnothing(value) || value isa AbstractString || value isa Symbol) &&
            setproperty!(state, name, isnothing(value) ? nothing : string(value))
    elseif name === :style
        value isa Symbol && setproperty!(state, name, value)
    elseif name in (
            :edgecolor, :majorhybridedgecolor, :minorhybridedgecolor,
            :nodelabelcolor, :edgelabelcolor, :edgenumbercolor,
        )
        value isa AbstractString && setproperty!(state, name, String(value))
    elseif name === :defaultedgecolor
        (isnothing(value) || value isa AbstractString) &&
            setproperty!(state, name, isnothing(value) ? nothing : String(value))
    end
    return nothing
end

function viewer_state(plot_options::AbstractDict{Symbol})::ViewerState
    state = default_viewer_state()
    foreach(option -> _apply_viewer_override!(state, first(option), last(option)), plot_options)
    return state
end

function viewer_attributes(state::ViewerState)::NamedTuple
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

function apply_viewer_state!(
        plot::PhyloMakie.PhyloPlot,
        axis::Makie.Axis,
        state::ViewerState,
    )::Nothing
    Makie.update!(plot; viewer_attributes(state)...)
    Makie.autolimits!(axis)
    return nothing
end

function _set_status!(label::Makie.Label, message::AbstractString)::Nothing
    label.text[] = String(message)
    return nothing
end

function _try_viewer_update!(
        update::Function,
        plot::PhyloMakie.PhyloPlot,
        axis::Makie.Axis,
        state::ViewerState,
        status_label::Makie.Label,
        description::AbstractString,
    )::Bool
    try
        update()
        apply_viewer_state!(plot, axis, state)
        _set_status!(status_label, "$(description) updated.")
        return true
    catch error
        _set_status!(status_label, sprint(showerror, error))
        return false
    end
end

function _add_boolean_controls!(
        controls::Makie.GridLayout,
        first_row::Int,
        plot::PhyloMakie.PhyloPlot,
        axis::Makie.Axis,
        state::ViewerState,
        status_label::Makie.Label,
    )::Int
    row = first_row
    for (label_text, field) in VIEWER_BOOLEAN_CONTROLS
        Makie.Label(controls[row, 1], label_text; halign = :left, tellwidth = false)
        checkbox = Makie.Checkbox(controls[row, 2], checked = getproperty(state, field))
        Makie.on(checkbox.checked) do checked
            _try_viewer_update!(plot, axis, state, status_label, label_text) do
                setproperty!(state, field, checked)
            end
        end
        row += 1
    end
    return row
end


function _add_menu_controls!(
        controls::Makie.GridLayout,
        first_row::Int,
        plot::PhyloMakie.PhyloPlot,
        axis::Makie.Axis,
        state::ViewerState,
        status_label::Makie.Label,
    )::Int
    row = first_row
    menus = (
        (
            "Style",
            :style,
            [("fulltree", :fulltree), ("majortree", :majortree)],
            string(state.style),
        ),
        (
            "Minor line",
            :minorlinetype,
            [
                ("automatic", nothing),
                ("solid", "solid"),
                ("dash", "dash"),
                ("dot", "dot"),
                ("dashdot", "dashdot"),
                ("longdash", "longdash"),
                ("blank", "blank"),
            ],
            isnothing(state.minorlinetype) ? "automatic" : state.minorlinetype,
        ),
    )
    for (label_text, field, options, default) in menus
        Makie.Label(controls[row, 3], label_text; halign = :left, tellwidth = false)
        menu = Makie.Menu(controls[row, 4:5], options = options, default = default)
        Makie.on(menu.selection) do selection
            _try_viewer_update!(plot, axis, state, status_label, label_text) do
                setproperty!(state, field, selection)
            end
        end
        row += 1
    end
    return row
end

function _format_slider_value(value::Real)::String
    return string(round(Float64(value); digits = 2))
end

function _slider_values(values, startvalue::Real)
    startvalue in values && return values
    return sort!(unique!(push!(Float64.(collect(values)), Float64(startvalue))))
end

function _add_slider_control!(
        controls::Makie.GridLayout,
        row::Int,
        label_text::AbstractString,
        field::Symbol,
        values,
        plot::PhyloMakie.PhyloPlot,
        axis::Makie.Axis,
        state::ViewerState,
        status_label::Makie.Label,
    )::Int
    Makie.Label(controls[row, 3], label_text; halign = :left, tellwidth = false)
    startvalue = getproperty(state, field)::Float64
    slider = Makie.Slider(
        controls[row, 4],
        range = _slider_values(values, startvalue),
        startvalue = startvalue,
    )
    value_label = Makie.Label(
        controls[row, 5],
        _format_slider_value(slider.value[]);
        halign = :right,
        tellwidth = false,
    )
    Makie.on(slider.value) do value
        value_label.text[] = _format_slider_value(value)
        _try_viewer_update!(plot, axis, state, status_label, label_text) do
            setproperty!(state, field, Float64(value))
        end
    end
    return row + 1
end

function _add_arrow_controls!(
        controls::Makie.GridLayout,
        row::Int,
        plot::PhyloMakie.PhyloPlot,
        axis::Makie.Axis,
        state::ViewerState,
        status_label::Makie.Label,
    )::Int
    Makie.Label(controls[row, 3], "Arrow auto"; halign = :left, tellwidth = false)
    automatic = Makie.Checkbox(controls[row, 4], checked = isnothing(state.arrowlen))
    row += 1
    Makie.Label(controls[row, 3], "Arrow length"; halign = :left, tellwidth = false)
    arrowlen = state.arrowlen
    startvalue = isnothing(arrowlen) ? 0.2 : arrowlen
    slider = Makie.Slider(
        controls[row, 4],
        range = _slider_values(0.05:0.05:2.0, startvalue),
        startvalue = startvalue,
    )
    value_label = Makie.Label(
        controls[row, 5],
        _format_slider_value(slider.value[]);
        halign = :right,
        tellwidth = false,
    )
    Makie.on(automatic.checked) do isautomatic
        _try_viewer_update!(plot, axis, state, status_label, "Arrow length") do
            state.arrowlen = isautomatic ? nothing : Float64(slider.value[])
        end
    end
    Makie.on(slider.value) do value
        value_label.text[] = _format_slider_value(value)
        if !automatic.checked[]
            _try_viewer_update!(plot, axis, state, status_label, "Arrow length") do
                state.arrowlen = Float64(value)
            end
        end
    end
    return row + 1
end

function _color_text(state::ViewerState, field::Symbol)::String
    value = getproperty(state, field)
    isnothing(value) && return ""
    return value::String
end

function _add_color_controls!(
        controls::Makie.GridLayout,
        first_row::Int,
        plot::PhyloMakie.PhyloPlot,
        axis::Makie.Axis,
        state::ViewerState,
        status_label::Makie.Label,
    )::Int
    row = first_row
    for (label_text, field, allow_nothing) in VIEWER_COLOR_CONTROLS
        Makie.Label(controls[row, 1], label_text; halign = :left, tellwidth = false)
        textbox = Makie.Textbox(
            controls[row, 2],
            stored_string = _color_text(state, field),
            placeholder = allow_nothing ? "automatic" : "color",
        )
        Makie.on(textbox.stored_string) do text
            next_text = isnothing(text) ? "" : strip(text)
            _try_viewer_update!(plot, axis, state, status_label, label_text) do
                if isempty(next_text)
                    allow_nothing || throw(ArgumentError("$(label_text) color cannot be empty."))
                    setproperty!(state, field, nothing)
                else
                    Makie.to_color(next_text)
                    setproperty!(state, field, String(next_text))
                end
            end
        end
        row += 1
    end
    return row
end

function _add_viewer_controls!(
        controls::Makie.GridLayout,
        plot::PhyloMakie.PhyloPlot,
        axis::Makie.Axis,
        state::ViewerState,
        status_label::Makie.Label,
    )::Nothing
    Makie.Label(controls[6, 1:2], "Display and colors"; halign = :left, tellwidth = false)
    Makie.Label(controls[6, 3:5], "Topology and scale"; halign = :left, tellwidth = false)
    _add_boolean_controls!(controls, 7, plot, axis, state, status_label)
    _add_color_controls!(controls, 15, plot, axis, state, status_label)
    row = _add_menu_controls!(controls, 7, plot, axis, state, status_label)
    row += 1
    for (label_text, field, values) in (
            ("Edge width", :edgewidth, 0.25:0.25:5.0),
            ("Node scale", :nodecex, 0.5:0.1:3.0),
            ("Edge scale", :edgecex, 0.5:0.1:3.0),
        )
        row = _add_slider_control!(
            controls,
            row,
            label_text,
            field,
            values,
            plot,
            axis,
            state,
            status_label,
        )
    end
    _add_arrow_controls!(controls, row, plot, axis, state, status_label)
    return nothing
end

function select_record!(
        viewer::Viewer,
        records::AbstractVector{SourceRecord},
        index::Integer,
    )::Nothing
    selected_index = mod1(index, length(records))
    Makie.update!(viewer.plot; arg1 = records[selected_index].phylogeny)
    Makie.autolimits!(viewer.axis)
    viewer.state.current_index = selected_index
    viewer.current_label.text[] = record_label(records, selected_index)
    viewer.status_label.text[] = "Showing $(record_label(records, selected_index))."
    return nothing
end

function build_viewer(
        records::AbstractVector{SourceRecord},
        warnings::AbstractVector{LoadWarning},
        plot_options::AbstractDict{Symbol};
        size::Tuple{Int, Int} = (1700, 950),
    )::Viewer
    isempty(records) && throw(ArgumentError("Cannot build a viewer without records."))
    state = viewer_state(plot_options)
    initial_options = PlotOptions(pairs(viewer_attributes(state)))
    merge!(initial_options, plot_options)

    figure = Makie.Figure(size = size, figure_padding = 28)
    controls = Makie.GridLayout(figure[1, 1])
    axis = Makie.Axis(figure[1, 2])
    Makie.colsize!(figure.layout, 1, Makie.Fixed(740))
    Makie.colsize!(figure.layout, 2, Makie.Auto())
    Makie.rowgap!(controls, 4)
    Makie.colgap!(controls, 6)

    Makie.Label(controls[1, 1:5], "PhyloMakie viewer"; halign = :left, tellwidth = false)
    current_label = Makie.Label(
        controls[2, 1:5],
        record_label(records, state.current_index);
        halign = :left,
        tellwidth = false,
        fontsize = 12,
    )
    previous_button = Makie.Button(controls[3, 1:2], label = "Previous")
    next_button = Makie.Button(controls[3, 3:5], label = "Next")
    status_message = isempty(warnings) ?
        "Loaded without warnings." :
        "Loaded with $(length(warnings)) skipped inputs. See stderr for details."
    status_label = Makie.Label(
        controls[4, 1:5],
        status_message;
        halign = :left,
        tellwidth = false,
        fontsize = 12,
    )

    plot = PhyloMakie.phyloplot!(
        axis,
        records[state.current_index].phylogeny;
        initial_options...,
    )
    viewer = Viewer(figure, axis, plot, state, current_label, status_label)
    _add_viewer_controls!(controls, plot, axis, state, status_label)
    Makie.colsize!(controls, 1, Makie.Fixed(145))
    Makie.colsize!(controls, 2, Makie.Fixed(180))
    Makie.colsize!(controls, 3, Makie.Fixed(125))
    Makie.colsize!(controls, 4, Makie.Fixed(190))
    Makie.colsize!(controls, 5, Makie.Fixed(55))

    Makie.on(previous_button.clicks) do _
        select_record!(viewer, records, state.current_index - 1)
    end
    Makie.on(next_button.clicks) do _
        select_record!(viewer, records, state.current_index + 1)
    end
    return viewer
end
