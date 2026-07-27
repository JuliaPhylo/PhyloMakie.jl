---
date-created: 2026-07-27T01:35:33-0700
workflow-instrument: Tasking plan
workflow-status: Proposed
workflow-agent-thread-id: codex/019fa296-25cd-7582-83fa-fd5de661a498
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-tree-viewer
workflow-prd: .workflow-docs/202607260356_interactive-tree-viewer/01_prd.md
workflow-tranche: .workflow-docs/202607260356_interactive-tree-viewer/02_tranches.md
---

# Tasks for tranches 1-5: Single-agent interactive tree and network viewer bundle

## Settled user decisions and environment baseline

This tasking plan packages all 5 approved tranches into 1 sequential bundle for 1 implementing agent. It replaces `03-01_tranche-01--tasking-1.md` as the recommended execution artifact when this file is approved. The older Tranche 1 tasking file remains a historical checkpoint reference and must not be executed separately in the same implementation run.

Implementation must treat these decisions and baselines as fixed input:

- The package root is `/home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl`.
- The parent PRD and tranche plan are approved.
- This bundle remains proposed until the project owner changes this file's `workflow-status` to `Approved`.
- The whole feature is an example-layer addition unless implementation proves a genuine missing package capability and obtains explicit project-owner approval before changing package source.
- The primary implementation file is `examples/src/05_interactive_ex1.jl`.
- Do not change `src/`, package public APIs, root `Project.toml`, root `Manifest.toml`, `examples/Project.toml`, or `examples/Manifest.toml`.
- Do not add dependencies.
- Do not add a command-line option parser package.
- Do not implement a custom tree or network parser.
- Use PhyloNetworks readers: `readnexus_treeblock`, `readmultinewick(path, false)`, and `readnewick`.
- Do not call `directedges!` or `preorder!` on user-loaded `HybridNetwork` records in this example.
- Use GLMakie for the viewer.
- Use the existing PhyloMakie public attribute surface declared in `src/recipe_declaration.jl`.
- Use `Makie.update!` on the existing plot handle for widget-driven attribute changes.
- Use `Makie.update!(plot_handle; arg1 = selected_network)` for previous and next navigation.
- Do not assign `Observable` objects directly to PhyloMakie plot attributes.
- The `style` control is required. It must expose `:fulltree` and `:majortree`.
- `minorlinetype` must expose `nothing`, `"solid"`, `"dash"`, `"dot"`, `"dashdot"`, `"longdash"`, and `"blank"`.
- `defaultedgecolor` must treat an empty color text box as `nothing`.
- The direct-run script must display the GLMakie figure and wait on the returned `GLMakie.Screen` so the window remains open until closed.

