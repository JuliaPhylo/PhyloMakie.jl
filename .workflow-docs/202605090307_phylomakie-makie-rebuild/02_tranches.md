---
date-created: 2026-05-09T03:07:47
date-updated: 2026-05-09T14:40:00
parent-prd: 01_prd.md
status: tranche-1-approved
---

# Tranches for Makie-native HybridNetwork plotting in PhyloMakie

## Parent PRD

`01_prd.md`

## Approval state

- This tranche plan remains proposed planning output for Tranches 2 through 6.
- Project-owner approval for Tranche 1 and its tranche-1 tasking file was
  recorded on 2026-05-09 via the explicit execution request for tranche-1
  implementation.
- Downstream `Tranches -> Tasks` execution remains blocked for Tranches 2
  through 6 until the project owner explicitly approves them.

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

- The repo-local `STYLE*.md` set is the operative governance set for this run.
- The overlapping bundled baseline files match the repo-local copies.
- No repo-local `STYLE-domain-vocabulary.md` was found.
- `STYLE-vocabulary.md` is the domain vocabulary authority for this project.
- `STYLE-workflow-vocabulary.md` remains authoritative for workflow-process
  terms such as `tranche`, `lock item`, `primary-goal lock`, and
  `red-state repro`.

## Controlled vocabulary

- Use `phyloplot` and `phyloplot!` as the canonical user-facing public names.
- Treat `PhyloPlot` as the recipe type name, not the primary user-facing API.
- Treat `PhyloNetworks.HybridNetwork` as the canonical supported input type for
  this production run.
- Use `major hybrid edge` and `minor hybrid edge` as the canonical edge terms.
- Use `full-tree style` and `major-tree style` in prose, and `:fulltree` and
  `:majortree` for the exact public symbols.
- Use `keyword surface`, `layout engine`, `render adapter`, and
  `FigureAxisPlot` with the meanings fixed in `STYLE-vocabulary.md`.
- Do not import foreign project terms such as `lineageplot`, `EdgeLayer`, or
  `lineageunits` into PhyloMakie planning, code, or docs.

## Upstream primary sources

- `PhyloPlots.jl/src/phylonetworksPlots.jl`
- `PhyloPlots.jl/src/plotRCall.jl`
- `PhyloPlots.jl/test/test_phylonetworkPlots.jl`
- `PhyloNetworks.jl/src/types.jl`
- `PhyloNetworks.jl/src/manipulateNet.jl`
- `PhyloNetworks.jl/docs/src/man/net_plot.md`
- `~/.julia/packages/Makie/FUAHr/MakieCore/src/recipes.jl`
- `~/.julia/packages/Makie/TOy8O/src/figureplotting.jl`

Inference boundary note:

- The exact Makie primitive-source files used by the final implementation for
  lines, arrows, and text are not fully settled in the PRD.
- Any tranche that depends on more detailed Makie primitive behavior must
  revalidate the exact resolved Makie dependency tree at tranche start and
  record the final source files it relies on.

## Authorization boundary

- Deep internal redesign is authorized.
- Public plotting behavior drift from `PhyloPlots.plot` is not authorized in
  this production run.
- Compatibility aliases to old package names are not required.
- R interoperability remains out of scope.
- No tranche may duplicate shared keyword, layout, or render semantics across
  sibling layers instead of establishing one owner.
- Every tranche must begin and end in a green, policy-compliant state.

## Tranche index

| Tranch id | Title | Status |
| --- | --- | --- |
| 1 | Verification and module shell foundation | Approved and implemented |
| 2 | Public keyword normalization owner | Proposed |
| 3 | Layout and annotation data owner | Proposed |
| 4 | Makie render adapter and style parity closure | Proposed |
| 5 | Recipe and entry surface integration | Proposed |
| 6 | Stabilization, docs, and cross-surface parity sweep | Proposed |

## Tranche 1: Verification and module shell foundation

**Type**: AFK
**Blocked by**: None — can start immediately
**Approval record**: Project-owner approval was recorded on 2026-05-09 via the
explicit execution request for tranche-1 implementation.

### Parent PRD

