# Adopt — SDD Adoption Pipeline

> Reference: Read after `/smart-sdd adopt` is invoked.
> For shared rules (MANDATORY RULES, Common Protocol), see SKILL.md.
> For per-step injection details, read `reference/injection/adopt-{specify,plan,verify}.md`.
> For git branch operations, also read `reference/branch-management.md`.

## Purpose

The `adopt` command wraps **existing, working code** with SDD documentation. Unlike the standard `pipeline` (which builds new code), `adopt` extracts what already exists and documents it in the SDD format.

**Key differences from `pipeline`**:
- No `tasks` or `implement` steps — the code already exists
- `specify` extracts behavior from existing code (not defines new)
- `plan` documents existing architecture as-is (not designs new)
- `verify` treats test failures as pre-existing issues (non-blocking)
- Feature status → `adopted` (not `completed`)

---

## Pipeline Overview

```
Environment Bootstrap   → Install deps, env check, smoke test (skippable)
  ↓
Phase 0: Constitution Finalization (same flow, adoption-specific framing)
  ↓
Phase 1~N: Feature-by-Feature Adoption (Release Group order)
  Each Feature:
    0. Pre-flight        → main branch check
    1. Specify (adopt)   → Extract existing behavior as FR/SC
    2. Plan (adopt)      → Document existing architecture
    3. Analyze           → Cross-artifact consistency (spec.md + plan.md only)
    4. Verify (adopt)    → Non-blocking verification + SBI coverage
    5. Merge             → Checkpoint + Feature branch merge
  ↓
Post-Pipeline: Coverage Verification (BLOCKING) → Resolve gaps to 100% P1+P2
  ↓
Post-Pipeline: Final Demo (HARD STOP) → project-level demo script
  ↓
Post-Pipeline Summary
```

---

## Pipeline Initialization

### Step 1 — State file initialization

If `BASE_PATH/sdd-state.md` does not exist, create it:
1. Read `BASE_PATH/roadmap.md` to extract the Feature list
2. Generate `sdd-state.md` following the [state-schema.md](../reference/state-schema.md) format
3. **Set Origin: `adoption`**
4. Set Source Path: `.` (CWD — the existing code is in the current directory)
5. Set Scope: `full` (adoption always processes all Features)

If `sdd-state.md` already exists, verify Origin is `adoption`. If Origin is different, warn the user:
```
⚠️ sdd-state.md exists with Origin: [current]. The adopt command expects Origin: adoption.
Continue with current origin, or update to adoption?
```

### Step 2 — Source Path verification

Source Path for adoption is always `.` (CWD). Verify the current directory contains source code:
- Check for common project markers: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `src/`, `app/`
- If no markers found, warn and ask for confirmation

### Step 3 — Scope display

Display adoption scope information:
```
📋 Adopt Pipeline
Origin: adoption
Source: [CWD path]
Features: [N] total (from roadmap.md)
Processing order: Release Group sequence

ℹ️ Adoption mode:
  - Specify: Extracts existing behavior (no new requirements)
  - Plan: Documents architecture as-is (no redesign)
  - Tasks/Implement: SKIPPED (code already exists)
  - Verify: Test failures = pre-existing issues (non-blocking)
  - Status: adopted (distinct from completed)
```

---

## Environment Bootstrap (Skippable)

Before documenting the codebase, verify that the existing project actually builds, runs, and passes tests. This establishes a **baseline** that the verify step later uses to distinguish pre-existing issues from adoption-introduced problems.

### HARD STOP — Skip Check

```
📋 Environment Bootstrap

Before starting adoption, we should verify the existing project works:
  1. Install dependencies
  2. Check environment configuration (.env, etc.)
  3. Build → verify compilation
  4. Test → establish pass/fail baseline
  5. Run → verify the application starts and responds

This establishes a baseline to distinguish pre-existing issues from adoption-introduced problems.
```

Use AskUserQuestion:
- **"Run bootstrap"** — Proceed with the full environment bootstrap below
- **"Skip — environment is ready"** — Skip to Phase 0. Record in sdd-state.md: `Environment Bootstrap: skipped (user confirmed ready)`

**If response is empty → re-ask** (per MANDATORY RULE 1).

### Step 1 — Dependency Installation

Detect the project's package manager and install dependencies:

| Marker | Command |
|--------|---------|
| `package-lock.json` | `npm ci` |
| `yarn.lock` | `yarn install --frozen-lockfile` |
| `pnpm-lock.yaml` | `pnpm install --frozen-lockfile` |
| `requirements.txt` / `pyproject.toml` | `pip install -r requirements.txt` / `pip install .` |
| `go.mod` | `go mod download` |
| `Cargo.toml` | `cargo fetch` |
| `pom.xml` | `mvn dependency:resolve` |

