---
date-created: 2026-07-14T20:28:01-07:00
workflow-instrument: Tasking plan
workflow-status: Approved
workflow-agent-thread-id: codex/019f63c7-8b38-7cb2-9a0c-2f565ac9b9d9
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-03
---

# Tasks for Tranche 3: Stable primitive assembly integration

This tasking file covers Tranche 3 of `reactive-makie-spine`, titled "Stable primitive assembly integration" in the approved tranche file. Tranche 3 changes `Makie.plot!(plot::PhyloPlot)` from broad rebuild reactivity to stable primitive assembly. The function `register_phylo_graph!` in `src/reactive_graph.jl` already registers the graph outputs that this tranche must consume. The new function `create_phylo_primitives!` must create child primitives once from those output nodes.

Repository revalidation before this file was written found the intended post-Tranche-2 and pre-Tranche-3 state:

```text
Test Summary: | Pass  Total     Time
PhyloMakie.jl |  523    523  2m13.1s
```

Current `src/recipe.jl` still contains the Tranche 3 red state: `Makie.onany` over the data and public attributes, `delete!` over current children, `empty!(plot.plots)`, direct calls to `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, and `render_plot!`. Current `src/reactive_graph.jl` defines `register_phylo_graph!`, `PhyloGraphOutputs`, `PhyloTextGraphOutputs`, and 71 final primitive output symbols. Current `src/render_adapter.jl` remains a transitional render shell that uses `Makie.linesegments!`, dynamic per-edge `Makie.arrows2d!`, `Makie.text!`, `_apply_plot_limits!`, and `PlotRenderLayers`.

One upstream-constrained revalidation finding modifies the literal code sketch in `codeplan.md`: Makie 0.24.10 does not accept `font = nothing` for `text!`. The repro `text!(axis, Point2f[(0, 0)]; text = ["a"], font = nothing)` fails with `MethodError: no method matching to_font(::Nothing)`. The existing function `_render_text_layer!` in `src/render_adapter.jl` preserves behavior by omitting the `font` keyword when `channel.font` is `nothing`. Tranche 3 must preserve that exact Makie contract: text layers whose `TextChannel.font` is `nothing` must create stable `text!` children without a `font` keyword, while text layers whose font output is `:italic` may pass the graph font node.

## Settled user decisions and environment baseline

- Public plotting entry points and public attributes remain protected: `Makie.plot`, `Makie.plot!`, `phyloplot`, `phyloplot!`, `PhyloPlot`, and the current keyword surface must keep working.
- The approved workflow is a deep internal architecture correction, not a public API redesign.
- Tranche 1 functions `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels` calculate values.
- Tranche 2 function `register_phylo_graph!` in `src/reactive_graph.jl` registers output nodes that expose those values.
- Tranche 3 function `create_phylo_primitives!` must create stable child primitives from the output nodes returned by `register_phylo_graph!`.
- `Makie.update!(plot; ...)` is the dynamic public update entry point to prove for this tranche. Tranche 3 tests must not rely on direct mutation such as `plot[:edgecolor][] = "firebrick"` as the only integration proof.
- The recipe argument update path is `arg1`. Tests must prove `Makie.update!(plot; arg1 = new_net)`.
- The top-level `:data_limits` graph output is the plot data-limit implementation. `Makie.plot!(plot::PhyloPlot)` must not apply limits by calling a render helper such as `_apply_plot_limits!`.
- Current hybrid arrowheads must use one stable `Makie.poly!` child that consumes `:minor_arrowhead_meshes`, `:minor_arrowhead_colors`, `:minor_arrowhead_strokecolors`, and `:minor_arrowhead_strokewidth`.
- Dynamic per-edge `Makie.arrows2d!` children are forbidden for current hybrid arrowheads. `src/render_adapter.jl` may still contain the transitional old path until Tranche 4, but `src/recipe.jl` and the new primitive assembly file must not call it.
- Current hidden layers must be represented by typed empty graph outputs consumed by stable child primitives. Normal updates must not delete child primitives to hide layers.
- `font = nothing` is not an accepted Makie text primitive argument. Plain text layers must omit the `font` keyword; italic text layers may pass the graph font node.
- `render_plot!`, `PlotRenderLayers`, `SegmentRenderLayer`, `ArrowTipRenderLayer`, and `TextRenderLayer` are not accepted primitive assembly architecture for Tranche 3. They may remain only as transitional old render-adapter verification targets until Tranche 4 removes or rewrites those tests.
- Pointer interactions remain out of scope.
- Do not add dependencies or edit `Project.toml`, `Manifest.toml`, `docs/Project.toml`, `docs/Manifest.toml`, `test/Project.toml`, or `test/Manifest.toml`. If a dependency change appears necessary, stop and ask for project-maintainer approval.
- Use local upstream sources already present in this workspace. Do not use network access for this tranche unless explicitly approved.

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

The bundled development-policy depot was consulted. Its `references/` directory contains no Markdown authority files in this environment. The project-local files listed above are the active project authorities. Expected bundled files such as `references/CONTRIBUTING.md`, `references/STYLE-python.md`, and `references/STYLE-vocabulary.md` were not present; this is not a blocker because project-local governance provides the needed authorities.

Read-only git and shell commands may be used freely for diagnosis. Mutating git operations such as commit, merge, push, rebase, reset, checkout for branch changes, and branch creation remain the human project maintainer's responsibility unless the user explicitly instructs otherwise.

Controlled vocabulary constraints:

- Use `HybridNetwork`, `Makie-native public plot owner`, `public attribute surface`, `full-tree style`, `major-tree style`, `major hybrid edge`, and `minor hybrid edge` as defined in `STYLE-vocabulary.md`.
- Use `tranche`, `lock item`, `red-state repro`, `handoff packet`, `upstream primary source`, `verification artifact`, and `stop condition` as defined in `STYLE-workflow-vocabulary.md`.
- Use `reactive graph layer` only for `src/reactive_graph.jl` and the named functions that register graph outputs. Do not add the phrase to `STYLE-vocabulary.md` in this tranche.
- Treat `render_plot!`, `PhyloPlotAttributes`, `PlotLayout`, and `PlotRenderLayers` as old scaffold names. They may survive only as pre-Tranche-4 transitional runtime or test debt, not as names in `src/primitive_assembly.jl`, `src/recipe.jl`, or new primitive-assembly tests for the new path.

Required upstream primary sources for this tranche:

- `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`, especially `ComputeGraph`, `update!`, `register_computation!`, and `map!`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`, especially `ComputePipeline.update!(plot::Plot; ...)`, `data_limits(plot::Plot)`, the warning against storing `Observable`s in plot attributes, plot `map!`, and primitive argument expansion.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`, especially the full recipe pattern and `plot!(plot::MyPlot)` contract.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`, especially `FigureAxisPlot` and `plot!(ax::AbstractAxis, plot::AbstractPlot)`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`, especially `LineSegments`, `Text`, and `Poly` recipe attributes.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`, especially text argument computation and `to_font` behavior.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`, especially `Arrows2D` `tiplength` and `tipwidth` metric computation.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`, especially vector-of-polygon `convert_arguments`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/annotation.jl`, especially Makie-owned examples of computed nodes plus narrow reactions.

## Primary-goal lock

### Lock 1: `Makie.plot!(plot::PhyloPlot)` removes broad rebuild reactivity

- The work is not complete if `Makie.plot!(plot::PhyloPlot)` still installs `Makie.onany` over `:net` and public attributes, deletes children, empties `plot.plots`, or reruns `render_plot!` on normal updates.
- Direct red-state repro: current `src/recipe.jl` registers `Makie.onany`, guards with `is_rebuilding`, deletes every child from `copy(plot.plots)`, calls `empty!(plot.plots)`, recalculates config/network/geometry/layout values, and calls `render_plot!`.
- Tasks that close it: 1, 3, 6.
- Verification artifact: `test/test_primitive_assembly.jl` source audit must fail the current `src/recipe.jl`; child identity tests must fail the current broad rebuild path because `Makie.update!` changes `plot.plots` identities.

### Lock 2: `Makie.update!` drives integration behavior

- The work is not complete if Tranche 3 integration tests prove visible updates only through direct compute-node mutation such as `plot[:edgecolor][] = value`, `plot[:style][] = value`, or `plot[:net][] = value`.
- Direct red-state repro: current `test/test_recipe.jl` reactivity test mutates `plot_handle[:edgecolor][]`, `plot_handle[:style][]`, and `plot_handle[:net][]`.
- Tasks that close it: 2, 3, 5.
- Verification artifact: integration tests must call `Makie.update!(plot; edgecolor = ...)`, `Makie.update!(plot; style = ...)`, `Makie.update!(plot; arg1 = new_net)`, `Makie.update!(plot; showtiplabel = ...)`, and `Makie.update!(plot; xlim = ..., ylim = ...)`.

### Lock 3: Stable child primitives consume graph output nodes

- The work is not complete if `Makie.plot!` or `create_phylo_primitives!` dereferences graph output nodes and passes snapshot values into `Makie.linesegments!`, `Makie.text!`, or `Makie.poly!`.
- Direct red-state repro: current `src/recipe.jl` computes concrete `PrimitiveChannels`; current `render_plot!` dereferences fields from those channels and passes concrete vectors into child primitive constructors.
- Tasks that close it: 1, 2, 6.
- Verification artifact: child primitive tests must show representative child `arg1`, `color`, `linewidth`, `text`, `fontsize`, and `polygon` values change after `Makie.update!` while the child plot objects remain identical. A fake fix that passes `plot[output][]` snapshots must fail because child values stay stale after update or child identity changes.

### Lock 4: Hybrid arrowheads use one stable `poly!` child

- The work is not complete if current minor hybrid arrowheads are represented by a dynamic list of per-edge `Makie.arrows2d!` children.
- Direct red-state repro: current `_render_arrow_tip_layer!` in `src/render_adapter.jl` creates one `Makie.arrows2d!` child for each arrowhead because per-arrow `tiplength` and `tipwidth` values are needed.
- Tasks that close it: 1, 2, 5, 6.
- Verification artifact: tests must assert the parent `PhyloPlot` has exactly one `Makie.Poly` child for current arrowheads, no `Makie.Arrows2D` child in `plot.plots`, and the `Poly` child's mesh/color values change through graph outputs after `Makie.update!`.

### Lock 5: `data_limits` is a top-level graph output

- The work is not complete if plot limits are applied through `_apply_plot_limits!`, `Makie.xlims!`, `Makie.ylims!`, or `plot[:data_limits] = value` inside primitive assembly or `Makie.plot!`.
- Direct red-state repro: current `render_plot!` calls `_apply_plot_limits!`; `_apply_plot_limits!` mutates axis limits or assigns `target[:data_limits]` as a side effect.
- Tasks that close it: 1, 2, 5, 6.
- Verification artifact: tests must assert `:data_limits` is not an input after graph registration, `Makie.data_limits(plot)` reads the graph output, and `Makie.update!(plot; xlim = ..., ylim = ...)` changes `Makie.data_limits(plot)` without child replacement.

### Lock 6: Public behavior and caller safety remain intact

- The work is not complete if `plot(net)`, `plot!(axis, net)`, `phyloplot(net)`, `phyloplot!(axis, net)`, full-tree style, major-tree style, labels, limits, edge colors, edge widths, gamma labels, hidden layers, or multi-axis composition regress without explicit project-maintainer approval.
- Direct red-state repro: current begin-green baseline is `523` passing tests, including public plotting, computation-layer, graph-layer, render adapter, Aqua, and JET checks.
- Tasks that close it: all tasks.
- Verification artifact: final gate must include `julia --project=test test/runtests.jl`; public render tests must still produce nonempty colorbuffers and distinguish accepted full-tree versus major-tree outputs.

### Lock 7: Old render scaffold is not accepted primitive ownership

- The work is not complete if `render_plot!`, `PlotRenderLayers`, `SegmentRenderLayer`, `ArrowTipRenderLayer`, or `TextRenderLayer` remains the function or type used by `Makie.plot!(plot::PhyloPlot)` or primitive assembly tests to prove the new path.
- Direct red-state repro: current `src/render_adapter.jl` defines `PlotRenderLayers` and current `test/support/render_test_helpers.jl` calls `render_plot!` for old render-adapter tests.
- Tasks that close it: 1, 4, 6.
- Verification artifact: source audit must show `src/recipe.jl`, `src/primitive_assembly.jl`, and `test/test_primitive_assembly.jl` do not reference `render_plot!`, `PlotRenderLayers`, `SegmentRenderLayer`, `ArrowTipRenderLayer`, or `TextRenderLayer`. `src/render_adapter.jl` and existing `test/test_render_adapter.jl` may remain only as transitional old-path verification until Tranche 4.

### Lock 8: Hidden layers keep stable child primitives with typed empty outputs

- The work is not complete if hidden layers are represented by deleting child primitives, omitting child creation, or recreating child plots after visibility changes.
- Direct red-state repro: current render adapter returns `nothing` plots for empty segment and text layers and dynamic per-edge arrow plot vectors for visible arrowheads.
- Tasks that close it: 1, 2, 5.
- Verification artifact: tests must create a plot with hidden tip labels and blank minor line type, assert the parent `PhyloPlot` still has the stable primitive child count, assert representative hidden child values are typed empty vectors from graph outputs, then call `Makie.update!` to toggle visibility without changing child identities.

### Lock 9: Text primitive assembly preserves Makie font contract

- The work is not complete if `create_text_primitive!` passes `font = plot[outputs.font]` for text layers whose graph font output resolves to `nothing`, or if the implementation changes the computation layer to a fake default font without render verification.
- Direct red-state repro: `text!(axis, Point2f[(0, 0)]; text = ["a"], font = nothing)` fails in Makie 0.24.10 with `MethodError: no method matching to_font(::Nothing)`. Current `_render_text_layer!` omits the `font` keyword when `channel.font` is `nothing`.
- Tasks that close it: 1, 2, 5.
- Verification artifact: primitive assembly tests must prove tip labels and internal node names can pass the italic font node, while node numbers, node labels, edge labels, edge lengths, gamma labels, and edge numbers create text children without passing a `font` keyword when the graph font output is `nothing`.

## Forbidden passing implementation table

| Lock item | Required behavior | Current code state | Resolved implementation instruction | Forbidden passing implementation | Failing verification artifact |
| --- | --- | --- | --- | --- | --- |
| Lock 1: remove broad rebuild | `Makie.plot!(plot::PhyloPlot)` registers graph outputs, creates child primitives once, and returns `plot` without broad callback rebuild logic. | `src/recipe.jl` contains `Makie.onany`, `is_rebuilding`, `delete!`, `empty!(plot.plots)`, direct computation calls, and `render_plot!`. | Replace the body of `Makie.plot!(plot::PhyloPlot)` in `src/recipe.jl` with `outputs = register_phylo_graph!(plot)`, `create_phylo_primitives!(plot, outputs.primitive_outputs, outputs.text_outputs)`, and `return plot`. | Leave the broad callback in place and also register graph outputs so graph tests pass while normal updates still rebuild children. | Source audit over `src/recipe.jl`; child identity test after `Makie.update!(plot; edgecolor = ...)`. |
| Lock 2: `Makie.update!` integration | Integration tests use `Makie.update!(plot; ...)` for public attribute and recipe argument updates. | `test/test_recipe.jl` mutates `plot_handle[:edgecolor][]`, `plot_handle[:style][]`, and `plot_handle[:net][]`. | Replace direct-node mutation in `test/test_recipe.jl` and new primitive assembly tests with `Makie.update!(plot; edgecolor = ...)`, `Makie.update!(plot; style = ...)`, and `Makie.update!(plot; arg1 = new_net)`. | Keep direct-node mutation tests and add one weak smoke test that calls `Makie.update!` without checking child values or render output. | Test review plus assertions that rendered output or child argument values change after each named `Makie.update!` call. |
| Lock 3: output nodes to primitives | `create_phylo_primitives!` passes `plot[output_symbol]` compute nodes to primitive constructors, not `plot[output_symbol][]` snapshots. | `render_plot!` passes concrete vectors from `PrimitiveChannels` fields. | Add `src/primitive_assembly.jl` with `create_segment_primitive!`, `create_arrowhead_primitive!`, `create_text_primitive!`, and `create_phylo_primitives!`; each helper must pass graph nodes to `Makie.linesegments!`, `Makie.poly!`, and `Makie.text!`. | Build graph outputs but call primitives with `plot[symbol][]`, or store `PrimitiveChannels` in a local variable and pass its fields. | Child identity plus child argument value tests: values change after `Makie.update!` while child objects remain identical. |
| Lock 4: one stable `poly!` arrowhead child | Current hybrid arrowheads are one stable `Makie.Poly` child consuming mesh and color nodes. | `_render_arrow_tip_layer!` creates a vector of per-edge `Makie.arrows2d!` children. | `create_arrowhead_primitive!` in `src/primitive_assembly.jl` must call only `Makie.poly!(plot, plot[outputs.meshes]; color = plot[outputs.colors], strokecolor = plot[outputs.strokecolors], strokewidth = plot[outputs.strokewidth])`. | Keep `_render_arrow_tip_layer!` or create multiple `arrows2d!` children from graph values because render output looks similar. | Test parent `plot.plots` has one `Makie.Poly` child and no `Makie.Arrows2D` child; source audit rejects `arrows2d!` in `src/primitive_assembly.jl` and `src/recipe.jl`. |
| Lock 5: graph data limits | `Makie.data_limits(plot)` reads the `:data_limits` graph output and updates through `Makie.update!`. | `_apply_plot_limits!` mutates axis limits or assigns `target[:data_limits]` during render. | `Makie.plot!` must rely on `register_data_limits_node!`; primitive assembly must not call `_apply_plot_limits!`, `xlims!`, `ylims!`, or assign `plot[:data_limits]`. | Keep side-effect limit application in primitive assembly while graph output exists, so data-limit tests pass only by coincidence. | Source audit plus `Makie.data_limits(plot)` update test after `Makie.update!(plot; xlim = ..., ylim = ...)`. |
| Lock 6: public behavior | Public surfaces and accepted visible behavior remain green. | Current suite passes `523/523` before Tranche 3. | Preserve public recipe declaration in `src/recipe_declaration.jl`; adjust only internals and tests needed for stable primitive assembly. | Make tests pass by dropping public render assertions, skipping mutating entrypoint tests, or changing public keyword behavior. | Full `julia --project=test test/runtests.jl` plus public surface render/colorbuffer assertions. |
| Lock 7: old scaffold demoted | `src/recipe.jl` and `src/primitive_assembly.jl` do not use `render_plot!` or `PlotRenderLayers` for the accepted primitive path. | `src/render_adapter.jl` still defines old render-layer types and `test/support/render_test_helpers.jl` still calls `render_plot!`. | Keep old render adapter only as transitional test debt until Tranche 4; do not call it from `Makie.plot!`, primitive assembly helpers, or new primitive assembly tests. | Rename `render_plot!` or wrap it behind `create_phylo_primitives!` while still using `PlotRenderLayers` as the primitive owner. | Source audit over `src/recipe.jl`, `src/primitive_assembly.jl`, and `test/test_primitive_assembly.jl`. |
| Lock 8: hidden stable children | Hidden layers keep child objects and receive typed empty graph output values. | Current render adapter omits some empty child plots and dynamic arrow plot vectors vary with arrow count. | Always create the 3 `LineSegments`, 1 `Poly`, and 9 `Text` children from graph nodes; hidden layers are empty output values, not missing children. | Skip creating hidden children or recreate children when toggling visibility because the image still looks correct. | Stable child count and identity tests before and after `Makie.update!(plot; showtiplabel = false, minorlinetype = "blank")`. |
| Lock 9: Makie text font contract | Plain text layers omit `font` when the graph font output is `nothing`; italic text layers pass the font node. | `text!(...; font = nothing)` fails; `_render_text_layer!` omits `font` for `nothing`. | Implement exact helper split in `src/primitive_assembly.jl`: `create_text_primitive!` dispatches to a no-font path for plain text layer symbols and to a fonted path for `tip_labels` and `internal_node_names`. | Pass `font = plot[outputs.font]` for every text layer, or change `TextChannel.font` from `nothing` to a guessed default without visual proof. | Test that all 9 text children are created; tests fail if plain text child construction throws `to_font(::Nothing)` or if rendered public text behavior drifts. |

## Handoff packet

- **Active authorities**: this tasking file after approval; `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`; Tranche 1 and 2 tasking files; project-local governance files listed in the Governance section; local upstream primary sources listed above.
- **Parent documents**: `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/03-01_tranche-01--tasking-1.md`, and `.workflow-docs/202606192224_makie-reactivity-architecture/03-02_tranche-02--tasking-1.md`.
- **Settled decisions and non-negotiables**: preserve public attributes and entrypoints; use `register_phylo_graph!`; create stable primitive children once; use `Makie.update!`; use one `poly!` child for current arrowheads; no broad `onany`; no normal-update child deletion; no child primitive `update!` reactions for current visual layers; no public API redesign; no pointer interactions; plain text layers omit `font` when the graph font value is `nothing`.
- **Authorization boundary**: deep internal redesign of recipe and primitive assembly is authorized; external breaking changes, public attribute renames, pointer interactions, dependency changes, and docs narrative rewrite are not authorized in this tranche.
- **Current-state diagnosis**: current recipe still implements the old broad rebuild path; current graph layer already exposes final output nodes; current render adapter is transitional old rendering code and must stop being the path used by `Makie.plot!(plot::PhyloPlot)`.
- **Primary-goal lock**: lock items 1 through 9 in this file.
- **Direct red-state repros**: current `src/recipe.jl` broad callback; current `test/test_recipe.jl` direct node mutation; current `_render_arrow_tip_layer!` per-edge `arrows2d!` children; current `_apply_plot_limits!`; `text!(...; font = nothing)` Makie failure.
- **Responsibility and rule being repaired**: `src/recipe.jl` must make `Makie.plot!(plot::PhyloPlot)` an orchestration function only. `src/primitive_assembly.jl` must define `create_phylo_primitives!` and helper functions that create child primitives from graph output nodes. `src/reactive_graph.jl` remains the named function set that maps public inputs to graph outputs. `src/primitive_channels.jl` remains the named function set that computes values.
- **Supported public surfaces affected**: `plot(net)`, `plot!(axis, net)`, `phyloplot(net)`, `phyloplot!(axis, net)`, public attribute updates through `Makie.update!`, and recipe argument updates through `Makie.update!(plot; arg1 = new_net)`.
- **Exact files in scope**: `src/primitive_assembly.jl`, `src/PhyloMakie.jl`, `src/recipe.jl`, `test/test_primitive_assembly.jl`, `test/test_recipe.jl`, `test/test_PhyloMakie.jl`, and `test/runtests.jl`.
- **Conditionally in scope**: `test/support/render_test_helpers.jl` and `test/test_render_adapter.jl` only if old render-adapter tests must be narrowed so they no longer claim `render_plot!` is accepted primitive architecture. `src/render_adapter.jl` only if a narrow compatibility comment or removal of recipe-facing behavior is required; it must not become the new primitive assembly path under another name.
- **Exact files and surfaces out of scope**: docs pages, dependency manifests, public attribute names, pointer interaction code, non-`HybridNetwork` plotting support, external public API redesign, performance tuning beyond removing rebuild architecture, and Tranche 4 documentation closeout.
- **Required upstream primary sources**: all Makie and ComputePipeline files listed in the Governance section.
- **Green-state gates**: targeted primitive assembly tests after each task, source audits for forbidden red states, child identity tests, direct `Makie.update!` integration tests, render/colorbuffer checks for representative public behavior, final `julia --project=test test/runtests.jl`, and `julia --project=docs docs/make.jl` unless a pre-existing docs failure is recorded and escalated before code changes.
- **Stop conditions**: stop if any current primitive argument other than the documented `font = nothing` case cannot be passed as a compute node under Makie 0.24.10; stop if a child `update!` reaction appears necessary for current visual layers; stop if public behavior must change; stop if text font handling requires changing public attributes or guessing a new default font; stop if implementation requires pointer interactions, dependency changes, or docs narrative rewrite; stop if upstream Makie or ComputePipeline source contradicts this tasking.

## Required revalidation before implementation

- Read this tasking file, the parent tranche file, the parent PRD, the codeplan, and Tranche 1 and 2 tasking files in full.
- Read the governance documents listed above line by line.
- Run or inspect the current baseline before edits. If `julia --project=test test/runtests.jl` is red before implementation, record the failure and stop unless the project maintainer authorizes proceeding from a red baseline.
- Re-read current files in scope: `src/PhyloMakie.jl`, `src/recipe.jl`, `src/reactive_graph.jl`, `src/primitive_channels.jl`, `src/render_adapter.jl`, `test/test_recipe.jl`, `test/test_reactive_graph.jl`, `test/test_render_adapter.jl`, `test/support/render_test_helpers.jl`, and `test/runtests.jl`.
- Re-read the required upstream primary sources named in the handoff packet where they constrain the task being executed.
- Re-run the `font = nothing` Makie check if the local Makie version or package path changes. If `text!(...; font = nothing)` starts succeeding under a different Makie version, stop and update this tasking before implementation.
- If current code no longer matches the post-Tranche-2 and pre-Tranche-3 diagnosis, stop and raise that before changing code.

## Tranche execution rule

Tranche 3 may replace internal recipe assembly and demote old render scaffold from the accepted `PhyloPlot` runtime path. It must begin and end green for its scope. It must leave current public plotting entrypoints and public attributes intact. It must not implement docs narrative closeout or pointer interactions.

After this tranche, `Makie.plot!(plot::PhyloPlot)` must call `register_phylo_graph!`, call `create_phylo_primitives!`, and return `plot`. Normal updates must flow through Makie and ComputePipeline graph propagation after `Makie.update!(plot; ...)`. The behavior that must no longer exist in the accepted runtime path is broad callback rebuild, child deletion for normal updates, render-helper primitive ownership, dynamic per-edge `arrows2d!` arrowhead children, and side-effect limit application.

`src/render_adapter.jl` may remain as transitional old render-adapter code only until Tranche 4, and only if existing tests still require it. It must not be called by `Makie.plot!(plot::PhyloPlot)` or by `src/primitive_assembly.jl`.

## Non-negotiable execution rules

- Do not keep the broad `Makie.onany` callback in `src/recipe.jl`.
- Do not delete child plots or call `empty!(plot.plots)` for normal updates.
- Do not call `render_plot!` from `Makie.plot!(plot::PhyloPlot)` or from `src/primitive_assembly.jl`.
- Do not pass `plot[output_symbol][]` snapshots into child primitives.
- Do not create one `Makie.arrows2d!` child per current hybrid arrowhead.
- Do not implement child primitive `update!` reactions for current visual layers.
- Do not call `_apply_plot_limits!`, `Makie.xlims!`, `Makie.ylims!`, or assign `plot[:data_limits]` from primitive assembly.
- Do not pass `font = plot[outputs.font]` for text layers whose graph font value is `nothing`.
- Do not rename public entrypoints, public attributes, or public style symbols.
- Do not edit docs pages, manifests, or dependency project files in this tranche.

## Concrete anti-patterns or removal targets

- `Makie.onany` in `src/recipe.jl`.
- `is_rebuilding` in `src/recipe.jl`.
- `foreach(child -> delete!(scene, child), copy(plot.plots))` in `src/recipe.jl`.
- `empty!(plot.plots)` in `src/recipe.jl`.
- Direct calls from `src/recipe.jl` to `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, or `render_plot!`.
- `Makie.arrows2d!` in `src/recipe.jl` or `src/primitive_assembly.jl`.
- `_apply_plot_limits!` in the accepted recipe path.
- Tests whose only reactivity proof is direct compute-node mutation.
- New primitive assembly tests that inspect `PlotRenderLayers` or `render_plot!` as proof of stable primitive architecture.
- A partial migration where `edge_segments` uses graph nodes but text layers, arrowheads, or data limits still use snapshot values or old render adapter code.

