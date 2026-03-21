# Archetype: Game Engine (reverse-spec)

> Game engine/interactive simulation detection

## R1. Detection Signals

> See [`shared/domains/archetypes/game-engine.md`](../../../shared/domains/archetypes/game-engine.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **Full engine** — Complete game engine with editor, renderer, physics, audio (Godot, Bevy)
- **Framework** — Game development framework without full editor tooling (Pygame, Love2D)
- **Component** — Standalone ECS library or game subsystem (ECS library, physics engine, renderer)

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Game loop architecture (fixed vs variable timestep, update/render separation, frame pacing)
- ECS implementation (entity storage, component layout, system scheduling, archetype queries)
- Rendering pipeline (scene graph, draw call batching, shader management, camera system)
- Physics integration (collision detection, rigid body dynamics, spatial partitioning, fixed-step simulation)
- Asset management (resource loading, hot-reloading, asset pipeline, format conversion)
- Input handling (input mapping, action system, device abstraction, event propagation)
