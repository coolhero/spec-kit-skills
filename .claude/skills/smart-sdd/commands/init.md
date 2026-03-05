# Init Command — Greenfield Project Setup

> Reference: Read after `/smart-sdd init` is invoked. For shared rules (MANDATORY RULES, --auto, argument parsing), see SKILL.md.

## Init Command — Greenfield Project Setup

Running `/smart-sdd init` sets up a new project by interactively defining Features, dependencies, and development principles, then generating the Global Evolution Layer artifacts.

### Input Sources

1. **PRD document** (`--prd path/to/prd.md`): Reads the PRD file and extracts project description, proposed features, and requirements as starting context for the interactive Q&A
2. **Conversational input**: If no `--prd` is specified, gathers all information through interactive Q&A with the user

### Init Workflow

#### Pre-Phase: Git Repository Setup

Before starting project setup, ensure the CWD has a git repository.

**Step 1 — Check existing git repo**:
Run `git rev-parse --is-inside-work-tree` in CWD.

- **If git repo already exists**: Skip to Step 3 (branch option).
- **If no git repo**: Proceed to Step 2.

**Step 2 — Initialize git repo**:
1. Run `git init` in CWD
2. Create a `.gitignore` with sensible defaults:
   - Always include: `node_modules/`, `.env`, `.env.*`, `__pycache__/`, `*.pyc`, `.DS_Store`, `dist/`, `build/`, `.venv/`, `venv/`
   - Add stack-specific entries if the user already specified the tech stack (from `--prd` or conversation)
3. Display: "✅ Git repository initialized with .gitignore"

**Step 3 — Branch option (HARD STOP)**:
Ask the user via AskUserQuestion whether to work on the current branch or create a dedicated branch:
- "Stay on current branch (Recommended)" — Continue on the current branch (usually `main`)
- "Create a new branch" — Create and checkout a new branch for the SDD work

**If response is empty → re-ask** (per MANDATORY RULE 1). If the user selects "Create a new branch", ask for the branch name via "Other" input (suggest `sdd-setup` as default).

> **`--dangerously-skip-permissions` mode**: Skip branch question. Stay on current branch.

**Step 4 — Auto-initialize case study logging**:
Check if `case-study-log.md` exists at project root:
- **If not exists**: Read the case-study skill's `templates/case-study-log-template.md` and write it to `case-study-log.md`. Display: `📝 Case study log initialized: case-study-log.md`
- **If already exists**: Skip silently

#### Phase 1: Project Definition

1. **If `--prd` is provided**: Read the PRD document and extract:
   - Project name and description
   - Target domain
   - Proposed features/capabilities
   - Technical requirements or constraints (if mentioned)
   - Present the extracted information to the user for confirmation/adjustment

2. **If no `--prd`**: Ask the user:
   - Project name
   - Project description (what problem it solves, target users)
   - Domain (e-commerce, SaaS, CMS, education platform, etc.)
   - Target architecture type (monolithic, microservice, etc.)
   - Tech stack (language, framework, DB, testing framework)

#### Phase 2: Feature Definition (Interactive Q&A)

1. **Initial Feature brainstorm**:
   - If PRD was provided: Present extracted feature candidates and ask for confirmation/additions/removals
   - If no PRD: Ask the user to list the major features of their project

