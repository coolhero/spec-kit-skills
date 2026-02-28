# SDD State Schema

This document defines the format of the `sdd-state.md` file. smart-sdd automatically creates and manages this file.

**File location**: `specs/reverse-spec/sdd-state.md` (or under the BASE_PATH specified with `--from`)

---

## File Structure

```markdown
# SDD State

**Project**: [Project name]
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

| Feature ID | Feature Name | Tier | specify | plan | tasks | implement | verify | Status |
|------------|-------------|------|---------|------|-------|-----------|--------|--------|
| F001 | auth | T1 | ✅ 01-15 | ✅ 01-16 | ✅ 01-16 | ✅ 01-17 | ✅ 01-17 | completed |
| F002 | product | T1 | ✅ 01-18 | 🔄 | | | | in_progress |
| F003 | order | T2 | | | | | | pending |

### Status Icons
- ✅ : Completed (followed by completion date MM-DD)
- 🔄 : In progress
- ❌ : Failed
- ⏭️ : Skipped
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

### F002-product

| Step | Status | Started | Completed | Notes |
|------|--------|---------|-----------|-------|
| specify | completed | 2024-01-18T09:00:00 | 2024-01-18T10:00:00 | 8 FRs, 12 SCs |
| plan | in_progress | 2024-01-18T10:30:00 | | |

---

## Feature Mapping

Mapping table between Feature ID and spec-kit Feature Name (directory name).

| Feature ID | spec-kit Name | spec-kit Path |
|------------|---------------|---------------|
| F001 | 001-auth | specs/001-auth/ |
| F002 | 002-product | specs/002-product/ |

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
3. Leave the Feature Mapping table empty; map the spec-kit Name when each Feature's specify step is completed
4. Initialize Constitution to `pending`

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

### When a Feature Completes (all steps ✅)
- Change the Feature Progress Status to `completed`
- Add update history to the Global Evolution Log

### When a Step is Skipped (e.g., clarify not needed)
- Change the corresponding cell to ⏭️
- Record the skip reason in the Feature Detail Log

---

## Verification Result Recording

When the verify step is completed, record the following information in the Notes column of the Feature Detail Log:

```
Tests: [passed count]/[total count] passed
Build: [success/failure]
Lint: [success/failure/not configured]
Cross-Feature: [verification point count] checked, [issue count] issues
```
