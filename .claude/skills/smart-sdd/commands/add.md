# Add Command — 6-Step Incremental Feature Consultation

> Reference: Read after `/smart-sdd add` is invoked. For shared rules, see SKILL.md.

## Add Command — Brownfield Incremental

Running `/smart-sdd add` adds new Feature(s) to an existing smart-sdd project through a **6-step collaborative consultation process**.

**Prerequisite**: `roadmap.md`, `entity-registry.md`, `api-registry.md`, and `sdd-state.md` must already exist at BASE_PATH.

---

## 6-Step Overview

```
Step 1: Explore          — Understand user intent (conversational, no HARD STOP)
Step 2: Impact Analysis  — context-summary.sh + agent analysis (HARD STOP)
Step 3: Scope Negotiation — Single vs multiple Feature proposal (HARD STOP)
Step 4: SBI Match        — Link to unmapped source behaviors (HARD STOP, conditional)
Step 5: Demo Group       — Assign to demo groups (HARD STOP)
Step 6: Finalization     — Create artifacts + user approval (HARD STOP)
```

---

## Step 1: Explore

> Conversational phase — no scripts, no HARD STOP.

Engage the user in a natural conversation to understand their intent:

1. Ask: "Describe the Feature(s) you want to add"
2. Clarify:
   - What problem does this solve?
   - Which existing Features does it interact with?
   - Is this extending an existing capability or adding something entirely new?
3. Listen for:
   - Entity references ("it needs user data", "it manages orders")
   - API dependencies ("it calls the auth endpoint")
   - UI implications ("a new page for...")
   - Data flow patterns ("it reads from X and writes to Y")

**Do NOT propose Feature structure yet** — just gather information.

**Transition**: When the user has provided enough context, move to Step 2. The user does not need to explicitly approve — this step is exploratory.

---

## Step 2: Impact Analysis (HARD STOP)

> Uses `scripts/context-summary.sh` + agent analysis.

### 2a. Run context-summary.sh

Execute the aggregation script to get a compact project summary:

```bash
scripts/context-summary.sh <project-root>
```

The script outputs:
```
Features: 8 (5 completed, 2 in_progress, 1 pending)
Entities: 12 (User, Product, Order, ...)
APIs: 23 endpoints
Demo Groups: 3 (DG-01: 4/4 ✅, DG-02: 2/3 ⏳, DG-03: 0/2)
Origin: rebuild | Scope: core
```

### 2b. Agent Analysis

Using the script output + the user's description from Step 1, identify:

1. **Related Features**: Which existing Features are affected by or depend on the new one?
2. **Shared Entities**: Which existing entities will be referenced? Any new entities needed?
3. **API Impact**: Which existing APIs will be consumed? Any new APIs needed?
4. **Dependency Direction**: Does this Feature depend on others, or will others depend on it?

### 2c. Present Analysis (HARD STOP)

```
📋 Impact Analysis:

── Current State ────────────────────────────────
[context-summary.sh output]

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

**HARD STOP** (CheckpointApproval): "Approve analysis", "Request modifications"

---

## Step 3: Scope Negotiation (HARD STOP)

> Based on complexity, propose single or multiple Features.

### 3a. Complexity Assessment

Evaluate the user's request against:
- Number of entities (owned + referenced)
- Number of API endpoints (provided + consumed)
- Number of distinct user scenarios
- Estimated FR/SC count

### 3b. Feature Proposal

Present options based on complexity:

**If simple** (≤5 FR, 1 entity, ≤3 APIs):
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

**HARD STOP** (CheckpointApproval): "Accept proposal", "Request modifications"

---

## Step 4: SBI Match (HARD STOP, Conditional)

> **Only runs when Origin = `adoption` or `rebuild`**. For greenfield projects, skip to Step 5.

### 4a. Run sbi-coverage.sh

Execute the SBI coverage script with keywords from the user's description:

```bash
scripts/sbi-coverage.sh <project-root> --filter <keywords>
```

Keywords are extracted from the user's description in Step 1 (e.g., "notification email send").

### 4b. Present Unmapped Behaviors

```
📋 SBI Match:

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

