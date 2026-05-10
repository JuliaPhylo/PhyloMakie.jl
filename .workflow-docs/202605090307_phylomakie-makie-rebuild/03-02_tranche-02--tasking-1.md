---
date-created: 2026-05-09T14:51:14
date-updated: 2026-05-09T20:16:02
parent-tranche: 02_tranches.md
parent-prd: 01_prd.md
workflow-instrument: Tasking plan
workflow-status: Implemented
workflow-id: 202605090307_phylomakie-makie-rebuild
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
---

# Tasks for tranche 2: Public keyword normalization owner

Parent tranche: Tranche 2
Parent PRD: `01_prd.md`

## Approval state

- This tasking file was proposed planning output derived from a proposed tranche
  plan and is now the execution record for the implemented tranche-2 snapshot.
- Project-owner approval for both Tranche 2 in `02_tranches.md` and this
  tasking file was recorded on 2026-05-09 via the explicit execution request
  for tranche-2 implementation.
- This file is ratified for the completed tranche-2 `Tasks -> Execute` run
  only.

## Settled user decisions and environment baseline

- The production-run public behavior target is `PhyloPlots.plot(net::HybridNetwork; ...)`.
- The canonical PhyloMakie target public surface names remain `phyloplot`, `phyloplot!`, and Makie `plot(net)` dispatch.
- `PhyloPlot` remains the recipe type name, not the primary user-facing API name.
- `PhyloNetworks.HybridNetwork` remains the only supported public input type for this production run.
- Deep internal redesign is authorized. Public plotting behavior drift from `PhyloPlots.plot` is not authorized.
- Compatibility aliases to old package names are not required.
- R interoperability remains out of scope.
- Preserve the existing root, `test/`, and `docs/` project split.
- Preserve `[sources.PhyloMakie] path = "../"` in `test/Project.toml` and `docs/Project.toml`.
- Use documented public `Pkg` operations to curate the root and `test/` project environments. Do not hand-edit manifests as a first resort.
- The exact accepted keyword names remain unchanged for this production run. No Makie-idiom renaming is authorized in tranche 2.
- The exact keyword ordering for the source-owned contract must follow the upstream `PhyloPlots.plot` keyword signature order in `PhyloPlots.jl/src/plotRCall.jl`, not the grouped presentation order in `design/prod01-vision-supplement.md`.
- Tranche 2 closes canonical ownership of keyword names, defaults, warning policy, fallback policy, and one shared normalized-spec boundary.
- Tranche 2 does close structural explicit-limit validation for non-`nothing` `xlim` and `ylim` inputs. The keyword owner must reject malformed explicit overrides that do not provide exactly 2 values, and tranche-2 tests must prove that rejection directly.
- Tranche 2 does not close DataFrame row-validation parity, DataFrame warning parity, midpoint-preparation parity, or exact `xlim` / `ylim` error-message parity. Those behaviors remain explicitly owned by tranche 3 because the current upstream contract ties them to helper and layout state or layout-derived default bounds.
- The implementer and reviewer must treat that split boundary as a formal gate. Tranche 2 is incomplete if it leaves the deferral implicit, if it skips structural explicit-limit validation, or if it fabricates partial closure by inventing layout-free or helper-free substitutes for tranche-3-owned behavior.
- Current repository baseline as revalidated on 2026-05-09: `julia --project=test test/runtests.jl` passes, and `julia --project=docs docs/make.jl` passes.

## Governance

Read all applicable governance documents line by line before implementing any task in this file.

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
- `01_prd.md`
- `02_tranches.md`

Authority notes that remain active in this tasking file:

- The repo-local `STYLE*.md` set is the operative governance set for this run.
- The overlapping bundled baseline STYLE files match the repo-local copies for this repository.
- No repo-local `STYLE-domain-vocabulary.md` was found.
- No repo-local `STYLE-python.md` was found.
- `STYLE-vocabulary.md` remains the domain vocabulary authority.
- `STYLE-workflow-vocabulary.md` remains authoritative for workflow terms such as `tranche`, `lock item`, `primary-goal lock`, `red-state repro`, and `verification artifact`.

