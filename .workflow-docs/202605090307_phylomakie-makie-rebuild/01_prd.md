---
date-created: 2026-05-09T03:07:47
date-updated: 2026-05-10T13:30:18
workflow-instrument: PRD
workflow-status: Approved
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
---

# PRD: Makie-native HybridNetwork plotting for PhyloMakie

## User statement

Merged from the revised `design/prod01-vision.md`,
`design/prod01-vision-supplement.md`, and user clarifications on 2026-05-10:

> "I am porting the package. Not hacking in an outside shell and then
> rewriting it on the inside."

> "I authorized a new API to support this ground up rewrite if it was more
> idiomatic or makes more sense."

> "I do not want the user to pretend they are using the same package."

> "I want the user to feel they are using a package that has the same
> functionality but written from the ground up for Makie."

> "The package must preserve the plotting capabilities that make
> `PhyloPlots.plot` useful, but the primary user experience must feel native
> to Makie."

## Problem statement

PhyloMakie no longer has an empty scaffold. Tranches 1 through 4 established
useful internal owners:

- a repo-owned Makie dependency baseline
- plot-sensitive verification scaffolding
- a layout and annotation data owner
- a render owner with direct CairoMakie proof

That work is valuable. The problem is that the planning chain centered the
wrong product goal.

The current architecture and workflow documents still treat the legacy
`PhyloPlots.plot` keyword shell as the canonical public contract. That
compatibility-first framing made `keyword_normalization.jl` and
`keyword_contract.jl` the intended center of gravity for future public API
work. If the package continues on that path, it will produce a Makie backend
with a legacy outer shell instead of a Makie-native plotting package.

The real problem now is architectural:

- the package has reusable internal geometry and render owners, but no
  Makie-native public plot owner
- the current workflow chain treats legacy keyword parity as the primary
  public semantic instead of capability parity
- the current public roadmap would naturally wrap the wrong owner rather than
  design a Makie-native plot surface
- the docs and verification metadata still teach the wrong user mental model

This PRD therefore resets the target architecture without reopening the value
of completed internal work. Tranches 1 through 4 become current-state assets.
The remaining work must build the correct Makie-native public product on top
of them, and retire or demote the compatibility-first structures that no
longer fit the authorized direction.

## Target outcome

When this work is complete, PhyloMakie feels like a Makie package for
phylogenetic trees and networks.

The public product must provide:

- a real Makie plot type or recipe for `PhyloNetworks.HybridNetwork`
- Makie-native plotting into new and existing figures and axes
- the same plotting capability envelope that made `PhyloPlots.plot` useful
- package-owned documentation that teaches the Makie-native surface first
- zero R dependency in the plotting path

The public product is explicitly allowed to:

- rename legacy keywords
- regroup options into more idiomatic Makie or Julia attribute structures
- change defaults that existed only to mirror R graphics conventions
- change wrapper structure if that produces a cleaner Makie-native contract

The public product is not allowed to:

- lose accepted plotting capabilities
- require the user to think in terms of the old package's keyword shell
- make a compatibility adapter the semantic owner of the package
- fake Makie integration through wrappers that own behavior independently from
  the recipe

The likely public surface matrix is:

- Makie `plot(net; attrs...)`
- Makie plotting into an existing axis through mutating semantics
- optional package-specific convenience surfaces such as `phyloplot` and
  `phyloplot!`, but only as thin wrappers over the same public owner

## Primary-goal lock

### Lock item 1: Makie-native public plotting owner

- The work is not complete if `HybridNetwork` still lacks a real Makie public
  plot owner, or if package-specific wrappers own semantics independently from
  the recipe.
- The direct red-state repro is the current package state:
  `verification_foundation.jl` still marks `phyloplot`, `phyloplot!`, and
  `plot(net)` as absent, and no public plot type exists.
- The owner expected to close this is the public plot-owner tranche.
- The verification artifact must include direct public API tests and docs
  examples that prove Makie-native plotting works in new and existing axes.

### Lock item 2: Capability parity without API mimicry

- The work is not complete if users cannot accomplish the accepted
  `PhyloPlots.plot` visualization tasks, or if the package still teaches the
  legacy keyword shell as the authoritative interface.
- The direct red-state repro is the earlier brief and PRD chain, which defined
  the full legacy keyword surface as the authoritative product spec.
- The owners expected to close this are the public API reset tranche and the
  docs and migration tranche.
- The verification artifact must include scenario-level proof for the accepted
  plotting capabilities plus docs that teach the Makie-native surface first.

### Lock item 3: Compatibility-first owner retirement

- The work is not complete if `keyword_normalization.jl` or
  `keyword_contract.jl` remains the canonical public semantic owner for
  plotting.
- The direct red-state repro is the current code path:
  `normalize_plot_keywords` produces `PlotKeywordSpec`, and layout and render
  code consume that compatibility-first owner directly.
- The owners expected to close this are the public API reset tranche and the
  compatibility-retirement tranche.
