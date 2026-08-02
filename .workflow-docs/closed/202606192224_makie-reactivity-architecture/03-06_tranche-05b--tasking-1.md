---
date-created: 2026-07-16T03:00:16-07:00
workflow-instrument: Tasking plan
workflow-status: Approved
workflow-agent-thread-id: codex/019f69d6-fd0d-7400-a103-d31e3e7d34f2
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-05b
---

# Tasks for tranche 5b: source compatibility review and final closeout

This tasking file covers Tranche 5b of `reactive-makie-spine`, titled
"Source compatibility review and final closeout" in the approved tranche plan.
It consumes the completed Tranche 5a implementation report and converts the
remaining HITL decisions into concrete implementation instructions.

This file is saved with `workflow-status: Approved` because the user in the
Codex thread approved checkpoints C1 through C5 before this file was written.
The implementation agent must treat those checkpoints as settled decisions and
must not reopen them as implementation choices.

## Settled human decisions

The user in the Codex thread approved the following decisions on 2026-07-16:

- **C1**: Delete `src/attribute_schema.jl`, `src/layout_engine.jl`,
  `src/plot_layout.jl`, and `src/render_adapter.jl`.
- **C2**: Remove the include lines for those 4 files from `src/PhyloMakie.jl`.
- **C3**: Treat old unexported source names such as `render_plot!`,
  `PhyloPlotAttributes`, `PlotGeometry`, `PlotBounds`,
  `PlotAnnotationData`, `PlotLayout`, `PlotRenderLayers`,
  `SegmentRenderLayer`, `ArrowTipRenderLayer`, `TextRenderLayer`,
  `resolve_phylo_plot_attributes`, `with_phylo_plot_limits`,
  `layout_plot_geometry`, and `prepare_plot_layout` as unsupported internal
  names with no deprecation period.
- **C4**: Update the sibling workspace example
  `../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`
  to use `phyloplot!` and remove the internal `preorder = false` diagnostic.
- **C5**: Treat this thread's approval from the user as the human closeout
  decision for `reactive-makie-spine`, but only if the implementation agent
  completes the authorized 5b work and records all required passing artifacts
  in the final implementation report.

The implementation agent must not mark Tranche 5b or `reactive-makie-spine`
complete if any C5 condition fails. It must report the failed condition instead.

## Governance and required reading

An implementation agent must read these governance documents line by line
before touching files:

- `CONTRIBUTING.md`.
- `STYLE-agent-handoffs.md`.
- `STYLE-agent-language.md`.
- `STYLE-architecture.md`.
- `STYLE-docs.md`.
- `STYLE-git.md`.
- `STYLE-julia.md`.
- `STYLE-makie.md`.
- `STYLE-upstream-contracts.md`.
- `STYLE-verification.md`.
- `STYLE-vocabulary.md`.
- `STYLE-workflow-docs.md`.
- `STYLE-workflow-vocabulary.md`.
- `STYLE-writing.md`.

`STYLE-agent-language.md` is mandatory for every responsibility statement in
implementation notes, review notes, and final reports. A statement that uses
ownership, contract, boundary, layer, invariant, compatibility, verification,
source, or responsibility language must name the exact code entity or external
contract, the behavior, the consumers, the duplicate or bypass paths that must
not keep the same responsibility, and the verification artifact.

The bundled development-policy skill was consulted during tasking. In this
installation no separate bundled `references/` directory was present beside the
development-policies skill. Project-local governance files are therefore the
active governance authorities for this tasking run.

## Parent documents and upstream primary sources

The implementation agent must read these workflow documents line by line:

- `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-01_tranche-01--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-02_tranche-02--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-04_tranche-04--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-05_tranche-05a--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/04-05_tranche-05a--implementation-report-1.md`.

The implementation agent must re-read these upstream primary sources where
they constrain final evidence:

- `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`.
- `../PhyloNetworks.jl/src/manipulateNet.jl`.

## Current-state diagnosis

The accepted runtime path is graph-driven. `Makie.plot!(plot::PhyloPlot)` in
`src/recipe.jl` validates public limits, calls `register_phylo_graph!`, calls
`create_phylo_primitives!`, and returns `plot`. `register_phylo_graph!` in
`src/reactive_graph.jl` registers graph outputs consumed by child primitives
and `Makie.data_limits`. `create_phylo_primitives!` in
`src/primitive_assembly.jl` creates stable `Makie.LineSegments`, `Makie.Poly`,
and `Makie.Text` child primitives from graph output nodes.

