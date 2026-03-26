# Add Command — Feature Briefing

> Reference: Read after `/smart-sdd add` is invoked. For shared rules, see SKILL.md.

## Add Command — Feature Briefing

Running `/smart-sdd add` defines new Feature(s) through a **6-Phase Briefing process** — a structured Feature intake that validates completeness across key dimensions before spec generation. This is the core implementation of the **Brief** concept (see README § Three Core Concepts). The output is a normalized, quality-checked Feature definition that feeds into the spec-kit pipeline.

This is the **universal Feature definition path** for all project modes:

- **Greenfield**: After `/smart-sdd init` sets up the project, use `add` to define Features
- **Incremental**: Add new Features to an existing smart-sdd project
- **Rebuild/Adoption**: Add Features beyond the original source scope

**Prerequisite**: `roadmap.md`, `entity-registry.md`, `api-registry.md`, and `sdd-state.md` must already exist at BASE_PATH.

### Input Sources

- **`--prd path/to/prd.md`**: Reads the PRD/requirements document and extracts Feature candidates (triggers Phase 1 Type 1). Each `add` invocation can reference a different PRD.
- **`--from-explore path/to/specs/explore/`**: Reads code-explore synthesis and trace artifacts to seed Feature candidates with pre-validated understanding (triggers Phase 1 Type 4 — Explore-Driven). See § Phase 1 Type 4 below.
- **`--gap`**: Starts in gap-driven mode — analyzes unmapped SBI behaviors and parity gaps to auto-propose Feature candidates (triggers Phase 1 Type 3). Only meaningful for rebuild/adoption projects with SBI data.
- **`--to F00N`**: Augment an existing Feature instead of creating a new one (triggers Phase 1 Type 5 — Augment). See § Phase 1 Type 5 below.
- **Conversational input** (default): Gathers Feature information through interactive Q&A (Phase 1 Type 2). Auto gap detection may suggest switching to Type 3 if unmapped behaviors are found.
- **Chained from init**: When init chains into add, the same `--prd` path is automatically passed if it was provided to init

---

## 6-Phase Briefing Overview

```
Phase 1: Briefing             — Adaptive consultation + completeness validation + intent verification (HARD STOP)
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

## Pre-Check: Pending Feature Review (Conditional)

> Runs ONCE before Phase 1, only when both completed AND pending Features exist.

When a project has partially implemented Features from reverse-spec (some completed, some still pending), the user may want to clean up stale pending Features before defining new ones.

### Trigger Conditions

1. Read `sdd-state.md` Feature Progress table
2. Count Features by status:
   - At least 1 Feature with status `completed` or `adopted`
   - At least 1 Feature with status `pending`
3. If BOTH conditions met → show review prompt
4. Otherwise → skip silently (no message)

### Review Prompt (HARD STOP)

```
📋 Pending Feature Review

You have [N] pending (unimplemented) Features from the original plan:

  F003-cart         | pending | Tier 1
  F005-reporting    | pending | Tier 2
  F007-admin-panel  | pending | Tier 3