The requested initial public attribute defaults are:

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
style = :fulltree
```

## Governance

Downstream implementation must read and conform to these project governance documents line by line before changing files:

- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
- `STYLE-agent-language.md`
- `STYLE-architecture.md`
- `STYLE-docs.md`
- `STYLE-git.md`
- `STYLE-julia.md`
- `STYLE-makie.md`
- `STYLE-upstream-contracts.md`
- `STYLE-verification.md`
- `STYLE-vocabulary.md`
- `STYLE-workflow-docs.md`
- `STYLE-workflow-vocabulary.md`
- `STYLE-writing.md`

The bundle uses these project workflow authorities:

- `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`
- `.workflow-docs/202607260356_interactive-tree-viewer/02_tranches.md`
- `.workflow-docs/202607260356_interactive-tree-viewer/03-01_tranche-01--tasking-1.md` as a historical Tranche 1 detail reference only

Archived governance files under `../00-archives/` and `../PhyloNetworks.jl/CONTRIBUTING.md` were found by broad search but are not active authorities for this PhyloMakie tasking bundle.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, branch creation, checkout, reset, and rebase remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Upstream primary sources

The implementing agent must read these upstream primary sources line by line before implementing the tasks that cite them:

- `../PhyloNetworks.jl/src/readwrite.jl` for `readnewick`, `readmultinewick`, and `readnexus_treeblock`.
- `../PhyloNetworks.jl/src/manipulateNet.jl` for `directedges!` and `preorder!`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/compute-plots.jl` for `Makie.update!` and `arg1`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/recipes.jl` for recipe behavior.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/figureplotting.jl` for plot handle behavior.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/display.jl` for `display(figlike)` returning a screen.
- `/home/jeetsukumaran/.julia/packages/GLMakie/A7mVm/src/display.jl` for `display(screen, scene)` returning the screen.
- `/home/jeetsukumaran/.julia/packages/GLMakie/A7mVm/src/screen.jl` for `Base.wait(screen::Screen)` and `Base.isopen(screen::Screen)`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/button.jl` for `Button.clicks`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/checkbox.jl` for `Checkbox.checked`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/slider.jl` for `Slider.value`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/toggle.jl` for `Toggle.active`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/menu.jl` for `Menu.selection`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/textbox.jl` for `Textbox.stored_string`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/axis.jl` for axis-limit reset only if the implemented script calls a Makie axis-limit helper after `arg1` updates.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/E2l50/src/ComputePipeline.jl` for compute graph update context.

The tasking agent revalidated current source before writing this file:

- `examples/src/05_interactive_ex1.jl` is absent.
- `src/recipe_declaration.jl` declares the requested attributes and defaults.
- `src/plot_config.jl` includes the requested attributes in the public attribute list and resolves `style`, `minorlinetype`, and `arrowlen`.
- Existing examples `03_mwe_reactivity_phylomakie.jl` and `04_maxwe_reactivity_phylomakie.jl` demonstrate scripted `Makie.update!`, including `arg1`, but they do not provide CLI loading or widgets.
- A reader smoke under `julia --project=examples` verified representative `readnewick`, `readmultinewick(path, false)`, and `readnexus_treeblock` behavior against temporary files.

## Primary-goal lock

### Lock item 1: Standalone CLI

- The work is not complete if `examples/src/05_interactive_ex1.jl` cannot run directly with `julia --project=examples examples/src/05_interactive_ex1.jl` and with positional tree or network file paths.
- Red-state repro: current examples are scripts with hardcoded networks and no CLI file list.
- Tasks that close it: Tasks 2, 3, 4, and 13.
- Verification artifact: no-argument direct run opens the demo viewer; helper smoke loads single-Newick, multi-Newick, and NEXUS files in deterministic order; missing-path direct run exits nonzero before display.

### Lock item 2: Reactive public updates

- The work is not complete if widget callbacks change attributes by rebuilding the axis, replacing the plot handle, assigning `Observable` objects directly to plot attributes, or mutating internal ComputePipeline nodes.
- Red-state repro: rebuilding the axis or plot from callbacks would show an interactive viewer shell but would not demonstrate the reactive PhyloMakie public attribute surface.
- Tasks that close it: Tasks 5, 6, 7, 8, 9, 10, 11, and 13.
- Verification artifact: source audit finds callbacks routed through `apply_viewer_state!` and `Makie.update!`; runtime or artifact smoke shows at least 1 boolean, 1 numeric, and 1 color change affecting the existing plot.

### Lock item 3: Navigation through `arg1`

- The work is not complete if previous or next navigation clears the axis, recreates the plot handle, mutates child primitive lists, or changes the plotted `HybridNetwork` without `arg1`.
- Red-state repro: existing reactivity examples only perform scripted `arg1` updates and do not expose user-driven navigation.
- Tasks that close it: Tasks 5, 6, and 13.
- Verification artifact: source audit finds `Makie.update!(plot_handle; arg1 = selected_network)` in `select_record!`; manual GLMakie verification confirms previous and next change topology and label while style settings persist.

### Lock item 4: Complete requested controls

- The work is not complete if any requested boolean, style, minor hybrid edge, numeric, optional-arrow, or color control is missing from the sidebar or starts from a value different from the requested default.
- Red-state repro: a partial control panel would not satisfy the user's request even if the plot itself is reactive.
- Tasks that close it: Tasks 7, 8, 9, 10, and 13.
- Verification artifact: source audit maps each requested attribute to 1 widget and callback; helper smoke checks `default_viewer_state()` fields; manual GLMakie verification changes representative controls.

### Lock item 5: Usable left-sidebar layout

- The work is not complete if controls are not in `fig[1, 1]`, the plot is not in `fig[1, 2]`, the main plot area is not visually larger than the sidebar, or typical desktop control text overlaps.
- Red-state repro: a cluttered single-column figure or overlapping controls would fail the example as an interactive demonstration.
- Tasks that close it: Tasks 5, 6, and 13.
- Verification artifact: source audit finds `GridLayout(fig[1, 1])`, `Axis(fig[1, 2])`, sidebar width control, and main plot relative sizing; manual GLMakie inspection or captured colorbuffer/screenshot verifies layout and text fit.

### Lock item 6: Input failures are handled

- The work is not complete if missing files, unreadable files, parse failures, invalid widget input, or all-failed input can crash routine user flows or leave the displayed plot desynchronized from state.
- Red-state repro: passing an unreadable file reaches upstream reader errors directly when no script-level loader wrapper exists; invalid widget text can crash a callback when no validation layer preserves the last valid state.
- Tasks that close it: Tasks 2, 3, 10, 11, and 13.
- Verification artifact: missing-path CLI exits nonzero with the path; valid-plus-invalid input opens valid records and reports the skipped path; invalid color and numeric helper smokes leave state unchanged and update status text.

### Lock item 7: Example-layer scope

- The work is not complete if the feature changes PhyloMakie runtime behavior outside the example layer without explicit project-owner approval.
- Red-state repro: changing package internals to make the example easier would broaden the requested example beyond its approved scope.
- Tasks that close it: Tasks 1 through 13.
- Verification artifact: final diff review shows implementation changes limited to `examples/src/05_interactive_ex1.jl` plus this tasking file and non-repo verification artifacts under `/tmp`.

### Lock item 8: Single-agent checkpoint discipline

- The work is not complete if the implementing agent skips a checkpoint gate, continues after a failed tranche gate, or declares final success while any tranche-level lock item remains unverified.
- Red-state repro: a one-agent bundle could drift by carrying a partial loader, partial control panel, or source-only verification through to the final report.
- Tasks that close it: Tasks 3, 6, 8, 11, 12, and 13.
- Verification artifact: implementation report records each checkpoint gate before moving to the next tranche; final report lists every lock item with its verification artifact or marks the run blocked.

## Forbidden passing implementation table

| Lock item | Required behavior | Current code state | Resolved implementation instruction | Forbidden passing implementation | Failing verification artifact |
| --- | --- | --- | --- | --- | --- |
| Standalone CLI | Direct run opens demo viewer with no args, accepts file paths, and reports all-failed input before display. | `examples/src/05_interactive_ex1.jl` does not exist; existing examples have hardcoded networks. | Create `main(args = ARGS)::Int`, include-safe helpers, loader functions, direct-run guard, and post-loader display path in `examples/src/05_interactive_ex1.jl`. | A file that includes demo data and widgets but ignores `ARGS` can look interactive while failing file loading. | Direct run with a missing path exits nonzero and direct run with no args opens the viewer. |
| Reactive public updates | Widget callbacks call `apply_viewer_state!`, which calls `Makie.update!` on the existing plot handle with public attributes. | Existing examples show scripted `Makie.update!`; no widget callbacks exist. | Define `default_viewer_state`, `viewer_attributes`, and `apply_viewer_state!`; every attribute widget callback mutates state and calls `apply_viewer_state!`. | A callback that calls `plot!` again or assigns `plot_handle.edgecolor = textbox.stored_string` can pass weak visual tests while bypassing the public update contract. | Source audit fails if callbacks call `plot!`, `empty!`, `delete!`, internal ComputePipeline mutation, or direct plot-attribute observable assignment. |
| Navigation through `arg1` | Previous and next callbacks call `select_record!`, and `select_record!` updates the existing plot handle with `arg1`. | Scripted `arg1` update exists in `04_maxwe_reactivity_phylomakie.jl`; no navigation buttons exist. | Define `select_record!` as the only record-navigation path. Button callbacks compute wrapped indices and call `select_record!`. | A navigation callback that clears the axis and replots passes a topology-change visual check while losing plot-handle continuity. | Source audit finds `Makie.update!(plot_handle; arg1 = selected_network)` and no normal navigation calls to `empty!`, `delete!`, or `plot!`. Manual verification confirms style state persists. |
| Complete requested controls | Every requested attribute has one sidebar widget, default state, callback, and update through `apply_viewer_state!`. | `src/recipe_declaration.jl` declares all requested attributes and defaults; no UI exists. | Build boolean, style, `minorlinetype`, numeric, optional-arrow, and color controls in `examples/src/05_interactive_ex1.jl` using the exact defaults listed above. | A panel that implements only a representative subset can pass smoke tests while omitting requested controls. | Source audit maps every attribute in the default list to state, widget creation, and update payload. |
| Usable left-sidebar layout | Controls live in `fig[1, 1]`, plot lives in `fig[1, 2]`, sidebar has fixed width, plot column uses remaining width, and text does not overlap on desktop. | No target example file exists. | Define `build_viewer` with `Figure(size = (1400, 900))`, `GridLayout(fig[1, 1])`, `Axis(fig[1, 2])`, `colsize!(fig.layout, 1, Fixed(360))`, and `colsize!(fig.layout, 2, Relative(1))`. | A single-axis or single-column layout could display controls and plot but fail the requested left-sidebar and main-body arrangement. | Source audit and manual screenshot/colorbuffer inspection fail if controls overlap or plot is not dominant. |
| Input failures are handled | File failures and invalid widget text report status and preserve last valid state. | No loader wrapper or widget validation exists. | Define `LoadWarning`, path-specific loader catches, `parse_positive_float`, `parse_optional_positive_float`, `parse_color_text`, and callbacks that update state only after successful validation. | A `try/catch` that returns `nothing` silently or a textbox callback that writes invalid text into state can pass happy-path tests while failing routine errors. | Missing-path CLI smoke and invalid color/numeric helper smokes fail the incomplete implementation. |
| Example-layer scope | Implementation stays in `examples/src/05_interactive_ex1.jl` unless explicit user approval changes scope. | `git status --short` is clean before this bundle except proposed workflow artifacts. | Edit only `examples/src/05_interactive_ex1.jl`; write screenshots/colorbuffers under `/tmp` when collected. | Changing `src/plot_config.jl`, dependencies, tests, or docs can make checks pass while violating scope. | `git -C . diff --name-only` from `workflow-location` shows no package-source, test, docs, or environment edits. |
| Single-agent checkpoint discipline | The agent completes and records each checkpoint before continuing. | No single-agent bundle existed before this file. | Follow tasks in order; do not start the next tranche's WRITE task until the current tranche's TEST task is green or the run is marked blocked. | A single agent finishes a plausible example but skips loader or invalid-input checks, causing hidden drift behind a working window. | Implementation report has separate Tranche 1, 2, 3, 4, and 5 checkpoint sections with command results and lock-item status. |

## Handoff packet

- **Active authorities**: user request to bundle tranches for a single agent; `development-policies`; `devflow-feature-03--tranche-to-tasks`; parent PRD; parent tranche plan; all project governance documents listed above.
- **Parent documents**: `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`; `.workflow-docs/202607260356_interactive-tree-viewer/02_tranches.md`; `.workflow-docs/202607260356_interactive-tree-viewer/03-01_tranche-01--tasking-1.md` as historical Tranche 1 detail reference.
- **Settled decisions and non-negotiables**: no new dependencies; no package API changes; use public PhyloMakie attributes through `Makie.update!`; use `arg1` for navigation; include `style`; validate widget text locally; preserve example-layer scope.
- **Authorization boundary**: implementation may create and modify `examples/src/05_interactive_ex1.jl`; verification artifacts may be written under `/tmp`; source, tests, docs, manifests, and environment files remain out of scope.
- **Current-state diagnosis**: PhyloMakie already has the reactive public attribute surface; existing examples demonstrate scripted updates but no CLI loader, left-sidebar viewer, widget callbacks, or direct-run GLMakie viewer.
- **Primary-goal lock**: lock items 1 through 8 in this tasking file.
- **Direct red-state repros**: current examples have no CLI; callbacks can cheat by rebuilding plots; navigation can cheat by clearing/replotting; partial control panels omit required attributes; invalid text can crash callbacks; package-source edits would broaden scope; one-agent execution can drift if checkpoint gates are skipped.
- **Responsible entities and invariants**: `load_records_from_file` owns reader selection; `load_records` owns file-list aggregation and warnings; `build_viewer` owns figure layout and widget construction; `default_viewer_state` owns initial UI state; `viewer_attributes` owns the public attribute payload; `apply_viewer_state!` owns public attribute updates; `select_record!` owns navigation through `arg1`; validation helpers own text-to-state conversion and must preserve last valid state on failure.
- **Exact files in scope**: `examples/src/05_interactive_ex1.jl`.
- **Exact files and surfaces out of scope**: `src/`, `test/`, `docs/`, root `Project.toml`, root `Manifest.toml`, `examples/Project.toml`, `examples/Manifest.toml`, package public APIs, new dependencies, pointer interactions, save/export/screenshot buttons in the viewer, dictionary-valued editors, `nodelabel` and `edgelabel` DataFrame editors.
- **Required upstream primary sources**: all sources listed in the upstream primary sources section.
- **Green-state gates**: Tranche 1 loader gate; Tranche 2 layout/navigation gate; Tranche 3 boolean/style gate; Tranche 4 numeric/color gate; Tranche 5 final source, CLI, helper, visual, and scope gate.
- **Stop conditions**: stop if any checkpoint gate fails; stop before package-source edits; stop before adding dependencies; stop if GLMakie cannot display and no colorbuffer/screenshot substitute can be produced; stop if a requested public attribute is missing from `src/recipe_declaration.jl`; stop if a verification artifact cannot be produced for a lock item.

## Required revalidation before implementation

- Read the parent PRD and parent tranche plan in full.
- Read this tasking file in full.
- Read the existing examples `examples/src/03_mwe_reactivity_phylomakie.jl` and `examples/src/04_maxwe_reactivity_phylomakie.jl` in full.
- Read `examples/Project.toml` in full.
- Read `src/recipe_declaration.jl`, `src/plot_config.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, and `src/primitive_channels.jl` in full.
- Read `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`, and `test/test_recipe.jl` in full to understand the existing public update guarantees.
- Read every upstream primary source listed above where it constrains the task being executed.
- Re-check that `examples/src/05_interactive_ex1.jl` is still absent or reconcile with any user-created version before editing.
- If the diagnosis no longer matches current source, stop before editing and raise the mismatch.

