# Archetype: Message Broker (reverse-spec)

> Message broker/event streaming detection

## R1. Detection Signals

> See [`shared/domains/archetypes/message-broker.md`](../../../shared/domains/archetypes/message-broker.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **Queue-based** — Traditional message queuing, exchange/binding routing, per-message acknowledgment (RabbitMQ)
- **Log-based** — Append-only log, offset tracking, replay capability (Kafka, Redpanda)
- **Lightweight** — Minimal protocol overhead, pub/sub + request/reply, low latency (NATS)
- **Embedded** — In-process streaming, integrated with data store (Redis Streams)

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Message routing (topic/queue semantics, exchange types, routing key patterns, wildcard subscriptions)
- Delivery guarantees (at-most-once, at-least-once, exactly-once, idempotency mechanisms)
- Persistence/retention (durable queues, log retention policies, compaction, snapshotting)
- Consumer groups (group coordination, partition assignment, rebalancing strategy, offset management)
- Partition strategy (key-based partitioning, partition count, ordering guarantees per partition)
- Protocol support (AMQP, MQTT, custom binary protocol, gRPC, WebSocket)
