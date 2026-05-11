---
date-created: 2026-05-10T19:03:21-07:00
date-updated: 2026-05-10T19:17:04-07:00
workflow-instrument: Tasking Plan
workflow-status: Approved
workflow-agent-thread-id: codex/019e14c0-3381-75c1-8cc9-72a24a3dec20
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-prd: .workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md
workflow-tranche: .workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md
---

# Tasks for tranche 7: Docs, migration, and final capability closure

## Approval state

- This file is approved tasking output for tranche 7 in `02_tranches.md`.
- This file is the authorized execution input for downstream
  `Tasks -> Execute` work on tranche 7.
- The tasking below remains fixed unless the project owner explicitly reopens
  it.

## Settled user decisions and environment baseline

- This tranche is tasked against the observed repository state on 2026-05-10,
  not against the older tranche-7 narrative alone. The live codebase is
  already post-tranche-6 for runtime ownership:
  `PlotKeywordSpec`, `normalize_plot_keywords`, `keyword_contract.jl`, and
  `keyword_normalization.jl` are absent from the accepted runtime path, and
  `PhyloPlotAttributes` is the sole accepted runtime semantic carrier.
- The accepted public owner is fixed input for this tranche:
  `Makie.@recipe(PhyloPlot, net)` plus
  `Makie.plottype(::PhyloNetworks.HybridNetwork) = PhyloPlot`, with
  `plot(net)`, `plot!(ax, net)`, `phyloplot`, and `phyloplot!` all remaining
  supported surfaces.
- Preserve the exact tranche-5 public attribute surface already live in
  `SUPPORTED_PHYLOPLOT_ATTRIBUTES` and
  `VERIFICATION_FOUNDATION.public_attribute_owner.supported_public_attributes`.
  Tranche 7 must not reopen attribute naming, grouping, omission, or
  `preorder` exposure decisions.
- Preserve the tranche-6 rejection boundary. Legacy public spellings such as
  `showtiplabel`, `xlim`, `ylim`, `nodelabel`, `edgelabel`, `edgecolor`, and
  `preorder` remain rejected at the public recipe boundary.
- The user-approved product direction is fixed input: capability parity is
  required, API mimicry is not, and the package must feel Makie-native rather
  than like a backend swap for `PhyloPlots.plot`.
- Legacy capability mapping belongs in documentation only. It must not
  reintroduce a runtime compatibility shell, a second semantic carrier, or a
  second public owner.
- R interoperability remains out of scope.
- No new plotting capabilities are authorized in this tranche beyond the
  accepted envelope already named in the PRD and design supplement.
- Preserve the root, `test/`, and `docs/` project split, current dependency
  baseline, and current path-override policy. Do not change dependency
  declarations, manifests, or source-set policy in this tranche.
- The installation truth boundary is settled for this tasking pass:
  no repo-owned source in scope proves General-registry installation, so the
  docs truth surface must not claim registry availability. README and docs may
  document GitHub-based or local-development installation paths only.
- On 2026-05-10:
  - `julia --project=test test/runtests.jl` passed `372/372` tests.
  - `julia --project=docs docs/make.jl` passed.
  - The docs build emitted only the known Documenter large-example PNG-fallback
    warnings on `public-api.md` and `render-verification.md`.
- Tranche 7 must begin and end from a green baseline at least this strong.
- Docs must adapt to the accepted API and runtime architecture. Do not broaden
  the API, restore legacy spellings, or reopen runtime cleanup merely to make
  prose read more familiar.

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
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-07_tranche-06--tasking-1.md`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`

Authority notes that remain active in this tasking file:

- The repo-local `STYLE*.md` set is the operative governance set for this
  repository.
- Bundled internal baseline files were found for
  `STYLE-agent-handoffs.md`, `STYLE-architecture.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-workflow-docs.md`,
  `STYLE-workflow-vocabulary.md`, and `STYLE-writing.md`.
