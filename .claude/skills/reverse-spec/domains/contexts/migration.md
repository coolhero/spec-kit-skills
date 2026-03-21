# Context: migration (reverse-spec)

> Extends shared M0-M4 framework with reverse-spec-specific analysis rules for migration impact assessment.

## R1: Detection Signals

See `shared/domains/contexts/migration.md` for M0 signal detection (dependency, infrastructure, code signals).

During reverse-spec analysis, additionally detect:

- **Version pinning patterns**: exact versions vs ranges in lockfiles — exact pins suggest stability concern
- **Compatibility layers**: adapter/wrapper modules that bridge old and new APIs
- **Conditional compilation/import**: `#ifdef`, dynamic `import()`, feature flags for version-specific code
- **Migration artifacts**: `MIGRATION.md`, `UPGRADE.md`, `CHANGELOG.md` references to breaking changes
- **Dead code from previous migrations**: commented-out old imports, unused adapter modules

---

## R3: Feature Boundary Impact

When migration context is detected during reverse-spec analysis:

### Library/Package Migration
- Each library with a **direct breaking API change** = potential Feature boundary
- Libraries used only internally (no user-facing impact) can be grouped into a single "Dependency Upgrade" Feature
- Libraries that affect **user-facing behavior** (e.g., date formatting library swap) = separate Feature per affected surface

### Framework Migration
- **Routing changes** = Feature boundary (each route group affected)
- **State management changes** = Feature boundary (each store/slice)
- **Component pattern changes** (e.g., class → hooks) = can be batched per page/module if no behavior change
- **Config/build changes** = single "Build Migration" Feature

### DB/Data Migration
- **Schema changes** = one Feature per aggregate/bounded context affected
- **Data transformation** = separate Feature (migration script, validation, rollback)
- **Query layer changes** (ORM swap) = Feature per repository/DAO module
- **Connection/pooling changes** = single infrastructure Feature

### Infrastructure Migration
- **Deployment target** change = single "Deployment Migration" Feature
- **Service-by-service** if migrating microservices = one Feature per service
- **Shared infrastructure** (logging, monitoring, secrets) = single "Infra Foundation" Feature

---

## R4: Data Flow Extraction

When analyzing an existing codebase for migration readiness:

### Dependency Graph Construction
- Trace: `lockfile → import statements → call sites → affected Features`
- For each migration target, build the complete call chain from entry point to dependency
- Mark direct vs transitive dependents (transitive may not need code changes)

### Data Flow for DB Migration
- Trace: `Application Code → ORM/Query Layer → Connection Pool → DB Engine`
- Record: all query patterns (raw SQL, ORM methods, stored procedures)
- Note: data types that differ between source and target DB
- Flag: DB-specific features (MySQL `ON DUPLICATE KEY UPDATE` → PostgreSQL `ON CONFLICT`)

### Configuration Flow
- Trace: `env vars → config loader → runtime config → component initialization`
- Record: all configuration points that reference the migrating component
- Note: environment-specific configs (dev/staging/prod) that may differ

---

## R5: Migration Scope Estimation

During reverse-spec analysis, produce a migration scope summary:

### Affected File Count
- Direct: files that import/use the migrating component
- Indirect: files that depend on direct files (may need type/interface changes)
- Config: configuration and build files affected

### Complexity Indicators
- **API surface change**: how many distinct API calls need updating
- **Pattern change**: does the migration require architectural pattern changes (not just API swaps)
- **Data involvement**: does any persistent data need transformation
- **Test coverage**: what percentage of affected code has existing tests

### Pre-context Recording
Record migration assessment in `pre-context.md`:
- § Migration Context: Scale (M1), Target Layer (M2), Risk (M3-d)
- § Affected Components: list of modules/files with dependency depth
- § Data Impact: schema changes, migration strategy recommendation
- § Estimated Effort: file count, complexity indicators
