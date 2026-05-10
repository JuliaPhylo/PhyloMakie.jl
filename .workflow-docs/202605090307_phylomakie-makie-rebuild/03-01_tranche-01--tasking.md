---
date-created: 2026-05-09T03:07:47
date-updated: 2026-05-09T14:40:00
parent-tranche: 02_tranches.md
parent-prd: 01_prd.md
workflow-instrument: Tasking plan
workflow-status: Implemented
workflow-id: 202605090307_phylomakie-makie-rebuild
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
---

# Tasks for tranche 1: Verification and module shell foundation

Parent tranche: Tranche 1
Parent PRD: `01_prd.md`

## Approval state

- This tasking file was proposed planning output derived from a proposed tranche
  plan and is now the execution record for the implemented tranche-1 snapshot.
- Project-owner approval for both Tranche 1 in `02_tranches.md` and this
  tasking file was recorded on 2026-05-09 via the explicit execution request
  for tranche-1 implementation.
- This file is ratified for the completed tranche-1 `Tasks -> Execute` run only.

## Settled user decisions and environment baseline

- The production-run public behavior target is `PhyloPlots.plot(net::HybridNetwork; ...)`.
- The canonical PhyloMakie target public surface names are `phyloplot`, `phyloplot!`, and Makie `plot(net)` dispatch.
- `PhyloPlot` is the recipe type name, not the primary user-facing API name.
- `PhyloNetworks.HybridNetwork` is the only supported public input type for this production run.
- Deep internal redesign is authorized. Public plotting behavior drift from `PhyloPlots.plot` is not authorized.
- Compatibility aliases to old package names are not required.
- R interoperability remains out of scope.
- Preserve the existing root, `test/`, and `docs/` project split.
- Preserve `[sources.PhyloMakie] path = "../"` in `test/Project.toml` and `docs/Project.toml`.
- Use the repo-local `test/` and `docs/` projects rather than an ad hoc global Julia environment.
- Curate the `test/` and `docs/` project environments with documented public `Pkg` operations from those environments. Do not hand-edit manifest files unless an explicit review or escalation note records that no public `Pkg` workflow can satisfy the required change.
- Public entry-surface proof closure is intentionally deferred to Tranche 5. Full verification-envelope closure is intentionally deferred to Tranche 6.
- In this tranche, docs must tell the truth about the current implementation state. They must not imply that `phyloplot`, `phyloplot!`, or `plot(net)` already exist.
- In this tranche, the three plotting entry surfaces are target public surfaces for the production run, not implemented tranche-1 APIs.
- Historical tranche-start baseline: `julia --project=test test/runtests.jl`
  failed before running tests because the `test/` manifest did not yet resolve
  `PhyloMakie` as a runnable direct dependency.

## Governance

Read all applicable governance documents line by line before implementing any task in this file.

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
- `01_prd.md`
- `02_tranches.md`

Controlled vocabulary obligations that matter directly in this tranche:

- Use `phyloplot` and `phyloplot!` for the target public surfaces.
- Use `PhyloPlot` only for the recipe type.
- Use `FigureAxisPlot` for the non-mutating Makie return contract.
- Use `major hybrid edge`, `minor hybrid edge`, `full-tree style`, `major-tree style`, `keyword surface`, `layout engine`, `render adapter`, `lock item`, `red-state repro`, and `foundational tranche` with their governed meanings.
- Do not import foreign project terms such as `lineageplot`, `EdgeLayer`, or `lineageunits`.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, branch creation, rebase, and reset remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Primary-goal lock

### Lock item 1: Runnable `test/` project baseline

- The work is not complete if `julia --project=test test/runtests.jl` still fails before running tests from the repo-local `test/` project.
- The direct red-state repro is the current failure:
  `ArgumentError: Package PhyloMakie ... is required but does not seem to be installed`,
  and the follow-on `Pkg.instantiate()` failure that reports `PhyloMakie` as a direct dependency missing from the manifest.
- The tasks that close this are task 1, then tasks 3 and 4, which depend on a runnable test project.
- The verification artifact is a passing `julia --project=test test/runtests.jl` run from the repository root after task 3.

### Lock item 2: Thin module owner

- The work is not complete if `src/PhyloMakie.jl` remains a placeholder shell or becomes a logic dump instead of a thin owner shell.
- The direct red-state repro is the current file:
  `module PhyloMakie`, a placeholder comment, and no includes or verification owner.
