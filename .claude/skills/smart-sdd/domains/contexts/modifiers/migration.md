# Context Modifier: migration (smart-sdd pipeline rules)

> Situational overlay for modernization, migration, and version upgrade projects.
> Activated when `Context Modifiers` in sdd-state.md includes `migration`.
> For signal detection and classification framework (M0-M4), see `shared/domains/contexts/modifiers/migration.md`.

---

## S1. SC Generation Rules (migration-specific)

When migration modifier is active, SCs must account for migration-specific concerns:

### Required SC Patterns

- **Behavioral preservation SCs**: "Feature X produces identical output before and after migration" — required for every migrated Feature
- **Data integrity SCs**: If data migration is involved (M2 target layer includes DB/ORM/Cache), SCs must cover data round-trip verification
- **Rollback feasibility SCs**: For Major/Platform scale (M1), at least one SC per Feature must verify rollback path

### Anti-patterns

- ❌ "App works after migration" — too vague, no measurable criteria
- ❌ "Data is migrated correctly" — missing volume, integrity, and format checks
- ✅ "All 847 user records are accessible via GET /api/users with identical field structure after migration"

---

## S3. Verify Steps (migration-specific additions)

| Step | Required | Description |
|------|----------|-------------|
| `migration-behavioral-parity` | BLOCKING | Compare pre/post-migration behavior for all SCs tagged `preservation` |
| `migration-data-integrity` | BLOCKING (if M2 includes data layer) | Verify data completeness, referential integrity, format consistency |
| `migration-rollback-test` | BLOCKING (Major/Platform only) | Execute rollback procedure and verify system returns to pre-migration state |
| `migration-performance-baseline` | optional | Compare key performance metrics pre/post migration |

---

## S5. Elaboration Probes (migration-specific)

Additional questions during `add` consultation when migration modifier is active:

| Perspective | Probe |
|-------------|-------|
| 2 (Edge Cases) | "What happens if the migration is interrupted midway? Is partial rollback possible?" |
| 2 (Edge Cases) | "Are there data format differences between old and new systems that could cause silent data loss?" |
| 3 (Data & State) | "What is the data volume? Is zero-downtime migration feasible or is a maintenance window needed?" |
| 4 (Integration) | "Which downstream services/Features depend on the component being migrated?" |
| 5 (Non-functional) | "What is the acceptable performance regression during and after migration?" |

---

## S7. Bug Prevention Rules (migration-specific)

| Rule | Stage | Description |
|------|-------|-------------|
| `migration-dual-write-safety` | implement | If using dual-write strategy, verify both paths produce identical results |
| `migration-feature-flag-cleanup` | verify | Ensure migration feature flags have defined cleanup timeline |
| `migration-compatibility-shim-audit` | verify | Identify and document all compatibility shims; verify each has a removal plan |
| `migration-dependency-cascade` | plan | Map all transitive dependencies of the migrated component; verify each is compatible with target version |

---

## Pipeline Depth Modifier

Migration scale (from shared migration module M1) adjusts pipeline depth:

| Scale | Pipeline Adjustment |
|-------|-------------------|
| Hotfix | Skip plan/tasks — targeted specify + implement + verify only |
| Patch | Lightweight plan (single paragraph), flat task checklist |
| Minor/Major/Platform | Full pipeline with migration-specific S1/S3/S5/S7 additions above |

---

## Module Metadata

- **Type**: Context modifier (situational overlay)
- **Depends on**: `shared/domains/contexts/modifiers/migration.md` (M0-M4 classification framework)
- **Activates dynamically**: Concerns and Foundations matching the migration target layer
