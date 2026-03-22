# 세 가지 스킬, 하나의 파이프라인: code-explore, reverse-spec, smart-sdd의 협업

## 4부작 중 2편 — 각 스킬 상세

![2편 커버](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part2.png)

*1편: 왜 에이전트에게 하네스가 필요한가 — (Medium 1편 링크로 교체)에서 이어집니다*

---

## /code-explore — 빌드 전에 이해하라

대부분의 개발자는 "X를 만들어줘"로 시작합니다. 하지만 최고의 프로젝트는 "먼저 Y를 이해하자"로 시작합니다.

`/code-explore`는 코드가 아니라 **문서화된 이해**를 생산하는 인터랙티브 탐색 도구입니다.

---

### 동작 방식

**Step 1: Orient — 코드베이스 스캔**

```
/code-explore /path/to/project
```

에이전트가 프로젝트를 스캔하고 `orientation.md`를 생성합니다:

- 프로젝트 유형, 언어, 프레임워크 감지
- 파일 수와 관계가 포함된 모듈 맵
- Domain Profile 도출 (5축)
- 동시성 모델 감지 (async/await, goroutine, 스레드 풀, 액터 모델, 이벤트 루프)
- 탐색 주제 제안

시니어 엔지니어가 30분간 코드를 훑어보는 것 — 다만 문서화됩니다.

**Step 2: Trace — 특정 흐름 추적**

```
/code-explore trace "인증 미들웨어가 토큰을 어떻게 검증하는지"
```

에이전트가 진입점에서 완료까지 추적하고, Mermaid 시퀀스 다이어그램과 함께 엔티티, API, 비즈니스 규칙을 기록합니다.

**Step 3: Synthesis — Feature 후보로 통합**

```
/code-explore synthesis
```

3–5개 트레이스 후, 통합 엔티티/API 맵, 분류된 관찰, 권장 Domain Profile, Feature 후보를 생성합니다.

---

### 5가지 트레이스 전략

**순차 흐름** — 요청 → 응답. 시퀀스 다이어그램.

**커넥션 생명주기** — TCP accept → handle → close. 장기 커넥션 표시.

**상태 머신** — 온라인/오프라인/부재중. 시퀀스 대신 상태 다이어그램.

**Pub/Sub 팬아웃** — 발행 → 브로커 → N 소비자. 양쪽 모두 추적.

**동시 액터** — 여러 goroutine/task 병렬 실행. 스레드별 주석.

WebSocket 프레즌스 시스템은 "흐름"이 아니라 상태 머신입니다. 시퀀스 다이어그램으로 추적하면 오해를 유발합니다.

---

## /reverse-spec — 기존 코드에서 지식 추출

code-explore의 수동 프로세스를 자동화한 버전입니다. 5단계로 전체 코드베이스에서 Global Evolution Layer를 추출합니다:

1. **코드 패턴 분석** — 파일 구조, 의존성, 아키텍처
2. **소스 행동 인벤토리** — 모든 사용자 대면 행동을 카탈로그화
3. **엔티티 & API 추출** — 데이터 모델, 엔드포인트, 계약
4. **로드맵 구성** — Feature를 의존성 순서로 그룹화
5. **헌법 시드** — 프로젝트 수준의 원칙과 제약

**언제 무엇을 쓰는가:**

- `/code-explore` → *이해*하고 싶을 때 (사람이 안내, 인터랙티브)
- `/reverse-spec` → *추출*하고 싶을 때 (자동화, 포괄적)

상호 보완적입니다. 체이닝도 가능: `/reverse-spec --from-explore`

---

## /smart-sdd — 전체 파이프라인

spec-kit 커맨드를 세 가지로 감쌉니다:

1. **Feature 간 메모리** (GEL — 레지스트리, 프리컨텍스트, 스텁)
2. **도메인 인식 동작** (규칙이 Interface + Concern + Archetype에 적응)
3. **파이프라인 무결성 가드** (에이전트가 건너뛸 수 없는 HARD STOP)

---

### 파이프라인

`init` → `add` → `pipeline` (Feature별)

**specify** (spec.md) → **plan** (plan.md) → **tasks** (tasks.md) → **implement** (소스 코드) → **verify** (4단계 검증)

### add — 6단계 구조화된 상담

1. **입력 파싱** → 2. **관점 갭 식별** → 3. **프로브로 정교화** → 4. **Brief 초안** → 5. **리뷰 HARD STOP** → 6. **아티팩트 생성**

### 4단계 검증

**Phase 1** — 빌드 + TypeScript + Lint

**Phase 2** — 자동 테스트 (유닛 + 통합)

**Phase 3** — UI/런타임 검증 (Playwright)

**Phase 4** — 크로스 Feature 통합

Playwright가 없으면 **사용자에게 위임** — 건너뛰지 않습니다. "Delegate, Don't Skip" 원칙.

### add --to — 기존 Feature 보강

```
/smart-sdd add --to F001 "OAuth 프로바이더 지원 추가"
```

기존 SC는 `[preserved]`, 새 SC는 `[new]` 태그. "처음부터 재빌드" 문제 방지.

---

## 조합 방법

**단독:** code-explore, smart-sdd, reverse-spec 각각 독립 사용 가능

**체이닝:** `--from-explore`, `--from-reverse-spec` 플래그로 스킬 간 컨텍스트 전달. 핸드오프에서 아무것도 손실되지 않습니다.

---

## 🤖 에이전트를 위한 글 — 스킬 참조 카드

```
code_explore:
  orient: 언어, 프레임워크, 프로젝트 유형, 진입점, 동시성 모델 감지
  trace: 5 전략 (순차, 커넥션 생명주기, 상태 머신, pub/sub, 동시 액터)
  synthesis: 엔티티 맵, API 맵, 관찰, Domain Profile, Feature 후보

smart_sdd:
  pipeline: specify → plan → tasks → implement → verify
  per_step: 컨텍스트 조립 → HARD STOP → 실행 → 리뷰 HARD STOP → 상태 업데이트
  verify: phase_1 (빌드) → phase_2 (테스트) → phase_3 (UI) → phase_4 (통합)
  augmentation: add --to → augmented 상태 → SC Preservation
```

---

*다음 편: **3편 — 아키텍처 딥 다이브** — 400개 이상의 마크다운 파일이 어떻게 스킬 시스템이 되는지.*