The remaining package source residue is confined to the old compatibility
files:

- `src/attribute_schema.jl` defines `PhyloPlotAttributes`,
  `resolve_phylo_plot_attributes`, and `with_phylo_plot_limits`, and adapts to
  `PhyloPlotConfig`.
- `src/layout_engine.jl` defines `PlotGeometry` and `layout_plot_geometry`,
  and adapts to `NetworkGeometry` and `compute_network_geometry`.
- `src/plot_layout.jl` defines `PlotBounds`, `PlotAnnotationData`,
  `PlotLayout`, and `prepare_plot_layout`, and adapts to `PlotExtent`,
  `AnnotationTables`, and `LayoutComputation`.
- `src/render_adapter.jl` defines `SegmentRenderLayer`, `ArrowTipRenderLayer`,
  `TextRenderLayer`, `PlotRenderLayers`, and `render_plot!`, and can still
  create old render-layer handles from current `PrimitiveChannels`.

Package docs, package tests, package README, and package examples no longer
depend on those old names as accepted architecture. Static inspection during
tasking found one sibling workspace example that still calls the old internals:
`../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`.

## Controlled vocabulary constraints

- Use `HybridNetwork`, `Makie-native public plot owner`,
  `public attribute surface`, `full-tree style`, `major-tree style`,
  `major hybrid edge`, and `minor hybrid edge` as defined in
  `STYLE-vocabulary.md`.
- Use `tranche`, `lock item`, `red-state repro`, `handoff packet`,
  `upstream primary source`, `verification artifact`, and `stop condition` as
  defined in `STYLE-workflow-vocabulary.md`.
- Treat `reactive graph layer` as workflow-local PRD language.
- Treat the old names listed in C3 as deleted unsupported internal names after
  this tranche completes.
- Do not use "project-owner acceptance" or "reviewer acceptance" without naming
  the concrete human approval condition. In this tasking, the concrete human
  approval condition is C5 above.

## Authorization boundary

The implementation agent is authorized to delete exactly these package files:

- `src/attribute_schema.jl`.
- `src/layout_engine.jl`.
- `src/plot_layout.jl`.
- `src/render_adapter.jl`.

The implementation agent is authorized to edit exactly these package files:

- `src/PhyloMakie.jl`.
- `test/test_PhyloMakie.jl`.
- `test/test_architecture_audits.jl`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/04-06_tranche-05b--implementation-report-1.md`.

The implementation agent is authorized to edit exactly this sibling workspace
file:

- `../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`.

No other implementation edits are authorized by this tasking. If another file
appears to require an edit, the implementation agent must stop and report the
exact file and reason instead of expanding scope.

Out of scope:

- Public plotting entrypoint changes.
- Public attribute renames.
- New public coordinate lookup APIs.
- New pointer interactions, including hover, click, drag, selection, or
  DataInspector behavior.
- Dependency or manifest edits.
- CI configuration edits.
- Performance benchmarking.
- Changelog creation or release-process repair.
- Edits to `.workflow-docs` other than the final Tranche 5b implementation
  report named above.

## Primary-goal lock

### Lock 1: Approved source compatibility files are deleted

- The work is not complete if `src/attribute_schema.jl`,
  `src/layout_engine.jl`, `src/plot_layout.jl`, or `src/render_adapter.jl`
  remain in the package source tree.
- Direct red-state repro: the current source tree contains those files, and
  `src/PhyloMakie.jl` includes them.
- Tasks that close it: 1.
- Verification artifact: `test/test_PhyloMakie.jl` asserts that the old names
  listed in C3 are not defined on `PhyloMakie` without spelling those names as
  contiguous source text; `rg` over `src` finds none of the old names listed in
  C3; `julia --project=test test/runtests.jl` passes.

### Lock 2: Old scaffold names are absent from accepted package surfaces

- The work is not complete if accepted package source, package tests, package
  docs, package README, or package examples contain old scaffold names as
  current architecture after deletion.
- Direct red-state repro: before Tranche 5b, `src/attribute_schema.jl`,
  `src/layout_engine.jl`, `src/plot_layout.jl`, and `src/render_adapter.jl`
  contain the old names listed in C3.
- Tasks that close it: 1 and 2.
- Verification artifact: `test/test_architecture_audits.jl` scans package
  source plus user-facing docs, README, and examples while excluding
  `.workflow-docs`, `00-archives`, governance files, and sibling repositories.
  The audit fails if an old scaffold name survives in accepted package
  surfaces.

### Lock 3: The sibling example uses public plotting

- The work is not complete if
  `../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`
  still calls `PhyloMakie.resolve_phylo_plot_attributes`,
  `PhyloMakie.prepare_plot_layout`, or `PhyloMakie.render_plot!`.
- Direct red-state repro: the current sibling example calls all 3 old internal
  functions and manually prepares traversal state to exercise `preorder = false`.
- Tasks that close it: 3.
- Verification artifact: `rg -n "resolve_phylo_plot_attributes|prepare_plot_layout|render_plot!|layout_plot_geometry|PhyloPlotAttributes|PlotLayout|PlotRenderLayers" ../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`
  returns no matches, and the example runs with
  `julia --project=../phylonetworks-visualization-examples ../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`.

### Lock 4: Final evidence maps PRD lock items 1 through 10

- The work is not complete if the final implementation report omits any PRD
  lock item from 1 through 10 or uses a source-text audit as the only evidence
  for behavior that runtime, render, docs, or example artifacts already prove.
- Direct red-state repro: Tranche 5b currently has no final closeout report
  mapping lock items 1 through 10 to artifacts after source compatibility
  deletion.
- Tasks that close it: 4.
- Verification artifact:
  `.workflow-docs/202606192224_makie-reactivity-architecture/04-06_tranche-05b--implementation-report-1.md`
  contains a table with PRD lock items 1 through 10 and concrete verification
  artifacts for each item.

### Lock 5: Public behavior remains stable

- The work is not complete if deleting the compatibility files breaks public
  plotting, public attributes, `Makie.update!`, docs generation, or accepted
  render behavior.
- Direct red-state repro: public behavior is currently proven by package tests
  and docs after Tranche 5a; deletion could break include order or accidental
  dependencies if any current public path still depends on old files.
- Tasks that close it: 1, 2, 3, and 5.
- Verification artifact: `julia --project=test test/runtests.jl` passes;
  `julia --project=docs docs/make.jl` passes; the sibling example gate in
  Lock 3 passes.

### Lock 6: Human closeout condition is recorded without ambiguity

- The work is not complete if the final report says Tranche 5b is accepted
  without recording the exact C5 condition and the passing artifacts required
  by C5.
- Direct red-state repro: the tranche plan used generic "project-owner or
  assigned-reviewer acceptance" language. The user rejected that phrasing as
  insufficiently concrete and approved the C5 rephrase in this Codex thread.
- Tasks that close it: 4 and 5.
- Verification artifact: the final implementation report records that the user
  in the Codex thread approved C1 through C5 before implementation and states
  that completion is valid only because every C5 artifact passed.

## Forbidden passing implementation table

| Lock item | Required behavior | Current code state | Resolved implementation instruction | Forbidden passing implementation | Failing verification artifact |
| --- | --- | --- | --- | --- | --- |
| Lock 1: approved source compatibility files are deleted | The 4 old compatibility files approved in C1 are absent, and `src/PhyloMakie.jl` no longer includes them. | `src/attribute_schema.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`, and `src/render_adapter.jl` exist and are included from `src/PhyloMakie.jl`. | Delete those 4 files and remove exactly their include lines from `src/PhyloMakie.jl`. Do not replace them with renamed files or new compatibility adapters. | Leave the files in place but add comments saying they are unsupported, or keep `render_adapter.jl` because no package test currently calls it. | `rg` over `src` finds old names; `test/test_PhyloMakie.jl` finds old names defined on `PhyloMakie`; full tests fail if include order breaks. |
| Lock 2: old scaffold names are absent from accepted package surfaces | Accepted package source, tests, docs, README, and package examples do not contain old scaffold names as current architecture. | Old names are present in compatibility files and excluded from current docs-facing audits. | Strengthen architecture audits to scan accepted package source plus user-facing package surfaces after deleting the files. Exclude `.workflow-docs`, `00-archives`, governance files, and sibling repositories from this package audit. | Delete files but leave tests or docs with old names hidden behind direct `getfield` calls, or scan `.workflow-docs` and edit historical workflow records instead of accepted package surfaces. | `test/test_architecture_audits.jl` fails on old names in accepted package source, tests, docs, README, or examples. |
| Lock 3: the sibling example uses `phyloplot!` | The sibling example uses `phyloplot!` and does not call old internal helpers. | `../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl` calls `resolve_phylo_plot_attributes`, `prepare_plot_layout`, and `render_plot!`. | Rewrite that file to create the same network and edge-label data, create a `Figure` and `Axis`, and call `phyloplot!(axis, net; edgelabel = edge_labels)`. Remove the manual `directedges!`, `preorder!`, and `preorder = false` diagnostic path. | Leave the example unchanged and say sibling examples are out of package scope, or replace old calls with current internal computation functions while still bypassing public plotting. | `rg` over the sibling file finds old internal names; the sibling example command fails. |
| Lock 4: final evidence maps PRD lock items 1 through 10 | The final report names each PRD lock item and gives concrete runtime, render, docs, source-audit, or review evidence. | Tranche 5b has no final implementation report yet. | Create `04-06_tranche-05b--implementation-report-1.md` with a lock-item evidence table for PRD lock items 1 through 10. | Write a short closeout note that says the suite passed but does not map the PRD lock items or hides behavioral proof behind a source audit. | Review of the final report finds any missing PRD lock item or source-audit-only proof where runtime/render/docs proof exists. |
| Lock 5: public behavior remains stable | Public plotting and docs still pass after deletion and sibling example migration. | Current tests and docs pass after Tranche 5a, but compatibility deletion has not occurred. | Run full tests, docs build, the old-name audit, and the sibling example gate after edits. | Delete files and rely only on `git diff --check` or a source-text audit without running behavior gates. | `julia --project=test test/runtests.jl`, `julia --project=docs docs/make.jl`, or the sibling example command fails. |
| Lock 6: human closeout condition is recorded without ambiguity | The final report records C1 through C5 and states completion only after all C5 artifacts pass. | The tranche plan used generic human-acceptance language that the user rejected as insufficiently concrete. | Record the exact C1 through C5 decisions in the final report and state whether every C5 artifact passed. | Claim final closeout using vague "project-owner acceptance" or "reviewer acceptance" wording without naming the C5 condition. | Review of the final report fails if C5 and its artifacts are absent or ambiguous. |

## Required revalidation before implementation

- Run `git status --short` in `PhyloMakie.jl`. If the worktree is dirty,
  inspect the changes and do not overwrite unrelated user changes.
- Re-read the 4 source files approved for deletion before deleting them.
- Re-read `src/PhyloMakie.jl`, `test/test_PhyloMakie.jl`, and
  `test/test_architecture_audits.jl`.
- Re-read
  `../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`.
- Run or inspect a package old-name audit before edits:
  `rg -n "PhyloPlotAttributes|PlotGeometry|PlotBounds|PlotAnnotationData|PlotLayout|PlotRenderLayers|render_plot!|resolve_phylo_plot_attributes|with_phylo_plot_limits|layout_plot_geometry|prepare_plot_layout|SegmentRenderLayer|ArrowTipRenderLayer|TextRenderLayer|arrows2d!" src test docs/src README.md examples`.
- Run or inspect a sibling old-name audit before edits:
  `rg -n "resolve_phylo_plot_attributes|prepare_plot_layout|render_plot!|layout_plot_geometry|PhyloPlotAttributes|PlotLayout|PlotRenderLayers" ../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`.
- If current reality no longer matches this diagnosis, stop and report the
  exact mismatch. Do not choose a new compatibility policy.

## Task 1: Delete approved source compatibility files

- **Type**: MIGRATE.
- **Output**: the 4 approved source compatibility files are deleted and
  `src/PhyloMakie.jl` includes only current architecture files.
- **Depends on**: none.
- **Primary lock items**: 1, 2, and 5.
- **Files**: delete `src/attribute_schema.jl`, `src/layout_engine.jl`,
  `src/plot_layout.jl`, and `src/render_adapter.jl`; edit
  `src/PhyloMakie.jl`; edit `test/test_PhyloMakie.jl`.
- **Positive contract**: `src/PhyloMakie.jl` includes `plot_config.jl`,
  `network_layout.jl`, `annotation_tables.jl`, `primitive_channels.jl`,
  `recipe_declaration.jl`, `reactive_graph.jl`, `primitive_assembly.jl`, and
  `recipe.jl`. It does not include the deleted compatibility files.
  `test/test_PhyloMakie.jl` asserts that the old names listed in C3 are not
  defined on `PhyloMakie` by constructing each checked `Symbol` from string
  fragments, so the final old-name audit over `test` does not fail on the test
  source itself.
- **Negative contract**: do not leave compatibility files in place; do not add
  new adapter files with the old names; do not keep `render_plot!` or
  `arrows2d!` as an accepted package source path.
- **Out of scope**: public plotting entrypoint changes, public attribute
  changes, manifest edits, docs narrative rewrites, and unrelated source
  refactors.
- **Verification**: run
  `rg -n "PhyloPlotAttributes|PlotGeometry|PlotBounds|PlotAnnotationData|PlotLayout|PlotRenderLayers|render_plot!|resolve_phylo_plot_attributes|with_phylo_plot_limits|layout_plot_geometry|prepare_plot_layout|SegmentRenderLayer|ArrowTipRenderLayer|TextRenderLayer|arrows2d!" src`
  and expect no matches. Run `julia --project=test test/runtests.jl` after the
  test updates in Task 2.

Delete the approved compatibility files rather than retaining them with
comments. Remove exactly their include lines from `src/PhyloMakie.jl`. Extend
`test/test_PhyloMakie.jl` with negative `isdefined` checks for the old names
listed in C3 so the package module test fails if any old name returns. Build
the checked symbols from string fragments rather than contiguous old-name
strings.

## Task 2: Strengthen architecture audits after deletion

- **Type**: TEST.
- **Output**: architecture audits reject old scaffold names in accepted package
  source and user-facing package surfaces after deletion.
- **Depends on**: Task 1.
- **Primary lock items**: 2 and 5.
- **Files**: `test/test_architecture_audits.jl`.
- **Positive contract**: architecture audits scan `src`, `test`, `docs/src`,
  `README.md`, and package `examples` for old scaffold names listed in C3.
  They exclude `.workflow-docs`, `00-archives`, governance files such as
  `STYLE-agent-language.md`, generated docs build output, and sibling
  repositories.
- **Negative contract**: do not scan workflow provenance and then edit
  `.workflow-docs` to make a test pass; do not force changes to governance
  examples; do not use source-text audits as the only evidence for public
  behavior.
- **Out of scope**: docs prose rewrites, public behavior changes, manifest
  edits, and sibling repository audits beyond the exact file in Task 3.
- **Verification**: run `julia --project=test test/runtests.jl`. Confirm the
  strengthened audit would fail if one of the old names listed in C3 appears in
  `src`.

Refine `test/test_architecture_audits.jl` so it has a source-facing audit for
accepted package source after the compatibility files are deleted. Keep the
existing docs-facing audit from Tranche 5a. The audit may continue to build old
tokens by joining string fragments so the audit file does not fail itself.

## Task 3: Update sibling preorder example to public plotting

- **Type**: MIGRATE.
- **Output**:
  `../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`
  uses `phyloplot!` and contains no calls to old internal compatibility
  functions.
- **Depends on**: Task 1.
- **Primary lock items**: 3 and 5.
- **Files**:
  `../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`.
- **Positive contract**: the example still reads the same Newick string,
  constructs the same `DataFrame(num = [2, 6], annotate = [85.0001, 90])`,
  creates a `Figure` and `Axis`, hides decorations and spines, and calls
  `phyloplot!(axis, net; edgelabel = edge_labels)`. The example returns `fig`.
- **Negative contract**: the example must not call `PhyloNetworks.directedges!`,
  `PhyloNetworks.preorder!`, `PhyloMakie.resolve_phylo_plot_attributes`,
  `PhyloMakie.prepare_plot_layout`, `PhyloMakie.render_plot!`, or any current
  internal computation-layer function as a replacement for those old names.
- **Out of scope**: edits to other sibling examples, sibling manifests,
  generated sibling build artifacts, and reference image updates.
- **Verification**: run
  `rg -n "resolve_phylo_plot_attributes|prepare_plot_layout|render_plot!|layout_plot_geometry|PhyloPlotAttributes|PlotLayout|PlotRenderLayers" ../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`
  and expect no matches. Run
  `julia --project=../phylonetworks-visualization-examples ../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`.

Rewrite the sibling example around public plotting. Do not preserve the old
`preorder = false` diagnostic, because that diagnostic depends on the old
source compatibility API approved for deletion.

## Task 4: Write the final Tranche 5b implementation report

- **Type**: REVIEW.
- **Output**:
  `.workflow-docs/202606192224_makie-reactivity-architecture/04-06_tranche-05b--implementation-report-1.md`
  records source compatibility deletion, final lock-item evidence, and the C5
  human closeout condition.
- **Depends on**: Tasks 1, 2, and 3.
- **Primary lock items**: 4 and 6.
- **Files**:
  `.workflow-docs/202606192224_makie-reactivity-architecture/04-06_tranche-05b--implementation-report-1.md`.
- **Positive contract**: the report names the exact files deleted, the include
  lines removed, the sibling example file updated, every verification command
  run with pass/fail status, and PRD lock items 1 through 10 with concrete
  verification artifacts. The report records C1 through C5 and states that the
  human closeout decision is valid only because every C5 artifact passed.
- **Negative contract**: the report must not use vague "project-owner
  acceptance" or "reviewer acceptance" wording without naming C5. It must not
  mark closeout complete if any required command failed, was skipped, or could
  not run.
- **Out of scope**: changing the PRD, codeplan, tranche plan, old tasking
  files, or Tranche 5a implementation report.
- **Verification**: review the report manually against the required report
  fields and C5. Run `rg -n "project-owner acceptance|reviewer acceptance|assigned-reviewer acceptance" .workflow-docs/202606192224_makie-reactivity-architecture/04-06_tranche-05b--implementation-report-1.md`
  and expect no vague acceptance claim.

The final report must include this PRD lock-item evidence table:

| PRD lock item | Required evidence |
| --- | --- |
| 1: remove broad rebuild reactivity | Source audit over accepted runtime files plus stable-child tests in `test/test_primitive_assembly.jl`. |
| 2: use `Makie.update!` as the dynamic entrypoint | `Makie.update!` tests in `test/test_recipe.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, and `test/test_public_render_contracts.jl`. |
| 3: establish the computation layer | Computation tests in `test/test_plot_config.jl`, `test/test_network_layout.jl`, `test/test_annotation_tables.jl`, and `test/test_primitive_channels.jl`. |
| 4: establish the reactive graph layer | Graph-node and recomputation tests in `test/test_reactive_graph.jl`. |
| 5: pass output nodes to primitives | Primitive assembly tests in `test/test_primitive_assembly.jl` and source audit that `src/primitive_assembly.jl` passes graph nodes without dereferencing them into snapshots. |
| 6: model hybrid arrowheads as computed mesh geometry | `test/test_primitive_channels.jl`, `test/test_primitive_assembly.jl`, and source audit that accepted runtime source contains no `arrows2d!` path. |
| 7: preserve current public behavior | Full test suite, docs build, public render contract tests, and public API docs. |
| 8: purge old scaffold names and ownership | Source deletion evidence, architecture audits, and `rg` old-name audit over accepted package surfaces. |
| 9: defer pointer interactions honestly | Architecture audit for pointer-scope tokens and docs review that no hover, click, drag, selection, or DataInspector behavior is claimed. |
| 10: keep network traversal preparation caller-safe | `test/test_network_layout.jl`, `test/test_reactive_graph.jl`, and public plotting/update tests that preserve caller-owned `HybridNetwork` values. |

