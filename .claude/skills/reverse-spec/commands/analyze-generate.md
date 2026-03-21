## Phase 4 — Deliverable Generation

Generate hierarchical deliverables in `specs/_global/` (in CWD — see Output Directory rule in SKILL.md).

> **Scope = Core**: All Features are included in generated artifacts (roadmap.md, pre-context.md, etc.) regardless of Tier. The Tier classification only determines which Features smart-sdd will initially process — Tier 2/3 Features are marked as `deferred` in `sdd-state.md` and skipped by the pipeline until activated via `/smart-sdd expand`. This ensures Tier 2/3 Features are ready for immediate activation without re-running `/reverse-spec`.
>
> **Scope = Full**: All Features are included without Tier classification. No Features are deferred. The `Tier` column is omitted from roadmap.md and sdd-state.md.

### 4-1. Project-Level Deliverables

Generate the following files in order. Each file follows the template structure found in this skill's `templates/` directory.

1. **`specs/_global/roadmap.md`** — See [roadmap-template.md](../templates/roadmap-template.md)
   - Project Overview, Rebuild Strategy, Feature Catalog (by Tier for Core scope / by dependency order for Full scope), Dependency Graph, Release Groups, **Demo Groups** (from Phase 3-1c), Cross-Feature Entity Dependencies, Cross-Feature API Dependencies

2. **`specs/_global/entity-registry.md`** — See [entity-registry-template.md](../templates/entity-registry-template.md)
   - Complete entity list, fields, relationships, validation rules, cross-Feature sharing mapping

3. **`specs/_global/api-registry.md`** — See [api-registry-template.md](../templates/api-registry-template.md)
   - Complete API endpoint index, detailed contracts, cross-Feature dependencies

4. **`specs/_global/business-logic-map.md`** — See [business-logic-map-template.md](../templates/business-logic-map-template.md)
   - Business rules per Feature, validation, workflows, cross-Feature rules

5. **`specs/_global/constitution-seed.md`** — See [constitution-seed-template.md](../templates/constitution-seed-template.md)
   - Source code reference principles (branching by stack strategy), extracted architecture principles, technical constraints, coding conventions
   - **Naming Conventions** (if project identity changed in Phase 0 Question 3): Include a mapping section documenting original → new naming patterns (e.g., `Cherry` → `Angdu`, `CS` → `AS`). This section guides `speckit-constitution` and `speckit-implement` to use the new project naming consistently.
   - **Recommended Development Principles (Best Practices)**: Test-First, Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution, Demo-Ready Delivery
   - **Global Evolution Layer Operational Principles**: Rules for maintaining cross-Feature context
   - **Project-Specific Recommended Principles**: Based on the domain, architecture patterns, and technical traits observed in Phase 1~3, recommend additional constitution principles tailored to this project. Use the recommendation categories in the template (domain-driven, architecture-driven, scale-driven, quality-driven) as a guide. Each recommendation must cite a specific observed trait from the source analysis as evidence.
   - **Archetype-Specific Principles (MANDATORY when archetype detected in Phase 3-1e)**:
     1. Read the archetype evidence extracted in Phase 3-1e (the "Archetype Evidence Extraction" output).
     2. For each detected archetype, create a subsection using this exact format:
        ```markdown
        ## Archetype-Specific Principles

        ### [Archetype Display Name] Domain

        - **[Principle Name]**: [One-line description of the principle]
          - **Observed Trait**: [Concrete evidence from source code — e.g., "SSE endpoints in src/api/chat/stream.ts, ReadableStream usage across 12 provider files"]
          - **Implication**: [How this affects the rebuild — e.g., "Streaming architecture is core UX; batch responses would be a regression"]

        - **[Principle Name]**: [One-line description]
          - **Observed Trait**: [Evidence from code]
          - **Implication**: [Rebuild impact]
        ```
     3. Do NOT use a simple numbered list of principles. Each principle MUST have the `**Observed Trait**` + `**Implication**` sub-items.
     4. If Phase 3-1e recorded "Not implemented in source" for a principle, include it with that note — do NOT silently omit it.
     5. If no archetype was detected, omit this entire section.
   - **Framework Philosophy (MANDATORY when Foundation has F7 section)**:
     1. Check: Does the loaded Foundation file (`domains/foundations/{framework}.md`) contain a `## F7. Framework Philosophy` section?
        - **If YES**: This section is **MANDATORY** in the constitution-seed. You MUST NOT skip it.
        - **If NO** (or no Foundation file loaded): Omit this section entirely.
     2. When F7 exists, create a `## Framework Philosophy` section in constitution-seed.md:
        ```markdown
        ## Framework Philosophy

        > Framework-endorsed architectural guardrails. Source: domains/foundations/{framework}.md § F7

        | Principle | Description | Implication |
        |-----------|-------------|-------------|
        | **[Principle name]** | [Description from F7 table] | [Implication from F7 table] |
        ```
     3. Copy ALL rows from the Foundation F7 table — do NOT summarize, abbreviate, or omit any principle.
     4. Place this section AFTER "Archetype-Specific Principles" (or after "Project-Specific Recommended Principles" if no archetype was detected).