`01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of every document listed in `Active authorities`
  above before implementation starts.
- Mandated reading of `STYLE-vocabulary.md` and
  `STYLE-workflow-vocabulary.md`.
- Mandated reading of the upstream sources named in this tranche handoff
  packet before implementation starts.

### Primary-goal lock

- Lock item 7: establish the foundational verification owner and stop the
  repository from treating Aqua, JET, and docs boilerplate as sufficient proof
  for plotting work.
- Preserve lock items 1 through 6 by creating the fixture corpus, contract
  matrix, and test and docs scaffolding that later tranches must populate.
- Non-completion condition: this tranche is not complete if later work could
  still land without dedicated plot-sensitive tests, docs scenarios, and direct
  red-state repro anchors.

### What to build

Build the foundational owner for green-state discipline, test fixtures, docs
scaffolding, and top-level source layout.

This tranche is foundational and verification-focused.

The remaining owner is a thin `PhyloMakie` module shell that imports
dependencies, exports public names, and includes implementation files only.
The remaining verification owner is a plot-specific harness that inventories
the accepted scenarios, the lock items, and the required proof surfaces before
feature work begins.

The public surfaces affected by this tranche are the whole supported entry
surface matrix because all later tranches depend on the same docs, tests, and
fixture discipline. No public plotting API is expected to be complete in this
tranche. Public entry-surface proofs are intentionally deferred to Tranche 5,
and full closure of the production verification envelope is intentionally
deferred to Tranche 6.

When this tranche is complete, the current empty module shell, placeholder
comment, boilerplate-only tests, and boilerplate-only docs state must no longer
remain as the effective owners of plotting verification.

### Legacy artifacts to retire or demote

- The placeholder comment in `src/PhyloMakie.jl`.
- The current no-owner module shell as the long-term source structure.
- The current test surface in `test/runtests.jl` as the only verification
  owner for plotting work.
- The current docs home page as a pure boilerplate landing page with no plot
  contract scenarios.

### Forbidden regressions

- Adding real plotting code while keeping the top-level module as a logic dump
  instead of a thin shell with includes.
- Claiming green from Aqua, JET, and a docs skeleton alone.
- Creating plotting fixtures or contract matrices only in comments, notes, or
  PR text rather than in repo-owned test or docs artifacts.
- Letting foreign project vocabulary re-enter docs, tests, or file naming.

### Environment and dependency baseline

- Preserve the existing root, `test/`, and `docs/` project split.
- Preserve the existing `[sources.PhyloMakie] path = "../"` path override in
  `test/Project.toml` and `docs/Project.toml`.
- Use repo-local projects for tests and docs rather than an ad hoc global Julia
  environment.
- Revalidate the exact upstream file set named in this document before feature
  implementation begins.

### Handoff packet

- **Active authorities**: `CONTRIBUTING.md`; all repo-local root `STYLE*.md`
  files; `STYLE-vocabulary.md`; `01_prd.md`; `design/prod01-vision.md`;
  `design/prod01-vision-supplement.md`.
- **Parent documents**: `01_prd.md`; `design/prod01-vision.md`;
  `design/prod01-vision-supplement.md`.
- **Settled decisions and non-negotiables**: follow `PhyloPlots.plot` public
  behavior; keep `phyloplot`, `phyloplot!`, and Makie `plot(net)` as the
  target surfaces; keep R interop out of scope; keep foreign domain vocabulary
  out of project-owned assets.
- **Authorization boundary**: deep internal redesign is allowed; public
  behavior drift is not; compatibility aliases are not required.
- **Current-state diagnosis**: `src/PhyloMakie.jl` is an empty shell; tests are
  Aqua and JET only; docs are boilerplate only; there is no plotting-specific
  verification owner.
- **Primary-goal lock**: establish the verification owner for lock item 7 and
  preserve the remaining lock items as explicit future proof obligations.
- **Direct red-state repros**: no `phyloplot`; no recipe; no dispatch; no
  plotting fixtures; no plot-specific tests; no render artifacts.
- **Owner and invariant under repair**: verification ownership and thin-module
  ownership.
- **Exact files or surfaces in scope**: `src/PhyloMakie.jl`; new source files
  under `src/`; `test/runtests.jl`; new test files under `test/`; `docs/src/`;
  `docs/make.jl`.
- **Exact files or surfaces out of scope**: R interop; `sexp`; `rexport`;
  non-`HybridNetwork` public input types; performance tuning; GraphMakie as a
  goal in itself.
- **Required upstream primary sources**: `PhyloPlots.jl/test/test_phylonetworkPlots.jl`;
  `PhyloPlots.jl/src/phylonetworksPlots.jl`; Makie recipe and figure-plotting
  sources for return-shape and entry-surface expectations.
- **Green-state gates**: package tests; Aqua; JET; docs build.
- **Stop conditions**: stop if the tranche cannot create a real plot-sensitive
  verification owner without changing the public contract; stop if a later
  tranche is forced to infer missing fixtures or contract matrices from PR
  prose alone.

### How to verify

- **Manual**: inspect `src/PhyloMakie.jl` and confirm it is only a module
  shell with imports, exports, and includes; inspect `test/` and `docs/src/`
  and confirm that accepted plotting scenarios and red-state repro anchors have
  repo-owned homes rather than only boilerplate placeholders.
- **Automated**: run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl`; ensure the test suite includes
  plot-specific fixture and contract-matrix coverage that would fail if those
  fixtures or scenario inventories were absent.

Negative verification for the known bad shape:

- The tranche must fail if the repository still presents Aqua, JET, and docs
  boilerplate as the only proof surface for plotting work.

### Acceptance criteria

- [ ] Given the current empty source shell, when this tranche completes, then
  `src/PhyloMakie.jl` is a thin owner shell rather than a placeholder module.
- [ ] Given the current boilerplate-only verification surface, when this
  tranche completes, then plot-sensitive fixtures and scenario inventories
  exist in repo-owned tests and docs scaffolding.
- [ ] Given the current legacy placeholder artifacts named above, when this
  tranche is complete, then they are removed, demoted, or prevented from
  remaining the effective owners of plotting verification.
- [ ] Given the forbidden regression shape of claiming green from boilerplate
  only, when verification is run, then the tranche fails rather than reporting
  a fake green.

### User stories addressed

- User story 12: As a maintainer, I can verify layout behavior with pure Julia
  helper tests without needing to infer geometry correctness from screenshots
  alone.
- User story 13: As a maintainer, I can verify visual and compositional
  behavior with render artifacts rather than claiming success from a green
  helper suite only.
- User story 14: As a future contributor, I can discuss animation,
  backend-specific polish, performance, or broader graph support later without
  those topics quietly driving this production run's acceptance boundary.

## Tranche 2: Public keyword normalization owner

**Type**: AFK
**Blocked by**: Tranche 1

### Parent PRD

