---
date-created: 2026-07-15T23:14:36-07:00
workflow-instrument: Tasking plan
workflow-status: Approved
workflow-agent-thread-id: codex/019f6986-d69b-72a1-b761-2c687c7b1335
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-05a
---

# Tasks for tranche 5a: Documentation migration and docs-facing audits

This tasking file covers Tranche 5a of `reactive-makie-spine`, titled "Documentation migration and docs-facing audits" in the tranche plan after the Tranche 5 split. Tranche 5a executes the first four tasks from the prior Tranche 5 tasking draft: public API documentation migration, render verification documentation migration, extension documentation migration, and docs-facing architecture audits.

Tranche 5b is intentionally not tasked here. A new agent will write the Tranche 5b tasking after Tranche 5a completes. Tranche 5b owns source compatibility review, final lock-item evidence, and project-owner or assigned-reviewer acceptance.

Repository revalidation before the first Tranche 5 tasking draft was written found the required begin-green state:

```text
Test Summary: | Pass  Total     Time
PhyloMakie.jl | 1270   1270  2m02.3s
```

The docs build also completed successfully. Documenter emitted non-fatal warnings that 17 large HTML example representations on `annotations.md`, `edge-controls.md`, `extending-plots.md`, `public-api.md`, and `render-verification.md` used available image fallbacks, and that deployment environment auto-detection was skipped.

The accepted runtime path at this point is graph-driven. `Makie.plot!(plot::PhyloPlot)` in `src/recipe.jl` calls `validate_public_plot_limits`, `register_phylo_graph!`, and `create_phylo_primitives!`, then returns `plot`. `register_phylo_graph!` in `src/reactive_graph.jl` registers graph output nodes for primitive payloads, text payloads, and `Makie.data_limits`. `create_phylo_primitives!` in `src/primitive_assembly.jl` creates stable `Makie.LineSegments`, `Makie.Poly`, and `Makie.Text` child primitives from those graph nodes.

Current red-state residue for Tranche 5a is in user-facing documentation and docs-facing audit coverage:

- `docs/src/public-api.md:14` describes a `PhyloPlotAttributes` payload and helper/render owners as current internals.
- `docs/src/public-api.md` says legacy public spellings such as `showtiplabel` and `xlim` are rejected at the recipe boundary, even though those names are part of the supported public attribute surface. `preorder` remains internal and must not be documented as a public keyword.
- `docs/src/render-verification.md:87-110` obtains `resolve_phylo_plot_attributes`, `prepare_plot_layout`, and `render_plot!` through `getfield`, calls them in example helpers, and treats `layers` as the current proof object.
- `docs/src/render-verification.md:189` describes `PlotLayout.annotations` and `PlotBounds` as current verification details.
- `docs/src/extending-plots.md:102-110` recommends `prepare_plot_layout`, `resolve_phylo_plot_attributes`, and `PlotLayout` as the way to perform coordinate lookup.
- `src/attribute_schema.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`, and `src/render_adapter.jl` still contain transitional compatibility names. Tranche 5a records that residue for handoff only. Tranche 5b owns the human review decision for those source names.

## Settled user decisions and environment baseline

