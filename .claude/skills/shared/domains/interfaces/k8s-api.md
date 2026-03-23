# Interface: k8s-api

> Kubernetes API extensions: Custom Resource Definitions (CRDs), operators, controllers, and webhooks.
> Distinct from HTTP-API: uses Kubernetes API conventions, reconciliation loops, and RBAC.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: Kubernetes API, CRD, Custom Resource, kubectl, controller-runtime, kubebuilder, operator-sdk, reconcile, operator

**Secondary**: reconciler, finalizer, status subresource, admission webhook, validating webhook, mutating webhook, RBAC, informer, lister, watch, ownerReference, controllerutil

### Code Patterns (R1 — for source analysis)

- CRD definitions: `*_types.go` with `+kubebuilder:` markers, `apiextensions.k8s.io/v1`, `CustomResourceDefinition`
- Go controller-runtime: `sigs.k8s.io/controller-runtime`, `ctrl.NewManager`, `ctrl.NewControllerManagedBy`, `Reconcile(ctx, req)`
- Go client-go: `k8s.io/client-go`, `informers.NewSharedInformerFactory`, `cache.ResourceEventHandlerFuncs`
- Rust (kube-rs): `kube::Client`, `kube::runtime::controller`, `#[derive(CustomResource)]`, `kube::Api`
- Python (kopf): `import kopf`, `@kopf.on.create`, `@kopf.on.update`, `@kopf.on.delete`
- Java (fabric8): `io.fabric8.kubernetes.client`, `@Controller`, `Reconciler<T>`
- RBAC: `ClusterRole`, `ClusterRoleBinding`, `Role`, `RoleBinding` in YAML manifests
- Webhooks: `admissionregistration.k8s.io/v1`, `ValidatingWebhookConfiguration`, `MutatingWebhookConfiguration`
- Project config: `PROJECT` file (kubebuilder), `Makefile` with `controller-gen`, `config/` directory with kustomize

---

## Module Metadata

- **Axis**: Interface
- **Common pairings**: graceful-lifecycle, observability, resilience
- **Archetypes**: microservice, platform-tool
- **Profiles**: k8s-operator, k8s-controller
