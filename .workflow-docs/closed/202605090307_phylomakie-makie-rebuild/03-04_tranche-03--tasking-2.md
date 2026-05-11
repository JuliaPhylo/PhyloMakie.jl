---
date-created: 2026-05-10T00:49:47-07:00
workflow-instrument: Tasking Plan
workflow-status: Completed
workflow-agent-thread-id: codex/019e102f-3917-77c3-9908-9966ee33fc1b
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-prd: .workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md
workflow-tranche: .workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md
---

# Tasks for tranche 3: Layout and annotation data owner remediation

## Approval state

- This file is proposed remedial tasking for tranche 3 after the first
  tranche-3 implementation landed only a partial closeout.
- `03-03_tranche-03--tasking-1.md` remains the historical approved tasking
  record for the first tranche-3 attempt. This file is the new downstream
  execution control once approved.
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
- Use documented public `Pkg` operations to curate root, `test/`, and `docs/`
  environments. Do not hand-edit manifests as a first resort.
- The current `preorder=true` behavior is still a settled public mutation
  boundary for this production run. Tranche 3 may make that boundary explicit
  and locally owned, but it may not silently change the default or weaken the
  behavior.
- Exact direct public `xlim` / `ylim` error-path proof remains deferred to
  tranche 5 because `phyloplot`, `phyloplot!`, and `plot(net)` are still
  unimplemented.
- The already landed `src/layout_engine.jl` and `src/annotation_data.jl` files
  are the canonical partial tranche-3 base. The remediation work must repair,
  verify, and truthfully migrate these owners rather than creating second
  owners or re-porting the same semantics into different files.
- The previously approved tranche-3 tasking overstates one proof target for the
  all-edge-lengths-missing fallback. The upstream helper keeps minor-edge
  horizontal x extents gated by the original `useedgelength` flag even when it
  falls back to calculated lengths, so the honest tranche-3 proof target is
  exact upstream parity for the `useedgelength=true` fallback branch, not
  equality with the `useedgelength=false` full-tree tuple.

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

Authority notes that remain active in this remedial tasking file:

- The repo-local `STYLE*.md` set is the operative governance set for this run.
- The overlapping bundled baseline files named by `development-policies` are
  present, but the repo-local copies control this repository.
- No repo-local `STYLE-domain-vocabulary.md` was found.
- No repo-local `STYLE-python.md` was found.
- `STYLE-vocabulary.md` remains the domain vocabulary authority.
- `STYLE-workflow-vocabulary.md` remains authoritative for workflow terms such
  as `tranche`, `lock item`, `primary-goal lock`, `red-state repro`, and
  `verification artifact`.

Controlled vocabulary obligations that matter directly in this remediation:

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

## Current-state diagnosis

The tranche-3 diagnosis has changed materially since the first tasking file was
approved.

- `src/layout_engine.jl` and `src/annotation_data.jl` now exist and already
  look like the intended canonical owners.
- The repository is not green. On 2026-05-10,
  `julia --project=test test/runtests.jl` failed because:
  `test/test_PhyloMakie.jl` still expects the old three-include shell,
  Aqua reports missing `PhyloNetworks` compat, and JET reports that
  `child_y` may be undefined in `src/layout_engine.jl`.
- On the same date, `julia --project=docs docs/make.jl` failed while loading
  `PhyloMakie` because the landed dependency change was not fully resolved for
  the repo-local docs path build.
- No `test/test_layout_engine.jl` or `test/test_annotation_data.jl` exists.
  The local fixture corpus still records only the old input cases and warning
  strings rather than the exact geometry tuples, annotation tables, fallback
  branch repros, and helper-level bounds/message outputs that tranche 3 now
  owns.
- `src/keyword_contract.jl`, `src/verification_foundation.jl`,
  `docs/src/verification-foundation.md`, and `docs/src/index.md` still tell the
  tranche-1 or tranche-2 story, so the source-backed verification surface is
  currently false even if the landed helper code is mostly correct.
- The first tranche-3 tasking file became partially stale after the review
  tightening around the all-edge-lengths-missing fallback. The new remedial
  tasking must correct that proof target instead of propagating it.

