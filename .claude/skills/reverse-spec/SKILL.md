---
name: reverse-spec
description: Reverse-analyzes existing source code to extract the Global Evolution Layer (roadmap.md + supporting artifacts) for spec-kit SDD redevelopment. A Reverse Specification skill that extracts specs from existing implementations.
argument-hint: "[target-directory] [--scope core|full] [--stack same|new] [--name new-project-name] [--domain app]"
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
  --name <val>  → New project name (skips Phase 0 Question 3 if provided; implies rename from detected project name)
  --domain <val> → Project domain profile: "app" (default). Determines analysis axes, registries, and Feature boundary heuristics
```

Execute the following phases in order. Report progress to the user after completing each Phase.

---

## Pre-Phase — Git Repository Setup

Before starting analysis, ensure the CWD (output directory) has a git repository. This enables branch-based workflow management throughout the SDD pipeline.

**Step 1 — Check existing git repo**:
Run `git rev-parse --is-inside-work-tree` in CWD.

- **If git repo already exists**: Skip to Step 3 (branch option).
- **If no git repo**: Proceed to Step 2.

**Step 2 — Initialize git repo**:
1. Run `git init` in CWD
2. Create a `.gitignore` with sensible defaults for the detected tech stack:
   - Always include: `node_modules/`, `.env`, `.env.*`, `__pycache__/`, `*.pyc`, `.DS_Store`, `dist/`, `build/`, `.venv/`, `venv/`
   - Add stack-specific entries based on the target project's tech stack (detected from config files in the target directory):
     - Node.js: `node_modules/`, `coverage/`, `.next/`, `.nuxt/`
     - Python: `__pycache__/`, `*.egg-info/`, `.venv/`
     - Go: vendor/ (if not using modules)
     - Java: `target/`, `*.class`, `.gradle/`
     - Rust: `target/`
   - If tech stack is not yet known (target not analyzed), use the universal defaults only
3. Display: "✅ Git repository initialized with .gitignore"

**Step 3 — Branch option (HARD STOP)**:
Ask the user via AskUserQuestion whether to work on the current branch or create a dedicated branch:
- "Stay on current branch (Recommended)" — Continue on the current branch (usually `main`)
- "Create a new branch" — Create and checkout a new branch for the SDD work

**If response is empty → re-ask.** If the user selects "Create a new branch", ask for the branch name via "Other" input (suggest `sdd-setup` as default).

> **`--dangerously-skip-permissions` mode**: Skip branch question. Stay on current branch.

---

## Domain Profile

The `--domain` argument selects the domain profile that governs domain-specific behavior throughout all Phases. Default: `app`.

**Loading**: Read `domains/{domain}.md` before starting Phase 1. The profile defines:
- **Analysis Axes** (Phase 2): What to extract during deep analysis
- **Project Type Classification** (Phase 1): How to classify the project
- **Registries** (Phase 4): Which registry files to generate
- **Feature Boundary Heuristics** (Phase 3): How to identify Feature boundaries
- **Tier Classification Axes** (Phase 3): How to evaluate Feature importance (core scope)

For the default `app` domain, detailed extraction patterns for each technology stack are defined in `domains/app.md`.

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

### Question 3: Project Identity (rebuild only)

When analyzing existing source code for rebuild, the original project's naming (class names, service names, branding) will appear throughout the codebase. If the new project has a different identity, this must be captured early so artifacts use the correct naming.

Ask via AskUserQuestion:
- "Is the new project name different from the original?"
  - **Yes — new name**: User provides the new project name (e.g., "Cherry Studio" → "Angdu Studio")
  - **No — same name**: Keep the original project name as-is

If the user selects "Yes":
1. Record the **original project name** and **new project name**
2. Ask the user to provide **naming prefix mappings** if applicable (e.g., `Cherry` → `Angdu`, `CS` → `AS`). These are optional — the user can skip if they want to decide later.
3. Store these mappings for use in:
   - **Phase 4 artifacts**: Replace original project name references with the new name in `roadmap.md`, `constitution-seed.md`, and `pre-context.md` descriptions
   - **Phase 4-3 coverage baseline**: When classifying unmapped items, highlight items containing the original project name prefix (e.g., "CherryINOAuth") and suggest renamed versions (e.g., "AngduINOAuth" or "INOAuth")
   - **constitution-seed.md**: Include a "Naming Conventions" section documenting the old → new mapping

> **Note**: This question can be skipped via `--name <new-name>` argument. If `--dangerously-skip-permissions` is set without `--name`, the original project name is kept as-is.

### Decision History Recording — Strategy

After all Phase 0 questions are answered, **append** to `specs/history.md` (create if it doesn't exist with this header):

```markdown
# Decision History

> Auto-generated during `/reverse-spec` and `/smart-sdd` execution.
> Records key strategic and architectural decisions with rationale.
```

Add a dated section under the header:

```markdown
---

