---
date-created: 2026-07-15T14:03:34-07:00
workflow-instrument: Tasking plan
workflow-status: Approved
workflow-agent-thread-id: codex/019f678f-e69e-7663-8203-67803dc30c62
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-04
---

# Tasks for tranche 4: Public reactivity and visual verification

This tasking file covers Tranche 4 of `reactive-makie-spine`, titled "Public reactivity and visual verification" in the approved tranche file. Tranche 4 converts the current implementation into contract-level verification. The implementation already has the post-Tranche-3 runtime shape: `Makie.plot!(plot::PhyloPlot)` in `src/recipe.jl` calls `validate_public_plot_limits`, `register_phylo_graph!`, and `create_phylo_primitives!`, then returns `plot`; `src/primitive_assembly.jl` creates 3 `Makie.LineSegments` children, 1 `Makie.Poly` child, and 9 `Makie.Text` children from graph output nodes.

Repository revalidation before this file was written found the required begin-green state:

```text
Test Summary: | Pass  Total     Time
PhyloMakie.jl |  868    868  2m06.3s
```

The docs build also completed successfully with non-fatal Documenter warnings about large HTML examples falling back to image representations.

Current red-state residue for this tranche is in the verification layer, not in `Makie.plot!` itself. `test/test_render_adapter.jl` and `test/support/render_test_helpers.jl` still call `render_plot!` and assert `PlotRenderLayers` behavior. `test/test_attribute_schema.jl`, `test/test_layout_engine.jl`, and `test/test_plot_layout.jl` still exercise `PhyloPlotAttributes`, `layout_plot_geometry`, `PlotGeometry`, `prepare_plot_layout`, and `PlotLayout` as test proof surfaces even though target computation-layer files now provide `PhyloPlotConfig`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels`. Tranche 4 must migrate those proof obligations to the current public, graph, primitive, and computation contracts without dropping behavior coverage.

## Settled user decisions and environment baseline

- Public plotting entry points and public attributes remain protected: `Makie.plot`, `Makie.plot!`, `phyloplot`, `phyloplot!`, `PhyloPlot`, and the current keyword surface must keep working.
- The recipe argument update path is `arg1`; public dynamic tests must call `Makie.update!(plot; arg1 = new_net)` for plotted-network updates.
- Public attribute updates must be tested through `Makie.update!(plot; ...)`, not through assignments such as `plot[:edgecolor][] = value`, `plot[:style][] = value`, or `plot[:net][] = value`.
- `register_phylo_graph!` in `src/reactive_graph.jl` is the function that registers graph outputs for `PhyloPlot`. Tests may read graph output node values after registration, but tests must not mutate public input nodes directly as the dynamic-entrypoint proof.
- `create_phylo_primitives!` in `src/primitive_assembly.jl` is the function that creates stable child primitives from graph output nodes. Tests must verify stable children and changed graph-driven child values for representative updates.
- Current hybrid arrowheads use one stable `Makie.Poly` child that consumes `:minor_arrowhead_meshes`, `:minor_arrowhead_colors`, `:minor_arrowhead_strokecolors`, and `:minor_arrowhead_strokewidth`.
- Dynamic per-edge `Makie.arrows2d!` children are forbidden for current hybrid arrowheads in the accepted runtime path.
- Hidden layers are represented by typed empty graph outputs consumed by stable child primitives. Normal updates must not delete child primitives to hide layers.
- Public plotting remains caller-safe for `PhyloNetworks.HybridNetwork`: `plot`, `plot!`, `phyloplot`, `phyloplot!`, and `Makie.update!(plot; arg1 = new_net)` must not mutate the caller-owned network.
- Pointer interactions are out of scope: hover, click, drag, selection, and DataInspector customization must not enter implementation or tests in this tranche.
- Tranche 4 may edit tests and test-support helpers to remove old scaffold proof surfaces. It must not make a hidden docs narrative rewrite or broad source deletion a prerequisite. Documentation narrative cleanup is Tranche 5.
- `src/attribute_schema.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`, and `src/render_adapter.jl` may remain as transitional compatibility source until a later approved cleanup, but no Tranche 4 test may use those old names as the proof surface for accepted target behavior.
- Do not add dependencies or edit `Project.toml`, `Manifest.toml`, `docs/Project.toml`, `docs/Manifest.toml`, `test/Project.toml`, or `test/Manifest.toml`. If a dependency change appears necessary, stop and ask for project-maintainer approval.
- Use local upstream sources already present in this workspace. Do not use network access for this tranche unless explicitly approved.
- No `codebases-and-documentation` directory is present at the workspace root or the PhyloMakie root. Use the sibling repositories and resolved package source paths listed here as upstream primary sources.

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

The bundled development-policy depot was consulted. Its reference files are byte-identical to the project-local files where both copies exist. Expected bundled files `references/CONTRIBUTING.md`, `references/STYLE-python.md`, and `references/STYLE-vocabulary.md` were not present. Project-local `CONTRIBUTING.md` and `STYLE-vocabulary.md` are present and are active authorities.

Read-only git and shell commands may be used freely for diagnosis. Mutating git operations such as commit, merge, push, rebase, reset, checkout for branch changes, and branch creation remain the human project maintainer's responsibility unless the user explicitly instructs otherwise.

Controlled vocabulary constraints:

- Use `HybridNetwork`, `Makie-native public plot owner`, `public attribute surface`, `full-tree style`, `major-tree style`, `major hybrid edge`, and `minor hybrid edge` as defined in `STYLE-vocabulary.md`.
- Use `tranche`, `lock item`, `red-state repro`, `handoff packet`, `upstream primary source`, `verification artifact`, and `stop condition` as defined in `STYLE-workflow-vocabulary.md`.
- Use `reactive graph layer` only for `src/reactive_graph.jl` and the named functions that register graph outputs. Do not add the phrase to `STYLE-vocabulary.md` in this tranche.
- Treat `render_plot!`, `PhyloPlotAttributes`, `PlotLayout`, and `PlotRenderLayers` as old scaffold names. They may appear in source compatibility files until a later cleanup, but Tranche 4 tests and test helpers must not use them as accepted target architecture names.
- Apply `STYLE-agent-language.md` to every responsibility statement. When this file says a function owns a responsibility, it names the function, the behavior, the consumers, the duplicate or bypass paths, and the verification artifact.

Required upstream primary sources for this tranche:

- `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`, especially the explanation that dereferencing compute nodes in a recipe produces snapshots and that reactive primitive calls must consume compute graph nodes.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`, especially `ComputePipeline.update!(plot::Plot; args...)`, `data_limits(plot::Plot)`, the warning against storing `Observable`s in plot attributes, plot `map!`, and primitive argument expansion.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`, especially `FigureAxisPlot`, `figurelike_return`, `figurelike_return!`, `_create_plot`, and `plot!(ax::AbstractAxis, plot::AbstractPlot)`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`, especially the `LineSegments`, `Text`, and `Poly` recipe attribute contracts.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`, especially same-transaction text and position update behavior and the error path for mismatched text blocks and positions.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`, especially vector-of-polygon `convert_arguments` and `poly!` conversion to mesh outputs.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`, especially `ComputeGraph`, `update!`, `register_computation!`, and `map!`.

## Primary-goal lock

### Lock 1: Public dynamic entrypoint coverage

- The work is not complete if tests prove reactivity only through direct graph input mutation or helper-level recomputation rather than `Makie.update!(plot; ...)`.
- Direct red-state repro: the historical recipe test mutated `plot_handle[:edgecolor][]`, `plot_handle[:style][]`, and `plot_handle[:net][]`; a weak replacement could still pass graph helper tests while the public Makie update contract is broken.
- Tasks that close it: 3 and 4.
- Verification artifact: public tests call `Makie.update!(plot; edgecolor = ...)`, `Makie.update!(plot; edgewidth = ...)`, `Makie.update!(plot; style = ...)`, `Makie.update!(plot; arg1 = new_net)`, `Makie.update!(plot; showtiplabel = ...)`, `Makie.update!(plot; shownodelabel = ...)`, `Makie.update!(plot; showgamma = ...)`, and `Makie.update!(plot; xlim = ..., ylim = ...)`. The tests assert changed graph outputs, changed child primitive values, stable child identities, or changed colorbuffers for each update class.

### Lock 2: Public surface matrix coverage

- The work is not complete if any supported public plotting surface lacks contract coverage after old helper tests are migrated.
- Direct red-state repro: old render-helper tests call `render_plot!` directly and therefore do not prove `plot(net)`, `plot!(axis, net)`, `phyloplot(net)`, or `phyloplot!(axis, net)` as the user-facing surfaces.
- Tasks that close it: 3 and 5.
- Verification artifact: tests cover `plot(net)` returning `Makie.FigureAxisPlot`, `phyloplot(net)` returning `Makie.FigureAxisPlot`, `plot!(axis, net)` returning `PhyloPlot`, `phyloplot!(axis, net)` returning `PhyloPlot`, and dual-axis composition in one `Figure`. Each surface must render a nonempty CairoMakie colorbuffer or match an equivalent public-surface colorbuffer.

### Lock 3: Old scaffold proof surfaces are retired from tests

- The work is not complete if tests or test support helpers still call `render_plot!`, assert `PlotRenderLayers`, or use `PhyloPlotAttributes`, `PlotGeometry`, `PlotLayout`, `layout_plot_geometry`, or `prepare_plot_layout` as accepted target architecture proof.
- Direct red-state repro: current `test/test_render_adapter.jl` asserts `PlotRenderLayers`; current `test/support/render_test_helpers.jl` calls `render_plot!`; current `test/test_attribute_schema.jl`, `test/test_layout_engine.jl`, and `test/test_plot_layout.jl` exercise old compatibility names as first-class test surfaces.
- Tasks that close it: 1, 2, and 6.
- Verification artifact: source audit over `test/` returns no matches for `render_plot!`, `PlotRenderLayers`, `SegmentRenderLayer`, `ArrowTipRenderLayer`, `TextRenderLayer`, `_render_arrow_tip_layer!`, `PhyloPlotAttributes`, `resolve_phylo_plot_attributes`, `with_phylo_plot_limits`, `PlotGeometry`, `layout_plot_geometry`, `PlotBounds`, `PlotAnnotationData`, `PlotLayout`, or `prepare_plot_layout`.

### Lock 4: Behavior migration preserves old render assertions on new surfaces

- The work is not complete if old render-helper assertions are removed without equivalent checks on `PrimitiveChannels`, graph outputs, stable child primitives, public plots, or CairoMakie colorbuffers.
- Direct red-state repro: current `test/test_render_adapter.jl` contains useful checks for style distinction, minor-edge linestyle, color and width policy, text size policy, text channel positions, gamma label colors, edge labels, explicit limits, and hidden minor-edge states, but those checks run through the old render adapter.
- Tasks that close it: 1, 2, and 5.
- Verification artifact: migrated tests assert the same behaviors through `compute_primitive_channels`, `register_phylo_graph!` outputs, child primitive values from `plot.plots`, `Makie.data_limits(plot)`, and public render colorbuffers. A deletion-only implementation fails because the named migrated assertions are absent.

### Lock 5: Forbidden architecture shapes fail direct checks

- The work is not complete if the test suite can pass while the broad rebuild callback, snapshot primitive arguments, dynamic per-edge `arrows2d!` arrowheads, side-effect limit application, or hidden-layer child deletion returns.
- Direct red-state repro: historical `src/recipe.jl` installed broad `Makie.onany`, deleted children, emptied `plot.plots`, recomputed values, and called `render_plot!`; historical `_render_arrow_tip_layer!` created one `Makie.arrows2d!` child per current arrowhead.
- Tasks that close it: 4 and 6.
- Verification artifact: source audits reject the forbidden runtime path in `src/recipe.jl` and `src/primitive_assembly.jl`; runtime tests assert stable child identities, one `Makie.Poly` arrowhead child, no `Makie.Arrows2D` child in accepted `PhyloPlot` child plots, graph-backed `Makie.data_limits(plot)`, and typed empty child values for hidden layers.

### Lock 6: Caller-safe `HybridNetwork` updates

- The work is not complete if plotting or `Makie.update!(plot; arg1 = new_net)` mutates a caller-owned `PhyloNetworks.HybridNetwork`.
- Direct red-state repro: a fresh `readnewick` network has empty `vec_node` before plotting; the old unsafe shape would require users to call `PhyloNetworks.directedges!` or `PhyloNetworks.preorder!`, or would mutate the original network during plotting.
- Tasks that close it: 3 and 5.
- Verification artifact: public tests snapshot `rooti`, `isrooted`, `vec_node`, edge parent and child values, `ischild1`, and `containroot` before public plotting and before `Makie.update!(plot; arg1 = new_net)`, then assert the caller-owned network snapshot is unchanged while graph outputs change.

### Lock 7: Pointer interactions stay out of scope

- The work is not complete if this tranche adds hover, click, drag, selection, or DataInspector behavior, or tests that imply those features are supported.
- Direct red-state repro: the open interaction design note lists pointer interaction ideas, but the PRD explicitly defers pointer interactions from `reactive-makie-spine`.
- Tasks that close it: 4 and 6.
- Verification artifact: source audit over Tranche 4-edited files rejects new pointer-interaction terms and Makie interaction APIs, while existing docs-only future-interaction prose remains a Tranche 5 concern.

### Lock 8: Green-state gates and docs boundary remain honest

- The work is not complete if Tranche 4 leaves tests or docs red, or if it hides docs narrative cleanup inside a verification tranche without naming it.
- Direct red-state repro: current docs still mention old scaffold names, but `julia --project=docs docs/make.jl` is green because compatibility source remains. Removing compatibility source or changing docs examples in Tranche 4 would silently cross the Tranche 5 boundary.
- Tasks that close it: 6.
- Verification artifact: final gates run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. The implementation report records that docs narrative old-name cleanup remains Tranche 5 unless the project maintainer separately approves moving that work into Tranche 4.

## Forbidden passing implementation table

| Lock item | Required behavior | Current code state | Resolved implementation instruction | Forbidden passing implementation | Failing verification artifact |
| --- | --- | --- | --- | --- | --- |
| Lock 1: public dynamic entrypoint coverage | Public dynamic changes enter through `Makie.update!(plot; ...)` and prove changed graph outputs, child values, stable child identities, or colorbuffers. | Current tests already use `Makie.update!` in `test/test_recipe.jl`, `test/test_reactive_graph.jl`, and `test/test_primitive_assembly.jl`, but old helper tests still bypass public surfaces. | Add or migrate public update cases in `test/test_recipe.jl`, `test/test_primitive_assembly.jl`, and the new public render contract tests for `edgecolor`, `edgewidth`, `style`, `arg1`, text visibility, gamma visibility, and limits. | Keep helper tests that read `plot[:primitive_channels][]` or direct graph node values and add only one weak `Makie.update!` smoke test. | Runtime assertions after each named `Makie.update!` call plus source audit rejecting direct public input assignments in tests. |
| Lock 2: public surface matrix coverage | `plot`, `plot!`, `phyloplot`, and `phyloplot!` each have public contract coverage and render evidence. | `test/test_recipe.jl` covers the four surfaces; old `test/test_render_adapter.jl` covers visible behavior through `render_plot!` instead of public surfaces. | Keep the surface dispatch tests in `test/test_recipe.jl`; move visible behavior preservation checks into public render tests that call `Makie.plot`, `Makie.plot!`, `phyloplot`, or `phyloplot!`. | Delete old render-adapter tests and rely only on computation-layer tests, leaving `plot!(axis, net)` and `phyloplot!` render behavior unverified. | Public-surface tests must produce nonempty colorbuffers and compare expected equivalent or distinct outputs. |
| Lock 3: old scaffold proof retired | Tests and helpers no longer use old scaffold names as proof surfaces. | `test/test_render_adapter.jl`, `test/support/render_test_helpers.jl`, `test/test_attribute_schema.jl`, `test/test_layout_engine.jl`, and `test/test_plot_layout.jl` use old names. | Migrate assertions to `test/test_plot_config.jl`, `test/test_network_layout.jl`, `test/test_annotation_tables.jl`, `test/test_primitive_channels.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, and new public render tests; remove the old test includes or leave the files empty only if `test/runtests.jl` no longer includes them. | Keep `render_plot!` and `PhyloPlotAttributes` tests but rename testsets to sound new. | `rg` audit over `test/` rejects the old names listed in Lock 3. |
| Lock 4: behavior migration | Style, minor-edge, color, width, text, gamma, label, hidden-layer, and limit assertions move to current computation, graph, primitive, and public render contracts. | Old behavior assertions are concentrated in `test/test_render_adapter.jl`. | Recreate those assertions with `compute_primitive_channels`, `register_phylo_graph!`, `plot.plots` child values, `Makie.data_limits(plot)`, and colorbuffer checks. | Remove `test/test_render_adapter.jl` without adding equivalent assertions, causing green tests with lost behavior coverage. | Named migrated assertions for each old behavior group; test review fails if any group is absent. |
| Lock 5: forbidden architecture checks | Broad rebuild, snapshot primitive arguments, per-edge `arrows2d!`, side-effect limits, and hidden-child deletion fail tests. | `src/recipe.jl` and `src/primitive_assembly.jl` currently avoid the forbidden runtime path; old `src/render_adapter.jl` still contains transitional forbidden old-path code. | Audit accepted runtime files `src/recipe.jl`, `src/primitive_assembly.jl`, and `src/reactive_graph.jl`; audit `src/render_adapter.jl` only to confirm tests no longer depend on it, not to require deletion in Tranche 4. | Add a broad source audit that scans all source and forces deleting compatibility modules, causing docs failure or a hidden source cleanup outside tranche scope. | Source audit with explicit included files and excluded compatibility/docs boundary, plus runtime child identity and child type tests. |
| Lock 6: caller-safe network updates | Public plotting and `Makie.update!(plot; arg1 = new_net)` prepare private network copies and leave caller networks unchanged. | `test/test_recipe.jl` and `test/test_reactive_graph.jl` already snapshot networks, but Tranche 4 must keep this as public-surface proof after test migration. | Preserve and extend network snapshot checks in public render/update tests; use `prepare_plot_network` only as a computation-layer proof, not as a user requirement. | Prove caller safety only by unit-testing `prepare_plot_network` while public `Makie.update!(plot; arg1 = new_net)` mutates its argument. | Public update test snapshots `new_net` before `Makie.update!` and asserts unchanged state after graph outputs change. |
| Lock 7: pointer interactions out of scope | No pointer interaction behavior or tests enter this tranche. | Current runtime source has no pointer implementation for this PRD; docs and open design notes mention future pointer interactions. | Add a Tranche 4 source audit over edited runtime and test files that rejects new hover/click/drag/selection/DataInspector implementation terms. | Add a hover smoke test or DataInspector hook while doing visual verification and call it incidental. | Source audit over Tranche 4-edited files plus absence of pointer-interaction tests. |
| Lock 8: green gates and docs boundary | Tests and docs are green, and docs narrative cleanup remains explicitly assigned to Tranche 5. | Current tests pass `868/868`; docs build passes with non-fatal Documenter warnings; docs still mention old scaffolds. | Run final test and docs gates. Do not edit docs narrative in Tranche 4 unless the maintainer explicitly expands scope. | Remove compatibility source or edit docs narrative opportunistically, making Tranche 5 unclear or breaking docs. | Final `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`; implementation report names Tranche 5 docs cleanup residue. |

