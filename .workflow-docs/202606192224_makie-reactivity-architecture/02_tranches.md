---
date-created: 2026-07-09T22:40:03-07:00
workflow-instrument: Tranche plan
workflow-status: Approved
workflow-agent-thread-id: codex/019f4a84-34b6-7d32-917e-77fbf2099ec8
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
---

# Tranche plan: Makie reactive graph architecture

## Governance confirmation

This tranche plan was created from:

- `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`
- `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`

The parent PRD and codeplan currently have `workflow-status: Proposed`. This
file is also saved as `workflow-status: Proposed`. It is a planning artifact
only. Do not advance to tasking or implementation until the project owner
approves the parent workflow documents as needed and sets this tranche plan's
frontmatter to `workflow-status: Approved`.

Active authorities for this tranche plan:

- User request to create tranching for `01_prd.md` plus `codeplan.md`.
- `devflow-feature-02--prd-to-tranches`.
- Bundled development-policy depot:
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`,
  `STYLE-upstream-contracts.md`, `STYLE-verification.md`,
  `STYLE-workflow-docs.md`, `STYLE-workflow-vocabulary.md`, and
  `STYLE-writing.md`.
- Project-local governance:
  `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`, `STYLE-architecture.md`,
  `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`,
  `STYLE-upstream-contracts.md`, `STYLE-verification.md`,
  `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  `STYLE-workflow-vocabulary.md`, and `STYLE-writing.md`.
- Parent workflow documents:
  `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md` and
  `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`.
- Upstream primary sources named in the PRD and codeplan, plus the additional
  PhyloNetworks source required by the caller-safe traversal contract.

Expected governance files not found in the bundled depot:
`references/CONTRIBUTING.md`, `references/STYLE-python.md`, and
`references/STYLE-vocabulary.md`. Project-local `STYLE-vocabulary.md` is present
and is the active domain vocabulary authority for this workflow. No
`codebases-and-documentation` directory was found at the workspace root or the
PhyloMakie root.

Controlled vocabulary constraints:

- Use `tranche`, `lock item`, `red-state repro`, `handoff packet`,
  `upstream primary source`, and `stop condition` as defined in
  `STYLE-workflow-vocabulary.md`.
- Use `HybridNetwork`, `Makie-native public plot owner`, `public attribute
  surface`, `full-tree style`, `major-tree style`, `major hybrid edge`, and
  `minor hybrid edge` as defined in `STYLE-vocabulary.md`.
- Treat `reactive graph layer` as workflow-local PRD language.
- Treat `render_plot!`, `PhyloPlotAttributes`, `PlotLayout`, and
  `PlotRenderLayers` as told internal scaffold names, not target architecture
  vocabulary.

Additional upstream source flagged:

- The PRD and codeplan name Makie and ComputePipeline sources, but the
  caller-safe traversal lock also depends on `PhyloNetworks.directedges!` and
  `PhyloNetworks.preorder!`. Downstream computation work must read
  `../PhyloNetworks.jl/src/manipulateNet.jl`, especially the definitions of
  those mutating functions.

## Global green-state gates

Each implementation tranche must begin green for its declared scope and end
green for that scope. The full workflow must end with:

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- computation-layer tests that do not construct a Makie figure or child
  primitive plot
- graph-layer tests that verify output-node registration and recomputation
- direct `Makie.update!` tests for public attributes and recipe argument updates
- render or colorbuffer artifacts for accepted visible behavior
- source-backed audits that fail the broad rebuild callback, snapshot primitive
  argument construction, dynamic per-edge `arrows2d!` arrowheads, and old
  scaffold names as target architecture

## Tranche 1: Computation layer foundation

**Type**: AFK
**Blocked by**: None -- can start immediately after the global workflow approval gate.

### Governance and required reading

- Read line by line:
  `CONTRIBUTING.md`, `STYLE-agent-handoffs.md`, `STYLE-architecture.md`,
  `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`,
  `STYLE-upstream-contracts.md`, `STYLE-verification.md`,
  `STYLE-vocabulary.md`, `STYLE-workflow-docs.md`,
  `STYLE-workflow-vocabulary.md`, and `STYLE-writing.md`.
- Read line by line:
  `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md` and
  `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`.
- Read upstream primary sources:
  `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`,
  `../PhyloNetworks.jl/src/manipulateNet.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`,
  and `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`.
