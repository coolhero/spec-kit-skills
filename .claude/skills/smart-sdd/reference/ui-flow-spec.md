# UI Flow Specification Reference

> Defines the format, generation rules, and consumption protocol for UI Flow Specs.
> UI Flow Specs capture multi-step interaction sequences at a level of detail that
> implementation can follow mechanically and verification can check step-by-step.

---

## Why UI Flow Specs Exist

FR/SC are **functional requirements** — they define WHAT the system does.
UI Flow Specs define **HOW the user interacts** — the step-by-step sequence of actions,
responses, and state transitions that make the feature usable.

```
Gap without UI Flow Spec:
  FR: "User can create a Knowledge Base"
  SC: "KB appears in list after creation"
  → Agent improvises: single text input + submit button
  → Source app has: dialog with name, model dropdown, auto-dimensions, validation

With UI Flow Spec:
  Flow: Create Knowledge Base
  Step 1: Click [+ Create KB] → Dialog opens
  Step 2: Fill name → —
  Step 3: Select model from dropdown → Dimensions auto-fills
  Step 4: Click Create → Dialog closes, KB in list, toast
  Error: Empty name → validation, No model → button disabled
  → Agent follows spec exactly → matches source app
```

---

## Format

Each UI Flow Spec describes one user-facing interaction sequence. A Feature with complex UI
typically has 2-5 flows (e.g., KB: create, add files, search, manage, delete).

```markdown
## Flow: [Flow Name]

> Source: [source component files, if rebuild] or [FR-### reference]
> Trigger: [what initiates this flow — button click, navigation, keyboard shortcut]
> Result: [what the user sees when the flow completes successfully]

### Happy Path

| Step | User Action | UI Response | State Change |
|------|------------|-------------|-------------|
| 1 | [concrete action: click, type, select, drag] | [visible UI change] | [data/store change, if any] |
| 2 | ... | ... | ... |

### Error Paths

| Trigger | UI Response | Recovery |
|---------|-------------|----------|
| [error condition] | [what user sees] | [how to fix — retry, correct input, configure] |

### Preconditions
- [what must be true before this flow can start]
- [e.g., "API key configured for embedding provider"]
```

### Column Definitions

| Column | What to write | ❌ Too vague | ✅ Specific enough |
|--------|--------------|-------------|-------------------|
| **User Action** | Concrete interaction verb + target | "interact with form" | "Click [Create KB] button" |
| **UI Response** | Observable visual change | "UI updates" | "Dialog closes, new row appears in KB list" |
| **State Change** | Data mutation identifier | "data changes" | `knowledgeBases.push(newKB)` or "KB count: 0 → 1" |
| **Trigger** (error) | Specific condition | "invalid input" | "Name field empty when Create clicked" |
| **Recovery** | User-actionable fix | "fix the error" | "Enter a name and click Create again" |

---

## Generation Rules

### Rebuild Mode (source app exists)

1. **Read source components** for this Feature (from pre-context Source Reference)
2. **Trace the user interaction** through the source code:
   - Entry point (button/link/menu) → event handler → state mutation → UI update
   - Form fields: type (text/select/number), validation rules, default values
   - Conditional UI: what shows/hides based on state
   - Error handling: what happens on failure
3. **One flow per distinct user task** — if the source has "create KB", "add file to KB", "search KB", those are 3 separate flows
4. **Include source file references** for each step (so implement can read the exact code)

```
❌ WRONG: Read 1 component, write generic flow
✅ RIGHT: Read AddKnowledgeBasePopup.tsx + useKnowledgeStore.ts + EmbeddingModelSelector.tsx
          → trace: button click → dialog → form fields → model fetch → auto-dimensions → create API call
          → each step maps to a source code location
```

### Greenfield Mode (no source app)

1. **Derive from FR/SC** — each FR with user interaction gets a flow
2. **Ask during Brief** — if the FR mentions a form/dialog/wizard, the Brief process should ask "what fields?" "what validation?" "what happens on submit?"
3. **Domain Profile S9 rules** may add completeness criteria (e.g., gui module requires interaction details for forms)

### Adoption Mode

1. **Extract from running app** — if runtime exploration (Phase 1.5) captured the interaction, use it
2. **Read source code** — same as rebuild, but documenting existing behavior (not designing new)

---

## Where UI Flow Specs Live

```
specs/{NNN-feature}/
  ├── spec.md          ← FR/SC (functional requirements)
  ├── ui-flows.md      ← UI Flow Specs (interaction sequences) ← NEW
  ├── plan.md          ← Architecture + Interaction Chains
  └── tasks.md         ← Implementation tasks
```