2. **Feature Granularity Selection (HARD STOP)**:
   After the initial feature list is compiled, present multiple granularity options. The same project can be decomposed at different levels, and the right choice depends on project goals, team size, and desired iteration speed.

   Present 2-3 granularity levels with concrete Feature lists for each:

   > **Note**: This table is shared with `/reverse-spec` § 3-1b. Keep both in sync when modifying.

   | Level | Name | Description | Typical Feature Count |
   |-------|------|-------------|----------------------|
   | **Coarse** | Domain-level | One Feature per major business domain. Larger scope per Feature, fewer total Features. Good for small teams or quick prototyping | 4-8 Features |
   | **Standard** | Module-level | One Feature per logical module/service boundary. Balanced scope and count. Recommended for most projects | 8-15 Features |
   | **Fine** | Capability-level | One Feature per distinct user-facing capability. Smaller scope per Feature, more total Features. Good for large teams or when granular tracking is needed | 15-30 Features |

   For each level, show a concrete Feature list derived from the brainstorm:
   ```
   📋 Feature Granularity Options:

   ── Option A: Coarse (Domain-level) ──────────────
   [N] Features total
     • auth — All authentication, authorization, and user management
     • core — Main business logic (CRUD + workflows)
     • admin — Admin panel + analytics
   Pros: Faster pipeline, fewer cross-Feature dependencies
   Cons: Larger Features (harder to review/test in isolation)

   ── Option B: Standard (Module-level) — Recommended ──
   [N] Features total
     • auth — User registration, login, sessions
     • user-profile — User profiles, preferences
     • [domain-feature-1] — ...
     • [domain-feature-2] — ...
   Pros: Balanced scope, manageable review cycles
   Cons: Moderate number of Features to track

   ── Option C: Fine (Capability-level) ────────────
   [N] Features total
     • user-register — User registration only
     • user-login — Login + session management
     • ...
   Pros: Granular tracking, easier isolated testing
   Cons: Many Features, more cross-Feature dependencies
   ```

   Use AskUserQuestion with options:
   - "Option B: Standard (Module-level) (Recommended)"
   - "Option A: Coarse (Domain-level)"
   - "Option C: Fine (Capability-level)"

   **If response is empty → re-ask** (per MANDATORY RULE 1). Do NOT proceed until the user selects a granularity level.

   If the user selects "Other", they can describe a custom granularity or request specific merges/splits.

3. **For each Feature (after granularity is selected), define**:
   - Feature name (concise English, e.g., "auth", "product", "order")
   - Description (1-2 sentences)
   - **Environment variables** (optional): Variables this Feature will need at runtime
     - Variable name, category (`secret` / `config` / `feature-flag`), required/optional, description
     - If the user doesn't know yet, mark as "TBD — will be determined during plan/implement"

4. **Define dependencies between Features**:
   - For each Feature: "Which other Features does this depend on?"
   - Record dependency type (entity reference, API call, shared logic)
   - Validate no circular dependencies exist

5. **Assign Feature IDs**:
   - Sort all Features by topological order (dependency-based) — Features with no dependencies first
   - Assign F001, F002, ... sequentially
   - Greenfield projects always use `Scope: full`, so no Tier classification is needed

6. **Define Release Groups**:
   - Propose grouping based on dependency layers (Features with no dependencies first, then Features that depend on completed groups)
   - Present to user for confirmation/adjustment

7. **Checkpoint (HARD STOP)**: Display the complete Feature catalog, dependency graph (Mermaid), and Release Groups. Use AskUserQuestion to ask for approval. **If response is empty → re-ask** (per MANDATORY RULE 1). Do NOT proceed to Phase 3 until the user explicitly approves.

