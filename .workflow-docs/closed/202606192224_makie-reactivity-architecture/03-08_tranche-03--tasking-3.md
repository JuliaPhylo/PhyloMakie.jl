---
date-created: 2026-07-25T03:10:24-07:00
workflow-instrument: Remedial tasking plan
workflow-status: Approved
workflow-agent-thread-id: codex/arrowhead-projection-remediation-20260725
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-makie-spine
workflow-prd: .workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md
workflow-tranche: .workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md
workflow-tranche-id: tranche-03
workflow-parent-tasking: .workflow-docs/202606192224_makie-reactivity-architecture/03-07_tranche-03--tasking-2.md
workflow-review-source: architecture code review of implementation commit 35e0b8bbc8e5c582c951ee7043c434a9d60aaa3b
---

# Remedial Tasks for Tranche 3: Full Makie-Compliant Arrowhead Projection

This is a remedial tasking file for Tranche 3, "Stable primitive assembly integration". It supersedes the incomplete completion claim for `.workflow-docs/202606192224_makie-reactivity-architecture/03-07_tranche-03--tasking-2.md` only where that implementation failed the Makie projection contract and where the verification was too weak. It does not reopen the parent Tranche 3 architecture, the stable primitive assembly decision, or public plotting behavior.

The implementation commit under review already completed several correct pieces: `ArrowheadSpecChannel`, `src/arrowhead_geometry.jl`, graph-owned `:minor_arrowhead_pixel_meshes`, and one stable `Makie.Poly` child with `space = :pixel` and `transformation = :nothing`. Those pieces are preserved. The remaining defect is that `src/reactive_graph.jl` registers the arrowhead start and end projection nodes with `input_space = :data`. Makie's upstream `Arrows2D` projection path starts from plot argument space, not data space. In this package, the current `input_space = :data` call bypasses plot model transforms, so a transformed `PhyloPlot` can leave arrowhead pixel endpoints and meshes detached from the rest of the plot.

The required repair is exact: both minor-arrowhead `Makie.register_projected_positions!` calls in `register_arrowhead_output_nodes!` must use `input_space = :space`, `output_space = :pixel`, and the existing graph-owned pixel mesh computation. The implementing agent must not substitute inverse-projected data-space triangles, `Makie.arrows2d!`, `@lift`, manual camera matrices, or public default changes.

## Settled Review Answers

- **Why migration away from Makie arrows remains correct**: Makie 0.24.10 `Arrows2D` supplies the projection and pixel-metric model we mirror, but it does not provide the required package-level surface for one stable child with per-arrow current-minor-hybrid specs, typed empty outputs, and the existing Tranche 3 graph-output ownership. Returning to per-edge `Makie.arrows2d!` children violates stable primitive assembly. Returning to one `Arrows2D` child would reopen per-arrow metric and public-update constraints that were already closed in Tranche 3.
- **Why accumulating specs in a vector and using `@lift` is not allowed**: this architecture stores render dependencies in the Makie/ComputePipeline graph and updates them with `Makie.update!` and graph `map!` registrations. A specs vector wrapped in `@lift`, direct `Observable` plumbing, `onany`, or snapshot `plot[symbol][]` computation would bypass the graph-owned output contract and reintroduce callback ownership outside the Makie-native public plot owner.
- **Why arrowhead polygons are in pixel space**: hybrid arrowheads are screen markers attached to projected edge shafts. Their public `arrowlen` semantics resolve to pixel metrics through `DEFAULT_ARROW_PIXEL_SCALE`; they are not branch-length geometry. Data-space final triangles make the rendered head size depend on branch length, axis scale, and aspect ratio.
- **Whether this survives anisotropic axes**: pixel-space polygons survive anisotropic axes only when the direction, tip, base, and wing are computed from Makie-projected start and end positions. Data-space triangles do not survive. The current implementation appears to update under ordinary `xlims!` and `ylims!`, but it still violates the full Makie projection contract because `input_space = :data` bypasses plot model transforms.
- **Full compliance fix**: keep the stable `Poly` child and pure pixel mesh helper, change arrowhead projection registration to `input_space = :space`, and add geometry tests that compare every rendered arrowhead against its projected shaft under anisotropic axis limits and plot model transforms.

## Governance

The implementing agent must read these project-local governance documents line by line before touching files:

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

