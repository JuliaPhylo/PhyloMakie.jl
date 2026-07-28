---
date-created: 2026-06-19T22:24:52
workflow-instrument: PRD
workflow-status: Proposed
workflow-agent-thread-id: codex/019ee2c5-3f99-73c1-ab0e-d938e2241d4e
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
---

# PRD: Makie reactive graph architecture

## User statement

Initial user statement:

> The fundamental architecture to implement interactivity is broken, targeting
> an older Makie.
>
> We should now be setting up output nodes that map to arguments passed to Makie
> primitives using `map!()`, and reactions implementedusing `update!(...)`
>
> The file
> `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`
> shows how it should be done.
>
> The new design should restructure the logic in `Makie.plot` upwards cleanly
> in a declarative approach in line with the new Makie approach.

Workflow identity confirmed by the user:

- `workflow-location`:
  `/home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl`
- `workflow-production-id`: `reactive-makie-spine`

User decisions during interview:

- The PRD should be saved as Markdown with YAML frontmatter in
  `.workflow-docs/YYYYMMDDHHmm_makie-reactivity-architecture/01_prd.md`.
- The work is a deep internal refactor with no intended external breaking
  change to the current public attribute surface, except where current behavior
  is already broken by the old Makie reactivity pattern.
- The target architecture must not preserve the current scaffold shape by
  default. It should be organized into:
  - a computation layer, with functions that calculate output numbers or values
    from input parameters and configuration
  - a graph structuring layer, which implements input and output node mapping
    and calls the computation layer for calculations
  - `Makie.plot!` tying the pieces together
- Mouse hover, click, and drag interactions are deferred from this PRD.
- Existing internal scaffold names that reflect the old implementation are not
  compatibility abstractions. They should be purged, restructured, and renamed
  from scratch to reflect the correct architecture, abstractions, and concepts.
  Public plot entrypoints and public attributes remain protected.
- The term `reactive graph layer` is workflow-local language in this PRD. It
  does not need to be added to `STYLE-vocabulary.md`.
- Child primitive architecture must be pinned in this PRD. The current plotted
  layers must use direct compute-node primitive arguments wherever Makie 0.24.10
  supports them, and the PRD must name any exceptions rather than leaving them
  for later discovery.
- Public plotting must remain caller-safe for `HybridNetwork` inputs. The
  computation layer owns traversal preparation by copying the input network and
  running `PhyloNetworks.directedges!` and `PhyloNetworks.preorder!` on the
  private copy. Making users prepare networks before plotting is not the
  default contract for this PRD.

## Problem statement

PhyloMakie currently exposes a Makie recipe for
`PhyloNetworks.HybridNetwork`, but the reactivity architecture inside
`Makie.plot!(plot::PhyloPlot)` follows an older style. The implementation
registers one broad `Makie.onany` callback over the data and every public
attribute. Each callback invocation deletes existing child plots, empties
`plot.plots`, deep-copies the network, resolves all attributes, recomputes the
layout, and calls `render_plot!` to reconstruct the primitive plots.

That structure produces visible changes for some attribute mutations, but it
does not match the current Makie and ComputePipeline contract. Current Makie
recipes should register output nodes on the plot compute graph using `map!` or
`register_computation!`, then pass those output nodes directly as arguments or
attributes to Makie primitive plots. Dynamic changes should enter through
`Makie.update!(plot; ...)`, and any effectful reactions should update existing
child plots or host-owned state rather than rebuilding the plot tree.

The current code also has too much scaffold in the critical path. The same
runtime path mixes public input collection, attribute resolution, graph
mutation, layout calculation, primitive construction, child plot deletion, axis
limit effects, and render-layer bookkeeping. This makes it hard to reason
about ownership, hard to verify that every reactive primitive argument has an
output node, and easy to regress into local callback patches.

The architecture problem is therefore not only "make updates work". The
architecture must move calculation out of `Makie.plot!`, make compute-graph
structure explicit, and leave `Makie.plot!` as a declarative tie point that
registers the graph and constructs primitive plots once.

## Target outcome

When this work is complete, `PhyloPlot` uses the current Makie compute graph
contract:

- Public plot inputs remain available through the current public attribute
  surface and recipe argument path.
- `Makie.update!(plt; ...)` is the supported reactivity entrypoint for dynamic
  changes.
- The computation layer calculates plot-ready output values from explicit data,
  attributes, and configuration.
- The reactive graph layer registers `map!` or `register_computation!` edges
  from input nodes to one output node per reactive primitive argument.
