# Concern: infra-as-code

> Infrastructure definitions (Terraform, Helm, K8s, Docker Compose) as first-class project components.

---

## S0. Signal Keywords

> See [`shared/domains/concerns/infra-as-code.md`](../../../shared/domains/concerns/infra-as-code.md) § Signal Keywords
>
> _(Define Signal Keywords in the shared module, not here.)_

---

## S1. SC Generation Rules

### Required SC Patterns

| Pattern | SC Requirement |
|---------|----------------|
| IaC validity | SC must verify infrastructure definitions pass validation (`terraform validate`, `helm lint`, `kubectl --dry-run`) |
| App-infra sync | SC must verify that application config changes (ports, env vars, service names) are reflected in IaC definitions |
| Secret management | SC must verify no secrets are hardcoded in IaC files; references use vault/secret-manager/sealed-secrets |
| Deployment reproducibility | SC must verify clean deployment from IaC definitions produces a working environment |

### SC Anti-Patterns (reject if seen)

- "Infrastructure is configured" — must specify which resources and what validates correctness
- "Deployment works" — must specify environment, validation method, and expected state
- "Helm chart deploys" — must specify which values, which namespace, and what health check confirms success

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|-----------------|
| IaC tool | Terraform? Helm? Kustomize? Pulumi? CDK? Docker Compose? Multiple? |
| Environment topology | How many environments? (dev/staging/prod) How do they differ? |
| State management | Where is IaC state stored? (S3, Terraform Cloud, local) Who has access? |
| Secret injection | How are secrets provided? (env vars, vault, sealed-secrets, external-secrets) |
| CI/CD integration | Does IaC apply automatically in CI? GitOps (ArgoCD/Flux)? Manual approval? |
| App-infra coupling | Do app Features require infra changes? (new service, new env var, new DB) |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| IAC-001 | Hardcoded secret | Secrets in plain text in `.tf`, `values.yaml`, `compose.yaml` | Pre-commit scan for common secret patterns; use secret references only |
| IAC-002 | App-infra drift | App expects `PORT=8080` but Helm chart exposes `3000` | Single source of truth for ports/env vars; validate IaC values against app config |
| IAC-003 | Missing resource cleanup | Terraform creates resources but no destroy/cleanup documented | Every resource must have documented lifecycle (create/update/destroy) |
| IAC-004 | Environment-specific leak | Production secrets in dev config, or dev shortcuts in production manifests | Environment-specific value files; CI validates no cross-environment contamination |
| IAC-005 | Operator CRD version mismatch | K8s operator expects CRD v1beta1 but cluster has v1 | Pin CRD versions; validate compatibility in CI |
