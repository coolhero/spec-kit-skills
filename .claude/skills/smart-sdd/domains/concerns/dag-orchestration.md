# Concern: dag-orchestration

> DAG-based workflow orchestration — Airflow, Prefect, Dagster, dbt, and similar task dependency engines.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/dag-orchestration.md`](../../../shared/domains/concerns/dag-orchestration.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Task dependency: upstream tasks complete successfully → downstream tasks execute → dependency violations detected before execution
- Failure handling: task failure → retry with backoff → max retries exhausted → alert/skip/fail-DAG behavior specified
- Idempotency: re-running a completed task with same inputs → same outputs, no duplicate side effects
- Data passing: task output → downstream task input mechanism specified (XCom, asset materialization, file, DB)

### SC Anti-Patterns (reject)
- "Pipeline runs successfully" — must specify which tasks, their dependencies, failure behavior, and retry policy
- "Data flows between tasks" — must specify passing mechanism, serialization, and size limits
- "DAG is scheduled" — must specify schedule interval, catchup behavior, and backfill strategy

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Framework** | Airflow? Prefect? Dagster? dbt? Custom scheduler? |
| **Dependencies** | Linear chain? Diamond? Dynamic task generation? Cross-DAG dependencies? |
| **Scheduling** | Cron-based? Event-triggered? Manual-only? Catchup on missed runs? |
| **Data passing** | XCom? Materialized assets? Shared filesystem? Database tables? Size constraints? |
| **Failure** | Retry policy (count, delay, backoff)? Partial DAG re-run? Task-level vs DAG-level failure handling? |
| **Observability** | Task duration tracking? SLA monitoring? Data lineage? Alert channels? |

---

## S7. Bug Prevention — DAG-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| DAG-001 | Circular dependency | DAG definition allows cycles → scheduler hangs or crashes | Validate DAG is acyclic at parse time; reject cyclic definitions |
| DAG-002 | Non-idempotent task | Re-run inserts duplicate rows or sends duplicate notifications | Design tasks as idempotent (upsert, deduplicate, check-before-write) |
| DAG-003 | XCom/data bloat | Large objects passed between tasks via metadata store → DB/memory bloat | Size limits on inter-task data; use object storage for large payloads, pass references only |
| DAG-004 | Backfill data corruption | Catchup runs process historical data with current logic → incorrect results | Backfill-aware logic; parameterize by execution date, not wall clock |
| DAG-005 | Silent task skip | Trigger rule misconfiguration → downstream tasks skip without error | Explicit trigger rules per task; alerting on unexpected skip states |
