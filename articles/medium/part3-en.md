400 Markdown Files That Think: The Architecture of spec-kit-skills

Part 3 of 4 — Design Philosophy, File Structure, Extensibility

![Part 3 Cover](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part3.png)

*Continued from Part 2: Three Skills, One Pipeline — (link to Part 2 on Medium)*

---

## The Paradox of AI Skill Design

Here's the strange truth about building tools for AI agents: **the agent is both your user and your runtime.**

When you write a React component, React runs it. When you write a Claude Code skill, Claude *reads* it — as markdown — and decides how to behave. Your "code" is natural language. Your "compiler" is an LLM. Your "bugs" are behavioral: the agent does the wrong thing not because of a syntax error, but because it misunderstood your intent.

This changes everything about how you design.

---

## Three Foundational Philosophies

Every design decision in spec-kit-skills traces back to three principles. We learned them the hard way — through hundreds of failed pipeline runs.

---

### P1: Context Continuity

> Information must flow continuously through every pipeline stage. Nothing gets lost at transitions.

This sounds obvious. It isn't.

In practice, an AI agent starting Feature 3 knows nothing about Feature 1 — unless you explicitly load Feature 1's artifacts into its context. The agent doesn't have a "project memory." It has a context window that gets compressed and eventually forgets.

Context Continuity manifests in three ways:

**P1-a: Domain Profile is a First-Class Citizen.** It's not a one-time config. It actively shapes every stage — which probes get asked during `add`, which rules activate during `specify`, which verification steps run during `verify`.

**P1-b: Source Code Fidelity.** Specs describe *what to build*, not *where it came from*. Source analysis stays in reverse-spec artifacts. Smart-sdd specs are source-agnostic. This means you can rebuild a feature differently from the source without the spec being contaminated by the old implementation.

**P1-c: Cross-Feature Memory (GEL).** Entity registries, API registries, pre-context, stubs — these are the Global Evolution Layer. Feature 3 reads Feature 1's registry. The information flows forward through files, not through the agent's memory.

---

### P2: Enforce, Don't Reference

> "See X for details" has zero enforcement power. Rules must be enforced at the point of execution, not referenced from a distance.

This is the most counterintuitive principle. In normal software, you write a function once and call it from everywhere. In agent skills, **referenced rules get ignored.**

Why? Because the agent treats references as optional reading.

"See verify-phases.md for the full verification protocol"
→ Agent: "there's more info somewhere, but I'll just do build + test and call it done."

Every critical rule needs three things:

**Inline instruction** — the rule appears directly at the execution point

**Blocking gate** — not a warning, a blocker. The agent cannot proceed without compliance.

**Anti-pattern examples** — explicit WRONG and RIGHT patterns

This is why spec-kit-skills has seemingly redundant text across files. It's intentional. The HARD STOP re-ask text appears 30+ times because each occurrence is at a different execution point, and referencing a shared file doesn't work.

---

### P3: File over Memory

> Every intermediate artifact and state goes into a file. Never rely on agent memory.

The agent's context window is **limited** (gets compressed), **session-scoped** (gone when session ends), and **non-inspectable** (you can't see what the agent remembers).

Files are **persistent** (survive across sessions), **diffable** (`git diff` shows changes), **editable** (you can fix a spec manually), and **shareable** (another agent or human can continue).

This is why `sdd-state.md` exists. It's the project's state machine — in a file, not in the agent's head.

---

## The File Architecture

Each skill follows the same pattern:

**SKILL.md** — System prompt. Slim routing + MANDATORY RULES. Always loaded. ~200 lines.