This is not primarily a missing-user-decision failure. The major settled
decisions were already present. The failure is that the first implementing
attempt stopped after partial owner landing and did not carry through the
required green-state restoration, proof-surface creation, or source-backed
truth migration.

## Primary-goal lock

### Lock item 1: Restore a real tranche-3 green baseline

- The work is not complete if the current partial tranche-3 landing still
  leaves the repo in a red state before the new proof surfaces are added.
- The direct red-state repro is the 2026-05-10 state:
  `julia --project=test test/runtests.jl` fails with shell-owner expectation
  drift, missing `PhyloNetworks` compat, and a JET undefined-variable finding;
  `julia --project=docs docs/make.jl` fails while loading `PhyloMakie`.
- The task that closes this is task 1.
- The verification artifact is a green `julia --project=test test/runtests.jl`
  and a green `julia --project=docs docs/make.jl` before any new tranche-3
  proof suites are introduced.

### Lock item 2: Close the geometry proof surface with the correct fallback contract

- The work is not complete if the landed layout owner can still ship without a
  direct local geometry regression suite for the three accepted style and
  edge-length tuples, the two level-2 tuples, the mixed missing-length warning
  path, the all-edge-lengths-missing fallback print path, the appended
  `RootMismatch` guidance sentence, and the explicit `preorder=true` /
  `preorder=false` mutation boundary.
- The direct red-state repro is the current repository state:
  no local layout regression file exists, no exact tuple data exists in the
  fixture corpus, and the first tasking file incorrectly says the all-missing
  fallback should equal the `useedgelength=false` full-tree tuple.
- The task that closes this is task 2.
- The verification artifact is one local `test/test_layout_engine.jl` suite and
  source-owned regression data that fail the current repository state and also
  fail the withdrawn equality anti-fix for the all-missing fallback branch.

### Lock item 3: Close the annotation and helper-level bounds proof surface

- The work is not complete if `nodelabel` and `edgelabel` warning parity,
  filtered-row behavior, prepared node and edge tables, major-tree minor-edge
  midpoint placement, and helper-level exact default-bounds / message-format
  behavior can still drift without a direct local proof surface.
- The direct red-state repro is the current repository state:
  no local annotation regression file exists, no local helper-level bounds
  message regression exists, and the tranche-3 owner surface is only spot-
  checked indirectly.
- The task that closes this is task 3.
- The verification artifact is one local `test/test_annotation_data.jl` suite
  and the matching fixture data that fail the current repository state and fail
  midpoint-offset or warning-suppression anti-fixes.

### Lock item 4: Repair the source-backed truth surface

- The work is not complete if the source-backed keyword contract, verification
  foundation, and docs pages still present the tranche-1 or tranche-2 story, or
  if they falsely claim that full public `xlim` / `ylim` proof is already
  closed in tranche 3.
- The direct red-state repro is the current repository state:
  `src/keyword_contract.jl` still marks tranche-3-owned helper contracts as
  deferred, `src/verification_foundation.jl` still records tranche-1 baseline
  red states, and `docs/src/index.md` still describes a tranche-1-only
  snapshot.
- The task that closes this is task 4.
- The verification artifact is updated source-owned metadata, updated
  verification tests, and a rendered docs build that fail if the stale story or
  the false public-proof claim returns.

### Lock item 5: Unblock tranche 4 honestly

- The work is not complete if a fresh tranche-4 implementing agent would still
  have to decide whether to trust the landed owners, recreate geometry or
  annotation logic in the render layer, or infer the remaining deferred proof
  boundary from review prose alone.
- The direct red-state repro is the current repository state:
  helper owners exist in `src/`, but no local closeout proof names them as the
  canonical owners and no source-backed docs table states clearly what tranche 3
  closed and what tranche 4 or tranche 5 still own.
- The tasks that close this are task 2, task 3, and task 4.
- The verification artifact is a source-backed owner table and docs narrative
  that make the canonical owner, the closed helper contracts, and the deferred
  public-surface contracts explicit for the next tranche.

## Handoff packet

- Active authorities: `CONTRIBUTING.md`; all repo-local root `STYLE*.md`
  files; `STYLE-vocabulary.md`; `STYLE-workflow-vocabulary.md`;
  `design/prod01-vision.md`; `design/prod01-vision-supplement.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`.
