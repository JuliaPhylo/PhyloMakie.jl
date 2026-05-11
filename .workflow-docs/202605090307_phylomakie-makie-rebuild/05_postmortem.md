---
date-created: 2026-05-10T18:29:38-07:00
date-updated: 2026-05-10T21:00:00-07:00
workflow-instrument: Postmortem
workflow-status: Approved
authoring-agent-thread-id:
  - 019e0c2f-337d-7973-b124-418e4b1c05e3
  - claude-sonnet-4-6-evaluation-20260510T2100-07:00
workflow-production-id: 202605090307_phylomakie-makie-rebuild
workflow-location: /home/jeetsukumaran/site/storage/local/computing/research/20260508_phylogenetic-graph-visualization/phylomakie-workspace/PhyloMakie.jl
workflow-prd: .workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md
workflow-tranche: .workflow-docs/202605090307_phylomakie-makie-rebuild/02_tranches.md
---

# Postmortem: compatibility-first drift during the PhyloMakie clean port

## Scope

This postmortem covers the compatibility-first planning and implementation
chain that the revised PRD and revised tranche plan explicitly replaced on
2026-05-10.

This is a responsibility document, not a blame ritual.

The question is not "who made one bad call?".
The question is "what decision path changed a clean port into a legacy-shell
preservation effort, and what guardrails must now exist so that path is harder
to repeat?".

## Ground truth

The clean-port target is clear in the revised design brief and PRD:

- the package is a Makie-native product, not a wrapped legacy shell
- capability parity is required
- API mimicry is not required
- runtime compatibility shells are not accepted end-state architecture

Evidence:

- `design/prod01-vision.md` (revised in commit d13faf2, 2026-05-10)
- `design/prod01-vision-supplement.md` (revised in commit d13faf2, 2026-05-10)
- `.workflow-docs/202605090307_phylomakie-makie-rebuild/01_prd.md` (revised in commit d13faf2, 2026-05-10)

**Note (added by evaluating session claude-sonnet-4-6-evaluation-20260510T2100):**
All three evidence documents are the *revised* versions. `design/prod01-vision-supplement.md`
in its original form (commit bbf114c, 2026-05-09T03:01) was itself a primary
source of the misframing, not evidence against it. Citing the revised supplement
as ground truth for the clean-port intent without acknowledging its original
content is an elision. See the amended Finding 1 below.

## Findings

### Finding 1: the original wrong turn was architectural, not implementation-level

The first major failure was not in rendering code or layout code.
It was the decision to make the historical `PhyloPlots.plot` keyword shell the
intended semantic center of the package.

The revised tranche plan names this explicitly:

- historical tranche 2 created `keyword_normalization.jl` and
  `keyword_contract.jl`
- historical tranche 2 made the legacy keyword shell the intended semantic
  center of the future package

That was the decisive misframing.

**Amendment (evaluating session claude-sonnet-4-6-evaluation-20260510T2100):**
The decisive misframing preceded tranche 2 by approximately fourteen hours.
Git history establishes the following sequence:

| Time | Commit | Event |
|------|--------|-------|
| 2026-05-09T02:01 | 2e3bf33 | User writes `design/prod01-vision.md`: *"internal API can be designed from the ground up for idiomatic Makie conventions"* but also *"replicated completely"* — genuine ambiguity |
| 2026-05-09T03:01 | bbf114c | Agent writes `design/prod01-vision-supplement.md`, resolving the ambiguity: *"Its complete keyword surface is the **authoritative specification** for `phyloplot`. Behaviors are non-negotiable."* — this is the actual first wrong step |
| 2026-05-09T04:14 | ccd0be3 | Agent writes PRD from supplement, enshrining keyword surface parity as Lock item 2 |
| 2026-05-09T05:15 | 9546506 | Agent writes tranche plan; Tranche 2 titled "Public keyword normalization owner" |
| 2026-05-09T16:58 | 712c2d8 | Tranche 2 tasking written: *"No Makie-idiom renaming is authorized in tranche 2"* |

Tranche 2 executed faithfully against a plan that was already wrong.
Attributing the misframing to tranche 2 is accurate as far as it goes, but it
obscures that the supplement document — agent-authored, written before the PRD
existed — is where the user's ambiguous brief was converted into a keyword-parity
mandate. That is the earliest fixable point in the chain.

The supplement also introduced the 29-keyword compliance table that became the
content of `keyword_contract.jl`. The contract file's entire scope was
downstream of one interpretive decision made in the supplement.

### Finding 2: the workflow optimized for keyword continuity after API redesign had already been authorized