- Revalidate current source:
  `src/attribute_schema.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`,
  `src/render_adapter.jl`, `test/test_attribute_schema.jl`,
  `test/test_layout_engine.jl`, `test/test_plot_layout.jl`,
  `test/test_render_adapter.jl`, and `test/support/fixture_corpus.jl`.

### Primary-goal lock

- Owns lock item 3: establish the computation layer.
- Owns lock item 10: keep network traversal preparation caller-safe.
- Owns the computation half of lock item 6: model hybrid arrowheads as computed
  mesh geometry.
- Preserves lock item 7: current public behavior must not regress.
- Begins closing lock item 8 for old scaffold names touched by computation
  extraction.

Non-completion conditions:

- The tranche is not complete if plot-ready calculations still live only inside
  primitive construction helpers or `Makie.plot!`.
- The tranche is not complete if public plotting requires users to call
  `PhyloNetworks.directedges!` or `PhyloNetworks.preorder!` on their own
  `HybridNetwork`.
- The tranche is not complete if hidden visual layers lack typed empty output
  values.
- The tranche is not complete if per-edge arrowhead metrics cannot be converted
  into concrete mesh-vector payloads suitable for `poly!`.

### What to build

This is a foundational and architecture-establishing tranche. It mines the
current correct value calculations out of the old scaffold into a computation
layer with explicit inputs and typed outputs. The tranche establishes the
caller-safe prepared-network owner, resolved plot config owner, layout and
annotation computation owners, primitive channel owners, data-limit computation,
and computed arrowhead mesh payloads.

The tranche does not need to change `Makie.plot!` to the new reactive graph yet.
It must, however, make the new computation layer strong enough that later
graph and primitive tranches can consume it without reintroducing calculation
inside recipe assembly.

### Handoff packet

- **Active authorities**: project-local governance files listed in the
  governance confirmation; bundled development-policy baseline; parent PRD;
  codeplan; this tranche plan after approval.
- **Parent documents**: `01_prd.md`, `codeplan.md`, current source and tests
  listed above.
- **Settled decisions and non-negotiables**: preserve the public attribute
  surface; use a private copied `HybridNetwork`; run `directedges!` and
  `preorder!` only on that private copy; do not implement pointer interactions;
  do not keep old scaffold names as target architecture names merely to reduce
  test churn; use computed `poly!` meshes for current hybrid arrowheads.
- **Authorization boundary**: deep internal redesign is authorized; public
  entrypoint and public attribute renames are not authorized.
- **Current-state diagnosis**: `render_plot!` currently mixes value resolution,
  primitive argument assembly, text channel construction, limit effects, and
  primitive plotting; `layout_plot_geometry` mutates its network argument when
  traversal preparation is enabled.
- **Primary-goal lock**: lock items 3, 6, 7, 8, and 10.
- **Direct red-state repros**: current `render_plot!` as calculation owner;
  current direct use of `PhyloPlotAttributes`, `PlotLayout`, and
  `PlotRenderLayers` in tests; a fresh `readnewick` network whose `vec_node` is
  empty before plotting; current per-edge `arrows2d!` arrow-tip helper.
- **Owner and invariant under repair**: the computation layer owns pure or
  narrowly effect-free plot-value calculation; public plotting owns
  caller-safety by preparing traversal state on a private copy.
- **Exact files or surfaces in scope**: new or renamed computation-layer files
  such as `src/plot_config.jl`, `src/network_layout.jl`,
  `src/annotation_tables.jl`, and `src/primitive_channels.jl`; current mined
  logic in `src/attribute_schema.jl`, `src/layout_engine.jl`,
  `src/plot_layout.jl`, and `src/render_adapter.jl`; matching unit tests.
- **Exact files or surfaces out of scope**: `Makie.plot!` broad callback
  removal; graph-node registration; primitive child plot construction; docs
  rewrite; pointer interactions; public API redesign.
- **Required upstream primary sources**:
  `../PhyloNetworks.jl/src/manipulateNet.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`.
- **Green-state gates**: targeted computation tests; current attribute,
  layout, annotation, render-channel expectation tests migrated to new names;
  no Makie figure required for computation tests; full test suite if feasible
  for the tranche branch.
