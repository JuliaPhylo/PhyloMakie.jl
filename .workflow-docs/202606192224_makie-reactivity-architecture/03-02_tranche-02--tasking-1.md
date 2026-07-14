---
date-created: 2026-07-14T00:23:02-07:00
workflow-instrument: Tasking plan
workflow-status: Proposed
workflow-agent-thread-id: codex/019f5f7c-8536-7933-a86c-8f51a3e797f6
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-02
---

# Tasks for Tranche 2: Reactive graph layer foundation

This tasking file covers Tranche 2 of `reactive-makie-spine`, titled "Reactive graph layer foundation" in the approved tranche file. In this tasking file, "reactive graph layer" means the file `src/reactive_graph.jl` and the functions `register_phylo_graph!`, `_register_phylo_intermediate_nodes!`, `register_primitive_graph_outputs!`, `register_text_graph_outputs!`, and their named registration helpers. Those functions must register Makie/ComputePipeline output nodes from public `PhyloPlot` inputs to primitive argument values. This file authorizes no implementation while its own `workflow-status` is `Proposed`; a project maintainer must set this file to `Approved` before an implementation agent begins work.

The repository was revalidated before tasking. `git status --short` reported no changes before this file was written, Tranche 1 files `src/plot_config.jl`, `src/network_layout.jl`, `src/annotation_tables.jl`, and `src/primitive_channels.jl` were present, and the baseline suite passed:

```text
Test Summary: | Pass  Total     Time
PhyloMakie.jl |  353    353  1m41.4s
```

The current state is therefore the intended post-Tranche-1 and pre-Tranche-2 state: functions such as `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels` exist and are used by the old rebuild recipe path, while `Makie.plot!(plot::PhyloPlot)` still installs a broad `Makie.onany` rebuild callback and no file `src/reactive_graph.jl` defines `register_phylo_graph!` or the graph-output types.

## Settled user decisions and environment baseline

- Public plotting entry points and public attributes remain protected: `Makie.plot`, `Makie.plot!`, `phyloplot`, `phyloplot!`, `PhyloPlot`, and the current keyword surface must keep working.
- The approved workflow is a deep internal architecture correction, not a public API redesign.
- The approved PRD assigns responsibility to three code areas: Tranche 1 functions `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels` calculate values; Tranche 2 functions in `src/reactive_graph.jl` register output nodes that expose those values; Tranche 3 changes `Makie.plot!(plot::PhyloPlot)` so child primitives consume those output nodes. Tranche 2 may modify only the second area.
- `src/reactive_graph.jl` must define `register_phylo_graph!(plot::PhyloPlot)` and helper functions that register the `PhyloPlot` compute graph.
- `Makie.update!(plot; ...)` is the dynamic entrypoint to prove for this tranche. Graph tests must call `Makie.update!(plot; edgecolor=...)`, `Makie.update!(plot; style=...)`, `Makie.update!(plot; arg1=new_net)`, and limit or text updates.
- The positional recipe argument update path is `arg1`. The named recipe output node `:net` may be used as a graph input because Makie maps `:arg1` through conversion and recipe argument naming, but tests must prove `Makie.update!(plot; arg1=new_net)`.
- Public plotting must preserve caller-owned `HybridNetwork` inputs. Graph registration must call `prepare_plot_network`; it must not call `PhyloNetworks.directedges!` or `PhyloNetworks.preorder!` directly.
- Existing internal scaffold names are not names for the new graph-registration API. Tranche 2 tests must target `register_phylo_graph!` and graph-output types, not `render_plot!`, `PlotRenderLayers`, `PlotLayout`, or `PhyloPlotAttributes`.
- The broad rebuild callback in `src/recipe.jl`, child primitive replacement, `render_plot!` removal, and stable primitive assembly are Tranche 3 work. Tranche 2 must not claim them complete.
- Pointer interactions remain out of scope.
- Do not add dependencies or edit `Project.toml`, `Manifest.toml`, `docs/Project.toml`, `docs/Manifest.toml`, `test/Project.toml`, or `test/Manifest.toml`. If a dependency change appears necessary, stop and ask for project-maintainer approval.
- Use the local upstream sources already present in this workspace. Do not use network access for this tranche unless explicitly approved.
- The parent PRD and codeplan frontmatter remain `Proposed`; `02_tranches.md` and Tranche 1 tasking are `Approved`. Treat this file as a proposed tasking plan only until its frontmatter is changed to `Approved`.

## Governance

An implementation agent must read these governance documents line by line before touching files:

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

The bundled development-policy depot was consulted. Its `references/` directory exists but contains no Markdown authority files in this environment. The project-local files listed above are the active project authorities. Expected bundled files such as `references/CONTRIBUTING.md`, `references/STYLE-python.md`, and `references/STYLE-vocabulary.md` were not present; this is not a blocker because project-local governance provides the needed authorities.

Read-only git and shell commands may be used freely for diagnosis. Mutating git operations such as commit, merge, push, rebase, reset, checkout for branch changes, and branch creation remain the human project maintainer's responsibility unless the user explicitly instructs otherwise.

Controlled vocabulary constraints:

