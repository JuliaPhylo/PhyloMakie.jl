---
date-created: 2026-05-10T02:11:11-07:00
workflow-instrument: Tasking Plan
workflow-status: Proposed
workflow-agent-thread-id: codex/019e111c-1e5e-70e2-9d5c-b6dea7b0ac91
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-prd: .workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md
workflow-tranche: .workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md
---

# Tasks for tranche 4: Makie render adapter and style parity closure

## Approval state

- This file is proposed planning output derived from proposed tranche 4 in
  `02_tranches.md`.
- Downstream `Tasks -> Execute` work remains blocked until the project owner
  sets `workflow-status: Approved` in this file's frontmatter.

## Settled user decisions and environment baseline

- The production-run public behavior target remains
  `PhyloPlots.plot(net::HybridNetwork; ...)`.
- The canonical target public surface names remain `phyloplot`,
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
- Use documented public `Pkg.add`, `Pkg.develop`, `Pkg.rm`, and related Pkg
  operations to curate root, `test/`, and `docs/` environments. Do not hand-
  edit manifests as a first resort.
- The tranche-3 helper owners are already live and green on 2026-05-10:
  `julia --project=test test/runtests.jl` passes with 345 tests, and
  `julia --project=docs docs/make.jl` passes.
- The canonical helper payload is already `PlotLayout`, with geometry and
  annotation preparation owned by `src/layout_engine.jl` and
  `src/annotation_data.jl`.
- Direct public proof for `phyloplot`, `phyloplot!`, `Makie.plottype`, and
  `plot(net)` remains intentionally deferred to tranche 5.
- Direct public `xlim` and `ylim` error-path proof remains intentionally
  deferred to tranche 5 even though tranche 4 must consume the resolved bounds
  and explicit-limit data already owned by tranche 3.