Controlled vocabulary obligations that matter directly in this tranche:

- Use `phyloplot` and `phyloplot!` for the target public surfaces.
- Use `PhyloPlot` only for the recipe type.
- Use `FigureAxisPlot` for the non-mutating Makie return contract.
- Use `keyword surface`, `layout engine`, `render adapter`, `major hybrid edge`, `minor hybrid edge`, `full-tree style`, and `major-tree style` with their governed meanings.
- Do not import foreign project terms such as `lineageplot`, `EdgeLayer`, or `lineageunits`.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, branch creation, rebase, and reset remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Primary-goal lock

### Lock item 1: Canonical keyword-surface owner

- The work is not complete if the exact accepted keyword surface still lives only in upstream prose, docs prose, or future entry-surface wrappers rather than one local source owner.
- The direct red-state repro is the current repository state: no keyword owner exists in `src/`, and the accepted keyword table lives only in `PhyloPlots.jl/src/plotRCall.jl` and `design/prod01-vision-supplement.md`.
- The tasks that close this are task 2, task 3, and task 4.
- The verification artifact is a source-owned keyword contract plus direct tests that fail if any accepted keyword is missing, reordered away from upstream signature order, or left unowned.

### Lock item 2: Style-dependent default and fallback parity

- The work is not complete if `style`, `arrowlen`, or `minorlinetype` can resolve differently for the same input depending on caller, or if the unknown-style fallback semantics drift from the upstream contract.
- The direct red-state repro is the behavior encoded in `PhyloPlots.jl/src/plotRCall.jl`: `arrowlen` defaults from the incoming `style`, `minorlinetype` defaults from the incoming `style`, then an unknown `style` warns and rewrites to `:fulltree` without recomputing those already-resolved defaults.
- The tasks that close this are task 2 and task 3.
- The verification artifact is a normalization regression suite that covers `:fulltree`, `:majortree`, and an unknown style, and that fails any fake fix that reorders or recomputes those policies.

### Lock item 3: Edge color and edge width policy parity

- The work is not complete if scalar-versus-dict behavior for `edgecolor`, `defaultedgecolor`, `majorhybridedgecolor`, `minorhybridedgecolor`, or `edgewidth` can drift or be recomputed independently downstream.
- The direct red-state repro is the behavior encoded in `PhyloPlots.jl/src/plotRCall.jl`: dict `edgecolor` ignores the major and minor hybrid-edge colors, scalar `edgecolor` backfills `defaultedgecolor`, and dict `edgewidth` requires numerical values.
- The tasks that close this are task 2 and task 3.
- The verification artifact is direct normalization coverage for scalar and dict inputs plus a failing regression for the forbidden non-numerical `edgewidth` dict case.

### Lock item 4: Shared-surface single-spec boundary

- The work is not complete if `phyloplot`, `phyloplot!`, or `plot(net)` would still need their own copy of keyword parsing, defaults, warnings, or fallback behavior.
- The direct red-state repro is the current repository state: no plotting entry surface exists and no shared normalized plot spec exists.
- The tasks that close this are task 2 and task 4.
- The verification artifact is one source-owned normalization owner and one source-backed verification-foundation record that names all 3 supported public surfaces as consumers of the same spec and leaves direct public-surface proof owned by tranche 5.

### Lock item 5: Honest DataFrame validation deferral

- The work is not complete if tranche 2 either claims closure of `nodelabel` and `edgelabel` row-validation and warning parity or leaves that ownership boundary implicit.
- The direct red-state repro is the upstream owner boundary: `PhyloPlots.jl/src/phylonetworksPlots.jl` still owns the row filtering, missing-first-column dropping, unmatched-number warnings, and midpoint-preparation behavior through `check_nodedataframe`, `prepare_nodedataframe`, and `prepare_edgedataframe`.
- The tasks that close this are task 2, task 3, and task 4.
- The verification artifact is source-owned deferral metadata and tests that fail if tranche 2 fabricates row filtering, warning emission, or midpoint-preparation closure instead of recording those contracts as tranche-3-owned.

