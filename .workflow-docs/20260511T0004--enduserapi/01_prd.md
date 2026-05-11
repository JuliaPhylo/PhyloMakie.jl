---
date-created: 2026-05-11T00:38:07
workflow-instrument: PRD
workflow-status: Approved
workflow-agent-thread-id: codex/019e15e4-4295-7a21-9f88-b3f615b795d0
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: crimson-cedar-bridge
---

# PRD: End-user API keyword restoration

## User statement

From `00_developer-brief.md`:

> Refactor current API cleanly, with no legacy or migration support of any kind.

Confirmed user clarifications on 2026-05-11:

- The right-hand names in the brief are the new canonical public API names.
- The current snake_case public names must be removed from the public API, not
  retained as aliases, deprecated names, or migration-supported spellings.
- "No migration support" means do not add any legacy migration support for the
  current API. Do not mention the current API in docs or as a legacy artifact.
- The current migration table or layer may become redundant, but it must not be
  the focus or center of the work. The brief is centered on renaming the API:
  old name to new name. The table or code associated with it may be changed or 
  removed if it blocks or interferes the rename. If the table becomes 
  redundant you may note once the codebase reaches the state.
- The supported plotting entry surfaces remain fixed: `plot(net)`,
  `plot!(ax, net)`, `phyloplot(net)`, and `phyloplot!(ax, net)`.
- `style` remains the public style attribute for `:fulltree` and `:majortree`.
- `preorder` remains internal and unsupported unless explicitly authorized in a
  later workflow.
- `edgenumbercolor` remains unsupported unless explicitly authorized in a later
  workflow.
- Update `STYLE-vocabulary.md` so the compact names become
  canonical PhyloMakie API names.

The confirmed rename map is:

| Current implementation name | New canonical public name |
| --- | --- |
| `use_edge_lengths` | `useedgelength` |
| `show_tip_labels` | `showtiplabel` |
| `show_internal_node_names` | `shownodelabel` |
| `show_node_numbers` | `shownodenumber` |
| `show_edge_lengths` | `showedgelength` |
| `show_edge_numbers` | `showedgenumber` |
| `show_gamma` | `showgamma` |
| `edge_color` | `edgecolor` |
| `default_edge_color` | `defaultedgecolor` |
| `major_hybrid_edge_color` | `majorhybridedgecolor` |
| `minor_hybrid_edge_color` | `minorhybridedgecolor` |
| `edge_width` | `edgewidth` |
| `minor_edge_linestyle` | `minorlinetype` |
| `minor_edge_arrow_length` | `arrowlen` |
| `node_annotations` | `nodelabel` |
| `edge_annotations` | `edgelabel` |
| `node_annotation_scale` | `nodecex` |
| `edge_annotation_scale` | `edgecex` |
| `node_annotation_color` | `nodelabelcolor` |
| `edge_annotation_color` | `edgelabelcolor` |
| `node_annotation_align` | `nodelabeladj` |
| `edge_annotation_align` | `edgelabeladj` |
| `tip_label_offset` | `tipoffset` |
| `tip_label_scale` | `tipcex` |
| `x_limits` | `xlim` |
| `y_limits` | `ylim` |

## Problem statement

PhyloMakie currently has a functional Makie-native plotting architecture for
`PhyloNetworks.HybridNetwork`, with a public plot owner, an internal attribute
carrier, a layout engine, an annotation data owner, and a render adapter.

The user-facing problem is that the public keyword names do not match the
desired end-user API. The current docs and tests teach snake_case names as the
supported API, while the user now wants the compact names in the developer brief
to become canonical.

The architectural problem is that the current public attribute names are
encoded in several ownership layers:

- `src/public_attribute_model.jl` owns the supported attribute list, attribute
  carrier fields, defaults, normalization, and limit replacement.
- `src/public_plot_owner.jl` owns the Makie recipe attribute block and forwards
  plot attributes into the attribute model.
- `src/layout_engine.jl`, `src/annotation_data.jl`, and
  `src/render_adapter.jl` consume those attribute fields.
- `test/support/public_surface_cases.jl`, public API tests, render tests, docs,
  and README examples assert or teach the current public names.