**commands/** — On-demand workflows. Only the invoked command gets loaded.

**reference/injection/** — Per-command context injection rules. Orchestrates which domain modules and artifacts load for each pipeline step.

**domains/** — Modular domain expertise:
- `_core.md` — Universal rules (always loaded)
- `_resolver.md` — Module loading logic
- `interfaces/` — 9 interface modules (gui, cli, http-api, grpc, tui, embedded, mobile, library, data-io)
- `concerns/` — 48 concern modules (auth, realtime, resilience, etc.)
- `archetypes/` — 15 archetype modules (ai-assistant, microservice, etc.)
- `profiles/` — 15 pre-built profiles

---

### Why This Structure?

**Context efficiency.** Here's the math:

- Always loaded: ~200 lines (SKILL.md)
- Per-command: ~500 lines (the invoked command file)
- Per-domain: ~400 lines (3–5 modules matching your profile)
- Per-Feature: ~200 lines (pre-context + spec)
- **Total: ~1,300 lines in context**

Compare this to loading everything: ~15,000+ lines → context overflow. The selective loading is what makes this work with real LLM context windows.

---

### The Domain Module Loading Order

When the pipeline runs, domain modules load in a specific order. Later modules extend earlier ones:

1. `_core.md` — Universal rules (always)
2. `interfaces/{name}.md` — Per Interface (gui, cli, etc.)
3. `concerns/{name}.md` — Per Concern (auth, realtime, etc.)
4. `archetypes/{name}.md` — Per Archetype (ai-assistant, etc.)
5. `foundations/{framework}.md` — Per Foundation (electron, fastapi, etc.)
6. `org-convention.md` — Organization-wide rules (optional)
7. `scenarios/{name}.md` — Per Scenario (greenfield, rebuild, etc.)
8. `domain-custom.md` — Project-level overrides (optional)

Each module has standardized sections. Rules accumulate — if both `gui` and `realtime` are active, their SC Generation Rules merge.

---

### Context Injection — The Key Innovation

Each pipeline step has an **injection file** that defines what context gets assembled:

- `injection/specify.md` — What context speckit-specify receives
- `injection/plan.md` — What context speckit-plan receives
- `injection/implement.md` — What context speckit-implement receives

Think of it as a dependency injection container for natural language rules.

Example: when `speckit-specify` runs for an `ai-assistant` + `gui` + `realtime` project, the injection file loads universal SC rules from `_core.md`, UI-specific patterns from `gui.md`, streaming requirements from `realtime.md`, and LLM-specific extensions from the `ai-assistant` archetype. All merged into one coherent context.

---

## Extensibility

**Adding a new Concern module:** Create `domains/concerns/your-concern.md`, follow the section schema. That's it — the resolver auto-discovers it.

**Adding a new Foundation:** Create `domains/foundations/your-framework.md`. Add specify-time and implement-time sections. Auto-loaded when matched.

**Creating a custom Profile:** Write a ~10-line manifest declaring your axes. Save to `domains/profiles/`. Use with `--profile`.

No code changes. No registration. Convention-based: if a file exists at the expected path, it gets loaded.

---

## 🤖 For Agents — Architecture Reference

```
architecture:
  principles:
    P1 Context Continuity:
      - Domain Profile is first-class (shapes every pipeline stage)
      - Artifact Separation (specs describe WHAT, not WHERE FROM)
      - Cross-Feature Memory via GEL files

    P2 Enforce Don't Reference:
      - Every critical rule: inline + blocking gate + anti-pattern
      - Never "See X.md for details" for critical behavior
      - 30+ inline repetitions > 1 reference that gets ignored

    P3 File over Memory:
      - All state in files (sdd-state.md, registries, pre-context)
      - Agent recovers from context compression by reading files
      - git diff = full audit trail

  file structure:
    SKILL.md: ~200 lines, always loaded (routing + mandatory rules)
    commands/: loaded per invocation (~500 lines)
    reference/injection/: context assembly per pipeline step
    domains/: loaded per Domain Profile (~400 lines for 3-5 modules)

  module loading order:
    _core → interfaces → concerns → archetypes → foundations → org → scenarios → custom

  context budget:
    typical total: ~1,300 lines
    worst case (all loaded): ~15,000 lines (avoided by selective loading)

  extensibility:
    add concern: create file at domains/concerns/{name}.md → auto-discovered
    add foundation: create file at domains/foundations/{name}.md → auto-loaded
    add profile: create file at domains/profiles/{name}.md → usable via --profile
```

---

*Next: **Part 4 — Lessons Learned: Building Skills for AI Agents** — failure patterns, tips, and practical guidance for skill developers.*
