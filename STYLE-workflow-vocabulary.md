### `anti-fix`

**Part of speech:** noun (process and review concept)

**Definition:** A change that appears to address a problem locally but actually
masks, reroutes, clamps, or cosmetically suppresses the bad state without
repairing the owning contract, invariant, or root cause.

An anti-fix may make tests, logs, or screenshots look better while leaving the
underlying design wrong.

**Usage notes:** The correct response to a suspected anti-fix is to identify the
owning layer and repair the invariant there, or explicitly document why the
local policy is in fact the intended owner-level behavior.

**Proscribed alternates:** using `fix` for known masking changes; `workaround`
without explicit statement of scope, owner, and temporary/permanent status.

---

### `foundational tranche`

**Part of speech:** noun (workflow concept)

**Definition:** A tranche that exists to establish, repair, or migrate a shared
owner, contract, invariant, or architectural boundary before user-facing or
symptom-level tranches are attempted.

A foundational tranche is appropriate when multiple visible defects or feature
requests depend on one shared internal responsibility.

**Proscribed alternates:** `cleanup tranche`; `prep work` when the tranche
changes a real contract; `horizontal slice` when the work is actually owner-
establishing.

---

### `governance document`

**Part of speech:** noun (process concept)

**Definition:** Any project document whose directives are binding on planning,
implementation, verification, naming, documentation, or review behavior.

In this project, governance documents include `CONTRIBUTING.md`, all
applicable `STYLE*.md` files, and any additional policy or design-governance
documents explicitly designated by the project owner.

**Usage notes:** Governance documents are not optional background reading.
Agents and contributors must read applicable governance documents line by line,
comply with them, and pass their mandates forward into downstream instructions
and delegated work.

**Proscribed alternates:** `reference` when the document is actually binding;
`optional guidance` for mandatory governance.

---

### `host-framework contract`

**Part of speech:** noun (architecture and integration concept)

**Definition:** The externally defined behavior, conventions, invariants,
ownership model, or API semantics imposed by a library or framework the project
is built on or tightly integrated with.

**Usage notes:** Host-framework contracts must be verified from upstream
primary sources, not assumed from memory. Local wrappers and abstractions must
preserve them unless an explicit, documented, user-approved divergence is
intended.

**Proscribed alternates:** `upstream behavior` when the specific contract being
relied on has not been identified; `Makie way` or other informal phrases in
place of a traced contract.

---

### `ownership boundary`

**Part of speech:** noun (architecture concept)

**Definition:** The explicit boundary that determines which module, type,
subsystem, or layer owns a given responsibility, invariant, contract, or
policy, and which adjacent modules merely consume that owned behavior.

**Usage notes:** If multiple modules appear to be applying the same defensive
logic, that is evidence the ownership boundary may be wrong or unclear. Fixes
should move toward clearer ownership, not toward broader duplication.

**Proscribed alternates:** `somewhere in the stack`; `handled upstream`
without naming the owner.

---

### `pass forward` / `pass-forward`

**Part of speech:** verb phrase / adjective (governance process concept)

**Definition:** The obligation to restate and preserve all relevant governance,
controlled-vocabulary, upstream-reference, authorization-boundary, and
verification requirements in downstream instructions, workflow documents, task
descriptions, or delegated work.

To pass a mandate forward is not merely to link the parent document. It means
making the downstream recipient explicitly aware of what they must read, obey,
verify, and continue transmitting.

**Usage notes:** This term applies especially to agents. If an agent reads a
governance document and then creates a PRD, tranche file, tasking file, review
instruction, or delegated task without carrying forward the relevant mandates,
that agent has not complied with governance.

**Proscribed alternates:** `implied by context`; `assumed known`; `see above`
as a substitute for a real downstream governance block.

---

### `handoff packet`

**Part of speech:** noun (workflow-governance concept)

**Definition:** The concise structured control block inside a workflow
document, delegated task, or agent handoff that restates the exact execution
inputs a downstream actor must use.

**Usage notes:** A handoff packet normally includes active authorities, parent
documents, settled decisions, authorization boundaries, current-state
diagnosis, primary-goal lock items, direct red-state repros, scope limits,
required upstream primary sources, green-state gates, and stop conditions. It
is not a link-only pointer back to a parent document.

**Proscribed alternates:** `summary` when execution controls are required;
`context dump`; `see parent`.

---

### `lock item`

**Part of speech:** noun (workflow and verification concept)

**Definition:** A separately named workflow item that turns one primary goal,
review finding, compatibility boundary, migration boundary, or explicit
non-negotiable into a concrete non-completion condition with its own red-state
repro and proof obligation.

**Usage notes:** A lock item must say what surviving shape is forbidden, how
the historical or current bad behavior is reproduced, what task or owner closes
it, and what verification artifact fails the bad implementation or fake-fix
shape. Use separate lock items whenever one goal could survive while another
is fixed.

**Proscribed alternates:** `goal` when a tracked proof obligation is intended;
`note`; `intent`.

---

### `red-state repro`

**Part of speech:** noun (verification concept)

**Definition:** The direct reproduction of the current or historical bad
behavior that a real fix must make impossible or explicitly reject.

