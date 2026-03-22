# 세 가지 스킬, 하나의 파이프라인: code-explore, reverse-spec, smart-sdd의 협업

## 4부작 중 2편 — 각 스킬 상세

*1편: 왜 에이전트에게 하네스가 필요한가 — (Medium 1편 링크로 교체)에서 이어집니다*

---

## /code-explore — 빌드 전에 이해하라

대부분의 개발자는 AI 프로젝트를 "X를 만들어줘"로 시작합니다. 하지만 최고의 프로젝트는 "먼저 Y를 이해하자"로 시작합니다.

`/code-explore`는 이 전제 위에 만들어졌습니다. 코드가 아니라, 스펙이 아니라, **문서화된 이해** — 코드베이스에 대한 구조화된 지식을 생산하는 인터랙티브 탐색 도구입니다.

### 동작 방식

**Step 1: Orient** — 코드베이스 스캔

```
/code-explore /path/to/project
```

에이전트가 프로젝트를 스캔하고 `orientation.md`를 생성합니다:
- 프로젝트 유형, 언어, 프레임워크 감지
- 파일 수와 관계가 포함된 모듈 맵
- Domain Profile 도출 (5축)
- 동시성 모델 감지 (async/await, goroutine, 스레드 풀, 액터 모델, 이벤트 루프)
- 탐색 주제 제안

시니어 엔지니어가 코드를 작성하기 전 30분간 코드베이스를 훑어보는 것과 같습니다 — 다만 그 훑어보기가 문서화됩니다.

**Step 2: Trace** — 특정 흐름 추적

```
/code-explore trace "인증 미들웨어가 토큰을 어떻게 검증하는지"
```

에이전트가 진입점에서 완료까지 흐름을 추적합니다:
- 진입점 탐색 (키워드 검색 + import 분석)
- 콜 체인 깊이 우선 추적
- 기록: 소스 위치, 데이터 변환, 분기, API 호출
- Mermaid 시퀀스 다이어그램 생성
- 발견된 엔티티, API, 비즈니스 규칙 기록

각 트레이스는 `specs/explore/traces/`에 독립 문서로 저장됩니다.

#### 5가지 트레이스 전략

모든 흐름이 선형인 것은 아닙니다. 에이전트가 추적 대상에 맞는 전략을 선택합니다:

| 전략 | 언제 사용 | 다이어그램 |
|------|----------|-----------|
| **순차 흐름** | 요청 → 응답 (REST 핸들러) | sequenceDiagram |
| **커넥션 생명주기** | TCP accept → handle → close (서버) | 장기 참가자가 있는 sequenceDiagram |
| **상태 머신** | 온라인/오프라인/부재중 (프레즌스 시스템) | stateDiagram-v2 |
| **Pub/Sub 팬아웃** | 발행 → 브로커 → N 소비자 | 팬아웃이 있는 sequenceDiagram |
| **동시 액터** | 여러 goroutine/task가 병렬 실행 | 스레드 주석이 있는 sequenceDiagram |

WebSocket 프레즌스 시스템은 "흐름"이 아니라 상태 머신입니다. 시퀀스 다이어그램으로 추적하면 오해를 유발합니다.

**Step 3: Synthesis** — Feature 후보로 통합

```
/code-explore synthesis
```

3-5개 트레이스 후, synthesis가 모든 것을 집계합니다:
- 통합 엔티티 맵 (트레이스 간 병합)
- 의존성 그래프가 포함된 통합 API 맵
- 분류된 관찰 (채택할 패턴, 리스크, 미해결 질문)
- 프로젝트를 위한 권장 Domain Profile
- smart-sdd에 투입할 Feature 후보 (C001, C002...)

---

## /reverse-spec — 기존 코드에서 지식 추출

`/reverse-spec`는 code-explore의 수동 프로세스를 자동화한 버전입니다. 흐름을 하나씩 추적하는 대신, 전체 코드베이스에서 **Global Evolution Layer**를 체계적으로 추출합니다.

### 5단계 프로세스

```
Phase 1: 코드 패턴 분석    → 파일 구조, 의존성, 아키텍처
Phase 2: 소스 행동 인벤토리 → 모든 사용자 대면 행동을 카탈로그화
Phase 3: 엔티티 & API 추출  → 데이터 모델, 엔드포인트, 계약
Phase 4: 로드맵 구성       → Feature를 의존성 순서로 그룹화
Phase 5: 헌법 시드         → 프로젝트 수준의 원칙과 제약
```

### 언제 무엇을 쓰는가

```
/code-explore    → 이해하고 싶을 때 (사람이 안내, 인터랙티브)
/reverse-spec    → 추출하고 싶을 때 (자동화, 포괄적)
```

상호 보완적입니다. 코드베이스가 낯설고 직관을 쌓고 싶다면 code-explore를 먼저 사용합니다. 체계적 추출이 준비되면 reverse-spec을 사용합니다.

체이닝도 가능합니다: `/reverse-spec --from-explore`는 트레이스 인사이트를 활용하여 추출 품질을 높입니다.

---

## /smart-sdd — 전체 파이프라인