- Parent documents:
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`;
  `design/prod01-vision.md`; `design/prod01-vision-supplement.md`;
  `03-03_tranche-03--tasking-1.md`.
- Settled decisions and non-negotiables: preserve the `PhyloPlots.plot`
  behavior target; keep `phyloplot`, `phyloplot!`, and `plot(net)` as the
  target public surfaces without implementing them here; keep `HybridNetwork`
  as the only supported public input type; keep R interop out of scope;
  preserve the root / `test/` / `docs/` project split and path overrides; keep
  `preorder=true` mutation behavior explicit; keep direct public
  `xlim` / `ylim` proof deferred to tranche 5; treat the already landed
  `src/layout_engine.jl` and `src/annotation_data.jl` as the canonical base to
  repair rather than optional prototypes.
- Authorization boundary: internal layout-owner, annotation-owner, and
  verification-owner repair is allowed; visible geometry drift, warning drift,
  midpoint drift, or public plotting-surface implementation is not.
- Current-state diagnosis: partial helper owners landed, but the repo is red,
  the helper proof surface is missing, the source-backed truth surface is
  stale, and one fallback proof target in the previous tasking is inaccurate.
- Primary-goal lock: the 5 lock items above.
- Direct red-state repros: current test-suite and docs-build failures; absent
  `test/test_layout_engine.jl`; absent `test/test_annotation_data.jl`; stale
  `VERIFICATION_FOUNDATION`; stale `docs/src/index.md`.
- Owner and invariant under repair: one Makie-independent layout engine owns
  geometry; one annotation-data owner owns validation, midpoint placement, and
  helper-level bounds/message ingredients; the verification owner and docs must
  state that truth explicitly.
- Supported public surfaces affected by that owner or semantic:
  `phyloplot`, `phyloplot!`, and `plot(net)` consume these owners later and
  therefore remain named as deferred public-surface proofs for tranche 5;
  `docs/src/index.md` and `docs/src/verification-foundation.md` are the
  immediate truth surfaces that must move now.
- Exact files or surfaces in scope: `Project.toml`; `Manifest.toml`;
  `test/Project.toml`; `test/Manifest.toml`; `docs/Manifest.toml`;
  `src/layout_engine.jl`; `src/annotation_data.jl`; `src/keyword_contract.jl`;
  `src/verification_foundation.jl`; `test/runtests.jl`;
  `test/test_PhyloMakie.jl`; `test/test_keyword_contract.jl`;
  `test/test_verification_foundation.jl`; `test/support/fixture_corpus.jl`;
  `test/test_layout_engine.jl`; `test/test_annotation_data.jl`;
  `docs/src/index.md`; `docs/src/verification-foundation.md`.
- Exact files or surfaces out of scope: public plotting entrypoints; recipe
  code; Makie primitive composition; render-level colors and text drawing;
  compatibility aliases; R interoperability; parent PRD and tranche files.
- Required upstream primary sources: `PhyloPlots.jl/src/phylonetworksPlots.jl`;
  `PhyloPlots.jl/src/plotRCall.jl`; `PhyloPlots.jl/test/test_phylonetworkPlots.jl`;
  `PhyloNetworks.jl/src/manipulateNet.jl`; `PhyloNetworks.jl/src/types.jl`;
  `PhyloNetworks.jl/docs/src/man/net_plot.md`.
- Green-state gates: `julia --project=test test/runtests.jl`;
  `julia --project=docs docs/make.jl`; the new layout regression suite; the new
  annotation regression suite; Aqua and JET as supplemental proof inside the
  test suite.
- Stop conditions: stop if the only way to match geometry or midpoint behavior
  is a render-layer workaround; stop if preserving accepted behavior appears to
  require changing the public `preorder` default; stop if direct public
  `xlim` / `ylim` proof would require pretending that unimplemented entry
  surfaces already exist; stop if the work would need to modify
  `.workflow-docs/.../01_prd.md` or `.workflow-docs/.../02_tranches.md`.

## Required revalidation before implementation

- Read `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`
  and `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md` in
  full.
- Read all governance files named above line by line.
- Re-read `src/PhyloMakie.jl`, `src/layout_engine.jl`, `src/annotation_data.jl`,
  `src/keyword_contract.jl`, `src/keyword_normalization.jl`,
  `src/verification_foundation.jl`, `test/test_PhyloMakie.jl`,
  `test/test_keyword_contract.jl`, `test/test_keyword_normalization.jl`,
  `test/test_verification_foundation.jl`, `test/support/fixture_corpus.jl`,
  `docs/src/verification-foundation.md`, and `docs/src/index.md` in full.
- Re-read `PhyloPlots.jl/src/phylonetworksPlots.jl`,
  `PhyloPlots.jl/src/plotRCall.jl`, and
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl` in full.
- Re-read `PhyloNetworks.jl/src/manipulateNet.jl`,
  `PhyloNetworks.jl/src/types.jl`, and
  `PhyloNetworks.jl/docs/src/man/net_plot.md` in full.
