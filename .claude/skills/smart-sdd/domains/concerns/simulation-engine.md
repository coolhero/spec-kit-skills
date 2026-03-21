# Concern: simulation-engine

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Physics simulation, discrete event simulation, time-stepping, state snapshots, deterministic replay, Monte Carlo methods.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/simulation-engine.md`](../../../shared/domains/concerns/simulation-engine.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Simulation loop: initial state set → time step executed → physics/rules applied → collisions/interactions resolved → state updated → time advanced → loop continues until termination condition → final state captured
- State snapshot: simulation paused or checkpoint interval reached → complete state serialized (positions, velocities, RNG state, event queue) → snapshot stored with simulation time → simulation resumes → snapshot available for rollback or replay
- Deterministic replay: snapshot loaded → RNG state restored → simulation advanced from snapshot → identical sequence of events produced → replay verified against original (bit-exact or tolerance-based) → divergence detected and reported
- Monte Carlo: parameter distributions defined → N iterations configured → each iteration: sample parameters → run simulation → collect results → aggregate statistics (mean, variance, percentiles, confidence intervals) → convergence checked

### SC Anti-Patterns (reject if seen)
- "Simulation runs" — must specify time-stepping method (fixed/variable), state representation, and termination condition
- "Results are reproducible" — must specify RNG seeding strategy, floating-point determinism approach, and snapshot format
- "Monte Carlo analysis done" — must specify parameter distributions, iteration count, convergence criteria, and output statistics

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Type** | Physics simulation? Discrete event? Agent-based? Monte Carlo? Hybrid? |
| **Time stepping** | Fixed timestep? Variable? What dt? Substeps for stability? |
| **Determinism** | Required? How is floating-point determinism ensured? Cross-platform reproducibility? |
| **Scale** | Entity count? Interaction complexity (N^2, spatial partitioning)? GPU acceleration? |
| **Output** | What metrics captured? Visualization? Data export format? Real-time vs batch? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| SIM-001 | Non-deterministic replay | Different results on replay due to floating-point ordering, uninitialized state, or non-deterministic iteration order → cannot reproduce bugs → untestable | Use fixed RNG seed; sort entities deterministically; avoid hash-map iteration; validate replay against recording |
| SIM-002 | Timestep instability | Variable or too-large timestep → simulation explodes (energy injection, tunneling, divergence) → invalid results | Use fixed timestep with interpolation for rendering; implement energy conservation checks; clamp maximum dt |
| SIM-003 | Incomplete snapshot | State snapshot missing RNG state, event queue, or internal counters → restore produces different trajectory → snapshot useless | Enumerate all state components in snapshot schema; validate snapshot completeness on save; test restore-and-continue |
| SIM-004 | Spatial partitioning boundary | Entity near partition boundary missed in neighbor queries → missed collision/interaction → simulation incorrectly skips interaction | Use overlapping partitions or ghost cells; test with entities exactly on boundaries; validate partition query completeness |
| SIM-005 | Monte Carlo insufficient samples | Too few iterations → high variance in results → false confidence in unreliable estimates | Implement convergence detection (coefficient of variation < threshold); report confidence intervals; warn if not converged |
