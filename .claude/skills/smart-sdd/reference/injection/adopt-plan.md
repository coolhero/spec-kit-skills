# Context Injection: Adopt — Plan

> Per-command injection rules for the **plan** step within `/smart-sdd adopt`.
> This is a variant of the standard `plan` injection — documents existing architecture as-is rather than designing new architecture.
> For shared patterns (HARD STOP, Checkpoint, --auto, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

**BASE_PATH**: `./specs/reverse-spec/` relative to CWD (or the path specified with `--from`)
**SPEC_PATH**: `./specs/` relative to CWD (spec-kit feature output path. Format: `specs/{NNN-feature}/`)

---

## Key Difference from Standard Plan

Standard plan: "Design new architecture" — creates data models and API contracts for new implementation.
Adopt plan: **"Document existing architecture as-is"** — records the current data models, API contracts, and component structure without suggesting changes.

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.plan" section | Relevant Feature only |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Naming Remapping" section | **If present** — use new identifiers |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Reference" section | Source files for architecture extraction |
| `BASE_PATH/entity-registry.md` | Related entity sections | Filtered per entity registry rules |
| `BASE_PATH/api-registry.md` | Related API sections | Filtered per API registry rules |
| `SPEC_PATH/[NNN-feature]/spec.md` | Entire file | Finalized spec for the current Feature |

### Source File Reading

Read actual source files to extract the existing architecture:
1. Data model schemas (from ORM definitions, database migrations, type definitions)
2. API contracts (from route handlers, controller signatures, middleware chains)
3. Component structure (from module imports, class hierarchies, service patterns)

---

## Injected Content

> **Framing**: "Document the existing architecture exactly as it is. Do NOT suggest improvements, refactoring, or alternative approaches. Record the inferred design rationale ('why was it built this way?')."

- **Dependency information**: Preceding Features and dependency types
- **Entity schemas**: Extract from actual source — ORM models, database schemas, type definitions
- **API contracts**: Extract from actual source — route definitions, request/response types, middleware
- **Technical decisions**: Document observed patterns and their inferred rationale
- **Component structure**: Module organization, service layers, abstraction patterns

### Adoption-Specific Instructions

1. **Document, don't redesign**: data-model.md and contracts/ must reflect the current state of the code, not an idealized version.
2. **Inferred rationale**: For each architectural decision, add a brief note explaining why it likely exists (e.g., "Likely chosen for simplicity" or "Required by framework convention").
3. **No migration notes**: Do not include migration plans, deprecation suggestions, or "should be refactored" comments.
4. **Record technical debt as-is**: If the architecture has inconsistencies (e.g., mixed naming conventions, unused fields), document them factually without judgment.

---

## Checkpoint Display Content

```
📋 Context for Adopt-Plan execution:

Feature: [FID] - [Feature Name]
Mode: ADOPTION — Documenting existing architecture as-is

── Dependencies ──────────────────────────────────
[List each preceding Feature with dependency type]

── Entity Schemas (from source) ──────────────────
[For each entity extracted from source code]
  ### EntityName (from [source file])
  | Field | Type | Constraints |
  ...
  Inferred rationale: [why this schema exists]

── API Contracts (from source) ───────────────────
[For each API extracted from route definitions]
  ### METHOD /api/path (from [source file])
  Request: { ... }
  Response: { ... }
  Inferred rationale: [why this endpoint exists]

── Observed Patterns ─────────────────────────────
[List architectural patterns found in source]
  - Pattern: [name] — Used in: [files] — Rationale: [inferred]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with speckit-plan
  - Request modifications (correct architecture descriptions)
```

---

## Review Display Content

After `speckit-plan` completes:

**Files to read**:
1. `specs/{NNN-feature}/plan.md` — Architecture decisions
2. `specs/{NNN-feature}/data-model.md` — Entity schemas
3. `specs/{NNN-feature}/contracts/*.md` — API contracts

**Display format**:
```
📋 Review: plan.md for [FID] - [Feature Name] (Adoption)

── Architecture Overview ────────────────────────
[Key architecture decisions — as documented from existing code]

── Data Model ───────────────────────────────────
[Entity schemas from data-model.md]

── API Contracts ────────────────────────────────
[Endpoints from contracts/]

── Adoption Notes ───────────────────────────────
  - Architecture documented as-is (no redesign applied)
  - Inferred rationale recorded for [N] decisions
  - Technical debt items noted: [N] (if any)

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/plan.md
  📄 specs/{NNN-feature}/data-model.md
  📄 specs/{NNN-feature}/contracts/*.md
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing"

---

## Post-Step Update Rules

Same as standard plan:
1. Compare `data-model.md` with `entity-registry.md` → update registry
2. Compare `contracts/` with `api-registry.md` → update registry
3. Update `sdd-state.md` per generic step-completion rules
