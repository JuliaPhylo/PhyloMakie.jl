function _load_selected_records(
        command::Union{ViewCommand, InspectCommand, RenderCommand};
        stdin_io::IO,
        error_io::IO,
    )::LoadResult
    input = command.input
    result = load_records(input; stdin_io)
    emit_load_warnings(result.warnings; io = error_io)
    isempty(result.records) && throw(ArgumentError("No phylogeny records could be loaded."))
    selected = select_records(result.records, input.selection)
    isempty(selected) && throw(ArgumentError("No phylogeny records matched the selection options."))
    write_selected_records(selected, command.selected_output)
    return (records = selected, warnings = result.warnings)
end

function _load_backend(name::Symbol)::Module
    backend = Base.require(@__MODULE__, name)
    backend isa Module || error("Loading $(name) did not return a module.")
    return backend
end

function _run_view_backend(
        backend::Module,
        records::AbstractVector{SourceRecord},
        warnings::AbstractVector{LoadWarning},
        plot_options::AbstractDict{Symbol},
        size::Tuple{Int, Int},
    )::Int
    backend.activate!()
    viewer = build_viewer(records, warnings, plot_options; size)
    screen = display(viewer.figure)
    wait(screen)
    return 0
end

function _run_render_backend(
        backend::Module,
        records::AbstractVector{SourceRecord},
        command::RenderCommand,
        plot_options::AbstractDict{Symbol},
    )::Vector{String}
    backend.activate!()
    return render_records(records, command, backend, plot_options)
end

function run_command(
        command::HelpCommand;
        output_io::IO = stdout,
        error_io::IO = stderr,
        stdin_io::IO = stdin,
    )::Int
    print(output_io, help_text(command.topic))
    return 0
end

function run_command(
        command::InspectCommand;
        output_io::IO = stdout,
        error_io::IO = stderr,
        stdin_io::IO = stdin,
    )::Int
    result = _load_selected_records(
        command;
        stdin_io,
        error_io,
    )
    write_inspection(
        output_io,
        collection_statistics(result.records);
        verbosity = command.verbosity,
        taxa_only = command.taxa_only,
    )
    return 0
end

function run_command(
        command::ViewCommand;
        output_io::IO = stdout,
        error_io::IO = stderr,
        stdin_io::IO = stdin,
    )::Int
    result = _load_selected_records(command; stdin_io, error_io)
    display_inputs = load_display_inputs(
        result.records,
        command.plot_options,
        command.node_label_path,
    )
    backend = _load_backend(:GLMakie)
    return Base.invokelatest(
        _run_view_backend,
        backend,
        display_inputs.records,
        result.warnings,
        display_inputs.plot_options,
        command.size,
    )
end

function run_command(
        command::RenderCommand;
        output_io::IO = stdout,
        error_io::IO = stderr,
        stdin_io::IO = stdin,
    )::Int
    result = _load_selected_records(
        command;
        stdin_io,
        error_io,
    )
    display_inputs = load_display_inputs(
        result.records,
        command.plot_options,
        command.node_label_path,
    )
    backend = _load_backend(:CairoMakie)
    paths = Base.invokelatest(
        _run_render_backend,
        backend,
        display_inputs.records,
        command,
        display_inputs.plot_options,
    )
    foreach(path -> println(output_io, path), paths)
    return 0
end

function run(
        args::AbstractVector{<:AbstractString};
        output_io::IO = stdout,
        error_io::IO = stderr,
        stdin_io::IO = stdin,
    )::Int
    try
        command = parse_command(args)
        return run_command(command; output_io, error_io, stdin_io)
    catch error
        error isa InterruptException && rethrow()
        prefix = error isa CLIUsageError ? "usage error" : "error"
        println(error_io, "$(prefix): $(sprint(showerror, error))")
        return error isa CLIUsageError ? 2 : 1
    end
end
