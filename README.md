# spec-kit-skills

**Repository**: [coolhero/spec-kit-skills](https://github.com/coolhero/spec-kit-skills)

[한국어 README](README.ko.md) | [Playwright Setup Guide](PLAYWRIGHT-GUIDE.md) | [Lessons Learned](lessons-learned.md) | Last updated: 2026-03-20 08:01 KST

**Three concepts that turn AI coding agents into reliable software engineers: [Global Evolution Layer](#global-evolution-layer) for cross-Feature memory, [Domain Profile](#domain-profile) for project-type expertise, and [Brief](#brief) for structured Feature intake — built on [spec-kit](https://github.com/github/spec-kit) SDD**

- **Code-Explore** helps you understand an existing codebase through interactive, source-level exploration. Scan a project to get an architecture map, then trace specific flows end-to-end — each session produces documented traces with call chains, entity maps, and flow diagrams. When you've understood enough, synthesize your traces into Feature candidates that feed directly into the SDD pipeline. *(Under development)*
- **Reverse-Spec** analyzes an existing codebase and reverse-engineers the spec — from source code all the way to draft spec.md per Feature. It runs the source app to capture real UI flows (form fields, dropdowns, auto-fill, error paths), then converts those observations into detailed requirements. The pipeline receives specs that already describe exact interaction patterns, not vague one-liners that the agent has to guess. Use it when you want to rebuild an existing app from scratch, or when you want to add SDD documentation to code you already have.
- **Smart-SDD** wraps each spec-kit command with project-wide awareness. When you run `/speckit-plan` for Feature 3, it automatically feeds in Feature 1's data models and Feature 2's API contracts — so the plan is grounded in what actually exists, not assumptions.

---

## Table of Contents

- [Quick Start](#quick-start)
- [What It Solves](#what-it-solves)
- [Skills](#skills)
- [User Journeys](#user-journeys)
- [Quick Examples](#quick-examples)
- [Architecture](#architecture)
- [Domain Module System](#domain-module-system)
- [Extensibility & Customization](#extensibility--customization)
- [Session Resilience & Agent Governance](#session-resilience--agent-governance)
- [Detailed Reference](#detailed-reference)
- [/reverse-spec — Detailed Workflow](#reverse-spec--detailed-workflow)
- [Using spec-kit without smart-sdd](#using-spec-kit-without-smart-sdd)
- [/smart-sdd — Detailed Workflow](#smart-sdd--detailed-workflow)
- [Reference](#reference)
- [File Map](#file-map)

---

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI — the AI coding agent that runs these skills
- [spec-kit](https://github.com/github/spec-kit) skill — the SDD pipeline engine (required for `/smart-sdd`, not needed for `/reverse-spec` alone)
- [Playwright](https://playwright.dev) — for runtime verification during `verify` step. Install: `npm install -D @playwright/test && npx playwright install`. Optional: [Playwright MCP](https://github.com/microsoft/playwright-mcp) for interactive acceleration — see [Playwright Setup Guide](PLAYWRIGHT-GUIDE.md)

### Installation

```bash
git clone https://github.com/coolhero/spec-kit-skills.git
cd spec-kit-skills
./install.sh      # creates symlinks → ~/.claude/skills/
# ./uninstall.sh  # removes symlinks (to uninstall)
```

The installer creates symlinks from `~/.claude/skills/` to this repository.

### Which Command Should I Use?

```
Have existing code?
  No  → /smart-sdd init → add → pipeline
  Yes → What's your goal?
         Understand first  → /code-explore ./source → (then choose below)
         Rebuild           → /reverse-spec ./source → /smart-sdd pipeline
         Document (keep)   → /reverse-spec --adopt  → /smart-sdd adopt
         Add new features  → /smart-sdd add         → /smart-sdd pipeline
```

### Verify Installation

```bash
# In Claude Code, type:
/reverse-spec --help     # Should show command help
/smart-sdd status        # Should show status or ask to initialize
```

---

## What It Solves

### Background: Spec-Driven Development

In spec-driven development, you don't ask an AI agent to "build a TO-DO app." You break the app into **Features** (a self-contained unit of functionality that is independently specifiable, implementable, and verifiable — e.g., authentication, task CRUD, dashboard UI). Each Feature gets exactly one **spec** that defines *what* it does (functional requirements, success criteria, data models) before the agent writes any code. The agent then implements that spec through a structured pipeline: specify → plan → tasks → analyze → implement → verify.

This is the approach that [spec-kit](https://github.com/github/spec-kit) provides. One Feature, one spec, one pipeline run — and it works well.

### The Problem: Specs Don't Talk to Each Other

The challenge is that **real software is never just one Feature.** Even a simple TO-DO app has auth, task management, and a UI — three Features, three specs, three separate pipeline runs. And each spec is written independently.

The agent building Feature 2 *might* figure out what Feature 1 decided — but that depends on the agent's capability and context window, not on any systematic guarantee. It may define the same `User` entity with different field names, or design APIs without knowing the auth pattern already chosen. Even within a single spec, the agent may lack sufficient understanding of the user's environment — the same "add authentication" means very different things for a multi-tenant SaaS platform versus an internal admin tool. And when the user's description is vague, like "add profile management," the agent may just accept it without asking what it actually means.

Each spec is internally solid, but these gaps — no memory across Features, insufficient understanding of the project's context, and no verification of user intent — are not things a single-spec workflow can address. spec-kit-skills adds three concepts to close them:

#### Global Evolution Layer

**The gap**: Each agent manages context its own way, and none track cross-Feature relationships systematically.

**The solution**: A set of project-wide artifacts that sit above spec-kit's per-Feature scope — so every Feature is built with full knowledge of the whole project, regardless of which agent or session is running.

| Artifact | What it tracks |
|----------|---------------|
| **Roadmap** | Feature dependency graph with execution ordering |
| **Entity Registry** | Shared data models referenced across Features |
| **API Registry** | Inter-Feature API contracts and endpoints |
| **Per-Feature Pre-contexts** | What each Feature needs to know about the rest of the project |
| **Source Behavior Inventory** | Function-level coverage tracking (for existing codebases) |
| **Constitution** | Project-wide principles and architectural decisions |

These artifacts live in your project directory:

```
my-project/
├── specs/
│   ├── _global/                   ← GEL (project-wide)
│   │   ├── roadmap.md             ← Feature dependency graph
│   │   ├── entity-registry.md     ← Shared data models
│   │   ├── api-registry.md        ← Inter-Feature API contracts
│   │   └── sdd-state.md           ← Pipeline state + Domain Profile
│   ├── 001-auth/                  ← ALL Feature artifacts in one place
│   │   ├── pre-context.md         ← What F001 needs to know (from reverse-spec)
│   │   ├── spec-draft.md          ← Initial spec (from reverse-spec)
│   │   ├── spec.md                ← Final spec (from speckit-specify)
│   │   ├── plan.md                ← Architecture (from speckit-plan)
│   │   └── tasks.md               ← Implementation tasks
│   └── 002-task-crud/
│       └── ...
└── .specify/
    └── memory/
        └── constitution.md        ← Project-wide principles
```

Before each pipeline step, the relevant artifacts are automatically injected into the agent's context. When a step completes, the artifacts are updated with automatic consistency verification — entity registries and API registries are cross-checked against actual implementations to catch drift. Dependency stubs from preceding Features are tracked and enforced as blocking gates before implementation begins. The agent doesn't need to remember — the artifacts remember for it, and the gates ensure what's recorded matches what's built.

**Artifact Separation**: Source analysis lives exclusively in `specs/_global/` (pre-context, registries, spec-drafts). Pipeline output lives in `specs/NNN-feature/` (spec.md, plan.md, tasks.md). The pipeline artifacts contain **requirements only** — no source code references. When you read `spec.md`, you see "what we're building," not "where it came from." This separation means specs are reusable across different source projects, and source analysis has a single source of truth.

#### Domain Profile

**The gap**: Agents apply the same generic approach regardless of project type. Every project and every organization has its own conventions, constraints, and quality criteria that agents don't know about.

**The solution**: A composable rule system that detects your project type and loads only the relevant rules — so a REST API gets endpoint validation checks, a desktop app gets window management safety rules, and an AI chatbot gets streaming-first design principles. Organization-level conventions can be shared across projects, and project-specific rules can override both.

A Domain Profile consists of **5 axes** that produce rules and **1 modifier** that adjusts their depth:

| | Component | What it determines | Example |
|-|-----------|-------------------|---------|
| Axis 1 | **Interface** | What the app exposes to users | GUI, HTTP API, CLI, TUI |
| Axis 2 | **Concern** | Cross-cutting patterns that span Features | auth, async-state, IPC, realtime, i18n |
| Axis 3 | **Archetype** | Domain philosophy — *why* certain decisions matter | AI assistant, microservice, public API |
| Axis 4 | **Foundation** | Framework-specific constraints and toolchain | React, Electron, Next.js (21 frameworks) |
| Axis 5 | **Scenario** | Project lifecycle context | greenfield, rebuild, adoption |
| Modifier | **Scale** | How much rigor to apply | prototype / mvp / production × solo / small-team / large-team |

Each axis contributes rules (SC quality criteria, bug prevention patterns, verification strategies). The Scale modifier doesn't add rules — it adjusts their enforcement: a prototype gets functional-only SCs with optional tests, while a production project gets full edge-case coverage with mandatory observability.

When multiple concerns are active together, **Cross-Concern Integration Rules** activate emergent patterns — for example, `gui` + `realtime` triggers optimistic update and reconnection UI rules that neither module produces alone.

Domain Profile is a **first-class citizen** — not a configuration that's set once and forgotten, but a living context that actively influences every step of every skill:

- **code-explore**: detects the source project's profile (all 5 axes + Scale) during orientation, guides which flows to trace, and derives your target profile during synthesis
- **init**: infers your profile from a text description or inherits it from code-explore, writes it to project state
- **add**: uses profile rules to determine what makes a Feature definition "complete" (an API project must define endpoints; a GUI project must specify interactions)
- **specify → plan → implement → verify**: each step loads profile-specific rules, filtered by Scale — so a production desktop app with IPC gets mandatory process boundary safety checks, while an MVP microservice with message queues gets dead-letter handling as a recommended (not blocking) pattern

See [Domain Module System](#domain-module-system) for details.

#### Brief

**The gap**: Agents start coding from whatever description they receive, with no quality gate on Feature definitions. Agents don't verify that they understood the user's intent — they accept input, interpret it, and proceed without confirmation.

**The solution**: A structured Feature intake process — implemented in `/smart-sdd add` — that normalizes any input into a consistently complete Feature definition, then **verifies the agent's understanding matches the user's actual intent** before entering the spec-kit pipeline.

A Brief is **not** the same as a PRD. A PRD is one possible *input* to the Brief process; a casual conversation or a gap analysis result are equally valid inputs. The Brief is the *output* — a normalized, quality-checked Feature definition that has been validated for both **completeness** (all key dimensions covered) and **accuracy** (the agent's interpretation confirmed by the user through an explicit approval gate).

```
/smart-sdd init                      /smart-sdd add (= Briefing)
Sets up the PROJECT:                 Defines each FEATURE:
- name, stack, principles            - capabilities, data, interfaces
- Domain Profile detection           - quality criteria, boundaries
- Feature candidates (names only)    - normalized Brief per Feature
         │                                      │
         └──── chains into ────────→            │
                                                ▼
                                         pre-context (GEL)
                                                │
                                                ▼
                                         spec-kit pipeline
```

`init` may accept a PRD to understand the *project* — extracting stack hints, Domain Profile signals, and a rough Feature list. But it stops at Feature *names*. The actual Feature *definition* — ensuring each Feature has complete capabilities, data requirements, interface contracts — happens in `add` through the Brief process.

Domain Profile rules add project-type-specific completion criteria — an API project's Brief must define endpoint contracts; a GUI project's Brief must specify user interactions. Incomplete inputs trigger targeted questions rather than proceeding with gaps.

After completeness criteria are met, the agent presents a **Brief Summary** showing its interpretation. The user explicitly approves it or corrects misunderstandings — an **intent verification gate** that catches interpretation errors before they propagate through the pipeline. A second-layer **Brief↔Spec alignment check** during `specify` verifies that the generated spec faithfully reflects the approved Brief.

For existing codebases (`/smart-sdd adopt`), Features are auto-extracted from source code — but the same intent verification principle applies. Each Feature goes through a scope confirmation gate before adoption begins, ensuring the user validates what was inferred from code analysis.

The result: specs generated from a well-formed, user-verified Brief are more complete, more testable, and require fewer mid-implementation corrections.

---

## Skills

### `/reverse-spec` — Existing Source → SDD-Ready Artifacts

Reads your existing source code and produces the foundation that SDD needs: Feature decomposition, entity/API registries, per-Feature pre-contexts, and source coverage baseline.

```bash
/reverse-spec [target-directory] [--scope core|full] [--stack same|new] [--name new-project-name]
```

**Workflow**: Phase 0 (strategy) → Phase 1 (project scan) → Phase 1.5 (runtime exploration — runs the source app, captures UI flows) → Phase 2 (deep analysis) → Phase 3 (Feature classification) → Phase 4 (artifact + spec-draft generation)

In rebuild mode, Phase 1.5 is **required** — it runs the source app and records exactly how each UI flow works (what controls exist, what auto-fills, what error messages appear). Phase 4 then converts these observations into `spec-draft.md` per Feature with detailed FR/SC that preserve every UI detail. The pipeline's `specify` step refines this draft instead of generating from scratch.

### `/smart-sdd` — spec-kit with Cross-Feature Context

Wraps every spec-kit command with a **4-step protocol**: Assemble context → Checkpoint → Execute + Review → Update registries. This means `/speckit-plan` for Feature 3 automatically knows Feature 1's `User` entity and Feature 2's API contracts.

```bash
/smart-sdd init                          # New project setup
/smart-sdd add                           # Define new Feature(s)
/smart-sdd pipeline                      # Run full SDD pipeline
/smart-sdd adopt                         # Document existing code with SDD
/smart-sdd status                        # Check progress
```

**Five modes**: greenfield (`init`), incremental (`add`), rebuild (`pipeline` after `reverse-spec`), adoption (`adopt`), scope expansion (`expand`)

### How the Skills Connect

```mermaid
flowchart TD
    subgraph entry["Entry Points"]
        direction LR
        IDEA["💡 Idea / PRD"]
        CODE["📦 Existing Code"]
    end

    subgraph explore["1. UNDERSTAND — /code-explore"]
        CE_ORIENT["Orient
        Architecture map
        Module discovery"]
        CE_TRACE["Trace (×N)
        End-to-end flow tracing
        Entity/API/Rule observations"]
        CE_SYNTH["Synthesis
        Feature candidates (C001...)
        Accumulated insights"]
        CE_ORIENT --> CE_TRACE --> CE_SYNTH
    end

    subgraph explore_out["specs/explore/"]
        EO["orientation.md
        traces/*.md
        synthesis.md"]
    end

    subgraph analyze["2. ANALYZE"]
        INIT["/smart-sdd init
        Domain Profile detection
        Feature candidates"]

        subgraph rs_detail["/reverse-spec"]
            RS_RUN["Phase 1.5: Run source app
            Capture UI flows, controls, error paths"]
            RS_CODE["Phase 2-3: Code analysis
            SBI, entities, APIs, Features"]
            RS_DRAFT["Phase 4: Generate per Feature
            pre-context + spec-draft.md"]
            RS_RUN --> RS_CODE --> RS_DRAFT
        end

        ADOPT_RS["/reverse-spec --adopt
        Document existing code"]
    end

    subgraph define["3. DEFINE"]
        ADD["/smart-sdd add (Brief)
        6-perspective validation
        Intent verification gate
        C001 → F001 confirmation"]
    end

    subgraph gel["Global Evolution Layer — specs/_global/"]
        GEL_PROJ["Project-wide:
        roadmap · registries · constitution"]
        GEL_FEAT["Per Feature:
        pre-context · UI Flow Spec · spec-draft"]
    end

    subgraph build["4. BUILD"]
        subgraph pipeline_detail["/smart-sdd pipeline"]
            SPECIFY["specify
            Refines spec-draft (not from scratch)
            UI control downgrade = BLOCKING"]
            PLAN["plan → tasks → analyze"]
            IMPL["implement
            Wiring Check (7-point)"]
            VERIFY["verify
            SC Evidence Gate (runtime proof required)"]
            SPECIFY --> PLAN --> IMPL --> VERIFY
        end
        ADOPT_P["/smart-sdd adopt
        specify → plan → analyze → verify"]
    end

    DP["⚙️ Domain Profile
    Per-step rules loaded
    from project type"]

    CODE --> CE_ORIENT
    CE_TRACE --> EO
    IDEA --> INIT

    CE_SYNTH -- "--from-explore" --> RS_RUN
    CE_SYNTH -- "--from-explore" --> ADD
    CE_SYNTH -- "--from-explore" --> ADOPT_RS

    CODE --> RS_RUN
    CODE --> ADOPT_RS
    INIT --> ADD
    RS_DRAFT --> GEL_PROJ
    RS_DRAFT --> GEL_FEAT
    ADOPT_RS --> GEL_PROJ
    ADD --> GEL_PROJ
    GEL_FEAT -- "spec-draft seeds specify" --> SPECIFY
    GEL_PROJ --> pipeline_detail
    GEL_PROJ --> ADOPT_P
    DP -.- pipeline_detail
    DP -.- ADOPT_P
    DP -.- ADD
```

The diagram shows the full lifecycle: **understand** existing code with code-explore, **analyze** it with reverse-spec (which runs the source app and generates spec-drafts per Feature), **define** Features through the Brief process, then **build** through the spec-kit pipeline (where specify refines spec-drafts instead of generating from scratch). Source analysis artifacts live in `specs/_global/`, pipeline output lives in `specs/NNN-feature/` — clean separation.

---

## User Journeys

```
── From an Idea (Proposal Mode) ──────────────────────────────────
/smart-sdd init "Build a Chrome extension..."
  Domain Profile detected → auto-chain to:
  /smart-sdd add (Brief) → /smart-sdd pipeline (GEL + Domain Profile)

── New Project (Standard) ────────────────────────────────────────
/smart-sdd init         →  /smart-sdd add      →  /smart-sdd pipeline
(Domain Profile setup)     (Brief per Feature)    (GEL + Domain Profile)

── SDD Adoption ──────────────────────────────────────────────────
/reverse-spec --adopt   →  GEL artifacts       →  /smart-sdd adopt
(Domain Profile auto)      (roadmap, registries)   (document existing)

── Rebuild ───────────────────────────────────────────────────────
/reverse-spec           →  GEL artifacts       →  /smart-sdd pipeline
(Domain Profile auto)      (Brief Summary in      (GEL + Domain Profile
                            pre-contexts)           per step)

── Incremental ───────────────────────────────────────────────────
/smart-sdd add          →  updated GEL         →  /smart-sdd pipeline
(Brief for new Feature)    (pre-context added)    (GEL + Domain Profile)
```

All journeys converge to **incremental mode** as the steady state. In every journey, the three core concepts participate: **Brief** ensures Feature definitions are complete, **GEL** provides cross-Feature context, and **Domain Profile** shapes each pipeline step's behavior.

### End-to-End Workflow Examples

### Scenario 1: Greenfield from an Idea (Proposal Mode)

```
1. /smart-sdd init "Build a task management app with Kanban boards and team workspaces"
   ┌─ Domain Profile ─────────────────────────────────────────────────┐
   │ Signal Extraction: "task management" → Core Purpose,            │
   │   "Kanban boards" → gui, "team workspaces" → auth + async-state │
   │ Clarity Index: 58% (Medium) → ask 2 targeted questions          │
   │ Result: [gui, http-api] + [auth, async-state]                   │
   └──────────────────────────────────────────────────────────────────┘
   +-- Proposal: 5 Features → User approves → auto-chain

2. /smart-sdd add (auto-chained) ← Brief
   ┌─ Briefing ───────────────────────────────────────────────────────┐
   │ Each Feature validated against 6 perspectives                    │
   │ + Domain-specific S9 criteria (gui: screens, http-api: endpoints)│
   │ → Normalized Brief → pre-context per Feature                     │
   └──────────────────────────────────────────────────────────────────┘

3. /smart-sdd pipeline ← GEL + Domain Profile
   +-- Phase 0: Constitution finalized
   +-- For each Feature (specify → plan → tasks → analyze → implement → verify):
   |   ┌─ GEL ─────────────────────────────────────────────────────────┐
   |   │ Each step gets cross-Feature context: entity registry,        │
   |   │ API contracts, preceding Features' decisions                   │
   |   └───────────────────────────────────────────────────────────────┘
   |   ┌─ Domain Profile ──────────────────────────────────────────────┐
   |   │ S1 shapes SCs, S7 prevents bugs, S8 drives verification      │
   |   └───────────────────────────────────────────────────────────────┘
   +-- F001-auth → F002-workspace → F003-task → F004-board → F005-notif
```

### Scenario 1b: Greenfield — Standard Q&A

```
1. /smart-sdd init
   +-- Define project: "TaskFlow", TypeScript + Next.js + Prisma
   +-- Domain Profile detected: [gui, http-api] + [auth, async-state]
   +-- Constitution seed with 6 Best Practices
   +-- Chain into /smart-sdd add...

2. /smart-sdd add ← Brief
   +-- Briefing: F001-auth, F002-workspace, F003-task, F004-board, F005-notif
   +-- Each Feature validated: capabilities, data, interfaces complete
   +-- S9 check: gui Brief requires screens, http-api Brief requires endpoints
   +-- Demo Group assignment → create pre-context (GEL) per Feature

3. /smart-sdd pipeline ← GEL + Domain Profile
   +-- Phase 0: Finalize constitution (Domain Profile A4 principles injected)
   +-- Release 1 (Foundation):
   |   F001-auth → specify → plan → tasks → analyze → implement → verify
   |   GEL Update: User, Session entities → entity-registry
   +-- Release 2 (Core):
   |   F002-workspace (GEL injects F001's User entity as context)
   |   F003-task ...
   +-- Release 3 (Enhancement): F004-board, F005-notification
```

### Scenario 2: Brownfield Rebuild — Legacy e-commerce to React + FastAPI

```
1. /reverse-spec ./legacy-ecommerce --scope core --stack new
   ┌─ Domain Profile ─────────────────────────────────────────────────┐
   │ Auto-detected: [http-api, gui] + [auth, async-state]            │
   │ Archetype: none (standard e-commerce)                            │
   └──────────────────────────────────────────────────────────────────┘
   +-- Phase 1: Detect Django + jQuery stack
   +-- Phase 2: Extract 12 entities, 45 APIs, 78 business rules
   +-- Phase 3: 8 Features (Tier 1: Auth, Product, Order | T2: Cart, Payment, Search | T3: Review, Notif)
   +-- Phase 4: Generate GEL artifacts (roadmap, registries, pre-contexts with Brief Summary)

2. /smart-sdd pipeline ← GEL + Domain Profile
   +-- Scope: Core (Tier 1 only)
   +-- Each Feature: specify → plan → tasks → analyze → implement → verify
   +-- F001-auth → F002-product → F003-order
   +-- Tier 2/3 remain deferred

3. /smart-sdd expand T2     → activates Cart, Payment, Search
4. /smart-sdd expand full   → activates Review, Notification
```

### Scenario 3: Incremental — Adding notifications to existing project

```
1. /smart-sdd add ← Brief
   +-- "I need real-time notifications for task updates"
   ┌─ Briefing ───────────────────────────────────────────────────────┐
   │ 6-perspective validation:                                        │
   │  ✅ User & Purpose: end users receive task update notifications  │
   │  ✅ Capabilities: real-time push, email digest, preferences      │
   │  ✅ Data: Notification entity (owned), User (referenced)         │
   │  ✅ Interfaces: WebSocket channel + /api/notifications           │
   │ S9 (http-api): endpoint defined ✅  S9 (realtime): WS type ✅   │
   └──────────────────────────────────────────────────────────────────┘
   +-- Overlap check: No conflicts with existing Features
   +-- ⚠️ Constitution Impact: WebSocket (new technology)
   +-- F005-notification depends on F001-auth, F003-task
   +-- Brief → pre-context stored in GEL

2. /smart-sdd pipeline ← GEL + Domain Profile
   +-- Skips completed Features
   +-- F005-notification: specify → plan → tasks → analyze → implement → verify
   +-- GEL Update: Notification entity → entity-registry
   +-- Domain Profile: S1 shapes SCs (realtime: reconnection SC required)
```

---

## Quick Examples

**Rebuild an existing app**:
```bash
/reverse-spec ./legacy-app --scope core --stack new
# → Scans source code, detects Domain Profile, extracts Features
# → Produces: roadmap.md, entity-registry.md, api-registry.md, pre-contexts
# → You review and approve the Feature list at a HARD STOP

/smart-sdd pipeline
# → Processes each Feature: specify → plan → tasks → analyze → implement → verify
# → HARD STOP at each Checkpoint (before) and Review (after)
# → Target app reproduces source app's UX patterns in the new stack
```

**Greenfield project**:
```bash
/smart-sdd init "Build a task management app with team workspaces"
# → Detects Domain Profile: [gui, http-api] + [auth, async-state]
# → Proposes 5 Features → you approve → chains into /smart-sdd add

/smart-sdd add
# → Briefing: 6-perspective validation per Feature
# → You approve each Brief Summary at a HARD STOP

/smart-sdd pipeline
# → Builds each Feature with cross-Feature context from GEL
```

**Add a Feature to an existing project**:
```bash
/smart-sdd add
# → "I need real-time notifications" → Briefing → Brief Summary → approval

/smart-sdd pipeline
# → Skips completed Features, processes only new/pending ones
```

---

## Architecture

### How the Three Concepts Work Together

The three concepts aren't independent features — they form a layered system where each concept feeds the next:

The three concepts chain: **Brief** produces a complete Feature definition → stored as **pre-context** in the **GEL** → injected into the **spec-kit pipeline** → where **Domain Profile** rules shape every step's behavior.

### Implementation: Pipeline Integrity Guards

The three concepts are enforced through 7 Pipeline Integrity Guards — protection patterns extracted from real-world failures. Each guard covers a class of problems with clear trigger conditions and enforcement rules. When new failures are discovered, they extend existing guards rather than pile up as one-off fixes. See [`pipeline-integrity-guards.md`](.claude/skills/smart-sdd/reference/pipeline-integrity-guards.md).

These guards implement three enforcement mechanisms:

| Mechanism | What It Does | Which Concept It Serves |
|-----------|-------------|------------------------|
| **Context Injection** | Feeds each step the knowledge it needs — what other Features decided, how the existing app works, what rules apply | Global Evolution Layer |
| **Gate Enforcement** | Checkpoints that stop the pipeline when output doesn't meet criteria — not "should check" but "cannot proceed" | Brief (intake gates) + GEL (review gates) |
| **Behavioral Fidelity** | Captures not just *what* to build but *how it should work* — how users interact, how data flows, how the app responds | Domain Profile (domain-aware verification) |

### Design Philosophy

Five principles shape every design decision:

1. **Structured input produces better output** (Brief) — Instead of accepting vague Feature descriptions, the system ensures every Feature is defined completely before specs begin. Missing dimensions trigger questions, not assumptions.

2. **Give each step only the context it needs** (GEL) — Before each pipeline step, the relevant cross-Feature knowledge is automatically injected — data models, API contracts, project rules. The agent sees exactly what it needs, no more, no less.

3. **Load only relevant rules** (Domain Profile) — A REST API project doesn't need GUI testing rules. An AI chat app doesn't need CRUD validation rules. The system auto-detects your project type and loads only the modules that apply.

4. **Humans approve before anything is final** — The agent runs autonomously through research, planning, and coding. But before specs are created and before code is accepted, you review and approve. The agent does the work; you make the decisions.

5. **Start broad, drill deep** — Analysis begins with tech stack and project structure, then progressively zooms into function signatures, UI components, micro-interactions, and edge cases. Each level builds on the one above.

### How the Pipeline Works

The pipeline runs in three phases. First, the project is analyzed (or defined from scratch). Then, each Feature is built one at a time through a 6-step cycle. Finally, each step is verified before moving on.

```
1. Analysis (reverse-spec or init):
   Source Code → Tech Stack Detection → Framework Identification →
   Foundation Extraction → Feature Extraction →
   Global Evolution Artifacts (roadmap, registries, pre-contexts)

2. Development (smart-sdd pipeline):
   For each Feature (T0 → T1 → T2 → T3):
   Assemble Context → Checkpoint (HARD STOP) →
   Execute spec-kit → Review (HARD STOP) → Update State

3. Verification (verify phases):
   Build → Test → Lint → Cross-Feature Consistency →
   Runtime SC Verification → Demo-Ready Check → Foundation Compliance
```

**What a HARD STOP looks like in practice**: At each Checkpoint and Review, the agent pauses and shows you a summary of what it assembled or produced, then asks for your decision:

```
📋 Checkpoint — Context for F002-task-crud specify:

  Entity context: User (from F001-auth), Session (from F001-auth)
  API context: POST /api/auth/login (from F001-auth)
  Domain Profile: [gui, http-api] + [auth, async-state] + mvp/solo

  Approve and proceed to specify?
  ├─ "Approve" — run speckit-specify with this context
  ├─ "Modify context" — adjust what's injected
  └─ "Skip Feature" — defer F002 and move to next
```

After spec-kit runs, a Review HARD STOP shows the output and asks you to approve before moving on. You always see what the agent produced and decide whether it's good enough.

Each Feature goes through a **6-step lifecycle**. If verify finds bugs, they loop back to the right step instead of being patched silently:

```
specify → plan → tasks → analyze → implement → verify → merge
                                                  │
                                    Minor fix ←────┘ (inline, ≤2 files)
                                    Major-Implement → back to implement
                                    Major-Plan → back to plan
                                    Major-Spec → back to specify
```

Verify discovers bugs and classifies them by severity. Only Minor issues are fixed inline; Major issues loop back to the appropriate pipeline step — with a **Spec Coverage Pre-check**: if no SC covers the broken behavior, it's Major-Spec (the spec was incomplete), not Major-Implement.

### Project Modes

Choose the mode that matches your situation:

| Mode | Entry Point | Use Case | Code Changes? |
|------|-------------|----------|--------------|
| Greenfield | `/smart-sdd init` → `add` → `pipeline` | New project from scratch | Yes — generates new code |
| Incremental | `/smart-sdd add` → `pipeline` | Add features to existing smart-sdd project | Yes — adds new code |
| Rebuild | `/reverse-spec` → `/smart-sdd pipeline` | Rebuild existing codebase with SDD | Yes — rewrites in new stack, targeting UX equivalence with the source app |
| Adoption | `/reverse-spec --adopt` → `/smart-sdd adopt` | Wrap existing code with SDD docs | **No** — documents existing code without rewriting. Skips `tasks` and `implement` |

> **Rebuild vs Adoption**: Rebuild re-implements the source app in a new stack — new code is written, and the target must match the source app's UX patterns. Adoption wraps your existing code with SDD specs and plans without touching the source — useful for onboarding an existing project into the SDD workflow so future changes follow the pipeline.

When rebuilding existing software (stack migration, framework upgrade, etc.), reverse-spec Phase 0 collects four configuration parameters:

| Parameter | What it controls | Example |
|-----------|-----------------|---------|
| Change scope | Elaboration probes, bug prevention rules | `framework` (Express → Fastify) |
| Preservation level | SC depth requirements, verification strictness | `equivalent` (same data, format may differ) |
| Source available | Side-by-side comparison strategy | `running` (original app accessible) |
| Migration strategy | Regression gate scope, merge policy | `incremental` (Feature-by-Feature) |

These are stored in `sdd-state.md` and automatically read by relevant pipeline steps — see `domains/scenarios/rebuild.md` for the full consumption matrix.

### Key Artifacts

The pipeline produces and maintains these shared artifacts — they're how Feature 3 knows what Feature 1 already decided:

| Artifact | Location | Purpose |
|----------|----------|---------|
| Roadmap | `specs/_global/roadmap.md` | Feature catalog, dependency graph, release groups |
| Entity Registry | `specs/_global/entity-registry.md` | Shared data model definitions |
| API Registry | `specs/_global/api-registry.md` | API contract specifications |
| Business Logic Map | `specs/_global/business-logic-map.md` | Cross-Feature business rules |
| Pre-context | `specs/_global/features/F00N-*/pre-context.md` | Per-Feature context for spec-kit |
| Constitution | `.specify/memory/constitution.md` | Project-wide principles & best practices |
| State | `specs/_global/sdd-state.md` | Pipeline progress, toolchain, Foundation decisions |

---

## Domain Module System

The Domain Profile concept from [What It Solves](#domain-profile) is implemented as a **composable module system** — standalone files that merge automatically based on your project's 5-axis configuration.

### Available Modules

```
Interfaces (5):   gui, http-api, cli, data-io, tui
Concerns (16):    auth, authorization, async-state, codegen, external-sdk, i18n,
                  infra-as-code, ipc, llm-agents, message-queue, multi-tenancy,
                  plugin-system, polyglot, protocol-integration, realtime, task-worker
Archetypes (4):   ai-assistant, public-api, microservice, sdk-framework
Foundations (21): electron, nextjs, express, django, spring-boot, tauri, ...
Scenarios (4):    greenfield, rebuild, incremental, adoption
```

### How Detection Works

- **Greenfield**: Signal keywords in your description are matched against each module's S0 keywords. Scored by a **Clarity Index** (7 dimensions) — high CI generates a Proposal directly, low CI triggers targeted questions. See `reference/clarity-index.md`.
- **Brownfield**: Code patterns (imports, decorators, config files) auto-detect which modules apply.
- Both produce the same format in `sdd-state.md` — the pipeline doesn't care how the profile was determined.

### What's Inside Each Module — The Section System

Each module isn't just a tag that says "this project uses auth." It's a file containing **numbered sections**, where each section feeds a specific pipeline step. There are four section families, each serving a different skill:

**S-sections** (smart-sdd — pipeline execution):

| Section | What it provides | Which pipeline step uses it |
|---------|-----------------|---------------------------|
| **S0** | Signal keywords for auto-detection | `init` (profile inference) |
| **S1** | Success criteria rules and anti-patterns | `specify` (what "done" means for this module) |
| **S3** | Verification steps and gates | `verify` (what to check and what blocks progress) |
| **S4** | Data integrity principles (authority, empty input, pipeline trace) | All steps (universal engineering principles) |
| **S5** | Consultation questions | `clarify` / `add` (what to ask the user about this module) |
| **S7** | Bug prevention rules with detection + fix | `plan` / `implement` / `verify` (known failure patterns) |

**A-sections** (archetypes — domain philosophy):

| Section | What it provides | Which pipeline step uses it |
|---------|-----------------|---------------------------|
| **A0** | Signal keywords for archetype detection | `init` (archetype inference) |
| **A1** | Core philosophy principles | Guides all steps (e.g., "Streaming-First" shapes every decision) |
| **A2** | SC generation extensions | `specify` (archetype-specific success criteria) |
| **A3** | Domain-specific consultation questions | `clarify` / `add` (e.g., "Single or multi-provider LLM?") |
| **A4** | Constitution injection | `constitution` (principles baked into the project's foundation) |

**R-sections** (reverse-spec — source analysis):

| Section | What it provides | Which pipeline step uses it |
|---------|-----------------|---------------------------|
| **R1** | Code patterns for detection | `analyze` Phase 1 (auto-detect which modules apply) |
| **R3** | Extraction axes | `analyze` Phase 2 (what to extract from the code for this module) |

**F-sections** (foundations — framework infrastructure):

| Section | What it provides | Which pipeline step uses it |
|---------|-----------------|---------------------------|
| **F0** | Framework detection signals | `analyze` Phase 1 / `init` (identify framework) |
| **F2** | Infrastructure checklist items | `init` (decisions before coding) / `analyze` (extract existing decisions) |
| **F7** | Framework philosophy principles | `constitution` (framework-endorsed patterns) |

**Module loading order**: `_core.md` (always) → active Interfaces → active Concerns → active Archetypes → Org Convention (if specified) → Scenario → Project Custom (`domain-custom.md`). When modules are loaded, their sections **merge by append** — an `http-api` project with `auth` concern and `ai-assistant` archetype accumulates S1 rules from all three, S5 probes from all three, and A4 principles from the archetype. The agent gets one combined ruleset, not three separate files to juggle. For the complete merge protocol and a worked example, see [ARCHITECTURE-EXTENSIBILITY.md § 2b](ARCHITECTURE-EXTENSIBILITY.md#2b-how-composed-modules-drive-the-pipeline).

### Platform Foundation & Tier System

Projects built on specific frameworks (Electron, Express, Next.js, etc.) have infrastructure decisions that must be established before any business Feature — single-instance lock, IPC architecture, middleware chain, rendering strategy. The Platform Foundation layer captures these decisions explicitly:

```
Profile (desktop-app, web-api, fullstack-web, cli-tool, ml-platform, sdk-library)
   │
   ├── Interface modules (gui, http-api, cli, data-io, tui)
   ├── Concern modules (15: auth, async-state, codegen, ipc, i18n, infra-as-code, ...)
   ├── Archetype modules (ai-assistant, public-api, microservice, sdk-framework)
   ├── Scenario (greenfield, rebuild, incremental, adoption)
   ├── Foundation (electron, express, nextjs, tauri, vite-react, ...)
   │     └── F7 Philosophy: framework-specific guiding principles (distinct from F0–F6 checklists)
   ├── Org Convention (organization-level shared rules)
   └── Project Custom (project-specific overrides)
```

**Foundation files** in `reverse-spec/domains/foundations/` provide exhaustive checklists of infrastructure decisions per framework. Each item is classified by priority (Critical / Important / Optional) and grouped into categories (Window Management, Security, IPC, Middleware, Routing, etc.). F7 Philosophy captures framework-endorsed principles (e.g., Electron's "Process Crash Isolation", Express's "Middleware Composition") — _why_ certain patterns are preferred, not _what_ to configure.

**In rebuild mode** (`/reverse-spec`): Foundation decisions are extracted from existing code and documented in pre-context.
**In greenfield mode** (`/smart-sdd init`): Critical Foundation items are presented to the user for explicit decisions before pipeline begins.

The Foundation layer supports framework migration (e.g., Express → NestJS) with a 4-classification system: carry-over, equivalent, irrelevant, new — preserving infrastructure decisions across stack changes. See `domains/foundations/_foundation-core.md` for the full protocol, case matrix, and cross-framework carry-over map.

Foundation decisions feed into the **Tier System**, which determines Feature processing order:

| Tier | Purpose | When Processed |
|------|---------|----------------|
| **T0** | **Platform Foundation** — infrastructure decisions (framework-specific) | First (before business Features) |
| **T1** | Essential — system cannot function without | After T0 |
| **T2** | Recommended — completes core user experience | After T1 |
| **T3** | Optional — supplementary, admin, convenience | After T2 |

T0 Features are auto-generated from Foundation categories with Critical items requiring code. They must complete before T1 begins — a Foundation Gate enforces this.

---

## Pipeline Quality Gates

Each pipeline step has built-in checks that catch problems **before** they cascade downstream. These gates work automatically — no configuration needed.

**Key principle**: Problems are cheapest to fix where they originate. A missing FR in specify costs minutes to add; the same gap discovered in verify costs hours of rework. The gates shift detection **left** — toward the earliest possible pipeline step.

| Stage | What gates catch | Example |
|-------|-----------------|---------|
| **specify** | Vague requirements, missing UI interaction detail | "file embedding" → 5 pipeline-stage FRs; "create KB" → step-by-step UI Flow Spec with form fields, validation, error paths |
| **plan** | Architecture gaps, missing components | No citation component in plan but FR requires citation display |
| **tasks** | Missing implementation work items | Cross-boundary Feature with no wiring task |
| **analyze** | Coverage holes between spec↔plan↔tasks | SC describes behavior but no task implements it |
| **implement** | Broken dependencies, disconnected modules | Library import fails at runtime; IPC handler exists but preload missing |
| **verify** | No evidence of runtime verification | Agent claims "12/12 SC ✅" but only read code, never ran the app |

---

## Extensibility & Customization

Each of the three core concepts can be extended independently. The system is designed so you can start with defaults and progressively customize:

**Level 0 — Out of the box**: All three concepts work automatically. Domain Profile is auto-detected, Brief completion criteria use built-in defaults, GEL artifacts are generated and injected without configuration. Works for most projects immediately. All pipeline-generated artifacts (specs, plans, tasks) are in English by default — pass `--lang ko` (or any language code) to `init`, `reverse-spec`, or `add` to generate artifacts in your preferred language.

**Level 1 — Tune Domain Profile**: Edit `sdd-state.md` to add/remove active Interfaces and Concerns. Loading `auth` adds authentication-specific SC rules and Brief completion criteria; removing `i18n` skips internationalization checks.

**Level 2 — Project-specific rules**: Create `specs/_global/domain-custom.md` in your project. Add rules using the same S1/S5/S7 schema (e.g., "all payment endpoints require idempotency SC", "dark mode must be tested in verify"). This file loads last with highest priority — no skill files modified.

**Level 3 — New Domain Profile modules**: Create custom Interface or Concern files (e.g., `domains/interfaces/grpc.md`, `domains/concerns/caching.md`). Follow `domains/_schema.md` for the module format. Your modules compose automatically with built-in ones.

**Level 4 — New Foundation checklists**: Create `reverse-spec/domains/foundations/{framework}.md` for frameworks not yet covered. The system gracefully degrades without it (Case B: universal categories + agent probes), but a dedicated checklist ensures nothing is missed.

**Level 5 — Pipeline behavior modification**: Override verify severity thresholds, pipeline step ordering, HARD STOP behavior, and context injection rules through the reference files. Advanced users can tune the balance between automation speed and review thoroughness.

Every customization level is backward-compatible — a Level 2 project doesn't break if the skill files update, because `domain-custom.md` lives in the user's project directory, not in the skills repo.

Each module is a standalone file with a uniform schema (`S1`: SC generation rules, `S5`: elaboration probes, `S7`: bug prevention). Adding a new module doesn't require modifying any existing file — it automatically composes with whatever is already active. Each interface module also declares an **S8 Runtime Verification Strategy** — how to start, verify, and stop that interface type at runtime.

**Add a new interface** (e.g., your project uses gRPC, which isn't built-in):
1. Create `domains/interfaces/grpc.md` — add SC rules ("every RPC method needs request/response proto shape"), probes ("streaming vs unary?"), and bug prevention rules
2. List it in sdd-state.md: `**Interfaces**: http-api, grpc`
3. The agent now loads `_core.md` + `http-api.md` + `grpc.md` + your concerns — all rules merge automatically

**Add a new concern** (e.g., your project has caching patterns worth checking):
1. Create `domains/concerns/caching.md` — add SC rules ("cache hit/miss/stale lifecycle"), probes ("TTL? Invalidation strategy?")
2. Add to active concerns: `**Concerns**: async-state, auth, caching`

**Add a new archetype** (e.g., your project is a SaaS platform with multi-tenancy patterns):
1. Create `domains/archetypes/saas-platform.md` in both skills — define A0 signal keywords ("multi-tenant", "subscription"), A1 philosophy principles ("Tenant Isolation", "Subscription Lifecycle"), and A2-A4 sections for SC rules, probes, and constitution injection
2. Set in sdd-state.md: `**Archetype**: saas-platform`
3. The agent now loads archetype-specific principles that guide every pipeline step — SCs require tenant isolation, probes ask about subscription billing, constitution gets multi-tenancy rules

**Add a new Foundation** (e.g., your team uses Remix, which has no built-in Foundation file):
1. Create `reverse-spec/domains/foundations/remix.md` following the F0-F7 format in `_foundation-core.md`
2. Define detection signals (F0), categories (F1), items (F2), extraction rules (F3), T0 grouping (F4), and optionally F7 philosophy
3. The system detects Remix automatically via F0 signals and loads the full Foundation flow
4. Without a custom Foundation file, the system still works — it falls back to Case B (universal categories + agent probes)

**Customize per project** — without modifying skill files at all:
1. Create `specs/_global/domain-custom.md` in your project directory
2. Add project-specific rules using the same S1/S5/S7 schema (e.g., "payment endpoints require idempotency SC")
3. This file loads last with highest priority, extending all other modules

**Adapt to your workflow** — every checkpoint and gate can be tuned:
- **Scope**: `core` scope activates T1 only (fastest path); `full` processes everything
- **Preservation**: `equivalent` requires behavioral parity; `similar` allows cosmetic differences
- **Pipeline steps**: Skip specific spec-kit steps via sdd-state.md flags
- **Severity thresholds**: Adjust which verify bugs loop back vs fix inline via `domain-custom.md`

For detailed step-by-step extension guides and the 5-level sophistication model, see [ARCHITECTURE-EXTENSIBILITY.md](ARCHITECTURE-EXTENSIBILITY.md). See also `domains/_schema.md` for the module schema, `domains/_resolver.md` for the full loading protocol, and `reference/runtime-verification.md` for the multi-backend runtime verification architecture.

---

## Session Resilience & Agent Governance

Long pipeline sessions face two systemic risks: **context window loss** (agent forgets progress mid-session) and **uncontrolled edits** (agent patches code without classification). The system addresses both:

**Compaction-Resilient State** — Verify progress, process rules, and minor fix accumulators are written to `sdd-state.md` at every phase boundary. When the context window compacts mid-verify, the Resumption Protocol reads the persisted state and resumes from the exact phase — no repeated work, no lost classifications. This makes multi-hour pipeline sessions survivable.

**Source Modification Gate** — During verify, every source edit must be classified (Minor / Major-Implement / Major-Plan / Major-Spec) *before* any code is touched. The classification determines whether the fix happens inline or routes back to the correct pipeline stage. A Minor Fix Accumulator tracks inline fixes per Feature — if the count reaches 3, the system auto-escalates to Major, preventing structural drift disguised as minor patches.

**Pipeline Integrity Guards** — 7 guards enforce the three concepts at runtime. Each guard covers a specific failure class: G1 Guideline→Gate escalation, G2 Static≠Runtime 5-level verification, G3 Cross-Stage Trust Breakers, G4 Granularity Alignment, G5 Environment Parity (dual-mode), G6 Cross-Feature Interface verification, G7 Rebuild Fidelity Chain (Component Tree + Data Lifecycle → Source Mapping → Source-First gates). New failures extend existing guards rather than accumulate as ad-hoc rules.

**Context Window Management** — Skill files are decomposed into lazy-loaded units: `SKILL.md` (always loaded, ~60 lines) routes to `commands/{cmd}.md` (loaded per command), which references `injection/{cmd}.md` (loaded per pipeline step) and `domains/{module}.md` (loaded per project profile). A desktop Electron rebuild loads ~3,200 tokens of domain rules; a CLI greenfield loads ~800. Unused modules never enter the context.

**Context Budget Protocol** — When assembled injection context for a pipeline step approaches the context window limit, sections are triaged via a 3-tier priority system: **P1** (must-inject — spec.md, tasks.md, Pattern Constraints), **P2** (summarizable to ≤30% — business-logic-map, referenced entities, preceding Feature results), **P3** (skip-safe — naming remapping, CSS value map, visual references). The overflow protocol: Summarize P2 → Skip P3 → Split (reduce parallel task batches). Each Checkpoint displays a budget indicator so the user sees what context was trimmed.

---

## Detailed Reference

### How It Works — Common Protocol

All spec-kit command executions follow this 4-step protocol:

```mermaid
flowchart LR
    A["1. Assemble
    Context Assembly"]
    B["2. Checkpoint
    Pre-Exec Confirmation
    (HARD STOP)"]
    C["3. Execute + Review
    spec-kit Execution +
    Artifact Review
    (HARD STOP)"]
    D["4. Update
    Global Refresh"]

    A --> B --> C --> D
```

| Step | Description |
|------|------------|
| **Assemble** | Reads files/sections required for the given command from `specs/_global/`, filters and assembles per command-specific injection rules. If a source file is missing or contains only placeholder text, that source is gracefully skipped |
| **Checkpoint** | Presents the assembled context to the user with actual content, providing an opportunity to approve or modify before execution |
| **Execute+Review** | Executes the corresponding spec-kit command and immediately presents the generated artifacts for review. **HARD STOP** — same rules as Checkpoint |
| **Update** | Updates Global Evolution Layer files to reflect execution results. Records progress in `sdd-state.md` |

### What Each Command Knows About Your Project

Each spec-kit command automatically receives relevant project context — you don't have to manually copy-paste anything between Features.

| Command | What it automatically knows | Why it matters |
|---------|---------------------------|---------------|
| `constitution` | Architecture principles, Best Practices from analysis | Project-wide rules are consistent from the start |
| `specify` | Feature summary, business rules, edge cases, source reference | Spec drafts are grounded in actual behavior, not guesses |
| `plan` | Dependencies, entity/API schemas from other Features, integration contracts | Plans reference real data shapes, not assumptions about other Features |
| `tasks` | The approved plan | Tasks are auto-generated from the plan |
| `analyze` | Spec + plan + tasks cross-checked | Catches spec↔plan↔task inconsistencies before implementation |
| `implement` | Tasks, interaction chains, UX behavior contract, API compatibility | Implementation follows verified contracts, runtime errors are caught immediately |
| `verify` | All cross-Feature contracts, SC verification matrix, integration contracts | Nothing ships without checking it actually works with the rest of the project |

**Preceding Feature results take priority**: If a dependent Feature's plan is already complete, the finalized `data-model.md` and `contracts/` are referenced instead of registry drafts.

#### Injection sources per command

| Command | Injection Source |
|---------|-----------------|
| `constitution` | `constitution-seed.md` |
| `specify` | `pre-context.md` + `business-logic-map.md` |
| `plan` | `pre-context.md` + `entity-registry.md` + `api-registry.md` |
| `tasks` | `plan.md` |
| `analyze` | `spec.md` + `plan.md` + `tasks.md` |
| `implement` | `tasks.md` + `plan.md` + `pre-context.md` |
| `verify` | `pre-context.md` + registries + `plan.md` |

## /reverse-spec — Detailed Workflow

### Usage

```bash
/reverse-spec [target-directory] [--scope core|full] [--stack same|new] [--name new-project-name]
```

| Option | Description |
|--------|------------|
| `--scope core` | Core features only (Tier classification enabled) |
| `--scope full` | All features (pure dependency ordering) |
| `--stack same` | Same tech stack as existing project |
| `--stack new` | Migrate to a new tech stack |
| `--name <name>` | Set new project name for identity renaming |

### Phase 0 — Strategy Questions

Two strategic questions determine the direction:

**Implementation Scope**: Core (foundation features, for learning/prototyping) vs Full (complete feature set)

**Technology Stack Strategy**: Same Stack (reuse implementation patterns) vs New Stack (extract logic only, use idiomatic patterns of the new stack)

**Project Identity** (rebuild only): Naming prefix mappings for project renaming (e.g., "Cherry Studio" → "Angdu Studio")

### Phase 1 — Project Scan

- Directory structure exploration: `**/*.{py,js,ts,jsx,tsx,java,go,rs,...}`
- Automatic tech stack detection from config files
- Project type classification: backend, frontend, fullstack, mobile, library
- Module/package boundary identification

### Phase 1.5 — Runtime Exploration (🚫 BLOCKING for rebuild)

Runs the source app and interacts with it — clicking through flows, filling forms, observing what controls exist (dropdowns vs text inputs), what auto-fills, what error messages appear. This is **required for rebuild mode** because code analysis alone cannot distinguish a Dropdown from a TextInput, or capture auto-fill behavior.

**What it captures**: For each Feature area, the agent executes the primary user flow (CRUD, configuration, data pipeline, cross-feature interaction) and records a **UI Flow Specification** — a step-by-step table of user actions, UI controls, responses, and state changes. These flow specs become the foundation for spec-draft generation in Phase 4.

For Electron apps, Playwright CLI uses `_electron.launch()` (no CDP needed). See [Playwright Setup Guide](PLAYWRIGHT-GUIDE.md).

### Phase 2 — Deep Analysis

Automatically extracts data models, API endpoints, business logic, inter-module dependencies, Source Behavior Inventory, and UI Component Features from your codebase.

**Supported frameworks** (auto-detected): Django, FastAPI/SQLAlchemy, Express/Fastify, Spring, Next.js/Nuxt, Rails, Go (Gin/Echo), TypeORM/Prisma, JPA/Hibernate, Mongoose, and more.

#### Framework-specific scan targets

**Data Model Extraction**:

| Technology | Scan Targets |
|-----------|-------------|
| Django | `models.py`, migrations |
| SQLAlchemy/FastAPI | Model classes, Alembic migrations |
| TypeORM/Prisma | Entity classes, `schema.prisma` |
| JPA/Hibernate | `@Entity` classes |
| Mongoose | Schema definitions |
| Rails | `app/models/`, migrations |
| Go | Struct definitions + DB tags (GORM, sqlx) |

**API Endpoint Extraction**:

| Technology | Scan Targets |
|-----------|-------------|
| Express/Fastify | Router files, `router.get()`, etc. |
| Django/DRF | `urls.py`, ViewSet, APIView |
| FastAPI | `@app.get()`, `@router.post()` decorators |
| Spring | `@RequestMapping`, `@GetMapping`, etc. |
| Next.js/Nuxt | `pages/api/`, `app/api/` directories |
| Rails | `config/routes.rb`, controllers |
| Go (net/http, Gin, Echo) | Router registration, handler functions |

### Phase 3 — Feature Classification & Importance Analysis

Identifies logical Feature boundaries → presents 2-3 granularity options (Coarse/Standard/Fine).

**Tier Classification (Core Scope Only)** — 5-axis evaluation:

| Axis | Criteria |
|------|----------|
| Structural Foundation | Can other Features not exist without this? |
| Domain Core | Is this directly tied to the project's reason for existence? |
| Data Ownership | Does this define and manage core entities? |
| Integration Hub | Is this a connection point with other Features/external systems? |
| Business Complexity | Are core business rules concentrated here? |

Results in Tier 1 (Essential), Tier 2 (Recommended), Tier 3 (Optional) classification.

### Phase 4 — Artifact + Spec-Draft Generation

Generates project-level artifacts (`roadmap.md`, `constitution-seed.md`, `entity-registry.md`, `api-registry.md`, `business-logic-map.md`) and per-Feature artifacts (`pre-context.md`, `spec-draft.md`).

**spec-draft.md** (rebuild mode): Converts UI Flow Specs and SBI behaviors into detailed functional requirements and success criteria — with **explicit UI control types** (Dropdown, Slider, auto-fill), **error paths** (empty input → validation error), and **data pipeline stages** (extract → chunk → embed → store → search → display). This draft becomes the seed for `speckit-specify` in the pipeline, which refines it instead of generating from scratch. The name "reverse-spec" literally describes this: reverse-engineering the spec from source code.

**Source Coverage Baseline** (rebuild only): Measures how much of the original source is covered. Unmapped items are grouped for interactive classification — assign to existing Feature, create new Feature, flag as cross-cutting, or mark as intentional exclusion.

### Artifact Details

**Project-Level**:

| Artifact | Role |
|----------|------|
| `roadmap.md` | Feature evolution map: Tier-based catalog, dependency graph, release groups |
| `constitution-seed.md` | Architecture principles, technical constraints, coding conventions, Best Practices |
| `entity-registry.md` | Complete entity list, fields, relationships, cross-Feature mapping |
| `api-registry.md` | Complete API endpoint index, detailed contracts, cross-Feature dependencies |
| `business-logic-map.md` | Per-Feature business rules, validations, workflows |
| `speckit-prompt.md` | Standalone prompt for using spec-kit without smart-sdd — per-command context guide |

**Feature-Level — `pre-context.md`**:

| Section | Target Command | Content |
|---------|---------------|---------|
| Source Reference | All | Related original files + per-stack strategy reference |
| Source Behavior Inventory | specify, verify | Function-level behavior list (P1/P2/P3) |
| UI Component Features | specify, plan, parity | Third-party UI library capabilities |
| Static Resources | All | Non-code files (images, fonts, i18n) |
| Environment Variables | All | Required runtime variables |
| For /speckit.specify | specify | Feature summary, FR/SC drafts, edge cases |
| For /speckit.plan | plan | Dependencies, entity/API schema drafts, technical decisions |
| For /speckit.analyze | analyze | Cross-Feature verification points, impact scope |

## Using spec-kit without smart-sdd

After running `/reverse-spec`, you can use plain spec-kit with the generated `speckit-prompt.md` instead of smart-sdd. This gives you the cross-Feature context that smart-sdd would normally inject automatically, but as a manual guide.

**Setup:**

1. Run `/reverse-spec` on your codebase — generates artifacts in `specs/_global/`
2. Copy `specs/_global/speckit-prompt.md` into your project's `CLAUDE.md` (or feed it to the agent at session start)
3. Run spec-kit commands (`specify`, `plan`, etc.) directly — the prompt tells the agent which artifacts to read before each command

**What the prompt covers:**
- **Artifact Map** — which reverse-spec files exist and what each one does
- **Per-command context** — for each spec-kit command (specify / plan / implement / verify), which artifacts to read and what to check after execution
- **Cross-Feature rules** — how to maintain consistency when entities or APIs are shared across Features

**When to use smart-sdd instead:**
- You want fully automated context injection (no manual steps)
- You need advanced checks: SBI cross-verification, CSS Value Map, Pattern Compliance Scan, Runtime Error Zero Gate
- You need automatic state tracking across Features (`sdd-state.md`)

---

## /smart-sdd — Detailed Workflow

### Full Command Reference

```bash
# Greenfield
/smart-sdd init "Build a task app with Kanban boards"  # Proposal Mode (from idea)
/smart-sdd init --prd path/to/prd.md     # PRD-based setup (Proposal Mode if PRD is rich)
/smart-sdd init                          # Standard interactive setup

# Add Features (universal)
/smart-sdd add                           # Interactive definition
/smart-sdd add --prd path/to/req.md      # From requirements document
/smart-sdd add --gap                     # Gap-driven: cover unmapped SBI/parity gaps

# Adoption
/smart-sdd adopt                         # Adopt pipeline: specify → plan → analyze → verify
/smart-sdd adopt --from ./path           # Read artifacts from specified path

# Pipeline (one Feature at a time by default)
/smart-sdd pipeline                      # Next single Feature (auto-select)
/smart-sdd pipeline F003                 # Target F003 specifically
/smart-sdd pipeline --start verify       # Next Feature, re-run from verify
/smart-sdd pipeline F003 --start verify  # F003, re-run from verify
/smart-sdd pipeline --all                # All eligible Features (batch mode)
/smart-sdd pipeline --from ./path        # Read artifacts from specified path

# Constitution (standalone)
/smart-sdd constitution                  # Finalize constitution

# Management
/smart-sdd expand T2                     # Activate Tier 2 Features
/smart-sdd expand full                   # Activate all remaining Features
/smart-sdd reset F007                    # Reset Feature progress (re-run from specify)
/smart-sdd reset F007 --from plan        # Reset from specific step (keep prior results)
/smart-sdd reset                         # Full pipeline reset
/smart-sdd reset --delete F007           # Permanently remove Feature
/smart-sdd status                        # Progress overview
/smart-sdd coverage                      # SBI coverage check
/smart-sdd parity                        # Parity check vs original source
```

### Four Project Modes

| Aspect | Greenfield | Incremental | Rebuild | Adoption |
|--------|-----------|-------------|---------|----------|
| Use case | New project | Add to existing | Re-implement (stack migration, framework upgrade, etc.) | Document existing |
| Entry point | `init` → `add` | `add` | `reverse-spec` → `pipeline` | `reverse-spec --adopt` → `adopt` |
| Entity/API registries | Empty → grow | Already exist | Pre-populated | Pre-populated |
| FR/SC drafts | Created from scratch | N/A | Extracted from code | Extracted from code |
| Pipeline | Full (specify→verify) | Pending Features only | Full | No implement step |

### Feature Definition Flow (`add`)

6-Phase structured consultation:

```
Phase 1: Feature Definition   — Adaptive (document / conversational / gap-driven)
Phase 2: Overlap & Impact     — Check against existing Features + constitution
Phase 3: Scope Negotiation    — Single vs split, Tier assignment
Phase 4: SBI Match + Expand   — Map source behaviors (rebuild/adoption only)
Phase 5: Demo Group           — Assign to demo groups
Phase 6: Finalization         — Create artifacts, update roadmap/sdd-state
```

**Three Entry Types**: Document-based (`--prd`), Conversational (default), Gap-driven (`--gap`)

### Pipeline Flow

```
Phase 0: Constitution Finalization
Foundation Gate (first Feature only — validates project infrastructure once):
   - Build check (BLOCKING), Toolchain Pre-flight (lint/test availability),
     Build Plugins, state management, IPC bridge, layout verification
   - Results cached in sdd-state.md — skipped for subsequent Features
Phase 1~N: Per Feature (in Release Group order):
   0. pre-flight → Ensure on main branch
   1. specify    → (pre-context + business-logic injection) → /speckit-specify → Pre-Approval Validation (BLOCK)
   2. clarify    → Only if [NEEDS CLARIFICATION] exists
   3. plan       → (pre-context + registry injection) → /speckit-plan → Pre-Approval Validation (BLOCK)
   4. tasks      → /speckit-tasks → Pre-Approval Validation (BLOCK)
   5. analyze    → /speckit-analyze (consistency check)
   6. implement  → Env var check (HARD STOP) → /speckit-implement → Smoke Launch → Completeness Gate (BLOCK) → runtime verification + fix loop
   7. verify     → 4-phase verification (+ Phase 3b bug prevention)
   8. merge      → Checkpoint (HARD STOP) → Merge to main
```

### 4-Phase Verification

What verify catches — before merge:

| What | Prevents |
|------|----------|
| Tests, build, lint pass | Broken code reaching main |
| Feature A↔B data shape compatible | Integration failures at runtime (e.g., wrong field names between Features) |
| Every scenario (SC) classified | Silently untested scenarios — you see what's verified and what's skipped with reason |
| Runtime behavior actually works (multi-backend: Playwright, curl, CLI) | "Build passes but feature does nothing at runtime" |
| Verify-time changes recorded | Hidden modifications during verify — all changes transparent in state |
| Context compaction recovery | Agent losing progress mid-verify after long sessions |

```
Phase 1:  Execution (tests, build, lint, build output fidelity) — BLOCKS on failure
Phase 2:  Cross-Feature Consistency — entity/API compat, interaction chains,
          UX behavior contract, API compat matrix, enablement smoke test,
          integration contract shape verification (Provider↔Consumer + bridge)
Phase 3:  Demo-Ready — SC Verification Matrix (coverage gate if < 50%),
          VERIFY_STEPS functional tests, visual fidelity (rebuild),
          navigation transition check, interactive runtime verification
          (interface-aware: Playwright for GUI, curl for API, shell for CLI),
          source app comparison (rebuild)
Phase 3b: Bug Prevention — empty state smoke test (data presence check),
          smoke launch criteria
Phase 4:  Global Evolution Update (registries, sdd-state)
```

### What Happens Automatically Between Steps

After each pipeline step, smart-sdd performs safety checks and keeps global state in sync — you don't need to manually update anything.

| When | What happens | Why |
|------|-------------|-----|
| After plan | Entity and API registries updated | Next Feature sees this Feature's data models |
| After implement | Console error check — **BLOCKS** if errors found | Runtime bugs caught before verify |
| After implement | Downstream Feature pre-contexts re-evaluated | Upcoming Features stay aligned with what actually got built |
| After verify | Results recorded in sdd-state.md + roadmap.md | Progress dashboard stays current |
| After verify | Merge prompt (**HARD STOP**) | You decide when code goes to main |

### Source Behavior Coverage (SBI)

End-to-end tracing: `reverse-spec SBI (B###) → specify FR (FR-###) → implement → verify → coverage update`

### Parity Checking (Rebuild)

5-phase post-pipeline check: Structural Parity → Logic Parity → Gap Report → Remediation Plan → Completion Report

### State Tracking (`sdd-state.md`)

```
Feature         | Tier | specify | plan | tasks | analyze | implement | verify | merge | Status
----------------|------|---------|------|-------|---------|-----------|--------|-------|----------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |   ✅    |    ✅     |   ✅   |  ✅  | completed
F002-product    | T1   |   ✅    |  🔄  |       |         |           |        |      | in_progress
F003-order      | T2   |         |      |       |         |           |        |      | 🔒 deferred
```

### Checking Project Status

Shell scripts in `.claude/skills/smart-sdd/scripts/` let you inspect project progress at any time:

| What you want to know | Script |
|----------------------|--------|
| Overall pipeline progress | `pipeline-status.sh` |
| Feature / Entity / API summary | `context-summary.sh` |
| How much original behavior is covered | `sbi-coverage.sh` |
| Demo group readiness | `demo-status.sh` |
| Cross-file consistency | `validate.sh` |

---

## Reference

### Installation — Alternative Methods

**Project-Local Installation**:

```bash
mkdir -p .claude/skills
cp -r /path/to/spec-kit-skills/.claude/skills/code-explore .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/reverse-spec .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/smart-sdd .claude/skills/
```

**Manual Symlinks**:

```bash
ln -s /path/to/spec-kit-skills/.claude/skills/code-explore ~/.claude/skills/code-explore
ln -s /path/to/spec-kit-skills/.claude/skills/reverse-spec ~/.claude/skills/reverse-spec
ln -s /path/to/spec-kit-skills/.claude/skills/smart-sdd ~/.claude/skills/smart-sdd
```

### Path Conventions

| Target | Path |
|--------|------|
| reverse-spec artifacts | `specs/_global/` |
| spec-kit Feature artifacts | `specs/{NNN-feature}/` |
| spec-kit constitution | `.specify/memory/constitution.md` |
| smart-sdd state file | `specs/_global/sdd-state.md` |
| Decision history | `history.md` |
| Failure patterns & countermeasures | [`lessons-learned.md`](lessons-learned.md) — 19 gap patterns + 42 specific lessons from real pipeline executions. Useful for anyone building AI agent pipelines. |

### Feature Naming Convention

| System | Format | Example |
|--------|--------|---------|
| smart-sdd (pre-context, roadmap, state) | `F{NNN}-{short-name}` | `F001-auth` |
| spec-kit (specs/ directory, git branch) | `{NNN}-{short-name}` | `001-auth` |

### Artifact Structure

```
history.md
lessons-learned.md
specs/
└── reverse-spec/
    ├── roadmap.md
    ├── constitution-seed.md
    ├── entity-registry.md
    ├── api-registry.md
    ├── business-logic-map.md           # rebuild only
    ├── stack-migration.md              # rebuild + new stack only
    ├── coverage-baseline.md            # rebuild only
    ├── parity-report.md                # rebuild only (by /smart-sdd parity)
    ├── sdd-state.md
    └── features/
        ├── F001-auth/pre-context.md
        ├── F002-product/pre-context.md
        └── ...
```

### Constitution Best Practices

| Principle | Core |
|-----------|------|
| **I. Test-First** | Write tests first. Code without tests is not complete |
| **II. Think Before Coding** | No assumptions. Mark unclear items as `[NEEDS CLARIFICATION]` |
| **III. Simplicity First** | Implement only what is in the spec |
| **IV. Surgical Changes** | No "improving" adjacent code |
| **V. Goal-Driven Execution** | Verifiable completion criteria required |
| **VI. Demo-Ready Delivery** | Each Feature ships with an executable demo script |

### Relationship with spec-kit

| Aspect | spec-kit | spec-kit-skills |
|--------|----------|-----------------|
| Role | Feature-local SDD framework | Global Evolution Layer augmentation |
| Scope | Individual Feature consistency | Cross-Feature dependencies and evolution |
| Relationship | Independent | Wraps spec-kit (does not replace) |
| Coupling | Works without spec-kit-skills | Requires spec-kit |

---

## File Map

Complete list of all files in this repository grouped by skill.

### Directory Structure Overview

Each skill follows the same internal directory convention:

```
.claude/skills/
├── shared/                        Cross-skill shared resources
│   └── domains/                   Signal keywords (S0 + R1/A0) — single source of truth
│       ├── _taxonomy.md           Module registry (all interfaces, concerns, archetypes)
│       ├── interfaces/            Per-interface signal keywords
│       ├── concerns/              Per-concern signal keywords
│       └── archetypes/            Per-archetype signal keywords
│
├── {skill}/                       Per-skill directory (code-explore, reverse-spec, smart-sdd)
│   ├── SKILL.md                   Entry point — command routing and mandatory rules
│   ├── commands/                  User commands — one file per command workflow
│   ├── domains/                   Skill-specific behavioral rules (S1-S8 or R3-R7)
│   │   ├── interfaces/            Per-interface rules (reference shared/ for S0/R1)
│   │   ├── concerns/              Per-concern rules (reference shared/ for S0/R1)
│   │   ├── archetypes/            Per-archetype rules (reference shared/ for A0)
│   │   ├── scenarios/             Project context rules (smart-sdd only)
│   │   ├── profiles/              Preset combinations (smart-sdd only)
│   │   └── foundations/           Framework checklists (reverse-spec only)
│   ├── reference/                 Pipeline mechanics — protocols and standards
│   │   └── injection/             Per-step context injection (smart-sdd only)
│   ├── templates/                 Artifact generation templates (reverse-spec only)
│   └── scripts/                   Status dashboard utilities (smart-sdd only)
```

**Key distinction**: `shared/` contains signal keywords used by both skills for module activation (single source of truth). `commands/` defines _what to execute_, `domains/` defines _what rules to apply_ (referencing shared/ for signal data), and `reference/` defines _how the pipeline works_.

### Root

| File | Description |
|------|-------------|
| `ARCHITECTURE-EXTENSIBILITY.md` | Detailed architecture extensibility guide (English) — module system, adding interfaces/concerns/archetypes/foundations, sophistication levels |
| `ARCHITECTURE-EXTENSIBILITY.ko.md` | Detailed architecture extensibility guide (Korean) |
| `CLAUDE.md` | Project rules for Claude Code agents (immutable rules, conventions, review protocol) |
| `README.md` | English documentation |
| `README.ko.md` | Korean documentation |
| `PLAYWRIGHT-GUIDE.md` | Playwright setup guide for browser automation and Electron CDP configuration |
| `history.md` | Design decision history extracted from git history |
| `lessons-learned.md` | AI agent pipeline failure patterns (G1–G19) and specific lessons (L1–L42) — universal takeaways for agent skill builders |
| `install.sh` | Installer — creates symlinks in `~/.claude/skills/` |
| `uninstall.sh` | Uninstaller — removes symlinks from `~/.claude/skills/` |
| `samples/code-explore-opencode/` | Sample code-explore artifacts — simulated opencode exploration (orientation, 3 traces, synthesis) for testing `--from-explore` handoff |

### code-explore (`.claude/skills/code-explore/`)

| File | Description |
|------|-------------|
| `SKILL.md` | Skill router — entry point and command routing for code-explore |
| `commands/orient.md` | Codebase orientation — scan and generate architecture map |
| `commands/trace.md` | End-to-end flow tracing — source-level call chain documentation |
| `commands/synthesis.md` | Trace aggregation — Feature candidates and spec-kit handoff |
| `commands/status.md` | Exploration coverage — trace index and readiness check |

### reverse-spec (`.claude/skills/reverse-spec/`)

| File | Description |
|------|-------------|
| `SKILL.md` | Skill router — entry point and mandatory rules for reverse-spec |
| `commands/analyze.md` | Multi-phase workflow for analyzing source code and generating Global Evolution Layer artifacts |
| **Domains** | |
| `domains/_core.md` | Universal analysis framework (R1–R7 analysis sections, including Foundation Detection Heuristics) |
| `domains/_schema.md` | Domain profile schema template (Detection Signals, Analysis Axes, Feature Registry, etc.) |
| `domains/app.md` | Application domain profile — detection and analysis behavior for backend/frontend/fullstack/mobile/library |
| `domains/data-science.md` | Data science domain profile — detection signals, project type classification, analysis axes, registries, tier classification |
| `domains/interfaces/gui.md` | GUI interface — R3 UI component extraction, R4 micro-interaction pattern extraction (hover, keyboard, animation, DnD, focus, context menu, scroll) |
| `domains/interfaces/http-api.md` | HTTP API interface — endpoint discovery, request/response analysis |
| `domains/interfaces/cli.md` | CLI interface — command parsing, argument analysis |
| `domains/interfaces/data-io.md` | Data I/O interface — pipeline discovery, data flow analysis |
| `domains/interfaces/tui.md` | TUI interface — terminal UI component extraction, PTY-based interaction analysis |
| `domains/concerns/async-state.md` | Async state concern — loading/streaming/error state detection |
| `domains/concerns/auth.md` | Authentication concern — auth flow detection |
| `domains/concerns/external-sdk.md` | External SDK concern — third-party API integration detection |
| `domains/concerns/i18n.md` | Internationalization concern — locale key detection |
| `domains/concerns/ipc.md` | IPC concern — inter-process communication detection (Electron/Tauri) |
| `domains/concerns/realtime.md` | Realtime concern — WebSocket/SSE detection |
| `domains/concerns/protocol-integration.md` | Protocol integration concern — LSP/MCP/custom protocol detection and lifecycle analysis |
| `domains/concerns/plugin-system.md` | Plugin system concern — plugin architecture, isolation, lifecycle detection |
| `domains/concerns/authorization.md` | Authorization concern — RBAC/ABAC/ACL permission model detection |
| `domains/concerns/message-queue.md` | Message queue concern — broker library detection (RabbitMQ, Kafka, BullMQ, Sidekiq, Celery), config and code pattern signals |
| `domains/concerns/task-worker.md` | Task worker concern — background job library detection (Celery, Sidekiq, BullMQ, Oban, Hangfire), scheduling pattern signals |
| `domains/concerns/polyglot.md` | Polyglot concern — multi-build-file detection, bridge directory patterns, generated stub co-location, R3 cross-language bridge extraction |
| `domains/concerns/codegen.md` | Codegen concern — generated marker scan, repetition analysis, generator config detection, R3 generated code extraction |
| `domains/concerns/multi-tenancy.md` | Multi-tenancy concern — tenant identification and query filtering detection |
| `domains/concerns/infra-as-code.md` | Infra-as-Code concern — IaC directory patterns, first-class infrastructure detection |
| `domains/concerns/llm-agents.md` | LLM agents concern — LLM SDK imports, prompt template detection, multi-agent coordination patterns |
| `domains/concerns/_TEMPLATE.md` | Contributor template for adding new reverse-spec concern modules (R1 detection signals) |
| **Archetypes** | |
| `domains/archetypes/ai-assistant.md` | AI assistant archetype — A0 signal keywords (LLM SDKs, streaming), A1 philosophy extraction (Streaming-First, Model Agnosticism, Token Awareness) |
| `domains/archetypes/public-api.md` | Public API archetype — A0 signal keywords (OpenAPI, rate limiting), A1 philosophy extraction (Contract Stability, Rate Limit Transparency) |
| `domains/archetypes/microservice.md` | Microservice archetype — A0 signal keywords (gRPC, Docker), A1 philosophy extraction (Service Autonomy, Failure Isolation) |
| `domains/archetypes/sdk-framework.md` | SDK/Framework archetype — A0 signal keywords (package metadata, public API), A1 philosophy extraction (API Surface, Extension Model, Consumer Patterns) |
| **Foundations** | |
| `domains/foundations/_foundation-core.md` | Foundation resolution protocol — detection signals, category taxonomy, case matrix, T0 grouping, cross-framework carry-over map |
| `domains/foundations/_TEMPLATE.md` | Contributor template for adding new Foundation files (F0-F9 structure) |
| `domains/foundations/electron.md` | Electron Foundation — 58 items, 13 categories (WIN, SEC, IPC, NAT, UPD, DLK, BLD, LOG, STR, ERR, DXP, BST, ENV) |
| `domains/foundations/tauri.md` | Tauri Foundation — 44 items, 12 categories |
| `domains/foundations/express.md` | Express.js Foundation — 43 items, 12 categories |
| `domains/foundations/nextjs.md` | Next.js Foundation — 44 items, 13 categories |
| `domains/foundations/vite-react.md` | Vite + React Foundation — 43 items, 12 categories |
| `domains/foundations/nestjs.md` | NestJS Foundation — F0 detection, 13 categories, F7 Modular Architecture/Decorator-Driven philosophy, F8 nest build/jest toolchain |
| `domains/foundations/fastapi.md` | FastAPI Foundation — F0 detection, 12 categories, F7 Type-Driven/Async-First philosophy, F8 pytest/ruff toolchain |
| `domains/foundations/react-native.md` | React Native Foundation — TODO scaffold (50 items, 14 categories) |
| `domains/foundations/flutter.md` | Flutter Foundation — TODO scaffold (50 items, 14 categories) |
| `domains/foundations/bun.md` | Bun Foundation — runtime/toolchain decisions, F7 philosophy, F8 toolchain commands, F9 scan targets |
| `domains/foundations/solidjs.md` | Solid.js Foundation — reactivity model decisions, F7 fine-grained reactivity philosophy |
| `domains/foundations/hono.md` | Hono Foundation — web framework decisions, F7 philosophy, F8 toolchain, F9 scan targets |
| `domains/foundations/spring-boot.md` | Spring Boot Foundation — F0 detection, 13 categories (35+ items), F7 Convention over Configuration philosophy, F8 Maven/Gradle toolchain |
| `domains/foundations/django.md` | Django Foundation — F0 detection, 12 categories, F7 Batteries Included philosophy, F8 pytest/collectstatic toolchain |
| `domains/foundations/rails.md` | Rails Foundation — F0 detection, 13 categories, F7 Convention over Configuration/Rails Doctrine philosophy, F8 rspec/rubocop toolchain |
| `domains/foundations/flask.md` | Flask Foundation — F0 detection, 12 categories, F7 Micro-Framework/Extension Ecosystem philosophy, F8 pytest toolchain |
| `domains/foundations/actix-web.md` | Actix Web Foundation — F0 detection, 12 categories, F7 Type-Safe Extractors/Zero-Cost Abstractions philosophy, F8 cargo toolchain |
| `domains/foundations/go-chi.md` | Go Chi/Gin Foundation — F0 detection, 12 categories, F7 Simplicity/Explicit Error Handling philosophy, F8 go build/golangci-lint toolchain |
| `domains/foundations/dotnet.md` | ASP.NET Core Foundation — F0 detection, 13 categories, F7 DI First/Middleware Pipeline philosophy, F8 dotnet build/test toolchain |
| `domains/foundations/laravel.md` | Laravel Foundation — F0 detection, 13 categories, F7 Elegant Syntax/Service Container philosophy, F8 artisan/phpstan toolchain |
| `domains/foundations/phoenix.md` | Phoenix Foundation — F0 detection, 12 categories, F7 Let It Crash/Functional Core philosophy, F8 mix compile/credo toolchain |
| `reference/speckit-compatibility.md` | Compatibility guide mapping reverse-spec outputs to spec-kit commands |
| **Templates** | |
| `templates/roadmap-template.md` | Template for project roadmap artifact |
| `templates/constitution-seed-template.md` | Template for initial constitution document |
| `templates/entity-registry-template.md` | Template for data entity registry |
| `templates/api-registry-template.md` | Template for API endpoint registry |
| `templates/business-logic-map-template.md` | Template for business rules documentation |
| `templates/stack-migration-template.md` | Template for stack migration plan (rebuild + new stack) |
| `templates/coverage-baseline-template.md` | Template for source coverage metrics baseline |
| `templates/pre-context-template.md` | Template for per-Feature context extracted from runtime exploration |
| `templates/speckit-prompt-template.md` | Standalone prompt template for using spec-kit without smart-sdd |

### smart-sdd (`.claude/skills/smart-sdd/`)

| File | Description |
|------|-------------|
| **SKILL.md** | **Skill router — entry point, mandatory rules, command routing table** |
| **Commands** | |
| `commands/add.md` | 6-phase Feature definition process (document / conversational / gap-driven) |
| `commands/adopt.md` | SDD adoption pipeline — wrap existing code with documentation without rewriting |
| `commands/coverage.md` | SBI coverage checker — identify unmapped behaviors and resolve gaps |
| `commands/expand.md` | Tier expansion — activate deferred Feature tiers for core-scope projects |
| `commands/init.md` | Greenfield project initialization — project identity and development principles |
| `commands/parity.md` | Source parity checker — compare original code vs implemented Features |
| `commands/pipeline.md` | Pipeline executor — Common Protocol (Assemble → Checkpoint → Execute+Review → Update) |
| `commands/reset.md` | Pipeline state reset — restore clean environment preserving reverse-spec artifacts |
| `commands/status.md` | Status display — project progress from sdd-state.md |
| `commands/verify-phases.md` | Verify hub — common gates (Bug Fix Severity, Source Modification Gate) + phase routing |
| `commands/verify-preflight.md` | Phase 0: Runtime environment readiness (Playwright backend detection) |
| `commands/verify-build-test.md` | Phase 1: Build/Test/Lint execution verification (BLOCKING) |
| `commands/verify-cross-feature.md` | Phase 2: Cross-Feature consistency + behavior completeness |
| `commands/verify-sc-verification.md` | Phase 3: SC verification planning + runtime execution orchestration |
| `commands/verify-sc-rebuild.md` | Phase 3 rebuild-only: Visual fidelity + source app comparison |
| `commands/verify-evidence-update.md` | SC Evidence Gate + Phase 4 (registry update) + Phase 5 (integration demo) |
| **Domains** | |
| `domains/_core.md` | Universal rules (S1–S7) — demo-ready delivery, bug prevention index, conditional rules |
| `domains/_resolver.md` | Profile resolution protocol — profile expansion, backward compatibility, module loading order |
| `domains/_schema.md` | Domain profile schema — demo patterns, parity dimensions, verification behavior |
| `domains/app.md` | Application domain profile — demo patterns, lint detection rules, UI testing, bug prevention |
| `domains/data-science.md` | Data science domain profile — demo patterns (3 project types), parity dimensions, verify steps |
| `domains/interfaces/gui.md` | GUI interface — CSS rendering bugs, UI interaction surface audit, visual fidelity, micro-interaction verification |
| `domains/interfaces/http-api.md` | HTTP API interface — API compatibility matrix, runtime verification |
| `domains/interfaces/cli.md` | CLI interface — CLI verification, process-runner backend |
| `domains/interfaces/data-io.md` | Data I/O interface — pipeline verification, data flow testing |
| `domains/interfaces/tui.md` | TUI interface — terminal UI SC generation, PTY-based runtime verification, bug prevention (TUI-001–006) |
| `domains/concerns/async-state.md` | Async state — loading/streaming patterns, UX behavior contract |
| `domains/concerns/auth.md` | Authentication — auth flow patterns, session management |
| `domains/concerns/external-sdk.md` | External SDK — type trust classification, API contract gap detection |
| `domains/concerns/i18n.md` | Internationalization — completeness check, locale key coverage |
| `domains/concerns/ipc.md` | IPC — boundary safety, return value defense (Electron/Tauri) |
| `domains/concerns/realtime.md` | Realtime — WebSocket/SSE connection management |
| `domains/concerns/protocol-integration.md` | Protocol integration — LSP/MCP/custom protocol SC generation, capability negotiation verification |
| `domains/concerns/plugin-system.md` | Plugin system — plugin lifecycle SC generation, isolation guarantees, API contract verification |
| `domains/concerns/authorization.md` | Authorization — RBAC/ABAC/ACL SC generation, permission boundary verification |
| `domains/concerns/message-queue.md` | Message queue — publish/consume lifecycle SC, dead letter handling, idempotency, bug prevention (MQ-001–005) |
| `domains/concerns/task-worker.md` | Task worker — dispatch/execution lifecycle SC, failure handling, scheduling, bug prevention (TW-001–005) |
| `domains/concerns/polyglot.md` | Polyglot — cross-language bridge SC, type mapping, build orchestration, bug prevention (PLY-001–005) |
| `domains/concerns/codegen.md` | Codegen — generated code integrity SC, source-of-truth tracking, Feature boundary rules, bug prevention (CGN-001–005) |
| `domains/concerns/multi-tenancy.md` | Multi-tenancy — tenant isolation SC, context propagation, cache isolation, bug prevention (MTN-001–005) |
| `domains/concerns/infra-as-code.md` | Infra-as-Code — IaC validity SC, app-infra sync, secret management, bug prevention (IAC-001–005) |
| `domains/concerns/llm-agents.md` | LLM agents — non-deterministic output handling SC, multi-agent coordination, prompt versioning, token budget enforcement, bug prevention (LLM-001–005) |
| `domains/concerns/_TEMPLATE.md` | Contributor template for adding new smart-sdd concern modules (S0/S1/S5/S7 structure) |
| `domains/archetypes/ai-assistant.md` | AI assistant archetype — A0–A4: signal keywords, philosophy (Streaming-First, Model Agnosticism), SC extensions, probes, constitution injection |
| `domains/archetypes/public-api.md` | Public API archetype — A0–A4: signal keywords, philosophy (Contract Stability, Rate Limit Transparency), SC extensions, probes, constitution injection |
| `domains/archetypes/microservice.md` | Microservice archetype — A0–A4: signal keywords, philosophy (Service Autonomy, Failure Isolation), SC extensions, probes, constitution injection |
| `domains/archetypes/sdk-framework.md` | SDK/Framework archetype — A0–A4: API Stability, Extension-First Design, Example-as-Contract, Documentation Parity, Backward Compatibility |
| `domains/profiles/fullstack-web.md` | Preset: [http-api, gui] + [async-state, auth, i18n] |
| `domains/profiles/web-api.md` | Preset: [http-api] + [auth] |
| `domains/profiles/desktop-app.md` | Preset: [gui] + [async-state, ipc] |
| `domains/profiles/cli-tool.md` | Preset: [cli] |
| `domains/profiles/ml-platform.md` | Preset: [http-api, cli, data-io] + [plugin-system, auth] |
| `domains/profiles/sdk-library.md` | Preset: [cli] + [plugin-system] + archetype: sdk-framework |
| `domains/scenarios/greenfield.md` | New project — no existing code, full pipeline from scratch |
| `domains/scenarios/rebuild.md` | Rebuild — preservation_level, change_scope, migration_strategy parameters |
| `domains/scenarios/incremental.md` | Incremental — add Features to existing SDD project |
| `domains/scenarios/adoption.md` | Adoption — wrap existing code with SDD documentation |
| **Reference** | |
| `reference/branch-management.md` | Git branch workflow — Feature isolation and merge validation |
| `reference/clarity-index.md` | Cross-reference clarity metrics and signal extraction |
| `reference/context-injection-rules.md` | Shared patterns — HARD STOP checkpoints, missing content handling, output suppression |
| `reference/demo-standard.md` | Demo-ready delivery standard — script requirements, VERIFY_STEPS format, 3-tier UI actions |
| `reference/feature-elaboration-framework.md` | 6-perspective Feature evaluation framework for gap identification |
| `reference/restructure-guide.md` | Feature restructure checklist (split, merge, move, reorder, delete) |
| `reference/runtime-verification.md` | Runtime verification backend registry — Playwright CLI/MCP detection, backend classification |
| `reference/state-schema.md` | `sdd-state.md` schema — Feature status, Toolchain, Demo Groups, Special Flags |
| `reference/ui-flow-spec.md` | UI Flow Specification format — step-by-step interaction sequences for GUI Features |
| `reference/ui-testing-integration.md` | Playwright MCP integration guide for UI verification |
| `reference/user-cooperation-protocol.md` | User assistance patterns for HARD STOP interactions |
| `reference/pipeline-integrity-guards.md` | 7 generalized guard patterns from 44 SKF field failures — extensible pipeline protection system |
| **Context Injection** | |
| `reference/injection/adopt-plan.md` | Adopt plan step — document existing architecture as-is |
| `reference/injection/adopt-specify.md` | Adopt specify step — SDD documentation wrapping of existing code |
| `reference/injection/adopt-verify.md` | Adopt verify step — test failures as non-blocking pre-existing issues |
| `reference/injection/analyze.md` | Analyze step — cross-artifact consistency verification before implement |
| `reference/injection/constitution.md` | Constitution step — system principles and architectural decisions |
| `reference/injection/implement.md` | Implement step — source injection, runtime verification, auto-fix loop, CSS value map |
| `reference/injection/parity.md` | Parity command — multi-phase workflow for source comparison |
| `reference/injection/plan.md` | Plan step — interaction chains, UX behavior contract, API compatibility matrix |
| `reference/injection/specify.md` | Specify + clarify steps — requirements, SBI cross-check, edge case coverage |
| `reference/injection/tasks.md` | Tasks step — 10 injection checks (demo, pattern audit, interaction chain, etc.) |
| `reference/injection/verify.md` | Verify step — checkpoint/review display, pipeline regression handling |
| **Scripts** | |
| `scripts/context-summary.sh` | Dashboard — Feature/Entity/API/DemoGroup summary |
| `scripts/demo-status.sh` | Dashboard — demo group progress |
| `scripts/pipeline-status.sh` | Dashboard — pipeline progress overview |
| `scripts/sbi-coverage.sh` | Dashboard — SBI coverage mapping |
| `scripts/validate.sh` | Cross-file consistency validator (exit code indicates pass/fail) |
| `scripts/semantic-stub-check.sh` | Semantic stub detector — finds Math.random(), placeholder text, hardcoded fallbacks in implementation |
| `scripts/wiring-check.sh` | Wiring integrity checker — IPC/API registration audit, parameter shape cross-check, orphan handler detection |

### shared (`.claude/skills/shared/`)

Signal keywords and module metadata shared by both reverse-spec and smart-sdd. Each module file merges S0 (semantic keywords for init inference) and R1/A0 (code patterns for source analysis) into a single source of truth.

| File | Description |
|------|-------------|
| `domains/_taxonomy.md` | Module registry — complete list of all interfaces, concerns, archetypes with metadata |
| `domains/_TEMPLATE.md` | Contributor template for adding new shared module files |
| **Interfaces** | |
| `domains/interfaces/gui.md` | GUI — S0 keywords (React, Vue, Electron, ...) |
| `domains/interfaces/http-api.md` | HTTP API — S0 keywords (REST, GraphQL, Express, ...) + R1 generic |
| `domains/interfaces/cli.md` | CLI — S0 keywords (CLI, Commander, yargs, ...) + R1 (bin/, CLI frameworks) |
| `domains/interfaces/data-io.md` | Data I/O — S0 keywords (ETL, Airflow, ...) + R1 (pipeline frameworks) |
| `domains/interfaces/tui.md` | TUI — S0 keywords (Ink, bubbletea, ...) + R1 (TUI framework imports) |
| **Concerns** | |
| `domains/concerns/async-state.md` | Async state — S0 + R1 (Zustand, Redux, MobX, store patterns) |
| `domains/concerns/auth.md` | Auth — S0 + R1 (passport, next-auth, JWT patterns) |
| `domains/concerns/authorization.md` | Authorization — S0 + R1 (RBAC, ABAC, ACL, permission checks) |
| `domains/concerns/external-sdk.md` | External SDK — S0 + R1 (AI SDKs, payment SDKs, cloud SDKs) |
| `domains/concerns/i18n.md` | i18n — S0 + R1 (i18next, locale files, translation patterns) |
| `domains/concerns/ipc.md` | IPC — S0 + R1 (Electron IPC, Web Workers, child_process) |
| `domains/concerns/message-queue.md` | Message queue — S0 + R1 (RabbitMQ, Kafka, BullMQ, broker patterns) |
| `domains/concerns/plugin-system.md` | Plugin system — S0 + R1 (dynamic import, extension points, isolation) |
| `domains/concerns/protocol-integration.md` | Protocol — S0 + R1 (LSP, MCP, JSON-RPC, capability negotiation) |
| `domains/concerns/realtime.md` | Realtime — S0 + R1 (Socket.io, WebSocket, SSE) |
| `domains/concerns/task-worker.md` | Task worker — S0 + R1 (Celery, Sidekiq, BullMQ, cron patterns) |
| `domains/concerns/polyglot.md` | Polyglot — S0 + R1 (FFI bridges, Protobuf, WASM, multi-build-file coexistence) |
| `domains/concerns/codegen.md` | Codegen — S0 + R1 (generated markers, template files, generator configs, repetitive file groups) |
| `domains/concerns/multi-tenancy.md` | Multi-tenancy — S0 + R1 (tenant_id patterns, RLS policies, tenant middleware) |
| `domains/concerns/infra-as-code.md` | Infra-as-Code — S0 + R1 (Terraform, Helm, K8s manifests, Docker Compose, CI/CD, operators) |
| `domains/concerns/llm-agents.md` | LLM agents — S0 + R1 (LLM SDKs, prompt templates, agent frameworks, multi-agent patterns) |
| **Archetypes** | |
| `domains/archetypes/ai-assistant.md` | AI assistant — A0 semantic + code patterns (LLM SDKs, streaming, RAG) |
| `domains/archetypes/public-api.md` | Public API — A0 semantic + code patterns (OpenAPI, rate limiting, versioning) |
| `domains/archetypes/microservice.md` | Microservice — A0 semantic + code patterns (gRPC, service mesh, Docker) |
| `domains/archetypes/sdk-framework.md` | SDK/Framework — A0 semantic + code patterns (package metadata, public API, extension points, examples) |

