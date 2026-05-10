---
date-created: 2026-05-09T21:51:31
workflow-instrument: Tasking plan
workflow-status: Proposed
workflow-agent-thread-id: codex/20260509-phylomakie-tranche-03-tasking-1
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: phylomakie-makie-rebuild
workflow-prd: .workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md
workflow-tranche: .workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md
---

# Tasks for tranche 3: Layout and annotation data owner

## Approval state

- This file is proposed planning output derived from proposed tranche 3 in
  `02_tranches.md`.
- Downstream `Tasks -> Execute` work remains blocked until the project owner
  sets `workflow-status: Approved` in this file's frontmatter.

## Settled user decisions and environment baseline

- The production-run public behavior target remains
  `PhyloPlots.plot(net::HybridNetwork; ...)`.
- The canonical PhyloMakie target public surface names remain `phyloplot`,
  `phyloplot!`, and Makie `plot(net)` dispatch.
- `PhyloPlot` remains the recipe type name, not the primary user-facing API
  name.
- `PhyloNetworks.HybridNetwork` remains the only supported public input type
  for this production run.
- Deep internal redesign is authorized. Public plotting behavior drift from
  `PhyloPlots.plot` is not authorized.
- Compatibility aliases to old package names are not required.
- R interoperability remains out of scope.
- Preserve the existing root, `test/`, and `docs/` project split.
- Preserve `[sources.PhyloMakie] path = "../"` in `test/Project.toml` and
  `docs/Project.toml`.
- Use documented public `Pkg` operations to curate the root and `test/`
  project environments. Do not hand-edit manifests as a first resort.
- The current `preorder=true` behavior is a settled public-mutation boundary
  for this production run. Tranche 3 may make that mutation explicit and
  locally owned, but it may not silently change the default or weaken the
  behavior.
- The current repository baseline was revalidated on 2026-05-09:
  `julia --project=test test/runtests.jl` passes with 268 tests, and
  `julia --project=docs docs/make.jl` passes.
- `docs/src/index.md` still describes a tranche-1-only snapshot even though
  tranche 2 is implemented. Any tranche-3 docs work must correct that truth
  boundary rather than preserve stale wording.
- The parent PRD and tranche file do not currently carry
  `workflow-location` or `workflow-production-id` frontmatter fields. This
  draft records the current repo root path explicitly and proposes
  `phylomakie-makie-rebuild` as the production id, matching the existing
  workflow directory name. Ratify or revise those values during review.
- Revalidation against `PhyloPlots.jl/src/plotRCall.jl` shows that exact
  public `xlim` / `ylim` error-path parity cannot honestly be marked closed in
  tranche 3 while `phyloplot` and `plot(net)` remain unimplemented and the
  current keyword owner still rejects malformed explicit limits before
  layout-derived default bounds exist. Tranche 3 therefore closes the
  Makie-independent default-bounds and exact message-format ingredients, but
  direct public-surface proof of those messages remains deferred to tranche 5.

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

Authority notes that remain active in this tasking file:

- The repo-local `STYLE*.md` set is the operative governance set for this run.
- The bundled baseline STYLE files required by `development-policies` are
  present, and the overlapping repo-local copies are the controlling
  authorities for this repository.
- No repo-local `STYLE-domain-vocabulary.md` was found.
- No repo-local `STYLE-python.md` was found.
- `STYLE-vocabulary.md` remains the domain vocabulary authority.
- `STYLE-workflow-vocabulary.md` remains authoritative for workflow terms such
  as `tranche`, `lock item`, `primary-goal lock`, `red-state repro`, and
  `verification artifact`.

Controlled vocabulary obligations that matter directly in this tranche:

- Use `phyloplot` and `phyloplot!` for the target public surfaces.
- Use `PhyloPlot` only for the recipe type.
- Use `FigureAxisPlot` for the non-mutating Makie return contract.
- Use `layout engine`, `annotation-data owner`, `render adapter`,
  `major hybrid edge`, `minor hybrid edge`, `full-tree style`, and
  `major-tree style` with their governed meanings.
