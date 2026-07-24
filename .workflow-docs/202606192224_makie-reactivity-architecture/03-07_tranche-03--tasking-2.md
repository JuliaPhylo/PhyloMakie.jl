---
date-created: 2026-07-23T23:44:04-07:00
workflow-instrument: Tasking plan
workflow-status: Proposed
workflow-agent-thread-id: codex/019f6c80-18d9-7642-9da6-936d5eb8ec46
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-03
---

# Tasks for Tranche 3: Repair Projected Minor Hybrid Arrowhead Geometry

This tasking file is a second tasking for Tranche 3, "Stable primitive assembly integration". It treats the reported oversized minor hybrid arrowhead defect as a projected-geometry repair to the Tranche 3 arrowhead implementation, not as a new parent tranche and not as a public API redesign.

Current revalidation found that Tranche 3 moved current minor hybrid arrowheads away from dynamic per-edge `Makie.arrows2d!` children and into one stable `Makie.Poly` child. The remaining defect is that `src/primitive_channels.jl` constructs the final triangle vertices in data coordinates, then divides pixel metrics by `DEFAULT_ARROW_PIXEL_SCALE`. That cancellation makes the default `arrowlen = 0.1` render as about `0.1` data units, which is large relative to short branch lengths and is distorted by anisotropic axes.

The required design decision is settled in this file: minor hybrid arrowhead metrics remain pixel metrics, final arrowhead polygons must be computed from projected pixel-space start and end points, and the existing stable `poly!` child must render those pixel-space polygons with `space = :pixel` and `transformation = :nothing`. Inverse-projected data-space triangles are not an allowed implementation for this tasking.

## Settled user decisions and environment baseline

- Public plotting entrypoints and public attributes remain protected: `Makie.plot`, `Makie.plot!`, `phyloplot`, `phyloplot!`, `PhyloPlot`, `:fulltree`, `:majortree`, `arrowlen`, `xlim`, and `ylim` must keep their current public meanings.
- This is a deep internal projected-geometry repair, not a public API redesign.
- The prior Tranche 3 decision remains fixed: current minor hybrid arrowheads use one stable `Makie.Poly` child. Dynamic per-edge `Makie.arrows2d!` children are forbidden.
- `@lift`, direct `Observable` plumbing, broad `onany`, and dynamically creating a vector of child plots are forbidden. Use Makie/ComputePipeline graph nodes through `map!` and Makie projection registration.
- `arrowlen = 0.1` in full-tree style must produce an 8 px default arrowhead length at linewidth 1, because `DEFAULT_ARROW_PIXEL_SCALE = 80.0f0` converts the legacy arrow length value into pixel metrics.
- Arrowhead width remains `DEFAULT_ARROW_WIDTH_RATIO * tiplength`, so the default width is 6.4 px at linewidth 1.
- Arrowhead length and width must be scaled down together when the projected shaft segment is shorter than the requested pixel tip length. This follows the verified Makie `Arrows2D` metric behavior in `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`.
- Do not add dependencies or edit `Project.toml`, `Manifest.toml`, `docs/Project.toml`, `docs/Manifest.toml`, `test/Project.toml`, `test/Manifest.toml`, or `examples/Project.toml`.
- Use local upstream sources already present in this workspace. Network access is out of scope unless the project owner explicitly approves it.
- No `codebases-and-documentation` directory was found at the workspace root during tasking.

## Governance

An implementation agent must read these governance documents line by line before touching files:

- `CONTRIBUTING.md`
- `STYLE-agent-handoffs.md`
- `STYLE-agent-language.md`
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

The bundled development-policy depot was consulted. Its `references/` directory contains `STYLE-agent-handoffs.md`, `STYLE-agent-language.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-workflow-docs.md`, `STYLE-workflow-vocabulary.md`, and `STYLE-writing.md`. These bundled files are byte-identical to the same-named project-local files in `PhyloMakie.jl`. Expected bundled files not found were `references/CONTRIBUTING.md`, `references/STYLE-python.md`, and `references/STYLE-vocabulary.md`; project-local `CONTRIBUTING.md` and `STYLE-vocabulary.md` are present and active.

Read-only git and shell commands may be used for diagnosis. Mutating git operations such as commit, merge, push, rebase, reset, checkout for branch changes, and branch creation remain the human project maintainer's responsibility unless the user explicitly instructs otherwise.

Controlled vocabulary constraints:

- Use `HybridNetwork`, `Makie-native public plot owner`, `public attribute surface`, `full-tree style`, `major-tree style`, `major hybrid edge`, and `minor hybrid edge` as defined in `STYLE-vocabulary.md`.
- Use `tranche`, `lock item`, `red-state repro`, `handoff packet`, `upstream primary source`, `verification artifact`, `anti-fix`, and `stop condition` as defined in `STYLE-workflow-vocabulary.md`.
- Because this document uses ownership, boundary, responsibility, source, contract, and verification language, `STYLE-agent-language.md` concrete-expansion rules are mandatory.

Required upstream primary sources for this tasking:

- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`, especially `markerspace = :pixel`, `register_projected_positions!`, pixel direction and metric scaling, and internal `poly!` rendering with `space = plot.markerspace`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/utilities/projection_utils.jl`, especially `register_projected_positions!`, `input_space`, `output_space`, camera projection registration, and inverse-transform behavior.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/camera/camera.jl`, especially `register_camera_matrix!`, `get_space_to_space_matrix`, and camera matrix update inputs.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`, especially vector-of-polygon conversion and `Poly` child rendering with `space = plot.space`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`, especially `ComputePipeline.update!(plot::Plot; ...)`, the warning against storing `Observable`s in plot attributes, plot `map!`, and `register_camera!`.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`, especially `Computed`, `add_input!`, `alias!`, `register_computation!`, and `map!`.

## Primary-goal lock

### Lock 1: Pixel metrics must not be converted into data-unit arrowheads

- The work is not complete if `arrowlen = 0.1` still produces a triangle with about `0.1` data-unit length or if `_arrowhead_polygon` or its replacement divides `tiplength` or `tipwidth` by `DEFAULT_ARROW_PIXEL_SCALE` while constructing final vertices.
- Direct red-state repro: `src/primitive_channels.jl` currently computes `base_tiplength = DEFAULT_ARROW_PIXEL_SCALE * arrowlen`, then `_arrowhead_polygon` divides `tiplength` and `tipwidth` by `DEFAULT_ARROW_PIXEL_SCALE`, so the rendered default length becomes `0.1` data units.
- Tasks that close it: 1, 2, 3.
- Verification artifact: pixel-geometry tests must measure an 8 px tip length and 6.4 px tip width at linewidth 1; source audit must fail the old `_arrowhead_polygon` data-unit conversion path.

### Lock 2: Arrowheads must survive anisotropic axes

- The work is not complete if the arrowhead direction, base point, or perpendicular vector is computed from data-coordinate `endpoint - startpoint` for final rendered triangles.
- Direct red-state repro: current `_arrowhead_polygon` computes `unit_direction` and `unit_perpendicular` in data space. With non-square figure geometry or unequal x/y scaling, the screen-space arrowhead is stretched and no longer perpendicular to the screen-space minor hybrid edge shaft.
- Tasks that close it: 1, 2, 3.
- Verification artifact: anisotropic-axis tests must compare pixel-space arrowhead length, width, and base perpendicularity before and after axis limit or figure-size changes. The old data-space implementation must fail this test.

### Lock 3: Stable primitive assembly must remain intact

- The work is not complete if the projected-geometry repair reintroduces dynamic per-edge `Makie.arrows2d!` children, creates or deletes arrowhead child plots on normal updates, or replaces the single stable `Makie.Poly` child.
- Direct red-state repro: the archived and old render-adapter path created one `Makie.arrows2d!` child per current minor hybrid arrowhead because Makie 0.24.10 does not support per-arrow vector `tiplength` and `tipwidth` in one `Arrows2D` child.
- Tasks that close it: 2, 3, 4.
- Verification artifact: primitive assembly tests must assert exactly one `Makie.Poly` child for current minor hybrid arrowheads, no `Makie.Arrows2D` child in `plot.plots`, and stable child identity after `Makie.update!`.

### Lock 4: Projection-dependent mesh construction must be graph-owned

- The work is not complete if `compute_primitive_channels` or `compute_arrowhead_channel` still returns final rendered arrowhead meshes, or if final meshes are computed once from snapshot values and do not depend on Makie projection nodes.
- Direct red-state repro: `ArrowheadChannel` currently stores `meshes`, and `_minor_arrowhead_outputs` exposes those precomputed meshes directly as `:minor_arrowhead_meshes`. The graph has no `:minor_arrowhead_startpoints`, `:minor_arrowhead_endpoints`, `:minor_arrowhead_tiplengths`, `:minor_arrowhead_tipwidths`, `:minor_arrowhead_pixel_startpoints`, or `:minor_arrowhead_pixel_endpoints` dependency path.
- Tasks that close it: 1, 2, 3.
- Verification artifact: graph-output tests must show arrowhead spec nodes exist, pixel projection nodes exist, and `:minor_arrowhead_pixel_meshes` changes when projected endpoints change while child identity remains stable.