## [YYYY-MM-DD] /reverse-spec — Project Setup

### Strategy Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scope | core / full | [user's reason if stated, otherwise "—"] |
| Stack | same / new | [user's reason if stated, otherwise "—"] |
| Project Identity | [original] → [new] / Same | [user's reason if stated, otherwise "—"] |
```

**Rules**: APPEND only — never overwrite existing entries. One row per decision. Record the user's reasoning if stated; write "—" if not.

---

## Phase 1 — Project Scan

Identify the overall structure and tech stack of the target directory.

### 1-1. Directory Structure Exploration
- Use Glob to search for major file patterns: `**/*.{py,js,ts,jsx,tsx,java,go,rs,rb,php,cs,kt,swift}` etc.
- Identify the top-level directory structure
- Identify exclusion targets such as `.gitignore`, `node_modules/`, `venv/`, etc.

### 1-2. Tech Stack Detection
Read configuration files to identify the tech stack. See `domains/{domain}.md` § Tech Stack Detection for the detection-target-to-file mapping.

### 1-3. Project Type Classification
Classify the project type based on the collected information. Use the project types defined in `domains/{domain}.md` § Project Type Classification.

### 1-4. Module/Package Boundary Identification
- Identify logical module boundaries from the directory structure
- For monorepos, identify workspace/package boundaries
- Estimate the role of each module

### 1-5. Static Resource Inventory
Identify non-code resource files that must be **copied as-is** to the new project (these cannot be regenerated through code):

| Resource Type | Search Patterns |
|---------------|-----------------|
| Images | `**/*.{png,jpg,jpeg,gif,svg,ico,webp,avif}` |
| Fonts | `**/*.{woff,woff2,ttf,otf,eot}` |
| Media | `**/*.{mp4,mp3,wav,ogg,webm}` |
| Documents | `**/*.{pdf,doc,docx}` (if used as app assets) |
| Localization | `**/*.{json,yaml,yml}` in `locales/`, `i18n/`, `translations/` directories |
| Configuration | Environment templates (`.env.example`), deployment configs used at runtime |
| Other static | Files in `public/`, `static/`, `assets/`, `resources/` directories |

For each discovered resource directory/group, record:
- **Directory path** and approximate file count
- **Usage context**: Where/how these resources are referenced in the code (e.g., imported in components, served statically, bundled by build tool)
- **Feature association**: Which Feature(s) use these resources

Exclude: `node_modules/`, build output (`dist/`, `build/`), generated files, test fixtures.

Upon completing Phase 1, report a summary of the detected tech stack, project structure, and static resource inventory to the user.

### 1-6. Stack Strategy Details (Only if "New Stack" was selected in Phase 0)

This step determines the concrete new tech stack **immediately after detecting the current stack**, so the user has a clear direction before deep analysis begins. Skip entirely if "Same Stack" was selected.

**Step 1 — Current Stack Summary**:
Present the current stack detected in Phase 1 as a categorized table:

| Category | Current Technology | Version | Usage Context |
|----------|--------------------|---------|---------------|
| Language | e.g., Python | 3.10 | Backend |
| Framework | e.g., Django | 4.2 | Web framework |
| ORM/DB | e.g., PostgreSQL + Django ORM | 14 | Data layer |
| Frontend | e.g., React | 18 | SPA |
| Testing | e.g., pytest | 7.x | Unit/Integration |
| Build/Deploy | e.g., Docker + GitHub Actions | — | CI/CD |

Adapt the categories to match the actual project. Add or remove rows as needed (e.g., add "State Management", "Editor", "AI/ML SDK" if relevant; remove "Frontend" if the project is backend-only).

**Step 2 — Per-Category Stack Negotiation (HARD STOP per category)**:

You MUST iterate through **every single category** from Step 1's table, **one at a time**, and call AskUserQuestion for each. There is no exception to this rule.

**PROHIBITED behaviors:**
- ❌ Batching multiple categories into a single question
- ❌ Deciding on behalf of the user that a category is "already optimal" or "already modern"
- ❌ Showing a summary table with "Keep" pre-filled for categories the user never confirmed
- ❌ Saying "All other categories: Keep current" — the user MUST confirm each one
- ❌ Presenting only "migration candidates" while skipping stable categories

**The ONLY way to skip remaining categories** is when the user explicitly selects the "Accept all remaining recommendations" option in AskUserQuestion. The agent NEVER decides to skip.

For each category (one at a time, in dependency order):
1. Show the current technology, 1~2 alternatives, AND "Keep Current" with rationale for each:
   ```
   📋 [Category]: [Current Technology] → ? (constrained by: [confirmed choices])

   | Option | Technology | Rationale |
   |--------|-----------|-----------|
   | Recommended | [Tech A] | [Why this fits, migration complexity] |
   | Alternative | [Tech B] | [Trade-offs vs recommended] |
   | Keep Current (Recommended) | [Current] | [Why keeping makes sense — mark as Recommended if current is optimal] |
   ```
   When the current technology IS the best choice, mark "Keep Current" as "(Recommended)" and still provide 1~2 alternatives so the user can see what other options exist.
2. Call AskUserQuestion with options:
   - "[Recommended option] (Recommended)" — could be a new tech OR "Keep [Current]" if current is best
   - "[Alternative Tech]"
   - "[Keep/Change option]" — whichever wasn't already listed as Recommended
   - "Accept all remaining recommendations" — skip subsequent categories and auto-apply recommended for each
3. **STOP and WAIT** for the user's response before moving to the next category. **If response is empty → re-ask.**
4. If the user selects "Other", accept their custom input and record it.
5. If the user selects "Accept all remaining recommendations", stop the per-category loop. Apply the recommended option for every remaining category and proceed directly to Step 3 (Final Summary and Confirmation), where the user can still review and revise if needed.

**Category dependency chain**: Categories have cascading constraints — each choice narrows the viable options for subsequent categories. Process them in this dependency order:

```
Language ──→ Framework ──→ ORM/DB ──→ Testing
                │                       │
                ├──→ State Mgmt         │
                ├──→ UI Library         │
                └──→ Build/Deploy ──────┘
```

1. **Language** — Constrains everything. Must be decided first.
2. **Framework** — Constrained by Language. (e.g., TypeScript → Next.js/Nuxt/Fastify, not Django)
3. **ORM/DB** — Constrained by Language + Framework. (e.g., TypeScript + Next.js → Prisma/Drizzle, not SQLAlchemy)
4. **Remaining categories** — Constrained by the above. (e.g., Framework choice determines viable state management, UI library, and testing options)

**Critical rule**: When presenting options for each category, **only propose technologies that are compatible with all previously confirmed choices**. Explicitly state why the recommendations fit the already-decided stack.

```
📋 [Category]: [Current] → ? (constrained by: [list confirmed choices])

| Option | Technology | Rationale |
|--------|-----------|-----------|
| Recommended | [Tech A] | [Why this fits with confirmed Language + Framework + ...] |
| Alternative | [Tech B] | [Why this also works, trade-offs vs recommended] |
| Keep Current | [Current] | [Compatibility note — may or may not work with new stack] |
```

If "Keep Current" is **incompatible** with previously confirmed choices (e.g., keeping Django ORM after choosing TypeScript), mark it clearly:
- "⚠️ Keep [Current] — **Incompatible** with [confirmed choice]. Would require a bridge/adapter."

Example flow:
```
📋 Language: Python 3.10 → ?
  → User selects "TypeScript 5.x"

📋 Framework: Django 4.2 → ? (constrained by: TypeScript)
  Options only include TypeScript-compatible frameworks
  → User selects "Next.js 14"

📋 ORM/DB: Django ORM + PostgreSQL → ? (constrained by: TypeScript + Next.js)
  Options only include TypeScript ORMs that work with Next.js
  ⚠️ "Keep Django ORM" marked as Incompatible with TypeScript
  → User selects "Prisma + PostgreSQL"

📋 State Management: Redux Toolkit → ? (constrained by: TypeScript + Next.js + React)
  Options only include React-compatible state libraries
  → User selects "Zustand"

... (continue for remaining categories)
```

**Step 3 — Final Summary and Confirmation**:
After all categories are decided, present the complete migration table:

| Category | Current | New | Migration Complexity |
|----------|---------|-----|---------------------|
| Language | Python 3.10 | TypeScript 5.x | Medium |
| Framework | Django 4.2 | Next.js 14 | High |
| ... | ... | ... | ... |

Ask via AskUserQuestion: "Confirm the final stack decisions?"
- "Confirm and proceed"
- "Revise some choices"

**If response is empty → re-ask.** If "Revise some choices", ask which categories to revisit and re-run Step 2 for those categories only.

**Step 4 — Finalize**:
Record the finalized stack decisions. These will be used in:
- Phase 4: `stack-migration.md` generation
- Phase 4: `constitution-seed.md` (New Stack Strategy section)
- Phase 4: Each Feature's `pre-context.md` (New Stack reference sections)

**Decision History Recording — Stack Choices**:
After Step 4 completes, **append** to `specs/history.md` under the current session's section:

```markdown
### Per-Category Stack Choices (New Stack)

| Category | Original | Chosen | Reason |
|----------|----------|--------|--------|
| [Category] | [current tech] | [chosen tech] | [user's reason or "—"] |
```

One row per category decided in Step 2. Record the user's reasoning for each choice if stated.

---

## Phase 2 — Deep Analysis

> **Domain Profile**: Read `domains/{domain}.md` § Analysis Axes for the domain-specific extraction targets used throughout this Phase.

Perform deep analysis using patterns appropriate to the tech stack identified in Phase 1. For large codebases, leverage parallel sub-agents via the Task tool.

### 2-1. Data Model Extraction
Extract entities from appropriate sources depending on the tech stack identified in Phase 1. See `domains/{domain}.md` § Data Model Extraction for the technology-to-search-target mapping and extraction details.

### 2-2. API Endpoint Extraction
Extract APIs from appropriate sources depending on the tech stack identified in Phase 1. See `domains/{domain}.md` § API Endpoint Extraction for the technology-to-search-target mapping and extraction details.

### 2-3. Business Logic Extraction
Extract business rules, validation, workflows, and external integrations from the service layer and domain logic. See `domains/{domain}.md` § Business Logic Extraction for extraction categories.

### 2-4. Inter-Module Dependency Mapping
Analyze import/require statements, service call relationships, shared utilities, and event-based coupling. See `domains/{domain}.md` § Inter-Module Dependency Mapping for details.

### 2-5. Environment Variable Extraction
Scan the codebase for environment variable usage to identify runtime configuration requirements. See `domains/{domain}.md` § Environment Variables for the technology-to-search-pattern mapping and per-variable extraction details.

⚠️ NEVER read or record actual secret values from `.env` files. Only read `.env.example` or detect variable names from code patterns.

### 2-6. Source Behavior Inventory

For each source file identified in Phase 1, extract a **function-level inventory** of exported/public behaviors (P1 core / P2 important / P3 nice-to-have). This captures discrete units of functionality that structural extraction (entities, APIs) may miss. See `domains/{domain}.md` § Source Behavior Inventory for extraction targets, priority classification, and scan patterns.

- Group by Feature association (determined in Phase 3 when Feature boundaries are identified)
- Skip internal/private helpers that are implementation details, not behaviors

This inventory feeds into each Feature's `pre-context.md` → "Source Behavior Inventory" section (Phase 4-2) and is used by `/smart-sdd verify` for Feature-level completeness checking.

### 2-7. UI Component Feature Extraction (Frontend/Fullstack Projects Only)

> Skip this step entirely for backend-only, library, or CLI projects.

Third-party UI libraries provide user-facing capabilities through **configuration and plugins**, not through exported functions — invisible to function-level analysis but significant functionality that must be reproduced. See `domains/{domain}.md` § UI Component Feature Extraction for the 3-step process (identify → extract → record) and library category mapping.

This inventory feeds into each Feature's `pre-context.md` → "UI Component Features" section (Phase 4-2) and is compared during `/smart-sdd parity` → UI Feature Parity.

Upon completing Phase 2, report a summary of the number of entities, APIs, business rules, environment variables, source behaviors, and UI component features discovered.

---

## Phase 3 — Feature Classification and Importance Analysis

### 3-1. Feature Boundary Identification
Identify logical functional units (Features) based on the Phase 2 analysis results, using the boundary heuristics defined in `domains/{domain}.md` § Feature Boundary Heuristics.

Define the following for each Feature:
- Feature name (concise English name)
- Description (1-2 sentences)
- List of associated files
- Owned entities
- Provided APIs

**Naming Remapping scan** (only if Phase 0 Question 3 established a new project name):
For each Feature's associated files, scan for code-level identifiers (function names, class names, variable names, constants, package names) that contain the original project name or its prefix mappings. Record each occurrence with:
- Original identifier (e.g., `createCherryIn`, `CherryProvider`)
- File and line number
- Suggested new identifier (apply the prefix mapping, e.g., `Cherry` → `Angdu`)
- Type (function, class, variable, constant, env var, package, etc.)

This per-Feature catalog will be populated into each Feature's `pre-context.md` → "Naming Remapping" section during Phase 4-2.

> Do not assign Feature IDs at this point. IDs will be assigned based on topological sort after constructing the dependency graph in 3-2.

### 3-1b. Feature Granularity Selection (HARD STOP)

After identifying Feature boundaries, present **multiple granularity options** to the user. The same codebase can be decomposed at different levels of granularity, and the right choice depends on project goals, team size, and desired iteration speed.

**Step 1 — Prepare granularity proposals**:
Analyze the identified Features and propose 2-3 granularity levels:

> **Note**: This table is shared with `/smart-sdd init` § Phase 2. Keep both in sync when modifying.

| Level | Name | Description | Typical Feature Count |
|-------|------|-------------|----------------------|
| **Coarse** | Domain-level | One Feature per major business domain. Larger scope per Feature, fewer total Features. Good for small teams or quick prototyping | 4-8 Features |
| **Standard** | Module-level | One Feature per logical module/service boundary. Balanced scope and count. Recommended for most projects | 8-15 Features |
| **Fine** | Capability-level | One Feature per distinct user-facing capability. Smaller scope per Feature, more total Features. Good for large teams or when granular tracking is needed | 15-30 Features |

**Step 2 — Present the proposals**:
For each granularity level, show a concrete Feature list derived from the analysis:

```
📋 Feature Granularity Options:

── Option A: Coarse (Domain-level) ──────────────
[N] Features total
  • auth — User authentication + authorization + roles
  • catalog — Products + categories + search
  • commerce — Cart + orders + payment + shipping
  • admin — Admin panel + analytics + reports
Pros: Faster pipeline, fewer cross-Feature dependencies
Cons: Larger Features (harder to review/test in isolation)

── Option B: Standard (Module-level) — Recommended ──
[N] Features total
  • auth — User registration, login, sessions
  • user-profile — User profiles, preferences
  • product — Product CRUD, categories
  • search — Product search, filtering
  • cart — Shopping cart management
  • order — Order placement, status tracking
  • payment — Payment processing
  • admin — Admin dashboard, reports
Pros: Balanced scope, manageable review cycles
Cons: Moderate number of Features to track

── Option C: Fine (Capability-level) ────────────
[N] Features total
  • user-register — User registration
  • user-login — Login + session management
  • user-roles — Role-based access control
  • product-crud — Product create/read/update/delete
  • product-category — Category management
  • product-search — Search + filtering
  • ...
Pros: Granular tracking, easier isolated testing
Cons: Many Features, more cross-Feature dependencies
```

**Step 3 — User selection**:
Use AskUserQuestion to ask the user:
- "Option B: Standard (Module-level) (Recommended)"
- "Option A: Coarse (Domain-level)"
- "Option C: Fine (Capability-level)"

**You MUST STOP and WAIT for the user's response. Do NOT proceed until the user selects a granularity level. If response is empty → re-ask.**

If the user selects "Other", they can describe a custom granularity or request specific merges/splits of the proposed Features.

**Step 4 — Apply the selected granularity**:
Reconstruct the Feature list according to the selected level. If Coarse is selected, merge related Features. If Fine is selected, split Features into smaller units. Then proceed to 3-2 with the finalized Feature list.

### 3-2. Dependency Graph Construction and Feature ID Assignment
Derive inter-Feature dependencies:
- **Direct Dependency**: Uses another Feature's modules via import/require
- **API Dependency**: Calls APIs provided by another Feature
- **Entity Dependency**: References entities owned by another Feature
- **Event Dependency**: Subscribes to events published by another Feature

Record dependency directions and types, and visualize them as a Mermaid diagram.

**Feature ID Assignment Rules**:

**If Scope = Core**:
Assign Feature IDs by **Tier first, then topological sort within each Tier**:
1. Group all Features by Tier (Tier 1 → Tier 2 → Tier 3)
2. Within each Tier group, sort by topological order (dependency-based)
3. Assign F001, F002, ... sequentially across the groups: all Tier 1 Features first, then all Tier 2, then all Tier 3

This ensures:
- All Tier 1 Features always have lower numbers than Tier 2/3
- Within the same Tier, dependency order is respected
- The F001, F002, ... sequence represents the **feasible implementation order** while keeping Tier grouping intact

**If Scope = Full**:
Assign Feature IDs by **pure topological sort** (dependency-based):
1. Sort all Features by topological order — Features with no dependencies first, then Features that depend only on already-ordered Features
2. Assign F001, F002, ... sequentially
3. No Tier classification is performed — all Features are treated equally

This ensures:
- The F001, F002, ... sequence represents the optimal implementation order based solely on dependencies
- No unnecessary classification overhead for full rebuilds

**Common**: These numbers also correspond to spec-kit's `specs/{NNN-feature}/` directory names (e.g., F001-auth → `specs/001-auth/`)

### 3-3. Importance Analysis and Tier Classification (Core Scope Only, HARD STOP)

> **This phase is SKIPPED when Scope = Full.** In full mode, all Features are implemented without prioritization — Feature ordering is determined solely by dependency-based topological sort (Phase 3-2). Skip directly to Phase 4.

**If Scope = Core**:

First, identify the project domain: understand what kind of system the project is (e-commerce, SaaS, CMS, education platform, financial service, etc.) and determine which features are foundational within that domain.

Evaluate each Feature comprehensively across the analysis axes and assign to Tier 1 (Essential) / Tier 2 (Recommended) / Tier 3 (Optional). See `domains/{domain}.md` § Tier Classification Axes for the evaluation criteria and Tier definitions. For each Feature, a **specific rationale** for the assigned Tier must be provided.

Present the classification results to the user via AskUserQuestion and obtain approval/adjustments. **If response is empty → re-ask.** If AskUserQuestion is unavailable (e.g., `--dangerously-skip-permissions` environment), display the results and proceed with the proposed classification.

### Decision History Recording — Architecture

After Phase 3 is complete (granularity selected, dependencies mapped, Tier classification approved if core scope), **append** to `specs/history.md` under the current session's section:

```markdown
### Architecture Decisions

| Decision | Choice | Details |
|----------|--------|---------|
| Feature Granularity | Coarse / Standard / Fine | [N] Features |
| Tier Adjustments | [summary of user modifications] | [details, or "None — accepted AI recommendation as-is"] |
```

Record each user modification to the AI's Tier proposals (e.g., "Moved Search from T2 → T1"). If scope is `full`, omit the Tier Adjustments row.

---

## Phase 4 — Deliverable Generation

Generate hierarchical deliverables in `specs/reverse-spec/` (in CWD — see Output Directory rule above).

> **Scope = Core**: All Features are included in generated artifacts (roadmap.md, pre-context.md, etc.) regardless of Tier. The Tier classification only determines which Features smart-sdd will initially process — Tier 2/3 Features are marked as `deferred` in `sdd-state.md` and skipped by the pipeline until activated via `/smart-sdd expand`. This ensures Tier 2/3 Features are ready for immediate activation without re-running `/reverse-spec`.
>
> **Scope = Full**: All Features are included without Tier classification. No Features are deferred. The `Tier` column is omitted from roadmap.md and sdd-state.md.

### 4-1. Project-Level Deliverables

Generate the following files in order. Each file follows the template structure found in this skill's `templates/` directory.

1. **`specs/reverse-spec/roadmap.md`** — See [roadmap-template.md](templates/roadmap-template.md)
   - Project Overview, Rebuild Strategy, Feature Catalog (by Tier for Core scope / by dependency order for Full scope), Dependency Graph, Release Groups, Cross-Feature Entity Dependencies, Cross-Feature API Dependencies

2. **`specs/reverse-spec/entity-registry.md`** — See [entity-registry-template.md](templates/entity-registry-template.md)
   - Complete entity list, fields, relationships, validation rules, cross-Feature sharing mapping

3. **`specs/reverse-spec/api-registry.md`** — See [api-registry-template.md](templates/api-registry-template.md)
   - Complete API endpoint index, detailed contracts, cross-Feature dependencies

4. **`specs/reverse-spec/business-logic-map.md`** — See [business-logic-map-template.md](templates/business-logic-map-template.md)
   - Business rules per Feature, validation, workflows, cross-Feature rules

5. **`specs/reverse-spec/constitution-seed.md`** — See [constitution-seed-template.md](templates/constitution-seed-template.md)
   - Source code reference principles (branching by stack strategy), extracted architecture principles, technical constraints, coding conventions
   - **Naming Conventions** (if project identity changed in Phase 0 Question 3): Include a mapping section documenting original → new naming patterns (e.g., `Cherry` → `Angdu`, `CS` → `AS`). This section guides `speckit-constitution` and `speckit-implement` to use the new project naming consistently.
   - **Recommended Development Principles (Best Practices)**: Test-First, Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution, Demo-Ready Delivery
   - **Global Evolution Layer Operational Principles**: Rules for maintaining cross-Feature context
   - **Project-Specific Recommended Principles**: Based on the domain, architecture patterns, and technical traits observed in Phase 1~3, recommend additional constitution principles tailored to this project. Use the recommendation categories in the template (domain-driven, architecture-driven, scale-driven, quality-driven) as a guide. Each recommendation must cite a specific observed trait from the source analysis as evidence.

6. **`specs/reverse-spec/stack-migration.md`** (only for New Stack strategy) — See [stack-migration-template.md](templates/stack-migration-template.md)
   - Current → New mapping per technology component, migration rationale, per-Feature migration notes, risks and mitigations

7. **`.env.example`** (project root, only if env vars were detected in Phase 2-5):
   - Generated at CWD root (NOT inside `specs/reverse-spec/`)
   - Lists all detected env vars with category comments and placeholder values
   - Groups by Feature association (shared vars first, then per-Feature)
   - Format:
     ```
     # ── Shared (used by multiple Features) ──
     DATABASE_URL=postgresql://localhost:5432/myapp

     # ── F001-auth ──
     JWT_SECRET=your-jwt-secret-here
     OAUTH_CLIENT_ID=your-oauth-client-id
     ```

### 4-2. Feature-Level Deliverables

For each Feature, generate `specs/reverse-spec/features/[Feature-ID]-[feature-name]/pre-context.md`. See [pre-context-template.md](templates/pre-context-template.md).

**Path Convention**: All file paths in pre-context.md's Source Reference and Static Resources sections MUST be **relative to the target directory** (the source being analyzed). Do NOT use absolute paths. The `Source Root` header in the template references `$SOURCE_ROOT`, whose actual value is stored as `Source Path` in `sdd-state.md` and resolved at runtime by smart-sdd.

For example, if the target directory is `/Users/dev/legacy-app`:
- ✅ `src/main/index.ts`
- ❌ `/Users/dev/legacy-app/src/main/index.ts`

Contents to include in each pre-context.md:
- **Source Reference**: List of related original files (relative paths) + reference guide by stack strategy
- **Source Behavior Inventory**: Function-level inventory from Phase 2-6, filtered to this Feature's associated files. Each entry: source file, function/method name, behavior description, priority (P1/P2/P3). This ensures no source-level functionality is lost during the extraction pipeline
- **UI Component Features** (frontend/fullstack projects only): Third-party UI library capabilities from Phase 2-7, filtered to this Feature's associated components. Each entry: component name, library, feature, category. Omit for backend-only projects
- **Naming Remapping** (only if Phase 0 Question 3 established a new project name): Per-Feature catalog of code-level identifiers containing the original project name, with suggested new identifiers. Populated from Phase 3-1 scan results. Omit this section entirely if project name is unchanged or no old-name identifiers were found in this Feature
- **Static Resources**: List of non-code files (images, fonts, i18n, etc.) used by this Feature, with source/target paths (source paths relative to target directory) and usage context. Based on Phase 1-5 inventory, filtered to this Feature's associated files
- **Environment Variables**: Variables this Feature requires at runtime, from Phase 2-5 extraction. Distinguishes Feature-owned vars from shared vars referenced from other Features
- **For /speckit.specify**: Existing feature summary, existing user scenarios, draft requirements (FR-###), draft success criteria (SC-###), edge cases
- **For /speckit.plan**: Preceding Feature dependencies, related entity/API contract drafts (owned + referenced entities, provided + consumed APIs), technical decisions
- **For /speckit.analyze**: Cross-Feature verification points, impact scope when this Feature changes

### 4-3. Source Coverage Baseline (BLOCKING)

> ⚠️ **This sub-phase is MANDATORY and BLOCKING.** Do NOT skip Steps 2-3 even if the deliverables are already generated. Low source coverage means Features are incomplete — the unmapped source files likely represent functionality that needs to be assigned to existing Features or defined as new Features. **Proceeding to Phase 4-4 without completing Step 3 classification is NOT allowed.**

After generating all deliverables, perform an automated source surface measurement to quantify how much of the original source code is covered by the extracted Features.

#### Step 1 — Automated Surface Measurement

Parse the original source (target directory) and compare against the generated artifacts. Reuse detection patterns from Phase 2 — do NOT re-parse from scratch; compare Phase 2 results against the generated artifact inventories:

| Metric | Source (parse from target) | Mapped (from artifacts) | Comparison Method |
|--------|---------------------------|------------------------|-------------------|
| Source files | Glob all source files (exclude vendor/build/test dirs) | Count files listed in all pre-context.md Source Reference tables | File path matching |
| API endpoints | Parse route definitions (Phase 2-2 tech-stack-specific patterns) | Count entries in api-registry.md | Method + path matching |
| DB models/entities | Parse model/entity definitions (Phase 2-1 patterns) | Count entries in entity-registry.md | Entity name matching |
| Source behaviors | Count exported functions/methods (Phase 2-6) | Count entries in all pre-context.md Source Behavior Inventory tables | Function name matching |
| UI component features | Count library features (Phase 2-7, if applicable) | Count entries in all pre-context.md UI Component Features tables | Feature name matching |
| Test files | Glob test file patterns (`**/*test*`, `**/*spec*`, `**/__tests__/**`) | Count test files listed in pre-context.md Source Reference | File path matching |
| Business rules | Count rules identified in Phase 2-3 | Count entries in business-logic-map.md | Rule ID matching |

Display the metrics table to the user:

```
📊 Source Coverage Analysis:

| Metric               | Source | Mapped | Coverage |
|----------------------|--------|--------|----------|
| Source files         | 87     | 72     | 82.8%    |
| API endpoints        | 45     | 43     | 95.6%    |
| DB entities          | 20     | 19     | 95.0%    |
| Test files      | 34     | 28     | 82.4%    |
| Source behaviors  | 85     | 72     | 84.7%    |
| UI features      | 12     | 12     | 100%     |
| Business rules   | 42     | 40     | 95.2%    |
```

#### Step 2 — Unmapped Items Identification

For each metric category, identify items in the source that were NOT mapped to any Feature:
- Source files not listed in any pre-context.md Source Reference
- Endpoints parsed from routes but not in api-registry.md
- Models parsed from source but not in entity-registry.md
- Source behaviors (exported functions) not listed in any pre-context.md Source Behavior Inventory
- UI component features not listed in any pre-context.md UI Component Features (if applicable)
- Test files not associated with any Feature

Group the unmapped items by apparent category/module (e.g., "middleware files", "admin endpoints", "utility models") to minimize the number of user interactions in Step 3.

**Project identity renaming**: If Phase 0 Question 3 established a new project name, highlight items containing the original project name prefix in the unmapped items list (e.g., "⚠️ CherryINOAuth — contains original project name"). When the user classifies these items, suggest renamed versions using the new project naming (e.g., "AngduINOAuth" or "INOAuth").

#### Step 3 — Classification (HARD STOP)

For each unmapped group, use AskUserQuestion and WAIT for the user's response:

```
📋 Unmapped Items: [Group Name] ([N] items)

  [file/endpoint/entity list]

Classification:
```

Options:
- **"Assign to Feature [FID]"** — Add to existing Feature's pre-context.md Source Reference. Ask which FID if not obvious from context.
- **"Create new Feature"** — Collect Feature name and description from user. Add to roadmap.md Feature Catalog (with next available ID). Generate pre-context.md for the new Feature.
- **"Cross-cutting concern"** — Flag for constitution-seed.md update (add principle) or future infrastructure Feature. Record in coverage-baseline.md.
- **"Intentional exclusion"** — Record with one of 6 exclusion reasons: `deprecated`, `replaced`, `third-party`, `deferred`, `out-of-scope`, `covered-differently`. If `deferred`, link to the relevant deferred Feature in roadmap.md.

**Empty/blank response = NOT classified — re-ask.** You MUST obtain an explicit classification for every group.

If user selects "Create new Feature" for any items:
- Assign the next available Feature ID (continuing the existing sequence)
- Add to roadmap.md Feature Catalog (with appropriate Tier for core scope, or dependency position for full scope)
- Generate pre-context.md for the new Feature using the [pre-context-template](templates/pre-context-template.md)
- The new Feature will be picked up by smart-sdd when the pipeline runs

#### Step 3b — Post-Classification Coverage Update

After classifying ALL unmapped groups:

1. **Recalculate coverage metrics**: Include newly assigned items and new Features from Step 3
2. **Display updated metrics**:
   ```
   📊 Updated Source Coverage (after classification):

   | Metric       | Before | After | Change |
   |--------------|--------|-------|--------|
   | Source files | 45.5%  | 89.2% | +43.7% |
   | ...          | ...    | ...   | ...    |

   New Features created: [count]
   Items assigned to existing Features: [count]
   Intentional exclusions: [count]
   ```
3. **If source file coverage is still below 70%** after classification: Display a warning and ask the user whether to continue or re-examine:
   ```
   ⚠️ Source file coverage is still [X]% after classification.
   This means [N] source files are not accounted for in any Feature.
   ```

#### Step 4 — Generate coverage-baseline.md

Generate `specs/reverse-spec/coverage-baseline.md` using the [coverage-baseline-template](templates/coverage-baseline-template.md):
- Populate Surface Metrics table with the **final** measured values (after Step 3b update)
- Record all unmapped items with their user-assigned classifications from Step 3
- Record all intentional exclusions with their reasons and descriptions
- Add coverage notes from the classification process

#### `--dangerously-skip-permissions` handling

When AskUserQuestion is unavailable, display unmapped items via regular text and ask for classification via text message. Items without explicit classification are marked as `unclassified` in coverage-baseline.md for later review via `/smart-sdd parity`.

### 4-4. Completion Report

Report the complete list of generated deliverables and next-step guidance to the user:

```
Generation complete:
- specs/reverse-spec/roadmap.md
- specs/reverse-spec/constitution-seed.md
- specs/reverse-spec/entity-registry.md
- specs/reverse-spec/api-registry.md
- specs/reverse-spec/business-logic-map.md
- specs/reverse-spec/stack-migration.md          (if New Stack strategy)
- specs/reverse-spec/coverage-baseline.md
- specs/reverse-spec/features/F001-xxx/pre-context.md
- specs/reverse-spec/features/F002-xxx/pre-context.md
- ...
- .env.example                                    (if environment variables were detected)

Next steps:
  /smart-sdd pipeline       — Run the full SDD pipeline (recommended)
  /smart-sdd pipeline --auto — Run without stopping for per-step confirmation
  /smart-sdd parity          — Check implementation parity against original source (after pipeline completes)

smart-sdd will automatically:
  1. Finalize constitution based on constitution-seed.md
  2. Progress Features in Release Group order (specify → plan → tasks → analyze → implement → verify → merge)
  3. Inject cross-Feature context from pre-context.md, business-logic-map.md, and registries at each step
  4. Update entity-registry.md and api-registry.md as Features are completed
```

---

## Notes

- **`sdd-state.md` is NOT generated by `/reverse-spec`**. It is created and managed by `/smart-sdd` when the pipeline first runs. References to `sdd-state.md` in pre-context.md and roadmap.md describe values that smart-sdd will populate at runtime.
- For large codebases (1000+ files), distribute model/API/logic extraction across parallel sub-agents using the Task tool in Phase 2.
- Write entity/API formats in deliverables to be compatible with spec-kit's data-model.md and contracts/ style.
- Refer to [speckit-compatibility.md](reference/speckit-compatibility.md) for the spec-kit integration guide.
