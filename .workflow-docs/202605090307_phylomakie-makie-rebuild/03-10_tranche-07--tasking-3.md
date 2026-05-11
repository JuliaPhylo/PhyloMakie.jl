---
date-created: 2026-05-10T21:45:08-07:00
date-updated: 2026-05-10T21:45:08-07:00
workflow-instrument: Tasking Plan
workflow-status: Proposed
workflow-agent-thread-id: codex/019e14c0-3381-75c1-8cc9-72a24a3dec20
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-prd: .workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md
workflow-tranche: .workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md
---

# Tasks for tranche 7 follow-on: burn away workflow verification scaffolding

## Approval state

- This file is a tranche-7 follow-on tasking plan for the accepted
  `202605090307_phylomakie-makie-rebuild` workflow.
- It does not reopen the PRD, the parent tranche plan, or the delivered
  Makie-native public architecture.
- It does override one earlier tranche-7 interpretation:
  where `02_tranches.md` or earlier tranche-7 tasking says to reuse
  verification scaffolding, the later user decision from 2026-05-10 controls.
  Runtime workflow-proof scaffolding is to be removed rather than preserved.
- No `REVIEW` task is authorized here. The user already made the material
  design decisions. The implementing agent is expected to execute them rather
  than reopen them.

## Settled user decisions and environment baseline

- Treat the following as fixed inputs:
  `design/prod01-vision.md`,
  `design/prod01-vision-supplement.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-08_tranche-07--tasking-1.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-09_tranche-07--tasking-2.md`,
  and
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`.
- Preserve the accepted Makie-native public plot owner and public surfaces:
  `plot(net)`, `plot!(ax, net)`, `phyloplot(net)`, and `phyloplot!(ax, net)`.
- Preserve the accepted public attribute surface and legacy rejection boundary
  in `src/public_attribute_model.jl`. Cleanup is not authorization to broaden
  the API, restore legacy names, or add new controls.
- Preserve the internal ownership split already accepted by the PRD:
  `PhyloPlotAttributes` remains the runtime attribute carrier,
  `PlotLayout` remains the layout/annotation carrier,
  and `render_plot!` remains the render owner.
- `VERIFICATION_FOUNDATION` is not accepted package runtime architecture after
  this follow-on. It is workflow/process scaffolding and must not survive in
  `src/`.
- The public plot object must not carry proof-only attached artifacts solely
  for docs or tests. Specifically, `resolved_attributes`, `resolved_layout`,
  and `render_layers` are to be removed from the returned public plot surface.
- `Makie.data_limits` remains part of the accepted Makie-facing behavior.
  This cleanup does not authorize weakening or bypassing that integration.
- Docs must adapt to the accepted API and accepted owners. Do not change the
  API merely to keep workflow metadata or internal proof artifacts alive.
- Package docs remain user-facing or maintainer-facing truth surfaces, but not
  workflow lock-item inventories. Delete workflow-proof pages rather than
  rephrasing them.
- Tests may continue to use `test/support/fixture_corpus.jl`. Docs may not
  include test support files during the docs build.
- Preserve the current environment split:
  root package env, `test/` env, `docs/` env, and `examples/` env remain
  separate.
- Preserve the current installation truth boundary:
  this repository may document GitHub-based installation and local development
  paths only. Do not claim General-registry installation.
- Preserve the current feature boundary:
  no new plotting capability, no R interoperability work, and no compatibility
  shell regrowth are authorized here.

## Governance

Read all applicable governance documents line by line before implementing any
task in this file.

All tasks must comply with:

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
- `design/prod01-vision.md`
- `design/prod01-vision-supplement.md`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-08_tranche-07--tasking-1.md`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-09_tranche-07--tasking-2.md`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`

Missing expected repo-local governance files at tasking time:

- `STYLE-python.md`
- `STYLE-domain-vocabulary.md`

Authority notes that remain active in this follow-on:

