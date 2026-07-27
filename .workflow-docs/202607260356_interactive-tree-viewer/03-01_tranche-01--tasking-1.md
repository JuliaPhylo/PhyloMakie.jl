---
date-created: 2026-07-27T01:05:26-0700
workflow-instrument: Tasking plan
workflow-status: Approved
workflow-agent-thread-id: codex/019fa296-25cd-7582-83fa-fd5de661a498
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-production-id: reactive-tree-viewer
workflow-prd: .workflow-docs/202607260356_interactive-tree-viewer/01_prd.md
workflow-tranche: .workflow-docs/202607260356_interactive-tree-viewer/02_tranches.md
---

# Tasks for Tranche 1: Input records and CLI shell

## Settled user decisions and environment baseline

This tasking plan applies to Tranche 1 only. The supplied tranche file contains 5 tranches and no earlier tasking file exists in `.workflow-docs/202607260356_interactive-tree-viewer`, so Tranche 1 is the next un-tasked tranche.

Implementation must treat these decisions and baselines as fixed input:

- The package root is `/home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl`.
- The parent PRD and tranche plan are approved. This tasking plan remains proposed until the project owner changes `workflow-status` to `Approved`.
- The feature remains an example-layer addition for this tranche.
- The only project file this tranche may create or modify is `examples/src/05_interactive_ex1.jl`.
- Do not change `src/`, `test/`, `docs/`, `Project.toml`, `Manifest.toml`, `examples/Project.toml`, or `examples/Manifest.toml`.
- Do not add dependencies.
- Do not add a command-line option parser package.
- Do not implement a custom tree or network parser.
- Use PhyloNetworks readers: `readnexus_treeblock`, `readmultinewick(path, false)`, and `readnewick`.
- Do not call `directedges!` or `preorder!` on user-loaded `HybridNetwork` records in this example.
- Tranche 1 must create the include-safe CLI and loader shell. It must not create GLMakie widgets, a figure, an axis, or a display window. Tranche 2 owns viewer construction.
- In Tranche 1, successful `main(args)` calls must load records, report a concise loaded-record count, and return `0` without displaying. Tranche 2 will replace the successful path with viewer construction.

## Governance

Downstream implementation must read and conform to these project governance documents line by line before changing files:

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

The bundled development-policy style files with matching names were checked and match the project-local copies by content. The bundled depot does not provide `CONTRIBUTING.md` or `STYLE-vocabulary.md`; the project-local files are authoritative for those.

Archived governance files under `../00-archives/` and `../PhyloNetworks.jl/CONTRIBUTING.md` were found by broad search but are not active authorities for this PhyloMakie tasking plan.

Read-only git and shell commands may be used freely. Mutating git operations such as commit, merge, push, branch creation, checkout, reset, and rebase remain the human project owner's responsibility unless the user explicitly instructs otherwise.

## Primary-goal lock

### Lock item 1: Include-safe executable shell

- The work is not complete if `examples/src/05_interactive_ex1.jl` is absent, cannot be included without exiting the Julia process, or lacks `main(args = ARGS)::Int` plus a program-file guard equivalent to `if abspath(PROGRAM_FILE) == @__FILE__; exit(main()); end`.
- Red-state repro: current examples `examples/src/03_mwe_reactivity_phylomakie.jl` and `examples/src/04_maxwe_reactivity_phylomakie.jl` are fixed scripts with hardcoded networks and no reusable CLI entrypoint.
- Tasks that close it: Tasks 1 and 3.
- Verification artifact: `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl"); @assert main(String[]) == 0'` succeeds without opening a window or exiting during include.

### Lock item 2: PhyloNetworks reader orchestration and deterministic records

- The work is not complete if `load_records_from_file(path::AbstractString)` is not the single authoritative implementation in `examples/src/05_interactive_ex1.jl` that chooses between `readnexus_treeblock`, `readmultinewick(path, false)`, and `readnewick`.
- Red-state repro: existing examples only call `readnewick` on inline strings and cannot load a deterministic positional file list.
- Tasks that close it: Tasks 1, 2, and 4.
- Verification artifact: helper smoke creates temporary single-Newick, multi-Newick, and NEXUS files, calls `load_records`, and fails if record counts, file order, record order, `source`, or one-based `record_index` metadata are wrong.

### Lock item 3: Routine input failure reporting