## Handoff packet

- **Active authorities**: this tasking file after approval; `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`; Tranche 1 through 3 tasking files and implementation results; project-local governance files listed in the Governance section; local upstream primary sources listed above.
- **Parent documents**: `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/03-01_tranche-01--tasking-1.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/03-02_tranche-02--tasking-1.md`, and `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`.
- **Settled decisions and non-negotiables**: preserve public attributes and entrypoints; prove dynamic behavior through `Makie.update!`; verify public surfaces; keep stable child primitives; keep one `Makie.Poly` arrowhead child; keep hidden layers as typed empty outputs; do not implement pointer interactions; do not move Tranche 5 docs narrative cleanup into Tranche 4 without explicit approval.
- **Authorization boundary**: tests and test-support helpers may be rewritten deeply. Runtime redesign, source compatibility deletion, public API changes, dependency changes, pointer interactions, and docs narrative rewrite are out of scope.
- **Current-state diagnosis**: accepted runtime path is new graph-driven primitive assembly, but the test suite still contains old scaffold proof surfaces that can let a future regression hide behind helper-level or compatibility-level checks.
- **Primary-goal lock**: lock items 1 through 8 in this file.
- **Direct red-state repros**: direct public input node mutation as dynamic proof; `render_plot!` helper tests; `PlotRenderLayers` assertions; old `PhyloPlotAttributes`/`PlotLayout` tests; broad rebuild callback; per-edge `arrows2d!`; pointer-interaction scope creep.
- **Responsible code entities and responsibilities**: `register_phylo_graph!` in `src/reactive_graph.jl` registers graph output nodes; `create_phylo_primitives!` in `src/primitive_assembly.jl` creates stable child primitives from graph output nodes; `Makie.plot!(plot::PhyloPlot)` in `src/recipe.jl` orchestrates validation, graph registration, primitive creation, and return; `compute_primitive_channels` in `src/primitive_channels.jl` computes segment, text, arrowhead, and data-limit payloads; public tests must verify these responsibilities through public plotting, graph output, child primitive, and render artifacts rather than through old compatibility helpers.
- **Supported public surfaces affected**: `plot(net)`, `plot!(axis, net)`, `phyloplot(net)`, `phyloplot!(axis, net)`, public attribute updates through `Makie.update!`, and recipe argument updates through `Makie.update!(plot; arg1 = new_net)`.
- **Exact files in scope**: `test/runtests.jl`, `test/support/render_test_helpers.jl`, `test/support/public_surface_cases.jl`, `test/support/fixture_corpus.jl`, `test/test_attribute_schema.jl`, `test/test_plot_config.jl`, `test/test_layout_engine.jl`, `test/test_network_layout.jl`, `test/test_plot_layout.jl`, `test/test_annotation_tables.jl`, `test/test_render_adapter.jl`, `test/test_primitive_channels.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, `test/test_recipe.jl`, new `test/test_public_render_contracts.jl`, and new `test/test_architecture_audits.jl`.
- **Exact files and surfaces out of scope**: `src/attribute_schema.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`, `src/render_adapter.jl`, docs pages, dependency manifests, public attribute names, pointer interaction code, non-`HybridNetwork` plotting support, external public API redesign, performance tuning, and Tranche 5 documentation closeout.
- **Required upstream primary sources**: all Makie and ComputePipeline files listed in the Governance section, plus the project Makie interactivity tutorial.
- **Green-state gates**: targeted tests after each task; source audits for forbidden red states; final `julia --project=test test/runtests.jl`; final `julia --project=docs docs/make.jl`.
- **Stop conditions**: stop if a public behavior change appears necessary; stop if docs cleanup becomes required to keep tests green; stop if compatibility source deletion appears necessary; stop if a public semantic lacks a testable surface; stop if pointer interaction code or tests appear necessary; stop if upstream Makie or ComputePipeline behavior contradicts the planned verification.

## Required revalidation before implementation

- Read this tasking file, the parent tranche file, the parent PRD, the codeplan, and Tranche 1 through 3 tasking files in full.
- Read the governance documents listed above line by line, especially `STYLE-agent-language.md`, before using ownership, contract, boundary, layer, invariant, compatibility, verification, source, or responsibility language.
- Run or inspect the current baseline before edits. If `julia --project=test test/runtests.jl` is red before implementation, record the failure and stop unless the project maintainer authorizes proceeding from a red baseline.
- Run or inspect `julia --project=docs docs/make.jl` before edits. If docs are red before implementation, record the failure and stop unless the maintainer authorizes proceeding.
- Re-read current files in scope under `test/`, plus `src/recipe.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, `src/primitive_channels.jl`, and the compatibility files named in the current-state diagnosis.
- Re-read the required upstream primary sources where they constrain the task being executed.
- If current code no longer matches the diagnosis in this tasking file, stop and raise that before changing code.