**Decision History Recording — Feature Definition**:
After the user approves the Phase 2 Checkpoint, **append** to `specs/history.md` (create with the standard header if it doesn't exist — see SKILL.md § History File Header):

```markdown
---

## [YYYY-MM-DD] /smart-sdd init — Project Setup

### Feature Definition

| Decision | Choice | Details |
|----------|--------|---------|
| Feature Granularity | Coarse / Standard / Fine | [N] Features, [N] Release Groups |
```

#### Phase 3: Constitution Seed Definition

1. **Present the 6 Best Practices** with descriptions:
   - I. Test-First (NON-NEGOTIABLE) — Write tests first. Code without tests is not complete
   - II. Think Before Coding — No assumptions. Mark unclear items as `[NEEDS CLARIFICATION]`
   - III. Simplicity First — Implement only what is in the spec. No speculative additions
   - IV. Surgical Changes — No "improving" adjacent code. Only clean up own changes
   - V. Goal-Driven Execution — Verifiable completion criteria required
   - VI. Demo-Ready Delivery — Each Feature must be demonstrable upon completion. "Tests pass" alone is NOT sufficient. Provide an **executable demo script** at `demos/F00N-name.sh` (or `.ts`/`.py`/etc.) that **launches the real, working Feature** so the user can experience it firsthand (browse the UI, call the API, use the CLI). Default = interactive (keep running), `--ci` = health check for verify automation. The script **maps to spec.md's FR-###/SC-###** to show what the user can try

2. **User selection**: All 6 are selected by default. The user can:
   - Deselect specific practices
   - Modify descriptions
   - Add custom principles (with Rule + Rationale format)

3. **Project conventions**: Ask for project-specific conventions:
   - Naming conventions
   - Project structure conventions
   - Error handling patterns
   - Testing patterns

4. **Checkpoint (HARD STOP)**: Display the complete constitution-seed content. Use AskUserQuestion to ask for approval. **You MUST STOP and WAIT for the user's response. Do NOT proceed to Phase 4 until the user explicitly approves.** **If response is empty → re-ask** (per MANDATORY RULE 1).

**Decision History Recording — Constitution**:
After the user approves the Phase 3 Checkpoint, **append** to `specs/history.md` under the current session's section:

```markdown
### Constitution

| Decision | Details |
|----------|---------|
| Best Practices | [e.g., "All 6 adopted" or "5 adopted, excluded: Demo-Ready Delivery"] |
| Custom Principles | [any custom principles added, or "None"] |
```

#### Phase 4: Artifact Generation

Generate all artifacts at BASE_PATH (defaults to `./specs/reverse-spec/`):

1. **`roadmap.md`**: Using the roadmap template format
   - Project Overview: From Phase 1 input
   - "Development Strategy" section (instead of "Rebuild Strategy"): "Greenfield — new project, no existing codebase"
   - Feature Catalog, Dependency Graph, Release Groups: From Phase 2
   - Cross-Feature Entity/API Dependencies: Leave empty (populated as Features are planned)

2. **`constitution-seed.md`**: Using the constitution-seed template format
   - Source Code Reference Principles: "N/A — Greenfield project. No existing source code to reference."
   - Architecture Principles: From user input (if any), otherwise "Define as the project evolves"
   - Technical Constraints: From user input (if any)
   - Coding Conventions: From user input (if any)
   - Project-Specific Recommended Principles: Based on the domain and tech stack from Phase 1 (e.g., e-commerce → Inventory Consistency, Payment Idempotency; SaaS → Tenant Isolation; real-time → Optimistic Updates). Use the recommendation categories in the constitution-seed template as a guide
   - Best Practices: From Phase 3 selections
   - Global Evolution Layer Operational Principles: Always included

3. **`entity-registry.md`**: Empty registry with headers only
   - Note: "Entities will be populated as Features are planned via speckit-plan."

4. **`api-registry.md`**: Empty registry with headers only
   - Note: "Endpoints will be populated as Features are planned via speckit-plan."

5. **`features/F00N-name/pre-context.md`** (per Feature): Simplified greenfield format
   - Source Reference: "N/A — Greenfield project"
   - For /speckit.specify: Feature description + dependencies only (no FR/SC drafts)
   - For /speckit.plan: Dependencies + empty entity/API draft sections (note: "Define during plan step")
   - For /speckit.analyze: Dependency-based cross-Feature verification points

6. **`sdd-state.md`**: Initialize with Origin: `greenfield`, Scope: `full`, all Features set to `pending` (no Active Tiers field — full scope has no Tier concept)

7. **Not generated**: `business-logic-map.md` (no existing logic to map), `stack-migration.md` (no existing stack)

#### Phase 5: Completion Report

```
✅ Greenfield project initialized:

  specs/reverse-spec/roadmap.md
  specs/reverse-spec/constitution-seed.md
  specs/reverse-spec/entity-registry.md (empty — populated during plan)
  specs/reverse-spec/api-registry.md (empty — populated during plan)
  specs/reverse-spec/sdd-state.md
  case-study-log.md
  specs/reverse-spec/features/F001-xxx/pre-context.md
  specs/reverse-spec/features/F002-xxx/pre-context.md
  ...

Next steps:
  /smart-sdd pipeline       — Run the full SDD pipeline
  /smart-sdd constitution   — Start by finalizing the constitution
```

#### Init and --auto Mode

When `--auto` is specified, Phase 2 and Phase 3 Checkpoints are skipped (content is displayed but proceeds immediately). However, interactive Q&A in Phases 1-3 still requires user input. If `--prd` is provided with `--auto`, reasonable defaults are used throughout (all 6 Best Practices, AI-suggested Feature granularity and Release Groups).

#### Init and --dangerously-skip-permissions

Same handling as other commands: interactive prompts use regular text messages instead of AskUserQuestion. The `--prd` argument is recommended in this environment to minimize required interaction.