- The work is not complete if missing files, unreadable files, parse failures, all-failed input, or partial success can reach a routine upstream stack trace or silently discard a user-provided path.
- Red-state repro: without a wrapper, passing an unreadable path to an upstream reader can raise directly before the example can report path-specific status.
- Tasks that close it: Tasks 2, 3, and 4.
- Verification artifact: `main([missing_path])` returns nonzero, emits a concise message containing the missing path, and does not import or construct GLMakie display objects in this tranche. A valid path plus an invalid path returns `0`, loads the valid record, and reports the invalid path.

### Lock item 4: Upstream ownership boundary

- The work is not complete if the example hand-parses Newick or NEXUS syntax, calls PhyloNetworks topology mutators on user-loaded records, or creates a second local interpretation of PhyloNetworks reader behavior.
- Red-state repro: a local parser or direct `directedges!` / `preorder!` call could make simple fixtures pass while bypassing PhyloNetworks-owned parsing and mutation contracts.
- Tasks that close it: Tasks 2 and 4.
- Verification artifact: source audit shows no calls to `directedges!`, `preorder!`, GLMakie display construction, or custom parser helpers, and the loader smoke proves NEXUS and multi-Newick behavior through PhyloNetworks readers.

### Lock item 5: Example-layer and environment scope

- The work is not complete if implementation changes package internals, public APIs, tests, docs, manifests, or example environment files to satisfy this tranche.
- Red-state repro: changing `src/` or project environments to support the loader would broaden an example-layer tranche beyond the approved scope.
- Tasks that close it: Tasks 1 through 4.
- Verification artifact: `git -C . diff --name-only` from `workflow-location` shows only `examples/src/05_interactive_ex1.jl` as the implementation change for this tranche, excluding this proposed workflow tasking file if it is already present.

### Lock item 6: Tranche-scoped verification is not source-only

- The work is not complete if success is declared from source inspection alone, without running include, loader, and CLI failure smokes in the examples environment.
- Red-state repro: a script can contain the right function names and still fail on include, fail to parse representative files, or exit with the wrong code for all-failed input.
- Tasks that close it: Task 4.
- Verification artifact: Task 4 commands run under `julia --project=examples` and include direct helper calls plus direct CLI behavior.

## Forbidden passing implementation table