- Public plotting entry points and public attributes remain protected: `Makie.plot`, `Makie.plot!`, `phyloplot`, `phyloplot!`, `PhyloPlot`, and the current keyword surface must keep working.
- The dynamic public entrypoint is `Makie.update!`. Documentation examples that show runtime updates must use `Makie.update!(plot; ...)`.
- The plotted-network update keyword is `arg1`. Documentation and tests must use `Makie.update!(plot; arg1 = new_net)` when updating the `HybridNetwork` argument after a plot exists.
- `showtiplabel`, `shownodelabel`, `showedgelabel`, `showgamma`, `xlim`, and `ylim` are supported public attributes. Documentation must not call them rejected legacy spellings.
- `preorder` remains an internal network-preparation choice. Documentation must not present it as part of the public plotting API.
- `Makie.plot!(plot::PhyloPlot)` in `src/recipe.jl` is the Makie-native public plot owner for recipe assembly. It owns validation, graph registration, primitive creation, and return of `plot`; its consumers are Makie dispatch and public plotting calls. The previous broad rebuild path is the bypass path that must stay absent from accepted runtime proof. The verification artifacts are runtime tests and source audits from Tranche 4 plus final gates in this tranche.
- `register_phylo_graph!` in `src/reactive_graph.jl` owns the reactive graph layer for `PhyloPlot`. It registers named graph outputs consumed by `create_phylo_primitives!`, `Makie.data_limits`, and tests. The bypass path is dereferencing graph nodes into snapshots before primitive creation. The verification artifacts are public update tests, child primitive value tests, and source audits that forbid snapshot-driven primitive calls in the accepted path.
- `create_phylo_primitives!` in `src/primitive_assembly.jl` owns stable child primitive creation from graph output nodes. Its consumers are `Makie.plot!(plot::PhyloPlot)` and public plots. The bypass paths are child deletion/recreation for normal updates and old `render_plot!` helper rendering. The verification artifacts are stable-child tests, render colorbuffer tests, and source audits from Tranche 4.
- `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, and `compute_primitive_channels` are the current computation-layer functions. Documentation may name them only as internal implementation details or internal examples, not as stable public API.
- Hybrid arrowheads are represented as computed mesh geometry consumed by one stable `Makie.Poly` child. Documentation must not describe current arrowheads as per-edge `Makie.arrows2d!` children.
- Hidden layers are represented by typed empty graph outputs consumed by stable child primitives. Documentation must not describe hiding as child primitive deletion.
- Public plotting remains caller-safe for `PhyloNetworks.HybridNetwork`: public plotting and `Makie.update!(plot; arg1 = new_net)` must prepare private network copies and leave caller-owned networks unchanged.
- Pointer interactions are out of scope. Documentation and docs-facing audits must not imply implemented hover, click, drag, selection, or DataInspector behavior.
- Tranche 5a may edit docs pages, docs examples, docs-facing architecture audits, and the test runner only if needed for an audit include. It may not redesign runtime architecture, change public attributes, add dependencies, implement pointer interactions, review source compatibility deletion, or mark the overall closeout complete.
- Source compatibility review is deferred to Tranche 5b. `src/attribute_schema.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`, and `src/render_adapter.jl` must not be deleted, rewritten, or removed from includes in Tranche 5a.
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

The bundled development-policy depot was consulted. In this installation no separate bundled `references/` directory was present beside the development-policies skill. Project-local governance files are therefore the active authorities for this tasking run.

Read-only git and shell commands may be used for diagnosis. Mutating git operations such as commit, merge, push, rebase, reset, checkout for branch changes, and branch creation remain the human project maintainer's responsibility unless the user explicitly instructs otherwise.

Controlled vocabulary constraints:

- Use `HybridNetwork`, `Makie-native public plot owner`, `public attribute surface`, `full-tree style`, `major-tree style`, `major hybrid edge`, and `minor hybrid edge` as defined in `STYLE-vocabulary.md`.
- Use `tranche`, `lock item`, `red-state repro`, `handoff packet`, `upstream primary source`, `verification artifact`, and `stop condition` as defined in `STYLE-workflow-vocabulary.md`.
- Use `tip`, not `leaf`, when referring to plotted tree or network tips.
- Treat `render_plot!`, `PhyloPlotAttributes`, `resolve_phylo_plot_attributes`, `with_phylo_plot_limits`, `PlotGeometry`, `layout_plot_geometry`, `PlotBounds`, `PlotAnnotationData`, `PlotLayout`, `prepare_plot_layout`, `SegmentRenderLayer`, `ArrowTipRenderLayer`, `TextRenderLayer`, and `PlotRenderLayers` as old scaffold names. In Tranche 5a docs and examples they may appear only as historical red-state references, migration notes, or explicit deferred-to-5b source-compatibility evidence.
- Apply `STYLE-agent-language.md` to every responsibility statement. When a task says a function, file, or type owns behavior, it must name the exact function, file, public surface, external contract, consumers, duplicate or bypass path, and verification artifact.
- Do not use broad shorthand such as owner, wrapper, layer, contract, source, or boundary without naming the concrete code entity and the behavior it is responsible for.

Required upstream primary sources for this tranche:

- `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`, especially the explanation that dereferencing compute nodes in a recipe produces snapshots and that reactive primitive calls must consume compute graph nodes.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`, especially `ComputePipeline.update!(plot::Plot; args...)`, `data_limits(plot::Plot)`, the warning against storing `Observable`s in plot attributes, plot `register_computation!`, and plot `map!`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`, especially `FigureAxisPlot`, `figurelike_return`, `figurelike_return!`, `_create_plot`, and `plot!(ax::AbstractAxis, plot::AbstractPlot)`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`, especially the `LineSegments`, `Text`, and `Poly` recipe attribute contracts.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`, especially same-transaction text and position update behavior and the error path for mismatched text blocks and positions.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`, especially vector-of-polygon `convert_arguments` and `poly!` conversion to mesh outputs.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`, especially `ComputeGraph`, `update!`, `register_computation!`, and `map!`.

## Primary-goal lock

### Lock 1: Public API docs match current public behavior

- The work is not complete if `docs/src/public-api.md` omits `Makie.update!`, describes `PhyloPlotAttributes` or helper/render owners as current accepted architecture, or says supported public attributes such as `showtiplabel` and `xlim` are rejected legacy spellings.
- Direct red-state repro: `docs/src/public-api.md:14` currently describes `PhyloPlotAttributes`; the page also conflates supported public attributes with rejected internal spellings.
- Tasks that close it: 1 and 4.
- Verification artifact: `docs/src/public-api.md` documents current public plotting surfaces, supported public attributes, `Makie.update!(plot; ...)`, `Makie.update!(plot; arg1 = new_net)`, and caller-safe `HybridNetwork` preparation. `julia --project=docs docs/make.jl` runs green. A docs source audit rejects old scaffold names on this page except in a historical red-state explanation if one is intentionally kept.

### Lock 2: Render verification docs use live public or current architecture proof

- The work is not complete if `docs/src/render-verification.md` calls `render_plot!`, `prepare_plot_layout`, `resolve_phylo_plot_attributes`, or treats `PlotRenderLayers` as the current render proof object.
- Direct red-state repro: `docs/src/render-verification.md:87-110` calls the old helper stack, and `docs/src/render-verification.md:189` names `PlotLayout.annotations` and `PlotBounds` as current verification details.
- Tasks that close it: 2 and 4.
- Verification artifact: render verification examples build from public plotting calls, current computation-layer functions, current graph outputs, child primitive values, or CairoMakie colorbuffers. They do not rely on `render_plot!`, `PlotRenderLayers`, or old layout wrappers. The docs build and public render contract tests stay green.

### Lock 3: Extension docs stop recommending old internal layout wrappers

- The work is not complete if `docs/src/extending-plots.md` recommends `prepare_plot_layout`, `resolve_phylo_plot_attributes`, or `PlotLayout` as the accepted way to obtain coordinates or extend plots.
- Direct red-state repro: `docs/src/extending-plots.md:102-110` currently recommends the old internal helpers for coordinate lookup.
- Tasks that close it: 3 and 4.
- Verification artifact: extension docs state the current extension boundary directly. If they need an internal coordinate example, they use current computation-layer names and clearly mark the example as internal and unstable. They must not introduce a new public layout-query API without project-owner approval.

### Lock 4: Docs and examples purge old scaffold names as accepted architecture

- The work is not complete if docs pages, README, or examples describe `render_plot!`, `PhyloPlotAttributes`, `PlotLayout`, `PlotRenderLayers`, or related old scaffold names as accepted architecture rather than historical residue.
- Direct red-state repro: current old-name hits are in `docs/src/public-api.md`, `docs/src/render-verification.md`, and `docs/src/extending-plots.md`; no old-name hits were found in `README.md`, `examples`, `docs/src/index.md`, `docs/src/edge-controls.md`, or `docs/src/annotations.md` during tasking revalidation.
- Tasks that close it: 1, 2, 3, and 4.
- Verification artifact: a docs/source audit over `docs/src`, `README.md`, and `examples` rejects old scaffold names except for explicitly allowed historical red-state text. Historical workflow documents under `.workflow-docs` may keep old names as provenance and must not be included in this docs-facing audit.

### Lock 5: Docs-facing audits supplement runtime and render proof and hand off to 5b

- The work is not complete if docs-facing audits are absent, if docs-facing audits replace runtime or render proof, or if Tranche 5a claims final closeout without handing source compatibility review and reviewer acceptance to Tranche 5b.
- Direct red-state repro: Tranche 4 runtime and source audits pass, but docs pages still contain old scaffold language and the final source compatibility review has not occurred.
- Tasks that close it: 4.
- Verification artifact: `test/test_architecture_audits.jl` or equivalent tests include docs-facing audit checks, accepted runtime source checks remain scoped to current runtime files, and the Tranche 5a implementation report names Tranche 5b residual work: source compatibility review, final lock-item evidence, and project-owner or assigned-reviewer acceptance.

## Forbidden passing implementation table

| Lock item | Required behavior | Current code state | Resolved implementation instruction | Forbidden passing implementation | Failing verification artifact |
| --- | --- | --- | --- | --- | --- |
| Lock 1: public API docs match current public behavior | `docs/src/public-api.md` documents public plotting surfaces, supported attributes, `Makie.update!`, `arg1` network updates, and caller-safe `HybridNetwork` preparation. | The page names `PhyloPlotAttributes` and implies supported attributes such as `showtiplabel` and `xlim` are rejected legacy spellings. | Rewrite the page around `Makie.plot`, `Makie.plot!`, `phyloplot`, `phyloplot!`, `PhyloPlot`, supported public attributes, and `Makie.update!(plot; ...)`; describe `preorder` as internal only if it is mentioned. | Rename `PhyloPlotAttributes` prose to a vague "resolved attributes" phrase while still describing helper/render owners and omitting `Makie.update!`. | `rg -n "PhyloPlotAttributes|helper and render|showtiplabel.*rejected|xlim.*rejected|Makie.update!" docs/src/public-api.md` plus docs build and public update tests. |
| Lock 2: render verification docs use live public or current architecture proof | Render verification examples use public plotting, current computation-layer functions, current graph outputs, child primitive values, or colorbuffers. | `docs/src/render-verification.md` calls `resolve_phylo_plot_attributes`, `prepare_plot_layout`, and `render_plot!`, then inspects old `layers`. | Rewrite the render helpers and narrative to use public plots or current functions such as `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`, `compute_layout`, `compute_primitive_channels`, `register_phylo_graph!`, and child primitive values. | Replace old function names in prose but leave example code calling `render_plot!` through `getfield`, or switch to source-only assertions while dropping visual artifacts. | `rg -n "render_plot!|prepare_plot_layout|resolve_phylo_plot_attributes|PlotRenderLayers|PlotLayout|PlotBounds|layers\\." docs/src/render-verification.md` plus `julia --project=docs docs/make.jl` and public render tests. |
| Lock 3: extension docs stop recommending old internal layout wrappers | Extension docs state the actual extension boundary and avoid presenting old layout wrappers as current extension APIs. | `docs/src/extending-plots.md` recommends `prepare_plot_layout`, `resolve_phylo_plot_attributes`, and `PlotLayout` for coordinate lookup. | Rewrite the coordinate section to use public plotting patterns, existing public label controls, or a clearly internal current computation-layer example. Do not create a new public coordinate API. | Keep the old helper code in a "temporary" box without an explicit instability warning and without a review/removal path. | `rg -n "prepare_plot_layout|resolve_phylo_plot_attributes|PlotLayout|PlotBounds|PhyloPlotAttributes" docs/src/extending-plots.md` plus docs build. |
| Lock 4: docs and examples purge old scaffold names as accepted architecture | User-facing docs, README, and examples no longer describe old scaffold names as accepted architecture. | Old-name hits are confined to `docs/src/public-api.md`, `docs/src/render-verification.md`, and `docs/src/extending-plots.md` during tasking revalidation. | Add docs-facing source audits that scan `docs/src`, `README.md`, and `examples`; allow old names only in explicit historical red-state text if a task intentionally keeps such text. | Scan only tests or source files and declare docs clean, or scan `.workflow-docs` and force historical workflow records to change. | A docs audit in `test/test_architecture_audits.jl` fails on the current red-state docs and passes only after user-facing docs stop presenting old names as current. |
| Lock 5: docs-facing audits supplement runtime and render proof and hand off to 5b | Source audits catch docs regressions, while runtime and render tests keep proving behavior; 5a leaves source compatibility review and final acceptance to 5b. | Runtime tests and source audits pass, docs build passes, but docs-facing audit coverage and 5b handoff are not yet in place. | Extend architecture audits only where they supplement behavior proof; make the 5a implementation report name residual 5b tasking scope. | Add broad regex tests and delete behavior tests, or mark the full Tranche 5 closeout complete from 5a alone. | `julia --project=test test/runtests.jl`, `julia --project=docs docs/make.jl`, docs-facing audit checks, and a 5a handoff that names 5b residual work. |

## Handoff packet

- **Active authorities**: this tasking file after approval; `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`; Tranche 1 through 4 tasking files and implementation results; project-local governance files listed in the Governance section; local upstream primary sources listed above.
- **Parent documents**: `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/03-01_tranche-01--tasking-1.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/03-02_tranche-02--tasking-1.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`, and `.workflow-docs/202606192224_makie-reactivity-architecture/03-04_tranche-04--tasking-1.md`.
- **Settled decisions and non-negotiables**: preserve public entrypoints and attributes; document `Makie.update!` as the public dynamic entrypoint; preserve `arg1` for plotted-network updates; use current computation-layer, reactive graph layer, and primitive assembly names; do not document old scaffold names as current architecture; keep pointer interactions deferred; defer source compatibility review and final acceptance to Tranche 5b.
- **Authorization boundary**: docs pages, docs examples, and docs-facing source-audit tests may be edited. Runtime architecture redesign, public API changes, dependency changes, pointer interactions, broad source deletion, source compatibility review, final lock-item closeout, reviewer acceptance, and manifest edits are out of scope.
- **Current-state diagnosis**: accepted runtime and tests are green, but user-facing docs still present old scaffold names as current implementation details. Source compatibility wrappers remain in source and must be handed off to Tranche 5b for explicit review after Tranche 5a stops docs from depending on them.
- **Primary-goal lock**: lock items 1 through 5 in this file.
- **Direct red-state repros**: `docs/src/public-api.md:14`; `docs/src/render-verification.md:87-110`; `docs/src/render-verification.md:189`; `docs/src/extending-plots.md:102-110`; absence of docs-facing audit coverage for these red-state docs.
- **Responsible documentation entities and responsibilities**: `docs/src/public-api.md` documents public plotting surfaces, public attributes, update entrypoints, and caller-safety behavior for users; `docs/src/render-verification.md` documents visual/render proof using live public or current architecture surfaces; `docs/src/extending-plots.md` documents the extension boundary and must not recommend old internal wrappers; `test/test_architecture_audits.jl` may own docs-facing audits that supplement runtime tests without replacing them.
- **Responsible source entities relied on by docs**: `src/recipe.jl` owns public plot assembly through `Makie.plot!(plot::PhyloPlot)`; `src/reactive_graph.jl` owns graph output registration through `register_phylo_graph!`; `src/primitive_assembly.jl` owns stable child primitive creation through `create_phylo_primitives!`; `src/plot_config.jl`, `src/network_layout.jl`, `src/annotation_tables.jl`, and `src/primitive_channels.jl` own current computation-layer data. The old compatibility files are Tranche 5b review subjects, not Tranche 5a edit targets.
- **Supported public surfaces affected**: `plot(net)`, `plot!(axis, net)`, `phyloplot(net)`, `phyloplot!(axis, net)`, public attribute updates through `Makie.update!`, and recipe argument updates through `Makie.update!(plot; arg1 = new_net)`.
- **Exact files in scope for edits**: `docs/src/public-api.md`, `docs/src/render-verification.md`, `docs/src/extending-plots.md`, `test/test_architecture_audits.jl`, and `test/runtests.jl` only if an added architecture audit file is not already included by the test runner.
- **Exact files in scope for audit-only review**: `README.md`, `examples`, `docs/src/index.md`, `docs/src/edge-controls.md`, `docs/src/annotations.md`, `src/recipe.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, `src/primitive_channels.jl`, `src/plot_config.jl`, `src/network_layout.jl`, and `src/annotation_tables.jl`.
- **Exact files and surfaces out of scope for implementation edits**: dependency manifests, public attribute names, public plotting entrypoint names, pointer interaction code, non-`HybridNetwork` plotting support, external public API redesign, performance benchmarking, CI configuration, source compatibility deletion, source compatibility review, final closeout packet, and project-owner acceptance.
- **Required upstream primary sources**: all Makie and ComputePipeline files listed in the Governance section, plus the project Makie interactivity tutorial.
- **Green-state gates**: targeted docs builds or doctest checks after docs tasks where practical; targeted tests for architecture audits after task 4; final `julia --project=test test/runtests.jl`; final `julia --project=docs docs/make.jl`; a Tranche 5a implementation report that names Tranche 5b residual work.
- **Stop conditions**: stop if a public behavior change appears necessary; stop if docs require a new public layout-query API; stop if source compatibility deletion or review appears necessary before 5b; stop if pointer interaction claims or implementation appear necessary; stop if upstream Makie or ComputePipeline behavior contradicts the planned docs; stop if tests or docs are red for reasons outside the touched scope.

