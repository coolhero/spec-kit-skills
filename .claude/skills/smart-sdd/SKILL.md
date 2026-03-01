---
name: smart-sdd
description: Orchestrates the spec-kit SDD workflow for greenfield and brownfield projects. Supports new project setup, adding Features to existing projects, and full rebuild via reverse-spec.
argument-hint: <command> [feature-id] [--from path] [--auto] [--prd path]
allowed-tools: [Read, Grep, Glob, Bash, Write, Task, Skill, AskUserQuestion]
---

# Smart-SDD: spec-kit Workflow Orchestrator

Wraps spec-kit commands with cross-Feature context injection and Global Evolution Layer management. Works with three project modes:

- **Greenfield**: New project from scratch via `/smart-sdd init`
- **Brownfield (incremental)**: Add Features to an existing smart-sdd project via `/smart-sdd add`
- **Brownfield (rebuild)**: Full re-implementation from reverse-spec artifacts via `/smart-sdd pipeline`

Does not replace spec-kit commands, but wraps them with a 5-step protocol: **Context Assembly → Pre-Execution Checkpoint → spec-kit Execution → Artifact Review → Global Evolution Update**.

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
/smart-sdd implement F001               # Implement Feature F001
/smart-sdd verify F001                   # Verify Feature F001

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
  First token  → command (init | add | expand | pipeline | constitution | specify | plan | tasks | implement | verify | status)
  Second token → feature-id (format: F001, required when command is specify/plan/tasks/implement/verify)
  --from <path> → artifacts path (defaults to ./specs/reverse-spec/ if not specified)
  --prd <path>  → Path to PRD document (only for init command)
  --auto        → Skip Checkpoint confirmation and execute all steps automatically
