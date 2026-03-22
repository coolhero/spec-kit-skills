Three Skills, One Pipeline: How code-explore, reverse-spec, and smart-sdd Work Together

Part 2 of 4 — Each Skill in Detail

![Part 2 Cover](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part2.png)

*Continued from Part 1: Why Your Agent Needs a Harness — (link to Part 1 on Medium)*

---

## /code-explore — Understand Before You Build

Most developers start AI projects by saying "build X." But the best projects start by saying "let me understand Y first."

`/code-explore` is built on this premise. It's an interactive exploration tool that produces **documented understanding** — not code, not specs, just structured knowledge about a codebase.

---

### How It Works

**Step 1: Orient — Scan the codebase**

```
/code-explore /path/to/project
```

The agent scans the project and generates `orientation.md`:

- Project type, language, framework detection
- Module map with file counts and relationships
- Domain Profile derivation (5 axes)
- Concurrency model detection (async/await, goroutines, thread pool, actor model, event loop)
- Suggested exploration topics

Think of it as a senior engineer spending 30 minutes browsing the codebase before writing anything — except the browsing is documented.

**Step 2: Trace — Follow specific flows**

```
/code-explore trace "how does the auth middleware validate tokens"
```

The agent traces the flow from entry point to completion:

- Finds the entry point (keyword search + import analysis)
- Follows call chains depth-first
- Records source locations, data transformations, branching, API calls
- Generates a Mermaid sequence diagram
- Notes entities, APIs, and business rules discovered along the way

Each trace produces a standalone document in `specs/explore/traces/`.

**Step 3: Synthesis — Consolidate into Feature candidates**

```
/code-explore synthesis
```

After 3–5 traces, synthesis aggregates everything into consolidated entity/API maps, categorized observations, a recommended Domain Profile, and Feature candidates ready to feed into smart-sdd.

---

### Five Trace Strategies

Not all flows are linear. The agent picks the right strategy:

**Sequential** — Request → response (REST handler). Uses sequence diagram.

**Connection Lifecycle** — TCP accept → handle → close (servers). Shows long-lived connections.

**State Machine** — Online/offline/away (presence systems). Uses state diagram instead of sequence.

**Pub/Sub Fan-out** — Publish → broker → N consumers. Traces both sides.

**Concurrent Actors** — Multiple goroutines/tasks in parallel. Annotates which thread each step runs on.

This matters because a WebSocket presence system isn't a "flow" — it's a state machine. Tracing it as a sequence diagram would be misleading.

---

### The "What I'd Do Differently" Pattern

Every trace naturally generates improvement observations (marked with 🔧). During synthesis, these become explicit design decisions:

- **C001 auth** — Source uses file-based sessions → My design: database-backed with Redis cache
- **C002 context** — Source has hardcoded token limits → My design: configurable per-provider

This is where exploration becomes a bridge to building.

---

## /reverse-spec — Extract Knowledge from Existing Code

`/reverse-spec` is the automated version of code-explore's manual process. Instead of tracing flows one by one, it systematically extracts the **Global Evolution Layer** from an entire codebase.

**The 5-Phase Process:**

1. **Code Pattern Analysis** — file structure, dependencies, architecture
2. **Source Behavior Inventory** — every user-facing behavior, catalogued
3. **Entity & API Extraction** — data models, endpoints, contracts
4. **Roadmap Construction** — Features grouped by dependency order
5. **Constitution Seed** — project-level principles and constraints

**What it produces:** roadmap.md, entity-registry.md, api-registry.md, constitution-seed.md, and per-Feature pre-context.md files.

**When to use what:**

- `/code-explore` → You want to *understand* (human-guided, interactive)
- `/reverse-spec` → You want to *extract* (automated, comprehensive)

They're complementary. Use code-explore first if the codebase is unfamiliar. Use reverse-spec when you're ready for systematic extraction. They can chain: `/reverse-spec --from-explore` uses your trace insights to improve extraction quality.

---

## /smart-sdd — The Full Pipeline

