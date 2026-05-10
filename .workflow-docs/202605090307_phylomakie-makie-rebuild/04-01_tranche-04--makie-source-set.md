# Tranche 4 Makie source set

## Scope

This note records the repo-owned Makie-family contract resolved during tranche 4
task 1 on 2026-05-10. It replaces the tasking-time depot candidates as the
authoritative source set for this repository.

## Resolved environment state

- Root environment:
  `Project.toml` now declares `Makie = "0.24.10"`.
- Test environment:
  `test/Project.toml` now declares `CairoMakie = "0.15.10"` and
  `Makie = "0.24.10"`.
- Docs environment:
  `docs/Project.toml` now declares `CairoMakie = "0.15.10"` and
  `Makie = "0.24.10"`.
- The tasking-time candidate `Makie 0.24.7` at
  `/home/jeetsukumaran/.julia/packages/Makie/TOy8O` is not the resolved
  repository contract.
- The resolved root Makie source tree is
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f`.
- The resolved CairoMakie source tree is
  `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v`.

## Activation and gate results

- `julia --project=. -e 'using Makie'`:
  passed. `pathof(Makie)` resolved to
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/Makie.jl`.
- `julia --project=test -e 'using CairoMakie; using Makie'`:
  passed after adding both `CairoMakie` and direct `Makie` entries to the test
  project.
- `julia --project=docs -e 'using CairoMakie; using Makie'`:
  passed after adding both `CairoMakie` and direct `Makie` entries to the docs
  project.
- `julia --project=docs docs/make.jl`:
  passed after dependency activation and still passes after the tranche-4
  render-verification page landed.
- `julia --project=test test/runtests.jl`:
  now passes after the package-side `import Makie`, render-owner
  implementation, and tranche-4 verification updates. The full suite reports
  `393/393` tests passing on 2026-05-10.

Historical red seam observed immediately after dependency activation:

- Task 1 requires `Makie` as a direct root dependency so the repo-owned root
  environment can load Makie.
- The current package still intentionally has no package-side Makie import
  before task 3.
- Aqua therefore reports `Makie` as a stale direct dependency even though the
  environment activation gate is now green.

This seam needs explicit project-owner ratification before render
implementation proceeds.

## Task-2 review outcome and seam closure

- On 2026-05-10, the project owner ratified the recommended path from task 2:
  allow a minimal package-side `import Makie` plus the corresponding
  shell-owner-test update before render implementation starts.
- `src/PhyloMakie.jl` now acknowledges `Makie` directly while keeping
  `phyloplot`, `phyloplot!`, `PhyloPlot`, `Makie.plottype`, and Makie
  `plot(net)` dispatch absent.
- The stale-dependency seam is closed honestly rather than masked by an Aqua
  exception: `Aqua.test_all(PhyloMakie)` now accepts `Makie` as a live direct
  dependency inside the passing test suite.
- The ratified primitive path did not change after review:
  `linesegments!`, `arrows2d!`, `text!`, and `Makie.colorbuffer` remain the
  tranche-4 render contract under CairoMakie.

## Ratified source files and contract conclusions

### Recipe and entry-surface host contract

- Source file:
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/recipes.jl`
- Conclusion:
  the resolved Makie 0.24.10 recipe contract is owned by `Makie/src/recipes.jl`
  itself, not by the tasking-time candidate path
  `MakieCore/src/recipes.jl`. The `@recipe` macro still generates the recipe
  plot type, generated `plot`/`plot!` helpers, and default-theme wiring.

### Figure-return and mutating-plot host contract

- Source file:
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/figureplotting.jl`
- Conclusion:
  non-mutating plot creation still routes through `_create_plot` and returns a
  `FigureAxisPlot`-style figurelike owner, while mutating creation routes
  through `_create_plot!` onto an existing axis or scene. Tranche 5 public
  entry surfaces must honor this contract.

### Segment primitive contract

- Source files:
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/Makie.jl`
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_plots.jl`
- Conclusion:
  the resolved Makie tree exports `linesegments!` as the atomic segment plot
  surface. Tranche 4 should use `linesegments!` for edge segments and node
  bars rather than inventing a custom segment primitive.

### Arrow primitive contract

- Source file:
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`
- Conclusion:
  the resolved Makie 0.24.10 tree still exposes `arrows!`, but it remains a
  deprecated shim that warns and dispatches to `arrows2d!` or `arrows3d!`.
  The render owner should call `arrows2d!` directly for tranche 4 minor-edge
  arrows instead of relying on the deprecated shim.

### Text primitive contract

- Source file:
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/text.jl`
- Conclusion:
  text rendering still flows through Makie text recipes, and TeX underline
  support itself composes via `linesegments!`. Tranche 4 should use `text!`
  for tip, node, edge, length, number, and gamma layers rather than
  hand-assembling glyph geometry.

### Render-capture contract

- Source files:
  `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/display.jl`
  `/home/jeetsukumaran/.julia/packages/CairoMakie/hql6v/src/screen.jl`
- Conclusion:
  `Makie.colorbuffer(fig; backend = CairoMakie, ...)` remains the host-side
  render-capture contract, and CairoMakie owns the backend-specific screen
  implementation. Render verification should capture figure outputs through
  `Makie.colorbuffer` under CairoMakie rather than by scraping SVG or source
  text.

## Review items for task 2

The project-owner review should explicitly ratify all of the following before
task 3 begins:

- Use `Makie/src/recipes.jl`, not the tasking-time `MakieCore/src/recipes.jl`
  candidate path, as the recipe contract source.
- Use `Makie/src/figureplotting.jl` as the figure-return and mutating-plot
  host contract source.
- Use `linesegments!` for segment primitives.
- Use `arrows2d!` directly for minor hybrid-edge arrows.
- Use `text!` for all text layers.
- Use `Makie.colorbuffer` with CairoMakie for render capture.
- Decide how to close the Aqua stale-dependency seam between task 1 and the
  still-deferred package-side Makie import in task 3.

## Recommended resolution for the Aqua seam

Recommended path:

- allow a minimal package-side `import Makie` plus the corresponding
  shell-owner-test update before render implementation starts

Reason:

- it keeps the Makie root dependency honest without masking the direct
  dependency in Aqua, and it does not force tranche 4 to rely on a temporary
  stale-dependency exception

Alternative path:

- allow a temporary Aqua stale-dependency exception for `Makie` until task 3
  lands the render owner

Tradeoff:

- this preserves the current package shell until task 3, but it weakens the
  stale-dependency proof surface during the review-gated gap