- Do not import foreign project terms such as `lineageplot`, `EdgeLayer`, or
  `lineageunits`.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, branch creation, rebase, and reset remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Primary-goal lock

### Lock item 1: Canonical Makie-independent geometry owner

- The work is not complete if PhyloMakie still has no local layout engine and
  later layers would need to depend on `PhyloPlots.jl` or on render-layer
  geometry recomputation to obtain node, edge, or minor-edge coordinates.
- The direct red-state repro is the current repository state: there is no
  `src/layout_engine.jl`, no `layout_plot_geometry` owner, and the exact
  helper regressions live only in upstream `PhyloPlots.jl`.
- The tasks that close this are task 2 and task 3.
- The verification artifact is one source-owned `PlotGeometry` owner plus a
  helper regression suite that fails the old repository state immediately.

### Lock item 2: Geometry parity for full-tree style, major-tree style, and edge-length scaling

- The work is not complete if the local layout engine drifts from the exact
  upstream coordinate tuples for the accepted regression network under
  `useedgelength=true`, `style=:fulltree`, `style=:majortree`, and
  `useedgelength=false` major-tree mode.
- The direct red-state repro is the three exact tuples asserted in
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl` for the network
  `(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);`.
- The tasks that close this are task 2 and task 3.
- The verification artifact is direct tuple equality against source-owned
  regression data, not screenshots or approximate visual checks.

### Lock item 3: Level-2 hybrid geometry parity

- The work is not complete if level-2 networks with non-tree-child hybrids can
  still pass tranche 3 while the local layout owner fails the exact upstream
  geometry behavior.
- The direct red-state repro is the pair of level-2 networks used at the end
  of `PhyloPlots.jl/test/test_phylonetworkPlots.jl`, with and without explicit
  gamma values on the second hybrid node.
- The tasks that close this are task 2 and task 3.
- The verification artifact is exact tuple equality for both level-2 network
  regressions. A fake fix that merely produces a plausible picture must fail.

### Lock item 4: Explicit mutation-policy boundary

- The work is not complete if tranche 3 leaves the `preorder=true` mutation
  contract implicit, or if it silently changes the default mutation behavior
  around `directedges!` and `preorder!`.
- The direct red-state repro is the upstream `edgenode_coordinates` contract:
  it calls `PhyloNetworks.directedges!` and `PhyloNetworks.preorder!` by
  default and only skips that mutation when `preorder=false`.
- The tasks that close this are task 2 and task 3.
- The verification artifact is direct helper tests showing that
  `preorder=true` prepares traversal state locally and that `preorder=false`
  remains a caller-visible contract rather than a silent no-op.

### Lock item 5: Canonical annotation-data validation owner

- The work is not complete if `nodelabel` and `edgelabel` validation, missing
  first-column filtering, and unmatched-number warnings still live only in
  upstream helpers, workflow prose, or a future render layer.
- The direct red-state repro is the current repository state:
  `normalize_plot_keywords` copies annotation data frames but does not perform
  row filtering, warning emission, or midpoint preparation.
- The tasks that close this are task 4 and task 5.
- The verification artifact is one local annotation-data owner plus warning
  and filtered-row regressions that fail the current repository state.

### Lock item 6: Midpoint placement and annotation table parity

- The work is not complete if node and edge annotation anchors drift from the
  upstream `prepare_nodedataframe` and `prepare_edgedataframe` contract, or if
  tranche 3 pushes midpoint placement into render-time offsets.
- The direct red-state repro is the exact DataFrame outputs asserted in
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl`, especially the major-tree
  minor-edge midpoint case.
- The tasks that close this are task 4 and task 5.
- The verification artifact is direct DataFrame equality tests and midpoint
  assertions that fail any render-offset anti-fix.

### Lock item 7: Honest explicit-limit boundary

- The work is not complete if layout-derived default bounds remain implicit, or
  if tranche 3 falsely claims that full public `xlim` / `ylim` error-path
  parity is already proven while public plotting entry surfaces are still
  unimplemented.