| Lock item | Required behavior | Current code state | Resolved implementation instruction | Forbidden passing implementation | Failing verification artifact |
| --- | --- | --- | --- | --- | --- |
| Include-safe executable shell | `examples/src/05_interactive_ex1.jl` defines `main(args = ARGS)::Int` and only calls `exit(main())` behind the program-file guard. Including the file must define helpers without exiting or displaying. | `examples/src/05_interactive_ex1.jl` does not exist. Existing reactivity examples execute fixed top-level plotting code. | Create `examples/src/05_interactive_ex1.jl`; define helper functions and `main(args = ARGS)::Int`; add the exact program-file guard only after `main` exists. Do not import GLMakie in Tranche 1. | A script that loads records at top level, calls `exit`, or opens a GLMakie window when included can appear executable but cannot be smoke-tested or reused by later tranches. | `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl"); @assert main(String[]) == 0'` fails or exits during include. |
| PhyloNetworks reader orchestration and deterministic records | `load_records_from_file` chooses the reader once; `load_records` preserves path order and reader-returned order and wraps each network as `ViewerRecord(network, source, record_index)`. | Existing examples call `readnewick` on inline strings only; no file-list loader exists. | Define `ViewerRecord` with `network::HybridNetwork`, `source::String`, and `record_index::Int`. Define `contains_nexus_treeblock(path)` using the upstream-compatible trees-block marker regex. Define `load_records_from_file(path)::Vector{HybridNetwork}` with NEXUS, multi-Newick, then single-Newick fallback. Define `load_records(paths)::Tuple{Vector{ViewerRecord}, Vector{LoadWarning}}`. | A loader that calls `readnewick` for every path can pass a single-Newick smoke while failing multi-Newick and NEXUS files. A loader that sorts paths or flattens metadata can pass count checks while breaking navigation labels. | Helper smoke with one single-Newick file, one multi-Newick file, and one NEXUS tree-block file checks record counts, order, `source`, and one-based `record_index`. |
| Routine input failure reporting | Missing, unreadable, unparsable, all-failed, and partial-success cases return structured warnings or nonzero exit status with path-specific messages. | No loader wrapper exists; upstream reader errors would reach callers directly if used naively. | Define `LoadWarning` with `path::String` and `message::String`. `load_records` catches per-path failures into `LoadWarning` objects. `main(args)` returns nonzero only when user-provided paths yield no records; partial success emits warnings and returns `0`. | A loader that catches all errors and returns an empty vector silently avoids stack traces but gives users no path-specific feedback. A CLI that exits `0` on all-failed input can pass include smoke while violating the failure contract. | `main([missing_path]) != 0` and captured stderr or stdout contains the missing path. A valid path plus missing path returns `0`, yields valid records through `load_records`, and produces one `LoadWarning`. |
| Upstream ownership boundary | The example delegates parsing to PhyloNetworks readers and does not call topology mutators on user-loaded records. | `readwrite.jl` owns reader semantics; `manipulateNet.jl` documents `directedges!` and `preorder!` as mutating topology operations. The new example file is absent. | Import only `HybridNetwork`, `readnewick`, `readmultinewick`, and `readnexus_treeblock` from PhyloNetworks for Tranche 1. Do not import or call `directedges!` or `preorder!`. Do not add local grammar parsing helpers. | A local `split`-based Newick loader or manual NEXUS scanner could satisfy tiny fixtures while misreading valid upstream syntax. A direct mutator call could make later plotting work while modifying caller-loaded records. | Source audit for `directedges!`, `preorder!`, GLMakie display construction, and custom parser helpers is clean; helper smoke exercises the upstream readers on representative files. |
| Example-layer and environment scope | The implementation diff for Tranche 1 is limited to `examples/src/05_interactive_ex1.jl`. | `git status --short` is clean before tasking; `examples/Project.toml` already contains GLMakie, PhyloMakie, and PhyloNetworks with `PhyloMakie = {path = ".."}`. | Do not edit manifests, package source, tests, docs, workflow parents, or dependency files while implementing this tranche. | Adding a dependency, changing `src/plot_config.jl`, or editing tests can make the loader easier to verify while violating the approved example-layer scope. | `git -C . diff --name-only` from `workflow-location` shows only `examples/src/05_interactive_ex1.jl` for Tranche 1 implementation changes. |
| Tranche-scoped verification is not source-only | Include, helper, and CLI smokes run in the examples environment and fail the known bad shapes. | No task-level verification exists yet for the new example because the file is absent. | Run the exact Task 4 verification commands under `julia --project=examples` and record results in the implementation report. | Declaring success after `rg` finds the right helper names would miss syntax errors, wrong return types, wrong exit codes, or upstream-reader incompatibility. | Task 4 fails unless include smoke, loader smoke, CLI no-args smoke, CLI missing-path smoke, and source audits all pass. |

## Handoff packet

- **Active authorities**: user request; `development-policies`; `devflow-feature-03--tranche-to-tasks`; parent PRD; parent tranche plan; all project governance documents listed above.
- **Parent documents**: `.workflow-docs/202607260356_interactive-tree-viewer/01_prd.md`; `.workflow-docs/202607260356_interactive-tree-viewer/02_tranches.md`.
- **Settled decisions and non-negotiables**: Tranche 1 creates only the include-safe CLI and loader shell; viewer construction belongs to Tranche 2; no new dependencies; no package API changes; no custom parser; no direct topology mutation; no source, test, docs, manifest, or environment edits.
- **Authorization boundary**: implementation may create and modify `examples/src/05_interactive_ex1.jl` only.
- **Current-state diagnosis**: the target example file is absent; existing examples are hardcoded reactivity demonstrations with no positional file loading and no reusable CLI entrypoint.
- **Primary-goal lock**: lock items 1 through 6 in this tasking file.
- **Direct red-state repros**: current examples have no CLI file list; naive upstream reader calls throw directly on routine file failures; `readnewick`-only loading misses multi-Newick and NEXUS support; a source-only review could miss failing include or exit behavior.
- **Responsible entities and invariants**: `load_records_from_file` is the single authoritative implementation in the example for reader selection; `load_records` is the single authoritative implementation for path-order aggregation, metadata wrapping, partial success, and warning collection; `main(args = ARGS)::Int` is the single authoritative implementation for CLI exit behavior. No other helper in the script may choose readers, wrap file records, or compute CLI success status independently.
- **Exact files in scope**: `examples/src/05_interactive_ex1.jl`.
- **Exact files and surfaces out of scope**: `src/`, `test/`, `docs/`, `Project.toml`, `Manifest.toml`, `examples/Project.toml`, `examples/Manifest.toml`, parent workflow documents, package public APIs, GLMakie viewer construction, widget callbacks, `Makie.update!`, and all future control-panel work.
- **Required upstream primary sources**: `../PhyloNetworks.jl/src/readwrite.jl` for `readnewick`, `readmultinewick`, and `readnexus_treeblock`; `../PhyloNetworks.jl/src/manipulateNet.jl` for `directedges!` and `preorder!`.
- **Green-state gates**: include smoke, loader smoke for single-Newick, multi-Newick, and NEXUS inputs, CLI no-argument smoke, CLI missing-path smoke, source audit for forbidden mutation and viewer construction, and final diff scope review.
- **Stop conditions**: stop if loader behavior requires a new dependency, direct parsing, package-source changes, mutation of caller-owned `HybridNetwork` records, or an implementation decision that contradicts the parent PRD or governance documents.