## Required revalidation before implementation

- Read this tasking file, the parent tranche file, the parent PRD, the codeplan, and Tranche 1 through 4 tasking files in full.
- Read the governance documents listed above line by line, especially `STYLE-agent-language.md`, before using ownership, contract, boundary, layer, invariant, compatibility, verification, source, or responsibility language.
- Run or inspect the current baseline before edits. If `julia --project=test test/runtests.jl` is red before implementation, record the failure and stop unless the project maintainer authorizes proceeding from a red baseline.
- Run or inspect `julia --project=docs docs/make.jl` before edits. If docs are red before implementation, record the failure and stop unless the maintainer authorizes proceeding.
- Re-run an old-name audit over `docs/src`, `README.md`, and `examples` before editing, because docs may have changed after this tasking file was written.
- Re-read `docs/src/public-api.md`, `docs/src/render-verification.md`, `docs/src/extending-plots.md`, `docs/src/index.md`, `docs/src/edge-controls.md`, and `docs/src/annotations.md`.
- Re-read `test/test_architecture_audits.jl` and `test/runtests.jl` before editing tests.
- Re-read `src/recipe.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, `src/primitive_channels.jl`, `src/plot_config.jl`, `src/network_layout.jl`, and `src/annotation_tables.jl` where docs or docs-facing audits rely on current implementation details.
- Re-read the required upstream primary sources where they constrain the task being executed.
- If current code or docs no longer match the diagnosis in this tasking file, stop and raise that before changing files.

## Tranche execution rule

Tranche 5a is a documentation migration and docs-facing audit tranche. It may rewrite docs pages and examples to match the accepted runtime architecture and add or refine architecture audits that supplement runtime and render proof.

Tranche 5a must not implement pointer interactions, create a new public layout-query API, rename public plotting entrypoints, change public attributes, add dependencies, edit manifests, review source compatibility deletion, delete source compatibility wrappers, produce the final closeout packet, or mark Tranche 5 complete. Those source compatibility and final acceptance responsibilities belong to Tranche 5b.

## Non-negotiable execution rules

- Do not document `render_plot!`, `PhyloPlotAttributes`, `PlotLayout`, `PlotRenderLayers`, or related old scaffold names as current accepted architecture.
- Do not leave docs examples calling old scaffold functions through `getfield`.
- Do not replace runtime, public surface, or render tests with source-text audits.
- Do not scan `.workflow-docs` in docs-facing old-name audits; historical workflow records are allowed to preserve old names as provenance.
- Do not add broad source audits that force deletion of transitional compatibility source before Tranche 5b review.
- Do not change public behavior to make documentation easier to write.
- Do not introduce a public coordinate lookup API without project-owner approval.
- Do not implement or document hover, click, drag, selection, or DataInspector behavior as available.
- Do not edit CI configuration or dependency manifests.
- Do not use docs build success alone as proof that user-facing docs describe the accepted architecture.

## Concrete anti-patterns or removal targets

- `docs/src/public-api.md` describing `PhyloPlotAttributes` as the current resolved payload.
- `docs/src/public-api.md` saying `showtiplabel` or `xlim` are rejected legacy spellings.
- `docs/src/render-verification.md` helper code that calls `resolve_phylo_plot_attributes`, `prepare_plot_layout`, or `render_plot!`.
- `docs/src/render-verification.md` prose that presents `PlotLayout.annotations`, `PlotBounds`, or `PlotRenderLayers` as current verification entities.
- `docs/src/extending-plots.md` recommending `prepare_plot_layout`, `resolve_phylo_plot_attributes`, or `PlotLayout` for coordinate lookup.
- Any docs/example code that obtains old internal helpers through `getfield(PhyloMakie, ...)`.
- Any source audit that scans all source and demands deleting compatibility wrappers before Tranche 5b review.
- Any documentation that implies pointer interactions are part of `reactive-makie-spine`.

## Failure-oriented verification

- A fake docs cleanup that renames old scaffold names in prose but leaves example code calling `render_plot!` must fail a docs source audit.
- A fake docs cleanup that removes all old names but omits `Makie.update!` and `arg1` update examples must fail Lock 1 review.
- A fake render verification rewrite that uses only source-text assertions and drops live render artifacts must fail Lock 2 review and existing public render tests.
- A fake extension docs rewrite that introduces an unsupported public coordinate lookup API must fail Lock 3 review.
- A fake source-audit closeout that scans `.workflow-docs` and edits historical workflow records must fail Lock 4 review.
- A fake Tranche 5a report that claims source compatibility review, final lock-item evidence, or project-owner acceptance is complete must fail Lock 5 review.

## Task 1: Rewrite public API docs around current public behavior

- **Type**: MIGRATE.
- **Output**: `docs/src/public-api.md` describes current public plotting surfaces, supported attributes, `Makie.update!`, `arg1` network updates, and caller-safe `HybridNetwork` preparation.
- **Depends on**: none.
- **Primary lock items**: 1 and 4.
- **Files**: `docs/src/public-api.md`.
- **Required context**: read `docs/src/public-api.md`, `src/recipe_declaration.jl`, `src/recipe.jl`, `src/reactive_graph.jl`, `src/plot_config.jl`, Tranche 4 tasking, and the Makie upstream sources for `Makie.update!`, `FigureAxisPlot`, and mutating/non-mutating plot return behavior.
- **Positive contract**: `docs/src/public-api.md` documents public plotting surfaces, supported attributes, `Makie.update!(plot; ...)`, `Makie.update!(plot; arg1 = new_net)`, caller-safe `HybridNetwork` preparation, and `preorder` as internal if mentioned.
- **Negative contract**: current-architecture prose must not name `PhyloPlotAttributes`, `resolve_phylo_plot_attributes`, `with_phylo_plot_limits`, `PlotLayout`, `PlotRenderLayers`, `render_plot!`, helper/render owner phrasing, or direct public graph input mutation as user-facing update behavior.
- **Out of scope**: source API changes, new public attributes, source compatibility review, source compatibility deletion, docs pages other than `docs/src/public-api.md`.
- **Verification**: run `julia --project=docs docs/make.jl` or a targeted docs command if available; run `rg -n "PhyloPlotAttributes|resolve_phylo_plot_attributes|with_phylo_plot_limits|PlotLayout|PlotRenderLayers|render_plot!|showtiplabel.*rejected|xlim.*rejected" docs/src/public-api.md` and expect no current-architecture hits.

Rewrite the public API page so it documents `plot(net)`, `plot!(axis, net)`, `phyloplot(net)`, `phyloplot!(axis, net)`, `PhyloPlot`, supported public attributes, `Makie.update!(plot; ...)`, and `Makie.update!(plot; arg1 = new_net)`. Explain caller-safe `HybridNetwork` preparation without implying users must call `directedges!` or `preorder!`. Remove current-architecture prose that names `PhyloPlotAttributes` or helper/render owners. Correct any claim that `showtiplabel`, `shownodelabel`, `showedgelabel`, `showgamma`, `xlim`, or `ylim` are rejected legacy spellings. Stop if the page needs a public API that does not exist, or if documenting current behavior appears to require changing source code.

## Task 2: Rebuild render verification docs on live public and current architecture evidence

- **Type**: MIGRATE.
- **Output**: `docs/src/render-verification.md` builds live render-verification examples from public plotting calls, current computation-layer functions, current graph outputs, child primitive values, or CairoMakie colorbuffers.
- **Depends on**: task 1.
- **Primary lock items**: 2 and 4.
- **Files**: `docs/src/render-verification.md`.
- **Required context**: read `docs/src/render-verification.md`, `test/test_public_render_contracts.jl`, `test/test_primitive_assembly.jl`, `test/test_reactive_graph.jl`, `src/recipe.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, `src/primitive_channels.jl`, `src/plot_config.jl`, `src/network_layout.jl`, `src/annotation_tables.jl`, and Makie upstream sources for `LineSegments`, `Poly`, `Text`, and `data_limits`.
- **Positive contract**: render verification examples use public plotting calls, current computation-layer functions, graph output values, child primitive values, CairoMakie colorbuffers, or a combination of those current surfaces, and keep evidence for full-tree style, major-tree style, colors, widths, text, explicit limits, and hidden layers.
- **Negative contract**: docs must not call `render_plot!`, `prepare_plot_layout`, or `resolve_phylo_plot_attributes`; docs must not present `PlotLayout`, `PlotBounds`, `PlotRenderLayers`, `layers.*`, `SegmentRenderLayer`, `ArrowTipRenderLayer`, or `TextRenderLayer` as current verification entities.
- **Out of scope**: runtime hooks, source compatibility review, source compatibility deletion, public API changes, docs pages other than `docs/src/render-verification.md`.
- **Verification**: run `julia --project=docs docs/make.jl`; run `rg -n "render_plot!|prepare_plot_layout|resolve_phylo_plot_attributes|PlotRenderLayers|SegmentRenderLayer|ArrowTipRenderLayer|TextRenderLayer|PlotLayout|PlotBounds|layers\\." docs/src/render-verification.md` and expect no current-architecture hits. Run or cite the existing public render contract tests that prove the rendered behavior remains live.

