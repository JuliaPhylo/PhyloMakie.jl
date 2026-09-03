# Native node and edge images

## Outcome

`plot` and `plot!` render arbitrary raster images as native annotations on
nodes and edges of a `PhyloNetworks.HybridNetwork`. Users target graph objects
semantically instead of discovering implementation-assigned node or edge
indices. Images may be decoded matrices, local files, or HTTP(S) URLs.

The feature includes a local-file example with reusable colored-circle assets
and a PhyloPicMakie example that passes PhyloPic thumbnail URLs through the
same native `nodeimages` mechanism.

## Scope

- Add `nodeimages` and `edgeimages` to the public attribute surface. Each
  accepts `nothing`, a callable evaluated on the caller's original node or
  edge objects, or a sparse dictionary. Node dictionaries accept node objects
  plus exact-label and regular-expression selectors. Edge dictionaries accept
  edge objects plus exact-label and regular-expression endpoint selectors.
  Label selectors apply to every match, including repeated labels. Numeric
  indices are rejected.
- Add an exported `ImageAnnotation` value type. A bare source uses its defaults;
  the type provides per-image `height`, `scale`, `size_space`, `position`,
  `align`, `aspect`, and pixel `offset` controls.
- Define data-sized height as full image height along the plot's y axis. The
  default is `0.8` data units, leaving a gutter between adjacent 1-unit tip
  rows. Preserve source aspect ratio in screen space. Explicit pixel sizing
  defaults to 32 pixels.
- Support color and real-valued image matrices and raster formats decoded by
  FileIO/ImageIO. Resolve local paths and HTTP(S) URLs with per-plot caching,
  URL deduplication, a finite download timeout, and a download size limit.
- Preserve native Makie plot ownership, reactive updates, stable child-plot
  identity, input-network immutability, and existing data-limit behavior.
- Keep PhyloPic discovery in PhyloPicMakie. PhyloMakie consumes only the
  resulting public thumbnail URLs and does not depend on PhyloPicMakie.
- Exclude SVG decoding, animation, collision avoidance, asynchronous network
  loading, and automatic x-limit expansion for pixel-rendered image width.

## Approach

`ImageAnnotation` is the single normalization point for presentation policy.
`src/image_annotations.jl` owns selector validation, source loading, cache
keys, normalized RGBA matrices, and pure image-marker geometry. Callable
mappings receive objects from the input network; the resolved entries are
translated to geometry by their position in the prepared copy, which preserves
the input vectors while allowing layout preparation to remain non-mutating.

The layout engine owns edge annotation anchors through one shared
`compute_edge_annotation_positions` function. Edge labels and edge images both
consume that result, so major-tree minor-edge placement has one implementation.

The reactive graph owns source-to-channel resolution and projected data-height
probes. The render adapter owns exactly 2 persistent `scatter!` children: edge
images and node images. They use data-space anchors with pixel-space markers,
so zoom and resize recompute row-relative heights while preserving image aspect
ratio. Draw order is edge geometry, edge images, node images, then text.

The controlling Makie sources are the installed Makie 0.24 files
`src/basic_plots.jl`, `src/conversions.jl`,
`src/utilities/texture_atlas.jl`, and `src/compute-plots.jl`. They establish
per-marker `markersize` and `marker_offset`, the uniform color-matrix vector
required for batched image markers, and the rule that pixel-marker extents do
not contribute to data limits when anchor and marker spaces differ.

This is additive. Existing calls with no image attributes retain empty image
children and unchanged visible output. Existing coordinate-query APIs remain
available for independently owned overlays.

## Tranches

### Image contracts and source resolution

Add the public type and attributes, semantic mapping validation, shared edge
anchors, matrix normalization, local and remote loaders, per-plot cache, and
focused unit tests. Add FileIO, ImageIO, and Downloads as direct dependencies.

Verification: constructor/default/validation tests, object/name/regular-
expression/endpoint selector tests, repeated-label matches, overlapping-
selector and stale-target failures, local-file decoding, URL loader injection,
cache deduplication, and unchanged layout-anchor tests.

### Reactive channels and native rendering

Register node and edge image channels independently of plot configuration,
project data-height probes, compute per-marker pixel geometry, and add the 2
stable scatter children in the documented compositing order. Keep image assets
cached while layout/style changes recompute anchors and marker geometry.

Verification: graph-output inventory tests, empty typed channels, rendered
node and edge images, data-height and pixel-height behavior, semantic retargeting
on network replacement, child identity across `Makie.update!`, no repeated
decode for unrelated restyling, and pixel checks on CairoMakie output.

### Examples and documentation

Create static colored-circle PNG files and a deliberately repetitive REPL
walkthrough of node and edge selector forms. Keep a compact 6-tip example that
reuses the red asset through semantic tip names. Add another example that
resolves PhyloPic records with PhyloPicMakie and gives their thumbnail URLs to
`nodeimages`. Document sources, mappings, sizing, placement, alignment,
reactivity, URL behavior, limits, and package separation.

Verification: execute the offline colored-circle example, render its PNG,
execute the PhyloPic example when network access is available, and build the
documentation.

## Completion checks

- The full test suite, Aqua checks, and JET checks pass.
- The documentation builds without warnings or doctest failures.
- The offline example renders all 6 tip images plus an edge image from checked-in
  assets, with the 2 red tips sharing one source file.
- A visual or pixel-level artifact confirms row-relative sizing, preserved
  circles, placement on both node and edge anchors, and intended draw order.
- The PhyloPic example uses only public PhyloPicDB records plus native
  `nodeimages`; PhyloMakie has no PhyloPicMakie dependency.
- Existing no-image rendering and coordinate queries remain compatible.
