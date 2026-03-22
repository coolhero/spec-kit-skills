# AI 코딩 에이전트 길들이기: 프롬프트가 아니라 하네스가 필요한 이유

## 4부작 중 1편 — 배경, 아키텍처, 실전 시나리오

![1편 커버](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part1.png)

*이 글은 Claude Code로 작성되었습니다 — 이 프로젝트가 바로 그 도구를 위해 만들어졌다는 점에서, 의도된 아이러니입니다.*

---

**요약**: AI 코딩 에이전트는 놀랍도록 유능하지만, "유능한 것"과 "통제 가능한 것"은 다릅니다. 이 시리즈는 **spec-kit-skills**를 소개합니다 — AI 에이전트가 코드를 탐색하고, 설계하고, 구현하는 과정을 개발자가 구조적으로 통제할 수 있게 해주는 오픈소스 Claude Code 스킬 세트입니다.

**레포지토리**: github.com/coolhero/spec-kit-skills

---

## 아무도 말하지 않는 문제

AI 코딩 도구를 사용하는 모든 개발자가 경험한 시나리오가 있습니다:

"사용자 인증을 추가해줘"라고 요청합니다. 30초 만에 400줄의 코드가 생성됩니다. 리뷰합니다. 괜찮아 보입니다. 머지합니다.

3주 후, 발견합니다:

- 팀이 세션 기반으로 표준화했는데 JWT를 썼다
- 토큰을 localStorage에 저장했다 (XSS 취약점)
- Feature 2에서 이미 정의한 User 모델과 충돌하는 새 모델을 만들었다
- 에러 처리가 정상 경로만 다루고 나머지는 없다

코드는 *동작했습니다*. 테스트도 있었습니다. 하지만 이건 *당신의* 코드가 아니었습니다.

**이것이 AI 능력과 개발자 통제 사이의 간극입니다.**

---

## "프롬프트를 더 잘 쓰면 되지"

더 나은 프롬프트는 도움이 됩니다. 하지만 한계가 있습니다.

프롬프트는 일회성 지시입니다. Feature 1이 무엇을 결정했는지 기억하지 못하고, 팀의 아키텍처 패턴을 인식하지 못하며, 이 프로젝트가 웹 앱이 아니라 Electron 앱이라서 상태 관리 방식이 다르다는 것을 이해하지 못합니다.

실제로 필요한 것은 더 나은 프롬프트가 아니라 **시스템**입니다:

**기억이 유지되고** — Feature 3이 Feature 1의 데이터 모델을 안다

**프로젝트 유형에 적응하고** — Electron 앱은 REST API와 다른 규칙을 적용

**품질 게이트를 강제하고** — 빌드가 통과했다고 검증을 건너뛸 수 없다

**결정을 파일에 기록하는** — 세션 간에 증발하지 않는

이것을 우리는 **Harness Engineering**이라 부릅니다 — AI 에이전트의 행동을 신뢰할 수 있는 결과로 이끄는 구조화된 시스템을 만드는 것입니다.

---

## 왜 지금인가?

Agentic 코딩 도구가 임계점을 넘었습니다. Claude Code, Cursor, Copilot Workspace, Devin — 이들은 단순히 한 줄을 자동완성하는 게 아니라, 전체 Feature를 계획하고, 구현하고, 테스트하고, 반복합니다.

핵심은 이것입니다: **에이전트가 똑똑할수록, 감독 없이 발생시키는 피해도 커집니다.**

이것이 업계가 향하는 방향입니다. "AI가 개발자를 대체한다"가 아니라 "개발자가 AI를 위한 하네스를 만든다."

---

## spec-kit-skills가 실제로 하는 것

세 개의 Claude Code 스킬이 spec-kit을 프로젝트 전체 인식으로 감쌉니다:

- `/code-explore` → 빌드 전에 기존 코드를 이해
- `/reverse-spec` → 기존 코드베이스에서 스펙을 추출
- `/smart-sdd` → 크로스 Feature 메모리로 전체 SDD 파이프라인 실행

**이해** (code-explore) → **명세화** (smart-sdd: init → add → specify → plan) → **빌드** (implement) → **검증** (4단계 런타임 검증) → *피드백 루프*

---

## 세 가지 핵심 개념

**1. Global Evolution Layer (GEL) — 파일에 저장되는 Feature 간 기억**

에이전트가 빌드하는 모든 Feature는 등록됩니다: 데이터 모델은 `entity-registry.md`에, API 엔드포인트는 `api-registry.md`에. Feature 3이 시작될 때 에이전트는 추측하지 않습니다 — 레지스트리를 읽습니다.

"File over Memory" 철학입니다: 에이전트가 기억해야 할 모든 것은 컨텍스트 윈도우가 아니라 파일에 저장됩니다.

**2. Domain Profile — 5축의 프로젝트 유형 전문성**

