---
date-created: 2026-07-10T17:46:31-07:00
workflow-instrument: Tasking plan
workflow-status: Proposed
workflow-agent-thread-id: codex/019f4e98-1ddf-7c70-b0af-5b726b7b95f0
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-01
---

# Tasks for Tranche 1: Computation layer foundation

This tasking file covers Tranche 1 of `reactive-makie-spine`: the computation layer foundation. It authorizes no implementation while its own `workflow-status` is `Proposed`; a project owner must set this file to `Approved` before an implementation agent begins work.

The baseline suite was re-run before tasking and passed:

```text
Test Summary: | Pass  Total     Time
PhyloMakie.jl |  230    230  5m19.7s
```

The current green behavior is therefore real and must be preserved unless this file explicitly says otherwise.

## Settled decisions

- Public plotting entry points and public attributes are preserved: `Makie.plot`, `Makie.plot!`, `phyloplot`, `phyloplot!`, and the current keyword surface remain supported.
- The approved work is a deep internal architecture correction, not a public API redesign.
- The target architecture has three layers: a pure computation layer, a later reactive graph layer, and a thin `Makie.plot!` tie point. This tranche builds only the computation layer.
- Pointer interactions remain out of scope.
- Old internal scaffold names are not protected compatibility surfaces: `render_plot!`, `PhyloPlotAttributes`, `PlotLayout`, and `PlotRenderLayers` must not remain the target architecture where this tranche touches their ownership.
- The phrase `reactive graph layer` remains workflow-local vocabulary and does not require a `STYLE-vocabulary.md` update in this tranche.
- Public plotting must be caller-safe: users must not have to call `directedges!`, `preorder!`, or any other mutating preparation on their own `HybridNetwork`.
- Hybrid arrowheads must be modeled as computed mesh or polygon payloads suitable for a later stable primitive, not as an inherently per-edge `arrows2d!` construction contract.
- Do not add dependencies or edit `Project.toml` or `Manifest.toml` for this tranche. If a dependency change appears necessary, stop and ask for approval.
- Use the local upstream sources already present in this workspace. Do not use network access for this tranche unless explicitly approved.
- The parent PRD and codeplan frontmatter are still `Proposed`; `02_tranches.md` frontmatter is `Approved`. Treat this user request as authorizing tasking only, not implementation.

## Governance to read before implementation

An implementation agent must read these line by line before touching files:

- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
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

The bundled development-policy depot was also consulted. The project-local files are the active authorities when they differ. Expected bundled files `references/CONTRIBUTING.md`, `references/STYLE-python.md`, and `references/STYLE-vocabulary.md` were not present in the bundled depot; this is not a blocker because project-local governance provides the needed authorities.

Use read-only git and shell commands freely for diagnosis. Do not run mutating git commands, rewrite history, or revert user work unless the project owner explicitly requests it.

## Parent references to read

Read these before implementation:

- `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`
- `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`
- `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`
- `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`
- `../PhyloNetworks.jl/src/manipulateNet.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`

The Makie and PhyloNetworks sources are primary-source contracts for this tranche. Do not rely on memory or package assumptions when implementing arrowhead or traversal behavior.

## Current red state

The existing implementation is green behaviorally but red architecturally for this tranche:

- `src/recipe.jl` owns broad rebuild reactivity in `Makie.plot!`, deletes all child plots on every observed change, and directly calls old computation/render scaffolding.
- `src/attribute_schema.jl` owns `PhyloPlotAttributes`, `resolve_phylo_plot_attributes`, and limit validation.
- `src/layout_engine.jl` owns `PlotGeometry`; `_prepare_traversal!` calls mutating `directedges!` and `preorder!` on its argument.
- `src/plot_layout.jl` owns `PlotBounds`, `PlotAnnotationData`, `PlotLayout`, and `prepare_plot_layout`.
- `src/render_adapter.jl` mixes calculation and primitive construction through `SegmentRenderLayer`, `ArrowTipRenderLayer`, `TextRenderLayer`, `PlotRenderLayers`, and `render_plot!`.
- `_render_arrow_tip_layer!` currently constructs one `Makie.arrows2d!` child per visible arrow tip.
- `test/test_PhyloMakie.jl` still asserts old internal scaffold names as loaded package members.
- Existing tests exercise current behavior and should remain green, but several computation tests must be moved from primitive/render ownership to the new computation owners.