```

**BASE_PATH** determination:
- If `--from` is specified: use that path
- If not specified: `./specs/reverse-spec/`

**Pre-validation** (for all commands):

**Step 0 — Git and spec-kit installation check** (all commands including `init`):

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
- `init` command: Skip Step 1 (init creates roadmap.md). Step 0 still applies.
- `add` command: roadmap.md **must** exist (adding to an existing project)
- `status` command: If `sdd-state.md` does not exist, display "No project initialized yet" and suggest `init` or `reverse-spec`

> **Note**: BASE_PATH is relative to the CWD. All smart-sdd commands must be invoked from the same project directory.

---

## Init Command — Greenfield Project Setup

Running `/smart-sdd init` sets up a new project by interactively defining Features, dependencies, and development principles, then generating the Global Evolution Layer artifacts.

### Input Sources

1. **PRD document** (`--prd path/to/prd.md`): Reads the PRD file and extracts project description, proposed features, and requirements as starting context for the interactive Q&A
2. **Conversational input**: If no `--prd` is specified, gathers all information through interactive Q&A with the user

### Init Workflow

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

   **You MUST STOP and WAIT for the user's response. Do NOT proceed until the user selects a granularity level.**

   If the user selects "Other", they can describe a custom granularity or request specific merges/splits.

3. **For each Feature (after granularity is selected), define**:
   - Feature name (concise English, e.g., "auth", "product", "order")
   - Description (1-2 sentences)
   - Tier classification (present Tier definitions, let user assign or confirm suggestion):
     - Tier 1 (Essential): System cannot function without it
     - Tier 2 (Recommended): Completes core UX, system works without but value diminished
     - Tier 3 (Optional): Auxiliary, can be added later
   - Classification rationale (1 sentence)
   - **Environment variables** (optional): Variables this Feature will need at runtime
     - Variable name, category (`secret` / `config` / `feature-flag`), required/optional, description
     - If the user doesn't know yet, mark as "TBD — will be determined during plan/implement"

4. **Define dependencies between Features**:
   - For each Feature: "Which other Features does this depend on?"
   - Record dependency type (entity reference, API call, shared logic)
   - Validate no circular dependencies exist

5. **Assign Feature IDs**:
   - Group Features by Tier (Tier 1 → Tier 2 → Tier 3)
   - Within each Tier, sort by topological order (dependency-based)
   - Assign F001, F002, ... sequentially: all Tier 1 first, then Tier 2, then Tier 3
   - This keeps Tier grouping intact while respecting dependency order within each Tier

6. **Define Release Groups**:
   - Propose grouping based on dependency layers and Tiers
   - Present to user for confirmation/adjustment

7. **Checkpoint (HARD STOP)**: Display the complete Feature catalog, dependency graph (Mermaid), and Release Groups. Use AskUserQuestion to ask for approval. **You MUST STOP and WAIT for the user's response. Do NOT proceed to Phase 3 until the user explicitly approves.**

#### Phase 3: Constitution Seed Definition

1. **Present the 6 Best Practices** with descriptions:
   - I. Test-First (NON-NEGOTIABLE) — Write tests first. Code without tests is not complete
   - II. Think Before Coding — No assumptions. Mark unclear items as `[NEEDS CLARIFICATION]`
   - III. Simplicity First — Implement only what is in the spec. No speculative additions
   - IV. Surgical Changes — No "improving" adjacent code. Only clean up own changes
   - V. Goal-Driven Execution — Verifiable completion criteria required
   - VI. Demo-Ready Delivery — Each Feature must be demonstrable upon completion. "Tests pass" alone is NOT sufficient. Implement a minimal demo surface (CLI command, simple demo page, API playground, or demo script) and provide step-by-step instructions in `demos/F00N-name.md`

2. **User selection**: All 6 are selected by default. The user can:
   - Deselect specific practices
   - Modify descriptions
   - Add custom principles (with Rule + Rationale format)

3. **Project conventions**: Ask for project-specific conventions:
   - Naming conventions
   - Project structure conventions
   - Error handling patterns
   - Testing patterns

4. **Checkpoint (HARD STOP)**: Display the complete constitution-seed content. Use AskUserQuestion to ask for approval. **You MUST STOP and WAIT for the user's response. Do NOT proceed to Phase 4 until the user explicitly approves.**

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

6. **`sdd-state.md`**: Initialize with Origin: `greenfield`, Scope: `full`, Active Tiers: `T1,T2,T3`, all Features set to `pending`

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

When `--auto` is specified, Phase 2 and Phase 3 Checkpoints are skipped (content is displayed but proceeds immediately). However, interactive Q&A in Phases 1-3 still requires user input. If `--prd` is provided with `--auto`, reasonable defaults are used throughout (all 6 Best Practices, AI-suggested Tier assignments and Release Groups).

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
   - Tier classification (default: Tier 2)
2. Multiple Features can be added at once (iterative)
3. Define dependencies between new Features if applicable
4. Assign Feature IDs: continue from the last existing ID

#### Phase 3: Checkpoint (HARD STOP)

1. Display new Feature(s) with Tier + dependencies
2. Show the updated Dependency Graph (existing + new nodes)
3. Propose Release Group placement
4. Use AskUserQuestion to ask for approval. **You MUST STOP and WAIT for the user's response. Do NOT proceed to Phase 4 until the user explicitly approves or requests modifications.**

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
  F006-notifications (Tier 2) — depends on F001-auth, F003-order
  F007-analytics (Tier 3) — depends on F002-product

Updated: roadmap.md, sdd-state.md
Created: features/F006-notifications/pre-context.md, features/F007-analytics/pre-context.md

Next steps:
  /smart-sdd specify F006     — Start specifying the first new Feature
  /smart-sdd pipeline         — Resume pipeline (picks up from first pending Feature)
```

---

## Common Protocol: Assemble → Checkpoint → Execute → Review → Update

All spec-kit command executions follow this 5-step protocol.

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

**CRITICAL — Checkpoint is a HARD STOP. You MUST NOT proceed past the Checkpoint without explicit user approval.**

After displaying the assembled context above, you MUST:
1. Use AskUserQuestion to ask: "Approve and proceed?" with options: "Approve as-is", "Request modifications"
2. **STOP and WAIT** for the user's response. Do NOT assume approval. Do NOT continue to the Execute step.
3. Only after the user explicitly responds with approval (selects "Approve as-is" or says "yes"/"proceed"/"approved"), move to the Execute step.
4. If the user requests changes, apply them, re-display the updated content, and ask again.

**You are NOT allowed to approve on behalf of the user. "User approved" must come from an actual user action, not from your own judgment.**

**Empty or missing response handling**: If AskUserQuestion returns an empty response, a blank string, or no meaningful selection, this is NOT approval. You MUST:
- Display: "⚠️ No approval received. Please confirm: approve the above context? (yes/no)"
- STOP and WAIT again. Repeat until a clear affirmative or negative response is received.
- NEVER interpret silence, empty response, or lack of explicit rejection as implicit approval.