- **Stop conditions**: stop if preserving `PhyloPlotAttributes`,
  `PlotLayout`, `PlotRenderLayers`, or `render_plot!` becomes the target
  architecture; stop if the private-copy traversal contract cannot be proven;
  stop if Makie or GeometryBasics mesh conversion contradicts the `poly!`
  arrowhead plan; stop if public plotting behavior must change externally.

### How to verify

- **Manual**: inspect the new computation-layer API and confirm that each
  public semantic flows through one named owner; run a small `readnewick`
  example through `prepare_plot_network` and confirm the original network's
  traversal and edge-direction state is unchanged.
- **Automated**: add computation-layer tests that compare config, layout,
  annotation tables, primitive channels, data limits, and arrowhead payloads
  against existing fixture expectations without creating a `Figure`, `Axis`,
  `ComputeGraph`, or child primitive plot.

### Acceptance criteria

- [ ] Given a fresh `HybridNetwork`, when `prepare_plot_network` is called, then
      the returned private copy is directed and preordered while the caller-owned
      network remains unchanged.
- [ ] Given current fixture cases, when computation-layer functions run, then
      geometry, annotation tables, segment channels, text channels, colors,
      widths, styles, data limits, and warning/error behavior match accepted
      current behavior.
- [ ] Given hidden layers, when primitive channels are computed, then the result
      contains typed empty point, string, color, width, and concrete mesh-vector
      outputs rather than deleted child-plot intent.
- [ ] Given minor hybrid edge arrowhead inputs, when arrowhead channels are
      computed, then all arrowheads are represented as concrete mesh payloads
      suitable for one `poly!` child.
- [ ] Given a new public attribute added later, when a maintainer reads the
      computation layer, then the normalization and channel owner for that
      attribute is discoverable without reading Makie graph internals.

### User stories addressed

- User story 5: fresh `HybridNetwork` plotting without manual traversal preparation.
- User story 6: readable computation layer independent of ComputePipeline.
- User story 9: output-value calculations testable without a Makie figure.
- User story 12: obsolete scaffold names replaced by responsibility names.
- User story 13: future public attribute extension path begins with computation.

## Tranche 2: Reactive graph layer foundation

**Type**: AFK
**Blocked by**: Tranche 1.

### Governance and required reading

- Read line by line all governance documents listed in the governance
  confirmation, including `STYLE-vocabulary.md` and
  `STYLE-workflow-vocabulary.md`.
- Read line by line `01_prd.md`, `codeplan.md`, and Tranche 1's completion
  notes or equivalent implementation handoff.
- Read upstream primary sources:
  `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`,
  `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`,
  and `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`.
- Revalidate current source:
  `src/recipe.jl`, computation-layer files from Tranche 1, and current recipe
  tests.

### Primary-goal lock

- Owns lock item 4: establish the reactive graph layer.
- Owns the graph-registration portion of lock item 2: updates must enter
  through `Makie.update!`.
- Owns the graph-output naming portion of lock item 5: reactive primitive
  arguments must have output nodes.
- Preserves lock item 7: public behavior must not regress.
- Continues lock item 8 for old scaffold names in graph-facing tests.

Non-completion conditions:

- The tranche is not complete if there is no source owner that names and
  registers input-to-output mappings for `PhyloPlot`.
- The tranche is not complete if final primitive arguments remain packed into
  one tuple, struct, or dictionary that `Makie.plot!` must dereference.
- The tranche is not complete if graph tests mutate nodes directly only and do
  not prove `Makie.update!(plot; ...)`.

### What to build

This foundational tranche establishes the reactive graph layer. It registers
normalized config, prepared plotting network, layout, primitive channel, data
limit, segment output, arrowhead output, and text output nodes. It uses `map!`
for unconditional recomputation paths and reserves `register_computation!` for
cases that require changed-input or cached-output behavior verified from
ComputePipeline.

The tranche must expose one final output node per reactive primitive argument
needed by `linesegments!`, `text!`, `poly!`, and the top-level `data_limits`
output. It may construct a `PhyloPlot` or its `ComputeGraph` for tests, but it
does not replace child primitive construction yet.

### Handoff packet

- **Active authorities**: same governance authorities as Tranche 1, plus
  Tranche 1 completion notes after implementation.
- **Parent documents**: `01_prd.md`, `codeplan.md`, Tranche 1 handoff, Makie
  interactivity tutorial, ComputePipeline source.
