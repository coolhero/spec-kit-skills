# Restructure Command — Feature Structure Modification

> Reference: Read after `/smart-sdd restructure` is invoked. For shared rules, see SKILL.md.

## Restructure Command — Feature Structure Modification

Running `/smart-sdd restructure` modifies the Feature structure of an existing project. This command handles splitting, merging, moving requirements, changing dependencies, or deleting Features — and propagates changes to all affected artifacts.

**Prerequisite**: `roadmap.md`, `entity-registry.md`, `api-registry.md`, and `sdd-state.md` must already exist at BASE_PATH.

**When to use**: When the user requests Feature structure changes — before, during, or after pipeline execution (e.g., "F003 is too big, let's split it", "Merge F004 and F005", "Remove F006"). For `pending`/`deferred` Features, the Impact Analysis is naturally lightweight since no spec-kit artifacts or entity/API ownership exist yet.

### Supported Operations

| Operation | Description | Example |
|-----------|-------------|---------|
| **split** | One Feature → two or more Features | F003-product → F003-product-catalog + F008-product-search |
| **merge** | Two or more Features → one Feature | F004-cart + F005-wishlist → F004-shopping |
| **move** | Move requirements/entities/APIs between Features | Move "guest checkout" from F003-order to F002-auth |
| **reorder** | Change dependency relationships | F005 no longer depends on F003 |
| **delete** | Remove a Feature entirely | Remove F006-analytics |

### Feature ID Stability Policy

- **Existing Feature IDs are never reassigned** — this prevents breaking references in completed artifacts
- **New Features** (from split) receive the next available ID after the current highest (same as `add`)
- **Split**: Original Feature ID is retained (scope narrowed) + new Feature(s) get end-number IDs
  - Example: F003 split → F003 retained (narrowed) + F008 new (if F007 was the last)
- **Merge**: The lowest-numbered Feature ID survives; higher-numbered Features are removed
  - Example: F004 + F005 merge → F004 survives, F005 removed
- **Delete**: ID gap is allowed (F001, F002, F004, F005 — F003 deleted)

### Restructure Workflow

#### Phase 1: Current State Assessment

1. Read `sdd-state.md` → completed/in-progress/pending/restructured Feature list
2. Read `roadmap.md` → Feature Catalog, Dependency Graph
3. Read `entity-registry.md` → currently defined entities and their Owner Features
4. Read `api-registry.md` → currently defined APIs and their Owner Features
5. Display current state summary to the user:
   ```
   📊 Current Project State:

   Features: N total (X completed, Y in-progress, Z pending)
   Entities: N defined (owners: F001, F002, ...)
   APIs: N defined (owners: F001, F002, ...)

   Feature Status:
     F001-auth       — completed (all steps ✅)
     F002-product    — in_progress (→ plan step)
     F003-order      — pending
     F004-cart       — pending
   ```

#### Phase 2: Change Request (Interactive)

1. Ask the user: "What Feature structure changes do you want to make?"
2. Identify which operation(s) apply: split, merge, move, reorder, delete
3. Gather details based on the operation:
   - **split**: Which Feature to split? How to divide it? (by entity, by user scenario, by API group, etc.)
   - **merge**: Which Features to merge? What should the surviving Feature be named?
   - **move**: What to move? From which Feature to which Feature?
   - **reorder**: Which dependency to add/remove/change?
   - **delete**: Which Feature to remove? How to handle its entities/APIs/downstream dependencies?
4. Multiple operations can be combined in a single restructure (e.g., split F003 AND delete F006)

#### Phase 3: Impact Analysis

Automatically analyze all affected artifacts for each operation:

**Common analysis items** (all operations):
1. `roadmap.md` — Feature Catalog, Dependency Graph, Dependency Table, Release Groups, Cross-Feature Entity/API Dependencies
2. `entity-registry.md` — Owner Feature column references
3. `api-registry.md` — Owner Feature column references
4. `business-logic-map.md` — Feature-assigned business rules (if file exists)
5. `features/F00N-name/pre-context.md` — the affected Feature(s) + all Features that depend on them
6. `sdd-state.md` — Feature Progress, Feature Detail Log, Feature Mapping
7. `specs/NNN-name/` — spec-kit generated artifacts (spec.md, plan.md, tasks.md) if the Feature has started