## Task 5: Run final gates and apply C5 completion rule

- **Type**: REVIEW.
- **Output**: final pass/fail status for Tranche 5b and
  `reactive-makie-spine` closeout.
- **Depends on**: Tasks 1, 2, 3, and 4.
- **Primary lock items**: 4, 5, and 6.
- **Files**: no additional files unless Task 4's report must be updated with
  final command output.
- **Positive contract**: all final gates pass, the final report records the
  passing artifacts, and the report states that the user-approved C5 human
  closeout condition is satisfied.
- **Negative contract**: do not mark Tranche 5b complete if any final gate
  fails, is skipped, or produces an unexplained warning that contradicts the
  expected architecture.
- **Out of scope**: adding new feature work, editing manifests, and creating
  follow-up implementation changes beyond the exact files authorized above.
- **Verification**: run every command listed in "Final green-state gates".

After all commands finish, update the final report with the command results.
If every C5 condition passed, record that Tranche 5b and
`reactive-makie-spine` are complete under the human approval from the user in
this Codex thread. If any condition failed, record the failed condition and do
not claim completion.

## Final green-state gates

Run these commands from `PhyloMakie.jl` unless the command names a sibling
project:

```sh
git status --short
git diff --check
rg -n "PhyloPlotAttributes|PlotGeometry|PlotBounds|PlotAnnotationData|PlotLayout|PlotRenderLayers|render_plot!|resolve_phylo_plot_attributes|with_phylo_plot_limits|layout_plot_geometry|prepare_plot_layout|SegmentRenderLayer|ArrowTipRenderLayer|TextRenderLayer|arrows2d!" src test docs/src README.md examples
rg -n "resolve_phylo_plot_attributes|prepare_plot_layout|render_plot!|layout_plot_geometry|PhyloPlotAttributes|PlotLayout|PlotRenderLayers" ../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl
julia --project=../phylonetworks-visualization-examples ../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl
julia --project=test test/runtests.jl
julia --project=docs docs/make.jl
```