- `STYLE-vocabulary.md` remains authoritative for terms such as
  `Makie-native public plot owner`, `public attribute surface`,
  `legacy rejection boundary`, and `capability parity`.
- `STYLE-workflow-vocabulary.md` remains authoritative for terms such as
  `lock item`, `red-state repro`, `handoff packet`, and `verification artifact`.
- `STYLE-upstream-contracts.md` remains active because the public owner and
  docs still depend on Makie bang/non-bang host semantics and CairoMakie proof.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, rebase, branch creation, and reset remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Primary-goal lock

### Lock item 1: no runtime workflow owner

- The work is not complete if `PhyloMakie` still loads, defines, or relies on
  `VERIFICATION_FOUNDATION` from `src/`.
- The direct red-state repro is the current package shell:
  `src/PhyloMakie.jl` includes `verification_foundation.jl`,
  `src/verification_foundation.jl` contains workflow lock items, proof-owner
  filenames, docs-proof surfaces, and current-status prose, and
  `test/test_PhyloMakie.jl` currently treats that symbol as required runtime
  module structure.
- Task 2 closes this lock item.
- The verification artifact that must fail the old shape is:
  `!isdefined(PhyloMakie, :VERIFICATION_FOUNDATION)` in the shell smoke test,
  plus absence of `VERIFICATION_FOUNDATION` references in
  `src/PhyloMakie.jl`, `src/`, `docs/src/`, `README.md`, and `docs/make.jl`.

### Lock item 2: no workflow-metadata or test-support ownership of docs truth

- The work is not complete if package docs still read
  `getfield(PhyloMakie, :VERIFICATION_FOUNDATION)`, still include
  `test/support/fixture_corpus.jl`, or still present workflow proof inventory
  as the package-facing truth surface.
- The direct red-state repro is the current docs set:
  `docs/src/public-api.md`, `docs/src/migration-guide.md`, and
  `docs/src/render-verification.md` render tables from
  `VERIFICATION_FOUNDATION`, `docs/src/render-verification.md` includes the
  test fixture file during docs build, and `README.md`, `docs/src/index.md`,
  and `docs/make.jl` still route readers to `verification-foundation.md`.
- Task 1 closes the docs/data-source side of this lock item.
- Task 2 closes the deleted-page and deleted-nav side of this lock item.
- The verification artifact that must fail the old shape is:
  `julia --project=docs docs/make.jl` staying green after the metadata owner is
  removed, plus targeted absence checks for `VERIFICATION_FOUNDATION` and
  `fixture_corpus` in the package docs sources.

### Lock item 3: no source-shape or workflow-prose policing in tests

- The work is not complete if tests still parse the module source, enforce an
  exact include order, or reproduce `VERIFICATION_FOUNDATION` as prose-shape,
  tuple-shape, or docs-heading policing.
- The direct red-state repro is the current suite:
  `test/test_PhyloMakie.jl` parses `src/PhyloMakie.jl`, asserts exact top-level
  form counts and include order, and `test/test_verification_foundation.jl`
  polices workflow metadata instead of runtime behavior.
- Task 2 closes this lock item.
- The verification artifact that must fail the old shape is:
  `test/test_PhyloMakie.jl` reduced to runtime smoke only,
  `test/test_verification_foundation.jl` deleted,
  and `test/runtests.jl` green without any replacement markdown/prose policing.

### Lock item 4: no proof-only artifacts attached to public plots

- The work is not complete if returned public plot objects still expose
  `resolved_attributes`, `resolved_layout`, or `render_layers`, or if public
  docs/tests still treat those attached artifacts as package contract.
- The direct red-state repro is the current public owner:
  `src/public_plot_owner.jl` writes those three fields onto the plot object,
  `docs/src/public-api.md` describes one of them as package behavior,
  and `test/test_public_plot_owner.jl` depends on all three for most of its
  proof surface.
- Task 1 closes the public-docs side of this lock item.
- Task 3 closes the runtime-owner and public-test side of this lock item.
- The verification artifact that must fail the old shape is:
  direct absence checks using `propertynames(surface.plot.attributes)` and
  `propertynames(plot.attributes)` for the non-mutating and mutating surfaces,
  respectively.

