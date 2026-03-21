# Concern: scheduling-algorithm

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Task scheduling (preemptive/cooperative), resource allocation, bin packing, priority queues, deadline scheduling, constraint solving.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/scheduling-algorithm.md`](../../../shared/domains/concerns/scheduling-algorithm.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Task scheduling: task submitted with priority and resource requirements → scheduler evaluates available resources → task assigned to resource slot using scheduling policy (FIFO, priority, deadline) → task executed → completion reported → resource released → next task dequeued
- Resource allocation: resource request received → available capacity checked → allocation strategy applied (first-fit, best-fit, bin packing) → resources reserved → allocation confirmed → on task completion, resources returned to pool → fragmentation metrics updated
- Deadline scheduling: task submitted with deadline → scheduler computes slack time (deadline - estimated duration - current time) → tasks ordered by earliest deadline first → deadline miss risk evaluated → at-risk tasks escalated or preempted → deadline adherence tracked
- Constraint solving: constraints defined (resource limits, dependencies, time windows, exclusions) → solver explores feasible solutions → optimal or near-optimal schedule produced → schedule validated against all constraints → schedule executed → constraint violations detected at runtime trigger re-scheduling

### SC Anti-Patterns (reject if seen)
- "Tasks are scheduled" — must specify scheduling policy, priority scheme, and what happens when resources are exhausted
- "Resources are allocated efficiently" — must specify allocation algorithm, fragmentation handling, and capacity monitoring
- "Deadlines are met" — must specify what happens on deadline miss, how priority is determined, and preemption policy

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Policy** | FIFO? Priority-based? Earliest deadline first? Fair share? Custom? |
| **Preemption** | Preemptive or cooperative? What triggers preemption? How is preempted task state saved? |
| **Resources** | What resources are scheduled (CPU, memory, GPUs, workers, rooms, vehicles)? Heterogeneous? |
| **Constraints** | Time windows? Dependencies between tasks? Mutual exclusion? Resource affinity? |
| **Scale** | Task volume? Scheduling latency requirement? Online vs batch scheduling? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| SCH-001 | Priority inversion | Low-priority task holds resource needed by high-priority task → high-priority task blocked → deadline miss | Implement priority inheritance or priority ceiling protocol; monitor wait times by priority level; detect and alert on inversions |
| SCH-002 | Starvation | Low-priority tasks never scheduled because high-priority tasks continuously arrive → low-priority tasks wait indefinitely | Implement aging (priority boost over wait time); set maximum wait time; monitor per-priority queue depth and wait time |
| SCH-003 | Resource leak on task failure | Task crashes without releasing allocated resources → resources permanently unavailable → capacity gradually shrinks → scheduling failures | Implement resource lease with timeout; watchdog reclaims resources from dead tasks; track allocated vs active resources |
| SCH-004 | Bin packing fragmentation | Suboptimal allocation leaves many small gaps → large tasks cannot be scheduled despite sufficient total capacity → artificial resource shortage | Implement defragmentation/compaction; use best-fit or score-based allocation; monitor fragmentation ratio; periodic re-packing |
| SCH-005 | Constraint solver timeout | Complex constraints → solver takes too long → scheduling decision delayed → tasks queue up → system throughput drops | Set solver timeout with fallback to heuristic; cache solutions for similar inputs; decompose large problems; monitor solve time |