### Lock item 6: Structural explicit-limit validation

- The work is not complete if malformed explicit `xlim` or `ylim` overrides can pass through the keyword owner without rejection, or if later layers would need to re-check the same “exactly 2 values” contract independently.
- The direct red-state repro is the upstream contract encoded in `PhyloPlots.jl/src/plotRCall.jl`: when `xlim` or `ylim` is not `nothing`, the value must contain exactly 2 entries or the owner throws an error instead of silently accepting malformed explicit limits.
- The tasks that close this are task 2 and task 3.
- The verification artifact is direct normalization regressions that fail malformed explicit `xlim` and `ylim` inputs while still preserving the later-tranche boundary for exact legacy message parity.

### Lock item 7: Honest exact `xlim` / `ylim` message deferral

- The work is not complete if tranche 2 fabricates exact `xlim` or `ylim` parity, especially the exact legacy error text that interpolates layout-derived defaults, or leaves that dependency implicit.
- The direct red-state repro is the upstream owner boundary in `PhyloPlots.jl/src/plotRCall.jl`: the `xlim` and `ylim` errors interpolate `xmin`, `xmax`, `ymin`, and `ymax` only after `edgenode_coordinates` and label-driven expansions have already run.
- The tasks that close this are task 2, task 3, and task 4.
- The verification artifact is source-owned deferral metadata and tests that fail if tranche 2 invents synthetic bounds, layout-free error strings, or a false “closed” status for exact limit-message parity.

### Lock item 8: Reviewer-clear deferral pass-forward

- The work is not complete if a fresh implementing agent or a reviewer could still misread tranche 2 as responsible for tranche-3-only contracts, or could clear a fake fix because the deferred-owner boundary is stated only in workflow prose.
- The direct red-state repro is the current repository state: there is no source-owned keyword owner, no source-owned deferral metadata for these contracts, and no docs-rendered reviewer note for the boundary.
- The tasks that close this are task 4 and, indirectly, task 3.
- The verification artifact is a source-backed verification-foundation and docs page that name the deferred contracts, their owning tranche, and the reviewer clear / reject rule.

## Handoff packet

- Approval state: approved and executed; project-owner approval for both
  Tranche 2 in `02_tranches.md` and this tasking file was recorded on
  2026-05-09 via the explicit execution request for tranche-2
  implementation.