**`--auto` mode**: When `--auto` is specified, the Checkpoint step is skipped. The assembled context is still **displayed** to the user (for transparency), but execution proceeds immediately without waiting for approval. This is the ONLY way to bypass Checkpoints.

**`--dangerously-skip-permissions` environment**: When Claude Code is run with `--dangerously-skip-permissions`, AskUserQuestion may not function. In this case, **Checkpoints are NOT automatically skipped** — instead, the assembled context is displayed and you MUST ask for confirmation via a regular text message: "Do you approve the above context? (yes/no)". You MUST then STOP and WAIT for the user's text response before proceeding. Only `--auto` explicitly opts out of Checkpoints; `--dangerously-skip-permissions` alone does not.

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

### 4. Review — Artifact Review

After spec-kit command execution completes, present the generated/modified artifacts to the user for review.

**Review Display Format**:

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

──────────────────────────────────────────────────

Review the generated artifact. You can:
  - Approve and continue to the next step
  - Request modifications (spec-kit will regenerate)
  - Edit the artifact files directly
```

For detailed per-command Review Display Content, see [context-injection-rules.md](reference/context-injection-rules.md).

**CRITICAL — Review is a HARD STOP (same rules as Checkpoint).**

You MUST:
1. Use AskUserQuestion to ask: "Approve the result?" with options: "Approve", "Request modifications", "Edit manually"
2. **STOP and WAIT** for the user's response. Do NOT assume approval. Do NOT continue to the Update step.
3. If "Request modifications": Ask what to change, re-execute the spec-kit command with the feedback, and re-display the Review.
4. If "Edit manually": Wait for the user to signal they are done editing, then proceed to Update.
5. Only after the user explicitly responds with approval (selects "Approve" or says "yes"/"approved"), move to the Update step.

**You are NOT allowed to approve on behalf of the user. "User approved" must come from an actual user action, not from your own judgment.**

**Empty or missing response handling**: If AskUserQuestion returns an empty response, a blank string, or no meaningful selection, this is NOT approval. You MUST:
- Display: "⚠️ No approval received. Please confirm: approve the generated artifact? (yes/no)"
- STOP and WAIT again. Repeat until a clear affirmative or negative response is received.
- NEVER interpret silence, empty response, or lack of explicit rejection as implicit approval.

**`--auto` mode**: When `--auto` is specified, the Review step is skipped. The generated artifact summary is still **displayed** to the user (for transparency), but execution proceeds immediately to Update without waiting for approval.

**`--dangerously-skip-permissions` environment**: When AskUserQuestion is unavailable, Review is still enforced — the artifact summary is displayed and you MUST ask for confirmation via a regular text message: "Do you approve the generated artifact? (yes/no)". You MUST then STOP and WAIT for the user's text response before proceeding.

### 5. Update — Global Evolution Layer Refresh

Updates global artifacts to reflect the command execution results. For detailed update rules per step, see [context-injection-rules.md → Post-Step Update Rules Detail](reference/context-injection-rules.md#post-step-update-rules-detail).

| Completed Step | Update Target | Content |
|----------------|--------------|---------|
| plan | `entity-registry.md` | Reflect new entities/changes from the `data-model.md` finalized in the plan |
| plan | `api-registry.md` | Reflect new APIs/changes from the `contracts/` finalized in the plan |
| implement | `roadmap.md` | Change Feature status to completed |
| implement | Subsequent Feature `pre-context.md` | Update pre-context affected by changed entities/APIs |
| verify | `sdd-state.md` | Record verification results |
| merge | `sdd-state.md` | Record merge completion, update Feature Mapping |

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

**You MUST STOP and WAIT for the user's response.** Do NOT auto-confirm.

**Step 3 — Scope display**:
Read `Scope` and `Active Tiers` from `sdd-state.md` and display scope information:

| Active Tiers | Display |
|-------------|---------|
| `T1` | "📋 Scope: Core — Only Tier 1 Features will be processed. Use `/smart-sdd expand` to add Tier 2/3 later." |
| `T1,T2` | "📋 Scope: Expanded — Tier 1 + Tier 2 Features will be processed. Tier 3 deferred." |
| `T1,T2,T3` | "📋 Scope: Full — All Features will be processed." |

If deferred Features exist, list them:
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
1. Reads `BASE_PATH/constitution-seed.md`
   - For greenfield/init: Uses the constitution-seed generated by the init command
   - For rebuild: Uses the constitution-seed generated by `/reverse-spec`
2. Shows the user a summary of the constitution-seed content and provides an opportunity to revise/supplement (Checkpoint — HARD STOP, same rules as Common Protocol)
3. Provides the constitution-seed content as context when executing `speckit-constitution`
4. Records the constitution completion in `sdd-state.md`

### Environment Setup (before first implement)

When the pipeline reaches the **first Feature's implement step** (i.e., the very first time implement runs in this pipeline session):

**Step 1 — Collect required env vars**:
Read all `pre-context.md` files for **active** (non-deferred) Features and aggregate the Environment Variables sections.

**Step 2 — Check for existing .env**:
- If `.env` exists in CWD: Check for the **presence** of required variable names (do NOT read actual values)
  - ✅ Found: list vars that are present
  - ❌ Missing: list vars that are needed but not in `.env`
- If `.env` does not exist: All vars are missing

**Step 3 — Environment Setup Checkpoint (HARD STOP)**:
Display the aggregated env var requirements and guide the user:

```
📋 Environment Setup Required

