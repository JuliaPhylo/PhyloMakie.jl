# STYLE-workflow-docs.md

## Purpose

This document governs project planning and review artifacts such as PRDs,
tranche documents, tasking documents, design notes, review reports, and audit
reports.

Its purpose is to prevent loss of context, loss of governance mandates, frozen
misdiagnoses, and handoffs that preserve a narrow framing while dropping the
concrete constraints.

## Mandatory reading and pass-forward

All contributors, including agents, must read this document line by line
before generating or revising workflow documents or delegating work.

All contributors, including agents, must also read `STYLE-agent-language.md`
line by line before generating, revising, reviewing, auditing, or delegating any
workflow document that uses ownership, contract, boundary, layer, invariant,
compatibility, verification, source, or responsibility language.

Compliance with `STYLE-agent-language.md` is mandatory. A workflow document is
not ready for downstream execution if it uses architectural shorthand without
naming the exact responsible code entity or external contract, the behavior or
responsibility, the consumers, duplicate or bypass paths, and the verification
artifact required by `STYLE-agent-language.md`.

If you create any downstream workflow document or dispatch any downstream task,
you must pass relevant mandates forward explicitly.

The downstream document must not merely inherit the parent context implicitly.
It must explicitly restate:

- which governance documents must be read line by line
- that `STYLE-agent-language.md` must be read line by line whenever the document
  uses ownership, contract, boundary, layer, invariant, compatibility,
  verification, source, or responsibility language
- which upstream primary sources must be read
- which vocabulary constraints apply
- which `STYLE-agent-language.md` specificity constraints apply when the
  document uses ownership, contract, boundary, layer, invariant, compatibility,
  or verification terms
- which authorization boundaries apply
- which verification gates define green state

This pass-forward obligation applies at every handoff boundary.

## Required sections

Every workflow document should include the sections needed for its level, but
the following obligations must be represented somewhere explicitly.

### Governance and required reading

List every applicable governance document that must be read line by line.

If only some documents are relevant, say which ones and why.

If the document uses ownership, contract, boundary, layer, invariant,
compatibility, verification, source, or responsibility language, list
`STYLE-agent-language.md` as required reading and state that its concrete
expansion rules are mandatory for the document.

### Controlled vocabulary

Name the relevant vocabulary constraints.

If new terms are required or existing terms are ambiguous, say so explicitly
and route the question through `STYLE-vocabulary.md` for project domain
terms, through `STYLE-workflow-vocabulary.md` for workflow-process terms, or
through `STYLE-agent-language.md` for architectural shorthand that needs
concrete expansion.

### Upstream primary sources

List the exact upstream primary sources that constrain the work.

If the work depends on framework behavior and no primary source has been read,
the workflow document is incomplete.

### Current-state diagnosis

Describe the current problem, not just the desired outcome.

If the work addresses a bug or architectural defect, the document must state:

- the observed failure mode
- the suspected root cause
- the exact function, type, module, file, public surface, or external contract
  suspected to be responsible for the relevant behavior
- the consumers or public surfaces that depend on that behavior
- any duplicate, fallback, or bypass paths suspected of keeping the same
  responsibility

### Ownership and invariant framing

If the work touches more than one module or layer, the document must identify:

- the exact function, type, module, file, public surface, or external contract
  responsible for each relevant invariant, contract, policy, or behavior
- the shared contract or invariant in active-voice prose
- the consumers that must call the responsible entity or receive its output
- the duplicate, fallback, or defensive paths that must be deleted, demoted, or
  prevented
- the verification artifact that fails if the responsibility remains duplicated
  or assigned to the wrong entity
- whether a foundational tranche is required before user-facing work

If a public semantic is accepted through more than one entry surface, the
document must also identify:

- the exact function, type, module, file, or public surface that normalizes that
  semantic
- each supported public surface through which it may enter
- any public surface that may adapt the resolved value but must not recalculate
  defaults, precedence rules, fallback behavior, or validation
- which surfaces must be covered by verification

### Authorization boundary

If disruptive redesign, deep refactor, clean-room replacement, migration, or
external breakage is in play, the document must state what is authorized and
what is not.

### Verification and green-state gates

Every workflow document must state what counts as complete for its scope.

This includes the required verification artifacts and the green-state gates
that must pass before the work is considered done.

