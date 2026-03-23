# Interface: k8s-api

> Kubernetes operators, controllers, CRDs, and webhooks. Uses reconciliation loops and Kubernetes API conventions.
> Module type: interface

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/k8s-api.md`](../../../shared/domains/interfaces/k8s-api.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- CRD lifecycle: specify create → reconcile → status update → delete (with finalizer cleanup). Status conditions must follow Kubernetes conventions (type, status, reason, message)
- Reconciliation idempotency: calling Reconcile twice with the same input produces the same cluster state. Verify no duplicate resource creation
- Status reporting: every reconcile updates `.status.conditions` and `.status.observedGeneration`. Verify generation check prevents stale status writes
- Finalizer: specify finalizer add on create → external cleanup on delete → finalizer remove. Verify stuck-finalizer recovery
- Webhook validation: specify valid and invalid CR payloads → verify admission accept/reject with proper status messages
- RBAC: specify minimum required permissions per resource/verb. Verify controller fails gracefully with insufficient permissions
- Owner references: child resources have ownerReference → verify garbage collection on parent delete

### SC Anti-Patterns (reject if seen)
- "Returns 200/404" — Kubernetes API uses structured Status objects, not raw HTTP codes in SCs
- "Calls REST endpoint to create" — use Kubernetes client verbs (Create, Get, Update, Delete, Patch, List, Watch)
- "Polls for changes" — controllers use informer watches, not polling loops
- "Stores state in database" — operator state belongs in CR status or annotations, not external DB

### SC Measurability Criteria
- Reconcile latency (p50, p95, p99)
- Queue depth and requeue rate
- Time from CR create to Ready=True condition

---

## S1. Demo Pattern (override)

- **Type**: kubectl script applying and verifying CRs
- **Default mode**: `kubectl apply -f sample-cr.yaml` → wait for Ready → `kubectl get` → verify status → `kubectl delete` → verify cleanup
- **CI mode**: envtest or kind cluster → apply CR → assert status conditions → delete → assert finalizer cleanup
- **"Try it" instructions**: `kubectl apply -f config/samples/` → `kubectl get <resource> -o yaml` → check `.status.conditions`

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **CRD design** | What fields in spec? What status conditions? Printer columns? Short names? |
| **Reconciliation** | What triggers reconcile? Requeue after how long? Max concurrent reconciles? |
| **Conflict handling** | How does the reconciler handle conflicting updates? Retry with backoff? Resource version check? |
| **Status strategy** | What's the status condition reporting strategy? Ready/Degraded/Progressing? observedGeneration? |
| **Multi-tenancy** | Namespace-scoped or cluster-scoped CRD? RBAC per namespace? |

---

## S6. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| CRD schema | Spec and status fields identified |
| Reconcile triggers | Watch sources (own CR + owned resources) specified |
| Status conditions | At least Ready condition defined with transitions |

---

## S7. Bug Prevention Rules

| Pattern | Risk | Prevention |
|---------|------|------------|
| Status update without generation check | Stale status overwrites newer state | Always compare `metadata.generation` with `status.observedGeneration` before status update |
| Reconcile without requeue on transient failure | Missed events, stuck resources | Return `ctrl.Result{RequeueAfter: ...}` on transient errors, not just error |
| Finalizer add without idempotency check | Infinite reconcile loop | Check `controllerutil.ContainsFinalizer()` before adding |
| Missing RBAC for status subresource | Controller silently fails to update status | Ensure `+kubebuilder:rbac` includes `status` subresource verb `update` |
| No leader election in multi-replica deploy | Duplicate reconciles, conflicts | Enable leader election via manager options for production |

---

## S8. Runtime Verification Strategy

| Field | Value |
|-------|-------|
| **Start method** | Start controller-manager process (`go run ./cmd/manager` or binary) with kubeconfig pointing to envtest/kind cluster |
| **Verify method** | `kubectl apply -f config/samples/` → `kubectl wait --for=condition=Ready` → `kubectl get <resource> -o jsonpath='{.status.conditions}'`. Backend: kubectl + envtest or kind cluster |
| **Stop method** | Send SIGTERM → verify leader election lease released → verify no orphaned resources |
| **SC classification extensions** | `k8s-auto` — CR lifecycle SCs verifiable via kubectl apply/get/delete; `k8s-webhook` — admission SCs verifiable via invalid CR apply → expect rejection |

**k8s-specific verification**:
- Lifecycle: apply CR → assert status becomes Ready → delete CR → assert finalizer cleanup completes
- Idempotency: apply same CR twice → assert no duplicate child resources
- Webhook: apply invalid CR → assert admission rejection with descriptive message
- RBAC: run controller with reduced permissions → assert graceful error (not crash)
- HA: run 2 replicas → assert only leader reconciles (no duplicate work)
