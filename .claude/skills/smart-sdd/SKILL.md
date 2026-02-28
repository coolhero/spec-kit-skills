---
name: smart-sdd
description: Orchestrates the spec-kit SDD workflow for greenfield and brownfield projects. Supports new project setup, adding Features to existing projects, and full rebuild via reverse-spec.
argument-hint: <command> [feature-id] [--from path] [--auto] [--prd path]
disable-model-invocation: true
allowed-tools: [Read, Grep, Glob, Bash, Write, Task, Skill, AskUserQuestion]
---

# Smart-SDD: spec-kit Workflow Orchestrator

Wraps spec-kit commands with cross-Feature context injection and Global Evolution Layer management. Works with three project modes:

- **Greenfield**: New project from scratch via `/smart-sdd init`
- **Brownfield (incremental)**: Add Features to an existing smart-sdd project via `/smart-sdd add`
- **Brownfield (rebuild)**: Full re-implementation from reverse-spec artifacts via `/smart-sdd pipeline`

Does not replace spec-kit commands, but wraps them with a 4-step protocol: **Context Assembly → User Confirmation → spec-kit Execution → Global Evolution Update**.

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
| spec-kit constitution | `./specs/constitution.md` | Native spec-kit path |
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
  First token  → command (init | add | pipeline | constitution | specify | plan | tasks | implement | verify | status)
  Second token → feature-id (format: F001, required when command is specify/plan/tasks/implement/verify)
  --from <path> → artifacts path (defaults to ./specs/reverse-spec/ if not specified)
  --prd <path>  → Path to PRD document (only for init command)
  --auto        → Skip Checkpoint confirmation and execute all steps automatically
