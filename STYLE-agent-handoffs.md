# STYLE-agent-handoffs.md

## Purpose

This document governs how agents and contributors prepare, transmit, receive,
and act on workflow handoffs.

Its purpose is to prevent shallow handoffs, context loss, missing authorities,
missing red-state repros, and downstream execution that quietly reopens
already-settled decisions or misses the contract that governs the work.

## Mandatory reading and pass-forward

All contributors, including agents, must read this document line by line
before creating or consuming:

- PRDs
- tranche files
- tasking files
- review scopes
- audit scopes
- implementation plans
- delegation prompts
- agent handoff instructions

All contributors, including agents, must also read `STYLE-agent-language.md`
line by line before creating, transmitting, receiving, reviewing, auditing, or
acting on any handoff that uses ownership, contract, boundary, layer, invariant,
compatibility, verification, source, or responsibility language.

Compliance with `STYLE-agent-language.md` is mandatory. A handoff is invalid if
it uses architectural shorthand without naming the exact responsible code entity
or external contract, the responsibility or behavior, the consumers, duplicate
or bypass paths, and the verification artifact required by
`STYLE-agent-language.md`.

If you create a downstream handoff, you must pass this document's mandates
forward explicitly. You must also pass forward the applicable
`STYLE-agent-language.md` obligations. Linking to a parent document is not
sufficient.

## Core rule

A handoff is not a summary, and it is not a context dump.

A handoff must give the downstream actor the exact controls needed to continue
the workflow honestly, without reopening derivable decisions and without
guessing at the governance, authorization, scope, or contract boundaries.

## Required handoff packet

Any governed workflow handoff must include a concise handoff packet.

The packet must include, where applicable:

- active authorities
- parent documents
- settled decisions and non-negotiables
- authorization boundary
- current-state diagnosis
- primary-goal lock
- direct red-state repros
- named responsible code entity or external contract, the invariant being
  repaired or relied on, the consumers that depend on it, and any duplicate or
  bypass paths that must not keep the same responsibility
- exact files or surfaces in scope
- exact files or surfaces out of scope
- required upstream primary sources
- green-state gates
- stop conditions or escalate-if conditions

If a field does not apply, say so explicitly or omit it deliberately with a
brief reason.

## Sender obligations

The sender of a handoff must:

- restate active authorities rather than assuming the receiver will infer them
- name `STYLE-agent-language.md` as a required authority whenever the handoff
  uses ownership, contract, boundary, layer, invariant, compatibility,
  verification, source, or responsibility language
- restate settled decisions rather than hiding them in prose elsewhere
- restate direct red-state repros when the work is bug-fix, review, audit, or
  remediation driven
- identify what the receiver must not change, not merely what they should build
- identify any derivable design decisions that are already resolved
- identify any true judgment calls that require `REVIEW` rather than silent
  implementer choice
- identify the exact function, type, module, file, public surface, or external
  contract responsible for the invariant or policy under repair when the work is
  architectural or cross-cutting
- identify the verification artifact that fails if that responsibility remains
  duplicated, bypassed, or assigned to the wrong entity

Do not hand off derivable decisions as implementer-choice questions. If an
existing pattern is mandatory, name the exact file, function, type, or test that
demonstrates the pattern and state how the downstream work must follow it.

## Receiver obligations

The receiver of a handoff must:

- read the cited authorities and parent documents line by line as required
- read `STYLE-agent-language.md` line by line before acting on handoff prose that
  uses ownership, contract, boundary, layer, invariant, compatibility,
  verification, source, or responsibility language
- restate the active authorities and handoff packet before substantial work
- revalidate the handoff packet against the current code, tests, docs, outputs,
  and upstream sources before acting on it
- stop if the packet conflicts with the current reality, the active
  authorities, or a higher-priority governing document
- stop if the packet uses architectural shorthand without the concrete
  expansion required by `STYLE-agent-language.md`
- stop if a required derivable decision was omitted and cannot be recovered
  honestly from the sources
- verify completion against the lock items and green-state gates, not merely
  against local intuition or passing smoke tests

## Handoff anti-patterns

Handoffs must not:

- pass only filenames or links when execution controls are needed
- rely on "see parent document" as the only pass-forward mechanism
- omit `STYLE-agent-language.md` from active authorities when the handoff uses
  ownership, contract, boundary, layer, invariant, compatibility, verification,
  source, or responsibility language
- use architectural shorthand without naming the responsible entity, behavior,
  consumers, duplicate or bypass paths, and verification artifact
- collapse several distinct primary goals into one generic acceptance note
- omit the direct red-state repro when the historical bug is reproducible
- replace contract-level proof with "the suite passes" or "the docs build"
- quietly reopen settled decisions under the label of implementation detail
- offload unresolved derivable design questions onto a fresh implementing agent

## Review and audit standard

Reviews and audits of governed handoffs must ask:

- does the handoff packet name the exact responsible code entity or external
  contract, its responsibility, the consumers that depend on it, the duplicate
  or bypass paths that must not keep that responsibility, and the verification
  artifact for that responsibility?
- does the handoff explicitly require line-by-line reading of
  `STYLE-agent-language.md` and comply with it wherever responsibility language
  appears?
- does it restate the active authorities and required upstream sources?
- does it preserve settled decisions and authorization boundaries?
- does it include the primary-goal lock and direct red-state repros where
  applicable?
- could a fresh downstream agent still declare success while missing a primary
  goal, violating a boundary, or reopening a settled decision?

If yes, the handoff is not yet strong enough.