- The verification artifact must fail if public plotting still depends on the
  compatibility-first owner as more than an explicit, secondary bridge.

### Lock item 4: Proven layout and annotation invariants survive

- The work is not complete if the remaining refactor discards, duplicates, or
  quietly changes the layout and annotation invariants already closed in
  Tranches 3 and 4.
- The direct red-state repro is the current helper and render regression
  inventory in `layout_engine.jl`, `annotation_data.jl`, and
  `render_adapter.jl`.
- Every remaining tranche preserves or consumes this lock item.
- The verification artifact must keep the helper and render regression suites
  green while the public API and ownership model are rewritten.

### Lock item 5: Makie composability and host-framework semantics

- The work is not complete if the final public surface blurs mutating versus
  non-mutating semantics, reintroduces hidden current-axis state, or fails
  multi-axis composition.
- The direct red-state repro is the current absence of any public Makie entry
  surface and the historical deferral of composable proof.
- The owners expected to close this are the public plot-owner tranche and the
  final capability-closure tranche.
- The verification artifact must include direct public composition tests and
  docs examples with more than one axis.

### Lock item 6: Honest docs and migration surface

- The work is not complete if docs still present PhyloMakie as "the same
  package with Makie underneath" or if users cannot map legacy PhyloPlots
  tasks to the new surface honestly.
- The direct red-state repro is the current workflow chain and design prose
  that treat exact legacy keyword parity as the product goal.
- The owner expected to close this is the docs and migration tranche.
- The verification artifact must include updated docs, migration material, and
  examples that teach the Makie-native package first.

### Lock item 7: Honest verification surface

- The work is not complete if the repository can go green while any of the
  above public-surface or migration failures survive.
- The direct red-state repro is the current verification metadata, which still
  inventories the wrong target architecture even though the internal baseline
  has advanced.
- The owners expected to close this are the compatibility-retirement tranche
  and the docs and migration tranche.
- The verification artifact must include source-backed metadata, public API
  tests, helper and render regressions, and docs examples that fail the wrong
  architecture instead of only the absence of code.

## User stories

1. As a Makie user, I can call `plot(net)` on a
   `PhyloNetworks.HybridNetwork` and get a real Makie plotting experience.
2. As a Makie layout user, I can plot into an existing axis and compose
   multiple networks in one figure without state bleed-through.
3. As a PhyloPlots user migrating to PhyloMakie, I can achieve the same
   visualization tasks through a clearly documented Makie-native interface.
4. As a network analyst, I can switch between full-tree and major-tree styles
   and preserve their distinct visual meanings.
5. As a user working with edge lengths, hybrid edges, and gamma values, I can
   reproduce the accepted visual behaviors without relying on R.
6. As a user annotating nodes and edges, I can attach labels and metadata at
   the correct anchors with clear control over styling.
7. As a user styling a plot, I can control text, colors, widths, and
   linestyles through the new surface without learning a legacy compatibility
   shim first.
8. As a maintainer, I can locate one public semantic owner in the Makie plot
   layer and one internal geometry owner in the layout layer.
9. As a maintainer, I can reuse the proven layout and render foundations while
   retiring the compatibility-first structures that no longer fit.
10. As a future contributor, I can extend a Makie-native codebase rather than
    inheriting a backend swap architecture.

## Authorized disruption boundary

- Internal redesign allowed: yes. The user has explicitly reopened the public
  API and architectural center of gravity for a Makie-native design.
- Internal redesign forbidden: no remaining tranche may preserve the wrong
  public owner merely because it already exists. Reuse completed work where it
  helps. Retire or demote it where it hurts.
- External API changes allowed: yes. Legacy keyword names, defaults, warning
  text, and wrapper structure may change.
- Required migration obligations:
  - teach the Makie-native API first in docs and examples
  - provide capability mapping from PhyloPlots tasks to PhyloMakie tasks
  - make any compatibility adapter explicit and secondary if it survives at
    all
- Non-negotiable protections:
  - preserve the accepted plotting capability envelope
  - preserve Makie host-framework semantics
  - keep R interop out of scope
  - keep tranche begin-green and end-green discipline

## Current-state architecture

- Existing reusable owners:
  - `layout_engine.jl` owns the current pure Julia geometry contract
  - `annotation_data.jl` owns the current annotation-table and bounds contract
  - `render_adapter.jl` owns the current primitive composition and render-proof
    surface
  - the Makie dependency baseline and render regression corpus already exist
- Existing misowned public semantics:
  - `keyword_normalization.jl` owns a legacy-keyword-first `PlotKeywordSpec`
  - `keyword_contract.jl` records legacy compatibility as the product center
  - `verification_foundation.jl` still describes public surfaces as absent and
    future rather than reframing the remaining work around a Makie-native API
- Existing missing product surfaces:
  - no recipe type
  - no Makie `plot(net)` support
  - no public plotting into an existing axis
  - no docs that teach a Makie-native public API

## Target architecture