### Lock item 5: cleanup must leave a stronger positive package surface

- The work is not complete if the cleanup only deletes scaffolding but leaves
  weaker public docs, weaker capability proof, or a less usable maintainer
  surface.
- The direct red-state repro to guard against is a fake simplification that
  removes `VERIFICATION_FOUNDATION` and public plot attachments but replaces
  them with prose-only docs, string-policing tests, or missing live artifacts.
- Task 1 closes the docs and migration side of this lock item.
- Task 3 closes the public-surface proof side of this lock item.
- The verification artifact is:
  live docs examples on Home, Public API, Migration guide, and Render
  verification still build and render, and the public plot owner tests still
  prove type parity, caller-owned network safety, limit validation, legacy
  keyword rejection, and non-empty public rendering.

## Handoff packet

- Active authorities:
  `CONTRIBUTING.md`,
  every repo-local `STYLE*.md` file listed above,
  `design/prod01-vision.md`,
  `design/prod01-vision-supplement.md`,
  the approved PRD,
  the approved tranche plan,
  the tranche-7 tasking and remediation tasking files,
  and the tranche-4 Makie source-set note.
- Parent documents:
  `design/prod01-vision.md`,
  `design/prod01-vision-supplement.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-08_tranche-07--tasking-1.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-09_tranche-07--tasking-2.md`,
  and
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`.
- Settled decisions and non-negotiables:
  preserve the accepted Makie-native public architecture;
  remove runtime workflow verification metadata from `src/`;
  remove `resolved_attributes`, `resolved_layout`, and `render_layers` from the
  returned public plot surface;
  keep `Makie.data_limits`;
  keep docs truthful to the accepted API;
  keep tests behavior-oriented rather than source-shape-oriented;
  do not add new features, legacy compatibility shells, or General-registry
  claims.
- Authorization boundary:
  aggressive subtractive cleanup is authorized in docs, tests, and package
  shell structure; the core Makie-native public owner, attribute model,
  layout owner, annotation owner, render owner, and feature scope are not to
  be redesigned beyond what is needed to remove proof-only public attachments.
- Current-state diagnosis:
  the core runtime architecture is in good shape, but the package still ships
  workflow/process metadata as runtime code, docs truth is coupled to that
  metadata and to test-support files, public-owner proof is overfit to
  plot-attached scaffolding, and the shell test suite polices source layout
  instead of behavior.
- Primary-goal lock:
  lock items 1 through 5 above.
- Direct red-state repros:
  `include("verification_foundation.jl")` in `src/PhyloMakie.jl`;
  `getfield(PhyloMakie, :VERIFICATION_FOUNDATION)` in docs pages;
  `include(... fixture_corpus.jl)` in `docs/src/render-verification.md`;
  `Meta.parse` and exact include-order assertions in `test/test_PhyloMakie.jl`;
  `plot[:resolved_attributes]`,
  `plot[:resolved_layout]`,
  and `plot[:render_layers]` in `src/public_plot_owner.jl`.
- Owner and invariant under repair:
  the package truth surface and public-proof boundary.
  The accepted owner set that must remain is:
  `src/public_attribute_model.jl`,
  `src/layout_engine.jl`,
  `src/annotation_data.jl`,
  `src/render_adapter.jl`,
  and `src/public_plot_owner.jl`.
- Supported public surfaces affected by that owner or semantic:
  README installation/quickstart,
  Documenter Home,
  Public API examples,
  Migration guide capability mapping,
  Render verification artifacts,
  `plot(net)`,
  `plot!(ax, net)`,
  `phyloplot(net)`,
  and `phyloplot!(ax, net)`.
- Exact files or surfaces in scope:
  `README.md`,
  `docs/make.jl`,
  `docs/src/index.md`,
  `docs/src/public-api.md`,
  `docs/src/migration-guide.md`,
  `docs/src/render-verification.md`,
  `docs/src/verification-foundation.md`,
  `src/PhyloMakie.jl`,
  `src/public_plot_owner.jl`,
  `src/verification_foundation.jl`,
  `test/runtests.jl`,
  `test/test_PhyloMakie.jl`,
  `test/test_public_plot_owner.jl`,
  and `test/test_verification_foundation.jl`.
- Exact files or surfaces out of scope:
  `src/public_attribute_model.jl`,
  `src/layout_engine.jl`,
  `src/annotation_data.jl`,
  `src/render_adapter.jl`,
  `test/test_public_attribute_model.jl`,
  `test/test_layout_engine.jl`,
  `test/test_annotation_data.jl`,
  `test/test_render_adapter.jl`,
  dependency manifests,
  `examples/`,
  new capabilities,
  runtime compatibility shells,
  and R interoperability.
- Required upstream primary sources:
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/display.jl`,
  `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v/src/screen.jl`.
