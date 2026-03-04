# Adopt — SDD Adoption Pipeline

> Reference: Read after `/smart-sdd adopt` is invoked.
> For shared rules (MANDATORY RULES, --auto, Common Protocol), see SKILL.md.
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
Phase 0: Constitution Finalization (same as pipeline)
  ↓
Phase 1~N: Feature-by-Feature Adoption (Release Group order)
  Each Feature:
    0. Pre-flight        → main branch check
    1. Specify (adopt)   → Extract existing behavior as FR/SC
    2. Plan (adopt)      → Document existing architecture
    3. Analyze           → Cross-artifact consistency check
    4. Verify (adopt)    → Non-blocking verification + SBI coverage
    5. Merge             → Checkpoint + Feature branch merge
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

## Phase 0: Constitution Finalization

**Same as standard pipeline Phase 0.** See [pipeline.md](pipeline.md) § Phase 0.

Skip check: If `.specify/memory/constitution.md` already exists and is finalized, skip Phase 0.

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

Execute the **standard analyze step** — same as pipeline. No adoption-specific variant needed.

```
analyze → Assemble → Checkpoint(STOP) → speckit-analyze + Review(STOP) → Update
```

**Injection rules**: Read `reference/injection/analyze.md` (standard)

Cross-artifact consistency is checked the same way regardless of adoption mode.

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
- **Phase 3 (Demo-Ready)**: If constitution is finalized and includes Demo-Ready Delivery, apply demo checks. Otherwise skip
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
   Options: "Approve merge", "Review issues first"

3. **After merge**:
   - Feature status → `adopted`
   - Record in Global Evolution Log
   - Update Demo Group Progress
   - Check Integration Demo trigger

---

## Post-Pipeline Summary

After all Features are adopted:

```
✅ Adoption Pipeline Complete

── Summary ──────────────────────────────────────
  Features adopted: [N]/[total]
  SBI Coverage:
    P1: [N]/[total] ([%])
    P2: [N]/[total] ([%])
    P3: [N]/[total] ([%])
  Pre-existing issues:
    Test failures: [N] across [M] Features
    Build issues: [N]
    No tests: [K] Features
  Demo Groups:
    [List group status]

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
