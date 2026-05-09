---
date-created: 2026-05-09T03:07:47
date-updated: 2026-05-09T03:07:47
---

# Controlled vocabulary

This file is the authoritative terminology reference for PhyloMakie.
All code, documentation, tests, tranche documents, review reports, and pull
requests must use the canonical terms defined here.
Proscribed terms must not appear in project-owned identifiers, type names,
function names, keyword arguments, symbols, field names, or workflow documents
except when quoting a third-party API or discussing legacy source material.

This list is not exhaustive and is not final.
If a contributor needs to coin a new term, or is uncertain whether an existing
term applies, that question must be raised with the project owner before the
term is introduced into project-owned code or documentation.
Once a term is ratified, this file must be updated and passed forward into all
downstream workflow documents and agent handoffs.

## Reader-facing prose versus API names

Controlled vocabulary distinguishes reader-facing prose from exact API names.
Use conventional spaced English terms in explanatory prose when that improves
clarity for readers outside the project.
Use compact project spellings only when referring to exact identifiers,
keyword arguments, symbols, struct fields, or public API names.

Examples:

- Write "major hybrid edge" in prose; write `majorhybridedgecolor` only when
  referring to the exact legacy keyword or a deliberate project-owned
  identifier.
- Write "leaf label" in prose; write `showleaflabel` only when referring to
  the exact keyword argument.
- Code examples in this repository are project-owned code and must follow the
  canonical identifier forms recorded here.

## Compound-word naming convention

Compound accessor names and domain-specific identifiers in this package are
written without underscores when the compound reads naturally as a single
concept.
Examples include `phyloplot`, `edgeweight`, `branchingtime`,
`coalescenceage`, `basenode`, `boundingbox`, and `lineageunits`.
This is consistent with `STYLE-julia.md` section 2.1.

## Entries

### `edge label`

**Part of speech:** noun.

**Definition:** Text associated with an edge by explicit user request, whether
through a DataFrame-provided annotation or through a built-in edge display such
as edge number, edge length, or inheritance value.

**Usage notes:** Use "edge label" for the rendered concept in prose.
Use `edgelabel` only for the exact keyword or identifier.

**Proscribed alternates:** `branch label` for project-owned terminology when
the plotted object is the network edge abstraction.

---

### `full tree style`

**Part of speech:** noun.

**Definition:** The plotting style in which minor hybrid edges are rendered as
their own branches rather than as simple overlays on the major tree.

**Usage notes:** The canonical prose term is "full tree style".
The exact symbol is `:fulltree`.

**Proscribed alternates:** `fulltree` in ordinary prose; `IcyTree style` as the
project's canonical term.

---

### `hybrid edge`

**Part of speech:** noun.

**Definition:** An edge incident to a hybrid node in a `HybridNetwork`.
Hybrid edges participate in major/minor role assignment and inheritance-value
display.

**Usage notes:** Use "hybrid edge" as the umbrella term.
Use the more specific terms "major hybrid edge" and "minor hybrid edge" when
the distinction matters.

**Proscribed alternates:** `reticulation arrow` when the term is meant to name
the network edge rather than the rendered glyph.

---

### `layout engine`

**Part of speech:** noun.

**Definition:** The internal owner that computes coordinate, extent, and
geometry information for nodes, edges, and hybrid-edge diagonals before Makie
rendering occurs.

**Usage notes:** The layout engine is a deep internal module, not a public API
name.
It owns plotting geometry semantics and should remain independent from Makie
primitive creation where practical.

**Proscribed alternates:** `R layout`; `plotting shell` when the subject is the
coordinate owner rather than the renderer.

---

### `leaf`

**Part of speech:** noun.

**Definition:** The canonical project term for a terminal taxon node.

**Usage notes:** PhyloMakie uses `leaf` consistently in new project-owned API
names, prose, and implementation terminology.
Legacy `PhyloPlots` material may use `tip`; that legacy term is only acceptable
when quoting or cross-referencing old sources.

**Proscribed alternates:** `tip` in new project-owned identifiers, docs, and
workflow documents; `terminal` when the project term intended is the concrete
leaf abstraction.

---

### `major hybrid edge`

**Part of speech:** noun.

**Definition:** The hybrid parent edge whose `ismajor` role is true for a
hybrid node under `PhyloNetworks` direction and traversal semantics.

**Usage notes:** Use this term when discussing color policy, style differences,
or inheritance-label placement.

**Proscribed alternates:** `primary hybrid edge`; `dark blue edge` as a
semantic name.

---

### `major tree style`

**Part of speech:** noun.

**Definition:** The plotting style in which minor hybrid edges are rendered as
overlay diagonals on the major tree rather than as separate branches.

**Usage notes:** The canonical prose term is "major tree style".
The exact symbol is `:majortree`.

**Proscribed alternates:** `majortree` in ordinary prose; `overlay style` as
the canonical project term.

---

### `minor hybrid edge`

**Part of speech:** noun.

**Definition:** The non-major parent hybrid edge for a hybrid node.
In plotting, this edge is the one rendered with the minor-edge diagonal or
branch treatment and is the default owner of arrow-tip display.

**Usage notes:** Use this term when discussing `:fulltree` versus `:majortree`
rendering, line style, arrow policy, and minor-edge color semantics.

**Proscribed alternates:** `secondary hybrid edge`; `arrow edge` as a semantic
name.

---

### `node label`

**Part of speech:** noun.

**Definition:** Text associated with a node by explicit user request, whether
through built-in node-name or node-number displays or through a DataFrame-based
annotation.

**Usage notes:** Use "node label" for the rendered concept in prose.
Use `nodelabel` only for the exact keyword or identifier.

**Proscribed alternates:** `vertex label` in project-owned terminology.

---

### `node number`

**Part of speech:** noun.

**Definition:** The internal integer identifier carried by a `PhyloNetworks`
node and optionally exposed for plotting, annotation, and rotation workflows.

**Usage notes:** Distinguish node number from node name.
Names are reader-facing labels such as `H1`; numbers are internal identifiers
such as `-5`.

**Proscribed alternates:** `vertex number` in project-owned terminology.

---

### `PhyloPlot`

**Part of speech:** noun.

**Definition:** The canonical Makie recipe type name for the main network plot
surface.

**Usage notes:** `PhyloPlot` is the type name generated by `@recipe`.
The public user-facing functions are `phyloplot` and `phyloplot!`.

**Proscribed alternates:** `PhyloNetworkPlot`; `TipPlot`; `TreePlot` when the
project-owned recipe is specifically the hybrid-network plotting surface.

---

### `phyloplot`

**Part of speech:** noun and function name.

**Definition:** The canonical public-facing plotting name for
`PhyloMakie`'s non-mutating `HybridNetwork` recipe surface.

**Usage notes:** Use `phyloplot` for the public entrypoint that creates a
`Makie.FigureAxisPlot`.
Use `phyloplot!` for the mutating entrypoint that renders into an existing
Makie axis.

**Proscribed alternates:** `plotphylo`; `plotnetwork`; `phyloplot` with mixed
`tip` vocabulary in adjacent identifiers.

---

### `rendering shell`

**Part of speech:** noun.

**Definition:** The internal owner that maps resolved layout and annotation
data onto Makie primitives, text, and axis-owned decorations.

**Usage notes:** The rendering shell may use Makie-specific types and
attributes.
It should consume already-resolved semantics from the layout engine and
annotation-preparation owners rather than recomputing those policies locally.

**Proscribed alternates:** `layout engine` when the subject is the Makie
primitive owner rather than the geometry owner.