This is the main event. Smart-sdd wraps spec-kit commands with three things spec-kit alone doesn't have:

1. **Cross-Feature memory** (GEL — registries, pre-context, stubs)
2. **Domain-aware behavior** (rules adapt to your Interface + Concern + Archetype)
3. **Pipeline integrity guards** (HARD STOPs that the agent cannot skip)

---

### The Pipeline

`init` → `add` → `pipeline` (per Feature)

Pipeline runs: **specify** (spec.md) → **plan** (plan.md) → **tasks** (tasks.md) → **implement** (source code) → **verify** (4-phase verification)

---

### init — Set Up the Project

```
/smart-sdd init "AI-powered knowledge base with multiple providers"
```

Creates `sdd-state.md` — the project's identity card with name, Domain Profile, language setting, and Feature progress tracking.

### add — Define Features Through Consultation

This is where smart-sdd shines. Instead of a one-liner, you go through a **6-step structured consultation:**

1. **Parse input** — understand what you're asking for
2. **Identify perspective gaps** — what's missing from your description
3. **Elaborate via probes** — domain-specific questions (different for `ai-assistant` vs `microservice`)
4. **Draft Brief** — structured summary of scope, actors, constraints
5. **Review HARD STOP** — you approve or modify the Brief
6. **Create artifacts** — pre-context, register in sdd-state.md

### pipeline — Build Feature by Feature

```
/smart-sdd pipeline F001
```

At each step transition: assemble context → execute → review HARD STOP → update state.

### The 4-Phase Verify

Verification isn't just "does it build?" It's four phases:

**Phase 1** — Build + TypeScript + Lint (CLI)

**Phase 2** — Automated tests, unit + integration (test runner)

**Phase 3** — UI/Runtime verification (Playwright)

**Phase 4** — Cross-Feature integration (Playwright + API probing)

If Playwright isn't available, the agent **delegates to the user** — it doesn't skip. This is the "Delegate, Don't Skip" principle.

### add --to — Augment Existing Features

```
/smart-sdd add --to F001 "add OAuth provider support"
```

New requirements get appended. Existing Success Criteria are **preserved** with `[preserved]` tags. New ones are added with `[new]` tags. This prevents the "rebuild from scratch" problem when adding to an existing Feature.

---

## How They Compose

**Standalone:**
- `code-explore .` → understand a codebase
- `smart-sdd init → add → pipeline` → build from scratch
- `reverse-spec .` → extract specs from code

**Chained:**
- `code-explore → init --from-explore` → understand then build
- `reverse-spec → init --from-reverse-spec` → extract then rebuild
- `adopt → code-explore` → document then deepen
- `pipeline → code-explore --no-branch` → investigate mid-build

The `--from-explore` and `--from-reverse-spec` flags carry context between skills — Domain Profile, entities, APIs, Feature candidates. Nothing is lost in the handoff.

---

## 🤖 For Agents — Skill Reference Card

```
code_explore:
  orient: detects language, framework, project_type, entry_points, concurrency_model
  trace: 5 strategies (sequential, connection_lifecycle, state_machine, pub_sub, concurrent_actors)
  synthesis: produces entity_map, api_map, observations, domain_profile, feature_candidates

reverse_spec:
  phases: code_patterns → source_behavior_inventory → entity_api_extraction → roadmap → constitution
  output: roadmap.md, entity-registry.md, api-registry.md, constitution-seed.md

smart_sdd:
  pipeline: specify → plan → tasks → implement → verify
  per_step: assemble context → checkpoint HARD STOP → execute → review HARD STOP → update state
  verify: phase_1 (build) → phase_2 (tests) → phase_3 (UI/Playwright) → phase_4 (integration)
  augmentation: add --to sets status to "augmented" → SC Preservation on next specify
  guards: G1 (constitution) through G7 (regression)
```

---

*Next: **Part 3 — Architecture Deep Dive** — how 400+ markdown files become a context-efficient, extensible skill system.*