- Use `HybridNetwork`, `Makie-native public plot owner`, `public attribute surface`, `full-tree style`, `major-tree style`, `major hybrid edge`, and `minor hybrid edge` as defined in `STYLE-vocabulary.md`.
- Use `tranche`, `lock item`, `red-state repro`, `handoff packet`, `upstream primary source`, `verification artifact`, and `stop condition` as defined in `STYLE-workflow-vocabulary.md`.
- Use `reactive graph layer` only with the meaning given at the top of this file: `src/reactive_graph.jl` plus the named registration functions and output-type definitions. Do not add the phrase to `STYLE-vocabulary.md` in this tranche.
- Treat `render_plot!`, `PhyloPlotAttributes`, `PlotLayout`, and `PlotRenderLayers` as old scaffold names. They may survive only as pre-Tranche-3 transitional runtime debt, not as names in `src/reactive_graph.jl` or `test/test_reactive_graph.jl` for the new graph-registration API.

## Primary-goal lock

### Lock 1: `src/reactive_graph.jl` defines graph registration

- The work is not complete if no file defines functions that register input-to-output mappings for `PhyloPlot`.
- Direct red-state repro: current code has no `src/reactive_graph.jl`, no `register_phylo_graph!`, and no graph-output types; `Makie.plot!(plot::PhyloPlot)` directly computes values inside a broad rebuild callback.
- Tasks that close it: 1, 2, 3, 4.
- Verification artifact: `test/test_reactive_graph.jl` must fail the current implementation because `register_phylo_graph!`, `PhyloGraphOutputs`, and `PhyloTextGraphOutputs` do not exist, then pass after graph registration exists and returns the declared output-name structs.

### Lock 2: Every reactive primitive argument has its own final output node

- The work is not complete if segment, arrowhead, text, or data-limit primitive arguments remain available only by dereferencing `:primitive_channels`, by unpacking a struct, tuple, or dictionary inside future `Makie.plot!`, or by snapshot values in `src/recipe.jl`.
- Direct red-state repro: current code computes `PrimitiveChannels` and then `render_plot!` dereferences fields to construct primitives, with no separate output nodes such as `:edge_segment_points`, `:tip_label_strings`, `:minor_arrowhead_meshes`, or `:data_limits`.
- Tasks that close it: 3, 4.
- Verification artifact: graph-output tests must enumerate every required segment, arrowhead, text, and `:data_limits` symbol, assert each symbol exists in `plot.attributes.outputs`, and compare node values to the matching field of `plot[:primitive_channels][]`. A fake fix that registers only `:primitive_channels` must fail.

### Lock 3: Graph recomputation is proven through `Makie.update!`

- The work is not complete if Tranche 2 graph tests mutate only `plot[:edgecolor][]`, `plot[:style][]`, `plot[:net][]`, or any other compute node directly.
- Direct red-state repro: current `test/test_recipe.jl` proves visible changes by direct node mutation: `plot_handle[:edgecolor][] = ...`, `plot_handle[:style][] = ...`, and `plot_handle[:net][] = ...`.
- Tasks that close it: 5.
- Verification artifact: `test/test_reactive_graph.jl` must call `Makie.update!(plot; edgecolor=...)`, `Makie.update!(plot; style=...)`, `Makie.update!(plot; arg1=new_net)`, and limit or text keyword updates, then prove the relevant output nodes recompute. A direct-node-mutation-only implementation must fail this task's review and file-content audit.

### Lock 4: Recipe argument updates preserve caller-owned networks

- The work is not complete if `Makie.update!(plot; arg1=new_net)` mutates the caller-owned `HybridNetwork` while preparing graph outputs.
- Direct red-state repro: `PhyloNetworks.directedges!` mutates edge direction and root state, and `PhyloNetworks.preorder!` mutates `net.vec_node` and `net.vec_bool`. A graph node that calls those functions directly on the input network would reproduce the old caller-owned-network mutation failure.
- Tasks that close it: 2, 5.
- Verification artifact: a graph test must snapshot a fresh `readnewick` network, call `Makie.update!(plot; arg1=new_net)`, read graph outputs, and assert the caller-owned `new_net` snapshot is unchanged while `plot[:plot_network][].net` is a distinct prepared copy with populated traversal state.

### Lock 5: Public behavior and Tranche 1 computation remain green

- The work is not complete if existing public plotting behavior, Tranche 1 function tests, render tests, Aqua, or JET regress without explicit project-maintainer approval.
- Direct red-state repro: the current green baseline is `353` passing tests, including Tranche 1 function tests and current render-path tests.
- Tasks that close it: all tasks.
- Verification artifact: every task must run its targeted tests, and the final task must run `julia --project=test test/runtests.jl`. Any failure caused by the tranche must be fixed in the tranche or escalated.

### Lock 6: Old scaffold names are not graph-registration proof targets

- The work is not complete if new graph tests or `src/reactive_graph.jl` depend on `render_plot!`, `PlotRenderLayers`, `PlotLayout`, `PhyloPlotAttributes`, or render-test helper metadata as proof that graph-registration output nodes exist.
- Direct red-state repro: current render tests still use `render_plot!` and `PlotRenderLayers`; those are accepted only as transitional render-path debt until Tranche 3.
- Tasks that close it: 1, 6.
- Verification artifact: file-content audit must show `src/reactive_graph.jl` and `test/test_reactive_graph.jl` do not reference `render_plot!`, `PlotRenderLayers`, `PlotLayout`, or `PhyloPlotAttributes`. A graph test that proves outputs through render metadata from `PlotRenderLayers` must fail this audit.

