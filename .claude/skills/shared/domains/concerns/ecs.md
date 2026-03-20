# Concern: ecs (Entity-Component-System)

> ECS architecture pattern — data-oriented design separating entities, components, and systems.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: Component, System, Query, World, Entity, Bundle, Resource, Schedule, ECS, entity component system, data-oriented design

**Secondary**: archetype, sparse set, table storage, system ordering, change detection, added/changed/removed filters, command buffer, exclusive system, run criteria

### Code Patterns (R1 — for source analysis)

- **Bevy**: `#[derive(Component)]`, `#[derive(Resource)]`, `Query<>`, `Commands`, `App::new().add_systems()`, `SystemParam`, `EventReader`/`EventWriter`
- **specs**: `Component`, `System`, `ReadStorage`, `WriteStorage`, `Join`, `World`
- **legion**: `#[system]`, `World`, `Query`, `ComponentTuple`
- **Unity DOTS**: `IComponentData`, `SystemBase`, `EntityQuery`, `EntityManager`, `BurstCompile`
- **Artemis** (Java): `@All`, `@One`, `@Exclude`, `BaseEntitySystem`, `ComponentMapper`
- **Common**: component struct definitions, system function signatures with query parameters, world/registry initialization, entity spawn/despawn patterns

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: game-engine (archetype), hardware-io
- **Profiles**: —
