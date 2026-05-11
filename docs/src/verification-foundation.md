```@meta
CurrentModule = PhyloMakie
```

# Verification foundation

Tranche 6 closes the compatibility-shell retirement on top of the tranche-1
verification foundation, the tranche-3 layout and annotation owners, the
tranche-4 render owner, and the tranche-5 Makie-native public owner.

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

## Owner summary

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
public_attribute_files =
    join(["`$(file)`" for file in foundation.public_attribute_owner.source_files], ", ")
layout_files =
    join(["`$(file)`" for file in foundation.layout_annotation_owner.source_files], ", ")
render_files = join(["`$(file)`" for file in foundation.render_owner.source_files], ", ")
public_plot_files =
    join(["`$(file)`" for file in foundation.public_plot_owner.source_files], ", ")
rows = [
    "| Owner | Canonical payload or entrypoint | Source files |",
    "| --- | --- | --- |",
    "| Public attribute owner | `$(foundation.public_attribute_owner.canonical_payload)` | $(public_attribute_files) |",
    "| Layout and annotation owner | `$(foundation.layout_annotation_owner.canonical_payload)` | $(layout_files) |",
    "| Render owner | `$(foundation.render_owner.typed_layer_bundle)` | $(render_files) |",
    "| Public plot owner | `$(foundation.public_plot_owner.public_recipe)` | $(public_plot_files) |",
]
Markdown.parse(join(rows, "\n"))
```

## Public attribute owner

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
owner = foundation.public_attribute_owner
rows = [
    "| Field | Live value |",
    "| --- | --- |",
    "| Canonical payload | `$(owner.canonical_payload)` |",
    "| Recipe attribute surface | `$(owner.recipe_attribute_surface)` |",
    "| Runtime consumers | $(join(["`$(consumer)`" for consumer in owner.runtime_consumers], ", ")) |",
    "| Legacy rejection source | `$(owner.legacy_rejection.source)` |",
]
Markdown.parse(join(rows, "\n"))
```

## Public attribute set

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Public attribute |",
    "| --- |",
]
for keyword in foundation.public_attribute_owner.supported_public_attributes
    push!(rows, "| `$(keyword)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Rejected legacy spellings

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Legacy spelling |",
    "| --- |",
]
for keyword in foundation.public_attribute_owner.legacy_rejection.rejected_spellings
    push!(rows, "| `$(keyword)` |")
end
Markdown.parse(join(rows, "\n"))
```

## Render and public-owner integration

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Field | Live value |",
    "| --- | --- |",
    "| Render consumer | `$(foundation.layout_annotation_owner.render_consumer.owner)` |",
    "| Public surface consumer | `$(foundation.layout_annotation_owner.public_surface_consumer.owner)` |",
    "| Render owner reuse | `$(foundation.render_owner.public_owner_reuse.owner)` |",
    "| Public owner boundary | `$(foundation.public_plot_owner.caller_owned_network_boundary)` |",
]
Markdown.parse(join(rows, "\n"))
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

## Green gates and current status

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
gate_rows = [
    "| Gate | Artifact | Command |",
    "| --- | --- | --- |",
]
for gate in foundation.green_state_gates
    push!(gate_rows, "| `$(gate.id)` | $(gate.artifact) | `$(gate.command)` |")
end

status_rows = [
    "| Status ID | State | Fact |",
    "| --- | --- | --- |",
]
for status in foundation.current_status
    push!(status_rows, "| `$(status.id)` | `$(status.status)` | $(status.fact) |")
end

Markdown.parse(join(vcat(gate_rows, [""], status_rows), "\n"))
```

## Stop conditions

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Stop condition ID | Condition |",
    "| --- | --- |",
]
for stop_condition in foundation.stop_conditions
    push!(rows, "| `$(stop_condition.id)` | $(stop_condition.condition) |")
end
Markdown.parse(join(rows, "\n"))
```
