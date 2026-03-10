# spec-kit-skills

[![GitHub](https://img.shields.io/badge/GitHub-coolhero%2Fspec--kit--skills-blue?logo=github)](https://github.com/coolhero/spec-kit-skills)

[한국어 README](README.ko.md) | [MCP Setup Guide](MCP-GUIDE.md) | Last updated: 2026-03-10 10:09 KST

**Claude Code skills that extend [spec-kit](https://github.com/github/spec-kit) beyond Feature-local scope into AI-controllable, contract-based development**

- **Reverse-Spec** reverse-extracts implicit contracts (behaviors, interfaces, data models) from brownfield codebases and realigns them into Specs — bringing legacy code into the contract-based system. Supports both Rebuild (rewrite from scratch using the original as reference) and Adopt (keep existing code, add SDD documentation). Also generates a standalone prompt (`speckit-prompt.md`) for using spec-kit without smart-sdd.
- **Smart-SDD** automatically assembles and injects related Features' contracts and state into each spec-kit command, then verifies changes don't violate existing contracts — keeping cross-Feature consistency intact.

---

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI
- [spec-kit](https://github.com/github/spec-kit) skill (for `/smart-sdd`)
- [Playwright MCP](https://github.com/microsoft/playwright-mcp) — `claude mcp add --scope user playwright -- npx @playwright/mcp@latest` — see [MCP Setup Guide](MCP-GUIDE.md) for Electron CDP setup

### Installation

```bash
git clone https://github.com/coolhero/spec-kit-skills.git
cd spec-kit-skills
./install.sh      # creates symlinks → ~/.claude/skills/
# ./uninstall.sh  # removes symlinks (to uninstall)
```

### First Commands

| Goal | Command |
|------|---------|
| Rebuild existing code | `/reverse-spec ./path/to/source` |
| New project | `/smart-sdd init` → `/smart-sdd add` |
| Add Feature to existing project | `/smart-sdd add` |
| Adopt SDD (keep existing code) | `/reverse-spec --adopt` → `/smart-sdd adopt` |
| Check spec-kit compatibility | `/speckit-diff` |

### Verify

```
/reverse-spec --help
/smart-sdd status
```

---

## What It Solves

spec-kit processes **one Feature at a time** — it has no mechanism for tracking shared entities, API contracts, or dependencies across Features. When you run `/speckit-plan` for Feature 3, it doesn't know what data models Feature 1 defined or what APIs Feature 2 expects.

**spec-kit-skills** fills this gap with a **Global Evolution Layer** — project-wide artifacts that sit above spec-kit's per-Feature scope:

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

### Utilities

| Skill | Purpose |
|-------|---------|
| `/speckit-diff` | Compares spec-kit versions, produces compatibility verdict + impact report |
| `/case-study` | Generates metrics + qualitative observations report from execution artifacts |

---

## User Journeys

```
── New Project ───────────────────────────────────────────────────
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

### Per-Command Context Injection

| Command | Injection Source | Injected Content |
|---------|-----------------|-----------------|
| `constitution` | `constitution-seed.md` | Full content (architecture principles, Best Practices, Global Evolution operational principles) |
| `specify` | `pre-context.md` + `business-logic-map.md` | Feature summary, FR/SC drafts, business rules, edge cases, source reference |
| `plan` | `pre-context.md` + `entity-registry.md` + `api-registry.md` | Dependency info, entity/API schema drafts (or finalized from preceding Features), integration contracts (cross-Feature data shape + bridge) |
| `tasks` | `plan.md` | Automatic execution based on plan |
| `analyze` | `spec.md` + `plan.md` + `tasks.md` | Cross-artifact consistency analysis |
| `implement` | `tasks.md` + `plan.md` + `pre-context.md` | Interaction chains, UX behavior contract, API compatibility matrix, env var verification, naming remapping, runtime verification + fix loop |
| `verify` | `pre-context.md` + registries + `plan.md` | Cross-Feature entity/API consistency, interaction chain completeness, UX behavior contract, API compatibility matrix, enablement smoke test, integration contract shape verification, SC verification matrix, impact scope |

**Preceding Feature results take priority**: If a dependent Feature's plan is already complete, the finalized `data-model.md` and `contracts/` are referenced instead of registry drafts.

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

Run the original application and explore it interactively via Playwright MCP before deep code analysis. Provides visual and behavioral context (UI layout, user flows, actual states). For Electron apps, requires CDP pre-setup — see [MCP Setup Guide](MCP-GUIDE.md).

### Phase 2 — Deep Analysis

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

Also extracts: Business logic, Inter-module dependencies, Source Behavior Inventory, UI Component Features

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
/smart-sdd init                          # Project setup
/smart-sdd init --prd path/to/prd.md     # PRD-based setup

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
/smart-sdd reset                         # Reset pipeline state
/smart-sdd status                        # Progress overview
/smart-sdd coverage                      # SBI coverage check
/smart-sdd parity                        # Parity check vs original source
```

### Four Project Modes

| Aspect | Greenfield | Incremental | Rebuild | Adoption |
|--------|-----------|-------------|---------|----------|
| Use case | New project | Add to existing | Re-implement | Document existing |
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
Foundation Gate (first Feature only):
   - Build check (BLOCKING), Toolchain Pre-flight (lint/test availability),
     CSS theme, state management, IPC bridge, layout verification
   - Results cached in sdd-state.md — skipped for subsequent Features
Phase 1~N: Per Feature (in Release Group order):
   0. pre-flight → Ensure on main branch
   1. specify    → (pre-context + business-logic injection) → /speckit-specify
   2. clarify    → Only if [NEEDS CLARIFICATION] exists
   3. plan       → (pre-context + registry injection) → /speckit-plan
   4. tasks      → /speckit-tasks
   5. analyze    → /speckit-analyze (consistency check)
   6. implement  → Env var check (HARD STOP) → /speckit-implement → runtime verification + fix loop
   7. verify     → 4-phase verification (+ Phase 3b bug prevention)
   8. merge      → Checkpoint (HARD STOP) → Merge to main
```

### 4-Phase Verification

```
Phase 1:  Execution (tests, build, lint) — BLOCKS on failure
          Lint tool detection per ecosystem (auto-install offer if missing)
Phase 2:  Cross-Feature Consistency — entity/API compat, interaction chains,
          UX behavior contract, API compatibility matrix, enablement smoke test,
          integration contract shape verification (Provider↔Consumer + bridge)
Phase 3:  Demo-Ready Verification — BLOCKS on failure
          SC Verification Matrix: classify ALL SCs → cdp-auto / test-covered /
          external-dep / manual. Coverage gate warns if < 50%.
          + VERIFY_STEPS functional tests, visual fidelity (rebuild)
Phase 3b: Bug Prevention — empty state smoke test, smoke launch criteria
Phase 4:  Global Evolution Update (registries, sdd-state)

Verify-time Change Recording: ALL source modifications during verify
(agent-discovered or user-feedback) classified as Bug Fix / Implementation
Gap / Design Change, with mandatory recording in sdd-state.md Notes.

Verify Progress Checkpoint: Phase-by-phase status written to sdd-state.md,
survives context compaction. Resumption Protocol re-reads verify-phases.md
and continues from the first pending Phase.
```

### Post-Feature Processing

| Timing | Processing |
|--------|-----------|
| After plan | Update entity-registry.md and api-registry.md |
| After implement | Runtime Error Zero Gate — BLOCKS if console errors detected |
| After implement | Impact analysis on subsequent Feature pre-contexts |
| After verify | Record results in sdd-state.md, update roadmap.md status |
| After verify | Merge Feature branch to main (HARD STOP) |

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

### Aggregation Scripts

Located in `.claude/skills/smart-sdd/scripts/`. Designed for use within the smart-sdd pipeline context.

| Script | Purpose |
|--------|---------|
| `context-summary.sh` | Feature/Entity/API/DemoGroup summary |
| `sbi-coverage.sh` | SBI coverage dashboard |
| `demo-status.sh` | Demo Group progress |
| `pipeline-status.sh` | Pipeline progress overview |
| `validate.sh` | Cross-file consistency check |

## End-to-End Workflow Examples

### Scenario 1: Greenfield — New task management app

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
cp -r /path/to/spec-kit-skills/.claude/skills/speckit-diff .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/case-study .claude/skills/
```

**Manual Symlinks**:

```bash
ln -s /path/to/spec-kit-skills/.claude/skills/reverse-spec ~/.claude/skills/reverse-spec
ln -s /path/to/spec-kit-skills/.claude/skills/smart-sdd ~/.claude/skills/smart-sdd
ln -s /path/to/spec-kit-skills/.claude/skills/speckit-diff ~/.claude/skills/speckit-diff
ln -s /path/to/spec-kit-skills/.claude/skills/case-study ~/.claude/skills/case-study
```

### Path Conventions

| Target | Path |
|--------|------|
| reverse-spec artifacts | `specs/reverse-spec/` |
| spec-kit Feature artifacts | `specs/{NNN-feature}/` |
| spec-kit constitution | `.specify/memory/constitution.md` |
| smart-sdd state file | `specs/reverse-spec/sdd-state.md` |
| Decision history | `specs/history.md` |

### Feature Naming Convention

| System | Format | Example |
|--------|--------|---------|
| smart-sdd (pre-context, roadmap, state) | `F{NNN}-{short-name}` | `F001-auth` |
| spec-kit (specs/ directory, git branch) | `{NNN}-{short-name}` | `001-auth` |

### Artifact Structure

```
specs/
├── history.md
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

### Using reverse-spec Artifacts without smart-sdd

| Command | What to Paste Before Invoking |
|---------|------------------------------|
| `/speckit-constitution` | Full `constitution-seed.md` |
| `/speckit-specify` | `pre-context.md` "For /speckit.specify" + `business-logic-map.md` |
| `/speckit-plan` | `pre-context.md` "For /speckit.plan" + registries |
| `/speckit-tasks`, `/speckit-implement` | Check `pre-context.md` for Static Resources and Environment Variables |
| `/speckit-analyze` | `pre-context.md` "For /speckit.analyze" + registries |

### Domain Profiles

Currently optimized for **application development** (backend, frontend, fullstack, mobile, library). Profiles for data science, AI/ML, embedded systems are planned.

```
Core Workflow (domain-agnostic)     ← Phases, checkpoints, pipeline orchestration
    ↓ reads
Domain Profile (swappable)          ← Analysis axes, extraction patterns, demo/verify conventions
    ↓ applies to
Tech Stack (detected at runtime)    ← Framework-specific file patterns, ORM types, API styles
```

Use `--domain` to select a profile (default: `app`). See `domains/_schema.md` for creating custom profiles.


