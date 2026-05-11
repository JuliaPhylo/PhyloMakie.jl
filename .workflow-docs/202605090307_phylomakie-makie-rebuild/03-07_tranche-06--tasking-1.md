---
date-created: 2026-05-10T17:13:29-07:00
workflow-instrument: Tasking Plan
workflow-status: Proposed
workflow-agent-thread-id: codex/019e145a-2aae-7993-9bae-eb4cc0329b6a
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-prd: .workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md
workflow-tranche: .workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md
---

# Tasks for tranche 6: Compatibility-shell eradication and internal public-path realignment

## Approval state

- This file is proposed tasking output for proposed tranche 6 in `02_tranches.md`.
- This file is not an execution request.
- To authorize a downstream `Tasks -> Execute` run, the project owner must set
  `workflow-status: Approved` in this file's frontmatter.

## Settled user decisions and environment baseline

- Public API redesign has already been exercised in tranche 5. Tranche 6 must
  preserve the implemented tranche-5 public API rather than reopen it.
- The package must feel Makie-native. No accepted end state may preserve a
  runtime compatibility shell or a second semantic center behind the public
  recipe.
- `PhyloNetworks.HybridNetwork` remains the only supported public input type in
  this production run.
- R interoperability remains out of scope.
- Preserve the root, `test/`, and `docs/` project split.
- Preserve the tranche-4 Makie dependency baseline and source-set note in
  `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`.
- Preserve the implemented tranche-5 public owner route:
  `Makie.@recipe(PhyloPlot, net)` plus
  `Makie.plottype(::PhyloNetworks.HybridNetwork) = PhyloPlot`, with
  `phyloplot` and `phyloplot!` surviving only as generated thin convenience
  surfaces over the same owner.
- Preserve the exact tranche-5 public attribute surface:
  `use_edge_lengths`, `show_tip_labels`, `show_internal_node_names`,
  `show_node_numbers`, `show_edge_lengths`, `show_edge_numbers`,
  `show_gamma`, `edge_color`, `default_edge_color`,
  `major_hybrid_edge_color`, `minor_hybrid_edge_color`, `edge_width`,
  `minor_edge_linestyle`, `minor_edge_arrow_length`, `node_annotations`,
  `edge_annotations`, `node_annotation_scale`, `edge_annotation_scale`,
  `node_annotation_color`, `edge_annotation_color`,
  `node_annotation_align`, `edge_annotation_align`, `tip_label_offset`,
  `tip_label_scale`, `x_limits`, `y_limits`, and `style`.
- Preserve the tranche-5 legacy-name rejection boundary. The public surface
  must continue rejecting legacy public spellings such as `showtiplabel`,
  `xlim`, `ylim`, `nodelabel`, `edgelabel`, `edgecolor`, and `preorder`.
- `preorder` remains internal only. Public plotting must not expose it or
  silently mutate the caller-owned `HybridNetwork`.
- Tasking-settled runtime-owner decision:
  `PhyloPlotAttributes` is the sole accepted runtime semantic carrier after
  tranche 6. Do not introduce a second replacement compatibility payload, and
  do not keep `PlotKeywordSpec` alive under another name.
- On 2026-05-10:
  - `julia --project=. -e 'using Makie'` passed.
  - `julia --project=test -e 'using CairoMakie; using Makie'` passed.
  - `julia --project=docs -e 'using CairoMakie; using Makie'` passed.
  - `julia --project=test test/runtests.jl` passed `572/572` tests.
  - `julia --project=docs docs/make.jl` passed, with only Documenter
    example-size fallback warnings on `public-api.md` and
    `render-verification.md`.
- Tranche 6 must begin and end from a green baseline at least this strong.
- Do not change dependency declarations, manifests, or path-override policy in
  this tranche.
- Docs must adapt to the accepted API and runtime architecture. Do not broaden
  the API to preserve old internal docs examples.
- Final migration-guide completion and legacy capability-mapping prose remain
  tranche-7 work.

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
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-06_tranche-05--tasking-1.md`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`

