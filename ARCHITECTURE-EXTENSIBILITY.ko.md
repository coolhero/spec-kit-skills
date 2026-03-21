# 아키텍처 & 확장성 가이드

> spec-kit-skills 모듈형 도메인 아키텍처의 이해와 확장을 위한 상세 레퍼런스.
> 개요는 [README.ko.md](README.ko.md) § 아키텍처 참고.

---

## 세 가지 핵심 개념

spec-kit-skills는 규모 있는 Agentic Coding의 세 가지 구조적 gap을 해결하는 세 가지 개념 위에 구축되었습니다:

| 개념 | 해결하는 문제 | 구현 |
|------|-------------|------|
| **Global Evolution Layer (GEL)** | 에이전트마다 컨텍스트 관리 방식이 다르고, 어느 것도 Feature 간 관계를 체계적으로 추적하지 않음 | 프로젝트 수준 아티펙트(roadmap, 레지스트리, pre-context) + 파이프라인 단계별 자동 컨텍스트 주입 |
| **Domain Profile** | 에이전트가 프로젝트 유형에 관계없이 동일한 범용 접근을 적용 | 합성형 5축 + 1 modifier 시스템(Interface × Concern × Archetype × Foundation × Scenario + Scale)으로 프로젝트 유형별 규칙 로드 |
| **Brief** | 에이전트가 받은 Feature 설명을 그대로 수용하며 품질 gate가 없음 | spec 생성 전 핵심 차원의 완전성을 검증하는 구조화된 Feature 정의 프로세스 |

**연결 방식**: Brief가 완전한 Feature 정의를 생성 → GEL에 pre-context로 저장 → spec-kit 파이프라인에 주입 → Domain Profile 규칙이 각 단계의 동작을 형성. 이 가이드는 세 개념 중 가장 확장성이 높은 **Domain Profile** 모듈 시스템을 집중적으로 다룹니다.

---

## 목차