The following environment variables are needed for implementation and testing:

── Secrets (must be set by you) ──────────────────
  DATABASE_URL        — [Required] Database connection string
  JWT_SECRET          — [Required] JWT signing secret
  OPENAI_API_KEY      — [Optional] AI feature integration

── Configuration ─────────────────────────────────
  PORT                — [Optional] Server port (default: 3000)
  NODE_ENV            — [Optional] Environment mode

Status: .env file [exists / does not exist]
  ✅ DATABASE_URL — already set
  ❌ JWT_SECRET — missing
  ❌ OPENAI_API_KEY — missing

👉 Please create or update your .env file with the required values.
   A .env.example file is available as a template.

⚠️ I will NOT ask you to paste secret values here.
   Edit the .env file directly in your editor.
```

Use AskUserQuestion:
- "Environment is ready — proceed with implementation"
- "Skip for now — I'll set up env vars later"

If "Skip for now":
- Display a warning: "⚠️ Tests may fail due to missing environment variables."
- Proceed but record in `sdd-state.md` Global Evolution Log: "Environment: partial (user skipped setup)"

**Important**: This checkpoint runs only **once** (before the first implement). Subsequent Features do NOT re-trigger the full env setup, but individual Feature implement steps will note any NEW env vars introduced by that Feature (see below).

**Skip conditions**: If no Features have Environment Variables in their pre-context.md, skip this checkpoint entirely.

### Phase 1~N: Progress Features in Release Group Order

Follows the Release Groups order from `BASE_PATH/roadmap.md`. **Skips completed and deferred Features** — only processes Features with `pending` or `in_progress` status in `sdd-state.md`. Features with `deferred` status (outside current Active Tiers) are not processed. Use `/smart-sdd expand` to activate deferred Features.

**CRITICAL: Each Feature must complete ALL steps (specify through verify and merge) before moving to the next Feature.** Do NOT skip implement or verify. Do NOT start the next Feature until the current Feature's merge step is complete.

Executes the following steps **strictly in order** for each Feature:

```
0. pre-flight → Ensure on main branch (clean state)
1. specify    → Assemble → Checkpoint → speckit-specify → Review → Update
                (spec-kit creates Feature branch: {NNN}-{short-name})
2. clarify    → (Only run speckit-clarify if [NEEDS CLARIFICATION] exists in the spec)
3. plan       → Assemble → Checkpoint → speckit-plan → Review → Update (entity-registry, api-registry)
4. tasks      → Checkpoint → speckit-tasks → Review
5. implement  → Env notice (new vars only) → Checkpoint → speckit-implement → Review
6. verify     → Execution verification → Cross-Feature verification → Global Evolution update
7. merge      → Checkpoint (HARD STOP) → Merge Feature branch to main → Cleanup

── Feature DONE ── only now proceed to the next Feature ──
```

#### Per-Feature Environment Variable Notice (implement step)

Before running `speckit-implement`, check the current Feature's `pre-context.md` for Environment Variables. If the Feature introduces **new** variables (not shared from preceding Features), display an informational notice:

```
📋 New environment variables for [FID]-[name]:
  STRIPE_SECRET_KEY — [Required] Payment processing API key