**Per-operation additional analysis**:

##### Split
- Determine which entities/APIs belong to which child Feature
- Identify downstream Features that depend on the original → determine which child each should now depend on
- Evaluate completed steps: which child Feature do existing artifacts (spec.md, plan.md) belong to?

##### Merge
- Combine entities/APIs from all merged Features under the surviving Feature
- Compare completion states → determine which steps need re-execution on the surviving Feature
- Redirect all downstream dependencies to the surviving Feature ID

##### Move
- Identify the specific requirements/entities/APIs being moved
- Determine if both Features' spec.md/plan.md need re-execution
- Update cross-Feature verification points in both Features' pre-context.md

##### Reorder
- Validate the modified Dependency Graph is a valid DAG (no circular dependencies)
- Recalculate Release Group placement
- Recalculate pipeline execution order

##### Delete
- Identify all downstream Features that depend on the deleted Feature
- Identify all entities/APIs owned by the deleted Feature
- Propose resolution: reassign entities/APIs to another Feature, or remove them
- Propose dependency resolution for downstream Features: remove the dependency, or redirect to another Feature
- **If the Feature is `completed`**: Its code is already merged into main. The restructure command removes the Feature from Global Evolution Layer artifacts (roadmap, registries, sdd-state, pre-context) but does NOT remove the merged code. Flag this prominently in the Impact Summary:
  ```
  ⚠️ COMPLETED FEATURE DELETION
  F001-auth is already implemented and merged to main.
  Restructure will remove it from project artifacts only.
  Code removal from the codebase is YOUR responsibility:
    - Review and manually remove F001-auth related code
    - Update/remove tests associated with F001-auth
    - Downstream Features referencing F001-auth code may break
  ```

#### Phase 4: Impact Summary Display (HARD STOP)

Display the analysis results in a structured format and request user approval:

```
🔀 Feature Restructure — Impact Summary

**Operation**: [split / merge / move / reorder / delete]
**Affected Features**: F003, F004, F005, F008 (new)

### Changes to Apply

#### 1. Feature Catalog (roadmap.md)
- REMOVE: F005-wishlist
- MODIFY: F004-cart → F004-shopping (description updated)
- ADD: (none)

#### 2. Dependency Graph (roadmap.md)
- REMOVE edge: F005 → F001
- MODIFY edge: F004 → F001 (unchanged), F004 → F002 (new — inherited from F005)

#### 3. Entity Ownership (entity-registry.md)
- TRANSFER: WishlistItem (F005 → F004)

#### 4. API Ownership (api-registry.md)
- TRANSFER: GET /wishlist (F005 → F004)
- TRANSFER: POST /wishlist (F005 → F004)

#### 5. Pre-Context Updates
- MODIFY: features/F004-shopping/pre-context.md (merged content from F005)
- DELETE: features/F005-wishlist/pre-context.md
- MODIFY: features/F006-order/pre-context.md (dependency F005 → F004)

#### 6. Pipeline State (sdd-state.md)
- REMOVE: F005 from Feature Progress
- MODIFY: F004 status → needs re-execution from "specify" step (🔀)
- NOTE: F005 had completed "specify" → content merged into F004

#### 7. spec-kit Artifacts (manual cleanup — NOT auto-deleted)
- PRESERVE: specs/005-wishlist/ (will NOT be auto-deleted)
- FLAG: specs/004-cart/ → may need re-execution of specify, plan, tasks

### ⚠️ Warnings
- F004 (specify: completed) will be marked as 🔀 from specify step
- specs/005-wishlist/ directory will NOT be deleted (cleanup command provided after completion)
```

**Use AskUserQuestion** to request approval (options: "Approve changes", "Request modifications"). **If response is empty → re-ask** (per MANDATORY RULE 1). If the user requests modifications, return to Phase 2 and re-analyze. Do NOT proceed to Phase 5 until the user explicitly approves.

#### Phase 5: Execute Changes

After approval, update all artifacts in order:

1. **`roadmap.md`** — Feature Catalog (add/remove/modify entries), Dependency Graph (update mermaid diagram + Dependency Table), Release Groups (reposition Features), Cross-Feature Entity/API Dependencies (update ownership references)