- `Makie.plot!(plot::PhyloPlot)` calls the reactive graph layer, passes output
  nodes into stable Makie primitive plots, installs no child primitive
  reactions for the current visual layers, and uses narrow `update!` reactions
  only for future host effects if any are proven necessary.
- The current visual layers require no child primitive `update!` reactions once
  hybrid arrowheads are modeled as computed `poly!` mesh geometry instead of
  per-edge `arrows2d!` children.
- Updates do not delete and recreate the child plot tree as the normal
  reactivity mechanism.
- Plotting and reactive updates do not mutate caller-owned
  `PhyloNetworks.HybridNetwork` values. Required direction and preorder
  traversal state is prepared on a private computation-layer copy.
- Existing capability behavior stays intact for full-tree style, major-tree
  style, edge lengths, hybrid edge styling, labels, text sizes, colors, widths,
  limits, and multi-axis composition.

## Primary-goal lock

### Lock item 1: Remove broad rebuild reactivity

- The work is not complete if `Makie.plot!(plot::PhyloPlot)` still registers a
  broad `onany` callback over the plot data and public attributes to delete
  children, empty `plot.plots`, and rerun `render_plot!`.
- The direct red-state repro is the current implementation in `src/recipe.jl`,
  where any watched input triggers a full rebuild guarded by `is_rebuilding`.
- The expected owner is the `Makie.plot!` integration tranche.
- The verification artifact must fail if a source audit finds the broad
  rebuild callback or if an update changes the child plot identities for a
  case where existing child plots should update in place.

### Lock item 2: Use `Makie.update!` as the dynamic entrypoint

- The work is not complete if tests only mutate compute nodes directly with
  `plot_handle[:attr][] = value` and do not prove `Makie.update!(plot; ...)`.
- The direct red-state repro is the current recipe reactivity test that mutates
  `plot_handle[:edgecolor][]`, `plot_handle[:style][]`, and
  `plot_handle[:net][]`.
- The expected owner is the public recipe and reactivity verification tranche.
- The verification artifact must include tests that call `Makie.update!` with
  public attribute updates and the recipe argument update path, then prove that
  rendered output and child primitive arguments change correctly.

### Lock item 3: Establish the computation layer

- The work is not complete if calculations remain embedded in primitive
  construction helpers or in `Makie.plot!` rather than in named functions that
  receive explicit inputs and return explicit output values.
- The direct red-state repro is the current runtime path where
  `render_plot!` performs value resolution, primitive argument assembly, text
  channel construction, limit effects, and primitive plotting in one pass.
- The expected owner is the computation-layer tranche.
- The verification artifact must include unit tests for the computation layer
  that do not require a `ComputeGraph`, a Makie scene, or child primitive plot
  creation.

### Lock item 4: Establish the reactive graph layer

- The work is not complete if there is no owner that names and registers the
  input-to-output node mapping for `PhyloPlot`.
- The direct red-state repro is the current absence of a source owner that
  registers output nodes such as segment points, colors, linewidths, text
  strings, text positions, font sizes, and limit values with `map!`.
- The expected owner is the reactive graph layer tranche.
- The verification artifact must include graph-level tests or source-backed
  checks that each reactive primitive argument has a corresponding output node,
  and that the output nodes recompute when their declared inputs change.

### Lock item 5: Pass output nodes to primitives

- The work is not complete if reactive primitive arguments are produced by
  dereferencing compute nodes in `Makie.plot!` and passing snapshot values to
  `linesegments!`, `text!`, `poly!`, or approved successor primitive calls.
- The direct red-state repro is the current pattern that dereferences plot
  nodes inside a callback, computes value structs, and calls primitive
  constructors with concrete values for each rebuild.
- The expected owner is the `Makie.plot!` integration tranche.
- The verification artifact must inspect representative child primitive plots
  after `Makie.update!` and prove the child arguments or attributes are driven
  by compute graph outputs rather than by a fresh child plot rebuild.

### Lock item 6: Model hybrid arrowheads as computed mesh geometry

- The work is not complete if current minor hybrid arrow tips are represented
  as a dynamic list of per-edge `arrows2d!` child plots.
- The direct red-state repro is the current render adapter's arrow-tip helper,
  which creates one `arrows2d!` child per arrow because per-arrow `tiplength`
  and `tipwidth` values are needed.
- The expected owner is the computation-layer and `Makie.plot!` integration
  tranches.
