## Phase 3 — Feature Classification and Importance Analysis

### 3-1. Feature Boundary Identification
Identify logical functional units (Features) based on the Phase 2 analysis results, using the boundary heuristics defined in `domains/_core.md` § R5 (Feature Boundary Heuristics).

Define the following for each Feature:
- Feature name (concise English name)
- Description (1-2 sentences)
- List of associated files
- Owned entities
- Provided APIs

**Naming Remapping scan** (only if Phase 0 Question 3 established a new project name):
For each Feature's associated files, scan for code-level identifiers (function names, class names, variable names, constants, package names) that contain the original project name or its prefix mappings. Record each occurrence with:
- Original identifier (e.g., `createCherryIn`, `CherryProvider`)
- File and line number
- Suggested new identifier (apply the prefix mapping, e.g., `Cherry` → `Angdu`)
- Type (function, class, variable, constant, env var, package, etc.)

This per-Feature catalog will be populated into each Feature's `pre-context.md` → "Naming Remapping" section during Phase 4-2.

> Do not assign Feature IDs at this point. IDs will be assigned based on topological sort after constructing the dependency graph in 3-2.

### 3-1b. Feature Granularity Selection (HARD STOP)

After identifying Feature boundaries, present **multiple granularity options** to the user. The same codebase can be decomposed at different levels of granularity, and the right choice depends on project goals, team size, and desired iteration speed.

**Step 1 — Prepare granularity proposals**:
Analyze the identified Features and propose 2-3 granularity levels:

| Level | Name | Description | Typical Feature Count |
|-------|------|-------------|----------------------|
| **Coarse** | Domain-level | One Feature per major business domain. Larger scope per Feature, fewer total Features. Good for small teams or quick prototyping | 4-8 Features |
| **Standard** | Module-level | One Feature per logical module/service boundary. Balanced scope and count. Recommended for most projects | 8-15 Features |
| **Fine** | Capability-level | One Feature per distinct user-facing capability. Smaller scope per Feature, more total Features. Good for large teams or when granular tracking is needed | 15-30 Features |

**Step 2 — Present the proposals**:
For each granularity level, show a concrete Feature list derived from the analysis:

```
📋 Feature Granularity Options:

── Option A: Coarse (Domain-level) ──────────────
[N] Features total
  • auth — User authentication + authorization + roles
  • catalog — Products + categories + search
  • commerce — Cart + orders + payment + shipping
  • admin — Admin panel + analytics + reports
Pros: Faster pipeline, fewer cross-Feature dependencies
Cons: Larger Features (harder to review/test in isolation)

── Option B: Standard (Module-level) — Recommended ──
[N] Features total
  • auth — User registration, login, sessions
  • user-profile — User profiles, preferences
  • product — Product CRUD, categories
  • search — Product search, filtering
  • cart — Shopping cart management
  • order — Order placement, status tracking
  • payment — Payment processing
  • admin — Admin dashboard, reports
Pros: Balanced scope, manageable review cycles
Cons: Moderate number of Features to track

── Option C: Fine (Capability-level) ────────────
[N] Features total
  • user-register — User registration
  • user-login — Login + session management
  • user-roles — Role-based access control
  • product-crud — Product create/read/update/delete
  • product-category — Category management
  • product-search — Search + filtering
  • ...
Pros: Granular tracking, easier isolated testing
Cons: Many Features, more cross-Feature dependencies
```

**Step 3 — User selection**:
Use AskUserQuestion to ask the user:
- "Option B: Standard (Module-level) (Recommended)"
- "Option A: Coarse (Domain-level)"
- "Option C: Fine (Capability-level)"

**You MUST STOP and WAIT for the user's response. Do NOT proceed until the user selects a granularity level. If response is empty → re-ask.**

If the user selects "Other", they can describe a custom granularity or request specific merges/splits of the proposed Features.

**Step 4 — Apply the selected granularity**:
Reconstruct the Feature list according to the selected level. If Coarse is selected, merge related Features. If Fine is selected, split Features into smaller units. Then proceed to 3-1c with the finalized Feature list.

### 3-1c. Demo Group Definition (HARD STOP)

After the Feature list is finalized (3-1b Step 4), define Demo Groups — end-to-end user scenarios that span multiple Features and serve as integration verification milestones.

**Step 1 — Analyze and propose Demo Groups**:
Based on the finalized Feature list, propose 2–4 Demo Groups by analyzing:
- Feature dependency chains (Features that form a complete user flow)
- Business scenario boundaries (distinct user journeys)
- SBI entries from Phase 2 that span multiple Features