- The direct red-state repro is the current repository state:
  `normalize_plot_keywords` throws a structural explicit-limit error before the
  layout engine can compute the default bounds interpolated by upstream
  `plotRCall.jl`, and `keyword_contract.jl` still tags exact message parity as
  tranche-3-owned.
- The tasks that close this are task 4, task 5, and task 6.
- The verification artifact is helper-level proof that the local layout owner
  computes the exact default bounds and exact upstream message strings, plus
  source-owned metadata and docs proof that direct public-surface verification
  remains deferred to tranche 5.

### Lock item 8: Source-owned pass-forward into verification and docs

- The work is not complete if the layout engine, annotation-data owner, and
  corrected explicit-limit proof boundary exist only in code comments, test
  cases, or workflow prose rather than in source-backed verification data and
  rendered docs.
- The direct red-state repro is the current repository state:
  `VERIFICATION_FOUNDATION` records the keyword owner only, and
  `docs/src/index.md` still describes a tranche-1-only snapshot.
- The tasks that close this are task 6.
- The verification artifact is updated source-owned verification metadata,
  updated verification-foundation tests, and a green docs build that renders
  the tranche-3 owner state truthfully.

## Handoff packet

- Approval state: proposed only. Do not execute until the project owner sets
  `workflow-status: Approved` in this file.
- Active authorities: `CONTRIBUTING.md`; all repo-local root `STYLE*.md`
  files; `STYLE-vocabulary.md`; `STYLE-workflow-vocabulary.md`;
  `design/prod01-vision.md`; `design/prod01-vision-supplement.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`.
