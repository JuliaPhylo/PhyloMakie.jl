---
date-created: 2026-07-16T03:47:00-07:00
workflow-instrument: Implementation report
workflow-status: Completed
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-05b
workflow-tasking: .workflow-docs/202606192224_makie-reactivity-architecture/03-06_tranche-05b--tasking-1.md
---

# Implementation report for tranche 5b: source compatibility review and final closeout

## Governance and required reading

This implementation report is a downstream workflow artifact. Any agent or
contributor that uses it for review, audit, or follow-up work must read the
following governance documents line by line before acting on it:

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

`STYLE-agent-language.md` remains mandatory for any downstream prose that uses
ownership, contract, boundary, layer, invariant, compatibility, verification,
source, or responsibility language. Such prose must name the exact code entity
or external contract, the behavior, the consumers, duplicate or bypass paths
that must not keep the same responsibility, and the verification artifact.

The active workflow authorities for this report are:

- `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/codeplan.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-01_tranche-01--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-02_tranche-02--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-04_tranche-04--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-05_tranche-05a--tasking-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/04-05_tranche-05a--implementation-report-1.md`.
- `.workflow-docs/202606192224_makie-reactivity-architecture/03-06_tranche-05b--tasking-1.md`.

The upstream primary sources rechecked for Tranche 5b were:

- `.workflow-docs/open/20260615--interactivity1/design/makie-interactivity-tutorial.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`.
- `../PhyloNetworks.jl/src/manipulateNet.jl`.

## Implementation summary

Tranche 5b removed the approved old source compatibility scaffold and closed
the `reactive-makie-spine` workflow against the user-approved C5 condition. It
did not change public plotting entrypoints, public attributes, dependency
manifests, pointer interactions, package docs narrative pages, CI
configuration, generated build artifacts, or unrelated examples.

Implemented package changes:

- Deleted `src/attribute_schema.jl`.
- Deleted `src/layout_engine.jl`.
- Deleted `src/plot_layout.jl`.
- Deleted `src/render_adapter.jl`.
- Removed `include("attribute_schema.jl")`,
  `include("layout_engine.jl")`, `include("plot_layout.jl")`, and
  `include("render_adapter.jl")` from `src/PhyloMakie.jl`.
- Extended `test/test_PhyloMakie.jl` with negative module-definition checks for
  the retired unsupported internal names by constructing the checked symbols
  from string fragments.
- Extended `test/test_architecture_audits.jl` so accepted package source is
  audited for retired scaffold tokens in addition to the existing user-facing
  docs, README, test, and package example audits.

Implemented sibling workspace change:

- Updated
  `../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl`
  to create the same network, create the same edge-label data, create a
  `Figure` and `Axis`, hide decorations and spines, call public
  `phyloplot!(ax, net2; edgelabel = edge_labels)`, and return `fig`.
- Removed the sibling example's manual `PhyloNetworks.directedges!`,
  `PhyloNetworks.preorder!`, old internal layout calls, old internal render
  call, and `preorder = false` diagnostic.

## Settled decision execution

| Decision | Status | Evidence |
| --- | --- | --- |
| C1: delete the 4 approved compatibility files | Complete. | The 4 files listed above are deleted from `src`. |
| C2: remove their include lines from `src/PhyloMakie.jl` | Complete. | The final include list is `plot_config.jl`, `network_layout.jl`, `annotation_tables.jl`, `primitive_channels.jl`, `recipe_declaration.jl`, `reactive_graph.jl`, `primitive_assembly.jl`, and `recipe.jl`. |
| C3: treat old unexported source names as unsupported internals with no deprecation period | Complete. | `test/test_PhyloMakie.jl` checks that those names are not defined on `PhyloMakie`; architecture audits and final `rg` checks reject those tokens from accepted package surfaces. |
| C4: update the sibling example to public plotting | Complete. | The sibling example now calls `phyloplot!` and the sibling old-name audit returns no matches. |
| C5: use the Codex-thread human closeout decision only if every required artifact passes | Complete. | The full package test suite, docs build, sibling example, old-name audits, whitespace checks, and final report evidence all passed. The closeout claim in this report is valid only because those C5 artifacts passed. |

## Tranche lock-item status

