---
date-created: 2026-07-27T00:43:59-0700
workflow-instrument: Tranche plan
workflow-status: Approved
workflow-agent-thread-id: codex/019fa280-bd38-7691-addf-dfc02939bcbe
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-tree-viewer
workflow-prd: .workflow-docs/202607260356_interactive-tree-viewer/01_prd.md
---

# Tranche plan: Interactive tree and network viewer example

## Governance confirmation

This tranche plan was created from `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`.
The parent PRD frontmatter has `workflow-status: Approved`.
This tranche plan is saved as `workflow-status: Proposed`.
Do not advance to tasking or implementation until the user sets this file's frontmatter to `workflow-status: Approved`.

The active authorities for this run are:

- User request from 2026-07-27 to create tranches from `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md` and follow `STYLE-*`, including `STYLE-agent-language.md`.
- Skill instructions: `development-policies` and `devflow-feature-02--prd-to-tranches`.
- Parent PRD: `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`.
- Project governance documents: `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`, `STYLE-agent-language.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`, `STYLE-workflow-vocabulary.md`, and `STYLE-writing.md`.
- Supporting workflow documents: `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`, `.workflow-docs/open/20260615--interactivity1/design/design.md`, and `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`.

The broad workspace search also found archived PhyloMakie governance files under `00-archives/` and `PhyloNetworks.jl/CONTRIBUTING.md`.
Those files are not active governance documents for this PhyloMakie workflow.
`PhyloNetworks.jl/src/readwrite.jl` and `PhyloNetworks.jl/src/manipulateNet.jl` are active upstream primary sources for reader and mutation contracts.

The installed `development-policies` skill directory did not contain a `references/` directory with bundled Markdown governance files.
No bundled depot Markdown file is active for this run beyond the mandates in the `development-policies` skill file.

## Controlled vocabulary

Downstream agents must read `STYLE-vocabulary.md`, `STYLE-workflow-vocabulary.md`, and `STYLE-agent-language.md` line by line before acting on this file.
The tranche work must use these terms consistently:

- `HybridNetwork` for the accepted PhyloNetworks object.
- `tree`, `network`, and `tree or network` for loaded inputs.
- `PhyloPlot` for the Makie recipe plot type and `plot handle` for the object returned by `plot!` or `phyloplot!`.
- `public attribute surface` for the supported PhyloMakie recipe attributes declared in `src/recipe_declaration.jl`.
- `Makie.update!` for widget-driven changes to the existing plot handle.
- `arg1` for replacing the plotted `HybridNetwork`.
- `full-tree style` and `major-tree style` in prose; `:fulltree` and `:majortree` in code.
- `major hybrid edge` and `minor hybrid edge` for hybrid-edge styling behavior.
- `tranche`, `lock item`, `red-state repro`, `handoff packet`, `stop condition`, and `verification artifact` for workflow control.

## Upstream primary sources

Downstream agents must read the project governance documents and the relevant upstream primary sources line by line before implementation or review.
The current examples manifest resolves the Makie-family sources to:

- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/compute-plots.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/recipes.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/figureplotting.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/button.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/checkbox.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/slider.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/toggle.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/menu.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/textbox.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/XzVRj/src/makielayout/blocks/axis.jl` if axis-limit reset behavior is used.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/E2l50/src/ComputePipeline.jl`.
- `/home/jeetsukumaran/.julia/packages/GLMakie/A7mVm/src/GLMakie.jl`.
- `/home/jeetsukumaran/.julia/packages/GLMakie/A7mVm/src/display.jl`.
- `../PhyloNetworks.jl/src/readwrite.jl`.
- `../PhyloNetworks.jl/src/manipulateNet.jl`.

The parent PRD named widget observable facts but did not name the Makie block source files that define `Button.clicks`, `Checkbox.checked`, `Toggle.active`, `Slider.value`, `Menu.selection`, and `Textbox.stored_string`.
This tranche plan adds those Makie block files to downstream reading mandates.

## User-story numbering

This tranche plan numbers the parent PRD user goals as follows:

- User story 1: no-argument demo viewer.
- User story 2: CLI file arguments load every tree or network in deterministic order.
- User story 3: previous and next navigation preserves the plot handle and current style choices.
- User story 4: left-sidebar toggles control labels, numbers, gamma labels, edge lengths, and hybrid-edge visibility.
- User story 5: widgets change scalar widths, label sizes, arrow length, edge colors, hybrid edge colors, and label colors.
- User story 6: maintainers can inspect `Makie.update!` use on the public attribute surface.
- User story 7: reviewers can verify example-layer scope.

## Primary-goal lock coverage

- Lock item 1, standalone CLI: Tranche 1 is responsible for the testable script shell and input loading; Tranche 5 verifies the executable viewer path.
- Lock item 2, reactive public updates: Tranches 3 and 4 are responsible for widget updates through `Makie.update!`; Tranche 5 verifies source and runtime behavior.
- Lock item 3, navigation through `arg1`: Tranche 2 is responsible for previous and next navigation through `Makie.update!(plot_handle; arg1 = selected_network)`.
- Lock item 4, complete requested controls: Tranche 3 is responsible for boolean, `style`, and `minorlinetype` controls; Tranche 4 is responsible for numeric, optional, and color controls.
- Lock item 5, usable left-sidebar layout: Tranche 2 is responsible for the figure layout; Tranche 5 verifies desktop usability.
- Lock item 6, input failures are handled: Tranche 1 is responsible for missing path, unreadable file, parse failure, partial success, and all-failed behavior.
- Lock item 7, example-layer scope: All tranches preserve the example-layer authorization boundary; Tranche 5 performs the final diff and source audit.

## Tranche 1: Input records and CLI shell

**Type**: AFK
**Blocked by**: None; can start immediately.

### Governance and required reading

- Read all active project governance documents line by line, including `STYLE-agent-language.md`, `STYLE-workflow-docs.md`, `STYLE-workflow-vocabulary.md`, `STYLE-vocabulary.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`, and `STYLE-verification.md`.
- Read the parent PRD line by line, including the active authorities, upstream facts, primary-goal lock, settled user decisions, and handoff packet.
- Read `../PhyloNetworks.jl/src/readwrite.jl` and `../PhyloNetworks.jl/src/manipulateNet.jl` line by line for `readnewick`, `readmultinewick`, `readnexus_treeblock`, `directedges!`, and `preorder!`.
- Read current examples `examples/src/03_mwe_reactivity_phylomakie.jl` and `examples/src/04_maxwe_reactivity_phylomakie.jl`.

### Primary-goal lock

- Responsible for lock item 1 by creating a standalone, includeable `examples/src/05_interactive_ex1.jl` with a program-file guard and `main(args = ARGS)::Int`.
- Responsible for lock item 6 by reporting missing files, unreadable files, no parseable records, partial success, and all-failed CLI invocations.
- Preserves lock item 7 by keeping this tranche limited to the new example script plus optional focused example smoke tests.
- The tranche is not complete if file loading directly parses Newick or NEXUS text instead of calling PhyloNetworks readers.
- The tranche is not complete if all-failed user input opens a GLMakie window.

### What to build

Create the new example script as a testable CLI shell that loads demo records or file-provided records without building the full viewer yet.
This tranche is foundational because `examples/src/05_interactive_ex1.jl` must establish the record shape, file-loading policy, warning model, and `main(args = ARGS)::Int` return contract that later viewer code consumes.

The new local function `load_records_from_file(path::AbstractString)` in `examples/src/05_interactive_ex1.jl` must be the only implementation in this script that chooses between `PhyloNetworks.readnexus_treeblock`, `PhyloNetworks.readmultinewick(path, false)`, and `PhyloNetworks.readnewick(path)`.
The local function `load_records(paths::AbstractVector{<:AbstractString})` must call `load_records_from_file` and must preserve file order and record order.
Later viewer code must consume the records returned by these functions and must not call the PhyloNetworks readers directly.

The script should define a small immutable local record type or named tuple that carries `network::HybridNetwork`, `source::String`, and `record_index::Int`.
The no-argument path should call `demo_records()` and return at least 1 tree or network record without requiring local input files.

### Handoff packet