- Parent documents:
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`;
  `design/prod01-vision.md`; `design/prod01-vision-supplement.md`.
- Settled decisions and non-negotiables: preserve the `PhyloPlots.plot`
  behavior target; keep `phyloplot`, `phyloplot!`, and `plot(net)` as the
  target public surfaces without implementing them here; keep `HybridNetwork`
  as the only supported public input type; keep R interop out of scope;
  preserve the root / `test/` / `docs/` project split and path overrides; keep
  `preorder=true` mutation behavior explicit; keep public exact `xlim` /
  `ylim` proof deferred past tranche 3.
- Authorization boundary: internal layout-owner and annotation-owner redesign
  is allowed; visible geometry drift, warning drift, midpoint drift, or public
  plotting-surface implementation is not.
- Current-state diagnosis: tranche 2 established the keyword owner and
  deferred contract metadata, but there is still no local layout engine, no
  local annotation-data owner, no helper-level geometry regressions, and stale
  docs truth still says the repo is tranche-1-only on the index page.
- Primary-goal lock: the 8 lock items above.
- Direct red-state repros: no local `layout_plot_geometry` owner; no local
  annotation-data owner; no exact geometry tuples in the local fixture corpus;
  no local bounds/message-format owner; no layout-owner verification block in
  `VERIFICATION_FOUNDATION`; stale `docs/src/index.md`.
- Owner and invariant under repair: one Makie-independent layout engine owns
  geometry; one annotation-data owner owns validation, warning parity, and
  midpoint preparation; render layers consume those owned results rather than
  reconstructing them.
- Exact files or surfaces in scope: `Project.toml`; `test/Project.toml`;
  `src/PhyloMakie.jl`; `src/keyword_contract.jl`; new source files under
  `src/` for the layout and annotation owners; `src/verification_foundation.jl`;
  `test/runtests.jl`; `test/test_PhyloMakie.jl`; new helper test files under
  `test/`; `test/support/fixture_corpus.jl`; `test/support/keyword_surface_cases.jl`;
  `test/test_keyword_contract.jl`; `test/test_verification_foundation.jl`;
  `docs/src/verification-foundation.md`; `docs/src/index.md`.
- Exact files or surfaces out of scope: Makie primitive composition; recipe
  code; `phyloplot`; `phyloplot!`; `plot(net)` dispatch; render-level colors
  and text drawing; compatibility aliases; R interoperability; parent PRD and
  tranche files.
- Required upstream primary sources: `PhyloPlots.jl/src/phylonetworksPlots.jl`;
  `PhyloPlots.jl/src/plotRCall.jl`; `PhyloPlots.jl/test/test_phylonetworkPlots.jl`;
  `PhyloNetworks.jl/src/manipulateNet.jl`; `PhyloNetworks.jl/src/types.jl`;
  `PhyloNetworks.jl/docs/src/man/net_plot.md`.
- Upstream contract conclusions already settled for this tranche:
  `edgenode_coordinates` is the geometry owner to port; `check_nodedataframe`,
  `prepare_nodedataframe`, and `prepare_edgedataframe` are the annotation
  owners to port; `plotRCall.jl` owns label-driven bounds expansion,
  `tipoffset`-driven `xmax` expansion, and the exact `xlim` / `ylim` message
  strings; `directedges!` and `preorder!` define the mutation boundary.
- Green-state gates: `julia --project=test test/runtests.jl`;
  `julia --project=docs docs/make.jl`; helper-level geometry and annotation
  regressions; Aqua and JET remain supplemental proof inside the test suite.
- Stop conditions: stop if the only way to match geometry or midpoint behavior
  is a render-layer workaround; stop if preserving accepted behavior appears to
  require changing the public `preorder` default; stop if exact public
  `xlim` / `ylim` parity would require pretending that unimplemented public
  surfaces already exist; stop if the task would need to modify
  `.workflow-docs/.../01_prd.md` or `.workflow-docs/.../02_tranches.md`.

## Required revalidation before implementation

- Read `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`
  and `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md` in
  full.
- Read all governance files named above line by line.
- Re-read `src/PhyloMakie.jl`, `src/keyword_contract.jl`,
  `src/keyword_normalization.jl`, `src/verification_foundation.jl`,
  `test/test_PhyloMakie.jl`, `test/test_keyword_contract.jl`,
  `test/test_keyword_normalization.jl`, `test/test_verification_foundation.jl`,
  `test/support/fixture_corpus.jl`, `docs/src/verification-foundation.md`, and
  `docs/src/index.md` in full.
- Re-read `PhyloPlots.jl/src/phylonetworksPlots.jl`,
  `PhyloPlots.jl/src/plotRCall.jl`, and
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl` in full.
- Re-read `PhyloNetworks.jl/src/manipulateNet.jl`,
  `PhyloNetworks.jl/src/types.jl`, and
  `PhyloNetworks.jl/docs/src/man/net_plot.md` in full.