- Direct public proof for the accepted `composable_dual_axes` scenario remains
  tranche-5-owned. Tranche 4 must avoid stateful render designs that would
  block later composability, but it must not quietly claim that proof early.

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
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-04_tranche-03--tasking-2.md`

Authority notes that remain active in this tasking file:

- The repo-local `STYLE*.md` set is the operative governance set for this run.
- The bundled baseline STYLE files named by `development-policies` are
  present, but the repo-local copies control this repository.
- No repo-local `STYLE-domain-vocabulary.md` was found.
- No repo-local `STYLE-python.md` was found.
- `STYLE-vocabulary.md` remains the domain vocabulary authority.
- `STYLE-workflow-vocabulary.md` remains authoritative for workflow terms such
  as `tranche`, `lock item`, `primary-goal lock`, `red-state repro`,
  `handoff packet`, and `verification artifact`.

Controlled vocabulary obligations that matter directly in this tranche:

- Use `phyloplot` and `phyloplot!` for the target public surfaces.
- Use `PhyloPlot` only for the future recipe type.
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

The tranche-4 diagnosis remains valid, but the repository state is sharper
than the parent tranche text alone records.

- The tranche-3 helper owners are real, green, and already source-backed.
  `src/layout_engine.jl`, `src/annotation_data.jl`, and `PlotLayout` now exist
  and are protected by direct helper-level regression suites.
- There is still no Makie render owner in `src/`, no `src/render_adapter.jl`,
  no render-focused test suite, and no render-focused docs page.
- `src/verification_foundation.jl`, `test/support/fixture_corpus.jl`, and the
  docs pages already enumerate the accepted render scenarios and still mark
  render proof as tranche-4-owned future work.
- The package, test, and docs project environments do not yet resolve Makie at
  all. On 2026-05-10:
  `julia --project=. -e 'using Makie'` failed,
  `julia --project=test -e 'using Makie'` failed, and the direct dependency
  lists in `Project.toml`, `test/Project.toml`, and `docs/Project.toml` do not
  include Makie-family packages.
- The local Julia depot does contain candidate Makie-family source trees,
  including `Makie 0.24.7` at
  `/home/jeetsukumaran/.julia/packages/Makie/TOy8O` and `CairoMakie 0.15.10`
  at `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v`, but those are
  not yet the repository's own resolved contract. Tasking must treat them as
  tranche-start review candidates, not as silently frozen truth.
- The current shell-owner test in `test/test_PhyloMakie.jl` still asserts an
  exact five-file include shell and the continued absence of `phyloplot`,
  `phyloplot!`, and `PhyloPlot`. Tranche 4 must update the include inventory
  while preserving the deferred public-surface boundary.

## Upstream primary sources and tranche-start source-set gate

The following upstream primary sources constrain this tranche and must be read
line by line before implementation:

- `PhyloPlots.jl/src/plotRCall.jl`
- `PhyloPlots.jl/src/phylonetworksPlots.jl`
- `PhyloPlots.jl/test/test_phylonetworkPlots.jl`
- `PhyloNetworks.jl/src/types.jl`
- `PhyloNetworks.jl/src/manipulateNet.jl`
- `PhyloNetworks.jl/docs/src/man/net_plot.md`
- `/home/jeetsukumaran/.julia/packages/Makie/FUAHr/MakieCore/src/recipes.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/TOy8O/src/figureplotting.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/TOy8O/src/basic_recipes/arrows.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/TOy8O/src/basic_recipes/text.jl`
- `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v/src/CairoMakie.jl`

Verified source conclusions at tasking time:

- `PhyloPlots.jl/src/plotRCall.jl` remains the authoritative visible render
  contract for segment, arrow, text, color, width, and bounds behavior.
- `MakieCore` recipe and `Makie` figure-plotting sources remain the host-
  framework contract for future mutating and non-mutating entry-surface work,
  even though tranche 4 must stop short of exposing those public surfaces.
- The current depot-candidate `Makie 0.24.7` source tree exports
  `linesegments!`, `text!`, `Makie.colorbuffer`, and a deprecated `arrows!`
  shim that routes to the 2D or 3D arrow primitives. That is a verified local
  fact about the candidate depot tree, not yet a verified fact about the
  repository's own future resolved environment.

Local inference boundary that must be reviewed explicitly:

- Because the repo does not yet resolve Makie in its own project environments,
  the exact resolved Makie and CairoMakie versions, plus the exact primitive
  files used by the implementation, remain a tranche-start gate.
- Task 1 must record the resolved source set after dependency activation in a
  repo-owned note.
- Task 2 must obtain explicit project-owner review of that note before task 3
  begins.

## Primary-goal lock

### Lock item 1: Makie-enabled baseline and exact source-set capture

- The work is not complete if the repository still cannot load Makie-family
  dependencies from its own root, `test/`, and `docs/` project environments,
  or if the exact resolved Makie-family source set remains implicit.
- The direct red-state repro is the 2026-05-10 repository state:
  `Project.toml`, `test/Project.toml`, and `docs/Project.toml` do not name
  Makie-family dependencies, `using Makie` fails under the repo-local project
  environments, and no repo-owned source-set review note exists.
- The tasks that close this are task 1 and task 2.
- The verification artifact is a green Makie-enabled environment baseline plus
  a repo-owned source-set note that would be absent in the old repository
  state.

### Lock item 2: Canonical render owner without tranche-5 public-surface drift

- The work is not complete if PhyloMakie still has no local render adapter, or
  if tranche 4 quietly implements `phyloplot`, `phyloplot!`, `PhyloPlot`, or
  `plot(net)` dispatch while claiming to close only the shared render owner.
- The direct red-state repro is the current repository state:
  there is no `src/render_adapter.jl`, no Makie import in the package, no
  render-owner test, and the shell tests still correctly record the public
  entry surfaces as absent.
- The tasks that close this are task 3 and task 4.
- The verification artifact is one internal render owner plus direct owner-
  level tests that fail the current repository state while still asserting that
  the tranche-5 public surfaces remain absent.

### Lock item 3: Style distinction and minor hybrid-edge render parity

- The work is not complete if the full-tree style and major-tree style can
  still collapse into the same rendered result, or if minor hybrid edges lose
  their accepted style-dependent horizontal-versus-direct geometry and arrow
  behavior.
- The direct red-state repro is the accepted network
  `"(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"` in
  `FIXTURE_CORPUS.accepted_design_scenarios.style_distinction_fulltree_vs_majortree`,
  which currently has no Makie render path at all.
- The tasks that close this are task 3 and task 4.
- The verification artifact is a CairoMakie-backed style comparison that fails
  the no-render state and also fails any fake fix where the two style outputs
  are visually identical or the minor-edge arrow path disappears.

### Lock item 4: Edge color, gamma color, and width policy parity

- The work is not complete if `edgecolor` dict fallback, `defaultedgecolor`,
  `majorhybridedgecolor`, `minorhybridedgecolor`, scalar-versus-dict
  `edgewidth`, or gamma text color semantics drift from `PhyloPlots.plot`.
- The direct red-state repro is the current absence of any local render owner
  plus the explicit color and width branches in `PhyloPlots.jl/src/plotRCall.jl`,
  including the rule that gamma text still uses major and minor hybrid colors
  even when edge segments use a dict-driven edge-color map.
- The task that closes this is task 4.
- The verification artifact is direct inspection of resolved plot-layer colors
  and widths plus render-level regression checks that fail if unmapped edges
  miss `defaultedgecolor` or if gamma text inherits dict edge colors.

### Lock item 5: Text and annotation layers must consume PlotLayout without geometry recompute

- The work is not complete if tip labels, internal node names, node numbers,
  edge labels, edge lengths, gamma text, edge numbers, or explicit-limit axis
  application are re-derived through ad hoc render-time geometry instead of
  consuming `PlotLayout`, `PlotBounds`, and the normalized plot spec.
- The direct red-state repro is the current repository state:
  `prepare_plot_layout` already owns midpoint and bounds ingredients, but no
  render owner exists to prove that those owners are actually consumed.
- The tasks that close this are task 3 and task 4.
- The verification artifact is a render-owner suite that compares text anchors
  and limits against `PlotLayout.annotations` and `PlotBounds` and fails any
  render-time midpoint, offset, or bounds anti-fix.

### Lock item 6: Source-backed render proof and honest tranche-5 handoff

- The work is not complete if source-backed verification metadata and docs
  still describe render proof as future work only, or if they falsely claim
  that tranche 5 public entry-surface proof has already been closed.
- The direct red-state repro is the current source-backed truth surface:
  `src/verification_foundation.jl`, `docs/src/index.md`, and
  `docs/src/verification-foundation.md` still mark render proof as deferred to
  tranche 4 and do not yet publish a render-verification page.
- The task that closes this is task 5.
- The verification artifact is updated source-backed metadata, updated docs,
  and a green docs build that fail if render-owner closure or tranche-5
  deferrals drift.

## Handoff packet

- Approval state: proposed only. Do not execute until the project owner sets
  `workflow-status: Approved` in this file.
- Active authorities: `CONTRIBUTING.md`; all repo-local root `STYLE*.md`
  files; `STYLE-vocabulary.md`; `STYLE-workflow-vocabulary.md`;
  `design/prod01-vision.md`; `design/prod01-vision-supplement.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-04_tranche-03--tasking-2.md`.
- Parent documents:
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`;
  `design/prod01-vision.md`; `design/prod01-vision-supplement.md`;
  `03-04_tranche-03--tasking-2.md`.
