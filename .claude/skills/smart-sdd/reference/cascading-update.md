# Cascading Update Protocol

> **When to read this file**: When a user provides feedback, requests changes, or directly edits an artifact (spec.md, plan.md, tasks.md) at ANY point after specify completes.
>
> **Core principle**: All changes flow through the artifact hierarchy. Code is NEVER directly modified without first updating the appropriate artifact. The artifact hierarchy is the single source of truth; code is derived from it.

---

## Artifact Hierarchy

```
spec.md (WHAT to build)
  ↓ drives
plan.md (HOW to build)
  ↓ drives
tasks.md (STEPS to build)
  ↓ drives
source code (THE build)
```

**Upstream changes cascade downstream. Downstream changes may require upstream updates.**

---

## Trigger: User Feedback During Pipeline

When the user provides feedback at any HARD STOP or between steps:

### Step 1 — Classify the Change Level

**Before touching ANY file**, determine which artifact level the change belongs to:

| Signal | Level | Example |
|--------|-------|---------|
| "This feature should also do X" | **spec** | Missing FR — new requirement |
| "The SC doesn't cover Y" | **spec** | Missing/incomplete SC |
| "This should be a dropdown, not text input" | **spec** | FR detail missing |
| "Use a different architecture for this" | **plan** | Architecture change |
| "This component should be split into two" | **plan** | Component structure change |
| "Add a task for error handling" | **tasks** | Missing task |
| "This function has a bug" | **code** | Implementation bug (Minor) |

**Decision flow**:
```
Is the user describing WHAT should happen (behavior/requirement)?
  → spec level change

Is the user describing HOW it should be built (architecture/design)?
  → plan level change

Is the user describing WHICH steps to take (task ordering/grouping)?
  → tasks level change

Is the user pointing out a bug in existing code?
  → code level (use Bug Fix Severity Rule)
```

### Step 2b — Impact Analysis + Flow Proposal (MANDATORY at all HARD STOPs)

When user feedback is received at ANY HARD STOP (specify Review, plan Review, tasks Review, verify Demo, etc.), the agent MUST:

**1. Classify the feedback:**

| Classification | Definition | Example |
|---------------|-----------|---------|
| **Bug** | Current implementation doesn't match current spec | "Login returns 500 instead of 401" |
| **Spec Gap** | Spec is missing a requirement | "Token estimation doesn't include output tokens" |
| **Improvement** | Spec is correct but could be better | "Could we add Korean chars/token ratio?" |
| **New Requirement** | Outside current Feature scope | "We need a model cost dashboard" |

**2. Analyze impact:**

```
Affected artifacts:
  FR: [list affected FRs]
  SC: [list affected SCs]
  Files: [estimated file count]
  Other Features: [cross-Feature impact if any]
```

**3. Propose flow:**

| Classification | Severity | Proposed Flow | Command |
|---------------|----------|--------------|---------|
| Bug, ≤2 files | Minor | Fix in current step | (inline fix) |
| Bug, 3+ files | Major-Implement | Return to implement | `pipeline F00N --start implement` |
| Bug, architecture | Major-Plan | Return to plan | `pipeline F00N --start plan` |
| Spec Gap | Major-Spec | Return to specify | `pipeline F00N --start specify` |
| Improvement (in scope) | Enhancement | Augment Feature | `add --to F00N "description"` → `pipeline F00N --start specify` |
| New Requirement | New Feature | Separate Feature | `add "description"` → new F00M |
| New Requirement (T2+) | Deferred | Record in roadmap | Note in roadmap.md, continue current pipeline |

**4. Present to user (HARD STOP):**

```
📋 Feedback Analysis:

Classification: [Spec Gap]
Impact: FR-004 (estimation logic), SC-003 (deduction flow), SC-006 (concurrency)
Files: ~2 (budget.guard.ts, budget-engine.service.ts Lua script)

Proposed Flow:
  → pipeline F004 --start specify
  → Spec에 output token estimation + message overhead FR 수정
  → Plan, Tasks, Implement, Verify cascade

Alternative:
  → 새 Feature F008로 분리 (T2 scope)

어떻게 진행할까요?
```

AskUserQuestion options:
- "Proposed Flow로 진행" (Recommended)
- "Alternative로 진행"
- "다른 방법 제안"

**If response is empty → re-ask** (per MANDATORY RULE 1).

**5. Execute chosen flow.**

---

❌ WRONG: User says "estimation이 부정확해" → Agent: "맞습니다. output 누락입니다." → (stops, waits for user to figure out next steps)
✅ RIGHT: User says "estimation이 부정확해" → Agent: "Spec Gap. FR-004/SC-003 영향. --start specify 권장. 진행할까요?"

---

### Step 2 — Update the Origin Artifact

Update ONLY the artifact at the identified level:

| Level | Action |
|-------|--------|
| **spec** | Add/modify FR-### or SC-### in spec.md. Mark new items with `[added: post-specify]` tag |
| **plan** | Add/modify component, architecture decision, or Interaction Chain in plan.md. Mark with `[added: post-plan]` tag |
| **tasks** | Add/modify task in tasks.md. Mark with `[added: post-tasks]` tag |
| **code** | Apply Bug Fix Severity Rule (verify-phases.md). Minor = inline fix. Major = route back to correct level |

### Step 3 — Cascade Downstream (Incremental)

After updating the origin artifact, cascade **only the change** downstream — do NOT re-run the entire step:

```
spec.md changed (new FR-008 added):
  → plan.md: Add component/architecture to support FR-008 ONLY
     (do NOT regenerate entire plan — append to existing)
  → tasks.md: Add implementation tasks for FR-008 ONLY
     (do NOT regenerate entire tasks — append to existing)
  → If already in implement: Add new tasks to task queue
  → If already in verify: Add new SC to verification matrix

plan.md changed (new component added):
  → tasks.md: Add tasks for new component ONLY
  → spec.md: Check if new component implies a missing FR
     (if yes → add FR first, then cascade again)

tasks.md changed (new task added):
  → No upstream change needed (tasks don't drive spec/plan)
  → If in implement: Add to task queue
```

### Step 4 — Record the Change

Append to sdd-state.md Feature Detail Log:

```
📝 POST-SPECIFY UPDATE: FR-008 "citation rendering" added during [plan/implement/verify]
   Origin: user feedback at [step] Review
   Cascade: → plan.md (CitationBlock added) → tasks.md (T012 added)
```

This creates an audit trail of post-specify changes.

---

## Trigger: User Directly Edits Artifact Files

When the user modifies spec.md, plan.md, or tasks.md directly (e.g., in their editor):

### Detection

At each HARD STOP, before displaying Review content:

1. **Check file timestamps**: Compare spec.md, plan.md, tasks.md modification times against last known state
2. **If changed**: Read the diff and display:
   ```
   📝 Artifact change detected:
     spec.md: 2 lines added (FR-008, SC-008)

   Cascade needed:
     → plan.md: Add architecture for FR-008
     → tasks.md: Add implementation tasks for FR-008

   Proceed with cascading update?
   ```
3. **HARD STOP**: User confirms cascade or provides additional context

### Cascade Rules (same as Step 3 above)

The cascade is identical whether the change came from user feedback or direct file editing.

---

## Incremental Update Format

When cascading, use **append sections** marked clearly:

### spec.md incremental addition:
```markdown
## Post-Specify Additions

> Added during [plan/implement/verify] based on [user feedback / source comparison / verify finding]

### FR-008: Citation rendering in chat responses
Each KB search result renders as a numbered badge [N] inline in the AI response.
Clicking the badge shows a tooltip with source file name and content preview.

### SC-008: Citation click shows correct source
User clicks citation badge [2] → tooltip displays source #2's file name and matched text.
```

### plan.md incremental addition:
```markdown
## Post-Plan Additions

### CitationBlock Component (added for FR-008)
- Renders inline [N] badges from KB search results
- Tooltip on click with source preview
- Uses refNumber-based lookup (not array index)
```

### tasks.md incremental addition:
```markdown
## Post-Tasks Additions

### T012: Implement CitationBlock component (FR-008)
- Create CitationBlock.tsx with refNumber-based lookup
- Integrate into MessageContent renderer
- Add citation data to AI prompt injection
```

---

## Anti-Patterns

```
❌ WRONG: User says "citation doesn't work" → agent modifies code directly
   → spec has no FR for citation → verify will find the same issue again

❌ WRONG: User says "add citation" during implement → agent adds code without spec
   → No SC exists → verify cannot evaluate → "implemented but unverifiable"

❌ WRONG: User edits spec.md → agent ignores → continues with old plan
   → plan/tasks/code diverge from spec → accumulated drift

✅ RIGHT: User says "citation doesn't work" →
   Step 1: "This is a spec-level issue (no FR for citation)"
   Step 2: Add FR-008, SC-008 to spec.md
   Step 3: Cascade → plan (CitationBlock) → tasks (T012)
   Step 4: Implement T012 → verify SC-008
```

---

## Cross-Feature Impact Analysis Protocol

> **When to execute**: When a spec-level or plan-level change affects entities/APIs that OTHER Features reference. Triggered by:
> - Step-back to `specify` or `plan` (pipeline.md § Step-Back Protocol)
> - `reset --from specify` or `reset --from plan` (reset.md § Mode B)
> - Cascading update that modifies entity fields or API signatures

### Step 1 — Identify Owned Public Surfaces

Read `entity-registry.md` and `api-registry.md`:
- **Entities**: rows where `Owner Feature` = current FID → extract field list (this is the "before" snapshot)
- **APIs**: rows where `Provider Feature` = current FID → extract endpoint signatures
- If FID owns NO entities and provides NO APIs → **skip impact analysis** (no public surface)

### Step 2 — Identify Consumers

