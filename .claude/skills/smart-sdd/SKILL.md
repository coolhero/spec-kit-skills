---
name: smart-sdd
description: Orchestrates the spec-kit SDD workflow for greenfield and brownfield projects. Supports new project setup, adding Features to existing projects, SDD adoption of existing code, and full rebuild via reverse-spec.
argument-hint: "<command> [feature-id] [--from path|step] [--prd path] [--gap] [--source path] [--start step] [--all] [--delete] [--domain app]  # commands: init|add|adopt|pipeline|constitution|coverage|expand|parity|reset|status"
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
>
> **Rule 3: spec-kit Output Suppression + Review Gate**
> After ANY spec-kit command completes (`speckit-constitution`, `speckit-specify`, `speckit-plan`, `speckit-tasks`, `speckit-analyze`, `speckit-implement`):
> 1. **SUPPRESS** spec-kit's raw output. Never show "Suggested commit", "Ready for /speckit.*", "Constitution finalized", "Done", or any navigation messages to the user.
> 2. **READ** the generated artifact file(s) per `reference/injection/{command}.md`.
> 3. **DISPLAY** the Review format per `reference/injection/{command}.md`.
> 4. **CALL AskUserQuestion** for ReviewApproval (HARD STOP). Do NOT proceed until the user approves.
> 5. **If context limit prevents steps 2-4**: Show `✅ [command] executed. 💡 Type "continue" to review the results.`
>
> Two common violations:
> - ❌ **Pattern A (Stop)**: Show raw output and stop — user sees spec-kit output but no Review, no way forward
> - ❌ **Pattern B (Skip)**: Show raw output and jump to next step — user loses Review approval, HARD STOP bypassed
> Both are wrong. Steps 1-4 are mandatory. The Review HARD STOP cannot be skipped even to maintain "continuity".

