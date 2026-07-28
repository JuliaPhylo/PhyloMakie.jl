---
date-created: 2026-07-16T01:34:17-07:00
workflow-instrument: Implementation report
workflow-status: Completed
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-05a
workflow-tasking: .workflow-docs/202606192224_makie-reactivity-architecture/03-05_tranche-05a--tasking-1.md
---

# Implementation report for tranche 5a: Documentation migration and docs-facing audits

## Governance and required reading

This implementation report is a downstream workflow artifact. Any agent or
contributor that uses it for review, audit, Tranche 5b tasking, or final
closeout must read the following governance documents line by line before
acting on it:

- `CONTRIBUTING.md`.
- `STYLE-agent-handoffs.md`.
- `STYLE-agent-language.md`.
- `STYLE-architecture.md`.
- `STYLE-docs.md`.
- `STYLE-git.md`.
- `STYLE-julia.md`.
- `STYLE-makie.md`.
- `STYLE-upstream-contracts.md`.
- `STYLE-verification.md`.
- `STYLE-vocabulary.md`.
- `STYLE-workflow-docs.md`.
- `STYLE-workflow-vocabulary.md`.
- `STYLE-writing.md`.

`STYLE-agent-language.md` is mandatory for any downstream prose that uses
ownership, contract, boundary, layer, invariant, compatibility, verification,
source, or responsibility language. Such prose must name the exact code entity
or external contract, the behavior, the consumers, the duplicate or bypass
paths that must not keep the same responsibility, and the verification artifact.

The active workflow authorities for this report are:

- `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-01_tranche-01--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-02_tranche-02--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-04_tranche-04--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-05_tranche-05a--tasking-1.md`.

The upstream primary sources used by Tranche 5a were:

- `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`.

## Implementation summary

Tranche 5a migrated user-facing documentation and docs-facing audits to the
accepted graph-driven Makie architecture. It did not change runtime behavior,
public plotting entrypoints, public attributes, dependency manifests, pointer
interaction support, or source compatibility files.

Implemented files:

- `docs/src/public-api.md` now documents `plot`, `plot!`, `phyloplot`,
  `phyloplot!`, `PhyloPlot`, the live `SUPPORTED_PHYLOPLOT_ATTRIBUTES` table,
  `Makie.update!(plot; ...)`, `Makie.update!(plot; arg1 = new_net)`, and
  caller-safe `HybridNetwork` preparation.
- `docs/src/render-verification.md` now builds render-verification artifacts
  through public `Makie.plot!` calls and current graph outputs such as
  `plot[:plot_config][]`, `plot[:plot_network][]`,
  `plot[:layout_computation][]`, and `plot[:primitive_channels][]`.
- `docs/src/extending-plots.md` now states that public plots do not expose a
  stable coordinate lookup return value and marks the current computation-layer
  sequence as internal package-development material.
- `test/test_architecture_audits.jl` now scans `docs/src`, `README.md`, and
  `examples` for old scaffold names and checks that docs contain the current
  public update and graph-output evidence.

## Lock-item status

| Lock item | Status | Evidence |
| --- | --- | --- |
| Lock 1: Public API docs match current public behavior | Complete for Tranche 5a. | `docs/src/public-api.md` documents the live public entry surfaces, live public attribute table, `Makie.update!`, `arg1`, and private `HybridNetwork` preparation. The review follow-up replaced the inaccurate "snake_case attribute set" wording with "public attribute surface." |
| Lock 2: Render verification docs use live public or current architecture proof | Complete for Tranche 5a. | `docs/src/render-verification.md` uses public `Makie.plot!`, current graph outputs, `Makie.data_limits`, and stable child primitive evidence. It no longer calls old helper functions or treats old render-layer payloads as current evidence. |
| Lock 3: Extension docs stop recommending old internal layout wrappers | Complete for Tranche 5a. | `docs/src/extending-plots.md` no longer recommends old coordinate helpers. It states the current extension boundary and labels current computation-layer access as internal and not a stable public layout-query surface. |
| Lock 4: Docs and examples purge old scaffold names as accepted architecture | Complete for Tranche 5a. | `test/test_architecture_audits.jl` scans `docs/src`, `README.md`, and `examples`, excluding `.workflow-docs`, and rejects old scaffold names and `.layers` render-verification payload access. |
| Lock 5: Docs-facing audits supplement runtime and render proof and hand off to 5b | Complete for Tranche 5a. | `test/test_architecture_audits.jl` adds docs-facing checks without replacing runtime or render tests. This report records the Tranche 5b residual work: source compatibility review, final lock-item evidence, and project-owner or assigned-reviewer acceptance. |

