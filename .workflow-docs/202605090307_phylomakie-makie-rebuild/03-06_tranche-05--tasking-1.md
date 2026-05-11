---
date-created: 2026-05-10T13:52:54-07:00
date-updated: 2026-05-10T19:17:04-07:00
workflow-instrument: Tasking Plan
workflow-status: Completed
workflow-agent-thread-id: codex/019e13a4-7e72-7f21-9868-ff250a0959a2
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-prd: .workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md
workflow-tranche: .workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md
---

# Tasks for tranche 5: Makie-native public plot owner and attribute model

## Approval state

- This file was approved, executed, and closed for tranche 5.
- The diagnosis, task list, and verification obligations below remain the
  historical execution input for that tranche.
- No downstream `Tasks -> Execute` run remains pending under this file.

## Settled user decisions and environment baseline

- Public API redesign is authorized for this tranche. Capability loss is not.
- The package must feel Makie-native. A compatibility-first public owner is not
  authorized as the final architecture.
- `PhyloNetworks.HybridNetwork` remains the only supported public input type in
  this production run.
- R interoperability remains out of scope.
- Preserve the root, `test/`, and `docs/` project split.
- Preserve the tranche-4 Makie dependency baseline and source-set note in
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`.
- Reuse `layout_engine.jl`, `annotation_data.jl`, and `render_adapter.jl` as
  the canonical geometry, annotation, and render owners.
- `keyword_normalization.jl` and `keyword_contract.jl` may survive only as a
  tightly local transitional bridge inside the tranche-5 public owner. They
  are not allowed to remain the public semantic center.
- The required public-owner path for this tranche is a Makie recipe:
  `Makie.@recipe(PhyloPlot, net)`. This keeps `plot(net)` and `plot!(ax, net)`
  on Makie host semantics while letting `phyloplot` and `phyloplot!` survive
  only as generated thin convenience surfaces over the same owner.
- The tranche-5 public attribute surface is exactly this keyword set:
  `use_edge_lengths`, `show_tip_labels`, `show_internal_node_names`,
  `show_node_numbers`, `show_edge_lengths`, `show_edge_numbers`,
  `show_gamma`, `edge_color`, `default_edge_color`,
  `major_hybrid_edge_color`, `minor_hybrid_edge_color`, `edge_width`,
  `minor_edge_linestyle`, `minor_edge_arrow_length`, `node_annotations`,
  `edge_annotations`, `node_annotation_scale`, `edge_annotation_scale`,
  `node_annotation_color`, `edge_annotation_color`,
  `node_annotation_align`, `edge_annotation_align`, `tip_label_offset`,
  `tip_label_scale`, `x_limits`, `y_limits`, and `style`.
- The tranche-5 public surface intentionally does not add separate styling
  controls for internal-node-name color, internal-node-name size,
  edge-length-label size, gamma-label size, or node-number size.
  `show_internal_node_names` reuses the tip-label scale group, and the existing
  render-owner defaults remain the authoritative grouping for the omitted
  controls.
- The public attribute surface must not accept the legacy public spellings
  `useedgelength`, `showtiplabel`, `shownodelabel`, `shownodenumber`,
  `showedgelength`, `showedgenumber`, `showgamma`, `edgecolor`,
  `defaultedgecolor`, `majorhybridedgecolor`, `minorhybridedgecolor`,
  `edgewidth`, `minorlinetype`, `arrowlen`, `nodelabel`, `edgelabel`, `xlim`,
  `ylim`, `tipoffset`, `tipcex`, `nodecex`, `edgecex`, `nodelabeladj`,
  `edgelabeladj`, or `preorder`.
- `preorder` is not part of the tranche-5 public surface. Public plotting must
  not mutate the caller-owned `HybridNetwork` implicitly.
- On 2026-05-10, `julia --project=test test/runtests.jl` passed with
  `416/416` tests, and `julia --project=docs docs/make.jl` passed. Tranche 5
  must begin and end from a green baseline at least this strong.

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
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`

Authority notes that remain active in this tasking file:

- The repo-local `STYLE*.md` set is the operative governance set for this
  repository.
- The bundled internal `STYLE*.md` baseline files checked by
  `development-policies` are present and byte-identical to the repo-local
  copies. Treat them as the same-text baseline authorities.
