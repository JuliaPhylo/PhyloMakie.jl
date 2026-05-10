---
date-created: 2026-05-09T03:07:47
workflow-instrument: PRD
workflow-status: Approved
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
---

# PRD: Makie-native HybridNetwork plotting for PhyloMakie

## User statement

Merged from `design/prod01-vision.md`, `design/prod01-vision-supplement.md`,
and user clarifications on 2026-05-09:

> "A ground-up reimplementation of `PhyloPlots.jl` in a full native Julia
> stack, using Makie for its visualization framework."

> "`PhyloPlots.jl` currently calls base R. This needs to be swapped out for
> Makie. Its sophisticated layout and other business-layer logic adapted to
> plot onto Makie surfaces with Makie abstractions rather than R."

> "Full visualization capacity and layout objectives and correctness of the
> key user surface plotting function in PhyloPlots, `PhyloPlots.plot`, should
> be replicated completely."

> "The function PhyloMakie will provide as the Makie-based counterpart to
> `PhyloPlots.plot(::PhyloNetworks.HybridNetwork; ...)` is `phyloplot`, which
> takes one positional argument of type `PhyloNetworks.HybridNetwork` and
> returns the result as a `Makie.FigureAxisPlot` object."

> "The target function is `PhyloPlots.plot(net::HybridNetwork; ...)`. Its
> complete keyword surface, grouped by role, is the authoritative specification
> for `phyloplot`."

> "The Makie `@recipe` macro uses a PascalCase type name and generates a
> lowercase function automatically. The public-facing names are `phyloplot` /
> `phyloplot!`. The type `PhyloPlot` is an implementation detail."

> "`edgenode_coordinates`, `check_nodedataframe`, `prepare_nodedataframe`, and
> `prepare_edgedataframe` in `PhyloPlots.jl/src/phylonetworksPlots.jl` are
> already pure Julia. They contain the tree layout algorithm and should be
> ported rather than rewritten."

> "It should follow `PhyloPlots.jl` completely for now."

> "R interoperability is out of scope for this production run."

## Problem statement

The user-facing problem is that `PhyloMakie.jl` does not yet provide a
Makie-native replacement for `PhyloPlots.plot(::PhyloNetworks.HybridNetwork;
...)`, despite that plotting surface being the main deliverable for the
package.

The architectural problem is sharper than "implement a plot":

- `PhyloMakie.jl` is currently an empty scaffold with no plotting owner,
  no keyword normalization owner, no layout owner, and no render-level
  verification.
- The legacy behavior is split across a pure Julia layout/data-preparation
  owner in `PhyloPlots.jl/src/phylonetworksPlots.jl` and an R graphics render
  shell in `PhyloPlots.jl/src/plotRCall.jl`.
- Several public semantics appear through more than one supported surface:
  non-mutating `phyloplot`, mutating `phyloplot!`, and `plot(net)` via Makie
  dispatch.
- If those semantics are normalized separately at each surface, the project
  will drift quickly even if one entrypoint appears correct.
- The current verification surface in `PhyloMakie.jl` is too shallow to prove
  visual, compositional, or contract-level correctness.

This work therefore needs an explicit target architecture with deep owners for:

- keyword-surface normalization
- layout and annotation geometry
- Makie recipe and render composition
- multi-surface verification

## Target outcome

When this work is complete, `PhyloMakie.jl` provides a Makie-native plotting
surface for `PhyloNetworks.HybridNetwork` that follows `PhyloPlots.plot`
completely for this production run.

At minimum, the package will provide:

- `phyloplot(net::PhyloNetworks.HybridNetwork; kwargs...)::Makie.FigureAxisPlot`
- `phyloplot!(ax, net::PhyloNetworks.HybridNetwork; kwargs...)`
- `Makie.plottype(::PhyloNetworks.HybridNetwork) = PhyloPlot`, so `plot(net)`
  works in Makie style

The new implementation will:

- preserve the legacy keyword surface and its visible behavior
- port the verified pure Julia layout/dataframe helpers rather than inventing a
  new layout contract casually
- translate the resolved layout into Makie primitives and recipe composition
- support composable plotting into existing Makie layouts
- leave behind render-level and helper-level verification that fails the old or
  fake-fix shapes

## Primary-goal lock

### Lock item 1: Entry surfaces and return contract