## Required revalidation before implementation

- Read the parent PRD and parent tranche plan in full.
- Read `examples/src/03_mwe_reactivity_phylomakie.jl`, `examples/src/04_maxwe_reactivity_phylomakie.jl`, and `examples/Project.toml` in full.
- Read `../PhyloNetworks.jl/src/readwrite.jl` around `readnewick`, `readmultinewick`, and `readnexus_treeblock` in full.
- Read `../PhyloNetworks.jl/src/manipulateNet.jl` around `directedges!` and `preorder!` in full.
- Re-check that `examples/src/05_interactive_ex1.jl` is still absent or reconcile with any user-created version before editing.
- Re-check that no earlier tasking file for Tranche 1 was added after this tasking plan was written.
- If the tranche diagnosis no longer matches current source, stop before editing and raise the mismatch.

The tasking agent ran a reader smoke under `julia --project=examples` before saving this file. It verified representative `readnewick`, `readmultinewick(path, false)`, and `readnexus_treeblock` behavior against temporary files.

## Tranche execution rule

The tranche begins with no `examples/src/05_interactive_ex1.jl` file and must end with an include-safe CLI and loader shell in that file. It must remain green for the examples-project checks listed here. Full viewer behavior is intentionally outside Tranche 1 and must not be faked with placeholder GLMakie construction.

The example layer owns CLI argument handling, demo records, file-loading orchestration, warning collection, and exit status for this script. PhyloNetworks owns parsing and topology mutation. PhyloMakie owns plotting behavior. Makie and GLMakie own viewer construction in later tranches.

## Non-negotiable execution rules

- Do not modify any file except `examples/src/05_interactive_ex1.jl`.
- Do not create `build_viewer`, widget helpers, figure layout, axes, buttons, sliders, menus, textboxes, or GLMakie display calls in Tranche 1.
- Do not import GLMakie in Tranche 1.
- Do not call `plot!`, `phyloplot!`, `Makie.update!`, `empty!`, `delete!`, or axis-clearing functions in Tranche 1.
- Do not call `directedges!` or `preorder!` on loaded records.
- Do not parse tree syntax manually.
- Do not catch errors without preserving path-specific feedback.
- Do not treat source inspection as the only verification.

## Concrete anti-patterns or removal targets

The following forbidden shapes must not appear in `examples/src/05_interactive_ex1.jl` after Tranche 1:

- top-level record loading that executes during `include`
- top-level `exit`, `display`, `Figure`, `Axis`, `plot!`, or `phyloplot!`
- more than one reader-selection implementation
- a `readnewick`-only file loader
- sorting or deduplicating user-provided path order
- local Newick or NEXUS grammar parsing
- direct calls to `directedges!` or `preorder!`
- silent `catch` blocks that erase path information
- changes to dependency or package environment files

## Failure-oriented verification

These checks must fail the known bad implementations:

- A script with top-level execution fails the include smoke.
- A `readnewick`-only loader fails the multi-Newick and NEXUS helper smoke.
- A loader that sorts paths fails the ordered metadata helper smoke.
- A loader that silently drops bad paths fails the partial-success warning smoke.
- A CLI that returns success for all-failed input fails the missing-path smoke.
- A source-only fake fix fails Task 4 because the examples-project commands must execute.
- A tranche that edits package internals fails the final diff scope review.

