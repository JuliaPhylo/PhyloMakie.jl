---
date-created: 2026-05-09T03:07:47
date-updated: 2026-05-10T16:48:24-07:00
---

# Controlled vocabulary

This file is the authoritative terminology reference for PhyloMakie.
All code, documentation, tests, workflow documents, review notes, and
delegated tasks must use the canonical terms defined here.
Proscribed terms must not appear in project-owned identifiers, type names,
function names, keyword arguments, symbols, or field names unless the project
owner explicitly approves an exception.

This file works alongside `STYLE-workflow-vocabulary.md`.
`STYLE-workflow-vocabulary.md` remains authoritative for workflow-process
terms such as `tranche`, `lock item`, and `red-state repro`.
This file is the domain vocabulary authority for PhyloMakie-specific plotting,
graph, and rendering concepts.

## Reader-facing prose versus API names

Controlled vocabulary distinguishes reader-facing prose from exact API names.
Use conventional spaced English terms in explanatory prose when that improves
clarity. Use exact project spellings only when referring to code identifiers,
keyword arguments, symbols, struct fields, or deliberate project terms.

Examples:

- Write "major hybrid edge" in prose; write `major_hybrid_edge_color` only for
  the exact keyword name.
- Write "tip label" in prose; write `show_tip_labels` only for the exact keyword
  name.
- Write "full-tree style" in prose; write `:fulltree` only for the exact style
  symbol.

## Entries

### Edge label

An edge label is text annotation attached to an edge.
This includes built-in edge annotations such as length, gamma, and edge
number, plus user-supplied annotations from the public edge-annotation
surface.

Use "edge label" as the default project term.
Do not use "branch label" as the default term in project-owned code or docs
for this production run.

### FigureAxisPlot

`Makie.FigureAxisPlot` is the canonical non-mutating return contract for
`plot(net; kwargs...)` and any equivalent non-mutating convenience wrapper
provided by PhyloMakie.

Use the exact type name when discussing the API contract.
Do not replace it with vague phrases such as "plot tuple" when the return-type
contract is the point under discussion.

### Foreign project terms

Terms such as `lineageplot`, `lineageunits`, `EdgeLayer`, `LeafLayer`,
`LeafLabelLayer`, `NodeLayer`, `NodeLabelLayer`, `CladeHighlightLayer`,
`CladeLabelLayer`, and `ScaleBarLayer` belong to another project's domain
vocabulary and are not part of PhyloMakie's default terminology.

Do not let those foreign domain tables shape PhyloMakie naming, planning, or
review unless the project owner explicitly adopts a specific term later.

### Fulltree and majortree

`:fulltree` and `:majortree` are the exact legacy style symbols inherited from
`PhyloPlots.plot`.

For this production run, keep these exact public spellings and behaviors.
In reader-facing prose, describe them as "full-tree style" and "major-tree
style".

### HybridNetwork

`PhyloNetworks.HybridNetwork` is the canonical input type for the current
production run.

Do not generalize planning language to arbitrary graphs, arbitrary trees, or
arbitrary network types when the contract being discussed is specific to
`HybridNetwork`.

### Capability parity

Capability parity means preserving the accepted visualization tasks and visible
plotting outcomes of `PhyloPlots.plot` without requiring identical public
keyword spellings, wrapper structure, or runtime architecture.

Use "capability parity" when the project must preserve what users can do or
see.
Do not collapse it into "keyword parity" or "API mimicry".

### Compatibility shell

The compatibility shell is any runtime layer that keeps legacy
`PhyloPlots.plot` keyword spellings, translation structs, or compatibility
payloads alive as the semantic center of public plotting.

It is not accepted end-state architecture for this production run.
Legacy capability mapping belongs in migration material, rejection boundaries,
or historical diagnosis unless the project owner explicitly authorizes a real
compatibility product.

### Public attribute surface

The public attribute surface is the Makie-native set of public plotting
attributes accepted by PhyloMakie's supported plotting entrypoints for this
production run.

It includes public names, grouping, defaults, validation rules, warnings, and
visible effects.
Use legacy `PhyloPlots.plot` keywords only as migration and capability
reference material.
Do not treat the legacy keyword shell as the authoritative PhyloMakie public
contract.

### Legacy keyword surface

The legacy keyword surface is the historical
`PhyloPlots.plot(net::HybridNetwork; ...)` interface used as a capability and
migration reference.

It is not the canonical PhyloMakie public contract for this production run.

### Makie-native public plot owner

The Makie-native public plot owner is the single recipe or plot type that owns
public plotting semantics for `PhyloNetworks.HybridNetwork` in PhyloMakie.

`plot(net)`, `plot!(ax, net)`, and any optional `phyloplot` convenience
surfaces must route through this same owner.
Do not let a wrapper, compatibility shell, or legacy keyword adapter become a
second semantic center.

### Layout engine

The layout engine is the internal owner that computes node, edge, and
minor-hybrid-edge geometry plus annotation anchor data before Makie rendering.

For this project, the layout engine is the Makie-independent descendant of the
pure Julia helper logic in `PhyloPlots.jl/src/phylonetworksPlots.jl`.
Do not use "renderer" when the geometry owner is what you mean.

### Major hybrid edge and minor hybrid edge

Major hybrid edge and minor hybrid edge are the canonical parent-edge terms
used by PhyloNetworks and PhyloPlots for hybrid nodes.

Use these exact terms in code, docs, tests, and workflow documents.
Do not replace them with vague substitutes such as "primary edge",
"secondary edge", or "overlay edge".

### PhyloPlot

`PhyloPlot` is the Makie recipe type name produced by `@recipe(PhyloPlot, net)`.

Treat `PhyloPlot` as an implementation-detail type.
User-facing prose should prefer `plot` and `plot!`, or `phyloplot` and
`phyloplot!` only when discussing the optional convenience surfaces
specifically.

### Phyloplot

`phyloplot(net; kwargs...)` is an optional package-specific non-mutating
convenience plotting function in PhyloMakie when it is present.

It must remain a thin wrapper over the same Makie-native public plot owner used
by `plot(net; kwargs...)`.
Do not define package semantics here independently from the host-framework
plotting surface.

### Phyloplot!

`phyloplot!(ax, net; kwargs...)` is an optional package-specific mutating
convenience plotting function for plotting into an existing Makie axis-like
owner when it is present.

Preserve Makie's mutating semantics.
Do not create a non-bang wrapper that silently mutates an existing axis.

### Render adapter

The render adapter is the internal owner that translates resolved plot options
and layout-engine outputs into Makie primitives, text, and recipe composition.

Keep render concerns separate from layout calculation and keyword
or public attribute resolution.

### Tip and leaf

`tip` is the canonical public plotting term for user-facing attribute names
such as `show_tip_labels`, `tip_label_offset`, and related tip-label controls.
`leaf` is the graph-structural term used when discussing `PhyloNetworks` node
properties or general tree and network structure.

Do not rename existing public plotting attributes from `tip` to `leaf` in this
production run.
Use `leaf` in internal design prose only when structural precision matters.