- Active authorities: `CONTRIBUTING.md`; all repo-local root `STYLE*.md` files; `STYLE-vocabulary.md`; `STYLE-workflow-vocabulary.md`; `design/prod01-vision.md`; `design/prod01-vision-supplement.md`; `01_prd.md`; `02_tranches.md`.
- Parent documents: `01_prd.md`; `02_tranches.md`; `design/prod01-vision.md`; `design/prod01-vision-supplement.md`.
- Settled decisions and non-negotiables: preserve the `PhyloPlots.plot` public behavior target; preserve the exact accepted keyword names; preserve upstream keyword signature order for the local contract; keep `phyloplot`, `phyloplot!`, and `plot(net)` as the target public surfaces; keep `HybridNetwork` as the only supported public input type; keep R interop out of scope; preserve the root / `test/` / `docs/` project split and path overrides; use public `Pkg` operations for dependency curation.
- Authorization boundary: internal redesign of the keyword owner is allowed; public keyword-surface drift is not; entry-surface integration remains out of scope for tranche 2; layout-owner and annotation-helper closure remain out of scope for tranche 2.
- Current-state diagnosis: tranche 1 established `VERIFICATION_FOUNDATION`, a fixture corpus, a thin module shell, and truthful docs scaffolding; there is still no keyword owner, no normalized plot spec, and no direct keyword regression coverage.
- Primary-goal lock: the 8 lock items above.
- Direct red-state repros: no keyword owner in `src/`; no keyword contract metadata in `VERIFICATION_FOUNDATION`; no direct keyword tests; no source-owned reviewer-readable deferral metadata; the exact upstream keyword behavior still lives only in `PhyloPlots.jl/src/plotRCall.jl`.
- Owner and invariant under repair: one public keyword surface, one normalization owner, one normalized spec boundary shared by all supported public plotting surfaces.
- Target public surfaces affected by this owner boundary: `phyloplot`, `phyloplot!`, and `plot(net)` via Makie dispatch. Tranche 2 must not expose them. Tranche 2 must record them as later consumers of the same spec and must leave their direct proof ownership with tranche 5.
- Exact files or surfaces in scope: `Project.toml`; `test/Project.toml`; `src/PhyloMakie.jl`; new keyword-owner source files under `src/`; `src/verification_foundation.jl`; `test/runtests.jl`; `test/test_PhyloMakie.jl`; new keyword tests under `test/`; `docs/src/verification-foundation.md`.
- Exact files or surfaces out of scope: public plotting entrypoints; `Makie.plottype`; `@recipe`; layout computation; annotation midpoint computation; DataFrame row validation; render primitives; R interoperability; `sexp`; `rexport`; support for non-`HybridNetwork` inputs; parent PRD and tranche files.
- Required upstream primary sources: `PhyloPlots.jl/src/plotRCall.jl`; `PhyloPlots.jl/src/phylonetworksPlots.jl`; `PhyloPlots.jl/test/test_phylonetworkPlots.jl`; `PhyloNetworks.jl/docs/src/man/net_plot.md`.
- Upstream contract conclusions already settled for this tranche: the exact keyword name and default surface is defined by the `PhyloPlots.plot` signature; style-dependent defaults and fallback ordering are defined inside `plotRCall.jl`; structural explicit-limit validation for malformed non-`nothing` `xlim` and `ylim` inputs belongs to the keyword owner; exact DataFrame validation and exact `xlim` / `ylim` limit-message parity still depend on the helper and layout owners and therefore cannot be closed honestly in tranche 2.
- Green-state gates: `julia --project=test test/runtests.jl`; `julia --project=docs docs/make.jl`; Aqua and JET remain supplemental proof inside the test suite.
- Stop conditions: stop if a keyword-owner design would require entry-surface implementation; stop if preserving public behavior appears to require keyword renaming; stop if a proposed fix duplicates tranche-3 helper or layout responsibilities; stop if the deferral boundary cannot be made source-owned and reviewer-readable; stop if structural explicit-limit validation appears to require layout-owned default-bound computation rather than direct malformed-input rejection.
- Reviewer gate note: reviewers should clear tranche 2 when the canonical keyword owner exists, representative keyword regressions pass, structural explicit-limit validation is closed in the keyword owner, and the deferred-owner boundary for DataFrame validation and exact `xlim` / `ylim` message parity is explicit in source, tests, and docs. Reviewers should reject tranche 2 if those deferred contracts are partially reimplemented, falsely marked closed, or left implicit.

## Required revalidation before implementation

