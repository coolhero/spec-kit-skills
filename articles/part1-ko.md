# AI 코딩 에이전트 길들이기: 프롬프트가 아니라 하네스가 필요한 이유

## 4부작 중 1편 — 배경, 아키텍처, 실전 시나리오

*이 글은 Claude Code로 작성되었습니다 — 이 프로젝트가 바로 그 도구를 위해 만들어졌다는 점에서, 의도된 아이러니입니다.*

---

**요약**: AI 코딩 에이전트는 놀랍도록 유능하지만, "유능한 것"과 "통제 가능한 것"은 다릅니다. 이 시리즈는 **spec-kit-skills**를 소개합니다 — AI 에이전트가 코드를 탐색하고, 설계하고, 구현하는 과정을 개발자가 구조적으로 통제할 수 있게 해주는 오픈소스 Claude Code 스킬 세트입니다. AI 조종사에게 비행 하네스를 채워주는 것과 같습니다 — 여전히 날 수 있지만, 어디로 갈지는 당신이 결정합니다.

**레포지토리**: [github.com/coolhero/spec-kit-skills](https://github.com/coolhero/spec-kit-skills)

---

## 아무도 말하지 않는 문제

AI 코딩 도구를 사용하는 모든 개발자가 경험한 시나리오가 있습니다:

"사용자 인증을 추가해줘"라고 요청합니다. 30초 만에 400줄의 코드가 생성됩니다. 리뷰합니다. 괜찮아 보입니다. 머지합니다.

3주 후, 발견합니다:
- 팀이 세션 기반으로 표준화했는데 JWT를 썼다
- 토큰을 localStorage에 저장했다 (XSS 취약점)
- Feature 2에서 이미 정의한 User 모델과 충돌하는 새 모델을 만들었다
- 에러 처리가 정상 경로만 다루고 나머지는 없다

코드는 *동작했습니다*. 테스트도 있었습니다. 하지만 이건 *당신의* 코드가 아니었습니다 — 당신의 레포지토리에 우연히 존재하게 된 코드였습니다.

**이것이 AI 능력과 개발자 통제 사이의 간극입니다.**

## "프롬프트를 더 잘 쓰면 되지"

가장 흔한 조언은 프롬프트를 더 잘 쓰라는 것입니다. 물론 더 나은 프롬프트는 도움이 됩니다. 하지만 한계가 있습니다.

프롬프트는 일회성 지시입니다. Feature 1이 무엇을 결정했는지 기억하지 못하고, 팀의 아키텍처 패턴을 인식하지 못하며, 이 프로젝트가 웹 앱이 아니라 Electron 앱이라서 상태 관리 방식이 다르다는 것을 이해하지 못합니다.

실제로 필요한 것은 더 나은 프롬프트가 아니라 **시스템**입니다:
1. Feature 간 **기억**이 유지되고 (Feature 3이 Feature 1의 데이터 모델을 안다)
2. 프로젝트 유형에 **적응**하고 (Electron 앱은 REST API와 다른 규칙을 적용)
3. 품질 게이트를 **강제**하고 (빌드가 통과했다고 검증을 건너뛸 수 없다)
4. 결정을 에이전트 메모리가 아닌 **파일**에 기록하는 (세션 간에 증발하지 않는)

이것을 우리는 **Harness Engineering**이라 부릅니다 — AI 에이전트의 행동을 신뢰할 수 있는 결과로 이끄는 구조화된 시스템을 만드는 것입니다.

## 왜 지금인가?

Agentic 코딩 도구가 임계점을 넘었습니다. Claude Code, Cursor, Copilot Workspace, Devin — 이들은 단순히 한 줄을 자동완성하는 게 아니라, 전체 Feature를 계획하고, 구현하고, 테스트하고, 반복합니다.

핵심은 이것입니다: **에이전트가 똑똑할수록, 감독 없이 발생시키는 피해도 커집니다.**

기본 자동완성은 리뷰하기 쉽습니다 — 한 줄이니까요. 12개 파일에 걸쳐 인증 시스템 전체를 스캐폴딩하는 에이전트 워크플로우? 그건 차원이 다른 리뷰입니다. 출력물이 아니라 그것을 만든 *프로세스*를 신뢰할 수 있어야 합니다.

이것이 업계가 향하는 방향입니다. "AI가 개발자를 대체한다"가 아니라 "개발자가 AI를 위한 하네스를 만든다." 가치의 중심이 *코드를 작성하는 것*에서 *코드를 작성하는 시스템을 설계하는 것*으로 이동합니다.

## spec-kit-skills가 실제로 하는 것

**spec-kit-skills**는 [spec-kit](https://github.com/github/spec-kit) (GitHub의 Specification-Driven Development 도구)을 프로젝트 전체 인식으로 감싸는 세 개의 Claude Code 스킬입니다:

```
/code-explore   → 빌드 전에 기존 코드를 이해
/reverse-spec   → 기존 코드베이스에서 스펙을 추출
/smart-sdd      → 크로스 Feature 메모리로 전체 SDD 파이프라인 실행
```

함께 하나의 파이프라인을 형성합니다:

```
  이해              명세화             빌드             검증
┌───────────┐   ┌──────────────┐   ┌───────────┐   ┌───────────┐
│code-explore│──→│  smart-sdd   │──→│  smart-sdd│──→│ smart-sdd │
│  orient    │   │  init → add  │   │  pipeline │   │  verify   │
│  trace     │   │  → specify   │   │  implement│   │  (runtime)│
│  synthesis │   │  → plan      │   │           │   │           │
└───────────┘   └──────────────┘   └───────────┘   └───────────┘
         ↑                                                │
         └────────────── 피드백 루프 ───────────────────────┘
```

### 세 가지 핵심 개념

**1. Global Evolution Layer (GEL)** — 파일에 저장되는 Feature 간 기억

에이전트가 빌드하는 모든 Feature는 등록됩니다: 데이터 모델은 `entity-registry.md`에, API 엔드포인트는 `api-registry.md`에. Feature 3이 시작될 때 에이전트는 무엇이 존재하는지 추측하지 않습니다 — 레지스트리를 읽습니다.

이것이 "File over Memory" 철학입니다: 에이전트가 기억해야 할 모든 것은 컨텍스트 윈도우(압축되고 결국 잊혀지는)가 아니라 파일에 저장됩니다.

**2. Domain Profile** — 5축의 프로젝트 유형 전문성

모든 프로젝트가 같지 않습니다. Electron 데스크톱 앱은 FastAPI 서버와 다른 관심사를 갖습니다. Domain Profile은 이를 5개 축으로 포착합니다:

| 축 | 무엇을 포착하는가 | 예시 |
|---|-----------------|-----|
| **Interface** | 사용자가 어떻게 상호작용하는가 | `gui`, `cli`, `http-api`, `grpc` |
| **Concern** | 횡단 관심사 패턴 | `auth`, `realtime`, `resilience` |
| **Archetype** | 도메인 철학 | `ai-assistant`, `microservice` |
| **Foundation** | 프레임워크 세부사항 | `electron`, `fastapi`, `go` |
| **Scenario** | 프로젝트 생명주기 | `greenfield`, `rebuild`, `adoption` |

프로젝트가 실시간 기능이 있는 Electron 앱이라고 알려주면, 이후의 모든 스펙, 계획, 검증 단계가 적응합니다 — IPC가 체크되고, 렌더러/메인 프로세스 경계가 강제되며, Playwright가 Electron 전용 프로토콜로 실행됩니다.

**3. Brief** — 구조화된 Feature 접수

"인증 추가해줘" 대신, 구조화된 상담을 거칩니다:
1. 이 Feature가 무엇을 하는가? (범위)
2. 누가 사용하는가? (액터)
3. 어떤 데이터를 다루는가? (엔티티)
4. 문제가 생기면 어떻게 되는가? (에러 경로)
5. 기존 Feature와 어떻게 상호작용하는가? (의존성)

2초 대신 2분이 걸립니다. 대가는 이후의 모든 산출물 — 스펙, 계획, 구현 — 이 가정이 아닌 명시적 결정에 기반한다는 것입니다.

## 실전 시나리오

실제 사용자가 시스템과 상호작용하는 방식입니다:

### "아이디어가 있고 만들고 싶다"
```
/smart-sdd init "AI 프로바이더와 채팅 앱 만들기"
/smart-sdd add "멀티 프로바이더 LLM 채팅 with 스트리밍"
/smart-sdd pipeline F001
```
파이프라인이 실행됩니다: specify → plan → tasks → implement → verify. 각 단계에서 리뷰하고 승인합니다. 에이전트는 단계를 건너뛸 수 없습니다.

### "기존 코드가 있고 이해하고 싶다"
```
/code-explore /path/to/opencode
/code-explore trace "컨텍스트 윈도우 관리가 어떻게 동작하는지"
/code-explore trace "프로바이더 추상화가 스트리밍을 어떻게 처리하는지"
/code-explore synthesis
```
결과물: 아키텍처 맵, Mermaid 다이어그램이 포함된 플로우 트레이스, 엔티티/API 인벤토리, SDD 파이프라인에 투입할 수 있는 Feature 후보들.

### "기존 앱을 처음부터 다시 만들고 싶다"
```
/reverse-spec /path/to/legacy-app
/smart-sdd init --from-reverse-spec
/smart-sdd pipeline
```

### "기존 코드에 SDD 문서를 입히고 싶다"
```
/smart-sdd adopt /path/to/existing-app
```

## 무엇이 다른가

1. **메모리가 아니라 파일**: 모든 결정, 모든 레지스트리, 모든 스펙이 레포에 존재합니다. `git diff`로 에이전트의 작업을 볼 수 있습니다.
2. **제안이 아니라 강제**: HARD STOP 게이트는 명시적 승인을 요구합니다. 에이전트는 응답 없이 절대 진행할 수 없습니다.
3. **도메인에 적응**: 48개 관심사 모듈, 15개 아키타입, 40개 이상의 프레임워크 파운데이션. Electron 앱의 검증 규칙은 Django 서버와 다릅니다.
4. **조합 가능**: 각 스킬은 독립적으로 동작하고, 함께 사용하면 파이프라인을 형성합니다.

---

## 사람을 위한 글 / 에이전트를 위한 글

> 이 시리즈는 특이한 구성을 가지고 있습니다: 각 편이 두 섹션으로 나뉩니다.
>
> **"사람을 위한 글"** (지금까지 읽은 부분)은 스토리와 예시로 개념을 설명합니다.
>
> **"에이전트를 위한 글"** (아래)은 같은 정보를 AI 에이전트가 직접 소비할 수 있는 구조화된 형식 — 명시적 규칙, 파일 경로, 의사결정 트리 — 으로 제시합니다.
>
> 왜? spec-kit-skills가 근본적으로 사람과 AI 에이전트 사이의 인터페이스에 관한 것이기 때문입니다. 같은 개념이 두 가지 표현이 필요합니다: 직관을 쌓아주는 것, 그리고 행동을 구동하는 것. 이 이중 구조 자체가 프로젝트의 핵심 철학을 시연합니다.
>
> 한번 해보세요: 아래의 "에이전트를 위한 글" 섹션을 복사해서 Claude Code 대화에 붙여넣어보세요. 무슨 일이 일어나는지 확인해보세요.

---

## 🤖 에이전트를 위한 글 — 구조화된 요약

```yaml
project: spec-kit-skills
version: 0.1.0
repository: https://github.com/coolhero/spec-kit-skills

purpose: |
  AI 코딩 에이전트를 위한 Harness Engineering.
  explore → specify → plan → implement → verify 파이프라인의 구조적 통제.

skills:
  - name: code-explore
    trigger: /code-explore
    purpose: 문서화된 이해를 생산하는 인터랙티브 소스 코드 탐색
    commands: [orient, trace, synthesis, status]
    output_path: specs/explore/
    key_concept: 빌드 전에 먼저 이해하라

  - name: reverse-spec
    trigger: /reverse-spec
    purpose: 기존 코드베이스에서 Global Evolution Layer 추출
    output_path: specs/reverse-spec/
    key_concept: 소스 코드 → 구조화된 스펙

  - name: smart-sdd
    trigger: /smart-sdd
    purpose: 크로스 Feature 메모리로 전체 SDD 파이프라인 오케스트레이션
    commands: [init, add, pipeline, adopt, status, coverage, parity, expand, reset]
    output_path: specs/
    key_concept: 모든 Feature가 다른 모든 Feature를 알고 있다

core_concepts:
  global_evolution_layer:
    what: 파일에 저장되는 Feature 간 메모리
    artifacts: [entity-registry.md, api-registry.md, sdd-state.md, roadmap.md]
    principle: File over Memory — 상태를 에이전트 컨텍스트에만 저장하지 마라

  domain_profile:
    axes: [Interface, Concern, Archetype, Foundation, Scenario]
    modifier: Scale (project_maturity × team_context)
    profiles_available: 15
    concerns_available: 48
    principle: 프로젝트 유형에 적응하라, 범용 체크리스트를 쓰지 마라

  brief:
    what: 구조화된 Feature 접수 (6단계 상담)
    steps: [scope, actors, entities, error_paths, dependencies, approval]
    principle: 2분의 구조화가 2시간의 재작업을 방지한다

enforcement:
  hard_stops: 모든 체크포인트에서 AskUserQuestion으로 명시적 사용자 승인 필요
  pipeline_guards: 7개 가드 (G1-G7)가 파이프라인 진행을 차단
  empty_response: 사용자 응답이 비어있으면 재질문 (침묵에 대해 절대 진행하지 않음)

installation:
  steps:
    - git clone https://github.com/coolhero/spec-kit-skills.git
    - cd spec-kit-skills
    - ./install.sh

scenarios:
  greenfield: /smart-sdd init → add → pipeline
  rebuild: /reverse-spec → /smart-sdd init --from-reverse-spec → pipeline
  adoption: /smart-sdd adopt
  exploration: /code-explore → /smart-sdd init --from-explore
  mid_pipeline_investigation: /code-explore --no-branch (활성 파이프라인 중 안전하게 사용)
```

---

*다음 편: **2편 — 세 가지 스킬 상세** — code-explore, reverse-spec, smart-sdd의 단계별 워크스루를 깊이 있게 다룹니다.*

*이 글은 Claude Code (Claude Opus 4.6)를 사용하여 작성되었습니다. spec-kit-skills 프로젝트 전체가, 이 글을 포함하여, 사람과 AI의 협업으로 개발되었습니다 — 사람이 하네스를 설계하고, AI가 그 안에서 동작합니다.*