- The bundled copies of `STYLE-agent-handoffs.md`, `STYLE-docs.md`,
  `STYLE-git.md`, `STYLE-julia.md`, `STYLE-upstream-contracts.md`,
  `STYLE-verification.md`, `STYLE-workflow-vocabulary.md`, and
  `STYLE-writing.md` are same-text baselines relative to the repo-local copies.
- The bundled copies of `STYLE-architecture.md` and
  `STYLE-workflow-docs.md` differ from the repo-local copies. Use the
  repo-local copies as the higher-priority authorities for this repository.
- No bundled internal `CONTRIBUTING.md` was found.
- No bundled internal `STYLE-makie.md` or `STYLE-vocabulary.md` was found.
- No repo-local `STYLE-python.md` or `STYLE-domain-vocabulary.md` was found.
- `STYLE-vocabulary.md` remains the domain vocabulary authority.
- `STYLE-workflow-vocabulary.md` remains authoritative for workflow terms such
  as `tranche`, `lock item`, `primary-goal lock`, `red-state repro`,
  `handoff packet`, and `verification artifact`.

Controlled vocabulary obligations that matter directly in this tranche:

- Use `Makie-native public plot owner` for the recipe owner.
- Use `public attribute surface` for the supported snake_case plotting surface.
- Use `capability parity` for preserved plotting outcomes.
- Use `legacy keyword surface` only for migration material, rejected spellings,
  or historical diagnosis.
- Treat `PhyloPlot` as an implementation-detail type.
- Treat `phyloplot` and `phyloplot!` only as thin convenience surfaces over the
  same Makie-native public plot owner.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, branch creation, rebase, and reset remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Primary-goal lock

### PRD lock item 2: Capability parity without API mimicry

- The work is not complete if users still cannot map the accepted
  `PhyloPlots.plot` visualization tasks to the Makie-native public surfaces,
  or if the package teaches the old keyword shell as the authoritative mental
  model.
- The direct red-state repro is the current repository state:
  there is no migration-guide page, `README.md` contains badges only, and the
  docs truth surface does not yet provide one explicit capability-to-surface
  mapping for the accepted design scenarios.
- The tasks that close this are task 1, task 2, and task 4.
- The verification artifact is the rendered migration guide plus fixture-backed
  public proof that covers the accepted design scenarios. The old repository
  shape fails because the migration guide and its proof mapping do not exist.

### PRD lock item 5: Makie composability and host-framework semantics

- The work is not complete if the final truth surface can go green while
  bang/non-bang semantics, `Makie.FigureAxisPlot` return expectations, or
  dual-axis composition drift behind package-facing docs.
- The direct red-state repro is the current repository state:
  the public plot-owner tests already prove composition and host semantics, but
  `VERIFICATION_FOUNDATION` still frames the verification owner as tranche-6
  runtime cleanup rather than as the final package closure that must keep those
  semantics live.
- The tasks that close this are task 3 and task 4.
- The verification artifact is the updated source-backed verification owner
  plus public-entrypoint tests that prove `plot(net)`, `plot!(ax, net)`,
  `phyloplot`, and `phyloplot!` remain aligned with the Makie host contract.
  The old metadata shape fails because it does not encode this as a final lock.

### PRD lock item 6: Honest docs and migration surface

- The work is not complete if `README.md`, `docs/src/index.md`, and the docs
  navigation still present PhyloMakie as a workflow snapshot, backend swap, or
  tranche inventory instead of as a Makie-native package with honest migration
  notes.
- The direct red-state repro is the current repository state:
  `README.md` has no package synopsis, installation path, or quickstart;
  `docs/src/index.md` opens by describing a rebuild and tranche history; and
  no migration-guide page exists.
- The tasks that close this are task 1 and task 2.
- The verification artifact is the rendered README-adjacent docs surface plus a
  migration guide that names the supported surfaces and intentional
  differences. The old repository shape fails because those pages and links are
  absent or misframed.

### PRD lock item 7: Honest verification surface

- The work is not complete if the repository can still go green while the
  package-facing truth surface drifts, the migration surface disappears, or the
  docs examples stop matching the accepted capability claims.