The bundled development-policy depot was consulted during tasking. Its `references/` directory contains `STYLE-agent-handoffs.md`, `STYLE-agent-language.md`, `STYLE-architecture.md`, `STYLE-docs.md`, `STYLE-git.md`, `STYLE-julia.md`, `STYLE-makie.md`, `STYLE-upstream-contracts.md`, `STYLE-verification.md`, `STYLE-workflow-docs.md`, `STYLE-workflow-vocabulary.md`, and `STYLE-writing.md`. The same-named bundled files are byte-identical to the project-local files. Expected bundled files not found were `references/CONTRIBUTING.md`, `references/STYLE-python.md`, and `references/STYLE-vocabulary.md`; project-local `CONTRIBUTING.md` and `STYLE-vocabulary.md` are present and active.

Read-only git and shell commands may be used for diagnosis. Mutating git operations such as commit, merge, push, rebase, reset, checkout for branch changes, and branch creation remain the human project maintainer's responsibility unless the user explicitly instructs otherwise.

Controlled vocabulary constraints:

- Use `HybridNetwork`, `Makie-native public plot owner`, `public attribute surface`, `full-tree style`, `major-tree style`, `major hybrid edge`, and `minor hybrid edge` as defined in `STYLE-vocabulary.md`.
- Use `tranche`, `lock item`, `red-state repro`, `handoff packet`, `upstream primary source`, `verification artifact`, `anti-fix`, and `stop condition` as defined in `STYLE-workflow-vocabulary.md`.
- Because this document uses ownership, boundary, responsibility, source, contract, and verification language, `STYLE-agent-language.md` concrete-expansion rules are mandatory.

Required upstream primary sources for this remedial tasking:

- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/arrows.jl`, especially the `Arrows2D` use of `register_projected_positions!` for startpoints and endpoints without an `input_space` override, which means upstream uses the default `input_space = :space`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/utilities/projection_utils.jl`, especially `register_projected_positions!`, where `input_space = :space` is the default and applies `transform_func`, plot model, and `float32convert` before projecting to the requested `output_space`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/camera/camera.jl`, especially `register_camera_matrix!`, `get_space_to_space_matrix`, and camera-triggered matrix updates.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/basic_recipes/poly.jl`, especially vector-of-polygon conversion and `Poly` child rendering with `space = plot.space`.
- `/home/jeetsukumaran/.julia/packages/Makie/p9K7f/src/compute-plots.jl`, especially `ComputePipeline.update!(plot::Plot; ...)`, the warning against storing `Observable`s in plot attributes, plot `map!`, and `register_camera!`.
- `/home/jeetsukumaran/.julia/packages/ComputePipeline/30b0T/src/ComputePipeline.jl`, especially `Computed`, `add_input!`, `alias!`, `register_computation!`, and `map!`.

## Current-State Diagnosis

- `src/arrowhead_geometry.jl` now computes arrowhead polygons from projected pixel start and end positions. This is the correct final geometry owner and must remain.
- `src/primitive_channels.jl` now exposes `ArrowheadSpecChannel` rather than final data-space arrowhead meshes. This is the correct primitive-channel boundary and must remain.
- `src/primitive_assembly.jl` now renders current minor hybrid arrowheads through one `Makie.Poly` child, with `space = :pixel`, `transformation = :nothing`, `xautolimits = false`, and `yautolimits = false`. This is the correct stable primitive owner and must remain.
- `src/reactive_graph.jl` currently calls `Makie.register_projected_positions!` for `:minor_arrowhead_startpoints` and `:minor_arrowhead_endpoints` with `input_space = :data`. This is the production defect under remediation.
- `test/test_reactive_graph.jl` currently checks that some arrowhead metrics are near 8 px and 6.4 px by using `any`. That lets bad or missing polygons pass when one polygon happens to match.
- `test/support/render_test_helpers.jl` currently checks only the arrowhead triangle's own axis-wing dot product. That does not prove the arrowhead axis is aligned with the projected edge shaft, does not prove the tip is anchored at the projected endpoint, and does not catch a backwards triangle.
- `test/test_arrowhead_geometry.jl` currently lacks direct vertical and zero-length helper tests.

Direct red-state repro already observed during review:

```julia
CairoMakie.activate!()
figure = Figure(size = (600, 400))
axis = Axis(figure[1, 1])
plot = Makie.plot!(axis, net; useedgelength = true, showgamma = true, style = :fulltree)
outputs = PhyloMakie.register_phylo_graph!(plot).primitive_outputs.minor_arrowheads
Makie.colorbuffer(figure; backend = CairoMakie)
before = copy(plot[:minor_arrowhead_pixel_startpoints][])
Makie.translate!(plot, 10, 0, 0)
Makie.colorbuffer(figure; backend = CairoMakie)
after = copy(plot[:minor_arrowhead_pixel_startpoints][])
before == after
```

With the reviewed implementation, `before == after` is `true`. That is wrong. The correct implementation must make the projected startpoints, projected endpoints, and `:minor_arrowhead_pixel_meshes` change after the plot model transform.

## Primary-Goal Lock

### Lock 1: Arrowhead projection starts from Makie plot argument space

- The work is not complete if either minor-arrowhead `register_projected_positions!` call uses `input_space = :data`, omits the projection path entirely, or compensates with manual camera/model matrix code.
- Required production behavior: both calls use `input_space = :space` explicitly, with `output_space = :pixel`, `input_name = :minor_arrowhead_startpoints` or `:minor_arrowhead_endpoints`, and the existing pixel output names.
- Red-state repro: `Makie.translate!(plot, 10, 0, 0)` leaves `:minor_arrowhead_pixel_startpoints` unchanged in the reviewed implementation.
- Tasks that close it: 2, 3, 4.
- Verification artifact: a source audit rejects `input_space = :data` in arrowhead projection registration and a reactive graph regression proves projected startpoints, projected endpoints, and pixel meshes change after `Makie.translate!(plot, 10, 0, 0)`.

### Lock 2: Arrowhead geometry is proven against the projected shaft

- The work is not complete if verification checks only that polygons exist, uses `any` for metric closure, or checks only the triangle's internal axis-wing perpendicularity.
- Required test behavior: every nonempty current minor hybrid arrowhead polygon must have its tip anchored at the corresponding projected endpoint, its axis parallel and same-direction with the projected shaft, its wing perpendicular to the projected shaft, and its length/width equal to the requested scaled pixel metrics.
- Red-state repro: the reviewed test would pass a backwards triangle, a detached triangle, or a plot where one arrowhead is correct and the rest are distorted.
- Tasks that close it: 1, 2, 3, 4.
- Verification artifact: a helper in `test/support/render_test_helpers.jl` asserts full projected-shaft geometry for every polygon before and after anisotropic axis-limit changes and after plot model transforms.

### Lock 3: Axis anisotropy and camera changes are covered as geometry, not resizing smoke tests

- The work is not complete if the only camera/projection check resizes the figure or merely asserts that meshes changed.
- Required test behavior: an explicit `Makie.xlims!(axis, ...)` and `Makie.ylims!(axis, ...)` test must render the figure, prove projected endpoints and meshes changed, and re-run the full projected-shaft geometry helper over every polygon.
- Red-state repro: a data-space or self-perpendicular arrowhead can still pass the reviewed resizing-only test.
- Tasks that close it: 1, 3, 4.
- Verification artifact: an anisotropic-axis regression in `test/test_reactive_graph.jl` that fails if final geometry is computed from data-coordinate deltas or if only one polygon is correct.

### Lock 4: Pure helper edge cases are complete

- The work is not complete if `compute_arrowhead_pixel_meshes` lacks direct tests for vertical shafts and zero-length shafts.
- Required helper behavior: a vertical segment from `(0, 0)` to `(0, 10)` with length `8` and width `6.4` has tip `(0, 10)`, base center `(0, 2)`, horizontal wing endpoints separated by `6.4`, and vertical axis length `8`; a zero-length shaft returns a degenerate three-vertex polygon at the endpoint with zero measured length and width.
- Red-state repro: the reviewed helper tests omit both cases, leaving vertical and degenerate behavior undocumented and unprotected.
- Tasks that close it: 1, 4.
- Verification artifact: direct tests in `test/test_arrowhead_geometry.jl` for vertical and zero-length cases.

### Lock 5: Stable primitive assembly and public surfaces remain intact