## Verification artifacts

Begin-green revalidation before edits:

- `julia --project=test test/runtests.jl` passed `1270/1270`.
- `julia --project=docs docs/make.jl` passed.

Final verification after Tranche 5a implementation:

- Focused architecture audits passed: docs audit `156/156`; source audit
  `358/358`.
- `julia --project=test test/runtests.jl` passed `1426/1426`.
- `julia --project=docs docs/make.jl` passed. Documenter emitted non-fatal
  warnings that large HTML example representations used image fallbacks and
  deployment environment auto-detection was skipped.
- `git diff --check` passed.

## Residual work for tranche 5b

Tranche 5b remains blocked until a new tasking is written from the parent
tranche file and this implementation report. Tranche 5b must not reuse the
Tranche 5a tasking as its execution plan.

Tranche 5b residual work is:

- Source compatibility review of `src/attribute_schema.jl`,
  `src/layout_engine.jl`, `src/plot_layout.jl`, `src/render_adapter.jl`, and
  `src/PhyloMakie.jl`.
- Final lock-item evidence for the complete `reactive-makie-spine` workflow,
  including confirmation that the accepted runtime, docs, examples, and audits
  all agree on the current architecture.
- Project-owner or assigned-reviewer acceptance of the final compatibility and
  closeout decision.

Tranche 5a did not delete, rewrite, or remove includes for source compatibility
files. It did not claim project-owner or assigned-reviewer acceptance.

## Handoff packet for tranche 5b

### Active authorities

Tranche 5b must use this implementation report, the approved Tranche 5a
tasking, the parent tranche file, the parent PRD, the codeplan, prior tasking
files, project-local governance documents, and the upstream primary sources
listed above.

### Parent documents

- `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-01_tranche-01--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-02_tranche-02--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-04_tranche-04--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-05_tranche-05a--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/04-05_tranche-05a--implementation-report-1.md`.

### Settled decisions and non-negotiables

- Public plotting entrypoints and public attributes remain protected:
  `Makie.plot`, `Makie.plot!`, `phyloplot`, `phyloplot!`, `PhyloPlot`, and the
  current public attribute surface.
- Runtime updates use `Makie.update!(plot; ...)`.
- Plotted-network replacement uses `Makie.update!(plot; arg1 = new_net)`.
- Pointer interactions remain out of scope unless the project owner creates a
  new approved tasking for them.
- Tranche 5a docs no longer depend on old scaffold names as accepted current
  architecture.

### Authorization boundary

Tranche 5b may review source compatibility files and prepare final closeout
evidence if the new Tranche 5b tasking authorizes that work. Tranche 5b must
not change public plotting entrypoint names, public attributes, dependency
manifests, pointer interaction support, or external behavior without explicit
project-owner approval.

### Current-state diagnosis

The accepted runtime remains graph-driven. The function
`Makie.plot!(plot::PhyloPlot)` in `src/recipe.jl` validates public limits,
calls `register_phylo_graph!`, calls `create_phylo_primitives!`, and returns
`plot`. The function `register_phylo_graph!` in `src/reactive_graph.jl`
registers graph outputs consumed by child primitives and `Makie.data_limits`.
The function `create_phylo_primitives!` in `src/primitive_assembly.jl` creates
stable `Makie.LineSegments`, `Makie.Poly`, and `Makie.Text` child primitives
from graph output nodes.