`01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of every document listed in `Active
  authorities` above before implementation starts.
- Mandated reading of `STYLE-vocabulary.md` and
  `STYLE-workflow-vocabulary.md`.
- Mandated reading of `PhyloPlots.jl/src/plotRCall.jl`,
  `design/prod01-vision-supplement.md`, and any tranche-start notes that map
  the authoritative keyword table into the local owner.

### Primary-goal lock

- Lock item 2: create one canonical owner for the full public keyword surface.
- Preserve lock items 1, 3, 4, 5, and 6 by resolving keyword semantics once
  and forwarding a single resolved plot spec downstream.
- Non-completion condition: this tranche is not complete if any supported entry
  surface would still need to infer defaults, warnings, precedence, or
  fallbacks independently.

### What to build

Build the internal owner that resolves the complete `PhyloPlots.plot`
keyword surface into one validated plot-spec object or equivalent structured
return.

This tranche is foundational and owner-establishing.

The remaining owner is keyword normalization. The retired shape is per-surface
keyword parsing in recipe, render, docs, or tests.

The supported public surfaces that must move together because they share the
same keyword semantic are `phyloplot`, `phyloplot!`, and `plot(net)`.
Direct entry-surface integration is intentionally deferred to Tranche 5 because
this tranche exists to establish the owner first, not to duplicate keyword
behavior across wrappers.

This tranche must cover the full production-run keyword surface, including:
`useedgelength`, `style`, `arrowlen`, `minorlinetype`, `edgewidth`, `xlim`,
`ylim`, `tipoffset`, `preorder`, `showtiplabel`, `shownodelabel`,
`shownodenumber`, `showedgelength`, `showgamma`, `showedgenumber`,
`edgelabel`, `nodelabel`, `tipcex`, `nodecex`, `edgecex`, `edgecolor`,
`majorhybridedgecolor`, `minorhybridedgecolor`, `defaultedgecolor`,
`edgenumbercolor`, `edgelabelcolor`, `nodelabelcolor`, `edgelabeladj`, and
`nodelabeladj`.

When this tranche is complete, duplicated surface-local keyword logic, silent
default drift, and casual Makie-idiom renaming of the accepted public keyword
surface must no longer be able to survive.

### Legacy artifacts to retire or demote

- Any wrapper-local keyword parsing in `phyloplot`, `phyloplot!`, or
  `Makie.plot`.
- Any render-layer fallback logic that recreates public keyword defaults.
- Any docs-only description of keyword semantics that is not backed by one
  normalization owner.

### Forbidden regressions

- Renaming or reinterpreting accepted public keywords without explicit user
  reapproval.
- Letting `phyloplot`, `phyloplot!`, and `plot(net)` drift in defaults,
  warnings, or fallback behavior.
- Recomputing `arrowlen` and `minorlinetype` policy independently in later
  layers.
- Treating docs examples as the owner of keyword precedence instead of code.

### Environment and dependency baseline

- Treat `PhyloPlots.jl/src/plotRCall.jl` and
  `design/prod01-vision-supplement.md` as the behavioral authorities for the
  keyword surface in this production run.
- Preserve the repo-local docs and test path-override policy.
- Do not add dependency churn unless the chosen normalization representation
  truly requires it.

### Handoff packet

- **Active authorities**: same active authority set named in this file.
- **Parent documents**: `01_prd.md`; `design/prod01-vision.md`;
  `design/prod01-vision-supplement.md`.
- **Settled decisions and non-negotiables**: public keyword names and visible
  behavior follow `PhyloPlots.plot`; `tip`-named options remain public; no
  external compatibility alias surface is required.
- **Authorization boundary**: internal redesign of the owner is allowed;
  public keyword drift is not.
- **Current-state diagnosis**: no keyword owner exists yet in PhyloMakie, and
  the upstream public contract currently lives in `plotRCall.jl`.
- **Primary-goal lock**: lock item 2 is the owner goal; later tranches consume
  the resolved plot spec rather than re-normalizing.
- **Direct red-state repros**: the package has no keyword owner; the accepted
  keyword table lives only in the PRD and upstream sources.
- **Owner and invariant under repair**: one public keyword surface, one
  normalization owner.
- **Exact files or surfaces in scope**: new keyword-owner source files under
  `src/`; tests that directly cover normalization behavior.
- **Exact files or surfaces out of scope**: render primitives; entry-surface
  return-shape work; docs-only parity claims without code ownership.
- **Required upstream primary sources**: `PhyloPlots.jl/src/plotRCall.jl`;
  `design/prod01-vision-supplement.md`; `PhyloNetworks.jl/docs/src/man/net_plot.md`
  for user-facing plotting contract context.
- **Green-state gates**: package tests; Aqua; JET; docs build; direct
  normalization regressions.
- **Stop conditions**: stop if preserving the public keyword surface appears to
  require public drift; stop if a downstream layer would still need to own a
  separate copy of defaults or warnings.

### How to verify

- **Manual**: compare the local normalization owner against the authoritative
  keyword table and confirm that one resolved internal representation covers all
  supported keyword semantics.
- **Automated**: run `julia --project=test test/runtests.jl` with direct
  normalization tests that cover representative defaults, warning paths,
  dict-versus-scalar color behavior, style-dependent `arrowlen` and
  `minorlinetype`, and bad `xlim` and `ylim` inputs.

Proxy note for deferred public surfaces:

- At this tranche, the normalization owner is the exact proxy for the three
  public entry surfaces because those surfaces are not yet exposed. Tranche 5
  must add surface-by-surface proofs before lock item 2 is considered fully
  closed.

Negative verification for the known bad shape:

- Verification must fail if two different callers can derive different defaults
  or warning behavior for the same public keyword combination.

### Acceptance criteria

- [ ] Given any supported public keyword combination, when the normalization
  owner resolves it, then one canonical plot spec is produced with no
  per-surface drift.
- [ ] Given an invalid or warning-producing keyword condition, then the
  normalization owner emits the accepted error or warning behavior rather than a
  silent reinterpretation.
- [ ] Given the legacy duplicated-artifact shapes named above, when the tranche
  is complete, then they are removed, demoted, or otherwise prevented from
  surviving as second implementations.
- [ ] Given the forbidden regression shape of surface-local keyword logic, when
  verification is run, then the tranche fails rather than reporting a fake
  green.

### User stories addressed

- User story 6: As a user working with branch lengths, I can set
  `useedgelength=true` and have x positions scale according to the current
  PhyloPlots contract, with missing lengths handled the same way.
- User story 9: As a user styling a network, I can use `edgecolor`,
  hybrid-edge colors, `edgewidth`, and text-size keywords and get the legacy
  contract rather than a silent reinterpretation.
- User story 10: As a user depending on `tip`-named public options, I can use
  `showtiplabel`, `tipoffset`, and `tipcex` exactly as documented in
  PhyloPlots for this production run.
- User story 11: As a maintainer, I can locate one owner for keyword
  normalization instead of rediscovering precedence and default rules in every
  entry surface.

## Tranche 3: Layout and annotation data owner

**Type**: AFK
**Blocked by**: Tranche 2

### Parent PRD

`01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of every document listed in `Active
  authorities` above before implementation starts.