- The verification artifact must prove that computed arrowhead meshes and
  colors are passed directly to a stable `poly!` child plot, including typed
  empty mesh-vector output for no-arrow states.

### Lock item 7: Preserve current public behavior

- The work is not complete if the refactor breaks the current public attribute
  surface or accepted visible behavior without explicit user approval.
- The direct red-state repro is any regression in the existing tests or docs
  examples for `plot(net)`, `plot!(ax, net)`, `phyloplot(net)`,
  `phyloplot!(ax, net)`, full-tree style, major-tree style, labels, limits,
  edge colors, edge widths, and gamma labels.
- The expected owner is every implementation tranche.
- The verification artifact must keep the full test suite and docs build green,
  and must include render or colorbuffer checks for the visual behaviors that
  are currently verified visually.

### Lock item 8: Purge old scaffold names and ownership

- The work is not complete if old internal scaffold names remain as stable
  compatibility abstractions after the architecture is rebuilt.
- The direct red-state repro is preserving names such as `render_plot!`,
  `PhyloPlotAttributes`, `PlotLayout`, or `PlotRenderLayers` merely to reduce
  internal test churn, while their names still encode the old snapshot-render
  ownership.
- The expected owner is every implementation tranche that touches the current
  scaffold files or tests.
- The verification artifact must show that internal tests and docs follow the
  new computation-layer, graph-layer, and primitive-assembly names. Public
  names such as `PhyloPlot`, `plot`, `plot!`, `phyloplot`, `phyloplot!`, and
  public attributes remain protected.

### Lock item 9: Defer pointer interactions honestly

- The work is not complete if this architecture PRD silently expands into
  hover, click, drag, or selection behavior without a separate approved scope.
- The direct red-state repro is the open design note listing edge and node
  mouse interactions without resolved behavior.
- The expected owner is a future interaction PRD or tranche family.
- The verification artifact for this PRD is an explicit out-of-scope boundary
  and stop condition for pointer interaction work.

### Lock item 10: Keep network traversal preparation caller-safe

- The work is not complete if public plotting requires users to call
  `PhyloNetworks.directedges!` or `PhyloNetworks.preorder!` on their own
  network before `plot(net)`, `plot!(axis, net)`, `phyloplot(net)`, or
  `phyloplot!(axis, net)` works.
- The direct red-state repro is calling the current geometry routine with
  traversal preparation disabled on a fresh `readnewick` network, which fails
  because `net.vec_node` is empty.
- The expected owner is the computation-layer tranche that introduces the
  prepared plotting network abstraction.
- The verification artifact must prove that plotting a fresh
  `HybridNetwork` prepares a private copy with `directedges!` and `preorder!`
  while preserving the caller-owned network's traversal and edge-direction
  state.
- A future explicit mutating preparation API such as `prepare_plot_network!`
  can be proposed separately, but it is out of scope for the default public
  plotting contract in this PRD.

## User stories

1. As a Makie user, I can call `plot(net)` and receive a
   `Makie.FigureAxisPlot` whose `PhyloPlot` child is reactive through the
   current Makie update contract.
2. As a Makie user, I can call `plot!(ax, net)` and compose multiple network
   plots across axes without hidden current-axis state or rebuild side effects.
3. As a package user, I can update public attributes with `Makie.update!` and
   see edge colors, widths, labels, styles, limits, and text settings update.
4. As a package user, I can update the plotted `HybridNetwork` through the
   recipe argument update path and see the plot update without mutating my
   original network.
5. As a package user, I can pass a fresh network from `readnewick` directly to
   plotting without manually preparing edge directions or preorder traversal.
6. As a maintainer, I can read the computation layer without knowing
   ComputePipeline internals.
7. As a maintainer, I can read the reactive graph layer and see every input
   node, output node, and calculation dependency.
8. As a maintainer, I can read `Makie.plot!` and see only orchestration:
   graph registration, primitive construction, narrow reactions, and return.
9. As a test author, I can test output-value calculations without creating a
   Makie figure.
10. As a test author, I can test graph mappings without depending on CairoMakie
   render capture.
11. As a reviewer, I can tell whether an implementation uses output nodes or
    hides a local `onany` anti-fix.
12. As a reviewer, I can see that obsolete scaffold names have been replaced
    by names that match the computation layer, graph layer, and primitive
    assembly responsibilities.
13. As a future contributor, I can add a new public attribute by adding a
    computation function, wiring it in the reactive graph layer, and consuming
    the output node in a primitive call.
