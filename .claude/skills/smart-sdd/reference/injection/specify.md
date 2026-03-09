# Context Injection: Specify + Clarify

> Per-command injection rules for `/smart-sdd specify [FID]` and the conditional Clarify sub-step.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Specify

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.specify" section | Relevant Feature only |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Behavior Inventory" section | **If present (rebuild/adoption/add mode with SBI)** — ensure FR-### cover all P1/P2 behaviors |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "UI Component Features" section | **If present (frontend/fullstack rebuild)** — ensure FR-### cover all UI features |
| `BASE_PATH/business-logic-map.md` | Relevant Feature section | Filtered by Feature ID. **If file does not exist (greenfield/add), skip entirely** |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Reference" section | Reference to original file list. **If N/A (greenfield), skip** |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Runtime Exploration Results" section | **If present (Phase 1.5 completed)** — reference observed UI layouts, user flows, and errors when drafting FR/SC. **If section says "Skipped"**, proceed without runtime context |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Naming Remapping" section | **If present (project identity changed)** — use new identifiers in requirements |

### Source Reference Path Resolution

File paths in pre-context.md's Source Reference and Static Resources are **relative to Source Root** (i.e., the original source directory). The pre-context.md header shows `Source Root: $SOURCE_ROOT` as a placeholder — the actual value is stored in `sdd-state.md` → `Source Path` field.

To resolve file paths at runtime:

1. Read `Source Path` from `sdd-state.md` to get the Source Root value
2. For each relative path in Source Reference / Static Resources, resolve as: `[Source Path]/[relative path]`
3. **Before injecting**, verify that the resolved files actually exist. If a file is missing (e.g., source was moved/deleted), note it in the Checkpoint: "⚠️ Source file not found: [resolved path]"

| Mode | Source Path (= Source Root) | Path Resolution |
|------|---------------------------|-----------------|
| **reverse-spec (rebuild)** | Absolute path (e.g., `/Users/dev/old-project`) | Prepend Source Path to each relative file in Source Reference |
| **add (incremental)** | `.` (CWD) | Files are in the current working directory — resolve relative to CWD. Read the existing source to understand current implementation before specifying changes |
| **greenfield** | `N/A` | Skip Source Reference entirely — no existing source to reference |

### Feature Section Filtering Rules (business-logic-map.md)

1. Find the section in `business-logic-map.md` that starts with the `## F[ID]` heading
2. Extract the Core Rules, Validation Logic, and Workflows sections for that Feature
3. Extract rules related to the Feature from the Cross-Feature Rules section

### Injected Content