- Mandated reading of `STYLE-vocabulary.md` and
  `STYLE-workflow-vocabulary.md`.
- Mandated reading of `PhyloPlots.jl/src/phylonetworksPlots.jl`,
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl`,
  `PhyloNetworks.jl/src/manipulateNet.jl`, and
  `PhyloNetworks.jl/src/types.jl`.

### Primary-goal lock

- Lock item 3: create a PhyloMakie-owned layout engine with verified geometry
  parity.
- Lock item 5: create a PhyloMakie-owned annotation-data and DataFrame
  validation owner with verified midpoint and warning parity.
- Preserve the mutation-policy boundary by keeping the current `preorder=true`
  behavior explicit unless a later user-approved redesign reopens it.

### What to build

Build the Makie-independent owner for geometry, annotation anchors, and
annotation-data validation by porting the verified pure Julia helpers from the
upstream layout owner.

This tranche is foundational and migration-oriented.

The remaining owner is the PhyloMakie layout engine and annotation-data owner.
The retired shapes are runtime dependence on PhyloPlots helpers, geometry logic
embedded in rendering code, and ad hoc DataFrame checks scattered across later
layers.

The supported public surfaces that move together because they share this owner
semantic are `phyloplot`, `phyloplot!`, and `plot(net)`. Direct public-surface
proofs are intentionally deferred to Tranche 5 because this tranche exists to
establish the shared owner. Render-level visibility of the results is
intentionally deferred to Tranche 4.

This tranche should port and adapt the upstream helpers that currently own the
contract:

- `edgenode_coordinates`
- `check_nodedataframe`
- `prepare_nodedataframe`
- `prepare_edgedataframe`

This tranche may preserve the current `directedges!` and `preorder!` mutation
behavior behind an explicit local owner for this production run, but it must
not silently change the public semantics around `preorder`.

When this tranche is complete, geometry and annotation parity can no longer
depend on visual guessing, render-layer nudging, or hidden calls into the
upstream PhyloPlots package at runtime.

### Legacy artifacts to retire or demote

- Any direct runtime dependence on `PhyloPlots.jl` as the live geometry owner.
- Any render-layer recomputation of geometry or annotation midpoints.
- Any wrapper-local DataFrame validation.
- Any R-shaped helper signatures that survive only because downstream code is
  compensating for them.

### Forbidden regressions

- Replacing upstream-tested geometry with handwritten coordinates that merely
  make screenshots look plausible.
- Swallowing the accepted missing-value and unmatched-number warning behavior.
- Changing `preorder` mutation semantics without explicit, user-approved owner
  framing.
- Encoding midpoint placement in render-time offsets instead of the layout
  owner.

### Environment and dependency baseline

- Treat `PhyloPlots.jl/src/phylonetworksPlots.jl` as the primary-source owner
  for geometry and annotation-data semantics.
- Treat `PhyloPlots.jl/test/test_phylonetworkPlots.jl` as the primary-source
  regression corpus for helper behavior.
- Treat `PhyloNetworks.jl/src/manipulateNet.jl` and `types.jl` as the source
  of truth for `HybridNetwork`, `directedges!`, and `preorder!` behavior.
- Do not change the public mutation contract unless the project owner reopens
  that question explicitly.

### Handoff packet

- **Active authorities**: same active authority set named in this file.
- **Parent documents**: `01_prd.md`; `design/prod01-vision.md`;
  `design/prod01-vision-supplement.md`.
- **Settled decisions and non-negotiables**: port the pure Julia layout and
  annotation helpers rather than casually redesigning them; preserve accepted
  public behavior; keep R interop out of scope.
- **Authorization boundary**: internal owner redesign is allowed; visible
  geometry or annotation drift is not.
- **Current-state diagnosis**: PhyloMakie currently has no layout owner, no
  annotation-data owner, and no helper-level regressions.
- **Primary-goal lock**: lock items 3 and 5 are the main closure targets; any
  mutation-policy change beyond preservation or explicit isolation is out of
  scope for this tranche.
- **Direct red-state repros**: the package has no local geometry owner; the
  upstream helper regressions live only in `test_phylonetworkPlots.jl`.
- **Owner and invariant under repair**: one geometry contract, one layout
  owner; one annotation-data validation contract, one owner.
- **Exact files or surfaces in scope**: new layout-owner source files under
  `src/`; helper-level tests under `test/`.
- **Exact files or surfaces out of scope**: Makie primitive composition;
  entry-surface return semantics; external compatibility aliases.
- **Required upstream primary sources**: `PhyloPlots.jl/src/phylonetworksPlots.jl`;
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl`; `PhyloNetworks.jl/src/manipulateNet.jl`;
  `PhyloNetworks.jl/src/types.jl`.
- **Green-state gates**: package tests; Aqua; JET; docs build; helper-level
  regression tests for geometry and annotation-data behavior.
- **Stop conditions**: stop if preserving accepted behavior appears to require a
  render-layer workaround; stop if implementing the owner would require changing
  the public `preorder` semantics.

### How to verify

- **Manual**: inspect the local layout owner and confirm it is Makie
  independent, that annotation-data validation lives there, and that public
  mutation semantics are explicit rather than implicit.
- **Automated**: run `julia --project=test test/runtests.jl` with helper-level
  regression tests adapted from `PhyloPlots.jl/test/test_phylonetworkPlots.jl`,
  including `useedgelength` cases, `:fulltree` versus `:majortree` coordinate
  differences, level-2 hybrid network repros, unmatched node and edge warning
  cases, and midpoint placement checks.

