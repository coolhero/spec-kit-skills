# Archetype: game-engine

> Game engines and interactive simulations — Unity, Unreal, Godot, Bevy, custom engines.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: game engine, game loop, ECS, entity component system, scene graph, scene tree, sprite, renderer, physics engine, asset pipeline, shader, frame rate, tick

**Secondary**: delta time, fixed update, draw call, GPU, mesh, material, collider, rigidbody, animation controller, input system, audio engine, level editor, prefab, asset bundle

### Code Patterns (A0 — for source analysis)

- **Game loop**: `Update()`/`FixedUpdate()` (Unity), `_process()`/`_physics_process()` (Godot), `fn update()` system (Bevy), `Tick()` (Unreal)
- **ECS**: `#[derive(Component)]`, `Query<>`, `Commands` (Bevy); `IComponentData`, `SystemBase` (Unity DOTS)
- **Scene**: scene tree hierarchy, node/entity parenting, transform propagation
- **Rendering**: shader files (`.shader`, `.glsl`, `.hlsl`, `.wgsl`), render pipeline config, material definitions
- **Assets**: asset import pipelines, `.meta` files (Unity), `.import` files (Godot), asset registries
- **Build**: platform-specific export configs, build profiles (debug/release/shipping)

---

## A1: Core Principles

| Principle | Description |
|-----------|-------------|
| **Deterministic Update Loop** | Game state advances in fixed timesteps. Variable frame rate does not affect simulation correctness. |
| **Data-Oriented Design (ECS)** | Prefer composition over inheritance. Components are plain data; Systems are stateless logic operating on component queries. |
| **Render-Update Separation** | Game logic update and rendering are decoupled. Simulation can run at different frequency than display refresh. |
| **Asset Lifecycle Management** | Assets are loaded, cached, and unloaded explicitly. Memory budgets per asset type are enforced. |
| **Scene Hierarchy** | Entities are organized in a spatial/logical tree. Transform, visibility, and lifecycle propagate through the hierarchy. |
| **Frame Budget Discipline** | Every system has a time budget per frame. Profiling identifies budget violations before they become user-visible stutters. |

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: gui, cli
- **Common pairings**: ecs, hardware-io