- **Active authorities**: User request; `development-policies`; `devflow-feature-02--prd-to-tranches`; parent PRD; all project `STYLE*.md` files and `CONTRIBUTING.md`.
- **Parent documents**: `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`; older reactive architecture PRD and tranche plan named above.
- **Settled decisions and non-negotiables**: no new dependencies; no command-line option parser package; no custom tree parser; no remote loading; no package API changes; no direct calls to `directedges!` or `preorder!` on user-loaded records.
- **Authorization boundary**: implementation may create `examples/src/05_interactive_ex1.jl` and optional focused smoke tests; changes to `src/`, root `Project.toml`, `examples/Project.toml`, or package public APIs require explicit user approval.
- **Current-state diagnosis**: existing examples are fixed scripts and do not accept positional tree or network file arguments.
- **Primary-goal lock**: lock items 1, 6, and 7.
- **Direct red-state repros**: current examples have hardcoded networks and no CLI file list; an unreadable path can reach upstream reader errors directly if the example script does not catch and report routine input failures.
- **Responsible entity and invariant under repair**: the new local function `load_records_from_file` must implement the reader-selection rule for this example; `load_records` and `main` must consume its result; no sibling helper in the script may keep a second reader-selection implementation. Loader smoke tests fail if file order, record order, or all-failed exit behavior changes.
- **Exact files or surfaces in scope**: `examples/src/05_interactive_ex1.jl`; optional example-environment smoke command or focused test file if it does not add dependencies.
- **Exact files or surfaces out of scope**: `src/`; package public plotting APIs; `Project.toml` files; documentation rewrites; pointer interactions; export or screenshot controls.
- **Required upstream primary sources**: `../PhyloNetworks.jl/src/readwrite.jl`; `../PhyloNetworks.jl/src/manipulateNet.jl`.
- **Green-state gates**: include smoke for the script; loader smoke for single Newick, multi-Newick, and, where supported by PhyloNetworks, NEXUS tree-block input; CLI missing-path smoke exits nonzero and includes the path.
- **Stop conditions**: stop if the loader contract requires a new dependency, direct parsing, mutation of caller-owned `HybridNetwork` records, or package-source changes.

### How to verify

- **Manual**: run from the package root with a missing path and confirm the script exits before creating a GLMakie window while printing a concise path-specific error.
- **Automated**: run `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl")'` from `workflow-location`; create temporary single-Newick and multi-Newick files and call loader helpers; run the script with a missing path and confirm nonzero exit status plus path text.

### Acceptance criteria

- [ ] Given no CLI arguments, when `demo_records()` runs, then it returns at least 1 `HybridNetwork` record with source metadata.
- [ ] Given 1 single-Newick file path, when `load_records([path])` runs, then it returns 1 record with `record_index == 1`.
- [ ] Given 1 multi-Newick file with 1 topology per line, when `load_records([path])` runs, then records appear in file order.
- [ ] Given a NEXUS trees block, when `load_records([path])` runs and PhyloNetworks supports the file, then returned records preserve upstream order.
- [ ] Given no parseable records from user-provided paths, when `main(args)` runs, then it returns nonzero before building a GLMakie figure.
- [ ] Given 1 valid path and 1 invalid path, when `load_records(paths)` runs, then it returns valid records and reports the skipped path.

### User stories addressed

- User story 1: no-argument demo viewer.
- User story 2: CLI file arguments load every tree or network in deterministic order.
- User story 7: reviewers can verify example-layer scope.

## Tranche 2: Viewer layout and navigation

**Type**: AFK
**Blocked by**: Tranche 1.

### Governance and required reading