14. As a future contributor, I can add pointer interactions later without
    overloading this PRD with unresolved hover and click semantics.

## Authorized disruption boundary

- Internal redesign allowed: yes. A deep internal refactor is authorized to
  replace the old reactivity architecture with the three-layer model described
  here.
- Internal redesign forbidden: preserving old internal scaffold names as
  compatibility abstractions is forbidden unless the name is part of the public
  plotting surface. Implementation work must not keep names such as
  `render_plot!`, `PhyloPlotAttributes`, `PlotLayout`, or `PlotRenderLayers`
  merely to protect internal tests or old module boundaries.
- External breaking changes allowed: no. Current public entry surfaces and
  public attributes must remain stable unless a separate user approval changes
  that boundary.
- Required migration or compatibility obligations: docs and examples must stay
  honest about the supported update path. Existing public behavior must remain
  covered by tests and visual verification artifacts.
- Non-negotiable protections: no broad rebuild callback as the accepted
  reactivity mechanism; no direct pointer-interaction implementation in this
  PRD; no public requirement that users mutate or pre-prepare networks before
  plotting; no hidden compatibility break; no local anti-fix that only masks
  the old architecture.

## Current-state architecture

### Existing owners

- `src/recipe.jl` owns the `PhyloPlot` recipe, public defaults, `Makie.plottype`
  dispatch, and the current `Makie.plot!(plot::PhyloPlot)` body.
- `src/attribute_schema.jl` owns supported public attributes and resolves them
  into `PhyloPlotAttributes`.
- `src/layout_engine.jl` computes node, edge, and arrow geometry after running
  `PhyloNetworks.directedges!` and `PhyloNetworks.preorder!` on a network copy
  to establish edge direction and `net.vec_node` preorder traversal.
- `src/plot_layout.jl` prepares annotation tables and bounds.
- `src/render_adapter.jl` resolves colors, widths, text channels, limits, and
  primitive plotting, then returns `PlotRenderLayers`.
- `test/test_recipe.jl` currently verifies reactivity through direct compute
  node mutation and rendered colorbuffer differences.

### Existing failure modes

- `Makie.plot!` contains calculation, graph observation, child plot deletion,
  child plot recreation, and effectful limit application in one body.
- A broad `onany` callback watches the data and every public attribute.
- The callback rebuilds the whole child plot tree on every watched change.
- The recipe guards against re-entry with local mutable state.
- Primitive calls consume concrete snapshot values rather than output nodes
  produced by the plot compute graph.
- Tests do not prove `Makie.update!(plot; ...)` as the dynamic entrypoint.
- The implementation does not expose a graph owner that names the dependency
  edges from public inputs to primitive arguments.

### Existing coupling and design debt

- Computation and rendering are coupled through `render_plot!`.
- Limit validation and application are split across the recipe and render
  adapter.
- Child primitive plot creation is coupled to value computation, which makes
  in-place update verification difficult.
- Render-layer structs record concrete values and child plot handles, but they
  are not the owner of the reactive graph contract.

## Target architecture

### Computation layer

The computation layer owns pure or narrowly effect-free functions that
calculate output values from explicit inputs. These functions must not register
compute graph nodes, create Makie child plots, observe Makie events, delete
plots, or mutate caller-owned data.

Representative responsibilities:

- normalize and validate public plot inputs
- calculate traversal-safe layout data from a private copied `HybridNetwork`
  prepared with `PhyloNetworks.directedges!` and `PhyloNetworks.preorder!`
- calculate edge segment points
- calculate node bar points
- calculate minor hybrid edge arrowhead meshes and colors
- calculate color vectors and linewidth vectors
- calculate text strings, text positions, alignments, and font sizes
- calculate default and applied plot limits
- calculate typed empty outputs for hidden layers, including typed empty text
  vectors, point vectors, color vectors, linewidth vectors, and concrete
  empty mesh vectors

This layer is expected to replace, split, or absorb parts of
`attribute_schema.jl`, `layout_engine.jl`, `plot_layout.jl`, and
`render_adapter.jl`. Target names must be chosen from the new responsibilities
rather than retained for compatibility with old scaffolding.

### Reactive graph layer

The reactive graph layer owns the `ComputeGraph` wiring for `PhyloPlot`.

Representative responsibilities:

- define the canonical input node set consumed by `PhyloPlot`
- register output nodes with `map!` for unconditional recomputation paths
- use `register_computation!` only where changed-input or cached-output logic
  is required