If the install command fails, display the error and ask the user to resolve it before continuing.

### Step 2 — Environment Configuration

1. Check if `.env.example` (or equivalent: `.env.sample`, `.env.template`) exists
2. If it does, check if `.env` (or equivalent runtime config) exists
3. **If `.env` is missing**: Display HARD STOP:
   ```
   ⚠️ Environment configuration required.

   Found: .env.example ([N] variables defined)
   Missing: .env (runtime values)

   Please create .env with the required values, then confirm to continue.
   ```
   Use AskUserQuestion with options: "I've created .env — continue", "Skip environment setup". **If response is empty → re-ask** (per MANDATORY RULE 1). Do NOT proceed without explicit user confirmation that .env is created.
4. **If `.env` exists**: Continue silently

### Step 3 — Smoke Test (Build + Test + Run Baseline)

Run the project's existing build, test, and run commands to establish a baseline:

**Build baseline**:
- Detect build command: `npm run build`, `go build ./...`, `cargo build`, `mvn compile`, etc.
- Run build and record result: success/failure
- If no build command is found, record: `No build command detected`

**Test baseline**:
- Detect test command: `npm test`, `pytest`, `go test ./...`, `cargo test`, `mvn test`, etc.
- Run tests and record results:
  - Total tests, passed, failed, skipped
- If no test command is found, record: `No test command detected`

**Run baseline**:
- Detect run/start command: `npm run dev`, `npm start`, `python manage.py runserver`, `go run .`, `docker compose up`, etc.
- Start the application in background, wait for it to be ready (up to 30 seconds)
- Verify the application responds:
  - HTTP server → health check request (e.g., `curl http://localhost:[port]`)
  - CLI tool → run with `--help` or `--version`
  - Library → skip run check (no standalone execution)
- Stop the application after verification
- If no run command is found or the project is a library/package, record: `No run command detected (library/package)` and skip

### Step 4 — Record Baseline

Record results in `sdd-state.md` under a new `Environment Bootstrap` section:

```
### Environment Bootstrap

| Item | Status | Details |
|------|--------|---------|
| Dependencies | ✅ installed | [package manager] |
| Environment  | ✅ configured | .env ([N] vars) |
| Build        | ✅ success | [build command] |
| Tests        | ⚠️ [M]/[N] passed | [M] passed, [F] failed, [S] skipped |
| Run          | ✅ responds | [run command] → http://localhost:[port] |
```

Display summary:
```
✅ Environment Bootstrap Complete

  Dependencies: installed ([package manager])
  Environment:  configured
  Build:        [success/failure]
  Tests:        [M]/[N] passed ([F] failures = pre-existing)
  Run:          [responds/failed/skipped] ([run command])

  ℹ️ [F] test failures and build/run issues are recorded as pre-existing.
     These will be non-blocking during per-Feature verify.
```

> The test/build baseline recorded here is used by the verify step (Step 4) to classify failures as "pre-existing" vs "newly introduced during adoption."

---

## Phase 0: Constitution Finalization

Follows the standard pipeline Phase 0 flow (see [pipeline.md](pipeline.md) § Phase 0) with **adoption-specific framing**.

**Skip check**: If `.specify/memory/constitution.md` already exists and is finalized, skip Phase 0.

**Adoption-specific constitution framing**:

The constitution-seed generated by `/reverse-spec --adopt` contains principles **extracted from the existing source code**. In adoption mode, the constitution documents "how the code IS built" — not "how we WILL build":

- **Greenfield/Rebuild**: Constitution defines new standards and principles to follow
- **Adoption**: Constitution documents the existing codebase's philosophy and conventions

When assembling context (Phase 0-1), prepend the adoption preamble from `reference/injection/constitution.md` to the constitution-seed content.

**Both HARD STOPs (Checkpoint + Review) MUST fire** — the user should validate that the extracted principles accurately reflect their understanding of the codebase. Do NOT skip these stops in adoption mode.

---

## Phase 1~N: Feature-by-Feature Adoption

Process Features in **Release Group order** (from roadmap.md). Within each Release Group, process Features in the order listed.

### Per-Feature Flow

For each Feature in the Release Group:

#### Step 0 — Pre-flight Check

1. Verify current branch is `main` (or `master`). If not, warn and ask:
   ```
   ⚠️ Current branch is [branch], not main.
   Switch to main before starting Feature adoption?
   ```
2. Check `sdd-state.md` for this Feature's current status:
   - `pending` → proceed
   - `in_progress` → resume from the last incomplete step
   - `adopted` → skip (already adopted)
   - `completed` → skip (already completed via standard pipeline)
   - `restructured` → warn user and ask whether to re-adopt (restructured Features have 🔀 steps that need re-execution; see `reference/state-schema.md` § Restructure)