- Re-run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` before modifying code so tranche 3
  starts from a known green baseline.
- Re-check that no local layout owner, annotation owner, or public entry
  surface landed after this tasking file was written. If any did, stop and
  rewrite the tasking against current reality.
- Re-check that exact public `xlim` / `ylim` proof is still blocked on the
  unimplemented public entry surfaces. If a new public owner lands, stop and
  update this tasking honestly rather than preserving a stale deferral.

## Tranche execution rule

This tranche may redesign internal helper ownership deeply, but it must begin
and end in a green, policy-compliant state for its scope.

When this tranche completes:

- the repository must have one canonical Makie-independent geometry owner;
- the repository must have one canonical annotation-data owner;
- the repository must have one local owner for default-bounds computation and
  exact limit-message ingredients;
- docs and verification metadata must tell the truth about what tranche 3
  closes now and what remains blocked on tranche 4 or tranche 5.

When this tranche completes, the following must no longer exist as acceptable
owner shapes:

- upstream `PhyloPlots.jl` as the live runtime geometry owner;
- render-layer recomputation of geometry or annotation midpoints;
- wrapper-local or keyword-owner-local annotation validation;
- stale source-owned metadata that still claims tranche 3 closed full public
  `xlim` / `ylim` proof when the public surfaces are still deferred;
- docs pages that preserve the tranche-1-only snapshot after tranche 3 has
  landed.

Docs truth-boundary rule for this tranche:

- Docs may describe the local layout engine, annotation-data owner, and the
  still-deferred public plotting surfaces.
- Docs must not claim that `phyloplot`, `phyloplot!`, or `plot(net)` are
  implemented.
- Docs must not claim that full public `xlim` / `ylim` error-path parity is
  proven in tranche 3.
- Docs should state that tranche 3 closes the local bounds and message-format
  ingredients while public-surface proof remains deferred.

## Non-negotiable execution rules

- Do not implement `phyloplot`, `phyloplot!`, `plot(net)`, `Makie.plottype`,
  or `@recipe` behavior in this tranche.
- Do not implement Makie primitives, text plotting, axis ownership, or render
  ordering in this tranche.
- Do not call `PhyloPlots.jl` at runtime for geometry, warnings, midpoint
  placement, or bounds computation.
- Do not leave `preorder=true` mutation behavior implicit.
- Do not change the default `preorder` value or reinterpret `preorder=false`.
- Do not solve midpoint drift by adding render-time offsets.
- Do not keep annotation validation in the keyword owner.
- Do not mark the public `xlim` / `ylim` proof closed in tranche 3.
- Do not add `Makie`, `CairoMakie`, `RCall`, or `PhyloPlots` as direct
  dependencies in this tranche.
- Do not modify `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`
  or `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`.

## Concrete anti-patterns or removal targets

- Any live dependency on `PhyloPlots.edgenode_coordinates`,
  `PhyloPlots.check_nodedataframe`, `PhyloPlots.prepare_nodedataframe`, or
  `PhyloPlots.prepare_edgedataframe`.
- Any render-layer repair of geometry, bounds, or annotation midpoints.
- Any second implementation of annotation filtering or warning emission outside
  the canonical annotation-data owner.
- Any free-form `Dict{Symbol,Any}` or abstractly typed bag used as the layout
  owner's canonical return type.
- Any stale `keyword_contract.jl` or `verification_foundation.jl` metadata
  that says tranche 3 already proved the public `xlim` / `ylim` error path.
- Any stale `docs/src/index.md` wording that still describes the repo as a
  tranche-1-only snapshot after this tranche lands.

## Failure-oriented verification

- Geometry verification must use exact local regression data for the three
  accepted edge-length/style cases and the two level-2 network cases from
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl`.
- Annotation verification must fail if rows with missing first-column values
  survive the local owner, if invalid first-column types fail to warn, or if
  unmatched node or edge numbers fail to warn.
- Midpoint verification must fail if major-tree minor-edge label coordinates
  use the horizontal-segment midpoint instead of the diagonal minor-edge
  midpoint.
- Mutation-boundary verification must fail if `preorder=true` no longer
  prepares traversal state, or if `preorder=false` stops being a real
  opt-out contract.
- Explicit-limit verification must fail if exact local default bounds and exact
  upstream message strings are missing, and it must also fail if source-owned
  metadata or docs falsely mark the full public proof closed now.
- Docs verification must fail if the rendered verification-foundation page
  omits the layout owner, or if the docs index keeps the stale tranche-1-only
  snapshot after the metadata changes.
- Positive maintainer-facing verification is also required: the local
  verification foundation and docs must make it obvious which owner is closed
  in tranche 3 and which public proofs remain deferred.

## Tasks

### 1. Add the layout-owner dependency baseline

**Type**: CONFIG
**Output**: `PhyloNetworks` is available as the only new tranche-3 direct
dependency needed by the local layout and annotation owners, and the current
green baseline still passes afterward.
**Depends on**: none
**Positive contract**: The root project and the `test/` project declare
`PhyloNetworks` through documented public `Pkg` operations. The existing root /
`test/` / `docs/` split and the existing path-override policy remain
unchanged.
**Negative contract**: Do not add `Makie`, `CairoMakie`, `RCall`,
`PhyloPlots`, or any new docs-only dependency in this task. Do not change
`docs/Project.toml`. Do not expose any plotting API.
**Files**: `Project.toml`; `test/Project.toml`
**Out of scope**: `src/`; `test/` source files; `docs/`; public plotting
entrypoints; render logic
**Verification**: `julia --project=test test/runtests.jl` passes after the
dependency addition. `julia --project=docs docs/make.jl` still passes. A
repo-local import smoke check from the root project can load both
`PhyloMakie` and `PhyloNetworks`. The old repository state fails that
project-local `PhyloNetworks` import check from the package environment.

