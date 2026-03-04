---
name: smart-sdd
description: Orchestrates the spec-kit SDD workflow for greenfield and brownfield projects. Supports new project setup, adding Features to existing projects, and full rebuild via reverse-spec.
argument-hint: "<command> [feature-id] [--from path] [--auto] [--prd path] [--source path] [--domain app]  # commands: init|add|adopt|pipeline|specify|plan|tasks|analyze|implement|verify|restructure|expand|parity|status"
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
> **Rule 2: Demo = Real Working Feature, NOT a Test Suite**
> When Demo-Ready Delivery is active, the demo MUST be an **executable script** (`demos/F00N-name.sh` or `.ts`/`.py`) that **launches the real, working Feature** so the user can experience it:
> - Default behavior: Start the Feature → print "Try it" instructions (URLs, commands) → keep running until Ctrl+C
> - `--ci` flag: Quick health check → exit (for `verify` Phase 3 automation)
> - ✅ CORRECT: `demos/F001-auth.sh` starts the server with demo data, prints `Open http://localhost:3000/login`, keeps running
> - ❌ WRONG: A script that runs curl assertions, prints `3/3 passed`, and exits — that's a test suite
> - ❌ WRONG: A markdown file with "## Demo Steps" and manual instructions
> - ❌ WRONG: Showing demo steps as text in the chat instead of writing a script file
>
> Tests belong in `verify` Phase 1. Demos show the **real thing running**. The user must be able to see, touch, and use the Feature.

Wraps spec-kit commands with cross-Feature context injection and Global Evolution Layer management. Works with three project modes:

- **Greenfield**: New project from scratch via `/smart-sdd init`
- **Brownfield (incremental)**: Add Features to an existing smart-sdd project via `/smart-sdd add`
- **Brownfield (rebuild)**: Full re-implementation from reverse-spec artifacts via `/smart-sdd pipeline`
- **Brownfield (adoption)**: Wrap existing code with SDD documentation via `/smart-sdd adopt`

Does not replace spec-kit commands, but wraps them with a 4-step protocol: **Context Assembly → Pre-Execution Checkpoint → spec-kit Execution + Artifact Review → Global Evolution Update**.

---

## Usage

```
# Greenfield — New project setup
/smart-sdd init                          # Interactive greenfield project setup
/smart-sdd init --prd path/to/prd.md     # Setup from a PRD document

# Brownfield (incremental) — Add new Feature(s) to existing smart-sdd project
/smart-sdd add                           # Interactive: define and add new Feature(s)

# Adoption — Wrap existing code with SDD documentation (after reverse-spec)
/smart-sdd adopt                         # Adopt existing code with SDD docs
/smart-sdd adopt --auto                  # Without stopping for confirmation
/smart-sdd adopt --from ./path           # Read artifacts from specified path

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
specs/
├── history.md                          # Decision history (auto-generated, shared by both skills)
└── reverse-spec/
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
  First token  → command (init | add | adopt | restructure | expand | pipeline | constitution | specify | plan | tasks | analyze | implement | verify | status | parity)
  Second token → feature-id (format: F001, required when command is specify/plan/tasks/analyze/implement/verify)
  --from <path>   → artifacts path (defaults to ./specs/reverse-spec/ if not specified)
  --prd <path>    → Path to PRD document (only for init command)
  --source <path> → Original source path for parity check (only for parity command)
  --auto          → Skip Checkpoint confirmation and execute all steps automatically
  --domain <val>  → Project domain profile: "app" (default). Determines demo pattern, parity dimensions, and verify steps
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

## Domain Profile

The `--domain` argument selects the domain profile. Default: `app`.

**Loading**: After argument parsing, read `domains/{domain}.md` for domain-specific behavior:
- **Demo Pattern**: How to demo completed Features (used in verify Phase 3)
- **Parity Dimensions**: What to compare in parity checks
- **Verify Steps**: What verification steps to run (test, build, lint, etc.)

For reverse-spec domain profiles (analysis axes, registries, etc.), see `../reverse-spec/domains/{domain}.md`.

---

## Common Protocol: Assemble → Checkpoint → Execute+Review → Update

**All spec-kit command executions follow this 4-step protocol. Each step MUST be executed in order. No step may be skipped (unless `--auto` mode is active).**

```
┌───────────┐    ┌────────────┐    ┌─────────────────────┐    ┌────────┐
│ 1.Assemble│───→│2.Checkpoint│───→│3.Execute + Review   │───→│4.Update│
│  (context)│    │ (HARD STOP)│    │  (spec-kit + STOP)  │    │ (state)│
└───────────┘    └────────────┘    └─────────────────────┘    └────────┘
```

### 1. Assemble — Context Assembly
Reads files/sections required for the given command from BASE_PATH. Filters and assembles information per command according to the per-command injection rules in [`reference/injection/{command}.md`](reference/injection/). Graceful degradation per [context-injection-rules.md](reference/context-injection-rules.md) § Missing/Sparse Content Handling.

### 2. Checkpoint — User Confirmation (HARD STOP)
Presents the assembled context with **actual content** (not just counts). The user reviews what will be injected and approves or requests modifications. Uses **PROCEDURE CheckpointApproval** (Approve as-is / Request modifications loop).

### 3. Execute + Review (HARD STOP)
Invokes the corresponding `speckit-[command]` via the Skill tool with the approved context. **Execute and Review are ONE continuous action** — after the spec-kit command returns, IMMEDIATELY read the generated artifacts, display the Review content, and call AskUserQuestion for approval. Do NOT generate a separate response between Execute and Review.

**Skill Invocation Fallback**: If "Unknown skill" is returned, read `.claude/skills/speckit-[command]/SKILL.md` and execute inline.

**SUPPRESS spec-kit output**: Ignore all "Next phase:", "Suggested commit:" messages from spec-kit. smart-sdd controls the workflow.

Review uses **PROCEDURE ReviewApproval** (Approve / Request modifications / I've finished editing loop).

### 4. Update — Global Evolution Layer Refresh
Updates global artifacts (registries, state, roadmap) to reflect command results. See per-command injection rules in [`reference/injection/{command}.md`](reference/injection/) for update rules.

**HARD STOP rules**: Both Checkpoint (Step 2) and Review (Step 3) require explicit user approval via AskUserQuestion. After AskUserQuestion returns, ALWAYS check the response — if empty, re-ask. Never proceed on empty.

**`--auto` mode**: BOTH Checkpoint and Review are skipped — content is still displayed for transparency, but execution proceeds immediately.

**`--dangerously-skip-permissions` mode**: AskUserQuestion is replaced with text messages. Checkpoints are NOT auto-skipped — only `--auto` does that.

For full protocol details (Checkpoint procedure, Review procedure, Update rules), read `commands/pipeline.md`.

---

## Command Reference

After parsing the command, read the corresponding file for the detailed workflow:

| Command | Reference File | Description |
|---------|---------------|-------------|
| `init` | `commands/init.md` | Greenfield project setup |
| `add` | `commands/add.md` | Add Features to existing project |
| `adopt` | `commands/adopt.md` | SDD adoption pipeline — wrap existing code with SDD docs |
| `pipeline` | `commands/pipeline.md` | Full SDD pipeline execution |
| `constitution`, `specify`, `plan`, `tasks`, `analyze`, `implement`, `verify` | `commands/pipeline.md` | Step mode — execute a specific pipeline step |
| `restructure` | `commands/restructure.md` | Modify Feature structure |
| `expand` | `commands/expand.md` | Activate deferred Tiers (core scope) |
| `parity` | `commands/parity.md` | Check parity against original source |
| `status` | *(inline below)* | Check progress |

For all commands: also read `domains/{domain}.md` for domain-specific behavior.
For pipeline/step commands: also read `reference/injection/{command}.md` for per-command injection details (shared patterns in `reference/context-injection-rules.md`).
For git branch operations: see `reference/branch-management.md`.

---

## Status Command

Running `/smart-sdd status` reads `sdd-state.md` and displays the overall progress.

Follows the schema defined in [state-schema.md](reference/state-schema.md).

Output format varies by scope:

**Full scope** (no Tier concept):
```
📊 Smart-SDD Progress Status