- Read `02_tranches.md` and `01_prd.md` in full.
- Read all governance files named above line by line.
- Re-read `src/PhyloMakie.jl`, `src/verification_foundation.jl`, `test/test_PhyloMakie.jl`, `test/test_verification_foundation.jl`, `docs/src/verification-foundation.md`, `Project.toml`, `test/Project.toml`, and `docs/Project.toml` in full.
- Re-read `PhyloPlots.jl/src/plotRCall.jl` in full and treat its keyword signature and its local normalization order as authoritative tranche-2 input.
- Re-read `PhyloPlots.jl/src/phylonetworksPlots.jl` and `PhyloPlots.jl/test/test_phylonetworkPlots.jl` in full to confirm exactly which DataFrame and layout contracts remain deferred.
- Re-read `PhyloNetworks.jl/docs/src/man/net_plot.md` for the legacy user-facing plotting contract context.
- Re-run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl` before modifying code so the tranche starts from a known green baseline.
- Re-check that no keyword owner or entry-surface plotting code landed after this tasking file was written. If it did, stop and rewrite the tasking against current reality.
- Re-check that exact DataFrame validation parity and exact `xlim` / `ylim` limit-message parity still require upstream helper and layout state. If they no longer do, stop and update the tasking honestly rather than preserving a stale deferral.
- Re-check that malformed explicit `xlim` and `ylim` inputs still admit direct structural validation at the keyword-owner boundary without needing layout-derived default bounds. If that stops being true, stop and raise the contract shift explicitly instead of silently weakening tranche-2 ownership.

## Tranche execution rule

This tranche may redesign the internal keyword owner deeply, but it must begin and end in a green, policy-compliant state for its scope.

When this tranche completes:

- the repository must have one canonical source owner for the full accepted keyword surface;
- the repository must have one normalized plot-spec boundary for all later plotting surfaces;
- docs and tests must tell the truth about what tranche 2 closes and what tranche 3 still owns;
- no later surface should need its own copy of keyword defaults, warning policy, or fallback rules.

When this tranche completes, the following must no longer exist as acceptable owner shapes:

- workflow prose as the only keyword contract owner;
- future wrapper-local keyword parsing as an allowed plan;
- render-layer fallback logic as an allowed place to re-decide keyword defaults;
- a reviewer-only verbal note for the deferral boundary with no source-owned proof artifact.

Docs truth-boundary rule for this tranche:

- Docs may describe the keyword owner and its deferred contracts.
- Docs must not claim that `phyloplot`, `phyloplot!`, or `plot(net)` are implemented.
- Docs must not claim that exact DataFrame validation parity or exact `xlim` / `ylim` message parity is closed in tranche 2.
- Docs should state that malformed explicit `xlim` and `ylim` overrides are rejected in tranche 2 while exact legacy message text remains deferred.

## Non-negotiable execution rules

- Do not implement `phyloplot`, `phyloplot!`, `plot(net)`, `Makie.plottype`, or `@recipe` behavior in this tranche.
- Do not implement layout computation, axis-limit computation, node or edge coordinate computation, or annotation midpoint computation in this tranche.
- Do not port `check_nodedataframe`, `prepare_nodedataframe`, or `prepare_edgedataframe` logic into the keyword owner.
- Do not emit unmatched-node or unmatched-edge warnings from the keyword owner.
- Do not drop missing first-column annotation rows from the keyword owner.
- Do not skip structural explicit-limit validation for malformed non-`nothing` `xlim` or `ylim` values.
- Do not fabricate exact `xlim` or `ylim` error strings by inventing layout-free defaults.
- Do not replace the deferred contracts with weaker proxies such as docs notes, source-text grep checks, or reviewer memory.
- Do not rename any accepted public keyword in this tranche.
- Do not use a free-form `Dict{Symbol,Any}` or an untyped bag as the canonical normalized spec.
- Do not add dependencies other than `DataFrames` unless a new approval reopens that question.
- Do not modify `01_prd.md` or `02_tranches.md`.

## Concrete anti-patterns or removal targets

- Any second keyword table that lives only in docs, tests, or workflow prose.
- Any wrapper-local keyword parsing in future `phyloplot`, `phyloplot!`, or `plot(net)` entry surfaces.
- Any render-layer logic that recomputes `arrowlen`, `minorlinetype`, `defaultedgecolor`, or `edgewidth` fallback policy.
- Any tranche-2 helper that performs DataFrame row filtering, unmatched-number warning emission, or midpoint preparation.
- Any tranche-2 helper that silently accepts malformed explicit `xlim` or `ylim` overrides.
- Any tranche-2 helper that invents layout-free `xlim` or `ylim` default bounds or error strings.
- Any canonical normalized-spec owner built as `Dict{Symbol,Any}`, `NamedTuple` plus loose helper conventions only, or any similarly weak shape that hides the owner boundary.
- Any source-owned metadata that records `phyloplot` but leaves `phyloplot!` or `plot(net)` implicit.
- Any source-owned metadata that marks DataFrame validation parity or exact `xlim` / `ylim` message parity as already closed in tranche 2.

## Failure-oriented verification

- The old repository state must fail direct keyword-owner tests because no keyword owner, no normalized spec, and no keyword contract metadata exists there.
- A fake fix that omits any accepted keyword or changes signature order must fail the keyword-contract completeness checks.
- A fake fix that resolves `arrowlen` or `minorlinetype` after rewriting an unknown style to `:fulltree` must fail the style-order regression tests.
- A fake fix that lets downstream layers infer `defaultedgecolor` or `edgewidth` fallback independently must fail the scalar-versus-dict normalization regressions.
- A fake fix that accepts malformed explicit `xlim` or `ylim` overrides, or that leaves their structural validation for later layers, must fail the new explicit-limit validation regressions.
- A fake fix that emits DataFrame warnings or filters annotation rows in tranche 2 must fail the deferral-boundary tests.
- A fake fix that invents exact `xlim` or `ylim` error strings without layout state must fail the deferral-boundary tests.
- A fake fix that leaves the deferral boundary only in prose and not in source-backed verification metadata must fail the verification-foundation and docs checks.

Positive runtime and maintainer-facing checks for this owner-establishing tranche:

- A new contributor can locate one canonical keyword owner under `src/`.
- A new contributor can locate one direct keyword regression suite under `test/`.
- A reviewer can inspect one source-backed docs page and see exactly which keyword contracts are closed in tranche 2 and which ones remain tranche-3-owned.
- Later tranches can consume one normalized plot spec rather than rediscovering keyword precedence and fallback behavior.

## Reviewer gate note

- Clear tranche 2 when the codebase contains one canonical keyword owner, one canonical normalized plot spec, representative keyword regressions, structural explicit-limit validation for malformed `xlim` and `ylim` inputs, and source-backed deferral metadata for the tranche-3-only contracts.
- Do not require DataFrame helper parity, midpoint-preparation parity, or exact `xlim` / `ylim` limit-message parity to clear tranche 2. Those are explicitly out of scope here.
- Reject tranche 2 if it partially reimplements those deferred contracts, falsely marks them closed, or leaves the reviewer to infer the deferral boundary from parent workflow prose alone.

## Tasks

### 1. Add the keyword-owner dependency baseline

**Type**: CONFIG
**Output**: `DataFrames` is available as the only new tranche-2 dependency needed to accept real `DataFrame()` defaults and concrete annotation-label inputs, and the current green baseline still passes afterward.
**Depends on**: none
**Positive contract**: The root project and the `test/` project declare `DataFrames` through documented public `Pkg` operations. The existing root / `test/` / `docs/` split and the existing path-override policy remain unchanged.
**Negative contract**: Do not add `Makie`, `CairoMakie`, `RCall`, `PhyloPlots`, or `PhyloNetworks` as new direct dependencies in this task. Do not change `docs/Project.toml`. Do not expose any plotting API.
**Files**: `Project.toml`; `test/Project.toml`
**Out of scope**: `src/`; `test/` source files; `docs/`; public plotting entrypoints; layout logic; render logic
**Verification**: `julia --project=test test/runtests.jl` passes after the dependency addition. `julia --project=docs docs/make.jl` still passes. A repo-local import smoke check can load both `DataFrames` and `PhyloMakie` from the intended project environments. The old repository state fails that `DataFrames` availability check from the local project environments.

Add `DataFrames` as the only new direct dependency needed by tranche 2. Use public `Pkg` operations from the root project and the `test/` project rather than hand-editing manifests. Preserve the repo-local environment split and the existing `[sources.PhyloMakie] path = "../"` policy. Do not broaden the dependency surface beyond what the keyword owner needs to accept concrete annotation-label inputs and defaults.

### 2. Establish the canonical keyword contract and normalization owner

**Type**: WRITE
**Output**: One canonical source-owned keyword contract and one canonical unexported normalization owner exist under `src/`, and `src/PhyloMakie.jl` remains a thin include-only shell.
**Depends on**: 1
**Positive contract**: `src/PhyloMakie.jl` includes `keyword_contract.jl`, `keyword_normalization.jl`, and `verification_foundation.jl` in that order and remains a thin shell. `src/keyword_contract.jl` defines `const SUPPORTED_PLOT_KEYWORDS` as the exact 29-keyword tuple in upstream signature order and defines `const KEYWORD_SURFACE_CONTRACT` with one entry per keyword recording the default source, closure status, and deferred-owner metadata where applicable. `src/keyword_normalization.jl` defines one immutable unexported `PlotKeywordSpec` owner with the exact top-level fields `layout`, `visibility`, `annotations`, `colors`, `strokes`, and `deferred_contracts`, plus one unexported `normalize_plot_keywords` function whose keyword signature matches the upstream `PhyloPlots.plot` keyword names and default expressions exactly.
**Negative contract**: Do not implement `phyloplot`, `phyloplot!`, `plot(net)`, recipe code, layout code, render code, or annotation-helper logic in this task. Do not use a free-form `Dict{Symbol,Any}` as the canonical spec. Do not close DataFrame row-validation parity or exact `xlim` / `ylim` message parity here. Do not recompute style defaults in a different order than upstream. Do not leave malformed explicit `xlim` or `ylim` values unvalidated.
**Files**: `src/PhyloMakie.jl`; `src/keyword_contract.jl`; `src/keyword_normalization.jl`
**Out of scope**: `test/`; `docs/`; `src/verification_foundation.jl`; layout-owner helpers; render-owner helpers; public entry-surface integration
**Verification**: The package loads with the new source files included in the declared order. Direct source-level tests can inspect `SUPPORTED_PLOT_KEYWORDS`, `KEYWORD_SURFACE_CONTRACT`, `PlotKeywordSpec`, and `normalize_plot_keywords`. The old repository state fails because none of those owners exist there.

Create `src/keyword_contract.jl` and `src/keyword_normalization.jl`. Follow the upstream keyword signature order from `PhyloPlots.jl/src/plotRCall.jl`, not the grouped order in the design supplement. Make `normalize_plot_keywords` the only canonical keyword-entry owner for later plotting surfaces. Resolve all derivable tranche-2 behavior inside that owner: the exact accepted keyword names; the exact default expressions; the unknown-style warning plus fallback to `:fulltree`; the subtle ordering rule that `arrowlen` and `minorlinetype` resolve from the incoming `style` before any unknown-style rewrite; scalar-versus-dict color and width policy; structural explicit-limit validation for non-`nothing` `xlim` and `ylim` values; and the “same keyword surface, one owner” boundary for all later entry surfaces. Normalize `edgelabel` and `nodelabel` into owned concrete `DataFrame` values so downstream owners receive stable concrete inputs, but do not perform row filtering, warning emission, or midpoint preparation here. Preserve accepted 2-value `xlim` and `ylim` overrides without inventing layout-derived default bounds in tranche 2 error paths. Record exact `xlim` and `ylim` message parity as deferred contracts in `deferred_contracts` with tranche 3 as the owner.

### 3. Add keyword regressions and fake-fix rejection tests

**Type**: TEST
**Output**: The repository has one direct keyword regression suite that proves tranche-2-owned behavior and rejects the known fake-fix shapes for the deferred contracts.
**Depends on**: 2
**Positive contract**: Tests exist for keyword-contract completeness, `PlotKeywordSpec` structure, default behavior, representative warning behavior, scalar-versus-dict normalization, structural explicit-limit validation for malformed `xlim` and `ylim` inputs, and the formal deferral boundary for DataFrame validation and exact limit-message parity. `test/test_PhyloMakie.jl` is updated so the thin-shell test now expects the three include files declared by task 2, rather than the tranche-1 single-include shell.
**Negative contract**: Do not use docs-string policing, grep-only assertions, or “function returns something” smoke checks as the primary proof. Do not write fake tranche-2 tests that assert exact layout-dependent `xlim` or `ylim` strings. Do not duplicate the keyword table independently from the source-owned contract. Do not treat “error thrown” alone as sufficient proof when the test can assert that malformed explicit limits are rejected at the keyword-owner boundary.
**Files**: `test/runtests.jl`; `test/test_PhyloMakie.jl`; `test/test_keyword_contract.jl`; `test/test_keyword_normalization.jl`; `test/support/keyword_surface_cases.jl`
**Out of scope**: `docs/`; layout-owner parity; annotation-helper parity; public entry-surface tests; render-level proofs
**Verification**: `julia --project=test test/runtests.jl` passes and includes failures that the old repository state would trip immediately. The suite also fails any fake fix that changes style-resolution order, defers color or width fallback to later layers, or pretends that deferred contracts are already closed.

Add source-mirroring tests for the new owner. Cover, at minimum, the exact 29-keyword tuple and its ordering; the exact `PlotKeywordSpec` top-level field set; `normalize_plot_keywords()` defaults; `style=:majortree`; `style=:fulltree`; unknown-style warning and fallback; scalar `edgecolor`; dict `edgecolor` plus `defaultedgecolor`; scalar `edgewidth`; dict `edgewidth`; the non-numerical `edgewidth` dict error; malformed explicit `xlim` and malformed explicit `ylim` values that fail the keyword-owner structural validation; accepted 2-value explicit `xlim` and `ylim` overrides that pass through intact; annotation-label inputs normalized to owned concrete `DataFrame` values; and the explicit deferred-contract records for `nodelabel` validation, `edgelabel` validation, `xlim` exact message parity, and `ylim` exact message parity. Update the existing shell-owner test so it still proves thin-shell discipline after the module grows to multiple includes.

### 4. Pass the keyword owner and reviewer gate into the verification foundation

**Type**: MIGRATE
**Output**: The verification foundation and docs page render the keyword owner, the deferred-contract boundary, and the reviewer clear / reject rule from source-owned data rather than from parent workflow prose alone.
**Depends on**: 2, 3
**Positive contract**: `VERIFICATION_FOUNDATION` gains one source-owned keyword-owner record that names the canonical source files, the supported keyword tuple, the target public surfaces that later consume the spec, and the exact tranche-3-owned deferred contracts. The docs page renders that data directly and states the reviewer gate in truth-boundary terms. The verification-foundation tests are updated to fail if that metadata disappears or drifts.
**Negative contract**: Do not create a second keyword contract that lives only in docs or only in tests. Do not mark any public plotting surface as implemented. Do not mark deferred DataFrame validation or exact `xlim` / `ylim` message parity as closed. Do not rely on a prose-only reviewer note.
**Files**: `src/verification_foundation.jl`; `test/test_verification_foundation.jl`; `docs/src/verification-foundation.md`
**Out of scope**: `01_prd.md`; `02_tranches.md`; new public API docs pages; layout-owner implementation; render-owner implementation
**Verification**: `julia --project=test test/runtests.jl` passes with updated verification-foundation tests. `julia --project=docs docs/make.jl` passes and renders the new keyword-owner and deferred-contract sections from source-backed data. Removing the source-owned deferred-owner metadata causes tests or docs evaluation to fail.

Extend the tranche-1 verification owner so it now passes forward tranche-2 ownership and the reviewer gate explicitly. Add a new source-owned keyword-owner block to `VERIFICATION_FOUNDATION` rather than leaving the keyword contract implicit in the new source files only. That block must record, at minimum, the canonical owner files, the supported keyword tuple, the target public surfaces that later consume the spec, and a deferred-contract table with the exact owner tranches for `nodelabel` validation, `edgelabel` validation, `xlim` exact message parity, and `ylim` exact message parity. Update `docs/src/verification-foundation.md` so the reviewer can clear tranche 2 by reading one rendered, source-backed explanation of what is closed now and what remains blocked on tranche 3 and tranche 5.