- Green-state gates:
  `julia --project=test test/runtests.jl`,
  `julia --project=docs docs/make.jl`,
  no `VERIFICATION_FOUNDATION` runtime symbol,
  no docs-source inclusion of `fixture_corpus.jl`,
  no `resolved_*` attributes on returned public plots,
  and live docs examples still rendering nontrivial package behavior.
- Stop conditions:
  stop if removing workflow scaffolding appears to require broadening the
  accepted API;
  stop if keeping docs truthful would require reintroducing a runtime workflow
  owner;
  stop if public-owner cleanup would require weakening `Makie.data_limits`;
  stop if the only way to keep proof is to replace runtime/test coupling with
  markdown, YAML, or prose-string policing.

## Required revalidation before implementation

- Read the tranche and parent PRD in full.
- Read this follow-on tasking file in full.
- Read all active governance documents in full.
- Re-read `src/PhyloMakie.jl`, `src/public_plot_owner.jl`, the docs files in
  scope, and the test files in scope before editing.
- Re-check that `VERIFICATION_FOUNDATION` still exists in `src/` and docs
  before starting the removal work.
- Re-check that `resolved_attributes`, `resolved_layout`, and `render_layers`
  are still attached to returned public plot objects before starting Task 3.
- Re-read the cited Makie/CairoMakie primary sources if any implementation
  detail depends on recipe or bang/non-bang host semantics.
- If the tranche-7 diagnosis no longer matches reality, stop and surface that
  before changing code.

## Tranche execution rule

This follow-on explicitly authorizes subtractive cleanup and deep simplification
where needed, but the work must begin and end in a green, policy-compliant
state.

When the tranche is complete:

- `VERIFICATION_FOUNDATION` no longer exists as package runtime code.
- `verification-foundation.md` no longer exists as package docs.
- package docs teach the product directly, not a workflow metadata owner.
- public proof no longer depends on plot-attached `resolved_*` artifacts.
- lower-level exact geometry and render semantics remain owned by the lower
  helper and render test suites rather than being recreated through public
  plot attachments.

Docs must be brought into truth with the accepted API and accepted owners.
Do not change the API to preserve workflow or proof scaffolding.

Forbidden workaround classes:

- recreating workflow metadata in another runtime file under a different name
- replacing deleted runtime metadata with markdown-shape or prose-shape tests
- moving example or product logic into tests just to recover deleted docs data
- restoring `resolved_*` public plot attachments as a testing convenience
- silently broadening the accepted public surface to compensate for cleanup

## Non-negotiable execution rules

- Do not recreate a second public owner, wrapper owner, or compatibility shell.
- Do not reintroduce `VERIFICATION_FOUNDATION` under any name in `src/`.
- Do not solve docs drift by adding more workflow metadata.
- Do not replace behavior proof with exact markdown text, docs-heading, or
  YAML policing.
- Do not keep `resolved_attributes`, `resolved_layout`, or `render_layers`
  alive on the public plot object.
- Do not weaken `Makie.data_limits`, caller-owned network protection, legacy
  keyword rejection, or bang/non-bang parity.