## Upstream contract notes

- The Makie tutorial source shows the later target shape: use compute graph nodes and `map!`; later public updates should flow through `Makie.update!`. This tranche must not preclude that shape, but does not build the reactive graph layer.
- `PhyloNetworks.directedges!` mutates network edge/root state and can partially update before throwing `RootMismatch`.
- `PhyloNetworks.preorder!` requires a rooted network and mutates `net.vec_node` and `net.vec_bool`.
- Makie's `Poly` recipe accepts vectors of poly elements and converts empty vectors through a concrete `GeometryBasics.SimpleMesh{2, Float64, GLTriangleFace}[]` path.
- Makie's `Arrows2D` metric computation combines scalar and vector values in a way that is not a suitable target contract for per-edge hybrid arrowhead geometry. Use computed mesh or polygon payloads for the architecture target.

## Supported public surfaces affected

Protect these public surfaces throughout the tranche:

- `Makie.plot(net; kwargs...)`
- `Makie.plot!(axis, net; kwargs...)`
- `phyloplot(net; kwargs...)`
- `phyloplot!(axis, net; kwargs...)`
- the current documented keyword attributes and accepted style values
- current warning/error behavior for unsupported labels, limits, colors, widths, and styles unless this tasking explicitly names a replacement

Current helper names such as `resolve_phylo_plot_attributes`, `layout_plot_geometry`, `prepare_plot_layout`, and `render_plot!` may remain only as transitional internal wrappers if needed to keep the current recipe green. They are not the target ownership model for new computation tests.

## Primary-goal locks

### Lock 1: Computation layer owns plot-ready values

Not complete if config resolution, network preparation, annotation computation, channel computation, arrowhead payload computation, or data-limit computation still exists only inside `render_plot!`, primitive-construction helpers, or `Makie.plot!`.

Direct red-state proof: current source routes through `resolve_phylo_plot_attributes`, `layout_plot_geometry`, `prepare_plot_layout`, and `render_plot!`.

Completion proof:

- New computation owners can be tested without `Figure`, `Axis`, `Scene`, `ComputeGraph`, or child primitive plots.
- Removing a new computation owner breaks tests even if old render helpers still exist.
- Source audit shows the new owners, not `render_adapter.jl`, own plot-ready calculations.

Covered by tasks: 1, 2, 3, 4, 5, 6, 7.

### Lock 2: Traversal preparation is caller-safe

Not complete if public plotting or the new computation layer mutates the caller's `HybridNetwork` as a required preparation step.

Direct red-state proof: `layout_plot_geometry(...; preorder=true)` currently calls traversal preparation on the network it receives, and PhyloNetworks' `directedges!` and `preorder!` are mutating APIs.

Completion proof:

- A freshly parsed caller network remains unrooted or unpreordered as before after `prepare_plot_network`.
- The returned prepared network is rooted/preordered on a private copy.
- Geometry computed from the private copy matches current accepted plotting behavior.
- An implementation that only renames the old mutating path fails the new tests.

Covered by tasks: 2, 7.

### Lock 3: Hybrid arrowheads are computed mesh payloads

Not complete if the only architecture-level representation of arrowheads remains per-edge `Makie.arrows2d!` child construction or if hidden/no-arrow cases return untyped `Any` vectors.

Direct red-state proof: `_render_arrow_tip_layer!` currently creates one `arrows2d!` child per arrow tip and stores render-layer metadata around those child plots.

