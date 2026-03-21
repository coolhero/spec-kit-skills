# Concern: schema-registry

> Schema evolution and compatibility management — registration, versioning, compatibility validation, and consumer migration.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/schema-registry.md`](../../../shared/domains/concerns/schema-registry.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Schema registration: submit schema (Avro/Protobuf/JSON Schema) → validate syntax → assign unique ID → store in registry → return ID
- Compatibility check: new schema version submitted → compare against existing version(s) → evaluate compatibility level (backward/forward/full/none) → accept or reject
- Schema evolution: add optional field with default (backward compatible) → verify old consumers read new data; remove field (breaking) → require major version bump → migration plan
- Consumer migration: old consumer encounters new schema → deserialize with reader schema → handle unknown fields gracefully → no crash or data loss

### SC Anti-Patterns (reject)
- "Schema is versioned" — must specify compatibility mode (backward, forward, full, none), versioning strategy, and what happens when compatibility check fails
- "Consumers handle schema changes" — must specify deserialization behavior for unknown fields, missing optional fields, and type promotion rules
- "Data is validated" — must specify validation point (producer-side, broker-side, consumer-side), rejection behavior, and dead-letter handling for invalid data

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Format** | Avro? Protobuf? JSON Schema? Thrift? Custom? Multiple formats coexisting? |
| **Compatibility** | Backward only? Forward only? Full? Transitive? Compatibility checked against which versions? |
| **Registry** | Confluent Schema Registry? AWS Glue? Custom registry? HA/replication? |
| **Evolution** | Field addition/removal rules? Type promotion (int→long)? Enum evolution? Nested schema changes? |
| **Integration** | Producer-side validation? Consumer-side validation? Broker enforcement? CI/CD schema validation? |

---

## S7. Bug Prevention — Schema Registry-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| SR-001 | Breaking schema without version bump | Required field added without default → old consumers cannot deserialize → consumer crash or data loss | Enforce compatibility check in CI/CD; reject incompatible changes at registry level; require explicit compatibility override with approval |
| SR-002 | Missing default values | New optional field added without default value → old consumers see null where they expect a value → NPE or logic error | Schema linter requires defaults for all new fields; integration test with previous schema version reader |
| SR-003 | Schema ID collision | Two different schemas assigned same ID → consumers deserialize with wrong schema → silent data corruption | Use monotonic ID assignment with uniqueness constraint; content-hash based deduplication; registry-level locking |
| SR-004 | Unbounded schema versions | No cleanup of old versions → registry storage grows indefinitely → query performance degrades → registry outage | Configure version retention policy; archive old versions; alert on version count thresholds per subject |
| SR-005 | Consumer deserialization failure | Consumer schema cache stale → new schema ID not found → deserialization fails → message processing stops | Consumer-side schema cache with TTL refresh; graceful fallback to registry fetch; dead-letter queue for undeserializable messages |
