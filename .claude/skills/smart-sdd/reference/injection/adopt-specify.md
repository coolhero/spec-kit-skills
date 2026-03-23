# Context Injection: Adopt — Specify

> Per-command injection rules for the **specify** step within `/smart-sdd adopt`.
> This is a variant of the standard `specify` injection — optimized for wrapping existing code with SDD documentation rather than defining new features.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Key Difference from Standard Specify

Standard specify: "Define what to build" — creates requirements for new functionality.
Adopt specify: **"Extract what exists"** — documents the current code's behavior as FR/SC, without inventing new requirements.

---

## Domain Module Filtering (per _resolver.md Step 5)

After domain modules are merged (Steps 1-4), retain ONLY these sections for `specify (adopt)`:

| Active (retain) | Skipped (discard from context) |
|-----------------|-------------------------------|
| S0, S1, S5, S9, A2, A3, A5 | S2, S3, S6, S7, S8 |

Display in Checkpoint: `📊 Domain: [N] modules → [M] sections active (S0,S1,S5,S9,A2,A3,A5) | [K] skipped`

🚫 Do NOT retain skipped sections.

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "For /speckit.specify" section | Relevant Feature only |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "Source Behavior Inventory" section | **REQUIRED** — each P1/P2 SBI entry must map to at least one FR-### |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "Source Reference" section | Source files to read for behavior extraction |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "UI Component Features" section | **If present** — ensure FR-### cover all UI features |
| `BASE_PATH/business-logic-map.md` | Relevant Feature section | Filtered by Feature ID |
| `SPEC_PATH/[NNN-feature]/pre-context.md` | "Naming Remapping" section | **If present (project identity changed)** |

### Source File Reading

Unlike standard specify, adopt-specify reads the **actual source files** listed in Source Reference to extract precise behavior descriptions:

1. Read `Source Path` from `sdd-state.md` to get the Source Root
2. For each file in Source Reference, resolve as `[Source Path]/[relative path]`
3. Read the source files to understand what the code actually does
4. Use the source code as the ground truth for FR/SC extraction

---

## SBI Parsing Protocol (🚫 BLOCKING — must complete before speckit-specify)

### Step 1 — Read SBI Table
1. Open `SPEC_PATH/[NNN-feature]/pre-context.md`
2. Locate the `## Source Behavior Inventory` section
3. Parse the markdown table rows: extract columns — B### ID, Priority (P1/P2/P3), Source File, Function/Method, Behavior Description
   - B### IDs may be in standard format (`B001`) or domain-prefixed format (`B-INF-001`) for large-scale projects. Both formats are valid.
4. Filter to current Feature's entries only (matched by Feature ID prefix or association column)
5. If SBI section is missing or empty:
   → 🚫 BLOCKING: "No SBI found in pre-context.md for [FID]. Cannot adopt without source behavior mapping. Re-run /reverse-spec to generate SBI."

### Step 2 — Build Source Behavior Map
For each P1 and P2 SBI entry:
1. Resolve source file path: `[Source Path from sdd-state.md]/[relative path from SBI table]`
2. Read the source file, locate the function/method by name
3. Extract: signature, parameters, return type, core logic (key branches, validations, transformations)
4. Record as structured context for FR generation

For P3 entries: read function signature only (one-line description sufficient).

### Step 3 — Generate FR with [source: B###] Tags
During speckit-specify execution, ensure each generated FR includes source traceability:
- Format: `FR-NNN: [behavior description] [source: B###]` or `[source: B-INF-001]` (match the format used in pre-context.md SBI table)
- If one B### maps to multiple FRs (complex function with multiple behaviors): tag ALL related FRs with the same B###
- If multiple B### entries collapse into one FR: tag with comma-separated sources `[source: B001, B002]`

### Step 4 — Coverage Validation (🚫 BLOCKING — checked in Review)
After speckit-specify generates spec.md, verify in the Review step:
1. ✅ Every **P1** SBI entry → at least one FR-### with matching `[source: B###]`
2. ✅ Every **P2** SBI entry → at least one FR-### with matching `[source: B###]`
3. ℹ️ P3 entries → coverage optional (informational)

Display coverage summary in Review:
```
📊 SBI Coverage: P1 [X/Y] (100% required) | P2 [X/Y] (100% required) | P3 [X/Y] (optional)
(IDs may use standard B### or domain-prefixed B-XXX-### format)
```

If unmapped P1 or P2 entries exist:
→ 🚫 BLOCKING: List unmapped B### entries
→ Agent must generate additional FRs OR provide explicit exclusion justification
→ Exclusion justification recorded in spec.md notes section

❌ WRONG: Generate FRs without reading source files → FRs are generic, miss edge cases and validations
❌ WRONG: Skip P2 SBI coverage check → secondary behaviors go undocumented in adoption
❌ WRONG: Tag FRs with `[source: B###]` without actually verifying the behavior matches
✅ RIGHT: Read each source function → extract precise behavior → generate FR → tag with [source: B###] → validate coverage

---

## Injected Content

> **Framing**: "Document the current code's behavior. Do NOT invent new requirements, suggest improvements, or add TODOs. Extract only what the code does today."

- **Feature summary**: Feature description from pre-context
- **Source Behavior Inventory**: SBI entries with B### IDs — **each P1/P2 entry MUST map to at least one FR-###**
  - Include `[source: B###]` tag on each FR that maps to an SBI entry
  - Format: `FR-001: [description] [source: B001]`
- **Source code reference**: Actual source files from Source Reference — the agent reads these to extract precise behavior
- **Draft requirements (FR-###)**: Draft from pre-context, but refined with actual source reading
- **Draft success criteria (SC-###)**: Derived from actual code behavior, not aspirational targets
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

── Draft Success Criteria ──────────────────────
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

> **⚠️ SUPPRESS spec-kit output**: `speckit-specify` prints navigation messages like "Ready for /speckit.plan" — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the Review Display below. If context limit prevents continuing, show instead: `✅ speckit-specify executed for [FID] - [Feature Name].\n💡 Type "continue" to review the results.`

After `speckit-specify` completes:

**Files to read**:
1. `specs/{NNN-feature}/spec.md` — Read the entire file
2. `SPEC_PATH/{NNN-feature}/pre-context.md` → SBI table (for B### coverage check)

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

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Post-Step Update Rules

1. Update `sdd-state.md` per generic step-completion rules
2. Update `sdd-state.md` → Source Behavior Coverage section:
   - For each FR-### with `[source: B###]` tag, update the SBI entry:
     - `FR` column: FR-### ID
     - `Feature` column: Feature ID
     - `Status` column: `🔄 in_progress`
3. Populate the Feature Mapping table (same as standard specify)