👉 Ensure these are added to your .env file before proceeding.
```

This is informational — NOT a HARD STOP (the full env setup was already confirmed before the first implement). If the user hasn't completed the initial env setup, they were already warned.

> **Git branching**: spec-kit automatically creates a Feature branch during `speckit-specify`. All subsequent steps (plan through verify) execute on that branch. After verify completes, smart-sdd handles the merge back to main. See [Git Branch Management](#git-branch-management) for details.

> **Why implement cannot be skipped**: The entire purpose of this pipeline is to produce working, tested code. Specs and plans without implementation have no value. The implement step writes the actual source code, and the verify step confirms it works. Subsequent Features depend on the preceding Feature's **actual implementation** (not just its plan) to ensure cross-Feature consistency.

#### Post-Feature Completion Processing

Once **all steps** for a Feature are complete (including implement, verify, and merge):

1. **Update entity-registry.md**: Reflect entities from the data-model.md finalized in the plan
2. **Update api-registry.md**: Reflect APIs from the contracts/ finalized in the plan
3. **Update roadmap.md**: Change the Feature status to `completed`
4. **Impact analysis on subsequent Feature pre-context.md**:
   - Find pre-context.md of subsequent Features that reference changed/added entities
   - Find pre-context.md of subsequent Features that consume changed/added APIs
   - Update the relevant sections in the affected pre-context.md files
   - Report the updates to the user
5. **Update sdd-state.md**: Record the completion time and result for each step
6. **Merge Feature branch to main**: See [Git Branch Management](#git-branch-management)
   - Commit all Global Evolution Layer updates on the Feature branch
   - Present merge summary to user (HARD STOP)
   - Merge to main after user approval
   - Return to main branch, ready for the next Feature

---

## Step Mode

Executes a single command. Validates prerequisites, then runs the common protocol (Assemble → Checkpoint → Execute → Review → Update).

### Prerequisite Validation

| Command | Prerequisite | Validation Method |
|---------|-------------|-------------------|
| `constitution` | constitution-seed exists | Check existence of `BASE_PATH/constitution-seed.md` |
| `specify` | pre-context exists, on main branch | Check existence of `BASE_PATH/features/[FID]/pre-context.md`. Verify current branch is `main` (spec-kit will create the Feature branch) |
| `plan` | spec.md exists, on Feature branch | Check existence of `specs/[NNN-feature-name]/spec.md`. Verify current branch matches the Feature |
| `tasks` | plan.md exists, on Feature branch | Check existence of `specs/[NNN-feature-name]/plan.md`. Verify current branch matches the Feature |
| `implement` | tasks.md exists, on Feature branch | Check existence of `specs/[NNN-feature-name]/tasks.md`. Verify current branch matches the Feature |
| `verify` | implement completed, on Feature branch | Confirm implement completion in `sdd-state.md`. Verify current branch matches the Feature |

If prerequisites are not met, displays an error message and guides the user to the required preceding step.

**Deferred Feature check**: Before checking other prerequisites, verify the Feature's status in `sdd-state.md`. If the Feature is `deferred` (outside current Active Tiers), display:
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

Output format:

```
📊 Smart-SDD Progress Status

Origin: [greenfield | reverse-spec]
Scope: [core | full] | Active Tiers: [T1 | T1,T2 | T1,T2,T3]
Constitution: ✅ v1.0.0 (2024-01-15)

Feature         | Tier | specify | plan | tasks | impl | verify | merge | Status
----------------|------|---------|------|-------|------|--------|-------|----------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |  ✅  |   ✅   |  ✅  | completed
F002-product    | T1   |   ✅    |  🔄  |       |      |        |      | in_progress
F003-cart       | T2   |         |      |       |      |        |      | 🔒 deferred
F004-payment    | T2   |         |      |       |      |        |      | 🔒 deferred

