# Context Injection Rules

This document defines which sections of which files smart-sdd reads and injects as context before executing each spec-kit command.

**BASE_PATH**: `./specs/reverse-spec/` relative to CWD (or the path specified with `--from`)
**SPEC_PATH**: `./specs/` relative to CWD (spec-kit feature output path. Format: `specs/{NNN-feature}/`)

> **`--auto` mode**: When `--auto` is specified, all Checkpoint steps below are skipped — the context summary is still displayed for transparency, but execution proceeds immediately without waiting for user approval.

---

## 1. Constitution

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/constitution-seed.md` | Entire file | None (load entire file) |

### Injected Content

All content from constitution-seed.md is provided as context when executing `/speckit.constitution`:
- Existing source code reference principles (only sections matching the stack strategy)
- Extracted architecture principles
- Extracted technical constraints
- Extracted coding conventions
- Recommended development principles (Best Practices)
- Global Evolution Layer operational principles

### Checkpoint Display Content

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
[Show the 5 best practices with their descriptions]

── Global Evolution Operational Principles ───────
[Show the operational principles]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with /speckit.constitution
  - Request modifications (add/remove/change principles)
  - Edit constitution-seed.md directly before proceeding
```

---

## 2. Specify

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.specify" section | Relevant Feature only |
| `BASE_PATH/business-logic-map.md` | Relevant Feature section | Filtered by Feature ID |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Reference" section | Reference to original file list |

### Feature Section Filtering Rules (business-logic-map.md)

1. Find the section in `business-logic-map.md` that starts with the `## F[ID]` heading
2. Extract the Core Rules, Validation Logic, and Workflows sections for that Feature
3. Extract rules related to the Feature from the Cross-Feature Rules section

### Injected Content

