---
name: reverse-spec
description: Reverse-analyzes existing source code to extract the Global Evolution Layer (roadmap.md + supporting artifacts) for spec-kit SDD redevelopment. A Reverse Specification skill that extracts specs from existing implementations.
argument-hint: [target-directory] [--scope core|full] [--stack same|new]
disable-model-invocation: true
allowed-tools: [Read, Grep, Glob, Bash, Write, Task, AskUserQuestion]
---

# Reverse-Spec: Existing Source Code → spec-kit Global Evolution Layer Extraction

Analyzes existing source code to extract project-level global context needed for spec-kit-based SDD (Spec-Driven Development) redevelopment.

**Target Directory** (source to analyze): First positional argument from `$ARGUMENTS` (defaults to the current directory if not specified)
**Output Directory** (where artifacts are written): Always the **current working directory** (CWD) where the skill was invoked — NOT the target directory. The target directory is read-only; no files are written there.

**Argument Parsing**:
```
$ARGUMENTS parsing rules:
  Positional    → target-directory (path to analyze, defaults to "." if not specified)
  --scope <val> → Implementation scope: "core" or "full" (skips Phase 0 Question 1 if provided)
  --stack <val> → Tech stack strategy: "same" or "new" (skips Phase 0 Question 2 if provided)
```

Execute the following 5 Phases in order. Report progress to the user after completing each Phase.

---

## Phase 0 — Strategy Questions

Determine the direction of the deliverables. Each question can be answered via CLI arguments OR interactive prompt.

### Question 1: Implementation Scope
- If `--scope` argument is provided: use the specified value (`core` or `full`).
- Otherwise: Ask the user via AskUserQuestion:
  - **Core Only (Core)**: Redevelop only the core features that form the foundation of the project. For learning/prototyping purposes
  - **Full Implementation (Full)**: Redevelop the full set of features identical to the existing system

### Question 2: Tech Stack Strategy
- If `--stack` argument is provided: use the specified value (`same` or `new`).
- Otherwise: Ask the user via AskUserQuestion:
  - **Same Stack (Same)**: Use the same language, framework, and libraries as the existing project
  - **New Stack (New)**: Migrate to an optimal modern tech stack

Record both responses and reference them throughout all subsequent Phases.

> **Note**: When running with `--dangerously-skip-permissions`, AskUserQuestion may be auto-skipped. Always provide `--scope` and `--stack` arguments in such environments to ensure correct strategy selection.

---

## Phase 1 — Project Scan

Identify the overall structure and tech stack of the target directory.

### 1-1. Directory Structure Exploration
- Use Glob to search for major file patterns: `**/*.{py,js,ts,jsx,tsx,java,go,rs,rb,php,cs,kt,swift}` etc.
- Identify the top-level directory structure
- Identify exclusion targets such as `.gitignore`, `node_modules/`, `venv/`, etc.

### 1-2. Tech Stack Detection
Read configuration files to identify the tech stack:

