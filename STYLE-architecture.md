# STYLE-architecture.md

## Purpose

This document governs architectural ownership, invariant repair, deep-module
design, authorization boundaries for disruptive change, and the difference
between contract-level fixes and anti-fixes.

Use this document whenever work touches more than one module, repairs a shared
contract, changes layout or rendering ownership, restructures a subsystem,
introduces or removes an abstraction boundary, or is likely to be framed as
"just a local patch" despite cross-cutting symptoms.

## Mandatory reading and pass-forward

All contributors, including agents, must read this document line by line
before planning, implementing, reviewing, or delegating architecture-touching
work.

If you generate downstream instructions or artifacts — PRDs, tranche files,
tasking files, review requests, audit scopes, or delegated task descriptions —
you must pass the relevant mandates forward explicitly.

Passing this document forward means:

- naming it as required reading downstream
- naming `STYLE-agent-language.md` as required reading whenever downstream prose
  uses ownership, contract, boundary, layer, invariant, or compatibility terms
- restating the applicable ownership and invariant rules downstream
- restating any authorization boundaries downstream
- restating the required verification gates downstream
- naming the responsible code entity or external contract, its responsibility,
  the consumers that rely on it, the duplicate or bypass paths that must not
  keep that responsibility, and the verification artifact that fails if the
  responsibility remains unclear

It is not acceptable to assume that a later contributor or agent will infer
these constraints from context.

## Core rules

### Repair the responsible entity before the symptom site

If multiple symptoms depend on the same underlying external contract, internal
invariant, or policy, identify the exact function, type, module, file, public
surface, or external contract responsible for that behavior. Repair that entity
before changing the symptom sites.

Do not solve a cross-cutting problem by stacking local compensations at the
symptom sites.

If a proposed change requires the same defensive logic to be repeated in
several sibling modules or layers, stop before implementation. The plan must
name the entity that should enforce the rule, the consumers that should rely on
that entity, the repeated defensive paths that must be removed or prevented, and
the verification artifact that fails if the duplication remains.

### One invariant, one responsible entity

Each important invariant should have one named responsible entity.

Consumers may rely on an invariant, but they should not each be responsible for
reconstructing or re-enforcing it independently.

If an invariant seems to be partially enforced in many places, that is a design
smell. Architectural review must identify the entity that should enforce the
invariant and the verification artifact that proves consumers no longer
reconstruct it independently.

### One public semantic, one normalization point

If the same public semantic can be supplied from more than one API surface,
one named function, type, module, or public surface must normalize it once and
forward the resolved value downstream explicitly.

Consumers may accept the resolved value, but they should not each infer
independent defaults, precedence rules, or fallback behavior for that same
semantic.

If a contributor finds the same semantic being reconciled separately in more
than one module or layer, that is evidence the normalization responsibility is
incompletely specified. The next planning artifact must name the normalization
entity, the public surfaces that feed it, the duplicate reconciliation paths
that must stop, and the verification artifacts that cover each supported public
surface.

### Prefer foundational tranches when ownership is wrong

If several user-visible defects or requested features depend on one unclear or
misassigned responsibility, create a foundational tranche first.

Do not force thin user-facing slices when that would lock the wrong
architecture into place.

A foundational tranche must still be:

- crisply scoped
- explicitly justified
- independently verifiable

### Deep modules over shallow coordination

Prefer modules that keep domain complexity behind a small, stable interface.

Avoid shallow modules that merely pass state around while exposing the true
complexity to all callers.

The more cross-cutting the behavior, the stronger the case for a module with a
named responsibility and a small public interface.

### Anti-fixes are prohibited

Do not clamp, mask, cosmetically suppress, or reroute a bad state merely to
make the output look plausible or to make a weak test pass.

A local masking change is acceptable only if:

- the masking policy is itself the intended behavior of the named responsible
  entity
- that responsible entity and policy are explicitly identified
- the policy is documented and verified as such

Otherwise, the change is an anti-fix and must not be presented as resolution.

### User authorization bounds disruptive change

Deep redesign, large refactors, internal replacement, and clean-room rebuild
work are permitted only within an explicit user-approved authorization
boundary.

When that boundary is in place, contributors may choose the better design
rather than preserving accidental structure.

When that boundary is not in place, do not silently smuggle in major
architectural change.

### External contracts require explicit migration

Internal redesign is one question; external breakage is another.

If a change may affect outside clients, public APIs, file formats, serialized
artifacts, or documented workflows, you must:

- identify the exposed contract explicitly
- obtain explicit user approval for the breaking change
- define migration, compatibility, and documentation obligations explicitly

No contributor or agent may assume that internal improvement automatically
justifies external breakage.

### Green-state discipline is mandatory

Architectural work does not excuse leaving the repository in an indeterminate
state.

Every approved tranche must begin and end in the required green state for its
scope. Required gates may include tests, docs builds, example renders,
integration checks, migration verification, or other project-specific
artifacts.

If a tranche cannot satisfy those gates, it is too large or incorrectly framed
and must be split or escalated.

## Required planning artifacts

Any PRD, tranche document, or tasking document for architecture-touching work
must explicitly include:

- the current-state problem, not just the desired feature
- the target-state ownership model
- the shared contracts and invariants involved
- the exact function, type, module, file, public surface, or external contract
  that must enforce each responsibility being repaired or established
- the consumers that must call that entity or receive its output
- the duplicate, fallback, or defensive paths that must be deleted, demoted, or
  prevented
- any areas that must not be solved by local patches
- the user authorization boundary
- the verification gates required before the work is considered complete

## Review and audit standard

Architecture reviews and audits must ask:

- did the change repair the named entity responsible for the invariant,
  contract, policy, or behavior?
- did it preserve or improve ownership clarity by naming the responsible entity,
  consumers, duplicate paths, and verification artifact?
- did it create or remove duplicated invariant logic?
- did it introduce any anti-fixes?
- did it respect the authorization boundary and migration obligations?

If the answer to any of these is unclear, the work is not yet adequately
specified or reviewed.