- Re-run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` before modifying code so the remediation
  starts from the current partial red state rather than from recollection.
- Re-check that the landed `src/layout_engine.jl` and `src/annotation_data.jl`
  files still exist and are still the canonical tranche-3 base. If they were
  reverted or replaced, stop and rewrite this remediation tasking against the
  current code.
- Re-check that the all-edge-lengths-missing fallback still follows the
  upstream branch where `elenCalculate=true` but the minor-edge x logic
  continues to branch on `useedgelength`. If upstream or current local code no
  longer behaves this way, stop and rewrite task 2 honestly.

## Tranche execution rule

This remediation may repair, tighten, or partially rewrite the landed
tranche-3 helper owners, but it must begin and end in a green, policy-compliant
state for its scope.

When this remediation completes:

- the repository must have one canonical Makie-independent geometry owner in
  `src/layout_engine.jl`;
- the repository must have one canonical annotation-data and helper-level
  bounds owner in `src/annotation_data.jl`;
- the repository must have direct local regression suites for those owners;
- the source-backed verification foundation and docs must state truthfully that
  tranche 3 closes the local helper owners and helper-level bounds/message
  ingredients, while render-level proof and direct public-surface proof remain
  deferred.

When this remediation completes, the following must no longer survive as
acceptable shapes:

- a red repo that still claims a tranche-3 delivery;
- a second geometry or annotation implementation outside the canonical owner
  files;
- tests or docs that still describe the repo as a tranche-1-only snapshot;
- the false claim that the all-missing fallback should equal the
  `useedgelength=false` full-tree tuple;
- any implication that full public `xlim` / `ylim` error-path proof is already
  closed before tranche 5.

Docs truth-boundary rule for this remediation:

- Docs may describe the landed local layout engine, annotation-data owner, and
  the still-deferred public plotting surfaces.
- Docs must not claim that `phyloplot`, `phyloplot!`, or `plot(net)` are
  implemented.
- Docs must not claim that full public `xlim` / `ylim` error-path parity is
  proven in tranche 3.
- Docs should state that tranche 3 closes the local helper owners and the
  helper-level bounds/message ingredients while render adapter work and direct
  public proof remain deferred.

## Non-negotiable execution rules

- Do not create second-generation owner files such as a new layout owner or a
  new annotation owner under different names. Repair the landed owners in
  `src/layout_engine.jl` and `src/annotation_data.jl`.
- Do not implement `phyloplot`, `phyloplot!`, `plot(net)`, `Makie.plottype`, or
  `@recipe` behavior in this remediation.
- Do not implement Makie primitives, text plotting, axis ownership, or render
  ordering in this remediation.
- Do not call `PhyloPlots.jl` at runtime for geometry, warnings, midpoint
  placement, or bounds computation.
- Do not leave `preorder=true` mutation behavior implicit.
- Do not change the default `preorder` value or reinterpret `preorder=false`.
- Do not solve midpoint drift by adding render-time offsets.
- Do not keep annotation validation in the keyword owner.
- Do not keep or recreate the withdrawn all-missing fallback equality claim in
  tests, docs, or metadata.
- Do not mark the direct public `xlim` / `ylim` proof closed in tranche 3.
- Do not add `Makie`, `CairoMakie`, `RCall`, or `PhyloPlots` as direct
  dependencies in this remediation.
- Do not modify `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`
  or `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`.

## Concrete anti-patterns or removal targets

- The hard-coded three-include shell-owner expectation in `test/test_PhyloMakie.jl`.
- The missing `PhyloNetworks` compat and unresolved repo-local manifests that
  leave tests or docs red after the dependency change.
- Any undefined-variable suppression trick that quiets JET without making the
  traversal branch explicit.
- Any local geometry proof that compares the all-missing fallback branch to the
  `useedgelength=false` full-tree tuple instead of asserting its own exact
  source-owned tuple.
- Any render-layer repair of geometry, bounds, or annotation midpoints.
- Any second implementation of annotation filtering or warning emission outside
  the canonical annotation-data owner.
- Any stale `keyword_contract.jl` or `verification_foundation.jl` metadata that
  still says tranche 3 has not closed the helper-level owners.
- Any stale `docs/src/index.md` wording that still describes the repo as a
  tranche-1-only snapshot after the closeout lands.
- Any source-text-only policing in place of the direct regression suites this
  tranche now owes.

## Failure-oriented verification

- Baseline verification must fail the current 2026-05-10 partial landing by
  reproducing the red `test/runtests.jl` and `docs/make.jl` runs before repairs
  are made.
- Geometry verification must use exact local regression data for the three
  accepted edge-length/style cases and the two level-2 network cases from
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl`.
- The all-edge-lengths-missing verification must fail if the test is weakened to
  compare against the `useedgelength=false` full-tree tuple or if the exact
  fallback print line disappears.
