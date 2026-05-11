---
date-created: 2026-05-10T20:36:01-07:00
date-updated: 2026-05-10T20:36:01-07:00
workflow-instrument: Tasking Plan
workflow-status: Approved
workflow-agent-thread-id: codex/019e14c0-3381-75c1-8cc9-72a24a3dec20
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-prd: .workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md
workflow-tranche: .workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md
---

# Tasks for tranche 7 remediation: docs truth and proof repairs

## Approval state

- This file is proposed remedial tasking for tranche 7 in `02_tranches.md`.
- It narrows execution to three review-backed corrections accepted by the
  project owner on 2026-05-10.
- It does not reopen tranche-7 architecture, public attribute policy, runtime
  ownership, or capability scope.
- No `REVIEW` task is required in this follow-up because the corrective
  choices are derivable from the approved tranche-7 tasking, the live codebase,
  and the accepted review findings.

## Settled user decisions and environment baseline

- Treat `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-08_tranche-07--tasking-1.md`
  as approved parent tasking input. This remedial file corrects its delivered
  truth surfaces; it does not replace tranche-7 goals.
- The remediation scope is fixed by the user-approved review findings:
  the first-use docs must show the backend install they rely on, volatile test
  counts must be removed from `VERIFICATION_FOUNDATION.current_status`, and
  `docs/src/public-api.md` must contain a real pure-tree `plot(net)` example
  that honestly backs `simple_tree_no_hybrid`.
- Preserve the accepted Makie-native public owner and supported public
  surfaces already live in the codebase:
  `plot(net)`, `plot!(ax, net)`, `phyloplot`, and `phyloplot!`.
- Preserve the accepted public attribute surface, legacy-spelling rejection
  boundary, and "docs must adapt to the accepted API" rule from tranche 7.
- Preserve the installation truth boundary:
  this repository may document GitHub-based installation and local development
  paths only. Do not claim General-registry installation.
- Preserve the current dependency baseline and project split:
  root package env, `test/` env, and `docs/` env remain separate.
- The live repository was green on the 2026-05-10 tranche-7 review pass for
  the full test suite and docs build. This remediation may rely on that green
  baseline, but it must not freeze exact test counts into source-backed truth
  metadata.
- No new plotting capability is authorized in this remediation. The new
  public-api tree example is proof of an accepted scenario, not a feature
  expansion.
- R interoperability remains out of scope.

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
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`

Authority notes that remain active in this remediation:

- `STYLE-vocabulary.md` remains authoritative for domain terms such as
  `Makie-native public plot owner`, `capability parity`, `public attribute
  surface`, and `legacy keyword surface`.
- `STYLE-workflow-vocabulary.md` remains authoritative for workflow terms such
  as `lock item`, `red-state repro`, `handoff packet`, and `verification
  artifact`.
- `STYLE-upstream-contracts.md` still applies because the docs and
  verification surfaces continue to describe Makie bang and non-bang host
  semantics and CairoMakie-backed examples.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, branch creation, rebase, and reset remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Primary-goal lock

### Remediation lock item 1: truthful first-use installation path

- The work is not complete if `README.md` or `docs/src/index.md` still tells a
  fresh reader to install only `PhyloMakie` and then immediately asks them to
  run `using CairoMakie`.
- The direct red-state repro is the delivered tranche-7 state on 2026-05-10:
  both package landing surfaces install only `PhyloMakie`, the first example
  imports `CairoMakie`, and the review repro
  `julia --project=. -e 'using CairoMakie'` failed because the package is not
  present in the root environment by default.
- Task 1 closes this lock item.
- The verification artifact must fail the old shape by checking that each
  first-use surface names the backend install or backend requirement before the
  first example that imports `CairoMakie`, in addition to a green docs build.

### Remediation lock item 2: honest pure-tree docs proof surface

- The work is not complete if
  `VERIFICATION_FOUNDATION.accepted_design_scenarios.simple_tree_no_hybrid`
  still claims `docs/src/public-api.md` as its docs proof surface without a
  real pure-tree `plot(net)` example on that page.
- The direct red-state repro is the delivered tranche-7 state on 2026-05-10:
  `docs/src/public-api.md` contains a reticulate `plot(net)` example and a
  composition example, but no tree-only network example without a `#H` node;
  `test/test_verification_foundation.jl` also accepts that overclaim because
  it checks only the allowed page strings.
