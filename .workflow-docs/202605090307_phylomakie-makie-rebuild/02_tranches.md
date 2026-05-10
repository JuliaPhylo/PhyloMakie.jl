---
date-created: 2026-05-09T03:07:47
date-updated: 2026-05-10T13:30:18
parent-prd: 01_prd.md
workflow-instrument: Tranche plan
workflow-status: Proposed
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
---

# Tranches for Makie-native HybridNetwork plotting in PhyloMakie

## Parent PRD

`01_prd.md`

## Approval state

- This revised tranche plan supersedes the earlier compatibility-first roadmap
  for all future work.
- Tranches 1 through 4 remain completed historical baseline. They are not
  reopened by this rewrite.
- Tranches 5 through 7 are proposed future work.
- Downstream `Tranches -> Tasks` execution remains blocked for Tranches 5
  through 7 until the project owner explicitly approves them.

## Active authorities

Read the following documents line by line before implementing any tranche in
this file.

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

Authority note:

- The revised design brief and revised PRD replace the earlier
  compatibility-first product framing.
- User clarification on 2026-05-10 explicitly reopened public API design and
  invalidated the old "same keyword shell, new backend" assumption.
- `STYLE-vocabulary.md` still governs general project terminology, but its
  earlier API-specific compatibility assumptions are no longer treated as fixed
  product requirements when they conflict with the revised PRD.

## Controlled vocabulary

- Use `Makie-native public plot owner` for the recipe or plot type that owns
  public plotting semantics.
- Use `compatibility adapter` only for explicit, secondary legacy bridging.
  Do not call the package center a compatibility adapter.
- Use `layout engine` and `render adapter` for the completed internal owners
  from Tranches 3 and 4.
- Use `capability parity` for preserved plotting outcomes.
  Do not use `keyword parity` as the primary product goal for future work.
- `phyloplot` and `phyloplot!` may survive as thin convenience surfaces.
  They are not assumed to be the primary public semantic owner.

## Upstream primary sources