## Single-agent checkpoint execution rule

This bundle is intended for one implementing agent. The agent must execute tasks in order. Each tranche checkpoint must be green before the next tranche's WRITE task begins.

Checkpoint gates are:

- Tranche 1 gate: Tasks 2 and 3 complete, then Task 4 passes.
- Tranche 2 gate: Task 5 completes, then Task 6 passes.
- Tranche 3 gate: Task 7 completes, then Task 8 passes.
- Tranche 4 gate: Tasks 9 and 10 complete, then Task 11 passes.
- Tranche 5 gate: Task 12 passes and Task 13 is completed or explicitly blocked by unavailable display.

If any checkpoint fails, the agent must stop, record the failing command or artifact, and not continue to the next tranche. Do not convert a failed checkpoint into weaker source-only verification.

## Non-negotiable execution rules

- Do not modify files outside `examples/src/05_interactive_ex1.jl`.
- Do not add dependencies.
- Do not broaden PhyloMakie public APIs.
- Do not hand-parse tree or network syntax.
- Do not call PhyloNetworks topology mutators on user-loaded records.
- Do not rebuild the plot handle as normal navigation or widget update behavior.
- Do not mutate `plot_handle.plots`, child primitive lists, or internal ComputePipeline nodes.
- Do not assign `Observable` objects directly to PhyloMakie plot attributes.
- Do not silently drop invalid paths or invalid widget text.
- Do not declare success from source audits alone.
- Do not move product logic into tests or source-text policing.
- Do not continue after a failed checkpoint.

