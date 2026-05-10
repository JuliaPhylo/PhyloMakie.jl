## Supplement to `prod01-vision.md`: Makie-native scope decisions

This document resolves the planning questions that changed after the first
compatibility-first workflow pass. It is the design supplement that the PRD
and tranche plan must follow for the remaining work.

---

### 1. Capability parity is required. API mimicry is not.

The target product is a Makie-native plotting package with the same core
plotting functionality as `PhyloPlots.plot`. The target product is not a
drop-in recreation of the same user-facing keyword shell.

For this production run, the following stay non-negotiable:

- support `PhyloNetworks.HybridNetwork`
- support full-tree and major-tree layout modes
- support major and minor hybrid edge rendering
- support edge-length-driven x placement
- support tip labels, internal node names, node numbers, edge numbers, edge
  lengths, gamma labels, and user-supplied annotations
- support edge, text, and annotation styling
- support plotting into new and existing Makie figures and axes
- remove all R dependencies from the plotting path

The following are explicitly authorized to change when a better Makie-native
surface results:

- public keyword names
- public keyword grouping
- defaults that only existed to mirror R graphics behavior
- warning text and validation ownership
- the wrapper structure around the plotting owner

The design standard for these changes is simple: users should feel they are
using a Makie package that covers the same problem space, not the old package
with a backend swap.

---

### 2. Public plotting direction

The public plotting owner should be a real Makie plot type or recipe.

The preferred direction for the remaining work is:

- Makie `plot(net; attrs...)` support through a package-owned recipe
- plotting into an existing axis through Makie mutating semantics
- optional package-specific helper entrypoints such as `phyloplot` and
  `phyloplot!`, but only as thin convenience wrappers over the same public
  owner

Do not make `phyloplot` or a legacy-keyword wrapper the semantic owner if the
recipe already exists.

Do not require users to learn or preserve legacy `PhyloPlots.plot` keyword
spelling in order to access the package correctly.

---

### 3. Reuse policy for completed internal work

Tranches 1 through 4 closed useful internal foundations. Treat them as
reusable current-state assets, not as proof that the old public architecture
was correct.

The following are considered good candidates for reuse:

- `layout_engine.jl`
- `annotation_data.jl`
- `render_adapter.jl`
- the Makie dependency baseline and render-proof scaffolding
- the accepted render regression corpus and helper-level regression suite

The following are considered transitional or suspect and may be retired,
reduced, or split apart:

- `keyword_normalization.jl`
- `keyword_contract.jl`
- any verification metadata that treats legacy keyword parity as the primary
  product definition
- any docs phrasing that presents PhyloMakie as "the same package with Makie
  underneath"

If a compatibility adapter survives, it must be explicit, thin, and secondary.
It must not remain the package's architectural center.

---

### 4. Public semantics that must survive the rewrite

The remaining work must preserve the following visible plotting semantics even
if the API names or ownership change:

| Capability | Required outcome |
| --- | --- |
| Full-tree style | Minor hybrid edges render as separate branches with their own visual path |
| Major-tree style | Minor hybrid edges render as overlays on the major tree |
| Edge-length scaling | Node x positions respect stored lengths, with coherent missing-length handling |
| Hybrid-edge labels | Gamma values render with distinct major and minor hybrid color policy |
| Internal labels | Tip labels, node names, node numbers, edge numbers, and edge lengths can all be shown |
| User annotations | User-supplied node and edge annotations render at the correct anchors |
| Styling | Colors, widths, linestyles, and text sizes can be controlled through the new surface |
| Composition | Two networks can render into separate axes in one figure without state bleed-through |

Use `PhyloPlots.jl` as a capability reference for these behaviors. Do not use
it as the authority for the final user-facing API shape.

---

### 5. Input mutation policy is reopened

The earlier compatibility-first plan preserved the legacy `preorder` behavior
and the associated input mutation by default.

That is no longer a fixed requirement.

The remaining work may:

- preserve the behavior if it is still the best Makie-native choice
- hide it behind internal copying or preparation
- expose it differently if public mutation control is genuinely useful

The important requirement is clarity:

- do not mutate input implicitly unless the public contract says so
- do not preserve a legacy mutation switch merely because it existed before

---

### 6. Documentation and migration standard

Documentation must teach the Makie-native package first.

Required documentation outcomes:

- primary examples use the Makie-native public API
- migration material maps legacy PhyloPlots capabilities to the new PhyloMakie
  surface
- migration material explains differences honestly instead of pretending the
  APIs are the same
- no primary docs page teaches the legacy keyword surface as the package's
  canonical interface

Compatibility notes may exist, but they must read as migration support, not as
the product definition.
