```@meta
CurrentModule = PhyloMakie
```

# Verification foundation

Tranche 4 closes the internal Makie render owner on top of the tranche-1
verification foundation, the tranche-2 keyword owner, and the tranche-3
layout and annotation owners. It still does not implement `phyloplot`,
`phyloplot!`, `PhyloPlot`, `Makie.plottype(::HybridNetwork)`, or Makie
`plot(net)` dispatch, so direct public entry-surface proof remains deferred to
tranche 5.

The tables below are rendered from `PhyloMakie.VERIFICATION_FOUNDATION`. If
the source-side owner drifts or disappears, this page should fail to build
instead of silently going stale.

## Target public surfaces

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Target surface | Implemented | Direct proof deferred | Proof owner | Docs visibility |",
    "| --- | --- | --- | --- | --- |",
]
for surface in foundation.target_public_surfaces
    push!(
        rows,
        "| `$(surface.public_name)` | `$(surface.implemented)` | `$(surface.direct_proof_deferred)` | `Tranche $(surface.direct_proof_owner)` | `$(surface.docs_visibility)` |",
    )
end
Markdown.parse(join(rows, "\n"))
```

## Lock items

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Lock item | Title |",
    "| --- | --- |",
]
for item in foundation.lock_items
    push!(rows, "| `$(item.number)` | $(item.title) |")
end
Markdown.parse(join(rows, "\n"))
```

## Keyword owner

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
owner = foundation.keyword_owner
source_files = join(["`$(file)`" for file in owner.source_files], ", ")
target_public_surfaces = join(["`$(surface)`" for surface in owner.target_public_surfaces], ", ")
rows = [
    "| Source files | Target public surfaces |",
    "| --- | --- |",
    "| $(source_files) | $(target_public_surfaces) |",
]
Markdown.parse(join(rows, "\n"))
```

## Supported plot keywords

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Keyword |",
    "| --- |",
]
for keyword in foundation.keyword_owner.supported_plot_keywords
    push!(rows, "| `$(keyword)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Deferred contracts

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Deferred contract | Keyword | Owner tranche | Closure status |",
    "| --- | --- | --- | --- |",
]
for contract in foundation.keyword_owner.deferred_contracts
    push!(
        rows,
        "| `$(contract.id)` | `$(contract.keyword)` | `$(contract.owner_tranche)` | `$(contract.closure_status)` |",
    )
end
Markdown.parse(join(rows, "\n"))
```

## Keyword owner reviewer gate

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
Markdown.parse(
    string(
        "Clear keyword-owner closeout when ",
        foundation.keyword_owner.reviewer_gate.clear,
        "\n\nReject keyword-owner closeout if ",
        foundation.keyword_owner.reviewer_gate.reject,
    ),
)
```

## Layout and annotation owner

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
owner = foundation.layout_annotation_owner
source_files = join(["`$(file)`" for file in owner.source_files], ", ")
supporting_types = join(["`$(type_name)`" for type_name in owner.supporting_types], ", ")
regression_suites = join(["`$(suite)`" for suite in owner.regression_suites], ", ")
rows = [
    "| Source files | Supporting types | Canonical payload | Regression suites | Render consumer | Deferred public proof |",
    "| --- | --- | --- | --- | --- | --- |",
    "| $(source_files) | $(supporting_types) | `$(owner.canonical_payload)` | $(regression_suites) | `Tranche $(owner.render_consumer.owner_tranche)` | `Tranche $(owner.deferred_public_surface_proof.owner_tranche)` |",
]
Markdown.parse(join(rows, "\n"))
```

## Render consumer contract

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
consumer = foundation.layout_annotation_owner.render_consumer
rows = [
    "| Owner tranche | Owner | Source file |",
    "| --- | --- | --- |",
    "| `$(consumer.owner_tranche)` | `$(consumer.owner)` | `$(consumer.source_file)` |",
]
Markdown.parse(join(rows, "\n"))
```