- Root-mismatch verification must fail if the appended guidance sentence
  disappears from the rethrown `RootMismatch`.
- Annotation verification must fail if rows with missing first-column values
  survive the local owner, if invalid first-column types fail to warn, or if
  unmatched node or edge numbers fail to warn.
- Midpoint verification must fail if major-tree minor-edge label coordinates use
  the horizontal-segment midpoint instead of the diagonal minor-edge midpoint.
- Helper-level explicit-limit verification must fail if the canonical annotation
  repro no longer produces:
  `xlim needs to contain 2 values: lower and upper limits. defaults: [0.6,5.44]`
  and
  `ylim needs to contain 2 values: lower and upper limits. defaults: [0.5,4.5]`.
- Metadata and docs verification must fail if the source-backed owner table or
  the docs index returns to the stale tranche-1-only story, or if the direct
  public `xlim` / `ylim` proof is falsely marked closed now.
- Positive maintainer-facing verification is also required: after the work,
  the source-backed verification page must make it obvious that tranche 4 can
  trust `PlotLayout` as the canonical helper payload and that tranche 5 still
  owns direct public entry-surface proof.

## Tasks

### 1. Restore the partial tranche-3 landing to a green baseline

**Type**: WRITE
**Output**: The existing partial tranche-3 landing remains the canonical source
base, and the repo-local test and docs gates are green again before new proof
surfaces are added.
**Depends on**: none
**Positive contract**: The root, `test/`, and `docs/` environments resolve the
landed `PhyloNetworks` dependency cleanly without changing the approved
project split or path-override policy. `test/test_PhyloMakie.jl` truthfully
describes the current thin shell, Aqua no longer reports a missing dependency
compat entry, JET no longer reports an undefined `child_y` branch in
`src/layout_engine.jl`, and the current suite plus docs build are green again.
**Negative contract**: Do not create new owner files, do not revert
`src/layout_engine.jl` or `src/annotation_data.jl`, do not change
`docs/Project.toml`, and do not broaden the public API surface.
**Files**: `Project.toml`; `Manifest.toml`; `test/Project.toml`;
`test/Manifest.toml`; `docs/Manifest.toml`; `src/layout_engine.jl`;
`test/test_PhyloMakie.jl`
**Out of scope**: `src/annotation_data.jl`; new regression suites;
`src/keyword_contract.jl`; `src/verification_foundation.jl`; docs page text;
public plotting entrypoints
**Verification**: Re-run `julia --project=test test/runtests.jl` and
`julia --project=docs docs/make.jl`. These commands must now pass, and they
must fail on the current 2026-05-10 partial landing state recorded in this
tasking.