- call computation-layer functions inside graph callbacks
- expose one output node per reactive primitive argument
- avoid packing several reactive primitive arguments into one tuple, struct, or
  dictionary output that must be dereferenced inside `Makie.plot!`
- expose graph output names that downstream tests can audit
- keep length-coupled primitive arguments synchronized by deriving each
  coupled layer's points, strings, colors, widths, font sizes, and mesh payloads
  from one semantic computation path
- model hidden layers as typed empty output values rather than as deleted child
  plots

The workflow-local term for this layer is `reactive graph layer`.

### `Makie.plot!` integration

`Makie.plot!(plot::PhyloPlot)` ties the architecture together.

Representative responsibilities:

- call the reactive graph layer to register output nodes
- create child primitive plots once, using output nodes as positional arguments
  and keyword attributes
- use `linesegments!` for edge, node-bar, and minor-edge shaft segment layers
- use `text!` for stable semantic text layers
- use `poly!` for computed hybrid arrowhead meshes
- avoid `arrows2d!` for current hybrid arrowheads because Makie 0.24.10 treats
  `tiplength` and `tipwidth` as scalar attributes in the `Arrows2D`
  computation, while current PhyloMakie behavior requires per-arrow metrics
- install narrow reactions only for host effects that cannot be represented as
  direct primitive arguments or as the top-level `data_limits` output
- implement reactions by calling `Makie.update!` on existing child plots or
  host-owned plot attributes, not by rebuilding the full child plot tree
- return `plot`

`Makie.plot!` must not become the calculation layer. It should read as a
declarative recipe assembly surface.

### Primitive output contract

The current target architecture has no child primitive arguments that require a
narrow `update!` reaction after the arrowhead primitive is changed from
`arrows2d!` to `poly!`. All current visual layers are direct compute-node
consumers:

| Visual layer | Primitive | Required output nodes | Hidden-state representation |
| --- | --- | --- | --- |
| Major and ordinary edge segments | `linesegments!` | segment points, segment colors, segment linewidths, linestyle | empty `Point2f`, color, and linewidth vectors |
| Node bars | `linesegments!` | bar points, bar colors, bar linewidths, linestyle | empty `Point2f`, color, and linewidth vectors |
| Minor hybrid edge shafts | `linesegments!` | minor shaft points, colors, linewidths, linestyle | empty `Point2f`, color, and linewidth vectors when minor line type is blank |
| Minor hybrid arrowheads | `poly!` | concrete arrowhead mesh vector, arrowhead colors, stroke settings | concrete typed empty mesh vector and empty color vector |
| Tip labels | `text!` | positions, strings, colors, font sizes, align, font | empty `Point2f`, `String`, color, and font-size vectors |
| Internal node names | `text!` | positions, strings, colors, font sizes, align, font | empty typed text-layer outputs |
| Node numbers | `text!` | positions, strings, colors, font sizes, align | empty typed text-layer outputs |
| Node labels | `text!` | positions, strings, colors, font sizes, align | empty typed text-layer outputs |
| Edge labels | `text!` | positions, strings, colors, font sizes, align | empty typed text-layer outputs |
| Edge lengths | `text!` | positions, strings, colors, font sizes, align | empty typed text-layer outputs |
| Minor gamma labels | `text!` | positions, strings, colors, font sizes, align | empty typed text-layer outputs |
| Major gamma labels | `text!` | positions, strings, colors, font sizes, align | empty typed text-layer outputs |
| Edge numbers | `text!` | positions, strings, colors, font sizes, align | empty typed text-layer outputs |
| Plot limits | top-level `PhyloPlot` `data_limits` output | `Rect3d` from resolved `xlim` and `ylim` | always present |

Narrow `update!` reactions are not part of the current child primitive design.
They remain allowed only for future host-owned effects that cannot be expressed
as direct primitive arguments or as a top-level plot output. Any such reaction
must name the host owner, the watched output node, the exact `update!` call, and
the upstream source reason it cannot be direct node wiring.

### Supported surface matrix

| Public semantic | Canonical owner | Supported surfaces | Verification |
| --- | --- | --- | --- |
| Public attributes | Computation layer plus recipe defaults | `plot`, `plot!`, `phyloplot`, `phyloplot!` | Attribute tests and public recipe tests |
| Input-to-output mapping | Reactive graph layer | `PhyloPlot` compute graph | Graph-level tests and source-backed audits |
| Primitive construction | `Makie.plot!` integration | Child `linesegments!`, `text!`, and `poly!` arrowhead primitives | Child primitive identity and argument update tests |
| Visible render behavior | Computation layer and primitive outputs | CairoMakie render artifacts | Colorbuffer or screenshot checks |
| Dynamic updates | Makie and ComputePipeline update contract | `Makie.update!(plot; ...)` | Direct update tests |
| Pointer interactions | Future interaction owner | Deferred | Out of scope here |