- `STYLE-vocabulary.md` currently describes the compact names as legacy or
  non-canonical for this project.

The old and new names cannot coexist as supported public surfaces. Keeping both
would create a compatibility layer, reopen the API-mimicry problem from the
closed production workflow, and violate the user's instruction that this work is
the rename itself rather than migration support.

## Target outcome

When the work is complete, PhyloMakie exposes the same plotting capabilities and
the same fixed entry surfaces, but the canonical public attributes are the
compact names from the developer brief.

The target public surfaces are:

- `plot(net; attrs...)`
- `plot!(ax, net; attrs...)`
- `phyloplot(net; attrs...)`
- `phyloplot!(ax, net; attrs...)`

The target attribute set is exactly:

- `useedgelength`
- `showtiplabel`
- `shownodelabel`
- `shownodenumber`
- `showedgelength`
- `showedgenumber`
- `showgamma`
- `edgecolor`
- `defaultedgecolor`
- `majorhybridedgecolor`
- `minorhybridedgecolor`
- `edgewidth`
- `minorlinetype`
- `arrowlen`
- `nodelabel`
- `edgelabel`
- `nodecex`
- `edgecex`
- `nodelabelcolor`
- `edgelabelcolor`
- `nodelabeladj`
- `edgelabeladj`
- `tipoffset`
- `tipcex`
- `xlim`
- `ylim`
- `style`

The work must not:

- change the supported plotting entry surfaces
- add aliases for the current snake_case names
- add deprecation handling or migration documentation for the current API
- make the current API an end-user legacy story
- add support for `preorder`
- add support for `edgenumbercolor`
- change layout, annotation, rendering, return-type, or Makie bang/non-bang
  behavior except as required to consume the renamed attributes

## Primary-goal lock

### Lock item 1: canonical attribute set

- The work is not complete if `Makie.attribute_names(PhyloPlot)` or
  `SUPPORTED_PHYLOPLOT_ATTRIBUTES` still exposes any current snake_case public
  attribute name.
- The direct red-state repro is the current implementation:
  `SUPPORTED_PHYLOPLOT_ATTRIBUTES` and the `Makie.@recipe PhyloPlot` block list
  names such as `use_edge_lengths`, `show_tip_labels`, `edge_annotations`,
  `tip_label_offset`, `x_limits`, and `y_limits`.
- The owner expected to close this is the public attribute model and public plot
  owner tranche family.
- The verification artifact must assert the exact canonical attribute set above
  against both `SUPPORTED_PHYLOPLOT_ATTRIBUTES` and
  `Makie.attribute_names(PhyloPlot)`.

### Lock item 2: no supported old-name aliases

- The work is not complete if any current snake_case public attribute name is
  accepted as an alias, deprecated name, compatibility spelling, or migration
  spelling.
- The direct red-state repro is the current public surface, where calls such as
  `plot(net; show_tip_labels = true)` are accepted.
- The owner expected to close this is the public plot owner and public attribute
  model tranche family.
- The verification artifact must include negative public API tests proving that
  representative current names are rejected at the Makie recipe boundary or
  equivalent public entry boundary.

### Lock item 3: no current-API migration story in user docs

- The work is not complete if README or docs teach, map, deprecate, explain, or
  otherwise mention the current snake_case API as an end-user legacy artifact.
- The direct red-state repro is the current docs and README, which contain a
  migration guide and describe rejected spellings and current snake_case names as
  the public attribute surface.
- The owner expected to close this is the docs tranche family.
- The verification artifact must include a docs build plus source audits over
  `README.md` and `docs/src/` showing that end-user docs use the canonical names
  and do not contain current-API migration framing.

### Lock item 4: capability parity survives the rename

- The work is not complete if any accepted plotting capability regresses while
  the attributes are renamed.
- The direct red-state repro is any green rename that only updates attribute
  names but breaks full-tree style, major-tree style, edge-length scaling, gamma
  labels, node labels, edge labels, edge colors, edge widths, custom limits, or
  dual-axis composition.
- The owner expected to close this is the public attribute model, layout engine,
  annotation data, render adapter, and public plot owner tranche family.
- The verification artifact must translate existing layout, annotation, render,
  and public plotting tests to the canonical names and keep the same direct
  behavioral proofs green.

