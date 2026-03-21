# Concern: k8s-operator

> Kubernetes operator pattern — custom controllers, CRDs, and reconciliation loops.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/k8s-operator.md`](../../../shared/domains/concerns/k8s-operator.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Reconciliation loop: observe current state → compare with desired state (CR spec) → take corrective action → update status subresource → requeue if not converged
- Finalizer lifecycle: CR created → finalizer added → CR deleted → finalizer logic executes (cleanup external resources) → finalizer removed → CR garbage collected
- Status reporting: reconcile outcome → status conditions updated (Ready, Degraded, Progressing) → status observed generation matches spec generation
- Error handling: reconcile error → exponential backoff requeue → max retries → status reflects error with human-readable message

### SC Anti-Patterns (reject)
- "Operator manages resources" — must specify which resources (CRD spec fields), what desired state, what corrective actions, and what status conditions
- "Reconciliation works" — must specify idempotency, convergence criteria, requeue policy, and error status reporting
- "CRD is created" — must specify validation rules, default values, status subresource fields, and printer columns

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Framework** | kubebuilder? operator-sdk? kopf (Python)? kube-rs (Rust)? controller-runtime directly? |
| **CRD design** | What does the spec contain? What status conditions are reported? Multi-version CRD? |
| **External resources** | Does the operator manage resources outside K8s (cloud infra, databases, DNS)? Finalizer needed? |
| **RBAC** | What cluster/namespace permissions are required? Least-privilege scoping? |
| **Webhooks** | Validating webhook? Mutating webhook (defaulting)? Conversion webhook (multi-version)? |
| **Testing** | envtest? Kind cluster? Integration tests against real cluster? Mock client? |

---

## S7. Bug Prevention — Operator-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| K8S-001 | Infinite reconcile loop | Reconcile updates spec/metadata → triggers watch event → reconcile called again → infinite loop | Only update status subresource (not spec); use `ObservedGeneration` to skip redundant reconciles |
| K8S-002 | Missing finalizer cleanup | CR deleted without finalizer → external resources orphaned (cloud infra, DNS records) | Add finalizer on creation; remove only after external cleanup confirmed |
| K8S-003 | Status update conflict | Concurrent status updates from multiple reconciles → conflict error → status stuck | Re-fetch resource before status update; retry on conflict with latest resource version |
| K8S-004 | RBAC insufficient | Operator lacks permission for managed resources → silent failure or crash | Generate RBAC from annotations; test with minimal permissions; fail-fast with clear error on 403 |
| K8S-005 | Leader election race | Multiple operator replicas reconciling same resource simultaneously → conflicting actions | Enable leader election; single active replica for controller manager |
