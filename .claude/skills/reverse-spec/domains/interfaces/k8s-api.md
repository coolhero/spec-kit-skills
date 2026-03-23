# Interface: k8s-api (reverse-spec)

> Kubernetes operator/controller detection. Identifies CRDs, reconciliation loops, webhooks, and RBAC.

## R1. Detection Signals

> See [`shared/domains/interfaces/k8s-api.md`](../../../shared/domains/interfaces/k8s-api.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- CRD spec and status schema (fields, validation, printer columns)
- Reconciliation loop structure (trigger sources, requeue strategy, error handling)
- RBAC requirements (ClusterRole vs Role, verb permissions per resource)
- Webhook definitions (validating vs mutating, failure policy, side effects)
- OwnerReference chains and garbage collection strategy
- Finalizer registration and cleanup logic
- Status condition reporting pattern (Ready, Degraded, Progressing)
- Multi-version CRD strategy (conversion webhooks, storage version)
- Leader election configuration for HA deployments
- Metrics exposed via controller-runtime (reconcile duration, queue depth, errors)