Completion proof:

- `compute_arrowhead_channel` returns a concrete, typed mesh or polygon payload for visible hybrid arrowheads.
- Hidden and no-arrow cases return concrete typed empty payloads.
- The computation-layer tests verify geometry and style payloads without constructing `arrows2d!`.

Covered by tasks: 5, 6, 7.

### Lock 4: Hidden layers return typed empty outputs

Not complete if hidden segment, text, or arrowhead states are represented only as skipped child plot construction, deleted children, `nothing`, or untyped vectors.

Direct red-state proof: current render-layer helpers represent hidden layers through `plot = nothing` or empty child-plot lists.

Completion proof:

- Segment, text, and arrowhead computation functions return typed empty vectors when hidden.
- Later reactive graph nodes can receive stable output types across visible and hidden states.

Covered by tasks: 4, 5, 7.

### Lock 5: Public behavior is preserved

Not complete if current accepted plotting behavior, visual output, keyword handling, or tested warnings/errors regress without explicit project-owner approval.

Direct red-state proof: the current test suite is green and is the baseline behavior contract.

Completion proof:

- Existing public behavior tests remain green.
- New computation tests increase coverage rather than replacing current public surface coverage.
- Any visual-diff or colorbuffer fixtures that currently protect behavior remain meaningful.

Covered by tasks: all tasks.

### Lock 6: Old scaffold names are demoted where touched

Not complete if `PhyloPlotAttributes`, `PlotLayout`, `PlotRenderLayers`, or `render_plot!` remain asserted as the target architecture for computation-layer tests.

Direct red-state proof: `test/test_PhyloMakie.jl` asserts old names as loaded package members, and old helper tests are organized around old ownership.

Completion proof:

- New tests assert new computation owner names and contracts.
- Old names, if retained for transitional green-state compatibility, delegate to new owners or stay quarantined as current-render wrappers.
- No new test treats an old scaffold name as the primary owner.

Covered by tasks: 1, 3, 4, 5, 6, 7.

### Lock 7: Authorization boundary is respected

Not complete if this tranche removes the broad callback, registers the reactive graph layer, rewrites docs, changes public attributes, or implements pointer interactions.

Direct red-state proof: those activities are later-tranche or deferred work in the approved tranche plan.

Completion proof:

- No `src/reactive_graph.jl` work is required by this tranche.
- No graph-node registration or `Makie.update!` migration is required to mark this tranche complete.
- Public docs rewrites and pointer interaction APIs remain untouched unless a small doc/test update is needed to keep this tranche green.

Covered by tasks: all tasks.

## Execution rules

- Work task by task and keep the repository green after each task whenever practical.
- Start each task by reproducing or locating the direct red state named in that task.
- Prefer new semantic owners over compatibility shims. Transitional wrappers are acceptable only when they preserve current public behavior until later tranches.
- Keep pure computation functions free of Makie scene mutation and child primitive construction.
- Use concrete or parametric struct fields for channel payloads; do not store `Vector{Any}` or abstractly typed fields for stable reactive payloads.
- Preserve current error and warning strings unless a task explicitly requires a new message.
- Do not rewrite docs in this tranche except for minimal updates required by tests or package loading.
- Do not start Tranche 2, Tranche 3, or pointer-interaction work.
- If implementation reveals that a public behavior must change to complete the tranche, stop and ask for project-owner approval.

No `REVIEW` tasks are included because the remaining decisions are derivable from the PRD, codeplan, tranche file, current source, tests, and primary upstream sources.

## Task 1: Establish the plot config owner

Type: `WRITE`

Dependencies: none

Primary output:

- `src/plot_config.jl` owns `PhyloPlotConfig`, supported public attribute names, public input normalization, and limit validation.
- Tests verify config behavior through the new owner, not through `PhyloPlotAttributes`.

Positive contract:

- Mine current public attribute defaults and validation behavior from `src/attribute_schema.jl` and `src/recipe.jl`.
- Implement `resolve_plot_config(...)::PhyloPlotConfig`.
- Preserve the current public keyword surface and current default behavior.
- Keep `SUPPORTED_PHYLOPLOT_ATTRIBUTES` or an equivalent public attribute-name owner available for tests and callers that rely on it.
- `resolve_phylo_plot_attributes`, `with_phylo_plot_limits`, and `PhyloPlotAttributes` may remain only as transitional wrappers if needed; wrappers must delegate to or be mechanically derived from `PhyloPlotConfig`.
- Update package include order and loading tests for the new owner.

Negative contract:

- Do not change public plotting keywords.
- Do not introduce the reactive graph layer.
- Do not move primitive-channel, geometry, or annotation computation into this file.
- Do not keep new tests centered on `PhyloPlotAttributes` as the target owner.

Likely files:

- `src/plot_config.jl`
- `src/attribute_schema.jl`
- `src/PhyloMakie.jl`
- `test/test_plot_config.jl`
- `test/test_attribute_schema.jl`
- `test/test_PhyloMakie.jl`
- `test/runtests.jl`

Verification:

- New tests fail on the current code because `PhyloPlotConfig` and `resolve_plot_config` do not exist.
- New tests pass after the task and cover defaults, accepted keyword forms, limit validation, and error/warning parity.
- `test/test_PhyloMakie.jl` asserts the new target owner names instead of asserting old scaffold names as architecture.
- Source audit confirms any remaining old config names are transitional wrappers and not the only implementation.

Suggested commands:

```bash
julia --project=test test/runtests.jl
rg -n "PhyloPlotAttributes|resolve_phylo_plot_attributes|with_phylo_plot_limits" src test
```

## Task 2: Add caller-safe prepared network and geometry owner

Type: `WRITE`

Dependencies: Task 1

Primary output:

- `src/network_layout.jl` owns `PlotNetwork`, `prepare_plot_network`, `NetworkGeometry`, and `compute_network_geometry`.
- Tests prove traversal preparation happens on a private copy and preserves current geometry behavior.

Positive contract:

- Implement `prepare_plot_network(net::PhyloNetworks.HybridNetwork)::PlotNetwork{<:PhyloNetworks.HybridNetwork}`.
- Copy the caller's network before running `directedges!` and `preorder!`.
- Keep traversal-related errors honest; do not hide `RootMismatch` or other upstream errors behind broad catches.
- Implement `compute_network_geometry(plot_network, config)::NetworkGeometry` by moving current geometry behavior out of `layout_engine.jl`.
- Preserve current geometric outputs for the existing fixture corpus.
- Keep mutating helper names marked with `!` if any remain internally.

Negative contract:

- Do not require callers to pre-root or preorder their network.
- Do not mutate the caller's network in a non-`!` computation path.
- Do not build Makie child primitives.
- Do not remove the broad callback from `Makie.plot!`; that is later work.

Likely files:

- `src/network_layout.jl`
- `src/layout_engine.jl`
- `src/PhyloMakie.jl`
- `test/test_network_layout.jl`
- `test/test_layout_engine.jl`
- `test/support/fixture_corpus.jl`
- `test/runtests.jl`

Verification:

- A new caller-safety test captures an original network state, calls `prepare_plot_network`, and proves the original is unchanged.
- The prepared private copy is rooted/preordered and usable for geometry computation.
- Geometry parity tests compare current accepted coordinates and edge/node ordering for representative fixtures.
- A fake implementation that only renames `layout_plot_geometry(...; preorder=true)` without copying fails the new tests.

Suggested commands:

```bash
julia --project=test test/runtests.jl
rg -n "directedges!|preorder!" src/network_layout.jl src/layout_engine.jl
```

## Task 3: Add annotation and extent computation owner

Type: `WRITE`

Dependencies: Tasks 1 and 2

Primary output:

- `src/annotation_tables.jl` owns `PlotExtent`, `AnnotationTables`, `LayoutComputation`, and `compute_layout`.
- Annotation, label, and extent calculations are testable without render-layer construction.

Positive contract:

- Move annotation-table and plot-extent logic out of `src/plot_layout.jl`.
- Implement `compute_layout(plot_network, config, geometry)::LayoutComputation`.
- Preserve current behavior for tip labels, node labels, edge labels, hybrid labels, formatted values, warnings, and bounds.
- Make extents and data needed for later primitive channels explicit in typed structs.
- Keep old `prepare_plot_layout` only as a transitional wrapper if current recipe/render code still needs it.

Negative contract:

- Do not use `PlotLayout` as the target owner in new tests.
- Do not construct Makie primitives.
- Do not implement graph nodes or `map!`.
- Do not rewrite docs as part of this task.

Likely files:

- `src/annotation_tables.jl`
- `src/plot_layout.jl`
- `src/PhyloMakie.jl`
- `test/test_annotation_tables.jl`
- `test/test_plot_layout.jl`
- `test/support/fixture_corpus.jl`
- `test/runtests.jl`

Verification:

- New tests fail on current code because `AnnotationTables`, `LayoutComputation`, and `compute_layout` do not exist.
- New tests pass without constructing `Figure`, `Axis`, `Scene`, or child plots.
- Old annotation behavior remains green through existing tests.
- Source audit confirms table and extent calculations are not duplicated between `annotation_tables.jl` and `plot_layout.jl`.

Suggested commands:

```bash
julia --project=test test/runtests.jl
rg -n "PlotLayout|prepare_plot_layout|PlotAnnotationData|PlotBounds" src test
```

## Task 4: Add segment, text, and data-limit channels

Type: `WRITE`

Dependencies: Task 3

Primary output:

- `src/primitive_channels.jl` owns segment-channel, text-channel, and data-limit computation.
- Hidden segment and text states return stable typed empty outputs.

Positive contract:

- Implement `SegmentChannel` and `TextChannel` with concrete or parametric field types.
- Implement `compute_edge_colors`, `compute_edge_widths`, `compute_segment_points`, `compute_segment_channels`, `compute_text_sizes`, `compute_text_align`, `compute_text_channel`, `compute_text_channels`, and `compute_data_limits` as needed by the codeplan.
- Preserve current color, width, linestyle, label, text-size, alignment, and limit behavior.
- Return typed empty vectors for hidden segment and hidden text cases.
- Keep the functions pure: no scene mutation and no child primitive construction.

Negative contract:

- Do not compute arrowhead mesh payloads in this task; that is Task 5.
- Do not represent hidden channels as `nothing`, skipped child plot construction, or `Vector{Any}`.
- Do not keep render-layer helpers as the only place where colors, widths, text, and limits are calculated.
- Do not alter public plotting behavior.

Likely files:

- `src/primitive_channels.jl`
- `src/render_adapter.jl`
- `src/PhyloMakie.jl`
- `test/test_primitive_channels.jl`
- `test/test_render_adapter.jl`
- `test/support/render_test_helpers.jl`
- `test/runtests.jl`

Verification:

- New tests fail on the current code because segment/text/data-limit channel owners do not exist.
- New tests pass without `Figure`, `Axis`, `Scene`, `linesegments!`, or `text!`.
- Hidden cases assert concrete empty `Vector{Makie.Point2f}`, string, color, and numeric payloads as appropriate.
- Existing render tests remain green.

Suggested commands:

```bash
julia --project=test test/runtests.jl
rg -n "Figure\\(|Axis\\(|Scene\\(|linesegments!|text!" test/test_primitive_channels.jl
```

## Task 5: Add arrowhead mesh channel and full primitive payload

Type: `WRITE`

Dependencies: Task 4

Primary output:

- `src/primitive_channels.jl` owns `ArrowheadChannel`, `PrimitiveChannels`, `compute_arrowhead_metrics`, `compute_arrowhead_channel`, and `compute_primitive_channels`.
- Hybrid arrowheads have a computed mesh or polygon payload suitable for later `poly!` consumption.

Positive contract:

- Use the local Makie `poly.jl` contract to choose a payload shape accepted by `poly!` or directly convertible by Makie's poly machinery.
- Preserve current hybrid arrowhead placement, scale, width, and color behavior.
- Return concrete typed empty mesh or polygon payloads when arrowheads are hidden or absent.
- Include enough style payload data for later primitive creation without recomputing arrowhead geometry in the render adapter.
- Build `PrimitiveChannels` as a typed aggregate of segment, text, arrowhead, and data-limit payloads.

Negative contract:

- Do not make `Makie.arrows2d!` the computation-layer owner.
- Do not store arrowhead payloads in `Vector{Any}` or abstractly typed struct fields.
- Do not require a Makie scene to compute arrowhead geometry.
- Do not remove the current render path unless Task 6 can preserve the full public behavior in the same green step.

Likely files:

- `src/primitive_channels.jl`
- `src/render_adapter.jl`
- `src/PhyloMakie.jl`
- `test/test_primitive_channels.jl`
- `test/test_render_adapter.jl`
- `test/support/fixture_corpus.jl`
- `test/support/render_test_helpers.jl`
- `test/runtests.jl`

Verification:

- New tests fail on current code because no arrowhead mesh channel exists.
- Visible hybrid-arrow cases produce non-empty concrete mesh or polygon payloads.
- Hidden and no-arrow cases produce concrete typed empty payloads.
- Tests verify that the payload is acceptable to Makie's poly conversion contract without constructing one `arrows2d!` child per arrowhead.
- Source audit confirms `src/primitive_channels.jl` contains no `arrows2d!`; any remaining `arrows2d!` in `src/render_adapter.jl` is explicitly transitional render debt for Tranche 3, not the computation owner.

Suggested commands:

```bash
julia --project=test test/runtests.jl
rg -n "arrows2d!" src/primitive_channels.jl src/render_adapter.jl
```

## Task 6: Migrate the current render adapter to consume computation channels

Type: `MIGRATE`

Dependencies: Task 5

Primary output:

- The current rebuild-based render path consumes `PrimitiveChannels` or thin delegating wrappers around it.
- Current public plotting behavior stays green while computation ownership moves out of the render adapter.

Positive contract:

- Refactor `render_plot!` and render-layer helpers so value calculations come from `PhyloPlotConfig`, `PlotNetwork`, `LayoutComputation`, and `PrimitiveChannels`.
- Keep render adapter responsibility limited to translating computed channels into the current child primitive calls and applying current scene/axis effects.
- Preserve the existing public plotting behavior and render test expectations.
- Keep transitional wrappers only when they delegate to the new computation owners and are necessary for current green-state compatibility.
- Document in code sparingly where a transitional render path remains for later Tranche 3 primitive-child consolidation.

Negative contract:

- Do not remove the broad callback in `Makie.plot!`.
- Do not register graph nodes or use `map!` for child primitives in this tranche.
- Do not duplicate color, width, text, arrowhead, and limit calculations in the render adapter after moving them.
- Do not turn this into a docs rewrite.

Likely files:

- `src/render_adapter.jl`
- `src/recipe.jl`
- `src/plot_config.jl`
- `src/network_layout.jl`
- `src/annotation_tables.jl`
- `src/primitive_channels.jl`
- `test/test_render_adapter.jl`
- `test/test_recipe.jl`
- `test/support/render_test_helpers.jl`
- `test/runtests.jl`

Verification:

- Existing render adapter and recipe tests remain green.
- Deleting or breaking `compute_primitive_channels` causes render or computation tests to fail, proving computation ownership is real.
- Source audit shows old render-only helper names are gone or are thin delegating wrappers.
- Visual/colorbuffer checks keep protecting current public behavior.

