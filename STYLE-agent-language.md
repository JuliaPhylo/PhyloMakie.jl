# STYLE-agent-language.md

## Purpose

This document governs technical prose written by agents and contributors in
workflow documents, handoff packets, reviews, audits, implementation reports,
and user-facing explanations.

Its purpose is to prevent agents from replacing concrete engineering thought
with informal shorthand. Technical prose must name the specific code entity,
responsibility, rule, and verification condition whenever those details affect
scope, design, or completion.

This document supplements every `STYLE*.md` document that uses technical
responsibility language. It is especially coupled to `STYLE-writing.md`,
`STYLE-architecture.md`, `STYLE-agent-handoffs.md`, `STYLE-workflow-docs.md`,
`STYLE-workflow-vocabulary.md`, `STYLE-upstream-contracts.md`,
`STYLE-verification.md`, `STYLE-makie.md`, `STYLE-julia.md`, and
`STYLE-vocabulary.md` when that file is present.

Any downstream workflow document, handoff, review, audit, implementation
report, or user-facing explanation that cites another style document must also
apply this document when the prose uses the terms listed below.

## Core rule

Do not use architectural shorthand as a substitute for a concrete statement.

If a sentence says that an owner, wrapper, layer, contract, boundary,
semantic, source, invariant, or path does something, the sentence must also
say what exact function, type, module, file, public surface, or external
contract is meant when that detail matters.

Incorrect:

> The computation owner is the real source of truth.

Correct:

> The function `resolve_plot_config` is the only implementation allowed to
> calculate keyword defaults and validate keyword values. Other functions may
> call `resolve_plot_config` and adapt its return value, but they must not keep
> separate defaulting or validation logic.

## Required specificity

When a prose statement assigns responsibility, it must answer these questions
when they are relevant:

- Which code entity has the responsibility?
- What exact value, invariant, rule, or behavior does it calculate, validate,
  store, mutate, or expose?
- Which callers or public surfaces consume that value, invariant, rule, or
  behavior?
- Which older code paths, duplicated implementations, or fallback paths must
  stop owning the same responsibility?
- What verification artifact fails if the responsibility remains duplicated,
  vague, or assigned to the wrong entity?

Do not rely on the reader to infer these answers from a phrase such as
"the owner", "the layer", "the wrapper", "the correct path", or "the real
implementation".

## Use of owner

Use "owner" only in the architectural sense defined by the active style
documents: the code entity or layer responsible for a specific invariant,
contract, policy, or behavior.

Do not use "owner" as a vague synonym for "function", "file", "module", or
"place in the code". If the responsible entity is a function, say "the function
`name`". If it is a type, say "the type `Name`". If it is a module or file,
say "the module" or "the file" and name it.

Acceptable:

> The function `compute_data_limits` calculates the `Makie.Rect3d` limits from
> the resolved plot configuration and computed plot extent.

Acceptable when architectural responsibility matters:

> The function `compute_data_limits` owns data-limit calculation. Render code
> may apply the returned limits to an axis, but render code must not calculate
> those limits independently.

Unacceptable:

> The limit owner handles limits.

## Use of wrapper

Do not write "wrapper" unless the prose names the old entry point, the new
entry point it calls, the behavior it may perform, and the behavior it must not
perform.

A transitional wrapper is an old function or type name that remains only
because immediate removal would force unrelated work into the current tranche
or task. It is temporary. It is allowed only when the old name calls the named
new implementation and performs return-shape adaptation or current integration
side effects.

A transitional wrapper must not independently calculate, validate, default,
mutate, or otherwise reimplement the behavior assigned to the new
implementation.

Incorrect:

> Keep bounded transitional wrappers around the new owners.

Correct:

> The function `resolve_phylo_plot_attributes` may remain during this tranche
> only if it calls `resolve_plot_config` and adapts the returned
> `PhyloPlotConfig` into the old return shape. It must not keep independent
> keyword defaulting, style validation, edge-color resolution, or limit
> validation logic.

## Avoid source of truth for code responsibility

Do not use "real source of truth" or "source of truth" to describe code
responsibility.

Use "single authoritative implementation" when the point is that exactly one
code entity implements a calculation or validation rule.

Use "upstream primary source" when the point is external evidence from
documentation, source code, standards, or an upstream project.

Incorrect:

> The new computation owner is the real source of truth.

Correct:

> `compute_network_geometry` is the single authoritative implementation for
> node and edge coordinate calculation. `layout_plot_geometry` may call
> `compute_network_geometry` while it remains as a compatibility entry point,
> but it must not keep a separate coordinate calculation.

## Terms that require expansion

The following words and phrases are allowed only when the prose expands them
into concrete obligations:

- owner
- owns
- source
- canonical
- semantic center
- wrapper
- bridge
- shim
- compatibility path
- layer
- boundary
- contract
- invariant
- safe
- clean
- real
- correct
- appropriate
- as needed

Expansion means naming the relevant code entity, the exact responsibility, the
forbidden duplicate or bypass path, and the verification artifact.

## Prohibited vague instructions

Do not write instructions that leave derivable engineering decisions hidden
behind broad verbs or informal phrases.

Prohibited forms include:

- "handle the owner"
- "wire through the right path"
- "use the new layer"
- "make this safe"
- "keep this clean"
- "delegate appropriately"
- "preserve the real logic"
- "add wrappers as needed"
- "follow the existing pattern" without naming the exact file and pattern
- "verify this is correct" without naming the verification artifact

Replace those forms with declarative instructions that name the code entity,
allowed behavior, disallowed behavior, and proof condition.

## Required pattern for temporary compatibility

When a workflow document allows temporary compatibility code, it must list each
temporary item separately.

For each item, state:

- the old function, type, file, keyword, or public surface that remains
- the reason it remains in the current tranche or task
- the new function, type, module, or file it must call
- the exact behavior it may perform
- the exact behavior it must not perform
- the task, tranche, or stop condition that removes or revisits it
- the verification artifact that fails if it becomes a second implementation

Do not approve a category such as "old wrappers" without listing the exact old
names.

## Required pattern for ownership statements

When a workflow document says that code owns a responsibility, it must state:

- the owner entity by exact name
- the responsibility in active-voice prose
- the consumers that must call or receive output from that entity
- the duplicate code paths that must be deleted, demoted, or prevented
- the verification artifact for that responsibility

Example:

> `prepare_plot_network` owns traversal preparation for plotting. It copies the
> caller's `HybridNetwork`, runs `directedges!` and `preorder!` on the copy,
> and returns the prepared copy. Public plotting entry points consume the
> prepared copy. No public plotting path may call `directedges!` or `preorder!`
> on the caller's original network. The caller-safety test fails if the
> original network's traversal fields change.

## User-facing explanations

When explaining technical work to the project owner, prefer complete
descriptive prose over internal shorthand.

State what the code does, where it does it, why that location is responsible,
and how the repository proves the statement.

Do not ask the project owner to accept phrases such as "source of truth",
"real owner", "safe wrapper", or "proper path" without definitions and concrete
code references.

## Review standard

Reviews of workflow documents, handoffs, and implementation reports must flag
any sentence that assigns responsibility without naming the responsible code
entity and exact behavior.

The prose is not acceptable if a fresh agent could implement two materially
different designs while still claiming to follow the sentence.

The prose is not acceptable if deleting or breaking the named implementation
would not fail the stated verification artifact.