Replace helper code and prose that use the old scaffold names. Render verification examples must use public plotting calls, current computation-layer functions, graph output values, child primitive values, CairoMakie colorbuffers, or a combination of those current surfaces. Keep the page focused on live artifacts that a user or reviewer can connect to rendered behavior. Stop if the page cannot produce live render evidence without using old scaffold functions, or if it needs a new runtime hook that Tranche 5a is not authorized to add.

## Task 3: Replace extension docs that recommend old layout wrappers

- **Type**: MIGRATE.
- **Output**: `docs/src/extending-plots.md` states the current extension boundary without recommending old internal layout wrappers or promising a stable public coordinate lookup API.
- **Depends on**: task 1.
- **Primary lock items**: 3 and 4.
- **Files**: `docs/src/extending-plots.md`.
- **Required context**: read `docs/src/extending-plots.md`, `docs/src/annotations.md`, current public API docs after Task 1 if already edited, `src/plot_config.jl`, `src/network_layout.jl`, `src/annotation_tables.jl`, `src/primitive_channels.jl`, and the codeplan sections about public API preservation and old scaffold names.
- **Positive contract**: extension docs state the current extension boundary, prefer public plotting surfaces and public label/style attributes, and clearly mark any current computation-layer example as internal and unstable.
- **Negative contract**: docs must not recommend `prepare_plot_layout`, `resolve_phylo_plot_attributes`, `PhyloPlotAttributes`, `PlotLayout`, `PlotBounds`, or `PlotAnnotationData` as current extension APIs; docs must not promise a stable public coordinate lookup API.
- **Out of scope**: new public coordinate APIs, source changes, source compatibility review, source compatibility deletion, docs pages other than `docs/src/extending-plots.md`.
- **Verification**: run `julia --project=docs docs/make.jl`; run `rg -n "prepare_plot_layout|resolve_phylo_plot_attributes|PhyloPlotAttributes|PlotLayout|PlotBounds|PlotAnnotationData" docs/src/extending-plots.md` and expect no current-architecture hits.