- Task 2 closes this lock item.
- The verification artifact must fail the old shape by requiring a dedicated
  pure-tree public-api proof artifact and by keeping `julia --project=docs
  docs/make.jl` green.

### Remediation lock item 3: nonvolatile verification status facts

- The work is not complete if `VERIFICATION_FOUNDATION.current_status` still
  hardcodes an exact `N/N` test count or if the regression suite can still go
  green while materially stale status facts survive.
- The direct red-state repro is the delivered tranche-7 state on 2026-05-10:
  `current_status.package_tests_green.fact` says `372/372` although the review
  pass observed a later green full-suite total, and
  `test/test_verification_foundation.jl` only checks status ids and enums
  rather than the truth-bearing fact content.
- Task 3 closes this lock item.
- The verification artifact must fail the old shape by rejecting exact pass
  counts in `current_status` and by checking the stable, meaning-bearing fact
  text that remains source-backed.

## Handoff packet

- Active authorities:
  `CONTRIBUTING.md`, every repo-local `STYLE*.md` file listed above, the
  revised design brief and supplement, the approved PRD, the approved tranche
  plan, the approved tranche-7 tasking file, and the tranche-4 Makie source-set
  note.
- Parent documents:
  `design/prod01-vision.md`,
  `design/prod01-vision-supplement.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-08_tranche-07--tasking-1.md`,
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`.
- Settled decisions and non-negotiables:
  preserve the accepted Makie-native public owner and public attribute
  surface; keep legacy capability mapping in docs only; do not claim
  General-registry installation; do not broaden the API, restore legacy
  spellings, or reopen runtime cleanup to make docs easier to write.
- Authorization boundary:
  package-facing docs and source-backed verification metadata may be corrected
  aggressively; runtime plotting architecture, helper owners, render owners,
  dependency policy, and capability scope are not reopened.
- Current-state diagnosis:
  tranche 7 is mostly delivered and green, but three truth-bearing surfaces
  remain wrong: the first-use install path omits the backend used in the
  example, the pure-tree docs proof claim lacks a real public-api artifact, and
  `current_status` encodes a stale volatile test count that the tests do not
  catch.
- Primary-goal lock:
  remediation lock items 1 through 3 above.
- Direct red-state repros:
  install only `PhyloMakie` then import `CairoMakie`; claim
  `docs/src/public-api.md` as tree-proof surface without a tree-only example;
  hardcode `372/372` in `current_status` while tests ignore stale fact text.
- Owner and invariant under repair:
  the package truth surface, with `README.md`, `docs/src/index.md`,
  `docs/src/public-api.md`, `docs/src/verification-foundation.md`, and
  `src/verification_foundation.jl` remaining the user-facing and source-backed
  owners that must tell the same truth.
- Supported public surfaces affected by that owner or semantic:
  README quickstart, Home page first plot, Public API examples, the
  `simple_tree_no_hybrid` scenario record, the Verification foundation page,
  and the `current_status` table rendered from live metadata.
- Exact files or surfaces in scope:
  `README.md`,
  `docs/src/index.md`,
  `docs/src/public-api.md`,
  `docs/src/verification-foundation.md`,
  `src/verification_foundation.jl`,
  `test/test_verification_foundation.jl`.
- Exact files or surfaces out of scope:
  `src/public_plot_owner.jl`,
  `src/public_attribute_model.jl`,
  `src/layout_engine.jl`,
  `src/annotation_data.jl`,
  `src/render_adapter.jl`,
  `test/test_public_plot_owner.jl`,
  dependency manifests,
  new plotting capabilities,
  runtime compatibility shells,
  General-registry claims.
- Required upstream primary sources:
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`,
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/display.jl`,
  `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v/src/screen.jl`,
  `PhyloPlots.jl/src/phylonetworksPlots.jl`,
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl`.
- Green-state gates:
  `julia --project=test test/runtests.jl`,
  `julia --project=docs docs/make.jl`,
  a truthful first-use install path on README and Home,
  a live pure-tree public-api example that matches the claimed docs proof
  surface,
  source-backed verification metadata with no exact pass-count drift.
