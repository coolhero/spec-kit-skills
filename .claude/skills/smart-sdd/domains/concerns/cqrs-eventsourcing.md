# Concern: cqrs-eventsourcing

> CQRS / Event Sourcing — separate read/write models, event-driven state, projections, sagas.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/cqrs-eventsourcing.md`](../../../shared/domains/concerns/cqrs-eventsourcing.md) § S0: Detection Signals

---

## S1. SC Generation Rules

### Required SC Patterns
- Command → Event flow: command validation → aggregate state check → event(s) emitted → event persisted → projection updated
- Event replay: aggregate rebuilt from event stream → current state matches expected state
- Projection consistency: event handler updates read model → read model reflects all published events (eventually consistent)
- Saga/Process Manager: triggering event → compensating action on failure → terminal state reached

### SC Anti-Patterns (reject)
- "Command is processed" — must specify which aggregate, what validation, what event(s) emitted, what state transitions
- "Read model is updated" — must specify which events trigger the projection, what denormalized shape, consistency guarantee (sync/async)
- "Events are stored" — must specify serialization format, schema versioning strategy, and replay capability

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Event store** | EventStoreDB? Relational table? Kafka as log? Custom append-only store? |
| **Aggregates** | What aggregates exist? What invariants does each enforce? Aggregate size/event count limits? |
| **Projections** | Sync or async projections? How many read models? Rebuild strategy (replay all vs snapshot)? |
| **Sagas** | Cross-aggregate workflows? Compensation on failure? Saga state persistence? |
| **Versioning** | Event schema evolution strategy? Upcasters? Weak schema (JSON) or strong schema (Protobuf/Avro)? |
| **Snapshotting** | Snapshot frequency? Snapshot + tail replay? Snapshot storage? |

---

## S7. Bug Prevention — CQRS/ES-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| ES-001 | Event ordering violation | Concurrent commands on same aggregate produce interleaved events → corrupted state | Optimistic concurrency (expected version on append); one aggregate = one stream |
| ES-002 | Projection drift | Projection misses events or processes out of order → stale/inconsistent read model | Idempotent event handlers with position tracking; rebuild capability from event stream |
| ES-003 | Schema evolution break | New event version breaks deserialization of old events → replay fails | Upcasters or multi-version deserializers; never delete/rename event fields, only add |
| ES-004 | Unbounded event stream | Aggregate with millions of events → slow rebuild on every command | Snapshotting at configurable intervals; snapshot + tail replay pattern |
| ES-005 | Saga stuck in intermediate state | Compensating action fails → saga neither completes nor rolls back | Saga state persistence with retry; dead letter routing for unrecoverable sagas |