Would you like to review these before adding new Features?
```

**HARD STOP** via AskUserQuestion:
- **"Keep all — proceed to add"** → Skip cleanup, continue to Phase 1
- **"Review and clean up"** → Enter cleanup flow (see below)

**If response is empty → re-ask** (per MANDATORY RULE 1).

### Cleanup Flow

If the user selects "Review and clean up":

1. Present each pending Feature with details (description, dependencies, SBI count)
2. Ask via AskUserQuestion (multiSelect): "Which Features would you like to remove?" **If response is empty → re-ask** (per MANDATORY RULE 1).
3. For each selected Feature, clean up:
   - **`roadmap.md`**: Remove from Feature Catalog, Dependency Graph, Release Groups, Demo Groups
   - **`sdd-state.md`**: Remove from Feature Progress, Feature Mapping, Demo Group Progress
   - **`pre-context.md`**: Delete `specs/F00N-name/pre-context.md`
   - **`entity-registry.md`**: Remove entity ownership entries (keep entities if referenced by other Features)
   - **`api-registry.md`**: Remove API entries owned by this Feature
   - **SBI Coverage**: Unlink SBI entries (set status back to `unmapped`, clear Feature column)
4. Record removed Features in `specs/history.md`:
   ```
   ## [YYYY-MM-DD] /smart-sdd add — Pending Feature Cleanup
   | Removed | Reason |
   |---------|--------|
   | F005-reporting | User chose to remove before adding new Features |
   ```
5. Display summary:
   ```
   ✅ Removed [N] pending Feature(s): F005-reporting, F007-admin-panel
      Updated: roadmap.md, sdd-state.md, entity-registry.md, api-registry.md
      SBI entries unlinked: [N] behaviors returned to unmapped status
   ```
6. Proceed to Phase 1

**Important**: Only Features with status `pending` can be removed via this flow. Features that are `in_progress`, `completed`, or `adopted` are NOT eligible. For those, use `/smart-sdd reset --delete [FID]` (see `commands/reset.md` Mode C).

---

## Phase 1: Briefing (Adaptive Consultation)

> The **Briefing** phase — structured Feature intake that validates completeness and intent accuracy before proceeding.
> Elaboration continues until Brief completion criteria are met, then a HARD STOP confirms the agent's understanding matches the user's intent.
> Uses [feature-elaboration-framework.md](../reference/feature-elaboration-framework.md) for the six-perspective quality evaluation.
> Uses `domains/_core.md` § S5 + active interface/concern modules § S5 for domain-specific elaboration probes.
> Uses active module § S9 / § A5 for domain-specific **Brief Completion Criteria** (see `domains/_schema.md`).

### 1a. Entry Detection + Auto Gap Suggestion

Determine entry type from the user's input and arguments:

| Type | Trigger | Approach |
|------|---------|----------|
| **Type 1: Document-based** | `--prd` provided, positional arg is a file path, or user pastes structured document | Parse document → extract Feature candidates → confirm with user |
| **Type 2: Conversational** | Default (no `--prd`, no `--gap`, no file path) | Gather Feature intent through interactive Q&A, gradually elaborating |
| **Type 3: Gap-driven** | `--gap` flag, or auto-detected | Analyze SBI/parity gaps → auto-propose Feature candidates → user selects |
| **Type 5: Augment** | `--to F00N` provided | Read existing Feature → append new requirements → re-specify with SC preservation |

**Positional input auto-detection**: Positional arguments after `add` can be mixed freely — files and text in any combination:
- If an argument ends with `.md`, `.txt`, `.yaml`, `.yml`, `.json`, or `.pdf` AND the file exists on disk → treat as document input (Type 1)
- If an argument is a quoted string or does not match a file on disk → treat as idea/text input (Type 2)
- Multiple files + text can be combined: `add requirements.md design.yaml "add user auth"` → all files are parsed for Feature candidates, text is used as supplementary context
- When both files and text are provided: merge all extracted Feature candidates, use text as additional intent signal for prioritization

**Auto gap detection** (when no `--gap` but project might have gaps):
- Read `sdd-state.md` for Origin (`rebuild` or `adoption`)
- Run `scripts/sbi-coverage.sh <project-root>` to check unmapped behaviors
- **Count only `unmapped` status** — exclude `in_progress` behaviors already assigned to pending Features
- If unmapped P1/P2 behaviors exist AND no `--prd` provided:
  → Ask via AskUserQuestion: "Found N unmapped source behaviors. How would you like to proceed?"
  - "Show me the gaps (Recommended)" → Switch to Type 3
  - "I have a specific Feature in mind" → Continue as Type 2
- **If response is empty → re-ask** (per MANDATORY RULE 1)
- For greenfield projects (no SBI): skip detection, default to Type 2

### 1b. Initial Information Gathering (per type)

#### Type 1 — Document-based

#### Type 1 Step 1a: Document Parsing Protocol

1. Read the file at the document path. Accepts any requirements/design/planning document — not limited to PRDs. Detect format:
   - Markdown (.md): parse by headings — each H2/H3 = potential Feature boundary
   - Plain text (.txt): segment by blank-line-separated paragraphs
   - YAML/YML (.yaml, .yml): parse top-level keys as Feature candidates, nested keys as sub-features
   - JSON (.json): parse top-level object keys as Feature candidates
   - PDF (.pdf): extract text content, then apply heading/paragraph segmentation
   - Other: ask user to paste key sections as text
2. For each identified section/Feature boundary:
   - Extract: name (from heading or first sentence), description (body text),
     capability bullets, entity mentions (nouns), API hints (verbs + endpoints), dependency hints
   - Assign candidate ID: C001, C002, etc.
3. If fewer than 2 Features identified:
   → AskUserQuestion: "Only [N] Feature(s) extracted. Options:"
     - "Add more Features manually"
     - "Proceed with [N] Feature(s)"
     - "Provide a different document"
   **If response is empty → re-ask** (per MANDATORY RULE 1)
4. Entity/API hints from document → pre-populate Perspective 3/4 during elaboration

1. Read the PRD/requirements document at the `--prd` path
2. Extract Feature candidates: name, description, capabilities, expected entities, API hints, dependencies
3. Present extracted candidates for user confirmation/adjustment:
   ```
   📋 Extracted from PRD: [filename]

   Candidate 1: [Feature Name]
     Description: [1-2 sentences]
     Capabilities: [bullet list]
     Entity hints: [entity names mentioned]
     API hints: [endpoint hints]

   Candidate 2: [if multiple]
   ...

   Please confirm, modify, or add to these candidates.
   ```
4. Apply user adjustments → proceed to Elaboration (1c)

#### Type 2 — Conversational

1. Ask the user to describe the Feature they want to add
2. Listen for information across the six perspectives (see 1c) — purpose, capabilities, data, interfaces
3. Iterate naturally: the user may provide a vague idea or specific requirements. Adapt:
   - **Vague** ("I want notifications"): Ask clarifying questions to shape the Feature
   - **Specific** ("push + email notifications with user preferences"): Organize into structured candidate
4. When enough initial context is gathered → proceed to Elaboration (1c)

#### Type 3 — Gap-driven

1. Run `scripts/sbi-coverage.sh <project-root>` for full coverage view
2. If `parity-report.md` exists at BASE_PATH: read gap areas for additional context
3. If `coverage-baseline.md` exists at BASE_PATH: read Unmapped Items tables and collect all `cross-cutting` classified entries (files, endpoints, entities). These are **promotion candidates** — items previously deferred as shared infrastructure that may now warrant their own Feature.
4. **Filter to `unmapped` status only**: Exclude `in_progress` behaviors (already assigned to pending Features). Only truly unmapped behaviors are gap candidates.

#### Type 3 Step 3a: Gap Clustering Algorithm

After filtering to unmapped-only behaviors (Step 4 above):

1. **Source file proximity**: Group behaviors whose source files share a common parent directory (depth ≤ 2)
2. **Entity co-reference**: Merge groups that reference the same entities (detected from function parameters and return types)
3. **Naming pattern**: Merge groups whose function names share a common prefix (e.g., `handlePayment*`, `processOrder*`)
4. **Minimum cluster size**: Clusters with <3 behaviors are merged into the nearest larger cluster by directory proximity
5. **Name each cluster**: Use the dominant entity name or directory name as the Feature candidate name (C### ID assigned sequentially)
6. **Cross-cutting detection**: If a behavior appears in 3+ clusters, classify as cross-cutting utility — NOT a Feature candidate, but noted in elaboration context

This is a **heuristic algorithm** — results are presented to the user for confirmation/adjustment at the Type 3 HARD STOP.

5. Cluster unmapped behaviors + cross-cutting items by domain/function (using behavior descriptions and source file proximity)
6. Auto-propose Feature candidates from clusters:
   ```
   📋 Gap Analysis — Unmapped Source Behaviors

   ── Cluster 1: Notification System ──────────────
     B023 | P2 | sendEmail() — Send email via SMTP
     B024 | P2 | formatNotification() — Template rendering
     → Suggested Feature: F009-notifications (2 behaviors)

   ── Cluster 2: Build Infrastructure (from cross-cutting) ──
     [cross-cutting] scripts/build.sh — Build orchestration
     [cross-cutting] scripts/i18n-extract.sh — i18n extraction
     [cross-cutting] scripts/release.sh — Release automation
     → Suggested Feature: F010-build-infra (3 cross-cutting items)

   ── Unclustered ─────────────────────────────────
     B045 | P3 | cleanupTempFiles() — Temp file cleanup
     → Could be: standalone Feature or part of existing Feature

   Select, modify, or reject these proposals.
   ```
7. User selects/modifies/rejects proposals
8. Proceed to Elaboration (1c)

**Type 3 → Phase 4 optimization**: Features built from SBI entries arrive at Phase 4 **pre-mapped**. Phase 4 confirms the mapping and allows expansion (NEW B### entries) only — no re-selection needed.

**Cross-cutting → Feature promotion**: When a cluster contains cross-cutting items and the user approves the Feature, Phase 6 (Finalization) updates `coverage-baseline.md` — changing the Classification of promoted items from `cross-cutting` to `assigned:F00N` with the new Feature ID. This ensures the coverage baseline stays in sync.

#### Type 4 — Explore-Driven (`--from-explore`)

> Triggered when `--from-explore <path>` is provided. Seeds Feature candidates from code-explore synthesis — the user has already studied the source and documented their understanding.

#### Type 4 Step 1a: Synthesis Parsing Protocol (🚫 BLOCKING)

1. Verify `{explore-path}/synthesis.md` exists. If missing:
   → 🚫 BLOCKING: "synthesis.md not found at `{explore-path}`. Run `/code-explore synthesis` first."
2. Parse `## Feature Candidates` table:
   - For each row: extract C### ID, Name, Based On (trace refs), Key Modules, Owned Entities, APIs, Traces
   - If table is empty or section missing:
     → 🚫 BLOCKING: "No Feature candidates in synthesis.md. Run `/code-explore synthesis` to generate candidates, or use Type 2 (interactive) instead."