- Public plot owner:
  - a real Makie plot type or recipe for `HybridNetwork`
  - public semantics owned here, not in a legacy-keyword adapter
- Public attribute owner:
  - a Makie-native attribute model or equivalent structured public surface
  - legacy capability reference informs this owner, but does not define its
    names or wrapper shape
- Internal geometry owner:
  - the existing `PlotLayout`-style geometry and annotation owner remains a
    strong candidate for reuse
  - public layers consume it; they do not recompute geometry independently
- Internal render owner:
  - `render_plot!` or its successor remains a low-level primitive composition
    owner
  - public layers consume it; they do not fork rendering semantics per entry
    surface
- Compatibility owner:
  - optional only
  - explicit, thin, and secondary
  - never the canonical public semantic owner
- Verification owner:
  - source-backed metadata, public API tests, helper regressions, render
    regressions, and docs examples all align with the Makie-native target

### Canonical owner matrix

- Public plotting semantics:
  owner = Makie plot type or recipe
  supported surfaces = `plot(net)`, plotting into an existing axis, optional
  package convenience wrappers
- Legacy capability mapping:
  owner = docs and optional explicit compatibility layer
  supported surfaces = migration material and any opt-in compatibility support
- Geometry and annotation anchors:
  owner = layout and annotation modules
  supported surfaces = every plotting entry surface
- Primitive composition and style-specific rendering:
  owner = render adapter
  supported surfaces = every plotting entry surface

## Migration envelope

Keep and reuse:

- `layout_engine.jl`
- `annotation_data.jl`
- `render_adapter.jl`
- `test/support/fixture_corpus.jl`
- `test/support/render_test_helpers.jl`
- the Makie source-set note from tranche 4, subject to normal revalidation

Rewrite, demote, or retire:

- `keyword_normalization.jl`
- `keyword_contract.jl`
- any tests that treat legacy keyword shape as the main product goal
- `verification_foundation.jl`
- docs that describe PhyloMakie as direct API mimicry
- the tranche plan and tasking assumptions downstream of the old compatibility
  framing

Likely new target-state owners:

- a recipe or plot-type source file
- a public API wrapper file if package convenience functions survive
- a Makie-native attribute or plot-model owner
- migration docs that map old tasks to new public usage

## Upstream primary sources

- `design/prod01-vision.md`
- `design/prod01-vision-supplement.md`
- `PhyloPlots.jl/src/phylonetworksPlots.jl`
- `PhyloPlots.jl/test/test_phylonetworkPlots.jl`
- `PhyloPlots.jl/src/plotRCall.jl` as a legacy capability reference, not as
  the final public API authority
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`
- the resolved Makie-family source files named in that source-set note

## Green-state gates

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- plot-sensitive public API tests
- helper-level layout and annotation regressions
- CairoMakie-backed render regressions
- source-backed verification metadata aligned with the revised target

## Out of scope

- R interoperability
- preserving the exact PhyloPlots keyword shell as the primary API
- non-`HybridNetwork` public input types
- generalized graph plotting beyond the current phylogenetic scope
- performance tuning as a gating objective for this production run
- animation or backend-specific polish as a gating objective for this
  production run

## Handoff packet

- **Active authorities**:
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
- **Parent documents**:
  - `design/prod01-vision.md`
  - `design/prod01-vision-supplement.md`
- **Settled decisions and non-negotiables**:
  - same capability envelope, Makie-native API
  - real Makie public plot owner
  - optional wrappers stay thin
  - compatibility-first keyword ownership is not the target architecture
  - Tranches 1 through 4 remain completed baseline rather than reopened
    failures
- **Authorization boundary**:
  - deep internal redesign and public API redesign are authorized
  - capability loss and fake Makie wrappers are not
- **Current-state diagnosis**:
  - completed internal layout and render owners exist
  - the workflow chain still centers the wrong public owner
  - no public Makie plot surface exists yet
- **Primary-goal lock**:
  - lock items 1 through 7 above
- **Direct red-state repros**:
  - no public plot owner
  - compatibility-first `PlotKeywordSpec` path is still central
  - docs and workflow chain still teach the wrong product
- **Owner and invariant under repair**:
  - repair the public semantic owner while preserving the internal geometry and
    render invariants already closed
- **Exact files or surfaces in scope**:
  - public plot owner
  - public attribute model
  - wrappers if retained
  - compatibility owner demotion or retirement
  - docs, tests, and verification metadata
- **Exact files or surfaces out of scope**:
  - R interop
  - non-`HybridNetwork` plotting
  - performance and animation as gating objectives
- **Required upstream primary sources**:
  - the sources named above, plus any additional Makie recipe or plotting files
    required by the final public owner
- **Green-state gates**:
  - the gates listed above
- **Stop conditions**:
  - stop if a tranche can only progress by keeping the compatibility-first
    owner as the package center
  - stop if public API redesign would require duplicating layout or render
    invariants in wrapper layers
  - stop if a required Makie host-framework contract remains unverified from
    source
