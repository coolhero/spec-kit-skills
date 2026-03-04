---
name: smart-sdd
description: Orchestrates the spec-kit SDD workflow for greenfield and brownfield projects. Supports new project setup, adding Features to existing projects, and full rebuild via reverse-spec.
argument-hint: <command> [feature-id] [--from path] [--auto] [--prd path] [--source path]
allowed-tools: [Read, Grep, Glob, Bash, Write, Task, Skill, AskUserQuestion]
---

# Smart-SDD: spec-kit Workflow Orchestrator

> **🚨 MANDATORY RULES — READ FIRST 🚨**
>
> **Rule 1: HARD STOP Enforcement**
> Every HARD STOP in this skill uses AskUserQuestion. After EVERY AskUserQuestion call:
> 1. **CHECK the response** — is it empty, blank, or missing a selection?
> 2. **If empty → call AskUserQuestion AGAIN.** Do NOT proceed. Do NOT treat empty as approval.
> 3. **Only proceed when the user has explicitly selected an option** ("Approve", "Request modifications", etc.)
>
> This rule applies to ALL Checkpoints and ALL Reviews. Violating this rule means the user loses control of the workflow. There are no exceptions.
>
> **Rule 2: Demo = Executable Script, NEVER Markdown**
> When Demo-Ready Delivery is active, the demo MUST be an **executable script** (`demos/F00N-name.sh` or `.ts`/`.py`).
> - ✅ CORRECT: `demos/F001-auth.sh` containing `#!/usr/bin/env bash` + executable commands
> - ❌ WRONG: A markdown file with "## Demo Steps" and manual instructions like "Open settings" or "Click button"
> - ❌ WRONG: Showing demo steps as text in the chat instead of writing a script file
>
> A demo that requires a human to read and follow steps is NOT a demo — it is documentation. The script must run autonomously.

Wraps spec-kit commands with cross-Feature context injection and Global Evolution Layer management. Works with three project modes:

- **Greenfield**: New project from scratch via `/smart-sdd init`
- **Brownfield (incremental)**: Add Features to an existing smart-sdd project via `/smart-sdd add`
- **Brownfield (rebuild)**: Full re-implementation from reverse-spec artifacts via `/smart-sdd pipeline`

Does not replace spec-kit commands, but wraps them with a 4-step protocol: **Context Assembly → Pre-Execution Checkpoint → spec-kit Execution + Artifact Review → Global Evolution Update**.

---

## Usage

```
# Greenfield — New project setup
/smart-sdd init                          # Interactive greenfield project setup
/smart-sdd init --prd path/to/prd.md     # Setup from a PRD document

# Brownfield (incremental) — Add new Feature(s) to existing smart-sdd project
/smart-sdd add                           # Interactive: define and add new Feature(s)

# Pipeline — Run the full SDD pipeline (after init, add, or reverse-spec)
/smart-sdd pipeline                      # With per-step confirmation
/smart-sdd pipeline --auto               # Without stopping for confirmation
/smart-sdd pipeline --from ./path        # Read artifacts from specified path

# Step Mode — Execute a specific step for a specific Feature
/smart-sdd constitution                  # Finalize constitution (one-time)
/smart-sdd specify F001                  # Specify Feature F001
/smart-sdd plan F001                     # Plan Feature F001
/smart-sdd tasks F001                    # Generate tasks for Feature F001
/smart-sdd analyze F001                  # Analyze cross-artifact consistency (before implement)
/smart-sdd implement F001               # Implement Feature F001
/smart-sdd verify F001                   # Verify Feature F001

# Feature restructuring — Modify Feature definitions mid-pipeline
/smart-sdd restructure                   # Interactive: describe what to change

# Scope expansion (core scope only — brownfield rebuild with scope=core)
/smart-sdd expand                        # Interactive: select which Tiers to activate
/smart-sdd expand T2                     # Activate Tier 2 Features
/smart-sdd expand T2,T3                  # Activate Tier 2 and Tier 3 Features
/smart-sdd expand full                   # Activate all remaining deferred Features

# Status check
/smart-sdd status                        # Check overall progress status

# Parity check (brownfield rebuild only — after pipeline completes)
/smart-sdd parity                        # Check parity against original source
/smart-sdd parity --source ./old-project # Specify source path explicitly

# --auto can be combined with any command to skip confirmation
/smart-sdd specify F001 --auto
/smart-sdd pipeline --from ./path --auto
```

---

## Path Conventions

All paths are relative to the **current working directory** (CWD) where the skill is invoked.

| Target | Path | Notes |
|--------|------|-------|
| Global Evolution artifacts | `./specs/reverse-spec/` | Relative to CWD. Can be changed via `--from` argument |
| spec-kit feature artifacts | `./specs/{NNN-feature}/` | Native spec-kit path. Not modified by smart-sdd |
| spec-kit constitution | `.specify/memory/constitution.md` | spec-kit native working path. Do NOT copy to `specs/` |
| State file | `./specs/reverse-spec/sdd-state.md` | Created and managed by smart-sdd |

### Global Evolution Layer Artifact Structure

```
specs/reverse-spec/
├── roadmap.md
├── constitution-seed.md
├── entity-registry.md
├── api-registry.md
├── business-logic-map.md           # (only for rebuild mode)
├── stack-migration.md              # (only for rebuild with new stack)
├── coverage-baseline.md            # (rebuild mode only — generated by /reverse-spec Phase 4-3)
├── parity-report.md                # (rebuild mode only — generated by /smart-sdd parity)
├── sdd-state.md                    # State file created and managed by smart-sdd
└── features/
    ├── F001-auth/pre-context.md
    ├── F002-product/pre-context.md
    └── ...
```

---

## Argument Parsing

Parses `$ARGUMENTS` to extract command, feature-id, and options.

```
$ARGUMENTS parsing rules:
  First token  → command (init | add | restructure | expand | pipeline | constitution | specify | plan | tasks | analyze | implement | verify | status | parity)
  Second token → feature-id (format: F001, required when command is specify/plan/tasks/analyze/implement/verify)
  --from <path>   → artifacts path (defaults to ./specs/reverse-spec/ if not specified)
  --prd <path>    → Path to PRD document (only for init command)
  --source <path> → Original source path for parity check (only for parity command)
  --auto          → Skip Checkpoint confirmation and execute all steps automatically
```

**BASE_PATH** determination:
- If `--from` is specified: use that path
- If not specified: `./specs/reverse-spec/`

**Pre-validation** (for all commands):

**Step 0 — Git and spec-kit installation check** (all commands except `init`):

> **`init` command**: Skips Steps 0 and 1 entirely. The `init` command has its own Pre-Phase that handles git setup, branch selection, and roadmap creation.

**0a. Git repository check**:
1. Check if the current directory is a git repository: `git rev-parse --is-inside-work-tree`
2. If NOT a git repository:
   - Run `git init` to initialize a new repository
   - Run `git add .` and `git commit -m "Initial commit"` if there are files to commit
   - Display: "📦 Initialized git repository in current directory."
