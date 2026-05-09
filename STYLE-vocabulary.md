---
date-created: 2026-05-09T03:07:47
date-updated: 2026-05-09T03:07:47
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

- Write "major hybrid edge" in prose; write `majorhybridedgecolor` only for
  the exact keyword name.
- Write "tip label" in prose; write `showtiplabel` only for the exact keyword
  name.
- Write "full-tree style" in prose; write `:fulltree` only for the exact style
  symbol.

## Entries

### Edge label

An edge label is text annotation attached to an edge.
This includes built-in edge annotations such as length, gamma, and edge
number, plus user-supplied annotations from the `edgelabel` data frame.

Use "edge label" as the default project term.
Do not use "branch label" as the default term in project-owned code or docs
for this production run.

### FigureAxisPlot

`Makie.FigureAxisPlot` is the canonical non-mutating return contract for
`phyloplot(net; kwargs...)`.

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

### Keyword surface

The keyword surface is the complete public keyword argument behavior inherited
from `PhyloPlots.plot(net::HybridNetwork; ...)` for this production run.

This includes keyword names, defaults, validation rules, warnings, and visible
effects.
Do not rename or reinterpret that public surface in this production run unless
the project owner explicitly reopens a specific keyword contract.

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
User-facing prose should prefer `phyloplot` and `phyloplot!`.

### Phyloplot

`phyloplot(net; kwargs...)` is the canonical non-mutating public plotting
function in PhyloMakie.

It must return `Makie.FigureAxisPlot` and must follow the `PhyloPlots.plot`
public behavior completely for this production run.
Do not use `plot` as the primary user-facing PhyloMakie name when the package
specific API is intended.

### Phyloplot!

`phyloplot!(ax, net; kwargs...)` is the canonical mutating public plotting
function for plotting into an existing Makie axis-like owner.

Preserve Makie's mutating semantics.
Do not create a non-bang wrapper that silently mutates an existing axis.

### Render adapter

The render adapter is the internal owner that translates resolved plot options
and layout-engine outputs into Makie primitives, text, and recipe composition.

Keep render concerns separate from layout calculation and keyword
normalization.

### Tip and leaf

`tip` is the canonical public plotting term inherited from PhyloPlots for
current user-facing keyword names such as `showtiplabel`, `tipoffset`, and
`tipcex`.
`leaf` is the graph-structural term used when discussing `PhyloNetworks` node
properties or general tree and network structure.

Do not rename existing public plotting keywords from `tip` to `leaf` in this
production run.
Use `leaf` in internal design prose only when structural precision matters.