3. Parse `## Consolidated Entity Map` → pre-populate entity ownership per candidate (Perspective 3 seed)
4. Parse `## Consolidated API Map` → pre-populate API mapping per candidate (Perspective 4 seed)
5. Parse `## Accumulated Insights`:
   - 💡 Patterns to Adopt → seed Perspective 5 (Quality Attributes)
   - 🔧 Design Improvements → seed Perspective 6 (Boundaries & Dependencies)
   - ❓ Unresolved Questions → auto-generate elaboration questions for Brief
6. For each candidate, read referenced traces (`{explore-path}/traces/{NNN}-{slug}.md`):
   - Extract Observations sections → per-candidate elaboration context
   - Extract Business Rules → seed domain logic understanding

❌ WRONG: Accept --from-explore but present empty Brief → user must re-enter all explore findings manually
✅ RIGHT: Parse synthesis → pre-populate Brief with explore-sourced perspectives → user refines, not re-creates

1. **Read explore artifacts**:
   - Read `{path}/synthesis.md` — extract Feature Candidates table, Entity/API Consolidation, Business Rule Consolidation, and Accumulated Insights
   - Read `{path}/orientation.md` — extract tech stack, module map, and exploration coverage
   - Read all `{path}/traces/*.md` — extract Observations sections for elaboration context