The remaining review question is source compatibility. The files
`src/attribute_schema.jl`, `src/layout_engine.jl`, `src/plot_layout.jl`, and
`src/render_adapter.jl` still contain transitional old names. Tranche 5b must
decide whether each compatibility item remains, is demoted, or is removed, and
must verify that no compatibility item becomes a second implementation for
public plotting behavior.

### Primary-goal lock

Tranche 5b must create its own primary-goal lock before execution. At minimum,
that lock must cover:

- Source compatibility review of the remaining old source files.
- Final lock-item evidence across runtime, docs, examples, and audits.
- Project-owner or assigned-reviewer acceptance.

### Direct red-state repros already closed by tranche 5a

- `docs/src/public-api.md` no longer describes `PhyloPlotAttributes` as the
  current public plotting payload.
- `docs/src/public-api.md` no longer calls supported public attributes rejected
  legacy spellings.
- `docs/src/render-verification.md` no longer calls old helper functions
  through `getfield(PhyloMakie, ...)`.
- `docs/src/render-verification.md` no longer presents old render-layer or
  layout payload names as current verification entities.
- `docs/src/extending-plots.md` no longer recommends old layout helpers for
  coordinate lookup.
- `test/test_architecture_audits.jl` now includes docs-facing audits for those
  user-facing docs and examples.

### Responsible code entities relied on by downstream work

- `Makie.plot!(plot::PhyloPlot)` in `src/recipe.jl` is responsible for public
  recipe assembly. Makie dispatch and public plotting calls consume its return
  value. The old broad rebuild path must not return as a bypass path; runtime
  tests and architecture source audits verify that behavior.
- `register_phylo_graph!` in `src/reactive_graph.jl` is responsible for
  registering graph outputs that child primitives and `Makie.data_limits`
  consume. Snapshot-driven primitive calls must not replace those graph nodes;
  public update tests and primitive assembly tests verify that behavior.
- `create_phylo_primitives!` in `src/primitive_assembly.jl` is responsible for
  creating stable child primitives from graph outputs. Child deletion and
  recreation for normal updates must not return; stable-child tests and render
  contract tests verify that behavior.
- `resolve_plot_config`, `prepare_plot_network`, `compute_network_geometry`,
  `compute_layout`, and `compute_primitive_channels` are current internal
  computation-layer functions. Documentation may name them as internal
  implementation details, but they are not public layout-query APIs.

### Exact scope for tranche 5b

In scope for Tranche 5b tasking:

- Read and evaluate `src/attribute_schema.jl`, `src/layout_engine.jl`,
  `src/plot_layout.jl`, `src/render_adapter.jl`, and `src/PhyloMakie.jl`.
- Decide the status of remaining compatibility names in source.
- Verify final lock-item evidence across source, docs, tests, examples, and
  rendered docs artifacts.
- Record project-owner or assigned-reviewer acceptance.

Out of scope unless explicitly approved:

- New pointer interactions.
- New public coordinate lookup APIs.
- New public plotting entrypoints.
- Public attribute renames.
- Dependency or manifest changes.
- CI configuration changes.

### Green-state gates for tranche 5b

Tranche 5b must define and run its final gates, including at least:

- `julia --project=test test/runtests.jl`.
- `julia --project=docs docs/make.jl`.
- Source compatibility review evidence for each remaining compatibility file.
- Docs-facing and runtime architecture audits.
- Final project-owner or assigned-reviewer acceptance record.

### Stop conditions for tranche 5b

Stop if source compatibility review requires public behavior changes not
authorized by the project owner. Stop if old compatibility code is needed as a
real compatibility product rather than a transitional source artifact. Stop if
final evidence cannot be produced from current tests, docs, rendered artifacts,
and source audits. Stop if project-owner or assigned-reviewer acceptance is not
available.