- No bundled internal `CONTRIBUTING.md` was found.
- No repo-local `STYLE-python.md` or `STYLE-domain-vocabulary.md` was found.
- `STYLE-vocabulary.md` remains the domain vocabulary authority except where
  the tranche and revised PRD explicitly reopen older API-specific
  compatibility assumptions.
- `STYLE-workflow-vocabulary.md` remains authoritative for workflow terms such
  as `tranche`, `lock item`, `primary-goal lock`, `red-state repro`,
  `handoff packet`, and `verification artifact`.

Controlled vocabulary obligations that matter directly in this tranche:

- Use `Makie-native public plot owner` for the recipe or plot type that owns
  the public plotting semantics.
- Use `compatibility adapter` only for an explicit, secondary bridge that is
  not the package center.
- Use `layout engine` and `render adapter` for the existing internal owners.
- Use `capability parity` for the preserved plotting outcomes.
- Use `PhyloPlot` only for the recipe type.
- Use `phyloplot` and `phyloplot!` only as recipe-generated convenience
  surfaces, not as the primary semantic owner.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, branch creation, rebase, and reset remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Current-state diagnosis

The tranche-5 diagnosis remains valid, but the current repository state is more
precise than the parent tranche text alone records.

- The internal helper and render owners are live and green. On 2026-05-10, the
  repo passed `416/416` tests and a full docs build with the tranche-4 render
  owner in place.
- There is still no `public_attribute_model.jl`, no `public_plot_owner.jl`, no
  `PhyloPlot` recipe type, no `Makie.plottype(::HybridNetwork)` override, and
  no public `plot(net)` or `plot!(ax, net)` proof surface.
- `src/PhyloMakie.jl` still includes only the compatibility-first keyword
  owners, the helper owners, the render owner, and `verification_foundation.jl`.
- `test/test_PhyloMakie.jl` still asserts that `phyloplot`, `phyloplot!`, and
  `PhyloPlot` are absent and that `Makie.plot(net)` fails with the current
  no-recipe error.
- `src/verification_foundation.jl`, `docs/src/index.md`, and
  `docs/src/verification-foundation.md` still describe the tranche-5 public
  owner as entirely absent future work.
- The current source-backed target-surface inventory is incomplete relative to
  the revised PRD and tranche acceptance criteria because it tracks
  `phyloplot`, `phyloplot!`, and `plot(net)` but omits direct
  `plot!(ax, net)` proof as a supported public surface.
- `keyword_normalization.jl` and `keyword_contract.jl` still own the only live
  normalized entry path, and their accepted names and messages are still legacy
  compatibility spellings.
- `prepare_plot_layout(net, spec)` still reaches `layout_plot_geometry`, which
  mutates the working network when `spec.layout.preorder` is true. A tranche-5
  public owner cannot call this path on the caller-owned network without an
  isolation step.
- `render_plot!(ax, net, spec, layout)::PlotRenderLayers` is already the only
  render owner. Tranche 5 must consume it rather than fork its drawing policy.

## Upstream primary sources and settled contract conclusions

The following upstream primary sources constrain this tranche and must be read
line by line before implementation:

