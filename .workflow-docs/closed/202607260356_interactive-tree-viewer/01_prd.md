---
date-created: 2026-07-26T03:56:50-0700
workflow-instrument: PRD
workflow-status: Approved
workflow-agent-thread-id: codex/019f9dc8-4ccf-73c0-a391-69f235eea9d8
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-tree-viewer
---

# PRD: Interactive tree and network viewer example

## Problem statement

PhyloMakie now has a Makie-native reactive plotting path, but the current examples only show fixed render cases or scripted calls to `Makie.update!`. Users need one standalone GLMakie example that can be invoked from the command line, load one or more tree or network files, and demonstrate that PhyloMakie plot attributes can be changed through ordinary Makie widgets without rebuilding the plot.

The requested deliverable is a new example file:

```text
examples/src/05_interactive_ex1.jl
```

It must run as a CLI program, visualize loaded `PhyloNetworks.HybridNetwork` objects under GLMakie, provide previous and next controls for navigating loaded trees or networks, and expose widget controls for the requested PhyloMakie reactive attributes.

## Workflow identity

The user confirmed the package workspace and production id for this PRD.

- `workflow-location`: `/home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl`
- `workflow-production-id`: `reactive-tree-viewer`
- `workflow-status`: `Proposed`

## Active authorities

The following authorities were read or inspected before this PRD was written and must be passed forward to tranche and implementation agents.

- User request from 2026-07-26 for `05_interactive_ex1.jl`, including positional treefile arguments, previous and next tree controls, the listed reactive attributes, and a left-sidebar plus main-body layout.
- Skill instructions: `development-policies` and `devflow-feature-01--write-a-prd`.
- Current PhyloMakie governance: `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`, `STYLE-agent-language.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, `STYLE-workflow-vocabulary.md`, and `STYLE-writing.md`.
- Bundled governance baseline from the shared development policy depot. Shared `STYLE*.md` files matched the project-local copies by content hash. The bundled depot did not include `CONTRIBUTING.md` or `STYLE-vocabulary.md`; the project-local files are authoritative for those.
- Supporting design documents: `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`, `.workflow-docs/open/20260615--interactivity1/design/design.md`, and `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`.
- Project source and tests for the current reactive plotting system: `src/recipe_declaration.jl`, `src/recipe.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, `src/primitive_channels.jl`, `src/plot_config.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`, `test/test_recipe.jl`, and existing examples `03_mwe_reactivity_phylomakie.jl` and `04_maxwe_reactivity_phylomakie.jl`.
- Upstream primary sources available locally: Makie `compute-plots.jl`, `recipes.jl`, and `figureplotting.jl`; ComputePipeline `ComputePipeline.jl`; GLMakie `GLMakie.jl` and `display.jl`; PhyloNetworks `readwrite.jl` and `manipulateNet.jl`.

## Controlled vocabulary

- Use `tree` for acyclic inputs and `network` for reticulate inputs. Use `tree or network` when the file may contain either.
- Use `HybridNetwork` for the PhyloNetworks object accepted by PhyloMakie.
- Use `PhyloPlot` for the Makie recipe plot type and `plot handle` for the object returned by `plot!` or `phyloplot!`.
- Use `public attribute surface` for the supported PhyloMakie recipe attributes declared in `src/recipe_declaration.jl`.
- Use `Makie.update!` for widget-driven changes to the plot handle.
- Use `arg1` for replacing the plotted network through Makie's positional argument update API.
- Use `edge label`, `node label`, `tip label`, `edge number`, and `node number` in the senses defined by `STYLE-vocabulary.md`.
- Use `major hybrid edge` and `minor hybrid edge` for hybrid-edge styling behavior.

## Current state diagnosis

The current PhyloMakie codebase already has the public surface needed by this example.