- The work is not complete if remediation reintroduces per-edge child plots, `Makie.arrows2d!`, direct `Observable` plumbing, `@lift`, dynamic child creation, public `arrowlen` default changes, or hidden arrowheads as a visual workaround.
- Required behavior: current minor hybrid arrowheads continue to render through one stable `Makie.Poly` child fed by graph outputs. `arrowlen = 0.1` continues to mean an 8 px requested tip length at linewidth 1, and default width remains 6.4 px.
- Red-state repro: a tempting anti-fix is to use Makie arrows again, lower `arrowlen`, hide short arrowheads, or compute transformed mesh snapshots outside the graph.
- Tasks that close it: 1, 2, 3, 4.
- Verification artifact: existing primitive assembly, primitive channel, public render contract, and architecture audit tests remain green, with added audits for projection-space compliance.

### Lock 6: Completion report closes every lock item with evidence

- The work is not complete if the implementation agent reports "complete" without naming every lock item, the artifact that closed it, and why the reviewed/fake implementation would fail.
- Required report behavior: the final implementation report or final response contains a six-row lock-closure table with lock item, production change or test artifact, red-state/fake-fix failure, and verification command.
- Red-state repro: the reviewed implementation was reported complete while `input_space = :data` remained and tests did not prove projected-shaft geometry.
- Tasks that close it: 5.
- Verification artifact: the final response includes the lock-closure table and exact verification command outcomes.

## Forbidden Passing Implementation Table

| Lock item | Required behavior | Current code state | Resolved implementation instruction | Forbidden passing implementation | Failing verification artifact |
| --- | --- | --- | --- | --- | --- |
| Lock 1: Projection from plot argument space | Minor arrowhead startpoints and endpoints are projected from Makie plot argument space to pixel space, applying transform function, model, and float32 conversion. | `src/reactive_graph.jl` uses `input_space = :data` for the two arrowhead projection registrations. | Change both calls to `input_space = :space` explicitly; keep `output_space = :pixel`; keep `compute_arrowhead_pixel_meshes` downstream. | Omitting projection nodes, using manual camera matrices, setting `apply_transform` manually, or relying on `input_space = :data`. | `test/test_architecture_audits.jl` rejects `input_space = :data`; `test/test_reactive_graph.jl` proves projected positions and meshes change after `Makie.translate!(plot, 10, 0, 0)`. |
| Lock 2: Projected-shaft geometry | Every polygon's tip, axis, wing, length, and width match its projected pixel shaft and requested pixel metrics. | Tests check `any` polygon with the right metrics and the triangle's internal axis-wing dot product only. | Add `_assert_arrowhead_matches_projected_shaft` and use it over every polygon paired with projected start/end and metric inputs. | Keeping `_arrowhead_axis_wing_dot` as the only proof, accepting `any`, or comparing only aggregate lengths. | A backwards, detached, or data-direction polygon fails the helper even when its internal axis and wing are perpendicular. |
| Lock 3: Anisotropic axis coverage | Axis-limit changes prove camera/projection compliance and re-run full geometry checks. | The reviewed test resizes the figure and checks changed arrays plus weak geometry predicates. | Add explicit `Makie.xlims!` and `Makie.ylims!` regression on an existing `Axis`, render through CairoMakie, assert projected endpoints and meshes changed, and re-run full per-polygon geometry checks. | Only resizing the figure, only asserting `meshes_before != meshes_after`, or asserting that at least one polygon has plausible metrics. | A data-space triangle implementation fails because its screen-space axis or wing no longer matches the projected shaft under anisotropic limits. |
| Lock 4: Helper edge cases | Vertical and zero-length projected shafts are directly specified and tested. | `test/test_arrowhead_geometry.jl` has horizontal, diagonal, short, empty, and mismatch coverage, but no vertical or zero-length case. | Add direct tests with exact expected vertical geometry and exact degenerate zero-length geometry. | Assuming diagonal coverage implies vertical coverage or leaving zero-length behavior only in source code. | Helper tests fail when vertical axis/wing orientation or degenerate polygon construction drifts. |
| Lock 5: Stable primitive/public contract | One stable `Makie.Poly` child, no `Makie.arrows2d!`, no direct Observables, no public default changes. | The reviewed implementation currently preserves the stable `Poly` child and spec-channel design. | Preserve those files except where tests require stricter source audits; do not alter `src/plot_config.jl` defaults. | Reverting to Makie arrows, per-edge child plots, `@lift`, snapshot mesh computation, hidden arrowheads, or changed `arrowlen` defaults. | Existing primitive assembly, primitive channel, public render contract, and architecture audits fail or are strengthened to fail these anti-fixes. |
| Lock 6: Evidence-bearing completion | The implementation report closes all locks with specific commands and artifacts. | The reviewed completion claim missed a production defect and weak verification. | Final report must include a six-row lock-closure table and exact command outcomes for tests and docs. | Saying "all tests pass" without lock-specific evidence, or omitting the red-state/fake-fix explanation. | Project owner rejects completion until the lock-closure report is present. |