- Settled decisions and non-negotiables: preserve `PhyloPlots.plot` visible
  behavior; keep `phyloplot`, `phyloplot!`, and `plot(net)` as the target
  public surfaces without implementing them in tranche 4; keep
  `HybridNetwork` as the only supported public input type; keep R interop out
  of scope; preserve the root / `test/` / `docs/` project split and path
  overrides; use public Pkg operations for dependency changes; keep
  `PlotLayout` as the canonical helper payload; keep direct public
  composability and direct public `xlim` / `ylim` proof deferred to tranche 5.
- Authorization boundary: internal render-owner design, Makie dependency
  activation, and render verification scaffolding are authorized; public
  entry-surface exposure, silent behavior drift, duplicated helper ownership,
  and unreviewed Makie contract assumptions are not.
- Current-state diagnosis: helper owners are real and green, but the repo has
  no Makie dependency baseline, no render adapter, no render proof suite, and
  no render docs page.
- Primary-goal lock: the 6 lock items above.
- Direct red-state repros: repo-local `using Makie` failure; absent
  `src/render_adapter.jl`; absent `test/test_render_adapter.jl`; absent
  render-verification docs page; current source-backed truth still says render
  proof is deferred work.
- Owner and invariant under repair: one render adapter owns Makie primitive
  composition, color policy, width policy, text-layer placement, and final
  limit application for all later public plotting surfaces. The layout engine
  and annotation-data owner continue to own geometry and midpoint data.