## Failure-oriented verification

- The current implementation must fail source audits that reject `Makie.onany`, `delete!`, `empty!(plot.plots)`, and `render_plot!` in `src/recipe.jl`.
- The current implementation must fail child identity tests because direct node or `Makie.update!` updates rebuild child plots.
- A fake fix that registers graph outputs but passes snapshots to primitives must fail after `Makie.update!` because child values do not change.
- A fake fix that leaves dynamic per-edge `arrows2d!` children must fail child type and source audits.
- A fake fix that omits hidden child primitives must fail stable child count and identity tests.
- A fake fix that passes `font = nothing` to `text!` must fail primitive creation under Makie 0.24.10.
- Positive runtime verification must show stable children, changed child argument values, changed colorbuffers for representative updates, and preserved caller-owned `HybridNetwork` state after `Makie.update!(plot; arg1 = new_net)`.

## Tasks

### 1. Create stable primitive assembly and replace recipe orchestration

**Type**: WRITE
**Output**: `src/primitive_assembly.jl` exists, `src/PhyloMakie.jl` includes it after `src/reactive_graph.jl` and before `src/recipe.jl`, and `Makie.plot!(plot::PhyloPlot)` calls `register_phylo_graph!` plus `create_phylo_primitives!`.
**Depends on**: none
**Positive contract**: `PhyloPrimitiveHandles`, `create_segment_primitive!`, `create_arrowhead_primitive!`, `create_text_primitive!`, and `create_phylo_primitives!` exist. `Makie.plot!(plot::PhyloPlot)` creates 3 stable `LineSegments` children, 1 stable `Poly` arrowhead child, 9 stable `Text` children, and returns `plot`.
**Negative contract**: `src/recipe.jl` must not contain broad `Makie.onany`, `is_rebuilding`, `delete!`, `empty!(plot.plots)`, direct computation calls, or `render_plot!`. `src/primitive_assembly.jl` must not call `render_plot!`, `Makie.arrows2d!`, `_apply_plot_limits!`, `Makie.xlims!`, `Makie.ylims!`, or pass snapshot values from `plot[output][]` into primitives.
**Files**: `src/primitive_assembly.jl`, `src/PhyloMakie.jl`, `src/recipe.jl`, `test/test_PhyloMakie.jl`, `test/test_primitive_assembly.jl`, `test/runtests.jl`.
**Out of scope**: `src/render_adapter.jl` removal, docs files, dependency manifests, public attribute names, pointer interactions, and Tranche 4 documentation closeout.
**Verification**: `julia --project=test test/runtests.jl` must pass after this task. Source audit commands must reject forbidden runtime-path shapes: `rg -n "Makie\\.onany|is_rebuilding|empty!\\(plot\\.plots\\)|delete!\\(|render_plot!|compute_network_geometry|compute_layout|prepare_plot_network|resolve_plot_config" src/recipe.jl` must return no matches, and `rg -n "render_plot!|arrows2d!|_apply_plot_limits!|xlims!|ylims!|\\[\\]\\]" src/primitive_assembly.jl` must return no forbidden primitive-assembly usage.