### Lock 5: Public plotting surfaces and `arrowlen` semantics must remain stable

- The work is not complete if `Makie.plot`, `Makie.plot!`, `phyloplot`, `phyloplot!`, full-tree style, major-tree style, hidden minor hybrid edge shafts, or public `arrowlen` behavior changes without explicit project-owner approval.
- Direct red-state repro: a tempting anti-fix is to shrink the default `arrowlen`, clamp arrowheads in data units, hide arrowheads for short branch lengths, or change full-tree defaults so the oversized heads are less noticeable.
- Tasks that close it: 1, 2, 3, 4.
- Verification artifact: public render tests must still show full-tree and major-tree visual distinction, `style = :majortree` must still suppress current minor hybrid arrowheads through typed empty outputs, and `arrowlen = 0.1` must measure as an 8 px default tip length rather than a different public default.

### Lock 6: Visual verification must fail the historical bug and fake fixes

- The work is not complete if verification only checks that arrowhead mesh arrays exist, that `poly!` exists, or that the test suite passes without pixel-level or rendered-output checks.
- Direct red-state repro: current `test/test_primitive_channels.jl` and `test/test_primitive_assembly.jl` prove typed mesh payloads and stable child wiring, but they do not measure on-screen arrowhead dimensions or anisotropic-axis behavior.
- Tasks that close it: 3, 4.
- Verification artifact: tests must include pixel-coordinate measurements and at least one CairoMakie colorbuffer render check for a network with current minor hybrid arrowheads.

## Forbidden Passing Implementation Table

| Lock item | Required behavior | Current code state | Resolved implementation instruction | Forbidden passing implementation | Failing verification artifact |
| --- | --- | --- | --- | --- | --- |
| Lock 1: Pixel metrics remain pixels | `arrowlen = 0.1` yields an 8 px arrowhead length and 6.4 px width at linewidth 1; no final vertex calculation divides metrics back into data units. | `src/primitive_channels.jl` has `DEFAULT_ARROW_PIXEL_SCALE = 80.0f0`, `compute_arrowhead_metrics`, and `_arrowhead_polygon` dividing `tiplength` and `tipwidth` by `DEFAULT_ARROW_PIXEL_SCALE`. | Add `src/arrowhead_geometry.jl` with `compute_arrowhead_pixel_meshes`; remove `_arrowhead_polygon`; make `compute_arrowhead_channel` return only startpoints, endpoints, colors, stroke settings, source indices, `tiplengths`, and `tipwidths`. | Lower `DEFAULT_ARROW_PIXEL_SCALE`, change default `arrowlen`, or keep data-space polygons with a different clamp. | `test/test_arrowhead_geometry.jl` exact pixel-size tests and a source audit rejecting `_arrowhead_polygon`, `data_length`, and data-unit metric division in `src/primitive_channels.jl`. |
| Lock 2: Anisotropic axes | Final arrowhead direction and perpendicular are computed from projected pixel start and end points, not data-coordinate deltas. | `_arrowhead_polygon` computes `direction = endpoint - startpoint` and `unit_perpendicular = Vec2f(-unit_direction[2], unit_direction[1])` in data space. | In `src/reactive_graph.jl`, register projected start and end nodes with `Makie.register_projected_positions!(plot, Point3f; input_name = :minor_arrowhead_startpoints, output_name = :minor_arrowhead_pixel_startpoints, output_space = :pixel)` and the corresponding endpoint node; map those pixel nodes through `compute_arrowhead_pixel_meshes`. | Multiply data x and y deltas by an ad hoc scale factor, or inverse-project a single data-space length while still computing the perpendicular from data coordinates. | Anisotropic-axis test that measures unchanged pixel tip length/width and screen-space perpendicularity after non-square figure or axis-limit changes. |
| Lock 3: Stable `Poly` child | Projected arrowheads render through one stable `Makie.Poly` child. | `src/primitive_assembly.jl` currently creates one `Makie.Poly` child; legacy paths used per-edge `Makie.arrows2d!`. | Keep `create_arrowhead_primitive!` as the only current arrowhead primitive constructor and pass `plot[outputs.meshes]` to `Makie.poly!` with `space = :pixel` and `transformation = :nothing`. | Revert to `Makie.arrows2d!`, create one `poly!` child per arrowhead, or recreate the `Poly` child on projection changes. | `test/test_primitive_assembly.jl` child inventory, no-`Arrows2D` assertion, and child identity assertions after `Makie.update!` and axis/camera changes. |
| Lock 4: Graph-owned projected meshes | `:minor_arrowhead_pixel_meshes` is a graph output that depends on projected start/end nodes and pixel metrics. | `_minor_arrowhead_outputs` currently returns only precomputed `arrowheads.meshes`, colors, stroke colors, and stroke width from `PrimitiveChannels`. | Expand `ArrowheadGraphOutputs` to include `startpoints`, `endpoints`, `tiplengths`, `tipwidths`, `meshes`, `colors`, `strokecolors`, and `strokewidth`; map primitive-channel spec outputs, projected endpoints, and `compute_arrowhead_pixel_meshes` inside `register_arrowhead_output_nodes!`. | Compute pixel meshes once with `plot[output][]` snapshots during primitive assembly, or keep `ArrowheadChannel.meshes` as a second implementation that tests ignore. | `test/test_reactive_graph.jl` graph inventory check for spec and projection nodes, plus update checks that `plot[outputs.primitive_outputs.minor_arrowheads.meshes][]` changes when projection changes. |
| Lock 5: Public surfaces and defaults | Public plotting entrypoints and `arrowlen` default behavior remain compatible while the rendered size matches the pixel metric contract. | Public `arrowlen` is resolved in `src/plot_config.jl` to `0.1` for full-tree style and `0` for major-tree style. | Do not edit `resolve_plot_config` default `arrowlen` logic except comments naming pixel metric semantics. Preserve style suppression by producing typed empty spec and mesh outputs when arrowheads are hidden. | Hide arrowheads for short branches, change `style = :fulltree` default `arrowlen`, or make `:majortree` depend on a new public knob. | Public render tests and primitive-channel tests for `:fulltree`, `:majortree`, `arrowlen = 0`, hidden minor line type, and default 8 px metrics. |
| Lock 6: Failure-oriented visual verification | Verification includes pixel measurements and rendered colorbuffer checks that fail the current data-space implementation. | Current tests prove mesh existence and stable child wiring but do not measure rendered arrowhead dimensions. | Add `test/test_arrowhead_geometry.jl` and strengthen `test/test_primitive_assembly.jl` or `test/test_public_render_contracts.jl` with pixel-size and colorbuffer checks. | Add only source grep checks or typed-array checks while leaving data-space geometry distorted. | Pixel measurement tests and CairoMakie colorbuffer test for a current minor hybrid arrowhead plot under anisotropic conditions. |

