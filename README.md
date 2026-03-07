# spec-kit-skills

[![GitHub](https://img.shields.io/badge/GitHub-coolhero%2Fspec--kit--skills-blue?logo=github)](https://github.com/coolhero/spec-kit-skills)

[한국어 README](README.ko.md) | Last updated: 2026-03-06 08:20 KST

**A collection of Claude Code custom skills that augment spec-kit-based Spec-Driven Development (SDD) workflows**

---

## Overview

Claude Code custom skills that add a **Global Evolution Layer** to [spec-kit](https://github.com/github/spec-kit) SDD workflows.

spec-kit is a powerful SDD framework, but it processes one Feature at a time — it has no built-in mechanism for tracking shared entities across Features, managing API contracts between Features, or understanding the overall project roadmap. The **Global Evolution Layer** fills this gap: a set of project-wide artifacts that sit above spec-kit's per-Feature scope.

| Artifact | What it tracks |
|----------|---------------|
| **Roadmap** | Feature dependency graph with execution ordering |
| **Entity Registry** | Shared data models referenced across Features |
| **API Registry** | Inter-Feature API contracts and endpoints |
| **Per-Feature Pre-contexts** | What each Feature needs to know about the rest of the project |
| **Source Behavior Inventory** | Function-level coverage tracking (for existing codebases) |
| **Constitution** | Project-wide principles and architectural decisions *(spec-kit built-in — extended with cross-Feature rules)* |

`/reverse-spec` **builds** these artifacts from existing source code. `/smart-sdd` **reads and updates** them during every spec-kit command execution.

### `/reverse-spec` — Existing Source → SDD-Ready Artifacts

When you already have working code and want to apply SDD, the first challenge is: **how do you break a monolithic codebase into well-defined Features with clear boundaries?**

`/reverse-spec` solves this. It reads your existing source code and produces the foundation that SDD needs:

- **Feature decomposition** — Identifies logical Feature boundaries from the source structure, then builds a dependency graph showing how Features relate to each other
- **Cross-Feature registries** — Extracts shared entities (data models used across Features), API contracts (how Features communicate), and business logic rules into project-wide registries
- **Per-Feature pre-contexts** — For each Feature, generates a context document listing which entities it owns, which APIs it exposes/consumes, and which other Features it depends on
- **Source coverage baseline** — Measures how much of the original source is accounted for by the extracted Features, so nothing falls through the cracks

The output is a complete set of SDD-ready artifacts that `/smart-sdd` can then consume to run the spec-kit pipeline with full cross-Feature awareness.

### `/smart-sdd` — spec-kit with Cross-Feature Context

spec-kit processes one Feature at a time. That works well in isolation, but real projects have Features that share data models, call each other's APIs, and have ordering constraints. When you run `/speckit-plan` for Feature 3, it has no idea what data models Feature 1 already defined or what API contracts Feature 2 expects.

`/smart-sdd` wraps every spec-kit command with a **4-step protocol**:

1. **Assemble** — Before running a spec-kit command, gathers relevant context: entity/API registries, preceding Features' decisions, dependency constraints
2. **Checkpoint** — Shows the assembled context to the user for review before execution
3. **Execute + Review** — Runs the spec-kit command with injected context, then reviews the output for cross-Feature consistency
4. **Update** — After execution, updates the global registries and state tracking with any new entities, APIs, or decisions

This means `/speckit-plan` for Feature 3 now automatically knows Feature 1's `User` entity has `email` and `role` fields, and Feature 2's `/api/orders` endpoint expects a `userId` parameter. No manual cross-referencing needed.

### Utilities

| Skill | Purpose |
|-------|---------|
| `/speckit-diff` | Compares spec-kit versions against a stored baseline, produces a compatibility verdict + impact report. Run after spec-kit updates. |
| `/case-study` | Generates a Case Study report (metrics + qualitative observations) from execution artifacts. Run after completing a workflow. |

### Four User Journeys

```
-- New Project ----------------------------------------------------------------
New project         --> /smart-sdd init --> /smart-sdd add --> /smart-sdd pipeline
                        (project setup)    (define Features)   (implement)

-- SDD Adoption ---------------------------------------------------------------
Existing source     --> /reverse-spec   --> Global Evolution Layer --> /smart-sdd adopt
code (in CWD)          --adopt             (roadmap, registries,        (document existing)
                                           pre-context, etc.)

-- Rebuild (Core/Full) --------------------------------------------------------
Existing source     --> /reverse-spec   --> Global Evolution Layer --> /smart-sdd pipeline
code                   (reverse-analysis)  (roadmap, registries,        (rebuild code)
                                           pre-context, etc.)

-- Incremental (Steady State) -------------------------------------------------
Existing smart-sdd  --> /smart-sdd add  --> updated Global Evolution --> /smart-sdd pipeline
project                                    Layer
```

All journeys converge to **incremental mode** as the steady state.

---

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI must be installed
- [spec-kit](https://github.com/github/spec-kit) skill must be installed (for `/smart-sdd` usage)

### Installation

**Method 1: Global Installation (use across all projects)**

```bash
# Clone the repository
git clone https://github.com/coolhero/spec-kit-skills.git
cd spec-kit-skills

# Run install script (creates symlinks for all skills)
./install.sh
```

Or manually create symbolic links:

```bash
ln -s /path/to/spec-kit-skills/.claude/skills/reverse-spec ~/.claude/skills/reverse-spec
ln -s /path/to/spec-kit-skills/.claude/skills/smart-sdd ~/.claude/skills/smart-sdd
ln -s /path/to/spec-kit-skills/.claude/skills/speckit-diff ~/.claude/skills/speckit-diff
ln -s /path/to/spec-kit-skills/.claude/skills/case-study ~/.claude/skills/case-study
```

**Method 2: Project-Local Installation (use in a specific project only)**

```bash
# From the project root
mkdir -p .claude/skills
cp -r /path/to/spec-kit-skills/.claude/skills/reverse-spec .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/smart-sdd .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/speckit-diff .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/case-study .claude/skills/
```

### Verify Installation

Confirm the skills are recognized in Claude Code with the following commands:

```
/reverse-spec --help
/smart-sdd status
```

### First Commands

| Mode | Command |
|------|---------|
| New project | `/smart-sdd init` → `/smart-sdd add` |
| Existing codebase rebuild | `/reverse-spec ./path/to/source` |
| SDD adoption | `/reverse-spec --adopt` → `/smart-sdd adopt` (run from source directory) |
| Add to existing project | `/smart-sdd add` |
| Check spec-kit compatibility | `/speckit-diff` |
| Generate Case Study report | `/case-study` (observations are auto-recorded during workflow) |

---

## How It Works

The Global Evolution Layer artifacts (described in [Overview](#overview)) are maintained through the following protocol:

### Common Protocol: Assemble → Checkpoint → Execute+Review → Update

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
| **Assemble** | Reads files/sections required for the given command from `specs/reverse-spec/`, filters and assembles per command-specific injection rules. Also references actual implementation results from preceding Features (under `specs/{NNN-feature}/`). If a source file is missing or a section contains only placeholder text, that source is gracefully skipped |
| **Checkpoint** | Presents the assembled context to the user with actual content, providing an opportunity to approve or modify before execution. If modifications are requested, applies changes and re-confirms. **Skipped only in `--auto` mode** (summary is still displayed but execution proceeds immediately). In `--dangerously-skip-permissions` environments, confirmation is requested via regular text message instead of AskUserQuestion |
| **Execute+Review** | Executes the corresponding spec-kit command and **immediately** — without stopping — presents the generated/modified artifacts for review. The user can approve, request modifications (re-execute), or edit artifacts directly. **HARD STOP** — same rules as Checkpoint. Execute and Review are ONE continuous action to prevent agent from stopping between them. **Review skipped only in `--auto` mode** |
| **Update** | Updates Global Evolution Layer files to reflect execution results. Records progress status in `sdd-state.md` |

### Per-Command Context Injection

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

---

## Skill Details

### 1. `/reverse-spec` -- Reverse-Analyze Existing Source Code for Full Rebuild

A skill that analyzes existing source code to extract **project-level global context** needed for spec-kit-based SDD redevelopment.

#### Core Value

- **Automatic reverse-extraction** of entities, APIs, business logic, and module dependencies from existing code
- **Core scope**: Feature-level classification with **5-axis analysis-based Tier recommendations** (Tier 1 Essential / Tier 2 Recommended / Tier 3 Optional) for incremental development
- **Full scope**: Pure dependency-based ordering without Tier classification — all Features processed equally
- Generation of **hierarchical artifacts** directly usable by each spec-kit command

#### Usage

```bash
/reverse-spec [target-directory] [--scope core|full] [--stack same|new] [--name new-project-name]
```

If the argument is omitted, the current directory is analyzed.

| Option | Description |
|--------|------------|
| `--scope core` | Set implementation scope to Core (skip interactive prompt) |
| `--scope full` | Set implementation scope to Full (skip interactive prompt) |
| `--stack same` | Use the same tech stack as existing project (skip interactive prompt) |
| `--stack new` | Migrate to a new tech stack (skip interactive prompt) |
| `--name <name>` | Set new project name for identity renaming (e.g., original → new brand) |

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

**Question 3: Project Identity** (rebuild only) -- If the new project has a different name from the original (e.g., "Cherry Studio" → "Angdu Studio"), naming prefix mappings are collected and applied throughout all generated artifacts. Original project-specific names are flagged for renaming during coverage baseline classification.

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
| Sequelize | Model definitions, migrations |
| Go | Struct definitions + DB tags (GORM, sqlx) |

Information extracted per entity: Fields (name, type, constraints), Relationships (1:1, 1:N, M:N), Validation rules, State transitions, Indexes

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

Information extracted per endpoint: HTTP method/path, Request/Response schema, Authentication/Authorization requirements, Middleware

**Business Logic Extraction**: Business rules, Validations, Multi-step workflows, External integrations

**Inter-Module Dependency Mapping**: import/require analysis, Service call relationships, Shared utilities, Event-based coupling

**Source Behavior Inventory**: Exported functions, public methods, request handlers per source file — with priority classification (P1 core / P2 important / P3 nice-to-have). Prevents functionality loss by ensuring every significant behavior maps to an FR-### during specify

**UI Component Feature Extraction** (frontend/fullstack only): Third-party UI library capabilities (toolbar items, plugins, editing modes) that are configured via library options, not exported as functions. These are invisible to function-level analysis but represent significant user-facing functionality

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

Generates hierarchical artifacts based on the finalized analysis results: `roadmap.md`, `constitution-seed.md`, registries, per-Feature `pre-context.md` files, and more.

**Source Coverage Baseline (Phase 4-3, rebuild mode only)**:

After artifact generation, `/reverse-spec` measures how much of the original source code is covered by the extracted Features. An automated scan counts source files, API endpoints, DB entities, and test files, then calculates coverage ratios:

| Metric | Source | Mapped | Coverage |
|--------|--------|--------|----------|
| Source files | 1,720 | 812 | 47.2% |
| API endpoints | 24 | 25 | 96.0% |
| DB tables | 12 | 12 | 100% |
| Test files | 214 | 0 | 0% |

*(Example from a real project)*

Unmapped items are grouped by logical category (e.g., shared UI components, utilities, hooks) and presented for **interactive classification** -- the user decides for each group whether to:
- Flag as **cross-cutting concern** (noted in constitution)
- **Assign to an existing Feature**
- **Create a new Feature**
- Mark as **intentional exclusion** (with reason code)

The result is saved as `coverage-baseline.md`, which feeds into the post-pipeline [Parity Check](#parity-checking-brownfield-rebuild) to detect implementation gaps.

#### Artifact Structure

See [Global Evolution Layer Artifact Structure](#global-evolution-layer-artifact-structure) below for the complete directory tree. Key outputs: `roadmap.md`, `constitution-seed.md`, `entity-registry.md`, `api-registry.md`, `business-logic-map.md`, and per-Feature `pre-context.md` files under `features/`.

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
| Source Behavior Inventory | `/speckit-specify`, verify | Function-level behavior list with P1/P2/P3 priorities — ensures FR-### coverage |
| UI Component Features | `/speckit-specify`, `/speckit-plan`, parity | Third-party UI library capabilities (toolbar items, plugins, modes) |
| Static Resources | All | Non-code files (images, fonts, i18n) used by this Feature with source/target paths |
| Environment Variables | All | Variables this Feature requires at runtime (Feature-owned and shared) |
| For /speckit.specify | `/speckit-specify` | Existing feature summary, user scenarios, draft requirements (FR-###), draft acceptance criteria (SC-###), edge cases |
| For /speckit.plan | `/speckit-plan` | Preceding Feature dependencies, owned/referenced entity schema drafts, provided/consumed API contract drafts, technical decisions |
| For /speckit.analyze | `/speckit-analyze` | Cross-Feature verification points (entity compatibility, API contract compatibility, business rule consistency), impact scope on change |

---

### 2. `/smart-sdd` -- spec-kit SDD Workflow Orchestrator

A skill that **wraps** spec-kit commands, automatically injecting cross-Feature context at each step and maintaining the Global Evolution Layer. Supports greenfield projects, incremental Feature additions, and full rebuilds from reverse-spec artifacts.

#### Core Value

- **Four user journeys**: `init` for greenfield, `adopt` for SDD adoption, `add` for incremental, `pipeline` for rebuild
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

# SDD Adoption -- Document existing code with SDD artifacts
/smart-sdd adopt                        # Adopt pipeline: specify → plan → analyze → verify
/smart-sdd adopt --auto                 # Without stopping for confirmation
/smart-sdd adopt --from ./path          # Read artifacts from specified path

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

# SBI coverage check (rebuild/adoption only)
/smart-sdd coverage                      # Check SBI coverage and resolve gaps interactively

# Parity check (brownfield rebuild only — after pipeline completes)
/smart-sdd parity                        # Check parity against original source
/smart-sdd parity --source ./old-project # Specify source path explicitly

# Check spec-kit compatibility (independent — works from any session)
/speckit-diff                            # Auto-clone latest spec-kit from GitHub and compare
/speckit-diff --local ./spec-kit-repo    # Compare against local spec-kit source
/speckit-diff --output report.md         # Write report to file

# --auto can be combined with any command to skip confirmation
/smart-sdd specify F001 --auto
/smart-sdd pipeline --from ./path --auto
```

#### Four Project Modes

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

**Adoption Mode** (new in v2):
- **Use case**: Keep existing code, wrap it with SDD governance documents
- **Entry point**: `/reverse-spec --adopt` → `/smart-sdd adopt` (run from source directory)
- **`--adopt` flag**: Forces scope=full, stack=same, skips project renaming — existing code stays as-is
- **Pipeline**: specify → plan → analyze → verify (no tasks/implement — no code to write)
- **Feature status**: `adopted` (distinct from `completed` — signals legacy code)
- **Verify behavior**: Test failures are recorded as pre-existing issues (non-blocking)

#### How the Modes Differ in Practice

The four modes differ primarily in **how much context is available at the start**:

- **Brownfield (rebuild)** has the richest starting context. `/reverse-spec` pre-analyzes the entire codebase and extracts entities, APIs, business rules, and Feature dependencies into the Global Evolution Layer. When the pipeline runs, each step receives draft requirements, schema references, and cross-Feature context from day one. This is a **refinement-based** workflow -- spec-kit refines pre-populated drafts rather than creating from scratch.

- **Greenfield** starts with minimal context. `/smart-sdd init` creates the project structure with empty entity/API registries and simplified pre-context files (no FR/SC drafts, no business logic map). The pipeline is **generative** -- spec-kit creates requirements, schemas, and contracts from scratch. As each Feature completes its `plan` step, the registries grow, providing context for subsequent Features. This means Feature ordering matters more in greenfield: a Feature's `plan` step populates the registries that the next Feature's `plan` step will reference.

- **Brownfield (incremental)** inherits the existing project's context. `/smart-sdd add` creates new Features that can immediately reference the already-populated registries and completed Feature artifacts. It's the simplest mode -- just define new Features and resume the pipeline.

- **Brownfield (adoption)** keeps existing code as-is and wraps it with SDD governance. `/reverse-spec --adopt` extracts the Global Evolution Layer, then `/smart-sdd adopt` runs a documentation-only pipeline (specify → plan → analyze → verify, no tasks/implement). Test failures are recorded as pre-existing issues rather than blocking. Features are marked `adopted` instead of `completed`.

Key practical differences:

| Aspect | Greenfield | Brownfield (rebuild) |
|--------|-----------|---------------------|
| Entity/API registries at start | Empty -- grow as Features are planned | Pre-populated from codebase analysis |
| FR/SC drafts in pre-context | None -- created from scratch by spec-kit | Extracted from existing code -- refined by spec-kit |
| Business logic map | Not available | Available -- injected during specify |
| Cross-Feature context for early Features | Limited -- only dependency info | Rich -- full entity/API schemas from registries |
| Pipeline ordering sensitivity | High -- dependent Features need predecessors to complete plan first | Low -- all registries pre-exist |

#### Source Behavior Coverage (SBI Tracking)

For rebuild and adoption projects, `/reverse-spec` assigns unique IDs (B001, B002, ...) to each behavior in the Source Behavior Inventory. These IDs enable end-to-end tracing through the pipeline:

```
reverse-spec SBI (B###) → specify FR (FR-###) → implement → verify → coverage update
```

Each FR in `spec.md` includes a source tag (e.g., `FR-001: Email login [source: B001]`). After verify, `sdd-state.md` tracks coverage: P1 behaviors require 100% mapping regardless of scope mode.

**What gets extracted?** The domain profile (`domains/app.md` § Source Behavior Inventory) defines extraction targets, priority classification rules (P1/P2/P3), and scan patterns per tech stack. The default `app` profile extracts: exported functions, public methods, request handlers, event listeners, middleware, CLI commands.

**Extending SBI extraction**: Edit the domain profile to add extraction targets for your project's patterns. For example, add `GraphQL resolvers`, `WebSocket handlers`, `cron jobs`, `database triggers`, `state machine transitions`, or `authorization policies`. `/reverse-spec` will then scan for those patterns during source analysis. To create a profile for a new domain, follow the schema in `domains/_schema.md`.

Use `/smart-sdd coverage` anytime to check current SBI coverage and resolve gaps interactively.

#### Demo Layering

Features are grouped into Demo Groups for multi-Feature integration testing:

| Layer | Trigger | Scope |
|-------|---------|-------|
| **Feature Demo** | Each Feature verify | Single Feature functionality |
| **Integration Demo** | All Features in demo group verified | User scenario — multi-Feature journey |

Demo Groups are defined during `/reverse-spec` Phase 3 and stored in `roadmap.md`. When the last Feature in a group completes verify, an Integration Demo is triggered.

#### Aggregation Scripts

Five read-only bash scripts reduce agent context consumption by pre-aggregating artifact data:

| Script | Purpose | Used By |
|--------|---------|---------|
| `context-summary.sh` | Feature/Entity/API/DemoGroup summary | `add` Step 2 |
| `sbi-coverage.sh` | SBI coverage dashboard with `--filter` | `add` Step 4, verify post-check |
| `demo-status.sh` | Demo Group progress | `add` Step 5, verify post-check |
| `pipeline-status.sh` | Pipeline progress overview | Session orientation |
| `validate.sh` | Cross-file consistency check | After artifact updates |

#### Feature Restructuring

During pipeline execution, Feature definitions can be modified using `/smart-sdd restructure`. This command supports splitting, merging, moving requirements, changing dependencies, and deleting Features. All changes are automatically propagated to every affected artifact (roadmap, registries, pre-context files, sdd-state) with user approval before execution.

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
       4. tasks    -> /speckit-tasks (+ demo task injection check if Demo-Ready active)
       5. analyze  -> /speckit-analyze (cross-artifact consistency check before implement)
       6. implement -> Per-Feature env var check (HARD STOP if missing) -> /speckit-implement
       7. verify   -> 4-phase verification (Test/Build/Lint + Cross-Feature consistency + Demo-Ready + Global Evolution update)
       8. merge    -> Checkpoint (HARD STOP) -> Merge Feature branch to main
```

#### Post-Feature Completion Processing

Tasks automatically performed by smart-sdd at different pipeline steps:

| Timing | Processing Item | Content |
|--------|----------------|---------|
| After **plan** | entity-registry.md update | Reflect new entities/changes from `data-model.md` finalized in the plan |
| After **plan** | api-registry.md update | Reflect new APIs/changes from `contracts/` finalized in the plan |
| After **implement** | roadmap.md update | Change Feature status to `completed` |
| After **implement** | Subsequent Feature pre-context.md impact analysis | Automatically update pre-context of subsequent Features affected by changed/added entities/APIs and report to user |
| After **verify** | sdd-state.md update | Record completion time and results for each step |
| After **verify** | entity-registry/api-registry verification | Verify consistency between registries and actual implementation; update if discrepancies found |
| After **verify** | Feature branch merge | Commit all updates on the Feature branch, then merge to main after user confirmation (HARD STOP). Next Feature starts from main |

#### Pre-Implementation Analysis (analyze step)

After tasks are generated, `speckit-analyze` runs a READ-ONLY consistency check across spec.md, plan.md, and tasks.md. CRITICAL issues block implementation; other findings are informational.

#### 4-Phase Verification (verify step)

```
Phase 1: Execution Verification (Code Level) — BLOCKS on failure
    +-- Run tests, Build check, Lint check
    +-- If ANY check fails → BLOCKED, or user may "Acknowledge limited verification" (⚠️)

Phase 2: Cross-Feature Consistency + Behavior Completeness
    +-- Check cross-verification points in pre-context.md
    +-- Analyze whether shared entities/APIs changed by this Feature affect other Features
    +-- Source behavior completeness check: P1/P2 behaviors vs FR-### coverage (rebuild only)

Phase 3: Demo-Ready Verification (only if Demo-Ready Delivery is in the constitution) — BLOCKS on failure
    +-- Check demo script exists and launches a real Feature (NOT a test-only script)
    +-- Check concrete "Try it" instructions for the user (URLs, commands ≥ 2)
    +-- Run --ci health check and verify it passes
    +-- Check Demo Components header and component markers (@demo-only / @demo-scaffold)
    +-- If ANY check fails → BLOCKED, or user may "Acknowledge limited verification" (⚠️)

Phase 4: Global Evolution Update
    +-- Verify consistency between entity-registry/api-registry and actual implementation; update if discrepancies found
    +-- Record verification results in sdd-state.md (status: success / limited / failure)
```

#### Constitution Incremental Update

When new architecture principles are discovered during Feature progression:
1. Provide "Constitution update proposal" checkpoint to the user
2. If approved, perform MINOR version update via `/speckit-constitution`
3. Display warning if already completed Features are affected

#### State Tracking (`sdd-state.md`)

```
📊 Smart-SDD Progress Status

Origin: [greenfield | rebuild | adoption]
Scope: core | Active Tiers: T1
Constitution: ✅ v1.0.0 (2026-01-15)

Feature         | Tier | specify | plan | tasks | analyze | implement | verify | merge | Status
----------------|------|---------|------|-------|---------|-----------|--------|-------|----------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |   ✅    |    ✅     |   ✅   |  ✅  | completed
F002-product    | T1   |   ✅    |  🔄  |       |         |           |        |      | in_progress
F003-order      | T2   |         |      |       |         |           |        |      | 🔒 deferred
F004-payment    | T2   |         |      |       |         |           |        |      | 🔒 deferred

Active: 1/4 completed, 1/4 in progress | Deferred: 2 (Tier 2)
💡 Use /smart-sdd expand to activate deferred Features
```

The state file includes Feature Progress, Feature Detail Log, Feature Mapping (Feature ID to spec-kit Name), Global Evolution Log, Restructure Log, and Constitution Update Log. When `scope=core`, Features outside the Active Tiers are marked as `deferred` and skipped by the pipeline until activated via `/smart-sdd expand`. Features modified via `/smart-sdd restructure` are marked as `restructured` with affected steps flagged for re-execution (🔀).

#### Parity Checking (Brownfield Rebuild)

After all Features complete the pipeline in brownfield rebuild mode, run `/smart-sdd parity` to verify implementation parity against the original source.

Parity checking addresses two types of gaps:
- **Gap A (extraction gap)**: Items in the original source that `/reverse-spec` missed during analysis. Mitigated by `coverage-baseline.md` generated at the end of `/reverse-spec` analysis (Phase 4-3).
- **Gap B (implementation gap)**: Items correctly captured by `/reverse-spec` but not fully implemented during the pipeline. Detected by the `/smart-sdd parity` command.

The parity command runs in 5 phases:
1. **Structural Parity** (automated) — Parse original source for endpoints, entities, routes, tests, source behaviors, and UI component features. Compare against registries, behavior inventories, and implemented code. Filter items marked as intentional exclusions in `coverage-baseline.md`.
2. **Logic Parity** (semi-automated) — Compare `business-logic-map.md` rules against implemented FR-### mappings. Check original test cases against new tests.
3. **Gap Report** — Generate `parity-report.md` with gaps table and auto-suggested grouping.
4. **Remediation Plan** (HARD STOP per group) — User decides per group: create new Feature (via `/smart-sdd add`), intentional exclusion (6 reason codes: `deprecated`, `replaced`, `third-party`, `deferred`, `out-of-scope`, `covered-differently`), defer, or add to existing Feature.
5. **Completion Report** — Display final parity percentages and next steps.

Cross-cutting gaps (e.g., rate limiting, CORS) receive dual treatment: constitution update (architectural principle) AND infrastructure Feature (actual implementation code).

### 3. `/speckit-diff` -- Spec-Kit Version Compatibility Analyzer

A utility skill that checks whether the current spec-kit-skills are compatible with the latest spec-kit version. Works independently — no dependency on reverse-spec, smart-sdd, or any active project.

**How it works**: Auto-clones the latest spec-kit from GitHub, compares structural signatures (skill sections, template formats, script interfaces, CLI flags, directory conventions) against a stored baseline from when spec-kit-skills was last verified. Produces a clear **COMPATIBLE / NOT COMPATIBLE** verdict followed by a prioritized impact report mapping each change to specific spec-kit-skills files.

**5 analysis dimensions**: Skill changes, Template format changes, Script interface changes, Workflow sequence changes, Directory structure changes

**Priority levels**: P1 (Breaking — must fix), P2 (Compatibility — should fix), P3 (Enhancement — optional)

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
   |   +-- Entities: 8 defined, APIs: 23 defined
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

## Reference

### Path Conventions

| Target | Path | Notes |
|--------|------|-------|
| Decision history | `specs/history.md` | Auto-generated. Shared by both `/reverse-spec` and `/smart-sdd` |
| reverse-spec artifacts | `specs/reverse-spec/` | Flat structure. Can be changed via `/smart-sdd --from` |
| spec-kit feature artifacts | `specs/{NNN-feature}/` | Native spec-kit path. Not modified by smart-sdd |
| spec-kit constitution | `.specify/memory/constitution.md` | spec-kit native working path |
| smart-sdd state file | `specs/reverse-spec/sdd-state.md` | Automatically created/managed by smart-sdd |

#### Feature Naming Convention

smart-sdd and spec-kit use slightly different naming formats, but the **short-name** is always identical:

| System | Format | Example |
|--------|--------|---------|
| smart-sdd (pre-context, roadmap, state) | `F{NNN}-{short-name}` | `F001-auth` |
| spec-kit (specs/ directory, git branch) | `{NNN}-{short-name}` | `001-auth` |

Conversion: strip or prepend `F` prefix. The mapping is tracked in `sdd-state.md` → Feature Mapping table.

#### Global Evolution Layer Artifact Structure

```
specs/
├── history.md                          # Decision history (auto-generated, shared by both skills)
└── reverse-spec/
    ├── roadmap.md
    ├── constitution-seed.md
    ├── entity-registry.md
    ├── api-registry.md
    ├── business-logic-map.md           # (rebuild mode only)
    ├── stack-migration.md              # (rebuild + new stack only)
    ├── coverage-baseline.md            # (rebuild mode only — generated by /reverse-spec Phase 4-3)
    ├── parity-report.md                # (rebuild mode only — generated by /smart-sdd parity)
    ├── sdd-state.md                    # Automatically created/managed by smart-sdd
    └── features/
        ├── F001-auth/pre-context.md
        ├── F002-product/pre-context.md
        └── ...
```

> Also generates `.env.example` at the project root if environment variables were detected.

### Constitution Best Practices

The `constitution-seed.md` generated by `/reverse-spec` or `/smart-sdd init` includes the following 6 recommended development principles:

| Principle | Core | Verification Criteria |
|-----------|------|----------------------|
| **I. Test-First (NON-NEGOTIABLE)** | Write tests first. Code without tests is not considered complete. spec.md's Acceptance Scenarios are the source of test cases | All tests pass |
| **II. Think Before Coding** | No assumptions. If unclear, mark as `[NEEDS CLARIFICATION]`. Explicitly record trade-offs | Every decision has an answer to "why?" |
| **III. Simplicity First** | Implement only what is in the spec. No speculative feature additions/premature abstractions | All code is traceable to requirements |
| **IV. Surgical Changes** | No "improving" adjacent code. Only clean up orphaned code caused by your own changes | Changed lines are traceable to tasks |
| **V. Goal-Driven Execution** | Verifiable completion criteria required. "implement" leads to "tests pass" | Automated verification passes |
| **VI. Demo-Ready Delivery** | Each Feature must ship with an **executable demo script** (`demos/F00N-name.sh`) that launches the real Feature, prints "Try it" instructions, and keeps running until Ctrl+C. `--ci` flag for automated health check. Demo code uses `@demo-only` / `@demo-scaffold` markers. Limited verification (⚠️) available when external dependencies block Phase 1/3 | `./demos/F00N-name.sh` launches the Feature — user sees, uses, and interacts with it |

### Relationship with spec-kit

| Aspect | spec-kit | spec-kit-skills |
|--------|----------|-----------------|
| **Role** | Feature-local SDD execution framework | Global Evolution Layer augmentation |
| **Scope** | Spec/Plan/Tasks consistency within individual Features | Cross-Feature dependencies, release evolution, cross-references |
| **Relationship** | Operates independently | Wraps spec-kit. Does not replace spec-kit commands |
| **Coupling** | Fully functional without spec-kit-skills | Requires spec-kit |
| **Compatibility** | Unaffected by spec-kit updates | Supplements via Constitution principles + artifacts, independent of spec-kit version |

#### Using reverse-spec Artifacts with Plain spec-kit (without smart-sdd)

You can use reverse-spec artifacts directly with spec-kit commands without smart-sdd. Paste the relevant sections from reverse-spec artifacts into your conversation, then invoke the spec-kit command — Claude will use the context.

| Command | What to Paste Before Invoking |
|---------|------------------------------|
| `/speckit-constitution` | Full contents of `constitution-seed.md` |
| `/speckit-specify` | `pre-context.md` "For /speckit.specify" section + `business-logic-map.md` Feature section + Source Reference section |
| `/speckit-plan` | `pre-context.md` "For /speckit.plan" section + `entity-registry.md` + `api-registry.md` + preceding Feature's finalized `data-model.md` / `contracts/` if available |
| `/speckit-tasks`, `/speckit-implement` | No additional context needed (operate on spec-kit's own outputs). Check `pre-context.md` for Static Resources and Environment Variables |
| `/speckit-analyze` | `pre-context.md` "For /speckit.analyze" section + `entity-registry.md` + `api-registry.md` |

**What you lose**: automatic context assembly/filtering, auto-updates to registries and roadmap, pipeline state tracking (`sdd-state.md`), preceding Feature result priority, per-Feature env var verification, and Feature branch management.

### Domain Profiles (Planned)

Currently optimized for **application development** (backend, frontend, fullstack, mobile, library). Domain-specific analysis profiles for **data science**, **AI/ML**, **embedded systems**, and other specialized domains are planned.

**Design philosophy**: The skill architecture separates concerns into three layers:

```
Core Workflow (domain-agnostic)     ← Phases, checkpoints, pipeline orchestration
    ↓ reads
Domain Profile (swappable)          ← Analysis axes, extraction patterns, demo/verify conventions
    ↓ applies to
Tech Stack (detected at runtime)    ← Framework-specific file patterns, ORM types, API styles
```

Changing the domain profile changes *what* gets analyzed and *how* artifacts are structured, without altering the underlying workflow engine. Each project uses a single domain profile — hybrid domains (e.g., AI-serving apps) receive dedicated profiles rather than composing multiple profiles.

The `domains/` directory in each skill contains the profile schema (`_schema.md`) and existing profiles. Use `--domain` to select a profile (default: `app`).

### Project Structure

```
spec-kit-skills/
└── .claude/
    └── skills/
        ├── reverse-spec/
        │   ├── SKILL.md                                 # Main skill definition (overview + routing)
        │   ├── commands/
        │   │   └── analyze.md                           # Pre-Phase + 5-Phase analysis workflow
        │   ├── domains/                                 # Domain-specific analysis profiles
        │   │   ├── _schema.md                           # Domain profile schema
        │   │   ├── app.md                               # Application domain (default)
        │   │   └── data-science.md                      # Data science domain (template)
        │   ├── templates/
        │   │   ├── roadmap-template.md                  # Feature evolution map template
        │   │   ├── entity-registry-template.md           # Shared entity registry template
        │   │   ├── api-registry-template.md              # API contract registry template
        │   │   ├── business-logic-map-template.md        # Business logic map template
        │   │   ├── constitution-seed-template.md         # Constitution draft template
        │   │   ├── coverage-baseline-template.md        # Source coverage baseline template
        │   │   ├── pre-context-template.md               # Per-Feature cross-reference info template
        │   │   └── stack-migration-template.md           # Stack migration plan template
        │   └── reference/
        │       └── speckit-compatibility.md              # spec-kit integration guide
        ├── smart-sdd/
        │   ├── SKILL.md                                 # Main skill definition (orchestrator)
        │   ├── commands/                                # Per-command workflow details
        │   │   ├── init.md                              # Greenfield setup workflow
        │   │   ├── add.md                               # Brownfield incremental workflow
        │   │   ├── pipeline.md                          # Pipeline + step mode workflows
        │   │   ├── adopt.md                              # SDD adoption pipeline workflow
        │   │   ├── coverage.md                          # SBI coverage check & gap resolution
        │   │   ├── restructure.md                       # Feature restructuring workflow
        │   │   ├── expand.md                            # Tier expansion workflow
        │   │   └── parity.md                            # Source parity verification
        │   ├── scripts/                                    # Read-only aggregation scripts
        │   │   ├── context-summary.sh
        │   │   ├── demo-status.sh
        │   │   ├── pipeline-status.sh
        │   │   ├── sbi-coverage.sh
        │   │   └── validate.sh
        │   ├── domains/                                 # Domain-specific behavior profiles
        │   │   ├── _schema.md                           # Domain profile schema
        │   │   ├── app.md                               # Application domain (default)
        │   │   └── data-science.md                      # Data science domain (template)
        │   └── reference/
        │       ├── context-injection-rules.md            # Shared injection patterns
        │       ├── injection/                            # Per-command context injection rules
        │       │   ├── constitution.md
        │       │   ├── specify.md                       # Includes Clarify
        │       │   ├── plan.md
        │       │   ├── tasks.md
        │       │   ├── analyze.md
        │       │   ├── implement.md
        │       │   ├── verify.md
        │       │   ├── adopt-specify.md                   # Adoption-mode specify injection
        │       │   ├── adopt-plan.md                      # Adoption-mode plan injection
        │       │   ├── adopt-verify.md                    # Adoption-mode verify injection
        │       │   └── parity.md
        │       ├── state-schema.md                      # sdd-state.md schema definition
        │       └── branch-management.md                 # Git branch management reference
        ├── speckit-diff/
        │   ├── SKILL.md                                 # Compatibility analyzer skill (overview + routing)
        │   ├── commands/
        │   │   └── diff.md                              # 4-Phase diff workflow
        │   └── reference/
        │       └── integration-surface.md               # Spec-kit baseline (structural signatures)
        └── case-study/
            ├── SKILL.md                                 # Case Study generator skill (overview + routing)
            ├── commands/
            │   ├── init.md                              # Auto-init logic (used internally by other skills)
            │   └── generate.md                          # Generate Case Study report
            ├── reference/
            │   └── recording-protocol.md                # Milestone-based recording guide
            └── templates/
                └── case-study-log-template.md            # Observation log template
```

### Maintenance

#### Spec-Kit Compatibility Baseline

When modifying spec-kit-skills (smart-sdd, reverse-spec, or their reference files), always check whether the changes affect spec-kit integration points. If spec-kit itself has been updated, run `/speckit-diff` to identify required changes.

After applying changes for a new spec-kit version, **update the baseline**:
1. Run `/speckit-diff` to verify all changes are applied (verdict should be COMPATIBLE)
2. Update `.claude/skills/speckit-diff/reference/integration-surface.md` to reflect the new spec-kit version
3. Commit the updated baseline together with the spec-kit-skills changes

#### Design Decision History (`history.md`)

The `history.md` file records architectural and design decisions made throughout the project's development. It serves two purposes:

**1. For contributors developing spec-kit-skills**

Understanding *why* the project is structured the way it is. Each entry documents the decision, the choice made, and the rationale — making it easier to maintain consistency when adding new features or modifying existing behavior.

**2. For users applying spec-kit-skills to their projects**

Understanding the design philosophy behind the skills' behavior. For example, why HARD STOPs are inescapable, why demo scripts must be executable (not markdown), or why 5-axis Tier classification was chosen over simpler approaches.

Key topics covered:

| Date | Topic |
|------|-------|
| 2026-02-28 | Initial architecture, HARD STOP philosophy, three project modes |
| 2026-03-01 | Demo-ready delivery, scope system (core/full), Feature granularity |
| 2026-03-02 | Pipeline hardening, Feature restructure protocol |
| 2026-03-03 | Review system overhaul, parity checking system |
| 2026-03-04 | speckit-diff utility, domain profile system, context optimization |
| 2026-03-05 | Unified commands/ structure, case-study skill |
| 2026-03-06 | **v2 redesign**: user intent model, adopt command, demo layering, SBI coverage tracking, script architecture ([design doc](v2-design.md)) |

> When making significant design decisions, add an entry to `history.md` to preserve the rationale for future reference.

---

### Case Study Workflow

The `/case-study` skill generates structured reports from SDD workflow execution.

> `case-study-log.md` (qualitative observations) is auto-created at the project root. Milestone entries (M1-M8) are appended automatically during workflow execution. If the log doesn't exist, the report is generated without qualitative sections.

```
Step 1: Run the SDD workflow (case-study-log.md is auto-created at project root)
  /reverse-spec ./source-code         → Auto-records M1-M4 milestones
  /smart-sdd pipeline                 → Auto-records M5-M8 milestones per Feature

Step 2: Generate the report
  /case-study                                      → English → case-study-YYYYMMDD-HHMM.md
  /case-study --lang ko                            → Korean → case-study-YYYYMMDD-HHMM.md
```

The report combines **quantitative data** (automatically extracted from sdd-state.md, registries, and spec-kit artifacts) with **qualitative observations** (manually recorded at 8 milestones during execution). Even without observations, a metrics-only report is generated from the available artifacts.