- The tasks that close this are task 2 and task 3.
- The verification artifact is a shell-level test that imports `PhyloMakie`, confirms the module exposes `VERIFICATION_FOUNDATION`, and confirms the top-level source is an include-only shell rather than the old placeholder state.

### Lock item 3: Canonical verification owner

- The work is not complete if the lock-item matrix, target public surfaces, accepted scenarios, deferred proof ownership, and green-state gates still live only in PRD or tranche prose.
- The direct red-state repro is the current package state: no runtime verification owner exists under `src/`.
- The tasks that close this are task 2 and task 3.
- The verification artifact is a test that loads `PhyloMakie.VERIFICATION_FOUNDATION` and proves it contains the required top-level sections, all 7 PRD lock items, and all 3 target public surfaces with explicit not-yet-implemented status.

### Lock item 4: Repo-owned fixture corpus

- The work is not complete if later tranches would still need to recover their plot-sensitive fixtures from prose, screenshots, or upstream files instead of one repo-owned fixture corpus.
- The direct red-state repro is the current package state: `test/` contains only `runtests.jl` with Aqua and JET; no fixture owner exists.
- The tasks that close this are task 3 and task 4.
- The verification artifact is a passing test that loads a dedicated fixture corpus and proves it contains every named design acceptance scenario plus every named upstream helper-regression scenario required by this tranche handoff.

### Lock item 5: Target-surface matrix with honest deferral

- The work is not complete if the shared target public surfaces `phyloplot`, `phyloplot!`, and `plot(net)` are not explicitly enumerated with honest deferred proof ownership and explicit not-yet-implemented status.
- The direct red-state repro is the current package state: no source owner or docs page records those three surfaces at all.
- The tasks that close this are task 2, task 3, and task 4.
- The verification artifact is a source-backed matrix that names all three target surfaces, records `implemented = false`, records that Tranche 5 owns their direct proof closure, and is consumed by both tests and docs.

### Lock item 6: Fake-green prevention

- The work is not complete if the repository can still go green with only Aqua, JET, and boilerplate docs while plotting-proof obligations remain unowned.
- The direct red-state repro is the current verification surface: Aqua, JET, a boilerplate docs home page, and no plot-sensitive contract tests.
- The tasks that close this are task 3 and task 4.
- The verification artifact is a suite that would fail the current placeholder state because `VERIFICATION_FOUNDATION`, the fixture corpus, and the docs-backed verification page do not yet exist there.

### Lock item 7: Honest docs scaffolding

- The work is not complete if docs remain a pure boilerplate landing page or if docs claim implemented plotting APIs that this tranche does not provide.
- The direct red-state repro is the current docs state: one boilerplate `index.md`, one-page `docs/make.jl`, and no plot-contract or verification-foundation scenarios.
- The tasks that close this are task 4 and, indirectly, task 2.
- The verification artifact is a passing docs build that renders a dedicated verification-foundation page from source-owned data and states the current deferred proof boundary honestly.

## Handoff packet

- Approval state: approved and executed; project-owner approval for both
  Tranche 1 in `02_tranches.md` and this tasking file was recorded on
  2026-05-09 via the explicit tranche-1 implementation request.
- Active authorities: `CONTRIBUTING.md`; repo-local `STYLE*.md`; `STYLE-vocabulary.md`; `STYLE-workflow-vocabulary.md`; `design/prod01-vision.md`; `design/prod01-vision-supplement.md`; `01_prd.md`; `02_tranches.md`.
- Parent documents: `01_prd.md`; `02_tranches.md`; `design/prod01-vision.md`; `design/prod01-vision-supplement.md`.
- Settled decisions and non-negotiables: preserve the `PhyloPlots.plot` public behavior target; keep `phyloplot`, `phyloplot!`, and `plot(net)` as the target public surfaces; keep `PhyloPlot` as the recipe type name; keep `HybridNetwork` as the only supported public input type; keep R interop out of scope; do not let foreign domain vocabulary enter project-owned assets; keep the root/test/docs project split and `[sources.PhyloMakie] path = "../"` overrides; use documented public `Pkg` operations to curate the local project environments.
- Authorization boundary: deep internal redesign is allowed; public behavior drift is not; compatibility aliases are not required; this tranche must not implement the plotting API itself.
- Historical tranche-start diagnosis: `src/PhyloMakie.jl` was an empty shell;
  `test/runtests.jl` was Aqua/JET-only and the `test/` project was not
  runnable from its own manifest; docs were boilerplate-only; there was no
  plotting-specific verification owner.