6. **`specs/_global/stack-migration.md`** (only for New Stack strategy) — See [stack-migration-template.md](../templates/stack-migration-template.md)
   - Current → New mapping per technology component, migration rationale, per-Feature migration notes, risks and mitigations

7. **`.env.example`** (project root, **rebuild mode only** — skip when `--adopt` is specified):
   - **Adoption mode**: `.env.example` already exists in the source project. Do NOT regenerate. Environment variables are documented in each Feature's pre-context.md → "Environment Variables" section only.
   - **Rebuild mode**: Generated at CWD root (NOT inside `specs/_global/`)
   - Lists all detected env vars with category comments and placeholder values
   - Groups by Feature association (shared vars first, then per-Feature)
   - Format:
     ```
     # ── Shared (used by multiple Features) ──
     DATABASE_URL=postgresql://localhost:5432/myapp

     # ── F001-auth ──
     JWT_SECRET=your-jwt-secret-here
     OAUTH_CLIENT_ID=your-oauth-client-id
     ```

8. **`specs/_global/speckit-prompt.md` (MANDATORY)** — See [speckit-prompt-template.md](../templates/speckit-prompt-template.md)
   - Standalone prompt for using spec-kit without smart-sdd
   - Per-command context guide: which artifacts to read before each spec-kit command (specify, plan, implement, verify)
   - Cross-Feature awareness rules
   - Fill ALL dynamic fields from the template:
     - `[PROJECT_NAME]`: from Phase 0
     - `[ORIGINAL_SOURCE_PATH]`: target directory absolute path
     - `[SCOPE]`, `[STACK_STRATEGY]`: from Phase 0 decisions
     - `[FEATURE_COUNT]`, `[TIER_BREAKDOWN]`: from Phase 3 classification
     - `[DETECTED_STACK]`: from Phase 1-2 tech stack detection
     - `[RG_COUNT]`: number of Release Groups from Phase 3-2
     - Feature Catalog table: copied from roadmap.md
   - **Verification**: After generating, check that NO placeholder tokens remain (no `[PROJECT_NAME]`, `[SCOPE]`, etc. in the output file). All brackets must be replaced with actual values.

### 4-2. Feature-Level Deliverables

For each Feature, generate `specs/[Feature-ID]-[feature-name]/pre-context.md`. See [pre-context-template.md](../templates/pre-context-template.md).

**Path Convention**: All file paths in pre-context.md's Source Reference and Static Resources sections MUST be **relative to the target directory** (the source being analyzed). Do NOT use absolute paths. The `Source Root` header in the template references `$SOURCE_ROOT`, whose actual value is stored as `Source Path` in `sdd-state.md` and resolved at runtime by smart-sdd.

For example, if the target directory is `/Users/dev/legacy-app`:
- ✅ `src/main/index.ts`
- ❌ `/Users/dev/legacy-app/src/main/index.ts`

#### B### ID Assignment Rules

When populating the Source Behavior Inventory (SBI) table in each pre-context.md, assign globally unique **B### IDs** to every SBI entry:

1. **Sequential numbering**: B001, B002, B003, ... across the entire project (not per-Feature)
2. **Feature order**: Assign IDs following Feature ID order — F001's SBI entries get the lowest B### numbers, then F002's entries continue from where F001 left off, and so on
3. **Contiguous — no gaps**: B### numbering MUST be contiguous across Features. If F001 ends at B017, F002 MUST start at B018. No gaps allowed (e.g., F001 ending at B017 and F002 starting at B031 = INVALID)
4. **Within a Feature**: Order entries by Priority (P1 first, then P2, then P3), then alphabetically by function name within the same priority
5. **Uniqueness**: Each B### ID is unique project-wide. If F001 has entries B001–B010, F002 starts at B011
6. **Global numbering only**: B### IDs are ALWAYS global. Do NOT use Feature-local numbering (e.g., every Feature starting from B001 = INVALID). Each Feature's first B### = previous Feature's last B### + 1

Example:
```
F001-auth (10 entries): B001–B010
F002-product (8 entries): B011–B018
F003-order (12 entries): B019–B030
Total: 30 entries, B001–B030 (contiguous, no gaps)
```

#### SBI Table Format (MANDATORY)

All pre-context.md SBI tables MUST use this exact table format (from [pre-context-template.md](../templates/pre-context-template.md)):

```markdown
| ID | Source File | Function/Method | Behavior Description | Priority | Origin |
|----|-------------|----------------|---------------------|----------|--------|
| B001 | `src/path/service.ts` | `functionName()` | One-line behavior description | P1 | extracted |
```

