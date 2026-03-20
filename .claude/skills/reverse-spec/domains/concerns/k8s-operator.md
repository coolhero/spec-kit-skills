# Concern: k8s-operator (reverse-spec)

> Extends shared S0/R1 signals with reverse-spec-specific analysis rules.

## R1: Detection Signals
See `shared/domains/concerns/k8s-operator.md` for S0 keywords and code patterns.

## R3: Feature Boundary Impact
When Kubernetes operator pattern is detected:
- Each **CRD type** + its Reconcile loop = one Feature
- **Shared infrastructure** (controller manager, webhooks, RBAC) = Foundation-level
- **Finalizers** and cleanup logic = part of the CRD's Feature, not separate
- **Multi-CRD operators** = one Feature per CRD, grouped under the operator

## R4: Data Flow Extraction
- Trace: CRD Create/Update → Watch Event → Reconcile() → K8s API Calls → Status Update
- Record CRD spec/status fields in pre-context.md § Data Model
- Note reconciliation frequency, error handling, and requeue strategies