Create `src/primitive_assembly.jl`. Define `PhyloPrimitiveHandles` with one field for each child group: `edge_segments`, `node_bars`, `minor_edge_shafts`, `minor_arrowheads`, `tip_labels`, `internal_node_names`, `node_numbers`, `node_labels`, `edge_labels`, `edge_lengths`, `minor_gamma_labels`, `major_gamma_labels`, and `edge_numbers`. Define `create_segment_primitive!(plot::PhyloPlot, outputs::SegmentGraphOutputs)` to call `Makie.linesegments!(plot, plot[outputs.points]; color = plot[outputs.colors], linewidth = plot[outputs.linewidths], linestyle = plot[outputs.linestyle])`. Define `create_arrowhead_primitive!(plot::PhyloPlot, outputs::ArrowheadGraphOutputs)` to call only `Makie.poly!(plot, plot[outputs.meshes]; color = plot[outputs.colors], strokecolor = plot[outputs.strokecolors], strokewidth = plot[outputs.strokewidth])`. Define two text helper paths: one path calls `Makie.text!` without the `font` keyword, and one path calls `Makie.text!` with `font = plot[outputs.font]`. `create_text_primitive!` must route `tip_labels` and `internal_node_names` to the fonted path and must route `node_numbers`, `node_labels`, `edge_labels`, `edge_lengths`, `minor_gamma_labels`, `major_gamma_labels`, and `edge_numbers` to the no-font path. Do not choose this route dynamically by reading `plot[outputs.font][]`; use the semantic group names from `PhyloTextGraphOutputs` so primitive creation does not depend on a snapshot value. Define `create_phylo_primitives!` to call these helpers in the order listed above and return `PhyloPrimitiveHandles`.

