# Three Skills, One Pipeline: How code-explore, reverse-spec, and smart-sdd Work Together

## Part 2 of 4 — Each Skill in Detail

*Continued from Part 1: Why Your Agent Needs a Harness — (link to Part 1 on Medium)*

---

## /code-explore — Understand Before You Build

Most developers start AI projects by saying "build X." But the best projects start by saying "let me understand Y first."

`/code-explore` is built on this premise. It's an interactive exploration tool that produces **documented understanding** — not code, not specs, just structured knowledge about a codebase.

### How It Works

**Step 1: Orient** — Scan the codebase

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

**Step 2: Trace** — Follow specific flows

```
/code-explore trace "how does the auth middleware validate tokens"
```

The agent traces the flow from entry point to completion:
- Finds the entry point (keyword search + import analysis)
- Follows call chains depth-first
- Records: source locations, data transformations, branching, API calls
- Generates a Mermaid sequence diagram
- Notes entities, APIs, and business rules discovered along the way

Each trace produces a standalone document in `specs/explore/traces/`.

#### Five Trace Strategies

Not all flows are linear. The agent picks the right strategy based on what it's tracing:

| Strategy | When to Use | Diagram Type |
|----------|-------------|-------------|
| **Sequential** | Request → response (REST handler) | sequenceDiagram |
| **Connection Lifecycle** | TCP accept → handle → close (servers) | sequenceDiagram with long-lived participants |
| **State Machine** | Online/offline/away (presence systems) | stateDiagram-v2 |
| **Pub/Sub Fan-out** | Publish → broker → N consumers | sequenceDiagram with fan-out |
| **Concurrent Actors** | Multiple goroutines/tasks running in parallel | sequenceDiagram with thread annotations |

This matters because a WebSocket presence system isn't a "flow" — it's a state machine. Tracing it as a sequence diagram would be misleading.

**Step 3: Synthesis** — Consolidate into Feature candidates

```
/code-explore synthesis
```

After 3-5 traces, synthesis aggregates everything:
- Consolidated entity map (merged across traces)
- Consolidated API map with dependency graph
- Categorized observations (patterns to adopt, risks, open questions)
- Recommended Domain Profile for your project
- Feature candidates (C001, C002...) ready to feed into smart-sdd

### The "What I'd Do Differently" Pattern

Every trace naturally generates "I'd do this differently" observations (marked with 🔧). During synthesis, these become explicit design decisions:

```markdown
| Candidate | Pattern from Source | My Design |
|-----------|-------------------|-----------|
| C001 auth | File-based sessions | Database-backed with Redis cache |
| C002 context | Hardcoded token limits | Configurable per-provider |
```

This is where exploration becomes a bridge to building.

---

## /reverse-spec — Extract Knowledge from Existing Code

`/reverse-spec` is the automated version of code-explore's manual process. Instead of tracing flows one by one, it systematically extracts the **Global Evolution Layer** from an entire codebase.

### The 5-Phase Process

```
Phase 1: Code Pattern Analysis    → file structure, dependencies, architecture
Phase 2: Source Behavior Inventory → every user-facing behavior, catalogued
Phase 3: Entity & API Extraction  → data models, endpoints, contracts
Phase 4: Roadmap Construction     → Features grouped by dependency order
Phase 5: Constitution Seed        → project-level principles and constraints
```

### What It Produces

| Artifact | Purpose |
|----------|---------|
| `roadmap.md` | Feature dependency graph with recommended build order |
| `entity-registry.md` | All data models with fields, relationships, validation rules |
| `api-registry.md` | All endpoints with contracts, auth requirements, error responses |
| `constitution-seed.md` | Project-level constraints (naming, architecture, patterns) |
| `pre-context.md` (per Feature) | Detailed requirements extracted from source code |

### When to Use What

```
/code-explore    → You want to understand (human-guided, interactive)
/reverse-spec    → You want to extract (automated, comprehensive)
```

They're complementary. Use code-explore first if the codebase is unfamiliar and you want to build intuition. Use reverse-spec when you're ready for systematic extraction.

They can even chain: `/reverse-spec --from-explore` uses your trace insights to improve extraction quality.

---

## /smart-sdd — The Full Pipeline

