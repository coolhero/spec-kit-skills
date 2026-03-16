# Concern: infra-as-code

> Infrastructure definitions (Terraform, Helm, K8s, Docker Compose) as first-class project components.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: Terraform, Helm, Kubernetes, Docker Compose, Pulumi, CDK, CloudFormation, infrastructure as code, IaC, K8s manifests, Kustomize, Ansible

**Secondary**: Helm chart, Terraform module, K8s operator, CRD, deployment manifest, ingress, service mesh, Istio, ArgoCD, Flux, GitOps

### Code Patterns (R1 — for source analysis)

- Terraform: `*.tf`, `*.tfvars`, `.terraform.lock.hcl`, `terraform {}` block, `resource`, `module`, `provider`
- Helm: `Chart.yaml`, `values.yaml`, `templates/`, `{{ .Values.* }}`
- Kubernetes: `kind: Deployment`, `kind: Service`, `kind: ConfigMap`, `apiVersion:`, `kustomization.yaml`
- Docker: `docker-compose.yml`, `compose.yaml`, multi-stage `Dockerfile`
- CDK/Pulumi: `cdk.json`, `Pulumi.yaml`, infrastructure-as-code class definitions
- CI/CD: `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `buildkite/`
- Operator: `kubebuilder`, `operator-sdk`, `controller-runtime`, CRD definitions

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: —
- **Profiles**: —