- `src/recipe_declaration.jl` declares `PhyloPlot(net)` and the requested default attributes, including `useedgelength`, label and number visibility flags, gamma labels, edge colors, edge width, minor edge line type, arrow length, label sizes, and label colors.
- `src/reactive_graph.jl` registers the recipe inputs into ComputePipeline nodes and exposes graph output nodes for primitive geometry, colors, line widths, line styles, text positions, text content, and plot data limits.
- `src/primitive_assembly.jl` creates stable Makie child primitives once and wires primitive arguments to graph output nodes.
- `src/primitive_channels.jl` implements the rendering policy for the requested controls, including hidden layers as typed empty nodes, major and minor hybrid edge colors, scalar or dictionary edge widths, text color channels, and minor hybrid edge style handling.
- `src/plot_config.jl` normalizes the public attribute surface and resolves defaults for `minorlinetype` and `arrowlen`.
- Existing tests verify that `Makie.update!` changes public attributes without replacing child primitives and that `Makie.update!(plot; arg1 = new_net)` replaces the plotted network without mutating caller-owned networks.
- Existing examples `03_mwe_reactivity_phylomakie.jl` and `04_maxwe_reactivity_phylomakie.jl` demonstrate scripted reactivity, but neither accepts CLI tree files nor exposes an interactive widget surface.

This means the example should be an example-layer viewer shell over existing PhyloMakie behavior. It should not introduce package internals, change PhyloMakie plotting APIs, or duplicate the reactive graph.

## Upstream facts

These facts were verified from local primary sources and must constrain implementation.

- `Makie.update!(plot::Plot; args...)` updates plot input attributes through the plot compute graph. Positional arguments are supplied as `arg1`, `arg2`, and so on in Makie `compute-plots.jl`.
- Makie no longer permits assigning an `Observable` directly to a plot attribute with `plot.attr = observable`; the verified path is ComputePipeline registration or graph updates. The example must therefore call `Makie.update!` on the existing plot handle from widget callbacks.
- Makie recipes created by `@recipe` define plot argument names and keyword attributes. `PhyloPlot(net)` uses this mechanism.
- Makie `plot!` into an `Axis` returns a plot handle; non-mutating `plot` may return a `FigureAxisPlot`.
- Makie widgets provide observable state: `Button.clicks`, `Checkbox.checked`, `Toggle.active`, `Slider.value`, `Menu.selection`, and `Textbox.stored_string`.
- PhyloNetworks `readnewick(input::AbstractString)` treats an input beginning with `(` as an inline extended-Newick string and otherwise treats it as a filename.
- PhyloNetworks `readmultinewick(file::AbstractString, fast::Bool=true)` reads a vector of `HybridNetwork` objects from one Newick topology per line. With `fast=false`, it skips empty or unparsable lines without failing the entire file.
- PhyloNetworks `readnexus_treeblock(file::AbstractString, ...)` returns a vector of `HybridNetwork` objects from the first NEXUS `trees` block and can translate reticulation syntax and gamma metadata.
- PhyloNetworks `directedges!` and `preorder!` are mutating topology operations. PhyloMakie's plotting path prepares a private network copy, so the example must not directly call these mutators on user-loaded records unless a later task proves a separate copy is necessary.

## User goals

- As a user, I can run `julia --project=examples examples/src/05_interactive_ex1.jl` and see an interactive demo network without preparing a file.
- As a user, I can run `julia --project=examples examples/src/05_interactive_ex1.jl treefile [tree_or_network_file...]` and view every loaded tree or network in a deterministic order.
- As a user, I can move to the previous or next loaded tree or network without the plot disappearing, the axis being recreated, or the viewer losing my current style choices.
- As a user, I can toggle labels, numbers, gamma labels, edge lengths, and hybrid-edge visibility behaviors from a left-hand control sidebar.
- As a user, I can change scalar edge width, node label size, edge label size, arrow length, edge colors, hybrid edge colors, and label colors from widgets.
- As a maintainer, I can inspect the example and see that it exercises the public PhyloMakie attribute surface through `Makie.update!`.
- As a reviewer, I can verify that this example does not change PhyloMakie runtime behavior outside `examples/src/05_interactive_ex1.jl` except for optional focused tests or documentation created during implementation.

## Functional requirements

### CLI invocation

The new file must be a standalone Julia script with a testable entrypoint and a program-file guard.

Required invocation:

```text
julia --project=examples examples/src/05_interactive_ex1.jl [treefile [tree_or_network_file...]]
```

Behavior:

- With no positional arguments, the script loads one or more built-in demo `HybridNetwork` objects. This keeps the example runnable as a normal numbered example.
- With one or more positional arguments, each argument is treated as a local file path.
- File order must be preserved.
- Records within a file must be appended in the order returned by the upstream reader.
- The viewer must flatten all loaded records into one navigation list.
- Each loaded record must carry display metadata at least including source path or demo label and one-based record index.
- If no records can be loaded from user-provided paths, the script must print a concise error and exit nonzero.
- Inline Newick strings passed as CLI arguments are out of scope unless the implementation can support them without weakening file-path behavior.

