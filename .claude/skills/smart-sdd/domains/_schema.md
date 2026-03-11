# Domain Module Schema (smart-sdd)

> Defines the section schema for domain modules in the modular 3-axis architecture.
> Every module (interface, concern, scenario) follows this schema. Omit sections that don't apply.
> For reverse-spec module sections (R1-R6), see `../reverse-spec/domains/_schema.md`.

---

## Module Types

| Type | Location | Purpose |
|------|----------|---------|
| **Interface** | `interfaces/{name}.md` | What the app exposes (http-api, gui, cli, data-io) |
| **Concern** | `concerns/{name}.md` | Internal cross-cutting patterns (async-state, ipc, external-sdk, i18n, realtime, auth) |
| **Scenario** | `scenarios/{name}.md` | Why we're building (greenfield, rebuild, incremental, adoption) |
| **Profile** | `profiles/{name}.md` | Preset composition of interfaces + concerns (~10 line manifest) |
| **Core** | `_core.md` | Universal rules loaded for ALL projects |

---

## Section Schema (S0–S7)

Every module uses the same section numbering. Omit sections that don't apply to the module type.

### S0. Signal Keywords (interfaces, concerns — optional)

Keywords that indicate this module should be activated. Used by Clarity Index signal extraction during `init` Proposal Mode. See `reference/clarity-index.md` § 5.

| Field | Description |
|-------|-------------|
| **Primary** | High-confidence keywords — strong indicator that this module is needed |
| **Secondary** | Medium-confidence keywords — needs user confirmation |

### S1. SC Generation Rules (interfaces, concerns)

Success Criteria patterns, anti-patterns, and measurability criteria for this module.

| Field | Description |
|-------|-------------|
| **Required SC patterns** | What every SC must include (e.g., status code + response shape for API) |
| **Anti-patterns** | Vague SC formulations to reject (e.g., "API responds correctly") |
| **Measurability criteria** | How to verify the SC is testable and automatable |

### S2. Parity Dimensions (interfaces — additions to _core)

Additional structural/logic parity dimensions when this interface is active.

| Field | Description |
|-------|-------------|
| **Structural dimensions** | Additional structural elements to compare |
| **Logic dimensions** | Additional behavioral elements to compare |

### S3. Verify Steps (concerns — additions or overrides to _core)

Additional verification steps when this module is active.

| Field | Description |
|-------|-------------|
| **Step name** | Identifier (e.g., `i18n-coverage`) |
| **Required** | Whether failure blocks the pipeline (`BLOCKING` or `optional`) |
| **Detection** | How to find/run the relevant tool |
| **Description** | What this step checks |

### S4. Adoption-Specific Behavior (scenarios/adoption.md only)

Behavior differences when wrapping existing code with SDD docs.

| Field | Description |
|-------|-------------|
| **Verify treatment** | How test/build/lint failures are treated (non-blocking vs blocking) |
| **Injection framing** | How spec-kit command prompts differ |
| **Feature status** | Post-adoption status value |

### S5. Elaboration Probes (interfaces, concerns — additions to _core)

Domain-specific questions asked during the `add` command's consultation phase.

| Field | Description |
|-------|-------------|
| **Perspective** | Which base perspective (1–6) this probe extends |
| **Sub-domain** | Category within the perspective |
| **Probe questions** | Domain-specific elaboration questions |

### S6. UI Testing Integration (interfaces/gui.md only)

Guidance for automated UI verification during verify Phase 3.

| Field | Description |
|-------|-------------|
| **Feature type mapping** | Which Feature types get UI verification |
| **MCP tools mapping** | Which MCP tools map to verification actions |
| **SC verification flow** | How to translate SC items into automated test steps |

### S7. Bug Prevention Rules (interfaces, concerns)

Pattern compliance rules and anti-patterns to check during implementation.

| Field | Description |
|-------|-------------|
| **Rule name** | Short identifier |
| **Stage** | Which pipeline stage enforces it (plan, analyze, implement, verify) |
| **Reference** | Cross-reference to injection file where the rule is enforced |
| **Description** | What the rule checks |

### S8. Runtime Verification Strategy (interfaces only)

Interface-specific runtime verification configuration. Cross-references [reference/runtime-verification.md](../reference/runtime-verification.md).

| Field | Description |
|-------|-------------|
| **Start method** | How to start the app/server/process for verification |
| **Verify method** | How to verify runtime behavior (backend type + approach) |
| **Stop method** | How to clean up after verification |
| **SC classification extensions** | Interface-specific SC auto-categories (e.g., `api-auto` for http-api) |

---

## Profile Schema

Profiles are pure manifests (~10 lines) that compose interfaces and concerns:

```markdown
# Profile: {name}

> {description}

interfaces: [{comma-separated list}]
concerns: [{comma-separated list}]

# Scenario is determined by sdd-state.md Origin field, not by profile.
```

---

## Loading Order

Defined in `_resolver.md`. Modules are loaded in this order:

```
1. _core.md                              (ALWAYS — universal rules)
2. interfaces/{interface}.md             (for EACH listed interface)
3. concerns/{concern}.md                 (for EACH listed concern)
4. scenarios/{scenario}.md               (ONE scenario)
5. {Custom path}/domain-custom.md        (if specified and file exists)
```

**Merge rule**: Later modules extend earlier ones. For same-section content:
- **S0 Signal Keywords**: Aggregated per-module (each module's keywords are independent; see `reference/clarity-index.md` § 5)
- **S1 SC Rules**: Append (accumulate all rules)
- **S2 Parity Dimensions**: Append (add module-specific dimensions)
- **S3 Verify Steps**: Override only if module explicitly overrides (otherwise inherit _core)
- **S5 Elaboration Probes**: Append (accumulate all probes)
- **S7 Bug Prevention**: Append (accumulate all activation conditions)
- **S8 Runtime Verification**: Per-interface (no merge — each interface has its own strategy)
