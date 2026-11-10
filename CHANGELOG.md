# Changelog

## 0.1.0

Initial release of PhyloMakie for visualizing phylogenetic trees and networks
with Makie. The package includes a native phylogeny model, Newick and NEXUS
readers, configurable plots and image annotations, coordinate queries for
reactive overlays.

The minimum Julia version is 1.11.

### Library

- Introduce the `AbstractPhylogeny` interface and native `LineageNetwork`,
  `LineageNode`, and `LineageEdge` types, with topology and metadata accessors,
  validation, traversal, and editing operations.
- Support Makie's `plot(phylogeny)` and `plot!(axis, phylogeny)` entry points,
  plus `phylogenyplot` and `phylogenyplot!` convenience aliases, for composition
  with Makie figures and layouts.
- Provide full-tree and major-tree layout styles, edge-length scaling,
  inheritance-probability display, node and edge labels, colors, and widths.
- Read Newick and NEXUS collections from strings, IO streams, and files with
  `parsephylogenies` and `readphylogenies`. Provide `parsephylogeny` and
  `readphylogeny` for single records, plus `newick"..."` and
  `nexustreeblock"..."` string literals.
- Convert between `LineageNetwork` and `PhyloNetworks.HybridNetwork` with
  `from_hybridnetwork` and `to_hybridnetwork`.
- Attach node and edge images from matrices, local files, or HTTP(S) URLs.
  Configure size, placement, alignment, aspect ratio, and offset with
  `ImageAnnotation`.
- Expose node-coordinate snapshots with `node_positions` and edge-annotation
  anchors with `edge_positions`. Use `node_positions_observable` to keep
  overlays synchronized with changes to plot attributes or the plotted
  phylogeny.

### Changes from development versions

- Replace phylogenetic tip and branch terminology with leaf and edge
  terminology throughout the API, documentation, tests, and examples;
  rename `PhyloPlot` and its convenience functions to `PhylogenyPlot`,
  `phylogenyplot`, and `phylogenyplot!` without compatibility aliases.
- Require conversion of `PhyloNetworks.HybridNetwork` values with
  `from_hybridnetwork` before plotting. The Newick and NEXUS readers return
  native `LineageNetwork` values directly.
- Fix GLMakie display failures for plots without node or edge image
  annotations.

### Documentation

- Introduce Makie figures, axes, plot results, and formatting tools earlier in
  the manual; clarify phylogeny types; add a PhyloNetworks conversion guide and
  a linked index of runnable example scripts.
- Correct the README's NEXUS format tag (`NexusFormat`); fix a heading level,
  first-person prose, and stale commented-out lines in the manual and examples.
- Rename the repository maintainer roster to `MAINTAINERS.md` and update
  repository references.