- **ID**: B### (globally unique, assigned per rules above)
- **Source File**: Relative path to source file (relative to target directory)
- **Function/Method**: Exported function or public method name
- **Behavior Description**: One-line description of what the function does
- **Priority**: P1 (core) / P2 (important) / P3 (nice-to-have)
- **Origin**: `extracted` (from source) or `new` (added during /smart-sdd)

Do NOT use heading format (`### B001 — Title`), alternate column orders, or omit columns. Every Feature MUST use the same table format.

#### SBI Numbering Verification (MANDATORY — after all pre-contexts are generated)

After generating ALL pre-context.md files, perform this verification before proceeding to Phase 4-3. This step is **BLOCKING** — do NOT proceed if any check fails.

1. **Build the global SBI map**: For each Feature (F001, F002, ..., F00N), read its pre-context.md SBI table and record: Feature ID, first B###, last B###, count
2. **Check contiguity**: Verify that each Feature's first B### = previous Feature's last B### + 1. No gaps allowed
3. **Check uniqueness**: Verify no B### appears in more than one Feature
4. **Check total**: Sum all per-Feature counts. This is the authoritative total SBI count for coverage-baseline.md

Display verification result:
```
✅ SBI Numbering Verification:
  F001-auth:     B001–B010 (10)
  F002-product:  B011–B018 (8)
  F003-order:    B019–B030 (12)
  Total: 30 SBI items, B001–B030 (contiguous, no gaps, no collisions)
```

If any check fails, fix the numbering BEFORE proceeding:
```
❌ SBI Numbering Verification FAILED:
  Gap detected: F003 ends at B048, F004 starts at B076 (missing B049–B075)
  Collision detected: F006 B176 and F007 B176 both exist
  → Fix: Renumber F004+ to close gaps, renumber F007+ to start after F006 ends
```

#### Demo Group SBI Coverage Ranges (MANDATORY — BLOCKING)

After SBI Numbering Verification passes, calculate the SBI coverage ranges for each Demo Group defined in Phase 3-1c. This data is required for `roadmap.md` → Demo Groups section.

**Calculation algorithm**:
1. For each Demo Group (DG-01, DG-02, ...), read its constituent Feature list (from Phase 3-1c)
2. For each constituent Feature, look up its SBI range from the SBI Numbering Verification result above
3. Combine: Demo Group SBI Coverage = union of all constituent Features' SBI ranges
4. Write ranges using comma-separated B###–B### notation (e.g., `B001–B055, B081–B160`)

**Display result**:
```
✅ Demo Group SBI Coverage:
  DG-01 (Basic Chat):     F001+F002+F004+F005 → B001–B055, B081–B160
  DG-02 (Knowledge RAG):  F004+F005+F006      → B081–B195
  DG-03 (Multi-Tool):     F003+F007+F008+F009 → B056–B080, B196–B290
  DG-04 (External API):   F004+F005+F010      → B081–B160, B291–B330
```

> ⚠️ **Do NOT write "TBD" or defer this calculation.** All data is available from SBI Numbering Verification + Phase 3-1c Demo Group definitions. If you cannot calculate the ranges, it means a prior step produced incomplete data — go back and fix it before proceeding.

These SBI Coverage values MUST be included when writing the Demo Groups section in `roadmap.md` (Phase 4-1). The `**SBI Coverage**` field in each Demo Group entry uses the ranges calculated here.

Contents to include in each pre-context.md (see [pre-context-template.md](../templates/pre-context-template.md) for exact section structure):
- **Runtime Exploration Results** (rebuild only, if Phase 1.5 was performed): Read `specs/_global/runtime-exploration.md` and distribute observations to each Feature based on route-to-Feature mapping. For each Feature: extract the `## Screen:` sections whose routes belong to this Feature, include associated user flows and runtime behavior from those screen blocks, and add relevant App-Wide Observations. If Phase 1.5 was skipped or the file does not exist, write "Skipped — [reason]"

  **Route-to-Feature Mapping Algorithm**:
  1. Feature boundaries are determined by file/module in Phase 3-1
  2. Phase 1 code scan identifies page component files for each route
  3. Mapping: route → page component file → Feature that owns the file (Phase 3-1 boundary)
  4. Shared routes: included in primary owner Feature, referenced in other Features
  5. Unmappable routes: recorded in App-Wide Observations
- **Source Reference**: List of related original files (relative paths) + reference guide by stack strategy. Include a **Rebuild Target** column set to `[TBD]` for all files — this column will be populated during `/speckit.plan` when the target architecture is decided. Use 3-column format: `File Path | Role | Rebuild Target`
- **Source Behavior Inventory**: Phase 2-6 SBI entries filtered to this Feature (see `domains/_core.md` § R3 (Source Behavior Inventory) for format)

  > **SBI Per-Feature Filtering**: Filter only behaviors belonging to this Feature's source files from the Phase 2-6 global SBI. B### IDs are assigned sequentially and uniquely across the entire project in Feature ID order.
