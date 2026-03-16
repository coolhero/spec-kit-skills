# Concern: infra-as-code

> Infrastructure definitions (Terraform, Helm, K8s, Docker Compose) as first-class project components.

---

## R1. Detection Signals

> See [`shared/domains/concerns/infra-as-code.md`](../../../shared/domains/concerns/infra-as-code.md) § Code Patterns

### Additional Detection Heuristics

- **IaC directory patterns**: `terraform/`, `infra/`, `deploy/`, `helm/`, `charts/`, `k8s/`, `manifests/`, `cloudformation/`
- **First-class indicator**: IaC files are >5% of total project files, or IaC directory has its own README/tests → IaC is a project component, not just deployment glue.
