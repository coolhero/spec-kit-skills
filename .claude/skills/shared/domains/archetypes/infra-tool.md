# Archetype: infra-tool

> Infrastructure-as-Code tools and reconciliation engines — Terraform, Pulumi, Crossplane, Kubernetes operators.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: provider, resource, data source, state, plan, apply, drift, reconcile, declarative, desired state, actual state, resource graph, dependency resolution, CRD, operator, infrastructure as code

**Secondary**: Terraform, Pulumi, Crossplane, CloudFormation, CDK, provisioner, backend, state lock, import, taint, module registry, stack, reconciliation loop, finalizer

### Code Patterns (A0 — for source analysis)

- **Terraform**: `.tf` files, `resource` / `data` / `module` blocks, `terraform.tfstate`, provider schemas, `terraform plan`/`apply`
- **Pulumi**: `Pulumi.yaml`, `__main__.py` or `index.ts` with resource constructors, stack exports
- **Crossplane/K8s operators**: `Reconcile()` function, CRD type definitions, controller-runtime, `+kubebuilder` annotations
- **CDK**: `cdk.json`, `Stack` classes, `Construct` subclasses, `cdk synth`/`cdk deploy`
- **Common**: dependency graph construction, diff/plan computation, rollback on failure, state serialization

---

## A1: Core Principles

| Principle | Description |
|-----------|-------------|
| **Declarative Over Imperative** | Users declare desired state; the tool computes and applies the diff. The "how" is the tool's responsibility, not the user's. |
| **Provider Extensibility** | New resource types are added via providers/plugins without modifying the core engine. Provider interface is stable and versioned. |
| **State as Source of Truth** | The state file/store is the authoritative record of managed resources. Drift detection compares actual state against recorded state. |
| **Idempotent Operations** | Applying the same configuration twice produces no changes. Every operation is safe to retry. |
| **Plan Before Apply** | Changes are previewed (plan/diff) before execution. No mutation without explicit user confirmation. |
| **Reconciliation Loop** | For operator-style tools: continuously compare desired vs actual state and converge. Handle partial failures gracefully. |

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: cli
- **Common pairings**: infra-as-code (concern), k8s-operator
