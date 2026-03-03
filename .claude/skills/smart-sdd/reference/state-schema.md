# SDD State Schema

This document defines the format of the `sdd-state.md` file. smart-sdd automatically creates and manages this file.

**File location**: `./specs/reverse-spec/sdd-state.md` relative to CWD (or under the BASE_PATH specified with `--from`)

---

## File Structure

```markdown
# SDD State

**Project**: [Project name]
**Origin**: [greenfield | reverse-spec]
**Source Path**: [Absolute path to original source code | "N/A" for greenfield | "." for incremental (add)]
**Scope**: [core | full]
**Active Tiers**: [T1 | T1,T2 | T1,T2,T3] ← core scope only; omit this line for full scope
**Created**: [Initial creation date/time]
**Last Updated**: [Last updated date/time]
**Constitution Version**: [Version]

---

## Constitution

| Item | Value |
|------|-------|
| Status | [pending / completed] |
| Version | [MAJOR.MINOR.PATCH] |
| Completed At | [ISO 8601 date/time] |
| Updates | [Number of incremental updates] |

---

## Feature Progress

**Full scope** (no Tier column):

| Feature ID | Feature Name | specify | plan | tasks | analyze | implement | verify | merge | Status |
|------------|-------------|---------|------|-------|---------|-----------|--------|-------|--------|
| F001 | auth | ✅ 01-15 | ✅ 01-16 | ✅ 01-16 | ✅ 01-16 | ✅ 01-17 | ✅ 01-17 | ✅ 01-17 | completed |
| F002 | product | ✅ 01-18 | 🔄 | | | | | | in_progress |
| F003 | order | | | | | | | | pending |

**Core scope** (with Tier column):

| Feature ID | Feature Name | Tier | specify | plan | tasks | analyze | implement | verify | merge | Status |
|------------|-------------|------|---------|------|-------|---------|-----------|--------|-------|--------|
| F001 | auth | T1 | ✅ 01-15 | ✅ 01-16 | ✅ 01-16 | ✅ 01-16 | ✅ 01-17 | ✅ 01-17 | ✅ 01-17 | completed |
| F002 | product | T1 | ✅ 01-18 | 🔄 | | | | | | in_progress |
| F003 | order | T2 | | | | | | | | deferred |

### Step Status Icons
- ✅ : Completed (followed by completion date MM-DD)
- 🔄 : In progress
- ❌ : Failed
- ⏭️ : Skipped
- 🔒 : Deferred (outside current Active Tiers, activate via `/smart-sdd expand`)
- 🔀 : Needs re-execution (Feature restructured via `/smart-sdd restructure` — affected steps must be re-run)
- (blank) : Not started

### Feature Status Values
- `pending` : Not yet started (all steps blank)
- `in_progress` : At least one step has started
- `completed` : All steps (including merge) are ✅
- `deferred` : Outside current Active Tiers (core scope only)
- `restructured` : Feature was modified via `/smart-sdd restructure` — has 🔀 steps that need re-execution

---

## Feature Detail Log

### F001-auth

| Step | Status | Started | Completed | Notes |
|------|--------|---------|-----------|-------|
| specify | completed | 2024-01-15T10:00:00 | 2024-01-15T10:30:00 | 5 FRs, 8 SCs |
| plan | completed | 2024-01-16T09:00:00 | 2024-01-16T11:00:00 | 3 entities, 5 APIs |
| tasks | completed | 2024-01-16T11:30:00 | 2024-01-16T12:00:00 | 12 tasks |
| analyze | completed | 2024-01-16T12:30:00 | 2024-01-16T12:45:00 | No CRITICAL issues |
| implement | completed | 2024-01-17T09:00:00 | 2024-01-17T16:00:00 | |
| verify | completed | 2024-01-17T16:30:00 | 2024-01-17T17:00:00 | Tests 24/24 passed |
| merge | completed | 2024-01-17T17:05:00 | 2024-01-17T17:06:00 | Branch 001-auth → main |

### F002-product

| Step | Status | Started | Completed | Notes |
|------|--------|---------|-----------|-------|
| specify | completed | 2024-01-18T09:00:00 | 2024-01-18T10:00:00 | 8 FRs, 12 SCs |
| plan | in_progress | 2024-01-18T10:30:00 | | |

---

## Feature Mapping

Mapping table between Feature ID, spec-kit Feature Name (directory name), and git branch. The `short-name` portion MUST be identical across smart-sdd Feature ID and spec-kit Name (e.g., `F001-auth` ↔ `001-auth`).

| Feature ID | spec-kit Name | spec-kit Path | Branch | Merged |
|------------|---------------|---------------|--------|--------|
| F001 | 001-auth | specs/001-auth/ | 001-auth | ✅ |
| F002 | 002-product | specs/002-product/ | 002-product | |

---

## Global Evolution Log

Update history of Global Evolution Layer files.

| Date/Time | Trigger Feature | Target File | Change Description |
|-----------|----------------|-------------|-------------------|
| 2024-01-16 | F001-auth (plan) | entity-registry.md | Finalized User, Session entities applied |
| 2024-01-16 | F001-auth (plan) | api-registry.md | Finalized POST /auth/register, POST /auth/login applied |
| 2024-01-17 | F001-auth (implement) | roadmap.md | F001 status → completed |
| 2024-01-17 | F001-auth (implement) | F002 pre-context.md | User entity reference schema updated |

---

## Restructure Log

Feature restructuring history. Recorded when `/smart-sdd restructure` is executed.

| Date/Time | Operation | Details | Affected Features |
|-----------|-----------|---------|-------------------|
| 2024-01-20T14:00:00 | merge | F004-cart + F005-wishlist → F004-shopping | F004 (restructured), F005 (removed), F006 (dependency updated) |
| 2024-01-22T10:00:00 | split | F003-product → F003-product-catalog + F008-product-search | F003 (restructured), F008 (created), F006 (dependency updated) |

---

## Parity Check Log

Parity check execution history. Recorded when `/smart-sdd parity` is executed. Only applicable to brownfield rebuild projects (Origin: `reverse-spec`).

| Date/Time | Source Path | Structural Parity | Logic Parity | Gaps Found | New Features | Exclusions | Deferred | Status |
|-----------|------------|-------------------|-------------|------------|-------------|------------|----------|--------|
| 2024-02-01T10:00:00 | /Users/dev/old-project | 95.6% | 90.5% | 8 | 2 | 3 | 1 | completed |

---

## Constitution Update Log

Constitution incremental update history.

| Version | Date/Time | Trigger | Change Description |
|---------|-----------|---------|-------------------|
| 1.0.0 | 2024-01-15 | Initial finalization | Finalized based on constitution-seed |
| 1.1.0 | 2024-01-17 | F001-auth implement | Added authentication middleware pattern principle |
```