- Primary-goal lock: the 7 lock items above.
- Historical tranche-start red-state repros: no `VERIFICATION_FOUNDATION`; no
  fixture corpus; no target-surface matrix; no docs verification page; no
  plot-sensitive tests; stale `test/Manifest.toml`; pure boilerplate docs; no
  recorded project-owner approval gate in the tasking file.
- Owner and invariant under repair: verification ownership, fixture ownership, honest deferred-proof ownership, and thin-module ownership.
- Target public surfaces affected by this owner boundary: `phyloplot`, `phyloplot!`, and `plot(net)` via Makie dispatch. This tranche must record all three as target surfaces with `implemented = false`. It must not implement direct proofs for them yet.
- Exact files or surfaces in scope: `src/PhyloMakie.jl`; new source files under `src/`; `test/Project.toml`; `test/Manifest.toml`; `test/runtests.jl`; new files under `test/`; `docs/make.jl`; `docs/src/`; the workflow docs created by this file.
- Exact files or surfaces out of scope: recipe implementation; render primitives; keyword normalization logic; layout computation; annotation rendering; R interoperability; `sexp`; `rexport`; support for non-`HybridNetwork` input types; performance tuning; GraphMakie as a goal in itself; `README.md`; parent PRD and tranche files.
- Required upstream primary sources: `PhyloPlots.jl/src/phylonetworksPlots.jl`; `PhyloPlots.jl/src/plotRCall.jl`; `PhyloPlots.jl/test/test_phylonetworkPlots.jl`; `PhyloNetworks.jl/src/types.jl`; `PhyloNetworks.jl/src/manipulateNet.jl`; `PhyloNetworks.jl/docs/src/man/net_plot.md`; `~/.julia/packages/Makie/FUAHr/MakieCore/src/recipes.jl`; `~/.julia/packages/Makie/TOy8O/src/figureplotting.jl`.
- Upstream contract conclusions already settled for this tranche: Makie `@recipe(PhyloPlot, net)` generates `phyloplot` and `phyloplot!`; Makie non-mutating plotting returns `FigureAxisPlot`; Makie bang plotting targets an axis-like owner; `PhyloPlots` owns the authoritative keyword surface and current helper-regression fixtures; `PhyloNetworks.directedges!` and `preorder!` are the current mutation owners used by the legacy plotting path.
- Green-state gates: runnable `test/` project; package tests; Aqua; JET; docs build.
- Stop conditions during implementation: stop if making the verification owner
  runnable requires implementing recipe, keyword, layout, or render logic;
  stop if the fixture corpus cannot be encoded without importing out-of-scope
  R behavior; stop if a later tranche would still need to infer target
  surfaces or scenario IDs from prose alone; stop if docs would need to lie
  about implemented plotting behavior to stay green.

## Required revalidation before implementation

- Read `02_tranches.md` and `01_prd.md` in full.
- Confirm that project-owner approval is recorded for both Tranche 1 in
  `02_tranches.md` and this tasking file. For the executed tranche-1 run, this
  approval was recorded on 2026-05-09.
- Read all governance files named above line by line.
- Re-read `src/PhyloMakie.jl`, `test/runtests.jl`, `docs/src/index.md`, `docs/make.jl`, `test/Project.toml`, and `test/Manifest.toml` in full.
- Re-read the upstream sources named in the handoff packet, especially the `PhyloPlots` helper tests and the Makie recipe and `FigureAxisPlot` source files.
- Re-check the user-authorized disruption boundary before making any deep source-layout change.
- Re-check that no public plotting code, recipe implementation, or keyword implementation already landed in the repo before starting. If it did, stop and rewrite this tasking against current reality.
- Re-check that the `test/` project still reproduces the current manifest failure before claiming to fix it. If that failure no longer reproduces, stop and update the tasking honestly instead of preserving a stale red-state repro.

## Tranche execution rule

This tranche could redesign the source layout and verification ownership
deeply, but it remained proposed planning output until the project owner
approved it on 2026-05-09. After approval for execution, it had to begin and
end in a green, policy-compliant state for its scope.

When this tranche completes:

- the placeholder comment in `src/PhyloMakie.jl` must no longer exist;
- the top-level module file must no longer be the effective owner of plotting logic or verification prose;
- the repo must have one canonical source-side verification owner and one canonical test-side fixture owner;
- docs must be brought into truth with the tranche-1 implementation state rather than widening the API surface to match aspirational docs.