1. [모듈 시스템 개요](#1-모듈-시스템-개요)
   - [Signal Keywords: 공유 아키텍처](#signal-keywords-공유-아키텍처)
2. [5축 + 1 Modifier 도메인 합성](#2-5축--1-modifier-도메인-합성)
2b. [합성된 모듈이 파이프라인을 구동하는 방식](#2b-합성된-모듈이-파이프라인을-구동하는-방식)
3. [새 Interface 추가](#3-새-interface-추가)
4. [새 Concern 추가](#4-새-concern-추가)
5. [새 Archetype 추가](#5-새-archetype-추가)
6. [새 Foundation 추가](#6-새-foundation-추가)
7. [새 Profile 추가](#7-새-profile-추가)
8. [새 Scenario 추가](#8-새-scenario-추가)
9. [Sophistication Levels](#9-sophistication-levels)
10. [API 서버 개선 예제](#10-api-서버-개선-예제)
11. [Cross-Reference Map](#11-cross-reference-map)

---

## 1. 모듈 시스템 개요

spec-kit-skills는 **모듈형 도메인 아키텍처**를 사용하여 프로젝트별 동작을 작고 집중된 모듈 파일들로 합성합니다. 각 모듈은 SDD 파이프라인이 특정 프로젝트에서 어떻게 동작하는지를 형성하는 규칙, 프로브, 제약조건을 기여합니다.

### Dual-Skill 아키텍처

모든 모듈 타입은 상호보완적 역할을 가진 **두 스킬**에 존재합니다:

| 스킬 | 목적 | Section Schema | 모듈 역할 |
|------|------|---------------|----------|
| **reverse-spec** | 분석 (기존 코드에서 추출) | R1–R6 (인터페이스/관심사), A0–A1 (아키타입) | 감지 신호, 추출 축, 철학 추출 |
| **smart-sdd** | 실행 (새/재구축 코드 빌드) | S0–S9 (인터페이스/관심사), A0–A5 (아키타입) | SC 생성, 정교화 프로브, 검증, Constitution 주입 |

새 모듈을 추가할 때는 **양쪽** 스킬에 파일을 생성합니다 — Section Schema는 다르지만 동일한 도메인 개념을 다룹니다.

### 모듈 로딩

모듈은 스킬 호출 시 프로젝트의 `sdd-state.md` 설정에 기반하여 로드됩니다. **Resolver** (`smart-sdd/domains/_resolver.md`)가 state 파일을 읽고 정해진 순서로 모듈을 로드합니다:

```
1. _core.md                    (항상 — 범용 규칙)
2. interfaces/{name}.md        (나열된 각 인터페이스)
3. concerns/{name}.md          (나열된 각 관심사)
4. archetypes/{name}.md        (나열된 각 아키타입)
5. org-convention.md           (지정된 경우 — 조직 수준 공유 규칙)
6. scenarios/{scenario}.md     (하나의 시나리오)
7. domain-custom.md            (지정된 경우 — 프로젝트 수준 커스텀)
```

3단계 커스텀 계층 (Skill → Org → Project)으로, 나중에 로드된 레벨이 앞선 레벨을 오버라이드합니다. Org convention은 조직 내 프로젝트 간 공유 규칙을, project convention은 특정 프로젝트 고유 규칙을 제공합니다. 병합 규칙은 섹션마다 다릅니다 — 각 스킬의 `_schema.md` 참고.

### Signal Keywords: 공유 아키텍처

Signal Keywords (init 추론용 S0/A0, 소스 분석용 R1/A0)는 **스킬 간 공유**됩니다 — 각 스킬의 도메인 모듈에 중복하지 않고 단일 위치에 존재합니다.

```
.claude/skills/shared/domains/          ← 스킬 간 공유 리소스 (스킬이 아님)
├── _taxonomy.md                        ← 모듈 레지스트리 (단일 진실 소스)
├── _TEMPLATE.md                        ← 새 모듈 기여자 템플릿
├── interfaces/{name}.md                ← 인터페이스별 S0 (의미) + R1 (코드 패턴)
├── concerns/{name}.md                  ← 관심사별 S0 (의미) + R1 (코드 패턴)
└── archetypes/{name}.md                ← 아키타입별 A0 (의미 + 코드 패턴)
```

각 공유 모듈 파일의 내용:
- **Semantic Keywords (S0/A0)** — `smart-sdd init`의 Proposal Mode Signal Extraction에 사용. [매칭 알고리즘](.claude/skills/smart-sdd/reference/clarity-index.md)으로 매칭 (대소문자 무시, 복합어 우선, 전체 토큰 매칭).
- **Code Pattern Keywords (R1/A0)** — `reverse-spec`의 소스 코드 분석 및 모듈 자동 감지에 사용.

**스킬 모듈이 공유 키워드를 참조하는 방식**: 각 스킬 로컬 도메인 모듈(예: `smart-sdd/domains/concerns/auth.md`)은 S0/R1 섹션을 상호 참조로 대체합니다:
```
> See [shared/domains/concerns/auth.md](.claude/skills/shared/domains/concerns/auth.md) § Signal Keywords
```

이를 통해 **단일 진실 소스**를 보장합니다 — `shared/`에서 키워드를 업데이트하면 양쪽 스킬에 자동 적용됩니다.

**새 모듈을 추가할 때는 2개가 아닌 3개 파일**을 생성합니다:
1. `shared/domains/{type}/{name}.md` — Signal Keywords (S0/R1 또는 A0)
2. `reverse-spec/domains/{type}/{name}.md` — R3–R7 분석 섹션 (R1은 shared/ 참조)
3. `smart-sdd/domains/{type}/{name}.md` — S1–S8 실행 섹션 (S0은 shared/ 참조)

기여자 템플릿은 `shared/domains/_TEMPLATE.md`, 전체 모듈 레지스트리는 `shared/domains/_taxonomy.md` 참고.

### 공유 런타임 모듈

도메인 모듈 외에, `shared/runtime/`에 앱 실행, 데이터 저장소 감지, 사용자 설정을 위한 교차 스킬 프로토콜이 있습니다. **Interface 인식** — Domain Profile Axis 1 (Interface)에 따라 동작이 달라집니다:

| 모듈 | 용도 | Domain Profile 연결 |
|------|------|-------------------|
| `playwright-detection.md` | Playwright 백엔드 감지 | Interface가 연결 모드 결정 |
| `data-storage-map.md` | 데이터 저장소 + userData 경로 감지 | Foundation이 저장소 패턴 결정 |
| `user-assisted-setup.md` | 사용자 설정 안내 | Interface가 설정 UX 결정 |
| `app-launch.md` | 앱 실행 + Playwright 연결 | Interface S8 런타임 검증 전략 |

---

## 2. 5축 + 1 Modifier 도메인 합성

도메인 합성 시스템은 규칙을 생산하는 **5개 축**과 규칙의 깊이를 조절하는 **1개 modifier**를 가집니다. 각 구성요소는 다른 질문에 답합니다:

```
                    ┌─────────────────────────────────────┐
                    │       Domain Profile                │
                    │                                     │
                    │  5 AXES (규칙 생산자)                 │
  INTERFACE ────────┤  앱이 무엇을 노출하는가?              │──── http-api, gui, cli, tui, data-io
                    │                                     │
  CONCERN ──────────┤  어떤 횡단 관심사가 있는가?            │──── auth, async-state, ipc, i18n, realtime
                    │                                     │
  ARCHETYPE ────────┤  어떤 도메인 철학인가?                │──── ai-assistant, public-api, microservice
                    │                                     │
  FOUNDATION ───────┤  어떤 프레임워크 제약인가?             │──── React, Electron, Next.js (21개)
                    │                                     │
  SCENARIO ─────────┤  왜 만드는가?                        │──── greenfield, rebuild, incremental, adoption
                    │                                     │
                    │  1 MODIFIER (규칙 필터)               │
  SCALE ────────────┤  얼마나 엄격하게?                     │──── prototype/mvp/production × solo/small-team/large-team
                    └─────────────────────────────────────┘
```

### Axis vs Modifier

- **축**은 규칙을 생산합니다: "IPC 호출에 timeout handling SC가 필수"
- **modifier**는 깊이를 조절합니다: "prototype 모드에서 timeout SC는 선택"

Scale은 규칙을 추가하지 않고 적용 강도를 조절합니다. `production` + `large-team` 프로젝트는 필수 observability, 코드 오너십, 완전한 엣지 케이스 커버리지를 요구합니다. `prototype` + `solo` 프로젝트는 기능적 SC와 선택적 테스트만 요구합니다.

### 5개 축의 차이점

| # | 축 | 정의 | 예시 |
|---|---|------|------|
| 1 | **Interface** | _표면_ — 사용자 또는 시스템이 상호작용하는 방식 | HTTP API는 엔드포인트, 상태 코드, 요청/응답 형태를 정의 |
| 2 | **Concern** | _메커니즘_ — 내부 횡단 패턴 | Auth는 인증 흐름, 토큰 관리, 세션 처리를 정의 |
| 3 | **Archetype** | _철학_ — 도메인 특화 가이드 원칙 | AI Assistant는 Streaming-First, Model Agnosticism, Token Awareness를 정의 |
| 4 | **Foundation** | _도구 체인_ — 프레임워크별 제약 | Electron은 프로세스 모델, IPC 패턴, 보안 경계를 정의 |
| 5 | **Scenario** | _컨텍스트_ — 이 프로젝트가 존재하는 이유 | Rebuild는 보존 규칙, 마이그레이션 게이트, 패리티 검사를 정의 |

### Archetype ↔ Concern 관계

Archetype과 Concern은 다른 추상 수준에 있습니다 — 경쟁하는 분류가 아닙니다:

- **Concern**은 _어떤_ 패턴을 처리할지 정의: `realtime` → WebSocket reconnection, 메시지 순서
- **Archetype**은 _왜_ 더 중요한지 정의: `ai-assistant` → LLM 응답이 본질적으로 스트리밍이므로 streaming은 non-negotiable

Archetype은 Concern 규칙을 A2/A3를 통해 **확장**합니다. 중복이 아닙니다.

### Cross-Concern Integration Rules

여러 Concern이 동시에 활성화되면 어느 모듈도 단독으로 생산하지 않는 **emergent patterns**가 발생합니다. `_resolver.md` § Step 3.5에 명시적으로 정의:

| 활성 조합 | Emergent Pattern |
|----------|-----------------|
| `gui` + `realtime` | Optimistic update + reconnection UI |
| `gui` + `async-state` + `realtime` | 충돌 해소를 포함한 실시간 상태 동기화 |
| `microservice` + `message-queue` | 메시지 계약 버전 관리 + dead-letter 처리 |
| `ai-assistant` + `realtime` | 스트림 중단 + 부분 응답 표시 + token budget |

### 합성 예시

AI 기반 데스크톱 앱을 재구축하는 경우 (MVP, 솔로 개발자):

```
Profile:     desktop-app
Interfaces:  [gui]                    ← 축 1
Concerns:    [async-state, ipc]       ← 축 2
Archetype:   ai-assistant             ← 축 3
Foundation:  electron                 ← 축 4
Scenario:    rebuild                  ← 축 5
Scale:       mvp / solo              ← Modifier
```

6개 도메인 모듈 + 2개 Foundation 파일 = 8개 파일 로드, 모두 세션 동안 캐시. Scale modifier가 조절: MVP는 핵심 경로의 SC 커버리지는 완전하지만 엣지 케이스는 선택적; solo는 코드 리뷰 요구사항 없음.

### 진화 이력

**3축 → 4축 (Archetype 추가)**: 기존 모델에 구조화된 도메인 철학이 없었습니다. "Streaming-First" 같은 원칙이 ad-hoc으로 생성되었고, Archetype 모듈이 이를 재사용 가능하고 버전 관리 가능한 어휘로 표준화했습니다.

**4축 → 5축 + Modifier (Foundation 승격 + Scale)**: MECE 분석 결과 Foundation이 공식 인정 없이 사실상 축으로 운용되고 있었고(21개 파일, 자체 resolver 단계, 자체 검증 게이트), Scale 파라미터는 `greenfield.md`에 정의만 되고 파이프라인에 연결되지 않았습니다. Foundation을 축으로 승격하고 Scale을 modifier로 운용화하여 모델을 완성했습니다.

---

## 2b. 합성된 모듈이 파이프라인을 구동하는 방식

> 이전 섹션은 *무엇이* 합성되는지를 설명합니다. 이 섹션은 합성이 *무엇을 생산하고* 각 파이프라인 단계를 *어떻게 형성하는지*를 설명합니다.

### 핵심 메커니즘

도메인 모듈은 출력 파일로 **컴파일되지 않습니다**. 세션 시작 시 에이전트의 워킹 메모리에 로드되어 **행동 수정자**로 작동합니다 — 각 S-섹션이 특정 파이프라인 단계에서 _추가로_ 또는 _다르게_ 동작하도록 에이전트에게 지시합니다.

파이프라인을 위한 CSS라고 생각하세요: 모듈이 캐스케이드되고, 병합되며, 결합된 규칙이 각 단계의 동작을 "스타일링"합니다.

```
┌─────────────────────────────────────────────────────────────┐
│                    모듈 로딩 (1회)                            │
│                                                             │
│  _core.md → gui.md → async-state.md → ipc.md                │
│           → ai-assistant.md → rebuild.md                    │
│           → electron.md (Foundation)                        │
│                                                             │
│  결과: 병합된 규칙셋이 에이전트 워킹 메모리에 캐시             │
└──────────────────────────┬──────────────────────────────────┘
                           │
         각 S/A/F 섹션이 파이프라인 단계로 라우팅
                           │
    ┌──────────┬──────────┬┴─────────┬───────────┬──────────┐
    ▼          ▼          ▼          ▼           ▼          ▼
 specify     plan      tasks    implement    verify    parity
```

### Section → 파이프라인 단계 매핑

모든 모듈의 모든 섹션은 특정 파이프라인 단계로 라우팅됩니다. 전체 매핑:

| 섹션 | 내용 | 파이프라인 단계 | 동작 수정 방식 |
|------|------|---------------|--------------|
| **S0** | Signal Keywords | `init` | 사용자의 프로젝트 설명에서 활성화할 모듈을 자동 감지 |
| **S1** | SC 생성 규칙 | `specify` | 필수 Success Criteria 패턴 추가; 안티패턴 거부 |
| **S2** | 패리티 차원 | `parity` | 구조/로직 비교 축 정의 (기존 vs 새 코드) |
| **S3** | Verify 단계 | `verify` | 검증 게이트 추가/확장 (test, build, lint, demo + 모듈별) |
| **S5** | 정교화 프로브 | `specify` (clarify) | Feature 컨설테이션에서 도메인별 질문 추가 |
| **S6** | UI 테스트 전략 | `verify` Phase 2-3 | UI 렌더링 테스트 방법 정의 (Playwright, 스크린샷) |
| **S7** | 버그 방지 규칙 | `plan` / `analyze` / `implement` / `verify` | 단계별 검사 활성화 (B-1, B-2, B-3, B-4로 분류) |
| **S8** | 런타임 검증 | `verify` Phase 2-3 | 실행 중인 앱의 시작, 프로브, 종료 방법 정의 |
| **S9** | Brief 완료 기준 | `add` Phase 1 | Briefing 프로세스를 위한 도메인별 최소 요구사항 |
| **A1** | 철학 원칙 | `constitution` | 도메인 가이드 원칙 주입 (예: "Streaming-First") |
| **A2** | SC 확장 | `specify` | 아키타입별 SC 패턴 추가 (S1에 append) |
| **A3** | 프로브 | `specify` (clarify) | 아키타입별 질문 추가 (S5에 append) |
| **A4** | Constitution 주입 | `constitution` | 실행 가능한 원칙을 프로젝트 Constitution에 내장 |
| **A5** | Brief 완료 기준 | `add` Phase 1 | 아키타입별 Briefing 프로세스 최소 요구사항 |
| **F2** | Foundation 체크리스트 | `pipeline` Phase 0 | 프레임워크 결정에서 T0 인프라 Feature 생성 |
| **F7** | Framework Philosophy | `constitution` | 프레임워크별 원칙 추가 (예: Electron 프로세스 모델) |
| **F8** | Toolchain 명령 | `verify` Phase 1 | 자동 감지된 build/test/lint 명령 오버라이드 |
| **F9** | 스캔 대상 | `reverse-spec` Phase 2 | 프레임워크별 추출 패턴 추가 (데코레이터, 모델) |

### 구체적 워크스루: 단계별

`desktop-app + ai-assistant + rebuild + electron` 예시를 사용하여, 각 파이프라인 단계에서 정확히 무엇이 바뀌는지 보여줍니다:

#### 1. `constitution` — 프로젝트 Constitution에 주입되는 것

| 소스 | 기여 |
|------|------|
| **A1** (ai-assistant) | 원칙: Streaming-First, Model Agnosticism, Offline Resilience, Token Awareness, Prompt Versioning |
| **A4** (ai-assistant) | 실행 규칙: "비즈니스 로직에서 프로바이더 SDK를 직접 호출하지 마라" |
| **F7** (electron) | 프레임워크 원칙: Process Crash Isolation, Secure by Default, Web Standards First |

모듈 없이: Constitution에는 사용자 제공 및 spec-kit 기본 원칙만 포함.
모듈 있으면: Constitution에 **12개 이상의 도메인 특화 원칙**이 내장되어 모든 하위 결정을 안내.

#### 2. `specify` — Feature 스펙이 형성되는 방식

| 소스 | 기여 |
|------|------|
| **S1** (_core) | 기본 SC 규칙: 모든 Feature에 명확한 pass/fail이 있는 테스트 가능한 SC 필요 |
| **S1** (gui) | +UI SC: 인터랙션 SC는 사용자 행동 → 시각적 결과를 명시 |
| **S1** (async-state) | +State SC: 비동기 작업에 loading/error/success 상태 필수 |
| **S1** (ipc) | +IPC SC: 프로세스 간 호출에 채널, 페이로드, 응답 명시 |
| **S1** (rebuild) | +보존 SC: 원본 동작이 유지되는지 검증 필수 |
| **A2** (ai-assistant) | +AI SC: 스트리밍 응답에 partial/complete/error 상태 처리 필수 |
| **S5** (모든 모듈) | 결합된 프로브: auth, CRUD, 라우팅, UI, IPC, 스트리밍, 모델 선택, 보존 관련 30개 이상 질문 |

모듈 없이: specify가 "사용자가 로그인할 수 있다" 같은 일반적 SC를 생성.
모듈 있으면: specify가 **정밀하고 도메인 인식적인 SC**를 생성 — "사용자가 메시지를 보내면 → 스트리밍 응답이 채팅 패널에서 토큰 단위로 렌더링 (first-token 지연 동안 로딩 인디케이터) → 응답 완료 → 채팅 히스토리가 앱 재시작 후에도 유지."

#### 3. `plan` — 아키텍처 설계 중 버그 방지

| 소스 | 기여 |
|------|------|
| **S7 B-1** (_core) | Runtime Compatibility, Async & Concurrency, Dependency Safety |
| **S7 B-1** (gui) | +UI 안티패턴: CSS 렌더링 트랩, 컴포넌트 생명주기 이슈 |
| **S7 B-1** (ipc) | +IPC 안티패턴: 직렬화 경계, 프로세스 생명주기 |

모듈 없이: plan이 일반적 런타임 이슈를 검사.
모듈 있으면: plan이 IPC 직렬화 경계 이슈, CSS 테마 토큰 매핑 갭, Electron 프로세스 모델 위반을 **사전에 플래그**.

#### 4. `implement` — 코딩 중 조건부 버그 검사

| 소스 | 기여 |
|------|------|
| **S7 B-3** (_core) | Cross-Feature 통합, 데이터 영속성, 모듈 스코프 생명주기 |
| **S7 B-3** (gui) | +Platform CSS Rendering 검사, +UI Interaction Surface 감사 |
| **S7 B-3** (ipc) | +IPC Boundary Safety, +IPC Return Value Defense |
| **S7 B-3** (async-state) | +Selector 불안정성, +미배치 업데이트, +UX 행동 계약 |

모듈 없이: implement가 일반적 안전 검사를 실행.
모듈 있으면: implement가 모든 IPC 핸들러의 반환 값 검증, 모든 CSS 변수의 테마 시스템 매핑, 모든 비동기 셀렉터의 메모이제이션을 **적극 검증**.

#### 5. `verify` — 다단계 검증

| 소스 | 기여 |
|------|------|
| **S3** (_core) | Phase 1: test + build + lint (차단) |
| **S3** (rebuild) | +Migration regression gate, +Foundation compliance (S3d) |
| **S6** (gui) | Phase 2-3: Playwright UI 테스트 — 스크린샷 비교, 인터랙션 테스트 |
| **S8** (gui) | 런타임 전략: Electron 앱 테스트를 위한 시작/종료 방법 |
| **F8** (electron) | Toolchain 오버라이드: Electron 전용 build/test 명령 사용 |

모듈 없이: verify가 test/build/lint만 실행하고 종료.
모듈 있으면: verify가 **5단계** 실행 — test/build/lint → Playwright UI 테스트 → 데모 스크립트 → 마이그레이션 패리티 검사 → Foundation 준수 감사.

### 병합 규칙 (충돌 해결 방식)

여러 모듈이 동일 섹션에 기여할 때, 간단한 규칙을 따릅니다:

```
로드 순서: _core → interfaces → concerns → archetypes → foundations → org-convention → scenarios → custom
이후 적용: Scale modifier (깊이 조절)

병합 동작:
  S1 (SC 규칙)         → APPEND  (모든 규칙 누적)
  S5 (프로브)           → APPEND  (모든 질문 누적)
  S7 (버그 방지)        → APPEND  (모든 검사 누적)
  S2 (패리티)           → APPEND  (모듈별 차원 추가)
  S3 (Verify 단계)      → EXTEND  (후속 모듈이 단계 추가; 명시적일 때만 오버라이드)
```

각 모듈이 **추가적** 도메인 지식을 기여하기 때문에 충돌이 발생하지 않습니다. `gui` 모듈은 `ipc` 모듈과 충돌하지 않습니다 — 서로 다른 도메인에 서로 다른 규칙을 추가합니다.

### 요약: 합성이 실제로 생산하는 것

```
5개 축 입력:  [_core, gui, async-state, ipc, ai-assistant, electron, rebuild]
                                    │
                                    ▼
병합 결과:  파일이 아님 — 에이전트 메모리의 행동 규칙셋
                                    │
                              Scale modifier
                         (mvp/solo → 깊이 조절)
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              SC 규칙 ×18    프로브 ×30+     버그 검사 ×15
              (S1+A2)         (S5+A3)         (S7 B1-B4)
              + Foundation    + Scale 조절    + Foundation
                (F2,F7)                        (F8)
                    │               │               │
                    ▼               ▼               ▼
              형성            형성            형성
              specify         clarify         plan/impl/verify
```

에이전트는 합성 산출물을 "생성"하지 않습니다. 병합된 규칙이 각 단계에서 **다르게 동작**하도록 지시하기 때문입니다: "SC 작성 시 IPC 패턴도 검사하라" 또는 "verify 시 Playwright UI 테스트도 실행하라." Scale modifier가 이후 조절합니다: `prototype` 모드에서 비핵심 검사는 선택적이 되고, `production` 모드에서 모든 검사가 차단 조건이 됩니다. 모듈은 보이지 않는 인프라입니다 — 사용자는 더 나은 스펙, 더 철저한 계획, 더 신뢰할 수 있는 구현을 경험합니다.

---

## 3. 새 Interface 추가

Interface는 앱의 외부 표면 — 사용자 또는 시스템이 상호작용하는 프로토콜을 정의합니다.

### 추가 시점

기존 인터페이스(gui, http-api, cli, data-io, tui)로 커버되지 않는 별도의 인터랙션 표면이 있을 때 추가합니다.

### 절차

1. **공유 Signal 모듈 생성**: `.claude/skills/shared/domains/interfaces/{name}.md`
   - S0 (Semantic Keywords)과 R1 (Code Patterns) 추가
   - `shared/domains/_TEMPLATE.md`를 시작 템플릿으로 사용
   - `shared/domains/_taxonomy.md`에 등록

2. **reverse-spec 모듈 생성**: `.claude/skills/reverse-spec/domains/interfaces/{name}.md`
   - R1은 shared/ 참조: `See [shared/domains/interfaces/{name}.md] § Signal Keywords`
   - R3 (분석 축) 추가: 분석 중 추출할 대상 (예: `graphql`의 경우: 스키마 추출, resolver 패턴)

3. **smart-sdd 모듈 생성**: `.claude/skills/smart-sdd/domains/interfaces/{name}.md`
   - S0은 shared/ 참조: `See [shared/domains/interfaces/{name}.md] § Signal Keywords`
   - S1 (SC 생성 규칙), S5 (정교화 프로브), S8 (런타임 검증) 추가

4. **_schema.md 업데이트** (양쪽 스킬): 변경 불필요 — 기존 스키마가 새 인터페이스를 자동 지원.

5. **프로필 업데이트**: 새 인터페이스가 프로필에 포함되어야 하면 (예: `web-api`에 `graphql` 포함), 프로필 매니페스트를 업데이트.

5. **테스트**: 이 인터페이스를 사용하는 프로젝트로 init → specify 흐름을 실행. S0 키워드가 감지를 트리거하고 S1 규칙이 의미 있는 SC를 생성하는지 확인. Signal 매칭 메커니즘(대소문자 무시, 복합어 우선, 전체 토큰 매칭)은 [`clarity-index.md` § 3 매칭 알고리즘](.claude/skills/smart-sdd/reference/clarity-index.md) 참고.

### Section 체크리스트

| 섹션 | reverse-spec | smart-sdd | 필수? |
|------|-------------|-----------|-------|
| Detection/Signal | R1 | S0 | 예 |
| Analysis/SC Rules | R3 | S1 | 예 |
| Parity Dimensions | — | S2 | 인터페이스가 구조/로직 패리티 차원을 추가하는 경우 |
| Elaboration Probes | — | S5 | 권장 |
| Bug Prevention | — | S7 | 권장 |
| Runtime Verification | — | S8 | 예 (인터페이스의 경우) |

---

## 4. 새 Concern 추가

Concern은 여러 Feature에 영향을 미치는 내부 횡단 패턴입니다.

### 추가 시점

기존 Concern(auth, async-state, ipc, i18n, realtime, external-sdk)으로 커버되지 않는 반복적 횡단 패턴이 있을 때 추가합니다.

### 절차

1. **공유 Signal 모듈 생성**: `.claude/skills/shared/domains/concerns/{name}.md`
   - S0 (init 추론용 Semantic Keywords)과 R1 (소스 분석용 Code Patterns) 추가
   - `shared/domains/_TEMPLATE.md`를 시작 템플릿으로 사용
   - `shared/domains/_taxonomy.md`에 등록

2. **reverse-spec 모듈 생성**: `.claude/skills/reverse-spec/domains/concerns/{name}.md`
   - R1은 shared/ 참조: `See [shared/domains/concerns/{name}.md] § Signal Keywords`
   - R3–R7 분석 전용 섹션 추가

3. **smart-sdd 모듈 생성**: `.claude/skills/smart-sdd/domains/concerns/{name}.md`
   - S0은 shared/ 참조: `See [shared/domains/concerns/{name}.md] § Signal Keywords`
   - S1, S5, S7 추가 (선택: S3 — 검증 오버라이드용, S4x — 데이터 무결성 확장용)
   - **S4 확장**: concern이 보편 S4a-c를 넘어서는 구체적 데이터 무결성 패턴을 추가할 경우 (예: `ipc`의 N-Layer 완전성 체크 = S4c Pipeline Traceability의 구체화), S4x 하위 섹션으로 추가

4. **프로필 업데이트**: Concern이 프로필의 기본값이어야 하면, 프로필 매니페스트를 업데이트.

5. **Cross-Concern Integration Rules**: 새 concern이 기존 concern과 결합될 때 발생하는 emergent pattern이 있는지 확인. 있으면 `_resolver.md` § Step 3.5 테이블에 행 추가. 예: `llm-agents` + `gui` → "동기 LLM 호출 중 UI 프리즈" 방지.

6. **테스트**: S0 키워드가 `init` Proposal Mode에서 모듈 활성화를 트리거하는지 확인. 매칭 메커니즘은 [`clarity-index.md` § 3 매칭 알고리즘](.claude/skills/smart-sdd/reference/clarity-index.md) 참고.

### 기존 Concern 모듈

| Concern | 설명 | 주요 패턴 |
|---------|------|----------|
| `auth` | 인증 흐름, 세션 관리 | 토큰 생명주기, OAuth, RBAC |
| `async-state` | 비동기 데이터 페칭, loading/error 상태 | 레이스 컨디션, stale-while-revalidate |
| `ipc` | 프로세스 간 통신 (데스크톱 앱) | 채널 설계, preload 브릿지, 메시지 직렬화 |
| `i18n` | 국제화 | 키 커버리지, 로케일 폴백, RTL 지원 |
| `realtime` | WebSocket, SSE, 실시간 데이터 | 연결 생명주기, 재연결, 상태 동기화 |
| `external-sdk` | 서드파티 SDK 통합 | SDK 계약 검증, 버전 관리 |
| `protocol-integration` | LSP/MCP/커스텀 프로토콜 구현 | 메시지 생명주기, 기능 협상, 전송 추상화 |
| `plugin-system` | 플러그인 아키텍처 패턴 | 플러그인 생명주기, 격리, API 표면, 버저닝 |
| `authorization` | RBAC/ABAC/ACL 접근 제어 | 권한 모델, 역할 계층, 정책 시행 |
| `llm-agents` | LLM 에이전트 조정, 비결정적 출력 | 구조적/행동적 테스트, 샌드박스 실행, 멀티 에이전트 라우팅, Golden Fixture |
| `message-queue` | 메시지 브로커 / 이벤트 버스 패턴 | Publish/consume 생명주기, DLQ, 전달 보장, 멱등성 |
| `task-worker` | 백그라운드 작업 / 스케줄 태스크 패턴 | 태스크 디스패치, 재시도, 타임아웃, 주기 스케줄링, 워커 생명주기 |
| `polyglot` | 다국어 코드베이스와 언어 간 브릿지 | FFI (PyO3, cgo, JNI), Protobuf/gRPC, WASM, 빌드 오케스트레이션 |
| `codegen` | IDL/스키마/템플릿에서 생성된 코드 | Source-of-truth 추적, 재생성 파이프라인, 반복 파일 감지 |
| `multi-tenancy` | 테넌트 격리, 테넌트별 설정 | Row-level security, 테넌트 컨텍스트 전파, 캐시 격리 |
| `infra-as-code` | 인프라 정의를 first-class 컴포넌트로 | Terraform, Helm, K8s, Docker Compose, app-infra 동기화 |

### 잠재적 새 Concern 예시

- `caching` — Redis, 인메모리 캐시, CDN 캐시 무효화 패턴
- `file-storage` — S3, 로컬 파일시스템, 업로드 처리, CDN 통합
- `notifications` — 푸시 알림, 이메일, SMS, 인앱 알림
- `search` — Elasticsearch, Algolia, 전문 검색 패턴

### 범위 밖 (향후 확장)

- **`native-app` 인터페이스** — 순수 네이티브 모바일/데스크톱 앱 (SwiftUI, Jetpack Compose, WinUI). 기존 `gui` 인터페이스 + `react-native`/`flutter` Foundation이 크로스 플랫폼 네이티브를 커버하지만, 순수 네이티브 (JS 브릿지 없는 Swift/Kotlin/C++)는 빌드 시스템(Xcode/Gradle), 네이티브 UI 테스트(XCTest/Espresso), 플랫폼별 SC 생성을 위한 전용 인터페이스 모듈이 필요합니다. 4축 합성 모델은 구조 변경 없이 이 확장을 지원합니다 — 새 모듈 파일만 필요합니다.

---

## 5. 새 Archetype 추가

Archetype은 프레임워크와 인터페이스 선택을 초월하는 애플리케이션 도메인 철학 — 가이드 원칙을 정의합니다.

### 추가 시점

특정 애플리케이션 클래스가 아키텍처 결정을 안내해야 하는 고유한 철학적 원칙을 가질 때 추가합니다. 핵심 테스트: **이 도메인의 프로젝트들이 기술 스택에 관계없이 일관되게 동일한 아키텍처 원칙 세트를 필요로 하는가?**

### 절차

1. **공유 Signal 모듈 생성**: `.claude/skills/shared/domains/archetypes/{name}.md`
   - **A0**: Signal Keywords — Semantic (init 추론용) + Code Patterns (소스 분석용)
   - `shared/domains/_TEMPLATE.md`를 시작 템플릿으로 사용
   - `shared/domains/_taxonomy.md`에 등록

2. **reverse-spec 모듈 생성**: `.claude/skills/reverse-spec/domains/archetypes/{name}.md`
   - A0은 shared/ 참조: `See [shared/domains/archetypes/{name}.md] § Signal Keywords`
   - **A1**: Analysis Axes — Philosophy Extraction — 코드에서 찾아야 할 원칙

3. **smart-sdd 모듈 생성**: `.claude/skills/smart-sdd/domains/archetypes/{name}.md`
   - A0은 shared/ 참조: `See [shared/domains/archetypes/{name}.md] § Signal Keywords`
   - **A1**: 철학 원칙 — 핵심 도메인 원칙 (이름, 설명, 함의)
   - **A2**: SC 생성 확장 — 도메인별 SC 패턴과 안티패턴
   - **A3**: 정교화 프로브 — 도메인별 컨설테이션 질문
   - **A4**: Constitution 주입 — 프로젝트 Constitution에 내장할 원칙

4. **스키마/Resolver 변경 불필요** — Archetype 로딩 시스템은 범용적.

4. **테스트**: A0 키워드를 포함한 아이디어 문자열로 `init`을 실행. Archetype이 자동 감지되는지 확인.

### Archetype 설계 원칙

- Archetype당 **3–5개 철학 원칙** (A1) — 너무 적으면 피상적, 너무 많으면 초점 희석
- **원칙은 비자명해야** — "테스트를 작성하라"는 범용적, "스트리밍이 기본 전달 모드"는 아키타입 특화
- **각 A2 SC 패턴은 A1 원칙을 인용해야** — SC 규칙이 철학에서 흘러나옴
- **A4 Constitution 주입은 실행 가능해야** — "model agnosticism"은 모호; "비즈니스 로직에서 프로바이더 SDK를 직접 호출하지 마라"는 실행 가능

### 잠재적 새 Archetype 예시

- `saas-platform` — Multi-tenancy, Tenant Isolation, Subscription Lifecycle, Usage Metering
- `real-time-collaboration` — Conflict Resolution (CRDT/OT), Presence Awareness, Offline-First
- `iot-gateway` — Device Lifecycle, Telemetry Pipeline, Firmware Updates, Connection Management

### 기존 Archetype 모듈

| Archetype | 설명 | 핵심 원칙 |
|-----------|------|----------|
| `ai-assistant` | LLM 기반 애플리케이션 | Streaming-First, Model Agnosticism, Offline Resilience, Token Awareness, Prompt Versioning |
| `public-api` | 외부 대면 API 플랫폼 | Rate Limiting, Versioning, API Key Lifecycle, Documentation Parity |
| `microservice` | 분산 서비스 아키텍처 | Service Autonomy, Contract-First, Circuit Breaking, Observability |
| `sdk-framework` | 다른 개발자용 라이브러리, SDK, 프레임워크 | API Stability, Extension-First Design, Example-as-Contract, Documentation Parity, Backward Compatibility |

---

## 6. 새 Foundation 추가

Foundation은 비즈니스 Feature 시작 전에 내려야 하는 프레임워크별 인프라 결정을 캡처합니다.

### 추가 시점

프레임워크가 구조화된 체크리스트의 이점을 받을 만큼 충분히 많은 고유한 인프라 결정(일반적으로 30개 이상)을 가질 때 추가합니다.

### 절차

1. **Foundation 파일 생성**: `.claude/skills/reverse-spec/domains/foundations/{name}.md`
   - **F0**: Detection Signals (프로필 해결 시 자동 감지)
   - **F1**: Framework Category Taxonomy (`_foundation-core.md`의 어떤 F1 카테고리가 적용되는지 + 프레임워크별 카테고리)
   - **F2**: Foundation 체크리스트 (실제 항목 — ID, 항목, 결정 필요 사항, 우선순위)
   - **F3**: 추출 규칙 (코드에서 기존 결정을 감지하는 방법)
   - **F4**: T0 Feature 그룹핑 (Foundation 항목이 T0 Feature에 매핑되는 방식)
   - **F7**: Framework Philosophy (선택 — 프레임워크가 옹호하는 가이드 원칙)
   - **F8**: Toolchain 명령 (선택 — 파이프라인이 자동화에 읽는 build/test/lint/typecheck 명령)
   - **F9**: 스캔 대상 (선택 — reverse-spec Phase 2 데이터 모델/API 추출용 프레임워크별 패턴)

2. **`_foundation-core.md` 업데이트**: F6 Framework Files 테이블에 행 추가.

3. **테스트**: 이 프레임워크를 사용하는 프로젝트에서 reverse-spec 실행. Foundation 항목이 감지되고 T0 Feature로 그룹핑되는지 확인.

### F8 Toolchain 명령

F8은 Foundation 파일이 해당 생태계의 정확한 build/test/lint 명령을 선언할 수 있게 합니다. 존재하면 Foundation Gate와 Verify Phase 1이 자동 감지 대신 이 명령을 사용합니다. F8이 없으면 파이프라인이 npm/yarn/pnpm 휴리스틱으로 폴백합니다. 전체 필드 목록은 `_foundation-core.md` § F8 참고.

### F9 스캔 대상

F9는 Foundation 파일이 reverse-spec Phase 2 분석(데이터 모델 추출, API 엔드포인트 추출, 컴포넌트 패턴)을 위한 프레임워크별 스캔 대상을 선언할 수 있게 합니다. 이 대상은 `_core.md`의 범용 스캔 대상과 **병합**됩니다 — 새 프레임워크를 추가할 때 `_core.md` 수정 불필요. F9가 없으면 범용 대상만 적용됩니다. 형식은 `_foundation-core.md` § F9 참고.

### Foundation 형식 변형

Foundation 파일은 프레임워크 성숙도와 항목 밀도에 따라 두 가지 형식으로 존재합니다:

| 형식 | 사용 시점 | 섹션 | 예시 파일 |
|------|----------|------|----------|
| **Full** | 40개 이상 결정 항목이 있는 프레임워크 | F0, F1 (항목 수), F2 (카테고리별 항목 테이블), F3, F4, F7, F8, F9 | `electron.md`, `express.md`, `nextjs.md` |
| **Compact** | 에이전트가 강한 내장 지식을 가진 잘 알려진 프레임워크 | F0, F1, F2 (핵심 항목만), F7, F8, F9 | `hono.md`, `spring-boot.md`, `django.md`, `fastapi.md`, `nestjs.md` |

Compact 형식이 작동하는 이유: Foundation 파일이 프레임워크를 가르치는 것이 아니라 **구조화된 추출**을 안내하기 때문입니다 — 에이전트는 이미 깊은 프레임워크 지식을 보유합니다. Compact 파일은 일반적으로 ~80-120줄 vs Full 파일의 ~200줄 이상.

### TODO Scaffold 패턴

아직 완전히 문서화되지 않은 프레임워크에는 TODO scaffold를 사용합니다 (F0과 F1만 채워지고 나머지는 TODO 표시). 이는 의도적입니다 — CLAUDE.md § Do NOT Modify #2 참고. 예시: `react-native.md`, `flutter.md`.

### 언어별 Foundation 커버리지

현재 언어 및 프레임워크별 Foundation 커버리지:

| 언어 | 커버되는 프레임워크 | Foundation 파일 | 형식 |
|------|-------------------|-----------------|------|
| **JavaScript/TypeScript** | Express, NestJS, Next.js, Hono | `express.md`, `nestjs.md`, `nextjs.md`, `hono.md` | Full / Compact |
| **Python** | FastAPI, Django, Flask | `fastapi.md`, `django.md`, `flask.md` | Compact |
| **Java/Kotlin** | Spring Boot | `spring-boot.md` | Compact |
| **Go** | Chi, Gin | `go-chi.md` | Compact |
| **Rust** | Actix-web | `actix-web.md` | Compact |
| **Ruby** | Rails | `rails.md` | Compact |
| **PHP** | Laravel | `laravel.md` | Compact |
| **Elixir** | Phoenix | `phoenix.md` | Compact |
| **C#** | ASP.NET Core | `dotnet.md` | Compact |
| **Dart** | Flutter | `flutter.md` | TODO scaffold |
| **JS (모바일)** | React Native | `react-native.md` | TODO scaffold |
| **JS (데스크톱)** | Electron, Tauri | `electron.md`, `tauri.md` | Full |
| **JS (프론트엔드)** | Vite+React, Solid.js | `vite-react.md`, `solidjs.md` | Full / Compact |
| **JS (런타임)** | Bun | `bun.md` | Compact |

위에 나열되지 않은 프레임워크를 사용하면, **Generic Foundation Protocol** (`_foundation-core.md`의 Case B)이 적용됩니다 — 범용 카테고리와 에이전트 보충 프로브를 사용합니다.

### F7 Philosophy 가이드라인

프레임워크가 강한 의견을 가질 때만 F7을 추가:
- Express: 최소주의지만 명확한 규약 → F7 적합 (Middleware Composition, Stateless Requests)
- Electron: 강한 프로세스 모델 의견 → F7 적합 (Process Crash Isolation, Secure by Default)
- 순수하게 의견이 없는 라이브러리: F7 생략

---

## 7. 새 Profile 추가

Profile은 인터페이스와 관심사를 이름 있는 설정으로 합성하는 ~10줄 매니페스트입니다.

### 형식

```markdown
# Profile: {name}

> {설명}

interfaces: [{쉼표로 구분된 목록}]
concerns: [{쉼표로 구분된 목록}]

# Scenario는 sdd-state.md의 Origin 필드로 결정되며, profile이 아닙니다.
```

### 추가 시점

공통 프로젝트 설정 (인터페이스 + 관심사 조합)이 반복적으로 사용될 때 추가합니다. Profile은 편의 단축키입니다 — 인터페이스와 관심사를 개별 지정해도 동일한 결과를 얻을 수 있습니다.

### 절차

1. `.claude/skills/smart-sdd/domains/profiles/{name}.md` 생성
2. 인터페이스와 관심사 나열
3. Profile에 선택적으로 `archetype:` 필드 포함 가능 (예: `sdk-library` → `sdk-framework`). 존재하면 Resolver가 Step 2c에서 해당 Archetype을 활성화.

### 기존 Profile

| Profile | Interfaces | Concerns | Archetype |
|---------|-----------|----------|-----------|
| `desktop-app` | gui | async-state, ipc | — |
| `fullstack-web` | http-api, gui | async-state, auth, i18n | — |
| `web-api` | http-api | auth | — |
| `cli-tool` | cli | (없음) | — |
| `ml-platform` | http-api, cli, data-io | plugin-system, auth | — |
| `sdk-library` | cli | plugin-system | sdk-framework |

---

## 8. 새 Scenario 추가

Scenario는 프로젝트가 _왜_ 만들어지는지에 따른 파이프라인 동작 변형을 정의합니다.

### 추가 시점

드뭅니다. 4가지 시나리오 (greenfield, rebuild, incremental, adoption)가 대부분의 사용 사례를 커버합니다. 새 프로젝트 컨텍스트에 파이프라인이 근본적으로 다른 동작을 필요로 할 때만 추가합니다.

### 절차

1. `.claude/skills/smart-sdd/domains/scenarios/{name}.md` 생성
2. 시나리오가 기여하는 S-섹션 정의 (일반적으로 S1, S3, S5, S7)
3. 시나리오에 특수 해결 규칙이 있으면 `_resolver.md` 업데이트

---

## 9. Sophistication Levels

모듈은 5단계의 정교화 수준을 거쳐 진화합니다. 이 모델은 개선 작업의 우선순위를 정하는 데 도움이 됩니다.

### 현재 상태 (2026-03-20 기준)

| Level | 상태 | 비고 |
|-------|------|------|
| **Level 1** | ✅ ~90% | 대부분의 모듈 완료. 나머지: `react-native`, `flutter` Foundation 파일에 TODO scaffold 잔존 |
| **Level 2** | 🔶 ~60% | Cross-Concern Integration Rules가 `_resolver.md` Step 3.5에 정의됨 (14개 규칙). 최근 `context-injection-rules.md` 및 모든 injection 파일에 enforcement 연결 완료. Scale modifier enforcement 추가됨. 충돌 해결 규칙은 문서화된 쌍에 한정 |
| **Level 3** | 🔶 ~40% | `ai-assistant`, `desktop-app`에 아키타입별 verify/specify 동작 존재. 대부분의 아키타입은 파이프라인 동작 커스터마이징 미비 |
| **Level 4** | ⬜ ~10% | lessons-learned.md 및 injection 파일에 anti-pattern 예시 존재하나, 모듈 조합별 구조화된 패턴 라이브러리 없음 |
| **Level 5** | ⬜ ~15% | skill-feedback.md 접수 프로세스 존재; 65개 이상 SKF 항목 처리 완료. 규칙 효과성 자동 추적은 아직 미구현 |

### Level 1: 모듈 완성도

**목표**: 모든 모듈이 모든 필수 섹션을 채움 (TODO scaffold가 아닌).

- 모든 reverse-spec 모듈의 R1/R3 채우기
- 모든 smart-sdd 인터페이스 모듈의 S0/S1/S5/S8 채우기
- 모든 smart-sdd 관심사 모듈의 S0/S1/S5/S7 채우기
- 모든 아키타입 모듈의 A0–A5 / A0–A1 채우기
- 모든 Foundation 파일의 F0–F4 채우기 (현재: react-native, flutter가 TODO)

**메트릭**: 전체 모듈에서 `(채워진 섹션) / (필수 섹션 총수)`.

### Level 2: 합성 인텔리전스

**목표**: 모듈이 결합될 때 어떻게 상호작용하는지 정의.

- 교차 모듈 상호작용 규칙 (예: "`http-api` + `public-api`가 모두 활성일 때, `public-api`의 S1 rate limit 규칙이 일반 `http-api` 규칙을 오버라이드")
- 충돌 해결 (예: "`auth` 관심사 + `public-api` 아키타입일 때, 세션 인증 프로브보다 API 키/OAuth 프로브 선호")
- 시너지 증폭 (예: "`gui` + `ai-assistant`일 때, 스트리밍 UI 렌더링 프로브 추가")

**메트릭**: 문서화된 교차 모듈 상호작용 규칙 수.

### Level 3: 파이프라인 동작 커스터마이징

**목표**: 모듈이 파이프라인 단계 동작을 수정할 수 있음 (콘텐츠 추가뿐 아니라).

- 아키타입별 verify 동작 (예: `ai-assistant`가 verify Phase 2에 토큰 버짓 검증 추가)
- 아키타입별 specify 동작 (예: `public-api`가 specify 시 OpenAPI 스펙 스텁 생성 요구)
- 조건부 단계 주입 (예: `microservice`가 계약 테스트 단계 추가)

**메트릭**: 모듈별 동작 변형이 있는 파이프라인 단계 수.

### Level 4: 패턴 라이브러리

**목표**: 모듈이 재사용 가능한 구현 패턴을 제공.

- 인터페이스/관심사/아키타입 조합별 코드 스니펫 템플릿
- 공통 결정을 위한 아키텍처 결정 기록 (ADR)
- 수정이 포함된 공통 구현 안티패턴

**메트릭**: 모듈 조합당 문서화된 패턴 수.

### Level 5: 증거 기반 개선

**목표**: 실제 프로젝트 데이터가 모듈 개선을 주도.

- 어떤 S1 규칙이 실제 이슈를 포착 vs. 노이즈를 생산하는지 추적
- 어떤 S5 프로브가 유용한 답변 vs. 혼란을 생산하는지 추적
- 어떤 A1 원칙이 구현 중 실제로 참조되는지 추적
- `skill-feedback.md` 데이터를 모듈 개선에 피드백

**메트릭**: 프로젝트 증거에 기반한 모듈 개선 사이클.

---

## 10. API 서버 개선 예제

이 워크스루는 API 서버 프로젝트에서 `web-api` 인터페이스 + `public-api` 아키타입이 Sophistication Levels을 거쳐 진화하는 과정을 보여줍니다.

### 시작점 (Level 0)

`web-api` 프로필 + `express` Foundation을 가진 프로젝트. 현재:
- `http-api.md` 인터페이스: 기본 S0/S1/S5/S8
- `express.md` Foundation: 전체 F0–F4, 추가 F7
- Archetype 없음 (Archetype: `"none"`)

### Level 1: 모듈 완성

1. 관련 프레임워크의 Foundation 파일이 구현되었는지 확인 (예: `nestjs.md`, `fastapi.md`, `spring-boot.md`)
2. 프로젝트의 sdd-state.md에 `public-api` 아키타입 추가
3. 이제 파이프라인이 로드: `_core → http-api → auth → public-api → scenarios/greenfield`

### Level 2: 합성 인텔리전스 추가

`http-api` + `public-api` 상호작용 정의:
- `public-api` A2 SC 규칙이 `http-api` S1 규칙을 **확장** (대체가 아님)
- 모두 활성일 때: `public-api`의 rate limit SC가 우선
- `auth` 관심사 + `public-api`: 세션 기반에서 API 키/OAuth로 프로브 전환

### Level 3: 파이프라인 커스터마이징

- `specify` 중: `public-api` 활성 시, OpenAPI 스펙 스텁 생성 요구
- `plan` 중: `public-api`가 복잡도 추적에 API 버저닝 결정 추가
- `verify` 중: `public-api`가 계약 테스트 검증 단계 추가
- `implement` 중: `public-api`가 모든 엔드포인트에 rate limit 헤더 요구

### Level 4: 패턴 라이브러리

공통 패턴 문서화:
- "Express + public-api: URL 접두사를 통한 API 버저닝" — 코드 템플릿 + ADR
- "NestJS + public-api: Swagger 자동 생성" — 설정 템플릿
- "express-rate-limit을 이용한 Rate limiting" — 미들웨어 설정 패턴
- "API 키 로테이션" — 구현 패턴

### Level 5: 증거 피드백

3개 이상의 실제 프로젝트에서 `public-api` 실행 후:
- A0 키워드 개선 (어떤 신호가 오탐을 일으켰는가?)
- A2 SC 규칙 조정 (어떤 규칙이 실제 이슈를 포착했는가?)
- A3 프로브 업데이트 (어떤 질문이 유용한 답변을 생산했는가?)
- 실제 프로젝트에서 발견된 새 A1 원칙 추가

---

## 11. Rebuild 아키텍처 — 소스 분석 → Spec-Draft → 파이프라인

rebuild 모드에서 시스템은 소스 앱 충실도를 보존하기 위해 3단계 아키텍처를 따릅니다:

### 단계 1: 소스 분석 (reverse-spec)

reverse-spec은 소스 분석 아티펙트의 **유일한 생산자**입니다:
1. 소스 코드 스캔 (Phase 1-2)
2. **소스 앱 실행** + UI 흐름 기록 (Phase 1.5 — rebuild 필수)
3. Feature 분류 (Phase 3)
4. Feature별 **spec-draft.md** 생성 (Phase 4) — 정확한 UI 컨트롤이 포함된 상세 FR/SC

### 단계 2: Spec 보완 (smart-sdd specify)

speckit-specify가 spec-draft.md를 **seed**로 받아 보완 — 처음부터 생성하지 않음. UI 컨트롤 다운그레이드 감지 (Dropdown → TextInput = BLOCKING).

### 단계 3: 파이프라인 실행 (smart-sdd plan → verify)

파이프라인 아티펙트(`spec.md`, `plan.md`, `tasks.md`)는 **요구사항만** 포함 — 소스 코드 참조 없음. 소스 분석 결과는 같은 Feature 디렉토리의 분석 레이어(`pre-context.md`, `spec-draft.md`)에 유지. **아티펙트 분리**로 spec이 깨끗하고 재사용 가능.

```
소스 코드 → reverse-spec  → specs/_global/          + specs/NNN-feature/
              (분석)          roadmap, registries       pre-context.md (분석)
                              sdd-state.md              spec-draft.md (초기 spec)
                                                      ↓
                           → smart-sdd pipeline     → specs/NNN-feature/
                              (분석 기반 구축)          spec.md (보완, 깨끗)
                                                       plan.md, tasks.md
```

---

## 12. Cross-Reference Map

어떤 파일이 어떤 개념을 다루는지 — 개념을 수정할 때 영향받는 모든 파일을 찾는 데 사용합니다.

| 개념 | 파일 |
|------|------|
| **모듈 로딩 순서** | `smart-sdd/domains/_schema.md` § Loading Order, `smart-sdd/domains/_resolver.md` § Step 3, `reverse-spec/domains/_schema.md` § Loading Order |
| **Section Schema (S0–S9)** | `smart-sdd/domains/_schema.md` § Section Schema |
| **Section Schema (R1–R6)** | `reverse-spec/domains/_schema.md` § Section Schema |
| **Section Schema (A0–A5)** | `smart-sdd/domains/_schema.md` § Archetype Section Schema, `reverse-spec/domains/_schema.md` § Archetype Section Schema |
| **Foundation Schema (F0–F9)** | `reverse-spec/domains/foundations/_foundation-core.md` |
| **F8 Toolchain 명령** | `reverse-spec/domains/foundations/_foundation-core.md` § F8, `smart-sdd/commands/pipeline.md` § Foundation Gate Toolchain Pre-flight, `smart-sdd/commands/verify-phases.md` § Phase 1 |
| **F9 스캔 대상** | `reverse-spec/domains/foundations/_foundation-core.md` § F9, `reverse-spec/commands/analyze.md` § Phase 2 F9 Scan Target Loading |
| **Structure 필드** | `smart-sdd/reference/state-schema.md` § Structure, `smart-sdd/commands/pipeline.md` § Foundation Gate build, `smart-sdd/commands/verify-phases.md` § Phase 1 test/build |
| **State 파일 형식** | `smart-sdd/reference/state-schema.md` |
| **Signal Keywords (S0/A0)** | `smart-sdd/reference/clarity-index.md` § 5, `smart-sdd/domains/_resolver.md` § S0/A0 Aggregation |
| **Constitution 흐름** | `reverse-spec/commands/analyze.md` § Phase 4-1, `reverse-spec/templates/constitution-seed-template.md`, `smart-sdd/commands/pipeline.md` § Phase 0, `smart-sdd/reference/injection/constitution.md` |
| **Profile Resolution** | `smart-sdd/domains/_resolver.md` § Step 2, `smart-sdd/domains/profiles/*.md` |
| **Archetype Resolution** | `smart-sdd/domains/_resolver.md` § Step 2c, `smart-sdd/reference/state-schema.md` § Archetype field |
| **Foundation Resolution** | `smart-sdd/domains/_resolver.md` § Step 2b, `reverse-spec/domains/foundations/_foundation-core.md` § F2 |
| **S3b Lint Detection** | `smart-sdd/domains/_core.md` § S3b (언어별 lint 도구 우선순위), `smart-sdd/commands/verify-phases.md` § Phase 1 |
| **Message queue Concern** | `reverse-spec/domains/concerns/message-queue.md` (R1 감지), `smart-sdd/domains/concerns/message-queue.md` (S0/S1/S5/S7), `smart-sdd/domains/_core.md` § B-3 (MQ-001, MQ-003) |
| **Task worker Concern** | `reverse-spec/domains/concerns/task-worker.md` (R1 감지), `smart-sdd/domains/concerns/task-worker.md` (S0/S1/S5/S7), `smart-sdd/domains/_core.md` § B-3 (TW-002, TW-004) |
| **Foundation 파일 (서버)** | `reverse-spec/domains/foundations/{express,nestjs,fastapi,spring-boot,django,rails,flask,actix-web,go-chi,dotnet,laravel,phoenix,hono}.md` |
| **Foundation 파일 (데스크톱)** | `reverse-spec/domains/foundations/{electron,tauri}.md` |
| **Foundation 파일 (프론트엔드)** | `reverse-spec/domains/foundations/{nextjs,vite-react,solidjs}.md` |
| **Foundation 파일 (런타임)** | `reverse-spec/domains/foundations/{bun}.md` |
| **Foundation 파일 (모바일)** | `reverse-spec/domains/foundations/{react-native,flutter}.md` (TODO scaffold) |
| **S4 데이터 무결성** | `smart-sdd/domains/_core.md` § S4a-S4c (보편), `smart-sdd/domains/scenarios/rebuild.md` § S4d (rebuild 전용), `smart-sdd/domains/concerns/ipc.md` § S7 IPC N-Layer (S4 확장), `smart-sdd/domains/_schema.md` § S4 (스키마 정의) |
| **Verify 파일 분할** | `smart-sdd/commands/verify-phases.md` (허브 + 공통 게이트), `verify-preflight.md` (Phase 0), `verify-build-test.md` (Phase 1), `verify-cross-feature.md` (Phase 2), `verify-sc-verification.md` (Phase 3 WHAT), `verify-sc-rebuild.md` (rebuild 전용), `verify-evidence-update.md` (Evidence + Phase 4-5), `smart-sdd/reference/runtime-verification.md` (Phase 3 HOW) |
| **Pipeline Integrity Guards** | `smart-sdd/reference/pipeline-integrity-guards.md` (7개 guard 패턴), `smart-sdd/reference/injection/implement.md` (Guards 1,2,5,6,7), `smart-sdd/reference/injection/plan.md` (Guard 7), `smart-sdd/reference/injection/analyze.md` (Guard 4), `smart-sdd/commands/verify-phases.md` (Guards 2,3,5,6), `reverse-spec/commands/analyze.md` (Guards 4,7) |
| **Component Tree 흐름** | `reverse-spec/commands/analyze.md` § Phase 2-7c, `reverse-spec/templates/pre-context-template.md` § Component Tree, `smart-sdd/reference/injection/plan.md` § Source Component Mapping, `smart-sdd/reference/injection/implement.md` § Source-First Implementation |
| **FR Element Decomposition** | `smart-sdd/reference/injection/analyze.md` § FR Element Decomposition, `smart-sdd/reference/pipeline-integrity-guards.md` § Guard 4b |
| **Data Round-trip Verification** | `smart-sdd/reference/injection/implement.md` § Data Persistence Round-Trip, `smart-sdd/reference/pipeline-integrity-guards.md` § Guard 2 Level 4 |
| **Data Lifecycle Paradigm Mapping** | `reverse-spec/commands/analyze.md` § Phase 2-7d, `reverse-spec/templates/pre-context-template.md` § Data Lifecycle Patterns, `smart-sdd/reference/injection/plan.md` § Data Lifecycle Mapping, `smart-sdd/reference/injection/implement.md` § Source Reference Injection (lifecycle compliance), `smart-sdd/reference/pipeline-integrity-guards.md` § Guard 7 |
| **Source Reference BLOCKING Gate** | `smart-sdd/reference/injection/implement.md` § Source Reference Injection (rebuild+GUI 시 차단), `smart-sdd/reference/pipeline-integrity-guards.md` § Guard 7 |
| **Polyglot Concern** | `shared/domains/concerns/polyglot.md` (S0/R1), `smart-sdd/domains/concerns/polyglot.md` (S1/S5/S7), `reverse-spec/domains/concerns/polyglot.md` (R1/R3) |
| **Codegen Concern** | `shared/domains/concerns/codegen.md` (S0/R1), `smart-sdd/domains/concerns/codegen.md` (S1/S5/S7), `reverse-spec/domains/concerns/codegen.md` (R1/R3) |
| **Multi-tenancy Concern** | `shared/domains/concerns/multi-tenancy.md` (S0/R1), `smart-sdd/domains/concerns/multi-tenancy.md` (S1/S5/S7), `reverse-spec/domains/concerns/multi-tenancy.md` (R1) |
| **Infra-as-Code Concern** | `shared/domains/concerns/infra-as-code.md` (S0/R1), `smart-sdd/domains/concerns/infra-as-code.md` (S1/S5/S7), `reverse-spec/domains/concerns/infra-as-code.md` (R1) |
| **SDK/Framework Archetype** | `shared/domains/archetypes/sdk-framework.md` (A0), `smart-sdd/domains/archetypes/sdk-framework.md` (A1-A4), `reverse-spec/domains/archetypes/sdk-framework.md` (A0/A1) |
| **Data Science 도메인** | `smart-sdd/domains/data-science.md` (Demo/Parity/Verify), `reverse-spec/domains/data-science.md` (Detection/Classification/Axes/Registries/Boundaries/Tiers/Demo/Parity/Verify) |
| **ML Platform Profile** | `smart-sdd/domains/profiles/ml-platform.md` |
| **SDK Library Profile** | `smart-sdd/domains/profiles/sdk-library.md` |
| **Completion Analysis Report** | `shared/reference/completion-report.md` (템플릿), `reverse-spec/commands/analyze-generate.md` § Phase 4-5 (reverse-spec 생성), `smart-sdd/commands/adopt.md` § Post-Pipeline Adoption Report (adopt 생성) |
| **Multi-language / Language Composition** | `reverse-spec/commands/analyze-scan.md` § 1-2a Language Composition, `reverse-spec/commands/analyze-deep.md` § Multi-Language SBI, `reverse-spec/domains/foundations/_foundation-core.md` § Monorepo Signals, `smart-sdd/reference/state-schema.md` § Foundation multi-language |
| **Scale Detection** | `reverse-spec/commands/analyze-scan.md` § 1-4a Scale Detection, `smart-sdd/domains/_resolver.md` § Step 4 Micro adjustment, `smart-sdd/reference/context-injection-rules.md` § large-project heuristics |
| **Repeating-Pattern Features** | `reverse-spec/commands/analyze-classify.md` § Repeating-Pattern Feature Strategy |
| **Multi-ecosystem Build** | `smart-sdd/commands/adopt.md` § Dependency Install Detection + Multi-Language Build, `smart-sdd/commands/pipeline.md` § Foundation Gate multi-ecosystem |
| **Hardware I/O Concern** | `shared/domains/concerns/hardware-io.md` (S0/R1 감지 스텁) |
| **Foundation 파일 (extension)** | `reverse-spec/domains/foundations/chrome-extension.md` (감지 스텁) |
| **Foundation 파일 (rust)** | `reverse-spec/domains/foundations/rust-cargo.md` (감지 스텁) |
| **Foundation 파일 (svelte)** | `reverse-spec/domains/foundations/svelte.md` (감지 스텁) |
| **Container-as-product SBI** | `reverse-spec/commands/analyze-deep.md` § Infrastructure-as-Product SBI Rule |
| **Instrumentation SDK** | `shared/domains/archetypes/sdk-framework.md` § Instrumentation/Wrapper Variant |
| **Spring/Java Enterprise SBI** | `reverse-spec/commands/analyze-deep.md` § Spring/Java Enterprise SBI Extension (어노테이션 기반 빈 탐색, AOP 프록시, DI 그래프) |
| **Spring Cloud 마이크로서비스** | `shared/domains/archetypes/microservice.md` § Spring Cloud Patterns, `reverse-spec/domains/foundations/spring-boot.md` § F9 Spring Cloud |
| **CQRS/Event Sourcing Concern** | `shared/domains/concerns/cqrs-eventsourcing.md` (S0/R1), `reverse-spec/domains/concerns/cqrs-eventsourcing.md` (R3 Feature 경계, R4 데이터 흐름) |
| **Java SPI (ServiceLoader)** | `shared/domains/concerns/plugin-system.md` § Java SPI |
| **Maven/Gradle 멀티모듈** | `reverse-spec/domains/foundations/_foundation-core.md` § Java/Maven + Java/Gradle Signals, `smart-sdd/reference/state-schema.md` § 모노레포 감지 |
| **Foundation 파일 (Spring Framework)** | `reverse-spec/domains/foundations/spring-framework.md` (non-Boot 감지 스텁) |
| **Foundation 파일 (C/C++ 빌드)** | `reverse-spec/domains/foundations/cmake.md`, `reverse-spec/domains/foundations/makefile.md` |
| **Hexagonal 아키텍처** | `reverse-spec/commands/analyze-classify.md` § Architectural Pattern Detection |
| **Reactive vs Servlet 스택** | `reverse-spec/domains/foundations/spring-boot.md` § SB-BST-06, § F9 reactive 패턴 |
| **Foundation 파일 (멀티 플랫폼)** | `reverse-spec/domains/foundations/{python,go,swift-spm,erlang-otp,nuxt,angular,remix,qt,gtk,symfony,wordpress,android-native}.md` (감지 스텁) |
| **Database engine Archetype** | `shared/domains/archetypes/database-engine.md` (A0 스토리지/쿼리 시그널) |
| **Network server Archetype** | `shared/domains/archetypes/network-server.md` (A0 프록시/LB/게이트웨이 시그널) |
| **Message broker Archetype** | `shared/domains/archetypes/message-broker.md` (A0 브로커/스트리밍 시그널) |
| **Game engine Archetype** | `shared/domains/archetypes/game-engine.md` (A0 엔진/ECS/렌더 시그널) |
| **Browser extension Archetype** | `shared/domains/archetypes/browser-extension.md` (A0 매니페스트/콘텐츠 스크립트 시그널) |
| **Infra tool Archetype** | `shared/domains/archetypes/infra-tool.md` (A0 IaC/재조정 시그널) |
| **Distributed consensus Concern** | `shared/domains/concerns/distributed-consensus.md` (S0/R1), `reverse-spec/domains/concerns/distributed-consensus.md` (R3 프로토콜 추출) |
| **DAG orchestration Concern** | `shared/domains/concerns/dag-orchestration.md` (S0/R1), `reverse-spec/domains/concerns/dag-orchestration.md` (R3 의존성 추출) |
| **ECS Concern** | `shared/domains/concerns/ecs.md` (S0/R1), `reverse-spec/domains/concerns/ecs.md` (R3 컴포넌트 추출) |
| **Wire protocol Concern** | `shared/domains/concerns/wire-protocol.md` (S0/R1), `reverse-spec/domains/concerns/wire-protocol.md` (R3 메시지 추출) |
| **K8s operator Concern** | `shared/domains/concerns/k8s-operator.md` (S0/R1), `reverse-spec/domains/concerns/k8s-operator.md` (R3 CRD/컨트롤러 추출) |
| **R2 프로젝트 유형 (확장)** | `reverse-spec/domains/_core.md` § R2 (`infrastructure`, `desktop`, `platform` 추가) |
| **R5 Feature 경계 휴리스틱** | `reverse-spec/domains/_core.md` § R5 (프로토콜 경계, 워크스페이스/패키지 경계 추가) |
| **Migration Context (shared)** | `shared/domains/contexts/migration.md` — M0 시그널 감지, M1 규모 분류 (Hotfix→Platform), M2 대상 계층, M3 영향 평가, M4 파이프라인 깊이 조절 |
| **Migration Context (reverse-spec)** | `reverse-spec/domains/contexts/migration.md` — R3 마이그레이션 유형별 Feature 경계, R4 의존성/데이터 흐름 추출, R5 범위 추정 |