## Implementation decisions

- The target architecture uses 3 layers: computation layer, reactive graph
  layer, and `Makie.plot!` integration.
- The current public attribute surface is preserved.
- Pointer interactions are deferred.
- Old internal scaffold names are to be purged and replaced by architecture
  names that reflect computation, graph wiring, and primitive assembly
  responsibilities. Public entrypoint names and public attributes are not part
  of this purge.
- `reactive graph layer` is workflow-local language in this PRD. No
  `STYLE-vocabulary.md` update is required for this workflow.
- The current child primitive design requires direct compute-node wiring, not
  child primitive `update!` reactions.
- `arrows2d!` is not the target primitive for current hybrid arrowheads because
  Makie 0.24.10 does not support per-arrow vector `tiplength` and `tipwidth`.
  The target is computed concrete arrowhead meshes passed to `poly!`.
- The top-level plot must expose a computed `data_limits` output for resolved
  limits rather than applying limits through render-helper side effects.
- Upstream Makie and ComputePipeline contracts must be verified from the local
  resolved source trees before implementation.

## Module design

### Computation layer

- **Public surfaces**: indirectly affects all public plotting entrypoints and
  rendered outputs.
- **Responsibility**: calculate output values from explicit data and
  configuration.
- **Interface**: named functions that accept `HybridNetwork` copies or
  prepared data plus explicit attribute/configuration values, and return typed
  output values.
- **Tested**: yes. Unit tests must run without creating a Makie figure or
  graph.

### Reactive graph layer

- **Public surfaces**: indirectly affects all public plotting entrypoints and
  dynamic update behavior.
- **Responsibility**: register compute graph input/output mappings and call
  computation-layer functions.
- **Interface**: one or more functions that accept a `PhyloPlot` or its
  `ComputeGraph` and register named output nodes.
- **Tested**: yes. Tests must verify node existence, dependency behavior, and
  recomputation through `Makie.update!`.

### `Makie.plot!` integration

- **Public surfaces**: `plot(net)`, `plot!(ax, net)`, `phyloplot(net)`,
  `phyloplot!(ax, net)`.
- **Responsibility**: register graph outputs, create child primitive plots, and
  install narrow host-effect `update!` reactions only if a future host effect
  cannot be represented as a direct graph output.
- **Interface**: `Makie.plot!(plot::PhyloPlot)`.
- **Tested**: yes. Tests must verify return contracts, child primitive
  stability where applicable, and visible render updates.

### Public recipe and defaults

- **Public surfaces**: `PhyloPlot` attributes and Makie dispatch.
- **Responsibility**: preserve the current public attribute surface and Makie
  recipe defaults.
- **Interface**: `Makie.@recipe PhyloPlot (net,)`, `Makie.plottype`.
- **Tested**: yes. Existing attribute-name and dispatch tests must remain
  green.

### Documentation and examples

- **Public surfaces**: `docs/src/public-api.md`, `docs/src/render-verification.md`,
  related examples.
- **Responsibility**: document `Makie.update!` reactivity and keep examples
  aligned with the new architecture.
- **Interface**: Documenter pages and rendered examples.
- **Tested**: yes. `julia --project=docs docs/make.jl` must pass.

## Governance and controlled vocabulary

Downstream tranches, tasking files, implementation agents, reviewers, and
auditors must read the following governance documents line by line before
acting:

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

The bundled development-policy depot remains a baseline authority where it
does not conflict with project-local governance. The project-local governance
documents are the active project authorities for this workflow.

Controlled vocabulary decisions:

- Use `reactive graph layer` as workflow-local PRD language for the layer that
  registers `map!` or `register_computation!` output nodes and maps public
  inputs to primitive arguments. Do not add this term to `STYLE-vocabulary.md`
  as part of this workflow.
- Continue using `Makie-native public plot owner`, `public attribute surface`,
  `layout engine`, `render adapter`, `HybridNetwork`, `full-tree style`,
  `major-tree style`, `major hybrid edge`, and `minor hybrid edge` as defined
  in `STYLE-vocabulary.md`.