## Handoff Packet

- **Active authorities**: this tasking file; `.workflow-docs/202606192224_makie-reactivity-architecture/03-07_tranche-03--tasking-2.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`; `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md`; project-local governance files listed above; local Makie and ComputePipeline upstream primary sources listed above.
- **Parent design**: Tranche 3 owns stable primitive assembly. Primitive channels calculate stable render specs from layout and public configuration. Reactive graph nodes own projection-dependent outputs. Primitive assembly creates durable Makie child plots that update through `Makie.update!`.
- **Settled production decision**: the only production geometry fix authorized by this remedial tasking is `input_space = :space` for arrowhead start/end projection registration, with final polygons computed by `compute_arrowhead_pixel_meshes` from projected pixel nodes.
- **Settled verification decision**: tests must compare every polygon to the projected shaft. Source audits and child-count checks are required but insufficient by themselves.
- **Authorization boundary**: edits are authorized in `src/reactive_graph.jl`, `test/support/render_test_helpers.jl`, `test/test_arrowhead_geometry.jl`, `test/test_reactive_graph.jl`, and `test/test_architecture_audits.jl`. Edits in `src/arrowhead_geometry.jl`, `src/primitive_channels.jl`, `src/primitive_assembly.jl`, `test/test_primitive_channels.jl`, `test/test_primitive_assembly.jl`, or `test/test_public_render_contracts.jl` are allowed only to preserve compatibility with the stricter tests. Public API changes, dependency changes, docs narrative rewrites, pointer interactions, examples, and manifest edits are not authorized.
- **Current diagnosis**: the implementation mirrors Makie `Arrows2D` pixel geometry except for the `input_space = :data` override. Upstream Makie uses default `input_space = :space`; therefore the local code must explicitly use `:space` to apply plot transforms.
- **Owner and invariant under repair**: `register_arrowhead_output_nodes!` in `src/reactive_graph.jl` owns projection registration for minor arrowhead specs. Its invariant is that `:minor_arrowhead_pixel_startpoints`, `:minor_arrowhead_pixel_endpoints`, and `:minor_arrowhead_pixel_meshes` follow Makie camera and plot model changes.
- **Supported public surfaces affected**: `Makie.plot(net; style = :fulltree)`, `Makie.plot!(axis, net; style = :fulltree)`, `phyloplot(net; style = :fulltree)`, `phyloplot!(axis, net; style = :fulltree)`, `Makie.update!(plot; arrowlen = ...)`, host axis operations through `Makie.xlims!` and `Makie.ylims!`, and plot model transforms through Makie transformation APIs.
- **Out-of-scope files**: docs pages, examples, dependency manifests, pointer-interaction code, recipe public surface changes, and non-`HybridNetwork` plotting redesign.
- **Green-state gates**: begin-green full test suite, red-state projection regression before production fix, targeted arrowhead tests after production fix, full `julia --project=test test/runtests.jl`, and `julia --project=docs docs/make.jl`.
- **Stop conditions**: stop if current code no longer contains the reviewed `input_space = :data` defect; stop if local Makie source no longer matches the listed upstream contract; stop if the production fix requires public API changes, dependency changes, manual camera matrices, per-edge child plots, or direct `Observable`/`@lift` plumbing.

## Required Revalidation Before Edits

1. Read this file, `.workflow-docs/202606192224_makie-reactivity-architecture/03-07_tranche-03--tasking-2.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/03-03_tranche-03--tasking-1.md`, `.workflow-docs/202606192224_makie-reactivity-architecture/02_tranches.md`, and `.workflow-docs/202606192224_makie-reactivity-architecture/01_prd.md` in full.
2. Read every governance document listed in the Governance section in full.
3. Read the required upstream primary sources listed in the Governance section where they constrain this tasking. At minimum, confirm Makie `register_projected_positions!` default `input_space = :space`, the transform/model application path, and Makie `Arrows2D` start/end projection registration.
4. Run `git status --short`. Record any pre-existing user changes and do not revert them.
5. Run `julia --project=test test/runtests.jl` before edits. If this begin-green baseline is red, record the failure and stop for maintainer direction unless the failure is clearly caused by local user changes outside this tasking.
6. Confirm current production source still has `input_space = :data` in the two minor-arrowhead projection registrations in `src/reactive_graph.jl`. If it does not, stop and revise the diagnosis with the maintainer before editing.
7. Reproduce the transform red state with a small local probe or by adding the regression test first. The red state is `before == after` for `:minor_arrowhead_pixel_startpoints` after `Makie.translate!(plot, 10, 0, 0)`.