### Input loading

The implementation must use PhyloNetworks readers instead of hand-parsing tree syntax.

Required loading policy:

- If a file contains a NEXUS trees block marker, use `readnexus_treeblock(file)`.
- Otherwise try multi-Newick loading with `readmultinewick(file, false)` for files that contain one topology per line.
- If multi-Newick loading returns no records, fall back to `readnewick(file)` so a single possibly multiline Newick file remains supported.
- For multiple Newick records, this example only needs to support one topology per line because that is the upstream `readmultinewick` file contract.
- Per-file parse failures must mention the failing path.
- Partial success is allowed: if at least one file yields records, load those records and report skipped paths to the terminal.

### Viewer layout

The first screen must be the interactive viewer, not explanatory content.

Required layout:

- Use GLMakie.
- Create a `Figure` with one left control sidebar and one larger main plot area.
- Put controls in `fig[1, 1]`.
- Put the tree or network axis in `fig[1, 2]`.
- Give the main plot area substantially more width than the sidebar.
- Keep controls vertically stacked, compact, and grouped by task.
- Avoid nested card-like UI groups. Use labels, grid spacing, and separators instead.
- Include a status label in the sidebar for current record identity, load warnings, and validation errors.
- Ensure controls do not overlap at typical desktop sizes.

Recommended starting point:

```julia
fig = Figure(size = (1400, 900))
controls = GridLayout(fig[1, 1])
axis = Axis(fig[1, 2])
colsize!(fig.layout, 1, Fixed(360))
colsize!(fig.layout, 2, Relative(1))
```

The exact layout code may vary if implementation discovers a better Makie-native arrangement, but the sidebar and main-body ownership must remain.

### Navigation controls

Required controls:

- Previous tree or network button.
- Next tree or network button.
- Current item label showing one-based index, total count, and source label.

Required behavior:

- Previous and next wrap around the loaded record list.
- Navigation preserves the current visualization-control state.
- Navigation updates the existing plot handle with `Makie.update!(plot_handle; arg1 = selected_network, ...)`.
- Navigation must not rebuild the axis or replace the plot handle as its normal update path.
- If axis limits do not visually refit after network changes, implementation must use a verified Makie axis-limit reset helper after the `Makie.update!` call and document that choice in implementation notes.

### Reactive visualization controls

The UI must expose controls for all user-requested attributes with these initial values:

```julia
useedgelength = false
showtiplabel = true
shownodelabel = false
shownodenumber = false
showedgelength = false
showedgenumber = false
showgamma = false
edgecolor = "black"
defaultedgecolor = nothing
majorhybridedgecolor = "deepskyblue4"
minorhybridedgecolor = "deepskyblue"
edgewidth = 1
minorlinetype = nothing
arrowlen = nothing
nodecex = 1
edgecex = 1
nodelabelcolor = "black"
edgelabelcolor = "black"
edgenumbercolor = "grey"
```

Required widget mapping:

- Boolean flags use Makie `Checkbox` or `Toggle` widgets.
- `edgewidth`, `nodecex`, and `edgecex` use bounded numeric widgets, preferably sliders with compact numeric labels.
- `arrowlen` must support `nothing` as automatic behavior and a numeric value when enabled.
- `minorlinetype` must support `nothing` as automatic behavior plus the supported line-style strings used by PhyloMakie, including `"blank"` for hiding minor hybrid edges.
- Color controls use compact text boxes initialized from the default color strings.
- `defaultedgecolor` must support empty input as `nothing`.
- Invalid color or numeric input must leave the last valid value active and show a status message instead of crashing the UI callback.

Required additional control:

- Include a `style` menu with `:fulltree` and `:majortree`. The user approved this addition on 2026-07-27. This control is part of the job, part of the current public attribute surface, and materially affects hybrid-edge visualization.

Out-of-scope control complexity:

- Dictionary-valued `edgecolor` and `edgewidth` editors.
- `nodelabel` and `edgelabel` DataFrame editors.
- Interactive rotation, node dragging, edge picking, or pointer inspection.
- Save, export, or screenshot buttons.

### Update model

The viewer must keep one plot handle alive and update it through public Makie APIs.

Required behavior:

