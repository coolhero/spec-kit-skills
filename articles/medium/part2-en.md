# Three Skills, One Pipeline: How code-explore, reverse-spec, and smart-sdd Work Together

## Part 2 of 4 — Each Skill in Detail

![Part 2 Cover](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part2.png)

*Continued from [Part 1: Why Your Agent Needs a Harness](https://medium.com/@thejihoonchoi/taming-the-ai-coder-why-your-agent-needs-a-harness-not-just-a-prompt-0869fa51da34)*

---

## /code-explore — Understand Before You Build

Most developers start AI projects by saying "build X." But the best projects start by saying "let me understand Y first."

This isn't a new idea. Every senior engineer does this — they spend time reading code, sketching diagrams, asking questions before writing a single line. But with AI agents, we skip this step. We jump straight to "build it" and hope the agent figures out the context.

`/code-explore` brings that "understand first" discipline back, but with a twist: everything the agent learns gets documented in persistent files that feed directly into the build pipeline.

---

## Orient: Your First 30 Minutes with a Codebase

```
/code-explore /path/to/project
```

When you run this, the agent performs a structured scan of the entire codebase. Not a cursory glance — a systematic analysis that produces `orientation.md`:

**What it detects:**

- **Language & framework** from project markers (package.json, go.mod, Cargo.toml, pyproject.toml, pom.xml, CMakeLists.txt)
- **Project type** — and this goes far beyond "web app or CLI." The agent recognizes TCP servers, UDP servers, gRPC services, message consumers, API gateways, WebSocket servers, TUI applications, embedded firmware, and more
- **Entry points** — not just `main.go` or `index.ts`, but server-specific patterns like accept loops, listener bindings, event handlers, `@KafkaListener` annotations, `.proto` service definitions, and even RTOS task creation for embedded systems
- **Concurrency model** — this is critical for server programs. The agent identifies whether the codebase uses async/await (tokio, asyncio), goroutines, thread pools, actor models (GenServer, Akka), or event loops (Node.js, libuv). Understanding concurrency shapes how every subsequent trace should be read
- **Module map** with file counts, import relationships, and inferred purposes
- **Domain Profile** across all 5 axes — the same vocabulary used by the build pipeline later

**What it looks like in practice:**

Imagine you're exploring an open-source AI coding assistant. Orient produces something like this:

```
📦 Project: opencode (Go / Bubble Tea TUI)
   Type: Desktop TUI application
   Entry: cmd/main.go → internal/app/app.go
   Size: 847 files, 42 directories
   Concurrency: goroutines (event-driven TUI + background tasks)

Detected Domain Profile:
  Interface: gui (TUI), cli
  Concern: async-state, ipc, external-sdk, realtime
  Archetype: ai-assistant
  Foundation: Go stdlib + Bubble Tea
  Scale: production, small-team
```

The agent then suggests 5-10 exploration topics, ordered by importance: entry points first, core business logic second, infrastructure third.

**Why this matters:** Without orient, every trace starts from scratch — the agent greps blindly for keywords. With orient, the agent knows the module map, knows the concurrency model, knows where to look. Traces become 3-5x faster and more accurate.

---

## Trace: Following the Thread

```
/code-explore trace "how does context window management work"
```

This is where code-explore becomes powerful. The agent doesn't just search for a keyword — it follows the complete execution path from entry point to completion, documenting everything along the way.

### How a trace actually works

1. **Entry point discovery** — The agent uses the Domain Profile to prioritize search. For an `ai-assistant` archetype, it knows to look for token counting, context assembly, and message truncation. For a `gui` interface, it prioritizes component files and state management. It presents candidate entry points and asks you to confirm.

2. **Depth-first traversal** — From the entry point, the agent reads each function, follows calls to other functions, tracks how data transforms at each step, notes where the flow branches (error paths, conditions), and stops at framework boundaries.

3. **Structured output** — Every trace produces a document with:
   - A **summary** (2-3 sentences explaining what this flow does and why it matters)
   - A **Mermaid sequence diagram** showing component interactions
   - A **flow table** mapping each step to source file:line, action, and data transformations
   - **Key source snippets** — the actual code that matters, with inline comments
   - **Entities discovered** (data structures with fields and relationships)
   - **APIs discovered** (endpoints with contracts)
   - **Business rules** (domain logic with source evidence)
   - **Observations** tagged with icons: 💡 patterns to adopt, ❓ open questions, ⚠️ concerns, 🔧 improvement ideas, 🔒 security considerations, 🧪 test gaps, 📊 performance concerns

### Five strategies for five kinds of flows

Here's what makes trace genuinely useful for diverse codebases. Not all code flows linearly from request to response. The agent selects the appropriate strategy:

**Strategy 1 — Sequential flow.** The classic request → handler → service → repository → response. Works for REST APIs, CLI commands, simple function chains. Produces a standard sequence diagram.

**Strategy 2 — Connection Lifecycle.** For TCP servers, WebSocket servers, gRPC services. Traces the full lifecycle: `accept` → `handshake/upgrade` → `read request` → `parse protocol` → `dispatch` → `handle` → `write response` → `close/disconnect`. The key difference: it includes the protocol framing layer (how raw bytes become messages) and shows the connection as a long-lived participant in the diagram.

Why this matters: If you ask "how does a Redis command get executed" and the trace starts at `parseCommand()`, you're missing half the story. The connection lifecycle strategy starts at `accept()` and traces through the RESP protocol parsing — because for a network server, the protocol IS the business logic.

**Strategy 3 — State Machine.** For presence systems, connection state management, reconciler loops, workflow engines. Instead of a sequence diagram, it produces a **state diagram**:

```
[*] → Connected (accept)
Connected → Authenticated (auth success)
Connected → Disconnected (auth fail / timeout)
Authenticated → Subscribed (subscribe to topic)
Subscribed → Disconnected (close / heartbeat timeout)
```

Each transition maps to source code locations. This is dramatically more useful than a linear trace for state-driven logic. A WebSocket presence system with online/offline/away states is a state machine, not a sequence — tracing it linearly would be misleading.

**Strategy 4 — Pub/Sub Fan-out.** For message brokers, event systems, broadcast patterns. Traces BOTH sides: the publish path AND the consume/delivery path, with the fan-out visualized. You see how a message enters the broker, gets persisted, and is delivered to N consumers with acknowledgment handling.

**Strategy 5 — Concurrent Actors.** For systems with multiple goroutines, tasks, or threads running in parallel. Each step is annotated with which actor it runs on. The diagram shows parallel participants with clear handoff points:

```
AcceptLoop → spawns ConnHandler per connection
ConnHandler → borrows from PoolManager
PoolManager → returns pooled connection
ConnHandler → reads/writes independently
```

### Protocol boundary guidance

This is a subtle but crucial enhancement. Traditional traces stop at "external API call" or "database operation" — that's the boundary. But for network programs, **the network IS the core concern**. Stopping at `socket.write()` is like stopping at `repository.save()` in a web app — the user wants to see what happens next.

For server programs, traces don't stop at the socket boundary. They document what bytes/messages are sent, what's expected back, and how errors are handled at the protocol level. Cross-service calls are documented as `[cross-service: ServiceName.Method()]` with request/response contracts.

For proxies and gateways, configuration files (routing rules, upstream definitions) are read and documented as part of the trace — because the config IS the logic.

---

## Synthesis: From Understanding to Action

```
/code-explore synthesis
```

After 3-5 traces, you've built up substantial knowledge. Synthesis aggregates it into an actionable handoff document.

### What synthesis actually produces

**Consolidated Entity Map** — All entities discovered across traces, with fields merged (union), type conflicts flagged, and a Mermaid ER diagram showing relationships. If trace 1 discovered `User { id, name, email }` and trace 3 discovered `User { id, role, avatar }`, synthesis produces `User { id, name, email, role, avatar }` with source trace references.

**Consolidated API Map** — All endpoints discovered, with a dependency graph showing which APIs call which other APIs. For multi-service architectures, this becomes especially valuable.

**Server Component Map** (for server/network projects) — A layer-based architectural view:

- **Listener** — TCP accept loop on :8080 (`cmd/server.go`)
- **Protocol** — Redis RESP parser (`protocol/resp.go`)
- **Middleware** — Auth → Rate limiter → Logger (`middleware/`)
- **Handler** — GET, SET, DEL commands (`handler/`)
- **Storage** — In-memory store + AOF persistence (`storage/`)
- **Background** — Key expiration goroutine, AOF compaction (`background/`)

This layer view is something no other tool produces — it maps the server's architecture in a way that directly translates to Feature boundaries.

**Network Topology** (for multi-service systems) — A Mermaid diagram showing how services communicate: which protocols, which directions, which dependencies.

**Accumulated Insights** — Categorized by icon type. All the 💡 patterns, 🔧 improvements, ❓ questions, and ⚠️ risks from every trace, with source references. This is where you see the big picture emerge from individual observations.

**Recommended Domain Profile** — Based on the source project's profile plus your differentiation decisions (🔧 observations). If you noted "change from TUI to Web" in trace 4, synthesis captures that as an Interface axis change for your target project.

**Feature Candidates** — Grouped by module clustering, entity ownership, and API mapping. Each candidate (C001, C002...) lists the modules, entities, APIs, and traces it's based on. These feed directly into `/smart-sdd add --from-explore`.

### The "What I'd Do Differently" pattern

This is synthesis's most valuable section for rebuild projects. Every trace generates improvement observations (🔧). Synthesis collects them into an explicit decision table:

- C001 auth — Source: file-based sessions → My design: database-backed with Redis cache
- C002 context — Source: hardcoded 128k token limit → My design: configurable per-provider
- C003 tools — Source: synchronous tool execution → My design: async with timeout + cancel

These decisions carry forward into the build pipeline. When smart-sdd's `speckit-specify` runs, it sees these decisions and generates SCs that reflect your design choices, not the source's.

---

## /reverse-spec — Automated Knowledge Extraction

If code-explore is a senior engineer carefully reading code, reverse-spec is an entire team doing a comprehensive audit. It systematically extracts the **Global Evolution Layer** from a codebase in 5 phases.

### Phase 1: Code Pattern Analysis

Scans the entire file structure, analyzes dependency graphs, identifies architectural patterns. Produces a structural map of the codebase — which modules exist, how they relate, what frameworks and libraries are used.

### Phase 2: Source Behavior Inventory (SBI)

This is the phase that makes reverse-spec unique. The agent catalogs every user-facing behavior in the codebase. Not just "the auth module exists" but:

- B001: User can log in with email and password
- B002: Failed login shows inline error message after 1 second
- B003: 3 failed attempts triggers 15-minute lockout
- B004: Session token stored in httpOnly cookie, expires in 24h

Each behavior entry maps to source code locations and gets a behavior ID (B###) that later maps to Feature Requirements (FR-###) in the SDD pipeline.

For rebuild projects, this is critical: it ensures you don't lose functionality when rebuilding. If the source has 47 behaviors, the rebuild should cover all 47 — or explicitly document which ones are intentionally dropped.

### Phase 3: Entity & API Extraction

Produces `entity-registry.md` and `api-registry.md` — the same formats that smart-sdd's pipeline uses. Entities include fields, types, relationships, and validation rules. APIs include methods, paths, request/response schemas, auth requirements, and error responses.

### Phase 4: Roadmap Construction

Groups behaviors into Features, orders Features by dependency, and produces `roadmap.md`. The ordering is important — Feature 2 depends on Feature 1's User entity, so Feature 1 must be built first. The agent doesn't guess this; it analyzes actual import dependencies and data flow.

### Phase 5: Constitution Seed

Extracts project-level architectural principles from the codebase patterns. If the source consistently uses a provider abstraction pattern, the constitution notes "Provider Agnosticism" as a guiding principle. These principles seed the `constitution.md` file that governs the entire rebuild.

### When to use code-explore vs reverse-spec

- **code-explore**: You're unfamiliar with the codebase and want to build intuition. Interactive, human-guided, selective. You choose what to trace.
- **reverse-spec**: You know the codebase well enough (or code-explore gave you the overview) and want comprehensive extraction. Automated, systematic, exhaustive. It catalogs everything.

They chain beautifully: `/code-explore` first to understand, then `/reverse-spec --from-explore` to extract with the benefit of your human insights.

---

## /smart-sdd — Where Understanding Becomes Code

This is the main event — the full Specification-Driven Development pipeline with cross-Feature memory.

### The Problem smart-sdd Solves

spec-kit by itself is powerful: you give it a spec, it generates a plan, tasks, and code. But spec-kit processes one Feature at a time with no memory of other Features. Feature 3 doesn't know Feature 1 created a User entity. Feature 5 doesn't know Feature 2 defined the API response format.

smart-sdd wraps spec-kit with:
1. **Global Evolution Layer** — registries, pre-context, stubs that carry information across Features
2. **Domain Profile** — rules that adapt to your project type
3. **Pipeline Integrity Guards** — 7 guards (G1-G7) that block progression when something is wrong

### init: Project Identity

```
/smart-sdd init "AI-powered knowledge base with provider abstraction"
```

Creates `sdd-state.md` — the project's identity card. This file tracks:
- Project name and description
- Domain Profile (auto-detected or manually set via `--profile`)
- Artifact Language (en/ko/ja via `--lang`)
- Active Tiers (which Features are in scope)
- Feature Progress table (which step each Feature is at)

Everything downstream reads this file. It's the single source of truth for project state.

### add: The 6-Step Consultation

This is where most of the value lives. Instead of "add auth," you go through a structured consultation that turns vague ideas into precise Feature definitions.

**Step 1 — Parse input.** The agent understands what you're asking for. You can provide text ("multi-provider LLM chat with streaming"), files (a requirements doc, a design spec), or both mixed together.

**Step 2 — Identify perspective gaps.** The agent analyzes your input against a checklist: Do you have actors defined? Error paths? Data model? Dependencies on other Features? Interaction patterns? Each gap becomes a question.

**Step 3 — Elaborate via domain-specific probes.** This is where the Domain Profile activates. If your project is an `ai-assistant`, the probes include: "How should streaming interruption work?" "What happens when the provider rate-limits?" "Should context window management be per-conversation or global?" If it's a `microservice`, completely different probes: "What's the service boundary?" "How does it handle upstream failures?" "What's the retry policy?"

The probe questions come from domain modules — they're not generic. They encode real expertise about what matters for each project type.

**Step 4 — Draft Brief.** The agent assembles your answers into a structured Brief: scope (in/out), actors with permissions, entity definitions, interaction patterns with temporal flows (loading → streaming → completion → error → retry), error scenarios, cross-Feature dependencies, and non-functional requirements.

**Step 5 — Review HARD STOP.** The agent presents the Brief and waits for your explicit approval. You can modify, add, remove. This is a blocking gate — the pipeline literally cannot proceed without your response.

**Step 6 — Create artifacts.** Pre-context is generated, the Feature is registered in sdd-state.md, entities and APIs are registered in the Global Evolution Layer.

### pipeline: Building Feature by Feature

```
/smart-sdd pipeline F001
```

This runs the full pipeline for one Feature: **specify → plan → tasks → implement → verify.**

At each step, a 4-phase protocol executes:

1. **Assemble** — Load the Domain Profile modules, GEL artifacts, pre-context. This is where cross-Feature memory kicks in. If F001 created a User entity, F002's specify step sees it in the entity registry and generates SCs that reference the existing entity.

2. **Checkpoint (HARD STOP)** — Show the assembled context. Wait for approval.

3. **Execute** — Run the spec-kit command with the injected context. The injection file orchestrates which domain rules apply — different rules for `gui` vs `cli` vs `grpc`, different depths for `mvp` vs `production` scale.

4. **Review (HARD STOP)** — Read the generated artifact, display a formatted review, wait for approval. The agent cannot proceed without your explicit "approve" or "modify."

5. **Update** — Register new entities/APIs in the GEL, update sdd-state.md.

### The 4-Phase Verify

Verification is not "does it build?" That was Gap Pattern G1 — the very first failure pattern we discovered. Build passes mean nothing about whether the feature actually works.

**Phase 1 — Build + TypeScript + Lint.** The baseline. If this fails, nothing else runs.

**Phase 2 — Automated tests.** Unit tests plus integration tests. If tests fail, the agent fixes them before proceeding — not by deleting the tests, but by fixing the code.

**Phase 3 — UI/Runtime verification.** This is where spec-kit-skills diverges from every other tool. The agent launches the actual application using Playwright (or Electron-specific protocols for desktop apps) and verifies each Success Criterion against the running UI. Not "does the login component render?" but "can I actually type a password, click submit, see the dashboard, and see the correct user name?"

If Playwright isn't available, the agent **delegates to the user**: "Please click the login button. Does the dashboard appear with your username?" It never skips. This is the "Delegate, Don't Skip" principle born from Gap Pattern G6.

**Phase 4 — Cross-Feature integration.** Verify that Features work together. Feature 2's settings page actually changes Feature 1's behavior. The API gateway correctly routes to both Feature 3 and Feature 4's endpoints. This catches Gap Pattern G7 — cross-Feature integration contract failures.

### add --to: Augmenting Without Destroying

```
/smart-sdd add --to F001 "add OAuth provider support"
```

This was one of our hardest problems. When you add requirements to an existing Feature, the naive approach is to re-specify from scratch. But that loses all previously approved Success Criteria.

The `add --to` flow solves this with SC Preservation:
- New requirements are appended to the pre-context under `## Augmented Requirements`
- Feature status is set to `augmented` in sdd-state.md
- When `speckit-specify` runs next, it detects the `augmented` status and activates SC Preservation
- Existing SCs get `[preserved]` tags — they cannot be removed or modified
- New SCs get `[new]` tags — only these are generated fresh
- If a new requirement explicitly contradicts an existing SC, it gets `[updated]` with an explanation
- A post-execution check verifies: SC count didn't decrease, preserved SCs match originals, every augmented requirement has at least one new SC

---

## How They Compose

The three skills are designed to work independently or together. Here are the composition patterns:

**Greenfield** (new project from scratch):
```
/smart-sdd init → add → pipeline
```

**Exploration → Build** (understand existing code, then build something inspired by it):
```
/code-explore /path/to/reference-project
/code-explore trace "auth flow"
/code-explore trace "data pipeline"
/code-explore synthesis
/smart-sdd init --from-explore
/smart-sdd add --from-explore    # Feature candidates become Briefs
/smart-sdd pipeline F001
```

**Rebuild** (rewrite an existing app from scratch):
```
/reverse-spec /path/to/legacy-app
/smart-sdd init --from-reverse-spec
/smart-sdd pipeline              # builds all Features in dependency order
```

**Adoption** (add SDD docs to existing code without rewriting):
```
/smart-sdd adopt /path/to/existing-app
```

**Mid-pipeline investigation** (something's wrong, need to understand the source better):
```
/smart-sdd pipeline F003         # stuck on implementation
/code-explore . --no-branch      # explore without disturbing the pipeline
/code-explore trace "how does the original handle this edge case"
# continue pipeline with new understanding
```

The `--from-explore` and `--from-reverse-spec` flags carry context seamlessly — Domain Profile, entities, APIs, Feature candidates. The handoff is lossless.

---

## 🤖 For Agents — Skill Reference Card

```
code_explore:
  orient:
    detects: language, framework, project_type, entry_points, concurrency_model, domain_profile
    interface_types: gui, http-api, grpc, cli, tui, embedded, mobile, library, data-io, message-consumer
    output: specs/explore/orientation.md

  trace:
    strategies:
      sequential: request → response (REST, CLI)
      connection_lifecycle: accept → handshake → request → response → close (TCP, WS, gRPC)
      state_machine: states + transitions mapped to source (presence, reconcilers)
      pub_sub_fanout: publish path + consume path + fan-out (brokers, events)
      concurrent_actors: per-goroutine/task annotation (parallel systems)
    output: specs/explore/traces/{NNN}-{slug}.md
    must_include: mermaid_diagram, flow_table, entities, apis, business_rules, observations

  synthesis:
    produces: entity_map, api_map, server_component_map (conditional), network_topology,
              observations, domain_profile, feature_candidates
    output: specs/explore/synthesis.md

reverse_spec:
  phases:
    1_code_patterns: file structure, dependencies, architecture
    2_source_behavior_inventory: every user-facing behavior catalogued as B### entries
    3_entity_api_extraction: entity-registry.md, api-registry.md
    4_roadmap: Features ordered by dependency
    5_constitution_seed: project-level principles
  output: specs/reverse-spec/

smart_sdd:
  add_consultation:
    steps: parse_input → identify_gaps → elaborate_probes → draft_brief → review_HARD_STOP → create_artifacts
    probes: domain-specific (ai-assistant probes ≠ microservice probes)

  pipeline_steps: specify → plan → tasks → implement → verify
  per_step_protocol: assemble → checkpoint_HARD_STOP → execute → review_HARD_STOP → update

  verify_phases:
    phase_1: build + typecheck + lint
    phase_2: automated tests (unit + integration)
    phase_3: UI/runtime (Playwright) — delegate to user if unavailable, never skip
    phase_4: cross-Feature integration

  augmentation:
    command: add --to F00N "new requirements"
    sets_status: augmented
    triggers: SC Preservation (preserved/new/updated tags)
    post_check: SC count >= previous, preserved SCs unchanged, new SCs cover augmented reqs

  guards: G1_constitution, G2_entity_registry, G3_api_registry, G4_pre_context,
          G5_dependency_order, G6_augmentation, G7_regression
```

---

*Next: **Part 3 — Architecture Deep Dive** — how 400+ markdown files become a context-efficient, extensible skill system. We'll look at why "enforce, don't reference" is the most counterintuitive lesson, and how domain modules make the same pipeline produce different results for different project types.*