## Tranche execution rule

Tranche 4 is a verification migration. It may rewrite tests and test support helpers. It must not redesign runtime architecture, delete compatibility source, change public attributes, implement pointer interactions, or rewrite docs narrative. It must begin and end green for tests and docs.

The behavior that must no longer exist in Tranche 4 test proof is direct public input node mutation, old render-adapter proof, old attribute/layout scaffold proof, source-audit-only proof where runtime evidence is available, and deleted coverage hidden behind a green suite.

## Non-negotiable execution rules

- Do not use `plot[:edgecolor][] = value`, `plot[:style][] = value`, `plot[:net][] = value`, or `plot[:arg1][] = value` as the public dynamic-entrypoint proof.
- Do not call `render_plot!` from tests or test helpers.
- Do not assert `PlotRenderLayers`, `SegmentRenderLayer`, `ArrowTipRenderLayer`, or `TextRenderLayer` in tests.
- Do not use `PhyloPlotAttributes`, `resolve_phylo_plot_attributes`, `with_phylo_plot_limits`, `PlotGeometry`, `layout_plot_geometry`, `PlotBounds`, `PlotAnnotationData`, `PlotLayout`, or `prepare_plot_layout` as test proof surfaces.
- Do not remove behavior coverage from old tests unless the same behavior is named and verified through the target computation, graph, primitive, public plotting, or render contract.
- Do not implement or test hover, click, drag, selection, or DataInspector behavior.
- Do not edit docs pages as part of Tranche 4 except for a maintainer-approved scope change recorded before implementation.
- Do not edit source compatibility modules merely to satisfy a broad source-text audit.
- Do not edit project or manifest files.

