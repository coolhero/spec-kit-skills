# Context Injection: Specify + Clarify

> Per-command injection rules for `/smart-sdd specify [FID]` and the conditional Clarify sub-step.
> For shared patterns (HARD STOP, Checkpoint, --auto, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

**BASE_PATH**: `./specs/reverse-spec/` relative to CWD (or the path specified with `--from`)
**SPEC_PATH**: `./specs/` relative to CWD (spec-kit feature output path. Format: `specs/{NNN-feature}/`)

---

## Specify

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.specify" section | Relevant Feature only |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Behavior Inventory" section | **If present (rebuild mode)** — ensure FR-### cover all P1/P2 behaviors |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "UI Component Features" section | **If present (frontend/fullstack rebuild)** — ensure FR-### cover all UI features |
| `BASE_PATH/business-logic-map.md` | Relevant Feature section | Filtered by Feature ID. **If file does not exist (greenfield/add), skip entirely** |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Reference" section | Reference to original file list. **If N/A (greenfield), skip** |
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
- **Draft acceptance criteria (SC-###)**: Draft Success Criteria / Acceptance Scenario extracted from pre-context
- **Source behavior inventory**: If present, the function-level behavior list with priorities — remind that each P1/P2 behavior should map to at least one FR-###. This prevents functionality loss during rebuild
- **UI component features**: If present, the third-party UI library capabilities — remind that each UI feature should map to an FR-###. These features (toolbar items, editing modes, plugins) are invisible to function-level analysis
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

── Source Behavior Inventory (rebuild only) ──────
[If present in pre-context — list P1/P2 behaviors]
  P1: registerUser(), loginUser(), requireAuth() ...
  P2: resetPassword(), updateProfile() ...
  ⚠️ Ensure each P1/P2 behavior maps to at least one FR-###.

── UI Component Features (frontend/fullstack rebuild) ─
[If present in pre-context — list UI library capabilities]
  NoteEditor (@toast-ui/editor): Bold/Italic toolbar, WYSIWYG mode, ...
  ⚠️ Ensure each UI feature maps to an FR-###.

── Business Rules (from business-logic-map) ──────
[List each business rule with its description]

── Edge Cases ────────────────────────────────────
[List each edge case]

── Original Source Files ─────────────────────────
[List of source files for reference]

── Preceding Feature References ──────────────────
[If applicable: what was referenced from preceding Features]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with speckit-specify
  - Request modifications (add/remove/change requirements or criteria)
  - Edit pre-context.md or business-logic-map.md directly before proceeding
```

### Review Display Content

After `speckit-specify` completes:

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

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing"

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

**HARD STOP** (ReviewApproval): Options: "Approve", "Run clarify again", "I've finished editing"

---

## Post-Step Update Rules

Update `sdd-state.md` per generic step-completion rules in [state-schema.md](../state-schema.md). Additionally:
- Populate the Feature Mapping table: record spec-kit Name, spec-kit Path, and Branch (spec-kit creates the branch during specify)
- No Global Evolution Layer artifact updates