### Lock item 5: fixed plotting entry surfaces and Makie semantics

- The work is not complete if the rename changes the supported entry surfaces,
  weakens `plot` versus `plot!` behavior, changes `FigureAxisPlot` returns, or
  makes `phyloplot` or `phyloplot!` own independent semantics.
- The direct red-state repro is any implementation that treats the API rename as
  authorization to redesign entrypoints or wrapper ownership.
- The owner expected to close this is the public plot owner tranche family.
- The verification artifact must keep direct public tests for `plot(net)`,
  `plot!(ax, net)`, `phyloplot(net)`, and `phyloplot!(ax, net)` with the renamed
  attributes.

### Lock item 6: unsupported controls remain unsupported

- The work is not complete if `preorder` or `edgenumbercolor` becomes public
  merely because the compact names are being restored.
- The direct red-state repro is a broadened attribute set that includes either
  name without explicit user authorization.
- The owner expected to close this is the public attribute model and public plot
  owner tranche family.
- The verification artifact must prove that `preorder` and `edgenumbercolor` are
  absent from `Makie.attribute_names(PhyloPlot)` and the supported attribute
  constant.

### Lock item 7: vocabulary realignment

- The work is not complete if project vocabulary still describes the compact
  names as legacy, rejected, or non-canonical after they become the public API.
- The direct red-state repro is the current `STYLE-vocabulary.md`, which defines
  the current snake_case names as the public attribute surface and the compact
  names as legacy keyword surface material.
- The owner expected to close this is the vocabulary and docs tranche family.
- The verification artifact must update `STYLE-vocabulary.md` and require
  downstream documents to read it line by line before implementation.

## User stories

1. As a PhyloMakie user, I can call `plot(net; useedgelength = true)` and get
   edge-length-aware layout.
2. As a PhyloMakie user, I can call `plot(net; showtiplabel = true)` and see tip
   labels without using the current snake_case spelling.
3. As a PhyloMakie user, I can call `plot(net; shownodelabel = true)` and show
   internal node names.
4. As a PhyloMakie user, I can call `plot(net; shownodenumber = true)` and show
   node numbers.
5. As a PhyloMakie user, I can call `plot(net; showedgelength = true)` and show
   edge lengths.
6. As a PhyloMakie user, I can call `plot(net; showedgenumber = true)` and show
   edge numbers with the existing render-owner default color policy.
7. As a PhyloMakie user, I can call `plot(net; showgamma = true)` and see gamma
   labels for hybrid edges.
8. As a PhyloMakie user, I can control edge color, default edge color, major
   hybrid edge color, minor hybrid edge color, and edge width with `edgecolor`,
   `defaultedgecolor`, `majorhybridedgecolor`, `minorhybridedgecolor`, and
   `edgewidth`.
9. As a PhyloMakie user, I can control minor hybrid edge style and arrow length
   with `minorlinetype` and `arrowlen`.
10. As a PhyloMakie user, I can provide node and edge annotation data frames with
    `nodelabel` and `edgelabel`.
11. As a PhyloMakie user, I can control annotation text size, color, and
    alignment with `nodecex`, `edgecex`, `nodelabelcolor`, `edgelabelcolor`,
    `nodelabeladj`, and `edgelabeladj`.
12. As a PhyloMakie user, I can control tip label offset and scale with
    `tipoffset` and `tipcex`.
13. As a PhyloMakie user, I can set plot limits with `xlim` and `ylim`.
14. As a Makie user, I can still call `plot(net)` and receive a
    `Makie.FigureAxisPlot`.
15. As a Makie user, I can still call `plot!(ax, net)` and render into an
    existing axis.
16. As a PhyloMakie user, I can still call `phyloplot(net)` and
    `phyloplot!(ax, net)` as thin convenience surfaces over the same plot owner.
17. As a user reading docs, I see only the canonical public API names for the
    current package, not a migration story from the previous current API.
18. As a maintainer, I can inspect one supported attribute set and one attribute
    carrier that use the canonical names consistently.
19. As a maintainer, I can verify that old current names are not accepted through
    any public plotting surface.