### Lock 7: Tranche 3 primitive integration does not enter Tranche 2

- The work is not complete if this tranche removes the broad rebuild callback, replaces `render_plot!`, changes child primitive construction, passes graph outputs into child primitives, or converts current arrowhead rendering to a stable `poly!` child.
- Direct red-state repro: Tranche 3 is assigned broad-callback removal, stable child primitive identity, direct primitive output-node consumption, and the single stable `poly!` arrowhead child.
- Tasks that close it: all tasks, especially 6.
- Verification artifact: final file-content audit must confirm `src/recipe.jl` still contains the current broad rebuild path unless a later approved tasking file supersedes this one, and `src/reactive_graph.jl` contains no calls to `Makie.linesegments!`, `Makie.text!`, `Makie.poly!`, `Makie.arrows2d!`, `delete!`, or `empty!(plot.plots)`.

### Lock 8: External scope, dependency, and docs limits hold

- The work is not complete if the tranche implements pointer interactions, edits docs narrative, renames public attributes, edits manifests, adds dependencies, or expands beyond `HybridNetwork` plotting.
- Direct red-state repro: the PRD explicitly defers pointer interactions and forbids public attribute redesign and dependency drift for this workflow.
- Tasks that close it: all tasks.
- Verification artifact: final audit must show no changes to docs pages, dependency manifests, public attribute names, pointer-interaction code paths, or non-`HybridNetwork` plotting behavior.

## Handoff packet

- **Active authorities**: this tasking file after approval; `02_tranches.md`; `01_prd.md`; `codeplan.md`; Tranche 1 tasking; project-local governance files listed in the Governance section; local upstream primary sources listed below.
- **Parent documents**: `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`, and `.workflow-docs/202606192224_makie-reactivity-architecture/03-01_tranche-01--tasking-1.md`.
- **Settled decisions and non-negotiables**: build `src/reactive_graph.jl`; preserve public attributes and entrypoints; use `map!` for unconditional recomputation; reserve `register_computation!` for changed-input or cached-output behavior only; expose one final output node per primitive argument; prove graph recomputation through `Makie.update!`; keep caller-owned `HybridNetwork` inputs unmutated; do not enter primitive assembly, docs rewrite, dependency change, or pointer interaction work.
- **Authorized and forbidden work**: `src/reactive_graph.jl`, `test/test_reactive_graph.jl`, and the include/test-loader files may be added or edited for graph registration. Public API redesign, primitive assembly integration, callback removal, docs rewrite, dependency changes, and pointer interactions are not authorized here.
- **Current-state diagnosis**: Tranche 1 files `src/plot_config.jl`, `src/network_layout.jl`, `src/annotation_tables.jl`, and `src/primitive_channels.jl` are present and tests are green. `src/recipe.jl` still contains the broad `Makie.onany` rebuild callback. No file currently registers output nodes for primitive arguments.
- **Primary-goal lock**: lock items 1 through 8 in this file.
- **Direct red-state repros**: absence of `src/reactive_graph.jl`; absence of `register_phylo_graph!`; `render_plot!` as current primitive/render shell; graph tests absent; current dynamic recipe test mutates compute nodes directly; direct network traversal preparation would mutate input networks.
- **Responsibility and rule being added**: `src/reactive_graph.jl` must define `register_phylo_graph!(plot::PhyloPlot)` so public graph inputs map to named primitive output nodes. The rule is that every reactive primitive argument has a named output symbol and recomputes from values produced by `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels` after `Makie.update!`.
- **Exact files in scope**: `src/reactive_graph.jl`, `src/PhyloMakie.jl`, `test/test_reactive_graph.jl`, `test/test_PhyloMakie.jl`, `test/runtests.jl`.
- **Conditionally in scope**: `src/recipe.jl` only if a minimal exported-name or include-order adjustment is required to let graph registration compile; it must not remove the broad rebuild callback or change child primitive construction in this tranche.
- **Exact files and surfaces out of scope**: `src/render_adapter.jl`, `src/plot_config.jl`, `src/network_layout.jl`, `src/annotation_tables.jl`, `src/primitive_channels.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`, docs pages, dependency manifests, public attribute names, pointer interactions, and stable primitive assembly.
- **Required upstream primary sources**: `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`, `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`, `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`, `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`, and `../PhyloNetworks.jl/src/manipulateNet.jl`.
- **Green-state gates**: targeted graph tests after each task, no file-content-audit violation for old scaffold names in `src/reactive_graph.jl` or `test/test_reactive_graph.jl`, and final `julia --project=test test/runtests.jl`.
- **Stop conditions**: stop if graph registration cannot be made idempotent without weakening ComputePipeline semantics; stop if output nodes must be dereferenced before future primitive construction; stop if `Makie.update!(plot; arg1=new_net)` cannot leave caller-owned `HybridNetwork` inputs unmutated; stop if public attribute semantics must change; stop if implementation requires Tranche 3 primitive assembly work; stop if upstream Makie or ComputePipeline files contradict this tasking's graph registration plan.

