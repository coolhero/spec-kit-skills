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

```
📋 Context for Constitution finalization:

Source reference strategy: [Same stack / New stack]
Architecture principles: [N] extracted
Technical constraints: [N] items
Coding conventions: [N] items
Best Practices: Test-First, Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution
Global Evolution operational principles: Cross-Feature Consistency

Please let me know if there is anything to modify. If approved, I will execute /speckit.constitution.
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

```
📋 Context for Specify execution:

Feature: [FID] - [Feature Name]
Information to inject:
  - pre-context "For /speckit.specify": [N] FR-###, [N] SC-###
  - business-logic-map: [N] business rules
  - Original sources: [N] files
  - [Preceding Feature reference: spec.md from F00X]

Please let me know if there is anything to modify.
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

```
📋 Context for Plan execution:

Feature: [FID] - [Feature Name]
Information to inject:
  - pre-context "For /speckit.plan": [N] dependencies, [N] technical decisions
  - entity-registry: [N] owned entities, [N] referenced entities
  - api-registry: [N] provided APIs, [N] consumed APIs
  - [Preceding Feature: F00X plan results applied (finalized schema takes precedence)]

Please let me know if there is anything to modify.
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

```
📋 Verify execution: [FID] - [Feature Name]

Verification items:
  Phase 1: Execution verification (test/build/lint)
  Phase 2: Cross-Feature verification ([N] cross-verification points)
  Phase 3: Global Evolution update (entity-registry, api-registry consistency)

Do you want to proceed?
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
