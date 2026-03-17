---
name: code-explore
description: Interactive source code exploration that produces documented understanding — architecture maps, flow traces with Mermaid diagrams, and Feature candidates — feeding directly into spec-kit SDD workflows.
argument-hint: "[path] | trace \"topic\" | synthesis | status"
allowed-tools: [Read, Grep, Glob, Bash, Write, Edit, AskUserQuestion]
---

# Code-Explore: Interactive Source Code Understanding

> **🚨 MANDATORY RULE — READ FIRST 🚨**
>
> **Empty Response Enforcement**
> Every AskUserQuestion in this skill MUST be checked after returning:
> 1. **CHECK the response** — is it empty, blank, or missing a selection?
> 2. **If empty → call AskUserQuestion AGAIN.** Do NOT proceed. Do NOT assume a default.
> 3. **Only proceed when the user has explicitly selected an option.**

Interactive, user-driven source code exploration that produces persistent, structured documentation. Unlike reverse-spec (which auto-extracts artifacts for redevelopment), code-explore supports **human-guided understanding** — the user decides what to explore, the agent traces the code and documents findings.

**Output path**: `specs/explore/` relative to CWD.

---

## Usage

```
/code-explore ./path/to/source          → Orient: scan and generate architecture map
/code-explore trace "context management" → Trace: end-to-end flow tracing
/code-explore synthesis                  → Synthesis: aggregate traces into Feature candidates
/code-explore status                     → Status: exploration coverage summary
```

---

## Argument Parsing

```
$ARGUMENTS parsing rules:
  Positional (path)         → target directory for orient (defaults to ".")
  trace "topic"             → topic string for flow tracing
  synthesis                 → no additional args
  status                    → no additional args
  --update                  → with orient: re-scan and merge new discoveries
```

---

## Command Routing

| Input Pattern | Command File |
|---------------|-------------|
| `/code-explore [path]` | Read `commands/orient.md` |
| `/code-explore --update` | Read `commands/orient.md` (update mode) |
| `/code-explore trace "..."` | Read `commands/trace.md` |
| `/code-explore synthesis` | Read `commands/synthesis.md` |
| `/code-explore status` | Read `commands/status.md` |

---

## Conventions

### Artifact Path

```
specs/explore/
├── orientation.md                # Architecture map + exploration coverage
├── traces/
│   ├── 001-context-assembly.md   # Numbered trace documents
│   ├── 002-priority-scoring.md
│   └── ...
└── synthesis.md                  # Feature candidates + handoff prep
```

### Feature Candidate IDs

Use **`C` prefix** (Candidate), not `F` (Feature):
- `C001-context-engine`, `C002-tool-runtime`, etc.
- `C → F` conversion happens during handoff to smart-sdd add

### Trace Numbering

Auto-increment: scan `specs/explore/traces/` for highest existing number, use next.
Format: `{NNN}-{slug}.md` where slug is derived from the topic (kebab-case, max 30 chars).

### Observation Icons

| Icon | Meaning | Synthesis aggregation |
|------|---------|----------------------|
| 💡 | Pattern to adopt in my project | "Patterns to Adopt" section |
| ❓ | Open question to investigate | "Unresolved Questions" section |
| ⚠️ | Concern or risk observed | "Risks and Concerns" section |
| 🔧 | Improvement idea for my version | "Design Improvements" section |

### Orientation Coverage

After each trace completes, auto-update `orientation.md` coverage section:
- Count files traced per module vs total files in module
- Display as progress bar: `████░░░░░░ 40%`
- If trace discovers a module not in orientation, add it automatically

### Mermaid Diagrams

Every trace MUST include at least one Mermaid diagram:
- **Flow traces** → `sequenceDiagram` (call chain between components)
- **Data model discoveries** → `erDiagram` (entity relationships)
- **Decision logic** → `flowchart` (branching/routing logic)

### Synthesis Nudge

After each trace completion, display trace count and coverage:
```
📝 Trace {NNN} saved. (Total: {N} traces, Coverage: {X}%)
```

When total traces ≥ 5 AND coverage ≥ 50%, add:
```
💡 Exploration is progressing well. Run /code-explore synthesis
   to organize your understanding into Feature candidates.
```

If user ignores, re-suggest after 3 more traces. Never more than twice.

### Relationship to Other Skills

```
code-explore (understand)
    │
    ├──→ /reverse-spec --from-explore    (enhance auto-extraction with human insights)
    ├──→ /smart-sdd add --from-explore   (Feature candidates → Brief input)
    └──→ /smart-sdd adopt --from-explore (adoption with pre-understanding)
```

The `--from-explore` flag tells the receiving skill to read `specs/explore/synthesis.md`:
- **Entity observations** → seed entity-registry.md
- **API observations** → seed api-registry.md
- **Business rules** → seed business-logic-map.md
- **Feature candidates (C###)** → pre-populate Feature list for Brief
- **Unresolved questions** → feed into Brief elaboration