**Usage notes:** A red-state repro is stronger than a broad negative test idea.
It should fail the current bad implementation or forbidden regression shape in
the same way the real bug, drift, or contract violation fails. Use it as part
of lock-item verification and handoff packets when a downstream actor must
prove that a known bad shape is gone.

**Proscribed alternates:** `negative case` when the historical bad behavior is
more specific; `failing scenario` when the repro itself is the contract anchor.

---

### `primary-goal lock`

**Part of speech:** noun (workflow-governance concept)

**Definition:** The workflow discipline and corresponding document section that
enumerate the lock items for the primary goals in a PRD, tranche file, tasking
file, review scope, or remediation plan.

**Usage notes:** A primary-goal lock is incomplete if a fresh implementing
agent could still declare success while one of its lock items survives behind a
green suite, docs build, or source-text audit. A primary-goal lock is stronger
than a summary of goals because it records direct non-completion conditions and
proof obligations.

**Proscribed alternates:** `goal summary` when direct proof obligations are
required; `acceptance criteria` when the red-state repro and non-completion
condition are omitted.

---

### `settled decision`

**Part of speech:** noun (workflow-control concept)

**Definition:** A design, migration, compatibility, naming, authorization, or
environment decision that has already been resolved and must be treated as
fixed input by downstream work unless the user explicitly reopens it.

**Usage notes:** Settled decisions belong in handoff packets and workflow
documents whenever a fresh agent could otherwise reopen them under the label of
implementation detail.

**Proscribed alternates:** `assumption` when the decision is already ratified;
`suggestion` when the downstream actor is not free to choose.

---

### `stop condition`

**Part of speech:** noun (workflow-control concept)

**Definition:** The explicit condition under which an agent or contributor must
halt, escalate, or request clarification instead of continuing the workflow.

**Usage notes:** Stop conditions are part of honest handoff packets. They
prevent downstream actors from proceeding through misdiagnosis, governance
conflicts, stale inputs, or unresolved design choices while preserving the
appearance of progress.

**Proscribed alternates:** `edge case` when the condition actually governs
whether work may continue; `note` when the effect is mandatory halting.

---

### `task`

**Part of speech:** noun (workflow concept)

**Definition:** A concrete, ordered unit of execution within a tranche. A task
must have a clear purpose, a clear verification condition, and a defined set of
dependencies or blockers.

Tasks are subordinate to tranches. They do not replace the need for sound
tranche framing.

**Proscribed alternates:** using `issue` to mean a task in workflow documents;
`step` when the unit carries formal execution and verification obligations.

---

### `tranche`

**Part of speech:** noun (workflow concept)

**Definition:** The canonical term for a bounded unit of planned work in this
project's AI workflow. A tranche may be user-facing, foundational, migration-
oriented, stabilization-focused, or review-gated, but it must always have a
clear purpose, clear dependencies, and clear verification criteria.

The term `tranche` is used to avoid collision with the overloaded word
"issue", which may otherwise refer to a problem, a GitHub issue, or an
arbitrary discussion thread.

**Usage notes:** Use `tranche` for the planned work unit, and reserve `issue`
for plain-English problem statements or for explicit GitHub issue references.

**Proscribed alternates:** using `issue` as the default workflow unit term in
project-generated planning documents; `ticket` unless referring to an external
system that actually uses that term.

---

### `upstream primary source`

**Part of speech:** noun (process and evidence concept)

**Definition:** The authoritative source material that defines the behavior,
contract, API, or policy of an external dependency, framework, renderer, or
tool on which the project relies.

Primary sources include official documentation, source files in the upstream
repository, accepted standards, and project-owned design documents when they
are the actual source of truth.

**Usage notes:** Secondary summaries, memory, or model recollection are not
substitutes when contract-sensitive behavior is at issue. When a change depends
on an upstream primary source, the exact source should be named and passed
forward into downstream planning and execution documents.

**Proscribed alternates:** `docs` when the exact authority is not specified;
`what Makie does` or similar vague paraphrases.

---

### `verification artifact`

**Part of speech:** noun (testing and review concept)

**Definition:** Any concrete artifact used to verify that work is correct at
the intended contract boundary.

Verification artifacts may include test results, rendered examples,
screenshots, pixel comparisons, docs builds, example outputs, migration checks,
benchmarks, or other reproducible evidence tied to the real acceptance
condition.

**Usage notes:** Verification artifacts should match the real failure mode. For
visual defects, geometry existence alone is often not a sufficient verification
artifact. For public API changes, docs and example behavior may be part of the
required artifact set.

**Proscribed alternates:** `proof` when no reproducible artifact is recorded;
`test coverage` as a substitute for a concrete acceptance artifact.

---

## Layer recipe names