3. If git is not installed at all (`which git` fails):
   - Display a warning: "⚠️ Git is not installed. Branch management will be disabled."
   - Continue without git (see [Non-Git Projects](#non-git-projects))

**0b. spec-kit CLI installation check**:
1. Check if spec-kit is available by running: `which specify`
2. If not found, automatically install it:
   ```
   uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
   ```
3. Verify installation succeeded by running `which specify` again
4. If installation fails, display the error and instruct the user to install manually

**0c. spec-kit project initialization check**:
1. Check if spec-kit skills are installed: look for `.claude/skills/speckit-specify/SKILL.md` in the current project
2. If NOT found, initialize spec-kit:
   ```
   specify init --here --ai claude --force --no-git --ai-skills
   ```
   - `--no-git`: Prevents spec-kit from running its own git init (we already handled git in Step 0a)
   - `--ai-skills`: Installs Claude Code skills (`speckit-specify`, `speckit-plan`, etc.) into `.claude/skills/`
   - `--force`: Overwrites any partial/broken previous initialization
3. Verify that `.claude/skills/speckit-specify/SKILL.md` now exists
4. If initialization fails, display the error and instruct the user to run `specify init` manually
5. **IMPORTANT**: After `specify init` installs new skills, they may not be available in the current Claude Code session. If a skill invocation fails with "Unknown skill", fall back to reading the skill's SKILL.md directly and executing the instructions inline (see [Skill Invocation Fallback](#skill-invocation-fallback))

> **Note**: The spec-kit CLI binary is named `specify` (not `speckit`). The Claude Code skills installed by spec-kit use **hyphen-separated** names (e.g., `speckit-specify`, `speckit-plan`), not dot-separated.

**Step 1 — roadmap.md check** (for all commands except `init` and `status`):
1. Check whether `roadmap.md` exists at BASE_PATH
2. If not found, display:
   ```
   No roadmap.md found at [BASE_PATH].
   To set up your project, run one of the following:
     - /smart-sdd init             — Start a new project (greenfield)
     - /smart-sdd init --prd <path> — Start from a PRD document
     - /reverse-spec [target-dir]  — Reverse-analyze existing code for full rebuild
   ```

**Additional rules**:
- `init` command: Skip Steps 0 and 1 (init has its own Pre-Phase and creates roadmap.md).
- `add` command: roadmap.md **must** exist (adding to an existing project)
- `restructure` command: `roadmap.md`, `entity-registry.md`, `api-registry.md`, and `sdd-state.md` must all exist (same prerequisites as `add`)
- `status` command: If `sdd-state.md` does not exist, display "No project initialized yet" and suggest `init` or `reverse-spec`

> **Note**: BASE_PATH is relative to the CWD. All smart-sdd commands must be invoked from the same project directory.

---

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

   | Level | Name | Description | Typical Feature Count |
   |-------|------|-------------|----------------------|
   | **Coarse** | Domain-level | One Feature per major business domain. Fewer total Features, larger scope each | 4-8 Features |
   | **Standard** | Module-level | One Feature per logical module. Balanced scope and count. Recommended for most projects | 8-15 Features |
   | **Fine** | Capability-level | One Feature per distinct user-facing capability. Smaller scope, more Features | 15-30 Features |

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

#### Phase 3: Constitution Seed Definition

1. **Present the 6 Best Practices** with descriptions:
   - I. Test-First (NON-NEGOTIABLE) — Write tests first. Code without tests is not complete
   - II. Think Before Coding — No assumptions. Mark unclear items as `[NEEDS CLARIFICATION]`
   - III. Simplicity First — Implement only what is in the spec. No speculative additions
   - IV. Surgical Changes — No "improving" adjacent code. Only clean up own changes
   - V. Goal-Driven Execution — Verifiable completion criteria required
   - VI. Demo-Ready Delivery — Each Feature must be demonstrable upon completion. "Tests pass" alone is NOT sufficient. Provide an **executable demo script** at `demos/F00N-name.sh` (or `.ts`/`.py`/etc.) that **maps to spec.md's FR-###/SC-###** and exercises as many functional requirements as possible. Each test step states what it verifies (FR/SC ref + expected behavior) and the script prints a passed/total summary

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

---

## Add Command — Brownfield Incremental

Running `/smart-sdd add` adds new Feature(s) to an existing smart-sdd project.

**Prerequisite**: `roadmap.md`, `entity-registry.md`, `api-registry.md`, and `sdd-state.md` must already exist at BASE_PATH.

### Add Workflow

#### Phase 1: Current Project State

1. Read `sdd-state.md` → completed/in-progress Feature list
2. Read `roadmap.md` → Feature Catalog, Dependency Graph
3. Read `entity-registry.md` → currently defined entities
4. Read `api-registry.md` → currently defined APIs
5. Display current state summary to the user:
   ```
   📊 Current Project State:

   Features: N total (X completed, Y in-progress, Z pending)
   Entities: N defined
   APIs: N defined

   Completed Features: F001-auth, F002-product, ...
   In-progress: F003-order (→ plan step)
   Pending: F004-payment, ...
   ```

#### Phase 2: New Feature Definition (Interactive Q&A)

1. Ask the user: "Describe the Feature(s) you want to add"
   - Feature name, description
   - Which existing Features it depends on (entity references, API calls, etc.)
   - Tier classification: Only if the project uses `core` scope (read from `sdd-state.md`). Default: Tier 2. If project scope is `full`, no Tier assignment needed.
2. Multiple Features can be added at once (iterative)
3. Define dependencies between new Features if applicable
4. Assign Feature IDs: continue from the last existing ID

#### Phase 3: Checkpoint (HARD STOP)

1. Display new Feature(s) with dependencies (and Tier, if `core` scope)
2. Show the updated Dependency Graph (existing + new nodes)
3. Propose Release Group placement
4. Use AskUserQuestion to ask for approval. **You MUST STOP and WAIT for the user's response. Do NOT proceed to Phase 4 until the user explicitly approves or requests modifications.** **If response is empty → re-ask** (per MANDATORY RULE 1).

#### Phase 4: Artifact Updates

1. **Update `roadmap.md`**:
   - Add new Features to Feature Catalog
   - Add new nodes/edges to Dependency Graph
   - Place new Features in Release Groups
   - Update Cross-Feature Entity/API Dependencies

2. **Create `features/F00N-name/pre-context.md`** per new Feature:
   - Source Reference: "N/A (added to existing project)"
   - For /speckit.specify: Feature description + dependency summary (no FR/SC drafts)
   - For /speckit.plan: Dependencies with entity/API info copied from existing registries
   - For /speckit.analyze: Dependency-based cross-Feature verification points

3. **Update `sdd-state.md`**:
   - Add new Features to Feature Progress table (`pending`)
   - Add to Feature Mapping
   - Record "Feature added" in Global Evolution Log

#### Phase 5: Completion Report

```
✅ Added N new Feature(s) to the project:
  F006-notifications — depends on F001-auth, F003-order [Tier 2 if core scope]
  F007-analytics — depends on F002-product [Tier 3 if core scope]

Updated: roadmap.md, sdd-state.md
Created: features/F006-notifications/pre-context.md, features/F007-analytics/pre-context.md

Next steps:
  /smart-sdd specify F006     — Start specifying the first new Feature
  /smart-sdd pipeline         — Resume pipeline (picks up from first pending Feature)
```

---

## Common Protocol: Assemble → Checkpoint → Execute+Review → Update

**All spec-kit command executions follow this 4-step protocol. Each step MUST be executed in order. No step may be skipped (unless `--auto` mode is active). In particular, Execute (Step 3) includes a mandatory Review HARD STOP — the spec-kit command runs, then the Review is presented, all in one continuous action.**

> ⚠️ **The most common failure mode is skipping Review.** After executing a spec-kit command (Step 3), you MUST stop, display the generated artifacts, and ask the user for approval. Do NOT proceed to Update without Review. Do NOT combine Execute and Update into a single flow.
>
> **`--auto` mode summary**: When `--auto` is specified, BOTH Checkpoint (Step 2) and Review (Step 3b-c) are skipped — their content is still displayed for transparency, but execution proceeds immediately without waiting for user approval. This is the ONLY way to bypass these stops. Without `--auto`, every Checkpoint and Review is a mandatory HARD STOP.

### 1. Assemble — Context Assembly

- Reads the files/sections required for the given command from BASE_PATH
- Filters and assembles the necessary information per command according to [context-injection-rules.md](reference/context-injection-rules.md)
- Also references actual implementation results from preceding Features (under `specs/`) if available
- **Graceful degradation**: If a source file is missing or a section contains only placeholder text (e.g., "N/A", "none yet"), that source is skipped. See [context-injection-rules.md](reference/context-injection-rules.md) for details.

### 2. Checkpoint — User Confirmation

Presents the assembled context to the user with **actual content**, not just counts. The user must be able to review what will be injected and make informed decisions.

Display format:

```
📋 Context for [command] execution:

Feature: [Feature ID] - [Feature Name]

── Injected Content ──────────────────────────────

[Show the actual assembled content organized by source.
 For example, for specify: show the FR-### list, SC-### list,
 business rules, and edge cases — the real text, not just counts.
 For plan: show the entity schemas, API contracts, and dependencies.
 For greenfield/add: note which sections are empty and will be defined from scratch.]

── Cross-Feature References ──────────────────────

[List of related Features and what is being referenced from each]

── Prerequisites ─────────────────────────────────

[Met / Not met — with details if not met]

──────────────────────────────────────────────────

Review the above content. You can:
  - Approve as-is to proceed
  - Request modifications (add/remove/change items)
  - Edit the source files directly before proceeding
```

**HARD STOP**: You MUST follow this exact procedure. No exceptions.

```
PROCEDURE CheckpointApproval:
  LOOP:
    response = AskUserQuestion(
      options: ["Approve as-is", "Request modifications"]
    )

    IF response is empty, blank, or has no meaningful selection:
      Display "⚠️ No approval received. Please review the context above and select one option."
      CONTINUE LOOP  ← ask again, do NOT proceed

    IF response == "Approve as-is" OR user typed "yes"/"approved"/"lgtm":
      BREAK LOOP → proceed to Step 3 (Execute+Review)

    IF response == "Request modifications":
      Ask user what to change
      Apply modifications to the context
      Re-display the updated context summary
      CONTINUE LOOP  ← ask for approval again

    OTHERWISE (unrecognized response):
      Display "Please select: Approve as-is / Request modifications"
      CONTINUE LOOP
```

**⚠️ CRITICAL**: After AskUserQuestion returns, you MUST check the response BEFORE doing anything else. If the response is empty — you have NOT received approval. Call AskUserQuestion AGAIN. Do NOT proceed to Execute.

**Mode overrides**:
- `--auto`: Skip the LOOP entirely. Content is still displayed for transparency but execution proceeds immediately.
- `--dangerously-skip-permissions`: Replace AskUserQuestion with a text message ("Approve as-is / Request modifications?") and WAIT for text response. Checkpoints are NOT auto-skipped — only `--auto` does that.

### 3. Execute — spec-kit Command Execution

Executes the corresponding spec-kit command with the approved context:
- Invokes `speckit-[command]` via the Skill tool (e.g., `Skill(speckit-specify)`, `Skill(speckit-plan)`)
- Includes the assembled context content in the conversation so spec-kit can reference it
- Feature artifacts created/modified by the spec-kit command are located under `specs/{NNN-feature}/`
- **Prerequisite**: spec-kit skills must be installed in the target project (Step 0c handles this automatically)

#### Skill Invocation Fallback

If the Skill tool returns "Unknown skill" for a `speckit-*` command (e.g., skills were installed mid-session):
1. Read the skill's SKILL.md file directly: `.claude/skills/speckit-[command]/SKILL.md`
2. Execute the instructions contained in the SKILL.md as inline workflow steps
3. This ensures the pipeline can continue even when skills aren't registered in the current session
4. Display: "ℹ️ Using inline execution for speckit-[command] (skill not yet registered in this session)"

#### Execute Error Handling

If the spec-kit command fails (error, crash, partial output):
1. Display the error message to the user
2. Use AskUserQuestion with options: "Retry", "Abort step", "Troubleshoot". **If response is empty → re-ask** (per MANDATORY RULE 1).
3. If "Retry": Re-run the Execute step
4. If "Abort step": Record failure in sdd-state.md, do NOT proceed to Review
5. If "Troubleshoot": Help the user diagnose and fix the issue, then offer to retry

**⚠️ CRITICAL — SUPPRESS spec-kit output**: spec-kit commands print "Next phase:", "Suggested commit:", and other messages. **IGNORE ALL of them.** Do NOT relay them to the user. smart-sdd controls the workflow.

**⚠️⚠️⚠️ EXECUTE + REVIEW CONTINUITY RULE ⚠️⚠️⚠️**

**Execute and Review are ONE continuous action — they MUST happen in the SAME response.** After the spec-kit command (skill invocation) returns, you MUST NOT:
- Generate a response to show the user the command output
- Stop to present results or a summary
- Wait for the user to click "continue" or send any message
- Show "Done" or "Completed" or "Constitution finalized" messages

Instead, in the SAME response where the spec-kit command completed, IMMEDIATELY:
1. Read the generated artifact file(s)
2. Display the Review content (Step 3b below)
3. Call AskUserQuestion for approval (Step 3c below)

**If you find yourself about to generate a response after Execute without showing the Review — STOP. You are violating this rule. Continue to Step 3b.**

#### Step 3b. Display the Review Content

Each command produces different artifacts. Display the **key content** of the generated artifact(s):

| Command | Artifact to Review | Key Content to Display |
|---------|-------------------|----------------------|
| constitution | `.specify/memory/constitution.md` | Full finalized constitution (principles, constraints, conventions, best practices) |
| specify | `specs/{NNN-feature}/spec.md` | Requirements (FR-###), Success Criteria (SC-###), scope boundaries |
| plan | `specs/{NNN-feature}/plan.md` + `data-model.md` + `contracts/` | Architecture decisions, data model schemas, API contracts, implementation phases |
| tasks | `specs/{NNN-feature}/tasks.md` | Task breakdown, task order, estimated complexity |
| implement | Source code files | Summary of files created/modified, test results, build status |

Display format:

```
📋 Review: [command] result for [FID] - [Feature Name]

── Generated Artifact ──────────────────────────
[Show the key sections of the generated artifact.
 Not the entire file — focus on the decision-making content:
 - For spec.md: list FR-### and SC-### with descriptions
 - For plan.md: architecture overview, data-model summary, API contract list
 - For tasks.md: task list with order and dependencies
 - For constitution: full content (it's a one-time critical document)
 - For implement: file list, test pass/fail summary]

── Differences from Pre-context ────────────────
[If applicable: highlight where spec-kit's output differs from
 the draft in pre-context.md — added requirements, changed schemas, etc.]

── Files You Can Edit ─────────────────────────
[List the EXACT file paths that were created/modified by this step:]
  📄 [absolute-path-to-artifact-1]
  📄 [absolute-path-to-artifact-2]
  ...
You can open and edit these files directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

For detailed per-command Review Display Content, see [context-injection-rules.md](reference/context-injection-rules.md).

#### Step 3c. Ask for User Approval (HARD STOP)

You MUST follow this exact procedure. No exceptions.

```
PROCEDURE ReviewApproval:
  LOOP:
    response = AskUserQuestion(
      options: ["Approve", "Request modifications", "I've finished editing"]
    )

    IF response is empty, blank, or has no meaningful selection:
      Display "⚠️ No approval received. Please review the artifact above and select one option."
      CONTINUE LOOP  ← ask again, do NOT proceed

    IF response == "Approve" OR user typed "yes"/"approved"/"looks good"/"lgtm":
      BREAK LOOP → proceed to Step 4 (Update)

    IF response == "Request modifications":
      Ask user what to change
      Re-execute spec-kit command with feedback
      Go back to Step 3b (re-display Review with updated content)
      CONTINUE LOOP

    IF response == "I've finished editing":
      Re-read the artifact file(s) to pick up user's changes
      Display a brief summary of what changed
      response2 = AskUserQuestion(options: ["Approve changes", "Edit more"])
      IF response2 == "Approve changes": BREAK LOOP → proceed to Step 4
      IF response2 == "Edit more": CONTINUE LOOP

    OTHERWISE (unrecognized response):
      Display "Please select: Approve / Request modifications / I've finished editing"
      CONTINUE LOOP
```

**⚠️ CRITICAL**: After AskUserQuestion returns, you MUST check the response BEFORE doing anything else. If the response is empty — you have NOT received approval. Call AskUserQuestion AGAIN. Do NOT proceed to Update.

**Mode overrides**:
- `--auto`: Skip the LOOP entirely (Step 3b content is still displayed for transparency).
- `--dangerously-skip-permissions`: Replace AskUserQuestion with a text message ("Approve / Request modifications / I've finished editing?") and WAIT for text response.

**Per-command option overrides**: Some commands use context-specific options (e.g., Clarify: "Run clarify again", Analyze: outcome-dependent, Verify: pass/fail-specific). See [context-injection-rules.md](reference/context-injection-rules.md) for details.

### 4. Update — Global Evolution Layer Refresh

Updates global artifacts to reflect the command execution results. For detailed update rules per step, see [context-injection-rules.md → Post-Step Update Rules Detail](reference/context-injection-rules.md#post-step-update-rules-detail).

| Completed Step | Update Target | Content |
|----------------|--------------|---------|
| plan | `entity-registry.md` | Reflect new entities/changes from the `data-model.md` finalized in the plan |
| plan | `api-registry.md` | Reflect new APIs/changes from the `contracts/` finalized in the plan |
| analyze | `sdd-state.md` | Record analysis results (issues found, severity levels) |
| implement | `roadmap.md` | Change Feature status to completed |
| implement | Subsequent Feature `pre-context.md` | Update pre-context affected by changed entities/APIs |
| verify | `sdd-state.md` | Record verification results |
| verify | `entity-registry.md` | Verify and update if actual implementation differs from registry |
| verify | `api-registry.md` | Verify and update if actual implementation differs from registry |
| merge | `sdd-state.md` | Record merge completion, update Feature Mapping, change Status to `completed` |

Reports the changes to the user after the update.

---

## Pipeline Mode

Running `/smart-sdd pipeline` progresses through the entire workflow sequentially.

### Pipeline Initialization

Before Phase 0, initialize the state and validate the source path.

**Step 1 — State file initialization**:
If `BASE_PATH/sdd-state.md` does not exist, create it:
1. Read `BASE_PATH/roadmap.md` to extract the Feature list and Tiers
2. Generate `sdd-state.md` following the [state-schema.md](reference/state-schema.md) format
3. Set Origin based on the project type (`greenfield` or `reverse-spec`)
4. Set Source Path (see state-schema.md for rules per mode)

**Step 2 — Source Path verification (HARD STOP)**:
Read the `Source Path` from `sdd-state.md` and verify based on the project mode:

| Mode | Source Path | Verification |
|------|------------|-------------|
| **greenfield** | `N/A` | Skip — no source to reference. Display: "Greenfield project — no existing source reference." |
| **reverse-spec (rebuild)** | Absolute path from reverse-spec | Verify the path exists and is accessible. Display the path and ask the user to confirm or update it (the source may have moved since `/reverse-spec` was run). |
| **add (incremental)** | `.` (CWD) | Verify that the current directory contains source code (check for common markers: `package.json`, `pyproject.toml`, `go.mod`, `src/`, etc.). Display: "Incremental mode — current directory is the source reference." |

For **reverse-spec** mode, present to the user via AskUserQuestion:
```
📂 Source Reference Path: [path from sdd-state.md]
```
- "Confirm path"
- "Update path"

If the user selects "Update path", accept the new path via "Other" input, verify it exists, and update `sdd-state.md`.
If the path does not exist, warn the user and ask for correction. **Do NOT proceed until a valid source path is confirmed** (source reference is essential for brownfield development).

**You MUST STOP and WAIT for the user's response.** Do NOT auto-confirm. **If response is empty → re-ask** (per MANDATORY RULE 1).

**Step 3 — Scope display**:
Read `Scope` from `sdd-state.md` and display scope information:

| Scope | Display |
|-------|---------|
| `full` | "📋 Scope: Full — All Features will be processed." |
| `core` | Read `Active Tiers` and display per the table below |

**Active Tiers display (core scope only)**:

| Active Tiers | Display |
|-------------|---------|
| `T1` | "📋 Scope: Core — Only Tier 1 Features will be processed. Use `/smart-sdd expand` to add Tier 2/3 later." |
| `T1,T2` | "📋 Scope: Expanded — Tier 1 + Tier 2 Features will be processed. Tier 3 deferred." |
| `T1,T2,T3` | "📋 Scope: Core (All Tiers active) — All Features will be processed." |

If deferred Features exist (core scope only), list them:
```
⏸️ Deferred Features (not in current scope):
  F005-review (Tier 3), F006-notification (Tier 3)
```

This step is informational only — no user confirmation required.

### Phase 0: Constitution Finalization

**Skip check**: Before executing, check if `.specify/memory/constitution.md` already exists AND its content is not just the initial template (i.e., it has been finalized by `speckit-constitution`). If it does, skip Phase 0 entirely and proceed to Phase 1. This covers:
- `add` mode (constitution already created in previous pipeline runs)
- Pipeline re-runs after interruption (constitution was already finalized)
- Any scenario where `speckit-constitution` has already been executed

**If constitution has not been finalized**:

Execute the **full Common Protocol** — same 4-step flow as Features:

```
constitution → Assemble → Checkpoint(STOP) → speckit-constitution + Review(STOP) → Update
```

#### Phase 0-1. Assemble

Read `BASE_PATH/constitution-seed.md`:
- For greenfield/init: Uses the constitution-seed generated by the init command
- For rebuild: Uses the constitution-seed generated by `/reverse-spec`

#### Phase 0-2. Checkpoint (HARD STOP)

Display the constitution-seed content per [context-injection-rules.md §1 Checkpoint Display Content](reference/context-injection-rules.md#checkpoint-display-content). Then follow **PROCEDURE CheckpointApproval** (defined in Step 2 of the Common Protocol). Do NOT proceed to Phase 0-3 until the user explicitly approves.

#### Phase 0-3. Execute + Review (HARD STOP)

**This is ONE continuous step — ALL of the following (1-7) MUST happen in the SAME response. Do NOT generate a separate response after step 1.**

1. Provide the constitution-seed content as context and execute `speckit-constitution`
2. **In the SAME response** — ignore any "Suggested commit" or "Next step" output from speckit-constitution
3. **In the SAME response** — read `.specify/memory/constitution.md` — the **entire file**
4. Display the Review content per [context-injection-rules.md §1 Review Display Content](reference/context-injection-rules.md#review-display-content)
5. Show the "Files You Can Edit" block with the absolute path to `constitution.md`
6. Follow **PROCEDURE ReviewApproval** (defined in Step 3c of the Common Protocol). If the response is empty — re-ask. Do NOT proceed.

Constitution is the most critical artifact — it governs all subsequent Features.

#### Phase 0-4. Update

Record the constitution completion in `sdd-state.md`:
- Set Constitution Status to `completed`
- Set Constitution Version to the version from the generated file
- Set Constitution Completed At to current ISO 8601 timestamp
- Add entry to Constitution Update Log

**After Phase 0-4 completes, IMMEDIATELY proceed to Phase 1 below. Do NOT stop. Do NOT wait for user input. Do NOT suggest running a separate command. The pipeline is a continuous flow — constitution finalization is just the first step.**

### Phase 1~N: Progress Features in Release Group Order

Follows the Release Groups order from `BASE_PATH/roadmap.md`. **Skips completed and deferred Features** — only processes Features with `pending`, `in_progress`, or `restructured` status in `sdd-state.md`.

- **Core scope**: Initially only Tier 1 Features are active (`Active Tiers: T1` in `sdd-state.md`). Tier 2/3 Features are `deferred` and skipped until activated via `/smart-sdd expand`.
- **Full scope**: All Features are active — no deferred Features exist.
- **Restructured Features**: Processed starting from their first 🔀 step (see [Restructure Command](#restructure-command--feature-structure-modification)).

**CRITICAL: Each Feature must complete ALL steps (specify through verify and merge) before moving to the next Feature.** Do NOT skip implement or verify. Do NOT start the next Feature until the current Feature's merge step is complete.

Executes the following steps **strictly in order** for each Feature.

**Every "Review" below is a HARD STOP — you MUST use AskUserQuestion and WAIT for explicit user approval before continuing.**

```
0. pre-flight → Ensure on main branch (clean state)
1. specify    → Assemble → Checkpoint(STOP) → speckit-specify → Review(STOP) → Update
                (spec-kit creates Feature branch: {NNN}-{short-name})
2. clarify    → Auto-scan spec.md for ambiguities → speckit-clarify (if needed)
3. plan       → Assemble → Checkpoint(STOP) → speckit-plan → Review(STOP) → Update
4. tasks      → Checkpoint(STOP) → speckit-tasks → Review(STOP)
5. analyze    → Checkpoint(STOP) → speckit-analyze → Review(STOP) (CRITICAL issues block implement)
6. implement  → Env check(STOP if missing) → Checkpoint(STOP) → speckit-implement → Review(STOP)
7. verify     → Checkpoint(STOP) → Test/Build/Lint(BLOCK on fail) → Cross-Feature → Demo-Ready → Review(STOP) → Update
8. merge      → Verify-gate(BLOCK if not success) → Checkpoint(STOP) → Merge Feature branch to main → Cleanup

── Feature DONE ── only now proceed to the next Feature ──
```

> **Reminder**: `(STOP)` means you MUST call AskUserQuestion, display the content, and WAIT for the user's response. Do NOT auto-approve. Do NOT skip. The only exception is `--auto` mode.
>
> **CRITICAL**: After each `speckit-*` command completes, it prints its own "Next phase:" or "Next step:" message. **IGNORE these messages completely — do NOT show them to the user.** smart-sdd controls the flow: after Execute, you MUST immediately proceed to the Review(STOP) step, not follow spec-kit's suggestions.

#### Clarify Trigger (after specify Review)

After `speckit-specify` completes and the user approves the Review, **automatically scan** the generated `spec.md` for ambiguities before proceeding to plan:

1. **Scan for explicit markers**: Search `spec.md` for `[NEEDS CLARIFICATION]`, `[TBD]`, `[TODO]`, `???`, or `<placeholder>` markers
2. **Scan for vague qualifiers**: Check for ambiguous adjectives without measurable criteria (e.g., "fast", "scalable", "intuitive", "robust")
3. **If ambiguities found**:
   - Display: "⚠️ Ambiguities detected in spec.md. Running speckit-clarify to resolve them."
   - Execute `speckit-clarify` via the Common Protocol (Assemble → Checkpoint → Execute+Review → Update)
   - `speckit-clarify` will ask the user up to 5 questions interactively and update spec.md directly
   - After clarify completes, re-scan to verify ambiguities are resolved
   - If unresolved ambiguities remain, display them and ask if the user wants to run clarify again or proceed
4. **If no ambiguities found**: Skip clarify and proceed directly to plan
   - Display: "✅ No critical ambiguities detected in spec.md. Proceeding to plan."

**`--auto` mode**: Clarify scan still runs. If ambiguities are found, `speckit-clarify` executes but uses its own recommendation/suggestion as the default answer for each question (clarify's built-in "recommended" option). The user can still intervene if watching.

#### Per-Feature Environment Variable Check (implement step)

Environment variables are checked **per Feature, at implement time** — not aggregated upfront. This ensures variables are only requested when the Feature that needs them is about to be implemented.

**Skip conditions**: If the current Feature's `pre-context.md` has no Environment Variables section or it contains only "None" / "TBD", skip this check entirely.

Before running `speckit-implement`, read the current Feature's `pre-context.md` → "Environment Variables" section and check for required variables:

**Step 1 — Collect this Feature's required env vars**:
Read `BASE_PATH/features/{FID}-{name}/pre-context.md` → "Environment Variables" section.
Include both Feature-owned variables AND shared variables listed in the "Shared variables" sub-table.

**Step 2 — Check .env file**:
- If `.env` exists: Check for the **presence** of each required variable name (do NOT read actual values)
- If `.env` does not exist: All variables are missing

**Step 3 — Display and confirm (HARD STOP if missing required vars)**:

```
📋 Environment Variables for [FID]-[name]:

── Required ────────────────────────────────────
  ✅ DATABASE_URL     — already set
  ❌ STRIPE_SECRET_KEY — missing [secret] Payment processing API key
  ❌ STRIPE_WEBHOOK_SECRET — missing [secret] Webhook verification

── Optional ────────────────────────────────────
  ✅ LOG_LEVEL        — already set
  ❌ SENTRY_DSN       — missing [config] Error tracking (optional)

⚠️ I will NOT ask you to paste secret values here.
   Edit the .env file directly in your editor.
```

**If any REQUIRED variables are missing**:
Use AskUserQuestion (HARD STOP):
- "Environment is ready — I've added the missing variables"
- "Skip for now — proceed without them"

**If response is empty → re-ask** (per MANDATORY RULE 1). If "Environment is ready": Re-check `.env` to verify the missing variables are now present. If still missing, display which ones and ask again.
If "Skip for now": Display warning "⚠️ Tests may fail due to missing environment variables." and proceed.

**If all required variables are present** (or the Feature has no env vars):
Display: "✅ All required environment variables for [FID]-[name] are set." and proceed directly to Checkpoint (no HARD STOP needed).

> **Security rule**: NEVER read actual values from `.env`. Only check for the **presence** of variable names.

> **Git branching**: spec-kit automatically creates a Feature branch during `speckit-specify`. All subsequent steps (plan through verify) execute on that branch. After verify completes, smart-sdd handles the merge back to main. See [Git Branch Management](#git-branch-management) for details.

#### Next Step Guidance (after each Feature completion)

**If more Features remain in the pipeline**:

Display progress and **IMMEDIATELY proceed to the next Feature** — do NOT stop, do NOT wait for user input, do NOT suggest running a separate command. The pipeline is a continuous flow:
```
✅ [FID]-[name] completed!

📊 Progress: [completed]/[total] Features done
  Proceeding to: [next-FID]-[next-name]
```
Then immediately start the next Feature's pre-flight (Step 0).

**If all Features are completed**:
```
🎉 All Features completed!

📊 Final Status: [total]/[total] Features done
  Constitution: ✅ v[version]

All Features have been implemented, verified, and merged to main.

Next steps:
  /smart-sdd status         — View final progress report
  /smart-sdd add            — Add new Features to the project
```

**If the pipeline is interrupted mid-Feature** (e.g., context limit, user pauses, error):

This is the ONLY case where "Next steps" with commands should be displayed:
```
⏸️ Pipeline paused at [FID]-[name] → [current-step]

To resume:
  /smart-sdd pipeline       — Resume from where you left off
  /smart-sdd [step] [FID]   — Resume a specific step (e.g., /smart-sdd implement F003)
  /smart-sdd status         — Check current state
```

> **Pipeline continuity rule**: The pipeline is a CONTINUOUS flow. The only reasons to stop are: (1) HARD STOP checkpoints requiring user approval, (2) BLOCK conditions (verify/merge gates), (3) All Features completed, or (4) Unrecoverable error. Between Features, between Phases — the pipeline keeps running. Never display "Next steps" with commands unless the pipeline is actually stopping.

---

## Step Mode

Executes a single command. Validates prerequisites, then runs the common protocol (Assemble → Checkpoint → Execute+Review → Update).

### Prerequisite Validation

| Command | Prerequisite | Validation Method |
|---------|-------------|-------------------|
| `constitution` | constitution-seed exists | Check existence of `BASE_PATH/constitution-seed.md` |
| `specify` | pre-context exists, on main branch | Check existence of `BASE_PATH/features/[FID]-[name]/pre-context.md`. Verify current branch is `main` (spec-kit will create the Feature branch) |
| `plan` | spec.md exists, on Feature branch | Check existence of `specs/[NNN-feature-name]/spec.md`. Verify current branch matches the Feature |
| `tasks` | plan.md exists, on Feature branch | Check existence of `specs/[NNN-feature-name]/plan.md`. Verify current branch matches the Feature |
| `analyze` | tasks.md exists, on Feature branch | Check existence of `specs/[NNN-feature-name]/tasks.md`. Verify current branch matches the Feature |
| `implement` | analyze completed (no CRITICAL issues), on Feature branch | Confirm analyze completion in `sdd-state.md`. Check no CRITICAL issues remain. Verify current branch matches the Feature |
| `verify` | implement completed, on Feature branch | Confirm implement completion in `sdd-state.md`. Verify current branch matches the Feature |

If prerequisites are not met, displays an error message and guides the user to the required preceding step.

**Deferred Feature check** (core scope only — full scope has no deferred Features): Before checking other prerequisites, verify the Feature's status in `sdd-state.md`. If the Feature is `deferred` (outside current Active Tiers), display:
```
❌ [FID]-[name] is deferred (Tier [N], outside current scope: [Active Tiers]).
Run /smart-sdd expand [Tier] first to activate Tier [N] Features.
```
Do NOT proceed with the step.

**Branch validation**: For `plan` through `verify`, the current git branch must be the Feature branch (pattern: `{NNN}-*`). If not on the correct branch, display the expected branch name and guide the user. For `specify`, the current branch should be `main` — if already on a Feature branch, warn the user.

### Feature ID → spec-kit Feature Name Mapping

spec-kit uses the naming format `{NNN}-{short-name}` (e.g., `001-auth`), while smart-sdd uses `F{NNN}-{short-name}` (e.g., `F001-auth`). The **short-name** portion MUST be identical across both systems.

**Naming Convention (MANDATORY)**:

| System | Format | Example | Notes |
|--------|--------|---------|-------|
| smart-sdd Feature ID | `F{NNN}-{short-name}` | `F001-auth` | Used in roadmap.md, pre-context folders, sdd-state.md |
| spec-kit Feature directory | `{NNN}-{short-name}` | `001-auth` | Under `specs/`. Created by `create-new-feature.sh` |
| git branch | `{NNN}-{short-name}` | `001-auth` | Created by spec-kit during `speckit-specify` |
| pre-context folder | `F{NNN}-{short-name}/` | `F001-auth/` | Under `specs/reverse-spec/features/` |

**Conversion rules**:
- `F001-auth` → spec-kit name: strip `F` prefix → `001-auth`
- `001-auth` → smart-sdd ID: prepend `F` → `F001-auth`

**When creating a Feature in spec-kit** (during `specify` step):
1. Extract the `short-name` from the smart-sdd Feature ID (e.g., `F001-auth` → `auth`)
2. Extract the numeric part (e.g., `F001` → `1`)
3. Pass to spec-kit: `create-new-feature.sh --number {N} --short-name "{short-name}"`
4. This produces the spec-kit directory `{NNN}-{short-name}` (e.g., `001-auth`)
5. Record the mapping in `sdd-state.md` → Feature Mapping table

**IMPORTANT**: The `short-name` MUST match between smart-sdd and spec-kit. If the user defined Feature name as `F001-platform` in the init/reverse-spec phase, the spec-kit Feature must be `001-platform` (NOT `001-app-shell` or any other name). This ensures consistent naming across all artifacts.

---

## Constitution Incremental Update

When new architectural principles or conventions are discovered during Feature progression:

1. **Checkpoint indication**: "Proposing a Constitution update: [principle content]"
2. **User approval**: Uses AskUserQuestion to confirm approval
3. **Execute update**: If approved, performs a MINOR version update via `speckit-constitution`
4. **Impact analysis**: Displays a warning if already completed Features are affected

---

## Status Command

Running `/smart-sdd status` reads `sdd-state.md` and displays the overall progress.

Follows the schema defined in [state-schema.md](reference/state-schema.md).

Output format varies by scope:

**Full scope** (no Tier concept):
```
📊 Smart-SDD Progress Status

Origin: [greenfield | reverse-spec]
Constitution: ✅ v1.0.0 (2024-01-15)

Feature         | specify | plan | tasks | analyze | implement | verify | merge | Status
----------------|---------|------|-------|---------|-----------|--------|-------|----------
F001-auth       |   ✅    |  ✅  |  ✅   |   ✅    |    ✅     |   ✅   |  ✅  | completed
F002-product    |   ✅    |  🔄  |       |         |           |        |      | in_progress
F003-cart       |         |      |       |         |           |        |      | pending

Active: 1/3 completed, 1/3 in progress
```

**Core scope** (with Tier column):
```
📊 Smart-SDD Progress Status

Origin: [greenfield | reverse-spec]
Scope: core | Active Tiers: [T1 | T1,T2 | T1,T2,T3]
Constitution: ✅ v1.0.0 (2024-01-15)

Feature         | Tier | specify | plan | tasks | analyze | implement | verify | merge | Status
----------------|------|---------|------|-------|---------|-----------|--------|-------|----------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |   ✅    |    ✅     |   ✅   |  ✅  | completed
F002-product    | T1   |   ✅    |  🔄  |       |         |           |        |      | in_progress
F003-cart       | T2   |         |      |       |         |           |        |      | 🔒 deferred
F004-payment    | T2   |         |      |       |         |           |        |      | 🔒 deferred

Active: 1/4 completed, 1/4 in progress | Deferred: 2 (Tier 2)
💡 Use /smart-sdd expand to activate deferred Features
```

---

## Expand Command — Activate Deferred Tiers (Core Scope Only)

> **Note**: The expand command is only available for `core` scope projects. In `full` scope, all Features are already active — running expand will display "All Features are already active. Nothing to expand." and exit.

Running `/smart-sdd expand` activates additional Tiers that were deferred by `scope=core` during `/reverse-spec`.

### Usage

```
/smart-sdd expand              # Interactive: select which Tiers to activate
/smart-sdd expand T2           # Activate Tier 2 Features
/smart-sdd expand T2,T3        # Activate Tier 2 and Tier 3 Features
/smart-sdd expand full         # Activate all remaining deferred Features
```

### Expand Workflow

**Step 1 — Current state check**:
1. Read `sdd-state.md` → Active Tiers, deferred Features
2. If no deferred Features exist: Display "All Features are already active. Nothing to expand." and exit.
3. Display current state:

```
📊 Current Scope:
  Active Tiers: T1
  Active Features: F001-auth ✅, F002-product 🔄, F003-order (pending)
  Deferred Features: F004-cart (T2), F005-payment (T2), F006-review (T3)
```

**Step 2 — Tier selection (HARD STOP)**:
If no argument was provided, ask via AskUserQuestion:
- "Activate Tier 2 (Recommended)" — adds [N] Features
- "Activate Tier 2 + Tier 3" — adds [N] Features
- "Activate specific Features only" — select individual Features via Other input

**If response is empty → re-ask** (per MANDATORY RULE 1). Do NOT auto-select.

**Step 3 — Dependency validation**:
For each Feature being activated, verify that all its dependencies are either:
- Already completed, or
- Already active (`pending` or `in_progress`), or
- Also being activated in this expansion

If a dependency is still deferred and NOT being activated:
```
⚠️ F005-payment depends on F004-cart (deferred). F004-cart will also be activated.
```
Auto-include the dependency Feature.

**Step 4 — Apply expansion**:
1. Update `sdd-state.md`:
   - Update `Active Tiers` to the new value
   - Change matched `deferred` Features to `pending`
2. Record in Global Evolution Log: "Scope expanded: T1 → T1,T2"
3. Display completion:

```
✅ Scope expanded: T1 → T1,T2
  Activated Features:
    F004-cart (T2) → pending
    F005-payment (T2) → pending

  Next: /smart-sdd pipeline    — Resume pipeline (picks up newly activated Features)
        /smart-sdd specify F004 — Start specifying a specific Feature
```

---

## Restructure Command — Feature Structure Modification

Running `/smart-sdd restructure` modifies the Feature structure of an existing project. This command handles splitting, merging, moving requirements, changing dependencies, or deleting Features — and propagates changes to all affected artifacts.

**Prerequisite**: `roadmap.md`, `entity-registry.md`, `api-registry.md`, and `sdd-state.md` must already exist at BASE_PATH.

**When to use**: When the user requests Feature structure changes — before, during, or after pipeline execution (e.g., "F003 is too big, let's split it", "Merge F004 and F005", "Remove F006"). For `pending`/`deferred` Features, the Impact Analysis is naturally lightweight since no spec-kit artifacts or entity/API ownership exist yet.

### Supported Operations

| Operation | Description | Example |
|-----------|-------------|---------|
| **split** | One Feature → two or more Features | F003-product → F003-product-catalog + F008-product-search |
| **merge** | Two or more Features → one Feature | F004-cart + F005-wishlist → F004-shopping |
| **move** | Move requirements/entities/APIs between Features | Move "guest checkout" from F003-order to F002-auth |
| **reorder** | Change dependency relationships | F005 no longer depends on F003 |
| **delete** | Remove a Feature entirely | Remove F006-analytics |

### Feature ID Stability Policy

- **Existing Feature IDs are never reassigned** — this prevents breaking references in completed artifacts
- **New Features** (from split) receive the next available ID after the current highest (same as `add`)
- **Split**: Original Feature ID is retained (scope narrowed) + new Feature(s) get end-number IDs
  - Example: F003 split → F003 retained (narrowed) + F008 new (if F007 was the last)
- **Merge**: The lowest-numbered Feature ID survives; higher-numbered Features are removed
  - Example: F004 + F005 merge → F004 survives, F005 removed
- **Delete**: ID gap is allowed (F001, F002, F004, F005 — F003 deleted)

### Restructure Workflow

#### Phase 1: Current State Assessment

1. Read `sdd-state.md` → completed/in-progress/pending/restructured Feature list
2. Read `roadmap.md` → Feature Catalog, Dependency Graph
3. Read `entity-registry.md` → currently defined entities and their Owner Features
4. Read `api-registry.md` → currently defined APIs and their Owner Features
5. Display current state summary to the user:
   ```
   📊 Current Project State:

   Features: N total (X completed, Y in-progress, Z pending)
   Entities: N defined (owners: F001, F002, ...)
   APIs: N defined (owners: F001, F002, ...)

   Feature Status:
     F001-auth       — completed (all steps ✅)
     F002-product    — in_progress (→ plan step)
     F003-order      — pending
     F004-cart       — pending
   ```

#### Phase 2: Change Request (Interactive)

1. Ask the user: "What Feature structure changes do you want to make?"
2. Identify which operation(s) apply: split, merge, move, reorder, delete
3. Gather details based on the operation:
   - **split**: Which Feature to split? How to divide it? (by entity, by user scenario, by API group, etc.)
   - **merge**: Which Features to merge? What should the surviving Feature be named?
   - **move**: What to move? From which Feature to which Feature?
   - **reorder**: Which dependency to add/remove/change?
   - **delete**: Which Feature to remove? How to handle its entities/APIs/downstream dependencies?
4. Multiple operations can be combined in a single restructure (e.g., split F003 AND delete F006)

#### Phase 3: Impact Analysis

Automatically analyze all affected artifacts for each operation:

**Common analysis items** (all operations):
1. `roadmap.md` — Feature Catalog, Dependency Graph, Dependency Table, Release Groups, Cross-Feature Entity/API Dependencies
2. `entity-registry.md` — Owner Feature column references
3. `api-registry.md` — Owner Feature column references
4. `business-logic-map.md` — Feature-assigned business rules (if file exists)
5. `features/F00N-name/pre-context.md` — the affected Feature(s) + all Features that depend on them
6. `sdd-state.md` — Feature Progress, Feature Detail Log, Feature Mapping
7. `specs/NNN-name/` — spec-kit generated artifacts (spec.md, plan.md, tasks.md) if the Feature has started

**Per-operation additional analysis**:

##### Split
- Determine which entities/APIs belong to which child Feature
- Identify downstream Features that depend on the original → determine which child each should now depend on
- Evaluate completed steps: which child Feature do existing artifacts (spec.md, plan.md) belong to?

##### Merge
- Combine entities/APIs from all merged Features under the surviving Feature
- Compare completion states → determine which steps need re-execution on the surviving Feature
- Redirect all downstream dependencies to the surviving Feature ID

##### Move
- Identify the specific requirements/entities/APIs being moved
- Determine if both Features' spec.md/plan.md need re-execution
- Update cross-Feature verification points in both Features' pre-context.md

##### Reorder
- Validate the modified Dependency Graph is a valid DAG (no circular dependencies)
- Recalculate Release Group placement
- Recalculate pipeline execution order

##### Delete
- Identify all downstream Features that depend on the deleted Feature
- Identify all entities/APIs owned by the deleted Feature
- Propose resolution: reassign entities/APIs to another Feature, or remove them
- Propose dependency resolution for downstream Features: remove the dependency, or redirect to another Feature
- **If the Feature is `completed`**: Its code is already merged into main. The restructure command removes the Feature from Global Evolution Layer artifacts (roadmap, registries, sdd-state, pre-context) but does NOT remove the merged code. Flag this prominently in the Impact Summary:
  ```
  ⚠️ COMPLETED FEATURE DELETION
  F001-auth is already implemented and merged to main.
  Restructure will remove it from project artifacts only.
  Code removal from the codebase is YOUR responsibility:
    - Review and manually remove F001-auth related code
    - Update/remove tests associated with F001-auth
    - Downstream Features referencing F001-auth code may break
  ```

#### Phase 4: Impact Summary Display (HARD STOP)

Display the analysis results in a structured format and request user approval:

```
🔀 Feature Restructure — Impact Summary

**Operation**: [split / merge / move / reorder / delete]
**Affected Features**: F003, F004, F005, F008 (new)

### Changes to Apply

#### 1. Feature Catalog (roadmap.md)
- REMOVE: F005-wishlist
- MODIFY: F004-cart → F004-shopping (description updated)
- ADD: (none)

#### 2. Dependency Graph (roadmap.md)
- REMOVE edge: F005 → F001
- MODIFY edge: F004 → F001 (unchanged), F004 → F002 (new — inherited from F005)

#### 3. Entity Ownership (entity-registry.md)
- TRANSFER: WishlistItem (F005 → F004)

#### 4. API Ownership (api-registry.md)
- TRANSFER: GET /wishlist (F005 → F004)
- TRANSFER: POST /wishlist (F005 → F004)

#### 5. Pre-Context Updates
- MODIFY: features/F004-shopping/pre-context.md (merged content from F005)
- DELETE: features/F005-wishlist/pre-context.md
- MODIFY: features/F006-order/pre-context.md (dependency F005 → F004)

#### 6. Pipeline State (sdd-state.md)
- REMOVE: F005 from Feature Progress
- MODIFY: F004 status → needs re-execution from "specify" step (🔀)
- NOTE: F005 had completed "specify" → content merged into F004

#### 7. spec-kit Artifacts (manual cleanup — NOT auto-deleted)
- PRESERVE: specs/005-wishlist/ (will NOT be auto-deleted)
- FLAG: specs/004-cart/ → may need re-execution of specify, plan, tasks

### ⚠️ Warnings
- F004 (specify: completed) will be marked as 🔀 from specify step
- specs/005-wishlist/ directory will NOT be deleted (cleanup command provided after completion)
```

**Use AskUserQuestion** to request approval (options: "Approve changes", "Request modifications"). **If response is empty → re-ask** (per MANDATORY RULE 1). If the user requests modifications, return to Phase 2 and re-analyze. Do NOT proceed to Phase 5 until the user explicitly approves.

#### Phase 5: Execute Changes

After approval, update all artifacts in order:

1. **`roadmap.md`** — Feature Catalog (add/remove/modify entries), Dependency Graph (update mermaid diagram + Dependency Table), Release Groups (reposition Features), Cross-Feature Entity/API Dependencies (update ownership references)

2. **`entity-registry.md`** — Change Owner Feature for transferred entities, add new entity sections for split Features, remove entity sections for deleted Features

3. **`api-registry.md`** — Change Owner Feature for transferred APIs, add new API sections for split Features, remove API sections for deleted Features

4. **`business-logic-map.md`** (if exists) — Reassign business rules to new Feature owners, remove rules for deleted Features

5. **`features/`** directory — Create new `pre-context.md` files (for split), modify existing ones (for merge/move/reorder/delete), delete files for removed Features

6. **`sdd-state.md`** — Update Feature Progress table (add/remove/modify rows, mark affected steps with 🔀), update Feature Detail Log, update Feature Mapping, add entry to Restructure Log

#### Phase 6: Post-Restructure Verification & Report

After all changes are applied, verify consistency and display the completion report:

**Verification checks**:
- Dependency Graph is a valid DAG (no cycles)
- All entities in entity-registry.md have valid Owner Features
- All APIs in api-registry.md have valid Owner Features
- All pre-context.md files reference valid Feature IDs in their dependency sections
- sdd-state.md Feature Progress matches roadmap.md Feature Catalog
- No orphaned pre-context.md files (no pre-context for non-existent Features)

**Completion report**:

```
✅ Feature restructure completed:

**Operation**: merge (F004-cart + F005-wishlist → F004-shopping)

**Updated artifacts**:
  - roadmap.md: Feature Catalog (1 removed), Dependency Graph (2 edges updated)
  - entity-registry.md: 1 entity transferred (WishlistItem → F004)
  - api-registry.md: 2 APIs transferred (GET/POST /wishlist → F004)
  - features/F004-shopping/pre-context.md: merged content
  - features/F005-wishlist/pre-context.md: DELETED
  - sdd-state.md: F005 removed, F004 status → restructured

**Pipeline impact**:
  - F004-shopping: needs re-execution from specify step (🔀)
  - Downstream Features unaffected

**Manual cleanup suggested**:
  - rm -rf specs/005-wishlist/       — Old spec-kit artifacts
  - git branch -d 005-wishlist       — Old Feature branch (if exists)

**Next steps**:
  /smart-sdd specify F004    — Re-specify the restructured Feature
  /smart-sdd pipeline        — Resume pipeline (processes restructured + pending Features)
```

### Re-Execution Rules

When a Feature is restructured, affected pipeline steps must be re-executed. The scope depends on the operation:

| Operation | Affected Feature | Re-execute from | Rationale |
|-----------|-----------------|-----------------|-----------|
| **split** | Original (narrowed) | specify | Scope of requirements changed |
| **split** | New Feature(s) | specify (fresh start) | Entirely new Feature |
| **merge** | Surviving Feature | specify | Combined requirements need re-specification |
| **move** | Source Feature | specify | Requirements removed, needs re-specification |
| **move** | Target Feature | specify | Requirements added, needs re-specification |
| **reorder** | Features with changed deps | plan | Dependencies changed, architecture may differ |
| **delete** | Downstream Features | plan | Lost dependency, architecture may need adjustment |

Steps marked with 🔀 are re-executed when the pipeline resumes. The pipeline treats `restructured` Features the same as `in_progress` Features — it processes them starting from the first 🔀 step.

### spec-kit Artifact Preservation

- **Never auto-delete** `specs/NNN-name/` directories — the user may want to reference or recover them
- **Never auto-delete** git branches — only suggest cleanup commands
- This policy ensures the user maintains full control over artifact and branch lifecycle

### Integration with Pipeline

- **Restructure is a separate command**, not part of the pipeline flow
- If the user requests a Feature change during pipeline execution:
  1. Complete (or abort) the current in-progress step
  2. Run `/smart-sdd restructure`
  3. After restructure, resume with `/smart-sdd pipeline` — the pipeline automatically detects `restructured` Features and processes them from the first 🔀 step

---

## Analyze Command

Running `/smart-sdd analyze [FID]` executes `speckit-analyze` to verify cross-artifact consistency **before implementation**.

**When**: After `tasks` step completes, before `implement` step.

**What it does**: `speckit-analyze` is a READ-ONLY analysis that checks consistency across spec.md, plan.md, and tasks.md. It identifies gaps, duplications, ambiguities, and inconsistencies.

**Workflow**:
1. Execute `speckit-analyze` via the Common Protocol (Assemble → Checkpoint → Execute+Review → Update)
2. Review the analysis report:
   - If **CRITICAL** issues exist: Block implementation. The user must resolve them first (re-run specify, plan, or tasks as needed)
   - If only **HIGH/MEDIUM/LOW** issues: Display findings, user may proceed or address them
3. Record analysis results in `sdd-state.md`

**Prerequisite**: `tasks.md` must exist for the Feature (`speckit-analyze` requires all three artifacts: spec.md, plan.md, tasks.md)

> **Note**: `speckit-analyze` checks intra-Feature artifact consistency (spec ↔ plan ↔ tasks). Cross-Feature entity/API consistency is checked separately during `verify` (after implementation).

---

## Verify Command

Running `/smart-sdd verify [FID]` performs post-implementation verification. This step runs **after implement** to validate that the actual code works correctly and is consistent with the broader project.

### Phase 1: Execution Verification (BLOCKING)

Run each check and record results. **If any check fails, verification is BLOCKED — do not proceed to Phase 2/3/4.**

1. **Test check**: Detect and execute the project's test command (from `package.json` scripts, `pyproject.toml`, `Makefile`, etc.)
2. **Build check**: Run the build command and confirm no errors
3. **Lint check**: Run the lint tool if configured

**If ANY check fails**, display and STOP:
```
❌ Execution Verification failed for [FID] - [Feature Name]:
  Tests: [PASS/FAIL — pass count/total, failure details]
  Build: [PASS/FAIL — error summary]
  Lint:  [PASS/FAIL — critical issue count]

Fix the failing checks before verification can continue.
Verification is BLOCKED — merge will not be allowed until all checks pass.
```

**Use AskUserQuestion** with options:
- "Fix and re-verify" — user will fix, then re-run `/smart-sdd verify`
- "Show failure details" — display full test/build/lint output

**Do NOT proceed to Phase 2** until all three checks pass. Do NOT allow the user to "skip" failed checks — there is no skip option.

> **Build prerequisites**: If the build fails due to missing setup steps (e.g., `pnpm approve-builds`, native module compilation), include the specific prerequisite command in the error message so the user knows what to run.

### Phase 2: Cross-Feature Consistency Verification
- Check the cross-verification points in the "For /speckit.analyze" section of `pre-context.md`
- Analyze whether shared entities/APIs changed by this Feature affect other Features
- Verify that entity-registry.md and api-registry.md match the actual implementation

### Phase 3: Demo-Ready Verification (BLOCKING — only if VI. Demo-Ready Delivery is in the constitution)

> **If VI. Demo-Ready Delivery is NOT in the constitution**: Skip this phase entirely.

**Step 1 — Check demo script exists AND is an executable script (NOT markdown)**:
- Verify `demos/F00N-name.sh` (or `.ts`/`.py`/etc. matching the project's language) exists
- **REJECT if**: the file is `.md`, contains `## Demo Steps`, or consists of prose instructions instead of executable commands
- **REJECT if**: the file lacks a shebang line (`#!/usr/bin/env bash` or equivalent) for `.sh` files
- The demo script must be executable and self-contained: running it should demonstrate the Feature without manual steps
- If a markdown demo file was generated instead, **delete it** and create a proper executable script

**Step 2 — Check coverage mapping and demo components**:
- The demo script must include a **Coverage** header comment mapping FR-###/SC-### from spec.md to specific demo tests
  - Each FR/SC should be either ✅ (covered by a test) or ⬜ (skipped with reason)
  - **Aim for maximum coverage** — every functional requirement should have a corresponding demo test unless genuinely untestable
  - If coverage is below 50% of the Feature's FR count, **WARN** the user and suggest adding more tests
- Each test step in the script must state what it verifies: `# --- Test N: [description] (FR-###, SC-###) ---`
- The demo script must include a **Demo Components** header comment listing each component as Demo-only or Promotable
- Demo-only components are marked with `// @demo-only` (removed after all Features complete)
- Promotable components are marked with `// @demo-scaffold — will be extended by F00N-[feature]`

**Step 3 — Execute the demo script**:
- Run the demo script and verify it completes without errors
- If the demo requires a running server (e.g., web app), start the server, verify the demo endpoints/pages respond correctly, then stop the server
- Capture the demo output (stdout/stderr) for the Review display

**If any check fails**, display and BLOCK:
```
❌ Demo-Ready verification failed for [FID] - [Feature Name]:
  - [Missing: demos/F00N-name.sh | Script execution failed: <error> | Missing: Demo Components header | Missing: component markers]

"Tests pass" alone does not satisfy Demo-Ready Delivery.
Please create an executable demo script at demos/F00N-name.sh that demonstrates the Feature,
and mark all demo code with appropriate category markers.
```

**Use AskUserQuestion** with options:
- "Fix and re-verify" — user will fix, then re-run `/smart-sdd verify`
- "Show failure details" — display full demo script output

**Do NOT proceed to Phase 4** until the demo script exists and executes successfully.

- Update `demos/README.md` (Demo Hub) with the Feature's demo status and the command to run the demo

### Phase 4: Global Evolution Update
- entity-registry.md: Verify that the actually implemented entity schemas match the registry; update if discrepancies are found
- api-registry.md: Verify that the actually implemented API contracts match the registry; update if discrepancies are found
- sdd-state.md: Record verification results — **status MUST be one of `success` or `failure`**, plus test pass/fail counts, build result, and verification timestamp. The merge step checks this status as a gate condition.

---

## Parity Command — Brownfield Source Parity Check

Running `/smart-sdd parity` compares the original source code against implemented Features to identify functionality gaps after the pipeline completes. This is a utility command — it does NOT follow the Common Protocol (Assemble → Checkpoint → Execute+Review → Update) but has its own multi-phase workflow.

### Prerequisites

- **Origin must be `reverse-spec`**: Parity checking is only available for brownfield rebuild projects. If Origin in sdd-state.md is not `reverse-spec` (e.g., `greenfield`), display: "⚠️ Parity check is only available for brownfield rebuild projects (Origin: reverse-spec)." and exit.
- **At least one Feature must be `completed`** in sdd-state.md.
- **`coverage-baseline.md` is optional but recommended**: If present at `BASE_PATH/coverage-baseline.md`, intentional exclusions will be filtered from the gap list. If missing, parity still runs but without exclusion filtering — display a note: "ℹ️ coverage-baseline.md not found. Run `/reverse-spec` with Phase 4-3 to generate it, or all source items will be treated as expected."

### Source Path Resolution

The original source path is resolved in this priority order:

1. `--source <path>` argument (if provided)
2. `Source Path` field from `sdd-state.md`
3. If neither is available: use AskUserQuestion to prompt the user for the path

**Verification**: Before proceeding, verify the resolved source path exists and is accessible. If not found, display error and ask user to provide a valid path.

### Phase 1: Structural Parity (Automated)

Parse the original source and compare against implemented code.

**Step 1 — Source parsing**: Reuse reverse-spec Phase 2 tech-stack-specific detection patterns to parse:
- All API endpoints (route definitions, controllers, decorators)
- All DB models/entities (ORM models, schema definitions)
- All route registrations (pages, views)
- All test files

**Step 2 — Implementation inventory**:
- Read `BASE_PATH/api-registry.md` for all defined endpoints
- Read `BASE_PATH/entity-registry.md` for all defined entities
- Scan implemented source code on the main branch for actually implemented endpoints, entities, routes

**Step 3 — Exclusion filtering**:
- If `BASE_PATH/coverage-baseline.md` exists: read the Intentional Exclusions table
- Remove all items marked with any exclusion reason from the gap list
- Items marked as `deferred` are excluded from the gap count but listed separately as "Deferred items"

**Step 4 — Display metrics**:

```
📊 Structural Parity: [Project Name]
   Source: [resolved source path]

| Category       | Original | Implemented | Excluded | Gap | Parity  |
|----------------|----------|-------------|----------|-----|---------|
| API endpoints  | 45       | 42          | 1        | 2   | 95.6%   |
| DB entities    | 20       | 18          | 1        | 1   | 94.7%   |
| Routes/pages   | 38       | 35          | 2        | 1   | 97.2%   |
| Test files     | 30       | 25          | 0        | 5   | 83.3%   |

Deferred items (from coverage-baseline.md): 12 endpoints, 3 entities
```

### Phase 2: Logic Parity (Semi-Automated)

**Step 1 — Business rule comparison**:
- Read `BASE_PATH/business-logic-map.md` for all extracted rules (skip if file does not exist — greenfield origin or no rules extracted)
- For each rule, check if the implementing Feature's `SPEC_PATH/{NNN-feature}/spec.md` contains a corresponding FR-### that maps to the rule
- A rule is "covered" if a FR-### in the responsible Feature's spec.md addresses the same behavior

**Step 2 — Test case comparison**:
- Parse original test files to extract test case names/descriptions (using `describe`/`it`/`test` patterns, or language-specific equivalents)
- Compare against implemented test files in the new codebase
- A test case is "covered" if a test with similar intent exists (name matching + behavior description comparison)

**Step 3 — Display metrics**:

```
📊 Logic Parity:

| Category        | Original | Covered | Gap | Parity |
|-----------------|----------|---------|-----|--------|
| Business rules  | 42       | 38      | 4   | 90.5%  |
| Test cases      | 120      | 98      | 22  | 81.7%  |
```

### Phase 3: Gap Report Generation

Generate `BASE_PATH/parity-report.md` with the following structure:

```markdown
# Parity Report

**Source**: [source path]
**Generated**: [DATE]
**Overall Parity**: Structural [X%] | Logic [Y%]

---

## Summary

| Category | Original | Implemented | Excluded | Gap | Parity |
|----------|----------|-------------|----------|-----|--------|
| [per category row] | ... | ... | ... | ... | ... |

---

## Gaps

### Structural Gaps

| # | Category | Item | Original Location | Related Feature | Group |
|---|----------|------|-------------------|-----------------|-------|
| G-001 | endpoint | DELETE /admin/users/:id | src/routes/admin.ts:42 | F001-auth | A |
| G-002 | entity | AuditLog | src/models/audit.ts:1 | (cross-cutting) | B |

### Logic Gaps

| # | Category | Rule/Test | Original Location | Related Feature | Group |
|---|----------|-----------|-------------------|-----------------|-------|
| G-003 | business-rule | "Discount caps at 50%" | src/services/pricing.ts:88 | F005-pricing | C |
| G-004 | test-case | "should handle timeout" | tests/api/reports.test.ts:45 | F003-reports | C |

---

## Suggested Grouping

| Group | Scope | Suggested Action | Gaps |
|-------|-------|-----------------|------|
| A | F001-auth scope | New Remediation Feature | G-001 |
| B | Cross-cutting | Infrastructure Feature + constitution update | G-002 |
| C | F003-reports + F005-pricing | New Remediation Feature | G-003, G-004 |

---

## Intentional Exclusions Applied

[Items from coverage-baseline.md that were filtered out during this parity check]

---

## Deferred Items

[Items from coverage-baseline.md marked as `deferred` — not counted as gaps but listed for reference]
```

**Auto-grouping logic**:
1. Gaps that belong to the same Feature scope → one group
2. Gaps that are cross-cutting (affect multiple Features or no single Feature) → "infrastructure" group
3. Test case gaps → grouped with the Feature they test
4. Single-item gaps → either standalone or merged into the closest group

### Phase 4: Remediation Plan (HARD STOP per group)

Present the gap groups to the user and ask for a decision per group:

```
📋 Remediation Plan:

── Group A: F001-auth scope (1 gap) ──────────
  G-001: DELETE /admin/users/:id (endpoint)

  Suggested: New Remediation Feature
```

Use AskUserQuestion per group with options:

- **"Create new Feature"** → Invoke the `add` workflow with pre-populated Feature definition:
  - Feature name derived from group scope (e.g., "F010-auth-parity")
  - Description includes the gap items as draft requirements
  - Dependencies derived from related existing Features
  - Pre-context.md populated with gap details and source references

- **"Add to existing Feature [FID]"** → Update the Feature's pre-context.md with additional requirements from the gaps. Mark the Feature's pipeline steps with 🔀 from specify onward in sdd-state.md. The Feature will need to re-run specify → plan → tasks → implement → verify.

- **"Intentional exclusion"** → Record in parity-report.md with one of 6 exclusion reasons (`deprecated`, `replaced`, `third-party`, `deferred`, `out-of-scope`, `covered-differently`). Also update coverage-baseline.md if it exists.

- **"Defer"** → Add to roadmap.md Deferred Features section. Record in parity-report.md as deferred with a link to the deferred entry.

**You MUST STOP and WAIT for the user's response for each group. Empty/blank response = NOT decided — re-ask.**

**Cross-cutting group special handling**: When a group is classified as cross-cutting:
1. Propose constitution update — add architectural principle (e.g., "All API endpoints must implement rate limiting")
2. Create an infrastructure Feature via the `add` workflow (e.g., "F010-infrastructure-parity")
3. Both actions happen together — constitution for the principle, Feature for the implementation

### Phase 5: Completion Report

```
✅ Parity check completed:

📊 Final Parity: Structural [X%] | Logic [Y%]

Gaps found: [N total]
  → New Features created: [N] (ready for /smart-sdd pipeline)
  → Added to existing Features: [N] (marked 🔀 for re-execution)
  → Intentional exclusions: [N] (recorded in parity-report.md)
  → Deferred: [N] (added to roadmap.md)

Generated: specs/reverse-spec/parity-report.md
Updated: specs/reverse-spec/sdd-state.md

Next steps:
  /smart-sdd pipeline       — Resume pipeline for new/modified Features
  /smart-sdd status         — View updated progress
```

### `--auto` Mode

When `--auto` is specified:
- Phases 1-3 (automated analysis and report generation) proceed normally
- Phase 4 HARD STOPs are skipped:
  - Groups are auto-assigned based on the suggested grouping in Phase 3
  - "Create new Feature" for groups with a clear Feature scope
  - "Create infrastructure Feature" for cross-cutting groups (constitution update included)
  - No gaps are auto-excluded (conservative: all gaps are treated as actionable)
- Phase 5 displays the results as usual

### `--dangerously-skip-permissions` handling

Same handling as other commands: AskUserQuestion replaced with text messages. Classification prompts display options as regular text and wait for text response.

---

## Git Branch Management

smart-sdd integrates with spec-kit's Feature branch workflow to ensure each Feature is developed in isolation and merged to main only after successful verification.

### Branch Lifecycle

```
main ─── (start) ──→ speckit-specify creates branch {NNN}-{short-name}
                          │
                          ├── plan, tasks, implement, verify (all on Feature branch)
                          │
                          ├── Post-Feature updates (entity-registry, api-registry, etc.)
                          │
                          ├── Merge Checkpoint (HARD STOP — user approval)
                          │
main ←── (merge) ────────┘
```

### Pre-Flight: Before Starting a Feature

Before executing `specify` for a new Feature:

1. **Verify current branch is `main`**: Run `git branch --show-current`
   - If not on main: Display warning and ask user whether to switch to main first
   - If there are uncommitted changes: Warn the user and ask how to proceed (stash, commit, or abort)
2. **Ensure main is up to date**: Run `git status` to check for uncommitted changes
   - If the project has a remote: Suggest `git pull` but do not force it

### During Feature Development (specify → verify)

spec-kit handles the branch creation automatically during `speckit-specify`:
- Creates branch `{NNN}-{short-name}` and switches to it
- All subsequent commands (`plan`, `tasks`, `implement`, `verify`) execute on this Feature branch
- smart-sdd validates the current branch matches the expected Feature branch before each step

**Branch validation** (for `plan`, `tasks`, `implement`, `verify`):
1. Run `git branch --show-current` to get the current branch name
2. Extract the numeric prefix (e.g., `001` from `001-auth`)
3. Match against the Feature's spec-kit Name prefix in `sdd-state.md`'s Feature Mapping
4. If mismatch: Display the expected branch and current branch, ask user to switch

### Post-Feature Merge: After verify Completes

After verify completes and Global Evolution Layer updates are applied:

**Step 0 — Verify-Success Gate (BLOCKING)**:
Before ANY merge activity, check the Feature's verification status in `sdd-state.md`:
- If the Feature's last verification result is **not `success`** (or if no verification was recorded): **BLOCK the merge**.
  ```
  ❌ Cannot merge [FID] - [Feature Name]: Verification has not passed.
  Last verify result: [failure/not recorded]

  Run `/smart-sdd verify [FID]` and ensure all checks pass before merging.
  ```
- Only proceed to Step 1 if verify status is `success`.

**Step 1 — Commit Global Evolution updates on the Feature branch**:
All Post-Feature Completion updates (entity-registry.md, api-registry.md, roadmap.md, pre-context.md updates, sdd-state.md) are committed on the Feature branch before merging.

**Step 2 — Merge Checkpoint (HARD STOP)**:
Present the merge summary to the user via AskUserQuestion:

```
🔀 Feature merge: [FID] - [Feature Name]

Branch: {NNN}-{short-name} → main

── Changes Summary ─────────────────────────────
  Commits: [N commits on this branch]
  Files changed: [count]
  Tests: [pass count]/[total] passed
  Build: [success/failure]

── Global Evolution Updates ────────────────────
  entity-registry.md: [changes summary]
  api-registry.md: [changes summary]
  roadmap.md: [Feature] → completed
  sdd-state.md: updated

─────────────────────────────────────────────────
```

Options:
- "Merge to main" — Proceed with merge
- "Review changes first" — Show detailed diff before merging
- "Skip merge (stay on branch)" — Keep the branch for manual merge later

**If response is empty → re-ask** (per MANDATORY RULE 1). Do NOT auto-merge.

**Step 3 — Execute merge** (only after user approval):
1. Switch to main: `git checkout main`
2. Merge the Feature branch: `git merge {NNN}-{short-name}`
   - Use the default merge strategy (no squash, no rebase — preserving commit history)
   - If merge conflicts occur: Report the conflicts to the user and **stop**. Do NOT attempt to resolve merge conflicts automatically.
3. Verify the merge was clean: `git status`
4. Record the merge in `sdd-state.md` Feature Detail Log

**Step 4 — Post-merge cleanup**:
- Do NOT delete the Feature branch automatically
- Display: "Feature branch `{NNN}-{short-name}` has been merged to main. You may delete it with `git branch -d {NNN}-{short-name}` if no longer needed."

### Step Mode Branch Handling

When using Step Mode (e.g., `/smart-sdd verify F001`):
- Each command validates the current branch as described in Prerequisite Validation
- After `verify` in Step Mode, the merge step is **not** automatically triggered. The user must explicitly run the pipeline or manually merge.
- To trigger the merge for a completed Feature in Step Mode, the user can run `/smart-sdd pipeline` which will detect the completed-but-unmerged Feature and proceed with the merge Checkpoint.

### Non-Git Projects

If the project directory is not a git repository:
- Skip all branch management (pre-flight, validation, merge)
- Display a one-time notice: "No git repository detected. Branch management is disabled."
- All other smart-sdd functionality works normally

---

## Per-Command Context Injection Details

For detailed per-command context injection rules, refer to [context-injection-rules.md](reference/context-injection-rules.md).
For the sdd-state.md file schema, refer to [state-schema.md](reference/state-schema.md).
