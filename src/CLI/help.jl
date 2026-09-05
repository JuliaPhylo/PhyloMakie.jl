const GENERAL_HELP = """
Usage: phylomakie <command> [options] INPUT ...

Commands:
  view       Display selected phylogenies in an interactive viewer.
  inspect    Summarize source and phylogeny metadata.
  render     Render selected phylogenies to one or more files.

Examples:
  phylomakie inspect trees.nwk
  phylomakie view trees.nwk
  phylomakie render --output tree.svg trees.nwk

Run `phylomakie <command> --help` for command-specific options and examples.
"""

const COMMON_HELP = """
Input, selection, and selected-record output:
  -f, --input-format FORMAT        newick (default), nexus, or auto.
  -s, --select SPEC                Global record positions, for example 1,3-5.
      --skip N                     Drop the first N records after --select (0).
      --stride N                   Keep every Nth remaining record (default: 1).
      --head N                     Keep the first N records after skip/stride.
      --tail N                     Keep the last N records after skip/stride.
      --selected-output-file PATH  Write/replace PATH with the selected records.
      --selected-output-format FMT newick (default) or nexus.

Use `-` as an input path to read from standard input. Selection is applied in
this order: --select, --skip, --stride, then --head/--tail. --head and --tail
may be combined; overlapping records are written or shown only once.
"""

const PLOT_HELP = """
Display-name remapping:
  --nodelabels PATH
      Read a headered .csv or .tsv file with exactly 2 columns: name,display.
      `name` is an existing node name in the Newick/NEXUS data; `display` is
      the replacement text used by view/render. Numeric node positions are not
      accepted. Input data and --selected-output-file retain the original names.
      Tip names are shown by default. Use -p 'shownodelabel=true' to show mapped
      internal names. Image selectors still use the original input names.
      --node-labels is accepted as an alias.

      CSV example:                 TSV example:
        name,display                 name<TAB>display
        A,Canis lupus                A<TAB>Canis lupus
        Root,Common ancestor         Root<TAB>Common ancestor

Plot options (repeat -p/--plot NAME=VALUE):
  -p 'useedgelength=true'                  Use edge lengths on the x axis (false).
  -p 'showtiplabel=false'                  Show tip names (true).
  -p 'shownodelabel=true'                  Show named internal nodes (false).
  -p 'shownodenumber=true'                 Show stable node IDs (false).
  -p 'showedgelength=true'                 Show branch lengths (false).
  -p 'showedgenumber=true'                 Show stable edge IDs (false).
  -p 'showgamma=true'                      Show inheritance probabilities (false).
  -p 'edgecolor="navy"'                    Set one edge color ("black").
  -p 'edgecolor=Dict(1=>"red",2=>"blue")' Set colors by stable edge ID.
  -p 'defaultedgecolor="gray"'             Set the dictionary fallback (nothing).
  -p 'majorhybridedgecolor="navy"'         Set major hybrid edges ("deepskyblue4").
  -p 'minorhybridedgecolor="skyblue"'      Set minor hybrid edges ("deepskyblue").
  -p 'edgewidth=2.5'                       Set one edge width (1).
  -p 'edgewidth=Dict(1=>2.5,2=>0.5)'       Set widths by stable edge ID.
  -p 'minorlinetype=:dash'                 Set the minor edge line style (automatic).
  -p 'arrowlen=0.15'                       Set minor edge arrow length (automatic).
  -p 'nodeimages=Dict("A"=>"/tmp/a.png")'  Map input node names to images (nothing).
  -p 'edgeimages=Dict(("R","A")=>"a.png")'
                                             Map input parent/child names to images.
  -p 'edgenumbercolor="gray"'              Set edge-ID text color ("grey").
  -p 'tipoffset=0.1'                       Offset tip names from their nodes (0).
  -p 'tipcex=1.2'                          Scale tip and internal names (1).
  -p 'xlim=(-1,10)'                        Set x-axis data limits (nothing).
  -p 'ylim=(0,20)'                         Set y-axis data limits (nothing).
  -p 'style=:majortree'                    Use :fulltree or :majortree (:fulltree).

Values use Julia literal syntax. Supported forms are numbers, booleans, strings,
symbols, tuples, arrays, and dictionaries. Constructors other than Dict,
regular expressions, functions, image matrices, and arbitrary Julia expressions
are not accepted. Node/edge image values may be local paths or HTTP(S) URLs;
their selectors use original input names even when --nodelabels is present.
"""

const VIEW_HELP = """
Usage: phylomakie view [options] INPUT ...

Display selected phylogenies in the interactive viewer.

  -p, --plot NAME=VALUE       Set a supported plot attribute; repeatable.
      --nodelabels PATH       Remap node names for display from CSV or TSV
                              (alias: --node-labels).
      --size WIDTHxHEIGHT     Window size (default: 1700x950).
  -h, --help                  Show this help.

$(COMMON_HELP)
$(PLOT_HELP)

Examples:
  phylomakie view --head 3 --tail 3 posterior.trees
  phylomakie view --skip 9 --stride 10 --size 1400x900 posterior.trees
  phylomakie view -p 'useedgelength=true' -p 'showgamma=true' trees.nwk
  phylomakie view --nodelabels display.csv -p 'shownodelabel=true' trees.nwk
"""

const INSPECT_HELP = """
Usage: phylomakie inspect [options] INPUT ...

  -v, --verbose               Add record detail; repeat for full listings.
      --taxa-only             Print sorted unique taxon names only.
  -h, --help                  Show this help.

$(COMMON_HELP)

Examples:
  phylomakie inspect --input-format auto --select '1,3-5' --skip 1 -v trees.nwk
  phylomakie inspect --head 5 --tail 5 -vv posterior.trees
  phylomakie inspect --stride 100 --selected-output-file sample.nwk posterior.trees
  phylomakie inspect --selected-output-file sample.nex --selected-output-format nexus trees.nwk
  phylomakie inspect --taxa-only trees.nwk
  printf '(A,(B,C));' | phylomakie inspect -
"""

const RENDER_HELP = """
Usage: phylomakie render [options] INPUT ...

  -o, --output PATH           Output path; repeat for exact per-record paths.
      --output-format FORMAT  auto (default), png, svg, or pdf.
      --multiple MODE         grid (default) or files.
      --columns N             Grid column count.
      --size WIDTHxHEIGHT     Per-panel size (default: 900x700).
      --no-titles             Omit source and record titles.
      --force                 Replace existing image output files.
  -p, --plot NAME=VALUE       Set a supported plot attribute; repeatable.
      --nodelabels PATH       Remap node names for display from CSV or TSV
                              (alias: --node-labels).
  -h, --help                  Show this help.

$(COMMON_HELP)
$(PLOT_HELP)

Examples:
  phylomakie render --output tree.svg --size 1200x900 --force trees.nwk
  phylomakie render --output grid.pdf --multiple grid --columns 3 --no-titles trees.nwk
  phylomakie render --output sample.pdf --skip 9 --stride 10 posterior.trees
  phylomakie render --output tree.png --nodelabels display.csv trees.nwk
  phylomakie render --multiple files --output 'tree-{index}.pdf' trees.nwk
"""

help_text(::Val{:general})::String = GENERAL_HELP
help_text(::Val{:view})::String = VIEW_HELP
help_text(::Val{:inspect})::String = INSPECT_HELP
help_text(::Val{:render})::String = RENDER_HELP

function help_text(topic::Symbol)::String
    topic in (:general, :view, :inspect, :render) || return GENERAL_HELP
    return help_text(Val(topic))
end