Forbidden anti-fixes in this tranche:

- adding plotting stubs or fake exports merely to make docs or tests look more feature-complete;
- keeping the scenario matrix only in comments, PR text, or workflow prose;
- replacing a missing verification owner with grep checks or string-policing tests;
- solving the stale `test/` baseline by telling contributors to use a global environment instead of fixing the repo-local `test/` project.

## Non-negotiable execution rules

- Do not implement `phyloplot`, `phyloplot!`, `plot(net)`, `Makie.plottype`, or `@recipe` behavior in this tranche.
- Do not add keyword normalization, layout computation, render-adapter logic, or annotation rendering logic in this tranche.
- Do not recreate retired placeholder ownership through comments, prose-only TODO inventories, or compatibility shims.
- Do not move product logic into tests or docs.
- Do not broaden the package dependency surface unless a named task in this file requires it.
- Do not hand-edit `test/Manifest.toml` or `docs/Manifest.toml` unless an explicit review or escalation note records that no documented public `Pkg` operation can satisfy the required environment repair.
- Do not change the root/test/docs project split.
- Do not modify `01_prd.md` or `02_tranches.md`.

## Concrete anti-patterns or removal targets

- The placeholder comment in `src/PhyloMakie.jl`.
- The current no-owner module shell as the long-term owner shape.
- `test/runtests.jl` as the sole verification owner for plotting work.
- `docs/src/index.md` as a pure boilerplate landing page with no plot-contract or verification-foundation content.
- The stale `test/Manifest.toml` state in which `PhyloMakie` is a direct dependency that does not resolve into a runnable test project.
- Any source-owned or docs-owned matrix that records only one of `phyloplot`, `phyloplot!`, or `plot(net)` while leaving the sibling surfaces implicit.
- Any source-owned or docs-owned matrix that marks a tranche-1 target surface as already implemented or already proven.
- Any source or docs artifact that records acceptance scenarios without also recording the direct red-state repro or later-tranche proof owner.
- Any docs-only or test-only duplicate of the canonical source-side verification matrix.

## Failure-oriented verification

- `julia --project=test test/runtests.jl` must fail the current repository state and must stop failing once task 1 and task 3 are complete.
- A repository state that adds only Aqua, JET, or prose comments but no `VERIFICATION_FOUNDATION` must fail the new shell and verification-owner tests.
- A repository state that adds only `VERIFICATION_FOUNDATION` but no fixture corpus must fail the new verification-foundation tests.
- A repository state that adds only a docs prose page but does not consume source-owned verification data must fail the docs-backed proof shape required by task 4.
- A repository state that records `phyloplot` but omits `phyloplot!` or `plot(net)` from the target-surface matrix must fail the target-surface completeness checks.
- A repository state that marks any of those three target surfaces as `implemented = true` in tranche 1 must fail the target-surface status checks and the docs truth-boundary checks.
- A repository state that claims green while docs still consist only of the boilerplate home page must fail the docs page and docs-build checks for the verification-foundation page.

Positive runtime and usability checks for this foundational cleanup:

- The `test/` project is runnable locally with no global-environment workaround.
- A new contributor can locate one source-side verification owner under `src/`, one fixture corpus under `test/`, and one truthful verification-foundation page under `docs/src/`.
- The docs build renders a human-readable verification matrix that records what exists now, what is deferred, and which tranche owns each deferred proof obligation.
- The docs build renders the target-surface matrix in a way that distinguishes planned target APIs from currently implemented tranche-1 assets.

## Tasks

### 1. Resolve the `test/` project baseline

**Type**: CONFIG
**Output**: The repo-local `test/` project resolves and runs `test/runtests.jl` without the current missing-manifest direct-dependency failure.
**Depends on**: none
**Positive contract**: `test/Project.toml` and `test/Manifest.toml` describe a runnable local test environment that keeps `[sources.PhyloMakie] path = "../"`, does not depend on a global environment, and was repaired through documented public `Pkg` operations from the `test/` environment.
**Negative contract**: the old failure shape must not survive; do not solve this by editing root or docs project state, by dropping the direct `PhyloMakie` dependency, by hand-editing `test/Manifest.toml`, or by documenting a manual global-environment workaround.
**Files**: `test/Project.toml`; `test/Manifest.toml`
**Out of scope**: `src/`; `docs/`; root `Project.toml`; any public plotting code; any test logic or fixture additions
**Verification**: `julia --project=test test/runtests.jl` must stop failing with the current `Package PhyloMakie ... is required but does not seem to be installed` error. The old repository state must still fail this check.

