# Archetype: infra-tool

> Infrastructure-as-Code tools and reconciliation engines — Terraform, Pulumi, Crossplane, Kubernetes operators.
> Module type: archetype

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/infra-tool.md`](../../../shared/domains/archetypes/infra-tool.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Declarative Over Imperative** | Users declare desired state; the tool computes and applies the diff. The "how" is the tool's responsibility. | SCs must specify desired state → actual state transition, not step-by-step mutation scripts. |
| **Provider Extensibility** | New resource types are added via providers/plugins without modifying the core engine. Provider interface is stable and versioned. | Features adding new resource types must implement the provider interface, not modify the core. SCs verify interface compliance. |
| **State as Source of Truth** | The state file/store is the authoritative record of managed resources. Drift detection compares actual vs recorded state. | SCs must specify state storage, drift detection, and import behavior. Verify must test state consistency after apply. |
| **Idempotent Operations** | Applying the same configuration twice produces no changes. Every operation is safe to retry. | SCs must specify idempotency guarantee. Verify runs apply twice and confirms no-op on second run. |
| **Plan Before Apply** | Changes are previewed before execution. No mutation without explicit user confirmation. | Features must support plan/preview mode. SCs specify what the plan output shows for each change type. |
| **Reconciliation Loop** | For operator-style tools: continuously compare desired vs actual state and converge. Handle partial failures gracefully. | SCs for reconciliation features must specify convergence criteria, partial failure handling, and requeue policy. |

---

## A2. SC Generation Extensions

### Required SC Patterns (append to S1)
- **State transition**: SC specifies desired state declaration → diff computation → plan output → apply execution → state update
- **Idempotency proof**: SC specifies that re-applying same config produces no changes (test: apply twice, diff is empty)
- **Drift detection**: SC specifies how actual state is fetched, compared with recorded state, and reported/remediated
- **Provider contract**: SC for new resource types specifies CRUD operations, schema, and validation against provider interface

### SC Anti-Patterns (reject)
- "Infrastructure is provisioned" — must specify desired state format, plan output, apply behavior, and state persistence
- "Provider works" — must specify which CRUD operations, schema validation, error handling, and state recording
- "Drift is handled" — must specify detection mechanism, reporting format, and auto-remediation vs manual resolution

---

## A3. Elaboration Probes (append to S5)

| Sub-domain | Probe Questions |
|------------|----------------|
| **Tool/framework** | Terraform? Pulumi? Crossplane? CDK? Custom? Which version? |
| **State management** | Local file? Remote backend (S3, GCS)? State locking? Encryption at rest? |
| **Provider model** | How are providers loaded? Versioned? What is the CRUD interface? |
| **Plan/apply** | Plan-only mode? Apply with auto-approve? Targeted apply (subset of resources)? |
| **Drift** | Periodic drift detection? On-demand? Auto-remediation or report-only? |
| **Rollback** | Rollback on partial failure? Manual intervention required? State rollback vs re-apply? |

---

## A4. Constitution Injection

| Principle | Rationale |
|-----------|-----------|
| All resource mutations must go through plan → apply — no direct state modification | Skipping plan risks unreviewed destructive changes; plan-before-apply is the core safety guarantee |
| State file is the single source of truth for managed resources — never bypass state with direct API calls | Direct API calls cause state drift; state file must reflect all managed resources at all times |
| Every apply operation must be idempotent — applying the same config twice produces no changes | Non-idempotent operations cause unexpected mutations on retry, CI re-runs, or concurrent applies |
| New resource types must implement the provider interface — never hardcode resource logic in the core engine | Core engine changes for each resource type don't scale; provider interface enables community extensibility |
| Partial apply failure must leave state consistent — either commit successful changes or roll back entirely | Inconsistent state after partial failure requires manual recovery; consistent state enables safe retry |

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Tool/framework | Target IaC tool or custom engine identified |
| State model | Where state is stored, locking strategy, and encryption stated |
| Provider model | How resource types are defined and extended |
| Plan/apply flow | User confirmation workflow before destructive changes |
