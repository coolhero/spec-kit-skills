# Feature Restructure Guide

> Reference checklist for modifying Feature structure (split, merge, move, reorder, delete).
> This is NOT an automated command — use `/smart-sdd add` for new Features and manually edit artifacts for changes.

## When You Need This

When the user requests Feature structure changes during or after pipeline execution:
- "F003 is too big, let's split it"
- "Merge F004 and F005"
- "Remove F006"
- "Move guest checkout from F003 to F002"

For **pending/deferred Features** (not yet started): changes are lightweight — mostly roadmap.md + pre-context edits.
For **in-progress/completed Features**: more artifacts are affected — follow the full checklist below.

## Operations

| Operation | Description | Example |
|-----------|-------------|---------|
| **split** | One Feature → two or more | F003-product → F003-product-catalog + F008-product-search |
| **merge** | Two or more → one | F004-cart + F005-wishlist → F004-shopping |
| **move** | Move requirements/entities/APIs between Features | Move "guest checkout" from F003-order to F002-auth |
| **reorder** | Change dependency relationships | F005 no longer depends on F003 |
| **delete** | Remove a Feature entirely (use `/smart-sdd reset --delete [FID]`) | Remove F006-analytics |

## Feature ID Stability Policy

- **Existing IDs are never reassigned** — prevents breaking references in completed artifacts
- **Split**: Original ID is retained (scope narrowed) + new Feature(s) get next available ID
  - Example: F003 split → F003 retained (narrowed) + F008 new (if F007 was the last)
- **Merge**: Lowest-numbered ID survives; higher-numbered are removed
  - Example: F004 + F005 merge → F004 survives, F005 removed
- **Delete**: ID gap is allowed (F001, F002, F004, F005 — F003 deleted)
- **Tier inheritance** (core scope): Split children inherit the parent's Tier. Merged Feature uses highest-priority Tier (T1 > T2 > T3).

## Artifact Update Checklist

Update these artifacts in order after any restructure operation:

| # | Artifact | What to Update |
|---|----------|---------------|
| 1 | `roadmap.md` | Feature Catalog entries, Dependency Graph (mermaid + table), Release Groups, Cross-Feature Entity/API Dependencies |
| 2 | `entity-registry.md` | Owner Feature column for affected entities |
| 3 | `api-registry.md` | Owner Feature column for affected APIs |
| 4 | `business-logic-map.md` | Feature-assigned business rules (if file exists) |
| 5 | `specs/F00N-name/pre-context.md` | Affected Feature(s) + all dependents |
| 6 | `sdd-state.md` | Feature Progress rows (add/remove/modify), mark affected steps with 🔀, Feature Mapping, Restructure Log |
| 7 | `specs/NNN-name/` | **Never auto-delete** — preserve for reference. Flag dirs needing re-execution |

## Re-Execution Rules

When a Feature is restructured, affected pipeline steps must be re-executed:

| Operation | Affected Feature | Re-execute from | Rationale |
|-----------|-----------------|-----------------|-----------|
| **split** | Original (narrowed) | specify | Scope of requirements changed |
| **split** | New Feature(s) | specify (fresh start) | Entirely new Feature |
| **merge** | Surviving Feature | specify | Combined requirements need re-specification |
| **move** | Source Feature | specify | Requirements removed |
| **move** | Target Feature | specify | Requirements added |
| **reorder** | Features with changed deps | plan | Dependencies changed, architecture may differ |
| **delete** | Downstream Features | plan | Lost dependency, architecture may need adjustment |

Mark affected steps with 🔀 in `sdd-state.md`. The pipeline treats `restructured` Features like `in_progress` — processes them starting from the first 🔀 step.

## Artifact Preservation Policy

- **Never auto-delete** `specs/NNN-name/` directories — the user may want to reference or recover them
- **Never auto-delete** git branches — only suggest cleanup commands

## Completed Feature Deletion Warning

If deleting a `completed` Feature (code already merged to main):

```
⚠️ COMPLETED FEATURE DELETION
Code removal from the codebase is YOUR responsibility:
  - Review and manually remove related code
  - Update/remove associated tests
  - Downstream Features referencing this code may break
```

## Post-Restructure Verification

After making changes, verify:
- Dependency Graph is a valid DAG (no cycles)
- All entities/APIs in registries have valid Owner Features
- All pre-context.md files reference valid Feature IDs
- sdd-state.md Feature Progress matches roadmap.md Feature Catalog
- No orphaned pre-context.md files

## Decision History Recording

After restructuring, append to `specs/history.md`:

```markdown
---

## [YYYY-MM-DD] Feature Restructure

| Operation | Details | Reason |
|-----------|---------|--------|
| [split/merge/move/reorder/delete] | [what changed] | [user's reason] |
```
