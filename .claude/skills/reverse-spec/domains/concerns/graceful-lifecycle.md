# Concern: graceful-lifecycle (reverse-spec)

> Server process lifecycle detection. Identifies health check, graceful shutdown, and startup readiness patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/graceful-lifecycle.md`](../../../shared/domains/concerns/graceful-lifecycle.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Shutdown handler implementation and signal handling
- Health check endpoint paths and dependency checks
- Startup warm-up sequence and readiness gates
- Connection draining timeout and in-flight request handling
- Process lifecycle state machine (starting → ready → draining → stopped)
