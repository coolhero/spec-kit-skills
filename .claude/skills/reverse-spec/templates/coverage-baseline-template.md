# Source Coverage Baseline

**Source**: `$SOURCE_ROOT`
**Generated**: [DATE]
**Scope**: [core|full]
**Stack Strategy**: [same|new]

---

## Surface Metrics

| Metric | Source Total | Mapped to Features | Coverage | Notes |
|--------|------------|-------------------|----------|-------|
| Source files | [N] | [M] | [%] | Excludes vendor/build/test directories |
| Source behaviors (SBI) | [N] | [M] | [%] | B### entries across all pre-context.md SBI tables |
| API endpoints | [N] | [M] | [%] | Parsed from route definitions vs api-registry.md entries |
| DB models/entities | [N] | [M] | [%] | Parsed from model files vs entity-registry.md entries |
| Test files | [N] | [M] | [%] | Total test files vs mapped to Features |
| Business rules | [N] | [M] | [%] | Identified rules vs business-logic-map.md entries |

> **How to read**: "Source Total" is what was found in the original source code. "Mapped to Features" is what was assigned to at least one Feature's pre-context.md or registry. The gap between them represents unmapped items classified below.

---

## Unmapped Items

Items found in the original source that are not assigned to any Feature. Each item was classified by the user during Phase 4-3 of `/reverse-spec`.

### Unmapped Source Files

| # | File Path | Detected Role | Classification | Detail |
|---|-----------|--------------|----------------|--------|
| 1 | [relative/path/to/file.ts] | [middleware / utility / config / service / ...] | [assigned:F00N / new-feature / cross-cutting / excluded] | [reason or target] |

### Unmapped Endpoints

| # | Method | Path | Source Location | Classification | Detail |
|---|--------|------|----------------|----------------|--------|
| 1 | [GET/POST/...] | [/api/path] | [file:line] | [assigned:F00N / new-feature / cross-cutting / excluded] | [reason or target] |

### Unmapped Entities/Models

| # | Model Name | Source Location | Classification | Detail |
|---|------------|----------------|----------------|--------|
| 1 | [ModelName] | [file:line] | [assigned:F00N / new-feature / cross-cutting / excluded] | [reason or target] |

### Unmapped Test Files

| # | Test File Path | Related Source | Classification | Detail |
|---|---------------|---------------|----------------|--------|
| 1 | [tests/path/to/test.ts] | [source file it tests] | [assigned:F00N / new-feature / excluded] | [reason or target] |

> **Classification values**:
> - `assigned:F00N` — Added to existing Feature F00N's pre-context.md Source Reference
> - `new-feature` — New Feature created to cover this item (see roadmap.md)
> - `cross-cutting` — Flagged as cross-cutting concern for constitution/infrastructure Feature
> - `excluded` — Intentionally excluded (see Intentional Exclusions below)
> - `unclassified` — Not yet classified (only when `--dangerously-skip-permissions` skips the classification HARD STOP)

---

## Intentional Exclusions

Items classified as intentional exclusions during Phase 4-3 review. These items will be **filtered out** from future parity checks via `/smart-sdd parity`.

| # | Item | Type | Exclusion Reason | Description |
|---|------|------|-----------------|-------------|
| 1 | [name or path] | [file / endpoint / entity / test] | [reason code] | [explanation] |

### Exclusion Reason Codes

| Code | Meaning | Revisit? |
|------|---------|----------|
| `deprecated` | Functionality already deprecated in the original source | No |
| `replaced` | Superseded by a different approach in the new implementation | No |
| `third-party` | Now handled entirely by an external service/library | Verify integration only |
| `deferred` | Intentionally deferred for future work (linked to roadmap.md) | Yes — during `/smart-sdd expand` |
| `out-of-scope` | Business decision to not include in redevelopment | On business request |
| `covered-differently` | Functionality achieved through a different architecture in the new system | No — verify behavior only |

---

## Coverage Notes

[Free-form notes about coverage decisions, major exclusion rationale, and areas that may need revisiting. Example:]

- [Utility functions in `src/utils/` were largely absorbed into the framework's built-in functions — classified as `covered-differently`]
- [Admin dashboard (`src/admin/*`) deferred to T2 — 12 endpoints and 3 entities excluded with reason `deferred`]