- **UI Component Features** (frontend/fullstack projects only): Third-party UI library capabilities from Phase 2-7, filtered to this Feature's associated components. Each entry: component name, library, feature, category. Omit for backend-only projects
- **Interaction Behavior Inventory** (frontend/fullstack projects only): Micro-interaction patterns from Phase 2-7b (hover behaviors, keyboard shortcuts, animations, focus management, drag-and-drop, context menus, scroll behaviors), filtered to this Feature's associated components and screens. Omit for backend-only projects
- **Foundation Decisions** (if Framework ≠ "custom"): From Phase 2-8 extraction results, populate the Foundation Decisions section (Critical, Important, Undecided tables) with items relevant to this Feature's domain. For T0 Features (F000-*): include all items from their owning Foundation categories. For T1+ Features: include only Foundation decisions that constrain this Feature
- **Foundation Dependencies**: For each Feature, classify its relationship to Foundation categories — `owns` (T0 only), `consumes` (T1+ uses Foundation decisions as constraints), `extends` (rare, adds to Foundation). Skip if Framework is "custom" or "none"
- **Naming Remapping** (only if Phase 0 Question 3 established a new project name): Per-Feature catalog of code-level identifiers containing the original project name, with suggested new identifiers. Populated from Phase 3-1 scan results. Omit this section entirely if project name is unchanged or no old-name identifiers were found in this Feature
- **Static Resources**: List of non-code files (images, fonts, i18n, etc.) used by this Feature, with source/target paths (source paths relative to target directory) and usage context. Based on Phase 1-5 inventory, filtered to this Feature's associated files. If none, write "None"
- **Environment Variables**: Variables this Feature requires at runtime, from Phase 2-5 extraction. Distinguishes Feature-owned vars from shared vars referenced from other Features. If none, write "None"
- **For /speckit.specify**: Existing feature summary, existing user scenarios, edge cases. (Draft FR/SC are now in spec-draft.md — see below)

#### Per-Feature Spec Draft Generation (rebuild mode — MANDATORY)

> **Why spec-draft.md exists**: Previously, Draft FR/SC were 1-line bullet points in pre-context's "For /speckit.specify" section. speckit-specify would read these and generate spec.md — but it consistently compressed UI details (dropdowns → "input", auto-fill → omitted, error paths → ignored). By generating a detailed spec-draft.md during reverse-spec (when source context is fully loaded), the conversion from source behavior → requirements happens ONCE with full context, instead of twice with progressive loss.

For each Feature, generate `SPEC_PATH/[NNN-feature]/spec-draft.md` using the [spec-draft-template.md](../templates/spec-draft-template.md):

**Conversion Rules (Source → spec-draft)**:

1. **UI Flow Spec → FR**: Each flow step becomes an FR with explicit UI control type, trigger, and result:
   ```
   Flow Step: | 3 | Select model | Dropdown(configured only) | Dimensions auto-fills |
   → FR-003: Select embedding model from Dropdown (shows ONLY configured providers' models).
             Selecting a model auto-fills the Dimensions field with the model's vector dimension count.
   ```
   - **NEVER abstract UI controls**: Dropdown stays Dropdown, Slider stays Slider, auto-fill stays auto-fill
   - **NEVER merge flow steps**: Each step that involves a distinct user action → separate FR
   ```
   ❌ WRONG: "FR-003: User selects embedding model" (UI control abstracted away)
   ✅ RIGHT: "FR-003: Select embedding model from Dropdown (configured providers only). Selecting a model auto-fills Dimensions." (exact control + behavior)

   ❌ WRONG: "FR-001: User can create a Knowledge Base" (entire flow merged into 1 FR)
   ✅ RIGHT: FR-001 (click Create button), FR-002 (fill name), FR-003 (select model), FR-004 (click Create) — one FR per user action
   ```

2. **UI Flow Spec Error Paths → Edge Case FR/SC**:
   ```
   Error: Empty name → red border, Create disabled
   → FR-E01: When name field is empty, show validation error (red border). Create button stays disabled.
   → SC-E01: Clear name field → red border appears on name input, Create button is disabled.
   ```