- Do not edit `src/public_attribute_model.jl`, `src/layout_engine.jl`,
  `src/annotation_data.jl`, or `src/render_adapter.jl` in this follow-on.
- Do not pull `examples/` or dependency policy into scope.

## Concrete anti-patterns or removal targets

- `src/verification_foundation.jl`
- `include("verification_foundation.jl")` in `src/PhyloMakie.jl`
- `docs/src/verification-foundation.md`
- the `Verification foundation` nav entry in `docs/make.jl`
- `getfield(PhyloMakie, :VERIFICATION_FOUNDATION)` in docs pages
- `include(joinpath(..., "test", "support", "fixture_corpus.jl"))` in docs
- docs statements that `resolved_attributes` or other proof-only attachments
  are part of the package-facing contract
- `Meta.parse`, exact top-level form counts, and include-order assertions in
  `test/test_PhyloMakie.jl`
- `test/test_verification_foundation.jl`
- `plot[:resolved_attributes]`, `plot[:resolved_layout]`, and
  `plot[:render_layers]` in `src/public_plot_owner.jl`
- any replacement overfit such as string-policing tests for docs tables,
  headings, workflow vocabulary, or deleted page names

## Failure-oriented verification

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- `rg -n "VERIFICATION_FOUNDATION" src docs/src README.md docs/make.jl`
  must fail after cleanup.
- `rg -n "fixture_corpus" docs/src` must fail after cleanup.
- `test/test_verification_foundation.jl` must not exist after cleanup.
- `test/test_PhyloMakie.jl` must no longer contain `Meta.parse`,
  exact top-level form counting, or include-order assertions.
- `test/test_public_plot_owner.jl` must contain direct absence checks for
  `:resolved_attributes`, `:resolved_layout`, and `:render_layers` on both the
  non-mutating and mutating returned public plot surfaces.
- Home, Public API, Migration guide, and Render verification must still build
  from live examples or live package constants.
- Public plot owner proof must still cover:
  type parity across all four public surfaces,
  caller-owned network preservation,
  explicit limit validation,
  legacy keyword rejection,
  non-empty public rendering for pure-tree and reticulate cases,
  and dual-axis composition.

## Tasks

### 1. Rewrite docs truth surfaces around product-owned sources and docs-local artifacts

**Type**: MIGRATE
**Output**: `README.md`, `docs/src/index.md`, `docs/src/public-api.md`,
`docs/src/migration-guide.md`, and `docs/src/render-verification.md` teach the
accepted package directly without `VERIFICATION_FOUNDATION` or docs-time test
support includes.
**Depends on**: none

Rewrite the package-facing docs so they own their truth directly. In
`README.md`, `docs/src/index.md`, `docs/src/public-api.md`,
`docs/src/migration-guide.md`, and `docs/src/render-verification.md`, remove
all use of `getfield(PhyloMakie, :VERIFICATION_FOUNDATION)` and any prose that
describes `resolved_attributes` or other proof-only plot attachments as package
behavior. Keep the four supported public entry surfaces as a manual docs-owned
table. Keep the live supported attribute list rendered from
`SUPPORTED_PHYLOPLOT_ATTRIBUTES`, and keep the rejected legacy spelling table
rendered from `PHYLOPLOT_ATTRIBUTE_MIGRATIONS`; these are accepted product
constants, not workflow metadata. In `docs/src/migration-guide.md`, replace
the old scenario/proof-surface table with a manual seven-row capability map in
this exact order: pure tree plotting, reticulate plotting with gamma display,
style distinction, edge-length scaling, data-frame annotations, edge color and
width control with fallback, and dual-axis composition. In
`docs/src/render-verification.md`, delete the render-owner summary block fed by
`VERIFICATION_FOUNDATION`, stop including `test/support/fixture_corpus.jl`,
and copy the current case data for `style_fulltree`, `style_majortree`,
`gamma_and_edgecolor`, `annotation_and_limits`,
`nodelabel_render_rows`, and `edgelabel_filtered_rows` into docs-local setup
data so the live artifacts stay equivalent without test-file coupling. Remove
all README and docs links that route readers to `verification-foundation.md`.
The positive maintainer-facing result is a docs set that is still live and
capability-rich, but no longer depends on workflow metadata or test-support
imports.

