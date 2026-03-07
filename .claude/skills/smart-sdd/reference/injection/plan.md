# Context Injection: Plan

> Per-command injection rules for `/smart-sdd plan [FID]`.
> For shared patterns (HARD STOP, Checkpoint, Missing/Sparse Content Handling), see [context-injection-rules.md](../context-injection-rules.md).

---

## Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.plan" section | Relevant Feature only |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Naming Remapping" section | **If present (project identity changed)** — use new identifiers in data models and API contracts |
| `BASE_PATH/entity-registry.md` | Related entity sections | See rules below |
| `BASE_PATH/api-registry.md` | Related API sections | See rules below |
| `BASE_PATH/stack-migration.md` | Category Details + Per-Feature row | **Only if New Stack strategy**. See rules below |
| `SPEC_PATH/[NNN-feature]/spec.md` | Entire file | Finalized spec for the current Feature |

## Entity Registry Filtering Rules

1. Check the **draft related entities** list in the "For /speckit.plan" section of `pre-context.md`
2. Find the `### [Entity Name]` headings in `entity-registry.md` matching those entity names
3. Entities **owned** by the Feature: Extract full schema (Fields, Relationships, Validation Rules, State Transitions, Indexes)
4. Entities **referenced** by the Feature: Extract summary schema (Fields, Relationships only)

> **Greenfield/add note**: If entity-registry.md is empty or has no matching entities, skip entity injection. The Checkpoint notes: "No pre-existing entity schemas — defining from scratch." As preceding Features complete their plans, entity-registry.md will be populated and available for subsequent Features.

## API Registry Filtering Rules

1. Check the **related API** list in the "For /speckit.plan" section of `pre-context.md`
2. Find the matching sections in `api-registry.md` by API path
3. APIs **provided** by the Feature: Extract full contract
4. APIs **consumed** by the Feature: Extract summary contract (Method, Path, Request/Response schema only)

> **Greenfield/add note**: If api-registry.md is empty or has no matching APIs, skip API injection. The Checkpoint notes: "No pre-existing APIs — defining from scratch." As preceding Features complete their plans, api-registry.md will be populated and available for subsequent Features.

## Stack Migration Filtering Rules (New Stack only)

Skip entirely if "Same Stack" strategy or if `stack-migration.md` does not exist.

1. Read the **Migration Overview** table to provide the full technology mapping context
2. Read the **Category Details** sections relevant to the Feature's technology areas (e.g., if the Feature uses ORM, include the ORM/Data Layer section)
3. Read the **Per-Feature Migration Notes** row for the current Feature
4. Read the **Patterns That Require Rethinking** section to highlight areas where the implementation approach must fundamentally differ

This context helps the plan step make technology decisions aligned with the new stack rather than carrying over patterns from the old stack.

## Preceding Feature Actual Implementation Reference

Reference the actual implementation results of dependent preceding Features:
1. Check the dependency relationship in `BASE_PATH/roadmap.md`
2. If the preceding Feature's `SPEC_PATH/[NNN-feature]/plan.md` exists:
   - Read the finalized schema for shared entities from `data-model.md`
   - Read the finalized contract for APIs to consume from `contracts/`
3. This information **takes precedence over** the drafts in entity-registry/api-registry

## Injected Content

- **Dependency information**: List of preceding Features and dependency types
- **Draft entity schemas**: Related entities filtered from entity-registry (or finalized schemas from preceding Features)
- **Draft API contracts**: Related APIs filtered from api-registry (or finalized contracts from preceding Features)
- **Stack migration context** (New Stack only): Technology mapping, per-Feature migration notes, and patterns requiring rethinking from stack-migration.md. Skipped if Same Stack or file missing
- **Technical decisions**: Draft technical decisions from pre-context
- **Preceding Feature actual results**: Reference data-model and contracts from Features that have already completed plan
- **Naming remapping**: If Naming Remapping section exists in pre-context, remind that entity names, API names, and technical terms should use the new identifiers