---

## Initial State Generation

When smart-sdd runs for the first time (when sdd-state.md does not exist), the initial state is generated using the following procedure:

1. Read `BASE_PATH/roadmap.md` to extract the Feature list and Tiers
2. Initialize all steps of all Features to `pending` (blank)
3. Leave the Feature Mapping table empty; map the spec-kit Name and Branch when each Feature's specify step is completed (spec-kit creates the branch during specify)
4. Initialize Constitution to `pending`
5. Set Origin based on how artifacts were generated:
   - `greenfield` — if initialized by `/smart-sdd init`
   - `reverse-spec` — if initialized from `/reverse-spec` artifacts
   - Origin does not change when Features are added later via `/smart-sdd add`
6. Set Source Path based on the project mode:
   - `greenfield` → `N/A` (no existing source code)
   - `reverse-spec` → Extract from the `**Source**:` field in `BASE_PATH/roadmap.md` (the original target-directory path used during `/reverse-spec`)
   - `add` (incremental) → `.` (source is the current working directory)
7. Set Scope:
   - `reverse-spec` → Read from `**Strategy**: Scope: [core|full]` in `BASE_PATH/roadmap.md`
   - `greenfield` (init) → Always `full`
   - If roadmap.md has no Scope info (legacy projects) → Default to `full`