- Supported public surfaces affected by that owner semantic:
  `phyloplot`, `phyloplot!`, and `plot(net)` all eventually consume the same
  render adapter. Tranche 4 closes the shared owner only. Tranche 5 closes the
  direct public entry-surface proofs.
- Exact files or surfaces in scope: root, `test/`, and `docs/` project
  environment files; one new render-owner source file under `src/`;
  render-focused tests and helpers under `test/`; source-backed verification
  metadata and render-focused docs pages; one repo-owned workflow note for the
  ratified Makie source set.
- Exact files or surfaces out of scope: `src/layout_engine.jl` semantics,
  `src/annotation_data.jl` semantics, keyword normalization ownership,
  `phyloplot`, `phyloplot!`, `PhyloPlot`, `Makie.plottype`, `plot(net)` public
  exposure, and direct dual-axis public composability proof.
- Required upstream primary sources: the 11 files listed in `Upstream primary
  sources and tranche-start source-set gate` above.
- Green-state gates: `julia --project=. -e 'using Makie'`; repo-local package
  tests via `julia --project=test test/runtests.jl`; docs build via
  `julia --project=docs docs/make.jl`; render-level proofs built on
  CairoMakie-backed outputs or colorbuffers; source-backed verification
  metadata that truthfully records the remaining tranche-5 public-surface
  boundary.
- Stop conditions: stop if the resolved Makie dependency tree differs
  materially from the ratified source-set note; stop if render proof would
  require implementing tranche-5 public entry surfaces early; stop if helper
  ownership would need to move back out of tranche 3 and into render code;
  stop if the only available verification plan degenerates to docs-string or
  source-text policing rather than render-level artifacts.

## Required revalidation before implementation

- Read the tranche and parent PRD in full.
- Read the relevant code, tests, docs, and examples in full.
- Read all cited upstream primary sources in full where they constrain the
  work.
- Re-check the user-authorized disruption boundary before making deep changes.
- Confirm that `src/layout_engine.jl`, `src/annotation_data.jl`, and
  `PlotLayout` are still the canonical helper owners and payload.