**Positive contract**: docs are truthful to the accepted API, still render live
examples, still expose the supported attribute set and migration guidance, and
no longer depend on workflow metadata or test-support files.
**Negative contract**: no `VERIFICATION_FOUNDATION`, no `fixture_corpus`
include, no docs-proof-surface inventory, no workflow-owner summary table, and
no public docs claim that `resolved_*` attachments are package contract.
**Files**:
`README.md`,
`docs/src/index.md`,
`docs/src/public-api.md`,
`docs/src/migration-guide.md`,
`docs/src/render-verification.md`.
**Out of scope**:
`docs/make.jl`,
`docs/src/verification-foundation.md`,
`src/`,
`test/`,
`examples/`,
and any runtime API change.
**Verification**:
`julia --project=docs docs/make.jl`;
`rg -n "VERIFICATION_FOUNDATION" README.md docs/src/index.md docs/src/public-api.md docs/src/migration-guide.md docs/src/render-verification.md` must fail;
`rg -n "fixture_corpus" docs/src/render-verification.md` must fail;
the docs build must still execute the pure-tree public example, the reticulate
public example, the migration guide, and the three live render-verification
artifacts.

### 2. Delete runtime verification scaffolding and replace shell policing with runtime smoke

**Type**: WRITE
**Output**: the package no longer ships `VERIFICATION_FOUNDATION`, the docs no
longer publish `verification-foundation.md`, and the shell test checks runtime
surfaces rather than source layout or workflow prose.
**Depends on**: 1

Remove the workflow-owner layer from the package shell and its test/doc
surfaces. Delete `src/verification_foundation.jl` and
`docs/src/verification-foundation.md`. Update `src/PhyloMakie.jl` to stop
including the deleted runtime file, and update `docs/make.jl` to remove the
deleted docs page from nav. Update `test/runtests.jl` to stop including
`test/test_verification_foundation.jl`, then delete that test file. Rewrite
`test/test_PhyloMakie.jl` as a runtime smoke test only: keep symbol-presence
checks for `PhyloPlotAttributes`, `PlotGeometry`, `PlotBounds`, `PlotLayout`,
`render_plot!`, `PlotRenderLayers`, `phyloplot`, `phyloplot!`, and `PhyloPlot`;
keep negative checks that legacy compatibility-shell artifacts do not exist;
add `!isdefined(PhyloMakie, :VERIFICATION_FOUNDATION)` explicitly; and keep the
`Makie.plottype(::HybridNetwork)` dispatch proof. Remove module-source parsing,
exact top-level form counts, and include-order assertions completely. Do not
replace the deleted verification-foundation coverage with markdown-, prose-,
tuple-, or heading-policing tests. The positive result is a thinner package
shell and a thinner test shell that prove real runtime structure instead of a
historical file layout.

**Positive contract**: `PhyloMakie` loads without a runtime verification owner,
docs nav contains only product-facing pages, and the shell test proves live
runtime symbols and Makie dispatch rather than source-file shape.
**Negative contract**: no `VERIFICATION_FOUNDATION` runtime symbol, no
`verification-foundation.md` docs page, no module-source parsing, no exact
include-order assertions, and no replacement docs/prose policing suite.
**Files**:
`src/PhyloMakie.jl`,
`src/verification_foundation.jl`,
`docs/make.jl`,
`docs/src/verification-foundation.md`,
`test/runtests.jl`,
`test/test_PhyloMakie.jl`,
`test/test_verification_foundation.jl`.
**Out of scope**:
`README.md`,
`docs/src/index.md`,
`docs/src/public-api.md`,
`docs/src/migration-guide.md`,
`docs/src/render-verification.md`,
`src/public_plot_owner.jl`,
`test/test_public_plot_owner.jl`,
and any feature or API change.
**Verification**:
`julia --project=test test/runtests.jl`;
`julia --project=docs docs/make.jl`;
`rg -n "VERIFICATION_FOUNDATION" src docs/src README.md docs/make.jl` must fail;
`test ! -e src/verification_foundation.jl`;
`test ! -e docs/src/verification-foundation.md`;
`test ! -e test/test_verification_foundation.jl`;
`test/test_PhyloMakie.jl` must still prove `Makie.plottype(readnewick("(A,B);")) == PhyloPlot`.