Update the `test/` project so it resolves `PhyloMakie` as a runnable direct dependency from the repo-local path override. Perform the repair from the `test/` environment with documented public `Pkg` operations such as `Pkg.resolve`, `Pkg.instantiate`, `Pkg.develop`, `Pkg.rm`, or `Pkg.add` as needed. Preserve the existing root/test/docs split and the existing `[sources.PhyloMakie]` policy. Do not add unrelated dependencies in this task. Do not hand-edit the manifest unless an explicit review or escalation note records that no public `Pkg` workflow can satisfy the repair. Leave the repository in a state where the test project can execute its current suite, even though the suite is still too shallow until later tasks replace the placeholder owner.

### 2. Establish the thin module shell and source-side verification owner

**Type**: WRITE
**Output**: `src/PhyloMakie.jl` becomes an include-only shell, and `src/verification_foundation.jl` defines the canonical unexported source-side verification owner.
**Depends on**: 1
**Positive contract**: `src/PhyloMakie.jl` imports only what this tranche needs, includes subordinate source files, and exposes one unexported immutable owner named `VERIFICATION_FOUNDATION`. `VERIFICATION_FOUNDATION` is a dependency-light `const` NamedTuple with exactly these top-level fields: `target_public_surfaces`, `lock_items`, `accepted_design_scenarios`, `upstream_helper_regressions`, `green_state_gates`, `current_red_state`, and `stop_conditions`.
**Negative contract**: the placeholder comment must not survive; do not export or stub `phyloplot`, `phyloplot!`, `plot(net)`, `PhyloPlot`, or Makie dispatch in this task; do not bury the scenario inventory in the top-level module file; do not use a mutable global or a free-form `Dict{Symbol,Any}` owner.
**Files**: `src/PhyloMakie.jl`; `src/verification_foundation.jl`
**Out of scope**: `test/`; `docs/`; Makie recipe code; keyword normalization; layout helpers; render code; public plotting entrypoints
**Verification**: a shell-level test must be able to import `PhyloMakie`, access `getfield(PhyloMakie, :VERIFICATION_FOUNDATION)`, and confirm the exact top-level field set above. The old placeholder state must fail this check because no such owner exists.

Refactor the module layout so `src/PhyloMakie.jl` becomes a thin owner shell and `src/verification_foundation.jl` owns the tranche-1 verification matrix. In `target_public_surfaces`, record exactly 3 entries: `phyloplot`, `phyloplot!`, and `plot(net)`. Each entry must record at least `implemented = false`, `direct_proof_deferred = true`, `direct_proof_owner = 5`, and `docs_visibility = :target_not_yet_implemented` so a downstream docs page cannot overstate current capability. In `lock_items`, record all 7 PRD lock items by number and title. In `accepted_design_scenarios`, record exactly these 8 scenario IDs from the design supplement: `:simple_tree_no_hybrid`, `:single_reticulation_gamma`, `:style_distinction_fulltree_vs_majortree`, `:useedgelength_scaling`, `:dataframe_label_rendering`, `:showgamma_rendering`, `:edgecolor_dict_fallback`, and `:composable_dual_axes`. In `upstream_helper_regressions`, record exactly these 7 upstream regression IDs from `PhyloPlots.jl/test/test_phylonetworkPlots.jl`: `:edgenode_coords_with_lengths_fulltree`, `:edgenode_coords_with_lengths_majortree`, `:edgenode_coords_without_lengths_majortree`, `:nodelabel_validation_and_prep`, `:edgelabel_validation_and_prep`, `:level2_network_with_gamma`, and `:level2_network_without_gamma`. Record the current red-state facts and stop conditions explicitly instead of leaving them in prose-only comments.

### 3. Replace the placeholder test owner with a fixture corpus and proof harness