| Lock item | Status | Evidence |
| --- | --- | --- |
| Lock 1: approved source compatibility files are deleted | Complete. | The 4 files are deleted, `src/PhyloMakie.jl` no longer includes them, `rg` over `src` finds no retired scaffold tokens, and the full package suite passed. |
| Lock 2: old scaffold names are absent from accepted package surfaces | Complete. | `test/test_architecture_audits.jl` scans accepted package source and user-facing package surfaces while excluding workflow provenance; the final accepted-surface `rg` returned no matches. |
| Lock 3: the sibling example uses `phyloplot!` | Complete. | The sibling example calls public `phyloplot!`; its old-name audit returned no matches; the sibling example ran successfully after an approved rerun outside the filesystem sandbox. |
| Lock 4: final evidence maps PRD lock items 1 through 10 | Complete. | The PRD lock-item evidence table below maps all 10 lock items to concrete artifacts. |
| Lock 5: public behavior remains stable | Complete. | `julia --project=test test/runtests.jl` passed `1598/1598`; `julia --project=docs docs/make.jl` passed with only expected Documenter warnings; the sibling example ran successfully. |
| Lock 6: human closeout condition is recorded without ambiguity | Complete. | This report records C1 through C5 and states that the C5 human closeout condition is satisfied only because every C5 verification artifact passed. |

## PRD lock-item evidence

