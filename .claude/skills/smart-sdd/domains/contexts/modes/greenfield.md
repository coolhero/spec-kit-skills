# Context Mode: greenfield

> Building a new project from scratch. No existing system to preserve.
> Module type: scenario

---

## Configuration Parameters

| Parameter | Values | Consumed By |
|-----------|--------|-------------|
| `project_maturity` | `prototype`, `mvp`, `production` | S1 (SC depth), S5 (probes), S7 (over-engineering guard) |
| `team_context` | `solo`, `small-team`, `large-team` | S5 (collaboration probes) |

> **Defaults**: `project_maturity` = `mvp`, `team_context` = `solo`.
> These are **optional** — if not explicitly set, defaults apply and all conditional rules below still function.
>
> **Auto-inference** (when CI scoring data is available during init Proposal Mode):
> - CI Scale = 0–1 or "personal tool" → `prototype`
> - CI Scale = 2 or "MVP", "startup" → `mvp`
> - CI Scale = 3 or "enterprise", "production" → `production`
>
> `team_context` is inferred from user input if mentioned, otherwise defaults to `solo`.

---

## S1. SC Rules (extends _core)

- Standard SC generation from requirements — no behavioral parity needed
- **Completeness focus**: Every FR must have at least one SC
- No preservation SCs (nothing to preserve)

### Greenfield SC Anti-Patterns

| Anti-Pattern | Why It's Wrong | Correct Approach |
|-------------|---------------|-----------------|
| "should work like [reference app]" | No source to compare against — vague | Specify exact behavior: inputs, outputs, state changes |
| "maintain backward compatibility" | Nothing to be backward-compatible with | Remove or reframe as "follow established conventions" |
| Over-specified SCs for prototype | Premature detail wastes effort | Match SC depth to `project_maturity` (see below) |
| SCs that describe implementation | "should use Redis for caching" | SCs describe behavior: "response time < 200ms for cached data" |

### Maturity-Adjusted SC Depth

| Maturity | SC Depth Requirement | Example |
|----------|---------------------|---------|
| `prototype` | Functional-level only (user goal achieved). Skip performance/edge-case SCs | "User can create a task" — no need for "handles 10k concurrent users" |
| `mvp` | Functional + key error-path SCs. Performance SCs for user-facing latency only | "User sees error message on invalid input", "Page loads < 3s" |
| `production` | Full SC coverage: edge cases, performance, error recovery, concurrency | "Handles concurrent task updates without data loss" |

---

## S3. Verify Steps (extends _core)

| Step | Required | Condition | Description |
|------|----------|-----------|-------------|
| Standard (test/build/lint) | BLOCKING | Always | Same as `_core` — test + build + lint must pass |
| Demo-Ready | Conditional | Constitution VI active | Same as `_core` — executable demo script |
| Architecture Scaffolding | Informational | First Feature only | Verify project structure matches the planned architecture |

### Architecture Scaffolding Check (First Feature)

On the FIRST Feature entering `verify`, perform a one-time structural check:
- Project root has expected config files (package.json, tsconfig.json, Cargo.toml, etc.)
- Directory structure follows the planned layout from the `plan` step
- Core dependencies are installed and importable
- Dev tooling (linter, test runner, formatter) is configured and runnable

This is **informational only** — structural deviations are flagged as warnings, not blockers.

---

## S5. Elaboration Probes (extends _core)

### Architecture Scaffolding Probes

| Category | Probes |
|----------|--------|
| **Project structure** | Feature-based or layer-based directory layout? Monorepo or single package? |
| **Tech stack validation** | Familiarity with chosen stack? Known limitations for this use case? |
| **MVP scoping** | What is the minimum feature set for a useful first version? What can wait for v2? |
| **Data model** | What are the core entities? What are their relationships? Any polymorphic or self-referential models? |
| **Deployment target** | Where will this run? (local dev, cloud VPS, serverless, edge, container, embedded) |
| **Error strategy** | Global error handling pattern? User-facing error messages vs. technical logs? |

### Per-Maturity Probes

| Maturity | Probes |
|----------|--------|
| `prototype` | What hypothesis are you validating? What is the fastest path to a testable version? |
| `mvp` | Who are the first users? What is the ONE flow they must complete successfully? |
| `production` | SLA requirements? Monitoring and alerting strategy? Backup and disaster recovery? |

### Per-Team Probes

| Team Context | Probes |
|-------------|--------|
| `solo` | (No additional probes — default workflow) |
| `small-team` | Code review process? Branch strategy? Shared conventions documented? |
| `large-team` | Module ownership? API contract enforcement? CI/CD pipeline requirements? |

---

## S7. Bug Prevention Rules

| Rule | Stage | Condition | Description |
|------|-------|-----------|-------------|
| Over-engineering Guard | plan | `prototype` or `mvp` | Warn if plan includes patterns for production scale (microservices, CQRS, event sourcing, message queues) when maturity is prototype/mvp |
| Premature Optimization | implement | Always | Flag performance optimization code (caching layers, memoization, lazy loading) unless a specific SC requires it |
| Missing Error Boundaries | implement | `gui` interface active | Every route/page component must have error boundary wrapping. Greenfield code often skips this |
| Incomplete Happy Path | verify | Always | All FRs must have at least one passing SC before any edge-case or optimization work |
| Tech Stack Mismatch | plan | Always | Warn if plan references libraries or APIs not available in the declared tech stack |
| Empty State Blindness | implement | `gui` interface active | Every list/table/dashboard view must handle the empty state (no data yet) |
| Missing Seed Data | verify | Always | Demo scripts must include seed data setup. A demo showing an empty app is not a demo |