20. As a downstream implementer, I can rename the API without changing layout,
    annotation, render, entry-surface, or Makie host-framework semantics.

## Authorized disruption boundary

- Internal redesign allowed:
  - rename public attribute names across the recipe attribute block, supported
    attribute constant, attribute carrier, resolver, helper consumers, tests,
    docs, README, and vocabulary
  - remove or bypass current-name migration or deprecation structures when they
    are redundant after the rename
  - update tests and docs so the canonical names are the only end-user truth
    surface
- Internal redesign forbidden:
  - changing the supported entry surfaces
  - adding a compatibility layer for the current snake_case API
  - making current API migration a docs or runtime product
  - changing layout, annotation, render, or Makie composition behavior beyond the
    attribute rename
  - using cleanup as a reason to add `preorder` or `edgenumbercolor`
- External breaking changes allowed:
  - yes, the current snake_case public names may be removed from the public API
- Required migration or compatibility obligations:
  - no migration support for the current API is required or desired
  - docs must teach the canonical names directly
  - tests must prove rejected current names rather than document a transition
- Non-negotiable protections:
  - preserve the fixed plotting entry surfaces
  - preserve capability parity
  - preserve Makie host-framework semantics
  - preserve caller-owned network protection
  - preserve green-state discipline for each tranche

## Current-state architecture

The current code is organized into useful owners:

- `src/PhyloMakie.jl` is a thin module shell that imports Makie and includes the
  active owner files.
- `src/public_attribute_model.jl` owns supported attribute names, attribute
  defaults, attribute normalization, style normalization, edge color fallback
  policy, edge width validation, data-frame copying, and limit replacement.
- `src/public_plot_owner.jl` owns the `PhyloPlot` Makie recipe, the
  `Makie.plottype(::HybridNetwork)` registration, the public plot execution
  path, and the current deprecation or rejection list for compact names.
- `src/layout_engine.jl` owns node and edge geometry, edge-length fallback
  behavior, traversal preparation on a caller-protecting copy, and full-tree or
  major-tree geometry differences.
- `src/annotation_data.jl` owns node and edge annotation table validation,
  formatted annotation text, plot bounds, and annotation anchor tables.
- `src/render_adapter.jl` owns conversion from resolved attributes and layout
  data into Makie line segment, arrow, text, color, width, and limit operations.
- `README.md` and `docs/src/*.md` currently teach the current snake_case public
  names and migration framing.
- `test/` contains public surface tests, layout tests, annotation tests, render
  tests, and support constants keyed to current names.

Existing failure modes:

- The desired canonical names are currently treated as rejected or deprecated
  attribute names.
- The current snake_case names are accepted through all public plotting entry
  surfaces.
- End-user docs currently teach the current snake_case names.
- `STYLE-vocabulary.md` contradicts the new naming decision.
- The migration table is now implementation baggage rather than a target-state
  owner, but removal is a consequence of the rename and not the product center.

## Target architecture

The target architecture keeps the same owners, but realigns the public attribute
contract.

- Public plot owner:
  - still owns `PhyloPlot`, `Makie.plottype(::HybridNetwork)`, `plot(net)`,
    `plot!(ax, net)`, `phyloplot(net)`, and `phyloplot!(ax, net)`
  - exposes the canonical compact attributes through the Makie recipe
  - rejects current snake_case names as unsupported attributes
- Public attribute model:
  - owns the exact canonical attribute set
  - resolves defaults using canonical names
  - carries runtime values without a current-name compatibility path
- Layout engine:
  - consumes the renamed edge-length and style controls
  - keeps traversal, geometry, bounds, and caller-protection behavior stable
- Annotation data:
  - consumes `nodelabel`, `edgelabel`, `shownodenumber`, `shownodelabel`,
    `showedgelength`, and related canonical names
  - keeps validation and formatting behavior stable
- Render adapter:
  - consumes the canonical names for rendering, styling, text sizing, text
    alignment, gamma labels, and limits
  - keeps primitive composition and render proof behavior stable
- Docs and README:
  - teach canonical names directly
  - do not mention the current API as migration or legacy material
- Controlled vocabulary:
  - updates compact names from legacy terminology to canonical PhyloMakie API
    terminology