Treat the already landed helper files as the canonical tranche-3 base. Repair
the environment and baseline code around them rather than starting over.
Curate the dependency state with public `Pkg` operations so the root, `test/`,
and `docs/` path-based package loads all resolve cleanly after the dependency
addition. Add the missing `PhyloNetworks` compat entry. Update the shell-owner
test from the old three-include shape to the current five-include shape.
Rewrite the `usedirecthybridline` branch in `src/layout_engine.jl` so `child_y`
is always initialized along every control-flow path that JET sees, while
preserving the current geometry semantics exactly.

### 2. Add geometry closeout proofs for the landed layout owner

**Type**: TEST
**Output**: The repository has one direct local geometry regression suite and
source-owned regression corpus that prove the landed layout owner rather than
merely assuming it.
**Depends on**: 1
**Positive contract**: `test/support/fixture_corpus.jl` gains exact geometry
data for the three accepted style and edge-length regressions and the two
level-2 regressions from upstream, plus explicit fixture entries for the
all-edge-lengths-missing fallback repro and the incompatible-root repro. A new
`test/test_layout_engine.jl` proves exact tuple parity, the mixed
missing-length warning branch, the exact fallback print line
`"All edge lengths are missing, won't be used for plotting."`, the appended
`RootMismatch` guidance sentence, and the explicit `preorder=true` /
`preorder=false` mutation boundary. The all-missing fallback proof stores and
checks its own exact tuple for `useedgelength=true`; it does not compare that
branch to the `useedgelength=false` full-tree tuple.
**Negative contract**: Do not call upstream `PhyloPlots` helpers from test
assertions. Do not weaken proof to screenshots, approximate checks, or
`returns something`. Do not keep the withdrawn all-missing equality claim in
any assertion, comment, or fixture name.
**Files**: `src/layout_engine.jl`; `test/runtests.jl`;
`test/support/fixture_corpus.jl`; `test/test_layout_engine.jl`
**Out of scope**: `src/annotation_data.jl`; `src/keyword_contract.jl`;
`src/verification_foundation.jl`; docs pages; public entry-surface tests;
render-level proofs
**Verification**: `julia --project=test test/runtests.jl` passes with the new
layout suite. Reverting to the current repository state, removing the new
fixture data, or restoring the false fallback-equality assertion must fail the
suite.

Add direct local tests for the canonical layout owner. Use the exact tuples
already asserted upstream for:
`useedgelength=true` with full-tree style,
`useedgelength=true` with major-tree style,
`useedgelength=false` with major-tree style,
and the two exact level-2 network tuples at the end of
`PhyloPlots.jl/test/test_phylonetworkPlots.jl`.
For the all-edge-lengths-missing repro
`readnewick("((((B)#H1:::0.2)#H2,((D,C,#H2)S1,(#H1,A)S2)S3)S4);")`,
record a literal source-owned expected tuple for the `useedgelength=true`,
`style=:fulltree` branch and assert that exact tuple directly.
Also add one incompatible-root repro with
`readnewick("((a,(b)#H1)i1,(#H1,c)i2)root:0.5;")` and `rooti = 2`,
asserting that the rethrown `RootMismatch` preserves the appended guidance
sentence exactly.
If any new direct assertion exposes geometry drift, repair only
`src/layout_engine.jl` to exact upstream parity before declaring the task done.

### 3. Add annotation and helper-level bounds closeout proofs for the landed layout payload

**Type**: TEST
**Output**: The repository has one direct local annotation and helper-level
bounds regression suite that proves the landed `PlotLayout` payload and the
annotation-data owner.
**Depends on**: 2
**Positive contract**: A new `test/test_annotation_data.jl` proves the exact
`nodelabel` warning and filtering cases, the exact prepared node table, the
exact `edgelabel` warning and filtered-row behavior, the exact prepared edge
table for the canonical major-tree repro, the major-tree minor-edge midpoint
coordinates, and the helper-level exact default-bounds / malformed-limit
message strings for the canonical annotation repro. The fixture corpus is
extended only where the local owner now owns exact table or bounds/message
data.
**Negative contract**: Do not assert that the unimplemented public plotting
surfaces already exercise those exact `xlim` / `ylim` messages. Do not move
production logic into the test layer. Do not replace midpoint proof with
render-time screenshots or source-text audits.
**Files**: `src/annotation_data.jl`; `test/runtests.jl`;
`test/support/fixture_corpus.jl`; `test/test_annotation_data.jl`
**Out of scope**: `src/keyword_contract.jl`; `src/verification_foundation.jl`;
docs pages; render adapter work; public entry-surface API tests
**Verification**: `julia --project=test test/runtests.jl` passes with the new
annotation suite. Reverting to the current repository state, keeping missing
first-column rows, suppressing warnings, or using horizontal-segment midpoints
for major-tree minor edges must fail the suite.