- The direct red-state repro is the current repository state:
  `VERIFICATION_FOUNDATION` has tranche-6-specific lock items and docs-surface
  inventory, omits `README.md` and a migration guide from the truth surface,
  and does not encode final package-closure proof obligations for the accepted
  capability scenarios.
- The tasks that close this are task 3 and task 4.
- The verification artifact is the updated `VERIFICATION_FOUNDATION`, its
  regression suite, and the public proof suite. The old repository shape fails
  because the metadata titles, inventories, and proof mapping are still
  tranche-6 oriented.

## Handoff packet

- Active authorities:
  `CONTRIBUTING.md`, every repo-local `STYLE*.md` file listed above, the
  revised design brief, the revised design supplement, the approved PRD, the
  revised tranche plan, tranche-6 tasking, and the tranche-4 Makie source-set
  note.
- Parent documents:
  `design/prod01-vision.md`,
  `design/prod01-vision-supplement.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-07_tranche-06--tasking-1.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`.
- Settled decisions and non-negotiables:
  teach the Makie-native package first; preserve the accepted public owner and
  public attribute surface; preserve capability parity without API mimicry; do
  not reopen runtime-carrier cleanup; do not claim General-registry
  installation; keep legacy capability mapping in docs only; keep R interop out
  of scope.
- Authorization boundary:
  aggressive rewrite of package-facing docs, migration material, and
  verification metadata is authorized; public API redesign is not reopened in
  this tranche; helper/render owner redesign is not in scope.
- Current-state diagnosis:
  the codebase is already post-tranche-6 for runtime ownership and public
  plotting, but the package truth surface is incomplete: README is skeletal,
  Home remains workflow-centric, no migration guide exists, and
  `VERIFICATION_FOUNDATION` still encodes tranche-6 closure rather than final
  package closure.
- Primary-goal lock:
  PRD lock items 2, 5, 6, and 7 as restated above.
- Direct red-state repros:
  missing migration page; empty README; Home page centered on rebuild/tranche
  framing; verification metadata still titled and scoped around tranche-6
  runtime cleanup.
- Owner and invariant under repair:
  the package truth surface, with `VERIFICATION_FOUNDATION` remaining the
  source-backed verification owner and `README.md` plus `docs/src/*.md`
  becoming honest user-facing consumers of the accepted public owner.
- Supported public surfaces affected by that owner or semantic:
  `plot(net)`, `plot!(ax, net)`, `phyloplot`, `phyloplot!`, the public
  attribute surface, the README quickstart, the Home page, the Public API page,
  the Migration guide, the Verification foundation page, and the Render
  verification page.
- Exact files or surfaces in scope:
  `README.md`,
  `docs/make.jl`,
  `docs/src/index.md`,
  `docs/src/public-api.md`,
  `docs/src/migration-guide.md`,
  `docs/src/verification-foundation.md`,
  `docs/src/render-verification.md`,
  `src/verification_foundation.jl`,
  `test/test_verification_foundation.jl`,
  `test/test_public_plot_owner.jl`,
  `test/support/fixture_corpus.jl`.
- Exact files or surfaces out of scope:
  `src/public_attribute_model.jl`,
  `src/layout_engine.jl`,
  `src/annotation_data.jl`,
  `src/render_adapter.jl`,
  `src/public_plot_owner.jl`,
  dependency manifests,
  any new capability beyond the accepted envelope,
  any runtime compatibility shell.
- Required upstream primary sources:
  `PhyloPlots.jl/src/phylonetworksPlots.jl`,
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl`,
  `PhyloPlots.jl/src/plotRCall.jl` as a legacy capability reference only,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/display.jl`,
  `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v/src/screen.jl`.
- Green-state gates:
  `julia --project=test test/runtests.jl`,
  `julia --project=docs docs/make.jl`,
  continued public-entrypoint proof for dual-axis composition and host
  semantics,
  continued live CairoMakie-backed docs artifacts.
