---
name: smart-sdd
description: Orchestrates the spec-kit SDD workflow for greenfield and brownfield projects. Supports new project setup, adding Features to existing projects, SDD adoption of existing code, and full rebuild via reverse-spec. Use this skill whenever the user mentions spec-kit, SDD, specification-driven development, Feature pipeline, spec generation, or wants to systematically break down a project into Features with specs, plans, and implementations. Typical flow — greenfield: init → add → pipeline. Brownfield: /reverse-spec first (or auto-chained via adopt), then pipeline. Composable with /code-explore for feature discovery before building.
argument-hint: "<command> [feature-id] [--from path|step] [--from-explore path] [--from-reverse-spec path] [--prd path] [--gap] [--source path] [--start step] [--all] [--auto] [--delete] [--domain app] [--lang <code>]  # commands: init|add|adopt|pipeline|constitution|coverage|expand|parity|reset|status"
allowed-tools: [Read, Grep, Glob, Bash, Write, Edit, Skill, AskUserQuestion]
---

# Smart-SDD: spec-kit Workflow Orchestrator

> **⚠️ Known pitfalls**: See [`lessons-learned.md`](../../../lessons-learned.md) for 19 gap patterns + 46 specific lessons from real pipeline runs. Consult when hitting unexpected agent behavior.
>
> **📋 Known limitations**: See [`reference/known-limitations.md`](reference/known-limitations.md) for documented system limitations (L1-L7) with recovery paths — mid-step crash recovery, architecture pivot, concurrent development, monorepo support, etc.

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
>
> **Rule 4: Sequential Feature Execution**
> Features MUST execute **one at a time, sequentially**. Never use Agent tool, background tasks, or any parallelism mechanism to process multiple Features simultaneously — even when the user says "do all Features" or "run them in parallel."
> - ❌ WRONG: Spawn background agents for F001 and F002 concurrently
> - ❌ WRONG: Start F002 specify while F001 is still in implement
> - ✅ RIGHT: F001 completes all steps through verify+merge → then F002 starts
>
> Parallel execution causes entity-registry conflicts, stale cross-Feature references, and untraceable sdd-state.md corruption. The ONLY parallelism allowed is **within-Feature task-level** parallelism (independent implement tasks within a single Feature).
>
> **Rule 5: Runtime SC Verification**
> `npm run build` + `npm test` passing is NOT verify completion. Verify Phase 3 REQUIRES:
> 1. Start the actual application (server, app, or service)
> 2. Execute each SC against the running application (curl, Playwright, or equivalent)
> 3. Record pass/fail evidence per SC
> - ❌ WRONG: "build passes, 12 unit tests pass → verify complete"
> - ❌ WRONG: "skipping runtime because Docker isn't running" (start it or ask user)
> - ✅ RIGHT: "server started on port 3000 → POST /auth/login returns 200 with token → SC-001 ✅"
>
> If infrastructure (DB, Redis, etc.) is required but not running, start it (`docker compose up -d`) or ask the user. NEVER skip runtime verification because of infrastructure absence.
>
> **Rule 6: Honest SC Evidence + User Demo**
> An SC is ✅ ONLY when the COMPLETE behavior specified in the SC is verified. Partial verification = ❌ (with notes).
> - ❌ WRONG: SC says "API Key → 200 + LLM response" but only auth layer passed (LLM returned 400) → report as ✅
> - ❌ WRONG: SC says "end-to-end" but only tested middleware → report as ✅
> - ✅ RIGHT: SC partially verified → report as ⚠️ PARTIAL with exact scope: "Auth ✅, LLM call ❌ (Provider API Key not configured)"
>
> **Demo requires user participation.** Writing a demo script is NOT the demo. The user must:
> 1. See the running application
> 2. Receive the URL/commands to try
> 3. Confirm the Feature works
>
> If environment setup is needed (API keys, DB seeds, external services):
> - ASK the user to configure it (P2: Delegate, Don't Skip)
> - Do NOT silently skip or report "N/A"
> - Reference: Gotcha G9 (User App Configuration Gate)

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
- **Brownfield (rebuild)**: Full re-implementation from reverse-spec artifacts via `/smart-sdd pipeline`. Rebuild targets **UX equivalence**, not just functional equivalence — the target app must reproduce the source app's screen layouts, interaction flows, and UI patterns, implemented with the new stack's component library
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
/smart-sdd add prd.md                    # Auto-detect file → same as --prd prd.md
/smart-sdd add --prd path/to/requirements.md  # Define from a PRD/requirements document
/smart-sdd add --to F001 "add OAuth"     # Augment existing Feature with new requirements
/smart-sdd add --to F001 oauth-spec.md   # Augment from file
/smart-sdd add --from-explore specs/explore/  # Define from code-explore synthesis
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
/smart-sdd pipeline --auto               # Auto-approve CALIBRATION+ROUTINE HARD STOPs
/smart-sdd pipeline --all --auto         # Batch + auto-approve
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
/smart-sdd reset --all                   # Full pipeline reset + clean history.md
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
| Global Evolution artifacts | `./specs/_global/` | Relative to CWD. Can be changed via `--from` argument |
| spec-kit feature artifacts | `./specs/{NNN-feature}/` | Native spec-kit path. Not modified by smart-sdd |
| spec-kit constitution | `.specify/memory/constitution.md` | spec-kit native working path. Do NOT copy to `specs/` |
| State file | `./specs/_global/sdd-state.md` | Created and managed by smart-sdd |

### Global Evolution Layer Artifact Structure

```
specs/
├── history.md                          # Decision history (auto-generated, shared by both skills)
├── _global/
│   ├── roadmap.md
│   ├── constitution-seed.md
│   ├── entity-registry.md
│   ├── api-registry.md
│   ├── business-logic-map.md           # (only for rebuild mode)
│   ├── stack-migration.md              # (only for rebuild with new stack)
│   ├── coverage-baseline.md            # (rebuild mode only — generated by /reverse-spec Phase 4-3)
│   ├── parity-report.md                # (rebuild mode only — generated by /smart-sdd parity)
│   └── sdd-state.md                    # State file created and managed by smart-sdd
├── 001-auth/
│   ├── pre-context.md
│   ├── spec.md
│   ├── plan.md
│   └── tasks.md
├── 002-product/
│   ├── pre-context.md
│   └── ...
└── ...
```

---

## Argument Parsing

Parses `$ARGUMENTS` to extract command, feature-id, and options.

```
$ARGUMENTS parsing rules:
  First token  → command (init | add | adopt | expand | pipeline | constitution | coverage | status | parity | reset)
  Second token → feature-id (format: F001, optional for pipeline/reset — targets specific Feature)
  --from <path|step> → artifacts path (for pipeline/init/adopt, defaults to ./specs/_global/) OR reset step name (for reset command: specify/plan/tasks/implement/verify)
  --delete        → Permanent Feature deletion (only for reset command: reset --delete F007)
  --prd <path>    → Path to PRD document (for init and add commands)
  --from-explore <path> → Path to code-explore artifacts directory (for init/add — seeds from synthesis)
  --from-reverse-spec <path> → Path to reverse-spec artifacts directory (for init — seeds from reverse-spec analysis). See init.md § Reverse-Spec-Informed Mode
  --gap           → Start add in gap-driven mode (analyze unmapped SBI + parity gaps)
  --source <path> → Original source path for parity check (only for parity command)
  --start <step>  → Start pipeline from a specific step (only for pipeline command). Valid: specify, plan, tasks, analyze, implement, verify
  --all           → For pipeline: process all eligible Features in batch mode. For reset (no FID): include logs in reset. Not valid with other commands.
  --auto          → Auto-approve CALIBRATION and ROUTINE HARD STOPs. CRITICAL HARD STOPs still require user approval. Recommended for experienced users on subsequent pipeline runs. Auto-approved decisions are logged in sdd-state.md Feature Detail Log.
  --domain <val>  → Project domain profile: "app" (default). Backward-compatible alias for --profile
  --profile <val> → Domain profile name (e.g., "fullstack-web", "desktop-app", "cli-tool"). Overrides --domain
  --lang <code>   → Artifact language (ko, en, ja, etc.). Stored in sdd-state.md as Artifact Language.
```

### Language Persistence (--lang)

`--lang` is stored in `sdd-state.md` header: `**Artifact Language**: ko`

- **If `--lang` provided**: update sdd-state.md Artifact Language field. All subsequent artifacts use this language.
- **If `--lang` not provided**: read from sdd-state.md. If field absent, default to `en`.
- **Language applies to**: all generated artifacts (spec.md, plan.md, tasks.md, pre-context.md, spec-draft.md, roadmap.md, registries). Also applies to AskUserQuestion option labels and Checkpoint/Review display text.
- **Language does NOT apply to**: skill files themselves (always English per CLAUDE.md), technical identifiers (FR-001, SC-001, entity names), markdown headings in templates.

**BASE_PATH** determination:
- If `--from` is specified: use that path
- If not specified: `./specs/_global/`

**Pre-validation** (all commands except `init` and `reset`, which have their own Pre-Phase/Pre-Validation):

**Step 0a. Git check**: Run `git rev-parse --is-inside-work-tree`. If not a repo → `git init` + initial commit. If git not installed → warn and continue without git.

**Step 0b. spec-kit CLI check**: Run `which specify`. If not found → try installation in order:
1. `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git` (if `uv` available)
2. `pipx install specify-cli --pip-args="--extra-index-url https://github.com/github/spec-kit.git"` (if `pipx` available)
3. `pip install git+https://github.com/github/spec-kit.git` (fallback)
Verify with `which specify` again. CLI binary is `specify` (not `speckit`); skill names use hyphens (`speckit-specify`).

**Step 0c. spec-kit project init check**: Look for `.claude/commands/speckit.specify.md`. If not found → run `specify init --here --ai claude --force`. This creates `.claude/commands/speckit.*.md` files (spec-kit's slash commands). If `specify` CLI is not installed, display: "⚠️ spec-kit CLI not found. Install: `pip install speckit-cli` (or see https://github.com/github/spec-kit)". **spec-kit Fallback**: if `.claude/commands/speckit.*.md` files don't exist and `specify` CLI is not available, generate artifacts directly using `.specify/templates/` as format reference. The pipeline continues — spec-kit commands are an enhancement, not a requirement.

**Step 1. roadmap.md check** (skip for `init` and `status`): Verify `roadmap.md` exists at BASE_PATH. If not found:
- **If command is `adopt`**: Auto-run `/reverse-spec . --adopt --lang {current lang}` inline (read `reverse-spec/SKILL.md` → `commands/analyze.md` → execute Phase 0–4). The `--adopt` flag forces `--scope full --stack same` and skips Phase 0 questions (scope, stack, rename), so no user interaction is needed before analysis begins. After reverse-spec completes, continue with the adopt pipeline.
- **Otherwise**: suggest `/smart-sdd init` or `/reverse-spec`.

**Additional rules**: `add` requires roadmap + registries + sdd-state.md. `status` without sdd-state.md → "No project initialized yet". BASE_PATH is relative to CWD.

---

## Domain Profile

The `--profile` argument (or `--domain` for backward compatibility) selects the domain profile. Default: `app` (expands to `fullstack-web` profile).

**Loading**: After argument parsing, read `domains/_resolver.md` for the module resolution protocol. The resolver loads modules based on the Domain Profile stored in `sdd-state.md`:

1. `domains/_core.md` — Universal rules (always loaded)
2. `domains/interfaces/{interface}.md` — For each active interface (see `shared/domains/_taxonomy.md` for complete list)
3. `domains/concerns/{concern}.md` — For each active concern (see `shared/domains/_taxonomy.md` for complete list)
4. `domains/archetypes/{archetype}.md` — For each active archetype
5. Organization convention file (if specified in sdd-state.md `**Org Convention**` field)
6. `domains/contexts/modes/{mode}.md` — One context mode (greenfield, rebuild, incremental, adoption)
6b. `domains/contexts/modifiers/{modifier}.md` — Zero or more context modifiers (migration, compliance, etc.)
7. Project customization file (if specified in sdd-state.md `**Custom**` field)

Loaded modules provide: **SC Generation Rules** (S1), **Parity Dimensions** (S2), **Verify Steps** (S3), **Elaboration Probes** (S5), **UI Testing** (S6), **Bug Prevention Rules** (S7), **Brief Completion Criteria** (S9/A5).

For reverse-spec domain modules (analysis axes, detection signals), see `../reverse-spec/domains/_core.md` and `../reverse-spec/domains/_schema.md`.

---

## Common Protocol: Assemble → Checkpoint → Execute+Review → Update

All spec-kit command executions follow a mandatory 4-step protocol: **(1) Assemble** context per [`reference/injection/{command}.md`](reference/injection/) → **(2) Checkpoint** HARD STOP for user approval → **(3) Execute** spec-kit + **Review** artifacts (HARD STOP) → **(4) Update** global artifacts.

Full procedures (`ApprovalGate(checkpoint)`, `ApprovalGate(review)`, spec-kit Fallback) are defined in `commands/pipeline.md`.

---

## Command Reference

After parsing the command, read the corresponding file for the detailed workflow:

| Command | Reference File | Description |
|---------|---------------|-------------|
| `init` | `commands/init.md` | Greenfield project setup |
| `add` | `commands/add.md` | Feature Briefing — structured intake + completeness validation |
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

---

## Gotchas

Accumulated edge cases from real pipeline runs. Check this list when hitting unexpected behavior.

| # | Gotcha | What Goes Wrong | Fix |
|---|--------|----------------|-----|
| G1 | Running `add` when no `init` has been done | sdd-state.md doesn't exist → add fails or creates incomplete state | Run `init` first (or `adopt` for existing code) |
| G2 | Using `Skill(speckit-specify)` instead of inline execution | Skill tool's response boundary ends smart-sdd's turn → Review HARD STOP never fires → user sees raw spec-kit output and doesn't know what to do next | Always use inline execution: read the SKILL.md and execute steps directly. Never call `Skill(speckit-*)` |
| G3 | Skipping HARD STOP Review after speckit-* execution | User loses approval opportunity → pipeline proceeds with potentially wrong artifacts | Every speckit-* command must be followed by artifact read → Review → AskUserQuestion in the same response |
| G4 | `pipeline --continue` after a crash | Agent doesn't know which step crashed → may re-execute completed steps or skip the failed one | Check sdd-state.md Feature status → resume from the recorded step |
| G5 | Amending a commit after pre-commit hook failure | `--amend` modifies the PREVIOUS commit (since the failed commit never happened) → destroys earlier work | Always create a NEW commit after fixing hook issues |
| G6 | `add --to F001` without subsequent `pipeline F001` | Pre-context is augmented but spec.md is not updated → stale spec doesn't reflect new requirements. Feature status is set to `augmented` which triggers SC Preservation on next specify — existing SCs are preserved with `[preserved]` tags and new SCs added with `[new]` tags | Always run `pipeline F001` (or at minimum `pipeline F001 --step specify`) after augmenting |
| G7 | Running `pipeline` without specifying Feature ID when multiple Features exist | May pick wrong Feature or process all in unintended order | Specify explicitly: `pipeline F003` |
| G8 | Forgetting `--lang` on first command | Artifacts default to English → switching language mid-pipeline requires regeneration | Set `--lang` on `init`, `adopt`, or first `add` |
| G9 | App requires user configuration (API keys, model selection) for verify | Playwright launches app but features don't work without setup | Agent asks user to configure the app, then continues verification (Phase 0-2b) |
| G10 | `pipeline F001 --step specify` on completed Feature without checking branch | May modify code on wrong branch (main vs feature branch) | Branch management auto-handles: creates fresh branch from main for re-opened Features |
| G11 | Processing 3+ Features without context reset | Context saturates → later Features get shallow specify/verify, Review quality drops, hallucination risk increases | Reset context at Feature boundaries (`/clear` then re-invoke). All state is in files (P3). See `pipeline.md` § Context Reset Protocol |
| G12 | Generating artifacts without reading spec-kit templates | spec.md has 3 sections instead of 8, data-model.md missing, contracts/ missing → downstream steps work with incomplete data | ALWAYS read `.specify/templates/` before generating. Match every section. |
| G13 | Skipping verify when user says "do everything" or "just finish it" | Feature marked complete without SC verification → bugs ship → trust lost | verify is CRITICAL classification. User urgency does NOT override. merge gate blocks without verify. |
| G14 | Running multiple Features in parallel via Agent tool or background tasks | Entity registry conflicts, shared file overwrites, Feature B references Feature A's incomplete entities → cascading inconsistency | Features are ALWAYS sequential. F001 verify+merge → F002 start. Only within-Feature task parallelism is allowed. |
| G15 | Merge without verify-report.md | Agent completes verify in chat, skips file generation, proceeds to merge — no persistent evidence | verify-report.md is MANDATORY. Merge gate checks file existence + Overall=PASS. Chat-level "verify complete" is not evidence |

---

## Composability

smart-sdd works with the other spec-kit skills:

```
/code-explore → /smart-sdd init --from-explore         (new project from exploration)
/code-explore → /smart-sdd add --from-explore           (add Features from exploration)
/reverse-spec → /smart-sdd init --from-reverse-spec     (rebuild with review checkpoint)
/reverse-spec → /smart-sdd pipeline                     (rebuild direct — skip review)
/smart-sdd adopt → /reverse-spec (auto-chained)         (adopt triggers reverse-spec)
/smart-sdd adopt → /code-explore                         (deepen understanding after adoption)
/smart-sdd pipeline → /code-explore --no-branch          (mid-pipeline investigation)
```

Inter-skill data flow is file-based (P3: File over Memory): `sdd-state.md`, registries, and pre-context files serve as the handoff medium.