- The work is not complete if `phyloplot(net)` does not exist, does not accept
  `HybridNetwork`, does not return `Makie.FigureAxisPlot`, or if `plot(net)`
  does not dispatch through Makie for the same input type.
- The direct red-state repro is the current package state:
  `src/PhyloMakie.jl` is empty, no `phyloplot` exists, and no plotting
  dispatch exists.
- The owner expected to close this is the recipe and entry-surface tranche.
- The verification artifact must include direct API tests and docs examples
  proving:
  `fig, ax, plt = phyloplot(net)`,
  `fig, ax, plt = plot(net)`,
  and successful plotting into an existing axis with `phyloplot!`.

### Lock item 2: Public keyword-surface parity

- The work is not complete if any production-run keyword from
  `PhyloPlots.plot(net::HybridNetwork; ...)` is missing, renamed, assigned a
  different default, validated differently, or produces a different visible
  behavior without explicit user reapproval.
- The direct red-state repro is the current package state plus the authoritative
  keyword table in `design/prod01-vision-supplement.md`.
- The owner expected to close this is the keyword-normalization tranche.
- The verification artifact must include direct API tests across representative
  keywords and docs examples that exercise the legacy surface.

### Lock item 3: Layout-owner parity

- The work is not complete if the Makie implementation drifts from the verified
  geometry semantics currently owned by
  `PhyloPlots.jl/src/phylonetworksPlots.jl`, including hybrid-edge coordinate
  handling, style-specific layout differences, and annotation anchor geometry.