- **Feature summary**: Feature description and scope from pre-context
- **Draft requirements (FR-###)**: Draft Functional Requirements extracted from pre-context
- **Draft acceptance criteria (SC-###)**: Draft Success Criteria / Acceptance Scenario extracted from pre-context. For UI Features, SCs should include verifiable UI actions where possible (e.g., "User enters credentials in login form and clicks Submit → dashboard screen is displayed"). These SC descriptions are converted to automated verification actions in the demo script's Coverage header
- **Source behavior inventory**: If present, the function-level behavior list with priorities — remind that each P1/P2 behavior should map to at least one FR-###. This prevents functionality loss during rebuild. **NEW entries** (Origin=`new`): Treat as new requirements to be specified, not as coverage of existing code. They should still map to FR-### but do not represent original source behaviors
- **UI component features**: If present, the third-party UI library capabilities — remind that each UI feature should map to an FR-###. These features (toolbar items, editing modes, plugins) are invisible to function-level analysis
- **Runtime exploration observations**: If present, the per-screen UI observations from Phase 1.5 runtime exploration — observed UI layouts inform FR descriptions, observed user flows inform SC scenarios, observed errors inform edge case SCs. If the section says "Skipped", note it and proceed without runtime context
- **Business rules**: List of rules for the Feature from business-logic-map (skipped if business-logic-map.md does not exist)
- **Edge cases**: Edge cases found in pre-context and business-logic-map
- **Original source reference**: File list from Source Reference (skipped if Source Reference is N/A)
- **Naming remapping**: If Naming Remapping section exists in pre-context, remind that requirements and descriptions should use the new identifiers (e.g., "AngduProvider" not "CherryProvider")

### Preceding Feature Result Reference

When a completed preceding Feature exists and the current Feature depends on it:
1. Check the dependency relationship in `BASE_PATH/roadmap.md`
2. If the preceding Feature's `SPEC_PATH/[NNN-feature]/spec.md` exists, reference the relevant requirements
3. Display "Preceding Feature [FID] spec referenced" information at the Checkpoint

### Checkpoint Display Content

Show the **actual content** that will be injected, so the user can review requirements, acceptance criteria, and business rules before spec creation:

```
📋 Context for Specify execution:

Feature: [FID] - [Feature Name]

── Feature Summary ───────────────────────────────
[Actual feature description and scope from pre-context]

── Draft Requirements ────────────────────────────
[List each FR-### with its full description]
  FR-001: ...
  FR-002: ...

── Draft Acceptance Criteria ─────────────────────
[List each SC-### with its full description]
  SC-001: ...
  SC-002: ...

── Source Behavior Inventory (rebuild/adoption) ──
[If present in pre-context — list P1/P2 behaviors with B### IDs]
  P1: B001 registerUser(), B002 loginUser(), B003 requireAuth() ...
  P2: B004 resetPassword(), B005 updateProfile() ...
  ⚠️ Ensure each P1/P2 behavior maps to at least one FR-### with [source: B###] tag.
  Example: FR-001: User registration with email verification [source: B001]

── UI Component Features (frontend/fullstack rebuild) ─
[If present in pre-context — list UI library capabilities]
  NoteEditor (@toast-ui/editor): Bold/Italic toolbar, WYSIWYG mode, ...
  ⚠️ Ensure each UI feature maps to an FR-###.

── Runtime Exploration Observations ─────────────
[If present in pre-context — show per-screen observations]
  Layout: [observed layout pattern, e.g., three-column, split-pane]
  Key Elements: [observed interactive elements, forms, tables]
  User Flows: [observed navigation paths and interactions]
  Errors/Edge Cases: [observed error states or edge cases]
  ⚠️ Reference observed UI layouts when describing FR scope,
    observed user flows when writing SC scenarios,
    and observed errors when defining edge case SCs.
[If "Skipped" — display: "Runtime exploration skipped — proceeding without runtime context."]

── Business Rules (from business-logic-map) ──────
[List each business rule with its description]

── Edge Cases ────────────────────────────────────
[List each edge case]

── Original Source Files ─────────────────────────
[List of source files for reference]

── Preceding Feature References ──────────────────
[If applicable: what was referenced from preceding Features]

── Functional Enablement Chain ─────────────────
[If present in pre-context — show enablement/blocking relationships]
  Enables → F005-chat: Provider settings panel works
  Blocked by ← F001-shell: Window frame config applied
  ⚠️ Ensure SC-### cover the functional interfaces that downstream Features depend on.
    These interfaces are what downstream Features need to work at runtime.
[If section empty, absent, or "None": skip this block entirely]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with speckit-specify
  - Request modifications (add/remove/change requirements or criteria)
  - Edit pre-context.md or business-logic-map.md directly before proceeding
```

### Post-Execution Verification Sequence

> **⚠️ SUPPRESS spec-kit output**: `speckit-specify` prints messages like "Ready for /speckit.clarify or /speckit.plan." — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the verification steps and Review Display below. If context limit prevents continuing, show instead: `✅ speckit-specify executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.`

After `speckit-specify` completes and BEFORE assembling the Review Display, run these checks in order:

1. **SBI Accuracy Cross-Check** (if applicable — rebuild/adoption with SBI)
2. **Platform Constraint FR Verification** (if applicable — pre-context has Platform Constraints)
3. **Edge Case Coverage Check** (if applicable — pre-context has Edge Cases)
4. **Assemble Review Display** (include any ⚠️ warnings from steps 1-3)
5. **HARD STOP** (ReviewApproval)

### SBI Accuracy Cross-Check (rebuild/adoption mode)

> **Purpose**: SBI text can be misinterpreted without checking the actual source. Example: "Manage sidebar tabs (assistants, topics, sessions)" was interpreted as 3 separate tabs, but the original had 2 tabs (sessions was a conditional view within topics). Reading the source prevents such misinterpretation.

If pre-context has SBI entries AND Source Reference files:

1. Read the original source files **relevant to P1/P2 SBI entries** (resolved via Source Reference Path Resolution above — only files whose functions appear in P1/P2 SBI, not all Source Reference files)
2. For each P1/P2 SBI entry that maps to an FR-###, spot-check:
   - Does the FR description match what the source code actually does?
   - Are counts correct? (e.g., tab count, form field count, block type count)
   - Are conditional behaviors captured? (e.g., feature flags, platform-specific branches)
3. If any discrepancy is found, append to Review Display:
   ```
   ── ⚠️ SBI Accuracy Concerns ─────────────────────
   B105 → FR-012: SBI says "3 sidebar tabs" but source HomeTabs.tsx
     shows 2 tabs (Sessions is conditional view within Topics tab).
   → Recommend updating FR-012 before approval.
   ────────────────────────────────────────────────────
   ```
4. **If visual references exist** (`specs/reverse-spec/visual-references/`): Cross-reference UI structure claims in FRs against reference screenshots. Visual references are the ground truth for tab counts, layout structure, and visible elements.

**Skip if**: No SBI entries, or Source Reference = "N/A" (greenfield).

### Platform Constraint FR Verification

> **Purpose**: Platform Constraints from preceding Features (in pre-context.md) impose requirements that MUST appear as explicit FRs. Missing these causes critical bugs (e.g., frameless window with no drag region).

If pre-context has a "Platform Constraints from Preceding Features" section with entries:

1. For each Platform Constraint entry, check whether an FR-### addresses the required action
2. If any constraint is NOT covered by an FR, append to Review Display:
   ```
   ── ⚠️ Platform Constraint Coverage Gap ──────────
   Constraint: "Frameless window" (F001-shell → frame: false)
   Required: -webkit-app-region: drag on navbar, no-drag on interactive elements
   ⚠️ No FR-### found that addresses this constraint.
   → Recommend adding an FR for window drag region.
   ────────────────────────────────────────────────────
   ```

**Skip if**: No Platform Constraints section, or section says "None".

### Edge Case Coverage Check

> **Purpose**: Edge cases from pre-context are often listed as free text without structured scenarios (expected result + verify method). This check ensures each edge case is covered by at least one SC-###, so they don't surface as surprise bugs during implementation.

If pre-context contains an "Edge Cases" section with entries:

1. For each edge case, search `spec.md` SC-### descriptions for a matching scenario
2. Build a coverage matrix and append to Review Display:
   ```
   ── ⚠️ Edge Case Coverage ─────────────────────
   | Edge Case | Covered by SC | Expected Result | Verify Method |
   |-----------|--------------|-----------------|---------------|
   | Empty form submit | SC-005 | Validation error shown | verify-state .error visible |
   | Network timeout | NOT COVERED | Retry or error toast | — |
   | Max-length input | SC-012 | Input truncated | verify-state input maxLength "100" |

   ⚠️ [N] edge cases have no corresponding SC-###.
   ────────────────────────────────────────────────
   ```
3. This is a **warning** (NOT blocking) — included in Review Display. The user decides whether to add missing SCs or proceed without them.

**Skip if**: No Edge Cases section in pre-context, or section is empty/contains only "N/A".

### Review Display Content

After `speckit-specify` completes and post-execution checks above have run:

**Files to read**:
1. `specs/{NNN-feature}/spec.md` — Read the **entire file** and extract FR-###, SC-###, scope sections
2. `BASE_PATH/features/{FID}-{name}/pre-context.md` → "Draft Requirements" and "Draft Acceptance Criteria" sections (for diff comparison)

**Display format**:
```
📋 Review: spec.md for [FID] - [Feature Name]
📄 File: specs/{NNN-feature}/spec.md

── Requirements ─────────────────────────────────
[List each FR-### with its full description from spec.md]
  FR-001: ...
  FR-002: ...

── Success Criteria ─────────────────────────────
[List each SC-### with its full description from spec.md]
  SC-001: ...
  SC-002: ...

── Scope ────────────────────────────────────────
[In-scope and out-of-scope items from spec.md]

── Differences from Draft ───────────────────────
[Compare spec.md content with pre-context.md drafts:
 - Added: requirements/criteria that spec-kit added beyond the drafts
 - Removed: draft items that were dropped
 - Changed: items whose scope or description significantly changed]

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/spec.md
You can open and edit this file directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Clarify (conditional — triggered after Specify Review)

> Clarify is a conditional sub-step. It runs **only** when the spec.md scan detects ambiguities (see SKILL.md "Clarify Trigger" section). If no ambiguities are found, skip directly to Plan.

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/spec.md` | Entire file | Scan for ambiguity markers and vague qualifiers |

### Ambiguity Scan

Before executing `speckit-clarify`, scan `spec.md` for:
1. **Explicit markers**: `[NEEDS CLARIFICATION]`, `[TBD]`, `[TODO]`, `???`, `<placeholder>`
2. **Vague qualifiers**: Adjectives without measurable criteria (e.g., "fast", "scalable", "intuitive", "robust")

If **no ambiguities found**: Display "✅ No critical ambiguities detected in spec.md. Proceeding to plan." and skip this section entirely.

### Checkpoint Display Content

If ambiguities are found:

```
📋 Ambiguities detected in spec.md for [FID] - [Feature Name]

── Explicit Markers ─────────────────────────────
[List each marker with its location in spec.md:
 - Line/section: "[NEEDS CLARIFICATION] ..."
 - Line/section: "[TBD] ..."]

── Vague Qualifiers ─────────────────────────────
[List each vague term with context:
 - "fast response time" — no measurable threshold defined
 - "scalable architecture" — no concrete scaling target]

──────────────────────────────────────────────────
⚠️ Running speckit-clarify to resolve these ambiguities.
```

### Injected Content

- The list of detected ambiguities (for speckit-clarify to focus on)
- `speckit-clarify` will interactively ask up to 5 questions and update spec.md directly

### Review Display Content

After `speckit-clarify` completes:

**Files to read**:
1. `specs/{NNN-feature}/spec.md` — Re-read the **entire file** and identify what changed (compare with pre-clarify content)

**Display format**:
```
📋 Review: Clarify results for [FID] - [Feature Name]
📄 File: specs/{NNN-feature}/spec.md

── Resolved Ambiguities ────────────────────────
[For each ambiguity that was resolved:
 - Before: "[TBD] response time"
 - After: "Response time under 200ms for 95th percentile"]

── Remaining Ambiguities (if any) ──────────────
[List any markers/qualifiers still present in spec.md]

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/spec.md
You can open and edit this file directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**If remaining ambiguities exist**: Offer to re-run clarify or proceed.

**HARD STOP** (ReviewApproval): Options: "Approve", "Run clarify again", "I've finished editing". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Post-Step Update Rules

Update `sdd-state.md` per generic step-completion rules in [state-schema.md](../state-schema.md). Additionally:
- Populate the Feature Mapping table: record spec-kit Name, spec-kit Path, and Branch (spec-kit creates the branch during specify)
- **SBI Coverage Update** (rebuild/adoption/add with SBI): After specify completes, scan the generated `spec.md` for `[source: B###]` tags. For each found tag:
  - Update `sdd-state.md` → Source Behavior Coverage table: set FR column to the FR-### ID, Feature column to the Feature ID, Status to `🔄 in_progress`
  - This establishes the SBI → FR mapping that will be confirmed during verify
  - For NEW entries (Origin=`new`): same process, but these entries are tracked separately in coverage metrics
- No other Global Evolution Layer artifact updates