## Concrete anti-patterns or removal targets

The completed example must not contain:

- top-level user-file loading during `include`
- top-level `exit` outside the program-file guard
- multiple reader-selection helpers
- `readnewick`-only file loading
- sorted or deduplicated CLI path order
- custom Newick or NEXUS parsing
- direct calls to `directedges!` or `preorder!`
- widget callbacks that call `plot!`, `phyloplot!`, `empty!`, or `delete!`
- widget callbacks that mutate ComputePipeline nodes
- direct assignment of observables to plot attributes
- partial UI default tables separate from `default_viewer_state`
- public attribute update payloads outside `viewer_attributes` and `apply_viewer_state!`
- validation callbacks that update state before validation succeeds
- package-source, docs, test, manifest, or environment edits

## Failure-oriented verification

These checks must fail known bad implementations:

- Include smoke fails a script with top-level execution.
- Multi-Newick and NEXUS helper smokes fail a `readnewick`-only loader.
- Ordered metadata smoke fails a loader that sorts paths or loses per-file `record_index`.
- Missing-path CLI smoke fails all-failed success or stack-trace-only failures.
- Source audit fails callbacks that rebuild plots or bypass `Makie.update!`.
- Source audit fails navigation that does not use `arg1`.
- Default-state helper smoke fails omitted controls or wrong defaults.
- Invalid-input helper smoke fails callbacks that mutate state on bad text.
- Manual GLMakie inspection or screenshot/colorbuffer artifacts fail overlapping controls and non-dominant plot layout.
- Final diff review fails source, test, docs, manifest, or environment edits.
- Final lock-item table fails a single-agent run that skipped a checkpoint.