Replace `Makie.plot!(plot::PhyloPlot)` in `src/recipe.jl` with the orchestration body from the codeplan, adjusted only to call the helper names in `src/primitive_assembly.jl`. Do not preserve the old callback behind a compatibility flag or fallback.

### 2. Verify stable child identity and graph-driven primitive arguments

**Type**: TEST
**Output**: `test/test_primitive_assembly.jl` proves child identity stability and graph-driven argument updates for representative segment, arrowhead, text, and data-limit outputs.
**Depends on**: 1
**Positive contract**: Tests show that `Makie.update!(plot; edgecolor = ...)`, `Makie.update!(plot; style = ...)`, `Makie.update!(plot; showtiplabel = ...)`, `Makie.update!(plot; xlim = ..., ylim = ...)`, and `Makie.update!(plot; arg1 = new_net)` change graph-driven child values while parent `plot.plots` child object identities remain stable.
**Negative contract**: Tests must not use `render_plot!`, `PlotRenderLayers`, `plot[:edgecolor][] = ...`, `plot[:style][] = ...`, `plot[:net][] = ...`, or source-text assertions as the only proof of graph-driven behavior.
**Files**: `test/test_primitive_assembly.jl`, `test/runtests.jl`, `test/test_PhyloMakie.jl`.
**Out of scope**: public docs, `src/render_adapter.jl`, dependency manifests, and pointer interactions.
**Verification**: `julia --project=test test/test_primitive_assembly.jl` if the test file can run standalone under the local test loader; otherwise run `julia --project=test test/runtests.jl`. A source audit over `test/test_primitive_assembly.jl` must find no `render_plot!`, `PlotRenderLayers`, or direct-node mutation reactivity proof.

