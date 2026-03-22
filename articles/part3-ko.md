# 생각하는 400개의 마크다운 파일: spec-kit-skills의 아키텍처

## 4부작 중 3편 — 설계 철학, 파일 구조, 확장성

*[2편: 세 가지 스킬, 하나의 파이프라인](part2-ko.md)에서 이어집니다*

---

## AI 스킬 설계의 역설

AI 에이전트를 위한 도구를 만들 때의 이상한 진실: **에이전트가 사용자이자 런타임입니다.**

React 컴포넌트를 작성하면 React가 실행합니다. Claude Code 스킬을 작성하면 Claude가 마크다운으로 *읽고* 어떻게 행동할지 결정합니다. "코드"는 자연어입니다. "컴파일러"는 LLM입니다. "버그"는 행동적입니다 — 에이전트가 구문 오류 때문이 아니라 의도를 오해해서 잘못된 일을 합니다.

이것이 설계 방식을 근본적으로 바꿉니다.

## 세 가지 기초 철학

spec-kit-skills의 모든 설계 결정은 세 가지 원칙으로 돌아갑니다. 수백 번의 실패한 파이프라인 실행을 통해 힘들게 배웠습니다.

### P1: Context Continuity (컨텍스트 연속성)

> 정보는 모든 파이프라인 단계를 통해 연속적으로 흘러야 한다. 전환에서 아무것도 손실되면 안 된다.

당연해 보입니다. 하지만 그렇지 않습니다.

실제로, Feature 3을 시작하는 AI 에이전트는 Feature 1에 대해 아무것도 모릅니다 — Feature 1의 아티팩트를 명시적으로 컨텍스트에 로드하지 않으면요. 에이전트에게 "프로젝트 메모리"는 없습니다. 압축되고 결국 잊혀지는 컨텍스트 윈도우가 있을 뿐입니다.

세 가지 구현으로 나타납니다:

**P1-a: Domain Profile은 First-Class Citizen.** 일회성 설정이 아닙니다. 모든 단계에서 적극적으로 동작합니다 — `add` 중 어떤 프로브를 물어볼지, `specify` 중 어떤 규칙이 활성화될지, `verify` 중 어떤 검증 단계를 실행할지.

**P1-b: Artifact Separation.** 스펙은 *무엇을 만들 것인가*를 기술하지, *어디서 왔는가*를 기술하지 않습니다. 소스 분석은 reverse-spec 아티팩트에 남습니다.

**P1-c: Cross-Feature Memory (GEL).** 엔티티 레지스트리, API 레지스트리, 프리컨텍스트, 스텁 — 이것들이 Global Evolution Layer입니다. 정보는 에이전트 메모리가 아니라 파일을 통해 앞으로 흐릅니다.

### P2: Enforce, Don't Reference (참조가 아닌 강제)

> "자세한 내용은 X 참조"는 강제력이 없다. 규칙은 실행 지점에서 직접 강제되어야 한다.

가장 반직관적인 원칙입니다. 일반 소프트웨어에서는 함수를 한 번 작성하고 모든 곳에서 호출합니다. 에이전트 스킬에서는 **참조된 규칙은 무시됩니다.**

왜? 에이전트가 참조를 선택적 읽기로 취급하기 때문입니다. "전체 검증 프로토콜은 verify-phases.md 참조" → 에이전트의 해석: "어딘가에 더 많은 정보가 있지만, 빌드 + 테스트만 하고 완료라고 하자."

모든 핵심 규칙에는 세 가지가 필요합니다:
1. **인라인 지시** — 규칙이 실행 지점에 직접 나타남
2. **차단 게이트** — 경고가 아닌 차단. 준수 없이 진행 불가
3. **안티패턴 예시** — 명시적 "WRONG"과 "RIGHT" 패턴

이것이 HARD STOP 재질문 텍스트가 30곳 이상에 반복되는 이유입니다. 각각이 다른 실행 지점에 있고, 공유 파일을 참조하는 것은 동작하지 않습니다.

### P3: File over Memory (메모리가 아닌 파일)

> 모든 중간 산출물과 상태는 파일에 저장한다. 에이전트 메모리에 의존하지 않는다.

에이전트의 컨텍스트 윈도우는 제한적이고, 세션 범위이며, 검사 불가능합니다. 파일은 지속적이고, diff 가능하며, 편집 가능하고, 공유 가능합니다.

## 파일 아키텍처

### 스킬 구조

