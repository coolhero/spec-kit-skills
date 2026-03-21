# Concern: schema-registry (reverse-spec)

> Schema evolution detection. Identifies schema registration, compatibility checking, and versioning patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/schema-registry.md`](../../../shared/domains/concerns/schema-registry.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Schema format (Avro, Protobuf, JSON Schema, Thrift)
- Compatibility mode (backward, forward, full, none)
- Registry implementation (Confluent, AWS Glue, custom)
- Version management strategy and retention policy
- Producer/consumer-side validation patterns
- Migration tooling and breaking change handling
