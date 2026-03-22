---
name: code-explore
description: "Interactive source code exploration that produces documented understanding — architecture maps, flow traces with Mermaid diagrams, and Feature candidates — feeding directly into spec-kit SDD workflows. Use this skill when the user wants to study, understand, or learn an unfamiliar codebase, trace how a feature works at the source level, or explore code architecture before building something similar. Output feeds into /smart-sdd init --from-explore or /reverse-spec --from-explore for seamless pipeline transition."
argument-hint: "[path] [--lang <code>] | trace \"topic\" | synthesis | status"
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

**Output path**: `specs/explore/` — location depends on context:
- **Same directory** (`/code-explore .`): output to `./specs/explore/`
- **Different directory** (`/code-explore /other/project`): output to `/other/project/specs/explore/` (so source links work). Creates `explore-study` branch in target repo to keep original clean. Synthesis handoff copies results back to CWD.

---

## Usage

```
/code-explore ./path/to/source          → Orient: scan and generate architecture map
/code-explore trace "context management" → Trace: end-to-end flow tracing (new trace)
/code-explore trace --continue [NNN]     → Continue: append to trace NNN (default: most recent)
/code-explore synthesis                  → Synthesis: aggregate traces into Feature candidates
/code-explore status                     → Status: exploration coverage summary
```

---

## Argument Parsing

```
$ARGUMENTS parsing rules:
  Positional (path)         → target directory for orient (defaults to ".")
  trace "topic"             → topic string for flow tracing
  trace --continue [NNN]    → continue trace NNN (default: most recent)
  synthesis                 → no additional args
  status                    → no additional args
  --update                  → with orient: re-scan and merge new discoveries
  --lang <code>             → artifact language (ko, en, ja, etc.). Stored in orientation.md header.
  --scope <path>            → Limit exploration to a specific directory or module (e.g., --scope src/auth)
  --no-branch               → Skip branch creation; explore in current working tree (useful when already on a feature branch)
```

### Language Persistence

**Single source**: `specs/_global/sdd-state.md` → `**Artifact Language**: <code>`

- **If `--lang` provided**: write to sdd-state.md (create minimal file if absent)
- **If `--lang` not provided**: read from sdd-state.md. If absent, default to `en`
- **If sdd-state.md doesn't exist and `--lang` provided**: create `specs/_global/sdd-state.md` with only `**Artifact Language**: <code>` (reverse-spec/smart-sdd will populate the rest later)

ALL generated content (section headings, descriptions, observations, AskUserQuestion labels) MUST use the stored language.

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
| 🔒 | Security consideration | Authentication bypass, input validation gap, exposed secret pattern |
| 🧪 | Test coverage gap | Untested path, missing edge case, no error test |
| 📊 | Performance concern | N+1 query, unbounded loop, missing cache, synchronous bottleneck |

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
    ├──→ /smart-sdd init --from-explore  (Domain Profile + project identity seed)
    │       └──→ auto-chains to add --from-explore
    │
    ├──→ /smart-sdd add --from-explore   (Feature candidates → Brief input)
    ├──→ /reverse-spec --from-explore    (enhance auto-extraction with human insights)
    └──→ /smart-sdd adopt --from-explore (adoption with pre-understanding)
```

The `--from-explore` flag tells the receiving skill to read `specs/explore/` artifacts:

| Receiving Skill | Reads From | Seeds Into |
|----------------|-----------|-----------|
| **init** | synthesis § Recommended Domain Profile | sdd-state.md Domain Profile, Proposal |
| **init** | synthesis § Cross-Concern Integration Rules | Domain resolver active rules |
| **init** | orientation § Architecture Overview | Constitution principle candidates |
| **init** | synthesis § Unresolved Domain Decisions | Proposal Open Questions |
| **add** (Type 4) | synthesis § Feature Candidates (C###) | Brief input with pre-populated perspectives |
| **add** (Type 4) | synthesis § Entity/API Consolidation | entity-registry.md, api-registry.md seeds |
| **add** (Type 4) | synthesis § Business Rules | business-logic-map.md seeds |
| **add** (Type 4) | synthesis § Unresolved Questions | Brief elaboration questions |
| **reverse-spec** | orientation § Module Map | Phase 1 code pattern hints |
| **reverse-spec** | traces § Flow/Entity/API data | Phase 2 SBI pre-validation |
| **adopt** | traces § per-Feature understanding | adopt-specify source knowledge |

**Primary flow**: `explore → init --from-explore → add --from-explore` (continuous handoff)
**Domain Profile continuity**: orient detects source profile → synthesis derives target profile → init seeds sdd-state.md → add/pipeline uses it throughout

### Context-Aware Mode

When SDD artifacts already exist (`specs/_global/sdd-state.md` or `specs/reverse-spec/`), code-explore activates **Context-Aware Mode** automatically:

- **orient**: Inherits Domain Profile from `sdd-state.md` instead of re-deriving. Shows existing Features (F001~F00N) and their coverage status
- **trace**: Cross-references `entity-registry.md` and `api-registry.md`. Marks entities/APIs as "already registered" vs "newly discovered". Cross-references spec.md SCs to identify untested behaviors
- **synthesis**: Produces additive Feature candidates (C001→ next available F-number). Offers registry update suggestions instead of fresh registry creation. Handoff uses `add --from-explore` instead of `init --from-explore`
- **Detection**: Check in this order: (1) `specs/_global/sdd-state.md` (2) `specs/reverse-spec/roadmap.md` (3) `specs/explore/orientation.md`. If (1) or (2) exists → Context-Aware Mode

This enables all post-adopt and mid-pipeline exploration scenarios without conflicting with existing SDD state.

---

## Gotchas

Accumulated edge cases from real usage. Check this list when hitting unexpected behavior.

| # | Gotcha | What Goes Wrong | Fix |
|---|--------|----------------|-----|
| G1 | Running on a monorepo without `--scope` | Orient tries to map everything → overwhelmingly large orientation → unfocused traces | Always use `--scope services/api` or similar for monorepos |
| G2 | Forgetting `--no-branch` mid-pipeline | code-explore creates its own git branch → conflicts with the pipeline's feature branch | Use `--no-branch` when exploring during an active pipeline |
| G3 | Tracing too broadly (e.g., "the whole auth system") | Trace becomes a wall of text, not actionable | Narrow the topic: "login flow from form submit to session creation" |
| G4 | Running synthesis with only 1-2 traces | Not enough coverage for meaningful architecture map | Complete at least 3-5 traces covering different system areas first |
| G5 | Expecting code-explore to generate SDD artifacts | code-explore produces understanding, not specs | Use `--from-explore` flag with `/smart-sdd init` or `/reverse-spec` to convert |
| G6 | Large codebase (1000+ files) orient timeout | orient scan takes too long or hits context limits | Use `--scope` to limit initial scan area, then expand in subsequent traces |
| G7 | Re-running orient after SDD artifacts exist | Orient overwrites previous orientation without Context-Aware Mode | Context-Aware Mode auto-detects SDD artifacts — let it merge, don't force fresh |

---

## Composability

code-explore is designed to work with the other spec-kit skills:

```
code-explore → /smart-sdd init --from-explore    (new project informed by exploration)
code-explore → /reverse-spec --from-explore       (rebuild informed by exploration)
code-explore → /smart-sdd add --from-explore      (add Features from exploration)
/smart-sdd adopt → code-explore                    (deepen understanding after adoption)
/smart-sdd pipeline → code-explore --no-branch     (mid-pipeline investigation)
```

All transitions preserve Domain Profile continuity via `sdd-state.md`.
