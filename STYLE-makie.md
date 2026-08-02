# STYLE-makie.md

## Purpose

This document governs how LineagesMakie.jl integrates with Makie and Makie-
family packages such as CairoMakie and GraphMakie.

Use this document whenever work touches plotting entrypoints, custom blocks,
recipes, scenes, layout ownership, rendering policy, annotation placement,
display behavior, or example outputs driven by Makie contracts.

## Mandatory reading and pass-forward

All contributors, including agents, must read this document line by line
before planning, implementing, reviewing, or delegating Makie-sensitive work.

If you generate downstream instructions or artifacts, you must pass forward:

- the exact Makie-family source files or docs that constrain the work
- the Makie contract conclusions drawn from them
- the verification artifacts needed to prove compliance
- any named Makie block, local function, module, public plotting surface, or
  adapter responsible for layout, annotation, scene, or rendering behavior
- any duplicate local layout, annotation, scene, or rendering path that must not
  keep the same responsibility

Do not reduce this to "follow Makie conventions". Name the specific upstream
contract whenever feasible.

## Core rules

### Makie contracts are host-framework contracts

Makie semantics are not optional local style.

When LineagesMakie wraps or extends Makie behavior, it must preserve Makie's
host-framework contract unless an explicit, documented divergence is approved.

### Non-mutating and mutating plotting entrypoints must follow Makie semantics

If the local API offers both non-bang and bang plotting forms, they must follow
Makie's mutating versus non-mutating contract clearly and predictably.

Do not blur the distinction through convenience entry points that return
surprising objects or mutate unexpectedly. If an old plotting entry point
remains only to call a new implementation, downstream prose must name the old
entry point, the new implementation, the adaptation it may perform, the behavior
it must not reimplement, and the render or API verification artifact for that
obligation.

### Decorations belong to the named layout entity

If an element is semantically a panel or axis decoration rather than data
content, the workflow document must name the Makie block, local function,
module, or public plotting surface responsible for its layout and placement.
Sibling rendering modules may consume the resolved placement, but they must not
invent independent offsets for the same decoration.

When multiple rendering modules participate in one panel-level contract, the
plan must name the single placement calculation, the modules that consume it,
the competing offset paths that must be removed or prevented, and the rendered
artifact, screenshot, pixel check, or integration test that fails if competing
offsets remain.

### Measure text before reserving annotation space

Text-driven layout must be based on measured or contractually derived text
extents whenever available.

Do not rely on magic offsets or uncoordinated local spacing when annotation
readability or collision avoidance matters.

### Scene and data-space responsibility must not be confused

Do not place decoration-like artifacts in data space merely because they are
drawn with plotting primitives.

When the semantics belong to a panel rather than the plotted data, the document
must name the Makie block or local layout function responsible for placement and
the data-space plotting path that must not own that placement.

### Compositing policy must be explicit

If the visual result depends on draw order, fill policy, stroke policy, or
scene layering, that policy must be intentional and documented.

Do not rely on accidental rendering order to create or hide an invariant.

## Required planning artifacts

Any PRD, tranche document, or tasking document for Makie-sensitive work must
include:

- the exact Makie-family primary sources read
- the specific contract being preserved or repaired
- the exact Makie block, local function, module, public plotting surface, or
  adapter responsible for annotation, layout, scene, or rendering policy
- the consumers that must use the resolved annotation, layout, scene, or
  rendering value
- the duplicate or bypass paths that must not recalculate that value
- the verification artifacts needed to demonstrate compliance

## Required verification

Makie-sensitive work typically requires more than unit tests.

Depending on the change, required verification may include:

- rendered example outputs
- screenshot or pixel-level checks
- docs builds
- integration tests for public plotting entrypoints
- direct checks of display-ready return types or the named Makie block/local
  entity responsible for the relevant behavior

Weak geometry-only checks are not sufficient when the observed defect is visual,
readability-related, or compositional.

## Review and audit standard

Reviews and audits of Makie-sensitive work must ask:

- which Makie-family primary sources were actually read?
- does the implementation match Makie's contract?
- is decoration placement centralized in the named Makie block, local function,
  module, public plotting surface, or adapter responsible for it?
- are annotations measured by the named entity responsible for annotation
  placement and consumed by the rendering paths that need them?
- is the visual result explained by intentional policy rather than accident?
