# Archetype: workflow-engine (reverse-spec)

> Workflow/durable execution engine detection. Identifies Temporal, Cadence, Step Functions patterns.

## R1. Detection Signals

> See [`shared/domains/archetypes/workflow-engine.md`](../../../shared/domains/archetypes/workflow-engine.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **Code-based**: Workflow as code with deterministic replay (Temporal, Cadence)
- **DSL-based**: Workflow as state machine definition (Step Functions, Argo Workflows)
- **Event-sourced**: Workflow state derived from event history (custom implementations)

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Workflow definitions and activity implementations
- Retry policies and timeout configurations per activity
- Saga/compensation patterns
- Versioning strategy for running workflows
- Signal and query handling
- Worker topology and task queue routing