- `PhyloPlots.jl/src/phylonetworksPlots.jl`
- `PhyloPlots.jl/src/plotRCall.jl`
- `PhyloPlots.jl/test/test_phylonetworkPlots.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/display.jl`
- `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v/src/screen.jl`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`

Verified contract conclusions already settled during tasking:

- `Makie.@recipe(PhyloPlot, net)` is the required host-framework route for one
  shared public owner because it generates `phyloplot` and `phyloplot!`
  automatically while leaving `plot(net)` and `plot!(ax, net)` on the Makie
  generic path through `Makie.plottype(::HybridNetwork)`.
- `Makie.plot(net)` returns `Makie.FigureAxisPlot`, while `Makie.plot!(ax, net)`
  returns the plot object itself. Tranche-5 verification must prove both
  contracts directly.
- The visible capability reference for labels, colors, widths, style
  distinctions, and gamma rendering remains `PhyloPlots.jl/src/plotRCall.jl`,
  but it is not the authority for final public keyword names.
- The existing helper owners already define the geometry, midpoint, annotation,
  and bounds contracts, and the existing render owner already defines the only
  primitive-composition contract. Tranche 5 must not recreate either owner.
- Because direct public limit messages were deferred to tranche 5 while the
  current helper owners still name `xlim` and `ylim`, the public owner must
  translate that contract to `x_limits` and `y_limits` instead of leaking the
  legacy spellings.
- Because `preorder` still mutates the working network in the helper path and
  the revised design supplement reopened the mutation policy, the tranche-5
  public surface must not expose `preorder` and must isolate caller-owned
  networks before traversal mutation occurs.

## Primary-goal lock

### Lock item 1: Makie-native public plot owner

- The work is not complete if `HybridNetwork` still lacks one real Makie plot
  owner, or if `plot(net)` and `plot!(ax, net)` resolve through different
  semantic centers.
- The direct red-state repro is the current repository state:
  `test/test_PhyloMakie.jl` still asserts that `PhyloPlot`, `phyloplot`,
  `phyloplot!`, and `Makie.plot(net)` support are absent, and
  `Makie.plot(net)` throws the no-recipe error.
- The tasks that close this are task 3 and task 4.
- The verification artifact is direct proof for `Makie.plottype`,
  `plot(net)`, `plot!(ax, net)`, `phyloplot`, and `phyloplot!` that fails the
  old repository state.

### Lock item 2: Makie-native public attribute surface

- The work is not complete if public plotting still requires legacy keyword
  spellings, or if docs and tests still teach the compatibility-first keyword
  shell as the canonical interface.
- The direct red-state repro is the current normalized owner in
  `keyword_normalization.jl`, which only accepts legacy spellings such as
  `showtiplabel`, `edgelabel`, `xlim`, and `preorder`.
- The tasks that close this are task 1, task 2, task 4, and task 5.
- The verification artifact is an exact public-attribute test suite for the
  settled snake_case names plus direct rejection of the legacy public names on
  the tranche-5 entry surfaces.

### Lock item 3: Compatibility-first owner demotion

- The work is not complete if `keyword_normalization.jl` or
  `keyword_contract.jl` still functions as the user-facing plotting owner, or
  if a public surface can bypass the new public attribute owner and talk to
  `PlotKeywordSpec` directly.
- The direct red-state repro is the current code path:
  `normalize_plot_keywords` produces `PlotKeywordSpec`, and every live plotting
  contract still centers that owner.
- The tasks that close this are task 1, task 3, and task 5.
- The verification artifact is a source-backed public-owner path in which any
  `PlotKeywordSpec` bridge remains unexported and local, public tests never
  mention legacy names, and docs describe the bridge only as transitional
  tranche-5 scaffolding if it survives at all.

### Lock item 4: Layout and render owner reuse

- The work is not complete if the public owner reimplements geometry,
  midpoints, bounds, or primitive composition, or if `render_plot!` ceases to
  be the only render owner.
- The direct red-state repro is the already-green tranche-3 and tranche-4
  owner stack: any fake tranche-5 fix could go visually green while silently
  forking the helper or render owners.
- The tasks that close this are task 3 and task 4.
- The verification artifact is owner-level public proof that the recipe stores
  the `PlotLayout` and `PlotRenderLayers` it actually consumed, combined with
  the existing helper and render regression suites staying green.

### Lock item 5: Public mutation and composability boundary

- The work is not complete if public plotting mutates the caller-owned
  `HybridNetwork`, exposes a public `preorder` knob, reintroduces hidden
  current-axis state, or fails to compose across two separate axes.
- The direct red-state repro is the current helper path:
  `layout_plot_geometry` still mutates the working network when `preorder` is
  true, and there is no public composability proof because the public owner is
  still absent.
- The tasks that close this are task 1, task 3, and task 4.
- The verification artifact is direct public tests that reject `preorder`,
  snapshot the caller-owned network before and after plotting, and render two
  networks into separate axes without state bleed-through.

### Lock item 6: Multi-surface direct public proof

- The work is not complete if any supported public surface can drift from its
  siblings, or if direct public `x_limits` and `y_limits` error paths remain
  unproved.
- The direct red-state repro is the current repository state:
  `plot(net)` has no recipe, `plot!(ax, net)` has no proof surface at all, and
  `VERIFICATION_FOUNDATION` does not even inventory the mutating Makie axis
  surface as a target public surface.
- The tasks that close this are task 3, task 4, and task 5.
- The verification artifact is one direct regression each for `plot(net)`,
  `plot!(ax, net)`, `phyloplot`, and `phyloplot!`, plus direct malformed-limit
  checks that use the new public names `x_limits` and `y_limits`.

### Lock item 7: Honest verification and docs truth surface

- The work is not complete if source-backed metadata or docs still say the
  tranche-5 public owner is absent, or if they teach the legacy keyword shell
  as canonical.
- The direct red-state repro is the current truth surface:
  `src/verification_foundation.jl`, `docs/src/index.md`, and
  `docs/src/verification-foundation.md` all still describe the target public
  owner as deferred future work.
- The task that closes this is task 5.
- The verification artifact is updated source-backed metadata, updated docs,
  and a green docs build with live public examples that fail the old deferred
  story.

## Handoff packet

- Approval state: proposed only. Do not execute until the project owner sets
  `workflow-status: Approved` in this file.
- Active authorities: `CONTRIBUTING.md`; all repo-local root `STYLE*.md`
  files; `STYLE-vocabulary.md`; `STYLE-workflow-vocabulary.md`;
  `design/prod01-vision.md`; `design/prod01-vision-supplement.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`.
- Parent documents:
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`;
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`;
  `design/prod01-vision.md`; `design/prod01-vision-supplement.md`;
  `04-01_tranche-04--makie-source-set.md`.
- Settled decisions and non-negotiables: Makie-native public API; one recipe
  owner `PhyloPlot`; mandatory generic Makie surfaces `plot(net)` and
  `plot!(ax, net)`; generated thin convenience surfaces `phyloplot` and
  `phyloplot!`; exact public attribute set recorded above; no public legacy
  keyword names; no public `preorder`; no implicit mutation of caller-owned
  networks; keep `HybridNetwork` scope; keep R interop out of scope.
- Authorization boundary: deep public-owner and public-API redesign is
  authorized; capability loss, fake wrappers, duplicated helper owners,
  duplicated render owners, and compatibility-first public semantics are not.
- Current-state diagnosis: internal helper and render owners are green, but the
  repo still has no public attribute owner, no public recipe owner, no
  `Makie.plottype(::HybridNetwork)` override, no public `plot(net)` or
  `plot!(ax, net)` proof, and stale source-backed docs truth.
- Primary-goal lock: the 7 lock items above.
- Direct red-state repros: no public recipe; no `Makie.plottype` override; no
  public mutating axis proof surface; current shell tests still assert absence;
  current docs and verification metadata still say the owner is deferred.
- Owner and invariant under repair: repair the public semantic owner; rely on
  the existing layout and render invariants without reimplementing them.
- Supported public surfaces affected by that owner semantic:
  `plot(net)`, `plot!(ax, net)`, `phyloplot`, and `phyloplot!`.
- Exact files or surfaces in scope: `src/PhyloMakie.jl`; one new public
  attribute-owner source file; one new public plot-owner source file; shell
  tests; direct public tests; source-backed verification metadata; home and
  public API docs pages.
- Exact files or surfaces out of scope: final retirement of the compatibility
  owner; migration-guide completion; non-`HybridNetwork` support; final docs
  and migration closure from tranche 7.
- Required upstream primary sources: the 10 files listed in `Upstream primary
  sources and settled contract conclusions` above.
- Green-state gates: `julia --project=test test/runtests.jl`;
  `julia --project=docs docs/make.jl`; direct public tests for all supported
  public surfaces; source-backed docs and verification metadata aligned with
  the implemented tranche-5 state.
- Stop conditions: stop if a single recipe owner cannot honestly drive all
  four supported public surfaces; stop if the only workable route still makes
  legacy keyword names or `preorder` part of the public surface; stop if
  caller-owned `HybridNetwork` mutation cannot be isolated without reopening
  the helper-owner boundary; stop if the only proof surface for public work
  degenerates to source-text or docs-string policing.

## Required revalidation before implementation

- Read the tranche and parent PRD in full.
- Read the revised design brief and revised design supplement in full.
- Read the tranche-4 Makie source-set note in full.
- Read the relevant current code, tests, docs, and examples in full.
- Re-run `julia --project=test test/runtests.jl` and
  `julia --project=docs docs/make.jl` at task start to confirm the current
  green baseline still holds.
- Re-check that `src/verification_foundation.jl` still omits direct
  `plot!(ax, net)` proof before task 5. If another actor has already repaired
  that source-backed truth surface, stop and revise the tasking file rather
  than replaying the migration blindly.
- Re-check that `layout_plot_geometry` or its successor still mutates the
  working network when `preorder` is true before task 3. If that boundary has
  already been redesigned upstream, stop and simplify the public-owner plan
  instead of preserving an unnecessary copy step.
- If the tranche diagnosis no longer matches reality, stop and rewrite,
  split, or escalate this tasking file before changing code.

## Tranche execution rule

The work may add new public owners and redesign the public plotting interface,
but it must begin and end in a green, policy-compliant state and it must not
cross the tranche boundary into final compatibility-owner retirement or final
migration-guide closure.

For this public-owner tranche:

- the remaining owners after completion are a Makie-native public attribute
  owner and a Makie recipe owner for `HybridNetwork`
- the only allowed compatibility-first survivor is a thin, local bridge into
  `PlotKeywordSpec` while tranche 6 is still pending
- the retired public shapes are the legacy keyword shell as the package center,
  public `preorder`, hand-written wrapper semantics independent from the
  recipe, and any docs that teach the legacy shell as canonical
- docs must be brought into truth with the implemented Makie-native API; API
  changes are authorized to satisfy that truth boundary

## Non-negotiable execution rules

- Do not accept legacy keyword names on the tranche-5 public surfaces.
- Do not expose `preorder` publicly.
- Do not mutate the caller-owned `HybridNetwork` implicitly.
- Do not write a separate semantic implementation for `phyloplot` or
  `phyloplot!`; let the recipe-generated surfaces stay thin.
- Do not duplicate geometry, midpoint, bounds, or render logic outside the
  existing helper and render owners.
- Do not claim final retirement of `keyword_normalization.jl` or
  `keyword_contract.jl`; tranche 6 still owns that closure.
- Do not teach the legacy keyword shell as the primary user surface anywhere in
  docs, examples, or verification metadata.
- Do not widen scope beyond `HybridNetwork`.
- Do not reintroduce R into the plotting path.

## Concrete anti-patterns or removal targets

- Any public recipe or wrapper that accepts `showtiplabel`, `edgelabel`,
  `nodelabel`, `xlim`, `ylim`, or `preorder` directly from the user.
- Any exported or docs-described public dependency on `PlotKeywordSpec`,
  `normalize_plot_keywords`, or `KEYWORD_SURFACE_CONTRACT`.
- Any public-owner implementation that plots by calling a separate wrapper
  logic path instead of one recipe owner.
- Any public-owner implementation that mutates the caller-owned network in
  place rather than isolating a working copy before traversal updates.
- Any `VERIFICATION_FOUNDATION` target-surface table that still omits
  `plot!(ax, net)` after tranche 5 lands.
- Any docs example that still teaches `showtiplabel`, `showedgelength`,
  `showgamma`, `edgelabel`, `nodelabel`, `xlim`, or `ylim` as the canonical
  tranche-5 surface.
- Any proof surface that relies only on source-text inspection, docs-string
  inspection, or grep checks while the public plotting behavior itself is
  untested.

## Failure-oriented verification

- `Makie.plot(net)` must fail the old repository state with the no-recipe error.
- `Makie.plot!(ax, net)` and `phyloplot!(ax, net)` must fail the old
  repository state because the public owner does not exist yet.
- `plot(net; show_tip_labels = true)` must succeed, while
  `plot(net; showtiplabel = true)` must fail on the implemented tranche-5
  public surface.
- `plot(net; x_limits = (1.0, 2.0, 3.0))` and
  `plot(net; y_limits = (1.0,))` must fail with public messages that use the
  new names and include the default bounds payload.
- Public plotting tests must fail if `plot(net)` or `plot!(ax, net)` mutates
  the caller-owned network state.
- Public plotting tests must fail if `plot(net)` and `phyloplot(net)` or
  `plot!(ax, net)` and `phyloplot!(ax, net)` can drift semantically or
  visually from each other.
- Public plotting tests must fail if `plot[:resolved_layout]` is missing or is
  not a `PlotLayout`, or if `plot[:render_layers]` is missing or is not a
  `PlotRenderLayers`.
- The docs build must fail if the home page or the verification-foundation page
  still says the tranche-5 public owner is unimplemented.

Positive runtime and usability checks required for honest tranche-5 closure:

- a live `plot(net)` example in docs
- a live `plot!(ax, net)` example in docs
- a direct dual-axis composition proof in tests
- source-backed `VERIFICATION_FOUNDATION` data that inventories all four
  supported public surfaces

## Tasks

### 1. Define the Makie-native public attribute owner

**Type**: WRITE
**Output**: `src/public_attribute_model.jl` exists, `src/PhyloMakie.jl`
includes it immediately after `keyword_normalization.jl`, and one unexported
`PhyloPlotAttributes` owner defines the exact tranche-5 public keyword
surface without yet exposing any public plotting surface.
**Depends on**: none

Create `src/public_attribute_model.jl` and include it from `src/PhyloMakie.jl`
immediately after `keyword_normalization.jl`. In that file, define one
unexported immutable `PhyloPlotAttributes` owner plus one unexported
resolver/bridge pair that the later recipe owner can consume. The accepted
public keyword names are exactly the 27 names listed in `Settled user
decisions and environment baseline`; no other public spellings are allowed.
Preserve current visible capability defaults where they remain valid, but adopt
the new spellings and groupings. Keep scalar-versus-dict behavior for
`edge_color` and `edge_width`, keep `style` as `:fulltree` or `:majortree`,
and keep DataFrame copy semantics for `node_annotations` and
`edge_annotations`. Do not accept `preorder` or any legacy keyword spelling in
this new public owner. Carry `x_limits` and `y_limits` forward as raw explicit
overrides rather than validating them through `_validate_explicit_limit`; the
direct public limit-message owner remains tranche-5 work after `PlotBounds`
exists. Update `test/test_PhyloMakie.jl` only as needed to keep the shell-owner
include inventory green while still asserting that the public plot owner is
absent at the end of this task.

**Positive contract**: The repository has one explicit Makie-native public
attribute owner with the settled snake_case keyword set, and the module shell
knows about it without exposing any public plotting entry surface yet.
**Negative contract**: Do not expose `PhyloPlot`, `phyloplot`, `phyloplot!`,
`Makie.plottype`, or any public plotting method in this task. Do not accept
legacy keyword names or `preorder`. Do not edit helper or render-owner logic.
**Files**:
- `src/PhyloMakie.jl`
- `src/public_attribute_model.jl`
- `test/test_PhyloMakie.jl`
**Out of scope**:
- `src/public_plot_owner.jl`
- direct public plotting tests
- docs and verification-foundation truth migration
- final retirement of `keyword_normalization.jl` or `keyword_contract.jl`
**Verification**:
- `julia --project=test test/runtests.jl`
- Shell-owner inspection that the include order is exactly
  `keyword_contract.jl`, `keyword_normalization.jl`, `public_attribute_model.jl`,
  `layout_engine.jl`, `annotation_data.jl`, `render_adapter.jl`,
  `verification_foundation.jl`
- A failure against the old repository state where `public_attribute_model.jl`
  and the new include inventory do not exist

### 2. Prove the public attribute surface and the public mutation boundary

**Type**: TEST
**Output**: A dedicated public-attribute regression suite proves the exact
tranche-5 keyword surface, the legacy-name rejection boundary, and the
continued local bridge contract into `PlotKeywordSpec`.
**Depends on**: 1

Create `test/test_public_attribute_model.jl` and include it from
`test/runtests.jl`. Add direct proofs for the exact public keyword set, default
values, style-dependent defaults, DataFrame copy semantics, and scalar-versus-
dict color and width behavior on the new owner. Add direct negative tests that
legacy public names such as `showtiplabel`, `edgelabel`, `nodelabel`, `xlim`,
`ylim`, and `preorder` are rejected at the new public boundary. Add bridge
tests that the resolver can still build the current internal `PlotKeywordSpec`
shape needed by `prepare_plot_layout` and `render_plot!` without reopening
helper or render ownership here. Preserve the current subtle ordering rule that
`minor_edge_arrow_length` and `minor_edge_linestyle` resolve from the incoming
`style` before unknown-style fallback rewrites the resolved style symbol, so a
fresh implementing agent does not silently change that contract during the
bridge phase.

**Positive contract**: There is a direct, dedicated proof surface for the
Makie-native attribute owner and for the exact boundary between the new public
surface and the old internal compatibility owner.
**Negative contract**: Do not prove this surface only by shell include counts
or source-text inspection. Do not add recipe or public plotting behavior in
this task. Do not let the tests accept legacy public names.
**Files**:
- `test/test_public_attribute_model.jl`
- `test/runtests.jl`
**Out of scope**:
- `src/public_plot_owner.jl`
- docs
- `src/verification_foundation.jl`
- public `plot(net)` or `plot!(ax, net)` proof
**Verification**:
- `julia --project=test test/runtests.jl`
- Direct failure of the old repository state where the new keyword names are
  unknown and the dedicated test file does not exist
- Direct failure of any fake fix that still accepts legacy names or exposes
  `preorder`

### 3. Land the `PhyloPlot` recipe owner and shared public plotting path

**Type**: WRITE
**Output**: `src/public_plot_owner.jl` exists, `src/PhyloMakie.jl` includes it
after `render_adapter.jl`, `PhyloPlot` is the real recipe owner for
`HybridNetwork`, and all four supported public surfaces route through that one
owner.
**Depends on**: 2

Create `src/public_plot_owner.jl` and include it from `src/PhyloMakie.jl`
after `render_adapter.jl` and before `verification_foundation.jl`. Define
`Makie.@recipe(PhyloPlot, net)` with the exact public attribute names from task
1 as recipe attributes. Define `Makie.plottype(::PhyloNetworks.HybridNetwork) =
PhyloPlot`. Implement `Makie.plot!(plot::PhyloPlot)` as the only public owner:
read the `HybridNetwork` argument, resolve `PhyloPlotAttributes`, bridge
locally into `PlotKeywordSpec`, isolate the caller-owned network with
`deepcopy` before any traversal mutation can occur, call `prepare_plot_layout`,
validate direct public `x_limits` and `y_limits` against `PlotBounds` using the
new public spellings in the final error text, then call `render_plot!`. Store
the `PlotLayout` and `PlotRenderLayers` that were actually consumed on the
recipe object under private attributes `:resolved_layout` and `:render_layers`
so task-4 tests can prove the owner boundary directly. Do not write separate
semantic logic for `phyloplot` or `phyloplot!`; rely on the recipe-generated
surfaces from `@recipe`. Update `test/test_PhyloMakie.jl` so the shell-owner
proof now requires `public_plot_owner.jl`, `PhyloPlot`, `phyloplot`,
`phyloplot!`, and `Makie.plottype(::HybridNetwork)` while preserving the thin
shell include assertions.

**Positive contract**: One recipe owner drives `plot(net)`, `plot!(ax, net)`,
`phyloplot`, and `phyloplot!`, and the owner isolates caller-owned network
state before any helper-level mutation can occur.
**Negative contract**: Do not hand-write separate wrapper semantics. Do not
accept legacy keyword names or public `preorder`. Do not reimplement geometry
or render logic. Do not let public plotting bypass Makie host semantics.
**Files**:
- `src/PhyloMakie.jl`
- `src/public_plot_owner.jl`
- `src/public_attribute_model.jl`
- `test/test_PhyloMakie.jl`
**Out of scope**:
- dedicated public API regression coverage
- docs and verification-foundation truth migration
- final compatibility-owner retirement
**Verification**:
- `julia --project=test test/runtests.jl`
- Shell-owner proof that the include order is exactly
  `keyword_contract.jl`, `keyword_normalization.jl`, `public_attribute_model.jl`,
  `layout_engine.jl`, `annotation_data.jl`, `render_adapter.jl`,
  `public_plot_owner.jl`, `verification_foundation.jl`
- Direct failure of the old repository state where `Makie.plot(net)` still
  throws the no-recipe error and `phyloplot` / `phyloplot!` / `PhyloPlot` are
  absent
- Direct proof that `Makie.plottype(::HybridNetwork)` resolves to `PhyloPlot`

### 4. Add direct multi-surface public API proof

**Type**: TEST
**Output**: A dedicated public-owner regression suite proves the four
supported public surfaces, the caller-network non-mutation boundary, direct
`x_limits` and `y_limits` error paths, and two-axis Makie composability.
**Depends on**: 3

Create `test/test_public_plot_owner.jl` and include it from `test/runtests.jl`.
Use `FIXTURE_CORPUS`, the existing render-test helpers where they fit, and
live CairoMakie-backed `Makie.colorbuffer` artifacts. Add one direct proof each
for `Makie.plot(net)`, `Makie.plot!(ax, net)`, `phyloplot(net)`, and
`phyloplot!(ax, net)`. For at least one representative reticulate fixture,
prove that `plot(net)` and `phyloplot(net)` produce identical rendered results,
and separately that `plot!(ax, net)` and `phyloplot!(ax, net)` produce
identical rendered results. Assert that the returned public plot object stores
`plot[:resolved_layout] isa PlotLayout` and
`plot[:render_layers] isa PlotRenderLayers`. Add direct negative tests that
legacy keyword names are rejected, malformed `x_limits` and `y_limits` raise
public errors using the new names, and caller-owned network state remains
unchanged before and after plotting. Add a dual-axis composition regression
using two different networks in one figure to prove that public plotting does
not depend on hidden current-axis state.

**Positive contract**: Every supported tranche-5 public surface has direct,
contract-level proof, and the owner boundary is verifiable from the returned
plot object rather than from source-text guesses.
**Negative contract**: Do not rely on a single helper-level proxy for all
surfaces. Do not accept legacy keyword names in any public proof. Do not use
docs-only or source-text-only proof for composability, limits, or mutation.
**Files**:
- `test/test_public_plot_owner.jl`
- `test/runtests.jl`
**Out of scope**:
- docs content
- `src/verification_foundation.jl`
- final compatibility-owner retirement
- non-`HybridNetwork` public support
**Verification**:
- `julia --project=test test/runtests.jl`
- Direct failure of the old repository state where the public owner does not
  exist
- Direct failure of any fake fix where wrappers drift from the recipe owner,
  where public plotting mutates the caller-owned network, or where two axes
  share hidden state

### 5. Migrate verification metadata and docs to the new public truth surface

**Type**: MIGRATE
**Output**: Source-backed verification metadata, shell tests, and docs all
tell the implemented tranche-5 story truthfully and teach the Makie-native
public surface first.
**Depends on**: 4

Update `src/verification_foundation.jl`, `test/test_verification_foundation.jl`,
`docs/make.jl`, `docs/src/index.md`, and `docs/src/verification-foundation.md`.
Add `docs/src/public-api.md` and register it in `docs/make.jl`. Rewrite the
source-backed target-surface inventory so it names all four supported public
surfaces: `plot(net)`, `plot!(ax, net)`, `phyloplot`, and `phyloplot!`. Update
the current-status facts so tranche 5 records a live public owner rather than
future absence, while still keeping tranche-6 compatibility-owner retirement
and tranche-7 migration-guide completion explicit as future work. Record the
new public attribute owner and the public plot owner as the canonical tranche-5
owners, and describe any surviving `PlotKeywordSpec` bridge only as local
transitional scaffolding. In docs, teach the Makie-native surface first through
live `@example` blocks for `plot(net)` and `plot!(ax, net)` using the new
snake_case attribute names. Mention `phyloplot` and `phyloplot!` only as
secondary convenience surfaces over the same owner. Remove all primary-docs
claims that the public owner is still unimplemented or that the legacy keyword
shell remains canonical.

**Positive contract**: The source-backed verification owner and the docs truth
surface both match the implemented tranche-5 architecture, and the primary docs
path teaches the Makie-native public API first.
**Negative contract**: Do not claim final retirement of the compatibility
owner. Do not teach legacy keyword names as canonical. Do not replace live
examples with static screenshots or prose-only claims.
**Files**:
- `src/verification_foundation.jl`
- `test/test_verification_foundation.jl`
- `docs/make.jl`
- `docs/src/index.md`
- `docs/src/public-api.md`
- `docs/src/verification-foundation.md`
**Out of scope**:
- final migration-guide completion
- tranche-6 compatibility-owner retirement
- non-`HybridNetwork` public support
**Verification**:
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- Direct failure of the old repository state where `VERIFICATION_FOUNDATION`
  still marks the public owner as deferred and the docs still teach the owner
  as absent future work
- Direct failure of any fake fix where the docs build stays green while one of
  the four supported public surfaces remains missing from the source-backed
  target-surface inventory