- Stop conditions:
  stop if a truthful install fix appears to require changing the accepted
  package API rather than the docs; stop if a pure-tree docs proof fix appears
  to require new runtime behavior; stop if de-volatilizing `current_status`
  would force removal of all concrete status facts instead of replacing them
  with stable truthful statements.

## Required revalidation before implementation

- Read the tranche and parent PRD in full.
- Read the approved tranche-7 tasking file in full.
- Read the relevant docs pages, `src/verification_foundation.jl`, and
  `test/test_verification_foundation.jl` in full.
- Re-check that the review-backed red states still exist before editing.
- Reconfirm that the accepted Makie-native public owner and public attribute
  surface remain unchanged.
- Read the cited Makie and CairoMakie primary sources in full if any repair
  touches the wording of host-framework semantics or the meaning of bang and
  non-bang entrypoints.
- If the red-state findings are already fixed or the diagnosis no longer
  matches reality, stop and raise that before changing code.

## Tranche execution rule

This remediation may correct package-facing prose, live docs examples,
source-backed verification metadata, and the verification suite that protects
those truth surfaces. It must begin and end in the required green state and
must preserve the accepted runtime and public-owner architecture already live
in the codebase.

When this remediation is complete:

- the package landing surfaces tell a fresh user exactly what to install before
  the first `CairoMakie` example
- `docs/src/public-api.md` contains a real pure-tree `plot(net)` example
  distinct from the existing reticulate example
- `VERIFICATION_FOUNDATION.current_status` contains stable truthful status
  facts rather than volatile suite counts
- the docs and regression suite fail the previously delivered broken shapes
  rather than only the total absence of content

## Non-negotiable execution rules

- Do not solve the install gap by silently swapping the example to a different
  backend unless the docs also teach that backend truthfully and consistently.
- Do not solve the tree-proof gap by changing only metadata or migration text;
  the proof surface must be a real live public-api example.
- Do not solve the stale-status gap by weakening `current_status` into vague
  nonfalsifiable prose.
- Do not broaden the public API, restore legacy spellings, or add runtime
  compatibility shims.
- Do not replace source-backed proof with docs-string policing alone where a
  live docs build or source-backed test can verify more directly.

## Concrete anti-patterns or removal targets

- `README.md` and `docs/src/index.md` installation blocks that install only
  `PhyloMakie` while the first example imports `CairoMakie`.
- `VERIFICATION_FOUNDATION.current_status.package_tests_green.fact`
  containing an exact pass count such as `372/372`.
- `accepted_design_scenarios.simple_tree_no_hybrid.docs_proof_surface`
  claiming `docs/src/public-api.md` without a dedicated pure-tree example on
  that page.
- `test/test_verification_foundation.jl` checks that validate only ids or
  allowed page strings while allowing stale or overstated fact content.

## Failure-oriented verification

- `julia --project=docs docs/make.jl` must remain green after the docs changes.
- `julia --project=test test/runtests.jl` must remain green after the metadata
  and regression changes.
- The old install-gap shape must fail because README and Home no longer omit
  the backend step before `using CairoMakie`.
- The old tree-proof overclaim must fail because the proof suite requires a
  dedicated pure-tree public-api artifact, not merely an allowed page name.
- The old stale-status shape must fail because `current_status` no longer
  accepts exact pass counts and the tests verify stable fact content.
- Positive user-facing proof must remain visible:
  a first-time reader can follow the documented install path honestly, and a
  reader of the Public API page can see both a pure-tree and a reticulate
  `plot(net)` example.

## Tasks

### 1. Repair first-use installation truth on package landing surfaces

**Type**: MIGRATE
**Output**: `README.md` and `docs/src/index.md` teach a truthful first-use path
that names the backend install or backend requirement before the first example
that imports `CairoMakie`.
**Depends on**: none