- Stop conditions:
  stop if truthful docs closure appears to require restoring legacy public
  spellings, broadening the public API, or reopening runtime-ownership cleanup;
  stop if the repo is reverted below the post-tranche-6 code state described
  here; stop if proof would collapse to text-policing without live public or
  render artifacts.

## Required revalidation before implementation

- Read the tranche and parent PRD in full.
- Read the relevant code, tests, docs, and examples in full.
- Read all cited upstream primary sources in full where they constrain the
  work.
- Re-check the user-authorized disruption boundary before making deep changes.
- Reconfirm that the live repository still matches the post-tranche-6 baseline
  recorded here.
- If the diagnosis no longer matches reality, stop and raise that before
  changing code.

## Tranche execution rule

This tranche may rewrite package-facing prose, docs navigation, source-backed
verification metadata, and proof inventory aggressively where needed, but it
must begin and end in the required green state and must preserve the accepted
runtime and public-owner architecture already live in the codebase.

When the tranche is complete:

- the package truth surface must no longer read like workflow notes or a
  backend-swap narrative
- the migration surface must exist as documentation and must not exist as a
  runtime compatibility shell
- `VERIFICATION_FOUNDATION` must no longer behave like a tranche-6 closure note
  masquerading as final package truth
- docs must be brought into truth with the accepted API and current runtime
  architecture, not vice versa

Forbidden anti-fixes include:

- replacing missing docs closure with string-policing tests only
- recreating compatibility-shell semantics in prose, wrappers, or examples
- burying API differences inside vague "mostly the same" language
- moving migration logic into tests while leaving user-facing docs empty

## Non-negotiable execution rules

- Do not reopen public attribute naming, grouping, or omitted-control decisions.
- Do not reintroduce `PlotKeywordSpec`, `normalize_plot_keywords`, legacy
  spellings, or `preorder` onto the public surface.
- Do not weaken Makie bang/non-bang semantics to make docs examples simpler.
- Do not mutate caller-owned `HybridNetwork` values implicitly.
- Do not solve docs drift by inventing unsupported installation paths or by
  claiming General registration without repo-owned proof.
- Do not replace live CairoMakie-backed proofs with Markdown-string, YAML, SVG,
  or source-text checks as the only verification artifact.
- Do not add new plotting capabilities, change dependency policy, or change the
  root/test/docs project split in this tranche.

## Concrete anti-patterns or removal targets

- `README.md` staying as a badges-only stub.
- `docs/src/index.md` opening with rebuild and tranche framing instead of a
  package-first explanation.
- Docs navigation staying limited to Home, Public API, Verification foundation,
  and Render verification with no migration page.
- A migration guide that degenerates into a one-to-one keyword list without
  capability narrative, intentional-difference notes, or links to the live
  Makie-native surfaces.
- `VERIFICATION_FOUNDATION.lock_items` staying centered on tranche-6 runtime
  retirement titles instead of final PRD locks 2, 5, 6, and 7.
- `VERIFICATION_FOUNDATION.public_plot_owner.docs_surface` or equivalent truth
  inventory omitting `README.md` or the migration guide.
- Any partial truth-surface rewrite where README teaches the package first but
  the Verification foundation page or migration page still tells the old story.
- Any attempt to satisfy migration obligations by reintroducing a second public
  wrapper, compatibility shim, or shell-owner test.

## Failure-oriented verification

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- `test/test_verification_foundation.jl` must fail the current repository shape
  until the verification owner is retargeted from tranche-6 closure to final
  package closure.
- `test/test_public_plot_owner.jl` must fail if public-entrypoint proof can no
  longer demonstrate `plot(net)`, `plot!(ax, net)`, `phyloplot`, and
  `phyloplot!`, `Makie.FigureAxisPlot`, or dual-axis composition.
- The docs build must render Home, Public API, Migration guide, Verification
  foundation, and Render verification from live code. The current repository
  fails this because the Migration guide page and navigation entry do not yet
  exist.