- **Feature summary**: Feature description and scope from pre-context
- **Draft requirements (FR-###)**: Draft Functional Requirements extracted from pre-context
- **Draft acceptance criteria (SC-###)**: Draft Success Criteria / Acceptance Scenario extracted from pre-context
- **Business rules**: List of rules for the Feature from business-logic-map
- **Edge cases**: Edge cases found in pre-context and business-logic-map
- **Original source reference**: File list from Source Reference (so that spec-kit can read the originals and verify existing implementations)

### Preceding Feature Result Reference

When a completed preceding Feature exists and the current Feature depends on it:
1. Check the dependency relationship in `BASE_PATH/roadmap.md`
2. If the preceding Feature's `SPEC_PATH/[feature-name]/spec.md` exists, reference the relevant requirements
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
  - Approve as-is to proceed with /speckit.specify
  - Request modifications (add/remove/change requirements or criteria)
  - Edit pre-context.md or business-logic-map.md directly before proceeding
```

---

## 3. Plan

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.plan" section | Relevant Feature only |
| `BASE_PATH/entity-registry.md` | Related entity sections | See rules below |
| `BASE_PATH/api-registry.md` | Related API sections | See rules below |
| `SPEC_PATH/[feature-name]/spec.md` | Entire file | Finalized spec for the current Feature |

### Entity Registry Filtering Rules

1. Check the **draft related entities** list in the "For /speckit.plan" section of `pre-context.md`
2. Find the `### [Entity Name]` headings in `entity-registry.md` matching those entity names
3. Entities **owned** by the Feature: Extract full schema (Fields, Relationships, Validation Rules, State Transitions, Indexes)
4. Entities **referenced** by the Feature: Extract summary schema (Fields, Relationships only)

### API Registry Filtering Rules

1. Check the **related API** list in the "For /speckit.plan" section of `pre-context.md`
2. Find the matching sections in `api-registry.md` by API path
3. APIs **provided** by the Feature: Extract full contract
4. APIs **consumed** by the Feature: Extract summary contract (Method, Path, Request/Response schema only)

### Preceding Feature Actual Implementation Reference

Reference the actual implementation results of dependent preceding Features:
1. Check the dependency relationship in `BASE_PATH/roadmap.md`
2. If the preceding Feature's `SPEC_PATH/[feature-name]/plan.md` exists:
   - Read the finalized schema for shared entities from `data-model.md`
   - Read the finalized contract for APIs to consume from `contracts/`
3. This information **takes precedence over** the drafts in entity-registry/api-registry

### Injected Content

- **Dependency information**: List of preceding Features and dependency types
- **Draft entity schemas**: Related entities filtered from entity-registry (or finalized schemas from preceding Features)
- **Draft API contracts**: Related APIs filtered from api-registry (or finalized contracts from preceding Features)
- **Technical decisions**: Draft technical decisions from pre-context
- **Preceding Feature actual results**: Reference data-model and contracts from Features that have already completed plan

### Checkpoint Display Content

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

── Preceding Feature Overrides ───────────────────
[If applicable: show which drafts were replaced by finalized schemas from preceding Features]

──────────────────────────────────────────────────
Review the above content. You can:
  - Approve as-is to proceed with /speckit.plan
  - Request modifications (adjust schemas, contracts, or decisions)
  - Edit entity-registry.md, api-registry.md, or pre-context.md directly before proceeding
```

---

## 4. Tasks

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[feature-name]/plan.md` | Entire file | Current Feature |

### Injected Content

- Automatically executes `/speckit.tasks` based on plan.md
- No additional context injection (all information is already included in the plan)

### Checkpoint

Only a simplified checkpoint is displayed:
```
📋 Tasks generation: [FID] - [Feature Name]
/speckit.tasks will be executed based on plan.md. Do you want to proceed?
```

---

## 5. Implement

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `SPEC_PATH/[feature-name]/tasks.md` | Entire file | Current Feature |

### Injected Content

- Automatically executes `/speckit.implement` based on tasks.md
- No additional context injection

### Checkpoint

Only a simplified checkpoint is displayed:
```
📋 Implement execution: [FID] - [Feature Name]
/speckit.implement will be executed based on tasks.md. Do you want to proceed?
```

---

## 6. Verify / Analyze

### Read Targets

| File | Section | Filtering |
|------|---------|-----------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.analyze" section | Relevant Feature only |
| `BASE_PATH/entity-registry.md` | Entities modified by the Feature | Change tracking |
| `BASE_PATH/api-registry.md` | APIs modified by the Feature | Change tracking |
| `SPEC_PATH/[feature-name]/` | data-model.md, contracts/ | Actual implementation results |

### Injected Content

- **Cross-Feature verification points**: Cross-verification checklist from pre-context
- **Impact scope analysis**: List of other Features referencing the modified entities/APIs
- **Consistency verification**: Whether entity-registry/api-registry matches the actual implementation

### Checkpoint Display Content

Show the **actual verification checklist** so the user can see what will be checked:

```
📋 Verify execution: [FID] - [Feature Name]

── Phase 1: Execution Verification ───────────────
  - Test command: [actual test command]
  - Build command: [actual build command]
  - Lint command: [actual lint command or "not configured"]

── Phase 2: Cross-Feature Verification ───────────
[List each cross-verification point from pre-context]
  - [ ] Entity compatibility: [specific check]
  - [ ] API contract compatibility: [specific check]
  - [ ] Business rule consistency: [specific check]

── Phase 3: Global Evolution Consistency ─────────
[List entities/APIs to verify against registry]
  - entity-registry: [entities to check]
  - api-registry: [APIs to check]

── Impact Scope ──────────────────────────────────
[List of other Features potentially affected by changes]

──────────────────────────────────────────────────
Review the verification plan. You can:
  - Approve as-is to proceed
  - Add or remove verification items
```

---

## Post-Step Update Rules Detail

### After Plan Completion

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

### After Implement Completion

1. Change the Status of the Feature in `BASE_PATH/roadmap.md` to `completed`
2. Subsequent Feature impact analysis:
   - Find the list of Features that depend on the current Feature from the Dependency Graph in `roadmap.md`
   - Inspect the `pre-context.md` of each subsequent Feature
   - If the entity/API drafts in the "For /speckit.plan" section differ from the actual implementation, update them
   - Report the changes to the user

### After Verify Completion

1. Record the verification results in `BASE_PATH/sdd-state.md`:
   - Test results (pass/fail, execution time)
   - Build results
   - Cross-Feature verification results
   - Overall verification status (pass/fail)