The 2 `rg` commands are expected to return no matches. If either `rg` command
returns matches, the implementation agent must treat that as a failed gate.

Known acceptable docs-build warnings are the Documenter warnings already
recorded in Tranche 5a: large HTML example representations using image
fallbacks and deployment environment auto-detection skipped. Any new warning
that contradicts public API docs, render verification, source deletion, or
old-name cleanup must be reported as a failed gate unless the user approves an
exception.

## Handoff packet

- **Active authorities**: project-local governance files listed in this
  tasking; parent PRD, codeplan, tranche plan, Tranche 1 through 5a tasking
  files, and Tranche 5a implementation report.
- **Parent documents**: `01_prd.md`, `codeplan.md`, `02_tranches.md`,
  `03-01_tranche-01--tasking-1.md`,
  `03-02_tranche-02--tasking-1.md`,
  `03-03_tranche-03--tasking-1.md`,
  `03-04_tranche-04--tasking-1.md`,
  `03-05_tranche-05a--tasking-1.md`, and
  `04-05_tranche-05a--implementation-report-1.md`.
- **Settled decisions and non-negotiables**: C1 through C5 above; public
  plotting entrypoints and public attributes remain stable; pointer
  interactions remain out of scope; no deprecation period is required for old
  unexported internal names listed in C3.