- The positive user-facing proof is that a new user can follow README or Home
  and produce a plot without workflow-doc context, and a migrating user can use
  the Migration guide to map the accepted capability scenarios to the
  Makie-native surface honestly.
- The positive maintainer-facing proof is that `VERIFICATION_FOUNDATION`
  records one source-backed final truth surface, and the test suite plus docs
  build fail if that truth surface or its capability mapping drifts.

## Tasks

### 1. Rewrite the package landing and public API surfaces

**Type**: WRITE
**Output**: `README.md`, `docs/src/index.md`, and `docs/src/public-api.md`
teach PhyloMakie as a Makie-native package with a working first-use path.
**Depends on**: none

Rewrite the badges-only README and the workflow-centric landing prose so a new
user can understand what the package is, how to install it through a truthful
GitHub-based path, and how to make a first plot through `plot(net)` or
`plot!(ax, net)` without reading tranche history first. Keep the current live
Documenter example style in `docs/src/public-api.md`, but retitle and
restructure the prose so those examples read as supported public usage rather
than as implementation inventory. Follow the accepted public owner and public
attribute surface already live in `src/public_plot_owner.jl` and
`src/public_attribute_model.jl`; do not change them here.

**Positive contract**: a new user can read `README.md`, the Home page, and the
Public API page and learn what PhyloMakie is, what surfaces it supports, how
to install it truthfully, and how to make a first plot.
**Negative contract**: the landing surfaces must not frame the package as a
backend swap, a tranche snapshot, or a near-drop-in keyword recreation, and
they must not invent registry installation or legacy-shell promises.
**Files**: `README.md`, `docs/src/index.md`, `docs/src/public-api.md`
**Out of scope**: `docs/make.jl`, `docs/src/migration-guide.md`,
`src/verification_foundation.jl`, `src/public_plot_owner.jl`,
`src/public_attribute_model.jl`, any runtime or API change
**Verification**:
- `julia --project=docs docs/make.jl`
- Confirm the rendered Home and Public API pages still execute live examples.
- Confirm `README.md` now contains package synopsis, truthful installation
  guidance, and a quickstart plot example; the old repository shape fails here
  because the README has badges only.

### 2. Add the migration guide and wire it into the docs truth surface

**Type**: MIGRATE
**Output**: the docs include a `Migration guide` page in navigation that maps
accepted `PhyloPlots` capabilities to the Makie-native public surfaces and
documents intentional differences honestly.
**Depends on**: 1

Create `docs/src/migration-guide.md` and update `docs/make.jl`, `README.md`,
`docs/src/index.md`, and `docs/src/public-api.md` so the migration material is
reachable from every primary user-facing surface. Build the guide around the
accepted design scenarios already ratified in
`design/prod01-vision-supplement.md` and `FIXTURE_CORPUS.accepted_design_scenarios`:
style distinction, edge-length scaling, gamma display, node and edge
annotations, edge-color and width control, and dual-axis composition. Use the
current public snake_case attributes and supported public entry surfaces as the
target of the mapping. Legacy spellings and omitted controls belong in
rejection notes or intentional-difference notes only.

**Positive contract**: a migrating `PhyloPlots` user can answer "how do I do
the old task here?" from one honest package-owned page that points to the live
Makie-native surfaces.
**Negative contract**: the migration surface must not become a disguised
keyword-parity table, must not imply that the APIs are the same, and must not
suggest that a runtime compatibility shell survives behind the package.
**Files**: `docs/src/migration-guide.md`, `docs/make.jl`, `README.md`,
`docs/src/index.md`, `docs/src/public-api.md`
**Out of scope**: `src/verification_foundation.jl`, verification tests,
public-owner runtime semantics, any new capability beyond the accepted
envelope
**Verification**:
- `julia --project=docs docs/make.jl`
- Confirm the docs navigation includes `Migration guide`; the old repository
  shape fails because this page and nav entry do not exist.
- Confirm the guide contains explicit sections or tables for style distinction,
  edge lengths, gamma, annotations, edge-color and width control, dual-axis
  composition, and legacy-name rejection.