### Handoff packet

Any workflow document that is meant to be consumed downstream by another
agent, contributor, tranche, review pass, or audit pass must include a concise
handoff packet.

The handoff packet must not merely point back to the parent document. It must
extract and restate the concrete execution controls that the downstream actor
needs in order to succeed honestly.

At minimum, the handoff packet must include, where applicable:

- active authorities
- parent documents
- settled decisions and non-negotiables
- authorization boundary
- current-state diagnosis
- primary-goal lock
- direct red-state repros
- named responsible code entity or external contract, the invariant or policy
  being repaired or relied on, the consumers that depend on it, and duplicate or
  bypass paths that must not keep the same responsibility
- exact files or surfaces in scope
- exact files or surfaces out of scope
- required upstream primary sources
- green-state gates
- stop conditions or escalate-if conditions

If a field does not apply, say so explicitly or omit it deliberately with a
clear reason. Do not silently rely on the downstream actor to infer it.

### Primary-goal lock

Any workflow document that turns requirements, findings, tranche goals,
compatibility boundaries, migration boundaries, or explicit non-negotiables
into downstream execution must convert each primary goal into an explicit lock
item.

Each lock item must state:

- the failure mode or forbidden surviving shape
- the non-completion condition in the form "the work is not complete if..."
- the direct red-state repro, historical bad behavior, or equivalent observed
  failure mode
- the task, tranche subsection, or exact responsible code entity that closes it
- the verification artifact that must fail the old implementation or fake-fix
  shape

Do not leave a user-stated primary goal or review finding as descriptive prose
only.

If multiple lock items share the same named repair entity, they may point at the
same task, but they must still remain separately named if one could survive
while another is fixed.

Green test suites, docs builds, grep checks, and source-text audits are
necessary but not sufficient as the only proof for a lock item unless no more
direct artifact is possible and that limitation is stated explicitly.

## Revalidation rule

Tasking documents must not blindly operationalize stale or partial diagnoses.

Before implementation begins, the current code, tests, examples, outputs, and
upstream sources must be rechecked against the document's framing.

If the diagnosis no longer matches reality, the contributor or agent must stop
and rewrite, split, or escalate the workflow document rather than blindly
continuing.

Receivers of a handoff packet must re-check the packet against the current
code, tests, docs, outputs, and upstream sources before acting on it. A
handoff packet does not waive revalidation.

## Anti-drift rules

Workflow documents must not:

- freeze a known partial diagnosis into downstream execution
- omit required line-by-line reading and compliance with
  `STYLE-agent-language.md` when the document uses ownership, contract,
  boundary, layer, invariant, compatibility, verification, source, or
  responsibility language
- use architectural shorthand without naming the responsible entity, behavior,
  consumers, duplicate or bypass paths, and verification artifact required by
  `STYLE-agent-language.md`
- omit architecture concerns merely to make the tranche look thinner
- omit upstream references when framework semantics matter
- omit verification gates when user-visible behavior is changing
- omit the handoff packet when downstream execution is expected
- pass only parent links or filenames when a downstream actor needs concrete
  execution controls
- leave primary goals, review findings, or compatibility requirements as
  descriptive intent without explicit lock items
- let several distinct primary goals collapse into one generic regression if
  one of those goals could still survive behind a green suite
- strip governance obligations from downstream documents

If a downstream document is materially weaker than its parent on these points,
that is workflow drift and must be corrected before execution proceeds.

## Review and audit standard

Reviews and audits of workflow documents must ask:

- did the mandates actually get passed forward?
- did the document mandate line-by-line reading of `STYLE-agent-language.md` and
  comply with its concrete expansion rules wherever responsibility language
  appears?
- did the document preserve the exact responsible code entity or external
  contract, its responsibility, the consumers that depend on it, duplicate or
  bypass paths, and root-cause framing?
- did it preserve upstream-reading obligations?
- did it preserve the named verification gates?
- did it create an honest authorization boundary?
- did it include a usable handoff packet rather than a link-only or
  context-dump handoff?
- did every primary goal, review finding, and compatibility boundary become a
  separate lock item with a direct proof obligation?
- could a fresh implementing agent still declare success while one of those
  lock items survives behind a green suite?

If not, the workflow document is not ready for downstream execution.