Add a test helper in `test/test_primitive_assembly.jl` that maps parent `plot.plots` by stable order into the 13 child groups. Assert that the first 3 children are `Makie.LineSegments`, the fourth child is `Makie.Poly`, and the remaining 9 children are `Makie.Text`. Record object identities before updates with `objectid.(plot.plots)`. After each `Makie.update!` call, assert `objectid.(plot.plots)` is unchanged and compare representative child output values to the corresponding parent graph output value. For example, after `Makie.update!(plot; edgecolor = "firebrick")`, the edge-segment child's color value must equal `plot[outputs.primitive_outputs.edge_segments.colors][]` and must differ from the pre-update value. After `Makie.update!(plot; style = :majortree)`, the arrowhead `Poly` child mesh value must equal `plot[outputs.primitive_outputs.minor_arrowheads.meshes][]` and must reflect the style change. After `Makie.update!(plot; xlim = (0.0, 5.0), ylim = (-1.0, 4.0))`, `Makie.data_limits(plot)` must equal the graph `:data_limits` value and must not come from a side-effect limit helper.

### 3. Migrate recipe reactivity tests to `Makie.update!`

**Type**: MIGRATE
**Output**: Existing recipe integration tests use `Makie.update!` as the public dynamic entrypoint and no longer present direct compute-node mutation as accepted reactivity proof.
**Depends on**: 1, 2
**Positive contract**: `test/test_recipe.jl` still verifies public surfaces and render/colorbuffer changes, but its reactivity test calls `Makie.update!(plot_handle; edgecolor = ...)`, `Makie.update!(plot_handle; style = ...)`, and `Makie.update!(plot_handle; arg1 = net2)`.
**Negative contract**: `test/test_recipe.jl` must not keep direct compute-node mutation as the only proof that public updates work. It must not weaken public render assertions or remove caller-owned-network tests.
**Files**: `test/test_recipe.jl`, `test/test_primitive_assembly.jl`.
**Out of scope**: source files except for fixing failures exposed by these tests, docs pages, dependency manifests, and public API redesign.
**Verification**: `julia --project=test test/runtests.jl` must pass. `rg -n "plot_handle\\[:edgecolor\\]\\[\\]|plot_handle\\[:style\\]\\[\\]|plot_handle\\[:net\\]\\[\\]|\\[:edgecolor\\]\\[\\] =|\\[:style\\]\\[\\] =|\\[:net\\]\\[\\] =" test/test_recipe.jl test/test_primitive_assembly.jl` must return no accepted integration proof.