- **Settled decisions and non-negotiables**: use the workflow-local term
  `reactive graph layer`; use `map!` or `register_computation!`; expose one
  final output node per reactive primitive argument; avoid graph-output
  dereferencing in future `Makie.plot!`; preserve public attribute names and
  `arg1` recipe argument path.
- **Authorization boundary**: graph internals may be redesigned; public
  attributes, `plot`, `plot!`, `phyloplot`, and `phyloplot!` remain protected.
- **Current-state diagnosis**: current code has no graph owner; current tests
  prove some visible changes by direct node mutation, not the intended
  `Makie.update!` contract.
- **Primary-goal lock**: lock items 2, 4, 5, 7, and 8.
- **Direct red-state repros**: current absence of named output nodes for segment
  points, colors, widths, text strings, text positions, font sizes, arrowhead
  meshes, and `data_limits`; current direct `plot_handle[:edgecolor][] = ...`
  test shape.
- **Owner and invariant under repair**: the reactive graph layer owns the
  mapping from public inputs to primitive output nodes and keeps length-coupled
  primitive arguments synchronized from one semantic computation path.
- **Exact files or surfaces in scope**: new `src/reactive_graph.jl`; module
  include order; graph-output structs or named tuples; graph-level tests;
  recipe tests that can verify `Makie.update!` without relying on child
  primitive replacement.
- **Exact files or surfaces out of scope**: deleting the broad callback from
  `Makie.plot!`; replacing `render_plot!`; docs rewrite; pointer interactions.
- **Required upstream primary sources**:
  `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`,
  and the project Makie interactivity tutorial.
- **Green-state gates**: graph-node existence tests; recomputation tests through
  `Makie.update!(plot; ...)`; data/network update tests that preserve the
  caller-owned network; source audit that each required primitive argument has
  a named output node.
- **Stop conditions**: stop if output nodes must be dereferenced before
  primitive construction; stop if a public semantic requires more than one
  normalization owner; stop if ComputePipeline source contradicts the proposed
  idempotent registration pattern; stop if tests rely only on direct
  `plot[:attr][]` mutation.

### How to verify

- **Manual**: inspect `register_phylo_graph!` and confirm a reviewer can trace
  every public input to the named final output nodes without opening
  `Makie.plot!`.
- **Automated**: add graph tests that call `Makie.update!(plot; edgecolor=...)`,
  `Makie.update!(plot; style=...)`, `Makie.update!(plot; arg1=new_net)`, and
  limit or text updates, then assert the corresponding output nodes recompute
  and preserve length-coupled values.

### Acceptance criteria

- [ ] Given a `PhyloPlot`, when `register_phylo_graph!` runs, then all required
      primitive output node symbols exist and are returned to callers.
- [ ] Given public attribute updates through `Makie.update!`, when graph outputs
      are read, then segment, text, arrowhead, and limit outputs recompute from
      the declared inputs.
- [ ] Given a new `HybridNetwork` passed through `Makie.update!(plot; arg1=...)`,
      then graph outputs recompute from a private prepared copy and the caller's
      network remains unchanged.
- [ ] Given hidden layer conditions, then final graph outputs are typed empty
      values rather than instructions to delete children.
- [ ] Given a source audit over graph output names, then every reactive
      primitive argument named in the codeplan has a corresponding output node.

### User stories addressed

- User story 3: public attribute updates through `Makie.update!`.
- User story 4: plotted `HybridNetwork` updates through the recipe argument path.
- User story 7: readable reactive graph layer.
- User story 10: graph mappings testable without CairoMakie render capture.
- User story 11: reviewers can detect output-node usage versus local anti-fixes.
- User story 13: future public attributes have a graph wiring path.

## Tranche 3: Stable primitive assembly integration

**Type**: AFK
**Blocked by**: Tranche 1 and Tranche 2.

### Governance and required reading

- Read line by line all governance documents listed in the governance
  confirmation, especially `STYLE-makie.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, and `STYLE-architecture.md`.
- Read line by line `01_prd.md`, `codeplan.md`, and completion handoffs from
  Tranches 1 and 2.
- Read upstream primary sources:
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/annotation.jl`,
  and `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`.
- Revalidate current source:
  `src/recipe.jl`, old `src/render_adapter.jl` primitive calls, and recipe
  integration tests.

