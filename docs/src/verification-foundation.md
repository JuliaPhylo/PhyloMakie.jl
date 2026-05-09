```@meta
CurrentModule = PhyloMakie
```

# Verification foundation

Tranche 1 establishes the source-side verification owner, the test-side
fixture corpus, and the thin module shell. It does not implement
`phyloplot`, `phyloplot!`, or Makie `plot(net)` dispatch.

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

## Accepted design scenarios

```@eval
using Markdown
using PhyloMakie

foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)
rows = [
    "| Scenario ID | Direct proof owner | Source |",
    "| --- | --- | --- |",
]
for (scenario_id, scenario) in pairs(foundation.accepted_design_scenarios)
    push!(
        rows,
        "| `:$(scenario_id)` | `Tranche $(scenario.direct_proof_owner)` | `$(scenario.source)` |",
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