```

**BASE_PATH** determination:
- If `--from` is specified: use that path
- If not specified: `./specs/reverse-spec/`

**Pre-validation** (for all commands):

**Step 0 — spec-kit installation check** (all commands including `init`):
1. Check if spec-kit is available by running: `speckit --version` (or `which speckit`)
2. If not found, automatically install it:
   ```
   uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
   ```
3. Verify installation succeeded by running `speckit --version` again
4. If installation fails, display the error and instruct the user to install manually

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

2. **For each Feature, define**:
   - Feature name (concise English, e.g., "auth", "product", "order")
   - Description (1-2 sentences)
   - Tier classification (present Tier definitions, let user assign or confirm suggestion):
     - Tier 1 (Essential): System cannot function without it
     - Tier 2 (Recommended): Completes core UX, system works without but value diminished
     - Tier 3 (Optional): Auxiliary, can be added later
   - Classification rationale (1 sentence)

3. **Define dependencies between Features**:
   - For each Feature: "Which other Features does this depend on?"
   - Record dependency type (entity reference, API call, shared logic)
   - Validate no circular dependencies exist

4. **Assign Feature IDs**:
   - Perform topological sort on the dependency graph
   - Assign F001, F002, ... in topological order
   - Features at the same level: Tier 1 first, then Tier 2, then Tier 3

5. **Define Release Groups**:
   - Propose grouping based on dependency layers and Tiers
   - Present to user for confirmation/adjustment

6. **Checkpoint (HARD STOP)**: Display the complete Feature catalog, dependency graph (Mermaid), and Release Groups. Use AskUserQuestion to ask for approval. **You MUST STOP and WAIT for the user's response. Do NOT proceed to Phase 3 until the user explicitly approves.**

#### Phase 3: Constitution Seed Definition

1. **Present the 6 Best Practices** with descriptions:
   - I. Test-First (NON-NEGOTIABLE) — Write tests first. Code without tests is not complete
   - II. Think Before Coding — No assumptions. Mark unclear items as `[NEEDS CLARIFICATION]`
   - III. Simplicity First — Implement only what is in the spec. No speculative additions
   - IV. Surgical Changes — No "improving" adjacent code. Only clean up own changes
   - V. Goal-Driven Execution — Verifiable completion criteria required
   - VI. Demo-Ready Delivery — Each Feature must be demonstrable upon completion. Include demo instructions so the Feature can be launched, exercised, and verified

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
   - Note: "Entities will be populated as Features are planned via /speckit.plan."

4. **`api-registry.md`**: Empty registry with headers only
   - Note: "Endpoints will be populated as Features are planned via /speckit.plan."

5. **`features/F00N-name/pre-context.md`** (per Feature): Simplified greenfield format
   - Source Reference: "N/A — Greenfield project"
   - For /speckit.specify: Feature description + dependencies only (no FR/SC drafts)
   - For /speckit.plan: Dependencies + empty entity/API draft sections (note: "Define during /speckit.plan")
   - For /speckit.analyze: Dependency-based cross-Feature verification points

6. **`sdd-state.md`**: Initialize with Origin: `greenfield`, all Features set to `pending`

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

When `--auto` is specified, Phase 2 and Phase 3 Checkpoints are skipped (content is displayed but proceeds immediately). However, interactive Q&A in Phases 1-3 still requires user input. If `--prd` is provided with `--auto`, reasonable defaults are used throughout (all 5 Best Practices, AI-suggested Tier assignments and Release Groups).

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

## Common Protocol: Assemble → Checkpoint → Execute → Update

All spec-kit command executions follow this 4-step protocol.

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

**`--auto` mode**: When `--auto` is specified, the Checkpoint step is skipped. The assembled context is still **displayed** to the user (for transparency), but execution proceeds immediately without waiting for approval. This is the ONLY way to bypass Checkpoints.

**`--dangerously-skip-permissions` environment**: When Claude Code is run with `--dangerously-skip-permissions`, AskUserQuestion may not function. In this case, **Checkpoints are NOT automatically skipped** — instead, the assembled context is displayed and you MUST ask for confirmation via a regular text message: "Do you approve the above context? (yes/no)". You MUST then STOP and WAIT for the user's text response before proceeding. Only `--auto` explicitly opts out of Checkpoints; `--dangerously-skip-permissions` alone does not.

### 3. Execute — spec-kit Command Execution

Executes the corresponding spec-kit command with the approved context:
- Invokes `speckit.[command]` via the Skill tool
- Includes the assembled context content in the conversation so spec-kit can reference it
- Feature artifacts created/modified by the spec-kit command are located under `specs/{NNN-feature}/`

### 4. Update — Global Evolution Layer Refresh

Updates global artifacts to reflect the command execution results:

| Completed Step | Update Target | Content |
|----------------|--------------|---------|
| plan | `entity-registry.md` | Reflect new entities/changes from the `data-model.md` finalized in the plan |
| plan | `api-registry.md` | Reflect new APIs/changes from the `contracts/` finalized in the plan |
| implement | `roadmap.md` | Change Feature status to completed |
| implement | Subsequent Feature `pre-context.md` | Update pre-context affected by changed entities/APIs |
| verify | `sdd-state.md` | Record verification results |

Reports the changes to the user after the update.

---

## Pipeline Mode

Running `/smart-sdd pipeline` progresses through the entire workflow sequentially.

### Pipeline Initialization

Before Phase 0, check if `BASE_PATH/sdd-state.md` exists. If not, initialize it:
1. Read `BASE_PATH/roadmap.md` to extract the Feature list and Tiers
2. Generate `sdd-state.md` following the [state-schema.md](reference/state-schema.md) format
3. Set Origin based on the project type (`greenfield` or `reverse-spec`)

### Phase 0: Constitution Finalization

**Skip check**: Before executing, check if `SPEC_PATH/constitution.md` (i.e., `specs/constitution.md`) already exists. If it does, skip Phase 0 entirely and proceed to Phase 1. This covers:
- `add` mode (constitution already created in previous pipeline runs)
- Pipeline re-runs after interruption (constitution was already finalized)
- Any scenario where `/speckit.constitution` has already been executed

**If constitution.md does not exist**:
1. Reads `BASE_PATH/constitution-seed.md`
   - For greenfield/init: Uses the constitution-seed generated by the init command
   - For rebuild: Uses the constitution-seed generated by `/reverse-spec`
2. Shows the user a summary of the constitution-seed content and provides an opportunity to revise/supplement (Checkpoint — HARD STOP, same rules as Common Protocol)
3. Provides the constitution-seed content as context when executing `/speckit.constitution`
4. Records the constitution completion in `sdd-state.md`

### Phase 1~N: Progress Features in Release Group Order

Follows the Release Groups order from `BASE_PATH/roadmap.md`. **Skips completed Features** — only processes Features with `pending` or `in_progress` status in `sdd-state.md`.

**CRITICAL: Each Feature must complete ALL 6 steps (including implement and verify) before moving to the next Feature.** Do NOT skip implement or verify. Do NOT start the next Feature until the current Feature's verify step is complete.

Executes the following steps **strictly in order** for each Feature:

```
1. specify   → Assemble → Checkpoint → /speckit.specify → Update
2. clarify   → (Only run /speckit.clarify if [NEEDS CLARIFICATION] exists in the spec)
3. plan      → Assemble → Checkpoint → /speckit.plan → Update (entity-registry, api-registry)
4. tasks     → Checkpoint → /speckit.tasks
5. implement → Checkpoint → /speckit.implement (MUST execute — actual code is written here)
6. verify    → Execution verification → Cross-Feature verification → Global Evolution update