Suggested commands:

```bash
julia --project=test test/runtests.jl
rg -n "_resolve_edgecolors|_resolve_edgewidths|_resolve_text_sizes|_collect_segment|_resolve_arrow|render_plot!" src/render_adapter.jl src/recipe.jl
```

## Task 7: Finalize computation-layer verification and scaffold audit

Type: `TEST`

Dependencies: Tasks 1 through 6

Primary output:

- The full tranche is verifiably green.
- The test suite proves the computation layer independently of render-side side effects.
- Old scaffold assertions are demoted to transitional compatibility checks only where still needed.

Positive contract:

- Ensure `test/runtests.jl` includes every new computation test file.
- Ensure new computation tests do not depend on `Figure`, `Axis`, `Scene`, `ComputeGraph`, or primitive construction.
- Ensure public behavior tests for `Makie.plot`, `Makie.plot!`, `phyloplot`, and `phyloplot!` remain green.
- Audit old scaffold names and classify remaining uses as transitional wrappers, tests for compatibility, or later-tranche debt.
- Run the full test suite. Run docs if source/include changes create documentation risk or if docs are already part of the active verification profile.

Negative contract:

- Do not rely on source-text searches as the only proof of behavior.
- Do not remove existing public behavior coverage to make new tests pass.
- Do not claim Tranche 2 or Tranche 3 completion.
- Do not change this tasking file from `Proposed` or `Approved`; implementation status belongs in an implementation report or project-owner workflow update.

Likely files:

- `test/runtests.jl`
- `test/test_PhyloMakie.jl`
- `test/test_plot_config.jl`
- `test/test_network_layout.jl`
- `test/test_annotation_tables.jl`
- `test/test_primitive_channels.jl`
- existing affected test files
- `test/support/*`

Verification:

- Full suite passes.
- Computation-layer tests fail on the old implementation and pass on the new one.
- Source/test audit shows no new computation test asserts old scaffold names as primary owners.
- Any remaining old scaffold names are explicitly understood as transitional compatibility, current public behavior, or later-tranche debt.

Suggested commands:

```bash
julia --project=test test/runtests.jl
julia --project=docs docs/make.jl
rg -n "Figure\\(|Axis\\(|Scene\\(|ComputeGraph|linesegments!|text!|poly!|arrows2d!" test/test_plot_config.jl test/test_network_layout.jl test/test_annotation_tables.jl test/test_primitive_channels.jl
rg -n "PhyloPlotAttributes|PlotLayout|PlotRenderLayers|render_plot!" src test
```

If `docs/make.jl` fails for an existing unrelated reason, record the exact failure and do not hide it. If it fails because of this tranche, fix the tranche.

## Completion bar

Tranche 1 is complete only when all of the following are true:

- `PhyloPlotConfig`, `PlotNetwork`, `NetworkGeometry`, `LayoutComputation`, annotation tables, primitive channels, data limits, and arrowhead mesh payloads have clear computation owners.
- The caller's `HybridNetwork` is not mutated by the public plotting preparation path.
- Computation tests prove plot-ready values without creating scenes or child plots.
- Existing public plotting behavior remains green.
- Old scaffold names are no longer treated as the architecture target where the tranche touched their ownership.
- No later-tranche work is claimed as done.
- Full verification is run or any inability to run it is recorded with the exact blocker.

## Stop conditions

Stop and ask the project owner before continuing if any of these occur:

- A public keyword or entry point must change.
- A dependency or manifest change appears necessary.
- Makie or PhyloNetworks local source contracts differ materially from the contracts recorded here.
- Caller-safe traversal appears impossible without changing public behavior.
- The implementation requires graph-node registration, broad-callback removal, or pointer interaction work.
- Tests reveal that current green behavior contradicts the PRD or tranche in a way this tasking cannot resolve.
