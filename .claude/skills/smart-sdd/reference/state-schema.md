# SDD State Schema

This document defines the format of the `sdd-state.md` file. smart-sdd automatically creates and manages this file.

**File location**: `./specs/reverse-spec/sdd-state.md` relative to CWD (or under the BASE_PATH specified with `--from`)

---

## File Structure

```markdown
# SDD State

**Project**: [Project name]
**Origin**: [greenfield | rebuild | adoption]
**Domain**: [app | data-science] ← domain profile used; default "app"
**Source Path**: [Absolute path to original source code | "N/A" for greenfield | "." for incremental (add)]
**Scope**: [core | full]
**Active Tiers**: [T1 | T1,T2 | T1,T2,T3] ← core scope only; omit this line for full scope
**Created**: [Initial creation date/time]
**Last Updated**: [Last updated date/time]
**Constitution Version**: [Version]

---

## Environment Bootstrap (adoption only)

> Only present when Origin is `adoption`. Omit this section for greenfield/rebuild.

| Item | Status | Details |
|------|--------|---------|
| Dependencies | [✅ installed / ❌ failed / ⏭️ skipped] | [package manager] |
| Environment  | [✅ configured / ⚠️ missing / ⏭️ skipped] | [.env details] |
| Build        | [✅ success / ❌ failed / ⏭️ skipped] | [build command] |
| Tests        | [✅ N/N passed / ⚠️ M/N passed / ⏭️ skipped] | [F] failed, [S] skipped |
| Run          | [✅ responds / ❌ failed / ⏭️ skipped] | [run command] |

If the user skips Environment Bootstrap, record a single row:

| Item | Status | Details |
|------|--------|---------|
| Bootstrap | ⏭️ skipped | User confirmed environment is ready |

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
- ⚠️ : Limited (verify only — user acknowledged limited verification with a recorded reason; merge is allowed with reminder)
- ⏭️ : Skipped
- 🔒 : Deferred (outside current Active Tiers, activate via `/smart-sdd expand`)
- 🔀 : Needs re-execution (Feature affected by `/smart-sdd restructure` or `/smart-sdd parity` — affected steps must be re-run)
- (blank) : Not started

### Feature Status Values
- `pending` : Not yet started (all steps blank)
- `in_progress` : At least one step has started
- `completed` : All steps (including merge) are ✅ — code was built from SDD specs (greenfield/rebuild)
- `adopted` : All adopt steps (specify → plan → analyze → verify → merge) are ✅ — existing code wrapped with SDD docs (adoption only). Distinct from `completed`: signals legacy code that may have pre-existing issues
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

> **Population timing**: Feature ID is set when Feature is created (init/add). spec-kit Name, Path, and Branch are set after `specify` completes (spec-kit creates the branch during specify). Merged is set to ✅ after `merge` completes.

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

Parity check execution history. Recorded when `/smart-sdd parity` is executed. Only applicable to brownfield rebuild projects (Origin: `rebuild`).

| Date/Time | Source Path | Structural Parity | Logic Parity | Gaps Found | New Features | Exclusions | Deferred | Status |
|-----------|------------|-------------------|-------------|------------|-------------|------------|----------|--------|
| 2024-02-01T10:00:00 | /Users/dev/old-project | 95.6% | 90.5% | 8 | 2 | 3 | 1 | completed |

---

## Source Behavior Coverage

Tracks mapping from Source Behavior Inventory (SBI) entries to Functional Requirements. Only populated for projects with Origin `rebuild` or `adoption` (greenfield has no SBI).

| SBI | Priority | FR | Feature | Status |
|-----|----------|----|---------|--------|
| B001 | P1 | FR-001 | F001-auth | ✅ verified |
| B002 | P2 | FR-002 | F001-auth | ✅ verified |
| B003 | P2 | — | — | ❌ unmapped |
| B004 | P1 | FR-005 | F002-product | 🔄 in_progress |
| B005 | P3 | — | — | 🔒 deferred |

**Summary:**
P1: 15/15 (100%) ✅
P2: 22/28 (79%) ⚠️
P3: 5/12 (42%)
Overall: 42/55 (76%)

### SBI Status Values
- `✅ verified` : Mapped to FR-###, Feature verify passed
- `🔄 in_progress` : Mapped to FR-###, Feature not yet verified
- `❌ unmapped` : No FR-### mapping exists yet
- `🔒 deferred` : Outside current Active Tiers (core scope only)

### Coverage Policy
- **P1 behaviors: 100% coverage mandatory** regardless of scope mode
- P2/P3 not in Active Tiers → `deferred` status
- After Core completion, deferred items become incremental candidates

---

## Demo Group Progress

Tracks demo groups defined in `roadmap.md`. Each group represents a user scenario that spans multiple Features. Only populated when Demo Groups exist in the roadmap.

| Group | Scenario | Features | Completed | Status | Last Demo |
|-------|----------|----------|-----------|--------|-----------|
| DG-01 | User Purchase Flow | F001,F002,F003,F005 | 3/4 | ⏳ F005 pending | — |
| DG-02 | Admin Dashboard | F001,F004,F006 | 1/3 | ⏳ F004,F006 pending | 2024-01-20 |

### Demo Group Status Values
- `✅ All verified` : All Features in group verified; Integration Demo completed
- `⏳ [Feature list] pending` : Waiting for listed Features to complete verify
- `⏳ [Feature list] deferred` : Features are outside Active Tiers (core scope); activate via `/smart-sdd expand`
- `🔄 re-run needed ([reason])` : Integration Demo invalidated (e.g., new Feature added to group)

### Integration Demo Trigger
When the last pending Feature in a group completes verify, display HARD STOP:
"All Features in [Group] verified. Run Integration Demo for [Scenario]?"

### Integration Demo Invalidation
When a Feature is added to an existing demo group (via incremental `add`):
- Previous Integration Demo result is invalidated
- Status changes to `🔄 re-run needed (F00N added)`
- Re-triggered when all Features (including new one) are verified

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
5. Set Domain based on the `--domain` argument (default: `app`)
6. Set Origin based on how artifacts were generated:
   - `greenfield` — if initialized by `/smart-sdd init`
   - `rebuild` — if initialized from `/reverse-spec` artifacts for rebuild workflow (`/smart-sdd pipeline`)
   - `adoption` — if initialized from `/reverse-spec` artifacts for adoption workflow (`/smart-sdd adopt`)
   - Origin does not change when Features are added later via `/smart-sdd add`
7. Set Source Path based on the project mode:
   - `greenfield` → `N/A` (no existing source code)
   - `rebuild` / `adoption` → Extract from the `**Source**:` field in `BASE_PATH/roadmap.md` (the original target-directory path used during `/reverse-spec`)
   - `add` (incremental) → `.` (source is the current working directory)
8. Set Scope:
   - `rebuild` → Read from `**Strategy**: Scope: [core|full]` in `BASE_PATH/roadmap.md`
   - `adoption` → Always `full` (must document everything)
   - `greenfield` (init) → Always `full`
   - If roadmap.md has no Scope info (legacy projects) → Default to `full`
9. Set Active Tiers based on Scope:
   - `core` → `T1` (only Tier 1 Features are initially active)
   - `full` → omit the `Active Tiers` field entirely (all Features are active, no Tier concept)
10. Set initial Feature Status:
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
- Update `Last Updated`

### When a Feature Completes (all steps including merge ✅)
- Change the Feature Progress Status to `completed`
- Mark the Feature as `✅` in the Merged column of the Feature Mapping table
- Add update history to the Global Evolution Log

### When a Feature is Adopted (adoption pipeline — all adopt steps including merge ✅)
- Change the Feature Progress Status to `adopted` (NOT `completed`)
- Mark the Feature as `✅` in the Merged column of the Feature Mapping table
- Add update history to the Global Evolution Log
- Note: `adopted` Features have no `tasks` or `implement` steps — these columns show `⏭️` (skipped)

### When Verify Completes in Adoption Mode
- Test failure → record as "pre-existing issue" in Notes (NOT a blocker)
- No tests present → record as "no tests — baseline" in Notes (NOT a blocker)
- Build/lint failure → record only; adoption's purpose is documentation, not code changes
- Set verify step icon to `⚠️` if any pre-existing issues found, `✅` otherwise
- Notes format: `Tests: [result]; Build: [result]; Pre-existing: [count] issues`

### When a Step is Skipped (e.g., analyze has no CRITICAL issues)
- Change the corresponding cell to ⏭️
- Record the skip reason in the Feature Detail Log
- Update `Last Updated`

> **Note on `clarify`**: `clarify` is a conditional sub-step of `specify` — it runs only when ambiguity markers are found in the spec. It is NOT tracked as a separate column in the Feature Progress table. If clarify was executed, note it in the Feature Detail Log under the `specify` row (e.g., "5 FRs, 8 SCs (clarify executed)").

### When Constitution is Finalized (Phase 0 completion)
- Set Constitution Status to `completed`
- Set Constitution Version to the version from the generated file (e.g., `1.0.0`)
- Set Constitution Completed At to current ISO 8601 timestamp
- Set Constitution Updates to `0`
- Add entry to Constitution Update Log: version, date, "Initial finalization"
- Update `Last Updated`

### When Constitution is Incrementally Updated (during Feature pipeline)
- Increment Constitution Version (MINOR bump, e.g., `1.0.0` → `1.1.0`)
- Increment Constitution Updates count
- Add entry to Constitution Update Log: new version, date, trigger Feature, change description
- Update `Last Updated`

### When Scope is Expanded (via /smart-sdd expand — core scope only)
- Update the `Active Tiers` field to the new value (e.g., `T1` → `T1,T2`)
- Change `deferred` Features whose Tier matches the newly activated Tiers to `pending`
- Record the expansion in Global Evolution Log: "Scope expanded: T1 → T1,T2"
- Note: This rule only applies to `core` scope projects. `full` scope has no deferred Features.
- Update `Last Updated`

### When Features are Added (via /smart-sdd add)
- Add new Feature rows to Feature Progress table (all step cells blank, Status = `pending`)
- Add new Feature rows to Feature Mapping table (Feature ID filled, spec-kit Name/Path/Branch blank until specify)
- Record "Feature F{NNN}-{name} added" in Global Evolution Log
- Update `Last Updated`

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

### When SBI Coverage Changes (after specify or verify — rebuild/adoption only)
- After `specify` completes: scan spec.md for `[source: B###]` tags → update Source Behavior Coverage table (SBI → FR → Feature mapping, Status → `🔄 in_progress`)
- After `verify` completes: update matched SBI entries to `✅ verified`
- Recalculate P1/P2/P3 summary percentages
- If P1 coverage < 100% after all Active Tier Features are verified: display warning

### When Demo Group Progress Changes (after verify)
- After `verify` completes: check if the verified Feature is the last pending Feature in any demo group
- If yes → update Demo Group Status to `✅ All verified` and display Integration Demo trigger (HARD STOP)
- If no → update completed count (e.g., `3/4`)
- When a Feature is added to an existing group via `add`: change group Status to `🔄 re-run needed (F00N added)`

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

### When Verify Step Completes — Result Recording

When the verify step is completed, record the following information in the Notes column of the Feature Detail Log:

```
Tests: [passed count]/[total count] passed
Build: [success/failure]
Lint: [success/failure/not configured]
Cross-Feature: [verification point count] checked, [issue count] issues
```

**If limited verification was acknowledged** (user selected "Acknowledge limited verification" in Phase 1 or Phase 3):
- Set the verify step icon to `⚠️` (not ✅) in Feature Progress
- Append to Notes: `⚠️ LIMITED — [reason]` and/or `⚠️ DEMO-LIMITED — [reason]`
- The overall verify status is `limited` (not `success`) — merge is allowed with a reminder
- Example Notes: `Tests: 12/12 passed; Build: success; ⚠️ DEMO-LIMITED — No frontend; pure data layer library`