Add direct tests for the local annotation-data and helper-level bounds owners.
Use the existing warning strings and row fixtures as the source of truth and
extend them with exact prepared tables and bounds/message values where the
current owner now owns that contract. For the canonical major-tree annotation
repro, assert the exact helper-level bounds and messages:
`xlim needs to contain 2 values: lower and upper limits. defaults: [0.6,5.44]`
and
`ylim needs to contain 2 values: lower and upper limits. defaults: [0.5,4.5]`.
If any new direct assertion exposes drift, repair only `src/annotation_data.jl`
and, if strictly required by midpoint ownership, `src/layout_engine.jl` before
declaring the task done.

### 4. Migrate tranche-3 closeout truth into the source-backed verification and docs surface

**Type**: MIGRATE
**Output**: The verification foundation, keyword contract metadata, and docs
render the real tranche-3 closeout state and the remaining deferred public
proof boundary from source-owned data.
**Depends on**: 2, 3
**Positive contract**: `src/verification_foundation.jl` gains one
source-owned `layout_annotation_owner` block that names the canonical source
files, the closed helper regressions, the still-deferred render and direct
public-surface proofs, and a reviewer clear / reject gate for tranche 3
closeout. `src/keyword_contract.jl` and `test/test_keyword_contract.jl` are
updated so `nodelabel` and `edgelabel` use the exact status symbol
`:helper_validation_closed_public_surface_proof_deferred`, `xlim` and `ylim`
use the exact status symbol
`:structural_validation_closed_helper_message_closed_public_surface_proof_deferred`,
and all four remaining direct-public-proof deferrals point at tranche 5. The
docs pages render that source-backed state and no longer describe a tranche-1-
only snapshot.
**Negative contract**: Do not create a second owner table that lives only in
docs or only in tests. Do not mark any public plotting surface as implemented.
Do not claim that tranche 3 already proved render-level behavior, recipe
integration, or direct public `xlim` / `ylim` entry-surface parity. Do not
reintroduce the withdrawn all-missing fallback equality claim as if it were a
real contract.
**Files**: `src/keyword_contract.jl`; `src/verification_foundation.jl`;
`test/test_keyword_contract.jl`; `test/test_verification_foundation.jl`;
`docs/src/verification-foundation.md`; `docs/src/index.md`
**Out of scope**: parent workflow docs; new public API docs pages; recipe
implementation; render adapter implementation; public plotting entry-surface
tests
**Verification**: `julia --project=test test/runtests.jl` passes with updated
metadata tests. `julia --project=docs docs/make.jl` passes and renders the new
layout/annotation owner block and the corrected deferred-proof boundary from
source-backed data. Removing the source-owned owner block, restoring the stale
docs snapshot, or falsely marking direct public proof closed must fail tests or
docs evaluation.

Extend the source-backed verification surface so tranche 4 can inherit a stable
and honest owner map. Update `VERIFICATION_FOUNDATION` to say explicitly that
`src/layout_engine.jl` and `src/annotation_data.jl` are the canonical tranche-3
helper owners, that their helper-level regressions are closed here, that render
adapter visibility proof remains tranche-4-owned, and that direct public entry-
surface proof remains tranche-5-owned. Update the docs index to say truthfully
that the repository now contains tranche-1 foundation, tranche-2 keyword
ownership, and tranche-3 layout / annotation ownership while render-level and
direct public entry-surface work remain deferred.

No `REVIEW` task is needed in this remedial set. The remaining work is fully
derivable from the current code, the approved PRD and tranche plan, the active
governance documents, the recorded red-state repros, and the upstream primary
sources named above.