## Non-Negotiable Execution Rules

- Do not change public `arrowlen` defaults in `src/plot_config.jl`.
- Do not hide or suppress arrowheads to mask geometry.
- Do not divide final arrowhead vertex metrics by `DEFAULT_ARROW_PIXEL_SCALE`.
- Do not compute final rendered arrowhead direction or perpendicular from data-coordinate endpoints.
- Do not reintroduce `ArrowheadChannel.meshes` or any equivalent final-mesh field in `src/primitive_channels.jl`.
- Do not use `Makie.arrows2d!` for current minor hybrid arrowheads.
- Do not create one child plot per current minor hybrid arrowhead.
- Do not use `@lift`, direct `Observable`, `onany`, or snapshot dereferencing through `plot[symbol][]` to compute final arrowhead meshes outside the compute graph.
- Do not use manual camera matrices, manual transform-function application, or ad hoc anisotropy scaling.
- Do not use `register_projected_rotations_2d!` for this fix.
- Do not edit dependency manifests, docs pages, examples, or pointer-interaction code.

## Tasks

### 1. Harden Arrowhead Geometry Test Helpers and Pure Helper Coverage

**Type**: TEST
**Output**: Test helpers and direct helper tests prove full projected-shaft geometry, vertical shafts, and zero-length shafts.
**Depends on**: required revalidation.
**Files**: `test/support/render_test_helpers.jl`, `test/test_arrowhead_geometry.jl`.

Add `using LinearAlgebra: dot, norm` to `test/support/render_test_helpers.jl` and add a helper named `_assert_arrowhead_matches_projected_shaft`. The helper must be deterministic and must not rely on aggregate checks or `any`.

The helper must implement this exact contract:

- Inputs: `polygon`, `pixel_startpoint`, `pixel_endpoint`, `requested_tiplength`, `requested_tipwidth`; keyword tolerances `atol = 0.75f0` and `unit_atol = 0.03f0`.
- Convert `pixel_startpoint` and `pixel_endpoint` to 2D points by using coordinates 1 and 2. The helper must accept projected `Point2f` or `Point3f` values.
- Treat `vertices[1]` as the tip, `vertices[2]` and `vertices[3]` as the base vertices, and `_arrowhead_base_center(vertices)` as the base center.
- Define `shaft = endpoint - startpoint`, `axis = tip - base_center`, and `wing = vertices[2] - vertices[3]`.
- For zero-length shaft, nonpositive requested length, or nonpositive requested width, assert that the measured arrowhead length and width are zero and that all three vertices are approximately at the projected endpoint.
- For nonzero shaft and positive metrics, compute `scale = min(1.0f0, norm(shaft) / requested_tiplength)`, `expected_length = requested_tiplength * scale`, and `expected_width = requested_tipwidth * scale`.
- Assert tip anchoring: `tip` is approximately the projected endpoint.
- Assert metric closure: `norm(axis)` is approximately `expected_length`, and `norm(wing)` is approximately `expected_width`.
- Assert direction closure: `dot(axis / norm(axis), shaft / norm(shaft))` is approximately `1.0f0`. Do not use `abs` for this assertion; a backwards arrowhead must fail.
- Assert wing closure: `abs(dot(wing / norm(wing), shaft / norm(shaft)))` is approximately `0.0f0`.
- Keep `_arrowhead_axis_wing_dot` only as a supplemental helper for direct pure-geometry tests; do not use it as the only proof in reactive graph tests.

Add direct helper tests to `test/test_arrowhead_geometry.jl`:

- Vertical segment: start `(0, 0)`, end `(0, 10)`, `tiplength = 8`, `tipwidth = 6.4`. Assert tip `(0, 10)`, base center `(0, 2)`, measured length `8`, measured width `6.4`, horizontal wing, and vertical axis.
- Zero-length segment: start `(5, 7)`, end `(5, 7)`, `tiplength = 8`, `tipwidth = 6.4`. Assert the polygon has three exterior vertices, all vertices are approximately `(5, 7)`, measured length is `0`, and measured width is `0`.
- Call `_assert_arrowhead_matches_projected_shaft` in the existing horizontal, diagonal, and short-segment helper tests. Call it in the new vertical and zero-length tests after the exact point and metric assertions.

Run `julia --project=test test/runtests.jl` after this task. The suite must remain green because this task adds missing helper coverage without yet addressing the projection defect.

### 2. Add Red-State Projection and Source-Audit Tests

**Type**: TEST
**Output**: Failing tests or source audits that expose the reviewed `input_space = :data` defect before the production fix.
**Depends on**: 1.
**Files**: `test/test_reactive_graph.jl`, `test/test_architecture_audits.jl`, `test/support/render_test_helpers.jl`.

Implement the red projection tests before changing `src/reactive_graph.jl`.

In `test/test_architecture_audits.jl`, strengthen the runtime source audit:

- Assert that `src/reactive_graph.jl` contains at least two projection registrations with `input_space = :space`.
- Assert that `src/reactive_graph.jl` does not contain `input_space = :data`.
- Keep the existing audits for `compute_arrowhead_pixel_meshes`, `:minor_arrowhead_pixel_meshes`, `space = :pixel`, `transformation = :nothing`, and the absence of `_arrowhead_polygon`, `data_length`, and final mesh fields in primitive channels.

In `test/test_reactive_graph.jl`, add a fresh regression test for plot model transforms:

- Construct a fresh `Figure`, `Axis`, and full-tree `PhyloPlot` from a fixture network with current minor hybrid arrowheads.
- Register the graph and render with CairoMakie before taking measurements.
- Copy `plot[:minor_arrowhead_pixel_startpoints][]`, `plot[:minor_arrowhead_pixel_endpoints][]`, and `plot[outputs.meshes][]`.
- Call `Makie.translate!(plot, 10, 0, 0)`.
- Render again with CairoMakie.
- Assert that projected startpoints changed, projected endpoints changed, and `plot[outputs.meshes][]` changed.
- Assert that the changed meshes still equal `compute_arrowhead_pixel_meshes(plot[:minor_arrowhead_pixel_startpoints][], plot[:minor_arrowhead_pixel_endpoints][], plot[outputs.tiplengths][], plot[outputs.tipwidths][])`.
- Run `_assert_arrowhead_matches_projected_shaft` over every polygon after the transform.

Run the targeted tests or the full suite after adding this task's assertions and before the production fix. The architecture audit and transform regression must fail against the reviewed implementation. If they do not fail, stop and record the mismatch.

### 3. Repair Projection Registration to Makie Plot Argument Space

**Type**: MIGRATE
**Output**: `src/reactive_graph.jl` registers minor-arrowhead projected start/end nodes from Makie plot argument space.
**Depends on**: 1, 2.
**Files**: `src/reactive_graph.jl`.

In `register_arrowhead_output_nodes!`, change both arrowhead projection registrations to this exact shape:

```julia
Makie.register_projected_positions!(
    plot,
    Makie.Point3f;
    input_space = :space,
    input_name = :minor_arrowhead_startpoints,
    output_name = :minor_arrowhead_pixel_startpoints,
    output_space = :pixel,
)

Makie.register_projected_positions!(
    plot,
    Makie.Point3f;
    input_space = :space,
    input_name = :minor_arrowhead_endpoints,
    output_name = :minor_arrowhead_pixel_endpoints,
    output_space = :pixel,
)
```

The `input_space = :space` keyword is mandatory even though upstream Makie defaults to `:space`. It makes the local contract explicit and gives source audits a stable target. Do not set `apply_transform`, `apply_transform_func`, `apply_model`, or `apply_float32convert` manually.

Preserve these downstream relationships:

- `:minor_arrowhead_pixel_meshes` is computed by `_compute_minor_arrowhead_pixel_meshes`.
- `_compute_minor_arrowhead_pixel_meshes` calls `compute_arrowhead_pixel_meshes`.
- The mesh computation depends on `:minor_arrowhead_pixel_startpoints`, `:minor_arrowhead_pixel_endpoints`, `:minor_arrowhead_tiplengths`, and `:minor_arrowhead_tipwidths`.
- `ArrowheadGraphOutputs.meshes` remains `:minor_arrowhead_pixel_meshes`.