- Read all active project governance documents line by line, including `STYLE-agent-language.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, and vocabulary authorities.
- Read the parent PRD line by line, especially viewer layout, navigation controls, update model, lock items 2, 3, 5, and 7.
- Read `src/recipe_declaration.jl`, `src/recipe.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`, and `test/test_recipe.jl`.
- Read Makie sources: `compute-plots.jl`, `recipes.jl`, `figureplotting.jl`, `button.jl`, and `axis.jl` if axis-limit reset is used.
- Read GLMakie sources: `GLMakie.jl` and `display.jl`.

### Primary-goal lock

- Responsible for lock item 3 by updating the plotted `HybridNetwork` through `Makie.update!(plot_handle; arg1 = selected_network)`.
- Responsible for the layout portion of lock item 5 by placing controls in `fig[1, 1]` and the tree or network axis in `fig[1, 2]`.
- Helps close lock item 2 by establishing the existing plot handle that later widget tranches update.
- Preserves lock item 7 by keeping viewer code inside `examples/src/05_interactive_ex1.jl`.
- The tranche is not complete if previous or next navigation clears the axis, replaces the plot handle as its normal update path, mutates `plot_handle.plots`, or loses current visualization state.

### What to build

Build the GLMakie viewer skeleton around records from Tranche 1.
The first screen must be the interactive viewer.
The new local function `build_viewer(records, warnings)` must create a `Figure`, a left `GridLayout` in `fig[1, 1]`, an `Axis` in `fig[1, 2]`, an initial `PhyloPlot` plot handle via `plot!` or `phyloplot!`, previous and next `Button` controls, a current-record label, and a status label.

The new local function `select_record!(plot_handle, viewer_state, records, index)` must update the existing plot handle with `Makie.update!(plot_handle; arg1 = selected_network)` and update the record label.
If axis limits do not refit after navigation, this function may call a verified Makie axis-limit reset helper after the `arg1` update; the implementation notes must name the Makie source line or function that justifies that helper.

### Handoff packet

- **Active authorities**: User request; parent PRD; all project governance documents; Makie and GLMakie upstream source files listed for this tranche.
- **Parent documents**: `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`; Tranche 1 result.
- **Settled decisions and non-negotiables**: use GLMakie; first screen is the viewer; left sidebar and larger main plot area are mandatory; previous and next wrap around; navigation preserves style state; navigation uses `arg1`.
- **Authorization boundary**: `build_viewer` and navigation helpers may be implemented in the example script; package internals and public APIs remain out of scope.
- **Current-state diagnosis**: existing examples demonstrate scripted `Makie.update!` calls but do not provide previous and next user controls.
- **Primary-goal lock**: lock items 2, 3, 5, and 7.
- **Direct red-state repros**: existing reactivity examples only perform scripted `arg1` updates; rebuilding the axis or plot from a button callback would show navigation but would not demonstrate the reactive PhyloMakie plot handle.
- **Responsible entity and invariant under repair**: `build_viewer` must create the single `PhyloPlot` plot handle for the viewer; `select_record!` must be the only navigation callback path that changes the displayed `HybridNetwork`; button callbacks must call `select_record!` and must not call `plot!`, `empty!`, or `delete!` to rebuild normal navigation. Child-identity or source-audit checks fail if navigation creates a second plot handle path.
- **Exact files or surfaces in scope**: `examples/src/05_interactive_ex1.jl`; optional smoke test that includes the script and calls non-displaying helper functions.
- **Exact files or surfaces out of scope**: full attribute control panel; numeric and color validation; package internals; pointer interactions; screenshots unless used for verification.
- **Required upstream primary sources**: Makie `compute-plots.jl`, `recipes.jl`, `figureplotting.jl`, `button.jl`, optional `axis.jl`, GLMakie `GLMakie.jl`, and GLMakie `display.jl`.
- **Green-state gates**: source inspection shows `Makie.update!(plot_handle; arg1 = ...)`; manual no-argument run opens the viewer; navigation changes topology and current-record label; plot handle identity stays stable during navigation.
- **Stop conditions**: stop if GLMakie cannot display in the environment and no non-displaying helper path can verify the code; stop if navigation requires package-source changes.

### How to verify

- **Manual**: run `julia --project=examples examples/src/05_interactive_ex1.jl` from `workflow-location`; confirm a GLMakie window opens with controls on the left and a larger plot area on the right; click previous and next; confirm the current item label changes and the plotted topology changes.
- **Automated**: include the script; construct demo records; call helper logic that computes previous and next indices; source-audit the script for `Makie.update!(plot_handle; arg1 =` and absence of normal navigation calls to `empty!`, `delete!`, or axis-clearing code.

### Acceptance criteria

- [ ] Given loaded records, when `build_viewer(records, warnings)` runs, then it creates a `Figure` with controls in `fig[1, 1]` and an `Axis` in `fig[1, 2]`.
- [ ] Given the first displayed record, when next is clicked, then `select_record!` updates the existing plot handle through `arg1`.
- [ ] Given the first displayed record, when previous is clicked, then navigation wraps to the last record.
- [ ] Given multiple records and a non-default viewer state, when navigation runs, then state values remain available for later attribute refresh.
- [ ] Given source inspection of the script, then normal navigation does not clear the axis, mutate child primitive lists, or recreate the plot handle.

### User stories addressed

- User story 1: no-argument demo viewer.
- User story 3: previous and next navigation preserves the plot handle and current style choices.
- User story 6: maintainers can inspect `Makie.update!` use on the public attribute surface.
- User story 7: reviewers can verify example-layer scope.

## Tranche 3: Boolean and style controls

**Type**: AFK
**Blocked by**: Tranche 2.

### Governance and required reading

- Read all active project governance documents line by line, especially `STYLE-agent-language.md`, `STYLE-makie.md`, `STYLE-vocabulary.md`, `STYLE-upstream-contracts.md`, and `STYLE-verification.md`.
- Read the parent PRD sections for reactive visualization controls, update model, lock items 2, 4, and 7.
- Read `src/recipe_declaration.jl`, `src/plot_config.jl`, `src/reactive_graph.jl`, `src/primitive_channels.jl`, and the public update tests listed in Tranche 2.
- Read Makie `checkbox.jl`, `toggle.jl`, `menu.jl`, and `compute-plots.jl`.

### Primary-goal lock

- Responsible for the boolean and style portion of lock item 4 for `useedgelength`, `showtiplabel`, `shownodelabel`, `shownodenumber`, `showedgelength`, `showedgenumber`, `showgamma`, `style`, and `minorlinetype`.
- Helps close lock item 2 by routing those widget changes through `Makie.update!` on the existing plot handle.
- Preserves lock item 7 by not changing package attribute declarations or normalization code.
- The tranche is not complete if any listed boolean or style control is missing, initialized to a value different from the PRD default, or implemented by assigning an `Observable` directly to a plot attribute.

### What to build

Add the left-sidebar controls for boolean attributes, full-tree style, major-tree style, and minor hybrid edge line type.
The new local function `default_viewer_state()` must return the exact PRD defaults for all public attributes, including controls that later tranches render.
The new local function `apply_viewer_state!(plot_handle, state)` must call `Makie.update!` with public attributes from the viewer state.

Checkbox or toggle callbacks must update the local viewer state and then call `apply_viewer_state!`.
The `style` menu must expose `:fulltree` and `:majortree`.
The `minorlinetype` control must expose automatic behavior as `nothing` plus supported line-style values, including `"blank"` for hiding minor hybrid edges.

### Handoff packet

- **Active authorities**: User request; parent PRD; all project governance documents; Makie widget and update source files.
- **Parent documents**: `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`; Tranches 1 and 2.
- **Settled decisions and non-negotiables**: `style` control is required; boolean controls use `Checkbox` or `Toggle`; `minorlinetype` supports `nothing` and `"blank"`; callbacks call `Makie.update!` on the existing plot handle.
- **Authorization boundary**: the example script may add local state and widget helpers; changes to `src/recipe_declaration.jl` or `src/plot_config.jl` are out of scope unless a missing package capability is proven and approved.
- **Current-state diagnosis**: the public attribute surface already declares the requested attributes; existing examples show scripted updates but not widget-driven updates.
- **Primary-goal lock**: lock items 2, 4, and 7.
- **Direct red-state repros**: a partial control panel omits user-requested toggles; a callback that rebuilds the plot hides the `Makie.update!` public update path.
- **Responsible entity and invariant under repair**: `default_viewer_state` must be the only local default table for this example; `apply_viewer_state!` must be the only local function that applies public attribute changes from widget state to the plot handle; boolean and menu callbacks must call `apply_viewer_state!` and must not call `plot!`, mutate child primitives, or write internal ComputePipeline nodes. Source audit fails if another callback keeps a second public-attribute update implementation.
- **Exact files or surfaces in scope**: `examples/src/05_interactive_ex1.jl`; optional helper tests or source audit.
- **Exact files or surfaces out of scope**: numeric controls; color controls; package attribute declaration changes; dictionary editors; DataFrame label editors.
- **Required upstream primary sources**: Makie `checkbox.jl`, `toggle.jl`, `menu.jl`, `compute-plots.jl`; project `src/recipe_declaration.jl`, `src/plot_config.jl`, and `src/primitive_channels.jl`.
- **Green-state gates**: source inspection maps every boolean, `style`, and `minorlinetype` requirement to a widget and callback; runtime smoke verifies at least `showtiplabel`, `showgamma`, `style`, and `"blank"` minor line type change the existing plot.
- **Stop conditions**: stop if a requested control is not present in `src/recipe_declaration.jl`; stop before broadening the public attribute surface.

### How to verify

- **Manual**: run the viewer; toggle tip labels and gamma labels; switch from full-tree style to major-tree style; set minor hybrid edge line type to `"blank"`; confirm visible changes without the window recreating the axis.
- **Automated**: include the script; inspect `default_viewer_state()` values; source-audit callback helpers for `Makie.update!` and absence of direct ComputePipeline node mutation.

### Acceptance criteria

- [ ] Given the viewer starts, then the boolean controls initialize to the PRD defaults.
- [ ] Given `style` is set to `:majortree`, when the callback runs, then `apply_viewer_state!` calls `Makie.update!` on the existing plot handle.
- [ ] Given `minorlinetype` is set to `"blank"`, when the callback runs, then minor hybrid edge visibility updates through the public attribute surface.
- [ ] Given source inspection, then boolean and menu callbacks do not assign `Observable` objects directly to plot attributes.

### User stories addressed

- User story 4: left-sidebar toggles control labels, numbers, gamma labels, edge lengths, and hybrid-edge visibility.
- User story 6: maintainers can inspect `Makie.update!` use on the public attribute surface.
- User story 7: reviewers can verify example-layer scope.

## Tranche 4: Numeric and color controls

**Type**: AFK
**Blocked by**: Tranche 3.

### Governance and required reading

- Read all active project governance documents line by line, especially `STYLE-agent-language.md`, `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, and vocabulary authorities.
- Read the parent PRD sections for reactive visualization controls, error handling and status, update model, lock items 2, 4, 6, and 7.
- Read `src/recipe_declaration.jl`, `src/plot_config.jl`, `src/primitive_channels.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`, and `test/test_recipe.jl`.
- Read Makie `slider.jl`, `textbox.jl`, and `compute-plots.jl`.

### Primary-goal lock

- Responsible for the numeric and color portion of lock item 4 for `edgewidth`, `nodecex`, `edgecex`, `arrowlen`, `edgecolor`, `defaultedgecolor`, `majorhybridedgecolor`, `minorhybridedgecolor`, `nodelabelcolor`, `edgelabelcolor`, and `edgenumbercolor`.
- Helps close lock item 2 by routing numeric and color controls through `Makie.update!`.
- Helps close lock item 6 by making invalid widget input leave the last valid state active and update the sidebar status label.
- Preserves lock item 7 by keeping validation local to the example shell and not changing package validation behavior.
- The tranche is not complete if invalid color or numeric text crashes a callback, desynchronizes the UI from the displayed plot, or mutates package internals.

### What to build

Add bounded numeric widgets for `edgewidth`, `nodecex`, and `edgecex`.
Add `arrowlen` controls that support `nothing` for automatic behavior and a numeric value when enabled.
Add compact text boxes for all requested color controls.
For `defaultedgecolor`, empty input must mean `nothing`.

The local validation functions must parse widget values, update the local viewer state only after successful parsing, call `apply_viewer_state!`, and update the sidebar status label on failure.
The local function that parses a color string must verify values through Makie's color conversion path before writing state.
The local function that parses a numeric control must reject invalid or out-of-range values without changing the active state.

### Handoff packet

- **Active authorities**: User request; parent PRD; all project governance documents; Makie slider, textbox, and update source files.
- **Parent documents**: `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`; Tranches 1 through 3.
- **Settled decisions and non-negotiables**: color controls use compact text boxes; invalid input reports status and preserves the last valid value; no dictionary-valued editors; no DataFrame editors; no package validation changes.
- **Authorization boundary**: local example validation may prevent bad widget input before calling `Makie.update!`; PhyloMakie package validation remains unchanged.
- **Current-state diagnosis**: the package public attribute surface accepts these attributes and existing tests prove scripted updates; the example still needs user-facing widgets and callback validation.
- **Primary-goal lock**: lock items 2, 4, 6, and 7.
- **Direct red-state repros**: a partial control panel omits user-requested numeric or color controls; invalid widget input crashes the callback or leaves UI text implying a value that the plot did not accept.
- **Responsible entity and invariant under repair**: local parse helpers in `examples/src/05_interactive_ex1.jl` must be the only example code that converts text-box and optional numeric widget values into state fields; `apply_viewer_state!` must remain the only local public-attribute update function; widget callbacks must not call `Makie.update!` with unvalidated text values. Validation smoke tests fail if bad input changes state or bypasses the status label.
- **Exact files or surfaces in scope**: `examples/src/05_interactive_ex1.jl`; optional helper tests or source audit.
- **Exact files or surfaces out of scope**: package color validation changes; dictionary-valued `edgecolor` or `edgewidth` editors; `nodelabel` and `edgelabel` DataFrame editors; save or screenshot controls.
- **Required upstream primary sources**: Makie `slider.jl`, `textbox.jl`, `compute-plots.jl`; project `src/plot_config.jl` and `src/primitive_channels.jl`.
- **Green-state gates**: source inspection maps every requested numeric and color attribute to a widget and callback; runtime smoke verifies at least 1 numeric control and 1 color control visibly update the existing plot; invalid color and invalid numeric input leave the last valid value active and report status.
- **Stop conditions**: stop if validation requires a new dependency; stop if a widget value cannot be represented through the current public attribute surface.

### How to verify

- **Manual**: run the viewer; change edge width, node label size, edge label size, arrow length, edge color, major hybrid edge color, minor hybrid edge color, node label color, edge label color, and edge number color; type an invalid color and confirm the status label reports it while the plot keeps the last valid color.
- **Automated**: include the script; call validation helpers for valid and invalid color strings, empty `defaultedgecolor`, valid and invalid numeric input, `nothing` arrow length, and numeric arrow length; source-audit callbacks for `apply_viewer_state!`.

### Acceptance criteria

- [ ] Given the viewer starts, then numeric and color controls initialize to the PRD defaults.
- [ ] Given a valid numeric widget change, when the callback runs, then state changes and `apply_viewer_state!` updates the plot handle.
- [ ] Given invalid numeric input, when validation runs, then state remains unchanged and the status label reports the failure.
- [ ] Given a valid color string, when validation runs, then the value is accepted and applied through `Makie.update!`.
- [ ] Given invalid color text, when validation runs, then the last valid color remains active and the callback does not crash.
- [ ] Given empty `defaultedgecolor`, when validation runs, then the active value is `nothing`.

### User stories addressed

- User story 5: widgets change scalar widths, label sizes, arrow length, edge colors, hybrid edge colors, and label colors.
- User story 6: maintainers can inspect `Makie.update!` use on the public attribute surface.
- User story 7: reviewers can verify example-layer scope.

## Tranche 5: Example verification and closeout

**Type**: HITL
**Blocked by**: Tranche 4.

### Governance and required reading

- Read all active project governance documents line by line, especially `STYLE-agent-handoffs.md`, `STYLE-agent-language.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-workflow-docs.md`, `STYLE-workflow-vocabulary.md`, and `STYLE-vocabulary.md`.
- Read the parent PRD line by line, especially the verification plan, settled user decisions, primary-goal lock, and handoff packet.
- Read Tranches 1 through 4 and revalidate their handoff packets against current source.
- Read every upstream primary source cited by any implemented tranche and any additional source cited in implementation notes.

### Primary-goal lock

- Finalizes lock items 1 through 7 by running the strongest available automated, source-audit, and manual GLMakie checks.
- The tranche is not complete if source audits are the only evidence for visible layout or interactive behavior.
- The tranche is not complete if the final report omits unverified GLMakie behavior, headless limitations, or any deviation from the parent PRD.
- The tranche is not complete if the final diff changes package runtime behavior outside `examples/src/05_interactive_ex1.jl` without explicit user approval.

### What to build

Perform final example verification and closeout.
This tranche may add or adjust focused smoke checks if earlier tranches left verification gaps, but it should not add new user-facing controls or change the package public API.
It must produce a clear implementation report or final handoff note that records executed commands, manual GLMakie checks, screenshot or colorbuffer evidence when available, source-audit results, and any unverified residual risk.

This tranche is HITL because the parent PRD requires manual GLMakie inspection of the left-sidebar layout, control text, navigation, and representative interactive changes.
If the implementation environment can produce screenshots or colorbuffer evidence, the implementing agent may collect those artifacts before human review.

### Handoff packet

- **Active authorities**: User request; parent PRD; all project governance documents; all upstream sources cited by Tranches 1 through 4.
- **Parent documents**: `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`; Tranches 1 through 4; implementation notes from completed tranches.
- **Settled decisions and non-negotiables**: final verification must cover CLI, loading, navigation through `arg1`, all controls, invalid input status, layout, and example-layer scope; do not advance to tasking from this proposed tranche file until approved.
- **Authorization boundary**: closeout verification may add focused smoke checks or notes; new feature work, package API changes, dependency changes, broad docs rewrites, and source compatibility deletion are out of scope.
- **Current-state diagnosis**: earlier tranches should have created the full example; this tranche verifies the externally observable behavior and the source shape against every lock item.
- **Primary-goal lock**: lock items 1 through 7.
- **Direct red-state repros**: hardcoded-only examples; plot rebuilds from callbacks; navigation not using `arg1`; partial control panel; overlapping controls; unhandled input failure; package-internal changes made to support an example.
- **Responsible entity and invariant under repair**: final verification must treat `examples/src/05_interactive_ex1.jl` as the only implementation surface for this feature; it must inspect `load_records_from_file`, `load_records`, `build_viewer`, `select_record!`, `default_viewer_state`, `apply_viewer_state!`, and validation helpers if those names exist. The report must name any changed helper names and verify that their responsibilities still match the tranche handoff packets.
- **Exact files or surfaces in scope**: `examples/src/05_interactive_ex1.jl`; focused smoke tests or verification notes; generated screenshots or colorbuffer artifacts if collected.
- **Exact files or surfaces out of scope**: package public APIs; package internals; dependency files; broad documentation changes; pointer interactions; export controls.
- **Required upstream primary sources**: all Makie, ComputePipeline, GLMakie, PhyloNetworks, and project source files cited above or by implementation notes.
- **Green-state gates**: include smoke, loader smoke, CLI error smoke, source audits, manual GLMakie run with no args, manual or screenshot layout verification, representative control updates, navigation handle identity, and final diff review.
- **Stop conditions**: stop if GLMakie cannot be manually or artifact-verified and no substitute is recorded; stop if any lock item survives; stop if final behavior depends on unapproved package-source changes.

### How to verify

- **Manual**: run `julia --project=examples examples/src/05_interactive_ex1.jl`; confirm no-argument demo records open; inspect sidebar placement and text fit; click previous and next; change representative boolean, style, numeric, and color controls; type invalid color text; verify status reporting and plot stability.
- **Automated**: run include smoke; run loader smoke for single-Newick, multi-Newick, and NEXUS where supported; run CLI missing-path smoke; run source audits for `Makie.update!`, `arg1`, absence of normal-path axis clearing, absence of child primitive mutation, and absence of package-source edits; run the project test suite if any package source or package tests changed.

### Acceptance criteria

- [ ] Given all tranches are implemented, when source audits run, then widget updates use `Makie.update!` and navigation uses `arg1`.
- [ ] Given the no-argument CLI invocation, when the viewer opens, then it shows demo records and a left-sidebar plus main-body layout.
- [ ] Given file paths for single-Newick, multi-Newick, and supported NEXUS inputs, when loader smoke runs, then record order is deterministic.
- [ ] Given invalid user input, when the corresponding callback runs, then the status label reports the failure and the last valid plot state remains active.
- [ ] Given final diff review, then package runtime behavior outside `examples/src/05_interactive_ex1.jl` is unchanged unless explicitly approved.
- [ ] Given headless or display limitations, then the implementation report records the limitation and the strongest completed substitute checks.

### User stories addressed

- User story 1: no-argument demo viewer.
- User story 2: CLI file arguments load every tree or network in deterministic order.
- User story 3: previous and next navigation preserves the plot handle and current style choices.
- User story 4: left-sidebar toggles control labels, numbers, gamma labels, edge lengths, and hybrid-edge visibility.
- User story 5: widgets change scalar widths, label sizes, arrow length, edge colors, hybrid edge colors, and label colors.
- User story 6: maintainers can inspect `Makie.update!` use on the public attribute surface.
- User story 7: reviewers can verify example-layer scope.