── Feature DONE ── only now proceed to the next Feature ──
```

> **Why implement cannot be skipped**: The entire purpose of this pipeline is to produce working, tested code. Specs and plans without implementation have no value. The implement step writes the actual source code, and the verify step confirms it works. Subsequent Features depend on the preceding Feature's **actual implementation** (not just its plan) to ensure cross-Feature consistency.

#### Post-Feature Completion Processing

Once **all 6 steps** for a Feature are complete (including implement and verify):

1. **Update entity-registry.md**: Reflect entities from the data-model.md finalized in the plan
2. **Update api-registry.md**: Reflect APIs from the contracts/ finalized in the plan
3. **Update roadmap.md**: Change the Feature status to `completed`
4. **Impact analysis on subsequent Feature pre-context.md**:
   - Find pre-context.md of subsequent Features that reference changed/added entities
   - Find pre-context.md of subsequent Features that consume changed/added APIs
   - Update the relevant sections in the affected pre-context.md files
   - Report the updates to the user
5. **Update sdd-state.md**: Record the completion time and result for each step

---

## Step Mode

Executes a single command. Validates prerequisites, then runs the common protocol (Assemble → Checkpoint → Execute → Update).

### Prerequisite Validation

| Command | Prerequisite | Validation Method |
|---------|-------------|-------------------|
| `constitution` | constitution-seed exists | Check existence of `BASE_PATH/constitution-seed.md` |
| `specify` | pre-context exists | Check existence of `BASE_PATH/features/[FID]/pre-context.md` |
| `plan` | spec.md exists | Check existence of `specs/[NNN-feature-name]/spec.md` |
| `tasks` | plan.md exists | Check existence of `specs/[NNN-feature-name]/plan.md` |
| `implement` | tasks.md exists | Check existence of `specs/[NNN-feature-name]/tasks.md` |
| `verify` | implement completed | Confirm implement completion in `sdd-state.md` |

If prerequisites are not met, displays an error message and guides the user to the required preceding step.

### Feature ID → spec-kit Feature Name Mapping

Converts a Feature ID (F001) to the Feature Name used by spec-kit (e.g., `001-auth`) using the Feature mapping table in `sdd-state.md` or the Feature Catalog in `roadmap.md`.

---

## Constitution Incremental Update

When new architectural principles or conventions are discovered during Feature progression:

1. **Checkpoint indication**: "Proposing a Constitution update: [principle content]"
2. **User approval**: Uses AskUserQuestion to confirm approval
3. **Execute update**: If approved, performs a MINOR version update via `/speckit.constitution`
4. **Impact analysis**: Displays a warning if already completed Features are affected

---

## Status Command

Running `/smart-sdd status` reads `sdd-state.md` and displays the overall progress.

Follows the schema defined in [state-schema.md](reference/state-schema.md).

Output format:

```
📊 Smart-SDD Progress Status

Origin: [greenfield | reverse-spec]
Constitution: ✅ v1.0.0 (2024-01-15)

Feature         | Tier | specify | plan | tasks | impl | verify
----------------|------|---------|------|-------|------|-------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |  ✅  |   ✅
F002-product    | T1   |   ✅    |  🔄  |       |      |
F003-order      | T2   |         |      |       |      |
F004-payment    | T2   |         |      |       |      |

Overall progress: 1/4 Features completed (25%)
Currently in progress: F002-product → plan step
```

---

## Verify Command

Running `/smart-sdd verify [FID]` performs a 3-phase verification.

### Phase 1: Execution Verification
- Run tests: Check and execute the project's test command from `sdd-state.md`
- Build check: Run the build command and confirm no errors
- Lint check: Run the lint tool if configured

### Phase 2: Cross-Feature Verification
- Run `/speckit.analyze` to perform Feature analysis
- Check the cross-verification points in the "For /speckit.analyze" section of `pre-context.md`
- Analyze whether shared entities/APIs changed by this Feature affect other Features

### Phase 3: Global Evolution Update
- entity-registry.md: Verify that the actually implemented entity schemas match the registry; update if discrepancies are found
- api-registry.md: Verify that the actually implemented API contracts match the registry; update if discrepancies are found
- sdd-state.md: Record verification results (success/failure, test results, verification time)

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

- **NEVER skip implement or verify.** Each Feature must go through all 6 steps (specify → clarify → plan → tasks → implement → verify) before moving to the next Feature. Creating specs/plans for multiple Features without implementing them defeats the purpose of this pipeline.
- Does not alter or override spec-kit command behavior. Only injects context and utilizes results.
- Does not directly modify files managed by spec-kit (`specs/`). Changes are made only through spec-kit commands.
- Global Evolution Layer files (`entity-registry.md`, `api-registry.md`, `roadmap.md`) are modified only during the Update step.
- If `sdd-state.md` does not exist, it is treated as a first run and an initial state file is created.
- For detailed context injection rules, refer to [context-injection-rules.md](reference/context-injection-rules.md).
- For state file schema, refer to [state-schema.md](reference/state-schema.md).