From entity-registry.md: `Referencing Features` column for each owned entity.
From api-registry.md: `Consumer Features` column for each provided API.
From roadmap.md: Dependency Table entries where `Depends On` includes current FID.

Deduplicate all downstream FIDs. If none → **skip** (no consumers).

### Step 3 — Diff Classification (after spec/plan change completes)

Compare the changed artifact against the "before" snapshot from Step 1:

| Change Type | Classification | Examples |
|-------------|---------------|---------|
| Field removed or renamed | 🔴 BREAKING | `User.email` removed, `Order.status` renamed to `state` |
| Field type changed | 🔴 BREAKING | `User.age: String → Number` |
| Required field added | 🔴 BREAKING | New required `User.phone` (existing consumers don't send it) |
| API endpoint removed/changed | 🔴 BREAKING | `POST /auth/register` removed or path changed |
| Required request param added | 🔴 BREAKING | New required `phone` param on existing API |
| Optional field added | 🟡 ADDITIVE | New `User.avatar_url` (nullable, backward-compatible) |
| New API endpoint added | 🟡 ADDITIVE | New `GET /auth/profile` (consumers don't need to call it) |
| Optional request param added | 🟡 ADDITIVE | New optional `limit` param |
| Internal logic changed | 🟢 INTERNAL | Rate limiting logic, validation rules, implementation details |

### Step 4 — Impact Report (HARD STOP)

Display classified impact to user:

```
📋 Cross-Feature Impact Analysis for [FID]-[name]:

── 🔴 BREAKING Changes ────────────────────────
  Entity [User]: field [email] type changed String → Email
    → F002-product (references User.email for display)
    → F003-order (references User.email for receipts)

  API [POST /api/auth/register]: new required field [phone]
    → F004-profile (calls POST /api/auth/register)

── 🟡 ADDITIVE Changes ────────────────────────
  Entity [User]: new optional field [avatar_url]
    → F002-product, F005-social (backward compatible)

── 🟢 INTERNAL Changes ────────────────────────
  API [POST /api/auth/register]: rate limiting logic changed
    → No downstream impact

── Summary ─────────────────────────────────────
  🔴 BREAKING: 2 changes → 3 Features affected (F002, F003, F004)
  🟡 ADDITIVE: 1 change → 2 Features notified (F002, F005)
  🟢 INTERNAL: 1 change → 0 Features affected
```

**Use AskUserQuestion** (HARD STOP):
- "Auto-mark BREAKING-affected Features for re-run from plan" → marks F002/F003/F004 plan step as 🔀
- "Auto-mark ALL affected Features for re-run" → includes ADDITIVE-affected too
- "Select which Features to re-run" → interactive selection
- "Proceed without marking (I'll handle downstream manually)"
**If response is empty → re-ask** (per MANDATORY RULE 1)

### Step 5 — Record Impact Analysis

Record in sdd-state.md Feature Detail Log under the current Feature:

```
📋 IMPACT ANALYSIS: [date] — [trigger: step-back / reset / cascading-update]
   🔴 BREAKING: [change details] → [FID2] 🔀plan, [FID3] 🔀plan
   🟡 ADDITIVE: [change details] → [FID4] (no action)
   🟢 INTERNAL: [change details]
   User action: [selected option]
```

Also record in `history.md` for audit trail.

### Step 6 — Execute Downstream Marking

Based on user selection, for each selected downstream Feature:
- 🔴 BREAKING → mark from `plan` onward as 🔀 (plan needs to update data-model/contracts)
- 🟡 ADDITIVE → mark from `implement` onward as 🔀 (plan structure is fine, just needs new code)
- Set downstream Feature status to `restructured`
- Update entity-registry.md and api-registry.md with new field/endpoint definitions

```
❌ WRONG: Reset F005's spec → blindly mark ALL downstream as 🔀 from specify
   → F002 (only reads User.avatar_url, an ADDITIVE change) gets full re-spec unnecessarily

✅ RIGHT: Reset F005's spec → classify changes → F002 marked 🔀 from implement only (ADDITIVE),
   F003 marked 🔀 from plan (BREAKING — field type changed)
```

---

## Context Optimization Note

This file is ~150 lines. It should be read:
- **Once** when the user first provides feedback or edits an artifact
- **NOT** at every HARD STOP (only when a change is detected)
- pipeline.md contains a brief reference to trigger reading this file

The agent does NOT need to re-read this file for every step — just when the cascading protocol is needed.

---

## Consumers

| Trigger Point | How Referenced |
|--------------|---------------|
| Any HARD STOP where user requests changes | pipeline.md § Cascading Update Reference |
| Any HARD STOP where artifact file timestamp changed | pipeline.md § Artifact Change Detection |
| verify Bug Fix Severity = Major-Spec or Major-Plan | verify-phases.md § Bug Fix Severity Rule |
| Step-back to specify or plan | pipeline.md § Step-Back Protocol → § Cross-Feature Impact Analysis |
| reset --from specify or --from plan | reset.md § Mode B Step B-4e |