### Primary-goal lock

- Owns lock item 1: remove broad rebuild reactivity.
- Owns the integration half of lock item 2: `Makie.update!` is the dynamic
  entrypoint.
- Owns lock item 5: pass output nodes to primitives.
- Owns the integration half of lock item 6: current hybrid arrowheads use one
  stable `poly!` child, not per-edge `arrows2d!` children.
- Preserves lock item 7: current public behavior remains intact.
- Continues lock item 8 for old scaffold removal.

Non-completion conditions:

- The tranche is not complete if `Makie.plot!(plot::PhyloPlot)` still installs
  the broad `Makie.onany` callback over the plot data and public attributes.
- The tranche is not complete if normal updates delete child plots, call
  `empty!(plot.plots)`, or recreate the child plot tree.
- The tranche is not complete if `Makie.plot!` dereferences output nodes to pass
  snapshot values into child primitives.
- The tranche is not complete if current minor hybrid arrowheads are still a
  dynamic list of per-edge `arrows2d!` children.

### What to build

This tranche replaces the old recipe-body rebuild path with stable primitive
assembly. `Makie.plot!(plot::PhyloPlot)` should read as orchestration:
register graph outputs, create child primitives once, install only approved
narrow host-effect reactions if a future host-owned effect requires them, and
return `plot`.

Primitive construction must pass compute nodes directly to:

- `linesegments!` for edge segments, node bars, and minor edge shafts
- `poly!` for all current minor hybrid arrowhead meshes
- `text!` for each semantic text layer

The top-level plot must expose computed `data_limits` rather than applying
limits through render-helper side effects.

### Handoff packet

- **Active authorities**: governance confirmation authorities; Tranche 1 and 2
  handoffs; Makie and ComputePipeline upstream sources listed above.
- **Parent documents**: `01_prd.md`, `codeplan.md`, graph and computation
  handoffs.
- **Settled decisions and non-negotiables**: direct computed primitive
  arguments; one stable `poly!` arrowhead child; no normal-update child
  deletion; no broad `onany`; no child primitive `update!` reactions for
  current visual layers; `Makie.plot!` is orchestration, not calculation.
- **Authorization boundary**: may retire old internal render scaffold; may not
  break public plotting entrypoints or public attributes.
- **Current-state diagnosis**: current `src/recipe.jl` lines up with the PRD's
  red state by deleting current children, emptying `plot.plots`, preparing
  layout, and rerunning `render_plot!` in a broad callback.
- **Primary-goal lock**: lock items 1, 2, 5, 6, 7, and 8.
- **Direct red-state repros**: source audit finds `Makie.onany` over all public
  attributes; update changes child primitive identities; `render_plot!` remains
  the accepted primitive owner; per-edge `arrows2d!` children remain for current
  arrowheads.
- **Owner and invariant under repair**: `Makie.plot!` owns recipe assembly only;
  graph outputs own reactivity; computation owns values; child primitives are
  stable consumers.
- **Exact files or surfaces in scope**: `src/recipe.jl`; new primitive assembly
  helpers such as `create_phylo_primitives!`; module include order; integration
  tests for child identity and primitive argument wiring; old render adapter
  removal or narrowing as required.
- **Exact files or surfaces out of scope**: docs rewrite except references
  needed to keep tests green; pointer interactions; public API redesign;
  performance tuning beyond eliminating rebuild architecture.
- **Required upstream primary sources**: all Makie and ComputePipeline files
  listed for this tranche.
- **Green-state gates**: source audit for forbidden rebuild shape; child
  primitive identity tests; direct `Makie.update!` integration tests; render
  colorbuffer checks for representative updates; no dynamic per-edge
  `arrows2d!` children.
- **Stop conditions**: stop if any current primitive argument cannot be passed a
  compute node under Makie 0.24.10; stop if implementing a child `update!`
  reaction becomes necessary without naming the host owner and upstream reason;
  stop if `poly!` mesh vector behavior contradicts the codeplan; stop if public
  entrypoint semantics change.

### How to verify

- **Manual**: create a plot, inspect `plot.plots`, call `Makie.update!` for
  representative attributes and `arg1`, and confirm the child primitive
  identities remain stable while rendered output changes.