Active: 1/4 completed, 1/4 in progress | Deferred: 2 (Tier 2)
💡 Use /smart-sdd expand to activate deferred Features
```

> If Scope is `full` and Active Tiers is `T1,T2,T3` (no deferred Features), the Scope line and deferred hint are omitted for cleaner output.

---

## Expand Command — Activate Deferred Tiers

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

**You MUST STOP and WAIT for the user's response. Do NOT auto-select.**

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

## Verify Command

Running `/smart-sdd verify [FID]` performs a 3-phase verification.

### Phase 1: Execution Verification
- Run tests: Check and execute the project's test command from `sdd-state.md`
- Build check: Run the build command and confirm no errors
- Lint check: Run the lint tool if configured

### Phase 2: Cross-Feature Verification
- Run `speckit-analyze` to perform Feature analysis
- Check the cross-verification points in the "For /speckit.analyze" section of `pre-context.md`
- Analyze whether shared entities/APIs changed by this Feature affect other Features

### Phase 3: Demo-Ready Verification (only if VI. Demo-Ready Delivery is in the constitution)
- Check that `demos/F00N-name.md` exists for the Feature
- Check that a demo surface exists (not just tests): CLI command, demo script, demo page, or API playground
- Check that `demos/F00N-name.md` includes a **Demo Components** table categorizing each component as Demo-only or Promotable with a clear Fate
- Check that demo-only components are marked with `// @demo-only` and promotable components with `// @demo-scaffold — will be extended by F00N-[feature]`
- If any check fails, **block verification** and instruct the user:
  ```
  ❌ Demo-Ready verification failed for [FID] - [Feature Name]:
    - [Missing: demos/F00N-name.md | Missing: demo surface implementation | Missing: Demo Components table | Missing: component markers]

  "Tests pass" alone does not satisfy Demo-Ready Delivery.
  Please implement a minimal demo surface, create demos/F00N-name.md with Demo Components table,
  and mark all demo code with appropriate category markers.
  ```
- Update `demos/README.md` (Demo Hub) with the Feature's demo status

> **If VI. Demo-Ready Delivery is NOT in the constitution**: Skip this phase entirely.

### Phase 4: Global Evolution Update
- entity-registry.md: Verify that the actually implemented entity schemas match the registry; update if discrepancies are found
- api-registry.md: Verify that the actually implemented API contracts match the registry; update if discrepancies are found
- sdd-state.md: Record verification results (success/failure, test results, verification time)

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

**You MUST STOP and WAIT for the user's response. Do NOT auto-merge.**

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

The context sources and content injected per command are defined in [context-injection-rules.md](reference/context-injection-rules.md). Below is a summary.

| Command | Injection Source | Injected Content |
|---------|-----------------|-----------------|
| constitution | `constitution-seed.md` | Full content (source reference principles, architectural principles, best practices, Global Evolution operational principles) |
| specify | `pre-context.md` → "For /speckit.specify" + `business-logic-map.md` (relevant Feature section) | Feature summary, FR-### drafts, SC-### drafts, edge cases, business rules. **If business-logic-map.md missing (greenfield/add), skip business logic injection** |
| plan | `pre-context.md` → "For /speckit.plan" + `entity-registry.md` (related entities) + `api-registry.md` (related APIs) | Dependencies, entity/API drafts, technical decisions, preceding Feature results. **If registries empty (early greenfield), skip registry injection** |
| tasks | `plan.md` (spec-kit artifact) | Automatic execution based on plan |
| implement | `tasks.md` (spec-kit artifact) | Automatic execution based on tasks |
| verify/analyze | `pre-context.md` → "For /speckit.analyze" | Cross-Feature verification points, impact scope |

---

## Important Notes

- **NEVER skip implement or verify.** Each Feature must go through all steps (specify → clarify → plan → tasks → implement → verify → merge) before moving to the next Feature. Creating specs/plans for multiple Features without implementing them defeats the purpose of this pipeline.
- **Git branch discipline**: Each Feature is developed on its own branch. Never start a new Feature without merging (or explicitly skipping) the previous Feature's branch. This ensures main always reflects the latest stable state.
- Does not alter or override spec-kit command behavior. Only injects context and utilizes results.
- Does not directly modify files managed by spec-kit (`specs/`). Changes are made only through spec-kit commands.
- Global Evolution Layer files (`entity-registry.md`, `api-registry.md`, `roadmap.md`) are modified only during the Update step.
- If `sdd-state.md` does not exist, it is treated as a first run and an initial state file is created.
- For detailed context injection rules, refer to [context-injection-rules.md](reference/context-injection-rules.md).
- For state file schema, refer to [state-schema.md](reference/state-schema.md).
