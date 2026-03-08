---
name: smart-sdd
description: Orchestrates the spec-kit SDD workflow for greenfield and brownfield projects. Supports new project setup, adding Features to existing projects, SDD adoption of existing code, and full rebuild via reverse-spec.
argument-hint: "<command> [feature-id] [--from path] [--prd path] [--gap] [--source path] [--start step] [--domain app]  # commands: init|add|adopt|pipeline|constitution|specify|plan|tasks|analyze|implement|verify|coverage|restructure|expand|parity|reset|status"
allowed-tools: [Read, Grep, Glob, Bash, Write, Edit, Skill, AskUserQuestion]
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

**Prerequisites**: [Playwright MCP](https://github.com/microsoft/playwright-mcp) must be installed and connected. Used for runtime verification (`implement`) and UI testing (`verify`). For Electron apps, CDP must be pre-configured — see [MCP-GUIDE.md](../../../MCP-GUIDE.md).

```bash
# Install (one-time)
claude mcp add --scope user playwright -- npx @playwright/mcp@latest
```

Wraps spec-kit commands with cross-Feature context injection and Global Evolution Layer management. Works with four project modes:

- **Greenfield**: New project setup via `/smart-sdd init`, then Feature definition via `/smart-sdd add`
- **Brownfield (incremental)**: Add Features to an existing smart-sdd project via `/smart-sdd add`
- **Brownfield (rebuild)**: Full re-implementation from reverse-spec artifacts via `/smart-sdd pipeline`
- **Brownfield (adoption)**: Wrap existing code with SDD documentation via `/smart-sdd adopt`

Does not replace spec-kit commands, but wraps them with a 4-step protocol: **Context Assembly → Pre-Execution Checkpoint → spec-kit Execution + Artifact Review → Global Evolution Update**.

---

## Usage

```
# Greenfield — New project setup + Feature definition
/smart-sdd init                          # Interactive project setup (constitution + artifacts)
/smart-sdd init --prd path/to/prd.md     # Setup from a PRD document
/smart-sdd add                           # Define Features (universal — used for all modes)

# Brownfield (incremental) — Add new Feature(s) to existing smart-sdd project
/smart-sdd add                           # Interactive: define and add new Feature(s)
/smart-sdd add --prd path/to/requirements.md  # Define from a PRD/requirements document
/smart-sdd add --gap                     # Gap-driven: cover unmapped SBI/parity gaps

# Adoption — Wrap existing code with SDD documentation (after reverse-spec)
/smart-sdd adopt                         # Adopt existing code with SDD docs
/smart-sdd adopt --from ./path           # Read artifacts from specified path

# Pipeline — Run the full SDD pipeline (after init, add, or reverse-spec)
/smart-sdd pipeline                      # With per-step confirmation
/smart-sdd pipeline --from ./path        # Read artifacts from specified path
/smart-sdd pipeline --start implement    # Start from implement step (all Features)
/smart-sdd pipeline --start verify       # Start from verify step (all Features)

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

# Reset pipeline state (start smart-sdd over from scratch)
/smart-sdd reset                         # Reset pipeline, keep reverse-spec artifacts + logs
/smart-sdd reset --all                   # Reset pipeline + reinitialize case-study-log + clean history.md

# Status check
/smart-sdd status                        # Check overall progress status

# Parity check (brownfield rebuild only — after pipeline completes)
/smart-sdd parity                        # Check parity against original source
/smart-sdd parity --source ./old-project # Specify source path explicitly

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
  First token  → command (init | add | adopt | restructure | expand | pipeline | constitution | specify | plan | tasks | analyze | implement | verify | coverage | status | parity | reset)
  Second token → feature-id (format: F001, required when command is specify/plan/tasks/analyze/implement/verify)
  --from <path>   → artifacts path (defaults to ./specs/reverse-spec/ if not specified)
  --prd <path>    → Path to PRD document (for init and add commands)
  --gap           → Start add in gap-driven mode (analyze unmapped SBI + parity gaps)
  --source <path> → Original source path for parity check (only for parity command)
  --start <step>  → Start pipeline from a specific step (only for pipeline command). Valid: specify, plan, tasks, analyze, implement, verify
  --domain <val>  → Project domain profile: "app" (default). Determines demo pattern, parity dimensions, and verify steps
```

**BASE_PATH** determination:
- If `--from` is specified: use that path
- If not specified: `./specs/reverse-spec/`

**Pre-validation** (all commands except `init` and `reset`, which have their own Pre-Phase/Pre-Validation):

**Step 0a. Git check**: Run `git rev-parse --is-inside-work-tree`. If not a repo → `git init` + initial commit. If git not installed → warn and continue without git.

**Step 0b. spec-kit CLI check**: Run `which specify`. If not found → try installation in order:
1. `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git` (if `uv` available)
2. `pipx install specify-cli --pip-args="--extra-index-url https://github.com/github/spec-kit.git"` (if `pipx` available)
3. `pip install git+https://github.com/github/spec-kit.git` (fallback)
Verify with `which specify` again. CLI binary is `specify` (not `speckit`); skill names use hyphens (`speckit-specify`).

**Step 0c. spec-kit project init check**: Look for `.claude/skills/speckit-specify/SKILL.md`. If not found → `specify init --here --ai claude --force --no-git --ai-skills`. If skills aren't registered in current session, use Skill Invocation Fallback (see [pipeline.md](commands/pipeline.md)).

**Step 1. roadmap.md check** (skip for `init` and `status`): Verify `roadmap.md` exists at BASE_PATH. If not found → suggest `/smart-sdd init` or `/reverse-spec`.

**Additional rules**: `add`/`restructure` require roadmap + registries + sdd-state.md. `status` without sdd-state.md → "No project initialized yet". BASE_PATH is relative to CWD.

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

All spec-kit command executions follow a mandatory 4-step protocol: **(1) Assemble** context per [`reference/injection/{command}.md`](reference/injection/) → **(2) Checkpoint** HARD STOP for user approval → **(3) Execute** spec-kit + **Review** artifacts (HARD STOP) → **(4) Update** global artifacts.

Full procedures (CheckpointApproval, ReviewApproval, Skill Invocation Fallback) are defined in `commands/pipeline.md`.

---

## Command Reference

After parsing the command, read the corresponding file for the detailed workflow:

| Command | Reference File | Description |
|---------|---------------|-------------|
| `init` | `commands/init.md` | Greenfield project setup |
| `add` | `commands/add.md` | Add Features to existing project |
| `adopt` | `commands/adopt.md` | SDD adoption pipeline — wrap existing code with SDD docs |
| `pipeline` | `commands/pipeline.md` | Full SDD pipeline execution |
| `constitution`, `specify`, `plan`, `tasks`, `analyze`, `implement` | `commands/pipeline.md` | Step mode — execute a specific pipeline step |
| `verify` | `commands/pipeline.md` + `commands/verify-phases.md` | Step mode — verify with Phase 1-4 details |
| `restructure` | `commands/restructure.md` | Modify Feature structure |
| `expand` | `commands/expand.md` | Activate deferred Tiers (core scope) |
| `coverage` | `commands/coverage.md` | SBI coverage check and gap resolution |
| `parity` | `commands/parity.md` | Check parity against original source |
| `reset` | `commands/reset.md` | Reset pipeline state (keep reverse-spec artifacts) |
| `status` | `commands/status.md` | Check progress |

For all commands: also read `domains/{domain}.md` for domain-specific behavior.
For pipeline/step commands: also read `reference/injection/{command}.md` for per-command injection details (shared patterns in `reference/context-injection-rules.md`).
For git branch operations: see `reference/branch-management.md`.

---

## Shared Rules

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

**Project Context block** (required for rebuild/adoption — written ONCE after the header):
- **Rebuild**: Include Mode, Original (name + path), Target (name + path), Stack, Identity mapping, **What it does** (user-perspective description)
- **Adoption**: Include Mode, Project (name + path), Purpose, **What it does** (user-perspective description)
- **Greenfield**: No Project Context block needed (no original source)
- See `reverse-spec/commands/analyze.md` § Decision History Recording for the full format

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