- **Automated**: add integration tests that fail the current broad-rebuild path:
  source audit for `Makie.onany`/`empty!(plot.plots)`, child identity stability
  after updates, `poly!` arrowhead child count, and output-node primitive
  arguments.

### Acceptance criteria

- [ ] Given `Makie.plot!(plot::PhyloPlot)`, when a source audit runs, then it
      does not find broad rebuild `Makie.onany`, child deletion, `empty!(plot.plots)`,
      direct `deepcopy(net)`, direct layout preparation, or `render_plot!`.
- [ ] Given a public attribute update through `Makie.update!`, when child plots
      are inspected before and after, then representative child identities are
      unchanged and their compute-driven arguments change.
- [ ] Given a recipe argument update through `Makie.update!(plot; arg1=new_net)`,
      then graph outputs and visible render output update while the original
      network remains unchanged.
- [ ] Given a network with minor hybrid edges, then current arrowheads are
      represented by one stable `poly!` child consuming computed mesh and color
      nodes, not by per-edge `arrows2d!` children.
- [ ] Given hidden layer states, then stable child primitives receive typed empty
      outputs rather than being deleted.

### User stories addressed

- User story 1: `plot(net)` returns a reactive `FigureAxisPlot`.
- User story 2: `plot!(ax, net)` composes across axes without rebuild side effects.
- User story 3: public attribute updates change rendered output.
- User story 4: recipe argument updates change the plotted network.
- User story 5: fresh `HybridNetwork` plotting remains caller-safe.
- User story 8: `Makie.plot!` reads as orchestration.
- User story 11: reviewers can detect output-node usage versus anti-fixes.
- User story 12: obsolete scaffold names are not target architecture.

## Tranche 4: Public reactivity and visual verification

**Type**: AFK
**Blocked by**: Tranche 3.

### Governance and required reading

- Read line by line all governance documents listed in the governance
  confirmation, especially `STYLE-verification.md`, `STYLE-makie.md`,
  `STYLE-docs.md`, and `STYLE-workflow-docs.md`.
- Read line by line `01_prd.md`, `codeplan.md`, and completion handoffs from
  Tranches 1 through 3.