Positive runtime success is also required: a user can run the example with no args, see a left-sidebar GLMakie viewer with a larger tree or network plot, navigate records, change requested controls through widgets, and receive understandable status for bad files and bad widget text.

## Tasks

### 1. Revalidate bundle authorities and current source

**Type**: TEST
**Output**: Implementation notes record active authorities, current source state, upstream source paths read, and unchanged authorization boundary.
**Depends on**: none
**Positive contract**: The implementing agent has read the required governance, PRD, tranche, current source, current tests, examples, and upstream primary sources before editing.
**Negative contract**: The agent must not edit files before recording this revalidation. The agent must not proceed if `examples/src/05_interactive_ex1.jl` already exists with user changes that conflict with this tasking.
**Files**: no project files may be touched.
**Out of scope**: code changes, workflow-document edits, dependency changes, and git mutations.
**Verification**: Run `git -C . status --short` from `workflow-location`; run `test ! -e examples/src/05_interactive_ex1.jl`; run `rg -n "@recipe|useedgelength|showtiplabel|showgamma|minorlinetype|arrowlen|style" src/recipe_declaration.jl src/plot_config.jl`; record the outputs in the implementation report.

Revalidate this bundle against current source. Confirm the target example file is absent. Confirm the public attribute surface still contains all requested attributes. Confirm existing examples still demonstrate scripted `Makie.update!` but not CLI loading or widgets. Stop before editing if any of those facts no longer hold.

### 2. Build the include-safe CLI loader shell

**Type**: WRITE
**Output**: `examples/src/05_interactive_ex1.jl` exists with include-safe loader helpers, demo records, `main(args = ARGS)::Int`, and the direct-run guard.
**Depends on**: Task 1
**Positive contract**: The file defines `ViewerRecord`, `LoadWarning`, `demo_records`, `contains_nexus_treeblock`, `load_records_from_file`, `load_records`, `emit_load_warnings`, and `main(args = ARGS)::Int`. Including the file does not run `main`, exit, or display.
**Negative contract**: This task must not import GLMakie, create a figure, construct widgets, call `plot!`, call `phyloplot!`, call `Makie.update!`, call `directedges!`, call `preorder!`, or parse tree syntax manually.
**Files**: `examples/src/05_interactive_ex1.jl`
**Out of scope**: viewer layout, navigation buttons, widgets, validation text boxes, package source, tests, docs, manifests, and environment files.
**Verification**: `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl"); records = demo_records(); @assert length(records) >= 2; @assert all(r -> r.network isa HybridNetwork, records); @assert main(String[]) == 0'`

Create the new example file with explicit imports from PhyloNetworks for `HybridNetwork`, `readnewick`, `readmultinewick`, and `readnexus_treeblock`. Define immutable `ViewerRecord` with `network::HybridNetwork`, `source::String`, and `record_index::Int`. Define immutable `LoadWarning` with `path::String` and `message::String`. `demo_records()` must use `readnewick` on inline strings and return at least 1 tree and 1 reticulate network. `contains_nexus_treeblock` must scan for `r"^\\s*begin\\s+trees\\s*;"i` and must not parse trees. `load_records_from_file` must be the only reader-selection function and must choose NEXUS, multi-Newick, then single-Newick fallback. `load_records` must preserve CLI path order and reader-returned order, collect per-path warnings, and produce one-based `record_index` values per source. `main` must return `0` on demo loading and partial success and nonzero when user-provided paths yield no records. Add the program-file guard after `main`.

### 3. Verify Tranche 1 loader and CLI checkpoint

**Type**: TEST
**Output**: Tranche 1 checkpoint is green and recorded.
**Depends on**: Task 2
**Positive contract**: Include, single-Newick, multi-Newick, NEXUS, partial-success, and all-failed smokes pass under the examples environment.
**Negative contract**: Do not continue to Task 5 if any command fails. Do not add tests or change implementation scope to make this checkpoint pass.
**Files**: no project files may be touched.
**Out of scope**: viewer construction, widgets, GLMakie display, package source, tests, docs, manifests, and environment files.
**Verification**: Run the Task 2 command. Run a helper smoke that creates temporary single-Newick, multi-Newick, and NEXUS files and checks counts, `source`, and `record_index`. Run `julia --project=examples examples/src/05_interactive_ex1.jl /tmp/phylomakie-missing-05-interactive-ex1.newick` and confirm nonzero exit plus path text. Run `rg -n 'directedges!|preorder!|GLMakie|Figure\\(|Axis\\(|plot!|phyloplot!|Makie\\.update!|empty!|delete!' examples/src/05_interactive_ex1.jl` and confirm no matches at this checkpoint.

