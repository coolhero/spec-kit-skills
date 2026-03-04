# Context Injection: Constitution

> Per-command injection rules for `/smart-sdd constitution`.
> For shared patterns (HARD STOP, Checkpoint, --auto, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

**BASE_PATH**: `./specs/reverse-spec/` relative to CWD (or the path specified with `--from`)

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
- Recommended development principles (Best Practices)
- Global Evolution Layer operational principles

## Checkpoint Display Content

Show the **actual content** of constitution-seed.md so the user can review and modify before finalizing:

```
📋 Context for Constitution finalization:

── Source Reference Strategy ─────────────────────
[Actual strategy content: Same/New stack details and reference approach]

── Architecture Principles ───────────────────────
[List each extracted principle with its description]

── Technical Constraints ─────────────────────────
[List each constraint]

── Coding Conventions ────────────────────────────
[List each convention]

── Best Practices ────────────────────────────────
[Show the 6 best practices with their descriptions]

── Global Evolution Operational Principles ───────
[Show the operational principles]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with speckit-constitution
  - Request modifications (add/remove/change principles)
  - Edit constitution-seed.md directly before proceeding
```

## Review Display Content

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

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing"

---

## Post-Step Update Rules

Update `sdd-state.md` per [state-schema.md → When Constitution is Finalized](../state-schema.md). No Global Evolution Layer artifact updates.