### 3. Reframe the source-backed verification owner around final package closure

**Type**: WRITE
**Output**: `VERIFICATION_FOUNDATION`, its docs page, and its regression tests
describe final package closure rather than tranche-6 runtime cleanup.
**Depends on**: 2

Keep `VERIFICATION_FOUNDATION` as the single source-backed verification owner,
but rewrite it so it closes the final PRD truth-surface problem rather than
recording a tranche-6 runtime migration snapshot. Retitle the lock items to
PRD lock items 2, 5, 6, and 7; add the final package truth surfaces to the
inventory, including `README.md`, Home, Public API, Migration guide,
Verification foundation, and Render verification; record the observed
2026-05-10 green baseline accurately; and map the accepted design scenarios to
their public or docs proof owners. Update `docs/src/verification-foundation.md`
so it continues to render from live metadata instead of freezing a hand-written
summary, and update `test/test_verification_foundation.jl` in the same task so
the repository remains green at task end.

**Positive contract**: a fresh maintainer can read one source-backed owner and
see the final package truth surfaces, final lock items, accepted capability
scenarios, proof owners, and current green-state gates without inferring them
from tranche history.
**Negative contract**: no tranche-6-only lock titles, no incomplete docs-surface
inventory, no shadow metadata constant, and no migration-guide omission may
survive as the final verification owner.
**Files**: `src/verification_foundation.jl`,
`docs/src/verification-foundation.md`, `test/test_verification_foundation.jl`
**Out of scope**: `src/public_plot_owner.jl`, `src/public_attribute_model.jl`,
helper/render owners, `README.md`, `docs/src/index.md`,
`docs/src/public-api.md`, `docs/src/migration-guide.md` prose beyond minimal
link or heading adjustments needed to keep the metadata truthful
**Verification**:
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- `test/test_verification_foundation.jl` must fail the current repository
  shape because the lock items, docs-surface inventory, and current-status
  facts are still tranche-6 oriented.

### 4. Strengthen public capability-closure proof against docs and migration drift

**Type**: TEST
**Output**: public-entrypoint tests and live docs examples fail if the accepted
capability scenarios, host semantics, or migration claims drift behind a green
docs build.
**Depends on**: 3

Extend the public proof surface so each accepted design scenario in
`FIXTURE_CORPUS.accepted_design_scenarios` is closed by a named public or docs
artifact, not only by helper or render-owner regressions. Reuse the existing
fixture corpus, public-owner tests, and live CairoMakie-backed docs examples.
Strengthen `test/test_public_plot_owner.jl` and, if needed, the fixture corpus
and the docs example pages so the suite proves `plot(net)`, `plot!(ax, net)`,
`phyloplot`, and `phyloplot!` stay aligned with the migration guide, keep the
`Makie.FigureAxisPlot` and mutating-axis contracts, and preserve dual-axis
composition and the accepted scenario-level capabilities. Keep the proof at the
public-entrypoint or live docs-example boundary; do not replace it with helper
assertions, source-text policing, or legacy wrapper tests.

**Positive contract**: every accepted capability scenario named in the
Migration guide and `VERIFICATION_FOUNDATION` has a maintained public proof
artifact, and the docs examples remain synchronized with that proof set.
**Negative contract**: no helper-only proxy can stand in for a public-surface
or docs-surface proof, no separate legacy-wrapper proof surface is introduced,
and no migration check is accepted if it only inspects prose text.
**Files**: `test/test_public_plot_owner.jl`, `test/support/fixture_corpus.jl`,
`docs/src/public-api.md`, `docs/src/render-verification.md`,
`docs/src/migration-guide.md`
**Out of scope**: helper/render algorithm changes, public attribute redesign,
runtime-owner changes, dependency edits, any new plotting capability outside
the accepted envelope
**Verification**:
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- Confirm the strengthened capability-closure checks fail the old repository
  shape because the migration guide and its public proof mapping do not yet
  exist.