3. **SBI Behaviors → FR with [source: B###] tag**:
   ```
   B105: CitationsList.tsx — renders inline citation badges with data-citation attribute
   → FR-008: Chat response displays numbered citation badges [1][2][3].
             Clicking badge [N] shows tooltip with source #N's preview. [source: B105]
   ```

4. **Cross-Feature Interactions → SC-X### (cross-feature SC)**:
   ```
   Cross-feature flow observed: KB attached to chat → message sent → citations in response
   → SC-X01: Attach KB to assistant → send message → response contains citation badges
             → click badge [2] → tooltip shows source file #2's name and content preview
   ```

5. **Data Pipeline → Pipeline-stage FRs**:
   ```
   Pipeline observed: file → extract text → chunk → embed → store → search → display
   → FR-010: Text extraction from uploaded files (PDF, TXT, MD, DOCX)
   → FR-011: Text chunking with configurable chunk size
   → FR-012: Vector embedding generation via configured provider's embedding model
   → FR-013: Vector storage in local database
   → FR-014: Similarity search against stored vectors
   → FR-015: Search result display as citation badges in chat response
   ```

**Completeness Check (BLOCKING)**:
After generating spec-draft.md for each Feature, verify:
- Every P1/P2 SBI behavior has a corresponding FR → if not, add it
- Every UI Flow Spec step has a corresponding FR → if not, add it
- Every UI Flow Spec error path has a corresponding SC-E### → if not, add it
- Every cross-feature interaction has a corresponding SC-X### → if not, add it
- No FR uses generic verbs ("input", "configure", "manage") where specific controls were observed ("Dropdown", "Slider", "auto-fill")

```
❌ WRONG: Phase 4 completes with 0 spec-draft.md files → "reverse-spec complete"
   → specify has no seed → generates vague spec from scratch → UI detail lost

✅ RIGHT: Phase 4 generates spec-draft.md for EVERY Feature → completeness check passes
   → specify refines detailed seed → UI controls preserved
```

**Phase 4 Completion Gate (BLOCKING)**:
Before displaying the Phase 4 Completion Report, verify:
1. `spec-draft.md` exists for EVERY Feature in the roadmap → if any missing, generate it before proceeding
2. Each spec-draft has at least 1 FR and 1 SC → empty spec-drafts are not acceptable
3. Display count: `📋 spec-draft.md: [N]/[total] Features generated`
4. If any missing → 🚫 BLOCKING: "spec-draft.md missing for [FID]. Generate before completing Phase 4."

#### Per-Feature Pre-Context Generation Protocol (MANDATORY)

When generating each Feature's pre-context.md, process the template sections **in order** and apply this protocol for EACH section:

1. **Check applicability**: Is this section applicable to this Feature? (See the "Required?" column in the Completeness Verification table below)
2. **If applicable**: Populate with data from the corresponding Phase 2/3 analysis. If the Phase analysis produced no data for this section, write the Empty Value from the table (e.g., "None", "N/A — backend-only").
3. **If not applicable**: Write the Empty Value explicitly. Do NOT omit the section heading.
4. **Never skip a section silently**: Every section heading from the template MUST appear in the generated pre-context.md, even if its content is "None" or "N/A".

The following sections are **commonly skipped by mistake** — pay special attention:
- **Runtime Exploration Results**: Must appear even if Phase 1.5 was skipped (write "Skipped — [reason]")
- **UI Component Features**: Must appear for frontend projects even if no 3rd-party UI features detected (write "None — no third-party UI component features detected")
- **Interaction Behavior Inventory**: Must appear for frontend projects (populate from `micro-interactions.md`; write "N/A — no interactive UI in this Feature" if truly none)
- **Foundation Decisions**: Must appear when Framework is not "custom" (write "No Foundation decisions apply to this Feature" if none relevant)
- **Foundation Dependencies**: Must appear when Framework is not "custom"
- **Static Resources**: Write "None" if no resources — do NOT omit the section
- **Environment Variables**: Write "None" if no variables — do NOT omit the section

#### Pre-context Completeness Verification (MANDATORY — after all pre-contexts are generated)

After generating ALL pre-context.md files (and after SBI Numbering Verification above), verify that each pre-context contains the required sections from the template. This step is **BLOCKING** — do NOT proceed to Phase 4-3 if required sections are missing.

For each pre-context.md, check the following sections exist:

| # | Section | Required? | Empty Value |
|---|---------|-----------|-------------|
| 1 | Runtime Exploration Results | Yes (rebuild + Phase 1.5 done) | "Skipped — [reason]" |
| 2 | Source Reference (3 columns: File Path, Role, Rebuild Target) | Always | — |
| 3 | Source Behavior Inventory (SBI table) | Always | — |
| 4 | UI Component Features | Frontend/fullstack only | "N/A — no UI components" or "N/A — backend-only" |
| 5 | Interaction Behavior Inventory | Frontend/fullstack only | "N/A — no interactive UI in this Feature" |
| 6 | Foundation Decisions | If Framework ≠ "custom" | "N/A — custom framework" or "No Foundation decisions" |
| 7 | Foundation Dependencies | If Framework ≠ "custom" | "None — this Feature has no Foundation dependencies." |
| 8 | Naming Remapping | If project name changed | "None — no original project name references" |
| 9 | Static Resources | Always | "None" |
| 10 | Environment Variables | Always | "None" |
| 11 | Feature Contracts | Always | "None — this Feature operates independently." |
| 12 | For /speckit.specify | Always | — |
| 13 | For /speckit.plan | Always | — |
| 14 | For /speckit.analyze | Always | — |

Display verification result:
```
✅ Pre-context Completeness Verification:
  F001-shell:     14/14 sections ✓
  F002-i18n-theme: 14/14 sections ✓
  ...
  All [N] pre-contexts complete.
```

**Completeness Score**: Each pre-context must score 14/14 sections (or the applicable subset for backend-only projects). Display the score per Feature. If ANY Feature scores below its required count, the verification FAILS.

**Cross-check against template**: For each pre-context, verify that the section headings match those in [pre-context-template.md](../templates/pre-context-template.md). Missing headings = missing sections, even if content exists elsewhere in the file under a different heading.

If any section is missing, add it BEFORE proceeding:
```
❌ Pre-context Completeness FAILED:
  F003-providers: 12/14 — missing Runtime Exploration Results, Static Resources
  F007-files: 13/14 — missing Interaction Behavior Inventory
  → Adding missing sections now...
```

### 4-3. Source Coverage Baseline (BLOCKING)

> ⚠️ **This sub-phase is MANDATORY and BLOCKING.** Do NOT skip Steps 2-3 even if the deliverables are already generated. Low source coverage means Features are incomplete — the unmapped source files likely represent functionality that needs to be assigned to existing Features or defined as new Features. **Proceeding to Phase 4-4 without completing Step 3 classification is NOT allowed.**

After generating all deliverables, perform an automated source surface measurement to quantify how much of the original source code is covered by the extracted Features.

#### Step 1 — Automated Surface Measurement

Parse the original source (target directory) and compare against the generated artifacts. Reuse detection patterns from Phase 2 — do NOT re-parse from scratch; compare Phase 2 results against the generated artifact inventories:

| Metric | Source (parse from target) | Mapped (from artifacts) | Comparison Method |
|--------|---------------------------|------------------------|-------------------|
| Source files | Glob all source files (exclude vendor/build/test dirs) | Count files listed in all pre-context.md Source Reference tables | File path matching |
| API endpoints | Parse route definitions (Phase 2-2 tech-stack-specific patterns) | Count entries in api-registry.md | Method + path matching |
| DB models/entities | Parse model/entity definitions (Phase 2-1 patterns) | Count entries in entity-registry.md | Entity name matching |
| Source behaviors | Count exported functions/methods (Phase 2-6) | Count entries in all pre-context.md Source Behavior Inventory tables | Function name matching |
| UI component features | Count library features (Phase 2-7, if applicable) | Count entries in all pre-context.md UI Component Features tables | Feature name matching |
| Micro-interaction inventory | Count patterns (Phase 2-7b, if applicable) | Count entries in all pre-context.md Interaction Behavior Inventory tables | Feature + screen matching |
| Test files | Glob test file patterns (`**/*test*`, `**/*spec*`, `**/__tests__/**`) | Count test files listed in pre-context.md Source Reference | File path matching |
| Business rules | Count rules identified in Phase 2-3 | Count entries in business-logic-map.md | Rule ID matching |

Display the metrics table to the user:

```
📊 Source Coverage Analysis:

| Metric               | Source | Mapped | Coverage |
|----------------------|--------|--------|----------|
| Source files         | 87     | 72     | 82.8%    |
| API endpoints        | 45     | 43     | 95.6%    |
| DB entities          | 20     | 19     | 95.0%    |
| Test files      | 34     | 28     | 82.4%    |
| Source behaviors  | 85     | 72     | 84.7%    |
| UI features      | 12     | 12     | 100%     |
| Business rules   | 42     | 40     | 95.2%    |
```

#### Step 2 — Unmapped Items Identification

For each metric category, identify items in the source that were NOT mapped to any Feature:
- Source files not listed in any pre-context.md Source Reference
- Endpoints parsed from routes but not in api-registry.md
- Models parsed from source but not in entity-registry.md
- Source behaviors (exported functions) not listed in any pre-context.md Source Behavior Inventory
- UI component features not listed in any pre-context.md UI Component Features (if applicable)
- Test files not associated with any Feature

Group the unmapped items by apparent category/module (e.g., "middleware files", "admin endpoints", "utility models") to minimize the number of user interactions in Step 3.

**Project identity renaming**: If Phase 0 Question 3 established a new project name, highlight items containing the original project name prefix in the unmapped items list (e.g., "⚠️ CherryINOAuth — contains original project name"). When the user classifies these items, suggest renamed versions using the new project naming (e.g., "AngduINOAuth" or "INOAuth").

#### Step 3 — Classification (HARD STOP)

For each unmapped group, use AskUserQuestion and WAIT for the user's response:

```
📋 Unmapped Items: [Group Name] ([N] items)

  [file/endpoint/entity list]

Classification:
```

Options:
- **"Assign to Feature [FID]"** — Add to existing Feature's pre-context.md Source Reference. Ask which FID if not obvious from context.
- **"Create new Feature"** — Collect Feature name and description from user. Add to roadmap.md Feature Catalog (with next available ID). Generate pre-context.md for the new Feature.
- **"Cross-cutting concern"** — Flag for constitution-seed.md update (add principle) or future infrastructure Feature. Record in coverage-baseline.md.
- **"Intentional exclusion"** — Record with one of the following reasons. **Rebuild mode restrictions apply:**
  - `deprecated` — Code exists but is no longer used in source app. ✅ Allowed in rebuild.
  - `replaced` — Functionality exists but will be replaced by a different approach (e.g., Dexie → better-sqlite3). ⚠️ **Rebuild: the replacement MUST be captured in a Feature's pre-context as a migration target.** Simply marking as "replaced" without specifying where the replacement lives is NOT allowed.
  - `third-party` — External package that will be imported, not reimplemented. ✅ Allowed.
  - `deferred` — Will be implemented later. ⚠️ **Rebuild: MUST be added to roadmap.md as a T3 Feature or explicitly merged into an existing Feature.** "Deferred" without a Feature assignment means the functionality is silently dropped.
  - `out-of-scope` — Not code (docs, scripts, build config, tests). ✅ Allowed.
  - `covered-differently` — Same functionality, different implementation. ⚠️ **Rebuild: the "different" approach MUST be documented in the owning Feature's pre-context.** Which Feature owns this? What's the alternative approach?

  ```
  ❌ WRONG (rebuild): "covered-differently — IndexedDB migration code" → no Feature assigned, no alternative documented → functionality silently lost
  ✅ RIGHT (rebuild): "covered-differently — IndexedDB (Dexie) migration → F001 app-shell pre-context § Data Migration notes better-sqlite3 migration strategy"
  ```

**Empty/blank response = NOT classified — re-ask.** You MUST obtain an explicit classification for every group.

If user selects "Create new Feature" for any items:
- Assign the next available Feature ID (continuing the existing sequence)
- Add to roadmap.md Feature Catalog (with appropriate Tier for core scope, or dependency position for full scope)
- Generate pre-context.md for the new Feature using the [pre-context-template](../templates/pre-context-template.md)
- The new Feature will be picked up by smart-sdd when the pipeline runs

#### Step 3b — Post-Classification Coverage Update

After classifying ALL unmapped groups:

1. **Recalculate coverage metrics**: Include newly assigned items and new Features from Step 3
2. **Display updated metrics**:
   ```
   📊 Updated Source Coverage (after classification):

   | Metric       | Before | After | Change |
   |--------------|--------|-------|--------|
   | Source files | 45.5%  | 89.2% | +43.7% |
   | ...          | ...    | ...   | ...    |

   New Features created: [count]
   Items assigned to existing Features: [count]
   Intentional exclusions: [count]
   ```
3. **If source file coverage is still below 70%** after classification: Display a warning and ask the user whether to continue or re-examine:
   ```
   ⚠️ Source file coverage is still [X]% after classification.
   This means [N] source files are not accounted for in any Feature.
   ```

#### Step 4 — Generate coverage-baseline.md

Generate `specs/_global/coverage-baseline.md` using the [coverage-baseline-template](../templates/coverage-baseline-template.md):
- Populate Surface Metrics table with the **final** measured values (after Step 3b update)
- Record all unmapped items with their user-assigned classifications from Step 3
- Record all intentional exclusions with their reasons and descriptions
- Add coverage notes from the classification process

**Cross-Verification (MANDATORY)**: After generating coverage-baseline.md, verify data consistency:

1. **SBI total consistency**: The "Source behaviors" count in Surface Metrics MUST equal the authoritative total from [SBI Numbering Verification](#sbi-numbering-verification-mandatory--after-all-pre-contexts-are-generated) (Phase 4-2). If they differ, use the SBI Numbering Verification total (it counts actual B### entries).
2. **Per-Feature SBI ranges**: The Per-Feature Coverage table's SBI ranges MUST match the ranges displayed in the SBI Numbering Verification output. Copy them directly — do not recalculate manually.
3. **Display verification**:
   ```
   ✅ Coverage-Baseline Cross-Verification:
     Surface Metrics SBI total: [N] = SBI Numbering Verification total: [N] ✓
     Per-Feature ranges match SBI Verification output ✓
   ```
   If mismatch:
   ```
   ❌ Coverage-Baseline Mismatch:
     Surface Metrics says [X] but SBI Verification counted [Y]
     → Correcting to [Y]
   ```

### 4-4. Completion Report

Report the complete list of generated deliverables and next-step guidance to the user:

```
Generation complete:
- specs/_global/roadmap.md
- specs/_global/constitution-seed.md
- specs/_global/entity-registry.md
- specs/_global/api-registry.md
- specs/_global/business-logic-map.md
- specs/_global/stack-migration.md          (if New Stack strategy)
- specs/_global/coverage-baseline.md
- specs/F001-xxx/pre-context.md
- specs/F002-xxx/pre-context.md
- ...
- .env.example                                    (rebuild only — if env vars detected)
- specs/_global/speckit-prompt.md             (spec-kit standalone usage prompt)

SBI: [N] source behaviors tracked (B001–B[N]) across [M] Features
Demo Groups: [K] groups defined — Integration Demos trigger when all Features in a group are verified

Next steps:
  /smart-sdd pipeline       — Run the full SDD pipeline for rebuild (recommended)
  /smart-sdd adopt          — Run the adoption pipeline to wrap existing code with SDD docs
  /smart-sdd parity          — Check implementation parity against original source (after pipeline completes)

  Or use spec-kit standalone with the generated prompt:
  Copy specs/_global/speckit-prompt.md into CLAUDE.md, then run spec-kit commands directly.
  The prompt guides which artifacts to read before each command.

smart-sdd will automatically:
  1. Finalize constitution based on constitution-seed.md
  2. Progress Features in Release Group order (specify → plan → tasks → analyze → implement → verify → merge)
  3. Inject cross-Feature context from pre-context.md, business-logic-map.md, and registries at each step
  4. Update entity-registry.md and api-registry.md as Features are completed
  5. Track SBI coverage (B### → FR-### mapping) and Demo Group progress in sdd-state.md
```

### 4-5. Completion Analysis Report Generation

After all Phase 4 artifacts are generated, create the Completion Analysis Report:

1. Read the shared template: `~/.claude/skills/shared/reference/completion-report.md`
2. Populate all sections using data from generated artifacts:
   - §1 Project Profile: from Phase 1 scan results + sdd-state.md
   - §2 Feature Catalog: from roadmap.md
   - §3 SBI Summary: aggregate from all pre-context.md files
   - §4 Entity & API: from entity-registry.md + api-registry.md
   - §5 Quality Assessment: per-phase confidence (record during each phase)
   - §6 Recommendations: based on scope (core vs full), scale, and any unresolved questions
   - §7 Artifact Inventory: list all generated files with paths
3. Write to `specs/_global/completion-report.md`
4. Display summary in the Phase 4-4 Completion Report output:
   ```
   📊 Completion Analysis Report saved to specs/_global/completion-report.md

   Key metrics:
   - [N] Features across [N] Release Groups
   - [N] SBI entries (P1: [N], P2: [N], P3: [N])
   - [N] entities, [N] APIs
   - Recommended next step: [adopt/rebuild/explore]
   ```

### 4-6. Completion Checkpoint (commit + tag)

After displaying the Completion Report, create a git checkpoint so the user can reset smart-sdd pipeline state back to this point:

1. **Stage all reverse-spec artifacts**:
   ```bash
   git add specs/ .env.example .gitignore
   ```

2. **Commit**:
   ```bash
   git commit -m "chore: reverse-spec analysis complete — [N] Features extracted"
   ```

3. **Tag** (for smart-sdd reset to reference):
   ```bash
   git tag -f reverse-spec-complete
   ```

4. **Playwright MCP CDP notice** (if CDP was used in Phase 1.5):
   If Playwright MCP was configured with `--cdp-endpoint` for Electron Runtime Exploration, display the appropriate notice based on stack strategy:

   **Same stack (Electron rebuild)** — CDP mode is reusable for `/smart-sdd` verify:
   ```
   ℹ️ Playwright MCP is in CDP mode (--cdp-endpoint http://localhost:9222).
      This is fine for /smart-sdd — when verify needs to test the new Electron app,
      start it with --remote-debugging-port=9222 and Playwright will connect automatically.
   ```

   **New stack (non-Electron)** — CDP mode must be restored to standard:
   ```
   ⚠️ Playwright MCP is still in CDP mode (--cdp-endpoint http://localhost:9222).
      Your new stack is not Electron, so restore standard browser mode before /smart-sdd:
        claude mcp remove playwright -s user
        claude mcp add --scope user playwright -- npx @playwright/mcp@latest
      Then restart Claude Code.
   ```

   Skip this notice if Phase 1.5 was skipped or CDP was not configured.

5. Display:
   ```
   📌 Checkpoint: Tagged as 'reverse-spec-complete'
      Use /smart-sdd reset to return to this point if you need to restart the pipeline.
   ```

> **If not a git repo**: Skip this step entirely. Display: "ℹ️ No git repository — checkpoint not created."
> **If tag already exists**: Overwrite with `-f` flag (user may have run reverse-spec multiple times).
