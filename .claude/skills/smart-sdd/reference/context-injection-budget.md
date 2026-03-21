# Context Injection: Context Budget Protocol

> Extracted from `context-injection-rules.md` for lazy loading.
> Only read this file when assembled context approaches the agent's usable context window.

When assembled context for a pipeline step approaches the agent's usable context window, sections must be triaged. This protocol defines the priority ordering and overflow behavior.

## Priority Tiers

Every injected section falls into one of three tiers:

| Tier | Label | Rule |
|------|-------|------|
| **P1** | Must-Inject | Always injected in full. Omission breaks the command. |
| **P2** | Inject-if-budget | Injected when budget allows. Summarizable to ≤30% of original if space is tight. |
| **P3** | Skip-safe | Skipped first when over budget. Agent re-reads on demand if needed during execution. |

## P1 Sections per Command

| Command | P1 (never skip) |
|---------|-----------------|
| specify | Pre-context §FR drafts, §SC drafts, §SBI (rebuild), Foundation Decisions (T0) |
| plan | spec.md (full), entity-registry (owned), api-registry (provided), Foundation Constraints |
| tasks | plan.md (full) |
| implement | tasks.md (full), plan.md §Pattern Constraints, plan.md §Interaction Chains (UI) |
| verify | spec.md §FR list, pre-context §cross-Feature points, registries (modified entries) |
| analyze | spec.md + plan.md (both full) |

P2 includes: business-logic-map, stack-migration, referenced entities/APIs, preceding Feature results, source reference file list, pre-context draft sections.
P3 includes: naming remapping, environment variables (presence check only), static resources, CSS value map, visual reference manifest.

## Overflow Protocol

When total assembled context exceeds approximately 80% of the usable window (reserve 20% for command execution and agent reasoning):

```
Step 1: SUMMARIZE P2 sections
  → Replace with 3-5 bullet point summary
  → Mark in Checkpoint: "⚠️ {Section} summarized due to context budget"

Step 2: SKIP P3 sections
  → Omit entirely
  → Mark in Checkpoint: "ℹ️ {Section} skipped (re-readable on demand)"

Step 2.5: RE-READ GATE for skipped P2/P3 sections
  → After command execution completes (before Review), check if any skipped/summarized section
    is relevant to the generated artifact's content:
    - If spec.md references an entity that was in a summarized registry section → re-read that entity
    - If plan.md defines architecture touching a skipped business rule → re-read business-logic-map.md
    - If implement touches files listed in a skipped source reference → re-read those entries
  → Display in Review: "📖 Re-read [N] sections that were initially skipped/summarized:
    [list of sections re-read and why]"
  → If NO skipped sections were relevant → display: "📖 Skipped sections verified — none relevant to generated output"

Step 3: SPLIT if still over budget
  → implement: reduce parallel task batch (8 → 4 → 2 → 1)
  → specify/plan with large pre-context: split into 2 injection rounds
  → Mark in Checkpoint: "⚠️ Context split: {N} rounds needed"
```

## Size Heuristics

The agent does NOT perform exact token counting. Use these thresholds to trigger budget triage:

| Signal | Action |
|--------|--------|
| plan.md > 15 KB | Watch — summarize referenced entities |
| Pre-context > 15 KB (after reverse-spec) | Summarize P2 draft sections |
| Entity registry > 3 owned entities | Summarize referenced (non-owned) entities to name + key fields only |
| Source reference > 30 files (rebuild) | Summarize to top-10 most relevant + count |
| Source Reference > 30 files per Feature | Apply Tier A/B/C prioritization (see reverse-spec Phase 1-4a) |
| SBI > 500 entries (Large project) | Use domain-prefixed B### IDs; P3 entries summarized to one-line |
| Modules > 60 | Use hierarchical domain grouping in all displays and Checkpoint summaries |
| Implement with 8+ parallel tasks | Reduce batch size preemptively |

## Checkpoint Budget Indicator

At every Checkpoint display, include a one-line budget status:

```
📊 Context: {P1 count}/{total sections} must-inject | {N} summarized | {M} skipped
```

This gives the user visibility into what context the agent is working with and whether any sections were trimmed.