## Required revalidation before implementation

- Read this tasking file, the parent tranche file, the parent PRD, the codeplan, and Tranche 1 tasking in full.
- Read the governance documents listed above line by line.
- Re-run or inspect the current baseline state before edits. If `julia --project=test test/runtests.jl` is red before implementation, record the failure and stop unless the project maintainer authorizes proceeding from a red baseline.
- Re-read current files and tests in scope: `src/PhyloMakie.jl`, `src/recipe.jl`, `src/plot_config.jl`, `src/network_layout.jl`, `src/annotation_tables.jl`, `src/primitive_channels.jl`, `test/test_recipe.jl`, `test/test_primitive_channels.jl`, and `test/runtests.jl`.
- Re-read the required upstream primary sources named in the handoff packet where they constrain the task being executed.
- If current code no longer matches the post-Tranche-1/pre-Tranche-2 diagnosis, stop and raise that before changing code.

## Tranche execution rule

Tranche 2 may add graph-registration internals in `src/reactive_graph.jl` and graph tests in `test/test_reactive_graph.jl`. It must begin and end green for its scope. It must leave current public plotting behavior intact and must not remove the current broad rebuild recipe path. Tranche 3 tasking must handle stable primitive construction and broad-callback removal.

After this tranche, `src/reactive_graph.jl` must exist and must define `register_phylo_graph!(plot::PhyloPlot)`. That function must register a named graph-registration path from public plot inputs to final primitive argument output nodes. The behavior that must remain unchanged in this tranche is current `render_plot!`-based primitive construction in `src/recipe.jl`.

Docs must not be rewritten in this tranche. The API may not be changed to satisfy graph tests. Tests must adapt to the current public API and to Tranche 1 functions `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels`.

## Non-negotiable execution rules

- Do not use anonymous `do` blocks or closure callbacks for graph registration paths that `register_phylo_graph!` may call repeatedly. Use named callback functions or a named `_register_outputs_once!` helper that rejects partial or mismatched existing outputs.
- Do not register one packed final node and leave future `Makie.plot!` to dereference fields from it. `:primitive_channels` may exist as an intermediate node, but every final primitive argument must have its own output node.
- Do not call `PhyloNetworks.directedges!` or `PhyloNetworks.preorder!` in `src/reactive_graph.jl`; call `prepare_plot_network` so the Tranche 1 rule remains in force: `prepare_plot_network` copies the caller's `HybridNetwork`, mutates only that copy for traversal preparation, and returns the prepared copy.
- Do not mutate graph inputs directly in new graph tests. Use `Makie.update!(plot; ...)`.
- Do not remove `Makie.onany`, `delete!`, `empty!(plot.plots)`, or `render_plot!` from `src/recipe.jl` in this tranche.
- Do not call `Makie.linesegments!`, `Makie.text!`, `Makie.poly!`, or `Makie.arrows2d!` from `src/reactive_graph.jl`.
- Do not add manifests, dependencies, docs narrative changes, public attribute renames, pointer interactions, or non-`HybridNetwork` plotting support.

## Concrete anti-patterns or removal targets

- Missing graph-registration file/function: absence of `src/reactive_graph.jl` and `register_phylo_graph!`.
- Packed final outputs: using only `:primitive_channels`, a tuple, a struct, or a dictionary as the future primitive-argument input surface.
- Direct graph input mutation in tests: `plot[:edgecolor][] = ...`, `plot[:style][] = ...`, `plot[:net][] = ...`, or another direct compute-node assignment.
- Direct traversal mutation in graph registration: `directedges!(net)` or `preorder!(net)` on a caller-owned `HybridNetwork`.
- Old scaffold graph tests: graph tests that prove behavior through `render_plot!`, `PlotRenderLayers`, `PlotLayout`, or `PhyloPlotAttributes`.
- Tranche 3 leakage: primitive child construction, broad callback removal, child identity tests, one stable `poly!` child integration, or file edits whose only purpose is primitive assembly.

## Failure-oriented verification

- The current implementation must fail tests that require `register_phylo_graph!`, `PhyloGraphOutputs`, `PhyloTextGraphOutputs`, and named final output nodes.
- A fake fix that registers only `:primitive_channels` must fail the output-node inventory tests.
- A fake fix that passes graph tests by mutating `plot[:edgecolor][]`, `plot[:style][]`, or `plot[:net][]` must fail the file-content audit and task review.
- A fake fix that calls `directedges!` or `preorder!` directly in graph registration must fail caller-owned-network mutation tests and file-content audit.
- A fake fix that removes the broad rebuild callback or starts primitive assembly must fail the Tranche 2 scope audit.
- Positive verification must show that graph outputs exist, read as values produced by `compute_primitive_channels`, and recompute through `Makie.update!` for attribute, style, limit or text, and recipe argument updates.

## Tasks

### 1. Add the required graph-output types