- **Authorization boundary**: delete exactly the files approved in C1; edit
  exactly the files listed under the authorization boundary; stop on any
  required expansion.
- **Current-state diagnosis**: accepted runtime is graph-driven and user-facing
  docs are migrated; remaining old names are source compatibility residue and
  one sibling example use.
- **Primary-goal lock**: lock items 1 through 6 in this file.
- **Direct red-state repros**: old source files remain included; package source
  contains old scaffold names; sibling example calls old internals; final
  closeout lacks PRD lock-item evidence; vague human-acceptance language hides
  C5.
- **Responsible source entities relied on after deletion**:
  `src/plot_config.jl` owns public attribute normalization through
  `resolve_plot_config`; `src/network_layout.jl` owns private copied
  `HybridNetwork` preparation through `prepare_plot_network` and geometry
  calculation through `compute_network_geometry`; `src/annotation_tables.jl`
  owns layout and annotation table calculation through `compute_layout`;
  `src/primitive_channels.jl` owns primitive channel calculation through
  `compute_primitive_channels`; `src/reactive_graph.jl` owns graph output
  registration through `register_phylo_graph!`; `src/primitive_assembly.jl`
  owns stable child primitive creation through `create_phylo_primitives!`;
  `src/recipe.jl` owns Makie recipe assembly through
  `Makie.plot!(plot::PhyloPlot)`.
- **Exact files in scope**: the files listed in the authorization boundary.
- **Exact files out of scope**: all files not listed in the authorization
  boundary, including manifests, CI files, package docs pages, other sibling
  examples, `.workflow-docs` parent files, and generated build artifacts.
- **Required upstream primary sources**: the Makie, ComputePipeline, project
  tutorial, and PhyloNetworks files listed above.
- **Green-state gates**: all commands in "Final green-state gates".
- **Stop conditions**: stop if any approved deletion breaks a public behavior
  gate; stop if any old internal name is still required by accepted package
  code after deletion; stop if the sibling example cannot be expressed through
  public plotting; stop if a final report cannot map every PRD lock item 1
  through 10 to concrete evidence; stop if any C5 artifact fails.
