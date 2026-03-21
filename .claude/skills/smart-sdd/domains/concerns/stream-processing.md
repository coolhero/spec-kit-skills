# Concern: stream-processing

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Windowing (tumbling/sliding/session), watermarks, exactly-once semantics, late data handling, checkpointing, backpressure.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/stream-processing.md`](../../../shared/domains/concerns/stream-processing.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Windowed aggregation: events ingested → assigned to window(s) based on event time → watermark advances → window closed when watermark passes window end → aggregation computed → result emitted → late events handled per policy (drop/update/side-output)
- Exactly-once processing: event consumed → processing + state update + output emission within single transaction → on failure, state rolled back to last checkpoint → reprocessing from checkpoint offset → no duplicate output
- Checkpointing: periodic checkpoint triggered → operator state snapshot taken → snapshot persisted to durable storage → checkpoint ID recorded → on failure, restore from latest completed checkpoint → resume from checkpoint offsets
- Backpressure: downstream consumer slower than upstream producer → buffer fills → backpressure signal propagated upstream → producer rate reduced → buffer drains → normal rate resumed

### SC Anti-Patterns (reject if seen)
- "Events are processed in real-time" — must specify windowing strategy, event time vs processing time, and watermark policy
- "No data is lost" — must specify delivery guarantee (at-least-once, exactly-once), checkpoint interval, and failure recovery mechanism
- "High throughput is supported" — must specify partitioning strategy, parallelism level, and backpressure handling

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Framework** | Kafka Streams? Flink? Spark Streaming? Beam? Custom? What drove the choice? |
| **Windowing** | Tumbling? Sliding? Session? What window sizes? Allowed lateness? |
| **Guarantees** | At-least-once? Exactly-once? Idempotent consumers? Transaction boundaries? |
| **State** | State store type (RocksDB, in-memory)? State size? Compaction? TTL? |
| **Scaling** | Partition count? Consumer group rebalancing strategy? Auto-scaling? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| SP-001 | Event time skew | Processing time used instead of event time → windows contain wrong events → aggregations incorrect during backlog processing | Always use event time; configure watermark generator; monitor event time skew metric; reject events with future timestamps |
| SP-002 | Checkpoint too infrequent | Long checkpoint interval → large state to replay on failure → long recovery time → extended downtime | Set checkpoint interval proportional to acceptable recovery time; monitor checkpoint duration; alert if checkpoint takes > 50% of interval |
| SP-003 | State store unbounded growth | No TTL on state entries → state grows indefinitely → memory/disk exhaustion → operator crash | Configure state TTL per operator; use session window expiry; monitor state size metric; alert on growth rate anomaly |
| SP-004 | Poison message loop | Malformed event causes processing failure → event retried → fails again → infinite retry loop → consumer stuck | Implement dead-letter queue; skip after N retries; log malformed events with context; alert on DLQ growth |
| SP-005 | Rebalance storm | Frequent consumer group rebalances → state migration overhead → processing gaps → duplicate outputs | Use static group membership; configure long session timeout; use cooperative rebalancing; monitor rebalance frequency |
