# Archetype: workflow-engine

<!-- Format defined in smart-sdd/domains/_schema.md § Archetype Section Schema. -->

> Durable execution engines, workflow orchestrators with history replay, saga coordination.
> Distinct from task-worker: stateful execution with replay, compensation, and versioning.

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/workflow-engine.md`](../../../shared/domains/archetypes/workflow-engine.md) § Signal Keywords

---

## A1. Domain Philosophy

| Principle | Description |
|-----------|-------------|
| **Deterministic Replay** | Workflow code must be deterministic: same input + same history → same decisions. No random(), no Date.now(), no external I/O in workflow code. Side effects are isolated in activities |
| **Activity Isolation** | All non-deterministic work (API calls, DB writes, file I/O) happens in activities, not workflows. Activities have independent retry policies, timeouts, and heartbeats. Workflows orchestrate activities |
| **Compensation over Rollback** | Distributed transactions use saga pattern: each step has a compensating action. Failure triggers compensation in reverse order. No global 2PC — eventual consistency with explicit compensation |
| **Versioning for Evolution** | Workflow definitions evolve over time. Running workflows must complete with original logic. New workflows use new version. Version branching (patching) handles mid-flight changes |
| **Durability over Performance** | Every workflow state change is persisted before proceeding. If the server crashes mid-execution, replay from history recreates exact state. Latency is secondary to correctness |

---

## A2. SC Extensions

| Domain | SC Extension |
|--------|-------------|
| **Workflow execution** | SC must specify: workflow start → activity sequence → completion/failure. Verify: start workflow → activities execute in order → workflow completes with expected result |
| **Activity retry** | SC must specify: retry policy per activity (max attempts, backoff, non-retryable errors). Verify: activity fails → retried N times with backoff → eventual success or failure |
| **Saga compensation** | SC must specify: for each step, the compensating action. Verify: step 3 fails → steps 2,1 compensated in reverse → final state is consistent |
| **Timer/signal** | SC must specify: timer-based waits and external signal handling. Verify: workflow waits for timer → timer fires → workflow proceeds. Signal received → workflow branches |
| **Replay safety** | SC must specify: workflow code is deterministic. Verify: replay workflow from history → same decisions, same result. No side effects in workflow code |

---

## A3. Probes

| Area | Probe Questions |
|------|----------------|
| **Workflow model** | Code-based (Temporal) or DSL-based (Step Functions)? Workflow language? |
| **Activities** | What activities exist? Timeout per activity? Heartbeat interval? |
| **Compensation** | Saga pattern used? Compensation actions defined for each step? |
| **Versioning** | How are workflow versions managed? Patching strategy for running workflows? |
| **Signals/queries** | External signals to running workflows? Query for workflow state? |
| **Scaling** | Worker count? Task queue routing? Rate limiting per workflow type? |

---

## A4. Constitution Injection

- **No I/O in workflow code**: Workflow functions must never make network calls, read files, or access databases directly. All I/O goes through activities
- **Determinism enforcement**: Workflow code must not use current time, random values, or mutable global state. Use workflow-provided time and random APIs
- **Compensation completeness**: Every state-changing activity must have a documented compensation action. "No compensation needed" must be explicitly stated and justified
- **Idempotent activities**: Activities may be retried. All activities must be idempotent or use idempotency keys

---

## A5. Bug Prevention Extensions

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| WE-001 | Non-deterministic workflow code | Workflow uses `Date.now()` or `Math.random()` → replay produces different decisions → workflow corruption | Use workflow-provided time/random APIs. Lint for forbidden APIs in workflow code |
| WE-002 | Missing compensation | Step 3 fails but step 2 has no compensation → inconsistent distributed state → manual intervention required | Require compensation action for every state-changing activity at spec time. No "TBD" compensations |
| WE-003 | Activity timeout too short | Activity timeout < actual execution time → activity killed → retried → cascading timeouts | Set timeouts based on measured p99 execution time + buffer. Use heartbeats for long-running activities |
| WE-004 | Workflow versioning break | New workflow code deployed → running workflows replay with new code → non-determinism error → workflow stuck | Use versioning/patching API. Never change existing workflow code — add new version branch |
| WE-005 | Unbounded workflow history | Workflow runs for months with thousands of events → history grows → replay becomes slow → memory exhaustion | Use "continue-as-new" to reset history periodically. Set maximum history length |