Replace the current `Reactivity: attribute changes propagate without re-creating the plot` test body in `test/test_recipe.jl` with `Makie.update!` calls. Preserve the colorbuffer assertions that prove visible edge color, style, and data updates. Add child identity checks in this test or delegate them to `test/test_primitive_assembly.jl`, but do not remove visible render checks from the public recipe test.

### 4. Demote old render adapter from the accepted primitive path

**Type**: MIGRATE
**Output**: Source and tests make clear that `render_plot!` and `PlotRenderLayers` are transitional old render-adapter artifacts, not the primitive assembly implementation used by `Makie.plot!(plot::PhyloPlot)`.
**Depends on**: 1, 2, 3
**Positive contract**: `src/recipe.jl`, `src/primitive_assembly.jl`, and `test/test_primitive_assembly.jl` contain no references to `render_plot!`, `PlotRenderLayers`, `SegmentRenderLayer`, `ArrowTipRenderLayer`, or `TextRenderLayer`. Existing `src/render_adapter.jl` and `test/test_render_adapter.jl` may remain only as transitional verification for old render-channel behavior until Tranche 4.
**Negative contract**: The implementation must not wrap or rename `render_plot!` as `create_phylo_primitives!`; it must not use `PlotRenderLayers` as the returned handle type for stable primitives; it must not remove old render-adapter tests by deleting coverage for accepted visible behavior.
**Files**: `src/recipe.jl`, `src/primitive_assembly.jl`, `test/test_primitive_assembly.jl`, `test/test_render_adapter.jl`, `test/support/render_test_helpers.jl`.
**Out of scope**: full render-adapter deletion if it requires Tranche 4 test rewrites, docs narrative cleanup, public API redesign, and dependency changes.
**Verification**: `rg -n "render_plot!|PlotRenderLayers|SegmentRenderLayer|ArrowTipRenderLayer|TextRenderLayer" src/recipe.jl src/primitive_assembly.jl test/test_primitive_assembly.jl` must return no matches. `julia --project=test test/runtests.jl` must pass.