Remove the recommendation to use `prepare_plot_layout`, `resolve_phylo_plot_attributes`, and `PlotLayout` for coordinate lookup. Replace it with a clear extension boundary: users can use public plotting surfaces and public label/style attributes; advanced internal experiments may inspect current computation-layer functions only with an explicit instability warning; no stable public coordinate lookup API is promised by this tranche. Stop if the desired extension docs require a new public API or if the page cannot be made accurate without source changes outside Tranche 5a scope.

## Task 4: Add docs-facing architecture audits

- **Type**: TEST.
- **Output**: docs-facing architecture audits reject old scaffold names as current architecture in `docs/src`, `README.md`, and `examples`, while preserving runtime and render tests as the behavioral verification artifacts.
- **Depends on**: tasks 1, 2, and 3.
- **Primary lock items**: 1, 2, 3, 4, and 5.
- **Files**: `test/test_architecture_audits.jl`; `test/runtests.jl` only if a new audit file is required and not already included.
- **Required context**: read `test/test_architecture_audits.jl`, `test/runtests.jl`, all edited docs from Tasks 1 through 3, `README.md`, `examples`, and Tranche 4 architecture audit rules.
- **Positive contract**: architecture audits scan `docs/src`, `README.md`, and `examples` for old scaffold names as current architecture; require `docs/src/public-api.md` to mention `Makie.update!`; reject docs examples obtaining old helpers through `getfield`.
- **Negative contract**: audits must not scan `.workflow-docs`, force source compatibility deletion, replace public render tests, scan CI/YAML, or move product behavior into string-policing tests.
- **Out of scope**: source compatibility review, source compatibility deletion, final closeout packet, project-owner acceptance, runtime architecture changes.
- **Verification**: run the targeted architecture audit tests if possible, then run `julia --project=test test/runtests.jl`. Run `julia --project=docs docs/make.jl` after docs changes. Confirm the docs-facing audit would have failed on the red-state strings named in this tasking file.

Add or refine audits that scan user-facing docs and examples for old scaffold names. The audit should cover `docs/src`, `README.md`, and `examples`. It must not scan `.workflow-docs` because workflow docs preserve historical red-state evidence. It must allow a narrow historical exception only when the text explicitly says an old name is historical, transitional, or forbidden, and the exception is listed in the audit with the exact file and reason. The Tranche 5a implementation report must name residual Tranche 5b scope: source compatibility review, final lock-item evidence, and project-owner or assigned-reviewer acceptance. Stop if the audit would require editing historical workflow records, deleting source compatibility wrappers, or weakening runtime tests.