## Handoff packet

- **Active authorities**: this tasking file after approval; `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`; project-local governance files listed in the Governance section; bundled byte-identical governance files listed in the Governance section; local Makie and ComputePipeline upstream primary sources listed above.
- **Parent documents**: `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`, and `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`.
- **Settled decisions and non-negotiables**: final arrowhead geometry is computed in pixel space; `poly!` renders the arrowhead polygons with `space = :pixel` and `transformation = :nothing`; no inverse-projected data-space triangle alternative; no `@lift`; no dynamic child-plot vector; no `Makie.arrows2d!`; no public `arrowlen` default change.
- **Authorization boundary**: internal struct, helper, graph-output, and test redesign is authorized. Public API changes, dependency changes, pointer interactions, docs narrative rewrite, and manifest edits are not authorized.
- **Current-state diagnosis**: `compute_arrowhead_metrics` creates pixel metrics, but `_arrowhead_polygon` in `src/primitive_channels.jl` divides those metrics back by `DEFAULT_ARROW_PIXEL_SCALE` and computes the final triangle in data space. `ArrowheadGraphOutputs` exposes only final meshes and therefore prevents camera/projection-driven arrowhead geometry.
- **Primary-goal lock**: lock items 1 through 6 in this file.
- **Direct red-state repros**: default `arrowlen = 0.1` becomes about `0.1` data units; `_arrowhead_polygon` computes the perpendicular in data coordinates; current tests do not fail oversized or anisotropically distorted heads.
- **Owner and invariant under repair**: `compute_arrowhead_metrics` in `src/primitive_channels.jl` calculates pixel metrics from public configuration and minor edge widths. `compute_arrowhead_channel` in `src/primitive_channels.jl` must calculate only renderable arrowhead specs from minor hybrid edge shaft data. `register_arrowhead_output_nodes!` in `src/reactive_graph.jl` must register projection-dependent graph outputs and map projected pixel endpoints plus pixel metrics into `:minor_arrowhead_pixel_meshes`. `create_arrowhead_primitive!` in `src/primitive_assembly.jl` must consume the final mesh graph node in one stable `Makie.Poly` child.
- **Supported public surfaces affected**: `Makie.plot(net; style = :fulltree)`, `Makie.plot!(axis, net; style = :fulltree)`, `phyloplot(net; style = :fulltree)`, `phyloplot!(axis, net; style = :fulltree)`, public updates through `Makie.update!(plot; arrowlen = ...)`, public updates through `Makie.update!(plot; xlim = ..., ylim = ...)`, and current minor hybrid edge rendering under `:fulltree` and `:majortree`.
- **Exact files in scope**: `src/arrowhead_geometry.jl`, `src/PhyloMakie.jl`, `src/primitive_channels.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, `test/test_arrowhead_geometry.jl`, `test/test_primitive_channels.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`, `test/support/render_test_helpers.jl`, and `test/runtests.jl`.
- **Exact files out of scope**: docs pages, examples, dependency manifests, public recipe declaration, `src/recipe.jl` except source-audit coverage, `src/render_adapter.jl` except source-audit coverage, pointer interaction code, non-`HybridNetwork` plotting support, and performance tuning outside the arrowhead projected-geometry repair.
- **Required upstream primary sources**: all Makie and ComputePipeline files listed in the Governance section.
- **Green-state gates**: targeted arrowhead geometry tests, primitive channel tests, reactive graph tests, primitive assembly tests, public render contract tests, source audits for forbidden red states, `julia --project=test test/runtests.jl`, and `julia --project=docs docs/make.jl` unless a pre-existing docs failure is recorded before implementation.
- **Stop conditions**: stop if `Makie.poly!` with `space = :pixel` and `transformation = :nothing` cannot render as a stable child of `PhyloPlot` under Makie 0.24.10; stop if projection nodes do not update on camera, axis-limit, or figure-size changes; stop if the implementation requires a public API change, dependency change, or dynamic child plot creation; stop if upstream Makie source contradicts the pixel-space `poly!` design in this file.

## Required revalidation before implementation

- Read this tasking file, the parent tranche file, the parent PRD, and the prior Tranche 3 tasking file in full.
- Read the governance documents listed above line by line.
- Read the required upstream primary sources listed above where they constrain the task being executed.
- Run or inspect the current begin-green baseline before edits. If `julia --project=test test/runtests.jl` is red before implementation, record the failure and stop unless the project maintainer authorizes proceeding from a red baseline.
- Re-read current files in scope: `src/primitive_channels.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, `src/PhyloMakie.jl`, `test/test_primitive_channels.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`, `test/support/render_test_helpers.jl`, and `test/runtests.jl`.
- Re-check that `Manifest.toml` still resolves Makie to `/home/jeetsukumaran/.julia/packages/Makie/p9K7f` and ComputePipeline to `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T`. If either package path changes, reread the corresponding upstream files before editing.
- If current code no longer matches the diagnosis above, stop and raise that before changing code.