- Treat `render_plot!`, `PhyloPlotAttributes`, `PlotLayout`, and
  `PlotRenderLayers` as old scaffold names, not target vocabulary.
- Do not describe the old `onany` rebuild path as "reactive graph" or as a
  valid end-state reactivity implementation.
- Do not call this work an interaction implementation; pointer interaction
  behavior is deferred.

## Primary upstream references

The following upstream primary sources were read or traced during PRD
discovery and must be revalidated downstream:

- `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`.
  This project-owned tutorial demonstrates `map!` output nodes and
  `Makie.update!`-driven reactivity.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/Makie.jl`.
  This is the resolved Makie 0.24.10 source entrypoint for the root project.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`.
  This defines the `@recipe` contract and the custom `plot!` recipe pattern.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`.
  This defines `ComputePipeline.update!(plot::Plot; ...)`, plot attribute
  graph behavior, positional argument inputs, argument-name outputs, and the
  warning against storing `Observable`s in plot attributes instead of using
  `map!` or `register_computation!`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`.
  This defines non-mutating plot creation, mutating plot creation, and
  `FigureAxisPlot` return behavior.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`.
  This is the resolved ComputePipeline 0.1.7 source for `ComputeGraph`,
  `update!`, `register_computation!`, and `map!`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/annotation.jl`.
  This provides a Makie-owned example of computed output nodes plus a narrow
  reaction that calls `update!` on a child text plot.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`.
  This constrains text update behavior and documents same-transaction updates
  for coupled text and position lengths.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`.
  This defines `LineSegments` attributes used for segment layers.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`.
  This defines `Arrows2D`; its `tiplength` and `tipwidth` handling is scalar
  in Makie 0.24.10 and therefore cannot represent current per-arrow hybrid
  arrowhead metrics as one vectorized `arrows2d!` child.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`.
  This defines `Poly` conversion for vectors of meshes and is the target
  primitive path for computed hybrid arrowhead mesh vectors.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/interaction/interactive_api.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/interaction/events.jl`,
  and `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/interaction/iodevices.jl`
  were inspected for future pointer interactions, but pointer interactions are
  explicitly deferred from this PRD.

Local verification prototypes run during PRD revision confirmed:

- `linesegments!`, `text!`, and `arrows2d!` accept Makie compute nodes as
  positional arguments and keyword attributes for the tested PhyloMakie-shaped
  inputs.
- `arrows2d!` fails for vector `tiplength` and `tipwidth` because the Makie
  `Arrows2D` metric computation subtracts scalar arrow lengths from the
  direction length.
- `poly!` accepts direct computed vectors of concrete arrowhead meshes and
  color vectors.
- Empty hidden states work when outputs are typed empty vectors; arrowhead
  meshes specifically require a concrete empty mesh-vector element type.

The workspace does not contain a `codebases-and-documentation` directory at the
workspace root or the PhyloMakie root. The available upstream context is the
resolved installed package source tree plus sibling repositories in the
workspace.

## Tranche gates

Every downstream tranche must begin from a green state and end in a green
state for its scope.

Required gates:

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- public surface tests for `plot`, `plot!`, `phyloplot`, and `phyloplot!`
- direct `Makie.update!` tests for attribute and data updates
- graph-level tests for output node registration and recomputation
- computation-layer unit tests independent of Makie figures
- render verification artifacts for visible behavior under CairoMakie
- source-backed audit that the broad rebuild `onany` path is gone from the
  accepted reactivity mechanism
- source-backed audit that current hybrid arrowheads are not implemented as a
  dynamic list of per-edge `arrows2d!` child plots
- source-backed audit that hidden layers are represented as typed empty output
  nodes rather than by deleting child primitives

If a tranche cannot preserve green state end to end, it must be split further
or escalated to the user.

## Handoff packet

- **Active authorities**: project-local `CONTRIBUTING.md` and all project-local
  `STYLE*.md` files listed above; bundled development-policy depot as baseline;
  this PRD after approval.
- **Parent documents**: this PRD; the open Makie interactivity tutorial;
  current source files in `src/`; current tests in `test/`; docs in `docs/src/`.
- **Settled decisions and non-negotiables**: use the 3-layer architecture;
  preserve current public attributes; use `Makie.update!` for dynamic entry;
  use `map!` or `register_computation!` for output nodes; defer pointer
  interactions; purge old internal scaffold names; use computed `poly!`
  meshes for hybrid arrowheads; keep public plotting caller-safe by preparing
  a private network copy with `PhyloNetworks.directedges!` and
  `PhyloNetworks.preorder!`.
- **Authorization boundary**: deep internal redesign and scaffold purging are
  authorized for the reactive architecture, but external breaking changes and
  public surface renames are not authorized.
- **Current-state diagnosis**: current `Makie.plot!` uses a broad `onany`
  callback that rebuilds child plots and targets an older reactivity style.
- **Primary-goal lock**: lock items 1 through 10 in this PRD.
- **Direct red-state repros**: current `src/recipe.jl` broad rebuild callback;
  direct compute-node mutation tests without `Makie.update!`; absence of a
  reactive graph layer; primitive construction from snapshot values.
- **Owner and invariant under repair**: repair the reactivity ownership
  boundary so computation, graph wiring, and `Makie.plot!` orchestration are
  separate and testable.
- **Exact files or surfaces in scope**: `src/recipe.jl`, current calculation
  and render helper modules, tests, docs, and workflow documents needed to plan
  the refactor.
- **Exact files or surfaces out of scope**: pointer interactions; R interop;
  non-`HybridNetwork` plotting; external public API redesign; making mutating
  network-preparation functions the default public plotting contract.
- **Required upstream primary sources**: all sources listed in the previous
  section.
- **Green-state gates**: full tests, docs build, direct `Makie.update!`
  reactivity tests, graph-level tests, computation unit tests, render
  artifacts.
- **Stop conditions**: stop if a tranche depends on preserving the broad
  rebuild callback; stop if it preserves old internal scaffold names as stable
  compatibility abstractions; stop if it implements current hybrid arrowheads
  as dynamic per-edge `arrows2d!` child plots; stop if it implements pointer
  interactions; stop if it breaks the public attribute surface without explicit
  approval; stop if it cannot name the output node corresponding to a reactive
  primitive argument; stop if it makes users call `directedges!` or
  `preorder!` before public plotting works.
- **Regression expectations**: every accepted visible behavior currently
  covered by tests or docs remains covered; new verification must fail the old
  broad-rebuild or direct-node-mutation-only implementation shape.

## Testing and verification decisions

- The full test suite must remain green.
- The docs build must remain green.
- Existing visual render checks remain required for visible behavior.
- New tests must call `Makie.update!`, not only direct compute node mutation.
- New tests must prove that representative child primitive plots receive
  updated arguments or attributes without full child plot tree recreation.
- Computation-layer tests must not require a Makie figure.
- Reactive graph layer tests must verify node names and recomputation behavior.
- Verification must include at least:
  - edge color update
  - style update
  - data/network update
  - text visibility or text channel update
  - limit update
  - multi-axis composition
  - hybrid arrowhead mesh update and hidden-arrow typed empty output

## Out of scope

- Mouse hover behavior.
- Mouse click behavior.
- Mouse drag behavior.
- DataInspector customization.
- Selection tools.
- R interoperability.
- Non-`HybridNetwork` public input types.
- Public attribute renaming.
- User-responsibility network preparation as the default public plotting
  contract.
- Performance optimization beyond avoiding the old full-rebuild architecture.
- Preserving old internal scaffold names as target architecture names.

## Open questions

None. The project owner resolved the prior open questions:

- `reactive graph layer` remains workflow-local PRD language and is not added
  to `STYLE-vocabulary.md`.
- Old internal scaffold names are purged and replaced with names that reflect
  the computation layer, graph layer, and primitive assembly responsibilities.
- The current child primitive design uses direct compute-node arguments and no
  child primitive `update!` reactions. The concrete exception discovered during
  PRD revision is architectural rather than reactive: hybrid arrowheads move
  from per-edge `arrows2d!` children to computed `poly!` mesh geometry because
  `Arrows2D` cannot represent per-arrow vector `tiplength` and `tipwidth`.
- Network traversal preparation remains caller-safe by default. The
  computation layer prepares a private copied network with
  `PhyloNetworks.directedges!` and `PhyloNetworks.preorder!`; users are not
  required to mutate their own network before public plotting works.

## Further notes

The current logic for computing, annotation preparation, render channels,
and accepted visual behavior is CORRECT.
The refactor should abstract these into a core computation layer, preserving all
functionality and behavior.
However, do not preserve the current scaffold as the default
shape.
The computation graph layer makes using of the computation layer functions for calculations, mapping
input nodes to output nodes based on the results.



This PRD is saved with `workflow-status: Proposed`. The project owner may
review and revise it. It must not drive trancheing until the project owner sets
`workflow-status: Approved` in the frontmatter.