`ui-flows.md` is generated during **specify** (after spec.md) and consumed by **plan**, **implement**, and **verify**.

---

## Pipeline Integration

### specify → ui-flows.md generation

After spec.md is generated and approved, for Features with GUI interactions:

1. Identify all FR-### that involve user interaction (forms, dialogs, navigation, CRUD)
2. For each interactive FR, generate a UI Flow Spec:
   - Rebuild: trace source components to fill Happy Path + Error Paths
   - Greenfield: derive from FR/SC description, ask user if ambiguous
3. Write to `specs/{NNN-feature}/ui-flows.md`
4. Display in Review for user approval

**Skip if**: Feature has no GUI interactions (pure API, CLI, background service)

### plan → Interaction Chains reference ui-flows.md

plan.md Interaction Chains should **reference** UI Flow Spec steps:

```markdown
| FR | User Action | Handler | ... | Flow Reference |
|----|-------------|---------|-----|---------------|
| FR-001 | Click Create KB | onCreateKB() | ... | ui-flows.md § Create KB, Step 4 |
```

This ensures plan architecture covers every step in the flow.

### implement → follow ui-flows.md step by step

When implementing a UI component for an FR that has a UI Flow Spec:
1. Read the corresponding flow from `ui-flows.md`
2. Implement each step's UI Response and State Change
3. Implement each Error Path
4. **After implementation**: walk through the flow mentally — does clicking step 1 lead to step 2's response?

```
❌ WRONG: Read FR "User can create KB" → improvise a form
✅ RIGHT: Read ui-flows.md § Create KB → implement exactly: dialog with name + model dropdown + auto-dimensions + validation
```

### verify → test each flow step

SC Verification Matrix scenarios should map to UI Flow Spec steps:

```
SC Verification Matrix:
| SC-001 | cdp-auto | Tier 2 | ui-flows.md § Create KB: steps 1-5 |
```

The test scenario IS the flow's Happy Path. Each step = one Playwright action + assertion.
Error Paths = additional test scenarios.

**Verification is tool-agnostic** — the flow steps define WHAT to verify:
- **Playwright/CDP**: `page.click('[data-testid="create-kb"]')` → `page.waitForSelector('.dialog')`
- **Cypress**: `cy.get('[data-testid="create-kb"]').click()` → `cy.get('.dialog').should('exist')`
- **Manual**: "Click Create KB button. Do you see a dialog? What fields are in it?"
- **curl/API**: Not applicable (UI flows are for GUI interfaces)

The flow spec is the **contract**; the verification tool is the **implementation**.

---

## Completeness Criteria

A UI Flow Spec is complete when:

| Criterion | Check |
|-----------|-------|
| **Every interactive FR has a flow** | Count FR-### with user actions → count flows. Gap = BLOCKING |
| **Every flow has ≥2 steps** | Single-step flows (click → done) indicate missing intermediate states |
| **Every form has field definitions** | Type, required/optional, validation, default value |
| **Error paths exist** | At least: empty required field, API failure, permission denied |
| **Preconditions are explicit** | What must be configured/available before the flow works |
| **Source references (rebuild)** | Each step links to source component file:line |

---

## Domain Profile Conditional Rules

| Interface | UI Flow Spec behavior |
|-----------|----------------------|
| `gui` | UI Flow Specs generated for all interactive FRs |
| `tui` | UI Flow Specs generated with terminal-specific actions (keystroke, menu select) |
| `cli` | Not generated — CLI has command/flag specs instead |
| `http-api` | Not generated — API has request/response specs instead |
| `data-io` | Not generated — data pipelines have stage specs instead |

| Concern | Additional flow requirements |
|---------|------------------------------|
| `auth` | Login/logout/session-expired flows must include auth state transitions |
| `i18n` | Flows must note which text is user-visible (= needs translation) |
| `realtime` | Flows must include connection state (connecting/connected/disconnected/reconnecting) |

---

## Anti-Patterns

```
❌ Flow with only Happy Path — no error paths
   → First user mistake = undefined behavior

❌ Flow step "User fills the form" — which fields? what types? what validation?
   → Agent improvises different fields every time

❌ Flow without preconditions — "API key must be configured" missing
   → Feature looks broken when key isn't set, no error message

❌ Rebuild flow that doesn't reference source files
   → Agent improvises instead of matching source pattern

❌ Flow that duplicates FR text verbatim
   → "User can create KB" is an FR, not a flow. Flow adds the HOW.
```