## Tranche execution rule

This tasking may redesign internal arrowhead structs, graph outputs, and tests within the named files. It must begin and end in a green, policy-compliant state for its scope. It must not reopen the already-settled Tranche 3 decision to use one stable `Makie.Poly` child for current minor hybrid arrowheads.

The behavior that must no longer exist when this tasking is complete is final arrowhead triangle construction in data coordinates before Makie projection. The behavior that must remain is stable primitive assembly through graph outputs and one `Poly` child.

## Non-negotiable execution rules

- Do not change public `arrowlen` defaults in `src/plot_config.jl`.
- Do not hide or suppress arrowheads to mask the geometry bug.
- Do not divide final arrowhead vertex metrics by `DEFAULT_ARROW_PIXEL_SCALE`.
- Do not compute final arrowhead direction or perpendicular from data-coordinate endpoints.
- Do not keep `ArrowheadChannel.meshes` or any equivalent field as a second final mesh implementation in `src/primitive_channels.jl`.
- Do not use `Makie.arrows2d!` for current minor hybrid arrowheads.
- Do not create one child plot per current minor hybrid arrowhead.
- Do not use `@lift`, `Observable`, `onany`, or snapshot dereferencing through `plot[symbol][]` to compute final arrowhead meshes outside the compute graph.
- Do not edit dependency manifests, docs pages, or examples in this tasking.

## Concrete anti-patterns or removal targets