2. **Convert C-IDs to Feature candidates**:
   - Each row in synthesis § Feature Candidates → one Feature candidate
   - Map fields: `C###` ID → display only (will become F### after confirmation), `Name` → Feature name, `Description` → Feature description, `Differentiation` → user's planned changes (critical elaboration context), `Source Traces` → reference links
3. **Pre-populate elaboration context from explore artifacts**:
   - Entity Consolidation → Perspective 3 (Data) pre-filled with known entities and fields
   - API Consolidation → Perspective 4 (Interfaces) pre-filled with known APIs and contracts
   - Business Rules → Perspective 5 (Quality) pre-filled with rules to preserve or modify
   - Observations (💡 adopt / ❓ improve / ⚠️ fix) → Perspective 6 (Boundaries) pre-filled with design decisions
   - Dependency Graph (from synthesis) → Phase 3 Tier/ordering input
4. **Display explore-sourced candidates** (HARD STOP):
   ```
   📋 Explore-Driven Feature Candidates (from code-explore synthesis)

   Source: [orientation.md project name] ([coverage]% explored)
   Traces: [N] traces analyzed

   | # | Candidate | Description | Differentiation | Confidence |
   |---|-----------|-------------|-----------------|------------|
   | 1 | C001-context-engine | Token-aware context window... | Configurable weights, ... | High (2 traces) |
   | 2 | C002-tool-runtime | Tool dispatch and execution... | Docker sandboxing, ... | High (1 trace) |
   | ... | | | | |

   Pre-populated from explore:
     Entities: [N] observed across traces
     APIs: [M] interfaces documented
     Business Rules: [K] rules cataloged
     Design Decisions: [J] observations recorded
   ```
   AskUserQuestion:
   - **"Accept all candidates"** → proceed to Elaboration (1c) with pre-populated context
   - **"Select/modify candidates"** → user picks subset, renames, adjusts descriptions
   - **"Add more candidates"** → user adds Features not in synthesis (e.g., from unexplored modules)

   **If response is empty → re-ask** (per MANDATORY RULE 1).

5. **Proceed to Elaboration (1c)** with explore context:
   - Elaboration Framework perspectives are pre-populated but NOT auto-completed — the user must still confirm or expand each perspective
   - `Differentiation` column provides critical context: "the user wants to CHANGE this from the source" — elaboration should focus on the changes, not re-describe the source behavior
   - Observations with ❓ markers → auto-generate elaboration questions

**Type 4 → Phase 2 optimization**: Entity/API Consolidation from synthesis is compared against existing registries. Overlaps are flagged with source evidence from traces.

**Type 4 → Phase 4**: No SBI mapping needed — explore traces serve as the user's source understanding. Phase 4 is skipped for explore-sourced Features.

**Type 4 → Phase 6 enhancement**: When generating pre-context.md, include explore trace references in the "For /speckit.specify" section so the specify step can reference the user's documented understanding of the source.

### 1c. Elaboration (COMMON — all types converge here)

After initial gathering, evaluate the Feature definition against the **Feature Elaboration Framework**:

1. **Load framework**: Read `reference/feature-elaboration-framework.md` for the six base perspectives
2. **Load domain probes**: Read `domains/_core.md` § S5 + active interface/concern modules § S5 for domain-specific probes (aggregate all)
3. **Assess coverage**: Score each perspective for the current definition:
   - **Covered**: Sufficient information to proceed
   - **Partial**: Some info, but key gaps remain
   - **Missing**: No information provided
4. **Elaborate gaps**: Ask targeted questions for REQUIRED perspectives (1–4) with partial/missing coverage. Merge domain-specific probes into the relevant base perspectives.
5. **Acknowledge optional**: For perspectives 5–6, record "TBD" if not discussed

**Strategy**:
- Batch 2–3 related questions — don't overwhelm the user
- Use what you already have — if a document was provided, extract maximum info before asking
- **Type 1**: Document likely covers Perspectives 1–4 well; focus on confirming + filling 5–6
- **Type 2**: Start with Perspective 1 (who/why), build incrementally
- **Type 3**: SBI behaviors provide Perspectives 2–3 automatically; focus on 1 (user scenarios) and 4 (interfaces)

**Completion criteria**:
1. **Base**: Perspectives 1–4 each have at least basic coverage (see framework's Completion Criteria table)
2. **Domain-specific**: All active module § S9 Brief Completion Criteria items are satisfied
3. **Archetype-specific**: All active archetype § A5 Brief Completion Criteria items are satisfied

If domain criteria are not met but base perspectives are covered, ask targeted questions using the module's S5 probes for the missing S9/A5 elements.

**Elaboration Quality Guard**:
- If a user gives a vague answer twice for the same perspective (e.g., "it just handles data" for Perspective 3), display an explicit warning:
  ```
  ⚠️ Perspective 3 (Data) is still unclear after two attempts.
     Without clear entity ownership, specify may produce incorrect FR/SC.
     Please provide at least: what data this Feature creates/owns.
  ```
- If after 3 attempts the answer is still vague, record as `⚠️ VAGUE — [perspective]` in the draft and proceed — but flag it in the Brief Summary (Phase 1e) so the user is aware this area may cause issues downstream.
- For S9/A5 criteria: if a required element cannot be determined, record as `⚠️ UNDETERMINED — [element]` and include in Brief Summary.

**Do NOT propose Feature structure yet** — just ensure the definition is rich enough to scope in Phase 3.


### 1c-post. Domain Profile Instance Update

After Elaboration completes and S5/A3 probe answers are gathered, persist the decisions to the Domain Profile Instance file:

1. **Read or create**: Read `BASE_PATH/domain-profile-instance.md`. If the file does not exist, create it from `smart-sdd/templates/domain-profile-instance-template.md` and populate the Project-Level Profile section from `sdd-state.md` header fields (Interfaces, Concerns, Archetype, Foundation, Context Mode/Scale/Modifiers).

2. **Record S5 answers**: For each S5 probe answer gathered during Elaboration (1c), append a row to the Per-Concern Decisions table under the matching `### [concern-name]` subsection. If the concern subsection does not exist yet, create it from the template pattern.

   | Probe (S5) | Decision | Decided At | Feature |
   |------------|----------|------------|---------|
   | [the S5 probe question] | [user's answer] | [ISO timestamp] | [current FID] |

3. **Record A3 answers** (if Archetype is active): Same process for the Per-Archetype Decisions table.

4. **Feature 2+ — Display inherited constraints**: If this is NOT the first Feature (i.e., Per-Feature Domain Summary already has entries), display a summary of preceding Features' key decisions that may constrain this Feature:

   ```
   📋 Inherited Domain Constraints (from domain-profile-instance.md)

   F001-auth:
     - auth concern: JWT with refresh tokens, session-based for GUI
     - async-state concern: Zustand for client state, React Query for server state

   These prior decisions may constrain the current Feature's design choices.
   ```

   This display is informational only — it does NOT require a HARD STOP. The user sees it as part of the Elaboration flow.

### 1d. Create Draft

Create `specs/add-draft.md` with the gathered information:

```markdown
# Add Draft — [Date]

Source: [PRD path / conversational / gap-analysis]
Entry type: [Type 1 / Type 2 / Type 3]

## Phase 1: Feature Candidates

### Candidate 1: [Feature Name]
- **Description**: [1-2 sentence description]
- **User & Purpose**: [actors, problem, key scenarios]
- **Capabilities**: [bullet list of concrete capabilities]
- **Data**: [owned entities, referenced entities, key attributes]
- **Interfaces**: [APIs provided/consumed, UI touchpoints, integrations]
- **Quality notes**: [performance, security concerns — or "TBD"]
- **Boundaries**: [exclusions, assumptions, constraints — or "TBD"]
- **SBI pre-mapping**: [B### IDs if Type 3, or "N/A"]
- **Estimated dependencies**: [Feature IDs]

### Candidate 2: [if multiple]
...

## Status: Phase 1 complete
```

### 1e. Brief Confirmation (HARD STOP)

Before proceeding to Phase 2, present the Brief Summary for user approval. This is the **intent verification gate** — ensuring the agent's understanding matches the user's actual intent.

Display the Brief Summary extracted from the draft:

```
📋 Brief Summary — [Feature Name]

  Description: [1-2 sentence description as understood by agent]

  User & Purpose:
    Actor(s): [identified actors]
    Problem:  [core problem as understood]
    Scenario: [key scenario]

  Capabilities:
    - [capability 1]
    - [capability 2]
    - ...

  Data:
    Owned:      [entities this Feature owns]
    Referenced: [entities from other Features]

  Interfaces:
    APIs:       [provided/consumed]
    UI:         [touchpoints — or "N/A"]
    External:   [integrations — or "none"]

  Quality: [key NFRs — or "TBD"]
  Boundaries: [exclusions/constraints — or "TBD"]

  ── Domain-Specific ──────────────────────────
  [S9/A5 criteria status — which items were satisfied and how]
```

**HARD STOP** — Use AskUserQuestion with options:
- **"Approve Brief — this is accurate"** → Proceed to Phase 2
- **"Correct misunderstandings"** → Agent asks what was misunderstood, adjusts the draft, and re-displays Brief Summary for re-approval
- **"Add more detail"** → Return to Elaboration (1c) for additional questions

**If response is empty → re-ask** (per MANDATORY RULE 1).

**Why this gate matters**: Phase 1 gathers information, but the agent's *interpretation* of that information may differ from the user's *intent*. Without this confirmation, misunderstandings propagate through the entire pipeline — the user only sees them at specify Review, when correction is expensive. This gate catches interpretation errors early.

**Transition**: After approval, proceed to Phase 2.

### Existing Feature Extension

#### Type 5 — Augment Existing Feature (`--to F00N`)

> Triggered when `--to F00N` is provided. Augments an existing Feature's pre-context with additional requirements, then triggers re-specify with SC preservation.

#### Type 5 Flow

1. **Validate target Feature**: Read `sdd-state.md` → confirm `F00N` exists. If not found:
   → 🚫 BLOCKING: "Feature F00N not found in sdd-state.md."

2. **Read existing artifacts**:
   - Read `SPEC_PATH/F00N-name/pre-context.md` → current Feature definition
   - Read `SPEC_PATH/F00N-name/spec.md` (if exists) → current SCs to preserve
   - Read `SPEC_PATH/F00N-name/plan.md` (if exists) → current architecture decisions

3. **Gather augmentation input**: The remaining positional arguments (files and/or text) describe what to add:
   - Files → parsed as additional requirements (same as Type 1 Document Parsing Protocol)
   - Text → conversational elaboration of what to add
   - Both can be mixed: `add --to F001 oauth-spec.md "add social login"`

4. **Display current → augmented comparison** (HARD STOP):
   ```
   📋 Augmenting F001: User Authentication

   Current scope:
   - Email/password login
   - Session management
   - Password reset

   Additions:
   - OAuth2 social login (Google, GitHub)
   - Two-factor authentication (TOTP)

   Source: oauth-spec.md + "add social login"
   ```
   AskUserQuestion: "Confirm augmentation?"
   - "Approve augmentation (Recommended)" → proceed
   - "Modify additions" → re-gather
   - "Cancel" → abort
   **If response is empty → re-ask** (per MANDATORY RULE 1)

5. **Update pre-context**: Append new requirements to `SPEC_PATH/F00N-name/pre-context.md` under an `## Augmented Requirements` section with timestamp:
   ```markdown
   ## Augmented Requirements (YYYY-MM-DD)

   ### Additional Requirements
   {parsed additions}

   ### Source
   {file paths and/or text input}
   ```

6. **Set Feature status to "augmented"**:
   - Update `sdd-state.md` Feature Progress table: set Feature status to `augmented`
   - The `augmented` status signals to the pipeline that re-specification is needed with SC preservation
   - When `speckit-specify` runs next (via `pipeline F00N`), the injection file detects `augmented` status and activates SC Preservation (see `injection/specify.md` § SC Preservation on Re-specification):
     ```
     ⚠️ SC PRESERVATION: This is a re-specify after augmentation.
     Existing SCs in spec.md MUST be preserved unless explicitly contradicted
     by the new requirements. New SCs are ADDED, not replaced.
     Renumber if needed to maintain sequence.
     ```
   - Skip Phases 2-6 of the add flow (overlap check, scope negotiation, etc. are unnecessary for augmentation)

7. **Display next step**:
   ```
   ✅ F00N pre-context augmented. Run `pipeline F00N` to re-specify.
   ```

❌ WRONG: Create a new Feature F00M that overlaps with F00N → duplicate scope, confused pipeline
✅ RIGHT: Augment F00N's pre-context → re-specify preserves existing SCs + adds new ones

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

**HARD STOP** — Use AskUserQuestion with options: "Approve analysis", "Request modifications". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Phase 3: Scope Negotiation (HARD STOP)

> Based on complexity, propose single or multiple Features.

### 3a. Complexity Assessment

Evaluate the user's request against:
- Number of entities (owned + referenced)
- Number of API endpoints (provided + consumed)
- Number of distinct user scenarios
- Estimated FR/SC count

### 3b. Vertical Slice Check

Before proposing the Feature structure, check whether the candidate is a **complete vertical slice** or a **horizontal layer**:

1. Read the Phase 1 candidate's Capabilities (Perspective 2) and Interfaces (Perspective 4)
2. **Detect backend-only scope**: The candidate defines stores, services, factories, CRUD operations, or data management — but Perspective 4 lists no UI touchpoints (pages, modals, panels, settings views)
3. **Determine Feature type**:
   - **User-facing** (app with UI, desktop app, web app): UI completeness matters
   - **Infrastructure/Library/CLI-only**: UI not expected — skip this check silently

**If user-facing Feature AND no UI touchpoints listed**:

Display warning in the scope proposal (3c):
```
⚠️ Vertical Slice Check: This Feature defines [stores/services/CRUD operations]
   but has no UI components in scope. Users will have no way to interact with
   these capabilities through the application interface.

   Recommendation: Include a minimal UI (settings page, management panel, or
   config view) so this Feature is a complete vertical slice.
```

This warning is included in the Phase 3 proposal display. The user can choose to add minimal UI or proceed without it.

### 3c. Feature Proposal

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

### 3d. Tier Assignment (core scope only)

If the project uses `core` scope (read from `sdd-state.md`):
- Propose Tier classification for each new Feature
- Default: Tier 2 (added Features are typically enhancements)
- If the user describes it as critical: propose Tier 1
- **Foundation Features**: If Feature is auto-generated from Foundation category → Tier: T0
  - T0 Features are NOT subject to normal Scope filtering (always active)
  - T0 Features appear BEFORE T1 in roadmap Feature Catalog
  - Feature ID format for T0: F000-{category} (e.g., F000-window-management)

If `full` scope: skip Tier assignment (but T0 assignment still applies for Foundation Features).

**Overlap Check with Foundation awareness**:
- T0 Foundation Features do NOT overlap with each other (different categories)
- T1+ Features that touch Foundation items → flag dependency on T0 Feature
- If T0 Feature for that category doesn't exist → suggest creating it

### 3e. Feature ID Assignment

Assign the next available Feature ID(s) based on existing Features in roadmap.md:
- Read the highest existing F### ID
- Assign sequentially: F[max+1], F[max+2], ...

Update `specs/add-draft.md` with the confirmed Feature structure.

**HARD STOP** — Use AskUserQuestion with options:
- "Accept proposal"
- "Add minimal UI to scope" — (shown only when Vertical Slice Check warning was triggered) agent adds basic UI touchpoints (settings page, management panel, or config view) to the candidate's Perspective 4 Interfaces
- "Request modifications"

**If response is empty → re-ask** (per MANDATORY RULE 1).

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

**HARD STOP** — Use AskUserQuestion with options: "Accept SBI selection", "Modify selection". **If response is empty → re-ask** (per MANDATORY RULE 1).

If no unmapped behaviors match the filter AND no new behaviors: display "No SBI changes" and proceed to Phase 5.

---

## Phase 5: Demo Group Assignment (HARD STOP)

> **What is a Demo Group?** A set of Features that together demonstrate a meaningful user scenario. Examples: "User registers → browses → purchases" spans 3 Features. "Admin configures budget → User gets blocked at limit" spans 2 Features. Demo Groups are independent of Release Groups — they group Features by business value, not technical dependency.
>
> **When does the Integration Demo run?** When the LAST Feature in a Demo Group completes verify, a HARD STOP offers to run the Integration Demo. The demo executes the full user scenario end-to-end across all Features in the group.

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

**HARD STOP** — Use AskUserQuestion with options:
- **"Accept recommendation"** — Use the suggested group assignment
- **"Join [other group]"** — Join a different existing group (specify which)
- **"Create new Demo Group"** — Define a brand new demo group for this Feature
- **"No demo group"** — Infrastructure/cross-cutting Feature, no user-facing demo

**If response is empty → re-ask** (per MANDATORY RULE 1).

### 5c. New Demo Group Creation (if selected)

If the user selects "Create new Demo Group":

1. Ask for group details via AskUserQuestion. **If response is empty → re-ask** (per MANDATORY RULE 1):
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

1. **Create `specs/F00N-name/pre-context.md`** per new Feature:
   - Source Reference: `.` (current project) for incremental/adoption, or `N/A` if greenfield with no source
   - Source Behavior Inventory:
     - **If SBI entries selected in Phase 4**: Include selected entries (with B### IDs and Origin), plus generate FR draft entries for each mapped behavior
     - **If no SBI (greenfield)**: "N/A — no source to inventory"
   - Interaction Behavior Inventory:
     - **If rebuild/adoption with micro-interactions.md**: Filter interactions to this Feature's screens/components, include in pre-context
     - **If greenfield/add**: "N/A — define during specify" (specify injection will prompt user to define interactions)
   - For /speckit.specify:
     - **With SBI mapping**: Feature description + dependency summary + FR drafts derived from SBI behaviors
     - **Without SBI**: Feature description + dependency summary only (no FR/SC drafts)
   - For /speckit.plan: Dependencies with entity/API info from existing registries
   - For /speckit.analyze: Dependency-based cross-Feature verification points
   - **Cross-Feature Awareness (greenfield/add)**: Even without source code, populate the following from the roadmap and registries:
     - **Sibling Feature Summary**: For each Feature defined in the same batch or already in roadmap, include: FID, name, description (1-line), owned entities (if any in registry), APIs provided (if any in registry). This gives each Feature visibility into the broader project context.
     - **Dependency Context**: For each dependency edge involving this Feature (from roadmap Dependency Graph), include: direction (blocked-by / enables), related FID, and the nature of the dependency (entity, API, UI component).
     - **Registry Snapshot**: If `entity-registry.md` or `api-registry.md` has entries from previously completed Features, include a summary (entity names + owner FIDs, API names + provider FIDs) so the new Feature's specify/plan can reference existing definitions rather than redefine from scratch.

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
  Created: specs/F009-notifications/pre-context.md
  Updated: roadmap.md (Feature Catalog, Dependency Graph, Demo Groups)
  Updated: sdd-state.md (Feature Progress, SBI Coverage, Demo Group Progress)
  Deleted: specs/add-draft.md
──────────────────────────────────────────────────
```

**HARD STOP** — Use AskUserQuestion with options:
- **"Run pipeline now"** (Recommended) → Finalize artifacts, then auto-chain to `pipeline.md` for the newly defined Feature(s). The user does NOT need to type a separate `/smart-sdd pipeline` command. Pipeline runs specify → plan → tasks → implement → verify → merge for each new Feature.
- **"Add another Feature first"** → Finalize current Feature, then loop back to Phase 1 for the next Feature. After the last Feature is defined, offer "Run pipeline now" again.
- **"Define only — I'll run pipeline later"** → Finalize artifacts and stop. User runs `/smart-sdd pipeline` manually later.
- **"Request modifications"** → Loop back to the relevant Phase (user indicates which aspect to change).
**If response is empty → re-ask** (per MANDATORY RULE 1).

If "Run pipeline now": proceed directly to `pipeline.md` execution for the newly added Feature(s). This is the default recommended flow — `add` defines WHAT to build, `pipeline` builds it.
If "Add another Feature first": repeat Phases 1-6 for the next Feature, then present the same options again.

---

## Edge Cases

### Multiple Features Added at Once

If Phase 3 proposes multiple Features:
- Phases 4-5 are repeated per Feature
- Phase 6 creates all artifacts in one batch
- Dependencies between new Features are also recorded

### Greenfield Projects (First Features)

- Phase 1 auto gap detection is skipped (no SBI data). `--gap` flag is ignored with a notice.
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
