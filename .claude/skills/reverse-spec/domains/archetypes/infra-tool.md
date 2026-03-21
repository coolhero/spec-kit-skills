# Archetype: Infra Tool (reverse-spec)

> Infrastructure/IaC tool detection

## R1. Detection Signals

> See [`shared/domains/archetypes/infra-tool.md`](../../../shared/domains/archetypes/infra-tool.md) § Code Patterns

## R2. Classification Guide

When detected, classify the sub-type:
- **Provisioning** — Declarative infrastructure definition, resource lifecycle management (Terraform, Pulumi)
- **Configuration** — Configuration management, desired-state convergence, idempotent operations (Ansible)
- **Container orchestration** — Container scheduling, service discovery, scaling policies (K8s tools)
- **CI/CD** — Pipeline definition, build automation, deployment orchestration (GitHub Actions, Jenkins)

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Resource definition format (HCL, YAML, DSL, imperative SDK)
- State management (state file format, remote state backends, locking, state migration)
- Plan/apply lifecycle (diff calculation, execution ordering, dependency graph, rollback strategy)
- Provider/plugin system (plugin protocol, resource schema discovery, CRUD lifecycle hooks)
- Drift detection (refresh mechanism, out-of-band change detection, reconciliation strategy)
