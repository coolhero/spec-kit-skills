# Status — Exploration Coverage

> Reference: Read after `/code-explore status` is invoked.

## Purpose

Display current exploration coverage, trace index, and readiness for synthesis.

---

## Process

### Step 1 — Read State

1. Check if `specs/explore/orientation.md` exists
   - If not: display `⚠️ No exploration started. Run /code-explore [path] to begin.` and stop.
2. Read `orientation.md` — extract Module Map and Exploration Coverage
3. Scan `specs/explore/traces/` — count trace files
4. Check if `specs/explore/synthesis.md` exists

### Step 2 — Display Status

```
📊 Code Exploration Status

Project: [name] ([language] / [framework])
Source:  [target path]

── Detected Domain Profile ──────────────────
Interfaces: [gui(TUI), cli]
Concerns:   [async-state, ipc]
Archetype:  [ai-assistant]
Foundation: [Go stdlib]

Exploration by Domain Axis:
  gui(TUI):      ████░░░░░░ 40% — Traces: 008
  async-state:   ████████░░ 80% — Traces: 001, 002
  ipc:           ██░░░░░░░░ 20% — Traces: 008
  ai-assistant:  ██████░░░░ 60% — Traces: 001, 002, 005
  (unexplored):  auth? realtime? — not detected, but consider tracing
─────────────────────────────────────────────

── Coverage ───────────────────────────────────
| Module              | Coverage | Traces     |
|---------------------|----------|------------|
| context/            | ████████░░ 80% | 001, 002 |
| provider/           | ████░░░░░░ 40% | 005      |
| tool/               | ██████░░░░ 60% | 003, 004 |
| lsp/                | ██░░░░░░░░ 20% | 008      |
| ui/                 | ░░░░░░░░░░  0% | —        |
| session/            | ████░░░░░░ 40% | 007      |

Overall: {X}% ({N} modules explored / {M} total)

── Traces ({T} total) ────────────────────────
| #   | Topic                    | Date       |
|-----|--------------------------|------------|
| 001 | Context assembly         | 2026-03-18 |
| 002 | Priority scoring         | 2026-03-18 |
| 003 | Tool execution           | 2026-03-19 |
| ... | ...                      | ...        |

── Observations ──────────────────────────────
💡 Patterns to adopt: {N}
🔧 Design improvements: {N}
❓ Unresolved questions: {N}
⚠️ Risks/concerns: {N}

── Entities & APIs ───────────────────────────
Entities discovered: {N}
APIs documented: {N}

── Synthesis ──────────────────────────────────
{If synthesis.md exists}:
  ✅ Synthesis generated — {N} Feature candidates
  Last updated: {timestamp}
{If not}:
  ⚠️ Not yet synthesized
  {If T >= 5 AND coverage >= 50%}: 💡 Ready for synthesis — run /code-explore synthesis
  {If T < 5}: ℹ️ Explore more flows before synthesizing (recommended: 5+ traces)
```

#### Context-Aware Status

If `specs/_global/sdd-state.md` exists, add these sections:

```
## SDD Integration Status

| Metric | Value |
|--------|-------|
| **Mode** | Context-Aware (SDD artifacts detected) |
| **Existing Features** | {count} ({list with status}) |
| **Registry Coverage** | Entities: {explored}/{registered} | APIs: {explored}/{registered} |
| **New Discoveries** | {count} entities, {count} APIs not yet in registries |
| **Suggested Profile Updates** | {count} new concerns/interfaces detected |
```

No HARD STOP needed — status is informational only.
