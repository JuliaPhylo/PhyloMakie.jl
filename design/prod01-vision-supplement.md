## Supplement to `prod01-vision.md`: Resolved gaps for PRD authoring

This document closes four gaps identified in `prod01-vision.md` that would otherwise require a PRD agent to make undocumented decisions.

---

### 1. Full keyword argument surface

The target function is `PhyloPlots.plot(net::HybridNetwork; ...)`. Its complete keyword surface, grouped by role, is the authoritative specification for `phyloplot`. The PRD should replicate all behaviors below. Kwarg *names* may be renamed for Makie idiom at the PRD author's discretion; behaviors are non-negotiable.

**Layout / geometry**

| Kwarg | Type | Default | Behavior |
|---|---|---|---|
| `useedgelength` | `Bool` | `false` | Draw edges proportional to stored lengths; missing lengths rendered as 1.0 |
| `style` | `Symbol` | `:fulltree` | `:fulltree` — minor hybrid edges as separate branches (IcyTree-style); `:majortree` — minor edges overlaid on major tree |
| `arrowlen` | `Real` | `0.1` (`:fulltree`), `0` (`:majortree`) | Arrow tip length for minor hybrid edge rendering |
| `minorlinetype` | any | `nothing` | Line style for minor hybrid arrows; defaults to `"longdash"` in `:fulltree`, `"solid"` in `:majortree` |
| `edgewidth` | `Number` or `Dict{Int,Number}` | `1` | Uniform width, or per-edge width keyed by edge number; unmapped edges default to 1 |
| `xlim` | 2-element array or `nothing` | `nothing` | Override computed x-axis limits |
| `ylim` | 2-element array or `nothing` | `nothing` | Override computed y-axis limits |
| `tipoffset` | any | `0` | Extra x-offset applied to tip label positions |
| `preorder` | `Bool` | `true` | If true, calls `directedges!` and `preorder!` on the network (mutates input — see §4) |

**Visibility toggles**

| Kwarg | Type | Default | Shows |
|---|---|---|---|
| `showtiplabel` | `Bool` | `true` | Taxon names at leaves |
| `shownodelabel` | `Bool` | `false` | Internal node names (e.g. `"H1"`) |
| `shownodenumber` | `Bool` | `false` | Internal node numbers |
| `showedgelength` | `Bool` | `false` | Edge lengths as text |
| `showgamma` | `Bool` | `false` | γ (inheritance probability) on hybrid edges |
| `showedgenumber` | `Bool` | `false` | Edge internal numbers as text |

**Custom annotations (DataFrame-based)**

| Kwarg | Type | Default | Behavior |
|---|---|---|---|
| `edgelabel` | `AbstractDataFrame` | `DataFrame()` | Col 1: edge numbers (Int); Col 2: labels. Annotates matching edges. |
| `nodelabel` | `AbstractDataFrame` | `DataFrame()` | Col 1: node numbers (Int); Col 2: labels. Annotates matching nodes. |

Validation rules (must be preserved): minimum 2 columns; col 1 must be integer-typed; rows with missing col-1 values are silently dropped; unmatched numbers produce a warning, not an error.

**Text sizing**

These are R `cex` (character expansion) scalars — multiplicative size factors.

| Kwarg | Default | Applies to |
|---|---|---|
| `tipcex` | `1` | Tip labels and `shownodelabel` text |
| `nodecex` | `1` | `nodelabel` DataFrame annotation text |
| `edgecex` | `1` | `edgelabel` DataFrame annotation text |

**Colors**

