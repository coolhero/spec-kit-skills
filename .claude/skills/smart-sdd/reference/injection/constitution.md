# Context Injection: Constitution

> Per-command injection rules for `/smart-sdd constitution`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/constitution-seed.md` | Entire file | None (load entire file) |

## Injected Content

All content from constitution-seed.md is provided as context when executing `speckit-constitution`:
- Existing source code reference principles (only sections matching the stack strategy)
- Extracted architecture principles
- Extracted technical constraints
- Extracted coding conventions
- **Archetype-specific principles**: If `sdd-state.md` Archetype field ≠ `"none"`:
  1. Read `domains/archetypes/{archetype}.md` § A4 (Constitution Injection)
  2. Extract each principle with its description
  3. Inject as `## Archetype-Specific Principles` section in the constitution-seed content
  4. Example: Archetype `ai-assistant` → A4 principles about Streaming-First, Model Agnosticism, Token Awareness, etc.
  5. If multiple archetypes (comma-separated): merge all A4 sections by append
- **Framework philosophy**: If Foundation F7 section exists in `foundations/{framework}.md`
- Recommended development principles (Best Practices)
- Global Evolution Layer operational principles

### Adoption Mode Preamble

When Origin is `adoption` (from `/smart-sdd adopt`), **prepend** the following preamble before the constitution-seed content:

```
📌 Adoption Mode — This constitution documents the existing codebase's philosophy.

The principles below were extracted from working source code. The constitution should:
- Preserve the existing code's architectural philosophy and conventions
- Describe current practices (descriptive), not impose new standards (prescriptive)
- Only add new rules if the user explicitly requests them during review
```

This framing ensures `speckit-constitution` produces a constitution that **reflects the existing codebase** rather than defining aspirational standards.

## Checkpoint Display Content

Show the **actual content** of constitution-seed.md so the user can review and modify before finalizing.

**Adoption mode**: Include the adoption preamble before the content, and add a note asking the user to validate that the extracted principles match their understanding of the codebase.

```
📋 Context for Constitution finalization:

[If adoption mode: show adoption preamble here]

── Source Reference Strategy ─────────────────────
[Actual strategy content: Same/New stack details and reference approach]

── Architecture Principles ───────────────────────
[List each extracted principle with its description]

── Technical Constraints ─────────────────────────
[List each constraint]

── Coding Conventions ────────────────────────────
[List each convention]

── Archetype-Specific Principles ──────────────────
[If archetype detected: show principles from the archetype's A4 section]
[If no archetype: omit this block]

── Framework Philosophy ───────────────────────────
[If Foundation F7 exists: show F7 principles]
[If no F7: omit this block]

── Best Practices ────────────────────────────────
[Show the 6 best practices with their descriptions]

── Global Evolution Operational Principles ───────
[Show the operational principles]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with speckit-constitution
  - Request modifications (add/remove/change principles)
  - Edit constitution-seed.md directly before proceeding

[If adoption mode: "⚠️ These principles were extracted from existing source code.
Please verify they accurately reflect the codebase's philosophy."]
```

## Review Display Content

> **⚠️ SUPPRESS spec-kit output**: `speckit-constitution` prints navigation messages — **never show these to the user**. Suppress ALL spec-kit navigation messages. Immediately proceed to the Review Display below. If context limit prevents continuing, show instead: `✅ speckit-constitution executed.\n💡 Type "continue" to review the results.`

After `speckit-constitution` completes:

**Files to read**:
1. `.specify/memory/constitution.md` — Read the **entire file** and display its full content

**Display format**:
```
📋 Review: Constitution finalized

── Finalized Constitution ──────────────────────
[Full content of .specify/memory/constitution.md:
 - All principles with descriptions
 - All constraints
 - All conventions
 - All best practices]

── Files You Can Edit ─────────────────────────
  📄 .specify/memory/constitution.md
You can open and edit this file directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing". **If response is empty → re-ask** (per MANDATORY RULE 1).

---

## Post-Step Update Rules

Update `sdd-state.md` per [state-schema.md → When Constitution is Finalized](../state-schema.md). No Global Evolution Layer artifact updates.
