# Concern: simulation-engine (reverse-spec)

> Simulation engine detection. Identifies physics engines, discrete event simulation, and Monte Carlo patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/simulation-engine.md`](../../../shared/domains/concerns/simulation-engine.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Simulation type (physics, discrete event, agent-based, Monte Carlo)
- Time-stepping method (fixed, variable, substeps) and step size
- State snapshot and serialization format
- Determinism strategy (RNG seeding, floating-point handling, iteration order)
- Spatial partitioning and collision detection approach
- Output metrics and visualization pipeline