- `_arrowhead_polygon` in `src/primitive_channels.jl`.
- `data_length = tiplength / DEFAULT_ARROW_PIXEL_SCALE` and `half_width = tipwidth / (2 * DEFAULT_ARROW_PIXEL_SCALE)` in final vertex construction.
- `ArrowheadChannel.meshes` or a renamed equivalent in `src/primitive_channels.jl`.
- `:minor_arrowhead_meshes` as a pre-projection primitive-channel output.
- Any `Makie.arrows2d!` call in `src/recipe.jl`, `src/reactive_graph.jl`, or `src/primitive_assembly.jl`.
- Any partial migration where `compute_arrowhead_channel` exposes startpoints but still computes final data-space polygons.
- Any partial migration where `create_arrowhead_primitive!` renders pixel-coordinate polygons without `space = :pixel`.
- Any verification plan that checks only typed arrays, source text, or child count without measuring pixel geometry.

## Failure-oriented verification

- The current implementation must fail exact pixel-size tests because default arrowhead length is derived from data units after the scale cancellation.
- The current implementation must fail anisotropic-axis tests because final direction and perpendicular are computed before projection.
- A fake fix that changes `arrowlen` defaults must fail public default and pixel metric tests.
- A fake fix that clamps only arrowhead length but not width must fail short-segment metric scaling tests.
- A fake fix that keeps precomputed `ArrowheadChannel.meshes` must fail source audits and graph inventory tests.
- A fake fix that uses one `poly!` child but passes data-space polygons must fail pixel-space `Poly` argument and anisotropic-axis tests.
- Positive render verification must show a nonempty CairoMakie colorbuffer for a full-tree plot with current minor hybrid arrowheads after the projection-aware mesh path is active.

## Tasks

### 1. Add Pure Pixel Arrowhead Geometry Helper