For each proposed group:
```
── DG-01: [Scenario Name] ──────────────────
Scenario: [End-to-end user journey description]
Features: F001-xxx, F002-yyy, F003-zzz
Related SBI: [Summary of behaviors this scenario covers]
```

**Step 2 — Display and approve**:
**FIRST**, display ALL proposed Demo Groups using the format above (DG-01, DG-02, ...) so the user can see the full details.
**THEN**, ask via AskUserQuestion:
- "Accept proposed Demo Groups"
- "Modify grouping" (user can reassign Features between groups)
- "Add more groups"
- "Skip Demo Groups" (not recommended — disables Integration Demo triggers)

**You MUST STOP and WAIT for the user's response. Do NOT proceed until the user approves Demo Groups. If response is empty → re-ask.**

**Step 3 — Record decision**:
After approval, **append** to `specs/history.md` under the current session's Architecture Decisions table:

| Decision | Choice | Details |
|----------|--------|---------|
| Demo Groups | [N] groups defined | [Group names: DG-01 Scenario, DG-02 Scenario, ...] |

The Demo Groups will be written to `roadmap.md` in Phase 4-1 and tracked in `sdd-state.md` → Demo Group Progress section.

> **Note**: Infrastructure or cross-cutting Features (e.g., shared utilities, configuration) may not belong to any Demo Group. This is acceptable — they support other Features but don't represent user-facing scenarios.

Then proceed to 3-1d.

### 3-1d. Cross-Feature Interaction Intensity Check

After Feature boundaries are finalized and Demo Groups defined, validate that boundaries correctly separate high-cohesion code and correctly identify cross-Feature interactions. This catches misdrawn boundaries where two "Features" are so tightly coupled they should be merged, or where interactions are unexpectedly complex.

**Step 1 — Build Interaction Intensity Matrix**:

Using Phase 2 inter-module dependency data (2-4), count interactions for each Feature pair:

| Interaction Type | Weight | Detection Method |
|-----------------|--------|-----------------|
| Direct import (A imports B's module) | 1 | Phase 2-4 import graph |
| Shared entity (A writes, B reads same entity) | 2 | Phase 2-1 entity ownership |
| API call (A calls B's endpoint) | 2 | Phase 2-2 API cross-references |
| Event coupling (A publishes, B subscribes) | 1 | Phase 2-4 event patterns |
| Shared business rule (rule spans both Features) | 3 | Phase 2-3 cross-Feature rules |

Calculate **Interaction Score** for each Feature pair: sum of (count × weight) for all interaction types.

**Step 2 — Anomaly Detection**:

| Anomaly | Threshold | Action |
|---------|-----------|--------|
| Over-coupled pair | Score ≥ 10 | Flag: "Consider merging [A] and [B] — interaction score [N] suggests tight coupling" |
| Orphan Feature | Score = 0 with all Features | Flag: "Feature [X] has no interactions — verify it's correctly bounded" |
| Hub Feature | Score ≥ 5 with 3+ Features | Flag: "Feature [Y] is a hub — verify its scope isn't too broad" |

**Step 3 — Display and optional adjustment**:

```
📊 Cross-Feature Interaction Intensity:

Top interactions:
  F001-auth ↔ F003-chat: Score 8 (3 shared entities, 2 API calls, 1 shared rule)
  F002-settings ↔ F005-ai: Score 12 ⚠️ OVER-COUPLED
    → Consider merging, or define explicit Feature Contracts in pre-context

Anomalies:
  ⚠️ F002-settings ↔ F005-ai: Over-coupled (score 12)
  ℹ️ F009-export: Low interaction (score 1 total) — verify boundary
```

If anomalies found, display them but do NOT auto-merge or auto-split. Proceed to 3-2. The user can revisit boundaries after seeing the full dependency graph.

> **Note**: This check is informational, not blocking. It enriches the dependency graph (3-2) with interaction intensity data and helps the user validate boundary decisions. The interaction data also feeds into Phase 4-2 when populating Feature Contract sections in each pre-context.md.

Then proceed to 3-1e.

### 3-1e. Archetype Detection

Scan the project for archetype signals using A0 keywords from all archetype modules (`domains/archetypes/*.md`).

**Steps**:
1. Read A0 Signal Keywords from each archetype module (ai-assistant, public-api, microservice)
2. Match against:
   - Package dependencies (from Phase 1 extraction)
   - Code patterns observed during Phase 2 deep analysis
   - Config files and directory structures
3. If a primary keyword matches ≥ 1 signal → record the archetype as **detected**
4. If only secondary keywords match → record as **candidate** (for user confirmation)

**Output**: Record detected/candidate archetypes in analysis notes.

**Archetype Evidence Extraction (MANDATORY when archetype detected)**:

When an archetype is detected (not just candidate), extract evidence from the source analysis for each A1 principle. This evidence is REQUIRED by Phase 4-1 for the constitution-seed "Archetype-Specific Principles" section.

For each detected archetype, read its `domains/archetypes/{archetype}.md` § A1 table and extract evidence:

```
Archetype: [name]
Principles with Evidence:
  1. [Principle name]:
     - Observed Trait: [Concrete evidence from code — e.g., "SSE endpoints in src/api/chat/stream.ts, ReadableStream usage in 12 files"]
     - Implication: [How this affects rebuild — e.g., "Streaming architecture must be preserved; batch response pattern would be a regression"]
  2. [Principle name]:
     - Observed Trait: [...]
     - Implication: [...]
```

- For EACH A1 principle: cite at least ONE concrete code-level observation from Phase 2 analysis.
- If a principle has NO evidence in the codebase (e.g., "Prompt Versioning" principle but prompts are hardcoded), record: `Observed Trait: "Not implemented in source — [why]"` and `Implication: "Consider introducing as improvement"`. Do NOT silently omit the principle.

This data feeds into:
- Phase 4-1: constitution-seed generation (archetype-specific principles with evidence)
- smart-sdd pipeline: sdd-state.md Archetype field
- `./case-study-log.md` (CWD root): Update `**Archetype**:` header field with detected archetype name(s) (e.g., `ai-assistant`). If no archetype detected, leave as `none`.

**No HARD STOP** — archetype detection is informational. Display detected archetypes and evidence summary in the Phase 3 summary.

Then proceed to 3-2.

### 3-2. Dependency Graph Construction and Release Group Determination
Derive inter-Feature dependencies:
- **Direct Dependency**: Uses another Feature's modules via import/require
- **API Dependency**: Calls APIs provided by another Feature
- **Entity Dependency**: References entities owned by another Feature
- **Event Dependency**: Subscribes to events published by another Feature
- **Platform Constraint**: Runtime environment setup by one Feature that downstream Features must respect (window config, CSS requirements, security policies, IPC channels)

**Platform constraint detection** (Electron/Tauri/Desktop apps):
- Scan BrowserWindow/Window options: `frame`, `transparent`, `titleBarStyle`, `titleBarOverlay`, `webPreferences`
- Scan security headers: CSP, CORS policies in main process
- Scan IPC channel registrations used by downstream Features
- Record as `Platform constraint` dependency type in Dependency Graph
- Example: `frame: false` in F001-shell → all downstream UI Features must implement custom titlebar with `-webkit-app-region: drag`

Record dependency directions and types, and visualize them as a Mermaid diagram.

**Dependency Interpretation Rules (MANDATORY)**:

Feature dependency means **implementation dependency**: "Must Feature B be IMPLEMENTED AND COMPLETED first for Feature A to be implementable?" This is NOT the same as runtime import relationships.

| Correct (Implementation Dependency) | Incorrect (Runtime Coupling) |
|--------------------------------------|-------------------------------|
| "Chat UI needs Shell window to render in" | "Shell imports DB module at startup" |
| "Settings UI needs Navigation to have routes" | "Data layer initializes before renderer" |
| "Knowledge Base needs Model management for embeddings" | "IPC channels import from shared constants" |

**Rule 1 — App Shell/Bootstrap Always RG-1 First**: The Feature containing the app entry point, window creation, or process bootstrap MUST be placed in Release Group 1 with zero incoming Feature dependencies, unless there is an explicit, justified reason to override. If the topological sort places the Bootstrap Feature after another Feature, this is almost certainly a runtime-coupling confusion — review and correct.

**Rule 2 — Foundation Feature Sanity Check**: If ANY Feature classified in RG-1 (Foundation) has incoming dependencies from other Features, display a warning and ask the user for confirmation:
```
⚠️ Foundation Feature Sanity Check:
  [Feature] is in RG-1 (Foundation) but depends on: [dependency list]
  Foundation Features typically have ZERO incoming dependencies.
  Are these implementation dependencies (Feature cannot be coded without them)
  or runtime coupling (code imports that don't affect implementation order)?
```
Ask via AskUserQuestion. **If response is empty → re-ask** (per MANDATORY RULE 1).

**Rule 3 — Dependency Direction Test**: For each candidate dependency edge A → B (A depends on B), apply this test:
  "If Feature B's source code artifacts did not exist at all, could I still write Feature A's code from scratch (with stubs/interfaces for B)?"
  - **YES** → This is runtime coupling, NOT an implementation dependency. Do NOT add this edge.
  - **NO** → This is a genuine implementation dependency. Add the edge.

**Release Group Determination**:
Group Features into Release Groups based on dependency layers:
1. **Release 1 (Foundation)**: Features with no dependencies (or only external dependencies)
2. **Release 2+**: Features whose dependencies are all satisfied by preceding Release Groups
3. Within each Release Group, order Features by topological sort (most independent first)
4. **Post-sort validation**: After topological sort, verify that the App Shell/Bootstrap Feature (if identified) is in Release Group 1 with no predecessors. If not, re-examine the dependency edges per the Dependency Interpretation Rules above.

> **Do NOT assign Feature IDs yet.** Use temporary labels (feature names only) until Phase 3-3 (Tier classification) is complete. IDs will be assigned after Release Groups and Tiers are both determined.

### 3-2b. Feature ID Assignment (after Phase 3-3)

> **This step runs AFTER Phase 3-3 (Tier Classification).** If Scope = Full, run immediately after 3-2 (no Tier classification needed).

**Feature ID Assignment Rules — IDs MUST follow the pipeline execution order (Tier-first)**:

**If Scope = Core**:
1. **Tier-first global ordering**: Assign ALL Tier 1 Features first, then ALL Tier 2, then ALL Tier 3
2. Within each Tier, follow Release Group order (RG-1 first, then RG-2, etc.)
3. Within the same Tier and Release Group, maintain topological order
4. Assign F001, F002, ... sequentially across all Tiers

This ensures:
- Feature IDs directly correspond to the pipeline execution order
- When only T1 is active: `F001 → F002 → F003 → F004` — no gaps, no skips
- When T2 is activated later, its Features continue sequentially from where T1 ends
- No ID gaps or out-of-order processing at any Tier activation level

**Example** (12 Features, 4 Release Groups):
```
T1 Features (in RG order): F001, F002, F003, F004   ← pipeline processes these first
T2 Features (in RG order): F005, F006, F007          ← activated when T2 starts
T3 Features (in RG order): F008, F009, F010, F011, F012 ← activated when T3 starts
```

**If Scope = Full**:
1. Start with Release Group 1, then Release Group 2, etc.
2. Within each Release Group, maintain topological order
3. Assign F001, F002, ... sequentially

This ensures:
- Feature IDs match the implementation order based on dependency-resolved Release Groups

**Common**: These numbers also correspond to spec-kit's `specs/{NNN-feature}/` directory names (e.g., F001-auth → `specs/001-auth/`)

### 3-3. Importance Analysis and Tier Classification (Core Scope Only, HARD STOP)

> **This phase is SKIPPED when Scope = Full.** In full mode, all Features are implemented without prioritization — Feature ordering is determined by Release Group order (Phase 3-2). Proceed to Phase 3-2b (Feature ID Assignment) then Phase 4.

**If Scope = Core**:

First, identify the project domain: understand what kind of system the project is (e-commerce, SaaS, CMS, education platform, financial service, etc.) and determine which features are foundational within that domain.

Evaluate each Feature comprehensively across the analysis axes and assign to Tier 1 (Essential) / Tier 2 (Recommended) / Tier 3 (Optional). See `domains/_core.md` § R6 (Tier Classification Axes) for the evaluation criteria and Tier definitions. For each Feature, a **specific rationale** for the assigned Tier must be provided.

**FIRST**, display the full Tier classification table showing each Feature's assigned Tier and rationale (using temporary names — final Feature IDs will be assigned in Phase 3-2b after Tier approval):
```
── Tier Classification Results ──────────────────

Tier 1 (Essential):
  auth            — [rationale]
  product         — [rationale]

Tier 2 (Recommended):
  order           — [rationale]

Tier 3 (Optional):
  analytics       — [rationale]
```

**THEN**, ask via AskUserQuestion for approval/adjustments. **If response is empty → re-ask.**

**After Tier approval**: Proceed to Phase 3-2b to assign final Feature IDs in Release Group order (Tier 1 first within each group).

### Decision History Recording — Architecture

After Phase 3 is complete (granularity selected, dependencies mapped, Tier classification approved if core scope), **append** to `specs/history.md` under the current session's section:

```markdown
### Architecture Decisions

| Decision | Choice | Details |
|----------|--------|---------|
| Feature Granularity | Coarse / Standard / Fine | [N] Features |
| Tier Adjustments | [summary of user modifications] | [details, or "None — accepted AI recommendation as-is"] |
```

Record each user modification to the AI's Tier proposals (e.g., "Moved Search from T2 → T1"). If scope is `full`, omit the Tier Adjustments row.

📝 **Case Study Recording**: Append milestone entry to `./case-study-log.md` (CWD root) per [recording-protocol.md](../../case-study/reference/recording-protocol.md) § M3.

---