- Initial rendering uses `plot!(axis, first_network; requested_defaults...)` or `phyloplot!(axis, first_network; requested_defaults...)`.
- Widget callbacks call a single local refresh function or small set of refresh helpers.
- Attribute changes call `Makie.update!(plot_handle; attribute = value)` or a synchronized update of all current values.
- Network navigation calls `Makie.update!(plot_handle; arg1 = selected_network)`.
- The example must not update internal ComputePipeline nodes directly.
- The example must not mutate `plot_handle.plots`, delete child primitives, clear the axis, or recreate the recipe plot as the normal response to a widget event.
- The example must not call PhyloNetworks topology mutators on the user-loaded record objects as part of widget updates.

### Error handling and status

Required behavior:

- Missing files, unreadable files, and files with no parseable records must be reported with the path.
- If at least one path succeeds, the viewer opens with the successful records and reports skipped paths in terminal output.
- If all user-provided paths fail, the CLI exits nonzero before creating the GLMakie window.
- Invalid widget values must be reported in the sidebar status label.
- A failed widget parse must not desynchronize the displayed plot from the UI state.

## Non-goals

- No change to PhyloMakie package APIs.
- No new package dependencies in `Project.toml` files unless the user explicitly approves them.
- No new reactive-graph implementation inside the example.
- No custom tree parser.
- No asynchronous file watching.
- No remote file loading.
- No command-line option parser package.
- No broad documentation rewrite.

## Ownership boundaries

The example owns:

- CLI argument handling for this script.
- Demo input data for no-argument invocation.
- File loading orchestration around PhyloNetworks readers.
- GLMakie figure, axis, widgets, callbacks, and status text.
- Mapping widget values to PhyloMakie public attributes.

PhyloMakie owns:

- `PhyloPlot` recipe declaration.
- Public attribute validation and normalization.
- Compute graph registration.
- Primitive channel computation.
- Stable primitive creation and updates.
- Private plotting copy of caller-owned `HybridNetwork` objects.

PhyloNetworks owns:

- Extended-Newick parsing.
- Multi-Newick file reading.
- NEXUS tree block parsing.
- Topology mutation functions such as `directedges!` and `preorder!`.

Makie and GLMakie own:

- Figure, layout, axis, widget, scene, and display behavior.
- `Makie.update!` semantics for plot attributes and positional arguments.

## Primary-goal lock

The primary goal is complete only when `examples/src/05_interactive_ex1.jl` is a runnable GLMakie CLI viewer that loads demo or file-provided trees and networks, navigates them through previous and next controls, and changes the requested visualization attributes through Makie widgets by updating the existing PhyloMakie plot handle.

The goal is not complete if any of these lock items fail.

### Lock item 1: standalone CLI

Requirement:

- `05_interactive_ex1.jl` runs directly with `julia --project=examples examples/src/05_interactive_ex1.jl`.
- It also accepts one or more tree or network file paths.

Red-state repro:

- Current examples are scripts with hardcoded networks and no CLI file list.

Green-state gate:

- A local run with no args opens the demo viewer.
- A local run with a temporary single-Newick file loads one record.
- A local run with a temporary multi-Newick file loads multiple records.
- A local run with a temporary NEXUS tree-block file loads records when supported by PhyloNetworks.

### Lock item 2: reactive public updates

Requirement:

- Widgets update public PhyloMakie attributes through `Makie.update!` on the existing plot handle.

Red-state repro:

- Rebuilding the axis or plot from a callback would demonstrate a viewer shell, but would not demonstrate the reactive PhyloMakie spine.

Green-state gate:

- Source inspection shows widget callbacks calling `Makie.update!` rather than clearing the axis or mutating primitive children.
- Runtime smoke shows at least one boolean control, one color control, and one numeric control visibly change the existing plot.

### Lock item 3: navigation through `arg1`

Requirement:

- Previous and next controls update the plotted `HybridNetwork` through `arg1`.

Red-state repro:

- Existing reactivity examples only perform scripted `arg1` updates and do not expose user-driven navigation.

Green-state gate:

- Navigation changes the displayed topology.
- Current record label changes.
- Current visualization settings persist after navigation.
- The plot handle remains the same object during navigation.

### Lock item 4: complete requested controls

Requirement:

- Every requested attribute appears in the UI and starts with the requested default.

Red-state repro:

- A partial control panel would not satisfy the user's request even if the plot itself is reactive.

Green-state gate:

- A reviewer can map each listed attribute to a widget and callback.
- Reset or initialization code uses the exact defaults from the user request and current recipe declaration.

### Lock item 5: usable left-sidebar layout