Record the Tranche 1 checkpoint result before continuing. This is the drift guard: a working later window is not allowed to compensate for a weak loader or CLI contract.

### 4. Add GLMakie imports and direct-run viewer display path

**Type**: WRITE
**Output**: The script can build a viewer object from loaded records and direct-run `main` displays it with GLMakie.
**Depends on**: Task 3
**Positive contract**: `main(args)` now loads records, builds the viewer after successful loading, calls `display(viewer.figure)`, waits on the returned screen, and returns `0` after the user closes the window. Including the file still does not display.
**Negative contract**: Missing-path and all-failed input must still return nonzero before any GLMakie figure or screen is created. Do not add controls beyond navigation and required status labels in this task.
**Files**: `examples/src/05_interactive_ex1.jl`
**Out of scope**: boolean controls, style controls, numeric controls, color controls, validation helpers, package source, tests, docs, manifests, and environment files.
**Verification**: `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl"); @assert main([joinpath(tempdir(), "phylomakie-missing-05-interactive-ex1.newick")]) != 0'` must return without display. Manual direct run with no args must open a GLMakie window and keep it alive until closed.

Import GLMakie and Makie names only after the loader checkpoint is green. Define a small return object for viewer handles as a `NamedTuple` with keys `figure`, `axis`, `plot_handle`, `state`, `current_label`, and `status_label`. The direct-run path must call `display(viewer.figure)` and then `wait(screen)` on the returned GLMakie screen. This follows Makie `display(figlike)` returning a screen and GLMakie `Base.wait(screen::Screen)` waiting on the render task. Do not invent a polling loop.

### 5. Build left-sidebar layout and navigation through `arg1`

**Type**: WRITE
**Output**: `build_viewer` creates the left-sidebar layout, initial plot handle, previous and next buttons, current-record label, and status label.
**Depends on**: Task 4
**Positive contract**: `build_viewer(records, warnings)` creates `Figure(size = (1400, 900))`, `GridLayout(fig[1, 1])`, `Axis(fig[1, 2])`, `colsize!(fig.layout, 1, Fixed(360))`, `colsize!(fig.layout, 2, Relative(1))`, one initial PhyloMakie plot handle, previous and next buttons, and labels. `select_record!` updates the existing plot handle through `Makie.update!(plot_handle; arg1 = selected_network)`.
**Negative contract**: Navigation must not call `plot!`, `phyloplot!`, `empty!`, `delete!`, mutate `plot_handle.plots`, clear the axis, or replace the plot handle as the normal path.
**Files**: `examples/src/05_interactive_ex1.jl`
**Out of scope**: boolean controls, style controls, numeric controls, color controls, validation helpers, package source, tests, docs, manifests, and environment files.
**Verification**: Source audit finds `GridLayout(fig[1, 1])`, `Axis(fig[1, 2])`, `Fixed(360)`, `Relative(1)`, and `Makie.update!(plot_handle; arg1 = selected_network)`. Source audit confirms previous and next callbacks call `select_record!` and no navigation callback calls `plot!`, `phyloplot!`, `empty!`, or `delete!`.

Build the first real viewer screen. Define a mutable `ViewerState` for callback-owned UI state, with a short comment justifying mutation as GLMakie widget boundary state. At this task, `ViewerState` must at least hold `current_index::Int` plus the public attribute fields with the requested defaults. Use `plot!` or `phyloplot!` exactly once during initial viewer construction. Previous and next button callbacks must compute wrapped one-based indices and call `select_record!`; `select_record!` must update `state.current_index`, update the current-record label, update the status label, and call `Makie.update!` with `arg1`.

### 6. Verify Tranche 2 layout and navigation checkpoint

**Type**: TEST
**Output**: Tranche 2 checkpoint is green and recorded.
**Depends on**: Task 5
**Positive contract**: Source and manual checks prove left-sidebar layout, stable plot handle navigation through `arg1`, wrapped previous and next behavior, and no normal-path plot rebuild.
**Negative contract**: Do not continue to Task 7 if navigation rebuilds the plot or if the direct-run viewer cannot be manually opened in a GLMakie-capable environment.
**Files**: no project files may be touched.
**Out of scope**: adding controls, changing implementation, package source, tests, docs, manifests, and environment files.
**Verification**: Run include smoke. Run source audits from Task 5. Run `julia --project=examples examples/src/05_interactive_ex1.jl` manually; confirm window opens with controls on the left, plot on the right, previous and next wrap through records, current label changes, and the plot changes topology.

Record the Tranche 2 checkpoint result before continuing. If GLMakie display fails because the environment is headless, record the exact error and stop; do not substitute source-only verification for the visual layout lock item.

### 7. Add default state, boolean controls, style, and minor line type