Add `PhyloNetworks` as the only new direct dependency needed by tranche 3.
Use public `Pkg` operations from the root project and the `test/` project
rather than hand-editing manifests. Preserve the repo-local environment split
and the existing `[sources.PhyloMakie] path = "../"` policy. Do not broaden
the dependency surface beyond what the local layout and annotation owners need.

### 2. Establish the canonical geometry owner

**Type**: WRITE
**Output**: One canonical source-owned geometry owner exists under `src/`,
and `src/PhyloMakie.jl` remains a thin include-only shell.
**Depends on**: 1
**Positive contract**: `src/PhyloMakie.jl` includes `layout_engine.jl` after
`keyword_normalization.jl`, and the shell remains include-only. The new source
file defines one immutable unexported `PlotGeometry` owner with the exact
top-level fields `edge_x_lo`, `edge_x_hi`, `edge_y_lo`, `edge_y_hi`, `node_x`,
`node_y`, `node_y_lo`, `node_y_hi`, `arrow_x_lo`, `arrow_x_hi`, `arrow_y_lo`,
`arrow_y_hi`, `xmin`, `xmax`, `ymin`, and `ymax`. The file also defines one
unexported `layout_plot_geometry(net::HybridNetwork,
spec::PlotKeywordSpec)::PlotGeometry` function that ports
`PhyloPlots.edgenode_coordinates` exactly, deriving direct-minor-edge mode from
`spec.layout.style == :majortree` and preserving the current
`preorder=true` mutation behavior.
**Negative contract**: Do not implement node or edge annotation tables in this
task. Do not implement bounds expansion for labels or `tipoffset` in this
task. Do not implement any Makie primitive composition, any public plotting
surface, or any runtime call into `PhyloPlots.jl`. Do not change keyword
normalization defaults or warning policies here.
**Files**: `src/PhyloMakie.jl`; `src/layout_engine.jl`; `test/test_PhyloMakie.jl`
**Out of scope**: `src/keyword_contract.jl`; `src/verification_foundation.jl`;
annotation-data helpers; docs; new regression suites; render-level behavior
**Verification**: `julia --project=test test/runtests.jl` passes after the new
source file and thin-shell test update land. Direct source-level inspection can
load `PlotGeometry` and `layout_plot_geometry` from `PhyloMakie`. The old
repository state fails because neither owner exists there.

Create `src/layout_engine.jl` as the one local owner of the upstream geometry
contract. Port the traversal order, leaf and minor-edge y assignment, internal
node y aggregation, missing-length fallback, and major/minor edge coordinate
logic from `PhyloPlots.jl/src/phylonetworksPlots.jl` exactly. Annotate
arguments at the abstract level required by the local contract and annotate the
return type explicitly. Keep struct fields concrete or concretized through type
parameters, with no `Any` or abstractly typed storage. Preserve the upstream
`RootMismatch` augmentation text when `directedges!` fails under
`preorder=true`. Treat `spec.layout.preorder` as the one explicit mutation
switch for this owner.

### 3. Add geometry regressions and mutation-boundary tests

**Type**: TEST
**Output**: The repository has one direct geometry regression suite that proves
tranche-3-owned helper behavior and rejects fake fixes for style or mutation
drift.
**Depends on**: 2
**Positive contract**: `test/support/fixture_corpus.jl` gains source-owned
expected geometry data for the three accepted style and edge-length regressions
and the two level-2 network regressions from upstream. A new
`test/test_layout_engine.jl` covers exact tuple equality, the warning path for
mixed missing and non-missing edge lengths, and the explicit `preorder=true` /
`preorder=false` mutation boundary.
**Negative contract**: Do not use screenshots, approximate comparisons, or
source-text greps as the primary proof. Do not call upstream `PhyloPlots`
helpers from the test assertions. Do not weaken proof to "returns something"
or "stays within bounds".
**Files**: `test/runtests.jl`; `test/support/fixture_corpus.jl`;
`test/test_layout_engine.jl`
**Out of scope**: docs; annotation-data regressions; verification-foundation
metadata; public entry-surface tests; render-level proofs
**Verification**: `julia --project=test test/runtests.jl` passes and fails the
old repository state immediately because no local geometry owner or regression
data exists there. The suite also fails any fake fix that changes the
full-tree or major-tree coordinate tuples, mutates when `preorder=false`, or
silently stops mutating when `preorder=true`.

