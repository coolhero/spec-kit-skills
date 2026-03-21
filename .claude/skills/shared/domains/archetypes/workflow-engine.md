# Archetype: workflow-engine

> Durable execution engines, workflow orchestrators with history replay, saga coordination.
> Distinct from task-worker: stateful, durable, replayable. Not fire-and-forget job queues.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: workflow engine, durable execution, Temporal, Cadence, saga, activity, workflow definition, orchestrator, step function, state machine

**Secondary**: history replay, workflow replay, compensation, timer, signal, query, child workflow, continue-as-new, deterministic replay, event sourcing, workflow versioning

### Code Patterns (R1 — for source analysis)

- Temporal: `temporalio`, `@temporalio/workflow`, `@temporalio/activity`, `workflow.Execute`, `activity.RegisterActivity`
- Go: `go.temporal.io/sdk`, `workflow.Context`, `activity.Context`, `workflow.ExecuteActivity`
- Python: `temporalio`, `@workflow.defn`, `@activity.defn`, `@workflow.run`
- Cadence: `go.uber.org/cadence`, `cadence.Workflow`, `cadence.Activity`
- AWS Step Functions: `StateMachine`, `states-language`, `Parallel`, `Choice`, `Wait`
- Patterns: `CompensatingTransaction`, `Saga`, `RetryPolicy`, `StartToCloseTimeout`, `ScheduleToStartTimeout`

---

## Module Metadata

- **Axis**: Archetype
- **Common interfaces**: http-api (API gateway), cli (worker binary)
- **Common concerns**: resilience, observability, graceful-lifecycle, task-worker (for activity execution)
- **Profiles**: —