The user had already authorized a Makie-native redesign, but the workflow kept
treating keyword preservation as the safest path.

That substituted the wrong question:

- wrong question: "How do we preserve the old surface while swapping
  backends?"
- right question: "How do we preserve plotting capabilities while establishing
  one Makie-native owner?"

The revised PRD now states this directly by resetting the goal from
compatibility-first keyword parity to capability parity.

**Amendment (evaluating session claude-sonnet-4-6-evaluation-20260510T2100):**
The claim that "the user had already authorized a Makie-native redesign" before
the compatibility path was set is not fully supported by the git history.

The user's first brief (2e3bf33, 2026-05-09T02:01) was genuinely ambiguous. It
said both *"internal API can be designed from the ground up"* and *"replicated
completely."* The authorization for API redesign — made explicit with phrases
like *"I authorized a new API"* and *"I do not want the user to pretend they are
using the same package"* — appears in the course correction commit (d13faf2,
2026-05-10T13:45), not before the supplement was written.

The supplement did not suppress an already-clear instruction. It resolved a
genuinely ambiguous brief in the wrong direction. This distinction matters for
how the failure is characterized:

- if the authorization was already clear, the failure is a governance failure
  (wrong question asked despite correct instruction)
- if the brief was ambiguous, the failure is an interpretation failure at the
  pre-PRD gap-closing stage

The git record supports the latter. The supplement agent was filling a real gap,
but filled it with the wrong answer and locked it in as non-negotiable.

### Finding 3: tranche 5 tolerated too much transitional debt

The tranche-5 tasking is already much better than the earlier architecture,
but it still allowed a "tightly local transitional bridge" through
`PlotKeywordSpec`.

That decision was understandable as a sequencing move, but it was still the
wrong compromise.

Once the Makie-native public plot owner existed, the live runtime should have
been pulled through that owner as quickly as possible.
Allowing the bridge to survive created a package that looked corrected at the
surface while still being centered internally on the wrong payload.

### Finding 4: requiring tranche 6 is justified, but it is remediation work

Tranche 6 is not evidence that the revised architecture is bad.
It is evidence that the earlier compatibility-first chain already landed too
much runtime baggage.

The tranche-6 tasking is honest: it exists to remove
`keyword_normalization.jl`, `keyword_contract.jl`, and `PlotKeywordSpec` from
the accepted runtime path and to make the Makie-native owner the actual center.

That is legitimate cleanup.
It also should not have been needed if the earlier planning chain had framed
the port correctly from the start.

### Finding 5: requiring tranche 7 is reasonable only if it stays docs- and truth-surface-only

Tranche 7 is appropriate for:

- docs closure
- migration material
- final verification truth-surface cleanup
- capability-mapping explanations

Tranche 7 is not appropriate for remaining runtime-owner cleanup.
If core runtime retirement had still been deferred that late, that would have
been another planning failure.

## Responsibility map

### Primary responsibility: the original planning and trancheing pass

The biggest failure belongs to the planning chain that translated a clean port
into a compatibility-first roadmap.

The specific mistake was not "using a bridge".
The specific mistake was treating the bridge as a normal architectural center
instead of as suspect debt that should die immediately.

**Amendment (evaluating session claude-sonnet-4-6-evaluation-20260510T2100):**
More precisely: the earliest identifiable responsible agent is the one that
authored `design/prod01-vision-supplement.md` (commit bbf114c,
2026-05-09T03:01). That agent made the interpretive decision that converted an
ambiguous user brief into an explicit keyword-parity mandate, attached a
29-keyword compliance table, and marked behaviors as "non-negotiable." Every
downstream agent — PRD author, tranche planner, tranche 2 tasker, tranche 2
implementer — operated correctly within the mandate they were given.

The pre-PRD gap-closing stage is therefore the highest-leverage point for
prevention. It is also the point least covered by existing review gates,
because gap-closing happens before the PRD exists and therefore before most
governance checks engage.

### Secondary responsibility: review and approval layers that did not stop it

Any agent, including me, that reviewed or passed forward the
compatibility-first plan without stopping on the semantic-center problem shares
responsibility.

The useful corrective sentence is not "I missed this".
The useful corrective sentence is:

"A review gate failed to reject a runtime design whose main job was preserving
legacy syntax after API redesign had already been authorized."

**Amendment (evaluating session claude-sonnet-4-6-evaluation-20260510T2100):**
A secondary failure is that this postmortem's original form cited
`design/prod01-vision-supplement.md` under "Ground truth" without noting that
the original supplement was the source of the problem. The revised supplement
(d13faf2) correctly supports the clean-port target; the original did not. A
postmortem that does not distinguish these versions is partially self-exculpating.