Requirement:

- Controls are stacked in a left sidebar and the plot occupies the larger main body.

Red-state repro:

- A cluttered single-column figure or overlapping controls would make the example poor as an interactive demonstration.

Green-state gate:

- A desktop screenshot or GLMakie inspection shows controls in `fig[1, 1]` and the plot in `fig[1, 2]`.
- Control text fits within the sidebar.
- The main plot remains the visually dominant area.

### Lock item 6: input failures are handled

Requirement:

- Bad paths and parse failures produce understandable feedback without Julia stack traces in routine user cases.

Red-state repro:

- Passing an unreadable file currently reaches upstream reader errors directly if no wrapper is written.

Green-state gate:

- Running the script with a missing file exits nonzero with a concise message.
- Running the script with one valid and one invalid file opens the valid records and reports the invalid path.

### Lock item 7: example-layer scope

Requirement:

- The feature remains an example-layer addition unless implementation discovers a genuine missing package capability and obtains user approval to change it.

Red-state repro:

- Changing PhyloMakie internals to make this example easier would broaden scope beyond the requested example file.

Green-state gate:

- The final diff is limited to `examples/src/05_interactive_ex1.jl` plus optional focused tests or workflow documents.

## Implementation outline

The implementing agent should prefer small local helper functions over a new module.

Suggested local entities:

- `ViewerRecord`: small immutable struct or named tuple with `network::HybridNetwork`, `source::String`, and `record_index::Int`.
- `demo_records()`: returns at least one tree and one reticulate network when no CLI files are provided.
- `load_records(paths::Vector{String})`: returns loaded records and load warnings.
- `load_records_from_file(path::String)`: chooses NEXUS, multi-Newick, or single-Newick loading using PhyloNetworks readers.
- `default_viewer_state()`: returns the requested attribute defaults.
- `build_viewer(records, warnings)`: creates figure, controls, plot handle, callbacks, and status label.
- `apply_viewer_state!(plot_handle, state)`: calls `Makie.update!` with public attributes.
- `select_record!(plot_handle, state, records, index)`: updates `arg1`, current-label text, and axis limits if verified necessary.
- `main(args = ARGS)::Int`: CLI shell that returns `0` or nonzero.

The final script should use a guard equivalent to:

```julia
if abspath(PROGRAM_FILE) == @__FILE__
    exit(main())
end
```

This keeps the file executable while allowing focused smoke tests to `include` it without opening a window.

## Verification plan

Required verification should scale with GUI availability.

- Syntax/load smoke: `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl")'`.
- Loader smoke: include the script, create temporary single-Newick and multi-Newick files, call the loader helpers, and assert record counts.
- CLI error smoke: run the script with a missing path and verify nonzero exit plus path-specific error text.
- GLMakie manual smoke: run the example with no args, verify the window opens, the sidebar is on the left, and previous/next plus representative controls update the plot.
- Visual behavior smoke: capture a screenshot or use an available colorbuffer path to verify a representative attribute update changes pixels.
- Source audit: confirm there is no axis clearing, primitive-child deletion, internal compute-node mutation, or package API change.

If headless GLMakie is not available in the implementation environment, the implementation report must say so and include the strongest completed substitute checks.

## Assumptions to ratify before approval

- No positional arguments open built-in demo records instead of exiting with usage. This follows the existing example convention that numbered examples are runnable without extra data.
- Multi-Newick files support one topology per line, matching the upstream `readmultinewick(file)` contract.
- The example remains a single file unless a small focused test file is needed for loader or callback verification.

## Settled user decisions

- The `style` control is required. It must expose `:fulltree` and `:majortree` and update the existing plot handle through `Makie.update!`.

## Handoff packet for tranche planning

Any tranche document produced from this PRD must pass forward:

- This PRD path and its `workflow-production-id`.
- The active authorities listed above.
- The exact requested attribute default list.
- The requirement to update the existing plot handle through `Makie.update!`.
- The requirement to use `arg1` for network navigation.
- The input-loading policy using PhyloNetworks readers.
- The left-sidebar and main-body layout requirement.
- The no-new-dependency constraint.
- The primary-goal lock items and green-state gates.

## Approval checklist

Before trancheing, the owner should confirm:

- The no-argument demo fallback is accepted.
- The multi-Newick one-topology-per-line limitation is acceptable for this example.
- `workflow-status` may be changed from `Proposed` to `Approved`.