Authority notes that remain active in this tasking file:

- The repo-local `STYLE*.md` set is the operative governance set for this
  repository.
- The bundled internal `STYLE*.md` baseline files checked by
  `development-policies` are present and byte-identical to the repo-local
  copies. Treat them as the same-text baseline authorities.
- No bundled internal `CONTRIBUTING.md` was found.
- No repo-local `STYLE-python.md` or `STYLE-domain-vocabulary.md` was found.
- `STYLE-vocabulary.md` remains the domain vocabulary authority.
- `STYLE-workflow-vocabulary.md` remains authoritative for workflow terms such
  as `tranche`, `lock item`, `primary-goal lock`, `red-state repro`,
  `handoff packet`, and `verification artifact`.

Controlled vocabulary obligations that matter directly in this tranche:

- Use `Makie-native public plot owner` for the recipe owner.
- Use `public attribute surface` for the supported snake_case surface.
- Use `legacy keyword surface` only for rejected compatibility spellings or
  historical diagnosis.
- Use `layout engine` and `render adapter` for the existing internal owners.
- Treat `PhyloPlot` as an implementation-detail type.
- Treat `phyloplot` and `phyloplot!` only as thin convenience surfaces over
  the same Makie-native public plot owner.

Read-only git and shell commands may be used freely. Mutating git operations
such as commit, merge, push, branch creation, rebase, and reset remain the
human project owner's responsibility unless the user explicitly instructs
otherwise.

## Current-state diagnosis

The tranche-6 diagnosis remains valid, but the current repository state is now
post-tranche-5 and therefore more specific than the parent tranche text.

- The tranche-5 public owner is live and green. `src/public_plot_owner.jl`
  defines `Makie.@recipe PhyloPlot (net,)`, and the repository now proves
  `plot(net)`, `plot!(ax, net)`, `phyloplot`, and `phyloplot!`.
- The default runtime still carries the compatibility shell:
  `src/PhyloMakie.jl` includes `src/keyword_contract.jl` and
  `src/keyword_normalization.jl`; loading the package still defines
  `PlotKeywordSpec` and `normalize_plot_keywords`.
- `src/public_attribute_model.jl` still ends in
  `bridge_phylo_plot_attributes(attributes; x_limits, y_limits)::PlotKeywordSpec`.
- `src/layout_engine.jl`, `src/annotation_data.jl`, and
  `src/render_adapter.jl` still consume `PlotKeywordSpec` directly through
  legacy field names such as `useedgelength`, `shownodelabel`, `nodelabel`,
  `edgelabel`, `tipoffset`, `xlim`, and `ylim`.
- `src/public_plot_owner.jl` still constructs two bridged `PlotKeywordSpec`
  values before calling `prepare_plot_layout` and `render_plot!`.
- The helper, render, and docs proof surfaces still depend on the
  compatibility shell:
  `test/support/render_test_helpers.jl`, `test/test_layout_engine.jl`,
  `test/test_annotation_data.jl`, `test/test_render_adapter.jl`, and
  `docs/src/render-verification.md` all call `normalize_plot_keywords` and
  still use legacy keyword spellings in their fixtures.
- `src/verification_foundation.jl`, `test/test_verification_foundation.jl`,
  `docs/src/index.md`, and `docs/src/verification-foundation.md` still record
  a `compatibility_keyword_bridge` owner and still describe `PlotKeywordSpec`
  as accepted tranche-5 scaffolding.
- `test/test_PhyloMakie.jl` still treats `keyword_contract.jl` and
  `keyword_normalization.jl` as required module includes, and `test/runtests.jl`
  still includes `test/test_keyword_contract.jl` and
  `test/test_keyword_normalization.jl`.

The current green state is therefore honest about public plotting, but it still
permits a wrong runtime architecture to survive behind the suite and docs.
Tranche 6 is still needed.

## Upstream primary sources and settled contract conclusions

The following upstream primary sources constrain this tranche and must be read
line by line before implementation:

- `PhyloPlots.jl/src/phylonetworksPlots.jl`
- `PhyloPlots.jl/src/plotRCall.jl`
- `PhyloPlots.jl/test/test_phylonetworkPlots.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/display.jl`
- `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v/src/screen.jl`
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`

Verified contract conclusions already settled during tasking:

- From `Makie/src/recipes.jl`, `@recipe(PhyloPlot, net)` generates
  `phyloplot` and `phyloplot!`. No hand-written wrapper semantics are allowed
  to survive as a second owner.
- From `Makie/src/figureplotting.jl`, `plot(net)` must keep the non-mutating
  `FigureAxisPlot` contract, while `plot!(ax, net)` must keep the mutating
  existing-axis contract.
- From `Makie/src/display.jl` and `CairoMakie/src/screen.jl`,
  `Makie.colorbuffer(...; backend = CairoMakie)` remains the host-side render
  capture contract for helper, render, and public proof. Do not replace it
  with SVG scraping, Markdown-string checks, or source-text policing.
- From `PhyloPlots.jl/src/phylonetworksPlots.jl` and
  `PhyloPlots.jl/test/test_phylonetworkPlots.jl`, the accepted capability
  reference still includes geometry parity, missing-length warnings,
  annotation-table preparation, and the reopened `preorder` mutation seam as a
  historical behavior reference. Those semantics must survive, but their legacy
  public names do not.
- From `PhyloPlots.jl/src/plotRCall.jl`, the legacy keyword shell remains
  capability reference material only. It is not an authority for the final
  user-facing API shape or the accepted internal runtime carrier.

## Primary-goal lock

### Lock item 1: Compatibility shell retirement

- The work is not complete if loading `PhyloMakie` still includes or defines
  `src/keyword_contract.jl`, `src/keyword_normalization.jl`,
  `PlotKeywordSpec`, or `normalize_plot_keywords` on the accepted runtime path.
- The direct red-state repro is the current repository state:
  `src/PhyloMakie.jl` still includes the keyword files, and the loaded module
  still defines `PlotKeywordSpec` and `normalize_plot_keywords`.
- The tasks that close this are task 1 and task 3.
- The verification artifact is the final shell-owner and verification-foundation
  proof surface that requires those includes and symbols to be absent and fails
  the current repository state.

### Lock item 2: Single public-owner continuity during cleanup

- The work is not complete if `plot(net)`, `plot!(ax, net)`, `phyloplot`, and
  `phyloplot!` stop sharing one semantic owner while the cleanup runs, or if
  any of those surfaces still routes through a compatibility-only semantic
  center.
- The direct red-state repro is the current repository state:
  `src/public_plot_owner.jl` still resolves the public surface through a local
  `PlotKeywordSpec` bridge before the helper and render owners run.
- The tasks that close this are task 1 and task 2.
- The verification artifact is direct public-surface proof that the returned
  plot stores the canonical `PhyloPlotAttributes` payload and that all four
  supported surfaces remain visually and semantically aligned.

### Lock item 3: Layout and annotation invariants survive the owner migration

- The work is not complete if geometry parity, missing-length warnings,
  caller-owned mutation isolation, helper bounds messages, or annotation-table
  preparation drift while the runtime carrier changes.
- The direct red-state repro is the current helper regression corpus in
  `test/test_layout_engine.jl`, `test/test_annotation_data.jl`, and
  `FIXTURE_CORPUS`.
- The tasks that close this are task 1 and task 2.
- The verification artifact is the migrated helper regression corpus using the
  Makie-native payload, with direct failure on the current repository state
  because the helper owners still accept only `PlotKeywordSpec`.

### Lock item 4: Render invariants and Makie host semantics survive the owner migration

- The work is not complete if `render_plot!` gains a second semantic carrier,
  if bang versus non-bang Makie semantics drift, or if the CairoMakie-backed
  render proof collapses to weaker non-visual proxies.
- The direct red-state repro is the current render owner corpus and the Makie
  source contracts recorded in the tranche-4 source-set note.
- The tasks that close this are task 1 and task 2.
- The verification artifact is the migrated render regression suite plus live
  docs and public plotting artifacts that still exercise `Makie.colorbuffer`
  under CairoMakie and fail if a shadow owner or host-contract drift appears.

### Lock item 5: Verification metadata and shell tests reject compatibility-shell regrowth

- The work is not complete if the repository can still go green while
  `VERIFICATION_FOUNDATION`, shell-owner tests, or suite inventory continue to
  accept a `compatibility_keyword_bridge` owner or keyword-file module includes.
- The direct red-state repro is the current repository state:
  `src/verification_foundation.jl` still exposes
  `compatibility_keyword_bridge`, and `test/test_PhyloMakie.jl` still requires
  `keyword_contract.jl` and `keyword_normalization.jl` in the module shell.
- The task that closes this is task 3.
- The verification artifact is the final test surface that removes the bridge
  field, removes the keyword include requirements, and fails the current
  repository state directly.

### Lock item 6: Docs truth surfaces no longer teach or require the compatibility shell

- The work is not complete if `docs/src/index.md`,
  `docs/src/verification-foundation.md`, or `docs/src/render-verification.md`
  still present `PlotKeywordSpec`, `normalize_plot_keywords`, or the
  compatibility bridge as accepted live architecture.
- The direct red-state repro is the current docs surface:
  `index.md` and `verification-foundation.md` still name the compatibility
  bridge explicitly, and `render-verification.md` still executes internal proof
  through `normalize_plot_keywords`.
- The tasks that close this are task 2 and task 3.
- The verification artifact is the docs build plus live example blocks that
  use the Makie-native payload or public surface directly and fail the current
  repository state.

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
  - `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md`
  - `.workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md`
  - `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-06_tranche-05--tasking-1.md`
  - `.workflow-docs/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`
- **Settled decisions and non-negotiables**:
  - keep the tranche-5 public API exactly as implemented
  - keep one Makie-native public plot owner
  - keep `PhyloPlotAttributes` as the sole accepted runtime carrier after this tranche
  - keep caller-owned network non-mutation on public surfaces
  - do not reopen legacy public names or `preorder`
  - do not change dependency policy or docs truth boundary
- **Authorization boundary**:
  - deep internal redesign is authorized
  - public API redesign is not reopened here
  - capability loss is not authorized
  - deletion of compatibility-runtime files and proof surfaces is authorized
- **Current-state diagnosis**:
  - tranche 5 closed the public owner correctly
  - compatibility-first runtime payloads still survive inside the module shell,
    helper/render owners, tests, docs, and verification metadata
- **Primary-goal lock**:
  - lock items 1 through 6 above
- **Direct red-state repros**:
  - `src/PhyloMakie.jl` still includes `keyword_contract.jl` and `keyword_normalization.jl`
  - helper/render owners still type on `PlotKeywordSpec`
  - docs and verification metadata still expose a `compatibility_keyword_bridge`
- **Owner and invariant under repair**:
  - repair the runtime semantic carrier and truth surface
  - preserve the existing layout, annotation, render, and public-owner invariants
- **Supported public surfaces affected by this owner change**:
  - `plot(net)` migrates in task 1 and is re-proved in task 2
  - `plot!(ax, net)` migrates in task 1 and is re-proved in task 2
  - `phyloplot` migrates in task 1 and is re-proved in task 2
  - `phyloplot!` migrates in task 1 and is re-proved in task 2
- **Exact files or surfaces in scope**:
  - `src/public_attribute_model.jl`
  - `src/public_plot_owner.jl`
  - `src/layout_engine.jl`
  - `src/annotation_data.jl`
  - `src/render_adapter.jl`
  - `src/PhyloMakie.jl`
  - `src/verification_foundation.jl`
  - helper, render, public-owner, shell-owner, and verification-foundation tests
  - `docs/src/index.md`
  - `docs/src/public-api.md`
  - `docs/src/render-verification.md`
  - `docs/src/verification-foundation.md`
- **Exact files or surfaces out of scope**:
  - final migration guide
  - legacy capability-mapping prose beyond truth-surface cleanup
  - non-`HybridNetwork` public support
  - dependency or manifest changes
- **Required upstream primary sources**:
  - the upstream sources listed above
- **Green-state gates**:
  - `julia --project=. -e 'using Makie'`
  - `julia --project=test -e 'using CairoMakie; using Makie'`
  - `julia --project=docs -e 'using CairoMakie; using Makie'`
  - `julia --project=test test/runtests.jl`
  - `julia --project=docs docs/make.jl`
- **Stop conditions**:
  - stop if keeping helper or render invariants green would require a second
    semantic carrier or a shadow compatibility wrapper
  - stop if preserving public proof would require reopening legacy public names
    or `preorder`
  - stop if the only way to keep docs green is to replace live CairoMakie
    artifacts with source-text, Markdown-string, or YAML policing

## Required revalidation before implementation

- Read the tranche and parent PRD in full.
- Read `.workflow-docs/202605090307_phylomakie-makie-rebuild/03-06_tranche-05--tasking-1.md`
  and the current tranche-5 implementation files in full.
- Read the relevant code, tests, docs, and examples in full, including every
  current `PlotKeywordSpec` and `normalize_plot_keywords` consumer.
- Read all cited upstream primary sources in full where they constrain the work.
- Re-check that the authorized disruption boundary still allows file deletion
  and payload realignment but does not reopen the tranche-5 public API.
- Re-run the green-state gates before and after the tranche.
- If the diagnosis no longer matches reality, stop and raise that before
  changing code.

## Tranche execution rule

This tranche may redesign the internal runtime carrier and delete compatibility
artifacts, but it must preserve the implemented tranche-5 public API, Makie
host semantics, helper invariants, render invariants, and public proof surface.

When the tranche is complete:

- `PhyloPlotAttributes` remains as the runtime semantic carrier.
- `PlotKeywordSpec`, `normalize_plot_keywords`, `keyword_contract.jl`, and
  `keyword_normalization.jl` no longer exist on the accepted runtime path.
- layout and render owners still own geometry, annotations, and primitive
  composition directly.
- docs and verification metadata tell the post-tranche-6 truth.

Docs must be brought into truth with the current API and runtime architecture.
Do not change the accepted public API to satisfy stale internal docs examples.

## Non-negotiable execution rules

- Do not recreate retired owners through compatibility fallbacks, shadow
  wrappers, or test-only normalization helpers.
- Do not move `PlotKeywordSpec` or `normalize_plot_keywords` under a new name
  and call that retirement.
- Do not reintroduce legacy public spellings or `preorder` on the public
  surface.
- Do not fork wrapper semantics away from the Makie recipe owner.
- Do not reimplement geometry, bounds, annotation placement, or primitive
  composition in the public owner or docs helpers.
- Do not solve docs drift by weakening live proof or replacing it with
  source-text audits.
- Do not change dependency declarations, manifests, or path overrides.

## Concrete anti-patterns or removal targets

- `src/keyword_contract.jl`
- `src/keyword_normalization.jl`
- `PlotKeywordLayout`
- `PlotKeywordVisibility`
- `PlotKeywordAnnotations`
- `PlotKeywordColors`
- `PlotKeywordStrokes`
- `PlotKeywordSpec`
- `normalize_plot_keywords`
- `bridge_phylo_plot_attributes(attributes; x_limits, y_limits)::PlotKeywordSpec`
- `test/test_keyword_contract.jl`
- `test/test_keyword_normalization.jl`
- `test/support/keyword_surface_cases.jl` as a compatibility-first support file
- `FIXTURE_CORPUS` fields named `keyword_args`
- helper-bounds message expectations that still use `xlim` and `ylim`
- docs or verification metadata that still expose `compatibility_keyword_bridge`
- any partial migration where `plot(net)` uses `PhyloPlotAttributes` but helper,
  render, docs, or verification proof still depends on a shadow
  `PlotKeywordSpec` path

## Failure-oriented verification

- Loading `PhyloMakie` must fail the old repository state by proving that
  `PlotKeywordSpec` and `normalize_plot_keywords` are absent at tranche end.
- Shell-owner proof must fail the old repository state by requiring
  `src/PhyloMakie.jl` to exclude `keyword_contract.jl` and
  `keyword_normalization.jl`.
- Public plotting tests must fail any implementation where the returned plot
  lacks a live `resolved_attributes` artifact carrying `PhyloPlotAttributes`.
- Helper and render tests must fail if `prepare_plot_layout` or `render_plot!`
  still requires `PlotKeywordSpec`.
- Helper-bounds tests and public-limit tests must fail if error messages still
  use `xlim` or `ylim` instead of `x_limits` or `y_limits`.
- Render-verification docs must fail the current repository state because they
  no longer call `normalize_plot_keywords` or use legacy keyword spellings in
  live proof blocks.
- Verification-foundation tests must fail the current repository state by
  requiring `propertynames(VERIFICATION_FOUNDATION)` to exclude
  `:compatibility_keyword_bridge`.
- The suite must fail any fake fix where compatibility logic survives only in
  test support, docs setup code, or a renamed internal helper.

Positive runtime and usability checks required for honest tranche-6 closure:

- `plot(net)`, `plot!(ax, net)`, `phyloplot`, and `phyloplot!` remain green.
- The dual-axis composition proof remains green.
- The caller-owned network mutation boundary remains green.
- The helper and render regression corpora remain green.
- `docs/src/render-verification.md` still builds live CairoMakie artifacts
  after the compatibility shell is gone.

## Tasks

### 1. Move the live runtime path onto `PhyloPlotAttributes`

**Type**: WRITE
**Output**: `PhyloPlotAttributes` is the canonical runtime payload for the
public owner, layout engine, annotation owner, and render adapter; the public
plotting path no longer constructs or passes `PlotKeywordSpec`.
**Depends on**: none

Update `src/public_attribute_model.jl`, `src/layout_engine.jl`,
`src/annotation_data.jl`, `src/render_adapter.jl`, and
`src/public_plot_owner.jl` so the end-to-end runtime carrier is
`PhyloPlotAttributes` rather than `PlotKeywordSpec`. Replace legacy field
accesses with the implemented public names:
`use_edge_lengths`, `show_tip_labels`, `show_internal_node_names`,
`show_node_numbers`, `show_edge_lengths`, `show_edge_numbers`,
`show_gamma`, `edge_color`, `default_edge_color`,
`major_hybrid_edge_color`, `minor_hybrid_edge_color`, `edge_width`,
`minor_edge_linestyle`, `minor_edge_arrow_length`, `node_annotations`,
`edge_annotations`, `node_annotation_scale`, `edge_annotation_scale`,
`node_annotation_color`, `edge_annotation_color`,
`node_annotation_align`, `edge_annotation_align`, `tip_label_offset`,
`tip_label_scale`, `x_limits`, `y_limits`, and `style`. Keep the internal
traversal policy explicit and internal-only by adding a `preorder::Bool=true`
keyword to `layout_plot_geometry` and `prepare_plot_layout`, and by having
`Makie.plot!(plot::PhyloPlot)` call those helper entrypoints with
`preorder=true` on the deepcopy-owned network. Do not reopen public
`preorder`. Update the helper-owned bounds messages to the
public names `x_limits` and `y_limits`, remove the public-owner name-rewrite
shim once the helper owner speaks the final names directly, and store the
canonical runtime payload on returned public plots as
`plot[:resolved_attributes]`. All four supported public surfaces
`plot(net)`, `plot!(ax, net)`, `phyloplot`, and `phyloplot!` migrate in this
task. The helper/render proof surfaces and docs examples that still call
`normalize_plot_keywords` are intentionally deferred to task 2, and physical
file deletion is intentionally deferred to task 3.

**Positive contract**: One Makie-native runtime payload owns the live public
semantics end to end, and the returned public plot proves which payload the
owner actually consumed.
**Negative contract**: Do not keep `PlotKeywordSpec` on the live public path.
Do not duplicate layout or render logic. Do not reintroduce public `preorder`
or legacy public names. Until task 3 deletes the compatibility files,
`normalize_plot_keywords` may survive only as an internal shim that returns or
constructs `PhyloPlotAttributes` and that no public surface consumes.
**Files**:
- `src/public_attribute_model.jl`
- `src/layout_engine.jl`
- `src/annotation_data.jl`
- `src/render_adapter.jl`
- `src/public_plot_owner.jl`
- `test/test_public_attribute_model.jl`
- `test/test_public_plot_owner.jl`
**Out of scope**:
- deleting `src/keyword_contract.jl`
- deleting `src/keyword_normalization.jl`
- helper/render proof-surface migration
- verification-foundation truth-surface rewrite
- final docs cleanup beyond what is required to keep the docs build green
**Verification**:
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- Direct public proof that `Makie.to_value(plot[:resolved_attributes])`
  carries `PhyloPlotAttributes` and fails the current repository state
- Direct public-limit proof that the helper-owned bound messages now use
  `x_limits` and `y_limits`

### 2. Rebase helper, render, and docs proof surfaces on the Makie-native payload

**Type**: TEST
**Output**: Helper regressions, render regressions, shared fixtures, and
`render-verification.md` all exercise the final runtime payload and public
spellings without calling `normalize_plot_keywords` or checking `PlotKeywordSpec`.
**Depends on**: 1

Update `test/support/render_test_helpers.jl`, `test/test_layout_engine.jl`,
`test/test_annotation_data.jl`, `test/test_render_adapter.jl`,
`test/test_public_attribute_model.jl`, `test/test_public_plot_owner.jl`,
`test/support/fixture_corpus.jl`, and `docs/src/render-verification.md`. Move
the helper/render proof surfaces off `normalize_plot_keywords` and onto
`resolve_phylo_plot_attributes`. Rename fixture fields currently called
`keyword_args` to `attribute_kwargs` in the layout and render regression
corpus. Update all helper and render examples to use the public spellings
`use_edge_lengths`, `show_internal_node_names`, `show_node_numbers`,
`show_edge_lengths`, `show_edge_numbers`, `show_gamma`, `node_annotations`,
`edge_annotations`, `tip_label_scale`, `edge_color`, `default_edge_color`,
`x_limits`, and `y_limits`. Keep the helper and render proof at the same
contract boundary: geometry parity, missing-length warnings, annotation-table
preparation, render-layer typing, CairoMakie colorbuffer artifacts, and
multi-surface public-owner integration must all remain directly provable.
Do not create a new test-only normalization layer; if an internal helper is
needed, it must live in production code and use the same runtime payload as the
public owner.

**Positive contract**: Every live proof surface below the final public API now
uses the same Makie-native runtime payload and naming that the accepted
architecture uses.
**Negative contract**: Do not keep `keyword_args` fixtures, `normalize_plot_keywords`,
or `PlotKeywordSpec` alive as proof-only shims. Do not move layout or render
policy into test helpers. Do not replace live CairoMakie artifacts with
source-text or Markdown-string assertions.
**Files**:
- `test/support/render_test_helpers.jl`
- `test/test_layout_engine.jl`
- `test/test_annotation_data.jl`
- `test/test_render_adapter.jl`
- `test/test_public_attribute_model.jl`
- `test/test_public_plot_owner.jl`
- `test/support/fixture_corpus.jl`
- `docs/src/render-verification.md`
**Out of scope**:
- deleting compatibility-runtime files
- shell-owner include cleanup
- `src/verification_foundation.jl`
- final docs home-page and verification-foundation rewrite
**Verification**:
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- Direct failure of the current repository state because helper and render
  proof surfaces no longer match `prepare_plot_layout` and `render_plot!`
  if they still require `PlotKeywordSpec`
- Direct failure if helper-bounds or render docs still use `xlim`, `ylim`,
  `nodelabel`, `edgelabel`, `edgecolor`, or `tipcex`

### 3. Delete the compatibility shell and rewrite the source-backed truth surface

**Type**: MIGRATE
**Output**: The default runtime, test suite, docs truth surface, and source-backed
verification metadata no longer expose `keyword_contract.jl`,
`keyword_normalization.jl`, `PlotKeywordSpec`, `normalize_plot_keywords`, or a
`compatibility_keyword_bridge`.
**Depends on**: 2

Remove `include("keyword_contract.jl")` and
`include("keyword_normalization.jl")` from `src/PhyloMakie.jl`, then delete
`src/keyword_contract.jl` and `src/keyword_normalization.jl`. Delete
`test/test_keyword_contract.jl` and `test/test_keyword_normalization.jl`.
Rename `test/support/keyword_surface_cases.jl` to
`test/support/public_surface_cases.jl`, update `test/runtests.jl`, and remove
the compatibility-only constants
`EXPECTED_SUPPORTED_PLOT_KEYWORDS`, `EXPECTED_PLOT_KEYWORD_SPEC_FIELDS`, and
`EXPECTED_DEFERRED_PLOT_CONTRACT_IDS`. Keep only the public-surface and
legacy-rejection constants that still matter after the shell is gone. Update
`test/test_PhyloMakie.jl` so the shell-owner proof now requires the final
module include inventory and directly requires that `PlotKeywordSpec` and
`normalize_plot_keywords` are not defined. Rewrite
`src/verification_foundation.jl` and `test/test_verification_foundation.jl` so
`VERIFICATION_FOUNDATION` exposes the final four-owner architecture:
`public_attribute_owner`, `layout_annotation_owner`, `render_owner`, and
`public_plot_owner`, with no `compatibility_keyword_bridge` field. Update
`docs/src/index.md`, `docs/src/public-api.md`, and
`docs/src/verification-foundation.md` so they describe the final tranche-6
truth: the runtime carrier is `PhyloPlotAttributes`, the helper and render
owners consume it directly, the public surface still rejects legacy names, and
no compatibility shell survives in the accepted package architecture. Keep the
final migration guide and capability-mapping narrative out of scope; only bring
the current docs truth surface into alignment with the implemented architecture.

**Positive contract**: Loading `PhyloMakie`, running the suite, and building the
docs all prove the same post-tranche-6 architecture, and none of them require
or describe a compatibility shell.
**Negative contract**: Do not keep dead compatibility files in the repo. Do not
move them under a new name. Do not preserve a test-only or docs-only semantic
carrier after deleting the runtime one. Do not reopen public API design or
tranche-7 migration work.
**Files**:
- `src/PhyloMakie.jl`
- `src/keyword_contract.jl`
- `src/keyword_normalization.jl`
- `src/verification_foundation.jl`
- `test/runtests.jl`
- `test/test_PhyloMakie.jl`
- `test/test_keyword_contract.jl`
- `test/test_keyword_normalization.jl`
- `test/test_verification_foundation.jl`
- `test/support/keyword_surface_cases.jl`
- `test/support/public_surface_cases.jl`
- `docs/src/index.md`
- `docs/src/public-api.md`
- `docs/src/verification-foundation.md`
**Out of scope**:
- the tranche-7 migration guide
- broader docs narrative expansion beyond truth-surface alignment
- non-`HybridNetwork` public support
- dependency changes
**Verification**:
- `julia --project=. -e 'using Makie'`
- `julia --project=test -e 'using CairoMakie; using Makie'`
- `julia --project=docs -e 'using CairoMakie; using Makie'`
- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`
- Direct shell-owner proof that `!isdefined(PhyloMakie, :PlotKeywordSpec)` and
  `!isdefined(PhyloMakie, :normalize_plot_keywords)` hold and fail the current
  repository state
- Direct verification-foundation proof that
  `propertynames(VERIFICATION_FOUNDATION)` excludes
  `:compatibility_keyword_bridge` and fails the current repository state
