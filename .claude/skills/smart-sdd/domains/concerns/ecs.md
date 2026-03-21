# Concern: ecs

> Entity-Component-System — data-oriented architecture separating entities, components, and systems.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/ecs.md`](../../../shared/domains/concerns/ecs.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Entity lifecycle: spawn with components → query by component set → modify components → despawn with cleanup
- System execution: system reads/writes specific component queries → execution order specified → no conflicting concurrent access
- Component composition: entity composed of independent components → components are plain data, no behavior → systems provide all logic
- Change detection: component added/changed/removed events → dependent systems react to changes only (not every frame)

### SC Anti-Patterns (reject)
- "Entity has behavior" — entities are IDs only; behavior lives in systems operating on component queries
- "Component processes data" — components are plain data structs; processing logic belongs in systems
- "Systems run" — must specify which components are queried, read vs write access, and execution ordering constraints

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Framework** | Bevy? specs? legion? Unity DOTS? Artemis? Custom ECS? |
| **Storage** | Archetype-based? Sparse set? Table storage? Hybrid? |
| **Scheduling** | Parallel system execution? System ordering constraints? Run conditions? Exclusive systems? |
| **Queries** | Component filters (With/Without/Added/Changed)? Optional components? Or-queries? |
| **Commands** | Deferred entity operations? Command buffers? When do commands flush? |
| **Events** | Event-driven systems? EventReader/EventWriter? Event lifetime (per-frame, buffered)? |

---

## S7. Bug Prevention — ECS-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| ECS-001 | System ordering bug | Systems accessing same components in undefined order → nondeterministic behavior | Explicit ordering constraints (before/after); system sets with defined execution order |
| ECS-002 | Component access conflict | Two systems write same component concurrently → data race | Borrow checker (Rust ECS) or explicit scheduling constraints; split read/write phases |
| ECS-003 | Archetype fragmentation | Too many unique component combinations → cache misses → performance degradation | Minimize unique component sets; use marker components sparingly; profile archetype count |
| ECS-004 | Deferred command confusion | Entity spawned in command buffer → queried before buffer flush → entity not found | Understand command flush points; apply_deferred between dependent systems |
| ECS-005 | Event missed | Event published in frame N → system reading events runs before publisher → event not seen until frame N+1 | System ordering ensures publisher runs before subscriber; or accept one-frame delay by design |