**Prerequisites**: [Playwright](https://playwright.dev) must be installed for runtime verification (`implement`) and UI testing (`verify`).

```bash
# Primary (CLI — recommended)
npm install -D @playwright/test
npx playwright install

# Optional (MCP accelerator — interactive sessions)
claude mcp add --scope user playwright -- npx @playwright/mcp@latest
```

**Electron**: CLI mode uses `_electron.launch()` (no CDP needed). MCP mode still requires CDP pre-configuration — see [PLAYWRIGHT-GUIDE.md](../../../PLAYWRIGHT-GUIDE.md) for full setup.

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

# Pipeline — Run the SDD pipeline (one Feature at a time by default)
/smart-sdd pipeline                      # Next single Feature (auto-select)
/smart-sdd pipeline F003                 # Target F003 specifically
/smart-sdd pipeline --start verify       # Next Feature, re-run from verify
/smart-sdd pipeline F003 --start verify  # F003, re-run from verify
/smart-sdd pipeline --all                # All eligible Features (batch mode)
/smart-sdd pipeline --all --start impl   # Batch, from implement step
/smart-sdd pipeline --from ./path        # Read artifacts from specified path

# Constitution (standalone)
/smart-sdd constitution                  # Finalize constitution (one-time)

# Scope expansion (core scope only — brownfield rebuild with scope=core)
/smart-sdd expand                        # Interactive: select which Tiers to activate
/smart-sdd expand T2                     # Activate Tier 2 Features
/smart-sdd expand T2,T3                  # Activate Tier 2 and Tier 3 Features
/smart-sdd expand full                   # Activate all remaining deferred Features

# Reset (per-Feature or full pipeline)
/smart-sdd reset F007                    # Reset F007 progress → re-run from specify
/smart-sdd reset F007 --from plan        # Reset F007 from plan step (keep specify results)
/smart-sdd reset F007 F008               # Reset multiple Features
/smart-sdd reset                         # Full pipeline reset, keep reverse-spec artifacts + logs
/smart-sdd reset --all                   # Full pipeline reset + reinitialize case-study-log + clean history.md
/smart-sdd reset --delete F007           # Permanently remove Feature (delete all traces)

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
  First token  → command (init | add | adopt | expand | pipeline | constitution | coverage | status | parity | reset)
  Second token → feature-id (format: F001, optional for pipeline/reset — targets specific Feature)
  --from <path|step> → artifacts path (for pipeline/init/adopt, defaults to ./specs/reverse-spec/) OR reset step name (for reset command: specify/plan/tasks/implement/verify)
  --delete        → Permanent Feature deletion (only for reset command: reset --delete F007)
  --prd <path>    → Path to PRD document (for init and add commands)
  --gap           → Start add in gap-driven mode (analyze unmapped SBI + parity gaps)
  --source <path> → Original source path for parity check (only for parity command)
  --start <step>  → Start pipeline from a specific step (only for pipeline command). Valid: specify, plan, tasks, analyze, implement, verify
  --all           → For pipeline: process all eligible Features in batch mode. For reset (no FID): include logs in reset. Not valid with other commands.
  --domain <val>  → Project domain profile: "app" (default). Backward-compatible alias for --profile
  --profile <val> → Domain profile name (e.g., "fullstack-web", "desktop-app", "cli-tool"). Overrides --domain
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

**Additional rules**: `add` requires roadmap + registries + sdd-state.md. `status` without sdd-state.md → "No project initialized yet". BASE_PATH is relative to CWD.

---

## Domain Profile

The `--profile` argument (or `--domain` for backward compatibility) selects the domain profile. Default: `app` (expands to `fullstack-web` profile).

**Loading**: After argument parsing, read `domains/_resolver.md` for the module resolution protocol. The resolver loads modules based on the Domain Profile stored in `sdd-state.md`:

1. `domains/_core.md` — Universal rules (always loaded)
2. `domains/interfaces/{interface}.md` — For each active interface (see `shared/domains/_taxonomy.md` for complete list)
3. `domains/concerns/{concern}.md` — For each active concern (see `shared/domains/_taxonomy.md` for complete list)
4. `domains/scenarios/{scenario}.md` — One scenario (greenfield, rebuild, incremental, adoption)
5. User customization file (if specified in sdd-state.md `**Custom**` field)

Loaded modules provide: **SC Generation Rules** (S1), **Parity Dimensions** (S2), **Verify Steps** (S3), **Elaboration Probes** (S5), **UI Testing** (S6), **Bug Prevention Rules** (S7).

For reverse-spec domain modules (analysis axes, detection signals), see `../reverse-spec/domains/_core.md` and `../reverse-spec/domains/_schema.md`.

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
| `pipeline` | `commands/pipeline.md` | SDD pipeline — one Feature at a time (default) or batch (`--all`) |
| `pipeline [FID]` | `commands/pipeline.md` | Target a specific Feature |
| `pipeline --start [step]` | `commands/pipeline.md` | Re-run from a specific step (force re-execute even if ✅) |
| `constitution` | `commands/pipeline.md` | Finalize constitution (standalone, one-time) |
| `verify` (with pipeline) | `commands/pipeline.md` + `commands/verify-phases.md` | Verify with Phase 1-4 details |
| `expand` | `commands/expand.md` | Activate deferred Tiers (core scope) |
| `coverage` | `commands/coverage.md` | SBI coverage check and gap resolution |
| `parity` | `commands/parity.md` | Check parity against original source |
| `reset [FID] [--from step]` | `commands/reset.md` | Reset Feature progress for re-execution |
| `reset` | `commands/reset.md` | Full pipeline reset (keep reverse-spec artifacts) |
| `reset --delete [FID...]` | `commands/reset.md` | Permanently delete Feature(s) from project |
| `status` | `commands/status.md` | Check progress |

For all commands: load domain modules per `sdd-state.md` Domain Profile (see `domains/_resolver.md`).
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