**Type**: WRITE
**Output**: Sidebar controls exist for all boolean attributes, `style`, and `minorlinetype`, and all update the existing plot handle through `apply_viewer_state!`.
**Depends on**: Task 6
**Positive contract**: `default_viewer_state()::ViewerState`, `viewer_attributes(state)`, and `apply_viewer_state!(plot_handle, state)::Nothing` exist. Boolean controls cover `useedgelength`, `showtiplabel`, `shownodelabel`, `shownodenumber`, `showedgelength`, `showedgenumber`, and `showgamma`. Menus cover `style` and `minorlinetype`.
**Negative contract**: Do not assign observables directly to plot attributes. Do not call `Makie.update!` directly from individual boolean, style, or minor-line callbacks; callbacks must update state and call `apply_viewer_state!`.
**Files**: `examples/src/05_interactive_ex1.jl`
**Out of scope**: numeric sliders, arrow-length controls, color text boxes, text validation helpers, package source, tests, docs, manifests, and environment files.
**Verification**: `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl"); s = default_viewer_state(); @assert s.useedgelength == false; @assert s.showtiplabel == true; @assert s.shownodelabel == false; @assert s.shownodenumber == false; @assert s.showedgelength == false; @assert s.showedgenumber == false; @assert s.showgamma == false; @assert s.style == :fulltree; @assert isnothing(s.minorlinetype)'`. Source audit confirms callbacks route through `apply_viewer_state!`.

Centralize defaults in `default_viewer_state`. `viewer_attributes` must return the exact public attribute payload consumed by `plot!` and `Makie.update!`. `apply_viewer_state!` must be the only function that updates public attributes from `ViewerState` to the plot handle. Boolean widgets may use `Checkbox` or `Toggle`; use one widget type consistently for booleans in this file. Use `Menu.selection` for `style` and `minorlinetype`. The `style` menu must expose `:fulltree` and `:majortree`. The `minorlinetype` menu must expose `nothing`, `"solid"`, `"dash"`, `"dot"`, `"dashdot"`, `"longdash"`, and `"blank"`.

### 8. Verify Tranche 3 boolean and style checkpoint

**Type**: TEST
**Output**: Tranche 3 checkpoint is green and recorded.
**Depends on**: Task 7
**Positive contract**: Default-state helper smoke passes; source audit maps every boolean, `style`, and `minorlinetype` control to state and callback; manual viewer smoke changes representative controls without rebuilding the plot.
**Negative contract**: Do not continue to Task 9 if a listed control is missing, has the wrong default, or bypasses `apply_viewer_state!`.
**Files**: no project files may be touched.
**Out of scope**: adding numeric or color controls, changing implementation after verification starts, package source, tests, docs, manifests, and environment files.
**Verification**: Run the Task 7 helper command. Run source audit for every boolean attribute plus `style` and `minorlinetype`. Manually run the viewer and verify `showtiplabel`, `showgamma`, `style = :majortree`, and `minorlinetype = "blank"` visibly change the plot.

Record the Tranche 3 checkpoint result before continuing. This checkpoint fails if the UI implements only a representative subset.

### 9. Add numeric, optional arrow length, and color controls

**Type**: WRITE
**Output**: Sidebar controls exist for `edgewidth`, `nodecex`, `edgecex`, `arrowlen`, `edgecolor`, `defaultedgecolor`, `majorhybridedgecolor`, `minorhybridedgecolor`, `nodelabelcolor`, `edgelabelcolor`, and `edgenumbercolor`.
**Depends on**: Task 8
**Positive contract**: Bounded numeric widgets update `edgewidth`, `nodecex`, and `edgecex`. `arrowlen` supports automatic `nothing` and a positive numeric value. Color text boxes initialize to requested defaults and route through validation before state changes.
**Negative contract**: Do not add dictionary-valued editors, DataFrame label editors, save/export/screenshot buttons, package validation changes, or direct `Makie.update!` calls from individual numeric or color callbacks.
**Files**: `examples/src/05_interactive_ex1.jl`
**Out of scope**: pointer interactions, file watching, remote loading, package source, tests, docs, manifests, and environment files.
**Verification**: Source audit maps every numeric, optional, and color attribute to a widget, callback, state field, and `viewer_attributes` payload.

Add bounded sliders for `edgewidth`, `nodecex`, and `edgecex`, each with compact labels that update from `Slider.value`. Use positive ranges that include the default `1`: `0.25:0.25:5.0` for `edgewidth`, `0.5:0.1:3.0` for `nodecex`, and `0.5:0.1:3.0` for `edgecex`. Add an arrow-length automatic toggle plus numeric control; when automatic is active, `state.arrowlen` must be `nothing`, and when numeric is active, `state.arrowlen` must be the positive slider value. Add compact `Textbox` controls for all color attributes. The empty `defaultedgecolor` text must map to `nothing`; every other color field must reject empty text.

### 10. Add validation helpers and status-preserving failure behavior

**Type**: WRITE
**Output**: Numeric and color parsing helpers preserve last valid state and report validation errors in the status label.
**Depends on**: Task 9
**Positive contract**: `parse_positive_float`, `parse_optional_positive_float`, `parse_color_text`, `try_update_numeric_state!`, and `try_update_color_state!` exist. Invalid numeric or color text updates the status label and leaves `ViewerState` unchanged.
**Negative contract**: Validation helpers must not call `Makie.update!` with unvalidated text. They must not write invalid values into `ViewerState`. They must not swallow validation failures without status text.
**Files**: `examples/src/05_interactive_ex1.jl`
**Out of scope**: package validation changes, dependency changes, tests, docs, manifests, and environment files.
**Verification**: `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl"); s = default_viewer_state(); old = s.edgecolor; @assert parse_color_text("red", false) == "red"; @assert isnothing(parse_color_text("", true)); try parse_color_text("not-a-color", false); error("invalid color accepted"); catch err; @assert err isa ArgumentError; end; @assert parse_positive_float("2.5", "edgewidth") == 2.5; try parse_positive_float("-1", "edgewidth"); error("invalid numeric accepted"); catch err; @assert err isa ArgumentError; end; @assert s.edgecolor == old'`