#### Step 1 — Specify (Adoption Mode)

Execute the **full Common Protocol** with adoption-specific injection:

```
adopt-specify → Assemble → Checkpoint(STOP) → speckit-specify + Review(STOP) → Update
```

**Injection rules**: Read `reference/injection/adopt-specify.md`

Key behaviors:
- Reads actual source files to extract behavior
- Each P1/P2 SBI entry must map to at least one FR-### with `[source: B###]` tag
- Does NOT add requirements for unimplemented features or TODOs
- Records SBI → FR mapping in `sdd-state.md` Source Behavior Coverage

**Branch**: Create Feature branch `{NNN}-{short-name}` from main before executing speckit-specify.

#### Step 2 — Plan (Adoption Mode)

Execute the **full Common Protocol** with adoption-specific injection:

```
adopt-plan → Assemble → Checkpoint(STOP) → speckit-plan + Review(STOP) → Update
```

**Injection rules**: Read `reference/injection/adopt-plan.md`

Key behaviors:
- Documents existing data models, API contracts, and component structure as-is
- Records inferred design rationale ("why was it built this way?")
- Does NOT suggest improvements or alternative approaches
- Updates entity-registry.md and api-registry.md with documented schemas

#### Step 3 — Analyze

Execute the analyze step with a key difference: **`tasks.md` does not exist** in adoption mode (tasks are skipped). Analyze operates on `spec.md` + `plan.md` only.

```
analyze → Assemble → Checkpoint(STOP) → speckit-analyze + Review(STOP) → Update
```

**Injection rules**: Read `reference/injection/analyze.md` (standard). Per `context-injection-rules.md` Missing/Sparse Content Handling rules, `tasks.md` absence is expected — analyze gracefully degrades to two-artifact mode.

**CRITICAL analyze issues**: If analyze produces CRITICAL-severity findings, they are **informational in adoption mode** (not blocking). Record them as pre-existing architectural issues in `sdd-state.md`. The code already exists and works — CRITICAL issues become technical debt items, not blockers.

#### ⏭️ Steps Skipped — Tasks + Implement

**Tasks and Implement are SKIPPED in adoption mode.** The code already exists — there is nothing to build.

Record in `sdd-state.md`:
- `tasks` step: `⏭️` with note "Skipped — adoption mode (code exists)"
- `implement` step: `⏭️` with note "Skipped — adoption mode (code exists)"

#### Step 4 — Verify (Adoption Mode)

Execute the **full Common Protocol** with adoption-specific injection:

```
adopt-verify → Assemble → Checkpoint(STOP) → verify execution + Review(STOP) → Update
```

**Injection rules**: Read `reference/injection/adopt-verify.md`

Key behaviors:
- **Phase 1 (Execution Verification)**: Test/build failures are **non-blocking** — recorded as "pre-existing issues"
- **Phase 2 (Cross-Feature Consistency)**: Same as standard
- **Phase 3 (Demo-Ready)**: **SKIP in adoption mode** — per-Feature demo scripts are not created during adoption. The final project demo is created in the Post-Pipeline Demo step instead.
- **Phase 4 (Global Evolution)**: Same as standard
- **SBI Coverage**: Check B### → FR-### mapping completeness
- **Overall status**: `adopted` (not `completed`)

#### Step 5 — Merge (Checkpoint)

**Same as standard pipeline merge**, but with adoption-specific status:

1. **Merge gate**: Verify is considered "passed" regardless of Phase 1 test/build results in adoption mode. The gate checks:
   - Phase 2 (Cross-Feature): must pass
   - Phase 4 (Global Evolution): must pass
   - Phase 1 and Phase 3: non-blocking in adoption mode

2. **HARD STOP**: Present merge checkpoint:
   ```
   📋 Ready to merge: [FID] - [Feature Name]

   Status: adopted
   Pre-existing issues: [N] test failures, [M] build issues
   SBI coverage: P1 [%], P2 [%]

   Merge Feature branch [branch-name] to main?
   ```
   Use AskUserQuestion with options: "Approve merge", "Review issues first". **If response is empty → re-ask** (per MANDATORY RULE 1).

3. **After merge**:
   - Feature status → `adopted`
   - Record in Global Evolution Log
   - Update Demo Group Progress
   - Check Integration Demo trigger

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M6. When composing the `### Philosophy Adherence` subsection: read the project's constitution (`.specify/memory/constitution.md`) for active archetype/F7 principles, and reference the Feature's `spec.md` and implementation decisions from `history.md` to identify which principles were applied during this Feature's pipeline. If no archetype/F7 principles are active, record "N/A".

**After recording, IMMEDIATELY proceed to the next Feature. Do NOT stop or wait for user input.**