**HARD STOP** (CheckpointApproval): "Accept SBI selection", "Modify selection"

If no unmapped behaviors match the filter: display "No matching unmapped behaviors found" and proceed to Step 5.

---

## Step 5: Demo Group Assignment (HARD STOP)

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

**HARD STOP** (CheckpointApproval): "Accept recommendation", "Join [other group]", "Create new group", "No demo group"

If creating a new group:
- Ask for scenario name and description
- The new group will be added to roadmap.md Demo Groups section

---

## Step 6: Definition Finalization (HARD STOP)

> Create all artifacts reflecting decisions from Steps 1-5.

### 6a. Generate Artifacts

1. **Create `features/F00N-name/pre-context.md`** per new Feature:
   - Source Reference: `.` (current project) for add mode, or `N/A` if truly new
   - Source Behavior Inventory: Selected SBI entries from Step 4 (with B### IDs), or "N/A — no source to inventory" for greenfield
   - For /speckit.specify: Feature description + dependency summary (no detailed FR/SC drafts for add mode, unless SBI entries provide them)
   - For /speckit.plan: Dependencies with entity/API info from existing registries
   - For /speckit.analyze: Dependency-based cross-Feature verification points

2. **Update `roadmap.md`**:
   - Add new Feature(s) to Feature Catalog (with Tier for core scope, or dependency position for full scope)
   - Add new nodes/edges to Dependency Graph
   - Place new Features in Release Groups
   - Update Cross-Feature Entity/API Dependencies
   - Update Demo Groups section (if group was joined or created in Step 5)

3. **Update `sdd-state.md`**:
   - Add new Feature rows to Feature Progress table (`pending`)
   - Add to Feature Mapping (spec-kit Name/Path/Branch blank until specify)
   - Record "Feature F{NNN}-{name} added" in Global Evolution Log
   - If SBI entries selected in Step 4: update Source Behavior Coverage (link to new Feature, status remains `❌ unmapped` until specify)
   - If Demo Group changed in Step 5: update Demo Group Progress

### 6b. Final Summary (HARD STOP)

```
📋 Summary: New Feature(s) Defined

── Features ─────────────────────────────────────
  F009-notifications
    Dependencies: F001-auth, F003-order
    [Tier: 2 (if core scope)]
    SBI: B023, B024, B031 (3 behaviors from original source)
    Demo Group: DG-01 (User Purchase Flow)
    Est. FRs: ~7 | Est. SCs: ~9

── Artifacts Created/Updated ────────────────────
  Created: features/F009-notifications/pre-context.md
  Updated: roadmap.md (Feature Catalog, Dependency Graph, Demo Groups)
  Updated: sdd-state.md (Feature Progress, SBI Coverage, Demo Group Progress)

── Next Steps ───────────────────────────────────
  /smart-sdd specify F009     — Start specifying the new Feature
  /smart-sdd pipeline         — Resume pipeline (picks up from first pending)

──────────────────────────────────────────────────
```

**HARD STOP** (CheckpointApproval): "Approve and finalize", "Request modifications"

If "Request modifications": loop back to the relevant Step (user indicates which aspect to change).

---

## Edge Cases

### Multiple Features Added at Once

If Step 3 proposes multiple Features:
- Steps 4-5 are repeated per Feature
- Step 6 creates all artifacts in one batch
- Dependencies between new Features are also recorded

### Greenfield Projects

- Step 4 (SBI Match) is skipped entirely — no source behaviors to match
- Step 5 may also be skipped if no Demo Groups exist yet (propose creating the first ones)

### No Demo Groups Defined

If the project has no Demo Groups in roadmap.md:
- Step 5 proposes creating the initial Demo Groups based on existing Features + the new one
- This is a catch-up mechanism for projects that predate the Demo Group feature