## Concrete anti-patterns or removal targets

- `test/support/render_test_helpers.jl` calling `render_plot!`.
- `test/test_render_adapter.jl` asserting `PlotRenderLayers` or old render-layer fields.
- `test/test_attribute_schema.jl` using `PhyloPlotAttributes`, `resolve_phylo_plot_attributes`, or `with_phylo_plot_limits`.
- `test/test_layout_engine.jl` using `layout_plot_geometry` or `PlotGeometry`.
- `test/test_plot_layout.jl` using `prepare_plot_layout`, `PlotLayout`, `PlotBounds`, or `PlotAnnotationData`.
- Any new or existing test whose only reactivity proof is direct mutation of public graph input nodes.
- Any source audit that forces broad deletion of docs or compatibility source instead of checking the accepted runtime path and test proof surfaces.
- Any partial migration where edge segments use graph/public proof while text layers, arrowheads, limits, or public surfaces remain verified only by old helper code.

## Failure-oriented verification

- The current verification layer must fail a `test/` source audit for old scaffold proof names before tasks 1 and 2 complete.
- A fake fix that deletes old tests without migrating style, color, width, text, gamma, limit, hidden-layer, and multi-axis assertions must fail named migrated assertion checks.
- A fake fix that proves only `register_phylo_graph!` outputs while public `Makie.update!` is broken must fail public update tests.
- A fake fix that registers output nodes but passes snapshots to child primitives must fail child value update tests after `Makie.update!`.
- A fake fix that keeps dynamic per-edge `Makie.arrows2d!` children must fail child type and source audits.
- A fake fix that deletes hidden child primitives must fail stable child count and identity tests.
- A fake fix that mutates caller-owned networks must fail public plotting and `arg1` update snapshot tests.
- Positive runtime verification must show stable children, changed child argument values, changed colorbuffers for representative updates, public-surface return contracts, public multi-axis composition, graph-backed data limits, and preserved caller-owned `HybridNetwork` state.

