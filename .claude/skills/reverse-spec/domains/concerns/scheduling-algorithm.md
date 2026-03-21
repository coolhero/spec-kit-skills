# Concern: scheduling-algorithm (reverse-spec)

> Scheduling algorithm detection. Identifies task schedulers, resource allocation, and constraint solving patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/scheduling-algorithm.md`](../../../shared/domains/concerns/scheduling-algorithm.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Scheduling policy (FIFO, priority-based, deadline-first, fair share)
- Resource types managed (CPU, memory, workers, GPU, custom)
- Preemption support and mechanism
- Constraint types and solver implementation
- Bin packing or allocation algorithm used
- Starvation prevention and priority aging strategy
