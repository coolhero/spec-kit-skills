# Archetype: message-broker

> Message brokers and event streaming platforms — Kafka, RabbitMQ, NATS, Pulsar, and similar systems.
> Module type: archetype

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/message-broker.md`](../../../shared/domains/archetypes/message-broker.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Protocol Spec Conformance** | Implemented protocols (AMQP, MQTT, etc.) must strictly conform to their specifications. Wire compatibility is non-negotiable. | SCs must specify protocol version and conformance scope. Verify includes protocol conformance test suites. |
| **Message Ordering Guarantees** | Ordering semantics (per-partition, per-key, global) are explicitly defined and enforced. Weaker guarantees are documented, not hidden. | Every SC must state its ordering guarantee. Plan flags features that could break existing ordering semantics. |
| **Durability vs Throughput Tradeoff** | Every persistence decision (fsync frequency, replication ack policy) is an explicit tradeoff with clear configuration knobs. | SCs must specify durability level. Verify tests both fast (async flush) and durable (sync flush) configurations. |
| **Cluster Consensus** | Leader election, membership changes, and state replication use a well-defined consensus protocol. Split-brain scenarios are handled explicitly. | Features touching cluster coordination must specify consensus protocol, quorum, and partition behavior. |
| **Backpressure & Flow Control** | Slow consumers do not cause unbounded memory growth. Flow control mechanisms are built into the protocol layer. | SCs must specify flow control behavior under slow consumer scenarios. Verify includes backpressure testing. |

---

## A2. SC Generation Extensions

### Required SC Patterns (append to S1)
- **Protocol conformance**: SC specifies which protocol commands/operations are implemented and references spec sections
- **Delivery guarantee**: SC specifies at-most-once, at-least-once, or exactly-once per feature, not per system
- **Cluster behavior**: SC specifies behavior during leader election, node failure, and partition — not just happy path
- **Storage lifecycle**: SC specifies message retention policy, segment rotation, and compaction strategy

### SC Anti-Patterns (reject)
- "Broker delivers messages" — must specify delivery guarantee, ordering, and behavior under consumer failure
- "Cluster is fault-tolerant" — must specify how many node failures are tolerated, consensus protocol, and recovery time
- "Messages are persisted" — must specify fsync policy, replication factor, and retention/compaction strategy

---

## A3. Elaboration Probes (append to S5)

| Sub-domain | Probe Questions |
|------------|----------------|
| **Protocol** | AMQP? MQTT? Kafka protocol? NATS? Custom? Multi-protocol? |
| **Storage** | Commit log? Append-only segments? In-memory only? Tiered storage? |
| **Cluster** | Raft? ZAB? Gossip? Controller-based (Kafka KRaft)? Minimum cluster size? |
| **Consumer model** | Consumer groups? Competing consumers? Exclusive consumers? Fan-out? |
| **Retention** | Time-based? Size-based? Compacted (key-based)? Infinite retention? |
| **Observability** | Consumer lag monitoring? Broker health metrics? Message tracing? |

---

## A4. Constitution Injection

| Principle | Rationale |
|-----------|-----------|
| Protocol implementations must pass official conformance test suites — wire compatibility is mandatory | Clients depend on protocol spec behavior; non-conformance causes subtle interoperability failures |
| Message ordering guarantees must be explicit per-topic/per-queue — never silently weaken ordering | Applications built on ordering assumptions break silently when ordering changes; document guarantees upfront |
| Every persistence configuration must expose the durability-throughput tradeoff — no hidden defaults | Operators must understand what they trade for performance; hidden async flush causes data loss surprises |
| Cluster membership changes must use safe consensus protocol — no manual coordination during rolling updates | Manual coordination during membership changes is error-prone; safe reconfiguration prevents split-brain |
| Slow consumers must trigger flow control — never unbounded buffering on the broker side | Unbounded buffering for slow consumers causes broker OOM; flow control preserves cluster stability |

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Protocol(s) | Which wire protocols are implemented and version(s) |
| Delivery guarantee | at-most-once, at-least-once, or exactly-once stated |
| Storage model | Message persistence strategy (commit log, segments, in-memory) identified |
| Cluster model | Consensus protocol and minimum topology stated (or single-node) |