- Re-run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` at task start to confirm the tranche-3
  green baseline is still real.
- Re-check that the root, `test/`, and `docs/` project files still lack Makie
  direct dependencies before task 1. If another actor has already activated
  Makie, stop and revise the source-set gate rather than blindly replaying the
  dependency task.
- If the tranche diagnosis no longer matches reality, stop and raise that
  before changing code.

## Tranche execution rule

The work may redesign or deepen the internal render owner where needed, but it
must begin and end in a green, policy-compliant state and it must not cross
the tranche boundary into public plotting entry-surface exposure.

For this render-owner tranche:

- the remaining owner after completion is one Makie render adapter that
  consumes the normalized plot spec and the tranche-3 `PlotLayout`
- the retired shapes are R-shaped drawing assumptions, deprecated or
  unreviewed Makie primitive usage, duplicated full-tree versus major-tree
  render pipelines, render-time geometry recomputation, and accidental draw
  order as the hidden owner of correctness
- docs must be brought into truth with the actual current API and proof
  boundary; docs may not silently broaden the public API surface to make the
  tranche look more complete than it is

## Non-negotiable execution rules

- Do not implement `phyloplot`, `phyloplot!`, `PhyloPlot`, `Makie.plottype`,
  or `plot(net)` dispatch in tranche 4.
- Do not recreate geometry, midpoint placement, or helper-bounds ownership in
  render-facing code.
- Do not rely on deprecated Makie primitive entrypoints if the ratified source
  set says a non-deprecated primitive must be used instead.
- Do not let render verification collapse to grep checks over SVG, XML, YAML,
  Markdown, or source text.
- Do not hand-edit manifests as a first resort.
- Do not change the `HybridNetwork` scope boundary, the path-override policy,
  or the R-out-of-scope decision.
- Do not let docs claim that direct public entry-surface proof is already
  complete.

## Concrete anti-patterns or removal targets

- Any attempt to make full-tree style and major-tree style look different only
  through titles, axis decorations, or test-only figure scaffolding while the
  actual edge semantics remain the same.
- Any render owner that keeps one codepath for `:fulltree` and another fully
  separate codepath for `:majortree` instead of one owner with explicit style
  policy branches.
- Any render-time recomputation of edge midpoints, node positions, minor-edge
  coordinates, or default bounds that duplicates `PlotLayout`.
- Any color-policy implementation that applies dict edge colors to gamma text,
  or otherwise drifts from the visible `plotRCall.jl` contract.
- Any use of module-global mutable state, cached current axis, or hidden
  backend state that would block later dual-axis composability.
- Any proof surface that inspects only shell includes, doc prose, or fixture
  names while leaving rendered behavior untested.

## Failure-oriented verification

- The current root, `test/`, and `docs/` project environments must fail the
  Makie activation checks before task 1. Task 1 closes that red state.
- The render-owner suite must fail the current repository state because
  `src/render_adapter.jl` and `test/test_render_adapter.jl` do not yet exist.
- The style-comparison verification must fail if the `:fulltree` and
  `:majortree` render outputs become pixel-identical for the accepted style
  scenario.
- The render-owner suite must fail if gamma text takes its color from
  dict-driven edge segment colors instead of `majorhybridedgecolor` and
  `minorhybridedgecolor`.
- The render-owner suite must fail if the final text anchors or applied axis
  limits diverge from `PlotLayout.annotations` and `PlotBounds`.
- The source-backed verification tests and docs build must fail if the render
  proof boundary remains implicit or if the docs falsely claim tranche-5
  public entry-surface work is already closed.

Positive runtime and usability checks required for honest render closure:

- a CairoMakie-backed style-comparison artifact for the accepted reticulate
  network
- a CairoMakie-backed gamma and edge-color artifact proving the two color
  policies simultaneously
- a docs page that renders those artifacts from live code rather than from
  static screenshots or prose-only claims

## Tasks

### 1. Activate the Makie baseline and capture the resolved source set

**Type**: CONFIG
**Output**: The root, `test/`, and `docs/` environments resolve the required
Makie-family dependencies, a repo-owned source-set review note exists, and the
pre-render green baseline remains intact.
**Depends on**: none

Use public Pkg operations to add `Makie` to the root package environment and
`CairoMakie` to the `test/` and `docs/` environments while preserving the
existing path-override policy. After dependency resolution, create
`.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`
to record the exact resolved Makie and CairoMakie versions, the exact source
files used to justify recipe, figure-plotting, segment, arrow, text, and
colorbuffer behavior, and the concrete contract conclusions drawn from them.
The note must state explicitly whether the resolved Makie version still uses a
deprecated `arrows!` shim or whether the owner should call the ratified 2D
arrow primitive directly. Re-run the existing package tests and docs build
after the environment change so tranche 4 begins from a real Makie-enabled
green state rather than from an unverified dependency change.

**Positive contract**: Repo-local environments, not a global Julia session,
own the Makie baseline, and the exact source-set input to tranche 4 is
recorded in a repo-owned file.
**Negative contract**: No render code lands yet, no manifest is hand-edited as
the primary mechanism, and no Makie contract assumption remains implicit.
**Files**:
- `Project.toml`
- `Manifest.toml`
- `test/Project.toml`
- `test/Manifest.toml`
- `docs/Project.toml`
- `docs/Manifest.toml`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`
**Out of scope**:
- all `src/` render logic
- render tests
- docs truth migration beyond the source-set note
- public plotting entry surfaces
**Verification**:
- `julia --project=. -e 'using Makie'`
- `julia --project=test -e 'using CairoMakie; using Makie'`
- `julia --project=docs -e 'using CairoMakie; using Makie'`
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- Manual inspection that the source-set note exists and names the exact source
  files that were absent in the old repository state.

