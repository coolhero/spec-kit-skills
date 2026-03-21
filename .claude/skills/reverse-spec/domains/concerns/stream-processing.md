# Concern: stream-processing (reverse-spec)

> Stream processing detection. Identifies windowing, checkpointing, and event stream patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/stream-processing.md`](../../../shared/domains/concerns/stream-processing.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Stream processing framework (Kafka Streams, Flink, Spark Streaming, Beam)
- Windowing strategies used (tumbling, sliding, session) and window sizes
- Delivery guarantees (at-least-once, exactly-once) and implementation
- State store type and management (RocksDB, in-memory, compaction)
- Checkpoint configuration and recovery mechanism
- Backpressure handling and scaling strategy