Proxy note for deferred public surfaces:

- At this tranche, helper-level regression is the exact proxy for all supported
  public surfaces because all later surfaces consume the same geometry and
  annotation outputs. Tranche 5 must still prove that each entry surface
  actually uses this owner faithfully.

Negative verification for the known bad shape:

- Verification must fail if a screenshot can look plausible while the helper
  coordinates, warning behavior, or midpoint placement drift from the upstream
  contract.

### Acceptance criteria

- [ ] Given the upstream regression corpus, when the local layout owner runs,
  then geometry outputs and annotation anchor outputs match the accepted
  contract.
- [ ] Given malformed or partially matched annotation DataFrames, then the
  local owner preserves the accepted warning and missing-value handling
  behavior.
- [ ] Given the legacy duplicated-artifact shapes named above, when the tranche
  is complete, then they are removed, demoted, or otherwise prevented from
  surviving as second implementations.
- [ ] Given the forbidden regression shape of render-layer geometry repair,
  when verification is run, then the tranche fails rather than reporting a fake
  green.

### User stories addressed

- User story 4: As a user inspecting reticulation structure, I can see major
  and minor hybrid edges rendered distinctly and consistently with current
  PhyloPlots semantics.
- User story 5: As a user comparing styles, I can switch between `:fulltree`
  and `:majortree` and get the same semantic distinction I currently get from
  PhyloPlots.
- User story 6: As a user working with branch lengths, I can set
  `useedgelength=true` and have x positions scale according to the current
  PhyloPlots contract, with missing lengths handled the same way.
- User story 7: As a user annotating support values or other metadata, I can
  pass `nodelabel` and `edgelabel` DataFrames and get the same validation and
  midpoint placement behavior I get from PhyloPlots.
- User story 8: As a user inspecting internals, I can enable
  `shownodenumber`, `showedgenumber`, `showedgelength`, and `showgamma` and
  see the correct text at the correct locations.
- User story 12: As a maintainer, I can verify layout behavior with pure Julia
  helper tests without needing to infer geometry correctness from screenshots
  alone.

## Tranche 4: Makie render adapter and style parity closure

**Type**: HITL
**Blocked by**: Tranche 3

### Parent PRD

`01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of every document listed in `Active
  authorities` above before implementation starts.
- Mandated reading of `STYLE-vocabulary.md` and
  `STYLE-workflow-vocabulary.md`.
- Mandated reading of the Makie-family sources recorded in the PRD and
  tranche-start revalidation of the exact primitive-source files used for the
  final render adapter.

### Primary-goal lock

- Lock item 4: preserve visible distinction between full-tree style and
  major-tree style, including hybrid-edge rendering, arrow behavior, and
  color-policy semantics.
- Preserve lock items 2, 3, and 5 by consuming the keyword owner and layout
  owner without recreating their logic in the render layer.
- Non-completion condition: this tranche is not complete if render output can
  collapse the two styles, lose hybrid-edge semantics, or depend on accidental
  draw order without explicit policy.

### What to build

Build the render adapter that maps the resolved plot spec and layout outputs to
Makie primitives, text, and composition policy once.

This tranche is migration-oriented, user-visible, and review-gated.

The remaining owner is the render adapter. The retired shapes are R-oriented
draw sequencing, style-specific shadow implementations, and render-time
recomputation of layout or keyword semantics.

The supported public surfaces that move together because they share this owner
semantic are `phyloplot`, `phyloplot!`, and `plot(net)`. Surface exposure and
return-shape proof are intentionally deferred to Tranche 5 because this tranche
exists to close the shared render contract first.

This tranche is HITL because the exact Makie primitive-source files needed for
lines, arrows, and text must be revalidated against the resolved dependency
tree at tranche start, and that source set should receive project-owner review
before implementation proceeds.

When this tranche is complete, style distinction, hybrid-edge rendering, color
policy, width policy, and text placement can no longer depend on accidental
Makie behavior, per-surface rendering branches, or undocumented draw order.

### Legacy artifacts to retire or demote

- Any R-shaped drawing assumptions that survive in the local render path.
- Any full-tree and major-tree rendering branches that duplicate whole render
  pipelines instead of sharing one owner with explicit policy switches.
- Any temporary draw-order hacks that only make one acceptance network look
  correct.

### Forbidden regressions

- Letting `:fulltree` and `:majortree` collapse into the same visual outcome.
- Recomputing geometry inside the render layer.
- Using different render semantics for `phyloplot`, `phyloplot!`, and
  `plot(net)`.
- Relying on accidental Makie layering or hidden state rather than explicit
  composition policy.

### Environment and dependency baseline

- Revalidate the exact Makie primitive-source files used for the final render
  adapter before code changes begin.
- Preserve the repo-local path-override policy for docs and tests.
- Do not freeze unverified Makie recollection into implementation or downstream
  tasking.

### Handoff packet

- **Active authorities**: same active authority set named in this file.
- **Parent documents**: `01_prd.md`; `design/prod01-vision.md`;
  `design/prod01-vision-supplement.md`.
- **Settled decisions and non-negotiables**: preserve visible behavior from
  `PhyloPlots.plot`; keep hybrid-edge color and style semantics; keep the
  render owner separate from layout and normalization owners.
- **Authorization boundary**: internal render design is allowed; silent
  divergence from Makie or `PhyloPlots.plot` behavior is not.
- **Current-state diagnosis**: PhyloMakie has no render owner, and the only
  live rendering authority is the old R shell in `plotRCall.jl`.
- **Primary-goal lock**: lock item 4 is the closure target; later tranches
  integrate this owner into public entry surfaces and docs.
- **Direct red-state repros**: the acceptance network currently has no Makie
  render path, and style comparison has no local proof surface.
- **Owner and invariant under repair**: one render composition policy, one
  render owner.
- **Exact files or surfaces in scope**: render-owner source files under `src/`;
  render-focused tests and artifacts under `test/` and `docs/src/`.
- **Exact files or surfaces out of scope**: keyword normalization; pure layout
  calculations; entry-surface return-shape wrappers beyond the minimal internal
  harness needed to test rendering.
- **Required upstream primary sources**: Makie recipe and figure-plotting
  sources; tranche-start revalidated Makie primitive sources; `plotRCall.jl`
  for visible rendering behavior.
- **Green-state gates**: package tests; Aqua; JET; docs build; render-level
  artifacts or image-diff checks for the accepted style and hybrid-edge cases.
- **Stop conditions**: stop if the resolved Makie contract differs materially
  from the recorded local sources; stop if preserving the accepted visual
  contract appears to require public-surface drift or an unapproved Makie
  divergence.

### How to verify

- **Manual**: review the tranche-start record of exact Makie primitive-source
  files, inspect the accepted style-comparison artifacts, and confirm that the
  render adapter owns draw order, arrow, text, and style policy explicitly.
- **Automated**: run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` with render-level checks for the accepted
  hybrid network, style-comparison artifacts for `:fulltree` versus
  `:majortree`, edgecolor-dict coverage, arrow behavior, and gamma text
  visibility.