Add comments or test names only where they prevent confusion: old render-adapter tests may say they cover transitional old helper behavior pending Tranche 4, but they must not describe `render_plot!` or `PlotRenderLayers` as the accepted primitive assembly path. Do not rewrite docs in this task.

### 5. Prove public visual behavior, hidden layers, and caller safety

**Type**: TEST
**Output**: Public render and update tests prove stable primitive assembly preserves accepted visible behavior, hidden typed outputs, multi-axis composition, and caller-owned `HybridNetwork` safety.
**Depends on**: 1, 2, 3, 4
**Positive contract**: Tests cover `plot`, `plot!`, `phyloplot`, `phyloplot!`, full-tree style, major-tree style, edge color updates, edge width behavior, labels, gamma labels, limits, hidden layers, multi-axis composition, and `Makie.update!(plot; arg1 = new_net)` caller safety.
**Negative contract**: Tests must not replace render/colorbuffer verification with geometry-only checks where visible behavior is available. Tests must not require users to call `PhyloNetworks.directedges!` or `PhyloNetworks.preorder!` before plotting or updating.
**Files**: `test/test_recipe.jl`, `test/test_primitive_assembly.jl`, `test/support/fixture_corpus.jl`, `test/support/public_surface_cases.jl`, `test/support/render_test_helpers.jl`.
**Out of scope**: docs rewrite, public keyword redesign, pointer interactions, dependency changes, and non-`HybridNetwork` public inputs.
**Verification**: `julia --project=test test/runtests.jl` must pass. Tests must fail a fake implementation that keeps the broad rebuild callback, omits hidden children, uses per-edge `arrows2d!` children, or mutates the caller-owned network during `Makie.update!(plot; arg1 = new_net)`.