## Checkpoint Display Content

Show the **actual schemas, contracts, and dependencies** so the user can verify data models and API designs before plan creation:

```
📋 Context for Plan execution:

Feature: [FID] - [Feature Name]

── Dependencies ──────────────────────────────────
[List each preceding Feature with dependency type]
  - F00X-name: [entity dependency / API dependency / etc.]

── Entity Schemas (Owned) ────────────────────────
[For each owned entity: show full schema with fields, types, constraints, relationships]
  ### EntityName
  | Field | Type | Constraints |
  ...

── Entity Schemas (Referenced) ───────────────────
[For each referenced entity: show summary schema]

── API Contracts (Provided) ──────────────────────
[For each API this Feature provides: show full contract]
  ### POST /api/resource
  Request: { ... }
  Response: { ... }

── API Contracts (Consumed) ──────────────────────
[For each API this Feature consumes from others: show summary]

── Technical Decisions ───────────────────────────
[List each technical decision from pre-context]

── Stack Migration Context (New Stack only) ──────
[If New Stack strategy: show technology mapping, migration notes for this Feature,
 and patterns that require rethinking. Omitted if Same Stack or file missing.]

── Preceding Feature Overrides ───────────────────
[If applicable: show which drafts were replaced by finalized schemas from preceding Features]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with speckit-plan
  - Request modifications (adjust schemas, contracts, or decisions)
  - Edit entity-registry.md, api-registry.md, or pre-context.md directly before proceeding
```

## Review Display Content

After `speckit-plan` completes:

**Files to read**:
1. `specs/{NNN-feature}/plan.md` — Read the **entire file** and extract architecture decisions, implementation phases
2. `specs/{NNN-feature}/data-model.md` — Read the **entire file** and extract entity schemas (fields, types, relationships)
3. `specs/{NNN-feature}/contracts/*.md` — Read **all contract files** and extract endpoints (method, path, request/response)
4. `BASE_PATH/features/{FID}-{name}/pre-context.md` → "Related Entities", "Related API Contracts", "Technical Decisions" sections (for diff comparison)

**Display format**:
```
📋 Review: plan.md for [FID] - [Feature Name]
📄 Files: specs/{NNN-feature}/plan.md, data-model.md, contracts/

── Architecture Overview ────────────────────────
[Key architecture decisions from plan.md]

── Data Model ───────────────────────────────────
[Entity schemas from data-model.md — fields, types, relationships]

── API Contracts ────────────────────────────────
[Endpoints from contracts/ — method, path, request/response summary]

── Implementation Phases ────────────────────────
[Phase breakdown with deliverables from plan.md]

── Differences from Draft ───────────────────────
[Compare with pre-context.md drafts:
 - Added: entities/APIs that spec-kit added beyond the drafts
 - Changed: schemas or contracts whose structure significantly changed
 - Architecture decisions that differ from "Technical Decisions" draft]

── Files You Can Edit ─────────────────────────
  📄 specs/{NNN-feature}/plan.md
  📄 specs/{NNN-feature}/data-model.md
  📄 specs/{NNN-feature}/contracts/*.md
You can open and edit these files directly, then select
"I've finished editing" to continue.
──────────────────────────────────────────────────
```

**HARD STOP** (ReviewApproval): Options: "Approve", "Request modifications", "I've finished editing"

---

## Post-Step Update Rules

1. Read `SPEC_PATH/[NNN-feature-name]/data-model.md`
2. Compare with `BASE_PATH/entity-registry.md`:
   - Newly defined entities → Add to entity-registry
   - Field/relationship changes in existing entities → Update entity-registry
   - Update "Used by Features" column
3. Read `SPEC_PATH/[NNN-feature-name]/contracts/`
4. Compare with `BASE_PATH/api-registry.md`:
   - Newly defined APIs → Add to api-registry
   - Contract changes in existing APIs → Update api-registry
   - Update "Cross-Feature Consumers" information