Proxy note for deferred public surfaces:

- At this tranche, the render adapter may be proven through an internal harness
  that bypasses the final public wrappers. Tranche 5 must still prove that all
  supported entry surfaces invoke the same render owner.

Negative verification for the known bad shape:

- Verification must fail if the style-comparison artifact can go green while
  the two style modes remain visually indistinguishable or while minor hybrid
  edges lose their accepted rendering rules.

### Acceptance criteria

- [ ] Given the accepted reticulate network, when the render adapter runs, then
  major and minor hybrid-edge rendering follows the accepted style, color, and
  arrow contract.
- [ ] Given `style=:fulltree` versus `style=:majortree`, when render artifacts
  are produced, then the two styles remain visibly distinct.
- [ ] Given the legacy duplicated-artifact shapes named above, when the tranche
  is complete, then they are removed, demoted, or otherwise prevented from
  surviving as second implementations.
- [ ] Given the forbidden regression shape of style collapse or accidental
  composition policy, when verification is run, then the tranche fails rather
  than reporting a fake green.

### User stories addressed

- User story 4: As a user inspecting reticulation structure, I can see major
  and minor hybrid edges rendered distinctly and consistently with current
  PhyloPlots semantics.
- User story 5: As a user comparing styles, I can switch between `:fulltree`
  and `:majortree` and get the same semantic distinction I currently get from
  PhyloPlots.
- User story 7: As a user annotating support values or other metadata, I can
  pass `nodelabel` and `edgelabel` DataFrames and get the same validation and
  midpoint placement behavior I get from PhyloPlots.
- User story 8: As a user inspecting internals, I can enable
  `shownodenumber`, `showedgenumber`, `showedgelength`, and `showgamma` and
  see the correct text at the correct locations.
- User story 9: As a user styling a network, I can use `edgecolor`,
  hybrid-edge colors, `edgewidth`, and text-size keywords and get the legacy
  contract rather than a silent reinterpretation.
- User story 13: As a maintainer, I can verify visual and compositional
  behavior with render artifacts rather than claiming success from a green
  helper suite only.

## Tranche 5: Recipe and entry surface integration

**Type**: AFK
**Blocked by**: Tranche 4

### Parent PRD

`01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of every document listed in `Active
  authorities` above before implementation starts.
- Mandated reading of `STYLE-vocabulary.md` and
  `STYLE-workflow-vocabulary.md`.
- Mandated reading of the revalidated Makie recipe and figure-plotting sources,
  especially the `@recipe`, `plottype`, and `FigureAxisPlot` contracts.

### Primary-goal lock

- Lock item 1: expose `phyloplot`, `phyloplot!`, and `plot(net)` with the
  accepted return-shape and dispatch contract.
- Lock item 6: preserve composable Makie plotting into existing axis owners
  without state bleed.
- Close the multi-surface proof obligation for the shared keyword, layout, and
  render owners established earlier.

### What to build

Build the public recipe and entry-surface owner that exposes the supported
Makie plotting surfaces and connects them to the shared normalization, layout,
and render owners.

This tranche is user-facing and integration-focused.

The remaining owner is the recipe and entry-surface layer. The retired shapes
are wrapper-local re-normalization, wrapper-local rendering branches, hidden
state transfer across panels, and surprising mutating versus non-mutating
behavior.

The supported public surfaces that must move together are:

- `phyloplot(net::PhyloNetworks.HybridNetwork; kwargs...)::Makie.FigureAxisPlot`
- `phyloplot!(ax, net::PhyloNetworks.HybridNetwork; kwargs...)`
- `Makie.plottype(::PhyloNetworks.HybridNetwork) = PhyloPlot` so `plot(net)`
  works through Makie style dispatch

Docs hardening and the final parity sweep are intentionally deferred to
Tranche 6. The entry surfaces themselves are not deferred.

When this tranche is complete, the package can no longer hide divergent
behavior behind one entry surface, nor can it blur Makie's mutating versus
non-mutating contract.

### Legacy artifacts to retire or demote

- Any wrapper-local keyword or render logic.
- Any public wrapper that returns a surprising shape or mutates unexpectedly.
- Any shared state object that leaks coordinates or annotations across axes.

### Forbidden regressions

- `phyloplot` failing to return `Makie.FigureAxisPlot`.
- `phyloplot!` creating a new figure or axis instead of plotting into the
  existing one.
- `plot(net)` bypassing the same owner stack used by `phyloplot`.
- Different entry surfaces exposing different defaults, style policy, or state
  bleed behavior.

### Environment and dependency baseline

- Follow the revalidated Makie recipe and figure-plotting contract recorded in
  the upstream sources for this run.
- Preserve the repo-local test and docs project structure.
- Do not introduce a local wrapper that hides a Makie contract violation.

### Handoff packet

- **Active authorities**: same active authority set named in this file.
- **Parent documents**: `01_prd.md`; `design/prod01-vision.md`;
  `design/prod01-vision-supplement.md`.
- **Settled decisions and non-negotiables**: keep `phyloplot` and
  `phyloplot!` as the canonical public names; support `plot(net)` through
  `Makie.plottype(::HybridNetwork) = PhyloPlot`; preserve Makie's mutating
  versus non-mutating semantics.
- **Authorization boundary**: internal integration design is allowed; silent
  public entry-surface drift is not.
- **Current-state diagnosis**: the package currently has no public plotting
  API, no recipe, and no dispatch.
- **Primary-goal lock**: lock items 1 and 6 are the closure targets; earlier
  owners must now be proven across all supported public surfaces.
- **Direct red-state repros**: no `phyloplot`; no `phyloplot!`; no
  `Makie.plottype(::HybridNetwork)`; no multi-panel composition proof.
- **Owner and invariant under repair**: one entry-surface matrix, one
  integration owner.
- **Exact files or surfaces in scope**: recipe and entry-surface source files
  under `src/`; API and composition tests under `test/`; docs examples that
  directly exercise the public entry surfaces.
- **Exact files or surfaces out of scope**: broader graph-type support; R
  interop; backend-specific polish.
- **Required upstream primary sources**: revalidated Makie recipe and
  figure-plotting sources; `design/prod01-vision.md`; `plotRCall.jl` for the
  accepted public behavior.
- **Green-state gates**: package tests; Aqua; JET; docs build; direct API
  regressions for `phyloplot`, `phyloplot!`, and `plot(net)`.
- **Stop conditions**: stop if a wrapper would need to own different keyword,
  layout, or render semantics from the shared owners; stop if Makie contract
  compliance would require an externally visible divergence.

### How to verify

- **Manual**: run the accepted MWE shape from `design/prod01-vision.md`,
  destructure `fig, ax, plt = phyloplot(net)`, confirm `plot(net)` returns the
  same public shape through Makie dispatch, and confirm `phyloplot!` composes
  cleanly into existing axes.
- **Automated**: run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` with direct API tests that cover all
  three supported public entry surfaces and multi-panel composition tests that
  prove no coordinate or annotation state bleeds across axes.