### Supported surface matrix

| Semantic | Canonical owner | Supported public surfaces | Verification requirement |
| --- | --- | --- | --- |
| Public attribute names | `public_attribute_model.jl` and `public_plot_owner.jl` | `plot`, `plot!`, `phyloplot`, `phyloplot!` | Exact attribute set tests and negative current-name tests |
| Edge-length placement | Layout engine | All public entry surfaces through `useedgelength` | Layout regression and public render tests |
| Tip labels | Render adapter | All public entry surfaces through `showtiplabel` | Public render or layer tests |
| Node and edge labels | Annotation data and render adapter | All public entry surfaces through `nodelabel`, `edgelabel`, and related controls | Annotation table and render tests |
| Colors and widths | Public attribute model and render adapter | All public entry surfaces through color and width controls | Render adapter and public plot tests |
| Limits | Public plot owner and render adapter | All public entry surfaces through `xlim` and `ylim` | Direct `Makie.data_limits` tests |
| Entry-surface behavior | Public plot owner | `plot`, `plot!`, `phyloplot`, `phyloplot!` | Return-type, composition, and caller-owned network tests |

## Implementation decisions

- The compact names from the developer brief are canonical, not legacy.
- The current snake_case names are current implementation names only. They must
  not remain accepted, documented, or described as migration inputs.
- `style` remains unchanged because it is not part of the rename map and already
  owns the `:fulltree` and `:majortree` surface cleanly.
- The entry surfaces are fixed and are not being reconsidered by this workflow.
- `preorder` remains internal. Adding it would reopen the traversal and
  caller-mutation boundary and is out of scope.
- `edgenumbercolor` remains unsupported. Adding it would be a small exposed
  parameter addition rather than a rearchitecture, but it is not part of this
  rename.
- The internal attribute carrier should move toward canonical names rather than
  maintaining a translation layer from current names to compact names.
- Any removal of the existing migration table is subordinate to the rename. It
  is not a standalone migration-cleanup goal.
- The docs truth surface must be updated to the canonical API directly.
- The vocabulary file must be updated before downstream implementation relies on
  the compact names as project terminology.

## Module design

### Public attribute model

- **Name**: `src/public_attribute_model.jl`
- **Public surfaces**: `SUPPORTED_PHYLOPLOT_ATTRIBUTES`, the plot recipe
  attribute surface, `resolve_phylo_plot_attributes`, attribute payload fields,
  error messages, and tests that inspect supported attributes.
- **Responsibility**: Own the canonical public attribute set, defaults,
  validation, normalization, and attribute payload.
- **Interface**: Keyword-only resolver with canonical names; `PhyloPlotAttributes`
  carrying the resolved values; helper functions for style, colors, widths, data
  frames, and limits.
- **Tested**: yes. Tests must assert exact canonical names, default values,
  data-frame ownership, style-dependent defaults, color and width policy, and
  negative rejection of representative current names.

### Public plot owner

- **Name**: `src/public_plot_owner.jl`
- **Public surfaces**: `PhyloPlot`, `Makie.plottype(::HybridNetwork)`,
  `plot(net)`, `plot!(ax, net)`, `phyloplot(net)`, and `phyloplot!(ax, net)`.
- **Responsibility**: Own the Makie recipe, fixed public entry surfaces, public
  plotting execution path, limit validation, and forwarding into layout and
  render owners.
- **Interface**: Makie recipe attributes with canonical names; `Makie.plot!`
  specialization for `PhyloPlot`.
- **Tested**: yes. Tests must prove return contracts, mutating and non-mutating
  behavior, wrapper parity, caller-owned network protection, limit handling, and
  rejection of current names.

### Layout engine

- **Name**: `src/layout_engine.jl`
- **Public surfaces**: all public plotting entry surfaces through the resolved
  attribute carrier.
- **Responsibility**: Compute node, edge, minor hybrid edge, arrow, and bounds
  geometry.
- **Interface**: `layout_plot_geometry(net, attributes; preorder = true)` and
  internal helpers over `PhyloNetworks.HybridNetwork`.
- **Tested**: yes. Tests must remain focused on geometry and edge-length
  behavior after attribute names are translated to canonical names.

