# 세 가지 스킬, 하나의 파이프라인: code-explore, reverse-spec, smart-sdd의 협업

## 4부작 중 2편 — 각 스킬 상세

![2편 커버](https://raw.githubusercontent.com/coolhero/spec-kit-skills/main/articles/medium/part2.png)

*[1편: 왜 에이전트에게 하네스가 필요한가](https://medium.com/@thejihoonchoi/taming-the-ai-coder-why-your-agent-needs-a-harness-not-just-a-prompt-0869fa51da34)에서 이어집니다*

---

## /code-explore — 빌드 전에 이해하라

대부분의 개발자는 AI 프로젝트를 "X를 만들어줘"로 시작합니다. 하지만 최고의 프로젝트는 "먼저 Y를 이해하자"로 시작합니다.

이건 새로운 아이디어가 아닙니다. 모든 시니어 엔지니어가 하는 일이죠 — 코드를 읽고, 다이어그램을 그리고, 질문을 던진 후에야 한 줄의 코드를 씁니다. 그런데 AI 에이전트를 쓸 때는 이 단계를 건너뜁니다. 바로 "만들어"로 넘어가고 에이전트가 알아서 컨텍스트를 파악하길 바라죠.

`/code-explore`는 이 "먼저 이해하기" 규율을 되살립니다. 단, 한 가지 차이가 있습니다: 에이전트가 학습한 모든 것이 영구적인 파일로 문서화되고, 그 파일이 빌드 파이프라인에 직접 투입됩니다.

---

## Orient: 코드베이스와의 첫 30분

```
/code-explore /path/to/project
```

이 명령을 실행하면 에이전트가 전체 코드베이스를 체계적으로 스캔합니다. 대충 훑는 게 아니라, `orientation.md`를 생산하는 구조화된 분석입니다:

**감지하는 것들:**

- **언어 & 프레임워크** — 프로젝트 마커(package.json, go.mod, Cargo.toml, pyproject.toml, pom.xml, CMakeLists.txt)에서 감지
- **프로젝트 유형** — 단순히 "웹앱인가 CLI인가"를 넘어섭니다. TCP 서버, UDP 서버, gRPC 서비스, 메시지 컨슈머, API 게이트웨이, WebSocket 서버, TUI 애플리케이션, 임베디드 펌웨어 등을 인식합니다
- **진입점** — `main.go`나 `index.ts`만이 아닙니다. accept 루프, 리스너 바인딩, 이벤트 핸들러, `@KafkaListener` 어노테이션, `.proto` 서비스 정의, 심지어 RTOS 태스크 생성까지 서버 특화 패턴을 감지합니다
- **동시성 모델** — 서버 프로그램에서 특히 중요합니다. async/await (tokio, asyncio), goroutine, 스레드 풀, 액터 모델 (GenServer, Akka), 이벤트 루프 (Node.js, libuv) 중 어떤 것을 사용하는지 식별합니다. 동시성 모델을 이해해야 이후의 모든 트레이스를 올바르게 읽을 수 있습니다
- **모듈 맵** — 파일 수, import 관계, 추론된 목적 포함
- **Domain Profile** — 5개 축 전체. 나중에 빌드 파이프라인에서 사용하는 것과 동일한 어휘입니다

**실제로 어떻게 보이는가:**

오픈소스 AI 코딩 어시스턴트를 탐색한다고 가정해봅시다. Orient는 이런 결과를 만들어냅니다:

```
📦 Project: opencode (Go / Bubble Tea TUI)
   Type: Desktop TUI application
   Entry: cmd/main.go → internal/app/app.go
   Size: 847 files, 42 directories
   Concurrency: goroutines (event-driven TUI + background tasks)

Detected Domain Profile:
  Interface: gui (TUI), cli
  Concern: async-state, ipc, external-sdk, realtime
  Archetype: ai-assistant
  Foundation: Go stdlib + Bubble Tea
  Scale: production, small-team
```

그런 다음 에이전트가 중요도 순으로 5~10개의 탐색 주제를 제안합니다: 진입점 먼저, 핵심 비즈니스 로직 다음, 인프라 마지막.

**왜 중요한가:** Orient 없이는 모든 트레이스가 백지에서 시작합니다 — 에이전트가 키워드를 맹목적으로 grep하죠. Orient가 있으면 에이전트가 모듈 맵을 알고, 동시성 모델을 알고, 어디를 봐야 하는지 압니다. 트레이스가 3~5배 빨라지고 정확해집니다.

---

## Trace: 실행 흐름 따라가기

```
/code-explore trace "컨텍스트 윈도우 관리가 어떻게 동작하는지"
```

여기서 code-explore가 진가를 발휘합니다. 에이전트가 키워드만 검색하는 게 아니라, 진입점에서 완료까지 전체 실행 경로를 따라가며 모든 것을 문서화합니다.

### 트레이스가 실제로 동작하는 방식

1. **진입점 탐색** — 에이전트가 Domain Profile을 활용해 검색 우선순위를 정합니다. `ai-assistant` 아키타입이면 토큰 카운팅, 컨텍스트 조립, 메시지 자르기를 우선 찾습니다. `gui` 인터페이스면 컴포넌트 파일과 상태 관리를 우선시합니다. 후보 진입점을 제시하고 확인을 요청합니다.

2. **깊이 우선 탐색** — 진입점에서부터 에이전트가 각 함수를 읽고, 다른 함수로의 호출을 따라가고, 데이터가 각 단계에서 어떻게 변환되는지 추적하고, 흐름이 분기하는 지점(에러 경로, 조건)을 기록하며, 프레임워크 경계에서 멈춥니다.

3. **구조화된 출력** — 모든 트레이스는 다음을 포함하는 문서를 생산합니다:
   - **요약** (이 흐름이 무엇을 하고 왜 중요한지 2~3문장)
   - **Mermaid 시퀀스 다이어그램** — 컴포넌트 간 상호작용
   - **흐름 테이블** — 각 단계를 소스 파일:라인, 동작, 데이터 변환에 매핑
   - **핵심 소스 스니펫** — 중요한 실제 코드, 인라인 코멘트 포함
   - **발견된 엔티티** (필드와 관계가 있는 데이터 구조)
   - **발견된 API** (계약이 있는 엔드포인트)
   - **비즈니스 규칙** (소스 증거가 있는 도메인 로직)
   - **관찰** — 아이콘 태그: 💡 채택할 패턴, ❓ 열린 질문, ⚠️ 우려, 🔧 개선 아이디어, 🔒 보안 고려사항, 🧪 테스트 갭, 📊 성능 우려

### 다섯 가지 흐름에 대한 다섯 가지 전략

트레이스가 다양한 코드베이스에서 진정으로 유용한 이유가 여기 있습니다. 모든 코드가 요청에서 응답으로 선형적으로 흐르지는 않습니다. 에이전트가 적절한 전략을 선택합니다:

**전략 1 — 순차 흐름.** 전형적인 요청 → 핸들러 → 서비스 → 리포지토리 → 응답. REST API, CLI 명령, 단순 함수 체인에 사용. 표준 시퀀스 다이어그램을 생산합니다.

**전략 2 — 커넥션 생명주기.** TCP 서버, WebSocket 서버, gRPC 서비스용. 전체 생명주기를 추적합니다: `accept` → `handshake/upgrade` → `read request` → `parse protocol` → `dispatch` → `handle` → `write response` → `close/disconnect`. 핵심 차이점: 프로토콜 프레이밍 레이어(원시 바이트가 메시지가 되는 과정)를 포함하고, 커넥션을 다이어그램의 장기 참여자로 표시합니다.

왜 중요한가: "Redis 명령이 어떻게 실행되는지" 물었을 때 트레이스가 `parseCommand()`에서 시작하면 이야기의 절반을 놓치는 겁니다. 커넥션 생명주기 전략은 `accept()`에서 시작해서 RESP 프로토콜 파싱을 거칩니다 — 네트워크 서버에서 프로토콜이 곧 비즈니스 로직이니까요.

**전략 3 — 상태 머신.** 프레즌스 시스템, 커넥션 상태 관리, 리컨실러 루프, 워크플로우 엔진용. 시퀀스 다이어그램 대신 **상태 다이어그램**을 생산합니다:

```
[*] → Connected (accept)
Connected → Authenticated (auth success)
Connected → Disconnected (auth fail / timeout)
Authenticated → Subscribed (subscribe to topic)
Subscribed → Disconnected (close / heartbeat timeout)
```

각 전환이 소스 코드 위치에 매핑됩니다. 상태 기반 로직에는 선형 트레이스보다 극적으로 유용합니다. 온라인/오프라인/부재중 상태를 가진 WebSocket 프레즌스 시스템은 시퀀스가 아니라 상태 머신입니다 — 선형적으로 추적하면 오해를 유발합니다.

**전략 4 — Pub/Sub 팬아웃.** 메시지 브로커, 이벤트 시스템, 브로드캐스트 패턴용. 양쪽을 모두 추적합니다: 발행 경로와 소비/전달 경로, 팬아웃을 시각화합니다. 메시지가 브로커에 들어가서 영속화되고, N개의 컨슈머에게 확인 처리와 함께 전달되는 과정을 볼 수 있습니다.

**전략 5 — 동시 액터.** 여러 goroutine, 태스크, 스레드가 병렬로 실행되는 시스템용. 각 단계에 어떤 액터에서 실행되는지 주석이 붙습니다. 다이어그램이 병렬 참여자들과 명확한 핸드오프 지점을 보여줍니다:

```
AcceptLoop → spawns ConnHandler per connection
ConnHandler → borrows from PoolManager
PoolManager → returns pooled connection
ConnHandler → reads/writes independently
```

### 프로토콜 경계 가이드

미묘하지만 결정적인 개선점입니다. 전통적인 트레이스는 "외부 API 호출"이나 "데이터베이스 연산"에서 멈춥니다 — 그게 경계니까요. 하지만 네트워크 프로그램에서는 **네트워크 자체가 핵심 관심사**입니다. `socket.write()`에서 멈추는 것은 웹 앱에서 `repository.save()`에서 멈추는 것과 같습니다 — 사용자는 그 다음에 무슨 일이 일어나는지 보고 싶어합니다.

서버 프로그램의 경우, 트레이스는 소켓 경계에서 멈추지 않습니다. 어떤 바이트/메시지가 전송되고, 무엇이 돌아올 것으로 예상되며, 프로토콜 수준에서 에러가 어떻게 처리되는지를 문서화합니다. 서비스 간 호출은 `[cross-service: ServiceName.Method()]`로 요청/응답 계약과 함께 문서화됩니다.

프록시와 게이트웨이의 경우, 설정 파일(라우팅 규칙, 업스트림 정의)도 트레이스의 일부로 읽고 문서화됩니다 — 설정이 곧 로직이니까요.

---

## Synthesis: 이해에서 행동으로

```
/code-explore synthesis
```

3~5개의 트레이스 후에 상당한 지식이 축적됩니다. Synthesis는 이를 실행 가능한 핸드오프 문서로 집약합니다.

### Synthesis가 실제로 생산하는 것

**통합 엔티티 맵** — 모든 트레이스에서 발견된 엔티티를 필드 합집합으로 병합하고, 타입 충돌을 표시하며, 관계를 보여주는 Mermaid ER 다이어그램을 생성합니다. 트레이스 1에서 `User { id, name, email }`을 발견하고 트레이스 3에서 `User { id, role, avatar }`를 발견했다면, synthesis는 소스 트레이스 참조와 함께 `User { id, name, email, role, avatar }`를 생산합니다.

**통합 API 맵** — 발견된 모든 엔드포인트를 어떤 API가 어떤 다른 API를 호출하는지 보여주는 의존성 그래프와 함께. 멀티 서비스 아키텍처에서 특히 가치 있습니다.

**서버 컴포넌트 맵** (서버/네트워크 프로젝트용) — 레이어 기반 아키텍처 뷰:

- **Listener** — TCP accept loop on :8080 (`cmd/server.go`)
- **Protocol** — Redis RESP parser (`protocol/resp.go`)
- **Middleware** — Auth → Rate limiter → Logger (`middleware/`)
- **Handler** — GET, SET, DEL commands (`handler/`)
- **Storage** — In-memory store + AOF persistence (`storage/`)
- **Background** — Key expiration goroutine, AOF compaction (`background/`)

이 레이어 뷰는 다른 도구가 생산하지 않는 것입니다 — 서버의 아키텍처를 Feature 경계로 직접 변환할 수 있는 방식으로 매핑합니다.

**네트워크 토폴로지** (멀티 서비스 시스템용) — 서비스 간 통신을 보여주는 Mermaid 다이어그램: 어떤 프로토콜, 어떤 방향, 어떤 의존성.

**축적된 인사이트** — 아이콘 유형별로 분류. 모든 트레이스에서 나온 💡 패턴, 🔧 개선점, ❓ 질문, ⚠️ 리스크를 소스 참조와 함께. 개별 관찰에서 전체 그림이 드러나는 지점입니다.

**권장 Domain Profile** — 소스 프로젝트의 프로필에 여러분의 차별화 결정(🔧 관찰)을 더한 것. 트레이스 4에서 "TUI를 Web으로 변경"이라고 기록했다면, synthesis는 이를 대상 프로젝트의 Interface 축 변경으로 포착합니다.

**Feature 후보** — 모듈 클러스터링, 엔티티 소유권, API 매핑을 기반으로 그룹화됩니다. 각 후보(C001, C002...)는 기반이 되는 모듈, 엔티티, API, 트레이스를 나열합니다. 이것이 `/smart-sdd add --from-explore`에 직접 투입됩니다.

### "나라면 다르게 했을 것" 패턴

리빌드 프로젝트에서 synthesis의 가장 가치 있는 섹션입니다. 모든 트레이스가 개선 관찰(🔧)을 생성합니다. Synthesis는 이를 명시적인 결정 테이블로 수집합니다:

- C001 auth — 소스: 파일 기반 세션 → 내 설계: Redis 캐시가 있는 데이터베이스 기반
- C002 context — 소스: 하드코딩된 128k 토큰 제한 → 내 설계: 프로바이더별 설정 가능
- C003 tools — 소스: 동기식 도구 실행 → 내 설계: 타임아웃 + 취소가 있는 비동기

이 결정들이 빌드 파이프라인으로 이어집니다. smart-sdd의 `speckit-specify`가 실행될 때 이 결정을 보고, 소스의 것이 아니라 여러분의 설계 선택을 반영하는 SC를 생성합니다.

---

## /reverse-spec — 자동화된 지식 추출

code-explore가 시니어 엔지니어가 코드를 주의 깊게 읽는 것이라면, reverse-spec는 팀 전체가 종합 감사를 하는 것입니다. 5단계로 코드베이스에서 **Global Evolution Layer**를 체계적으로 추출합니다.

### Phase 1: 코드 패턴 분석

전체 파일 구조를 스캔하고, 의존성 그래프를 분석하며, 아키텍처 패턴을 식별합니다. 코드베이스의 구조적 맵을 생산합니다 — 어떤 모듈이 존재하고, 어떻게 관련되며, 어떤 프레임워크와 라이브러리를 사용하는지.

### Phase 2: 소스 행동 인벤토리 (SBI)

reverse-spec를 독특하게 만드는 단계입니다. 에이전트가 코드베이스의 모든 사용자 대면 행동을 카탈로그화합니다. "인증 모듈이 있다" 수준이 아니라:

- B001: 사용자가 이메일과 비밀번호로 로그인할 수 있다
- B002: 로그인 실패 시 1초 후 인라인 에러 메시지를 표시한다
- B003: 3회 실패 시 15분 잠금이 발동된다
- B004: 세션 토큰이 httpOnly 쿠키에 저장되고, 24시간 후 만료된다

각 행동 항목은 소스 코드 위치에 매핑되고, 나중에 SDD 파이프라인의 Feature Requirements (FR-###)에 매핑되는 행동 ID (B###)를 받습니다.

리빌드 프로젝트에서 이것이 결정적인 이유: 재구축할 때 기능을 잃지 않도록 보장합니다. 소스에 47개의 행동이 있다면, 재구축도 47개 전부를 커버하거나 — 어떤 것이 의도적으로 제외되었는지 명시적으로 문서화해야 합니다.

### Phase 3: 엔티티 & API 추출

`entity-registry.md`와 `api-registry.md`를 생산합니다 — smart-sdd의 파이프라인이 사용하는 것과 같은 포맷입니다. 엔티티에는 필드, 타입, 관계, 검증 규칙이 포함됩니다. API에는 메서드, 경로, 요청/응답 스키마, 인증 요구사항, 에러 응답이 포함됩니다.

### Phase 4: 로드맵 구성

행동을 Feature로 그룹화하고, 의존성에 따라 순서를 정하며, `roadmap.md`를 생산합니다. 순서가 중요합니다 — Feature 2가 Feature 1의 User 엔티티에 의존하므로, Feature 1을 먼저 빌드해야 합니다. 에이전트가 추측하는 게 아니라, 실제 import 의존성과 데이터 흐름을 분석합니다.

### Phase 5: 헌법 시드

코드베이스 패턴에서 프로젝트 수준의 아키텍처 원칙을 추출합니다. 소스가 일관되게 프로바이더 추상화 패턴을 사용한다면, 헌법은 "Provider Agnosticism"을 지도 원칙으로 기록합니다. 이 원칙들이 전체 재구축을 지배하는 `constitution.md` 파일의 시드가 됩니다.

### code-explore vs reverse-spec — 언제 무엇을

- **code-explore**: 코드베이스에 익숙하지 않고 감을 잡고 싶을 때. 인터랙티브하고, 사람이 안내하며, 선택적. 무엇을 추적할지 여러분이 선택합니다.
- **reverse-spec**: 코드베이스를 충분히 알거나 (혹은 code-explore가 개요를 줬거나) 포괄적 추출이 필요할 때. 자동화되고, 체계적이며, 빠짐없이. 모든 것을 카탈로그화합니다.

아름답게 체이닝됩니다: `/code-explore`로 먼저 이해한 다음, `/reverse-spec --from-explore`로 인간의 통찰이 반영된 상태에서 추출합니다.

---

## /smart-sdd — 이해가 코드가 되는 곳

이것이 메인 이벤트입니다 — Feature 간 메모리를 갖춘 완전한 Specification-Driven Development 파이프라인.

### smart-sdd가 해결하는 문제

spec-kit 자체는 강력합니다: 스펙을 주면 플랜, 태스크, 코드를 생성합니다. 하지만 spec-kit은 한 번에 하나의 Feature를 처리하며 다른 Feature에 대한 기억이 없습니다. Feature 3은 Feature 1이 User 엔티티를 만들었다는 것을 모릅니다. Feature 5는 Feature 2가 API 응답 포맷을 정의했다는 것을 모릅니다.

smart-sdd는 spec-kit을 세 가지로 감쌉니다:
1. **Global Evolution Layer** — Feature 간 정보를 전달하는 레지스트리, 프리컨텍스트, 스텁
2. **Domain Profile** — 프로젝트 유형에 맞게 적응하는 규칙
3. **Pipeline Integrity Guards** — 무언가 잘못되었을 때 파이프라인 진행을 막는 7개의 차단 검사

### init: 프로젝트 정체성

```
/smart-sdd init "프로바이더 추상화를 갖춘 AI 기반 지식 베이스"
```

`sdd-state.md`를 생성합니다 — 프로젝트의 신분증입니다. 이 파일이 추적하는 것:
- 프로젝트 이름과 설명
- Domain Profile (자동 감지 또는 `--profile`로 수동 설정)
- Artifact 언어 (`--lang`으로 en/ko/ja)
- 활성 Tier (어떤 Feature가 범위 안에 있는지)
- Feature 진행 테이블 (각 Feature가 어떤 단계에 있는지)

모든 다운스트림이 이 파일을 읽습니다. 프로젝트 상태의 단일 진실 출처입니다.

### add: 6단계 구조화된 상담

대부분의 가치가 여기에 있습니다. "인증 추가"가 아니라, 모호한 아이디어를 정확한 Feature 정의로 바꾸는 구조화된 상담을 거칩니다.

**Step 1 — 입력 파싱.** 에이전트가 무엇을 요청하는지 파악합니다. 텍스트("스트리밍이 가능한 멀티 프로바이더 LLM 채팅"), 파일(요구사항 문서, 설계 스펙), 또는 둘의 조합을 제공할 수 있습니다.

**Step 2 — 관점 갭 식별.** 에이전트가 체크리스트 대비 입력을 분석합니다: 액터가 정의되었는가? 에러 경로는? 데이터 모델은? 다른 Feature와의 의존성은? 인터랙션 패턴은? 각 갭이 질문이 됩니다.

**Step 3 — 도메인 특화 프로브로 정교화.** Domain Profile이 활성화되는 지점입니다. 프로젝트가 `ai-assistant`면 이런 프로브가 나옵니다: "스트리밍 중단은 어떻게 동작해야 하나?" "프로바이더가 Rate Limit을 걸면 어떻게 되나?" "컨텍스트 윈도우 관리는 대화별인가 전역인가?" `microservice`면 완전히 다른 프로브: "서비스 경계는?" "업스트림 실패는 어떻게 처리하나?" "재시도 정책은?"

프로브 질문은 도메인 모듈에서 옵니다 — 범용적이지 않습니다. 각 프로젝트 유형에서 무엇이 중요한지에 대한 실제 전문 지식을 인코딩합니다.

**Step 4 — Brief 초안.** 에이전트가 여러분의 답변을 구조화된 Brief로 조립합니다: 범위(in/out), 권한이 있는 액터, 엔티티 정의, 시간적 흐름이 있는 인터랙션 패턴(로딩 → 스트리밍 → 완료 → 에러 → 재시도), 에러 시나리오, Feature 간 의존성, 비기능 요구사항.

**Step 5 — 리뷰 HARD STOP.** 에이전트가 Brief를 제시하고 명시적 승인을 기다립니다. 수정, 추가, 제거 가능. 이것은 차단 게이트 — 파이프라인이 여러분의 응답 없이는 말 그대로 진행할 수 없습니다.

**Step 6 — 아티팩트 생성.** 프리컨텍스트가 생성되고, Feature가 sdd-state.md에 등록되며, 엔티티와 API가 Global Evolution Layer에 등록됩니다.

### pipeline: Feature별 빌드

```
/smart-sdd pipeline F001
```

하나의 Feature에 대해 전체 파이프라인을 실행합니다: **specify → plan → tasks → implement → verify.**

각 단계에서 4단계 프로토콜이 실행됩니다:

1. **Assemble** — Domain Profile 모듈, GEL 아티팩트, 프리컨텍스트를 로드합니다. Feature 간 메모리가 작동하는 지점입니다. F001이 User 엔티티를 만들었다면, F002의 specify 단계는 엔티티 레지스트리에서 이를 보고 기존 엔티티를 참조하는 SC를 생성합니다.

2. **Checkpoint (HARD STOP)** — 조립된 컨텍스트를 보여줍니다. 승인을 기다립니다.

3. **Execute** — 주입된 컨텍스트로 spec-kit 커맨드를 실행합니다. injection 파일이 어떤 도메인 규칙이 적용되는지 오케스트레이션합니다 — `gui` vs `cli` vs `grpc`에 따라 다른 규칙, `mvp` vs `production` 스케일에 따라 다른 깊이.

4. **Review (HARD STOP)** — 생성된 아티팩트를 읽고, 포맷된 리뷰를 표시하며, 승인을 기다립니다. 에이전트는 명시적 "승인" 또는 "수정" 없이 진행할 수 없습니다.

5. **Update** — 새 엔티티/API를 GEL에 등록하고, sdd-state.md를 업데이트합니다.

### 4단계 검증

검증은 "빌드가 되는가?"가 아닙니다. 이것은 우리가 가장 먼저 발견한 실패 패턴이었습니다 — 빌드 통과는 Feature가 실제로 동작하는지에 대해 아무것도 말해주지 않습니다.

**Phase 1 — 빌드 + TypeScript + Lint.** 기본선. 이것이 실패하면 다른 것은 실행되지 않습니다.

**Phase 2 — 자동 테스트.** 유닛 테스트와 통합 테스트. 테스트가 실패하면 에이전트가 진행 전에 수정합니다 — 테스트를 삭제해서가 아니라, 코드를 고침으로써.

**Phase 3 — UI/런타임 검증.** spec-kit-skills가 다른 모든 도구와 갈라지는 지점입니다. 에이전트가 Playwright(데스크톱 앱은 Electron 특화 프로토콜)를 사용해 실제 애플리케이션을 실행하고, 실행 중인 UI 대비 각 Success Criterion을 검증합니다. "로그인 컴포넌트가 렌더링되는가?"가 아니라 "실제로 비밀번호를 입력하고, 제출을 클릭하고, 대시보드를 보고, 올바른 사용자 이름을 볼 수 있는가?"

Playwright를 사용할 수 없으면 에이전트가 **사용자에게 위임**합니다: "로그인 버튼을 클릭해주세요. 대시보드가 사용자 이름과 함께 나타나나요?" 건너뛰지 않습니다. 이것이 "Delegate, Don't Skip" 원칙입니다.

**Phase 4 — Feature 간 통합.** Feature들이 함께 동작하는지 검증합니다. Feature 2의 설정 페이지가 실제로 Feature 1의 동작을 변경하는지. API 게이트웨이가 Feature 3과 Feature 4의 엔드포인트로 올바르게 라우팅하는지. 가장 빈번한 깨짐 패턴 중 하나인 Feature 간 통합 계약 실패를 잡아냅니다.

### add --to: 파괴 없이 보강하기

```
/smart-sdd add --to F001 "OAuth 프로바이더 지원 추가"
```

이것은 가장 어려웠던 문제 중 하나였습니다. 기존 Feature에 요구사항을 추가할 때, 단순한 접근은 처음부터 재스펙하는 것입니다. 하지만 그러면 이전에 승인된 모든 Success Criteria가 사라집니다.

`add --to` 플로우는 SC Preservation으로 이를 해결합니다:
- 새 요구사항이 프리컨텍스트의 `## Augmented Requirements` 아래에 추가됩니다
- Feature 상태가 sdd-state.md에서 `augmented`로 설정됩니다
- `speckit-specify`가 다음에 실행될 때 `augmented` 상태를 감지하고 SC Preservation을 활성화합니다
- 기존 SC는 `[preserved]` 태그 — 제거하거나 수정할 수 없습니다
- 새 SC는 `[new]` 태그 — 이것만 새로 생성됩니다
- 새 요구사항이 기존 SC와 명시적으로 충돌하면 `[updated]`와 설명이 붙습니다
- 실행 후 검사: SC 수가 감소하지 않았는지, preserved SC가 원본과 일치하는지, 모든 augmented 요구사항에 최소 하나의 새 SC가 있는지 확인

---

## 세 스킬의 조합

세 스킬은 독립적으로 또는 함께 사용하도록 설계되었습니다. 조합 패턴은 다음과 같습니다:

**그린필드** (처음부터 새 프로젝트):
```
/smart-sdd init → add → pipeline
```

**탐색 → 빌드** (기존 코드를 이해한 후 영감을 받아 빌드):
```
/code-explore /path/to/reference-project
/code-explore trace "인증 흐름"
/code-explore trace "데이터 파이프라인"
/code-explore synthesis
/smart-sdd init --from-explore
/smart-sdd add --from-explore    # Feature 후보가 Brief가 됨
/smart-sdd pipeline F001
```

**리빌드** (기존 앱을 처음부터 재작성):
```
/reverse-spec /path/to/legacy-app
/smart-sdd init --from-reverse-spec
/smart-sdd pipeline              # 의존성 순서로 모든 Feature 빌드
```

**어답션** (재작성 없이 기존 코드에 SDD 문서 추가):
```
/smart-sdd adopt /path/to/existing-app
```

**파이프라인 중간 조사** (뭔가 잘못되었을 때 소스를 더 이해해야 할 때):
```
/smart-sdd pipeline F003         # 구현에서 막힘
/code-explore . --no-branch      # 파이프라인을 방해하지 않고 탐색
/code-explore trace "원본이 이 엣지 케이스를 어떻게 처리하는지"
# 새 이해로 파이프라인 계속
```

`--from-explore`와 `--from-reverse-spec` 플래그가 컨텍스트를 매끄럽게 전달합니다 — Domain Profile, 엔티티, API, Feature 후보. 핸드오프에서 손실이 없습니다.

---

## 🤖 에이전트를 위한 글 — 스킬 참조 카드

```
code_explore:
  orient:
    감지 대상: 언어, 프레임워크, 프로젝트 유형, 진입점, 동시성 모델, Domain Profile
    인터페이스 유형: gui, http-api, grpc, cli, tui, embedded, mobile, library, data-io, message-consumer
    출력: specs/explore/orientation.md

  trace:
    전략:
      순차: 요청 → 응답 (REST, CLI)
      커넥션 생명주기: accept → handshake → request → response → close (TCP, WS, gRPC)
      상태 머신: 상태 + 전환을 소스에 매핑 (프레즌스, 리컨실러)
      pub/sub 팬아웃: 발행 경로 + 소비 경로 + 팬아웃 (브로커, 이벤트)
      동시 액터: goroutine/task별 주석 (병렬 시스템)
    출력: specs/explore/traces/{NNN}-{slug}.md
    필수 포함: mermaid 다이어그램, 흐름 테이블, 엔티티, API, 비즈니스 규칙, 관찰

  synthesis:
    생산물: 엔티티 맵, API 맵, 서버 컴포넌트 맵 (조건부), 네트워크 토폴로지,
            관찰, Domain Profile, Feature 후보
    출력: specs/explore/synthesis.md

reverse_spec:
  단계:
    1단계 코드 패턴: 파일 구조, 의존성, 아키텍처
    2단계 소스 행동 인벤토리: 모든 사용자 대면 행동을 B### 항목으로 카탈로그
    3단계 엔티티 API 추출: entity-registry.md, api-registry.md
    4단계 로드맵: 의존성 순서로 Feature 정렬
    5단계 헌법 시드: 프로젝트 수준 원칙
  출력: specs/reverse-spec/

smart_sdd:
  add 상담:
    단계: 입력 파싱 → 갭 식별 → 프로브 정교화 → Brief 초안 → 리뷰 HARD STOP → 아티팩트 생성
    프로브: 도메인 특화 (ai-assistant 프로브 ≠ microservice 프로브)

  파이프라인 단계: specify → plan → tasks → implement → verify
  단계별 프로토콜: assemble → checkpoint HARD STOP → execute → review HARD STOP → update

  검증 단계:
    phase 1: 빌드 + 타입체크 + lint
    phase 2: 자동 테스트 (유닛 + 통합)
    phase 3: UI/런타임 (Playwright) — 불가능하면 사용자에게 위임, 건너뛰기 금지
    phase 4: Feature 간 통합

  보강:
    커맨드: add --to F00N "새 요구사항"
    상태 설정: augmented
    트리거: SC Preservation (preserved/new/updated 태그)
    실행 후 검사: SC 수 >= 이전, preserved SC 불변, 새 SC가 augmented 요구사항 커버

  가드: constitution, entity_registry, api_registry, pre_context,
        dependency_order, augmentation, regression (총 7개)
```

---

*다음 편: **3편 — 아키텍처 딥 다이브** — 400개 이상의 마크다운 파일이 어떻게 컨텍스트 효율적이고 확장 가능한 스킬 시스템이 되는지. "Enforce, Don't Reference"가 가장 반직관적인 교훈인 이유, 그리고 도메인 모듈이 어떻게 같은 파이프라인으로 다른 프로젝트 유형에 다른 결과를 만들어내는지.*