Negative verification for the known bad shape:

- Verification must fail if one entry surface can stay green while another one
  still has different defaults, different return shape, or state bleed in
  multi-panel composition.

### Acceptance criteria

- [ ] Given a `HybridNetwork`, when `phyloplot(net)` runs, then it returns
  `Makie.FigureAxisPlot` with the accepted public semantics.
- [ ] Given an existing axis-like owner, when `phyloplot!(ax, net)` runs, then
  it plots into that owner without creating a new figure or leaking state.
- [ ] Given the legacy duplicated-artifact shapes named above, when the tranche
  is complete, then they are removed, demoted, or otherwise prevented from
  surviving as second implementations.
- [ ] Given the forbidden regression shape of divergent entry surfaces, when
  verification is run, then the tranche fails rather than reporting a fake
  green.

### User stories addressed

- User story 1: As a PhyloNetworks user, I can call `phyloplot(net)` on a
  simple tree-like `HybridNetwork` and receive a `Makie.FigureAxisPlot`
  without needing R.
- User story 2: As a Makie user, I can call `plot(net)` and get the PhyloMakie
  recipe automatically.
- User story 3: As a Makie layout user, I can call `phyloplot!(ax, net)` inside
  an existing figure and compose multiple networks without state bleed-through.
- User story 6: As a user working with branch lengths, I can set
  `useedgelength=true` and have x positions scale according to the current
  PhyloPlots contract, with missing lengths handled the same way.
- User story 9: As a user styling a network, I can use `edgecolor`,
  hybrid-edge colors, `edgewidth`, and text-size keywords and get the legacy
  contract rather than a silent reinterpretation.
- User story 10: As a user depending on `tip`-named public options, I can use
  `showtiplabel`, `tipoffset`, and `tipcex` exactly as documented in
  PhyloPlots for this production run.

## Tranche 6: Stabilization, docs, and cross-surface parity sweep

**Type**: AFK
**Blocked by**: Tranche 5

### Parent PRD

`01_prd.md`

### Governance and required reading

- Mandated line-by-line reading of every document listed in `Active
  authorities` above before implementation starts.
- Mandated reading of `STYLE-vocabulary.md` and
  `STYLE-workflow-vocabulary.md`.
- Mandated reading of all upstream sources and earlier tranche notes that define
  the final proof envelope for helper, render, docs, and API artifacts.

### Primary-goal lock

- Lock item 7: close the production-run verification envelope honestly.
- Preserve and harden lock items 1 through 6 across tests, docs, doctests,
  helper regressions, render artifacts, and composition artifacts.
- Non-completion condition: this tranche is not complete if the repository can
  still go green while any primary-goal lock item survives behind a weak proxy.

### What to build

Build the final stabilization tranche that unifies helper-level, render-level,
API-level, and docs-level proof, removes temporary implementation shims, and
turns the accepted scenarios into durable repo-owned verification artifacts.

This tranche is stabilization-focused.

The remaining owner is the final verification and docs envelope for the whole
entry-surface matrix. The retired shapes are temporary shims, one-off artifact
generation paths, doc omissions, and weak proxy tests that do not fail the
historical bad shapes.

The supported public surfaces that move together are `phyloplot`, `phyloplot!`,
and `plot(net)`, plus the helper and render artifacts that prove the shared
owners under them. No supported public surface is intentionally deferred beyond
this tranche.

When this tranche is complete, the repository must no longer be able to claim
success from partial proof, temporary compatibility shapes, or docs that omit
the accepted mutation and composition behavior.

### Legacy artifacts to retire or demote