### 3. Remove proof-only public-plot attachments and re-scope public proof to behavior

**Type**: WRITE
**Output**: the public recipe stops attaching `resolved_attributes`,
`resolved_layout`, and `render_layers`, and the public plot owner regression
proves behavior and parity without depending on those artifacts.
**Depends on**: 2

In `src/public_plot_owner.jl`, keep the existing accepted owner flow:
resolve attributes, deepcopy the caller-owned network, build one `PlotLayout`,
validate limits, apply `render_plot!`, and return the plot. Remove only the
three proof-only plot attachments:
`plot[:resolved_attributes]`,
`plot[:resolved_layout]`,
and `plot[:render_layers]`.
Do not alter `deepcopy` ownership, limit validation, public return contracts,
or `Makie.data_limits`. In `test/test_public_plot_owner.jl`, delete the helper
accessors that read those three plot-attached artifacts and rewrite the public
proof around behavior-level checks only. Keep:
type and return parity across `plot`, `plot!`, `phyloplot`, and `phyloplot!`;
caller-owned network preservation;
explicit limit validation errors plus `Makie.data_limits` proof;
legacy keyword rejection;
non-empty rendering for a pure-tree `plot(net)` case and a reticulate
`plot(net; show_gamma = true, ...)` case;
style distinction by differing rendered output;
an annotation-and-limits public render smoke;
and dual-axis composition on existing axes.
Move no geometry, annotation-anchor, gamma-color, or edge-width exactness onto
the public plot object; those exact semantics remain owned by
`test/test_layout_engine.jl`,
`test/test_annotation_data.jl`,
and `test/test_render_adapter.jl`.
Add direct negative checks that
`:resolved_attributes`,
`:resolved_layout`,
and `:render_layers`
are absent from `propertynames(surface.plot.attributes)` for non-mutating
surfaces and from `propertynames(plot.attributes)` for mutating surfaces. The
positive result is a cleaner public surface and a public-proof suite that still
proves useful behavior without freezing internal owner payloads onto user
objects.

**Positive contract**: public plot surfaces preserve Makie behavior and parity,
but no longer expose proof-only internal payloads on returned plot objects.
**Negative contract**: no `resolved_*` plot attachments, no public docs/tests
depending on them, and no replacement overfit that recreates their role via
source-text parsing or docs-output parsing.
**Files**:
`src/public_plot_owner.jl`,
`test/test_public_plot_owner.jl`.
**Out of scope**:
`src/public_attribute_model.jl`,
`src/layout_engine.jl`,
`src/annotation_data.jl`,
`src/render_adapter.jl`,
`test/test_public_attribute_model.jl`,
`test/test_layout_engine.jl`,
`test/test_annotation_data.jl`,
`test/test_render_adapter.jl`,
`docs/`,
and any new capability work.
**Verification**:
`julia --project=test test/runtests.jl`;
`julia --project=docs docs/make.jl`;
the public-owner regression must fail the old shape by asserting
`:resolved_attributes ∉ propertynames(...)`,
`:resolved_layout ∉ propertynames(...)`,
and `:render_layers ∉ propertynames(...)` for both non-mutating and mutating
public surfaces;
the same regression must still prove parity, caller-owned network safety,
limit validation, legacy keyword rejection, pure-tree render smoke, reticulate
render smoke, and dual-axis composition.