Extend tests only where current coverage is weaker than the Tranche 3 lock items. For hidden layers, create a plot with `showtiplabel = false` and `minorlinetype = "blank"` and assert the stable child count remains 13, the representative child graph values are typed empty vectors, and `objectid.(plot.plots)` remains unchanged after toggling `showtiplabel` and `minorlinetype` with `Makie.update!`. For caller safety, snapshot a fresh `HybridNetwork`, call `Makie.update!(plot; arg1 = new_net)`, and assert the snapshot remains unchanged while output node values and render output change.

### 6. Run final green gates and source audits

**Type**: REVIEW
**Output**: The tranche has a recorded green-state result, source audits reject forbidden red states, and every primary-goal lock item has a direct verification artifact.
**Depends on**: 1, 2, 3, 4, 5
**Positive contract**: Full tests pass, docs build passes or any pre-existing docs failure is recorded before implementation, source audits fail the old accepted runtime path, and the final implementation report maps each lock item to a passing verification artifact.
**Negative contract**: Do not declare Tranche 3 complete with only source audits, only unit tests, only render screenshots, or only a green suite that could still hide one lock item. Do not proceed to Tranche 4 implementation from this tasking file.
**Files**: no source edits expected; implementation report or completion notes if the executing workflow records them.
**Out of scope**: committing, pushing, Tranche 4 docs closeout, pointer interactions, public API redesign, and dependency changes.
**Verification**: Run `julia --project=test test/runtests.jl`. Run `julia --project=docs docs/make.jl` unless a pre-existing docs failure was recorded before edits and escalated. Run these source audits from the repository root: `rg -n "Makie\\.onany|is_rebuilding|empty!\\(plot\\.plots\\)|delete!\\(|render_plot!" src/recipe.jl`; `rg -n "arrows2d!|render_plot!|_apply_plot_limits!|xlims!|ylims!" src/primitive_assembly.jl src/recipe.jl`; `rg -n "plot_handle\\[:edgecolor\\]\\[\\]|plot_handle\\[:style\\]\\[\\]|plot_handle\\[:net\\]\\[\\]" test/test_recipe.jl test/test_primitive_assembly.jl`.

Before reporting completion, inspect each lock item in this file. The work is not complete if any source audit, child identity test, graph-driven argument test, visual update test, caller-safety test, or public surface test is absent or only proves an internal helper while the public `PhyloPlot` integration remains unproven.