Run the red tests from Task 2 after this production change. They must pass.

### 4. Strengthen Anisotropic Axis Regression and Preserve Stable Primitive Contracts

**Type**: TEST
**Output**: Axis-limit and public-contract tests prove geometry and stable primitive assembly together.
**Depends on**: 1, 2, 3.
**Files**: `test/test_reactive_graph.jl`, `test/test_public_render_contracts.jl`, `test/test_primitive_assembly.jl`, `test/test_primitive_channels.jl`, `test/test_architecture_audits.jl`.

Replace the weak `arrowhead meshes follow projected pixel positions` assertions in `test/test_reactive_graph.jl` with a full per-polygon geometry proof:

- Render a full-tree fixture plot in a non-square figure.
- Copy projected startpoints, projected endpoints, requested lengths, requested widths, and meshes.
- Assert there is at least one arrowhead polygon.
- Assert `meshes == compute_arrowhead_pixel_meshes(projected_startpoints, projected_endpoints, tiplengths, tipwidths)`.
- Run `_assert_arrowhead_matches_projected_shaft` for every polygon.
- Call `Makie.xlims!(axis, -1, 3)` and `Makie.ylims!(axis, -2, 5)` on the host axis.
- Render again.
- Assert projected startpoints changed, projected endpoints changed, and meshes changed.
- Recompute expected meshes from the changed projected nodes and metrics.
- Run `_assert_arrowhead_matches_projected_shaft` for every changed polygon.
- Do not use `any` to prove metric closure.
- Do not rely on figure resizing as the only anisotropic-axis proof. A resize may remain as supplemental coverage after explicit `xlims!` and `ylims!`.

Preserve these existing contracts:

- `children.minor_arrowheads isa Makie.Poly`.
- `children.minor_arrowheads.space[] == :pixel`.
- The source audit in `test/test_architecture_audits.jl` continues to assert `transformation = :nothing` in `src/primitive_assembly.jl`.
- `children.minor_arrowheads.xautolimits[] == false`.
- `children.minor_arrowheads.yautolimits[] == false`.
- `Makie.Arrows2D` is absent from `plot.plots` for current minor hybrid arrowheads.
- Child identity remains stable across `Makie.update!` calls.
- `:majortree` continues to produce typed empty minor arrowhead specs and meshes.
- Full-tree default `arrowlen = 0.1` continues to request 8 px length and 6.4 px width at linewidth 1.

Add or strengthen source audits only as guardrails. Do not use source audits as a substitute for rendered geometry checks.

### 5. Final Green Verification and Lock Closure

**Type**: REVIEW
**Output**: End-green verification and completion report with lock-specific evidence.
**Depends on**: 1, 2, 3, 4.
**Files**: no required production files.

Run these commands from the repository root:

```sh
julia --project=test test/runtests.jl
julia --project=docs docs/make.jl
```

The docs build is a required compatibility gate even though this remedial tasking does not authorize docs content changes. Existing Documenter warnings may be recorded if the build exits successfully. A docs failure is not accepted as complete unless the implementing agent proves it existed before remediation and the maintainer explicitly accepts proceeding.

Run source inspections with `rg` or test audits to confirm:

- No arrowhead projection registration uses `input_space = :data`.
- The two minor-arrowhead projection registrations use `input_space = :space`.
- No production code reintroduces `_arrowhead_polygon`, `data_length`, `ArrowheadChannel.meshes`, `Makie.arrows2d!` for current minor hybrid arrowheads, `@lift`, direct `Observable` mesh construction, or manual camera matrices for arrowheads.

The final implementation response must include this lock-closure table filled with actual artifacts:

| Lock item | Artifact that closed it | Why the reviewed or fake implementation fails | Verification command |
| --- | --- | --- | --- |
| Lock 1: Projection from plot argument space |  |  |  |
| Lock 2: Projected-shaft geometry |  |  |  |
| Lock 3: Anisotropic axis coverage |  |  |  |
| Lock 4: Helper edge cases |  |  |  |
| Lock 5: Stable primitive/public contract |  |  |  |
| Lock 6: Evidence-bearing completion |  |  |  |

Completion is not accepted without all six rows populated.