## Tasks

### 1. Migrate old attribute and layout tests to computation-layer proofs

**Type**: MIGRATE
**Output**: Attribute, geometry, and annotation behavior currently tested through `PhyloPlotAttributes`, `layout_plot_geometry`, and `prepare_plot_layout` is tested through `PhyloPlotConfig`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels`.
**Depends on**: none
**Positive contract**: `test/test_plot_config.jl`, `test/test_network_layout.jl`, `test/test_annotation_tables.jl`, and `test/test_primitive_channels.jl` contain the migrated assertions for defaults, style-dependent defaults, color and width policy, DataFrame copying, warning behavior, geometry fixtures, annotation table fixtures, midpoint positions, and limit messages.
**Negative contract**: `test/test_attribute_schema.jl`, `test/test_layout_engine.jl`, and `test/test_plot_layout.jl` must not remain included test files that prove accepted behavior through old compatibility names. Their coverage must not disappear.
**Files**: `test/test_attribute_schema.jl`, `test/test_plot_config.jl`, `test/test_layout_engine.jl`, `test/test_network_layout.jl`, `test/test_plot_layout.jl`, `test/test_annotation_tables.jl`, `test/test_primitive_channels.jl`, `test/runtests.jl`.
**Out of scope**: `src/attribute_schema.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`, docs files, public attribute names, and compatibility source removal.
**Verification**: `rg -n "PhyloPlotAttributes|resolve_phylo_plot_attributes|with_phylo_plot_limits|PlotGeometry|layout_plot_geometry|PlotBounds|PlotAnnotationData|PlotLayout|prepare_plot_layout" test/test_attribute_schema.jl test/test_layout_engine.jl test/test_plot_layout.jl test/test_plot_config.jl test/test_network_layout.jl test/test_annotation_tables.jl test/test_primitive_channels.jl` returns no matches. `julia --project=test test/runtests.jl` passes after the migration.

Move the `SUPPORTED_PHYLOPLOT_ATTRIBUTES` and `Makie.attribute_names(PhyloPlot)` assertions from `test/test_attribute_schema.jl` into `test/test_plot_config.jl` or `test/test_recipe.jl`. Move style-default, invalid-style warning, edge-color fallback, edge-width validation, DataFrame copying, and limit-copy assertions to `resolve_plot_config`, `_resolve_defaultedgecolor`, `_resolve_edgewidth_mode`, `with_plot_config_limits`, and `compute_primitive_channels`. Move `test/test_layout_engine.jl` fixture-coordinate, missing-length warning, all-missing fallback, and root-mismatch assertions to `test/test_network_layout.jl` using `prepare_plot_network` and `compute_network_geometry`. Move `test/test_plot_layout.jl` node-label, edge-label, warning, midpoint, and limit-message assertions to `test/test_annotation_tables.jl` using `compute_layout`. Remove the old test includes from `test/runtests.jl` after the migrated assertions are present.

### 2. Replace render-adapter tests with public render contract tests

**Type**: MIGRATE
**Output**: `test/test_public_render_contracts.jl` verifies visible behavior and primitive payload behavior without calling `render_plot!`, and `test/support/render_test_helpers.jl` no longer builds old render-adapter cases.
**Depends on**: 1
**Positive contract**: Public render tests cover style distinction, minor-edge linestyle visibility, edge color and width policy, gamma label colors, text sizes, text positions, edge labels, node labels, explicit limits, hidden minor-edge states, and arrowhead suppression through `compute_primitive_channels`, graph outputs, stable child primitives, `Makie.data_limits(plot)`, and CairoMakie colorbuffers.
**Negative contract**: Tests must not assert `PlotRenderLayers`, old render-layer fields, or `_render_arrow_tip_layer!`. Removing `test/test_render_adapter.jl` without migrating its behavior groups is a forbidden passing implementation.
**Files**: `test/support/render_test_helpers.jl`, `test/test_render_adapter.jl`, `test/test_public_render_contracts.jl`, `test/test_primitive_channels.jl`, `test/test_primitive_assembly.jl`, `test/test_recipe.jl`, `test/support/fixture_corpus.jl`, `test/runtests.jl`.
**Out of scope**: `src/render_adapter.jl`, docs files, source compatibility deletion, public API redesign, and pointer interactions.
**Verification**: `rg -n "render_plot!|PlotRenderLayers|SegmentRenderLayer|ArrowTipRenderLayer|TextRenderLayer|_render_arrow_tip_layer!" test` returns no matches. `julia --project=test test/runtests.jl` passes. New public render tests must fail if `test/test_render_adapter.jl` is removed without migrated assertions.

Create `test/test_public_render_contracts.jl` and include it from `test/runtests.jl`. Replace `_render_case` in `test/support/render_test_helpers.jl` with helpers that call public plotting surfaces or build `PrimitiveChannels` from `prepare_plot_network`, `resolve_plot_config`, `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels`. Delete or stop including `test/test_render_adapter.jl` after moving each behavior group. Use existing fixture data in `test/support/fixture_corpus.jl`; do not invent new fixture semantics unless a migrated assertion needs a named fixture row.

### 3. Complete the public update and public surface matrix

**Type**: TEST
**Output**: Public tests prove `Makie.update!` for attribute, text, style, limit, and network updates across the supported public surfaces.
**Depends on**: 2
**Positive contract**: Tests cover `plot(net)`, `phyloplot(net)`, `plot!(axis, net)`, and `phyloplot!(axis, net)` return contracts and render behavior. Tests call `Makie.update!` for `edgecolor`, `edgewidth`, `style`, `arg1`, `showtiplabel`, `shownodelabel`, `showgamma`, `xlim`, and `ylim`, then assert changed graph outputs, changed child primitive values, stable child identities, changed colorbuffers, or changed `Makie.data_limits(plot)`.
**Negative contract**: Direct assignments to public graph input nodes must not be the dynamic-entrypoint proof. Tests must not cover only one public surface and infer the rest.
**Files**: `test/test_recipe.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`, `test/support/public_surface_cases.jl`, `test/support/render_test_helpers.jl`.
**Out of scope**: pointer interactions, docs pages, source compatibility removal, new public attributes, and performance benchmarking.
**Verification**: `rg -n "\\[:(edgecolor|edgewidth|style|net|arg1|showtiplabel|shownodelabel|showgamma|xlim|ylim)\\]\\[\\]\\s*=" test` returns no matches. `julia --project=test test/runtests.jl` passes. Tests must fail a build that implements only direct node mutation or only helper-level recomputation.

Extend existing update tests rather than duplicating identical assertions. Keep `test/test_reactive_graph.jl` focused on node registration and recomputation, keep `test/test_primitive_assembly.jl` focused on stable children and child argument values, and keep public render contract tests focused on externally meaningful colorbuffers and return surfaces. For caller-safe updates, snapshot the caller-owned `HybridNetwork` before `Makie.update!(plot; arg1 = new_net)` and assert the snapshot is unchanged after graph outputs and render output change.

### 4. Add architecture source audits that supplement runtime proof

**Type**: TEST
**Output**: `test/test_architecture_audits.jl` rejects forbidden runtime-path and verification-path shapes without treating docs or transitional compatibility source as Tranche 4 deletion targets.
**Depends on**: 1, 2, and 3
**Positive contract**: Source audits reject broad rebuild reactivity in `src/recipe.jl`, snapshot primitive arguments and per-edge `arrows2d!` in `src/primitive_assembly.jl`, old scaffold proof names in `test/`, direct public input assignment in tests, and pointer-interaction scope creep in Tranche 4-edited tests and runtime files.
**Negative contract**: Source audits must not replace runtime proof. They must not scan docs pages for old names in Tranche 4. They must not force deletion of `src/attribute_schema.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`, or `src/render_adapter.jl`.
**Files**: `test/test_architecture_audits.jl`, `test/runtests.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`.
**Out of scope**: docs narrative audits, broad source compatibility deletion, CI YAML checks, dependency manifests, and pointer interaction implementation.
**Verification**: `julia --project=test test/runtests.jl` passes. The audit test must fail if `src/recipe.jl` contains `Makie.onany`, `is_rebuilding`, child deletion, `empty!(plot.plots)`, direct layout/computation calls, or `render_plot!`; if `src/primitive_assembly.jl` contains `plot[output_symbol][]` snapshot use, `render_plot!`, `arrows2d!`, `_apply_plot_limits!`, `xlims!`, or `ylims!`; or if `test/` contains old scaffold proof names from Lock 3.

Implement source audits as small helper functions that read exact files and match exact forbidden tokens. Pair every source audit with a runtime or public-surface test already created by tasks 2 and 3. Record in test names that docs old-name cleanup is Tranche 5 so a future reviewer does not expand the audit boundary by accident.

### 5. Strengthen visual preservation artifacts

**Type**: TEST
**Output**: Visual and runtime artifacts prove the accepted visible behavior survives the verification migration.
**Depends on**: 2 and 3
**Positive contract**: Tests render nonempty CairoMakie colorbuffers for full-tree style, major-tree style, labels, explicit limits, edge colors, edge widths, gamma labels, hidden layers, and multi-axis composition. Tests compare full-tree and major-tree colorbuffers as distinct for a reticulate network, compare equivalent `plot` and `phyloplot` colorbuffers for the same input, and compare equivalent `plot!` and `phyloplot!` colorbuffers for the same input.
**Negative contract**: Geometry-only assertions, source audits, and docs builds must not be the only proof for visible behavior. Tests must not use `render_plot!` or old render-layer fields to produce visual artifacts.
**Files**: `test/test_public_render_contracts.jl`, `test/test_recipe.jl`, `test/support/render_test_helpers.jl`, `test/support/fixture_corpus.jl`, `test/support/public_surface_cases.jl`.
**Out of scope**: golden image files, docs narrative pages, new visual features, pointer interactions, and performance benchmarks.
**Verification**: `julia --project=test test/runtests.jl` passes. The tests must fail if public surfaces render blank colorbuffers, full-tree and major-tree style produce identical colorbuffers for the reticulate style fixture, hidden layers delete stable children, or visible behavior is verified only by old helper values.

Use the existing `_plot_colorbuffer` behavior from `test/test_recipe.jl` or move it into `test/support/render_test_helpers.jl` under a public-render helper name. Keep colorbuffer checks deterministic by copying the buffer after each render. Do not add image snapshots to the repository in this tranche.

### 6. Run final gates and record remaining Tranche 5 residue

**Type**: TEST
**Output**: The repository is green for tests and docs, and the implementation report names the docs/source closeout residue that remains assigned to Tranche 5.
**Depends on**: 1, 2, 3, 4, and 5
**Positive contract**: `julia --project=test test/runtests.jl` passes, `julia --project=docs docs/make.jl` passes, and final source audits show Tranche 4 tests no longer validate old scaffold names as target behavior.
**Negative contract**: Do not edit docs narrative to hide old-name residue; do not delete compatibility source to satisfy a broad audit; do not mark Tranche 5 complete from this tranche.
**Files**: no additional files may be touched for this task unless one of the final gates exposes a direct regression in a file already in scope for tasks 1 through 5.
**Out of scope**: docs narrative rewrite, source compatibility deletion, workflow status approval, commits, branch operations, and pointer interactions.
**Verification**: Run `julia --project=test test/runtests.jl`. Run `julia --project=docs docs/make.jl`. Run the Lock 3 and Lock 5 source-audit checks. The implementation report must state that docs pages such as `docs/src/render-verification.md`, `docs/src/public-api.md`, and `docs/src/extending-plots.md` may still contain old scaffold prose until Tranche 5.

After the code and tests are green, write the implementation report in the response or handoff notes. The report must list the migrated test files, the public update cases, the visual artifacts, the source audits, the final gate outputs, and the explicit Tranche 5 residue. Do not modify this tasking file's `workflow-status` field during execution.
