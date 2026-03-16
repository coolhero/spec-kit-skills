# Concern: message-queue

> Message broker and event bus patterns. Applies when the project uses async messaging for inter-service communication, event-driven workflows, or background task dispatch.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/message-queue.md`](../../../shared/domains/concerns/message-queue.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Message publish + consume lifecycle: produce → broker ack → consume → process → ack/nack
- Dead letter handling: max retries exceeded → DLQ routing → alert/log
- Message ordering: specify guarantee level (per-partition ordering / no ordering / total ordering)
- Idempotency: duplicate message delivery → no duplicate side effects (idempotency key or deduplication)

### SC Anti-Patterns (reject)
- "Messages are processed" — must specify delivery guarantee (at-most-once/at-least-once/exactly-once), retry policy, failure routing
- "Queue handles load" — must specify max queue depth, backpressure strategy (reject/drop/block), consumer scaling behavior
- "Events are published" — must specify event schema, serialization format, and consumer contract

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Broker** | Which broker? RabbitMQ? Kafka? Redis Streams? In-memory? Multiple brokers? |
| **Delivery** | At-most-once? At-least-once? Exactly-once? Idempotency strategy? |
| **Failure** | Retry policy (count, backoff)? Dead letter queue? Poison message handling? |
| **Scaling** | Consumer group? Partition strategy? Competing consumers? Backpressure? |
| **Serialization** | JSON? Protobuf? Avro? Schema registry? Schema evolution strategy? |
| **Observability** | Queue depth monitoring? Consumer lag alerting? Message tracing? |

---

## S7. Bug Prevention — Message Queue-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| MQ-001 | Message loss on crash | Consumer acks before processing completes → message lost on crash | Ack AFTER processing completes, or use transactional outbox pattern |
| MQ-002 | Unbounded queue growth | Producer faster than consumer with no backpressure → OOM | Set max queue length + reject/drop policy; monitor queue depth |
| MQ-003 | Poison message loop | Malformed message causes consumer crash → redelivery → infinite loop | Max retry count + DLQ routing after exhaustion |
| MQ-004 | Duplicate processing | At-least-once delivery without idempotency → duplicate side effects | Idempotency key per message; deduplication table or check-before-write |
| MQ-005 | Ordering violation | Parallel consumers break assumed ordering | Partition by ordering key, or single consumer per ordered stream |