### Lower responsibility: execution agents following the wrong plan

Implementing agents usually follow the tasking shape they are given.

They still own any extra overengineering they add locally, but the core
misdesign here was upstream of most execution:

- wrong semantic center
- wrong public-product framing
- wrong staging assumptions

## Evaluation of the tranche-6 and tranche-7 redirection

### Tranche 6

Keep it if needed for runtime retirement.
It is the correct repair tranche for an already-landed bridge.

Do not pretend it is good original architecture.
It is debt-eradication work caused by the earlier misframing.

### Tranche 7

Keep it if it remains:

- docs-first
- migration-first
- verification-metadata-first

Do not let tranche 7 absorb any remaining runtime semantic-center work.

## Concrete project-harness changes

**Amendment (evaluating session claude-sonnet-4-6-evaluation-20260510T2100):**
One additional change is required, targeting the pre-PRD gap-closing stage
specifically (see amended Finding 1):

### 0. Require explicit user confirmation before gap-closing documents lock in non-negotiable constraints

Pre-PRD supplement documents (or any equivalent gap-closing artifact) that add
compliance tables, mark behaviors as "non-negotiable," or enumerate an
authoritative keyword or API surface must present these to the user for
explicit confirmation before the PRD treats them as settled.

Gap-closing happens before governance checks engage. It is currently the
highest-risk stage for misinterpretation of ambiguous user language. An agent
resolving ambiguity at this stage without a confirmation gate can propagate a
wrong interpretation through every subsequent document in the chain.

The specific failure mode to prevent: an agent reads an ambiguous phrase
("replicated completely"), resolves it to the stricter interpretation
(keyword-surface parity), marks it non-negotiable, and embeds it in a
supplement that the PRD then treats as authoritative user intent.

### 1. Require explicit port classification in workflow documents

Every PRD, tranche plan, and tasking file for a port, rewrite, or backend
replacement must explicitly classify the work as one of:

- compatibility-preserving port
- clean port with API redesign
- staged migration with temporary compatibility surface

Without that classification, the workflow is allowed to drift into whatever
seems locally convenient.

### 2. Require an explicit compatibility stance

Workflow documents must state:

- whether legacy public names are required at all
- whether a runtime compatibility shell is authorized at all
- whether compatibility belongs only in docs and migration material

This decision must be in the PRD and passed forward into tranche and tasking
documents.

### 3. Forbid unnamed temporary bridges

No workflow document may authorize a transitional bridge unless it names:

- the one owner allowed to consume it
- the exact tranche or task that deletes it
- the failing proof that rejects it at end state

If those three things are absent, the bridge is architecture drift.

### 4. Forbid late cleanup of the semantic center

Once a new public owner exists, runtime semantic-center cleanup must either:

- finish in the same tranche
- or move into the immediately following foundational cleanup tranche

It must not drift into a docs tranche, migration tranche, or vague "later
cleanup" state.

### 5. Add review gates that ask the right question

Architecture reviews, tranche reviews, and final audits should ask:

- is the code preserving historical capability or historical syntax?
- what is the actual semantic center of the package right now?
- could the runtime delete the compatibility layer today without changing the
  accepted public API?
- are docs and verification teaching the final architecture or the staging
  scaffolding?

## Concrete shared-skill changes to make outside this repo

These should be added to the shared architecture skills:

- `devflow-architecture-01--write-a-prd`
  Add mandatory port classification and compatibility-stance sections.
- `devflow-architecture-02--prd-to-tranches`
  Add a rule that clean ports may not defer semantic-center repair into late
  cleanup or narrative tranches.
- `devflow-architecture-03--tranche-to-tasks`
  Add a rule that any temporary bridge must name its consuming owner, kill
  task, and failure proof.
- `devflow-architecture-05--code-review`
  Add a first-pass check for "wrong semantic center despite locally green
  behavior".
- `devflow-architecture-06--final-audit`
  Add explicit questions about compatibility-shell survival, bridge drift, and
  docs that still teach staging scaffolds as target architecture.

## Current recovery status

The current worktree already shows that recovery has started.

The main module shell no longer includes `keyword_contract.jl` or
`keyword_normalization.jl`, and the verification foundation now treats
`PhyloPlotAttributes` plus the Makie-native public plot owner as the canonical
runtime path.

That means the revised PRD and tranche plan are not the problem.
They are the repair.