**Type**: WRITE
**Output**: `src/reactive_graph.jl` is included by the module and defines the graph-output types and required node-name inventory.
**Depends on**: none
**Positive contract**: `PhyloGraphOutputs`, `SegmentGraphOutputs`, `ArrowheadGraphOutputs`, `TextGraphOutputs`, and `PhyloTextGraphOutputs` exist, are concrete or concretely parametric, and store output-node names as `Symbol` fields. `src/PhyloMakie.jl` includes `src/reactive_graph.jl` after `src/primitive_channels.jl` and before `src/recipe.jl`.
**Negative contract**: The new file must not call Makie primitive constructors, delete child plots, register broad callbacks, dereference primitive output nodes for rendering, or reference old render scaffold names as definitions for graph output behavior.
**Files**: `src/reactive_graph.jl`, `src/PhyloMakie.jl`, `test/test_reactive_graph.jl`, `test/test_PhyloMakie.jl`, `test/runtests.jl`.
**Out of scope**: `src/recipe.jl`, `src/render_adapter.jl`, docs files, dependency manifests, public attribute names, and primitive assembly.
**Verification**: `julia --project=test test/runtests.jl` must fail on the current code because the graph type and function names do not exist, then pass after this task once the new graph-output tests are satisfied and existing tests remain green. `rg -n "render_plot!|PlotRenderLayers|PlotLayout|PhyloPlotAttributes|linesegments!|text!|poly!|arrows2d!" src/reactive_graph.jl test/test_reactive_graph.jl` must find no dependency on old render scaffold or primitive construction.

Create `src/reactive_graph.jl`. Define `SegmentGraphOutputs` with fields `points::Symbol`, `colors::Symbol`, `linewidths::Symbol`, and `linestyle::Symbol`. Define `ArrowheadGraphOutputs` with fields `meshes::Symbol`, `colors::Symbol`, `strokecolors::Symbol`, and `strokewidth::Symbol`. Define `PhyloGraphOutputs` with fields `edge_segments::SegmentGraphOutputs`, `node_bars::SegmentGraphOutputs`, `minor_edge_shafts::SegmentGraphOutputs`, `minor_arrowheads::ArrowheadGraphOutputs`, and `data_limits::Symbol`. Define `TextGraphOutputs` with fields `positions::Symbol`, `strings::Symbol`, `colors::Symbol`, `fontsizes::Symbol`, `align::Symbol`, and `font::Symbol`. Define `PhyloTextGraphOutputs` with fields `tip_labels::TextGraphOutputs`, `internal_node_names::TextGraphOutputs`, `node_numbers::TextGraphOutputs`, `node_labels::TextGraphOutputs`, `edge_labels::TextGraphOutputs`, `edge_lengths::TextGraphOutputs`, `minor_gamma_labels::TextGraphOutputs`, `major_gamma_labels::TextGraphOutputs`, and `edge_numbers::TextGraphOutputs`.

Also define a single inventory function or constant in `src/reactive_graph.jl` that lists all final output symbols exactly as specified in this file. The non-text final symbols are `:edge_segment_points`, `:edge_segment_colors`, `:edge_segment_linewidths`, `:edge_segment_linestyle`, `:node_bar_points`, `:node_bar_colors`, `:node_bar_linewidths`, `:node_bar_linestyle`, `:minor_edge_shaft_points`, `:minor_edge_shaft_colors`, `:minor_edge_shaft_linewidths`, `:minor_edge_shaft_linestyle`, `:minor_arrowhead_meshes`, `:minor_arrowhead_colors`, `:minor_arrowhead_strokecolors`, `:minor_arrowhead_strokewidth`, and `:data_limits`. The text prefixes are `tip_label`, `internal_node_name`, `node_number`, `node_label`, `edge_label`, `edge_length`, `minor_gamma_label`, `major_gamma_label`, and `edge_number`; each prefix must have `_positions`, `_strings`, `_colors`, `_fontsizes`, `_align`, and `_font` output symbols.

Add `test/test_reactive_graph.jl` and include it from `test/runtests.jl` after `test/test_primitive_channels.jl` and before `test/test_render_adapter.jl`. Update `test/test_PhyloMakie.jl` to assert the new graph type and function names are loaded. Do not export these internal names unless an existing package-loading pattern requires it; tests may use `getfield(PhyloMakie, :Name)` as current internal tests do.

### 2. Register config, network, layout, primitive-channel, and data-limit nodes