| Kwarg | Type | Default | Behavior |
|---|---|---|---|
| `edgecolor` | `String` or `Dict{Int,String}` | `"black"` | Uniform color, or per-edge color keyed by edge number. If Dict: `majorhybridedgecolor` and `minorhybridedgecolor` are ignored |
| `majorhybridedgecolor` | `AbstractString` | `"deepskyblue4"` | Major hybrid edge color (when `edgecolor` is not a Dict) |
| `minorhybridedgecolor` | `AbstractString` | `"deepskyblue"` | Minor hybrid edge color (when `edgecolor` is not a Dict) |
| `defaultedgecolor` | any | `nothing` | Fallback for edges not in `edgecolor` Dict; defaults to `"black"` (Dict case) or `edgecolor` (scalar case) |
| `edgenumbercolor` | any | `"grey"` | Color for edge number annotations |
| `edgelabelcolor` | any | `"black"` | Color for `edgelabel` DataFrame annotation text |
| `nodelabelcolor` | any | `"black"` | Color for `nodelabel` DataFrame annotation text |

**Label placement**

| Kwarg | Default | Semantics |
|---|---|---|
| `edgelabeladj` | `[0.5, 0]` | [x, y] anchor adjustment for edge annotation text |
| `nodelabeladj` | `1` | Anchor adjustment for node annotation text |

---

### 2. Acceptance criteria

The implementation is done when all of the following pass:

| # | Input | Required output |
|---|---|---|
| 1 | Simple tree, no hybrids: `"(A,((B,C),(D,E)));"` | Renders without error; no hybrid-edge drawing code is invoked |
| 2 | One reticulation, γ present: `"(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"` | Major and minor hybrid edges visible in distinct colors; arrow tip rendered on minor edge |
| 3 | Same network, `style=:majortree` vs `:fulltree` | Visually distinct layouts; `:majortree` draws minor edges as diagonal overlays, `:fulltree` as separate branches with spacing |
| 4 | `useedgelength=true` on a network with branch lengths | Node x-positions scaled to edge lengths; missing lengths rendered as 1.0 |
| 5 | `edgelabel` and `nodelabel` DataFrames with valid data | Labels appear at the midpoint of the correct edges/nodes |
| 6 | `showgamma=true` on a hybrid network | γ values appear: minor edge gets `minorhybridedgecolor`, major edge gets `majorhybridedgecolor` |
| 7 | `edgecolor` as a `Dict{Int,String}` | Mapped edges get their specified color; unmapped edges get `defaultedgecolor` |
| 8 | `phyloplot!(Axis(fig[1,1]), net1)` and `phyloplot!(Axis(fig[1,2]), net2)` | Both render in their respective panels with no coordinate bleed-through |

---

### 3. Recipe naming convention

The Makie `@recipe` macro uses a PascalCase *type* name and generates a lowercase function automatically:

```julia
@recipe(PhyloPlot, net) do scene    # defines type PhyloPlot
    Attributes(...)
end
# macro generates: phyloplot(args...; kwargs...) and phyloplot!(args...; kwargs...)

Makie.plottype(::HybridNetwork) = PhyloPlot   # enables plot(net) dispatch
```

The public-facing names are `phyloplot` / `phyloplot!`. The type `PhyloPlot` is an implementation detail. The PRD should treat `phyloplot` as the canonical user-facing name.

---

### 4. Layout engine ownership

**Decision: port the existing Julia layout engine as internal helpers.**

`edgenode_coordinates`, `check_nodedataframe`, `prepare_nodedataframe`, and `prepare_edgedataframe` in `PhyloPlots.jl/src/phylonetworksPlots.jl` are already pure Julia — no R dependency. They contain the tree layout algorithm (cladewise y-assignment, preorder x-assignment, hybrid edge coordinate resolution). This logic is correct, battle-tested, and should be ported rather than rewritten.

These functions become private helpers in PhyloMakie — not exported, not part of the public API. The PRD should plan to adapt their signatures to remove any implicit R/RCall assumptions and fit them cleanly into the `Makie.plot!` implementation.

**Input mutation policy:** The current code mutates the network by calling `directedges!` and `preorder!`. PhyloMakie preserves this behavior, controlled by the `preorder` kwarg (default `true`). This must be documented in the `phyloplot` docstring.
