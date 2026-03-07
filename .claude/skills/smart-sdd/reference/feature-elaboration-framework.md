# Feature Elaboration Framework

> Reference: Used by `/smart-sdd add` Phase 1 to evaluate Feature definitions for completeness.
> Read by the agent after initial information gathering (regardless of entry type) to identify gaps and guide elaboration.

## Purpose

When a user defines a Feature, the initial definition is often incomplete. This framework provides **six perspectives** for evaluating Feature definitions and identifying areas that need elaboration before proceeding to Phase 2.

All three Phase 1 entry types (Document-based, Conversational, Gap-driven) converge on this framework after initial information gathering. The agent uses it to:
1. Assess what information is already available
2. Identify which perspectives have insufficient coverage
3. Ask targeted questions to fill gaps

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

### 1. User & Purpose (누가, 왜) — REQUIRED

Who uses this Feature and why?

- **Target actors**: Who interacts with this Feature? (end users, admins, external systems, cron jobs)
- **Core problem**: What problem does this solve? What happens without it?
- **Key scenarios**: 2–3 primary usage scenarios (actor does X → system does Y → actor sees Z)

**Gap signals**: No actor identified, no clear problem statement, no usage scenarios described.

**Example questions**:
- "이 기능을 주로 사용하는 사람은 누구인가요? (일반 사용자, 관리자, 외부 시스템?)"
- "이 기능이 없으면 사용자가 겪는 불편은 무엇인가요?"
- "대표적인 사용 시나리오 1–2개를 설명해주실 수 있나요?"

### 2. Capabilities (무엇을) — REQUIRED

What does this Feature do?

- **Core capabilities**: List of things the user can DO (verbs: create, search, configure, export, etc.)
- **Business rules**: Constraints on behavior (e.g., "max 3 attempts", "only admins can delete", "must be unique")
- **State transitions**: Key state changes (e.g., order: draft → submitted → approved → shipped)

**Gap signals**: Only vague description ("handles notifications"), no specific capabilities listed, no business rules.

**Example questions**:
- "사용자가 이 기능으로 할 수 있는 구체적인 행동을 나열해주실 수 있나요?"
- "특별한 비즈니스 규칙이나 제약 조건이 있나요? (예: 횟수 제한, 권한 제한)"
- "주요 상태 변화가 있나요? (예: 초안→제출→승인→완료)"

### 3. Data (어떤 데이터로) — REQUIRED

What data does this Feature manage?

- **Owned entities**: Data this Feature is the primary owner of (CRUD authority)
- **Referenced entities**: Data from other Features this Feature reads but doesn't own
- **Key attributes**: Important fields/properties (not exhaustive — just the key ones)
- **Relationships**: How entities relate (1:N, M:N, hierarchical, etc.)

**Gap signals**: No entities mentioned, unclear ownership, entity overlaps with existing Features.

**Example questions**:
- "이 기능이 직접 관리(생성/수정/삭제)하는 데이터는 무엇인가요?"
- "다른 기능에서 가져와 참조하는 데이터가 있나요?"
- "주요 데이터 간의 관계는 어떻게 되나요? (1:N, M:N 등)"

### 4. Interfaces (어떻게 연결) — REQUIRED

How does this Feature connect to users and other Features?

- **APIs provided**: Endpoints this Feature exposes for others to use
- **APIs consumed**: Endpoints from other Features this Feature calls
- **UI touchpoints** (if applicable): Pages, modals, components
- **Events**: Events emitted/consumed (if event-driven architecture)
- **External integrations**: Third-party services, APIs, or systems

**Gap signals**: No APIs mentioned, no UI hints for user-facing Features, unclear dependencies.

**Example questions**:
- "이 기능이 제공해야 할 API 엔드포인트가 있나요?"
- "다른 기능의 API를 호출해야 하나요? 어떤 것들?"
- "사용자 인터페이스가 필요한가요? (페이지, 모달, 컴포넌트)"
- "외부 서비스와 연동이 필요한가요? (이메일, 결제, 알림 등)"

### 5. Quality (얼마나 잘) — OPTIONAL but recommended

Non-functional requirements.

- **Performance**: Expected load, response time constraints
- **Security**: Authentication/authorization requirements, data sensitivity
- **Error handling**: What happens when things fail?
- **Scalability**: Growth expectations

**Gap signals**: Not critical for Phase 1. Note "TBD" if not discussed. Flag security-sensitive Features.

**Example questions**:
- "성능 요구사항이 있나요? (동시 접속자, 응답시간 등)"
- "보안 관련 특별한 고려사항이 있나요? (인증, 민감 데이터)"

### 6. Boundaries (어디까지) — OPTIONAL but recommended

Scope boundaries.

- **Explicit exclusions**: What this Feature does NOT do (to prevent scope creep)
- **Assumptions**: What we're assuming is true
- **Constraints**: Technical or business constraints
- **Future considerations**: Things explicitly deferred to later

**Gap signals**: Feature description is very broad with no boundaries set. Risk of scope creep.

**Example questions**:
- "이 기능에서 명시적으로 제외할 것이 있나요?"
- "전제 조건이나 가정하고 있는 것이 있나요?"

---

## Domain-Specific Extension

The six perspectives above are **domain-independent**. Each domain profile (`domains/{domain}.md`) may define additional elaboration probes in its **§ 5. Feature Elaboration Probes** section.

Domain probes are NOT separate perspectives — they are **additional questions** within the existing six perspectives (typically Perspectives 2, 4, and 5). The agent should:

1. Read `domains/{domain}.md` § 5 after loading this framework
2. Merge domain probes into the relevant base perspectives
3. Apply domain probes during the elaboration step alongside the base questions

If the domain profile has no § 5, use only the base six perspectives.

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

A Feature definition is ready for Phase 2 when:

| Perspective | Minimum Coverage |
|-------------|-----------------|
| 1. User & Purpose | At least one actor + one scenario |
| 2. Capabilities | At least 2–3 concrete capabilities listed |
| 3. Data | Owned entities identified (even if attributes TBD) |
| 4. Interfaces | API direction clear (provides/consumes), UI need stated |
| 5. Quality | Acknowledged or "TBD" |
| 6. Boundaries | Acknowledged or "TBD" |