**Type**: TEST
**Output**: `test/` gains a dedicated fixture corpus, mirrored test files for the tranche-1 source owners, and a test runner that makes Aqua and JET supplemental instead of sole proof owners.
**Depends on**: 1, 2
**Positive contract**: `test/runtests.jl` becomes an include-only orchestrator; `test/test_PhyloMakie.jl` and `test/test_verification_foundation.jl` mirror the source files; `test/support/fixture_corpus.jl` defines one canonical dependency-light `const FIXTURE_CORPUS = (...)` owner for the named scenario inventory; the suite proves source-owner completeness, target-surface completeness, target-surface status honesty, lock-item completeness, and fixture-corpus completeness.
**Negative contract**: do not add fake plotting tests against unimplemented APIs; do not make Aqua or JET the only plot-sensitive proof; do not encode the fixture corpus only in comments, markdown, or source-text assertions; do not require `RCall` or out-of-scope rendering machinery in this tranche.
**Files**: `test/runtests.jl`; `test/test_PhyloMakie.jl`; `test/test_verification_foundation.jl`; `test/support/fixture_corpus.jl`
**Out of scope**: docs scaffolding; actual plotting implementation; helper-function execution against missing layout code; image regression assets; keyword or layout logic
**Verification**: `julia --project=test test/runtests.jl` passes and includes explicit testsets for the shell owner, the verification owner, the fixture corpus, Aqua, and JET. The current placeholder repository must fail because neither `VERIFICATION_FOUNDATION` nor `FIXTURE_CORPUS` exists there.

Create a canonical fixture corpus under `test/support/fixture_corpus.jl` as plain Julia literals so this tranche does not need to add `RCall`, Makie rendering, parsed `HybridNetwork` objects, or `DataFrame` construction just to preserve the proof inventory. The corpus must contain the exact Newick strings and structured literal data needed for later tranches to build their direct proofs. Record at minimum these exact strings: `"(A,((B,C),(D,E)));"` for `:simple_tree_no_hybrid`; `"(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"` for `:single_reticulation_gamma`; `"(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);"` for the second composable example; `"((((B)#H1:::0.2)#H2,((D,C,#H2:::0.8)S1,(#H1,A)S2)S3)S4);"` and `"((((B)#H1:::0.2)#H2,((D,C,#H2)S1,(#H1,A)S2)S3)S4);"` for the two level-2 helper regressions. Also record literal node-label and edge-label row data plus the exact warning strings and expected helper-regression IDs derived from the upstream `PhyloPlots` test file. In the tests, assert that `VERIFICATION_FOUNDATION` names every scenario ID in the fixture corpus, that no target public surface is omitted, and that all three target public surfaces remain explicitly marked `implemented = false` in tranche 1.

### 4. Replace the boilerplate docs landing page with truthful verification scaffolding

**Type**: WRITE
**Output**: The docs build renders a dedicated verification-foundation page and a non-boilerplate home page that tell the truth about tranche-1 implementation state and deferred proof ownership.
**Depends on**: 2, 3
**Positive contract**: `docs/make.jl` includes `verification-foundation.md`; `docs/src/index.md` stops being boilerplate-only; `docs/src/verification-foundation.md` consumes `PhyloMakie.VERIFICATION_FOUNDATION` in executable Documenter blocks so the docs build proves source-backed ownership instead of hand-copied prose.
**Negative contract**: do not claim that `phyloplot`, `phyloplot!`, `plot(net)`, recipe code, keyword handling, layout helpers, or render adapters are already implemented; do not make docs the canonical owner of the matrix; do not solve the docs task with static text that can drift away from the source owner.
**Files**: `docs/make.jl`; `docs/src/index.md`; `docs/src/verification-foundation.md`
**Out of scope**: public API docs for working plotting functions; screenshot regression assets; recipe examples that require implemented plot behavior; `README.md`
**Verification**: `julia --project=docs docs/make.jl` passes and executes source-backed blocks that render the target-surface matrix, lock-item inventory, and deferred proof boundary. The current boilerplate docs state must fail this proof shape because the page and source-backed owner do not exist there.

Replace the current docs boilerplate with a truthful tranche-1 docs scaffold.
Keep the docs project lightweight and tied to the source-side owner rather
than to aspirational API examples. The home page must explain that Tranche 1
establishes the verification owner, fixture corpus, and thin-module shell
only, and that project-owner approval for the tranche-1 `Tasks -> Execute` run
was recorded on 2026-05-09. The dedicated verification-foundation page must
render, from `PhyloMakie.VERIFICATION_FOUNDATION`, the 3 target public
surfaces, the explicit `implemented = false` and deferred-proof status for
each, the 7 PRD lock items, the 8 design acceptance scenarios, the 7 upstream
helper-regression IDs, the green-state gates, and the stop conditions. Use
executable Documenter blocks so a stale or missing source-side owner breaks
the docs build instead of drifting silently.
