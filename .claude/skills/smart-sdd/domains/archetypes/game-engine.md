# Archetype: game-engine

> Game engines and interactive simulations — Unity, Unreal, Godot, Bevy, custom engines.
> Module type: archetype

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/game-engine.md`](../../../shared/domains/archetypes/game-engine.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Deterministic Update Loop** | Game state advances in fixed timesteps. Variable frame rate does not affect simulation correctness. | SCs must specify whether logic runs in fixed update or variable update. Verify must test simulation consistency across frame rates. |
| **Data-Oriented Design (ECS)** | Prefer composition over inheritance. Components are plain data; Systems are stateless logic operating on component queries. | Features must be scoped as systems + components, not OOP class hierarchies. SCs specify component queries, not method calls. |
| **Render-Update Separation** | Game logic update and rendering are decoupled. Simulation can run at different frequency than display refresh. | Features must specify which loop they belong to (logic or render). No rendering logic in simulation update and vice versa. |
| **Asset Lifecycle Management** | Assets are loaded, cached, and unloaded explicitly. Memory budgets per asset type are enforced. | SCs must specify asset loading strategy (preload, lazy, streaming) and unload triggers. Verify checks for memory leaks. |
| **Scene Hierarchy** | Entities organized in spatial/logical tree. Transform, visibility, and lifecycle propagate through the hierarchy. | Features modifying scene structure must specify parent-child relationships and propagation behavior. |
| **Frame Budget Discipline** | Every system has a time budget per frame. Profiling identifies budget violations before they become user-visible stutters. | Plan must flag features at risk of exceeding frame budget. Verify includes performance profiling under load. |

---

## A2. SC Generation Extensions

### Required SC Patterns (append to S1)
- **Update loop placement**: SC specifies whether the feature runs in fixed update (physics), variable update (logic), or render loop
- **Component schema**: SC specifies new components introduced (data layout) and which systems query them
- **Asset dependencies**: SC specifies which assets are required, loading strategy, and memory budget impact
- **Frame budget**: SC specifies expected per-frame cost and acceptable worst-case latency

### SC Anti-Patterns (reject)
- "Game feature works" — must specify update loop placement, component queries, and frame budget impact
- "Assets load" — must specify loading strategy (preload/lazy/streaming), memory budget, and unload trigger
- "Physics behaves correctly" — must specify timestep (fixed/variable), determinism requirement, and collision handling

---

## A3. Elaboration Probes (append to S5)

| Sub-domain | Probe Questions |
|------------|----------------|
| **Engine** | Unity? Unreal? Godot? Bevy? Custom? Which version? |
| **Architecture** | ECS? Component-based OOP? Scene graph? Hybrid? |
| **Rendering** | 2D? 3D? Which graphics API (Vulkan, DirectX, Metal, WebGPU, OpenGL)? Render pipeline? |
| **Physics** | Built-in physics? Third-party (Rapier, Box2D, PhysX)? Deterministic simulation needed? |
| **Networking** | Single-player? Local multiplayer? Networked (client-server, P2P)? Rollback netcode? |
| **Platform** | Desktop? Console? Mobile? Web (WASM)? Cross-platform build pipeline? |

---

## A4. Constitution Injection

| Principle | Rationale |
|-----------|-----------|
| Game logic must run in fixed timestep loops — variable frame rate must not affect simulation outcomes | Variable timestep causes non-deterministic physics, speed-dependent gameplay, and unreproducible bugs |
| Components are plain data structs with no behavior — all logic lives in systems | Behavior in components creates hidden coupling; data-oriented design enables parallelism and cache efficiency |
| Every system must declare its component read/write access explicitly — no implicit global state | Implicit dependencies create ordering bugs and prevent parallel execution; explicit access enables ECS scheduling |
| Asset loading must specify memory budget and unload strategy — no fire-and-forget loads | Unmanaged asset loading causes memory exhaustion on constrained platforms (console, mobile, WASM) |
| Performance-sensitive code paths must have profiling instrumentation from day one | Frame budget violations caught late are expensive to fix; early profiling prevents architectural rework |

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Engine/framework | Target engine or custom engine architecture identified |
| Update model | Fixed vs variable timestep clarified; which loop each feature uses |
| Data architecture | ECS, component OOP, or hybrid approach stated |
| Target platforms | Supported platforms and any platform-specific constraints listed |