| Detection Target | Files to Search |
|------------------|-----------------|
| Language/Version | `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `build.gradle`, `pom.xml`, `Gemfile`, `composer.json`, `.python-version`, `.nvmrc`, `.tool-versions` |
| Framework | Identify frameworks from dependency lists (React, Next.js, Django, FastAPI, Spring, Express, Rails, etc.) |
| DB/Storage | ORM configuration, migration files, connection settings |
| Testing | Test framework configuration, test directory structure |
| Build/Deploy | Dockerfile, docker-compose, CI/CD configuration, Makefile |

### 1-3. Project Type Classification
Classify the project type based on the collected information:
- **backend**: API server, service
- **frontend**: SPA, SSR web app
- **fullstack**: Backend + Frontend integrated
- **mobile**: iOS/Android app
- **library**: Reusable library/package

### 1-4. Module/Package Boundary Identification
- Identify logical module boundaries from the directory structure
- For monorepos, identify workspace/package boundaries
- Estimate the role of each module

Upon completing Phase 1, report a summary of the detected tech stack and project structure to the user.

---

## Phase 2 — Deep Analysis

Perform deep analysis using patterns appropriate to the tech stack identified in Phase 1. For large codebases, leverage parallel sub-agents via the Task tool.

### 2-1. Data Model Extraction
Extract entities from appropriate sources depending on the tech stack:

| Technology | Search Targets |
|------------|----------------|
| Django | `models.py`, migrations |
| SQLAlchemy/FastAPI | Model classes, Alembic migrations |
| TypeORM/Prisma | Entity classes, `schema.prisma` |
| Sequelize | Model definitions, migrations |
| JPA/Hibernate | `@Entity` classes |
| Mongoose | Schema definitions |
| Go | struct definitions + DB tags |
| Rails | `app/models/`, migrations |

Information to extract from each entity:
- Entity name, fields (name, type, constraints)
- Relationships (1:1, 1:N, M:N, target entity)
- Validation rules
- State transitions (enum, state machine)
- Indexes, unique constraints

### 2-2. API Endpoint Extraction
Extract APIs from appropriate sources depending on the tech stack:

| Technology | Search Targets |
|------------|----------------|
| Express/Fastify | Router files, `app.use()`, `router.get()`, etc. |
| Django/DRF | `urls.py`, ViewSet, APIView |
| FastAPI | `@app.get()`, `@router.post()`, etc. decorators |
| Spring | `@RequestMapping`, `@GetMapping`, etc. |
| Rails | `config/routes.rb`, controllers |
| Next.js/Nuxt | `pages/api/`, `app/api/` directories |
| Go (net/http, Gin, Echo) | Router registration, handler functions |

Information to extract from each endpoint:
- HTTP method, path
- Request parameters, body schema
- Response schema (per status code)
- Authentication/authorization requirements
- Middleware/interceptors

### 2-3. Business Logic Extraction
Extract from the service layer, utilities, and domain logic:
- **Business Rules**: Conditional logic, policy enforcement, calculation logic
- **Validation**: Input validation, state transition conditions, business constraints
- **Workflows**: Multi-step processes, state machines, event chains
- **External Integrations**: External API calls, message queues, event publishing/subscribing

### 2-4. Inter-Module Dependency Mapping
- Analyze import/require statements to identify dependencies between modules
- Service call relationships (dependency injection, direct calls)
- Shared utilities, common type usage relationships
- Event/message-based coupling relationships

Upon completing Phase 2, report a summary of the number of entities, APIs, and business rules discovered.

---

## Phase 3 — Feature Classification and Importance Analysis

### 3-1. Feature Boundary Identification
Identify logical functional units (Features) based on the Phase 2 analysis results:
- Domain module boundaries (e.g., auth, product, order, payment)
- Service boundaries (in the case of microservice architectures)
- Route groups (based on API path prefixes)
- Entity clusters (groups of closely related entities)

Define the following for each Feature:
- Feature name (concise English name)
- Description (1-2 sentences)
- List of associated files
- Owned entities
- Provided APIs

> Do not assign Feature IDs at this point. IDs will be assigned based on topological sort after constructing the dependency graph in 3-2.

### 3-2. Dependency Graph Construction and Feature ID Assignment
Derive inter-Feature dependencies:
- **Direct Dependency**: Uses another Feature's modules via import/require
- **API Dependency**: Calls APIs provided by another Feature
- **Entity Dependency**: References entities owned by another Feature
- **Event Dependency**: Subscribes to events published by another Feature

Record dependency directions and types, and visualize them as a Mermaid diagram.

**Feature ID Assignment Rules**:
Assign Feature IDs in the order determined by topological sort of the dependency graph.
- Features with no dependencies (zero preceding dependencies) receive the lowest numbers
- Features at the same level are assigned in descending Tier order (Tier 1 → 2 → 3)
- As a result, the F001, F002, ... sequence directly represents the **feasible implementation order**
- These numbers also correspond to spec-kit's `specs/{NNN-feature}/` directory names (e.g., F001-auth → `specs/001-auth/`)

### 3-3. Importance Analysis and Tier Classification

First, identify the project domain: understand what kind of system the project is (e-commerce, SaaS, CMS, education platform, financial service, etc.) and determine which features are foundational within that domain.

Evaluate each Feature comprehensively across 5 analysis axes:

**Analysis Axis 1 — Structural Foundation**
- Can other Features not exist without this Feature?
- Basis for judgment: Number of reverse dependencies, import depth, number of shared entities owned

**Analysis Axis 2 — Domain Core**
- Is this feature directly tied to the project's reason for existence?
- Basis for judgment: Role within the project domain (e.g., for e-commerce, products/orders are core)

**Analysis Axis 3 — Data Ownership**
- Does this feature define and manage core entities?
- Basis for judgment: Number of owned entities, ratio of entities referenced by other Features

**Analysis Axis 4 — Integration Hub**
- Is this a connection point with other Features/external systems?
- Basis for judgment: Role as API provider, number of external integrations, number of events published

**Analysis Axis 5 — Business Complexity**
- Are core business rules concentrated in this feature?
- Basis for judgment: Number of business rules, number of state transitions, validation complexity

Assign each Feature to a Tier based on the comprehensive evaluation results:

| Tier | Meaning | Criteria |
|------|---------|----------|
| **Tier 1 (Essential)** | Foundation of the project. The system cannot function without it | Must be included in redevelopment |
| **Tier 2 (Recommended)** | Features that complete the core user experience | System works without them but core value is significantly diminished |
| **Tier 3 (Optional)** | Supplementary features, admin tools, convenience features | Can be added in later phases |

For each Feature, a **specific rationale** for the assigned Tier must be provided.
Examples:
- "Auth recommended as Tier 1: 7 Features directly depend on it, owns the User entity, used as middleware for all APIs"
- "Notification recommended as Tier 3: Independent module with no reverse dependencies, loosely coupled via event subscription"

Present the classification results to the user via AskUserQuestion and obtain approval/adjustments. If AskUserQuestion is unavailable (e.g., `--dangerously-skip-permissions` environment), display the results and proceed with the proposed classification.

### 3-4. Stack Strategy Details (Only if "New Stack" was selected in Phase 0)

This step determines the concrete new tech stack. Skip entirely if "Same Stack" was selected.

**Step 1 — Current Stack Summary Table**:
Present the current stack detected in Phase 1 as a categorized table:

| Category | Current Technology | Version | Usage Context |
|----------|--------------------|---------|---------------|
| Language | e.g., Python | 3.10 | Backend |
| Framework | e.g., Django | 4.2 | Web framework |
| ORM/DB | e.g., PostgreSQL + Django ORM | 14 | Data layer |
| Frontend | e.g., React | 18 | SPA |
| Testing | e.g., pytest | 7.x | Unit/Integration |
| Build/Deploy | e.g., Docker + GitHub Actions | — | CI/CD |

**Step 2 — Recommended Stack Proposal**:
For each category, propose 1~2 modern alternatives with rationale:

| Category | Current | Recommended | Alternative | Rationale |
|----------|---------|-------------|-------------|-----------|
| Language | Python 3.10 | TypeScript 5.x | Go 1.22 | [Pros: type safety, ecosystem. Cons: migration cost] |
| Framework | Django 4.2 | Next.js 14 (App Router) | Fastify | [Pros/cons/migration complexity] |
| ... | ... | ... | ... | ... |

For each recommendation, briefly evaluate:
- **Pros**: Why this is a good fit for the project
- **Cons**: Trade-offs, learning curve, ecosystem gaps
- **Migration complexity**: Low / Medium / High — what makes migration easier or harder

**Step 3 — User Confirmation (HARD STOP)**:
Present the proposal table and ask the user via AskUserQuestion:
- "Approve recommended stack as-is"
- "Choose alternatives for some categories"
- "Propose a different stack"

**You MUST STOP and WAIT for the user's response.** Do NOT auto-approve or proceed without explicit user input.

If the user chooses alternatives or proposes changes, update the table accordingly and re-confirm.

**Step 4 — Finalize**:
Record the finalized stack decisions. These will be used in:
- Phase 4: `stack-migration.md` generation
- Phase 4: `constitution-seed.md` (New Stack Strategy section)
- Phase 4: Each Feature's `pre-context.md` (New Stack reference sections)

---

## Phase 4 — Deliverable Generation

Generate hierarchical deliverables from the finalized analysis results. Create a `specs/reverse-spec/` directory in the **current working directory** (CWD), NOT in the target directory. The target directory is the source being analyzed and must remain untouched.

### 4-1. Project-Level Deliverables

Generate the following files in order. Each file follows the template structure found in this skill's `templates/` directory.

1. **`specs/reverse-spec/roadmap.md`** — See [roadmap-template.md](templates/roadmap-template.md)
   - Project Overview, Rebuild Strategy, Feature Catalog (by Tier), Dependency Graph, Release Groups, Cross-Feature Dependencies

2. **`specs/reverse-spec/entity-registry.md`** — See [entity-registry-template.md](templates/entity-registry-template.md)
   - Complete entity list, fields, relationships, validation rules, cross-Feature sharing mapping

3. **`specs/reverse-spec/api-registry.md`** — See [api-registry-template.md](templates/api-registry-template.md)
   - Complete API endpoint index, detailed contracts, cross-Feature dependencies

4. **`specs/reverse-spec/business-logic-map.md`** — See [business-logic-map-template.md](templates/business-logic-map-template.md)
   - Business rules per Feature, validation, workflows, cross-Feature rules

5. **`specs/reverse-spec/constitution-seed.md`** — See [constitution-seed-template.md](templates/constitution-seed-template.md)
   - Source code reference principles (branching by stack strategy), extracted architecture principles, technical constraints, coding conventions

6. **`specs/reverse-spec/stack-migration.md`** (only for New Stack strategy) — See [stack-migration-template.md](templates/stack-migration-template.md)
   - Current → New mapping per technology component, migration rationale, per-Feature migration notes, risks and mitigations

### 4-2. Feature-Level Deliverables

For each Feature, generate `specs/reverse-spec/features/[Feature-ID]-[feature-name]/pre-context.md`. See [pre-context-template.md](templates/pre-context-template.md).

Contents to include in each pre-context.md:
- **Source Reference**: List of related original files + reference guide by stack strategy
- **For /speckit.specify**: Existing feature summary, draft requirements (FR-###), draft acceptance criteria (SC-###)
- **For /speckit.plan**: Preceding Feature dependencies, related entity/API contract drafts, technical decisions
- **For /speckit.analyze**: Cross-Feature verification points

### 4-3. Completion Report

Report the complete list of generated deliverables and next-step guidance to the user:

```
Generation complete:
- specs/reverse-spec/roadmap.md
- specs/reverse-spec/constitution-seed.md
- specs/reverse-spec/entity-registry.md
- specs/reverse-spec/api-registry.md
- specs/reverse-spec/business-logic-map.md
- specs/reverse-spec/features/F001-xxx/pre-context.md
- specs/reverse-spec/features/F002-xxx/pre-context.md
- ...

Next steps:
  /smart-sdd pipeline       — Run the full SDD pipeline (recommended)
  /smart-sdd pipeline --auto — Run without stopping for per-step confirmation

smart-sdd will automatically:
  1. Finalize constitution based on constitution-seed.md
  2. Progress Features in Release Group order (specify → plan → tasks → implement → verify)
  3. Inject cross-Feature context from pre-context.md and registries at each step
  4. Update entity-registry.md and api-registry.md as Features are completed
```

---

## Notes

- For large codebases (1000+ files), distribute model/API/logic extraction across parallel sub-agents using the Task tool in Phase 2.
- Exclude binary files, build artifacts, node_modules, venv, etc. from analysis.
- Report a progress summary to the user upon completing each Phase.
- Write entity/API formats in deliverables to be compatible with spec-kit's data-model.md and contracts/ style.
- Refer to [speckit-compatibility.md](reference/speckit-compatibility.md) for the spec-kit integration guide.
