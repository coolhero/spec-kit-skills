# Context Injection: Adopt — Specify

> Per-command injection rules for the **specify** step within `/smart-sdd adopt`.
> This is a variant of the standard `specify` injection — optimized for wrapping existing code with SDD documentation rather than defining new features.
> For shared patterns (HARD STOP, Checkpoint, --auto, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Key Difference from Standard Specify

Standard specify: "Define what to build" — creates requirements for new functionality.
Adopt specify: **"Extract what exists"** — documents the current code's behavior as FR/SC, without inventing new requirements.

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.specify" section | Relevant Feature only |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Behavior Inventory" section | **REQUIRED** — each P1/P2 SBI entry must map to at least one FR-### |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Reference" section | Source files to read for behavior extraction |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "UI Component Features" section | **If present** — ensure FR-### cover all UI features |
| `BASE_PATH/business-logic-map.md` | Relevant Feature section | Filtered by Feature ID |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Naming Remapping" section | **If present (project identity changed)** |

### Source File Reading

Unlike standard specify, adopt-specify reads the **actual source files** listed in Source Reference to extract precise behavior descriptions:

1. Read `Source Path` from `sdd-state.md` to get the Source Root
2. For each file in Source Reference, resolve as `[Source Path]/[relative path]`
3. Read the source files to understand what the code actually does
4. Use the source code as the ground truth for FR/SC extraction

---

## Injected Content

> **Framing**: "Document the current code's behavior. Do NOT invent new requirements, suggest improvements, or add TODOs. Extract only what the code does today."

- **Feature summary**: Feature description from pre-context
- **Source Behavior Inventory**: SBI entries with B### IDs — **each P1/P2 entry MUST map to at least one FR-###**
  - Include `[source: B###]` tag on each FR that maps to an SBI entry
  - Format: `FR-001: [description] [source: B001]`
- **Source code reference**: Actual source files from Source Reference — the agent reads these to extract precise behavior
- **Draft requirements (FR-###)**: Draft from pre-context, but refined with actual source reading
- **Draft acceptance criteria (SC-###)**: Derived from actual code behavior, not aspirational targets
- **Business rules**: From business-logic-map.md (if exists)
- **UI component features**: If present — ensure each UI feature maps to an FR-###
- **Edge cases**: Observed edge case handling in the existing code

### Adoption-Specific Instructions

The following instructions are injected as guidance for `speckit-specify`:

1. **Extract, don't invent**: Every FR-### must correspond to behavior that exists in the current code. Do NOT add requirements for features that are TODO, commented out, or not yet implemented.
2. **B### mapping is mandatory**: Each P1/P2 SBI entry must appear as `[source: B###]` on at least one FR-###. If a behavior can't be mapped, flag it.
3. **SC-### must be verifiable against existing code**: Success criteria should describe what the code currently achieves, not what it should ideally do.
4. **Pre-existing issues go in Edge Cases**: Known bugs, incomplete error handling, or missing validation should be noted as edge cases, not as FR-###.

---

## Checkpoint Display Content

```
📋 Context for Adopt-Specify execution:

Feature: [FID] - [Feature Name]
Mode: ADOPTION — Extracting existing behavior as SDD requirements

── Source Behavior Inventory ────────────────────
[List all SBI entries with B### IDs and priorities]
  B001 (P1): registerUser() — Creates new user account
  B002 (P1): loginUser() — Authenticates with email/password
  B003 (P2): resetPassword() — Password reset flow
  ...
  ⚠️ Each P1/P2 entry MUST map to at least one FR-### with [source: B###] tag.

── Draft Requirements (from pre-context) ────────
[List each FR-### draft with source mapping]
  FR-001: ... [source: B001]
  FR-002: ... [source: B002]

── Draft Acceptance Criteria ────────────────────
[List each SC-### draft]

── Source Files ─────────────────────────────────
[List of source files that will be read for extraction]

── Business Rules ───────────────────────────────
[From business-logic-map.md, if available]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with speckit-specify
  - Request modifications (adjust requirements or SBI mappings)
```

---

## Review Display Content

After `speckit-specify` completes:

**Files to read**:
1. `specs/{NNN-feature}/spec.md` — Read the entire file
2. `BASE_PATH/features/{FID}-{name}/pre-context.md` → SBI table (for B### coverage check)

**Display format**:
```
📋 Review: spec.md for [FID] - [Feature Name] (Adoption)

── Requirements ─────────────────────────────────
[List each FR-### with its description]
  FR-001: ... [source: B001]
  FR-002: ... [source: B002]

── Success Criteria ─────────────────────────────
[List each SC-###]

── SBI Coverage ─────────────────────────────────
  P1: [N]/[N] mapped ([%])
  P2: [N]/[N] mapped ([%])
  [⚠️ Unmapped P1: B005 — funcName (if any)]
  [⚠️ Unmapped P2: B012 — funcName (if any)]

── Adoption Notes ───────────────────────────────
  - Behaviors extracted: [N] from existing code
  - TODO/unimplemented items excluded: [N] (if any)
  - Pre-existing issues noted: [N] (if any)

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/spec.md
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing"

---

## Post-Step Update Rules

1. Update `sdd-state.md` per generic step-completion rules
2. Update `sdd-state.md` → Source Behavior Coverage section:
   - For each FR-### with `[source: B###]` tag, update the SBI entry:
     - `FR` column: FR-### ID
     - `Feature` column: Feature ID
     - `Status` column: `🔄 in_progress`
3. Populate the Feature Mapping table (same as standard specify)