| PRD lock item | Status | Concrete artifacts |
| --- | --- | --- |
| 1: remove broad rebuild reactivity | Complete. | `Makie.plot!(plot::PhyloPlot)` in `src/recipe.jl` calls `register_phylo_graph!` and `create_phylo_primitives!` instead of a broad rebuild adapter. Stable-child behavior is tested in `test/test_primitive_assembly.jl`; architecture audits in `test/test_architecture_audits.jl` reject old rebuild scaffold names in accepted source; the full suite passed. |
| 2: use `Makie.update!` as the dynamic entrypoint | Complete. | Public update behavior is covered by `test/test_recipe.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, and `test/test_public_render_contracts.jl`; the full suite passed after compatibility deletion. |
| 3: establish the computation layer | Complete. | `src/plot_config.jl`, `src/network_layout.jl`, `src/annotation_tables.jl`, and `src/primitive_channels.jl` remain the current computation-layer files. Their behavior is covered by `test/test_plot_config.jl`, `test/test_network_layout.jl`, `test/test_annotation_tables.jl`, and `test/test_primitive_channels.jl`; the full suite passed. |
| 4: establish the reactive graph layer | Complete. | `register_phylo_graph!` in `src/reactive_graph.jl` registers graph outputs consumed by child primitives and `Makie.data_limits`. Graph-node and recomputation behavior is covered by `test/test_reactive_graph.jl`; the full suite passed. |
| 5: pass output nodes to primitives | Complete. | `create_phylo_primitives!` in `src/primitive_assembly.jl` creates stable `Makie.LineSegments`, `Makie.Poly`, and `Makie.Text` children from graph output nodes. Primitive assembly behavior is covered by `test/test_primitive_assembly.jl`; source audits confirm the old snapshot render adapter is gone. |
| 6: model hybrid arrowheads as computed mesh geometry | Complete. | Arrowhead geometry remains modeled through primitive channel and mesh payload tests in `test/test_primitive_channels.jl` and `test/test_primitive_assembly.jl`. The accepted runtime source audit and final old-name `rg` confirm no accepted `arrows2d!` path remains. |
| 7: preserve current public behavior | Complete. | Full package tests passed `1598/1598`; docs generation passed; public render behavior is covered by `test/test_public_render_contracts.jl`; public API docs from Tranche 5a still document public `plot`, `plot!`, `phyloplot`, `phyloplot!`, `PhyloPlot`, public attributes, and `Makie.update!`. |
| 8: purge old scaffold names and ownership | Complete. | The 4 source compatibility files were deleted, their include lines were removed, module negative checks were added, `test/test_architecture_audits.jl` rejects the old tokens, and final `rg` checks over accepted package surfaces and the sibling example returned no matches. |
| 9: defer pointer interactions honestly | Complete. | Pointer interactions remain out of scope. Existing architecture audits continue to reject unsupported hover, click, drag, selection, and DataInspector claims in accepted docs; docs generation passed after Tranche 5b. |
| 10: keep network traversal preparation caller-safe | Complete. | `prepare_plot_network` and reactive graph tests preserve caller-owned `HybridNetwork` values. Caller-safe traversal behavior is covered by `test/test_network_layout.jl`, `test/test_reactive_graph.jl`, and public plotting/update tests; the full suite passed. |

## Verification command log

| Command or gate | Result |
| --- | --- |
| Pre-edit package `git status --short` | Passed; package worktree was clean before edits. |
| Pre-edit sibling `git status --short` | Passed; sibling worktree was clean before edits. |
| Pre-edit package old-name audit over `src`, `test`, `docs/src`, `README.md`, and `examples` | Passed as a red-state audit; matches were confined to the 4 approved source compatibility files before deletion. |
| Pre-edit sibling old-name audit | Passed as a red-state audit; matches were confined to the one approved sibling example before migration. |
| `rg` over `src` for retired scaffold tokens after deletion | Passed; no matches, with `rg` exit code 1 as expected for no matches. |
| `rg` over `src`, `test`, `docs/src`, `README.md`, and `examples` for retired scaffold tokens after deletion | Passed; no matches, with `rg` exit code 1 as expected for no matches. |
| `rg` over `src/PhyloMakie.jl` for deleted include lines | Passed; no matches, with `rg` exit code 1 as expected for no matches. |
| `rg` over the sibling example for old internal names after migration | Passed; no matches, with `rg` exit code 1 as expected for no matches. |
| `git -C PhyloMakie.jl diff --check` | Passed; no whitespace errors. |
| `git -C phylonetworks-visualization-examples diff --check` | Passed; no whitespace errors. |
| Sibling status and diff probes using the wrong relative path from the workspace root | Failed as a command-addressing mistake; the path did not exist from that working directory. The corrected sibling path was used immediately after and passed. |
| `julia --project=../phylonetworks-visualization-examples ../phylonetworks-visualization-examples/src/34_mwe_test_level2_preorder_false_phylomakie.jl` | The first sandboxed run failed because Julia could not create a compiled-package pidfile under the read-only home cache. The approved rerun outside that filesystem sandbox passed with exit code 0. |
| `julia --project=test test/runtests.jl` | Passed `1598/1598` in `2m16.8s`. |
| `julia --project=docs docs/make.jl` | Passed. Documenter emitted non-fatal warnings for large HTML example representations using PNG fallbacks and deployment environment auto-detection being skipped. Those warning classes are the expected Tranche 5a warnings and do not contradict Tranche 5b source deletion or public API behavior. |
| Final package `git status --short` before report creation | Passed with expected uncommitted implementation changes: `src/PhyloMakie.jl`, 4 deleted source files, `test/test_PhyloMakie.jl`, and `test/test_architecture_audits.jl`. |
| Final sibling `git status --short` before report creation | Passed with expected uncommitted implementation change in `src/34_mwe_test_level2_preorder_false_phylomakie.jl`. |

The final report also avoids the vague closeout phrases prohibited by Tranche
5b tasking. The literal phrase-audit pattern is not reproduced here because
doing so would make this report match its own audit.

## Post-report final gates

After this report was created, the final green-state gates were rerun:

| Command or gate | Result |
| --- | --- |
| Package `git status --short` | Passed with expected uncommitted implementation changes: `src/PhyloMakie.jl`, 4 deleted source files, `test/test_PhyloMakie.jl`, `test/test_architecture_audits.jl`, and this new implementation report. |
| Sibling `git status --short` | Passed with expected uncommitted implementation change in `src/34_mwe_test_level2_preorder_false_phylomakie.jl`. |
| Package `git diff --check` | Passed; no whitespace errors. |
| Sibling `git diff --check` | Passed; no whitespace errors. |
| Accepted package-surface old-name audit | Passed; no matches, with `rg` exit code 1 as expected for no matches. |
| Sibling example old-name audit | Passed; no matches, with `rg` exit code 1 as expected for no matches. |
| Final report vague-closeout phrase audit | Passed; no matches, with `rg` exit code 1 as expected for no matches. |
| Sibling example command | Passed in the normal sandbox with exit code 0. |
| `julia --project=test test/runtests.jl` | Passed `1598/1598` in `1m45.9s`. |
| `julia --project=docs docs/make.jl` | Passed. Documenter emitted the same non-fatal warning classes: 18 large HTML example representations used PNG fallbacks, and deployment environment auto-detection was skipped. |

## Closeout status

Tranche 5b is complete. The `reactive-makie-spine` workflow is complete under
the C5 human closeout condition from the Codex thread because every required
C5 artifact passed:

- The 4 approved compatibility source files are deleted.
- The 4 approved include lines are removed.
- Old unsupported internal names are absent from accepted package surfaces.
- The sibling example uses public `phyloplot!`.
- Full tests passed.
- Docs generation passed with only expected Documenter warnings.
- The final PRD lock-item table maps lock items 1 through 10 to concrete
  verification artifacts.

No follow-up implementation work is required by Tranche 5b.
