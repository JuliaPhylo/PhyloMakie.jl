# STYLE-upstream-contracts.md

## Purpose

This document governs how the project reads, cites, obeys, wraps, extends, or
deliberately diverges from external framework and library contracts.

Use this document whenever behavior depends materially on Julia Base,
Makie, CairoMakie, GraphMakie, Documenter, or any other external dependency
whose semantics constrain the required design.

## Mandatory reading and pass-forward

All contributors, including agents, must read this document line by line
before planning, implementing, reviewing, or delegating contract-sensitive
work.

If you generate downstream instructions or artifacts, you must pass forward:

- the exact upstream primary sources that must be read
- the contract conclusions drawn from those sources
- any known uncertainties or inference boundaries
- any approved divergences from upstream behavior
- any local API, compatibility function, custom block, adapter, or recipe that
  must preserve the verified upstream behavior, including the behavior it may
  perform, the behavior it must not reimplement or conceal, and the verification
  artifact for that obligation

Do not simply say "follow Makie" or "see upstream docs". Name the relevant
source files, documentation pages, or standards explicitly whenever feasible.

## Core rules

### Verify from primary sources

When host-framework behavior matters, read the upstream primary source or
official documentation directly.

Do not rely on memory, secondary summaries, or plausible recollection when
contract-sensitive behavior is in scope.

Primary sources may include:

- official documentation
- upstream source files
- official examples
- accepted standards or specifications

### Distinguish verified fact from local inference

When you describe an upstream contract, be clear about which parts are directly
verified from the source and which parts are your inference from that source.

Do not present local inference as if the upstream text said it directly.

### Preserve host-framework semantics by default

If a local API, custom block, adapter, recipe, or compatibility function is
meant to behave like the host framework, preserve the host-framework contract by
default.

For example, if the host framework distinguishes mutating and non-mutating
entrypoints, local compatibility functions and adapters must not silently blur
that distinction.

When an old local entry point remains only to call a new implementation, the
downstream document must name the old entry point, the new implementation or
upstream entry point it calls, the adaptation it may perform, the behavior it
must not reimplement, and the verification artifact that fails if it becomes a
second implementation.

### Divergence must be explicit and approved

If the project intentionally diverges from upstream behavior, you must:

- identify the divergence explicitly
- justify why the divergence is needed
- obtain user approval if the divergence is externally visible or risky
- document any compatibility, migration, or review implications

Silent divergence is a governance failure.

### Upstream uncertainty raises the review level

If framework semantics are uncertain, obscure, changing, or undocumented, do
not freeze the assumption into downstream tasking as if it were settled fact.

Instead:

- flag the uncertainty explicitly
- escalate to HITL or explicit review when the uncertainty blocks implementation
  or creates material user-facing risk
- avoid claiming that AFK implementation is available if the contract is still
  materially ambiguous

### Local abstractions must not hide contract violations

Local compatibility functions, convenience APIs, adapters, and helper functions
must not be used to conceal a misunderstood or violated upstream contract.

If a local function, module, or adapter exists only to smooth over a contract
mismatch, the planning or review artifact must name that local entity, the
upstream contract point, the mismatch, the approved divergence if one exists,
and the verification artifact that proves the chosen behavior.

## Required planning artifacts

Any PRD, tranche document, or tasking document for contract-sensitive work must
include:

- the exact upstream primary sources read
- the specific contract points they constrain
- any local inference being made
- any approved divergence from upstream behavior
- any local compatibility entry point or adapter involved, with its old entry
  point, delegated implementation, permitted adaptation, forbidden
  reimplementation, and verification artifact
- the verification artifacts that prove the local code actually respects the
  intended contract

## Review and audit standard

Reviews and audits must ask:

- which upstream primary sources were actually read?
- does the implementation match the verified contract?
- is any claimed contract merely recollection or inference?
- does any local compatibility entry point or adapter preserve the
  host-framework semantics, or does it hide a contract mismatch?
- was any divergence explicit, justified, and approved?
