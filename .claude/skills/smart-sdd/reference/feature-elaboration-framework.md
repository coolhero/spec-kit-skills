# Feature Elaboration Framework

> Reference: Used by `/smart-sdd add` Phase 1 (Briefing) to evaluate Feature definitions for completeness.
> Read by the agent after initial information gathering (regardless of entry type) to identify gaps and guide elaboration.
> This framework is the **quality gate** for the **Brief** concept — it ensures every Feature intake meets a minimum quality bar before entering the spec-kit pipeline.

## Purpose

When a user defines a Feature, the initial definition is often incomplete. This framework provides **six base perspectives** for evaluating Feature definitions and identifying areas that need elaboration before proceeding to Phase 2. Domain modules extend these with **S9/A5 Brief Completion Criteria** for project-type-specific requirements.

All three Phase 1 entry types (Document-based, Conversational, Gap-driven) converge on this framework after initial information gathering. The agent uses it to:
1. Assess what information is already available
2. Identify which perspectives have insufficient coverage
3. Ask targeted questions to fill gaps
4. Verify domain-specific Brief Completion Criteria (§ S9/A5) are met

---

## How to Use

1. After gathering initial Feature information (via document, conversation, or gap analysis):
   - Evaluate the current definition against each perspective below
   - Score each: **covered** / **partial** / **missing**
2. Ask targeted questions for missing perspectives (prioritize by order below)
3. A Feature definition is "Phase 1 complete" when:
   - Perspectives 1–4 have at least basic coverage
   - Perspectives 5–6 are acknowledged (even if "none" or "TBD")

---

## The Six Perspectives

### 1. User & Purpose (Who, Why) — REQUIRED

Who uses this Feature and why?

- **Target actors**: Who interacts with this Feature? (end users, admins, external systems, cron jobs)
- **Core problem**: What problem does this solve? What happens without it?
- **Key scenarios**: 2–3 primary usage scenarios (actor does X → system does Y → actor sees Z)

**Gap signals**: No actor identified, no clear problem statement, no usage scenarios described.

**Example questions**:
- "Who primarily uses this feature? (end users, admins, external systems?)"
- "What inconvenience do users face without this feature?"
- "Can you describe 1–2 representative usage scenarios?"

### 2. Capabilities (What) — REQUIRED

What does this Feature do?

- **Core capabilities**: List of things the user can DO (verbs: create, search, configure, export, etc.)
- **Business rules**: Constraints on behavior (e.g., "max 3 attempts", "only admins can delete", "must be unique")
- **State transitions**: Key state changes (e.g., order: draft → submitted → approved → shipped)

**Gap signals**: Only vague description ("handles notifications"), no specific capabilities listed, no business rules.

**Example questions**:
- "Can you list the specific actions a user can perform with this feature?"
- "Are there special business rules or constraints? (e.g., attempt limits, permission restrictions)"
- "Are there key state transitions? (e.g., draft → submitted → approved → completed)"

### 3. Data (What data) — REQUIRED

What data does this Feature manage?

- **Owned entities**: Data this Feature is the primary owner of (CRUD authority)
- **Referenced entities**: Data from other Features this Feature reads but doesn't own
- **Key attributes**: Important fields/properties (not exhaustive — just the key ones)
- **Relationships**: How entities relate (1:N, M:N, hierarchical, etc.)

**Gap signals**: No entities mentioned, unclear ownership, entity overlaps with existing Features.

**Example questions**:
- "What data does this feature directly manage (create/update/delete)?"
- "Is there data referenced from other features?"
- "What are the relationships between key data entities? (1:N, M:N, etc.)"

### 4. Interfaces (How it connects) — REQUIRED

How does this Feature connect to users and other Features?

- **APIs provided**: Endpoints this Feature exposes for others to use
- **APIs consumed**: Endpoints from other Features this Feature calls
- **UI touchpoints** (if applicable): Pages, modals, components
- **Events**: Events emitted/consumed (if event-driven architecture)
- **External integrations**: Third-party services, APIs, or systems

**Gap signals**: No APIs mentioned, no UI hints for user-facing Features, unclear dependencies. Feature defines data stores or services that users will configure/view but lists no UI touchpoints — potential horizontal layer instead of vertical slice.

**Example questions**:
- "Does this feature need to expose API endpoints?"
- "Does it need to call other features' APIs? Which ones?"
- "Is a user interface needed? (pages, modals, components)"
- "Does it need to integrate with external services? (email, payment, notifications, etc.)"