- **Interface** — 사용자 상호작용: `gui`, `cli`, `http-api`, `grpc`
- **Concern** — 횡단 관심사: `auth`, `realtime`, `resilience`
- **Archetype** — 도메인 철학: `ai-assistant`, `microservice`
- **Foundation** — 프레임워크: `electron`, `fastapi`, `go`
- **Scenario** — 생명주기: `greenfield`, `rebuild`, `adoption`

프로젝트가 실시간 기능이 있는 Electron 앱이라고 알려주면, 이후의 모든 단계가 적응합니다.

**3. Brief — 구조화된 Feature 접수**

"인증 추가해줘" 대신 구조화된 상담:

1. 이 Feature가 무엇을 하는가? *(범위)*
2. 누가 사용하는가? *(액터)*
3. 어떤 데이터를 다루는가? *(엔티티)*
4. 문제가 생기면 어떻게 되는가? *(에러 경로)*
5. 기존 Feature와 어떻게 상호작용하는가? *(의존성)*

2초 대신 2분. 대가는 모든 산출물이 가정이 아닌 명시적 결정에 기반한다는 것입니다.

---

## 실전 시나리오

**"아이디어가 있고 만들고 싶다"**

```
/smart-sdd init "AI 프로바이더와 채팅 앱 만들기"
/smart-sdd add "멀티 프로바이더 LLM 채팅 with 스트리밍"
/smart-sdd pipeline F001
```

**"기존 코드가 있고 이해하고 싶다"**

```
/code-explore /path/to/opencode
/code-explore trace "컨텍스트 윈도우 관리가 어떻게 동작하는지"
/code-explore synthesis
```

**"기존 앱을 처음부터 다시 만들고 싶다"**

```
/reverse-spec /path/to/legacy-app
/smart-sdd init --from-reverse-spec
/smart-sdd pipeline
```

**"기존 코드에 SDD 문서를 입히고 싶다"**

```
/smart-sdd adopt /path/to/existing-app
```

---

## 무엇이 다른가

**메모리가 아니라 파일.** 모든 결정, 레지스트리, 스펙이 레포에 존재합니다. `git diff`로 에이전트의 작업을 볼 수 있습니다.

**제안이 아니라 강제.** HARD STOP 게이트는 명시적 승인을 요구합니다. 에이전트는 응답 없이 절대 진행할 수 없습니다.

**도메인에 적응.** 48개 관심사 모듈, 15개 아키타입, 40개 이상의 프레임워크 파운데이션.

**조합 가능.** 각 스킬은 독립적으로 동작하고, 함께 사용하면 파이프라인을 형성합니다.

---

## 사람을 위한 글 / 에이전트를 위한 글

> 이 시리즈는 특이한 구성을 가지고 있습니다: 각 편이 두 섹션으로 나뉩니다.
>
> **"사람을 위한 글"** (지금까지 읽은 부분)은 스토리와 예시로 개념을 설명합니다.
>
> **"에이전트를 위한 글"** (아래)은 같은 정보를 AI 에이전트가 직접 소비할 수 있는 구조화된 형식으로 제시합니다.
>
> 왜? spec-kit-skills가 근본적으로 사람과 AI 에이전트 사이의 인터페이스에 관한 것이기 때문입니다. 이 이중 구조 자체가 프로젝트의 핵심 철학을 시연합니다.
>
> 한번 해보세요: 아래 섹션을 복사해서 Claude Code 대화에 붙여넣어보세요.

---

## 🤖 에이전트를 위한 글 — 구조화된 요약

```
project: spec-kit-skills
version: 0.1.0
repository: https://github.com/coolhero/spec-kit-skills

purpose:
  AI 코딩 에이전트를 위한 Harness Engineering.
  explore → specify → plan → implement → verify 파이프라인의 구조적 통제.

skills:
  code-explore: 문서화된 이해를 생산하는 인터랙티브 소스 코드 탐색
  reverse-spec: 기존 코드베이스에서 Global Evolution Layer 추출
  smart-sdd: 크로스 Feature 메모리로 전체 SDD 파이프라인 오케스트레이션

core concepts:
  GEL: 파일에 저장되는 Feature 간 메모리
  Domain Profile: 5축 (Interface, Concern, Archetype, Foundation, Scenario)
  Brief: 6단계 구조화된 Feature 접수

enforcement:
  HARD STOP: 모든 체크포인트에서 명시적 사용자 승인
  Pipeline Guards: G1-G7 파이프라인 진행 차단
  빈 응답: 항상 재질문, 침묵에 대해 절대 진행하지 않음

scenarios:
  greenfield: init → add → pipeline
  rebuild: reverse-spec → init --from-reverse-spec → pipeline
  adoption: adopt
  exploration: code-explore → init --from-explore
```

---

*다음 편: **2편 — 세 가지 스킬 상세** — code-explore, reverse-spec, smart-sdd의 단계별 워크스루.*

*이 글은 Claude Code (Claude Opus 4.6)를 사용하여 작성되었습니다. 사람이 하네스를 설계하고, AI가 그 안에서 동작했습니다.*
