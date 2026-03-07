# Add Command — 6-Phase Universal Feature Definition

> Reference: Read after `/smart-sdd add` is invoked. For shared rules, see SKILL.md.

## Add Command — Universal Feature Definition

Running `/smart-sdd add` defines new Feature(s) through a **6-Phase collaborative consultation process**. This is the **universal Feature definition path** for all project modes:

- **Greenfield**: After `/smart-sdd init` sets up the project, use `add` to define Features
- **Incremental**: Add new Features to an existing smart-sdd project
- **Rebuild/Adoption**: Add Features beyond the original source scope

**Prerequisite**: `roadmap.md`, `entity-registry.md`, `api-registry.md`, and `sdd-state.md` must already exist at BASE_PATH.

---

## 6-Phase Overview

```
Phase 1: Feature Definition   — Adaptive consultation (no HARD STOP)
Phase 2: Overlap & Impact     — Overlap check + constitution impact (HARD STOP)
Phase 3: Scope Negotiation    — Single vs multiple Feature, Tier assignment (HARD STOP)
Phase 4: SBI Match + Expand   — Link/create source behaviors (HARD STOP, conditional)
Phase 5: Demo Group           — Assign to demo groups (HARD STOP)
Phase 6: Finalization         — Create artifacts + user approval (HARD STOP)
```

---

## Draft File Lifecycle

All Phases share a persistent draft file at `specs/add-draft.md`:

```
Phase 1 → Create specs/add-draft.md (Feature candidates)
Phase 2 → Add Overlap Report + Constitution Impact sections
Phase 3 → Add Confirmed Feature Structure section
Phase 4 → Add SBI Mapping section
Phase 5 → Add Demo Group Assignment section
Phase 6 → Generate final artifacts → DELETE specs/add-draft.md
```

**Session resume**: If `specs/add-draft.md` exists when `add` is invoked:
1. Read the draft and identify the last completed Phase
2. Ask the user via AskUserQuestion:
   - "Resume from Phase [N+1]" — Continue where we left off
   - "Start fresh" — Delete draft and restart from Phase 1
3. **If response is empty → re-ask** (per MANDATORY RULE 1)

---

## Phase 1: Feature Definition (Adaptive Consultation)

> Conversational phase — no scripts, no HARD STOP.
> ※ Detailed adaptive consultation design is deferred to a follow-up iteration. Current implementation provides the framework.

### 1a. User Readiness Detection

Observe the user's initial input to determine their readiness level:

| Type | Signal | Approach |
|------|--------|----------|
| **A: Vague idea** | "I want something for notifications" | Guided brainstorming — ask clarifying questions to shape the Feature |
| **B: Specific requirements** | "I need push + email notifications with user preferences" | Structured confirmation — organize into Feature structure |
| **C: PRD/document** | User provides a document path or pastes structured requirements | Document parsing — extract Features from the document, confirm with user |
| **D: Extend existing** | "I want to add search to the product Feature" | Reference existing Feature's spec.md/plan.md to understand current scope |

### 1b. Information Gathering

Regardless of readiness type, collect:

1. **Feature purpose**: What problem does this solve?
2. **Key capabilities**: What should the user be able to do?
3. **Entity hints**: What data does it manage? ("it needs user data", "it manages orders")
4. **API hints**: What endpoints are needed? ("it calls the auth endpoint")
5. **Dependency hints**: Which existing Features does it interact with?
6. **UI hints** (if applicable): What pages or components are needed?

**Do NOT propose Feature structure yet** — just gather information.

### 1c. Create Draft

Create `specs/add-draft.md` with the gathered information:

```markdown
# Add Draft — [Date]

## Phase 1: Feature Candidates

### Candidate 1: [Feature Name]
- **Description**: [1-2 sentence description]
- **Key capabilities**: [bullet list]
- **Estimated entities**: [entity names mentioned]
- **Estimated APIs**: [endpoint hints]
- **Estimated dependencies**: [Feature IDs]

### Candidate 2: [if multiple]
...

## Status: Phase 1 complete
```

**Transition**: When the user has provided enough context and the draft is created, move to Phase 2. The user does not need to explicitly approve — this phase is exploratory.

---

## Phase 2: Overlap & Impact Analysis (HARD STOP)

> Uses `scripts/context-summary.sh` + agent analysis.

### 2a. Run context-summary.sh

Execute the aggregation script to get a compact project summary:

```bash
scripts/context-summary.sh <project-root>
```

### 2b. Overlap Check

**Skip condition**: If this is the **first Feature in a greenfield project** (no existing Features in roadmap.md), skip overlap analysis and proceed to impact assessment only.

Analyze the Feature candidate(s) from Phase 1 against existing Features:

