# Concern: stream-processing

> Windowing (tumbling/sliding/session), watermarks, exactly-once semantics, late data handling, checkpointing, backpressure.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: stream processing, Kafka Streams, Flink, windowing, watermark, exactly-once, backpressure, event stream, Spark Streaming, Beam

**Secondary**: tumbling window, sliding window, session window, late data, checkpoint, state store, changelog, partition, offset, consumer group, stream topology, join, co-partition, keyed state

### Code Patterns (R1 — for source analysis)

- Frameworks: `kafka-streams`, `@apache/flink`, `apache-beam`, `spark-streaming`, `risingwave`, `materialize`, `ksqlDB`
- Patterns: `.windowedBy()`, `TimeWindows.of()`, `.withWatermarks()`, `Checkpointed`, `ProcessFunction`, `KeyedStream`
- Kafka: `KafkaConsumer`, `KafkaProducer`, `StreamsBuilder`, `Topology`, `KStream`, `KTable`, `GlobalKTable`
- Backpressure: `Flux`, `Observable`, `Flow`, `Channel`, `buffer()`, `onBackpressure*()`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: message-queue, data-io
- **Profiles**: —