### 5. Quality (How well) — OPTIONAL but recommended

Non-functional requirements.

- **Performance**: Expected load, response time constraints
- **Security**: Authentication/authorization requirements, data sensitivity
- **Error handling**: What happens when things fail?
- **Scalability**: Growth expectations

**Gap signals**: Not critical for Phase 1. Note "TBD" if not discussed. Flag security-sensitive Features.

**Example questions**:
- "Are there performance requirements? (concurrent users, response time, etc.)"
- "Are there special security considerations? (authentication, sensitive data)"

### 6. Boundaries (Scope limits) — OPTIONAL but recommended

Scope boundaries.

- **Explicit exclusions**: What this Feature does NOT do (to prevent scope creep)
- **Assumptions**: What we're assuming is true
- **Constraints**: Technical or business constraints
- **Future considerations**: Things explicitly deferred to later

**Gap signals**: Feature description is very broad with no boundaries set. Risk of scope creep.

**Example questions**:
- "Is there anything explicitly excluded from this feature?"
- "Are there any prerequisites or assumptions?"

---

## Domain-Specific Extension

The six perspectives above are **domain-independent**. Domain modules define additional elaboration probes in their **§ S5. Elaboration Probes** sections.

Domain probes are NOT separate perspectives — they are **additional questions** within the existing six perspectives (typically Perspectives 2, 4, and 5). The agent should:

1. Read `domains/_core.md` § S5 for universal probes after loading this framework
2. Read each active interface module § S5 and each active concern module § S5 for module-specific probes
3. Merge all domain probes into the relevant base perspectives
4. Apply domain probes during the elaboration step alongside the base questions

If no active modules define § S5, use only the base six perspectives.

---

## Elaboration Strategy

The agent should NOT dump all perspectives at once. Instead:

1. **Assess current coverage**: Score each perspective after initial gathering
2. **Prioritize gaps**: Ask about Perspectives 1–4 first (REQUIRED)
3. **Batch questions**: Group 2–3 related questions together — don't overwhelm the user
4. **Use what you have**: If a document was provided, extract maximum information before asking
5. **Adapt depth to type**:
   - Type 1 (Document-based): Document likely covers 1–4 well; focus on confirming + filling 5–6
   - Type 2 (Conversational): Start with Perspective 1 (who/why), build from there
   - Type 3 (Gap-driven): SBI behaviors provide Perspectives 2–3 automatically; focus on 1 and 4
6. **Know when to stop**: Phase 1 is for DEFINITION, not specification. Don't try to nail down every FR/SC — that's specify's job. "Good enough to scope" is the bar.

### Completion Criteria

A Feature definition (Brief) is ready for Phase 2 when:

**Base criteria** (all projects):

| Perspective | Minimum Coverage |
|-------------|-----------------|
| 1. User & Purpose | At least one actor + one scenario |
| 2. Capabilities | At least 2–3 concrete capabilities listed |
| 3. Data | Owned entities identified (even if attributes TBD) |
| 4. Interfaces | API direction clear (provides/consumes), UI need stated |
| 5. Quality | Acknowledged or "TBD" |
| 6. Boundaries | Acknowledged or "TBD" |

**Domain-specific criteria** (when modules are active):

| Source | Check |
|--------|-------|
| Active interface modules § S9 | All Required Elements have Completion Signals met |
| Active concern modules § S9 | All Required Elements have Completion Signals met |
| Active archetype modules § A5 | All Required Elements have Completion Signals met |

> If no domain modules define S9/A5, only base criteria apply.
> See `domains/_schema.md` for the S9/A5 schema definition.

### Intent Verification Gate

After completion criteria are met, the agent presents a **Brief Summary** to the user for explicit approval (HARD STOP — see `commands/add.md` § 1e). This gate ensures:

1. **Completeness** is confirmed by the criteria above (structural check)
2. **Accuracy** is confirmed by the user reviewing the agent's interpretation (intent check)

The Brief Summary shows the agent's understanding of: description, actors, capabilities, data, interfaces, quality, and boundaries. The user can approve, correct misunderstandings, or request more detail.

> Without this gate, the agent may structurally satisfy all criteria while misunderstanding the user's actual intent. The Brief↔Spec Alignment Check (see `injection/specify.md`) provides a second-layer verification after spec generation.
