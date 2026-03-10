# SDD State Schema

This document defines the format of the `sdd-state.md` file. smart-sdd automatically creates and manages this file.

**File location**: `./specs/reverse-spec/sdd-state.md` relative to CWD (or under the BASE_PATH specified with `--from`)

---

## File Structure

```markdown
# SDD State

**Project**: [Project name]
**Origin**: [greenfield | rebuild | adoption]
**Domain Profile**: [profile-name or "custom"]
**Interfaces**: [comma-separated list, e.g., http-api, gui]
**Concerns**: [comma-separated list, e.g., async-state, auth, i18n]
**Scenario**: [greenfield | rebuild | incremental | adoption]
**Custom**: [path to domain-custom.md | "none"]
**Source Path**: [Absolute path to original source code | "N/A" for greenfield | "." for incremental (add)]
**Clarity Index**: [XX% | "N/A" for rebuild/adoption]
**CI Dimensions**: [Core:N, Cap:N, Type:N, Stack:N, Users:N, Scale:N, Constraints:N]
**CI Low-confidence**: [comma-separated dimension names with score ≤ 1, or "none"]
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

## Toolchain

> Detected by Foundation Gate Toolchain Pre-flight. verify Phase 1 reads this to skip unavailable tools.

| Tool | Command | Status | Detected At |
|------|---------|--------|-------------|
| Build | npm run build | ✅ available | 2024-01-15T10:00:00 |
| Test | npm test | ✅ available | 2024-01-15T10:00:00 |
| Lint | npx eslint . | ⚠️ not installed | 2024-01-15T10:00:00 |

**Status values**:
- `✅ available` : Tool detected and executable
- `⚠️ not installed` : Config found but tool binary missing or not executable
- `ℹ️ not configured` : No configuration found for this tool type

**Update rules**:
- **Written by**: Foundation Gate Toolchain Pre-flight (first Feature or Foundation re-run)
- **Updated by**: verify Phase 1 Step 3b (retroactive — if user installed the tool between Features)
- **Re-detection trigger**: Foundation Gate re-runs when Foundation-affecting files change (e.g., `package.json` change qualifies)

---

## Foundation Verified

> Written by Foundation Gate (pipeline.md Step 3b). Read by pipeline to determine if Foundation Gate can be skipped for subsequent Features.

```
Foundation Verified: [ISO date] | [PASS/WARN/FAIL] | [details summary]
```

**Example**: `Foundation Verified: 2024-01-15T10:30:00 | WARN | Build ✅, Toolchain ⚠️ (lint not installed), CSS Theme ✅, Layout ✅`

**Skip logic**: If this field exists AND no Foundation-affecting changes since the recorded date → skip Foundation Gate. Foundation-affecting changes = modifications to files outside `specs/` (theme config, store definitions, layout components, IPC handlers, build config, package.json).

---

## Feature Progress

**Full scope** (no Tier column):

| Feature ID | Feature Name | specify | plan | tasks | analyze | implement | verify | merge | Status |
|------------|-------------|---------|------|-------|---------|-----------|--------|-------|--------|
| F001 | auth | ✅ 01-15 | ✅ 01-16 | ✅ 01-16 | ✅ 01-16 | ✅ 01-17 | ✅ 01-17 | ✅ 01-17 | completed |
| F002 | product | ✅ 01-18 | 🔄 | | | | | | in_progress |

**Core scope** (with Tier column):

| Feature ID | Feature Name | Tier | specify | plan | tasks | analyze | implement | verify | merge | Status |
|------------|-------------|------|---------|------|-------|---------|-----------|--------|-------|--------|
| F001 | auth | T1 | ✅ 01-15 | ✅ 01-16 | ✅ 01-16 | ✅ 01-16 | ✅ 01-17 | ✅ 01-17 | ✅ 01-17 | completed |
| F002 | product | T1 | ✅ 01-18 | 🔄 | | | | | | in_progress |

### Step Status Icons
- ✅ : Completed (followed by completion date MM-DD)
- 🔄 : In progress
- ❌ : Failed
- ⚠️ : Limited (verify only — user acknowledged limited verification with a recorded reason; merge is allowed with reminder)
- ⏭️ : Skipped
- 🔒 : Deferred (outside current Active Tiers, activate via `/smart-sdd expand`)
- 🔀 : Needs re-execution (Feature affected by restructure or `/smart-sdd parity` — affected steps must be re-run; see `reference/restructure-guide.md`)
- (blank) : Not started

### Feature Status Values
- `pending` : Not yet started (all steps blank)
- `in_progress` : At least one step has started
- `completed` : All steps (including merge) are ✅ — code was built from SDD specs (greenfield/rebuild)
- `adopted` : All adopt steps (specify → plan → analyze → verify → merge) are ✅ — existing code wrapped with SDD docs (adoption only). Distinct from `completed`: signals legacy code that may have pre-existing issues
- `deferred` : Outside current Active Tiers (core scope only)
- `restructured` : Feature was modified (split/merge/move/delete) — has 🔀 steps that need re-execution (see `reference/restructure-guide.md`)
- `regression-specify` : Verify found regression requiring re-run from specify step
- `regression-plan` : Verify found regression requiring re-run from plan step
- `regression-implement` : Verify found regression requiring re-run from implement step

---

### Special Flags (Detail/Notes column)

| Flag | Set By | Meaning | Impact |
|------|--------|---------|--------|
| `⚠️ RUNTIME-DEGRADED` | implement (MCP unavailable) | Feature was implemented without runtime verification | verify Phase 3 BLOCKS if MCP is still unavailable — requires user acknowledgment |
| `⚠️ NEVER-RUNTIME-VERIFIED — [reason]` | verify (MCP still unavailable) | User acknowledged no runtime verification will be done | Recorded for traceability. Not blocking further pipeline steps |
| `⚠️ RUNTIME-ERRORS-ACKNOWLEDGED — [reason]` | implement (Runtime Error Zero Gate) | User acknowledged runtime errors exist but chose to proceed | verify Phase 1 will still check; recorded for traceability |
| `⚠️ FOUNDATION-OVERRIDE — [reason]` | pipeline (Foundation Gate) | User overrode a BLOCKING Foundation check failure | Foundation issues may surface during Feature verification |

---

## Feature Detail Log

### F001-auth

| Step | Status | Started | Completed | Notes |
|------|--------|---------|-----------|-------|
| specify | completed | 2024-01-15T10:00:00 | 2024-01-15T10:30:00 | 5 FRs, 8 SCs |
| plan | completed | 2024-01-16T09:00:00 | 2024-01-16T11:00:00 | 3 entities, 5 APIs |

### F002-product

| Step | Status | Started | Completed | Notes |
|------|--------|---------|-----------|-------|
| specify | completed | 2024-01-18T09:00:00 | 2024-01-18T10:00:00 | 8 FRs, 12 SCs |
| plan | in_progress | 2024-01-18T10:30:00 | | |

### Verify Progress

> Written by verify at start, updated after each Phase. Survives context compaction.
> Deleted when verify completes (replaced by final result in Notes).

Format (in Feature Detail Log, below the Step table):

```
#### Verify Progress
| Phase | Status | Result |
|-------|--------|--------|
| Phase 0 | ✅ complete | App started, CDP active |
| Phase 1 | ✅ complete | Tests 228/228, Build ✅, Lint ✅ |
| Phase 2 | ✅ complete | SBI 30/30, Cross-feature ✅ |
| Phase 3 | ⏳ pending | — |
| Phase 3b | ⏳ pending | — |
| Phase 4 | ⏳ pending | — |