### Annotation data

- **Name**: `src/annotation_data.jl`
- **Public surfaces**: node labels, edge labels, node numbers, edge numbers,
  edge lengths, gamma labels, and custom limit behavior through public plotting.
- **Responsibility**: Validate annotation tables, prepare node and edge
  annotation frames, format labels, and compute bounds.
- **Interface**: `prepare_plot_layout(net, attributes; preorder = true)` and
  internal validation helpers.
- **Tested**: yes. Tests must keep warning behavior and prepared table behavior
  green while using canonical names.

### Render adapter

- **Name**: `src/render_adapter.jl`
- **Public surfaces**: rendered output for every public plotting entry surface.
- **Responsibility**: Render edge segments, node bars, minor hybrid edge arrows,
  tip labels, node names, node numbers, node annotations, edge annotations, edge
  lengths, gamma labels, edge numbers, and plot limits.
- **Interface**: `render_plot!(target, net, attributes, layout)`.
- **Tested**: yes. Render tests must keep layer-level and CairoMakie-backed
  public proof green under canonical names.

### Docs and README

- **Name**: `README.md`, `docs/src/index.md`, `docs/src/public-api.md`,
  `docs/src/render-verification.md`, and docs navigation.
- **Public surfaces**: all user-facing examples and rendered docs pages.
- **Responsibility**: Teach the canonical API directly without current-API
  migration framing.
- **Interface**: Documenter pages and README examples.
- **Tested**: yes. `docs/make.jl` must pass, and source audits must reject
  current-API migration framing in user docs.

### Controlled vocabulary

- **Name**: `STYLE-vocabulary.md`
- **Public surfaces**: all downstream workflow docs, implementation plans, tests,
  docs, review notes, and handoffs.
- **Responsibility**: Define compact names as canonical PhyloMakie public API
  names and remove contradictory legacy wording for this production.
- **Interface**: Governance document read line by line downstream.
- **Tested**: review and source audit. It must not contradict the PRD.

## Governance and controlled vocabulary

Downstream tranches and tasks must read these repo-local governance documents
line by line before implementation:

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

The bundled development-policy references are also active when the workflow is
executed through the shared development-policies skill. Several repo-local style
files are byte-identical to bundled references, but repo-local authorities take
priority.

Vocabulary decisions:

- Compact names such as `useedgelength`, `showtiplabel`, `nodelabel`,
  `edgelabel`, `tipoffset`, `xlim`, and `ylim` are canonical PhyloMakie public
  API names for this workflow.
- The current snake_case names are current implementation names, not an
  end-user migration story.
- `public attribute surface` now means the compact-name attribute set listed in
  this PRD.
- Avoid describing the compact names as legacy, deprecated, rejected, or
  migration-only in project-owned docs after this PRD is approved.
- Avoid describing the current snake_case names in user docs after this PRD is
  implemented.

Expected governance files not found:

- repo-local `STYLE-domain-vocabulary.md`
- bundled `CONTRIBUTING.md`
- bundled `STYLE-python.md`
- repo-local `CODE_OF_CONDUCT.md`

The workspace also lacks a `codebases-and-documentation` directory. Relevant
context projects are present as local checkouts in the workspace instead:

- `PhyloPlots.jl`
- `PhyloNetworks.jl`

## Primary upstream references

Downstream work must read these sources line by line where they constrain the
change.

Project authorities and current workflow sources:

- `.workflow-docs/20260511T0004--enduserapi/00_developer-brief.md`
- `.workflow-docs/20260511T0004--enduserapi/01_prd.md`
- `design/prod01-vision.md`
- `design/prod01-vision-supplement.md`
- `.workflow-docs/closed/202605090307_phylomakie-makie-rebuild/01_prd.md`
- `.workflow-docs/closed/202605090307_phylomakie-makie-rebuild/02_tranches.md`
- `.workflow-docs/closed/202605090307_phylomakie-makie-rebuild/05_postmortem.md`
- `.workflow-docs/closed/202605090307_phylomakie-makie-rebuild/04-01_tranche-04--makie-source-set.md`

Current PhyloMakie sources:

- `src/public_attribute_model.jl`
- `src/public_plot_owner.jl`
- `src/layout_engine.jl`
- `src/annotation_data.jl`
- `src/render_adapter.jl`
- `test/support/public_surface_cases.jl`
- `test/support/fixture_corpus.jl`
- `test/test_public_attribute_model.jl`
- `test/test_public_plot_owner.jl`
- `test/test_layout_engine.jl`
- `test/test_annotation_data.jl`
- `test/test_render_adapter.jl`
- `README.md`
- `docs/src/index.md`
- `docs/src/public-api.md`
- `docs/src/migration-guide.md`
- `docs/src/render-verification.md`

Makie-family sources:

- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`
  - recipe generation, `attribute_names`, `deprecated_attributes`, and attribute
    validation
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`
  - `FigureAxisPlot`, non-mutating `plot`, mutating `plot!`, and axis ownership
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`
  - `linesegments!` and text recipe context used by the render adapter
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`
  - `arrows2d!` contract used by the render adapter
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/display.jl`
  - render-capture contract inherited from the source-set note
- `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v/src/screen.jl`
  - CairoMakie render-capture implementation inherited from the source-set note

PhyloPlots sources:

- `PhyloPlots.jl/src/plotRCall.jl`
  - compact keyword names and capability reference
- `PhyloPlots.jl/src/phylonetworksPlots.jl`
  - layout, annotation, and helper behavior reference
- `PhyloPlots.jl/test/test_phylonetworkPlots.jl`
  - helper-level regression cases

PhyloNetworks sources:

- `PhyloNetworks.jl/src/types.jl`
  - `HybridNetwork`, `Node`, `Edge`, `RootMismatch`
- `PhyloNetworks.jl/src/auxiliary.jl`
  - `getroot`, `getparent`, `getchild`, and related graph accessors
- `PhyloNetworks.jl/src/manipulateNet.jl`
  - `directedges!` and `preorder!`
- `PhyloNetworks.jl/src/PhyloNetworks.jl`
  - exported public surface for network functions
- `PhyloNetworks.jl/src/readwrite.jl`
  - `readnewick`

## Tranche gates

Every downstream tranche must begin from a green state and end in a green state.

Required green checks at tranche start and end:

- `julia --project=test test/runtests.jl`
- `julia --project=docs docs/make.jl`

Required verification artifacts:

- exact canonical public attribute set tests
- negative tests that representative current names are unsupported
- direct public tests for `plot`, `plot!`, `phyloplot`, and `phyloplot!`
- layout and annotation regression tests translated to canonical names
- render adapter and CairoMakie-backed public render tests translated to
  canonical names
- docs build with canonical names
- source audit for README and `docs/src/` to ensure no current-API migration
  framing survives
- vocabulary update or vocabulary audit before downstream implementation

If a tranche cannot preserve the fixed entry surfaces, capability parity, and
green-state gates while performing the rename, it must be split or escalated.

## Handoff packet

- **Active authorities**:
  - `CONTRIBUTING.md`
  - all repo-local `STYLE*.md` files listed in governance
  - `00_developer-brief.md`
  - this PRD
  - relevant prior design and closed workflow documents listed above
- **Parent documents**:
  - `00_developer-brief.md`
  - `design/prod01-vision.md`
  - `design/prod01-vision-supplement.md`
  - closed Makie rebuild PRD and tranche plan as current-state context
- **Settled decisions and non-negotiables**:
  - rename the public API attributes to the compact names in the developer brief
  - do not accept current snake_case names as aliases
  - do not document current snake_case names as migration or legacy material
  - keep `plot`, `plot!`, `phyloplot`, and `phyloplot!`
  - keep `style`
  - keep `preorder` and `edgenumbercolor` unsupported
  - keep layout, annotation, render, and Makie host-framework behavior stable
- **Authorization boundary**:
  - external breaking change is authorized for public attribute names
  - entry-surface redesign, migration support, and new feature additions are not
    authorized
- **Current-state diagnosis**:
  - the current package is functional but exposes and documents the wrong
    attribute names for the desired end-user API
  - the desired names are currently treated as rejected compact names
  - vocabulary contradicts the new naming decision
- **Primary-goal lock**:
  - lock items 1 through 7 above
- **Direct red-state repros**:
  - `Makie.attribute_names(PhyloPlot)` contains current snake_case names
  - `plot(net; show_tip_labels = true)` succeeds today
  - `plot(net; showtiplabel = true)` is currently rejected
  - docs currently teach current names and migration framing
  - `STYLE-vocabulary.md` describes compact names as legacy or non-canonical
- **Owner and invariant under repair**:
  - repair the public attribute naming owner while preserving the fixed public
    plotting owner and internal capability invariants
- **Exact files or surfaces in scope**:
  - `src/public_attribute_model.jl`
  - `src/public_plot_owner.jl`
  - `src/layout_engine.jl`
  - `src/annotation_data.jl`
  - `src/render_adapter.jl`
  - tests under `test/`
  - `README.md`
  - `docs/src/`
  - `docs/make.jl` if navigation changes are needed
  - `STYLE-vocabulary.md`
- **Exact files or surfaces out of scope**:
  - entrypoint redesign
  - R interoperability
  - non-`HybridNetwork` input support
  - new `preorder` support
  - new `edgenumbercolor` support
  - migration support for the current API
  - performance tuning unrelated to the rename
- **Required upstream primary sources**:
  - all sources listed under primary upstream references
- **Green-state gates**:
  - full test suite
  - docs build
  - public API negative and positive tests
  - render and layout regression tests
  - docs and vocabulary source audits
- **Stop conditions**:
  - stop if implementing the rename requires changing entry surfaces
  - stop if current names survive as aliases or deprecations
  - stop if docs closure requires mentioning the current API as migration
    material
  - stop if `preorder` or `edgenumbercolor` becomes necessary to complete the
    rename
  - stop if a Makie recipe or attribute-validation contract is unclear and has
    not been revalidated from primary sources
- **Regression expectations**:
  - behavior and rendered capability proofs must remain equivalent except for
    public keyword names

## Testing and verification decisions

The following must stay green throughout:

- package load and shell tests
- public attribute model tests
- layout engine tests
- annotation data tests
- render adapter tests
- public plot owner tests
- Aqua and JET gates
- docs build

Verification must prove the real contract boundary:

- exact public attribute set from Makie recipe metadata
- public entry calls using canonical names
- rejection of representative current names
- stable `Makie.FigureAxisPlot` return contract for non-mutating calls
- stable `PhyloPlot` return contract for mutating calls
- stable caller-owned network behavior
- stable rendered outputs and non-empty CairoMakie buffers
- stable custom limits through `Makie.data_limits`
- no current-API migration framing in README or docs pages

Source audits should include README and docs paths, not closed workflow
documents. Closed workflow documents may keep historical context.

## Out of scope

- Changing `plot`, `plot!`, `phyloplot`, or `phyloplot!`.
- Reopening the Makie-native public plot owner design.
- Adding current snake_case aliases, deprecations, compatibility shims, or
  migration docs.
- Teaching the current API as legacy material in user docs.
- Adding support for `preorder`.
- Adding support for `edgenumbercolor`.
- Adding non-`HybridNetwork` inputs.
- Adding R interoperability.
- Changing capability behavior, render policy, layout algorithm, or annotation
  semantics except where field names must be updated.
- Performance tuning unrelated to the rename.

## Open questions

No blocking open questions remain for this PRD.

If the project owner later wants `edgenumbercolor`, that should be handled as a
separate public-API addition. It is likely a small exposed-parameter thread
through the attribute model, recipe, render adapter, tests, and docs, not a
rearchitecture.

If the project owner later wants `preorder`, that should be handled as a
separate behavior-boundary design. It is not a simple thread-through because it
controls whether PhyloMakie prepares a caller-protected network copy with
`PhyloNetworks.directedges!` and `preorder!`.

## Further notes

This PRD intentionally does not center the existing migration table or rejection
layer. Those structures are relevant only insofar as they currently encode the
opposite of the desired public naming contract. The product goal is the public
API rename itself.

The current snake_case API may appear in workflow documents, code review notes,
tests, and implementation tasks as current-state diagnosis. It must not appear
in end-user docs as a supported, deprecated, legacy, or migrated API once the
rename is implemented.
