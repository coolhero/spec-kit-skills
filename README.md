# spec-kit-skills

**Repository**: [coolhero/spec-kit-skills](https://github.com/coolhero/spec-kit-skills)

[한국어 README](README.ko.md) | [Playwright Setup Guide](PLAYWRIGHT-GUIDE.md) | [Lessons Learned](lessons-learned.md) | Last updated: 2026-03-17 07:57 KST

**Claude Code skills that make [spec-kit](https://github.com/github/spec-kit) work across Features — so Feature 3 knows what Feature 1 already decided**

- **Reverse-Spec** analyzes an existing codebase and extracts everything the SDD pipeline needs to know: what the app does, how it's structured, what data models and APIs exist. Use it when you want to rebuild an existing app from scratch, or when you want to add SDD documentation to code you already have. Also generates a standalone prompt (`speckit-prompt.md`) for using spec-kit without smart-sdd.
- **Smart-SDD** wraps each spec-kit command with project-wide awareness. When you run `/speckit-plan` for Feature 3, it automatically feeds in Feature 1's data models and Feature 2's API contracts — so the plan is grounded in what actually exists, not assumptions.
- **Case Study** generates a structured after-action report from a completed project — what went well, what was hard, and what the numbers say. It collects the metrics that accumulated during the pipeline (how many Features, how tests went, how close the rebuild matched the original) and pairs them with the story of *why* things were built the way they were. The report also feeds back into improving the domain modules for next time.

---

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI
- [spec-kit](https://github.com/github/spec-kit) skill (for `/smart-sdd`)
- [Playwright](https://playwright.dev) — `npm install -D @playwright/test && npx playwright install` (primary). Optional: [Playwright MCP](https://github.com/microsoft/playwright-mcp) for interactive acceleration — see [Playwright Setup Guide](PLAYWRIGHT-GUIDE.md)

### Installation

```bash
git clone https://github.com/coolhero/spec-kit-skills.git
cd spec-kit-skills
./install.sh      # creates symlinks → ~/.claude/skills/
# ./uninstall.sh  # removes symlinks (to uninstall)
```

### First Commands

| Your situation | Command | What happens |
|------|---------|------|
| **Starting from scratch** | `/smart-sdd init` | Set up a new project, define Features, run the pipeline |
| **Have existing code, want to rebuild it** | `/reverse-spec ./path/to/source` | Analyze the code → rebuild with SDD |
| **Have existing code, want to keep it** | `/reverse-spec --adopt` → `/smart-sdd adopt` | Wrap existing code with SDD docs, no rewrite |
| **Already running smart-sdd, need more Features** | `/smart-sdd add` | Add new Features to an existing project |
| **Want an after-action report** | `/case-study generate` | Generate metrics and lessons from completed project |

### Verify

```
/reverse-spec --help
/smart-sdd status
```

---

## What It Solves

AI coding agents write great code — until the project gets big enough. Then things start falling apart: code written last week contradicts code written today, bugs you already fixed come back, and you spend more time correcting the agent than building.

This is a **harness engineering** problem. Like harnessing a horse, the goal isn't to limit the agent's power but to make it directed and reliable. [spec-kit](https://github.com/github/spec-kit) provides the first layer of harness through Specification-Driven Development: break the project into Features, write specs for each one, then code against them. The agent gets a clear target and a structured pipeline (specify → plan → implement → verify) instead of winging it.

But spec-kit processes **one Feature at a time** — it has no mechanism for tracking shared entities, API contracts, or dependencies across Features. When you run `/speckit-plan` for Feature 3, it doesn't know what data models Feature 1 defined or what APIs Feature 2 expects.

**spec-kit-skills** strengthens the harness by adding a **Global Evolution Layer** — project-wide artifacts that sit above spec-kit's per-Feature scope:

| Artifact | What it tracks |
|----------|---------------|
| **Roadmap** | Feature dependency graph with execution ordering |
| **Entity Registry** | Shared data models referenced across Features |
| **API Registry** | Inter-Feature API contracts and endpoints |
| **Per-Feature Pre-contexts** | What each Feature needs to know about the rest of the project |
| **Source Behavior Inventory** | Function-level coverage tracking (for existing codebases) |
| **Constitution** | Project-wide principles and architectural decisions |

---

## Skills

### `/reverse-spec` — Existing Source → SDD-Ready Artifacts

Reads your existing source code and produces the foundation that SDD needs: Feature decomposition, entity/API registries, per-Feature pre-contexts, and source coverage baseline.

```bash
/reverse-spec [target-directory] [--scope core|full] [--stack same|new] [--name new-project-name]
```

**Workflow**: Phase 0 (strategy) → Phase 1 (project scan) → Phase 1.5 (runtime exploration via Playwright) → Phase 2 (deep analysis) → Phase 3 (Feature classification) → Phase 4 (artifact generation)

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

### Utility

| Skill | Purpose |
|-------|---------|
| `/case-study` | Generates an after-action report from a completed project — metrics, decisions, and what to improve next time |

> **What the report covers**: The case study isn't just numbers — it tells the story of the project. For each major architectural decision ("Why did we use an abstraction layer for AI providers?"), it traces back to the principle that motivated it ("Model Agnosticism from the AI Assistant archetype"). It also spots gaps — principles you declared but never actually applied. This feedback helps refine domain modules so the next project starts smarter.

### How the Skills Connect

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        The Big Picture                                  │
│                                                                         │
│  1. ANALYZE    /reverse-spec analyzes your code (or /smart-sdd init     │
│                creates from scratch)                                    │
│                         │                                               │
│                         ▼                                               │
│  2. ARTIFACTS  Global Evolution Layer is created:                       │
│                roadmap, entity/API registries, pre-contexts             │
│                         │                                               │
│                         ▼                                               │
│  3. BUILD      /smart-sdd pipeline runs spec-kit for each Feature,      │
│                automatically injecting cross-Feature context            │
│                         │                                               │
│                   ┌─────┴─────┐                                         │
│                   ▼           ▼                                         │
│  4. PER FEATURE  specify → plan → tasks → implement → verify → merge    │
│                  Each step gets context from previous Features          │
│                  Each step has human checkpoints (HARD STOP)            │
│                         │                                               │
│                         ▼                                               │
│  5. REPORT     /case-study generates after-action report (optional)     │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Architecture

Beyond connecting Features, spec-kit-skills strengthens the harness in three ways — keeping the agent's memory alive across Features, making verification gates that can't be skipped, and checking that the software doesn't just have the right structure but actually *behaves* correctly:

| Pillar | What It Does | Without It |
|--------|-------------|------------|
| **Context Injection** | Feeds each step the knowledge it needs — what other Features decided, how the existing app works, what rules apply | Agent works from incomplete information, re-invents what was already decided |
| **Gate Enforcement** | Checkpoints that stop the pipeline when output doesn't meet criteria — not "should check" but "cannot proceed" | Agent skips verification, wrong assumptions propagate uncaught |
| **Behavioral Fidelity** | Captures not just *what* to build but *how it should work* — how users interact, how data flows, how the app responds | Agent builds something that looks right but works wrong |

These pillars are implemented through 7 Pipeline Integrity Guards — protection patterns extracted from real-world failures. Each guard covers a class of problems with clear trigger conditions and enforcement rules. When new failures are discovered, they extend existing guards rather than pile up as one-off fixes. See [`pipeline-integrity-guards.md`](.claude/skills/smart-sdd/reference/pipeline-integrity-guards.md).

### Design Philosophy

Five principles shape every design decision in spec-kit-skills:

1. **Define what "done" means, upfront** — Instead of hoping the agent writes correct code, every Feature has explicit success criteria and contracts. Verification checks against these criteria — not against a vague feeling of "looks right."

2. **Give each step the context it needs** — An agent working on Feature 3 has no memory of what it decided for Feature 1. So before each step, the system automatically feeds in the relevant data models, API contracts, and project rules. The agent sees exactly what it needs — no more, no less.

3. **Load only relevant rules** — A REST API project doesn't need GUI testing rules. An AI chat app doesn't need CRUD validation rules. The system auto-detects your project type and loads only the modules that apply — keeping the agent focused and the context window lean.

4. **Humans approve before anything is final** — The agent runs autonomously through research, planning, and coding. But before specs are created and before code is accepted, you review and approve. The agent does the work; you make the decisions.

5. **Start broad, drill deep** — Analysis begins with tech stack and project structure, then progressively zooms into function signatures, UI components, micro-interactions, and edge cases. Each level builds on the one above, so nothing is analyzed out of context.

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

Each Feature goes through a **6-step lifecycle**. If verify finds bugs, they loop back to the right step instead of being patched silently:

```
specify → plan → tasks → implement → verify → merge
   │                                    │
   │  ◄──── Major-Spec ─────────────────┤
   │  ◄──── Major-Plan ─────────────────┤
   │  ◄──── Major-Implement ────────────┤
   │                                    │
   └── Minor Fix (inline, ≤2 files) ────┘
```

Verify discovers bugs and classifies them into 4 severity levels. Only Minor issues are fixed inline; Major issues loop back to the appropriate pipeline step.

### Project Modes

Choose the mode that matches your situation:

| Mode | Entry Point | Use Case |
|------|-------------|----------|
| Greenfield | `/smart-sdd init` → `add` → `pipeline` | New project from scratch |
| Incremental | `/smart-sdd add` → `pipeline` | Add features to existing smart-sdd project |
| Rebuild | `/reverse-spec` → `/smart-sdd pipeline` | Rebuild existing codebase with SDD |
| Adoption | `/reverse-spec --adopt` → `/smart-sdd adopt` | Wrap existing code with SDD docs |

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
| Roadmap | `specs/reverse-spec/roadmap.md` | Feature catalog, dependency graph, release groups |
| Entity Registry | `specs/reverse-spec/entity-registry.md` | Shared data model definitions |
| API Registry | `specs/reverse-spec/api-registry.md` | API contract specifications |
| Business Logic Map | `specs/reverse-spec/business-logic-map.md` | Cross-Feature business rules |
| Pre-context | `specs/reverse-spec/features/F00N-*/pre-context.md` | Per-Feature context for spec-kit |
| Constitution | `.specify/memory/constitution.md` | Project-wide principles & best practices |
| State | `specs/reverse-spec/sdd-state.md` | Pipeline progress, toolchain, Foundation decisions |

### How Rules Are Selected for Your Project

Different projects need different rules. A REST API needs status code checks; a desktop app needs window management safety; a rebuild needs to match the original; an AI app needs streaming-first design. Instead of loading every rule for every project, the system picks what's relevant based on **four questions about your project**:

```
Interface                    Concern                      Archetype                    Scenario
(what the app exposes)       (cross-cutting patterns)     (domain philosophy)          (why we're building)
├── http-api                 ├── async-state              ├── ai-assistant             ├── greenfield
├── gui                      ├── auth                     ├── public-api               ├── rebuild
├── cli                      ├── authorization            ├── microservice             ├── incremental
├── data-io                  ├── codegen                  └── sdk-framework            └── adoption
└── tui                      ├── external-sdk
                             ├── i18n
                             ├── infra-as-code
                             ├── ipc
                             ├── message-queue
                             ├── multi-tenancy
                             ├── plugin-system
                             ├── polyglot
                             ├── protocol-integration
                             ├── realtime
                             └── task-worker
```

Each axis answers a different question:
- **Interface**: _What surface_ does the app expose? (HTTP endpoints, GUI windows, CLI commands)
- **Concern**: _What internal patterns_ cut across Features? (Auth flows, state management, IPC)
- **Archetype**: _What domain philosophy_ guides architectural decisions? (Streaming-first for AI, contract stability for public APIs)
- **Scenario**: _Why_ is this project being built? (New from scratch, rebuilding existing, adopting existing code)

A **Domain Profile** = selected Interfaces + selected Concerns + Archetype + Scenario. For example: `desktop-app + [gui] + [async-state, ipc] + ai-assistant + rebuild`. The agent loads only modules relevant to the project — an API-only project never sees GUI testing rules, an AI project gets streaming verification that a CRUD app doesn't need.

**How auto-detection works**: Each module declares **S0 Signal Keywords** (interfaces/concerns) or **A0 Signal Keywords** (archetypes). When you start a project with an idea string (`init "Build an AI chat assistant with..."`), the agent scans all keywords to infer your profile automatically. "React" triggers `gui`, "REST API" triggers `http-api`, "OpenAI" triggers both `external-sdk` concern and `ai-assistant` archetype — all without manual configuration.

This inference is scored by the **Clarity Index (CI)** — a percentage measuring how concrete your idea is across 7 dimensions (purpose, capabilities, type, stack, users, scale, constraints). High CI (70%+) skips clarification and generates a Proposal directly; low CI triggers targeted questions using the active modules' S5 Elaboration Probes. The generated Proposal can be modified per-section before approval — change the tech stack without re-answering purpose questions, or adjust Features without affecting the architecture. CI propagates into the pipeline — lower initial CI means more verification checkpoints during specify and plan, ensuring vague ideas don't produce incomplete specs. See `reference/clarity-index.md` for the full model.

**How composition drives the pipeline**: Modules don't produce an output file — they merge into a behavioral ruleset in the agent's working memory. Each section routes to a specific pipeline step: `S1` shapes `specify` (SC generation), `S5` shapes `clarify` (consultation probes), `S7` shapes `plan`/`implement`/`verify` (bug prevention), `S3` shapes `verify` (verification gates), and `A1`/`A4`/`F7` shape `constitution` (domain principles). For a complete walkthrough with concrete before/after examples, see [ARCHITECTURE-EXTENSIBILITY.md § 2b](ARCHITECTURE-EXTENSIBILITY.md#2b-how-composed-modules-drive-the-pipeline).

**Module loading order**: `_core.md` (always) → each active Interface → each active Concern → each active Archetype → Scenario → user custom (`domain-custom.md`).

> **Why Archetype?** The original 3-Axis model covered _what_ the app exposes (Interface), _how_ it handles cross-cutting patterns (Concern), and _why_ it's being built (Scenario). But it lacked structured guidance for **domain-specific philosophy** — principles like "Streaming-First" for AI apps or "Contract Stability" for public APIs were generated ad-hoc. Archetype modules make these principles **structured, reusable, and extensible**.

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
   └── Custom (project-specific overrides)
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

### Extensibility & Customization

The system is designed so you can start with defaults and progressively customize:

**Level 0 — Out of the box**: Run `/smart-sdd init` or `/reverse-spec` with no customization. The agent auto-detects your profile, framework, interfaces, and concerns. Works for most projects immediately.

**Level 1 — Domain profile tuning**: Edit `sdd-state.md` to add/remove active Interfaces and Concerns. Loading `auth` adds authentication-specific SC rules; removing `i18n` skips internationalization checks.

**Level 2 — Project-specific rules**: Create `specs/reverse-spec/domain-custom.md` in your project. Add rules using the same S1/S5/S7 schema (e.g., "all payment endpoints require idempotency SC", "dark mode must be tested in verify"). This file loads last with highest priority — no skill files modified.

**Level 3 — New domain modules**: Create custom Interface or Concern files (e.g., `domains/interfaces/grpc.md`, `domains/concerns/caching.md`). Follow `domains/_schema.md` for the module format. Your modules compose automatically with built-in ones.

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
1. Create `specs/reverse-spec/domain-custom.md` in your project directory
2. Add project-specific rules using the same S1/S5/S7 schema (e.g., "payment endpoints require idempotency SC")
3. This file loads last with highest priority, extending all other modules

**Adapt to your workflow** — every checkpoint and gate can be tuned:
- **Scope**: `core` scope activates T1 only (fastest path); `full` processes everything
- **Preservation**: `equivalent` requires behavioral parity; `similar` allows cosmetic differences
- **Pipeline steps**: Skip specific spec-kit steps via sdd-state.md flags
- **Severity thresholds**: Adjust which verify bugs loop back vs fix inline via `domain-custom.md`

For detailed step-by-step extension guides and the 5-level sophistication model, see [ARCHITECTURE-EXTENSIBILITY.md](ARCHITECTURE-EXTENSIBILITY.md). See also `domains/_schema.md` for the module schema, `domains/_resolver.md` for the full loading protocol, and `reference/runtime-verification.md` for the multi-backend runtime verification architecture.

### Session Resilience & Agent Governance

Long pipeline sessions face two systemic risks: **context window loss** (agent forgets progress mid-session) and **uncontrolled edits** (agent patches code without classification). The system addresses both:

**Compaction-Resilient State** — Verify progress, process rules, and minor fix accumulators are written to `sdd-state.md` at every phase boundary. When the context window compacts mid-verify, the Resumption Protocol reads the persisted state and resumes from the exact phase — no repeated work, no lost classifications. This makes multi-hour pipeline sessions survivable.

**Source Modification Gate** — During verify, every source edit must be classified (Minor / Major-Implement / Major-Plan / Major-Spec) *before* any code is touched. The classification determines whether the fix happens inline or routes back to the correct pipeline stage. A Minor Fix Accumulator tracks inline fixes per Feature — if the count reaches 3, the system auto-escalates to Major, preventing structural drift disguised as minor patches.

**Pipeline Integrity Guards** — The 7 guards introduced in the [Harness Engineering](#what-is-harness-engineering) section above are the concrete implementation of the three pillars. Each guard covers a specific failure class: G1 Guideline→Gate escalation, G2 Static≠Runtime 5-level verification, G3 Cross-Stage Trust Breakers, G4 Granularity Alignment, G5 Environment Parity (dual-mode), G6 Cross-Feature Interface verification, G7 Rebuild Fidelity Chain (Component Tree + Data Lifecycle → Source Mapping → Source-First gates). New failures extend existing guards rather than accumulate as ad-hoc rules.

**Context Window Management** — Skill files are decomposed into lazy-loaded units: `SKILL.md` (always loaded, ~60 lines) routes to `commands/{cmd}.md` (loaded per command), which references `injection/{cmd}.md` (loaded per pipeline step) and `domains/{module}.md` (loaded per project profile). A desktop Electron rebuild loads ~3,200 tokens of domain rules; a CLI greenfield loads ~800. Unused modules never enter the context.

**Context Budget Protocol** — When assembled injection context for a pipeline step approaches the context window limit, sections are triaged via a 3-tier priority system: **P1** (must-inject — spec.md, tasks.md, Pattern Constraints), **P2** (summarizable to ≤30% — business-logic-map, referenced entities, preceding Feature results), **P3** (skip-safe — naming remapping, CSS value map, visual references). The overflow protocol: Summarize P2 → Skip P3 → Split (reduce parallel task batches). Each Checkpoint displays a budget indicator so the user sees what context was trimmed.

---

## User Journeys

```
── From an Idea (Proposal Mode) ──────────────────────────────────
/smart-sdd init "Build a Chrome extension that summarizes web pages using AI"
→ Signal Extraction → Clarity Index scoring → Proposal (1 approval)
→ auto-chains to constitution + add + pipeline

── New Project (Standard) ────────────────────────────────────────
/smart-sdd init  →  /smart-sdd add  →  /smart-sdd pipeline
(project setup)     (define Features)   (implement)

── SDD Adoption ──────────────────────────────────────────────────
/reverse-spec --adopt  →  Global Evolution Layer  →  /smart-sdd adopt
                           (roadmap, registries)      (document existing)

── Rebuild ───────────────────────────────────────────────────────
/reverse-spec  →  Global Evolution Layer  →  /smart-sdd pipeline
(analyze code)    (roadmap, registries)      (rebuild code)

── Incremental ───────────────────────────────────────────────────
/smart-sdd add  →  updated Global Evolution  →  /smart-sdd pipeline
```

All journeys converge to **incremental mode** as the steady state.

---

## Quick Examples

**Rebuild an existing app**:
```
/reverse-spec ./legacy-app --scope core --stack new
/smart-sdd pipeline
```

**Greenfield project**:
```
/smart-sdd init
/smart-sdd add        # define Features interactively
/smart-sdd pipeline   # specify → plan → tasks → implement → verify
```

**Add a Feature to an existing project**:
```
/smart-sdd add        # "I need real-time notifications"
/smart-sdd pipeline   # processes only new/pending Features
```

---

## Detailed Reference

### How It Works — Common Protocol

All spec-kit command executions follow this 4-step protocol:

```
+--------------+     +---------------+     +------------------------+     +--------------+
|  1. Assemble |---->| 2. Checkpoint |---->|  3. Execute + Review   |---->|  4. Update   |
|  Context     |     |  Pre-Exec     |     | spec-kit Execution +   |     | Global       |
|  Assembly    |     |  Confirmation |     | Artifact Review        |     | Refresh      |
+--------------+     +---------------+     +------------------------+     +--------------+
```

| Step | Description |
|------|------------|
| **Assemble** | Reads files/sections required for the given command from `specs/reverse-spec/`, filters and assembles per command-specific injection rules. If a source file is missing or contains only placeholder text, that source is gracefully skipped |
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

### Phase 1.5 — Runtime Exploration (Optional)

Run the original application and explore it interactively via Playwright (CLI primary, MCP optional) before deep code analysis. Provides visual and behavioral context (UI layout, user flows, actual states). For Electron apps, CLI uses `_electron.launch()` (no CDP needed) — see [Playwright Setup Guide](PLAYWRIGHT-GUIDE.md).

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

### Phase 4 — Artifact Generation

Generates: `roadmap.md`, `constitution-seed.md`, `entity-registry.md`, `api-registry.md`, `business-logic-map.md`, per-Feature `pre-context.md` files.

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

1. Run `/reverse-spec` on your codebase — generates artifacts in `specs/reverse-spec/`
2. Copy `specs/reverse-spec/speckit-prompt.md` into your project's `CLAUDE.md` (or feed it to the agent at session start)
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

## End-to-End Workflow Examples

### Scenario 1: Greenfield from an Idea (Proposal Mode)

```
1. /smart-sdd init "Build a task management app with Kanban boards and team workspaces"
   +-- Signal Extraction: "task management" → Core Purpose, "Kanban boards" → gui,
   |   "team workspaces" → auth + async-state
   +-- Clarity Index: 58% (Medium tier) → ask 2 targeted questions
   +-- Proposal: 5 Features, Domain Profile [gui, http-api] + [auth, async-state]
   +-- User approves → auto-chain to constitution + add + pipeline

2. /smart-sdd pipeline (auto-chained)
   +-- Phase 0: Constitution finalized (principles inferred from Proposal)
   +-- CI propagation: "Target Users" low-confidence → specify adds user role prompt
   +-- F001-auth → F002-workspace → F003-task → F004-board → F005-notification
```

### Scenario 1b: Greenfield — Standard Q&A

```
1. /smart-sdd init
   +-- Define project: "TaskFlow", TypeScript + Next.js + Prisma
   +-- Constitution seed with 6 Best Practices
   +-- Generate empty artifacts
   +-- Chain into /smart-sdd add...
       +-- Define: F001-auth, F002-workspace, F003-task, F004-board, F005-notification
       +-- Demo Group assignment, create pre-context per Feature

2. /smart-sdd pipeline
   +-- Phase 0: Finalize constitution
   +-- Release 1 (Foundation):
   |   F001-auth → specify → plan → ... → verify
   |   Update: User, Session entities → entity-registry
   +-- Release 2 (Core):
   |   F002-workspace (references F001's User entity)
   |   F003-task ...
   +-- Release 3 (Enhancement): F004-board, F005-notification
```

### Scenario 2: Brownfield Rebuild — Legacy e-commerce to React + FastAPI

```
1. /reverse-spec ./legacy-ecommerce --scope core --stack new
   +-- Phase 1: Detect Django + jQuery stack
   +-- Phase 2: Extract 12 entities, 45 APIs, 78 business rules
   +-- Phase 3: Select Standard granularity (8 Features)
   |   Tier 1: Auth, Product, Order
   |   Tier 2: Cart, Payment, Search
   |   Tier 3: Review, Notification
   +-- Phase 4: Generate all artifacts

2. /smart-sdd pipeline
   +-- Scope: Core (Tier 1 only)
   +-- F001-auth → F002-product → F003-order
   +-- Tier 2/3 remain deferred

3. /smart-sdd expand T2     → activates Cart, Payment, Search
4. /smart-sdd expand full   → activates Review, Notification
```

### Scenario 3: Incremental — Adding notifications to existing project

```
1. /smart-sdd add
   +-- "I need real-time notifications for task updates"
   +-- Overlap check: No conflicts with existing Features
   +-- ⚠️ Constitution Impact: WebSocket (new technology)
   +-- F005-notification depends on F001-auth, F003-task

2. /smart-sdd pipeline
   +-- Skips completed Features
   +-- F005-notification: specify → plan → ... → verify
   +-- Update: Notification entity → entity-registry
```

## Reference

### Installation — Alternative Methods

**Project-Local Installation**:

```bash
mkdir -p .claude/skills
cp -r /path/to/spec-kit-skills/.claude/skills/reverse-spec .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/smart-sdd .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/case-study .claude/skills/
```

**Manual Symlinks**:

```bash
ln -s /path/to/spec-kit-skills/.claude/skills/reverse-spec ~/.claude/skills/reverse-spec
ln -s /path/to/spec-kit-skills/.claude/skills/smart-sdd ~/.claude/skills/smart-sdd
ln -s /path/to/spec-kit-skills/.claude/skills/case-study ~/.claude/skills/case-study
```

### Path Conventions

| Target | Path |
|--------|------|
| reverse-spec artifacts | `specs/reverse-spec/` |
| spec-kit Feature artifacts | `specs/{NNN-feature}/` |
| spec-kit constitution | `.specify/memory/constitution.md` |
| smart-sdd state file | `specs/reverse-spec/sdd-state.md` |
| Decision history | `history.md` |
| Failure patterns & countermeasures | [`lessons-learned.md`](lessons-learned.md) — 16 gap patterns + 22 specific lessons from real pipeline executions. Useful for anyone building AI agent pipelines. |

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
├── {skill}/                       Per-skill directory (reverse-spec, smart-sdd, case-study)
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
| `ARCHITECTURE-EXTENSIBILITY.md` | Detailed architecture extensibility guide — module system, adding interfaces/concerns/archetypes/foundations, sophistication levels |
| `CLAUDE.md` | Project rules for Claude Code agents (immutable rules, conventions, review protocol) |
| `README.md` | English documentation |
| `README.ko.md` | Korean documentation |
| `PLAYWRIGHT-GUIDE.md` | Playwright setup guide for browser automation and Electron CDP configuration |
| `TODO.md` | Project task tracker (all planned tasks completed as of 2026-03-08) |
| `history.md` | Design decision history extracted from git history |
| `lessons-learned.md` | AI agent pipeline failure patterns (G1–G16) and specific lessons (L1–L22) — universal takeaways for agent skill builders |
| `install.sh` | Installer — creates symlinks in `~/.claude/skills/` |
| `uninstall.sh` | Uninstaller — removes symlinks from `~/.claude/skills/` |

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
| `commands/verify-phases.md` | 4-phase verification workflow (Test/Build/Lint → Cross-Feature → Demo-Ready → Global Update) |
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
| **Archetypes** | |
| `domains/archetypes/ai-assistant.md` | AI assistant — A0 semantic + code patterns (LLM SDKs, streaming, RAG) |
| `domains/archetypes/public-api.md` | Public API — A0 semantic + code patterns (OpenAPI, rate limiting, versioning) |
| `domains/archetypes/microservice.md` | Microservice — A0 semantic + code patterns (gRPC, service mesh, Docker) |
| `domains/archetypes/sdk-framework.md` | SDK/Framework — A0 semantic + code patterns (package metadata, public API, extension points, examples) |

### case-study (`.claude/skills/case-study/`)

| File | Description |
|------|-------------|
| `SKILL.md` | Skill router — case study report generator entry point |
| `commands/generate.md` | Report generation — extract metrics + philosophy data, generate philosophy-aware narrative |
| `reference/recording-protocol.md` | M1-M8 milestone recording protocol with philosophy adherence tracking |
| `templates/case-study-log-template.md` | Observation log template for chronological milestone entries |