> **Fallback**: If you cannot immediately proceed to the next Feature (e.g., context limit reached), display:
> ```
> ⏸️ Adopt pipeline paused after [FID]-[name].
> To resume: /smart-sdd adopt (or type "continue")
>
> → Next: [next-FID]-[next-name]
>   Steps: specify(adopt) → plan(adopt) → analyze → verify(adopt) → merge
> ```

---

## Post-Pipeline: Coverage Verification (BLOCKING)

Execute `/smart-sdd coverage` in **adopt pipeline mode** — gap resolution is mandatory and P1+P2 must reach 100%.

See [coverage.md](coverage.md) for the full workflow. In adopt pipeline mode:
- "View only" option is NOT offered — gaps must be resolved
- New Features created during gap resolution go through the adopt pipeline (specify → plan → analyze → verify → merge)
- Coverage verification does not complete until P1+P2 = 100%

---

## Post-Pipeline: Final Demo (HARD STOP)

After coverage verification, create a **project-level demo** based on the existing project's execution methods. This is not a per-Feature demo — it's a single demo that proves the adopted codebase runs correctly.

### Step 1 — Detect Existing Run Methods

Scan the project for existing execution methods:
- `package.json` → `scripts.start`, `scripts.dev`, `scripts.serve`
- `Makefile` → common targets (`run`, `dev`, `serve`, `start`)
- `docker-compose.yml` → service definitions
- `Procfile` → process definitions
- `manage.py` → Django management commands
- `main.go`, `cmd/` → Go entry points
- README/CONTRIBUTING → documented run instructions

### Step 2 — Present and Confirm

Display the detected run methods:
```
📋 Final Demo — Existing Run Methods:

  Detected:
    npm run dev        — Development server (from package.json)
    docker compose up  — Full stack (from docker-compose.yml)

  Recommended demo command: [most appropriate option]
```

Use AskUserQuestion:
- "Accept recommended" — Use the suggested run method
- "Use different command" — User specifies custom command
- "Skip final demo" — No demo creation (not recommended)

**If response is empty → re-ask** (per MANDATORY RULE 1).

### Step 3 — Create Demo Script

If the user doesn't skip, create `demos/project-demo.sh`:

```bash
#!/usr/bin/env bash
# Project Demo — Adopted SDD Codebase
# Launches the existing application to demonstrate adopted Features
#
# Usage:
#   ./demos/project-demo.sh         # Interactive (keeps running)
#   ./demos/project-demo.sh --ci    # Health check only
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Launching [project-name]..."
echo ""
echo "── Try it ──────────────────────────────────"
echo "  [instructions based on detected run method]"
echo "─────────────────────────────────────────────"

if [[ "${1:-}" == "--ci" ]]; then
    # CI mode: start, health check, stop
    [run command] &
    PID=$!
    sleep 5
    [health check command]
    kill $PID
    echo "✅ Health check passed"
else
    # Interactive mode
    [run command]
fi
```

Make executable: `chmod +x demos/project-demo.sh`

Display: `✅ Created: demos/project-demo.sh`

---

## Post-Pipeline Summary

📝 **Case Study Recording**: Append milestone entry to `case-study-log.md` per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M8.

After coverage verification and final demo:

```
✅ Adoption Pipeline Complete

── Summary ──────────────────────────────────────
  Features adopted: [N]/[total]
  SBI Coverage (after gap resolution):
    P1: [N]/[total] (100%) — [E] excluded
    P2: [N]/[total] (100%) — [E] excluded
    P3: [N]/[total] ([%]) — not required
  Pre-existing issues:
    Test failures: [N] across [M] Features
    Build issues: [N]
    No tests: [K] Features
  Demo Groups:
    [List group status]
  Final Demo:
    demos/project-demo.sh — [run method used]

── What's Next ──────────────────────────────────
  The existing codebase is now wrapped with SDD documentation.
  All Features have status "adopted" (not "completed").

  To resolve pre-existing issues and transition to "completed":
    /smart-sdd pipeline    — Re-run standard pipeline on adopted Features
                             (tasks + implement to fix issues, verify to confirm)

  To check SBI coverage:
    Review sdd-state.md → Source Behavior Coverage section

  To add new features:
    /smart-sdd add         — Add new Features using the 6-step process
```

---

## Resuming an Interrupted Adoption

If the adopt pipeline is interrupted mid-Feature:
1. Read `sdd-state.md` to find the Feature with status `in_progress`
2. Check which step was last completed (from Feature Detail Log)
3. Resume from the next incomplete step
4. Display: "Resuming adoption of [FID] from [step] step"

If the pipeline is interrupted between Features:
1. Find the last `adopted` Feature
2. Resume with the next `pending` Feature in Release Group order
3. Display: "Resuming adoption pipeline from [FID]"