- `design/prod01-vision.md`
- `design/prod01-vision-supplement.md`
- `PhyloPlots.jl/src/phylonetworksPlots.jl`
- `PhyloPlots.jl/test/test_phylonetworkPlots.jl`
- `PhyloPlots.jl/src/plotRCall.jl` as a legacy capability reference only
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`
- the Makie-family source files recorded in that source-set note

## Authorization boundary

- Deep internal redesign is authorized.
- Public API redesign is authorized.
- Capability loss is not authorized.
- A compatibility-first public owner is not authorized as the final package
  architecture.
- R interoperability remains out of scope.
- Every tranche must begin and end in a green, policy-compliant state.

## Tranche index

| Tranche id | Title | Status |
| --- | --- | --- |
| 1 | Verification and module shell foundation | Completed |
| 2 | Historical compatibility-first keyword baseline | Completed |
| 3 | Layout and annotation data owner | Completed |
| 4 | Render adapter and render-proof baseline | Completed |
| 5 | Makie-native public plot owner and attribute model | Proposed |
| 6 | Compatibility-owner retirement and internal public-path realignment | Proposed |
| 7 | Docs, migration, and final capability closure | Proposed |

## Tranche 1: Verification and module shell foundation

**Type**: AFK
**Blocked by**: None — historical baseline

### Primary-goal lock

- Lock item 7 historical baseline: plot-sensitive fixtures, docs scaffolding,
  and a thin module shell exist.

### What to build

This tranche is already complete.

It established the repo-owned Makie test and docs baseline, the thin module
shell, and the initial fixture and verification scaffolding that later
tranches still rely on.

### Current interpretation

- Keep this tranche complete.
- Reuse its verification scaffolding.
- Do not treat its completion as approval for the later compatibility-first
  public API framing that followed.

## Tranche 2: Historical compatibility-first keyword baseline

**Type**: AFK
**Blocked by**: Tranche 1 — historical baseline

### Primary-goal lock

- Historical output only. Lock item 2 is reopened by the revised PRD.

### What to build

This tranche is already complete.

It created `keyword_normalization.jl` and `keyword_contract.jl` and made the
legacy `PhyloPlots.plot` keyword shell the intended semantic center of the
future package.

### Current interpretation

- Treat this tranche as a useful exploration and regression anchor.
- Do not treat it as target-state architecture.
- Later tranches are expected to retire, reduce, or explicitly demote this
  owner so it cannot remain the public center of the package.

## Tranche 3: Layout and annotation data owner

**Type**: AFK
**Blocked by**: Tranche 2 — historical baseline

### Primary-goal lock

- Lock items 4 and 7 historical baseline: layout, annotation anchors, and
  helper regressions are closed and remain reusable.

### What to build

This tranche is already complete.

It established the internal geometry, bounds, and annotation-table owners that
the remaining public API work should preserve and consume.

### Current interpretation

- Keep this tranche complete.
- Preserve its invariants.
- Do not duplicate its geometry or annotation logic in future wrapper or
  recipe layers.

## Tranche 4: Render adapter and render-proof baseline

**Type**: AFK
**Blocked by**: Tranche 3 — historical baseline

### Primary-goal lock

- Lock items 4 and 7 historical baseline: render-time primitive composition,
  style distinction, and direct CairoMakie proof are closed and remain
  reusable.

### What to build

This tranche is already complete.

It established the internal render owner, its direct proof surface, and the
Makie source-set note that later public API work should continue to consume.

### Current interpretation

- Keep this tranche complete.
- Reuse its render owner where it fits.
- Do not mistake its completion for a finished public product.

## Tranche 5: Makie-native public plot owner and attribute model

**Type**: HITL
**Blocked by**: Tranche 4

### Governance and required reading

- Mandated line-by-line reading of every document listed in `Active
  authorities` above before implementation starts.
- Mandated reading of the revised design brief and revised PRD.
- Mandated reading of the Makie-family source files already recorded in the
  tranche-4 source-set note, plus any additional recipe-specific sources
  needed by the final public owner.

### Primary-goal lock

- Close lock item 1: establish a real Makie-native public plot owner.
- Start closing lock items 2 and 3 by moving public semantics away from the
  compatibility-first keyword owner.
- Preserve lock items 4, 5, and 7 by consuming the completed layout and
  render owners rather than reimplementing them.
- Non-completion condition: this tranche is not complete if the public surface
  still reads like a wrapped legacy keyword shell, or if the new plot owner
  owns separate geometry or render semantics.

### What to build

Build the Makie-native public plot owner for `HybridNetwork`.

This tranche is user-facing and owner-establishing.

The remaining owner is a real Makie plot type or recipe that accepts a
Makie-native attribute surface and supports plotting into new and existing
axes. If package-specific convenience surfaces such as `phyloplot` and
`phyloplot!` survive, they must be thin wrappers over the same owner.

This tranche may use a temporary bridge from the new public attribute model
into the current `PlotKeywordSpec` path if that is the smallest honest route
to public API proof. If such a bridge exists, keep it tightly local to the
public owner and mark it transitional. Do not let it become the final semantic
center of the package.

### Legacy artifacts to retire or demote

- `keyword_normalization.jl` as the package's public semantic owner
- `keyword_contract.jl` as the package's public product definition
- docs and examples that teach the legacy keyword shell as canonical

### Forbidden regressions

- A public wrapper that owns behavior independently from the recipe
- A public API that requires legacy keyword names to feel complete
- Hidden current-axis state or other non-Makie public plotting semantics
- A second geometry owner in recipe or wrapper code
- A second render implementation outside the existing render owner

### Environment and dependency baseline

- Preserve the existing tranche-4 Makie dependency baseline and source-set note
- Preserve the completed layout and render owners as the geometry and render
  foundations for this tranche
- Revalidate any additional Makie recipe or plotting files before relying on
  them

### Handoff packet

- **Active authorities**:
  - every document listed in `Active authorities`
- **Parent documents**:
  - `01_prd.md`
  - `design/prod01-vision.md`
  - `design/prod01-vision-supplement.md`
- **Settled decisions and non-negotiables**:
  - Makie-native public API
  - same capability envelope
  - real recipe or plot-type owner
  - wrappers remain thin if they survive
- **Authorization boundary**:
  - public API redesign is authorized
  - capability loss and fake wrappers are not
- **Current-state diagnosis**:
  - layout and render owners are usable
  - compatibility-first keyword ownership is the wrong public center
  - no public Makie plot owner exists yet
- **Primary-goal lock**:
  - lock items 1, 2, 3, 4, 5, and 7
- **Direct red-state repros**:
  - no public recipe
  - no public plotting into existing axes
  - current code path centers `PlotKeywordSpec`
- **Owner and invariant being repaired or relied on**:
  - repair the public owner
  - rely on the layout and render invariants already closed
- **Exact files or surfaces in scope**:
  - public plot owner
  - public attribute model
  - wrapper surfaces if retained
  - public docs examples and tests
- **Exact files or surfaces out of scope**:
  - final retirement of the compatibility owner
  - migration guide completion
  - non-`HybridNetwork` public support
- **Required upstream primary sources**:
  - the sources listed above
- **Green-state gates**:
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
  - direct public API proof
- **Stop conditions**:
  - stop if a real public plot owner cannot be added without duplicating
    geometry or render ownership
  - stop if the only workable path keeps the compatibility-first owner as the
    public semantic center

### How to verify

- **Manual**: inspect the public plotting surface and confirm it reads as a
  Makie-native owner rather than as a legacy keyword shim.
- **Automated**:
  - public API tests for `HybridNetwork`
  - direct plotting into an existing axis
  - existing helper and render regressions remain green
  - docs build with Makie-native public examples

Negative verification for the known bad shape:

- The tranche must fail if the recipe and any package-specific wrappers can
  drift semantically from each other, or if the public owner bypasses Makie
  semantics in favor of a wrapper-first path.

### Acceptance criteria

- [ ] Given a `HybridNetwork`, when the public plot owner is called, then a
  real Makie-native plotting path exists.
- [ ] Given an existing Makie axis, when the public mutating surface is used,
  then plotting composes into that axis without hidden global state.
- [ ] Given the completed layout and render owners, when this tranche is
  complete, then the public plot owner consumes them rather than reimplementing
  them.
- [ ] Given the old compatibility-first shape, when verification is run, then
  the tranche fails if that shape still owns the public semantics.

### User stories addressed

- User stories 1, 2, 3, 8, and 10 from the PRD

## Tranche 6: Compatibility-owner retirement and internal public-path realignment

**Type**: AFK
**Blocked by**: Tranche 5

### Governance and required reading

- Mandated line-by-line reading of every document listed in `Active
  authorities` above before implementation starts.
- Mandated revalidation of the tranche-5 public owner against the revised PRD.
- Mandated reading of any surviving compatibility-owner code before deciding
  whether it is retired or demoted.

### Primary-goal lock

- Close lock item 3: compatibility-first owner retirement.
- Preserve lock items 1, 4, 5, and 7 while realigning internal public paths.
- Non-completion condition: this tranche is not complete if the package still
  needs `keyword_normalization.jl` or `keyword_contract.jl` on the default
  public plotting path.

### What to build

Realign the internal public plotting path so the Makie-native public owner is
the actual semantic center of the package.

This tranche is foundational and cleanup-oriented.

The remaining owner is the new public plot owner and its Makie-native
attribute or plot-model representation. The retired shape is the
compatibility-first keyword owner as the package center.

This tranche may:

- delete `keyword_normalization.jl` and `keyword_contract.jl`
- move them into an explicit compatibility namespace
- or replace them with a smaller, clearly subordinate adapter

What it must not do is keep them in the default include path as the main route
through which public plotting works.

### Legacy artifacts to retire or demote

- `src/keyword_normalization.jl` in the default public path
- `src/keyword_contract.jl` in the default public path
- `PlotKeywordSpec` as the canonical public semantic carrier
- tests and metadata that define the package in terms of legacy keyword
  ownership

### Forbidden regressions

- Keeping both the Makie-native owner and the compatibility-first owner alive
  as parallel semantic centers
- Moving the old owner unchanged under a new name and calling it architectural
  cleanup
- Retaining compatibility code in the default module shell without explicit
  justification
- Reopening helper or render invariants while trying to retire the keyword
  owner

### Environment and dependency baseline

- Preserve the completed layout and render regression suites
- Preserve the tranche-5 public plotting proof
- Do not add a second public plotting entry path merely to preserve legacy
  structure

### Handoff packet

- **Active authorities**:
  - every document listed in `Active authorities`
- **Parent documents**:
  - `01_prd.md`
  - `design/prod01-vision.md`
  - `design/prod01-vision-supplement.md`
- **Settled decisions and non-negotiables**:
  - compatibility-first ownership is not the target architecture
  - completed layout and render owners remain valid
  - public API work from Tranche 5 remains the center
- **Authorization boundary**:
  - retire or demote compatibility-first structures as needed
  - do not lose accepted plotting capabilities
- **Current-state diagnosis**:
  - Tranche 5 created the correct public owner
  - default module and test paths still need cleanup if legacy ownership
    survives
- **Primary-goal lock**:
  - lock items 1, 3, 4, 5, and 7
- **Direct red-state repros**:
  - public plotting still passes through `PlotKeywordSpec`
  - `src/PhyloMakie.jl` still includes legacy keyword files by default
- **Owner and invariant being repaired or relied on**:
  - retire the wrong owner
  - preserve the existing geometry and render invariants
- **Exact files or surfaces in scope**:
  - `src/PhyloMakie.jl`
  - compatibility-owner files
  - public owner files
  - verification metadata and tests affected by the retirement
- **Exact files or surfaces out of scope**:
  - final docs and migration closure
- **Required upstream primary sources**:
  - the same sources as Tranche 5, plus any compatibility reference kept for an
    explicit opt-in adapter
- **Green-state gates**:
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
  - public plotting proof remains green
- **Stop conditions**:
  - stop if compatibility retirement would require throwing away proven layout
    or render owners instead of simply rewiring their consumer

### How to verify

- **Manual**: inspect the default module shell and confirm the Makie-native
  owner is the public center.
- **Automated**:
  - shell tests for default includes and public owner presence
  - public plotting tests remain green
  - helper and render regressions remain green
  - docs build remains green

Negative verification for the known bad shape:

- The tranche must fail if the default public plotting path still routes
  through the compatibility-first owner as anything more than an explicit,
  opt-in bridge.

### Acceptance criteria

- [ ] Given the tranche-5 public owner, when this tranche completes, then the
  default public plotting path no longer depends on the compatibility-first
  owner as the package center.
- [ ] Given the completed layout and render foundations, when this tranche
  completes, then they remain reusable and green.
- [ ] Given the old default include path, when verification is run, then the
  tranche fails if the old compatibility-first owner still sits at the center
  of public plotting.

### User stories addressed

- User stories 7, 8, 9, and 10 from the PRD

## Tranche 7: Docs, migration, and final capability closure

**Type**: AFK
**Blocked by**: Tranche 6

### Governance and required reading

- Mandated line-by-line reading of every document listed in `Active
  authorities` above before implementation starts.
- Mandated reading of the revised design brief, revised PRD, and the final
  public plot owner from Tranches 5 and 6.
- Mandated reading of any migration notes that describe the relationship
  between PhyloPlots capabilities and the Makie-native public API.

### Primary-goal lock

- Close lock items 2, 5, 6, and 7.
- Preserve lock items 1 and 4 by keeping public examples aligned with the
  final public owner and the completed internal invariants.
- Non-completion condition: this tranche is not complete if users still have
  to infer the new package from legacy docs, stale metadata, or implementation
  details.

### What to build

Close the public-facing and verification-facing truth surface for the revised
architecture.

This tranche is user-facing and stabilization-oriented.

It must:

- rewrite docs to teach the Makie-native API first
- provide migration material from PhyloPlots capabilities to PhyloMakie usage
- update verification metadata so it describes the final public architecture
  honestly
- close direct public composition and capability proofs

### Legacy artifacts to retire or demote

- docs that teach the old keyword shell as canonical
- metadata that defines the package in compatibility-first terms
- README or example text that makes the package read like a backend swap

### Forbidden regressions

- Teaching the legacy keyword shell as the primary user story
- Hiding API differences in prose while claiming "same package, new backend"
- Leaving source-backed verification metadata anchored to the pre-rewrite
  target architecture
- Replacing direct public proof with helper-only green suites

### Environment and dependency baseline

- Preserve the final public owner from Tranches 5 and 6
- Preserve the completed helper and render regression suites
- Preserve the Makie dependency baseline and source-set note unless a new
  tranche explicitly revalidates and updates them

### Handoff packet

- **Active authorities**:
  - every document listed in `Active authorities`
- **Parent documents**:
  - `01_prd.md`
  - `design/prod01-vision.md`
  - `design/prod01-vision-supplement.md`
- **Settled decisions and non-negotiables**:
  - teach the Makie-native package first
  - map old capabilities honestly
  - do not redefine the package around the old shell
- **Authorization boundary**:
  - rewrite docs and verification truth aggressively where needed
  - do not reopen public API design without project-owner direction
- **Current-state diagnosis**:
  - internal foundations and public owner are complete
  - public-facing truth and verification metadata still need final closure
- **Primary-goal lock**:
  - lock items 2, 5, 6, and 7
- **Direct red-state repros**:
  - docs teach the wrong mental model
  - verification metadata describes the wrong public product
  - public composition proof is still incomplete
- **Owner and invariant being repaired or relied on**:
  - repair public truth surfaces
  - rely on completed internal and public code owners
- **Exact files or surfaces in scope**:
  - README
  - docs pages
  - verification metadata
  - final public API examples and tests
- **Exact files or surfaces out of scope**:
  - new plotting capabilities beyond the accepted envelope
- **Required upstream primary sources**:
  - the revised design brief, revised PRD, final public owner, and the legacy
    capability references used for migration material
- **Green-state gates**:
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
  - public composition and capability proof remain green
- **Stop conditions**:
  - stop if docs closure would require pretending the API did not change

### How to verify

- **Manual**: read the docs and confirm that a new user can understand the
  package as a Makie-native product without learning the legacy shell first.
- **Automated**:
  - full test suite
  - full docs build
  - public composition examples
  - source-backed verification metadata tests

Negative verification for the known bad shape:

- The tranche must fail if the package can still be described honestly only as
  a compatibility shell or a backend swap.

### Acceptance criteria

- [ ] Given the final public plotting owner, when this tranche completes, then
  docs teach that owner first.
- [ ] Given a user familiar with PhyloPlots capabilities, when they read the
  migration material, then they can map old tasks to the new surface without
  being told the APIs are the same.
- [ ] Given the old verification metadata and docs truth, when verification is
  run, then the tranche fails if those stale descriptions survive.

### User stories addressed

- User stories 2, 3, 4, 5, 6, 7, 9, and 10 from the PRD
