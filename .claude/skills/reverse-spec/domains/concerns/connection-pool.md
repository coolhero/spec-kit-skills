# Concern: connection-pool (reverse-spec)

> Connection pool detection. Identifies database, HTTP client, and resource pool configurations.

## R1. Detection Signals

> See [`shared/domains/concerns/connection-pool.md`](../../../shared/domains/concerns/connection-pool.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Pool library and configuration (min/max size, timeouts)
- Resources being pooled (DB connections, HTTP clients, gRPC channels, thread pools)
- Connection validation and eviction strategies
- Pool exhaustion handling (queue, reject, timeout)
- Shutdown behavior for pooled connections