**Type**: WRITE
**Output**: Helper functions in `src/reactive_graph.jl` register the intermediate graph nodes `:plot_config`, `:plot_network`, `:network_geometry`, `:layout_computation`, `:primitive_channels`, and `:data_limits`.
**Depends on**: 1
**Positive contract**: `_register_phylo_intermediate_nodes!(plot::PhyloPlot)` calls `register_plot_config_node!`, `register_plot_network_node!`, `register_layout_nodes!`, `register_primitive_channel_node!`, and `register_data_limits_node!`, and returns the registered intermediate symbols. The config node calls `resolve_plot_config`; the network node calls `prepare_plot_network`; the geometry/layout/channel nodes call `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels`; `:data_limits` maps from `:primitive_channels` to `PrimitiveChannels.data_limits`.
**Negative contract**: Graph registration must not call `directedges!`, `preorder!`, `render_plot!`, `prepare_plot_layout`, `layout_plot_geometry`, or any Makie primitive constructor. It must not compute values directly inside registration functions by dereferencing nodes.
**Files**: `src/reactive_graph.jl`, `test/test_reactive_graph.jl`.
**Out of scope**: `src/recipe.jl` broad-callback removal, `src/render_adapter.jl`, primitive child construction, docs files, dependency manifests, and public attribute changes.
**Verification**: Graph tests must create a `PhyloPlot`, call `_register_phylo_intermediate_nodes!(plot)`, assert each intermediate node exists in `plot.attributes.outputs`, and assert `plot[:data_limits][] == plot[:primitive_channels][].data_limits`. The caller-owned-network portion must snapshot a fresh network, call intermediate graph registration and read `plot[:plot_network][]`, and assert the original network snapshot is unchanged. `julia --project=test test/runtests.jl` must pass after this task. `rg -n "directedges!|preorder!|render_plot!|prepare_plot_layout|layout_plot_geometry|linesegments!|text!|poly!|arrows2d!" src/reactive_graph.jl` must find no forbidden graph-registration or primitive call.

Implement the intermediate graph registration functions in `src/reactive_graph.jl`. Use `map!` for unconditional recomputation. Use named callback functions for registrations that may be called more than once on the same plot; if a helper is introduced for repeated registration, name it `_register_outputs_once!` and make it reject partial or mismatched existing output sets. This decision follows `ComputePipeline.register_computation!`, which treats already-registered outputs as valid only when the existing parent edge has the same inputs and callback.

The `register_plot_config_node!` input list is the public attribute inputs consumed by `resolve_plot_config`: `:useedgelength`, `:showtiplabel`, `:shownodelabel`, `:shownodenumber`, `:showedgelength`, `:showedgenumber`, `:showgamma`, `:edgecolor`, `:defaultedgecolor`, `:majorhybridedgecolor`, `:minorhybridedgecolor`, `:edgewidth`, `:minorlinetype`, `:arrowlen`, `:nodelabel`, `:edgelabel`, `:nodecex`, `:edgecex`, `:nodelabelcolor`, `:edgelabelcolor`, `:edgenumbercolor`, `:nodelabeladj`, `:edgelabeladj`, `:tipoffset`, `:tipcex`, `:xlim`, `:ylim`, and `:style`. Do not include `:clip_planes` because `resolve_plot_config` does not consume it.

The `register_plot_network_node!` input node is `:net`, not `:arg1`, because the recipe argument declaration provides the named converted output node `:net`. Tests must still prove `Makie.update!(plot; arg1=new_net)` recomputes this path. The graph node must call `prepare_plot_network` so caller-owned networks remain unchanged.

Do not define a placeholder-returning `register_phylo_graph!` in Task 2. Task 2's green endpoint is `_register_phylo_intermediate_nodes!(plot)` plus direct tests for intermediate nodes. `register_phylo_graph!` becomes the complete public-internal graph entrypoint in Task 4 after segment, arrowhead, and text final output registration exists.

### 3. Split segment and arrowhead primitive outputs

**Type**: WRITE
**Output**: Segment and arrowhead primitive arguments are registered as final output nodes and returned through `PhyloGraphOutputs`.
**Depends on**: 2
**Positive contract**: `register_segment_output_nodes!` creates one output node for each future `linesegments!` argument for edge segments, node bars, and minor edge shafts. `register_arrowhead_output_nodes!` creates one output node for each future `poly!` argument for current minor hybrid arrowheads. `register_primitive_graph_outputs!` calls `_register_phylo_intermediate_nodes!(plot)`, registers segment and arrowhead outputs, and returns a `PhyloGraphOutputs` value naming every non-text primitive output and `:data_limits`.
**Negative contract**: Do not leave final segment or arrowhead arguments packed only inside `:primitive_channels`. Do not use `render_plot!`, `SegmentRenderLayer`, `ArrowTipRenderLayer`, `PlotRenderLayers`, or Makie primitive constructors as the graph proof. Do not implement the stable `poly!` child in this tranche.
**Files**: `src/reactive_graph.jl`, `test/test_reactive_graph.jl`.
**Out of scope**: `src/recipe.jl`, `src/render_adapter.jl`, `src/primitive_channels.jl`, primitive construction, child identity tests, docs files, and dependency manifests.
**Verification**: Tests must assert all segment and arrowhead symbols exist and that node values equal the corresponding fields in `plot[:primitive_channels][]`: `edge_segments.points`, `edge_segments.colors`, `edge_segments.linewidths`, `edge_segments.linestyle`, `node_bars.*`, `minor_edge_shafts.*`, and `minor_arrowheads.meshes`, `colors`, `strokecolors`, and `strokewidth`. A fake fix that exposes only `:primitive_channels` must fail.

Add named field-extraction callbacks for segment and arrowhead outputs. The segment output names are exactly those listed in Task 1. The arrowhead output names are exactly `:minor_arrowhead_meshes`, `:minor_arrowhead_colors`, `:minor_arrowhead_strokecolors`, and `:minor_arrowhead_strokewidth`. The output values must come from `PrimitiveChannels`, not from recomputing colors, widths, geometry, arrowhead metrics, or data limits in `src/reactive_graph.jl`. This preserves the Tranche 1 responsibility split: `compute_primitive_channels` calculates primitive-channel values; functions in `src/reactive_graph.jl` map those values to named output nodes.