**Type**: WRITE
**Output**: `src/arrowhead_geometry.jl` defines pure pixel-space arrowhead polygon construction and `test/test_arrowhead_geometry.jl` verifies exact pixel metrics.
**Depends on**: none
**Positive contract**: `compute_arrowhead_pixel_meshes(pixel_startpoints, pixel_endpoints, tiplengths, tipwidths)` returns `Vector{ArrowheadPixelPolygon}` from projected pixel positions and pixel metrics. For a horizontal segment from `(0, 0)` to `(10, 0)` with `tiplength = 8` and `tipwidth = 6.4`, the returned triangle has tip `(10, 0)`, base center `(2, 0)`, and wing separation `6.4` pixels. If the projected shaft is shorter than `tiplength`, both length and width scale down by the same ratio.
**Negative contract**: The helper must not accept data-space positions, must not divide by `DEFAULT_ARROW_PIXEL_SCALE`, must not inspect Makie plot state, must not register graph nodes, and must not create Makie child plots.
**Files**: `src/arrowhead_geometry.jl`, `src/PhyloMakie.jl`, `test/test_arrowhead_geometry.jl`, `test/runtests.jl`.
**Out of scope**: `src/primitive_channels.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, public attributes, docs, examples, manifests.
**Verification**: Run `julia --project=test test/runtests.jl` after adding the helper and tests. `test/test_arrowhead_geometry.jl` must include exact tests for horizontal, vertical, diagonal, zero-length, and short-segment cases. The short-segment case must fail an implementation that clamps length but leaves width unscaled.

Create `src/arrowhead_geometry.jl` and include it in `src/PhyloMakie.jl` after `primitive_channels.jl` and before `reactive_graph.jl`. Define `const ArrowheadPixelPolygon = Makie.GeometryBasics.Polygon{2, Float32}`. Define `compute_arrowhead_pixel_meshes` as the only helper that constructs final arrowhead polygons. The helper must convert projected `Point3f` inputs to 2D pixel points by using the first two coordinates, compute direction and perpendicular in pixel space, and return degenerate three-point polygons only for zero-length projected shafts. For nonzero projected shafts, compute the scale factor as `min(1, segment_length / tiplength)` when `tiplength > 0`; multiply both `tiplength` and `tipwidth` by that scale. Tests must call this helper directly and must not construct a `Figure`, `Axis`, `PhyloPlot`, or `ComputeGraph`.

### 2. Migrate Arrowhead Channels and Graph Outputs to Specs Plus Projected Meshes

**Type**: MIGRATE
**Output**: `compute_arrowhead_channel` returns arrowhead specs without final meshes, and `register_arrowhead_output_nodes!` creates projection-dependent `:minor_arrowhead_pixel_meshes`.
**Depends on**: 1
**Positive contract**: `src/primitive_channels.jl` exposes `ArrowheadSpecChannel` with colors, stroke colors, stroke width, source indices, startpoints, endpoints, `tiplengths`, and `tipwidths`. `src/reactive_graph.jl` registers graph nodes for those spec fields, registers `:minor_arrowhead_pixel_startpoints` and `:minor_arrowhead_pixel_endpoints` with `Makie.register_projected_positions!`, and maps projected points plus pixel metrics through `compute_arrowhead_pixel_meshes` to `:minor_arrowhead_pixel_meshes`.
**Negative contract**: `src/primitive_channels.jl` must not construct final polygon meshes. `src/reactive_graph.jl` must not compute final meshes from `plot[symbol][]` snapshots. The graph must not expose pre-projection data-space meshes as the primitive argument.
**Files**: `src/primitive_channels.jl`, `src/reactive_graph.jl`, `src/primitive_assembly.jl`, `test/test_primitive_channels.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`.
**Out of scope**: `src/recipe.jl`, `src/render_adapter.jl`, docs, examples, dependency manifests, public attribute defaults.
**Verification**: Run `julia --project=test test/runtests.jl`. Source audit must show no `_arrowhead_polygon`, no `ArrowheadChannel.meshes`, and no data-unit final vertex construction in `src/primitive_channels.jl`. `test/test_reactive_graph.jl` must assert graph nodes exist for `:minor_arrowhead_startpoints`, `:minor_arrowhead_endpoints`, `:minor_arrowhead_tiplengths`, `:minor_arrowhead_tipwidths`, `:minor_arrowhead_pixel_startpoints`, `:minor_arrowhead_pixel_endpoints`, and `:minor_arrowhead_pixel_meshes`.

In `src/primitive_channels.jl`, replace `ArrowheadChannel{TMesh}` with `ArrowheadSpecChannel` and keep the field name `minor_arrowheads` inside `PrimitiveChannels`. `compute_arrowhead_channel` must filter out entries only when `render_visible` is false or when `tiplength <= 0` or `tipwidth <= 0`; it must preserve startpoints, endpoints, colors, stroke colors, source indices, and pixel metrics for renderable arrowhead specs. It must return typed empty vectors for hidden or zero-arrow states. Remove `_arrowhead_polygon` from this file.

In `src/reactive_graph.jl`, expand `ArrowheadGraphOutputs` to contain `startpoints`, `endpoints`, `tiplengths`, `tipwidths`, `meshes`, `colors`, `strokecolors`, and `strokewidth`, with `meshes = :minor_arrowhead_pixel_meshes`. Register spec outputs from `PrimitiveChannels.minor_arrowheads`. Then call `Makie.register_projected_positions!` for `:minor_arrowhead_startpoints` and `:minor_arrowhead_endpoints`, using `Point3f`, `output_space = :pixel`, and explicit output names `:minor_arrowhead_pixel_startpoints` and `:minor_arrowhead_pixel_endpoints`. Register `:minor_arrowhead_pixel_meshes` with `map!` over the two projected position nodes and the two metric nodes. Do not include the projection nodes in `phylo_graph_output_symbols()` as final primitive arguments, but tests must assert they exist in `plot.attributes.outputs`.

In `src/primitive_assembly.jl`, keep one `create_arrowhead_primitive!` helper and make it call `Makie.poly!(plot, plot[outputs.meshes]; color = plot[outputs.colors], strokecolor = plot[outputs.strokecolors], strokewidth = plot[outputs.strokewidth], space = :pixel, transformation = :nothing)`. This helper must not read `plot[outputs.meshes][]`.

### 3. Add Projection and Anisotropy Regression Tests

**Type**: TEST
**Output**: Tests fail the current data-space arrowhead implementation and prove pixel-metric geometry under anisotropic axes.
**Depends on**: 1, 2
**Positive contract**: Tests measure pixel-space arrowhead length, width, tip anchoring, and base perpendicularity from the `:minor_arrowhead_pixel_meshes` graph output under square and anisotropic render conditions. Measurements remain within a tolerance of 0.75 px for the default 8 px length and 6.4 px width when the projected minor hybrid edge shaft is long enough.
**Negative contract**: Tests must not accept data-space polygon geometry, source-audit-only proof, or a fix that merely changes `arrowlen` defaults. Tests must not depend on dynamic per-edge child plots.
**Files**: `test/test_arrowhead_geometry.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`, `test/support/render_test_helpers.jl`.
**Out of scope**: production source changes, docs, examples, manifests.
**Verification**: Run `julia --project=test test/runtests.jl`. The new tests must fail the pre-fix `_arrowhead_polygon` implementation. At least one test must render a CairoMakie colorbuffer for a full-tree `HybridNetwork` with current minor hybrid arrowheads after setting a non-square figure size or anisotropic axis limits.

Strengthen `test/test_primitive_assembly.jl` with helpers that extract the one `Makie.Poly` arrowhead child and read `plot[outputs.primitive_outputs.minor_arrowheads.meshes][]`. Measure each polygon directly in pixel coordinates: the first vertex is the tip, the midpoint of the second and third vertices is the base center, `norm(tip - base_center)` is the effective pixel length, and `norm(wing_a - wing_b)` is the effective pixel width. Also compute the projected shaft direction from `:minor_arrowhead_pixel_startpoints` and `:minor_arrowhead_pixel_endpoints`; assert that `tip - base_center` is parallel to the projected shaft and that `wing_a - wing_b` is perpendicular to it in screen coordinates.

Add a regression using a non-square `Figure` and an anisotropic axis condition. The test must construct an actual public plot through `Makie.plot` or `Makie.plot!`, extract `surface.plot`, call `register_phylo_graph!` only to obtain output symbols when required by the current test pattern, force rendering with `Makie.colorbuffer(...; backend = CairoMakie)`, and assert nonempty render output. The test must not inspect only `PrimitiveChannels`, because `PrimitiveChannels` no longer owns final mesh geometry.

### 4. Preserve Public Surfaces, Hidden States, and Source Shape

**Type**: TEST
**Output**: Public plotting surfaces and source audits prove the projected-geometry repair did not regress Tranche 3 primitive stability or public plotting behavior.
**Depends on**: 2, 3
**Positive contract**: `Makie.plot`, `Makie.plot!`, `phyloplot`, and `phyloplot!` still render current minor hybrid arrowheads in full-tree style and suppress them through typed empty outputs in major-tree style or hidden minor-edge states. `Makie.update!(plot; arrowlen = ...)`, `Makie.update!(plot; style = :majortree)`, and `Makie.update!(plot; xlim = ..., ylim = ...)` keep child identities stable while updating graph outputs.
**Negative contract**: Source and tests must not accept `Makie.arrows2d!`, dynamic arrowhead child creation, data-space final polygons, changed `arrowlen` defaults, or snapshot mesh computation outside graph nodes.
**Files**: `test/test_primitive_channels.jl`, `test/test_reactive_graph.jl`, `test/test_primitive_assembly.jl`, `test/test_public_render_contracts.jl`, `test/runtests.jl`.
**Out of scope**: docs pages, examples, manifests, public API additions, pointer interactions.
**Verification**: Run `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl`. Add or keep source audits that fail if `src/primitive_channels.jl` contains `_arrowhead_polygon`, if `src/reactive_graph.jl` or `src/primitive_assembly.jl` contains `@lift`, `Observable`, or `arrows2d!`, or if `src/primitive_assembly.jl` creates arrowhead polygons without `space = :pixel`.

Update existing primitive-channel tests so they assert typed arrowhead specs rather than typed final mesh payloads. Hidden states must assert empty startpoints, endpoints, colors, source indices, `tiplengths`, and `tipwidths`. Reactive graph tests must update the final output-symbol count and must assert both spec-node and projection-node existence. Primitive assembly tests must keep the existing child inventory and no-`Arrows2D` assertions while changing mesh-output expectations to `:minor_arrowhead_pixel_meshes`.

### 5. Final Review Against Lock Items and Upstream Contracts

**Type**: REVIEW
**Output**: A short implementation report or review note records that all six lock items are closed with named verification artifacts.
**Depends on**: 1, 2, 3, 4
**Positive contract**: The review maps every lock item in this tasking file to a passing test, source audit, render artifact, or upstream-contract check.
**Negative contract**: The review must not accept a green suite if any lock item lacks a direct failing artifact for the old implementation or a named forbidden passing implementation.
**Files**: No production files. A reviewer may add an implementation report in `.workflow-docs/202606192224_makie-reactivity-architecture/` only if the project owner requests one.
**Out of scope**: code changes, docs rewrite, public API changes, new tranche creation.
**Verification**: Confirm `julia --project=test test/runtests.jl` and `julia --project=docs docs/make.jl` results. Inspect the final diff against the Non-negotiable execution rules and Concrete anti-patterns or removal targets in this tasking file.

Review the implementation against Makie `Arrows2D` pixel-metric semantics, Makie projection utilities, and `Poly` rendering behavior. Confirm that any local inference from upstream source is recorded in the implementation report or final handoff and that no approved divergence from Makie semantics was introduced.

---