Add source-mirroring tests for the local geometry owner. Cover, at minimum,
the exact tuple currently asserted upstream for `useedgelength=true` under
full-tree style, the exact tuple for `useedgelength=true` under major-tree
style, the exact tuple for `useedgelength=false` under major-tree style, and
the two exact level-2 network tuples that reproduce the non-tree-child hybrid
case. Add one test that prepares a network explicitly with
`directedges!` and `preorder!`, then proves `preorder=false` preserves the
same geometry without re-owning that mutation implicitly.

### 4. Establish the annotation-data and bounds owner

**Type**: WRITE
**Output**: One canonical annotation-data owner and one canonical local
bounds-resolution owner exist under `src/`, and later render layers can
consume a single layout payload instead of reconstructing these contracts.
**Depends on**: 2, 3
**Positive contract**: `src/PhyloMakie.jl` includes `annotation_data.jl` after
`layout_engine.jl`. The new file defines immutable unexported
`PlotBounds`, `PlotAnnotationData`, and `PlotLayout` owners plus one unexported
`prepare_plot_layout(net::HybridNetwork,
spec::PlotKeywordSpec)::PlotLayout` function. That function uses the local
geometry owner, ports the upstream `nodelabel` and `edgelabel` validation and
preparation logic exactly, computes default bounds in the exact upstream order
from `plotRCall.jl`, and defines helper-level exact message-format owners for
`xlim` and `ylim` based on the computed default bounds.
**Negative contract**: Do not implement Makie primitives, text rendering, axis
ownership, recipe code, or public plotting entrypoints in this task. Do not
move midpoint placement to the render layer. Do not change the current
structural explicit-limit validation in `normalize_plot_keywords`. Do not claim
that full public `xlim` / `ylim` proof is closed here.
**Files**: `src/PhyloMakie.jl`; `src/annotation_data.jl`; `test/test_PhyloMakie.jl`
**Out of scope**: `docs/`; `src/verification_foundation.jl`; public plotting
surfaces; render adapter; image-level verification
**Verification**: `julia --project=test test/runtests.jl` passes after the new
owner lands and the thin-shell test is updated. Direct source-level inspection
can load `PlotLayout` and `prepare_plot_layout` from `PhyloMakie`. The old
repository state fails because none of those owners exist there.

Create `src/annotation_data.jl` as the one local owner of `nodelabel`,
`edgelabel`, and default-bounds preparation. Port the warning strings,
missing-first-column filtering, unmatched-number warnings, node-label table
construction, and edge-label midpoint logic exactly from the upstream helper
code. Preserve the exact upstream order for default-bounds computation:
geometry first, `nodelabel` validation and preparation next, 10 percent x
expansion and 0.5 y expansion only when tip or node text is visible, then
`tipoffset` added to `xmax`, then the exact default-bound message strings that
upstream `plotRCall.jl` interpolates into `xlim` and `ylim` errors. Use this
task to create the helper-level message owner, not to pretend the public entry
surface proof is already available.

### 5. Add annotation, midpoint, and explicit-limit-owner regressions