⚠️ RESUME FROM: Phase 3 — Read commands/verify-phases.md § Phase 3
```

**Status values**: `⏳ pending`, `🔄 in_progress`, `✅ complete`, `❌ failed`, `⏭️ skipped`

**Lifecycle**: Created at verify start → Updated per Phase → Deleted at verify completion (success/failure recorded in Notes)

**Purpose**: When context compaction occurs during verify, the agent loses in-memory progress tracking. On resumption, the agent reads sdd-state.md (which is always read at session start), finds the Verify Progress table, and resumes from the first pending Phase without re-running completed Phases.

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
| 2024-01-17 | F001-auth (implement) | pre-context.md (F002) | Updated entity/API drafts to match actual implementation |

---

## Restructure Log

Feature restructuring history. Recorded when Feature structure is modified (see `reference/restructure-guide.md`).

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

Tracks mapping from Source Behavior Inventory (SBI) entries to Functional Requirements. Populated for projects with Origin `rebuild` or `adoption`, and also when `/smart-sdd add` creates NEW behaviors.

| SBI | Priority | Origin | FR | Feature | Status |
|-----|----------|--------|----|---------|--------|
| B001 | P1 | extracted | FR-001 | F001-auth | ✅ verified |
| B050 | P2 | new | FR-003 | F009-notif | 🔄 in_progress |

**Summary (extracted only — original source coverage):**
P1: 15/15 (100%) ✅
P2: 22/28 (79%) ⚠️
P3: 5/12 (42%)
Overall: 42/55 (76%)

**NEW behaviors:** 1 total (0 verified, 1 in_progress)

### SBI Status Values
- `✅ verified` : Mapped to FR-###, Feature verify passed
- `🔄 in_progress` : Mapped to FR-###, Feature not yet verified
- `❌ unmapped` : No FR-### mapping exists yet
- `🔒 deferred` : Outside current Active Tiers (core scope only)

### SBI Origin Values
- `extracted` : Behavior extracted from original source code during `/reverse-spec` Phase 2/4
- `new` : Behavior defined by user during `/smart-sdd add` Phase 4 (not present in original source)

### Coverage Policy
- **P1 behaviors: 100% coverage mandatory** regardless of scope mode (applies to Origin=`extracted` only)
- P2/P3 not in Active Tiers → `deferred` status
- After Core completion, deferred items become incremental candidates
- **NEW entries** (Origin=`new`): Tracked separately from original source coverage metrics. They do NOT affect the extracted P1/P2/P3 percentages. NEW coverage is reported as a separate "NEW behaviors" line

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
For the full execution procedure and result recording, see `reference/demo-standard.md` § 7.

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
5. Set Domain Profile based on the `--profile` argument (or `--domain` for backward compatibility). Resolve via `domains/_resolver.md`
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
11. Set Clarity Index (greenfield only — from Proposal Mode):
   - If init used Proposal Mode: write CI percentage, per-dimension scores, and low-confidence list
   - If init used Standard Mode (full Q&A): set CI to `N/A` (user provided all info interactively)
   - `rebuild` / `adoption`: always `N/A` (CI not applicable — project already exists)

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

### When a Feature is Restructured (see reference/restructure-guide.md)
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

### When Clarity Index Updates (greenfield only)

> CI is set during init Proposal Mode and may improve as the pipeline progresses. CI never decreases.
> Full specification: `reference/clarity-index.md` § 6.

- After `init` Proposal Mode — initial scoring: write initial CI to header
- After `init` Proposal Mode — after clarification: update CI with improved scores
- After `add` — Features defined: update Key Capabilities dimension based on Feature count and specificity
- After `specify` — spec.md generated: partial update (constraints/capabilities refined from spec details)
- **CI never decreases**: Only dimensions that improve are updated; scores never drop
- `rebuild` / `adoption` origins: CI remains `N/A` throughout (existing project, no inference needed)