| Canonical recipe type | Canonical function | Former name (proscribed) |
|---|---|---|
| `EdgeLayer` | `edgelayer!` | `BranchLayer`, `branchlayer!` |
| `NodeLayer` | `nodelayer!` | `VertexLayer`, `vertexlayer!` |
| `LeafLayer` | `leaflayer!` | `TipLayer`, `tiplayer!` |
| `LeafLabelLayer` | `leaflabellayer!` | `TipLabelLayer`, `tiplabellayer!` |
| `NodeLabelLayer` | `nodelabellayer!` | `VertexLabelLayer`, `vertexlabellayer!` |
| `CladeHighlightLayer` | `cladehighlightlayer!` | — |
| `CladeLabelLayer` | `cladelabellayer!` | — |
| `ScaleBarLayer` | `scalebarlayer!` | — |
| `LineagePlot` | `lineageplot!` | — |

## Layout `lineageunits`

| Symbol | Accessor required | x-coordinate source | Polarity | `axis_polarity` |
|---|---|---|---|---|
| `:edgeweights` | `edgeweight` | Cumulative `edgeweight(src, dst)` from `basenode`; computes `branchingtime` on the fly | Basenode = 0, increases toward leaves | `:forward` |
| `:branchingtime` | `branchingtime` | `branchingtime(node)` directly; user pre-supplies divergence times | Basenode = 0, increases toward leaves | `:forward` |
| `:coalescenceage` | `coalescenceage` | `coalescenceage(node)`; requires ultrametric tree (or `nonultrametric` policy) | Leaf = 0, increases toward basenode | `:backward` |
| `:nodedepths` | none | Cumulative path distance (edge count) from `basenode` (all edge weights = 1) | Basenode = 0, increases toward leaves | `:forward` |
| `:nodeheights` | none | Per-node height (path distance to farthest leaf); all leaves at x = 0; clade graph (unweighted) analogue of `:coalescenceage` | Leaf = 0, increases toward basenode | `:backward` |
| `:nodelevels` | none | Integer level = edge count from `basenode`; equal spacing between levels; clade graph (unweighted) analogue of `:branchingtime` | Basenode = 0, increases toward leaves | `:forward` |
| `:node_coordinates` | `node_coordinates` | User-supplied `(x, y)` in data coordinates | User-defined | User-defined |
| `:nodepos` | `nodepos` | User-supplied `(x, y)` in pixel coordinates | User-defined | User-defined |

**Default `lineageunits`:** `:edgeweights` if an `edgeweight` accessor is
supplied; `:nodeheights` otherwise.

**Polarity summary:** `lineageunits` values that are basenode-relative
(`:edgeweights`, `:branchingtime`, `:nodedepths`, `:nodelevels`) have
`:forward` `axis_polarity` and assign the basenode x = 0 increasing toward the
leaves. `lineageunits` values that are leaf-relative (`:coalescenceage`,
`:nodeheights`) have `:backward` `axis_polarity` and assign leaves x = 0
increasing toward the basenode. With the default `display_polarity = :standard`
and `lineage_orientation = :left_to_right`, forward `lineageunits` values
place leaves at the right; backward `lineageunits` values place the
basenode at the right.

## Compound-word naming convention

Compound accessor names and domain-specific identifiers in this package are
written without underscores when the compound reads naturally as a single
concept: `edgeweight`, `nodevalue`, `coalescenceage`, `branchingtime`,
`basenode`, `boundingbox`, `lineageunits`. This is consistent with
STYLE-julia.md §2.1, which permits omitting underscores when the name is not
hard to read.

Edge-endpoint parameters `src` and `dst` are short conventional forms (3
characters each) following the `Graphs.jl` ecosystem; they are an approved
exception to the "full word preferred" rule in STYLE-julia.md §2.4.

Multi-word field names on structs retain underscores: `node_positions`,
`edge_shapes`, `leaf_order`, `leaf_spacing`, `axis_polarity`, `display_polarity`,
`lineage_orientation`, `interval_schema`.

## Project-specific short-form canonical table

The table below records this project's canonical identifier forms for each
domain concept, governed jointly by STYLE-julia.md §2.4 (identifier form rules)
and this document (lexeme choices). All proscribed forms in the right column
must not appear in project-owned identifiers, field names, keywords, type
names, or symbols, including code examples.

| Concept | Canonical form | Type-param form | Proscribed short forms |
|---|---|---|---|
| A generic graph node | `node` (full word) | `NodeT` | `n`, `nd`, `v`, `V` |
| Distinguished node ("root" in rooted structures | `basenode` (one word) | — | `base`, `basevertex`, `base_node` |
| Edge source (parent node) | `src` | — | `fromnode`, `fromvertex`, `s`, `from_node` |
| Edge destination (child node) | `dst` | — | `tonode`, `tovertex`, `d`, `to_node` |
| Indexed nodes | `node1`, `node2` | — | `n1`, `n2`, `v1`, `v2` |
| Child node (loop variable) | `child` | — | `c`, `ch` (when meaning child node) |
| Children collection (local var) | `child_collection` | — | `ch`, `children` (collision with `AbstractTrees.children`) |
| Node identity type parameter | — | `NodeT` | `V`, `N`, `T` |
| Collection of all nodes | `all_nodes` | — | `all_vertices`, `vs` |
| Node data accessor | `node_coordinates` / `nodepos` | `NC` / `NP` | `vertexcoords`, `vertexpos`, `vc`, `vp` |