Update the README installation and quickstart material and the Home-page
installation and first-plot material so the docs no longer imply that
installing only `PhyloMakie` is enough for the very next `using CairoMakie`
example. Keep the GitHub-only installation truth boundary, preserve the
Makie-native framing, and keep the first example centered on the accepted
public surface rather than on legacy migration talk.

**Positive contract**: a fresh reader can follow the documented install path
honestly from install block to first plot without discovering an unstated
backend dependency after the fact.
**Negative contract**: no landing surface may rely on an implicit CairoMakie
install, claim General-registry availability, or revert to a backend-swap
mental model.
**Files**: `README.md`, `docs/src/index.md`.
**Out of scope**: `docs/src/public-api.md`, `src/verification_foundation.jl`,
`test/test_verification_foundation.jl`, runtime code, dependency manifests.
**Verification**: `julia --project=docs docs/make.jl`; direct inspection of
both landing surfaces confirms that the install guidance names the backend
install or backend requirement before the first `using CairoMakie` example,
which the old delivered state fails.

### 2. Add a real pure-tree public-api proof artifact

**Type**: WRITE
**Output**: `docs/src/public-api.md` contains a dedicated pure-tree
`plot(net)` section with a network that has no `#H` node, and the
`simple_tree_no_hybrid` scenario record points honestly at that live proof
surface.
**Depends on**: 1

Add a new Public API section that uses a tree-only Newick string and calls
`plot(net)` directly so the page contains a real simple-tree proof artifact
distinct from the existing reticulate example and the composition example.
Then align `VERIFICATION_FOUNDATION.accepted_design_scenarios.simple_tree_no_hybrid`
with that artifact and strengthen the verification-foundation regression suite
so it no longer accepts a page-level overclaim without a real tree-only
example.

**Positive contract**: the Public API page visibly proves that tree-only
inputs use the same Makie-native `plot(net)` surface without hybrid-edge
machinery, and the scenario metadata names that proof honestly.
**Negative contract**: no reticulate example may be relabeled as the tree
proof, and no docs-proof claim may survive as metadata-only prose.
**Files**: `docs/src/public-api.md`, `src/verification_foundation.jl`,
`test/test_verification_foundation.jl`, `docs/src/verification-foundation.md`
for any minimal truth-alignment needed by the live rendered tables.
**Out of scope**: `README.md`, `docs/src/index.md`, runtime plot-owner code,
new capabilities, migration-table redesign beyond the scenario truth fix.
**Verification**: `julia --project=docs docs/make.jl`; `julia --project=test
test/runtests.jl`; the verification suite must fail the old delivered shape
where `simple_tree_no_hybrid` points at `docs/src/public-api.md` but the page
lacks a dedicated pure-tree example.

### 3. De-volatile current status and harden truth-bearing metadata checks

**Type**: TEST
**Output**: `VERIFICATION_FOUNDATION.current_status` records stable,
date-scoped status facts without exact suite counts, and
`test/test_verification_foundation.jl` checks the fact content strongly enough
to catch stale or overclaimed status text.
**Depends on**: 2

Replace the volatile exact pass-count fact in `current_status` with a stable
truthful statement about the 2026-05-10 green review baseline, then strengthen
the verification-foundation tests so they check the meaning-bearing fact text
that must remain source-backed instead of checking only ids and enum values.
Keep concrete truthful status facts; do not collapse the section into vague
claims that say nothing falsifiable.

**Positive contract**: the verification foundation remains concrete and
auditable, but exact suite totals and similar drift-prone values no longer
survive as source-backed truth claims.
**Negative contract**: no `N/N` pass count or equivalent volatile test-total
claim may remain in `current_status`, and the tests may not accept stale
fact text behind green ids and enums alone.
**Files**: `src/verification_foundation.jl`,
`test/test_verification_foundation.jl`,
`docs/src/verification-foundation.md` if the rendered explanation needs a
minimal update to match the new stable status wording.
**Out of scope**: runtime plotting code, public attribute definitions,
README/Home example content beyond any incidental table refresh from the docs
build.
**Verification**: `julia --project=test test/runtests.jl`; `julia --project=docs
docs/make.jl`; regression checks in `test/test_verification_foundation.jl`
must fail the old `372/372`-style fact and must continue to assert the stable
fact content that replaces it.