**Type**: TEST
**Output**: The repository has one direct annotation and bounds regression
suite that proves tranche-3-owned validation, midpoint, and helper-level
message-format behavior while rejecting fake closure of the public proof.
**Depends on**: 4
**Positive contract**: A new `test/test_annotation_data.jl` covers the exact
`nodelabel` warning and filtering cases, the exact `prepare_nodedataframe`
output, the exact `edgelabel` warning and filtered-row behavior, the exact
major-tree midpoint placement for minor edges, and the exact helper-level
default-bound message strings for malformed `xlim` and `ylim` inputs. The
fixture corpus is extended only where local source-owned regression data is
needed.
**Negative contract**: Do not assert that the currently unimplemented public
plotting surfaces already exercise those exact `xlim` / `ylim` messages. Do
not use docs-string policing, screenshots, or source-text audits as the main
proof. Do not move production logic into the test layer.
**Files**: `test/runtests.jl`; `test/support/fixture_corpus.jl`;
`test/test_annotation_data.jl`
**Out of scope**: `docs/`; render-level verification; public entry-surface API
tests; recipe integration; verification-foundation metadata
**Verification**: `julia --project=test test/runtests.jl` passes and fails the
current repository state because no local annotation-data owner or helper-level
explicit-limit owner exists there. The suite also fails any fake fix that keeps
missing first-column rows, suppresses warnings, uses horizontal-segment
midpoints in major-tree mode, or falsely marks the public `xlim` / `ylim`
proof closed.

Add direct tests for the local annotation-data and bounds owners. Use the
existing fixture corpus rows and warning strings as the source of truth, and
extend it only where exact local helper-level bounds or message strings need to
be recorded. Test the helper-level message owner directly with the exact bounds
that upstream `plotRCall.jl` would interpolate after label-driven expansion and
`tipoffset` adjustment. Keep the proof boundary honest: helper-level closure is
real here; public-surface proof is not.

### 6. Pass the tranche-3 owner state into source-backed verification and docs

**Type**: MIGRATE
**Output**: The verification foundation, keyword contract metadata, and docs
render the tranche-3 owner state and the corrected explicit-limit proof
boundary from source-owned data rather than from stale workflow prose.
**Depends on**: 3, 5
**Positive contract**: `src/verification_foundation.jl` gains a source-owned
layout and annotation owner block naming the canonical source files, the local
helper owners, the closed helper regressions, and the reviewer clear / reject
gate for tranche 3. `src/keyword_contract.jl` and
`test/test_keyword_contract.jl` are updated so the exact public
`xlim` / `ylim` proof is no longer mis-tagged as fully tranche-3-owned; the
metadata must instead state that tranche 3 closes the helper-level ingredients
and tranche 5 still owns direct public-surface proof. `docs/src/verification-foundation.md`
renders that data, and `docs/src/index.md` no longer describes a tranche-1-only
snapshot.
**Negative contract**: Do not create a second owner table that lives only in
docs or only in tests. Do not mark any public plotting surface as implemented.
Do not claim that tranche 3 already proved render-level behavior, recipe
integration, or public `xlim` / `ylim` entry-surface parity.
**Files**: `src/keyword_contract.jl`; `src/verification_foundation.jl`;
`test/test_keyword_contract.jl`; `test/test_verification_foundation.jl`;
`docs/src/verification-foundation.md`; `docs/src/index.md`
**Out of scope**: parent workflow docs; new public API docs pages; recipe
implementation; render adapter implementation
**Verification**: `julia --project=test test/runtests.jl` passes with updated
keyword-contract and verification-foundation tests. `julia --project=docs
docs/make.jl` passes and renders the layout-owner and corrected explicit-limit
proof sections from source-backed data. Removing the source-owned metadata or
restoring the stale docs snapshot causes tests or docs evaluation to fail.

Extend the tranche-1 and tranche-2 verification owner so it now passes forward
tranche-3 ownership and the corrected explicit-limit proof boundary explicitly.
Add a new source-owned layout-owner block to `VERIFICATION_FOUNDATION` rather
than leaving the new owner implicit in source files only. Use this task to
repair the stale docs truth boundary as well: the verification page should
render the tranche-3 owner and reviewer gate, and the docs index should say
truthfully that the repo now contains tranche-1 foundation, tranche-2 keyword
ownership, and tranche-3 layout and annotation ownership while render and
public entry surfaces remain deferred.