1. **Feature duplication**: Does an existing Feature already cover this functionality?
   - Check Feature descriptions in roadmap.md
   - If partial overlap: suggest extending the existing Feature vs. creating a new one
2. **Entity ownership conflict**: Does the candidate claim entities already owned by another Feature?
   - Check entity-registry.md ownership
   - If conflict: propose referencing (FK) instead of owning
3. **API path duplication**: Do proposed endpoints duplicate existing ones?
   - Check api-registry.md routes
   - If conflict: suggest versioning, namespacing, or extending existing endpoints
4. **Scope readjustment**: Should the candidate absorb part of an existing Feature, or vice versa?

### 2c. Constitution Impact Check (Conditional)

Evaluate whether the new Feature introduces patterns not covered by the current constitution:

1. **New technology**: Does the Feature require libraries/frameworks not in the current stack?
2. **New patterns**: Does it introduce patterns (e.g., event sourcing, CQRS, WebSocket) not covered by existing principles?
3. **New constraints**: Does it add runtime requirements (e.g., GPU, external service dependency)?

**If impact detected**: Display a warning:
```
⚠️ Constitution Impact: This Feature introduces [new technology/pattern].
   Consider updating the constitution after this Feature is defined:
   /smart-sdd constitution
```

**If no impact**: Skip silently.

### 2d. Agent Impact Assessment

Using the script output + Phase 1 candidates, identify:

1. **Related Features**: Which existing Features are affected by or depend on the new one?
2. **Shared Entities**: Which existing entities will be referenced? Any new entities needed?
3. **API Impact**: Which existing APIs will be consumed? Any new APIs needed?
4. **Dependency Direction**: Does this Feature depend on others, or will others depend on it?

### 2e. Present Analysis (HARD STOP)

```
📋 Phase 2: Overlap & Impact Analysis

── Current State ────────────────────────────────
[context-summary.sh output]

── Overlap Check ────────────────────────────────
[If overlaps found:]
  ⚠️ Feature duplication: [candidate] overlaps with F003-order in [area]
     Recommendation: [extend F003 / create new with clear boundary]
  ⚠️ Entity conflict: [candidate] claims "User" entity owned by F001-auth
     Recommendation: Reference via FK, not own
[If no overlaps:]
  ✅ No overlaps with existing Features

── Constitution Impact ──────────────────────────
[If impact:]
  ⚠️ New technology: Redis (not in current stack)
  💡 Consider /smart-sdd constitution update after Feature definition
[If no impact:]
  ✅ No constitution impact

── Impact Assessment ────────────────────────────
  Related Features:
    - F001-auth: [entity dependency — references User entity]
    - F003-order: [API dependency — will consume order status API]

  Entities affected:
    - User (F001-auth): will add new field or reference
    - [NEW] Notification: new entity needed

  APIs affected:
    - POST /auth/verify (F001-auth): consumed for authentication
    - [NEW] POST /notifications/send: new API to define

  Dependency: F001-auth, F003-order → [new Feature]

──────────────────────────────────────────────────
```

Update `specs/add-draft.md` with Phase 2 results.

**HARD STOP** (CheckpointApproval): "Approve analysis", "Request modifications"

---

## Phase 3: Scope Negotiation (HARD STOP)

> Based on complexity, propose single or multiple Features.

### 3a. Complexity Assessment

Evaluate the user's request against:
- Number of entities (owned + referenced)
- Number of API endpoints (provided + consumed)
- Number of distinct user scenarios
- Estimated FR/SC count

### 3b. Feature Proposal

Present options based on complexity:

**If simple** (<=5 FR, 1 entity, <=3 APIs):
```
📋 Scope Proposal:

Option A (Recommended): Single Feature
  F009-notifications
  Est. 4 FRs, 6 SCs
  Dependencies: F001-auth, F003-order
```

**If complex** (>5 FR, multiple entities, >3 APIs):
```
📋 Scope Proposal:

Option A: Single Feature (larger)
  F009-notifications
  Est. 12 FRs, 15 SCs — larger review cycle

Option B (Recommended): Split into 2 Features
  F009-notification-engine — Core notification logic, templates, delivery
    Est. 7 FRs, 9 SCs
  F010-notification-preferences — User preferences, channels, schedules
    Est. 5 FRs, 6 SCs
    Depends on: F009
```

### 3c. Tier Assignment (core scope only)

If the project uses `core` scope (read from `sdd-state.md`):
- Propose Tier classification for each new Feature
- Default: Tier 2 (added Features are typically enhancements)
- If the user describes it as critical: propose Tier 1

If `full` scope: skip Tier assignment.

### 3d. Feature ID Assignment

Assign the next available Feature ID(s) based on existing Features in roadmap.md:
- Read the highest existing F### ID
- Assign sequentially: F[max+1], F[max+2], ...

Update `specs/add-draft.md` with the confirmed Feature structure.