```
SKILL.md              ← 시스템 프롬프트 (슬림 라우팅, 필수 규칙)
commands/
  orient.md           ← 온디맨드 워크플로우 (호출 시에만 로드)
reference/
  injection/          ← 커맨드별 컨텍스트 주입 규칙
domains/
  _core.md            ← 보편 규칙 (항상 로드)
  _resolver.md        ← 모듈 로딩 로직
  interfaces/         ← 9개 인터페이스 모듈
  concerns/           ← 48개 관심사 모듈
  archetypes/         ← 15개 아키타입 모듈
  profiles/           ← 15개 사전 빌드 프로필
```

### 왜 이런 구조인가?

**컨텍스트 효율성.** SKILL.md는 항상 로드 (~200줄). 커맨드 파일은 온디맨드 로드. 도메인 모듈은 선택적 로드 — Domain Profile에 맞는 모듈만.

```
항상 로드:         SKILL.md (~200줄)
커맨드별:         commands/pipeline.md (~500줄)
도메인별:         3-5개 모듈 × ~100줄 = ~400줄
Feature별:       pre-context.md + spec.md (~200줄)
                  ─────────────────────
합계:             ~1,300줄

vs. 전부 로드:    ~15,000+줄 → 컨텍스트 오버플로우
```

### 도메인 모듈 로딩 순서

```
1. _core.md                     ← 보편 규칙 (항상)
2. interfaces/{name}.md         ← 인터페이스별
3. concerns/{name}.md           ← 관심사별
4. archetypes/{name}.md         ← 아키타입별
5. foundations/{framework}.md   ← 파운데이션별
6. org-convention.md            ← 조직 공통 (옵션)
7. scenarios/{name}.md          ← 시나리오별
8. domain-custom.md             ← 프로젝트 레벨 오버라이드 (옵션)
```

후순위 모듈이 선순위를 확장합니다 — `gui`와 `realtime`이 모두 활성화되면, 양쪽의 S1 (SC 생성 규칙) 섹션이 병합됩니다.

### Context Injection

핵심 아키텍처 혁신입니다. 각 파이프라인 단계마다 **injection 파일**이 어떤 컨텍스트를 조립할지 정의합니다:

```
reference/injection/
  specify.md    ← speckit-specify가 받는 컨텍스트
  plan.md       ← speckit-plan이 받는 컨텍스트
  implement.md  ← speckit-implement가 받는 컨텍스트
```

자연어 규칙을 위한 의존성 주입 컨테이너라고 생각하면 됩니다.

## 확장성

### 새 Concern 모듈 추가

1. `domains/concerns/your-concern.md` 생성
2. 섹션 스키마 (S0-S9) 준수
3. 끝 — resolver가 Domain Profile에 포함되면 자동 발견

코드 변경 없음. 등록 없음. 규약 기반 모듈 시스템입니다.

### 커스텀 프로필 생성

```markdown
# Profile: my-custom-stack

interfaces: gui, http-api
concerns: auth, realtime, ai-assistants
archetype: ai-assistant
foundation: nextjs
scenario: greenfield
scale:
  project_maturity: mvp
  team_context: solo
```

---

## 🤖 에이전트를 위한 글 — 아키텍처 참조

```yaml
architecture:
  design_principles:
    P1_context_continuity:
      sub_principles: [domain_profile_first_class, artifact_separation, cross_feature_memory]
      enforcement: GEL artifacts (entity-registry, api-registry, sdd-state.md)
    P2_enforce_dont_reference:
      requirement: 모든 핵심 규칙에 inline_instruction + blocking_gate + anti_pattern 필요
      reason: 에이전트는 참조를 선택적 읽기로 취급
    P3_file_over_memory:
      requirement: 모든 중간 상태를 파일에 저장, 에이전트 컨텍스트만에 의존하지 않음

  module_loading:
    order: [_core, interfaces, concerns, archetypes, foundations, org_convention, scenarios, domain_custom]
    merge_rule: 후순위 모듈이 선순위를 확장 (S1, S5, A2에 대해 append 의미론)
    selection: 활성 Domain Profile에 맞는 모듈만 로드

  context_budget:
    always_loaded: ~200줄 (SKILL.md)
    per_command: ~500줄 (커맨드 파일)
    per_domain: ~400줄 (3-5 모듈)
    total_typical: ~1,300줄 (전체 로드 시 ~15,000줄 대비)

  extensibility:
    add_concern: domains/concerns/{name}.md 생성 (S0-S9 섹션) → 자동 발견
    add_foundation: domains/foundations/{name}.md 생성 (F2-F3 섹션) → 자동 로드
    add_profile: domains/profiles/{name}.md 생성 → --profile로 사용 가능
```

---

*다음 편: **4편 — AI 에이전트를 위한 스킬 만들기: 실패 패턴과 팁** — 실패 패턴, 팁, 그리고 스킬 개발자를 위한 실전 가이드.*
