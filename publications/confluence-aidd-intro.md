# Spec-Driven + Skill 기반 Agentic Coding 체계화 시도

> 관련: [SDD 도입(안) (260223)](#) · [기술 레퍼런스 매뉴얼 (120p)](https://github.com/coolhero/spec-kit-skills/releases/download/v0.2.0/spec-kit-skills-technical-reference-ko.pdf)

---

### 1. 배경

- 소프트웨어 선도 기업들은 Agentic AI를 활용하여 SDLC 전반을 자동화 중심으로 재설계하고 있음
  - **Spotify**: 내부 AI 시스템 Honk을 통해 월 650건 이상의 에이전트 생성 PR을 프로덕션에 머지. 개발자가 폰에서 버그 수정을 지시하면 AI가 구현·빌드·PR 생성까지 수행
  - **당근**: 슬랙에서 버그 리포트가 올라오면 AI 에이전트 '카비(Kaby)'가 원인 분석→코드 수정→PR 생성까지 자동 처리. PM·운영 매니저가 에이전트에 직접 지시하고, 개발자는 최종 리뷰·승인만 수행
- Agentic Coding의 성숙도를 3단계로 구분할 수 있음
  - **1단계(AI 도구 개인 활용)**: 개발자가 개인 단위로 AI 도구 활용. 생산성 향상되나 품질 편차·범위 통제 한계
  - **2단계(공통화·구조화)**: 기능 단위 실행 기준 + 자동 검증 + 변경 추적 체계 확립
  - **3단계(Agentic SDLC)**: AI Agent가 SDLC 전 단계 실행 주체. 통합 자동화 파이프라인 운영
- 현재 조직은 **1단계에서 2단계로의 전환을 준비하는 시점**
  - 1단계의 핵심 한계:
    - AI가 요청 범위를 초과하여 의도하지 않은 부분까지 구현(overreach)
    - 전체적인 생성은 빠르지만, 원하는 부분만 정확히 수정하거나 기존 코드와 맞추는 세밀한 제어가 어려움
    - 개발자마다 AI 통제 방식이 달라 산출물의 일관성 유지 어려움
- 2단계를 실현하기 위한 대표적 접근이 **SDD(Spec-Driven Development)**
  - SDD에서 **Feature**란 시스템의 행동이 변화하는 단위 (예: "사용자 인증", "실시간 채팅", "결제 처리")
  - 각 Feature를 **Spec**(입력·출력·제약·완료 조건을 명시한 검증 가능한 계약)으로 정의하고, 이를 단일 실행 기준으로 설정
  - Feature 단위 Spec은 업계 공통 방향 — spec-kit(GitHub), Kiro(AWS), Thoughtworks 등이 동일한 접근을 채택
  - Spec이 있으면 AI의 구현 범위가 해당 Feature의 계약 내로 제한되어 overreach 문제를 구조적으로 방지
  - GitHub의 오픈소스 프레임워크 **spec-kit**이 SDD를 실제 워크플로우로 구현 (Constitution → Spec → Plan → Tasks → Implement)
- 다만 **spec-kit 단독 사용에는 한계** 존재
  - spec-kit은 Feature 단위(하나의 Spec → Plan → Tasks → Implement)로 동작하나, 실제 프로젝트는 수십 개 Feature가 서로 의존하며 진화
  - Feature 간 정합성(엔티티 충돌, API 계약 불일치 등) 관리가 자동화되어 있지 않음
  - 프로젝트 유형별 규칙 차별화 없음, 기존 코드에서 Spec 역추출 기능 없음
- 이러한 한계를 **Skill 기반 확장**으로 해결하려는 시도를 진행 중
  - 마크다운 규칙 공통화는 좋은 출발점이나, 에이전트가 선택적으로 참고하는 가이드라인 수준에 머무름
  - 이처럼 AI 에이전트의 행동을 구조적으로 통제하는 체계를 만드는 것을 **하네스 엔지니어링(Harness Engineering)**이라 함
    - 코드를 직접 작성하는 역량에서, **AI가 올바르게 작동하도록 구조를 설계하는 역량**으로 개발자의 핵심 역할이 이동
    - 프롬프트 작성이 "매번 구두로 지시하는 것"이라면, 하네스 엔지니어링은 **"재사용 가능한 업무 매뉴얼을 만드는 것"**
  - Agentic Coding 도구(Claude Code 기준)의 확장 체계는 7가지로 구성되며 빠르게 진화 중
    - **CLAUDE.md(AGENTS.md)**: 프로젝트 규칙·컨벤션 정의. 매 세션 시작 시 로딩
    - **Skill**: 반복 가능한 워크플로우를 구조화한 명령 체계. 슬래시 커맨드로 호출
    - **Hook**: 특정 이벤트(파일 저장, 세션 시작 등)에 자동 실행되는 스크립트
    - **MCP Server**: 외부 도구·데이터 소스 연결 (GitHub, DB, API 등)
    - **Sub-agent**: 독립 컨텍스트에서 병렬 작업 수행. 메인 에이전트가 위임·통합
    - **Agent Team**: 복수 에이전트가 역할 분담·상호 소통하며 협업 (2026.2 출시)
    - **Plugin**: 위의 모든 요소를 패키징하여 팀·프로젝트 간 공유·설치
  - 이 중 **Skill이 가장 핵심적인 빌딩 블록** — Hook이나 MCP는 개별 동작을 자동화하지만, Skill은 **여러 단계로 구성된 워크플로우 전체를 구조화**
  - Skill의 실체:
    - 하나의 디렉토리 안에 `SKILL.md`(진입점) + `commands/*.md`(세부 명령) + `reference/*.md`(참조 규칙) + `scripts/*.sh`(자동화 스크립트)로 구성된 **파일 묶음**
    - 에이전트가 사용자 요청을 받으면 `SKILL.md`의 **frontmatter(설명·트리거 조건 등 수 줄)만 먼저 읽어** 이 Skill을 사용할지 판단하고, 필요한 명령 파일만 추가 로딩
    - 즉, 수백 개 파일 중 **매 작업마다 2~3개 파일만 읽는 구조**이기 때문에 규칙이 아무리 늘어나도 에이전트의 컨텍스트를 효율적으로 사용
  - 커뮤니티에서도 개발자 간 Skill 공유가 활발하며, 우선 **Skill 기반의 체계화부터 시도**해보는 것이 현실적 출발점

---

### 2. 시도하고 있는 것

- 위에서 언급한 다양한 프로젝트 특수성(소프트웨어 유형, 개발 체제, migration 유형 등)을 **포괄적으로 수용할 수 있는 Skill 아키텍처**를 SDD 기반으로 설계·검증 중
  - spec-kit의 Feature-local 구조를 기반으로, Feature 간 정합성·도메인 적응·검증 체계를 확장


| Skill             | 역할                                           |
| ----------------- | -------------------------------------------- |
| **code-explore**  | 기존 코드 체계적 이해 — 아키텍처 맵, 흐름 추적, Feature 후보 도출  |
| **reverse-spec**  | 기존 코드에서 Spec 역추출 — 소스 코드 → 구조화된 요구사항 변환      |
| **smart-sdd**     | Spec → Plan → Implement → Verify 전체 파이프라인 실행 |
| **domain-extend** | 도메인 규칙 확장 — 조직 표준·프로젝트 특화 규칙을 Skill에 반영      |


- 프로젝트 상황에 따라 접근이 달라짐
  - **새로 만들 때 (Greenfield)**: 아이디어나 PRD에서 출발하여 Feature를 정의하고 설계→구현→검증
    - init → add → pipeline (specify → plan → implement → verify)
  - **다시 만들 때 (Rebuild)**: 기존 코드를 분석하여 Spec을 역추출한 뒤, 새 코드로 재구현
    - code-explore → reverse-spec → pipeline
  - **기존 코드에 체계를 입힐 때 (Adoption)**: 코드는 그대로 두고 SDD 문서(Spec·Plan)만 생성
    - adopt (specify → plan → verify, 구현 단계 생략)
  - **이미 체계가 있는 프로젝트에 기능을 추가할 때 (Incremental)**: 기존 Feature의 결정을 자동 참조하며 새 Feature 추가
    - add → pipeline (기존 레지스트리 자동 참조)
  - **전환이 수반될 때 (Migration)**: 위 4가지 상황에 전환 유형별(프레임워크·DB·클라우드 등) 추가 규칙 적용
- SDD 기본 구조에 세 가지를 추가하여 spec-kit의 한계를 보완
  - **Global Evolution Layer**: Feature 간 정보 연속성 보장. 다음 4개 파일이 Feature 간 공유 기억 역할
    - `entity-registry.md` — 전체 프로젝트의 데이터 모델(Entity) 목록과 소유 Feature 기록
    - `api-registry.md` — API 계약(엔드포인트, 요청/응답 형태)과 소비자 Feature 기록
    - `domain-profile-instance.md` — 프로젝트의 도메인 결정 이력(인증 방식, 프로토콜 선택 등)
    - `sdd-state.md` — 각 Feature의 진행 상태, Domain Profile, 파이프라인 설정
  - **5축 Domain Profile**: 프로젝트 유형을 5개 축으로 정의하고, 축 조합에 따라 100+ 모듈에서 해당 규칙만 자동 선택·조합
    - **Interface** — 사용자와 어떻게 소통하는가: GUI, CLI, HTTP API, gRPC 등
    - **Concern** — 어떤 횡단 관심사가 있는가: 인증, 실시간 처리, 결제, 암호화 등
    - **Archetype** — 어떤 종류의 소프트웨어인가: AI 어시스턴트, 마이크로서비스, 게임 엔진 등
    - **Foundation** — 어떤 기술 스택인가: React, FastAPI, Electron, Go 등
    - **Context** — 지금 어떤 상황인가: 신규/재개발/유지보수, 프로토타입/프로덕션 등
  - **Pipeline Integrity Guards**: 파이프라인 주요 단계마다 사용자의 확인·승인 없이는 다음 단계로 진행 불가

> **[architecture-overview.png 삽입]**
>
> 4개 Skill · Global Evolution Layer · Domain Profile 관계도

---

### 3. 현재까지 확인된 것

- Skill 기반 구조(차단 게이트 + 규칙 재로딩 + 파일 기반 상태)를 통해, 마크다운 규칙만으로는 불가능했던 에이전트 통제가 가능함을 확인
- 기능 단위 실행 기준 명확화, 정합성 확보, 자동 검증, 변경 추적 등의 과제가 Skill 구조 안에서 해결 가능성을 보임
- 다만 이것은 SDD 영역에서의 한 가지 시도
- 개발 프로젝트마다 특수성이 존재하며, 이 **특수성을 AI에게 전달하는 것**이 Agentic Coding의 핵심 과제
  - 소프트웨어 유형별로 접근이 크게 달라짐 — 웹 서비스, 모바일 앱, 데이터 파이프라인, 임베디드 시스템 등 각각 아키텍처 패턴·검증 방식·품질 기준이 다름
  - 내재화·외주·혼합 등 개발 체제에 따라 통제 수준과 협업 방식도 달라짐
  - 가령 migration 하나만 해도 프레임워크 전환, DB 스키마 변경, 모놀리스→마이크로서비스 분리, 클라우드 이전 등 유형별로 필요한 규칙과 검증 방식이 전혀 다름
  - 범용 AI 도구는 "일반적으로 좋은 코드"는 만들지만, "이 프로젝트에서 통용되는 코드"를 만들려면 프로젝트 고유의 맥락이 주입되어야 함
  - Skill은 그 맥락을 구조화하여 주입하는 수단
- 결국 **개발자가 자신의 프로젝트·업무 영역에 맞는 Skill을 찾아 구성해나가야 하는 과정**이며, 테스트 자동화, 코드 리뷰, 배포 등 다양한 영역에서 동일한 접근이 가능

---

> 상세: [기술 레퍼런스 매뉴얼 (120p, PDF)](https://github.com/coolhero/spec-kit-skills/releases/download/v0.2.0/spec-kit-skills-technical-reference-ko.pdf)

