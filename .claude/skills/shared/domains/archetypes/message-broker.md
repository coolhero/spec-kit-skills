# Archetype: message-broker

> Message brokers and event streaming platforms — Kafka, RabbitMQ, NATS, Pulsar, and similar systems.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: broker, queue, topic, partition, consumer group, AMQP, MQTT, RESP, cluster, replication, raft, consensus, producer, consumer, message broker, event streaming

**Secondary**: offset, commit log, retention, dead letter queue, exactly-once, at-least-once, acknowledgment, durable subscription, fanout, exchange, routing key, backpressure

### Code Patterns (A0 — for source analysis)

- **Protocol**: AMQP frame parser, MQTT packet handler, RESP command parser, custom binary protocol implementation
- **Storage**: commit log (append-only), segment files, index files, compaction, retention policies
- **Cluster**: Raft/ZAB consensus, controller election, partition assignment, ISR (in-sync replicas)
- **Producer/Consumer**: publish API, subscribe API, consumer group coordination, offset management, rebalancing
- **Config**: broker config (listeners, log dirs, replication factor), topic-level configs

---

## A1: Core Principles

| Principle | Description |
|-----------|-------------|
| **Protocol Spec Conformance** | Implemented protocols (AMQP, MQTT, etc.) must strictly conform to their specifications. Wire compatibility is non-negotiable. |
| **Message Ordering Guarantees** | Ordering semantics (per-partition, per-key, global) are explicitly defined and enforced. Weaker guarantees are documented, not hidden. |
| **Durability vs Throughput Tradeoff** | Every persistence decision (fsync frequency, replication ack policy) is an explicit tradeoff with clear configuration knobs. |
| **Cluster Consensus** | Leader election, membership changes, and state replication use a well-defined consensus protocol. Split-brain scenarios are handled explicitly. |
| **Backpressure & Flow Control** | Slow consumers do not cause unbounded memory growth. Flow control mechanisms (credits, quotas, blocking) are built into the protocol layer. |

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: cli, wire-protocol
- **Common pairings**: distributed-consensus, wire-protocol