메인 이벤트입니다. Smart-sdd는 [spec-kit](https://github.com/github/spec-kit) 커맨드를 세 가지로 감쌉니다 — spec-kit 단독으로는 없는 것들:

1. **Feature 간 메모리** (GEL — 레지스트리, 프리컨텍스트, 스텁)
2. **도메인 인식 동작** (규칙이 Interface + Concern + Archetype에 적응)
3. **파이프라인 무결성 가드** (에이전트가 건너뛸 수 없는 HARD STOP)

### 파이프라인

```
init → add → pipeline (Feature별)
                 │
                 ├── specify  → spec.md (무엇을 만들 것인가)
                 ├── plan     → plan.md (어떻게 만들 것인가)
                 ├── tasks    → tasks.md (단계별 구현)
                 ├── implement → 소스 코드 (작업별 런타임 검증 포함)
                 └── verify   → 4단계 검증 (빌드, 테스트, UI, 통합)
```

### add — 상담을 통한 Feature 정의

스마트한 부분입니다. 한 줄짜리 대신 **6단계 구조화된 상담**을 거칩니다:

```
/smart-sdd add "스트리밍 응답이 있는 멀티 프로바이더 LLM 채팅"
```

에이전트가 안내합니다:

1. **입력 파싱** — 요청 이해
2. **관점 갭 식별** — 설명에서 빠진 부분
3. **프로브로 정교화** — 도메인별 질문 (`ai-assistant` vs `microservice`마다 다름)
4. **Brief 초안** — 범위, 액터, 제약의 구조화된 요약
5. **리뷰 HARD STOP** — Brief 승인 또는 수정
6. **아티팩트 생성** — 프리컨텍스트 생성, sdd-state.md에 등록

### add --to — 기존 Feature 보강

```
/smart-sdd add --to F001 "OAuth 프로바이더 지원 추가"
```

새 요구사항이 F001의 프리컨텍스트에 추가됩니다. 기존 SC(Success Criteria)는 **보존**되고 — 새 SC는 `[new]` 태그로 추가됩니다. Feature에 추가할 때 "처음부터 재빌드" 문제를 방지합니다.

### 4단계 검증

검증은 "빌드 되나?"가 아닙니다:

| Phase | 무엇을 체크하는가 | 도구 |
|-------|----------------|------|
| **Phase 1** | 빌드 + TypeScript + Lint | CLI |
| **Phase 2** | 자동 테스트 (유닛 + 통합) | 테스트 러너 |
| **Phase 3** | UI/런타임 검증 | Playwright |
| **Phase 4** | 크로스 Feature 통합 | Playwright + API 프로빙 |

Playwright가 없으면 에이전트가 **사용자에게 위임**합니다 — 건너뛰지 않습니다. "Delegate, Don't Skip" 원칙입니다.

---

## 조합 방법

```
단독:
  /code-explore .                          → 코드베이스 이해
  /smart-sdd init → add → pipeline        → 처음부터 빌드
  /reverse-spec .                          → 코드에서 스펙 추출

체이닝:
  /code-explore → init --from-explore      → 이해 → 빌드
  /reverse-spec → init --from-reverse-spec → 추출 → 재빌드
  adopt → code-explore                     → 문서화 → 심화 이해
  pipeline → code-explore --no-branch      → 빌드 중 조사
```

`--from-explore`와 `--from-reverse-spec` 플래그가 스킬 간 컨텍스트를 전달합니다 — Domain Profile, 엔티티, API, Feature 후보. 핸드오프에서 아무것도 손실되지 않습니다.

---

## 🤖 에이전트를 위한 글 — 스킬 참조 카드

```yaml
code_explore:
  commands:
    orient:
      input: 대상 디렉토리 경로
      output: specs/explore/orientation.md
      detects: [language, framework, project_type, entry_points, concurrency_model, domain_profile]
      interface_types: [gui, http-api, grpc, cli, tui, embedded, mobile, library, data-io, message-consumer]
    trace:
      input: 토픽 문자열 (코드에 대한 자연어 질문)
      output: specs/explore/traces/{NNN}-{slug}.md
      strategies: [sequential, connection_lifecycle, state_machine, pub_sub_fanout, concurrent_actors, error_retry_path]
    synthesis:
      input: specs/explore/traces/의 모든 트레이스
      output: specs/explore/synthesis.md
      produces: [entity_map, api_map, observations, domain_profile, feature_candidates]

smart_sdd:
  pipeline_steps: [specify, plan, tasks, implement, verify]
  per_step_protocol:
    1_assemble: 도메인 모듈 + GEL 아티팩트 + 프리컨텍스트 로드
    2_checkpoint: HARD STOP — 조립된 컨텍스트를 리뷰용으로 표시
    3_execute: 주입된 컨텍스트로 speckit-* 커맨드 실행
    4_review: HARD STOP — 결과 표시, 승인 대기
    5_update: 새 엔티티/API 등록, sdd-state.md 업데이트
  feature_augmentation:
    command: add --to F00N
    sets_status: augmented
    triggers: 다음 speckit-specify 시 SC Preservation 활성화
```

---

*다음 편: **3편 — 아키텍처 딥 다이브** — 400개 이상의 마크다운 파일이 어떻게 컨텍스트 효율적이고 확장 가능한 스킬 시스템이 되는지.*