**HARD STOP** (CheckpointApproval): "Accept proposal", "Request modifications"

---

## Phase 4: SBI Match + Expansion (HARD STOP, Conditional)

> **Runs when Origin = `adoption` or `rebuild`**. For greenfield projects, skip to Phase 5.

### 4a. Run sbi-coverage.sh

Execute the SBI coverage script with keywords from Phase 1:

```bash
scripts/sbi-coverage.sh <project-root> --filter <keywords>
```

Keywords are extracted from the Phase 1 description (e.g., "notification email send").

### 4b. Present Unmapped Behaviors

```
📋 Phase 4: SBI Match + Expansion

── Current SBI Coverage ─────────────────────────
  P1: 15/15 (100%) ✅
  P2: 22/28 (79%) ⚠️
  P3: 5/12 (42%)

── Matching Unmapped Behaviors ──────────────────
  B023 | P2 | sendEmail() — Send email via SMTP | ❌ unmapped
  B024 | P2 | formatNotification() — Template rendering | ❌ unmapped
  B031 | P3 | scheduleDelivery() — Delayed notification | ❌ unmapped

  These behaviors from the original source are not yet covered by
  any Feature. Should this new Feature cover them?

──────────────────────────────────────────────────
```

### 4c. User Selection

Ask which unmapped SBI entries should be covered by this new Feature:
- Selected entries will be referenced in the new Feature's pre-context.md SBI section
- Their status in `sdd-state.md` Source Behavior Coverage will be updated when the Feature completes specify

### 4d. SBI Expansion (NEW Behaviors)

After mapping existing behaviors, ask the user:

> "Does this Feature include capabilities **beyond** the original source? If so, describe them."

If the user describes new behaviors not in the original SBI:

1. **Assign NEW B### IDs**: Continue from the project's highest existing B### ID
2. **Record with Origin=`new`**: These entries are tagged as `new` to distinguish from `extracted` entries
3. **Priority assignment**: Ask the user to assign P1/P2/P3 for each new behavior

```
── NEW Behaviors (not in original source) ───────
  B045 | P1 | new | pushNotification() — Send push notification via FCM
  B046 | P2 | new | notificationPreferences() — Per-user channel preferences

  ⚠️ NEW behaviors are tracked separately from original source coverage.
  They do NOT affect the original SBI coverage metrics.
```

If no new behaviors: proceed without expansion.

Update `specs/add-draft.md` with SBI mapping and NEW entries.

**HARD STOP** (CheckpointApproval): "Accept SBI selection", "Modify selection"

If no unmapped behaviors match the filter AND no new behaviors: display "No SBI changes" and proceed to Phase 5.

---

## Phase 5: Demo Group Assignment (HARD STOP)

> Uses `scripts/demo-status.sh` + agent analysis.

### 5a. Run demo-status.sh

```bash
scripts/demo-status.sh <project-root>
```

### 5b. Propose Demo Group

Based on the new Feature's entity/API dependencies and user scenario:

1. **Join existing group**: If the new Feature extends an existing user journey
2. **Create new group**: If the new Feature introduces a new user scenario
3. **No group (infrastructure)**: If the Feature is cross-cutting (utilities, config)

```
📋 Demo Group Assignment:

── Current Demo Groups ──────────────────────────
[demo-status.sh output]

── Proposal ─────────────────────────────────────
  Recommendation: Join DG-01 (User Purchase Flow)
  Reason: Notifications are triggered by order events (F003-order)

  Alternatives:
    - Create DG-04 "Notification Management"
    - No demo group (infrastructure)

──────────────────────────────────────────────────
```

**HARD STOP** (CheckpointApproval):
- **"Accept recommendation"** — Use the suggested group assignment
- **"Join [other group]"** — Join a different existing group (specify which)
- **"Create new Demo Group"** — Define a brand new demo group for this Feature
- **"No demo group"** — Infrastructure/cross-cutting Feature, no user-facing demo

### 5c. New Demo Group Creation (if selected)

If the user selects "Create new Demo Group":

1. Ask for group details via AskUserQuestion:
   - **Scenario name**: Short name (e.g., "Notification Management")
   - **Description**: One-line user journey description

2. Assign the next available Demo Group ID (DG-NN)

3. Add the new group to `roadmap.md` Demo Groups section:
   ```
   ### DG-{NN}: {Scenario Name}
   **Scenario**: {Description}
   **Features**: F{NNN}-{new-feature}
   **SBI Coverage**: (populated during specify)
   ```

4. Display confirmation:
   ```
   ✅ Created Demo Group DG-{NN}: {Scenario Name}
      Feature: F{NNN}-{new-feature}
   ```

Update `specs/add-draft.md` with Demo Group assignment.

---

## Phase 6: Definition Finalization (HARD STOP)

