# spec-kit-skills

[한국어 README](README.ko.md) | Last updated: 2026-03-03

**A collection of Claude Code custom skills that augment spec-kit-based Spec-Driven Development (SDD) workflows**

---

## Purpose

[spec-kit](https://github.com/github/spec-kit) is a Git-based execution framework for implementing Spec-Driven Development (SDD) as a practical workflow. However, spec-kit has the following project-level limitations.

### Limitations of spec-kit

spec-kit is optimized for **Feature-local governance** (internal control within individual features), but lacks the following project-level management mechanisms out of the box:

| Limitation | Impact |
|-----------|--------|
| No cross-Feature references | `/speckit-plan` does not automatically reference preceding Features' data-model or API contracts, potentially leading to incompatible designs |
| Limited cross-Feature analysis | `/speckit-analyze` only analyzes within a single Feature, unable to detect entity/interface conflicts between Features |
| Insufficient agent context | The "Recent Changes" section only accumulates one-line summaries for the last 3 Features. Data model/API/business logic level context is not included |
| No release-level management | No artifacts for managing Feature dependencies, priorities, and release grouping, leaving integration planning outside the framework |

### This Project's Solution: Global Evolution Layer

Without modifying spec-kit's command templates, this project compensates for these limitations through **Constitution principles + project-level artifacts + operational skills**.

Two custom skills implement a Global Evolution Layer that wraps the spec-kit workflow, supporting three distinct project modes:

```
-- Greenfield -----------------------------------------------------------
New project         --> /smart-sdd init --> Global Evolution Layer --> /smart-sdd pipeline

-- Brownfield (incremental) ---------------------------------------------
Existing smart-sdd  --> /smart-sdd add  --> updated Global Evolution --> /smart-sdd pipeline
project                                    Layer

-- Brownfield (rebuild) -------------------------------------------------
Existing source     --> /reverse-spec   --> Global Evolution Layer --> /smart-sdd pipeline
code                   (reverse-analysis)  (roadmap, registries,
                                           pre-context, etc.)
```

### When to Use `/reverse-spec`

The `/reverse-spec` skill is designed for the **full rebuild scenario** -- when you have an existing codebase and want to re-implement it using spec-kit SDD. It is not needed for greenfield projects or for adding Features to an existing smart-sdd project.

In the rebuild workflow, `/reverse-spec` **generates the essential prerequisites for smart-sdd to function correctly**. It reverse-analyzes existing source code to extract entities, API contracts, business logic, and inter-Feature dependencies. smart-sdd needs this information to **accurately inject cross-Feature context** when executing spec-kit commands for each Feature. Without reverse analysis, smart-sdd cannot know which entities to reference, which API contracts to comply with, or how each Feature depends on its predecessors.

Furthermore, **reproducing and testing the existing implementation** is at the core of the rebuild approach. The extracted draft requirements (FR-###) and acceptance criteria (SC-###) are derived from what the existing system actually does, providing test criteria to verify that the redeveloped system accurately reproduces the original functionality.

---

## Skill Overview

### 1. `/reverse-spec` -- Reverse-Analyze Existing Source Code for Full Rebuild

A skill that analyzes existing source code to extract **project-level global context** needed for spec-kit-based SDD redevelopment.

#### Core Value

- **Automatic reverse-extraction** of entities, APIs, business logic, and module dependencies from existing code
- **Core scope**: Feature-level classification with **5-axis analysis-based Tier recommendations** (Tier 1 Essential / Tier 2 Recommended / Tier 3 Optional) for incremental development
- **Full scope**: Pure dependency-based ordering without Tier classification — all Features processed equally
- Generation of **hierarchical artifacts** directly usable by each spec-kit command

#### Usage

```bash
/reverse-spec [target-directory] [--scope core|full] [--stack same|new]
```

If the argument is omitted, the current directory is analyzed.

| Option | Description |
|--------|------------|
| `--scope core` | Set implementation scope to Core (skip interactive prompt) |
| `--scope full` | Set implementation scope to Full (skip interactive prompt) |
| `--stack same` | Use the same tech stack as existing project (skip interactive prompt) |
| `--stack new` | Migrate to a new tech stack (skip interactive prompt) |

> **Note**: When running with `--dangerously-skip-permissions`, interactive prompts (AskUserQuestion) may be auto-skipped. Always provide `--scope` and `--stack` arguments in such environments to ensure correct strategy selection.

#### Execution Workflow

##### Pre-Phase -- Git Repository Setup

Ensures the output directory (CWD) has a git repository before analysis begins. If no git repo exists, initializes one with a `.gitignore` tailored to the project's tech stack. Optionally creates a dedicated branch for the SDD work (e.g., `sdd-setup`). If a git repo already exists, this step is skipped (branch option still offered).

##### Phase 0 -- Strategy Questions

Two strategic questions at skill execution determine the direction of the artifacts. These can be answered interactively or pre-specified via CLI arguments (`--scope`, `--stack`):

**Question 1: Implementation Scope**

| Option | Description |
|--------|------------|
| **Core** | Redevelop only the core features that form the project's foundation. For learning/prototyping purposes |
| **Full** | Redevelop the complete feature set identical to the existing system |

**Question 2: Technology Stack Strategy**

| Option | Description | Source Code Reference Approach |
|--------|------------|-------------------------------|
| **Same** (Same Stack) | Use the same language, framework, and libraries as existing | **Implementation Reference** -- Actively reuse existing implementation patterns. Document reasons when designing differently |
| **New** (New Stack) | Migrate to an optimal modern technology stack | **Logic-Only Reference** -- Extract only What/Why. Ignore How (implementation approach) and prioritize idiomatic patterns of the new stack |

##### Phase 1 -- Project Scan

Automatically identifies the entire structure and technology stack of the target directory.

- **Directory structure exploration**: Scan major source file patterns (`**/*.{py,js,ts,jsx,tsx,java,go,rs,...}`)
- **Automatic tech stack detection**: Identify language/framework/DB/test/build tools from config files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `build.gradle`, etc.)
- **Project type classification**: backend, frontend, fullstack, mobile, library
- **Module/package boundary identification**: Logical module boundaries, monorepo workspace recognition

##### Phase 2 -- Deep Analysis

Performs deep code analysis using patterns appropriate for the tech stack. Utilizes parallel sub-agents for large codebases.

**Data Model Extraction**:

| Technology | Scan Targets |
|-----------|-------------|
| Django | `models.py`, migrations |
| SQLAlchemy/FastAPI | Model classes, Alembic migrations |
| TypeORM/Prisma | Entity classes, `schema.prisma` |
| JPA/Hibernate | `@Entity` classes |
| Mongoose | Schema definitions |
| Rails | `app/models/`, migrations |

Information extracted per entity: Fields (name, type, constraints), Relationships (1:1, 1:N, M:N), Validation rules, State transitions, Indexes

**API Endpoint Extraction**:

| Technology | Scan Targets |
|-----------|-------------|
| Express/Fastify | Router files, `router.get()`, etc. |
| Django/DRF | `urls.py`, ViewSet, APIView |
| FastAPI | `@app.get()`, `@router.post()` decorators |
| Spring | `@RequestMapping`, `@GetMapping`, etc. |
| Next.js/Nuxt | `pages/api/`, `app/api/` directories |

Information extracted per endpoint: HTTP method/path, Request/Response schema, Authentication/Authorization requirements, Middleware

**Business Logic Extraction**: Business rules, Validations, Multi-step workflows, External integrations

**Inter-Module Dependency Mapping**: import/require analysis, Service call relationships, Shared utilities, Event-based coupling

##### Phase 3 -- Feature Classification & Importance Analysis

Identifies logical functional units (Features) based on the analysis results.

**Feature Granularity Selection**: After identifying Feature boundaries, `/reverse-spec` presents 2-3 granularity options (Coarse/Standard/Fine) with concrete Feature lists for each level. The user selects the appropriate decomposition level based on their project goals, team size, and desired iteration speed. This ensures the Feature count and scope match the project's needs.

After constructing a dependency graph, **Feature IDs (F001, F002, ...)** are assigned based on the scope:

- **Full scope**: Pure topological sort (dependency-based) — no Tier classification
- **Core scope**: Tier first (all Tier 1, then Tier 2, then Tier 3), then topological order within each Tier

**Tier Classification (Core Scope Only)**:

> In full scope, this step is skipped entirely. All Features are treated equally and ordered by dependency topology.

For core scope, each Feature is comprehensively evaluated along **5 analysis axes**:

| Analysis Axis | Criteria |
|--------------|----------|
| **Structural Foundation** | Can other Features not exist without this Feature? Number of dependents, import depth, number of shared entities owned |
| **Domain Core** | Is this feature directly tied to the project's reason for existence? Role within the project domain (e.g., for e-commerce, Product/Order are core) |
| **Data Ownership** | Does this feature define and manage core entities? Number of owned entities, percentage referenced by other Features |
| **Integration Hub** | Is this a connection point with other Features/external systems? API provider role, number of external integrations |
| **Business Complexity** | Are core business rules concentrated in this feature? Number of business rules, state transitions, validation complexity |

Based on the comprehensive evaluation, each Feature is classified into **3 Tiers**:

| Tier | Meaning | Criteria |
|------|---------|----------|
| **Tier 1 (Essential)** | Project foundation. The system cannot exist without it | Must be included in redevelopment |
| **Tier 2 (Recommended)** | Features that complete the core user experience | System works without it, but core value is significantly degraded |
| **Tier 3 (Optional)** | Auxiliary features, admin tools, convenience features | Can be added in later stages |

**Specific rationale** must be provided for each Feature's Tier classification. Examples:
- "Auth recommended as Tier 1: 7 Features directly depend on it, owns User entity, used as middleware for all APIs"
- "Notification recommended as Tier 3: Independent module with no dependents, loosely coupled via event subscription"

##### Phase 4 -- Artifact Generation

Generates hierarchical artifacts based on the finalized analysis results.

#### Artifact Structure

```
[current-working-directory]/specs/reverse-spec/
├── roadmap.md                           # Feature evolution map + Tier classification + Release plan
├── constitution-seed.md                 # Constitution draft (source reference principles + Best Practices)
├── entity-registry.md                   # Shared entity registry
├── api-registry.md                      # API contract registry
├── business-logic-map.md                # Business logic map
├── stack-migration.md                   # Stack migration plan (only for new stack)
└── features/
    ├── F001-auth/pre-context.md         # Per-Feature spec-kit cross-reference info
    ├── F002-product/pre-context.md
    └── ...
```

#### Artifact Details

**Project-Level Artifacts:**

| Artifact | Role | spec-kit Usage |
|----------|------|---------------|
| `roadmap.md` | Complete Feature evolution map. Tier-based Feature Catalog, Dependency Graph, Release Groups, Cross-Feature dependency mapping | Determines Feature execution order, dependency verification |
| `constitution-seed.md` | Architecture principles, technical constraints, coding conventions extracted from existing code + project-specific recommended principles (derived from domain/architecture/scale traits) + recommended Best Practices (TDD, Simplicity First, etc.) + source code reference strategy (per-stack branching) | Used as draft when running `/speckit-constitution` |
| `entity-registry.md` | Complete entity list, fields, relationships, validation rules, cross-Feature sharing mapping. Includes Mermaid state diagrams | Cross-reference for writing `data-model.md` during `/speckit-plan` |
| `api-registry.md` | Complete API endpoint index, detailed contracts (Request/Response schemas), Cross-Feature dependencies | Cross-reference for writing `contracts/` during `/speckit-plan` |
| `business-logic-map.md` | Per-Feature business rules, validations, workflows (flowcharts), Cross-Feature rules | Prevents omission of requirements/acceptance criteria during `/speckit-specify` |

**Feature-Level Artifact -- `pre-context.md`:**

Pre-prepares information needed for spec-kit's 3 core commands in dedicated sections per Feature:

| Section | Target Command | Content |
|---------|---------------|---------|
| Source Reference | All | Related original file list + per-stack strategy reference guide (Implementation Reference vs Logic-Only Reference) |
| For /speckit.specify | `/speckit-specify` | Existing feature summary, user scenarios, draft requirements (FR-###), draft acceptance criteria (SC-###), edge cases |
| For /speckit.plan | `/speckit-plan` | Preceding Feature dependencies, owned/referenced entity schema drafts, provided/consumed API contract drafts, technical decisions |
| For /speckit.analyze | `/speckit-analyze` | Cross-Feature verification points (entity compatibility, API contract compatibility, business rule consistency), impact scope on change |

---

### 2. `/smart-sdd` -- spec-kit SDD Workflow Orchestrator

A skill that **wraps** spec-kit commands, automatically injecting cross-Feature context at each step and maintaining the Global Evolution Layer. Supports greenfield projects, incremental Feature additions, and full rebuilds from reverse-spec artifacts.

#### Core Value

- **Three project entry points**: `init` for greenfield, `add` for incremental, `pipeline` for all modes
- **Wraps rather than replaces** spec-kit commands, unaffected by spec-kit updates
- **Automatically assembles and injects** required cross-Feature information before each command execution
- **Automatically updates** the Global Evolution Layer (entity-registry, api-registry, roadmap, subsequent pre-context) upon Feature completion
- **Systematic tracking** of overall progress via `sdd-state.md`

#### Usage

```bash
# Greenfield -- New project setup
/smart-sdd init                          # Interactive greenfield project setup
/smart-sdd init --prd path/to/prd.md     # Setup from a PRD document

# Brownfield (incremental) -- Add new Feature(s) to existing smart-sdd project
/smart-sdd add                           # Interactive: define and add new Feature(s)

# Pipeline -- Run the full SDD pipeline (after init, add, or reverse-spec)
/smart-sdd pipeline                      # With per-step confirmation
/smart-sdd pipeline --auto               # Without stopping for confirmation
/smart-sdd pipeline --from ./path        # Read artifacts from specified path

# Step Mode -- Execute a specific step for a specific Feature
/smart-sdd constitution                  # Finalize constitution (one-time)
/smart-sdd specify F001                  # Specify Feature F001
/smart-sdd plan F001                     # Plan Feature F001
/smart-sdd tasks F001                    # Generate tasks for Feature F001
/smart-sdd analyze F001                  # Analyze cross-artifact consistency (before implement)
/smart-sdd implement F001               # Implement Feature F001
/smart-sdd verify F001                   # Verify Feature F001

# Feature restructuring -- Modify Feature definitions mid-pipeline
/smart-sdd restructure                   # Interactive: split, merge, move, reorder, or delete Features

# Scope expansion (brownfield rebuild with scope=core)
/smart-sdd expand                        # Interactive: select which Tiers to activate
/smart-sdd expand T2                     # Activate Tier 2 Features
/smart-sdd expand T2,T3                  # Activate Tier 2 and Tier 3 Features
/smart-sdd expand full                   # Activate all remaining deferred Features

# Status check
/smart-sdd status                        # Check overall progress status

# --auto can be combined with any command to skip confirmation
/smart-sdd specify F001 --auto
/smart-sdd pipeline --from ./path --auto
```

#### Three Project Modes

| Aspect | Greenfield | Brownfield (incremental) | Brownfield (rebuild) |
|--------|-----------|-------------------------|---------------------|
| Use case | New project from scratch | Add Features to existing smart-sdd project | Full re-implementation of existing code |
| Entry point | `/smart-sdd init` | `/smart-sdd add` | `/reverse-spec` then pipeline |
| Prerequisite | None | Existing smart-sdd artifacts | Existing source code |
| Scope | Always Full (user defines only needed Features) | N/A (inherits existing scope) | Core (T1 only) or Full (all Tiers). Use `/smart-sdd expand` to activate deferred Tiers |
| Feature granularity | User selects from Coarse/Standard/Fine options during init | N/A (adding to existing Features) | User selects from Coarse/Standard/Fine options during reverse-spec |
| Entity/API registries | Empty, populated during plan | Already exist, updated | Generated by reverse-spec |
| Constitution | Created during init | Already exists | Created from constitution-seed |
| business-logic-map | Not generated | Already exists | Generated by reverse-spec |

#### How the Modes Differ in Practice

The three modes differ primarily in **how much context is available at the start**:

- **Brownfield (rebuild)** has the richest starting context. `/reverse-spec` pre-analyzes the entire codebase and extracts entities, APIs, business rules, and Feature dependencies into the Global Evolution Layer. When the pipeline runs, each step receives draft requirements, schema references, and cross-Feature context from day one. This is a **refinement-based** workflow -- spec-kit refines pre-populated drafts rather than creating from scratch.

- **Greenfield** starts with minimal context. `/smart-sdd init` creates the project structure with empty entity/API registries and simplified pre-context files (no FR/SC drafts, no business logic map). The pipeline is **generative** -- spec-kit creates requirements, schemas, and contracts from scratch. As each Feature completes its `plan` step, the registries grow, providing context for subsequent Features. This means Feature ordering matters more in greenfield: a Feature's `plan` step populates the registries that the next Feature's `plan` step will reference.

- **Brownfield (incremental)** inherits the existing project's context. `/smart-sdd add` creates new Features that can immediately reference the already-populated registries and completed Feature artifacts. It's the simplest mode -- just define new Features and resume the pipeline.

Key practical differences:

| Aspect | Greenfield | Brownfield (rebuild) |
|--------|-----------|---------------------|
| Entity/API registries at start | Empty -- grow as Features are planned | Pre-populated from codebase analysis |
| FR/SC drafts in pre-context | None -- created from scratch by spec-kit | Extracted from existing code -- refined by spec-kit |
| Business logic map | Not available | Available -- injected during specify |
| Cross-Feature context for early Features | Limited -- only dependency info | Rich -- full entity/API schemas from registries |
| Pipeline ordering sensitivity | High -- dependent Features need predecessors to complete plan first | Low -- all registries pre-exist |

#### Feature Restructuring

During pipeline execution, Feature definitions can be modified using `/smart-sdd restructure`. This command supports splitting, merging, moving requirements, changing dependencies, and deleting Features. All changes are automatically propagated to every affected artifact (roadmap, registries, pre-context files, sdd-state) with user approval before execution.

#### Common Protocol: Assemble --> Checkpoint --> Execute --> Review --> Update

All spec-kit command executions follow this 5-step protocol:

```
+--------------+     +---------------+     +--------------+     +------------+     +--------------+
|  1. Assemble |---->| 2. Checkpoint |---->|  3. Execute  |---->|  4. Review |---->|  5. Update   |
|  Context     |     |  Pre-Exec     |     | spec-kit     |     | Artifact   |     | Global       |
|  Assembly    |     |  Confirmation |     | Execution    |     | Review     |     | Refresh      |
+--------------+     +---------------+     +--------------+     +------------+     +--------------+
```

| Step | Description |
|------|------------|
| **Assemble** | Reads files/sections required for the given command from `specs/reverse-spec/`, filters and assembles per command-specific injection rules. Also references actual implementation results from preceding Features (under `specs/{NNN-feature}/`). If a source file is missing or a section contains only placeholder text, that source is gracefully skipped |
| **Checkpoint** | Presents the assembled context to the user with actual content, providing an opportunity to approve or modify before execution. If modifications are requested, applies changes and re-confirms. **Skipped only in `--auto` mode** (summary is still displayed but execution proceeds immediately). In `--dangerously-skip-permissions` environments, confirmation is requested via regular text message instead of AskUserQuestion |
| **Execute** | Executes the corresponding spec-kit command (`/speckit-specify`, `/speckit-plan`, etc.) with the approved context. The actual work is performed by spec-kit |
| **Review** | Presents the generated/modified artifacts to the user for review after execution. The user can approve, request modifications (re-execute), or edit artifacts directly. **HARD STOP** — same rules as Checkpoint. **Skipped only in `--auto` mode** |
| **Update** | Updates Global Evolution Layer files to reflect execution results. Records progress status in `sdd-state.md` |

#### Per-Command Context Injection

Summary of what information is automatically injected before each spec-kit command execution:

| Command | Injection Source | Injected Content |
|---------|-----------------|-----------------|
| `constitution` | `constitution-seed.md` | Full content (source reference principles, architecture principles, Best Practices, Global Evolution operational principles) |
| `specify` | `pre-context.md` "For /speckit.specify" + `business-logic-map.md` | Feature summary, FR-### drafts, SC-### drafts, business rules, edge cases, original source reference. **If business-logic-map.md missing (greenfield/add), skip business logic injection** |
| `plan` | `pre-context.md` "For /speckit.plan" + `entity-registry.md` + `api-registry.md` | Dependency info, entity/API schema drafts (or finalized schemas from preceding Features), technical decisions. **If registries empty (early greenfield), skip registry injection** |
| `tasks` | `plan.md` (spec-kit artifact) | Automatic execution based on plan. No additional injection |
| `analyze` | `spec.md` + `plan.md` + `tasks.md` (spec-kit artifacts) | Cross-artifact consistency analysis (gaps, duplications, ambiguities). Runs before implement |
| `implement` | `tasks.md` (spec-kit artifact) | Automatic execution based on tasks. No additional injection |
| `verify` | `pre-context.md` "For /speckit.analyze" + registries | Cross-Feature entity/API consistency, impact scope analysis |

**Preceding Feature results take priority**: If a dependent preceding Feature's plan is already complete, the **finalized data-model.md and contracts/** from `specs/{NNN-feature}/` are referenced instead of the drafts in entity-registry/api-registry.

#### Pipeline Mode Details

Running `/smart-sdd pipeline` progresses through the entire workflow sequentially:

```
Phase 0: Constitution Finalization
    +-- Execute /speckit-constitution based on constitution-seed.md
    |   (Skipped if constitution already exists, e.g., after /smart-sdd add)

Phase 1~N: Progress Features in Release Group Order
    +-- For each Feature:
       0. pre-flight -> Ensure on main branch (clean state)
       1. specify  -> (pre-context + business-logic-map injection) -> /speckit-specify
                      (spec-kit creates Feature branch: {NNN}-{short-name})
       2. clarify  -> Run /speckit-clarify only if [NEEDS CLARIFICATION] exists in the spec
       3. plan     -> (pre-context + entity-registry + api-registry injection) -> /speckit-plan
       4. tasks    -> /speckit-tasks
       5. analyze  -> /speckit-analyze (cross-artifact consistency check before implement)
       6. implement -> Per-Feature env var check (HARD STOP if missing) -> /speckit-implement
       7. verify   -> 3-phase verification (Test/Build/Lint + Cross-Feature consistency + Global Evolution update)
       8. merge    -> Checkpoint (HARD STOP) -> Merge Feature branch to main
```

#### Post-Feature Completion Processing

Tasks automatically performed by smart-sdd when all steps for a Feature are complete:

| Processing Item | Content |
|----------------|---------|
| entity-registry.md update | Reflect new entities/changes from `data-model.md` finalized in the plan |
| api-registry.md update | Reflect new APIs/changes from `contracts/` finalized in the plan |
| roadmap.md update | Change Feature status to `completed` |
| Subsequent Feature pre-context.md impact analysis | Automatically update pre-context of subsequent Features affected by changed/added entities/APIs and report to user |
| sdd-state.md update | Record completion time and results for each step |
| Feature branch merge | Commit all updates on the Feature branch, then merge to main after user confirmation (HARD STOP). Next Feature starts from main |

#### Pre-Implementation Analysis (analyze step)

After tasks are generated, `speckit-analyze` runs a READ-ONLY consistency check across spec.md, plan.md, and tasks.md. CRITICAL issues block implementation; other findings are informational.

#### 3-Phase Verification (verify step)

```
Phase 1: Execution Verification (Code Level)
    +-- Run tests, Build check, Lint check

Phase 2: Cross-Feature Consistency Verification
    +-- Check cross-verification points in pre-context.md
    +-- Analyze whether shared entities/APIs changed by this Feature affect other Features

Phase 3: Global Evolution Update
    +-- Verify consistency between entity-registry/api-registry and actual implementation; update if discrepancies found
    +-- Record verification results in sdd-state.md
```

#### Constitution Incremental Update

When new architecture principles are discovered during Feature progression:
1. Provide "Constitution update proposal" checkpoint to the user
2. If approved, perform MINOR version update via `/speckit-constitution`
3. Display warning if already completed Features are affected

#### State Tracking (`sdd-state.md`)

```
📊 Smart-SDD Progress Status

Origin: [greenfield | reverse-spec]
Scope: core | Active Tiers: T1
Constitution: ✅ v1.0.0 (2024-01-15)

Feature         | Tier | specify | plan | tasks | impl | verify | merge | Status
----------------|------|---------|------|-------|------|--------|-------|----------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |  ✅  |   ✅   |  ✅  | completed
F002-product    | T1   |   ✅    |  🔄  |       |      |        |      | in_progress
F003-order      | T2   |         |      |       |      |        |      | 🔒 deferred
F004-payment    | T2   |         |      |       |      |        |      | 🔒 deferred

Active: 1/4 completed, 1/4 in progress | Deferred: 2 (Tier 2)
💡 Use /smart-sdd expand to activate deferred Features
```

The state file includes Feature Progress, Feature Detail Log, Feature Mapping (Feature ID to spec-kit Name), Global Evolution Log, Restructure Log, and Constitution Update Log. When `scope=core`, Features outside the Active Tiers are marked as `deferred` and skipped by the pipeline until activated via `/smart-sdd expand`. Features modified via `/smart-sdd restructure` are marked as `restructured` with affected steps flagged for re-execution (🔀).

---

## Path Conventions

| Target | Path | Notes |
|--------|------|-------|
| reverse-spec artifacts | `specs/reverse-spec/` | Flat structure. Can be changed via `/smart-sdd --from` |
| spec-kit feature artifacts | `specs/{NNN-feature}/` | Native spec-kit path. Not modified by smart-sdd |
| spec-kit constitution | `.specify/memory/constitution.md` | spec-kit native working path |
| smart-sdd state file | `specs/reverse-spec/sdd-state.md` | Automatically created/managed by smart-sdd |

### Feature Naming Convention

smart-sdd and spec-kit use slightly different naming formats, but the **short-name** is always identical:

| System | Format | Example |
|--------|--------|---------|
| smart-sdd (pre-context, roadmap, state) | `F{NNN}-{short-name}` | `F001-auth` |
| spec-kit (specs/ directory, git branch) | `{NNN}-{short-name}` | `001-auth` |

Conversion: strip or prepend `F` prefix. The mapping is tracked in `sdd-state.md` → Feature Mapping table.

### Global Evolution Layer Artifact Structure

```
specs/reverse-spec/
├── roadmap.md
├── constitution-seed.md
├── entity-registry.md
├── api-registry.md
├── business-logic-map.md           # (rebuild mode only)
├── stack-migration.md              # (rebuild + new stack only)
├── sdd-state.md                    # Automatically created/managed by smart-sdd
└── features/
    ├── F001-auth/pre-context.md
    ├── F002-product/pre-context.md
    └── ...
```

---

## Constitution Best Practices

The `constitution-seed.md` generated by `/reverse-spec` or `/smart-sdd init` includes the following 6 recommended development principles:

| Principle | Core | Verification Criteria |
|-----------|------|----------------------|
| **I. Test-First (NON-NEGOTIABLE)** | Write tests first. Code without tests is not considered complete. spec.md's Acceptance Scenarios are the source of test cases | All tests pass |
| **II. Think Before Coding** | No assumptions. If unclear, mark as `[NEEDS CLARIFICATION]`. Explicitly record trade-offs | Every decision has an answer to "why?" |
| **III. Simplicity First** | Implement only what is in the spec. No speculative feature additions/premature abstractions | All code is traceable to requirements |
| **IV. Surgical Changes** | No "improving" adjacent code. Only clean up orphaned code caused by your own changes | Changed lines are traceable to tasks |
| **V. Goal-Driven Execution** | Verifiable completion criteria required. "implement" leads to "tests pass" | Automated verification passes |
| **VI. Demo-Ready Delivery** | Each Feature must be demonstrable upon completion. "Tests pass" alone is NOT sufficient — implement a minimal demo surface (CLI command, demo script, demo page) and document it in `demos/F00N-name.md`. Demo code is categorized as **Demo-only** (`// @demo-only`, removed later) or **Promotable** (`// @demo-scaffold`, extended later) | A non-developer can follow `demos/F00N-name.md` and verify the Feature works |

---

## End-to-End Workflow Examples

### Scenario 1: Greenfield -- Building a new task management app

```
1. /smart-sdd init
   +-- Phase 1: Define project
   |   +-- Name: "TaskFlow", Domain: SaaS productivity
   |   +-- Stack: TypeScript + Next.js + Prisma + PostgreSQL
   +-- Phase 2: Define Features interactively
   |   +-- Brainstorm initial features
   |   +-- Granularity selection:
   |   |   A. Coarse (3 Features): auth, core-app, admin
   |   |   B. Standard (5 Features) — Recommended ← selected
   |   |   C. Fine (9 Features): register, login, workspace, task-crud, ...
   |   +-- F001-auth: User registration, login, sessions
   |   +-- F002-workspace: Team workspaces, member management
   |   +-- F003-task: Task CRUD, assignment, status tracking
   |   +-- F004-board: Kanban board views, drag-and-drop
   |   +-- F005-notification: Email/in-app notifications
   |   +-- Dependency graph validated, Release Groups proposed
   +-- Phase 3: Constitution seed with 6 Best Practices (all selected)
   +-- Phase 4: Generate artifacts under specs/reverse-spec/
   |   +-- roadmap.md, constitution-seed.md
   |   +-- entity-registry.md (empty), api-registry.md (empty)
   |   +-- features/F001-auth/pre-context.md, ...
   +-- Phase 5: Completion report

2. /smart-sdd pipeline
   +-- Phase 0: Finalize /speckit-constitution based on constitution-seed
   +-- Release 1 (Foundation):
   |   +-- F001-auth:
   |       +-- Assemble: Gather auth pre-context (no business-logic-map, skip)
   |       +-- Checkpoint: "Injecting Feature description, dependencies. Proceed?"
   |       +-- Execute: Run /speckit-specify, /speckit-plan, etc.
   |       +-- Update: Populate entity-registry with User, Session entities
   |                    Populate api-registry with /auth/* endpoints
   +-- Release 2 (Core):
   |   +-- F002-workspace:
   |   |   +-- Assemble: pre-context + entity-registry(User reference)
   |   |   +-- (F001's finalized User schema takes priority)
   |   |   +-- ...
   |   +-- F003-task: ...
   +-- Release 3 (Enhancement): F004-board, F005-notification
```

### Scenario 2: Brownfield (incremental) -- Adding notifications to an existing project

```
1. /smart-sdd add
   +-- Phase 1: Current project state
   |   +-- Features: 4 total (3 completed, 1 pending)
   |   +-- Entities: 8 defined, APIs: 22 defined
   +-- Phase 2: Define new Feature(s) interactively
   |   +-- F005-notification (Tier 2): Real-time notifications for task updates
   |   |   +-- Depends on: F001-auth (User entity), F003-task (Task events)
   |   +-- F006-analytics (Tier 3): Dashboard with task completion metrics
   |       +-- Depends on: F002-workspace, F003-task
   +-- Phase 3: Checkpoint with updated dependency graph
   +-- Phase 4: Update roadmap.md, create pre-context.md for new Features
   +-- Phase 5: Completion report

2. /smart-sdd pipeline
   +-- Phase 0: Skipped (constitution already exists)
   +-- Skips F001-F003 (completed), F004 (pending but already defined)
   +-- Processes F004 (if pending), then F005-notification, F006-analytics
       +-- F005-notification:
           +-- Assemble: pre-context + entity-registry(User, Task) + api-registry
           +-- (References finalized schemas from completed Features)
           +-- specify -> plan -> tasks -> implement -> verify
           +-- Update: Add Notification entity to entity-registry
                        Add /notifications/* to api-registry
```

### Scenario 3: Brownfield (rebuild) -- Redeveloping a legacy e-commerce system with React + FastAPI

```
1. /reverse-spec ./legacy-ecommerce --scope core --stack new
   +-- Phase 0: Select "Core" scope + "New" stack
   +-- Phase 1: Detect Django + jQuery tech stack
   +-- Phase 2: Extract 12 entities, 45 APIs, 78 business rules, 15 env vars
   +-- Phase 3: Feature boundary identification + granularity selection
   |   +-- Granularity options:
   |   |   A. Coarse (4 Features): auth, catalog, commerce, admin
   |   |   B. Standard (8 Features) — Recommended ← selected
   |   |   C. Fine (14 Features): register, login, product-crud, ...
   |   +-- Tier classification + recommendation rationale:
   |   +-- Tier 1: Auth, Product, Order (foundation features)
   |   +-- Tier 2: Cart, Payment, Search (core UX)
   |   +-- Tier 3: Review, Notification (auxiliary features)
   +-- Phase 4: Generate artifacts for ALL 8 Features (regardless of scope)
   +--           Generate .env.example with detected env vars

2. /smart-sdd pipeline
   +-- Scope: "Core — Tier 1 only. Deferred: Cart, Payment, Search (T2), Review, Notification (T3)"
   +-- Phase 0: Finalize /speckit-constitution based on constitution-seed
   +-- Tier 1 Features only (scope=core):
   |   +-- F001-auth:
   |       +-- Assemble: Gather auth-related info from pre-context + business-logic-map
   |       +-- Checkpoint: "Injecting 5 FRs, 8 SCs, 4 business rules. Proceed?" -> Approved
   |       +-- Execute: Run /speckit-specify
   |       +-- (plan, tasks, implement, verify proceed sequentially)
   |       +-- Update: Reflect finalized User, Session in entity-registry
   |   +-- F002-product, F003-order proceed similarly
   +-- Pipeline complete (Tier 1 done). Tier 2/3 remain deferred.

3. (Later) /smart-sdd expand T2
   +-- Activates Cart, Payment, Search → pending
   +-- /smart-sdd pipeline → processes newly activated Tier 2 Features

4. (Later) /smart-sdd expand full
   +-- Activates Review, Notification → pending
   +-- /smart-sdd pipeline → completes all remaining Features
```

---

## Relationship with spec-kit

| Aspect | spec-kit | spec-kit-skills |
|--------|----------|-----------------|
| **Role** | Feature-local SDD execution framework | Global Evolution Layer augmentation |
| **Scope** | Spec/Plan/Tasks consistency within individual Features | Cross-Feature dependencies, release evolution, cross-references |
| **Relationship** | Operates independently | Wraps spec-kit. Does not replace spec-kit commands |
| **Coupling** | Fully functional without spec-kit-skills | Requires spec-kit |
| **Compatibility** | Unaffected by spec-kit updates | Supplements via Constitution principles + artifacts, independent of spec-kit version |

### Using reverse-spec Artifacts with Plain spec-kit (without smart-sdd)

If you want to use reverse-spec artifacts directly with spec-kit commands — without the smart-sdd orchestrator — you can manually provide the relevant context in your conversation before invoking each command. Smart-sdd automates this assembly, but the same result can be achieved manually.

**How it works**: spec-kit commands receive context through the **conversation thread**, not through CLI arguments. You read the relevant sections from reverse-spec artifacts, include them in your message, and then invoke the spec-kit command. Claude will reference this context when executing the command.

#### Per-Command Context Guide

**`/speckit-constitution`**
```
Read the following file and use it as the basis for the constitution:
[paste contents of specs/reverse-spec/constitution-seed.md]

/speckit-constitution
```

**`/speckit-specify` (for a specific Feature)**
```
I'm specifying Feature F001-auth. Here is the context from reverse-spec:

## Draft Requirements & Acceptance Criteria
[paste "For /speckit.specify" section from specs/reverse-spec/features/F001-auth/pre-context.md]

## Business Rules
[paste F001-auth section from specs/reverse-spec/business-logic-map.md]

## Original Source Reference
[paste "Source Reference" section from pre-context.md — read the listed source files for implementation context]

/speckit-specify
```

**`/speckit-plan` (for a specific Feature)**
```
I'm planning Feature F002-product. Here is the cross-Feature context:

## Dependencies & Entity/API Drafts
[paste "For /speckit.plan" section from specs/reverse-spec/features/F002-product/pre-context.md]

## Shared Entity Registry
[paste relevant entities from specs/reverse-spec/entity-registry.md]

## API Registry
[paste relevant APIs from specs/reverse-spec/api-registry.md]

## Preceding Feature Results (if F001 is already completed)
[paste specs/001-auth/plan/data-model.md and contracts/ — finalized schemas take priority over registry drafts]

/speckit-plan
```

**`/speckit-tasks`** and **`/speckit-implement`**
- These operate on spec-kit's own outputs (`plan.md`, `tasks.md`) — no additional reverse-spec context needed.
- For implement: check the Feature's `pre-context.md` for Static Resources and Environment Variables that may need setup.

**`/speckit-analyze` (cross-artifact consistency check — run after tasks, before implement)**
```
Analyze cross-artifact consistency for Feature F002-product:

## Additional Cross-Feature Verification Context
[paste "For /speckit.analyze" section from specs/reverse-spec/features/F002-product/pre-context.md]

## Current Entity Registry
[paste specs/reverse-spec/entity-registry.md]

## Current API Registry
[paste specs/reverse-spec/api-registry.md]

/speckit-analyze
```

#### What You Lose Without smart-sdd

| Capability | smart-sdd | Manual spec-kit |
|-----------|-----------|-----------------|
| Context assembly per command | Automatic | You read and paste relevant sections |
| Cross-Feature context filtering | Auto-filtered by Feature | You filter manually |
| Global Evolution Layer updates | Auto-updated after each step | You update registries manually |
| Pipeline state tracking | `sdd-state.md` | You track progress yourself |
| Preceding Feature result priority | Auto-detects finalized schemas | You check and reference manually |
| Per-Feature env var verification | Checked at each Feature's implement step with HARD STOP | You check `.env` yourself |
| Feature branch management | Automated create/merge | You manage git branches yourself |

---

## Installation & Setup

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI must be installed
- [spec-kit](https://github.com/github/spec-kit) skill must be installed (for `/smart-sdd` usage)

### Installation

**Method 1: Global Installation (use across all projects)**

```bash
# Clone the repository
git clone https://github.com/coolhero/spec-kit-skills.git

# Create symbolic links
ln -s /path/to/spec-kit-skills/.claude/skills/reverse-spec ~/.claude/skills/reverse-spec
ln -s /path/to/spec-kit-skills/.claude/skills/smart-sdd ~/.claude/skills/smart-sdd
```

**Method 2: Project-Local Installation (use in a specific project only)**

```bash
# From the project root
mkdir -p .claude/skills
cp -r /path/to/spec-kit-skills/.claude/skills/reverse-spec .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/smart-sdd .claude/skills/
```

### Verify Installation

Confirm the skills are recognized in Claude Code with the following commands:

```
/reverse-spec --help
/smart-sdd status
```

---

## Project Structure

```
spec-kit-skills/
└── .claude/
    └── skills/
        ├── reverse-spec/
        │   ├── SKILL.md                                 # Main skill definition (5-Phase workflow)
        │   ├── templates/
        │   │   ├── roadmap-template.md                  # Feature evolution map template
        │   │   ├── entity-registry-template.md           # Shared entity registry template
        │   │   ├── api-registry-template.md              # API contract registry template
        │   │   ├── business-logic-map-template.md        # Business logic map template
        │   │   ├── constitution-seed-template.md         # Constitution draft template
        │   │   └── pre-context-template.md               # Per-Feature cross-reference info template
        │   └── reference/
        │       └── speckit-compatibility.md              # spec-kit integration guide
        └── smart-sdd/
            ├── SKILL.md                                 # Main skill definition (orchestrator)
            └── reference/
                ├── context-injection-rules.md            # Per-command context injection rules
                └── state-schema.md                      # sdd-state.md schema definition
```