- The direct red-state repro is the current absence of any PhyloMakie layout
  owner plus the regression data in
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl`.
- The owner expected to close this is the layout-engine tranche.
- The verification artifact must include helper-level regression tests derived
  from the current `PhyloPlots` coordinate-owner behavior, not only visual
  smoke checks.

### Lock item 4: Style distinction and hybrid-edge rendering

- The work is not complete if `:fulltree` and `:majortree` cease to be
  visually distinct, if minor hybrid edges lose their style-specific rendering
  rules, or if arrow behavior drifts from the current contract.
- The direct red-state repro is the acceptance network
  `"(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"` with
  `style=:fulltree` versus `style=:majortree`.
- The owner expected to close this is the render-adapter tranche.
- The verification artifact must include render-level examples or regression
  images that fail if the two styles collapse into one visual outcome.

### Lock item 5: Annotation and DataFrame validation parity

- The work is not complete if node labels, edge labels, gamma text, edge
  lengths, edge numbers, node numbers, or DataFrame validation warnings drift
  from the PhyloPlots contract.
- The direct red-state repro is the validation and midpoint-placement behavior
  covered by `PhyloPlots.jl/test/test_phylonetworkPlots.jl`.
- The owner expected to close this is the annotation-owner tranche.
- The verification artifact must include validation tests for missing first
  column values, unmatched node and edge numbers, warning behavior, and render
  or coordinate checks for midpoint placement.

### Lock item 6: Composable Makie plotting

- The work is not complete if
  `phyloplot!(Axis(fig[1, 1]), net1)` and
  `phyloplot!(Axis(fig[1, 2]), net2)` cannot coexist cleanly in one figure or
  if coordinate state bleeds across panels.
- The direct red-state repro is the current absence of any Makie implementation
  and the accepted composable example in `design/prod01-vision.md`.
- The owner expected to close this is the recipe and render-composition
  tranche.
- The verification artifact must include a docs or test render that places two
  networks side by side in one figure.

### Lock item 7: Honest verification surface

- The work is not complete if the repository can go green while one of the
  above visual or API contract failures still survives.
- The direct red-state repro is the current verification surface:
  Aqua, JET, docs boilerplate, and no plotting-specific contract tests.
- The owner expected to close this is the foundational verification tranche.
- The verification artifact must include helper tests, API tests, docs build,
  doctests where applicable, and render-level artifacts for the accepted
  plotting scenarios.

## User stories

1. As a PhyloNetworks user, I can call `phyloplot(net)` on a simple tree-like
   `HybridNetwork` and receive a `Makie.FigureAxisPlot` without needing R.
2. As a Makie user, I can call `plot(net)` and get the PhyloMakie recipe
   automatically.
3. As a Makie layout user, I can call `phyloplot!(ax, net)` inside an existing
   figure and compose multiple networks without state bleed-through.
4. As a user inspecting reticulation structure, I can see major and minor
   hybrid edges rendered distinctly and consistently with current PhyloPlots
   semantics.
5. As a user comparing styles, I can switch between `:fulltree` and
   `:majortree` and get the same semantic distinction I currently get from
   PhyloPlots.
6. As a user working with branch lengths, I can set `useedgelength=true` and
   have x positions scale according to the current PhyloPlots contract, with
   missing lengths handled the same way.
7. As a user annotating support values or other metadata, I can pass
   `nodelabel` and `edgelabel` DataFrames and get the same validation and
   midpoint placement behavior I get from PhyloPlots.
8. As a user inspecting internals, I can enable `shownodenumber`,
   `showedgenumber`, `showedgelength`, and `showgamma` and see the correct text
   at the correct locations.
9. As a user styling a network, I can use `edgecolor`, hybrid-edge colors,
   `edgewidth`, and text-size keywords and get the legacy contract rather than
   a silent reinterpretation.
10. As a user depending on `tip`-named public options, I can use
    `showtiplabel`, `tipoffset`, and `tipcex` exactly as documented in
    PhyloPlots for this production run.
11. As a maintainer, I can locate one owner for keyword normalization instead
    of rediscovering precedence and default rules in every entry surface.
12. As a maintainer, I can verify layout behavior with pure Julia helper tests
    without needing to infer geometry correctness from screenshots alone.
13. As a maintainer, I can verify visual and compositional behavior with render
    artifacts rather than claiming success from a green helper suite only.
14. As a future contributor, I can discuss animation, backend-specific polish,
    performance, or broader graph support later without those topics quietly
    driving this production run's acceptance boundary.

## Authorized disruption boundary

- Internal redesign allowed: yes. `PhyloMakie.jl` is an early-stage rebuild and
  may choose the better internal design rather than preserving accidental
  scaffold structure.
- Internal redesign forbidden: no tranche may duplicate shared keyword,
  layout, or render contracts across sibling layers instead of establishing a
  clear owner.
- External breaking changes allowed: the package is allowed to deliver the new
  public surfaces `phyloplot`, `phyloplot!`, and Makie `plot(net)` dispatch
  rather than preserving the old module/function import path from
  `PhyloPlots.jl`.
- Required migration or compatibility obligations: for this production run, the
  public plotting behavior within the accepted `phyloplot` surface must follow
  `PhyloPlots.plot` completely. No compatibility aliases are required, but no
  intentional keyword or behavior drift is authorized either.
- Non-negotiable protections: the work must preserve the accepted plotting
  semantics, must remain green at tranche boundaries, must keep R interop out
  of scope, and must not let future-topic discussion silently become a hidden
  acceptance criterion.

## Current-state architecture

- Existing owners:
  - `PhyloMakie.jl/src/PhyloMakie.jl` is an empty module shell.
  - `PhyloPlots.jl/src/phylonetworksPlots.jl` owns the pure Julia layout and
    annotation-data helpers.
  - `PhyloPlots.jl/src/plotRCall.jl` owns legacy public keyword handling and R
    graphics rendering.
  - `PhyloNetworks.jl/src/manipulateNet.jl` owns `directedges!` and
    `preorder!`, which legacy plotting relies on.
- Existing failure modes:
  - No Makie plotting implementation exists in PhyloMakie.
  - No public plotting API exists.
  - No plot-specific tests or docs examples exist.
  - No render-level verification exists.
- Existing coupling, duplication, or design debt:
  - Legacy public semantics are coupled to an R render shell.
  - Current PhyloMakie scaffold has no owner boundaries at all yet.
  - The current workflow vocabulary file contains foreign domain tables from
    another project, so PhyloMakie needs its own domain vocabulary authority.

## Target architecture

- Major modules and responsibilities:
  - A module shell that only declares the package module, imports needed
    dependencies, and includes implementation files.
  - A keyword-normalization owner that resolves the public keyword surface once
    for all supported entry surfaces.
  - A layout engine that ports the verified pure Julia coordinate and
    annotation-anchor logic from `PhyloPlots`.
  - A render adapter that maps resolved layout outputs to Makie primitives and
    text.
  - A recipe and entry-surface owner that exposes `phyloplot`, `phyloplot!`,
    and Makie `plot(net)` dispatch.
  - A verification owner covering helper tests, API tests, docs examples, and
    render artifacts.
- Ownership boundaries:
  - Keyword normalization owns public defaults, validation, and resolved
    surface semantics.
  - Layout owns geometry and annotation anchor calculation.
  - Render owns Makie primitive composition.
  - Recipe/entry surfaces own surface exposure and return-shape semantics.
- Shared contracts and invariants:
  - One public keyword surface, one normalization owner.
  - One geometry contract, one layout owner.
  - One render composition policy, one render owner.
  - One entry-surface matrix, verified across all supported surfaces.
- Canonical owners for shared public semantics and the supported surface matrix
  for each such semantic:
  - Public plotting keyword semantics:
    owner = keyword normalization
    supported surfaces = `phyloplot`, `phyloplot!`, `plot(net)`
  - Geometry semantics for nodes, edges, and minor hybrid edges:
    owner = layout engine
    supported surfaces = all three plotting surfaces
  - Return-shape and axis ownership semantics:
    owner = recipe and entry surfaces
    supported surfaces = `phyloplot` and `phyloplot!`
  - Text and line render semantics:
    owner = render adapter
    supported surfaces = all rendered entry surfaces
- Target deep modules and simplified interfaces:
  - A deep layout module that exposes a small, testable interface for resolved
    coordinates and annotation data rather than leaking raw traversal policy
    through several layers.
  - A deep keyword-resolution module that turns public kwargs into one resolved
    internal plot-spec object.
  - A deep render module that accepts the resolved plot-spec plus layout output
    and emits Makie composition once.

## Implementation decisions

- Follow `PhyloPlots.plot` completely for the public plotting contract in this
  production run.
- Keep `phyloplot` and `phyloplot!` as the canonical PhyloMakie public names.
- Support Makie `plot(net)` dispatch for `HybridNetwork` through
  `Makie.plottype(::HybridNetwork) = PhyloPlot`.
- Port the existing pure Julia layout/dataframe helpers from
  `PhyloPlots.jl/src/phylonetworksPlots.jl` rather than redesigning the layout
  owner prematurely.
- Treat `PhyloPlots.jl/src/plotRCall.jl` as the behavioral authority for the
  public keyword surface, validation rules, and visible semantics, not as an
  implementation model to copy literally.
- Leave the internal owner decision around network preprocessing and input
  mutation intentionally unlocked for now. Downstream work may preserve,
  isolate, or remove the current `preorder=true` mutation behavior if the user
  visible plotting contract stays correct and the owner decision is made
  explicit.
- Omit R documentation as an upstream-reading mandate for now.
- Treat `STYLE-workflow-vocabulary.md` as authoritative for workflow-process
  terms only. Use the new `STYLE-vocabulary.md` as the domain vocabulary
  authority for this project.

## Module design

### Name

`PhyloMakie`

### Public surfaces

Module import surface and exported plotting functions.

### Responsibility

Declare the package module, import dependencies, export public names, and
include implementation files only.

### Interface

Minimal top-level shell. No substantial implementation logic should live here.

### Tested

Yes. Aqua, JET, module-load tests, and exported-surface smoke tests.

### Name

Phyloplot keyword normalization

### Public surfaces

All supported plotting entry surfaces that accept the public keyword contract.

### Responsibility

Resolve the complete `PhyloPlots.plot` keyword surface once into a single
internal plot-spec object with validated defaults and warnings.

### Interface

Internal-only normalization interface consumed by recipe and render owners.

### Tested

Yes. Direct API and normalization tests must fail drift in defaults,
validation, and warnings.

### Name

Phyloplot layout engine

### Public surfaces

Indirectly influences all plotting entry surfaces and docs examples.

### Responsibility

Compute node, edge, and minor-hybrid-edge geometry plus annotation anchor data
independently of Makie rendering.

### Interface

Internal-only layout result object or equivalent structured return consumed by
the render adapter.

### Tested

Yes. Helper-level regression tests derived from the current `PhyloPlots`
coordinate-owner behavior.

### Name

Phyloplot render adapter

### Public surfaces

All rendered plotting outputs for `phyloplot`, `phyloplot!`, and `plot(net)`.

### Responsibility

Translate the resolved keyword spec and layout-engine output into Makie
primitives, text, and composition rules.

### Interface

Internal-only render API consumed by the recipe owner.

### Tested

Yes. Render-level artifacts, example renders, and composition tests.

### Name

PhyloPlot recipe and entry surfaces

### Public surfaces

`phyloplot`, `phyloplot!`, `Makie.plot(::HybridNetwork)` via plottype dispatch.

### Responsibility

Expose the Makie recipe type, enforce mutating versus non-mutating entrypoint
semantics, create or reuse axis owners appropriately, and preserve the return
contract.

### Interface

`@recipe(PhyloPlot, net)`, `Makie.plot!`, `Makie.plottype(::HybridNetwork)`,
and exported wrappers.

### Tested

Yes. API, return-shape, and multi-surface composition tests.

## Governance and controlled vocabulary

- Governance documents that must be read line by line downstream:
  - `CONTRIBUTING.md`
  - `STYLE-architecture.md`
  - `STYLE-docs.md`
  - `STYLE-git.md`
  - `STYLE-julia.md`
  - `STYLE-makie.md`
  - `STYLE-upstream-contracts.md`
  - `STYLE-verification.md`
  - `STYLE-workflow-docs.md`
  - `STYLE-workflow-vocabulary.md`
  - `STYLE-agent-handoffs.md`
  - `STYLE-writing.md`
  - `STYLE-vocabulary.md`
- Vocabulary decisions or required updates:
  - `STYLE-vocabulary.md` is now the PhyloMakie domain vocabulary authority.
  - Public plotting keywords follow the current `PhyloPlots` names in this
    production run, including `tip`-named options.
  - `PhyloPlot` is the recipe type; `phyloplot` and `phyloplot!` are the
    public user-facing names.
  - `HybridNetwork` is the canonical input type for the current production run.
- Terms that must be avoided:
  - foreign domain terms imported from another project's workflow-vocabulary
    tables, including lineage-specific recipe names and `lineageunits`, unless
    explicitly reopened later
  - casual renaming of public `PhyloPlots` keyword terms in this production run

## Primary upstream references

- `PhyloPlots.jl/src/phylonetworksPlots.jl`
- `PhyloPlots.jl/src/plotRCall.jl`
- `PhyloPlots.jl/test/test_phylonetworkPlots.jl`
- `PhyloNetworks.jl/src/types.jl`
- `PhyloNetworks.jl/src/manipulateNet.jl`
- `PhyloNetworks.jl/docs/src/man/net_plot.md`
- Local Makie-family sources read for recipe and return-contract behavior:
  - `~/.julia/packages/Makie/FUAHr/MakieCore/src/recipes.jl`
  - `~/.julia/packages/Makie/TOy8O/src/figureplotting.jl`

Inference boundary note:
the exact active Makie checkout hash used by the future implementation could
not be confirmed from a running Julia session in this environment because the
Julia launcher could not acquire its lockfile. Downstream implementation must
revalidate the exact resolved Makie dependency tree before relying on a
checkout-specific source path.

## Tranche gates

- Required green checks at tranche start and end:
  - package tests green
  - Aqua green
  - JET green
  - docs build green
  - no unauthorized regressions in public plotting behavior already completed
    by earlier tranches
- Required docs, example builds, or integration outputs:
  - docs examples for the accepted plotting scenarios
  - side-by-side composition example
  - at least one hybrid-network render artifact exercising `showgamma`
  - at least one style-comparison artifact for `:fulltree` versus `:majortree`
- Migration and compatibility verification obligations:
  - verify the public `phyloplot` keyword surface against the accepted
    `PhyloPlots.plot` contract
  - verify all supported entry surfaces, not just one

## Handoff packet

- Active authorities:
  - `CONTRIBUTING.md`
  - all applicable `STYLE*.md` files in the package root
  - `STYLE-vocabulary.md`
  - this PRD
- Parent documents:
  - `design/prod01-vision.md`
  - `design/prod01-vision-supplement.md`
- Settled decisions and non-negotiables:
  - follow `PhyloPlots.plot` public behavior completely for this production run
  - expose `phyloplot`, `phyloplot!`, and Makie `plot(net)` dispatch
  - keep R interop out of scope
  - port the existing pure Julia layout helpers rather than casually
    redesigning the layout contract
  - do not use foreign domain vocabulary tables from another project
- Authorization boundary:
  - deep internal redesign is allowed
  - public plotting behavior drift is not allowed in this production run
  - compatibility aliases to old package names are not required
- Current-state diagnosis:
  - PhyloMakie is an empty scaffold
  - legacy behavior splits between pure Julia layout helpers and an R render
    shell
  - no plot-specific verification exists yet
- Primary-goal lock:
  - entry surfaces and return contract
  - public keyword-surface parity
  - layout-owner parity
  - style distinction and hybrid-edge rendering
  - annotation and DataFrame validation parity
  - composable Makie plotting
  - honest verification surface
- Direct red-state repros:
  - current `PhyloMakie.jl` has no `phyloplot`, no recipe, no dispatch
  - `PhyloPlots.jl/test/test_phylonetworkPlots.jl` contains current helper
    regression data that a real port must satisfy
- Owner and invariant under repair:
  - keyword normalization owner for the public surface
  - layout engine owner for geometry and annotation anchors
  - render adapter owner for Makie composition
  - recipe owner for mutating versus non-mutating entry surfaces
- Exact files or surfaces in scope:
  - `src/PhyloMakie.jl`
  - new included source files under `src/`
  - `test/runtests.jl` and new plotting-specific test files
  - `docs/src/` and `docs/make.jl`
  - dependency manifests in package, test, and docs projects if required by the
    accepted implementation
  - `STYLE-vocabulary.md`
- Exact files or surfaces out of scope:
  - `sexp` and `rexport`
  - R interoperability
  - non-`HybridNetwork` public input types
  - performance work, animation, interactive editing, backend-specific polish,
    and GraphMakie adoption as production-run lock items
- Required upstream primary sources:
  - the exact files listed in the upstream references section above
  - revalidated Makie primitive sources if the implementation depends on more
    detailed lines, arrows, or text contracts
- Green-state gates:
  - Aqua
  - JET
  - package tests
  - docs build
  - docs examples and render artifacts required by the tranche
- Stop conditions:
  - stop if an implementing tranche cannot preserve the accepted PhyloPlots
    public behavior and needs explicit reauthorization
  - stop if the exact active Makie contract differs materially from the local
    source files recorded here
  - stop if the implementer is about to introduce foreign-project domain
    vocabulary into public names or docs
- Regression expectations:
  - every behavioral fix or feature slice must leave behind stronger helper,
    API, or render-level verification than the current scaffold provides

## Testing and verification decisions

- What must stay green throughout:
  - package tests
  - Aqua
  - JET
  - docs build
- What examples or integration artifacts must be checked:
  - simple tree render with no hybrid drawing path
  - one-reticulation acceptance network with visible major and minor hybrid
    edges
  - style comparison for `:fulltree` versus `:majortree`
  - `useedgelength=true` case with missing lengths handled as in PhyloPlots
  - node and edge label DataFrame example
  - side-by-side composition example using two axes in one figure
- What migration verification is required if breakage is allowed:
  - no old-package alias surface is required
  - new-package public plotting behavior must still be checked directly against
    the accepted `PhyloPlots.plot` contract

## Out of scope

- `sexp`
- `rexport`
- all R interoperability behavior
- non-`HybridNetwork` public input types for this production run
- animation, interactive editing, and backend-specific polish as lock items
- performance optimization as a lock item
- GraphMakie adoption as a goal in itself

These topics may still be discussed later when they materially affect
architecture or future work, but they do not define completion for this
production run.

## Open questions

1. Should a later tranche replace or isolate the current legacy input-mutation
   behavior behind a non-mutating normalization owner?
   Owner: project owner.
   Suggested resolution path: defer until after functionality parity is
   established, then reopen only if mutation materially complicates testing,
   composition, or public API clarity.

2. Which exact Makie primitive-source files should become mandatory upstream
   reading once implementation settles on concrete lines, arrows, and text
   primitives?
   Owner: implementing tranche author with project-owner review.
   Suggested resolution path: revalidate against the actual resolved Makie
   dependency tree at tranche start and record the exact files in the tranche
   document before code changes begin.

## Further notes

- `PhyloMakie.jl` currently has CI coverage for Julia 1.11 and 1.12 plus docs
  deployment. Those existing gates remain part of tranche green-state
  discipline.
- The legacy `PhyloPlots` tests provide a strong seed corpus for helper-level
  layout verification and should be treated as high-value upstream regression
  artifacts.
- The new domain vocabulary file is part of the architecture fix, not a side
  note. It prevents further planning drift from foreign project terminology.