2. **`entity-registry.md`** — Change Owner Feature for transferred entities, add new entity sections for split Features, remove entity sections for deleted Features

3. **`api-registry.md`** — Change Owner Feature for transferred APIs, add new API sections for split Features, remove API sections for deleted Features

4. **`business-logic-map.md`** (if exists) — Reassign business rules to new Feature owners, remove rules for deleted Features

5. **`features/`** directory — Create new `pre-context.md` files (for split), modify existing ones (for merge/move/reorder/delete), delete files for removed Features

6. **`sdd-state.md`** — Update Feature Progress table (add/remove/modify rows, mark affected steps with 🔀), update Feature Detail Log, update Feature Mapping, add entry to Restructure Log

#### Phase 6: Post-Restructure Verification & Report

After all changes are applied, verify consistency and display the completion report:

**Verification checks**:
- Dependency Graph is a valid DAG (no cycles)
- All entities in entity-registry.md have valid Owner Features
- All APIs in api-registry.md have valid Owner Features
- All pre-context.md files reference valid Feature IDs in their dependency sections
- sdd-state.md Feature Progress matches roadmap.md Feature Catalog
- No orphaned pre-context.md files (no pre-context for non-existent Features)

**Completion report**:

```
✅ Feature restructure completed:

**Operation**: merge (F004-cart + F005-wishlist → F004-shopping)

**Updated artifacts**:
  - roadmap.md: Feature Catalog (1 removed), Dependency Graph (2 edges updated)
  - entity-registry.md: 1 entity transferred (WishlistItem → F004)
  - api-registry.md: 2 APIs transferred (GET/POST /wishlist → F004)
  - features/F004-shopping/pre-context.md: merged content
  - features/F005-wishlist/pre-context.md: DELETED
  - sdd-state.md: F005 removed, F004 status → restructured

**Pipeline impact**:
  - F004-shopping: needs re-execution from specify step (🔀)
  - Downstream Features unaffected

**Manual cleanup suggested**:
  - rm -rf specs/005-wishlist/       — Old spec-kit artifacts
  - git branch -d 005-wishlist       — Old Feature branch (if exists)

**Next steps**:
  /smart-sdd specify F004    — Re-specify the restructured Feature
  /smart-sdd pipeline        — Resume pipeline (processes restructured + pending Features)
```

**Decision History Recording — Restructure**:
After Phase 6 completes, **append** to `specs/history.md`:

```markdown
---

## [YYYY-MM-DD] /smart-sdd restructure

### Restructure

| Operation | Details | Reason |
|-----------|---------|--------|
| [split/merge/move/reorder/delete] | [what changed, e.g., "F003 → F003 + F010"] | [user's reason] |
```

One row per operation. If multiple operations were combined, record each.

### Re-Execution Rules

When a Feature is restructured, affected pipeline steps must be re-executed. The scope depends on the operation:

| Operation | Affected Feature | Re-execute from | Rationale |
|-----------|-----------------|-----------------|-----------|
| **split** | Original (narrowed) | specify | Scope of requirements changed |
| **split** | New Feature(s) | specify (fresh start) | Entirely new Feature |
| **merge** | Surviving Feature | specify | Combined requirements need re-specification |
| **move** | Source Feature | specify | Requirements removed, needs re-specification |
| **move** | Target Feature | specify | Requirements added, needs re-specification |
| **reorder** | Features with changed deps | plan | Dependencies changed, architecture may differ |
| **delete** | Downstream Features | plan | Lost dependency, architecture may need adjustment |

Steps marked with 🔀 are re-executed when the pipeline resumes. The pipeline treats `restructured` Features the same as `in_progress` Features — it processes them starting from the first 🔀 step.

### spec-kit Artifact Preservation

- **Never auto-delete** `specs/NNN-name/` directories — the user may want to reference or recover them
- **Never auto-delete** git branches — only suggest cleanup commands
- This policy ensures the user maintains full control over artifact and branch lifecycle

### Integration with Pipeline

- **Restructure is a separate command**, not part of the pipeline flow
- If the user requests a Feature change during pipeline execution:
  1. Complete (or abort) the current in-progress step
  2. Run `/smart-sdd restructure`
  3. After restructure, resume with `/smart-sdd pipeline` — the pipeline automatically detects `restructured` Features and processes them from the first 🔀 step
