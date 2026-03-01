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
**Active Tiers**: [T1 | T1,T2 | T1,T2,T3]
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

| Feature ID | Feature Name | Tier | specify | plan | tasks | implement | verify | merge | Status |
|------------|-------------|------|---------|------|-------|-----------|--------|-------|--------|
| F001 | auth | T1 | ✅ 01-15 | ✅ 01-16 | ✅ 01-16 | ✅ 01-17 | ✅ 01-17 | ✅ 01-17 | completed |
| F002 | product | T1 | ✅ 01-18 | 🔄 | | | | | in_progress |
| F003 | order | T2 | | | | | | | deferred |

### Status Icons
- ✅ : Completed (followed by completion date MM-DD)
- 🔄 : In progress
- ❌ : Failed
- ⏭️ : Skipped
- 🔒 : Deferred (outside current Active Tiers, activate via `/smart-sdd expand`)
- (blank) : Not started

---

## Feature Detail Log

### F001-auth

| Step | Status | Started | Completed | Notes |
|------|--------|---------|-----------|-------|
| specify | completed | 2024-01-15T10:00:00 | 2024-01-15T10:30:00 | 5 FRs, 8 SCs |
| plan | completed | 2024-01-16T09:00:00 | 2024-01-16T11:00:00 | 3 entities, 5 APIs |
| tasks | completed | 2024-01-16T11:30:00 | 2024-01-16T12:00:00 | 12 tasks |
| implement | completed | 2024-01-17T09:00:00 | 2024-01-17T16:00:00 | |
| verify | completed | 2024-01-17T16:30:00 | 2024-01-17T17:00:00 | Tests 24/24 passed |
| merge | completed | 2024-01-17T17:05:00 | 2024-01-17T17:06:00 | Branch 001-user-auth → main |

### F002-product

| Step | Status | Started | Completed | Notes |
|------|--------|---------|-----------|-------|
| specify | completed | 2024-01-18T09:00:00 | 2024-01-18T10:00:00 | 8 FRs, 12 SCs |
| plan | in_progress | 2024-01-18T10:30:00 | | |

---

## Feature Mapping

Mapping table between Feature ID, spec-kit Feature Name (directory name), and git branch.

| Feature ID | spec-kit Name | spec-kit Path | Branch | Merged |
|------------|---------------|---------------|--------|--------|
| F001 | 001-auth | specs/001-auth/ | 001-user-auth | ✅ |
| F002 | 002-product | specs/002-product/ | 002-product-catalog | |

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
   - `core` → `T1`
   - `full` → `T1,T2,T3`
9. Set initial Feature Status based on Active Tiers:
   - Features whose Tier is included in Active Tiers → `pending` (blank)
   - Features whose Tier is NOT in Active Tiers → `deferred`

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

### When a Step is Skipped (e.g., clarify not needed)
- Change the corresponding cell to ⏭️
- Record the skip reason in the Feature Detail Log

### When Scope is Expanded (via /smart-sdd expand)
- Update the `Active Tiers` field to the new value (e.g., `T1` → `T1,T2`)
- Change `deferred` Features whose Tier matches the newly activated Tiers to `pending`
- Record the expansion in Global Evolution Log: "Scope expanded: T1 → T1,T2"

---

## Verification Result Recording

When the verify step is completed, record the following information in the Notes column of the Feature Detail Log:

```
Tests: [passed count]/[total count] passed
Build: [success/failure]
Lint: [success/failure/not configured]
Cross-Feature: [verification point count] checked, [issue count] issues
```