Implement validation as local example-shell behavior before calling `apply_viewer_state!`. `parse_color_text` must validate color strings through Makie's color conversion path, returning the original accepted string for public attribute updates and throwing `ArgumentError` on invalid color text. `parse_positive_float` must parse finite positive numbers and throw `ArgumentError` for invalid, zero, negative, NaN, or infinite input. The callback helpers must update `ViewerState` and call `apply_viewer_state!` only after validation succeeds; on validation failure they must write an informative status message and preserve the last valid plot state.

### 11. Verify Tranche 4 numeric, color, and validation checkpoint

**Type**: TEST
**Output**: Tranche 4 checkpoint is green and recorded.
**Depends on**: Tasks 9 and 10
**Positive contract**: Helper smokes and source audits prove all requested numeric and color controls exist, defaults are correct, valid values update state, invalid values preserve last valid state, and callbacks use `apply_viewer_state!`.
**Negative contract**: Do not continue to Task 12 if any requested control is missing, any invalid value mutates state, or any callback bypasses validation.
**Files**: no project files may be touched.
**Out of scope**: adding controls beyond the PRD, changing implementation after verification starts, package source, tests, docs, manifests, and environment files.
**Verification**: Run the Task 10 helper command. Run source audit for `edgewidth`, `nodecex`, `edgecex`, `arrowlen`, `edgecolor`, `defaultedgecolor`, `majorhybridedgecolor`, `minorhybridedgecolor`, `nodelabelcolor`, `edgelabelcolor`, and `edgenumbercolor`. Manually run the viewer and verify one numeric control, `arrowlen`, one ordinary color, empty `defaultedgecolor`, and invalid color text.

Record the Tranche 4 checkpoint result before continuing. The checkpoint fails if invalid input crashes a callback or if status text does not report the failure.

### 12. Run final automated and source-audit closeout

**Type**: TEST
**Output**: Final automated closeout report records command results, source audits, diff scope, and lock-item status.
**Depends on**: Task 11
**Positive contract**: CLI, include, loader, default-state, validation, callback-source, navigation-source, and diff-scope checks all pass.
**Negative contract**: Do not mark the bundle complete if source audits are the only evidence for visible layout or interactive behavior. Do not edit implementation code inside this verification task except to correct a failed checkpoint and then rerun every affected checkpoint.
**Files**: no project files may be touched unless a failed checkpoint sends the agent back to the owning WRITE task.
**Out of scope**: new feature work, package source, tests, docs, manifests, dependency changes, and broad documentation.
**Verification**: Run `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl")'`; rerun the non-display loader helper smoke from Task 3 without calling no-argument `main`; rerun the helper smokes from Tasks 7 and 10; run missing-path direct CLI; run `rg -n 'directedges!|preorder!|empty!|delete!|ComputePipeline|\\.plots\\b' examples/src/05_interactive_ex1.jl` and confirm no forbidden implementation path; run source audit proving `Makie.update!` and `arg1`; run `git -C . diff --name-only` and confirm implementation changes are limited to `examples/src/05_interactive_ex1.jl`.

Write a closeout section in the implementation report with 1 row per lock item. Each row must name the verification artifact or mark the run blocked. This final automated closeout cannot replace Task 13 visual review.

### 13. Complete GLMakie visual and interactive review

**Type**: REVIEW
**Output**: Human or artifact-backed GLMakie review confirms the final viewer satisfies layout and interaction behavior, or the task is explicitly blocked by display limitations.
**Depends on**: Task 12
**Positive contract**: The reviewer can run the viewer, see demo records, inspect left-sidebar layout, navigate records, change representative boolean, style, numeric, arrow, and color controls, and see invalid input status preserve the last valid plot.
**Negative contract**: Do not mark this REVIEW task complete from source audit alone. Do not hide headless or GLMakie display limitations.
**Files**: no project files may be touched. Screenshot or colorbuffer artifacts must be written under `/tmp` if collected.
**Out of scope**: implementation changes, new controls, package source, tests, docs, manifests, and dependency changes.
**Verification**: Manual run `julia --project=examples examples/src/05_interactive_ex1.jl` confirms no-argument demo viewer; left controls in `fig[1, 1]`; plot in `fig[1, 2]`; main plot visually larger; previous and next wrap; current label changes; `showtiplabel`, `showgamma`, `style`, `minorlinetype = "blank"`, `edgewidth`, `arrowlen`, and at least 2 color controls update the existing plot; invalid color text updates status and preserves the last valid color.

This task is the final HITL gate inherited from Tranche 5. If the environment cannot display GLMakie, record the exact error, collect the strongest possible `/tmp` screenshot or colorbuffer substitute, and mark this task blocked rather than complete. Execution is not final-approved until this review is complete or the project owner accepts the documented display limitation.