Origin: [greenfield | rebuild | adoption]
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

Origin: [greenfield | rebuild | adoption]
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

## Shared Rules

### `--auto` Mode

When `--auto` is specified:
- BOTH Checkpoint (Step 2) and Review (Step 3b-c) are skipped — content is still displayed for transparency, but execution proceeds immediately without waiting for user approval
- This is the ONLY way to bypass HARD STOPs
- Clarify scan still runs; if ambiguities found, `speckit-clarify` uses its own recommendation as default
- For `init`: Phase 2 and Phase 3 Checkpoints are skipped; if `--prd` is provided, reasonable defaults are used throughout
- For `parity`: Phase 4 HARD STOPs are skipped; groups are auto-assigned per suggested grouping (conservative: no auto-exclusions)
- For `expand`: Tier selection is skipped if argument was provided
- Error handling AskUserQuestion calls are NOT skipped (errors always need user attention)

### `--dangerously-skip-permissions` Mode

When `--dangerously-skip-permissions` is active:
- AskUserQuestion is replaced with regular text messages ("Approve as-is / Request modifications?") and WAIT for text response
- Checkpoints are NOT auto-skipped — only `--auto` does that
- For `init`: Branch question is skipped (stay on current branch). `--prd` argument is recommended to minimize interaction
- Interactive Q&A still requires user input (but via text, not AskUserQuestion)
- All other functionality is identical

### Non-Git Projects

If the project directory is not a git repository:
- Skip all branch management (pre-flight, validation, merge)
- Display a one-time notice: "No git repository detected. Branch management is disabled."
- All other smart-sdd functionality works normally

---

## History File Header

When creating `specs/history.md` for the first time, use this header:

```markdown
# Decision History

> Auto-generated during `/reverse-spec` and `/smart-sdd` execution.
> Records key strategic and architectural decisions with rationale.
```

**Recording rules**:
1. Create the file with the header above if it doesn't exist
2. APPEND only — never overwrite or reorder existing entries
3. Each session adds a dated section: `## [YYYY-MM-DD] /command-name — Context`
4. Record decisions in table format with Choice + Rationale/Details columns
5. If the user explained their reasoning, record it. If not, write "—"
6. Keep entries concise — one row per decision, no paragraphs

---

## References

- Shared injection patterns: [context-injection-rules.md](reference/context-injection-rules.md)
- Per-command injection details: [injection/{command}.md](reference/injection/) (constitution, specify, plan, tasks, analyze, implement, verify, parity, adopt-specify, adopt-plan, adopt-verify)
- State file schema: [state-schema.md](reference/state-schema.md)
- Git branch management: [branch-management.md](reference/branch-management.md)