### 2. Ratify the resolved Makie contract note before render implementation

**Type**: REVIEW
**Output**: The project owner has an explicit go or no-go review point over
the resolved Makie-family contract note before the render owner lands.
**Depends on**: 1

Present
`.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`
for review. The review must explicitly ratify the exact primitive paths to use
for disjoint segments, minor-edge arrows, text, and render capture. If the
resolved dependency tree differs materially from the tasking-time candidate
sources, revise the note and stop there rather than guessing through the
difference inside the implementation tasks.

**Positive contract**: The render implementation starts from a ratified
Makie-family contract note instead of an implicit assumption set.
**Negative contract**: The project does not proceed into render code with an
unreviewed or materially ambiguous source-set record.
**Files**:
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`
**Out of scope**:
- all `src/` implementation files
- all `test/` render regressions
- docs truth migration
- public plotting entry surfaces
**Verification**:
- Manual review of the source-set note against the resolved project
  environments and the cited upstream files.
- Explicit project-owner go or no-go confirmation before task 3 begins.

### 3. Land the render adapter owner and internal axis harness

**Type**: WRITE
**Output**: `src/render_adapter.jl` defines the canonical internal render owner
and a typed internal layer bundle, the module shell includes it, and the shell
tests still prove that tranche-5 public plotting surfaces are absent.
**Depends on**: 2

Create `src/render_adapter.jl` and include it from `src/PhyloMakie.jl`. The
canonical internal owner for this tranche is
`render_plot!(ax, net, spec, layout)::PlotRenderLayers`, where `ax` is an
explicit axis-like owner, `net` is used only for edge and node metadata that
render policy still needs, `spec` is the normalized keyword owner, and
`layout` is the canonical `PlotLayout` payload from tranche 3. `render_plot!`
must centralize final limit application, segment and bar primitive drawing,
minor-edge arrow drawing, and the assembly of a typed `PlotRenderLayers`
bundle that exposes the relevant plot handles and resolved style, color, and
width vectors for direct tests. It must not own axis-decoration policy beyond
the minimal needs of an internal verification harness, and it must not create
public `phyloplot`, `phyloplot!`, `PhyloPlot`, `Makie.plottype`, or
`plot(net)` entry surfaces. Update the shell tests to include the new render
file while preserving the explicit absence of tranche-5 public surfaces.

Use the ratified source-set note from task 2 as the authority for the exact
Makie primitive calls. Under the current verified candidate sources, that
means `linesegments!`, the ratified 2D arrow primitive path, and `text!`.

**Positive contract**: One internal render owner exists, its owner boundary is
explicit, and the package shell plus tests acknowledge the new owner without
claiming public API closure.
**Negative contract**: No public plotting surface appears, no geometry or
midpoint data is recomputed locally, and no second render implementation is
created per style.
**Files**:
- `src/PhyloMakie.jl`
- `src/render_adapter.jl`
- `test/runtests.jl`
- `test/test_PhyloMakie.jl`
- `test/test_render_adapter.jl`
**Out of scope**:
- `src/layout_engine.jl`
- `src/annotation_data.jl`
- `src/keyword_normalization.jl`
- docs truth migration
- public recipe and entry-surface exposure
**Verification**:
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- Direct shell-owner and render-owner tests that fail the old repository state
  because `src/render_adapter.jl` and the expanded shell include set did not
  exist.

### 4. Close render parity regressions for styles, colors, widths, and text layers

**Type**: TEST
**Output**: CairoMakie-backed render regressions prove style distinction,
hybrid-edge rendering, color policy, width policy, bounds application, and
text-layer placement against the accepted scenarios.
**Depends on**: 3

Expand the fixture corpus and render-owner tests so the accepted render
scenarios become direct local proof artifacts rather than deferred intent.
Create `test/support/render_test_helpers.jl` if needed for figure setup,
backend activation, colorbuffer capture, or plot-handle extraction. The render
suite must exercise:
the accepted reticulate network for `:fulltree` versus `:majortree`;
the gamma scenario;
the edge-color-dict fallback scenario;
the annotation-label scenario; and
the explicit-limit application path.
It must inspect `PlotRenderLayers` directly for color and width policy, and it
must also use a CairoMakie-backed render artifact or `Makie.colorbuffer` to
prove that the two styles do not collapse visually. The tests must assert that
text anchors come from `PlotLayout.annotations`, that final limits come from
the normalized spec plus `PlotBounds`, and that gamma text keeps its major and
minor hybrid colors even when edge segments use dict-driven colors. Keep
direct proof for `composable_dual_axes` deferred to tranche 5, but do not
allow module-global or hidden-axis state to regrow in the render owner.

**Positive contract**: The real render contract is proven directly by local
artifacts that fail the historical no-render state and fail the likely fake
fixes for style collapse, color drift, and text-anchor drift.
**Negative contract**: The suite does not fall back to source-text policing,
SVG-string grep checks, or public recipe tests as substitutes for direct
render-owner proof.
**Files**:
- `src/render_adapter.jl`
- `test/support/fixture_corpus.jl`
- `test/support/render_test_helpers.jl`
- `test/test_render_adapter.jl`
- `test/runtests.jl`
**Out of scope**:
- `phyloplot`
- `phyloplot!`
- `PhyloPlot`
- `Makie.plottype(::HybridNetwork)`
- direct public proof for `plot(net)` or dual-axis composability
**Verification**:
- `julia --project=test test/runtests.jl`
- Direct checks that fail if the full-tree and major-tree colorbuffers are
  identical for the accepted style-comparison scenario.
- Direct checks that fail if gamma text colors follow dict edge colors.
- Direct checks that fail if text anchors or axis limits diverge from
  `PlotLayout.annotations` and `PlotBounds`.

### 5. Migrate source-backed verification and docs to tranche-4 truth

**Type**: MIGRATE
**Output**: Source-backed verification metadata and docs record tranche-4
render closure truthfully while preserving the remaining tranche-5 public API
boundary.
**Depends on**: 4

Update `src/verification_foundation.jl` and
`test/test_verification_foundation.jl` so the render owner, render regression
suite, ratified Makie-family source files, and tranche-4 reviewer gate are all
recorded in source-owned metadata. Create `docs/src/render-verification.md`,
add it to `docs/make.jl`, and update `docs/src/index.md` plus
`docs/src/verification-foundation.md` so they no longer say that render proof
is wholly future work. The new docs truth must still say explicitly that
`phyloplot`, `phyloplot!`, `PhyloPlot`, `Makie.plottype(::HybridNetwork)`, and
`plot(net)` public proof remain tranche-5-owned. The render page must build
the accepted style-comparison, gamma, and edge-color scenarios from live code
using CairoMakie-backed outputs rather than prose-only claims or static
workflow screenshots.

**Positive contract**: The repository's source-backed truth surface now names
the real render owner, the real render proof artifacts, the exact Makie-family
sources read, and the real tranche-5 deferrals.
**Negative contract**: No docs page or metadata entry falsely claims public
entry-surface closure, and no docs-only string update stands in for render
verification.
**Files**:
- `src/verification_foundation.jl`
- `test/test_verification_foundation.jl`
- `docs/make.jl`
- `docs/src/index.md`
- `docs/src/verification-foundation.md`
- `docs/src/render-verification.md`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`
**Out of scope**:
- public recipe or entry-surface implementation
- README migration
- tranche-5 composability proof
- helper-owner rewrites in tranche-3 files
**Verification**:
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- Direct verification-foundation tests that fail the old repository state
  because the render owner and render docs page were still deferred or absent.