Add `register_primitive_graph_outputs!(plot)` so its returned `PhyloGraphOutputs` value is complete after this task. It must include segment groups for edge segments, node bars, and minor edge shafts; the arrowhead group; and the data-limit symbol. Do not add `register_phylo_graph!` until Task 4 supplies the text output side as well.

### 4. Split text primitive outputs

**Type**: WRITE
**Output**: Every text group has final output nodes for positions, strings, colors, font sizes, alignment, and font.
**Depends on**: 3
**Positive contract**: `register_text_output_nodes!` creates `TextGraphOutputs` for `tip_labels`, `internal_node_names`, `node_numbers`, `node_labels`, `edge_labels`, `edge_lengths`, `minor_gamma_labels`, `major_gamma_labels`, and `edge_numbers`. `register_text_graph_outputs!(plot)` returns a complete `PhyloTextGraphOutputs`. `register_phylo_graph!(plot::PhyloPlot)` calls `register_primitive_graph_outputs!(plot)` and `register_text_graph_outputs!(plot)` and returns `(primitive_outputs = primitive_outputs, text_outputs = text_outputs)`.
**Negative contract**: Do not pack text output as one `TextChannel` node per text group for future primitive construction. `:primitive_channels` may remain an intermediate node, but every future `text!` positional or keyword argument must have a final output symbol. Do not use render metadata from `PlotRenderLayers` or current child text plots as the graph proof.
**Files**: `src/reactive_graph.jl`, `test/test_reactive_graph.jl`.
**Out of scope**: `src/recipe.jl`, `src/render_adapter.jl`, `src/primitive_channels.jl`, docs files, primitive child construction, and visual render checks.
**Verification**: Tests must assert all 54 text output symbols exist and that each node value equals the matching field of the corresponding `TextChannel` inside `plot[:primitive_channels][]`. Hidden text states must produce typed empty vectors through these output nodes. A fake fix that exposes only one `TextChannel` node for each text group must fail.

Register the text output nodes using the exact prefixes and suffixes listed in Task 1. Each text group must expose positions, strings, colors, fontsizes, align, and font. The extraction callbacks in `src/reactive_graph.jl` must only read the matching field from `PrimitiveChannels`; they must not repeat text filtering, label selection, color resolution, text-size calculation, or alignment calculation.

Add the complete `register_phylo_graph!(plot::PhyloPlot)` entrypoint in this task. It must return a named tuple `(primitive_outputs = primitive_outputs, text_outputs = text_outputs)` where `primitive_outputs` is a `PhyloGraphOutputs` value and `text_outputs` is a `PhyloTextGraphOutputs` value. Do not return placeholders.

### 5. Prove graph recomputation through `Makie.update!`

**Type**: TEST
**Output**: Graph-level tests prove output-node recomputation through `Makie.update!` for public attribute, style, text or limit, and recipe argument updates.
**Depends on**: 4
**Positive contract**: `test/test_reactive_graph.jl` calls `Makie.update!(plot; edgecolor=...)`, `Makie.update!(plot; style=...)`, `Makie.update!(plot; xlim=..., ylim=...)` or `Makie.update!(plot; showtiplabel=...)`, and `Makie.update!(plot; arg1=new_net)`. After each update, tests read final output nodes and assert the values changed or remained typed empty according to the documented public keyword behavior.
**Negative contract**: New graph recomputation tests must not mutate `plot[:attr][]`, `plot[:net][]`, `plot[:style][]`, or any other compute node directly. They must not rely on CairoMakie colorbuffers, child primitive identity, `render_plot!`, or render metadata from `PlotRenderLayers`.
**Files**: `test/test_reactive_graph.jl`, `src/reactive_graph.jl`.
**Out of scope**: `test/test_recipe.jl` direct-mutation test migration, child primitive identity tests, render/colorbuffer tests, `src/recipe.jl` callback removal, docs files, dependency manifests, and primitive assembly.
**Verification**: Targeted graph tests must fail a current direct-node-mutation-only graph implementation and pass when updates go through `Makie.update!`. `rg -n "\\[:[A-Za-z0-9_]+\\]\\[\\] *=|plot_handle\\[:|plot\\[:.*\\]\\[\\] =" test/test_reactive_graph.jl` must not find direct graph-input mutation assignments. `julia --project=test test/runtests.jl` must pass.

Add tests that construct a `PhyloPlot` using existing public plotting entrypoints, call `register_phylo_graph!`, and inspect graph node values without capturing a render buffer. The tests may construct the current child plots because Tranche 2 does not replace primitive construction yet, but the assertions must target graph outputs.