> Create all artifacts reflecting decisions from Phases 1-5.

### 6a. Generate Artifacts

1. **Create `features/F00N-name/pre-context.md`** per new Feature:
   - Source Reference: `.` (current project) for incremental/adoption, or `N/A` if greenfield with no source
   - Source Behavior Inventory:
     - **If SBI entries selected in Phase 4**: Include selected entries (with B### IDs and Origin), plus generate FR draft entries for each mapped behavior
     - **If no SBI (greenfield)**: "N/A — no source to inventory"
   - For /speckit.specify:
     - **With SBI mapping**: Feature description + dependency summary + FR drafts derived from SBI behaviors
     - **Without SBI**: Feature description + dependency summary only (no FR/SC drafts)
   - For /speckit.plan: Dependencies with entity/API info from existing registries
   - For /speckit.analyze: Dependency-based cross-Feature verification points

2. **Update `roadmap.md`**:
   - Add new Feature(s) to Feature Catalog (with Tier for core scope, or dependency position for full scope)
   - Add new nodes/edges to Dependency Graph
   - Place new Features in Release Groups
   - Update Cross-Feature Entity/API Dependencies
   - Update Demo Groups section (if group was joined or created in Phase 5)

3. **Update `sdd-state.md`**:
   - Add new Feature rows to Feature Progress table:
     - If core scope AND new Feature's Tier is outside Active Tiers → Status = `deferred` (lock)
     - Otherwise → Status = `pending`
   - Add to Feature Mapping (spec-kit Name/Path/Branch blank until specify)
   - Record "Feature F{NNN}-{name} added" in Global Evolution Log
   - If SBI entries selected/created in Phase 4: update Source Behavior Coverage
     - Existing entries: link to new Feature, status remains `unmapped` until specify
     - NEW entries: add with Origin=`new`, status `unmapped`
   - If Demo Group changed in Phase 5: update Demo Group Progress

4. **Delete `specs/add-draft.md`** — draft served its purpose

### 6b. Decision History Recording

**Append** to `specs/history.md` (create with standard header if it doesn't exist):

```markdown
---

## [YYYY-MM-DD] /smart-sdd add — Feature Definition

### Feature Definition

| Decision | Choice | Details |
|----------|--------|---------|
| Features added | F{NNN}-{name}[, F{NNN}-{name}] | [N] Feature(s), [dependencies] |
| Overlap resolution | [None / Adjusted boundary with F{NNN}] | [details if applicable] |
| SBI mapping | [N] existing + [N] NEW behaviors | [or "N/A — greenfield"] |
| Demo Group | [DG-NN / New DG-NN / None] | [group name] |
```

### 6c. Final Summary (HARD STOP)

```
📋 Summary: New Feature(s) Defined

── Features ─────────────────────────────────────
  F009-notifications
    Dependencies: F001-auth, F003-order
    [Tier: 2 (if core scope)]
    SBI: B023, B024, B031 (3 existing) + B045, B046 (2 NEW)
    Demo Group: DG-01 (User Purchase Flow)
    Est. FRs: ~7 | Est. SCs: ~9

── Artifacts Created/Updated ────────────────────
  Created: features/F009-notifications/pre-context.md
  Updated: roadmap.md (Feature Catalog, Dependency Graph, Demo Groups)
  Updated: sdd-state.md (Feature Progress, SBI Coverage, Demo Group Progress)
  Deleted: specs/add-draft.md

── Next Steps ───────────────────────────────────
  /smart-sdd specify F009     — Start specifying the new Feature
  /smart-sdd pipeline         — Resume pipeline (picks up from first pending)

──────────────────────────────────────────────────
```

**HARD STOP** (CheckpointApproval): "Approve and finalize", "Request modifications"

If "Request modifications": loop back to the relevant Phase (user indicates which aspect to change).

---

## Edge Cases

### Multiple Features Added at Once

If Phase 3 proposes multiple Features:
- Phases 4-5 are repeated per Feature
- Phase 6 creates all artifacts in one batch
- Dependencies between new Features are also recorded

### Greenfield Projects (First Features)

- Phase 2 overlap check is skipped (no existing Features to overlap with)
- Phase 4 (SBI Match) is skipped entirely — no source behaviors to match
- Phase 5 proposes creating the initial Demo Groups

### Existing Draft File

If `specs/add-draft.md` exists when `add` is invoked:
- The draft represents an incomplete previous session
- Offer to resume from the last completed Phase or start fresh
- See [Draft File Lifecycle](#draft-file-lifecycle) section above

### No Demo Groups Defined

If the project has no Demo Groups in roadmap.md:
- Phase 5 proposes creating the initial Demo Groups based on existing Features + the new one
- This is a catch-up mechanism for projects that predate the Demo Group feature