This is the main event. Smart-sdd wraps [spec-kit](https://github.com/github/spec-kit) commands with three things spec-kit alone doesn't have:

1. **Cross-Feature memory** (GEL — registries, pre-context, stubs)
2. **Domain-aware behavior** (rules adapt to your Interface + Concern + Archetype)
3. **Pipeline integrity guards** (HARD STOPs that the agent cannot skip)

### The Pipeline

```
init → add → pipeline (per Feature)
                 │
                 ├── specify  → spec.md (what to build)
                 ├── plan     → plan.md (how to build it)
                 ├── tasks    → tasks.md (step-by-step implementation)
                 ├── implement → source code (with per-task runtime verification)
                 └── verify   → 4-phase verification (build, test, UI, integration)
```

### init — Set Up the Project

```
/smart-sdd init "AI-powered knowledge base with multiple providers"
```

Creates `sdd-state.md` (the project's identity card):
- Project name and description
- Domain Profile (auto-detected or manually set)
- Artifact Language (en/ko/ja)
- Feature Progress tracking table

### add — Define Features Through Consultation

This is where smart-sdd shines. Instead of a one-liner, you go through a **6-step structured consultation**:

```
/smart-sdd add "multi-provider LLM chat with streaming responses"
```

The agent walks you through:

1. **Parse input** — understand what you're asking for
2. **Identify perspective gaps** — what's missing from your description
3. **Elaborate via probes** — domain-specific questions (different for `ai-assistant` vs `microservice`)
4. **Draft Brief** — structured summary of scope, actors, constraints
5. **Review HARD STOP** — you approve or modify the Brief
6. **Create artifacts** — pre-context, register in sdd-state.md

The Brief format ensures every Feature has:
- Clear scope boundary (what's IN, what's OUT)
- Identified actors and their permissions
- Known entity relationships
- Error scenarios (not just happy path)
- Dependencies on other Features

### pipeline — Build Feature by Feature

```
/smart-sdd pipeline F001
```

Runs through specify → plan → tasks → implement → verify. At each transition:

1. **Assemble context** — load Domain Profile modules, GEL artifacts, pre-context
2. **Execute step** — run speckit-* command with injected context
3. **Review HARD STOP** — show results, wait for your approval
4. **Update state** — register new entities/APIs, update sdd-state.md

#### The 4-Phase Verify

Verification isn't just "does it build?" It's:

| Phase | What It Checks | Tool |
|-------|---------------|------|
| **Phase 1** | Build + TypeScript + Lint | CLI |
| **Phase 2** | Automated tests (unit + integration) | Test runner |
| **Phase 3** | UI/Runtime verification | Playwright |
| **Phase 4** | Cross-Feature integration | Playwright + API probing |

If Playwright isn't available, the agent **delegates to the user** — it doesn't skip. This is the "Delegate, Don't Skip" principle.

### adopt — Add SDD to Existing Code

```
/smart-sdd adopt /path/to/existing-app
```

For teams that want SDD documentation without rewriting:
1. Reverse-spec extracts the knowledge
2. Smart-sdd creates spec.md, plan.md for each Feature
3. Existing code is preserved — documentation wraps around it

### add --to — Augment Existing Features

```
/smart-sdd add --to F001 "add OAuth provider support"
```

New requirements get appended to F001's pre-context. Existing SCs (Success Criteria) are **preserved** — new ones are added with `[new]` tags. This prevents the "rebuild from scratch" problem when adding to an existing Feature.

---

## How They Compose

```
Standalone:
  /code-explore .                          → understand a codebase
  /smart-sdd init → add → pipeline        → build from scratch
  /reverse-spec .                          → extract specs from code

Chained:
  /code-explore → init --from-explore      → understand then build
  /reverse-spec → init --from-reverse-spec → extract then rebuild
  adopt → code-explore                     → document then deepen
  pipeline → code-explore --no-branch      → investigate mid-build
```

The `--from-explore` and `--from-reverse-spec` flags carry context between skills — Domain Profile, entities, APIs, Feature candidates. Nothing is lost in the handoff.

---

## 🤖 For Agents — Skill Reference Card

```yaml
code_explore:
  commands:
    orient:
      input: target directory path
      output: specs/explore/orientation.md
      detects: [language, framework, project_type, entry_points, concurrency_model, domain_profile]
      interface_types: [gui, http-api, grpc, cli, tui, embedded, mobile, library, data-io, message-consumer]
    trace:
      input: topic string (natural language question about the code)
      output: specs/explore/traces/{NNN}-{slug}.md
      strategies: [sequential, connection_lifecycle, state_machine, pub_sub_fanout, concurrent_actors, error_retry_path]
      must_include: [mermaid_diagram, flow_table, entities, apis, observations]
    synthesis:
      input: all traces in specs/explore/traces/
      output: specs/explore/synthesis.md
      produces: [entity_map, api_map, observations, domain_profile, feature_candidates]
      conditional: server_component_map (when network-server archetype detected)

reverse_spec:
  phases: [code_patterns, source_behavior_inventory, entity_api_extraction, roadmap, constitution]
  output_path: specs/reverse-spec/
  artifacts: [roadmap.md, entity-registry.md, api-registry.md, constitution-seed.md, pre-context.md]

smart_sdd:
  pipeline_steps: [specify, plan, tasks, implement, verify]
  per_step_protocol:
    1_assemble: load domain modules + GEL artifacts + pre-context
    2_checkpoint: HARD STOP — show assembled context for review
    3_execute: run speckit-* command with injected context
    4_review: HARD STOP — show results, wait for approval
    5_update: register new entities/APIs, update sdd-state.md

  verify_phases:
    phase_1: build + typecheck + lint
    phase_2: automated tests
    phase_3: UI/runtime verification (Playwright)
    phase_4: cross-feature integration

  feature_augmentation:
    command: add --to F00N
    sets_status: augmented
    triggers: SC Preservation on next speckit-specify
    tags: [preserved] for existing SCs, [new] for added SCs

  guards: [G1_constitution, G2_entity_registry, G3_api_registry, G4_pre_context, G5_dependency_order, G6_augmentation, G7_regression]
```

---

*Next: **Part 3 — Architecture Deep Dive** — how 400+ markdown files become a context-efficient, extensible skill system.*
