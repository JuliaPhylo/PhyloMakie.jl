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

All commands accept the same positional record selectors. `--select` first
chooses global record indices from the concatenated inputs, `--skip` discards
records from the start of that selection, and `--head` or `--tail` limits the
remaining records:

```sh
phylomakie inspect \
    --select '1,3-5' \
    --skip 1 \
    --head 3 \
    posterior.trees

phylomakie inspect --tail 10 posterior.trees
```

`--head` and `--tail` cannot be used together.

## Interactive viewing

The viewer provides previous and next navigation plus live controls for labels,
lengths, colors, line styles, arrow length, and scale. Use `-p` or `--plot`
repeatedly to initialize a plot attribute supported by the command-line literal
syntax:

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
from being interpreted by the shell. Run `phylomakie view --help` for a
copyable example of every supported plot attribute.

The CLI supports node and edge image dictionaries whose values are local image
paths or HTTP(S) URLs. Node keys are node names. Edge keys are parent/child name
pairs:

```sh
phylomakie view \
    -p 'nodeimages=Dict("A"=>"/absolute/path/a.png")' \
    -p 'edgeimages=Dict(("Root","A")=>"https://example.org/a.png")' \
    trees.nwk
```

The Julia API also accepts table, callable, regular-expression, object, and
image-matrix values that cannot be represented by this CLI literal syntax.
Those forms are intentionally not advertised or accepted by `-p`.

## Custom node labels

Pass `--node-labels PATH` to `view` or `render` to add node annotations from a
headered CSV or TSV file. The file must have exactly the columns `number` and
`label`; `number` contains an integer node ID and `label` contains the text to
display. Use `-p 'shownodenumber=true'` to display the node IDs that a file can
target:

```csv
number,label
1,Ancestor
4,Focal clade
```

```sh
phylomakie view \
    --node-labels labels.csv \
    -p 'showtiplabel=false' \
    trees.nwk

phylomakie render \
    --output labeled-tree.svg \
    --node-labels labels.tsv \
    trees.nwk
```

Custom labels are a separate annotation channel. Keep the default
`showtiplabel=true` to display original tip names as well, or set it to `false`
when the file's annotations should replace the visible tip text.

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