8. Set Active Tiers based on Scope:
   - `core` → `T1` (only Tier 1 Features are initially active)
   - `full` → omit the `Active Tiers` field entirely (all Features are active, no Tier concept)
9. Set initial Feature Status:
   - `core` → Features whose Tier is in Active Tiers → `pending` (blank), others → `deferred`
   - `full` → all Features → `pending` (no deferred Features, no Tier column in progress table)

---

## State Update Rules

### When a Step Starts
- Change the corresponding cell to 🔄
- Record the start time in the Feature Detail Log
- Change the Feature Progress Status to `in_progress`

### When a Step Completes
- Change the corresponding cell to ✅ MM-DD
- Record the completion time and notes in the Feature Detail Log
- Update `Last Updated`

### When a Step Fails
- Change the corresponding cell to ❌
- Record the failure reason in the Feature Detail Log
- Feature Progress Status remains `in_progress` (retry is possible)

### When a Feature Completes (all steps including merge ✅)
- Change the Feature Progress Status to `completed`
- Mark the Feature as `✅` in the Merged column of the Feature Mapping table
- Add update history to the Global Evolution Log

### When a Step is Skipped (e.g., analyze has no CRITICAL issues)
- Change the corresponding cell to ⏭️
- Record the skip reason in the Feature Detail Log

> **Note on `clarify`**: `clarify` is a conditional sub-step of `specify` — it runs only when ambiguity markers are found in the spec. It is NOT tracked as a separate column in the Feature Progress table. If clarify was executed, note it in the Feature Detail Log under the `specify` row (e.g., "5 FRs, 8 SCs (clarify executed)").

### When Scope is Expanded (via /smart-sdd expand — core scope only)
- Update the `Active Tiers` field to the new value (e.g., `T1` → `T1,T2`)
- Change `deferred` Features whose Tier matches the newly activated Tiers to `pending`
- Record the expansion in Global Evolution Log: "Scope expanded: T1 → T1,T2"
- Note: This rule only applies to `core` scope projects. `full` scope has no deferred Features.

### When Parity Check is Executed (via /smart-sdd parity)
- Add a new entry to the Parity Check Log with:
  - Date/time of execution
  - Source path used (resolved from `--source` argument or sdd-state.md)
  - Structural and logic parity percentages
  - Number of gaps found, new Features created, intentional exclusions, and deferred items
  - Status: `completed` or `in_progress`
- If new Features were created via the `add` workflow:
  - Add new Feature rows to Feature Progress table with all steps blank (`pending`)
  - Record "Feature F00N-name added via parity check" in Global Evolution Log
- If existing Features were flagged for re-execution:
  - Mark affected steps with 🔀 from specify onward in Feature Progress table
  - Change Feature Status to `restructured`
  - Record in Restructure Log: "parity-driven re-specification for F00N-name"
- Update `Last Updated`

### When a Feature is Restructured (via /smart-sdd restructure)
- Change affected step cells to 🔀 (all steps from the first affected step onward)
- Change Feature Progress Status to `restructured`
- Record the restructure operation in the Restructure Log
- If the Feature is **deleted**: remove the row from Feature Progress table entirely
- If a **new Feature** is created (e.g., split): add a new row with all steps blank (`pending`)
- If a Feature is **merged** into another: remove the absorbed Feature's row; update the surviving Feature's row
- Update `Last Updated`

### When a Restructured Feature Resumes
- When a 🔀 step starts execution, follow normal "When a Step Starts" rules (🔀 → 🔄)
- The 🔀 is replaced by 🔄, then ✅ upon completion
- When all 🔀 steps are re-executed successfully, change Status from `restructured` to `in_progress` or `completed` as appropriate

---

## Verification Result Recording

When the verify step is completed, record the following information in the Notes column of the Feature Detail Log:

```
Tests: [passed count]/[total count] passed
Build: [success/failure]
Lint: [success/failure/not configured]
Cross-Feature: [verification point count] checked, [issue count] issues
```
