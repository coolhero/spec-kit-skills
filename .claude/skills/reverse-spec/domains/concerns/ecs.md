# Concern: ecs (reverse-spec)

> Extends shared S0/R1 signals with reverse-spec-specific analysis rules.

## R1: Detection Signals
See `shared/domains/concerns/ecs.md` for S0 keywords and code patterns.

## R3: Feature Boundary Impact
When ECS is detected:
- **Components** are data — not Features themselves but part of Feature definitions
- **Systems** are behavior — each system or system group = potential Feature boundary
- **Plugins/Bundles** (e.g., Bevy plugins) = natural Feature grouping
- ECS framework setup (World, Schedule, resources) = Foundation-level

## R4: Data Flow Extraction
- Trace: Input System → Component Mutation → Query in System → Rendering/Output
- Record component relationships and system ordering in pre-context.md § Data Lifecycle Patterns
- Note which systems have ordering dependencies (before/after constraints)
