# Reverse-Spec ↔ Spec-Kit Compatibility Guide

This document explains how to utilize the outputs of the `/reverse-spec` skill within the spec-kit workflow.

---

## Output ↔ Spec-Kit Command Mapping

| Reverse-Spec Output | Spec-Kit Command | Usage |
|--------------------|-----------------|-----------|
| `constitution-seed.md` | `/speckit.constitution` | Load as a draft to establish principles. Reflect architecture principles and source reference strategies extracted from existing code into the constitution |
| `roadmap.md` Feature Catalog | `/speckit.specify` | Input source for Feature descriptions. Select implementation targets from the tier-based Feature list and use the descriptions as input |
| `pre-context.md` → For /speckit.specify | `/speckit.specify` | Use as drafts for spec.md Requirements (FR-###) and Success Criteria (SC-###). Also provides existing user scenarios and edge cases |
| `entity-registry.md` | `/speckit.plan` | Global entity reference when writing data-model.md. Prevents cross-Feature entity conflicts |
| `api-registry.md` | `/speckit.plan` | Global API contract reference when writing contracts/. Ensures cross-Feature API consistency |
| `pre-context.md` → For /speckit.plan | `/speckit.plan` | Reference for preceding Feature dependencies, related entity/API drafts, and technical decisions |
| `business-logic-map.md` | `/speckit.specify` | Prevents omission of existing business rules. Checks that all rules are reflected when writing specs |
| `pre-context.md` → For /speckit.analyze | `/speckit.analyze` | Cross-Feature validation points to verify consistency between Features |
| `coverage-baseline.md` | `/smart-sdd parity` | Used for intentional exclusion filtering during parity checks |
| `stack-migration.md` | `/speckit.plan` | Referenced for migration implications when planning Feature implementation |
| `.env.example` | Project setup | Used during project setup for environment variable configuration |

---

## Workflow: Pre-Extract → Spec-Kit Progression Order

### Step 1: Finalize Constitution

```
1. Read specs/reverse-spec/constitution-seed.md
2. When running /speckit.constitution, provide the contents of constitution-seed.md as input
3. Select source code reference principles that match the stack strategy and include them in the constitution
4. Include Global Evolution Layer operational principles in the constitution
5. Review the extracted architecture principles and modify/supplement them for redevelopment
```

### Step 2: Specify → Plan → Tasks → Analyze → Implement → Verify → Merge in Feature Order

```
Follow the Release Group order in roadmap.md:
  Release 1 (Foundation) → Release 2 (Core Business) → Release 3 (Enhancement) → ...

For each Feature:
  1. Read specs/reverse-spec/features/F00N-xxx/pre-context.md
  2. Run /speckit.specify:
     - Refer to the "For /speckit.specify" section in pre-context.md
     - Read the original files from Source Reference to review existing implementation
     - Use the draft requirements (FR-###) and draft success criteria (SC-###)
  3. Run /speckit.plan:
     - Refer to the "For /speckit.plan" section in pre-context.md
     - Check related entity schemas in entity-registry.md
     - Check related API contracts in api-registry.md
     - Reference stack-migration.md when using New Stack strategy
     - Design reflecting preceding Feature dependencies
  4. /speckit.tasks → /speckit.analyze (cross-artifact consistency check) → /speckit.implement
  5. Verify: Run tests/build/lint (BLOCKS on failure), cross-Feature consistency, demo script execution
  6. Merge: Verify-success gate → merge Feature branch to main
  7. After completion: Update entity-registry.md and api-registry.md to the latest state
```

> **Tip**: `/smart-sdd pipeline` automates the above workflow with cross-Feature context injection at each step. See the `/smart-sdd` skill for details.

---

## Format Compatibility Details

### Entity Registry → Spec-Kit data-model.md

| Entity Registry Field | data-model.md Mapping |
|----------------------|----------------------|
| Fields table | Entities → Fields section |
| Relationships table | Entities → Relationships section |
| Validation Rules table | Entities → Validation Rules section |
| State Transitions diagram | Entities → State Transitions section |
| Indexes table | Entities → Indexes section |

**Conversion Method**: Extract the entity sections owned by the relevant Feature from the Entity Registry and place them in data-model.md. For referenced entities, include the schema with an "External Entity" annotation.

### API Registry → Spec-Kit contracts/

| API Registry Field | contracts/ Mapping |
|-------------------|-------------------|
| Method + Path | Contract filename (e.g., `post-auth-register.md`) |
| Request Body/Parameters | Request Schema section |
| Response (by status code) | Response Schema section |
| Auth | Authentication section |
| Dependencies | Dependencies section |

**Conversion Method**: Extract the API sections provided by the relevant Feature from the API Registry and separate them into individual files in the contracts/ directory.

### Business Logic Map → Spec-Kit spec.md

| Business Logic Map Field | spec.md Mapping |
|-------------------------|----------------|
| Core Rules | Requirements (FR-###) |
| Validation Logic | Acceptance Scenarios (Given/When/Then) |
| Workflows | User Scenarios & Testing |
| Cross-Feature Rules | Requirements + Edge Cases |

**Conversion Method**: Convert the rules from the Business Logic Map into spec-kit's requirements format (FR-###) and acceptance scenarios (Given/When/Then).

---

## Global Evolution Layer Maintenance

After implementing Features with spec-kit, the global outputs must be kept up to date:

### When to Update

| Event | Update Target |
|-------|--------------|
| Feature plan completed | entity-registry.md (add new entities), api-registry.md (add new APIs) |
| Feature implementation completed | roadmap.md (update Feature status), pre-context.md (reflect actual implementation) |
| Cross-Feature dependency changes | roadmap.md Dependency Graph, dependency sections in related pre-context.md |
| New Feature added | roadmap.md Feature Catalog, create new pre-context.md |

### Update Rules

1. **When entity schema changes**: Update the entity in entity-registry.md and verify cross-validation points in the pre-context.md of referencing Features
2. **When API contract changes**: Update the API in api-registry.md and verify compatibility in the pre-context.md of consumer Features
3. **When Features are added/removed**: Update the Feature Catalog, Dependency Graph, and Release Groups in roadmap.md
