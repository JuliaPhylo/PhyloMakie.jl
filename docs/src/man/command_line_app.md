# Command-line app

The `phylomakie` app reads collections of phylogenetic trees or networks,
selects records, and sends the selected records to 1 of 3 commands:

- `view` opens an interactive GLMakie viewer.
- `inspect` reports source, topology, taxon, and branch-length metadata.
- `render` writes static PNG, SVG, or PDF files with CairoMakie.

Run `phylomakie --help` or `phylomakie COMMAND --help` to see the current
option reference.

## Input formats

Newick is the default input format. Select NEXUS explicitly or request
content-based detection with `auto`:

```sh
phylomakie inspect trees.nwk
phylomakie inspect --input-format nexus posterior.trees
phylomakie inspect --input-format auto trees.nwk posterior.trees
```

Use `-` as a path to read 1 input from standard input:

```sh
printf '(A,(B,C));' | phylomakie inspect -
```

PhyloMakie concatenates records from multiple inputs in command-line order.
Record indices used by `--select` refer to this concatenated collection.
Unreadable inputs produce warnings; processing continues when at least 1 input
loads successfully.

## Record selection

All commands accept the same record filters:

```sh
phylomakie inspect \
    --select '1,3-5' \
    --taxon Homo_sapiens \
    --tree-type tree \
    --rootedness rooted \
    --min-tips 10 \
    --max-tips 100 \
    posterior.trees
```

Repeat `--taxon` to require every listed taxon. `--tree-type` accepts `any`,
`tree`, or `network`; `--rootedness` accepts `any`, `rooted`, or `unrooted`.

## Interactive viewing

Open the built-in demonstrations by omitting input paths:

```sh
phylomakie view
```

With input paths, the viewer provides previous and next navigation plus live
controls for labels, lengths, colors, line styles, arrow length, and scale.
Use `-p` or `--plot` repeatedly to initialize any public `PhyloPlot` attribute:

```sh
phylomakie view \
    -p 'useedgelength = true' \
    -p 'showgamma = true' \
    -p 'style = :majortree' \
    trees.nwk
```

Plot values use Julia literal syntax. Supported forms include booleans,
numbers, strings, symbols, tuples, arrays, and dictionaries such as
`Dict(1 => "red", 2 => "blue")`. Shell quoting prevents spaces and symbols
from being interpreted by the shell.

## Metadata inspection

The default report contains collection counts and range summaries:

```sh
phylomakie inspect trees.nwk
```

The report includes tree and network counts, rooted and unrooted counts,
unique taxon count, minimum/mean/maximum tip count, complete/partial/absent
branch-length coverage, complete tree-length statistics, and observed edge-
length statistics.

Add `-v` for 1 line per record. Add `-vv` for record lines and complete taxon
lists. Use `--taxa-only` to print only the sorted unique taxon names:

```sh
phylomakie inspect -v trees.nwk
phylomakie inspect -vv trees.nwk
phylomakie inspect --taxa-only trees.nwk
```

## Static rendering

Grid mode writes all selected records to 1 image. `--size` specifies each
panel's width and height, and `--columns` fixes the grid width:

```sh
phylomakie render \
    --output trees.svg \
    --multiple grid \
    --columns 3 \
    --size 900x700 \
    -p 'useedgelength = true' \
    trees.nwk
```

File mode writes 1 image per record. A single output path derives numbered
paths, while `{index}` in a path acts as an explicit template:

```sh
phylomakie render --multiple files --output tree.png trees.nwk
# Writes tree-001.png, tree-002.png, and so on.

phylomakie render --multiple files --output 'tree-{index}.pdf' trees.nwk
```

Repeat `--output` once per selected record to provide exact paths. The app
infers PNG, SVG, or PDF format from each extension; `--output-format` sets the
format when a path has no extension. Existing files are rejected unless
`--force` is present. Use `--no-titles` to omit source and record titles.