- Read upstream primary sources needed to revalidate test expectations:
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`,
  and `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`.
- Revalidate tests and support files:
  `test/runtests.jl`, `test/test_recipe.jl`, computation and graph test files,
  `test/support/fixture_corpus.jl`, `test/support/render_test_helpers.jl`, and
  `test/support/public_surface_cases.jl`.

### Primary-goal lock

- Finalizes verification for lock item 2: `Makie.update!` is the dynamic
  entrypoint.
- Finalizes behavioral preservation for lock item 7.
- Verifies lock items 1, 4, 5, 6, 8, and 10 with contract-level tests and
  source-backed checks.
- Preserves lock item 9 by asserting pointer interactions remain out of scope.

Non-completion conditions:

- The tranche is not complete if tests prove reactivity only through direct
  `plot[:attr][] = value` mutation.
- The tranche is not complete if visible behavior is verified only by weak
  internal proxies where render artifacts are available.
- The tranche is not complete if any supported public surface lacks coverage.

### What to build

This tranche turns the architecture into contract-level verification. It updates
the test suite so public behavior, graph behavior, primitive stability, visual
rendering, and source audits all fail the old implementation shape. It must
cover public surfaces and accepted visible behavior for `plot`, `plot!`,
`phyloplot`, `phyloplot!`, full-tree style, major-tree style, labels, limits,
edge colors, edge widths, gamma labels, multi-axis composition, hidden layers,
and fresh-network caller safety.

### Handoff packet

- **Active authorities**: governance confirmation authorities; handoffs from
  Tranches 1 through 3; Makie and ComputePipeline sources listed above.
- **Parent documents**: `01_prd.md`, `codeplan.md`, implementation handoffs,
  current tests and fixture corpus.
- **Settled decisions and non-negotiables**: test `Makie.update!`, not only
  direct node mutation; verify public surfaces; keep render/colorbuffer
  artifacts for visible behavior; source audits are necessary but not
  sufficient where direct runtime proof is available.
- **Authorization boundary**: may rewrite internal tests away from old scaffold
  names; may not reduce public coverage or accept visible behavior drift
  without explicit approval.
- **Current-state diagnosis**: current tests include direct compute-node
  mutation and old scaffold assertions; docs and helper tests still call
  `render_plot!`.
- **Primary-goal lock**: lock items 1 through 10 as verification targets, with
  special ownership of lock items 2 and 7.
- **Direct red-state repros**: current reactivity test mutates
  `plot_handle[:edgecolor][]`, `plot_handle[:style][]`, and
  `plot_handle[:net][]`; current source contains broad rebuild callback; current
  docs/test helpers reference old render owner.
- **Owner and invariant under repair**: verification owns proof at the real
  contract boundary: public entrypoints, Makie update semantics, child
  primitive stability, visual output, and source shape.
- **Exact files or surfaces in scope**: all test files and support fixtures;
  render/colorbuffer helpers; source-audit helpers; public surface cases.
- **Exact files or surfaces out of scope**: further architecture redesign;
  docs narrative rewrite beyond test support; pointer interactions.
- **Required upstream primary sources**: Makie/ComputePipeline files listed for
  this tranche.
- **Green-state gates**: full `julia --project=test test/runtests.jl`; targeted
  render/colorbuffer checks; source-backed audits for forbidden red states;
  Aqua and JET gates retained unless a user-approved exception is recorded.
- **Stop conditions**: stop if a green suite can still pass with broad rebuild
  reactivity; stop if tests only assert internal helper return values for a
  public contract; stop if any supported public surface lacks coverage; stop if
  pointer interaction behavior enters the test scope.

### How to verify

- **Manual**: review test names and assertions to confirm each primary-goal lock
  item has at least one direct proof artifact and that no test still encodes old
  scaffold names as accepted end state.
- **Automated**: run `julia --project=test test/runtests.jl`; confirm tests fail
  the old direct-node-mutation-only and broad-rebuild implementation shapes.

### Acceptance criteria

- [ ] Given `plot`, `plot!`, `phyloplot`, and `phyloplot!`, when tests run, then
      each supported surface is covered for public plotting behavior.
- [ ] Given public attribute updates, recipe argument updates, text visibility
      updates, limit updates, style updates, and edge color updates, when tests
      call `Makie.update!`, then graph outputs and render artifacts change
      correctly.
- [ ] Given a broad-rebuild implementation, when source and identity tests run,
      then the implementation fails.
- [ ] Given current public behavior fixtures, when render/colorbuffer checks
      run, then full-tree style, major-tree style, labels, limits, edge colors,
      edge widths, gamma labels, hidden layers, and multi-axis composition remain
      accepted.
- [ ] Given old internal scaffold names, when tests and helper code are audited,
      then they are no longer asserted as target architecture.

### User stories addressed

- User story 1: `plot(net)` reactive return contract.
- User story 2: `plot!(ax, net)` multi-axis composition.
- User story 3: public attribute updates.
- User story 4: recipe argument updates.
- User story 5: fresh `HybridNetwork` caller safety.
- User story 9: computation tests independent of Makie figures.
- User story 10: graph mapping tests independent of CairoMakie capture.
- User story 11: reviewer-visible output-node proof.

## Tranche 5: Documentation and source-audit closeout

**Type**: HITL
**Blocked by**: Tranche 4.

### Governance and required reading

- Read line by line all governance documents listed in the governance
  confirmation, especially `STYLE-docs.md`, `STYLE-writing.md`,
  `STYLE-workflow-docs.md`, `STYLE-agent-handoffs.md`,
  `STYLE-verification.md`, and `STYLE-vocabulary.md`.
- Read line by line `01_prd.md`, `codeplan.md`, and completion handoffs from
  Tranches 1 through 4.
- Read upstream primary sources needed to keep documentation accurate:
  `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`,
  and `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`.
- Revalidate docs:
  `docs/src/public-api.md`, `docs/src/render-verification.md`,
  `docs/src/edge-controls.md`, `docs/src/annotations.md`,
  `docs/src/extending-plots.md`, and `docs/src/index.md`.

### Primary-goal lock

- Finalizes lock item 7 for public documentation and examples.
- Finalizes lock item 8 by removing old scaffold names from docs, examples, and
  workflow-facing prose unless explicitly described as historical red state.
- Preserves lock item 9 by documenting pointer interactions as out of scope.
- Audits lock items 1 through 10 before closure.

Non-completion conditions:

- The tranche is not complete if docs still describe `render_plot!`,
  `PhyloPlotAttributes`, `PlotLayout`, or `PlotRenderLayers` as accepted target
  architecture.
- The tranche is not complete if docs omit `Makie.update!` as the supported
  dynamic entrypoint.
- The tranche is not complete if source audits are absent or are the only proof
  where runtime/render proof exists.
- The tranche is not complete until a human reviewer or project owner accepts
  the closeout evidence or routes requested follow-up.

### What to build

This tranche aligns documentation, examples, render verification pages, and
source-audit reports with the new architecture. It removes old scaffold
language from accepted docs, documents `Makie.update!` as the supported
dynamic entrypoint, keeps public behavior examples honest, records source-audit
evidence for forbidden red states, and produces a closeout handoff strong
enough for review or final audit.

This tranche is HITL because final closure depends on project-owner or reviewer
acceptance of the docs, visual artifacts, and lock-item audit.

### Handoff packet

- **Active authorities**: all governance authorities; handoffs from Tranches 1
  through 4; docs style and vocabulary authorities.
- **Parent documents**: `01_prd.md`, `codeplan.md`, all tranche handoffs,
  current docs and render verification pages.
- **Settled decisions and non-negotiables**: documentation must describe the
  new computation, reactive graph, and primitive assembly ownership; public
  entrypoints and public attributes remain stable; pointer interactions remain
  deferred; source audits supplement but do not replace runtime/render proof.
- **Authorization boundary**: docs may explain internal redesign; docs may not
  imply public attribute renames or external breaking changes that were not
  approved.
- **Current-state diagnosis**: current docs still reference old render scaffold
  and helper surfaces that are no longer target architecture after this PRD.
- **Primary-goal lock**: final audit of lock items 1 through 10, with direct
  docs ownership of lock items 7, 8, and 9.
- **Direct red-state repros**: docs or examples call `render_plot!`; docs
  describe old internal payloads as current owners; docs imply pointer
  interactions were implemented.
- **Owner and invariant under repair**: documentation and audit closeout own the
  public explanation of supported behavior and the reviewable evidence that old
  architecture is gone.
- **Exact files or surfaces in scope**: docs pages listed above; source-audit
  output or notes; final review handoff; render verification artifacts.
- **Exact files or surfaces out of scope**: new pointer interactions; public
  attribute redesign; R interoperability; performance benchmarking beyond the
  accepted verification gates.
- **Required upstream primary sources**: Makie/ComputePipeline files listed for
  this tranche and any additional sources cited in docs.
- **Green-state gates**: `julia --project=docs docs/make.jl`; full tests or
  recorded test-suite green state from Tranche 4; source audits; reviewer or
  project-owner acceptance of final closeout evidence.
- **Stop conditions**: stop if docs require a public behavior change not
  authorized by the PRD; stop if docs cannot be made truthful without reopening
  implementation; stop if pointer interactions appear in scope; stop if the
  project owner rejects final lock-item evidence.

### How to verify

- **Manual**: review docs and audit notes for old scaffold language, public
  surface stability, accurate `Makie.update!` examples, pointer-interaction
  deferral, and complete lock-item evidence; obtain project-owner or reviewer
  acceptance.
- **Automated**: run `julia --project=docs docs/make.jl`; run source audits for
  forbidden red-state shapes; confirm render verification examples build from
  live package code.

### Acceptance criteria

- [ ] Given the public API docs, when a user reads the dynamic update path, then
      `Makie.update!` is documented as the supported entrypoint.
- [ ] Given docs and examples, when old scaffold names appear, then they are
      either removed or explicitly framed as historical red-state names.
- [ ] Given the render verification docs, when `docs/make.jl` runs, then visual
      artifacts are generated from live new architecture code.
- [ ] Given source-audit checks, when they run, then broad rebuild callbacks,
      snapshot primitive arguments, dynamic per-edge `arrows2d!` arrowheads, and
      target old scaffold names are rejected.
- [ ] Given final closeout, when the project owner or reviewer evaluates the
      evidence, then every primary-goal lock item has an honest owner and proof
      artifact.

### User stories addressed

- User story 11: reviewer can identify output-node architecture.
- User story 12: obsolete scaffold names replaced in implementation-facing prose.
- User story 13: future contributors can add attributes through the new owner path.
- User story 14: pointer interactions remain deferred.

