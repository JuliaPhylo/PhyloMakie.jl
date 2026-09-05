# Changelog

## Unreleased

- Fix GLMakie display failures for plots without node or edge image
  annotations.
- Add the installable `phylomakie` app with `view`, `inspect`, and `render`
  subcommands.
- Add shared input-format and record-selection controls across app commands.
- Add PNG, SVG, and PDF grid and per-record rendering modes.
- Add composable head/tail selection, stride sampling, and Newick/NEXUS export
  of selected records to the command-line app.
- Replace numeric CLI node annotations with CSV/TSV `name,display` remapping
  that leaves input and selected-record output unchanged.