- Temporary implementation shims that duplicate an already-established owner.
- One-off or manually maintained artifact generation paths that are not part of
  the normal verification surface.
- Weak proxy tests that prove only that something rendered or that the docs
  built.
- Boilerplate docs language that omits real plotting scenarios.

### Forbidden regressions

- Keeping temporary compatibility or helper shims as permanent second
  implementations.
- Letting docs silently change the API surface or omit the `preorder` mutation
  behavior.
- Treating one passing render artifact as sufficient proof for all three public
  entry surfaces.
- Allowing the full suite to go green while one accepted scenario or style
  distinction still fails.

### Environment and dependency baseline

- Preserve the repo-local root, test, and docs project split and path-override
  policy.
- Use the repo-owned docs and test commands as the authoritative build paths.
- Do not require hidden global-environment setup for docs or tests to pass.

### Handoff packet

- **Active authorities**: same active authority set named in this file.
- **Parent documents**: `01_prd.md`; `design/prod01-vision.md`;
  `design/prod01-vision-supplement.md`; this tranche file.
- **Settled decisions and non-negotiables**: all production-run public
  semantics follow `PhyloPlots.plot`; the three entry surfaces stay aligned;
  R interop remains out of scope; foreign domain vocabulary remains forbidden.
- **Authorization boundary**: stabilization and cleanup are allowed; reopening
  already-settled owner or public-surface decisions is not.
- **Current-state diagnosis**: earlier tranches can establish functionality,
  but the final risk is fake-green proof gaps or temporary structures that
  survive into the production owner graph.
- **Primary-goal lock**: close lock item 7 and preserve the rest with final
  cross-surface proof.
- **Direct red-state repros**: current scaffold history shows no plotting proof;
  the final tranche must make that state impossible to regress to without test
  or docs failure.
- **Owner and invariant under repair**: one honest verification envelope for
  all supported surfaces and accepted scenarios.
- **Exact files or surfaces in scope**: final test suite; docs pages and
  examples; artifact generation paths; any temporary compatibility or helper
  shim left by earlier tranches.
- **Exact files or surfaces out of scope**: future performance work; animation;
  backend-specific polish; GraphMakie as a separate goal.
- **Required upstream primary sources**: all sources named in this document,
  plus any tranche-start revalidated Makie primitive files used by the render
  owner.
- **Green-state gates**: package tests; Aqua; JET; docs build; helper
  regressions; render artifacts; docs examples; cross-surface API regressions.
- **Stop conditions**: stop if final verification would rely on a weak proxy
  where a direct artifact is available; stop if cleanup would remove the only
  remaining proof surface for a lock item.

### How to verify

- **Manual**: inspect the final docs and confirm they show the accepted simple
  tree example, reticulate acceptance network, style comparison, label-data
  example, and side-by-side composition example; confirm public docs mention
  the `preorder` mutation behavior explicitly.
- **Automated**: run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl`; require helper regressions, public API
  regressions, render artifacts, style-comparison proof, `showgamma` proof,
  `useedgelength` proof, DataFrame validation proof, and side-by-side
  composition proof to pass together.

Negative verification for the known bad shape:

- Verification must fail if any one of the following can survive behind a green
  suite: missing public surface, keyword drift, geometry drift, style collapse,
  annotation-data drift, composition state bleed, or a docs contract omission.

### Acceptance criteria

- [ ] Given the accepted production scenarios, when the full test and docs
  verification surface runs, then each primary-goal lock item has a direct
  proof artifact and no lock item survives behind a weak proxy.
- [ ] Given the final public API and docs surface, when users read the docs and
  run the examples, then the accepted entry surfaces, style semantics, and
  mutation notes are present and consistent.
- [ ] Given the legacy duplicated-artifact shapes named above, when the tranche
  is complete, then they are removed, demoted, or otherwise prevented from
  surviving as second implementations.
- [ ] Given the forbidden regression shape of fake-green parity, when
  verification is run, then the tranche fails rather than reporting a fake
  green.

### User stories addressed

- User story 1: As a PhyloNetworks user, I can call `phyloplot(net)` on a
  simple tree-like `HybridNetwork` and receive a `Makie.FigureAxisPlot`
  without needing R.
- User story 2: As a Makie user, I can call `plot(net)` and get the PhyloMakie
  recipe automatically.
- User story 3: As a Makie layout user, I can call `phyloplot!(ax, net)` inside
  an existing figure and compose multiple networks without state bleed-through.
- User story 4: As a user inspecting reticulation structure, I can see major
  and minor hybrid edges rendered distinctly and consistently with current
  PhyloPlots semantics.
- User story 5: As a user comparing styles, I can switch between `:fulltree`
  and `:majortree` and get the same semantic distinction I currently get from
  PhyloPlots.
- User story 6: As a user working with branch lengths, I can set
  `useedgelength=true` and have x positions scale according to the current
  PhyloPlots contract, with missing lengths handled the same way.
- User story 7: As a user annotating support values or other metadata, I can
  pass `nodelabel` and `edgelabel` DataFrames and get the same validation and
  midpoint placement behavior I get from PhyloPlots.
- User story 8: As a user inspecting internals, I can enable
  `shownodenumber`, `showedgenumber`, `showedgelength`, and `showgamma` and
  see the correct text at the correct locations.
- User story 9: As a user styling a network, I can use `edgecolor`,
  hybrid-edge colors, `edgewidth`, and text-size keywords and get the legacy
  contract rather than a silent reinterpretation.
- User story 10: As a user depending on `tip`-named public options, I can use
  `showtiplabel`, `tipoffset`, and `tipcex` exactly as documented in
  PhyloPlots for this production run.
- User story 12: As a maintainer, I can verify layout behavior with pure Julia
  helper tests without needing to infer geometry correctness from screenshots
  alone.
- User story 13: As a maintainer, I can verify visual and compositional
  behavior with render artifacts rather than claiming success from a green
  helper suite only.
