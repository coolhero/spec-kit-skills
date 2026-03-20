# Concern: k8s-operator

> Kubernetes operator pattern — custom controllers, CRDs, and reconciliation loops.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: controller-runtime, Reconcile, kubebuilder, operator-sdk, CRD, CustomResourceDefinition, informer, watch, reconciliation loop, Kubernetes operator

**Secondary**: finalizer, owner reference, status subresource, RBAC, webhook, admission controller, leader election, controller manager, predicate, event filter

### Code Patterns (R1 — for source analysis)

- **Reconcile**: `Reconcile()` function signature, `ctrl.Result` return, `ctrl.Request` input, error-based requeue
- **CRD types**: `api/v1/*.go` type definitions, `+kubebuilder:object:root`, `+kubebuilder:subresource:status`, `Spec`/`Status` struct pattern
- **Annotations**: `+kubebuilder:rbac:groups=...`, `+kubebuilder:validation:...`, `+kubebuilder:default:...`, `+kubebuilder:printcolumn`
- **Libraries**: `controller-runtime` (`sigs.k8s.io/controller-runtime`), `client-go`, `operator-sdk`, `kopf` (Python), `kube-rs` (Rust)
- **Structure**: `api/` (CRD types), `controllers/` or `internal/controller/`, `config/` (RBAC, CRD YAML, webhooks), `Dockerfile` with manager binary

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: infra-tool (archetype), infra-as-code
- **Profiles**: —