The edge-color update test must capture `plot[:edge_segment_colors][]`, call `Makie.update!(plot; edgecolor="firebrick")`, then assert `plot[:edge_segment_colors][]` changes and still has a length coupled to `plot[:edge_segment_points][]`. The style update test must call `Makie.update!(plot; style=:majortree)` and assert at least the minor shaft or arrowhead output changes according to current full-tree versus major-tree behavior. The limit or text update test must call `Makie.update!` with public keywords and assert `:data_limits` or a text output node recomputes. The `arg1` update test must snapshot `new_net`, call `Makie.update!(plot; arg1=new_net)`, read `plot[:plot_network][]`, assert the prepared graph network is not `new_net`, assert its traversal state is populated, and assert `new_net` remains unchanged.

### 6. Finalize graph-registration audit and green state

**Type**: TEST
**Output**: The tranche is green, `src/reactive_graph.jl` and `test/test_reactive_graph.jl` are auditable, and Tranche 2 has not claimed Tranche 3 work.
**Depends on**: 5
**Positive contract**: Full tests pass; `src/reactive_graph.jl` defines graph-registration functions; final primitive output nodes exist and recompute; file-content audits show graph tests use `Makie.update!`; file-content audits show `src/reactive_graph.jl` and `test/test_reactive_graph.jl` do not depend on old render scaffold names or primitive constructors.
**Negative contract**: Do not use file-content searches as the only proof of behavior. Do not remove existing public behavior coverage, direct render tests, or computation-function tests. Do not claim stable primitive assembly, callback removal, child identity stability, docs alignment, or pointer interactions complete.
**Files**: `test/test_reactive_graph.jl`, `test/test_PhyloMakie.jl`, `test/runtests.jl`, `src/reactive_graph.jl`, `src/PhyloMakie.jl`.
**Out of scope**: `src/recipe.jl` callback removal, `src/render_adapter.jl`, docs files, dependency manifests, public API changes, and workflow-status changes.
**Verification**: Run `julia --project=test test/runtests.jl`. Run file-content audits for forbidden dependencies in `src/reactive_graph.jl` and `test/test_reactive_graph.jl`, and for direct node-mutation assignments in `test/test_reactive_graph.jl`. Record any inability to run these commands with the exact blocker.

Complete the tranche by reviewing every lock item in this file against the implementation. Confirm that `register_phylo_graph!` can be traced from public inputs to final primitive output symbols without opening `Makie.plot!`. Confirm that every output symbol listed in Task 1 is registered and tested. Confirm that the graph tests would fail the current no-graph implementation and a fake implementation that registers only `:primitive_channels`. Confirm that current public render behavior remains covered by existing tests and still passes.

Suggested commands:

```bash
julia --project=test test/runtests.jl
rg -n "render_plot!|PlotRenderLayers|PlotLayout|PhyloPlotAttributes|linesegments!|text!|poly!|arrows2d!|directedges!|preorder!" src/reactive_graph.jl test/test_reactive_graph.jl
rg -n "\\[:[A-Za-z0-9_]+\\]\\[\\] *=|plot_handle\\[:|plot\\[:.*\\]\\[\\] =" test/test_reactive_graph.jl
rg -n "Makie.onany|empty!\\(plot\\.plots\\)|render_plot!" src/recipe.jl
```

The first `rg` command should find no forbidden dependency in `src/reactive_graph.jl` or `test/test_reactive_graph.jl`. The second `rg` command should find no direct graph-input mutation assignment in the new graph tests. The third `rg` command should still find the current Tranche 3 red-state callback and render shell in `src/recipe.jl`; if it does not, this tranche has probably crossed into Tranche 3 without approval.

## Completion bar

Tranche 2 is complete only when all of the following are true:

- `src/reactive_graph.jl` exists and is included by `src/PhyloMakie.jl`.
- `register_phylo_graph!` returns `(primitive_outputs = ::PhyloGraphOutputs, text_outputs = ::PhyloTextGraphOutputs)`.
- `:plot_config`, `:plot_network`, `:network_geometry`, `:layout_computation`, `:primitive_channels`, and `:data_limits` exist as graph outputs.
- Every segment, arrowhead, and text primitive argument named in this tasking file has a final output node.
- Graph output nodes recompute after `Makie.update!(plot; edgecolor=...)`, `Makie.update!(plot; style=...)`, `Makie.update!(plot; arg1=new_net)`, and limit or text keyword updates.
- `Makie.update!(plot; arg1=new_net)` preserves the caller-owned `HybridNetwork`.
- New graph tests do not use direct compute-node mutation as the dynamic entrypoint.
- Current public behavior tests remain green.
- No Tranche 3 primitive assembly, callback removal, docs rewrite, dependency change, public API redesign, or pointer-interaction work is included.

## Stop conditions

Stop and ask the project maintainer before continuing if any of these occur:

- `register_phylo_graph!` cannot be made idempotent without weakening ComputePipeline's existing registration semantics.
- A primitive argument cannot be exposed as a distinct output node and would require dereferencing a packed `PrimitiveChannels` value inside future primitive construction.
- `Makie.update!(plot; arg1=new_net)` cannot preserve caller safety through `prepare_plot_network`.
- A public attribute or public entrypoint must change.
- A dependency or manifest change appears necessary.
- Tests reveal that current green behavior contradicts the PRD, tranche, or codeplan in a way this tasking cannot resolve.
- The implementation requires broad-callback removal, stable primitive assembly, child identity tests, docs rewrite, or pointer interaction work.