Positive tranche success is also required: a maintainer can include the new file, call the loader helpers from the examples environment, and direct-run the script to validate CLI success and failure behavior without opening a GLMakie window in this tranche.

## Tasks

### 1. Create include-safe records and demo data

**Type**: WRITE
**Output**: `examples/src/05_interactive_ex1.jl` exists, includes without side effects, and defines concrete record and warning types plus demo records.
**Depends on**: none
**Positive contract**: Including the file defines `ViewerRecord`, `LoadWarning`, and `demo_records()::Vector{ViewerRecord}`. `demo_records()` returns at least 2 records: one tree and one reticulate network, both created through PhyloNetworks `readnewick`.
**Negative contract**: The file must not run `main`, call `exit`, import GLMakie, create a figure, display anything, load user files, or define placeholder viewer functions.
**Files**: `examples/src/05_interactive_ex1.jl`
**Out of scope**: `load_records_from_file`, `load_records`, `main`, program-file guard, GLMakie viewer construction, package source, tests, docs, manifests, and environment files.
**Verification**: `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl"); records = demo_records(); @assert length(records) >= 2; @assert all(r -> r.network isa HybridNetwork, records); @assert first(records).source == "demo"; @assert first(records).record_index == 1'`

Create `examples/src/05_interactive_ex1.jl` with explicit imports from PhyloNetworks: `HybridNetwork`, `readnewick`, `readmultinewick`, and `readnexus_treeblock`. Define immutable concrete structs `ViewerRecord` and `LoadWarning`. `ViewerRecord` must have `network::HybridNetwork`, `source::String`, and `record_index::Int`. `LoadWarning` must have `path::String` and `message::String`. Define `demo_records()::Vector{ViewerRecord}` using inline extended-Newick strings and `readnewick`; the first demo record must be a tree and the second must be a reticulate network, with `source == "demo"` and one-based `record_index` values. Do not add `main` or the program-file guard in this task because the loader and CLI exit behavior do not exist yet.

### 2. Implement reader selection and record aggregation

**Type**: WRITE
**Output**: File and path loaders exist and return ordered records plus warnings without direct topology mutation.
**Depends on**: Task 1
**Positive contract**: `contains_nexus_treeblock(path::AbstractString)::Bool`, `load_records_from_file(path::AbstractString)::Vector{HybridNetwork}`, and `load_records(paths::AbstractVector{<:AbstractString})::Tuple{Vector{ViewerRecord}, Vector{LoadWarning}}` exist. NEXUS files use `readnexus_treeblock`; non-NEXUS files use `readmultinewick(path, false)` and fall back to `readnewick(path)` only when multi-Newick returns no records.
**Negative contract**: No second helper may choose readers. No helper may sort paths, deduplicate paths, hand-parse tree syntax, call `directedges!`, call `preorder!`, or swallow path-specific failures.
**Files**: `examples/src/05_interactive_ex1.jl`
**Out of scope**: CLI `main`, program-file guard, terminal output formatting, GLMakie viewer construction, widget state, package source, tests, docs, manifests, and environment files.
**Verification**: `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl"); mktemp() do p1, io1; write(io1, "(A,B);\\n"); close(io1); records, warnings = load_records([p1]); @assert isempty(warnings); @assert length(records) == 1; @assert records[1].source == p1; @assert records[1].record_index == 1; end; mktemp() do p2, io2; write(io2, "(A,B);\\n(A,(B,C));\\n\\nnot-newick\\n"); close(io2); records, warnings = load_records([p2]); @assert isempty(warnings); @assert length(records) == 2; @assert getfield.(records, :record_index) == [1, 2]; end; mktemp() do p3, io3; write(io3, "#NEXUS\\nBegin trees;\\nTree t1 = (A,B);\\nTree t2 = (A,(B,C));\\nEnd;\\n"); close(io3); records, warnings = load_records([p3]); @assert isempty(warnings); @assert length(records) == 2; @assert getfield.(records, :record_index) == [1, 2]; end'`

Implement `contains_nexus_treeblock` as a line scan for the same trees-block marker shape used by PhyloNetworks: `r"^\\s*begin\\s+trees\\s*;"i`. This helper only detects the NEXUS trees block; it must not parse trees. Implement `load_records_from_file` as the only reader-selection function. If `contains_nexus_treeblock(path)` is true, return `readnexus_treeblock(path)`. Otherwise call `readmultinewick(path, false)` first; if it returns a nonempty vector, return it; if it returns an empty vector, call `readnewick(path)` and return a one-element vector. Implement `load_records` so it iterates over the provided paths in order, calls `load_records_from_file` once per path, converts returned networks into `ViewerRecord` values with `source == String(path)` and one-based `record_index` per file, catches whole-file failures into `LoadWarning(String(path), sprint(showerror, err))`, and returns `(records, warnings)`.