## Render consumer invariants

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Contract |",
    "| --- |",
]
for contract in foundation.layout_annotation_owner.render_consumer.contracts
    push!(rows, "| $(contract) |")
end
Markdown.parse(join(rows, "\n"))
```

## Closed helper regressions

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Regression ID |",
    "| --- |",
]
for regression_id in foundation.layout_annotation_owner.closed_helper_regressions
    push!(rows, "| `:$(regression_id)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Layout and annotation reviewer gate

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
Markdown.parse(
    string(
        "Clear helper-owner closeout when ",
        foundation.layout_annotation_owner.reviewer_gate.clear,
        "\n\nReject helper-owner closeout if ",
        foundation.layout_annotation_owner.reviewer_gate.reject,
    ),
)
```

## Render owner

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
owner = foundation.render_owner
source_files = join(["`$(file)`" for file in owner.source_files], ", ")
supporting_types = join(["`$(type_name)`" for type_name in owner.supporting_types], ", ")
regression_suites = join(["`$(suite)`" for suite in owner.regression_suites], ", ")
rows = [
    "| Source files | Supporting types | Typed layer bundle | Regression suites | Source-set note |",
    "| --- | --- | --- | --- | --- |",
    "| $(source_files) | $(supporting_types) | `$(owner.typed_layer_bundle)` | $(regression_suites) | `$(owner.source_set_note)` |",
]
Markdown.parse(join(rows, "\n"))
```

## Ratified primitive entrypoints

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Primitive |",
    "| --- |",
]
for primitive in foundation.render_owner.primitive_entrypoints
    push!(rows, "| `$(primitive)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Ratified Makie source files

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Source file |",
    "| --- |",
]
for source_file in foundation.render_owner.makie_source_files
    push!(rows, "| `$(source_file)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Closed render regressions

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Regression ID |",
    "| --- |",
]
for regression_id in foundation.render_owner.closed_render_regressions
    push!(rows, "| `:$(regression_id)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Render owner reviewer gate

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
Markdown.parse(
    string(
        "Clear render-owner closeout when ",
        foundation.render_owner.reviewer_gate.clear,
        "\n\nReject render-owner closeout if ",
        foundation.render_owner.reviewer_gate.reject,
    ),
)
```

## Accepted design scenarios

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Scenario ID | Direct proof owner | Closure status | Source |",
    "| --- | --- | --- | --- |",
]
for (scenario_id, scenario) in pairs(foundation.accepted_design_scenarios)
    push!(
        rows,
        "| `:$(scenario_id)` | `Tranche $(scenario.direct_proof_owner)` | `$(scenario.closure_status)` | `$(scenario.source)` |",
    )
end
Markdown.parse(join(rows, "\n"))
```

## Upstream helper regressions

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Regression ID | Proof owner | Source |",
    "| --- | --- | --- |",
]
for (regression_id, regression) in pairs(foundation.upstream_helper_regressions)
    push!(
        rows,
        "| `:$(regression_id)` | `Tranche $(regression.proof_owner)` | `$(regression.source)` |",
    )
end
Markdown.parse(join(rows, "\n"))
```

## Green-state gates

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Gate | Verification artifact | Command |",
    "| --- | --- | --- |",
]
for gate in foundation.green_state_gates
    push!(rows, "| `$(gate.id)` | $(gate.artifact) | `$(gate.command)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Current status

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Status ID | Status | Fact |",
    "| --- | --- | --- |",
]
for state in foundation.current_status
    push!(rows, "| `$(state.id)` | `$(state.status)` | $(state.fact) |")
end
Markdown.parse(join(rows, "\n"))
```

## Stop conditions

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Stop condition | Trigger |",
    "| --- | --- |",
]
for stop_condition in foundation.stop_conditions
    push!(rows, "| `$(stop_condition.id)` | $(stop_condition.condition) |")
end
Markdown.parse(join(rows, "\n"))
```

## Live render proof

- [Render verification](render-verification.md)