### 3. Add CLI exit behavior and reporting

**Type**: WRITE
**Output**: `main(args = ARGS)::Int` and the program-file guard exist and satisfy Tranche 1 CLI behavior.
**Depends on**: Tasks 1 and 2
**Positive contract**: `main(String[])` loads demo records and returns `0`. `main(paths)` loads user paths, reports warnings, returns `0` when at least 1 record loads, and returns nonzero when user-provided paths yield no records. The program-file guard calls `exit(main())` only when the file is run directly.
**Negative contract**: `main` must not create a viewer, import GLMakie, open a window, hide routine failures behind stack traces, return `0` for all-failed user input, or execute during `include`.
**Files**: `examples/src/05_interactive_ex1.jl`
**Out of scope**: GLMakie viewer construction, widget controls, `Makie.update!`, source package changes, tests, docs, manifests, and environment files.
**Verification**: `julia --project=examples -e 'include("examples/src/05_interactive_ex1.jl"); @assert main(String[]) == 0; missing = joinpath(tempdir(), "phylomakie-missing-05-interactive-ex1.newick"); @assert main([missing]) != 0; mktemp() do p, io; write(io, "(A,B);\\n"); close(io); records, warnings = load_records([p, missing]); @assert length(records) == 1; @assert length(warnings) == 1; @assert warnings[1].path == missing; @assert main([p, missing]) == 0; end'` and direct run `julia --project=examples examples/src/05_interactive_ex1.jl` exits `0`.

Implement `emit_load_warnings(warnings::AbstractVector{LoadWarning})::Nothing` to print each warning with its path. Define `main(args = ARGS)::Int` with an explicit return type. With no arguments, call `demo_records()`, print a concise loaded-record count, and return `0`. With arguments, call `load_records(args)`, print path-specific warnings, and return `0` only when at least 1 record loads. When no user-provided path yields a record, print a concise path-aware error and return `1`. Add the program-file guard after `main`. Do not call `display`, `wait`, `Figure`, `Axis`, `plot!`, or `phyloplot!`; Tranche 2 owns viewer construction.

### 4. Verify loader contract and tranche scope

**Type**: TEST
**Output**: The implementation report has passing include, helper, CLI, source-audit, and diff-scope verification for Tranche 1.
**Depends on**: Tasks 1 through 3
**Positive contract**: The exact examples-project smokes execute successfully and prove include safety, demo loading, single-Newick loading, multi-Newick loading, NEXUS loading, partial success, all-failed nonzero exit behavior, and path-specific warnings.
**Negative contract**: Do not add or edit test files for this tranche. Do not substitute source inspection for execution. Do not declare success if package source, tests, docs, manifests, or environment files changed.
**Files**: No project files may be touched in this task.
**Out of scope**: Changing implementation code, adding tests, modifying workflow documents, starting GLMakie, or broadening verification into later viewer controls.
**Verification**: Run the three commands from Tasks 1 through 3. Also run `julia --project=examples examples/src/05_interactive_ex1.jl /tmp/phylomakie-missing-05-interactive-ex1.newick` and confirm it exits nonzero while printing `/tmp/phylomakie-missing-05-interactive-ex1.newick`. Also run `rg -n 'directedges!|preorder!|GLMakie|Figure\\(|Axis\\(|plot!|phyloplot!|Makie\\.update!|empty!|delete!' examples/src/05_interactive_ex1.jl` from `workflow-location` and confirm no matches for Tranche 1. Run `git -C . diff --name-only` from `workflow-location` and confirm the only implementation file changed by this tranche is `examples/src/05_interactive_ex1.jl`.

Run all verification under the examples environment from `workflow-location`. Record command results in the implementation report. If source audit finds a forbidden identifier only inside a required explanatory string or comment, remove that string or comment rather than weakening the audit, because Tranche 1 does not need those viewer or mutator names in the example source. If any command fails because the tasking diagnosis no longer matches current code, stop and report the mismatch instead of broadening scope.
