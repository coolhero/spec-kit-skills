# spec-kit-skills

**Repository**: [coolhero/spec-kit-skills](https://github.com/coolhero/spec-kit-skills)

[English README](README.md) | [Playwright 설정 가이드](PLAYWRIGHT-GUIDE.md) | Last updated: 2026-03-12 18:27 KST

**[spec-kit](https://github.com/github/spec-kit)의 Feature-local 한계를 넘어 AI 통제 가능한 계약 기반 개발을 실현하는 Claude Code 스킬**

- **Reverse-Spec** — 브라운필드 코드베이스에서 암묵적 계약(동작·인터페이스·데이터 모델)을 역추출해 Spec으로 정렬하고, 레거시를 계약 기반 체계에 편입시킵니다. Rebuild(원본 참조, 새로 작성)과 Adopt(기존 코드 유지, SDD 문서 추가) 두 접근을 지원하며, smart-sdd 없이 spec-kit만 사용할 수 있도록 독립 프롬프트(`speckit-prompt.md`)도 함께 생성합니다.
- **Smart-SDD** — spec-kit 명령 실행 시 관련 Feature의 계약·상태를 자동 주입하고, 변경이 기존 계약을 위반하지 않는지 검증하여 Feature 간 정합성을 유지합니다.

---

## 빠른 시작

### 사전 요구사항

- [Claude Code](https://claude.ai/claude-code) CLI
- [spec-kit](https://github.com/github/spec-kit) 스킬 (`/smart-sdd` 사용 시)
- [Playwright](https://playwright.dev) — `npm install -D @playwright/test && npx playwright install` (기본). 선택: [Playwright MCP](https://github.com/microsoft/playwright-mcp) 인터랙티브 가속 — [Playwright 설정 가이드](PLAYWRIGHT-GUIDE.md) 참고

### 설치

```bash
git clone https://github.com/coolhero/spec-kit-skills.git
cd spec-kit-skills
./install.sh      # ~/.claude/skills/에 심링크 생성
# ./uninstall.sh  # 심링크 제거 (제거 시)
```

### 첫 번째 커맨드

| 목표 | 커맨드 |
|------|--------|
| 아이디어로 새 프로젝트 시작 | `/smart-sdd init "칸반 보드가 있는 작업 관리 앱 만들기"` |
| 기존 코드 재구축 | `/reverse-spec ./path/to/source` |
| 새 프로젝트 (전체 Q&A) | `/smart-sdd init` → `/smart-sdd add` |
| PRD로 새 프로젝트 | `/smart-sdd init --prd design.md` |
| 기존 프로젝트에 Feature 추가 | `/smart-sdd add` |
| SDD 도입 (기존 코드 유지) | `/reverse-spec --adopt` → `/smart-sdd adopt` |
| spec-kit 호환성 검사 | `/speckit-diff` |

### 설치 확인

```
/reverse-spec --help
/smart-sdd status
```

---

## 해결하는 문제

spec-kit은 **한 번에 하나의 Feature만** 처리합니다 — Feature 간 공유 엔티티, API 계약, 의존성을 추적하는 메커니즘이 없습니다. Feature 3의 `/speckit-plan`을 실행할 때, Feature 1이 정의한 데이터 모델이나 Feature 2가 기대하는 API를 알 수 없습니다.

**spec-kit-skills**는 **Global Evolution Layer** — spec-kit의 Feature별 범위 위에 위치하는 프로젝트 수준 아티펙트 — 로 이 문제를 해결합니다:

| 아티펙트 | 추적하는 것 |
|----------|------------|
| **Roadmap** | Feature 의존성 그래프 + 실행 순서 |
| **Entity Registry** | Feature 간 공유 데이터 모델 |
| **API Registry** | Feature 간 API 계약 및 엔드포인트 |
| **Feature별 Pre-context** | 각 Feature가 프로젝트에 대해 알아야 할 것 |
| **Source Behavior Inventory** | 함수 수준 커버리지 추적 (기존 코드베이스용) |
| **Constitution** | 프로젝트 전역 원칙 및 아키텍처 결정 |

---

## 스킬

### `/reverse-spec` — 기존 소스 → SDD-Ready 아티펙트

기존 소스코드를 읽고 SDD에 필요한 기반을 생성합니다: Feature 분해, 엔티티/API 레지스트리, Feature별 pre-context, 소스 커버리지 베이스라인.

```bash
/reverse-spec [target-directory] [--scope core|full] [--stack same|new] [--name new-project-name]
```

**워크플로우**: Phase 0 (전략) → Phase 1 (프로젝트 스캔) → Phase 1.5 (Playwright 런타임 탐색) → Phase 2 (심층 분석) → Phase 3 (Feature 분류) → Phase 4 (아티펙트 생성)

### `/smart-sdd` — 교차 Feature 컨텍스트를 갖춘 spec-kit

모든 spec-kit 커맨드를 **4단계 프로토콜**로 래핑합니다: 컨텍스트 조립 → 체크포인트 → 실행 + 검토 → 레지스트리 갱신. Feature 3의 `/speckit-plan`이 Feature 1의 `User` 엔티티와 Feature 2의 API 계약을 자동으로 알게 됩니다.

```bash
/smart-sdd init                          # 새 프로젝트 설정
/smart-sdd add                           # 새 Feature 정의
/smart-sdd pipeline                      # 전체 SDD 파이프라인 실행
/smart-sdd adopt                         # 기존 코드 SDD 문서화
/smart-sdd status                        # 진행 상태 확인
```

**다섯 가지 모드**: 그린필드 (`init`), 점진적 추가 (`add`), 재구축 (`reverse-spec` 후 `pipeline`), 도입 (`adopt`), 범위 확장 (`expand`)

### 유틸리티

| 스킬 | 목적 |
|------|------|
| `/speckit-diff` | spec-kit 버전 비교, 호환성 판정 + 영향 리포트 |
| `/case-study` | 실행 아티펙트에서 메트릭 + 정성적 관찰 보고서 생성 |

---

## 아키텍처

spec-kit-skills는 **에이전트 코딩을 위한 하네스(harness)** 입니다 — AI 에이전트가 생성하는 결과물을 제약하고, 안내하고, 검증하는 구조적 레이어입니다. 에이전트가 올바른 코드를 작성하기를 기대하는 대신, 하네스가 에이전트가 충족해야 할 계약을 정의하고, 에이전트가 달리 알 수 없는 교차 Feature 컨텍스트를 주입하며, 머지 전에 계약 위반 여부를 검증합니다. 아래 아키텍처는 이 하네스가 세 가지 독립된 차원에서 어떻게 확장 가능하게 설계되어 있는지 보여줍니다.

### 3축 도메인 합성

도메인 동작(SC 생성, 검증, 프로브, 버그 방지)은 프로젝트 유형마다 다릅니다. REST API는 엔드포인트 상태 코드 검사가 필요하고, 데스크톱 앱은 IPC 경계 안전성 검사가 필요하며, 재구축 프로젝트는 동작 패리티 검증이 필요합니다. 모든 프로젝트에 모든 규칙을 로드하는 단일 파일 대신, 도메인 지식을 세 개의 독립 축으로 분해합니다:

```
Interface (앱이 노출하는 것)        Concern (횡단 관심사)                Scenario (왜 만드는가)
├── http-api                       ├── async-state                     ├── greenfield
├── gui                            ├── ipc                             ├── rebuild
├── cli                            ├── external-sdk                    ├── incremental
└── data-io                        ├── i18n                            └── adoption
                                   ├── realtime
                                   └── auth
```

**Domain Profile** = 선택된 Interface + 선택된 Concern + Scenario. 예: `desktop-app = [gui] + [async-state, ipc] + rebuild`. 에이전트는 프로젝트에 관련된 모듈만 로드합니다 — API 전용 프로젝트에 GUI 테스트 규칙이 로드되지 않고, IPC가 없는 프로젝트에 IPC 경계 검사가 적용되지 않습니다.

**모듈 로딩 순서**: `_core.md` (항상) → 활성 Interface → 활성 Concern → Scenario → 사용자 커스텀 (`domain-custom.md`).

### 재구축 구성(Rebuild Configuration)

기존 소프트웨어를 재구축할 때(스택 마이그레이션, 프레임워크 업그레이드, 플랫폼 마이그레이션 등), reverse-spec Phase 0에서 하네스 전반의 파이프라인 동작에 영향을 미치는 네 가지 구성 파라미터를 수집합니다:

| 파라미터 | 제어 대상 | 예시 |
|----------|----------|------|
| Change scope | 정교화 프로브, 버그 방지 규칙 | `framework` (Express → Fastify) |
| Preservation level | SC 깊이 요구사항, 검증 엄격도 | `equivalent` (동일 데이터, 포맷 차이 허용) |
| Source available | Side-by-side 비교 전략 | `running` (원본 앱 접근 가능) |
| Migration strategy | 회귀 게이트 범위, 머지 정책 | `incremental` (Feature별) |

이 값들은 `sdd-state.md`에 저장되며 관련 파이프라인 단계에서 자동으로 읽힙니다 — 전체 소비 매트릭스는 `domains/scenarios/rebuild.md` 참고.

### 확장 방법

각 모듈은 통일된 스키마(`S1`: SC 생성 규칙, `S5`: 정교화 프로브, `S7`: 버그 방지)를 따르는 독립 파일입니다. 새 모듈을 추가할 때 기존 파일을 수정할 필요가 없습니다 — 이미 활성화된 모듈과 자동으로 합성됩니다.

**새 인터페이스 추가** (예: 프로젝트가 기본 제공되지 않는 gRPC를 사용하는 경우):
1. `domains/interfaces/grpc.md` 생성 — SC 규칙("모든 RPC 메서드에 request/response proto shape 필수"), 프로브("스트리밍 vs 단방향?"), 버그 방지 규칙 추가
2. sdd-state.md에 등록: `**Interfaces**: http-api, grpc`
3. 에이전트가 `_core.md` + `http-api.md` + `grpc.md` + 활성 concern을 로드 — 모든 규칙이 자동 병합

**새 관심사 추가** (예: 프로젝트에 캐싱 패턴 검사가 필요한 경우):
1. `domains/concerns/caching.md` 생성 — SC 규칙("cache hit/miss/stale 생애주기"), 프로브("TTL? 무효화 전략?") 추가
2. 활성 관심사에 추가: `**Concerns**: async-state, auth, caching`

**프로젝트별 커스터마이징** — 스킬 파일을 수정하지 않고:
1. 프로젝트 디렉토리에 `specs/reverse-spec/domain-custom.md` 생성
2. 동일한 S1/S5/S7 스키마로 프로젝트 고유 규칙 추가 (예: "결제 엔드포인트에 멱등성 SC 필수")
3. 이 파일은 가장 마지막에 최우선 순위로 로드되어 다른 모든 모듈을 확장

새 모듈은 기존 모듈과 자유롭게 합성됩니다 — 중복 없이, 불필요한 규칙 없이. 각 인터페이스 모듈은 **S8 런타임 검증 전략**도 선언합니다 — 해당 인터페이스 타입을 런타임에서 어떻게 시작, 검증, 종료하는지 정의합니다. 모듈 스키마는 `domains/_schema.md`, 로딩 프로토콜은 `domains/_resolver.md`, 다중 백엔드 런타임 검증 아키텍처는 `reference/runtime-verification.md` 참고.

### 신호 키워드와 Proposal Mode

각 도메인 모듈은 **S0 신호 키워드**를 선언합니다 — 해당 모듈이 활성화되어야 함을 나타내는 용어들입니다. 아이디어 문자열로 프로젝트를 시작하면 (`init "AI로 웹 페이지를 요약하는 Chrome 확장 프로그램"`), 에이전트가 모든 S0 키워드를 스캔하여 Domain Profile을 자동으로 추론합니다. "React"는 `gui`를, "REST API"는 `http-api`를, "OpenAI"는 `external-sdk`를 트리거합니다 — 수동 설정 없이 자동으로.

이 추론은 **Clarity Index (CI)**로 채점됩니다 — 7개 차원(목적, 기능, 유형, 스택, 사용자, 규모, 제약조건)에 걸쳐 아이디어의 구체성을 측정하는 백분율입니다. CI는 에이전트 행동을 결정합니다: 높은 CI(70%+)는 명확화를 건너뛰고 Proposal을 바로 생성하고, 낮은 CI는 활성 모듈의 S5 정교화 프로브를 사용하여 타겟 질문을 합니다.

CI는 파이프라인으로 전파됩니다 — 초기 CI가 낮을수록 specify와 plan에서 더 많은 검증 체크포인트가 적용되어, 모호한 아이디어가 불완전한 스펙을 생성하지 않도록 합니다. 전체 모델은 `reference/clarity-index.md` 참고.

---

## 사용자 여정

```
── 아이디어에서 시작 (Proposal Mode) ─────────────────────────────
/smart-sdd init "AI로 웹 페이지를 요약하는 Chrome 확장 프로그램 만들기"
→ 신호 추출 → Clarity Index 채점 → Proposal (1번 승인)
→ constitution + add + pipeline으로 자동 연결

── 신규 프로젝트 (표준) ──────────────────────────────────────────
/smart-sdd init  →  /smart-sdd add  →  /smart-sdd pipeline
(프로젝트 설정)      (Feature 정의)      (구현)

── SDD 도입 ──────────────────────────────────────────────────────
/reverse-spec --adopt  →  Global Evolution Layer  →  /smart-sdd adopt
                           (roadmap, registries)      (기존 코드 문서화)

── 재구축 ────────────────────────────────────────────────────────
/reverse-spec  →  Global Evolution Layer  →  /smart-sdd pipeline
(코드 분석)       (roadmap, registries)      (코드 재구축)

── 점진적 추가 ───────────────────────────────────────────────────
/smart-sdd add  →  갱신된 Global Evolution  →  /smart-sdd pipeline
```

모든 여정은 **점진적 추가 모드**로 수렴합니다.

---

## 빠른 예시

**기존 앱 재구축**:
```
/reverse-spec ./legacy-app --scope core --stack new
/smart-sdd pipeline
```

**그린필드 프로젝트**:
```
/smart-sdd init
/smart-sdd add        # Feature를 대화형으로 정의
/smart-sdd pipeline   # specify → plan → tasks → implement → verify
```

**기존 프로젝트에 Feature 추가**:
```
/smart-sdd add        # "실시간 알림 기능이 필요합니다"
/smart-sdd pipeline   # 새로운/대기 중인 Feature만 처리
```

---

## 상세 레퍼런스

### 작동 방식 — 공통 프로토콜

모든 spec-kit 커맨드 실행은 이 4단계 프로토콜을 따릅니다:

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────────┐     ┌─────────────┐
│  1. Assemble │────▶│ 2. Checkpoint│────▶│  3. Execute + Review │────▶│  4. Update  │
│  컨텍스트 조립 │     │ 실행 전 확인   │     │ spec-kit 실행 + 검토  │     │ 글로벌 갱신  │
└─────────────┘     └──────────────┘     └──────────────────────┘     └─────────────┘
```

| 단계 | 설명 |
|------|------|
| **Assemble** | `specs/reverse-spec/`에서 해당 커맨드에 필요한 파일/섹션을 읽고, 커맨드별 주입 규칙에 따라 필터링하여 조립. 소스 파일이 없거나 플레이스홀더만 있으면 건너뜀 |
| **Checkpoint** | 조립된 컨텍스트를 사용자에게 보여주고 실행 전 승인/수정 기회 제공 |
| **Execute+Review** | spec-kit 커맨드를 실행하고 즉시 생성된 산출물을 검토용으로 제시. **HARD STOP** |
| **Update** | 실행 결과를 반영하여 Global Evolution Layer 파일 갱신. `sdd-state.md`에 진행 상태 기록 |

### 각 명령이 프로젝트에 대해 아는 것

각 spec-kit 명령은 관련 프로젝트 컨텍스트를 자동으로 받습니다 — Feature 간에 수동으로 복사·붙여넣기할 필요가 없습니다.

| 명령 | 자동으로 아는 것 | 왜 중요한가 |
|------|----------------|------------|
| `constitution` | 분석에서 추출된 아키텍처 원칙, Best Practices | 프로젝트 전역 규칙이 처음부터 일관됨 |
| `specify` | Feature 요약, 비즈니스 규칙, 엣지 케이스, 소스 참조 | 스펙 초안이 추측이 아닌 실제 동작에 기반 |
| `plan` | 의존성, 다른 Feature의 엔티티/API 스키마, 통합 계약 | 계획이 다른 Feature에 대한 가정이 아닌 실제 데이터 형태를 참조 |
| `tasks` | 승인된 plan | plan에서 태스크가 자동 생성 |
| `analyze` | spec + plan + tasks 교차 검사 | spec↔plan↔task 불일치를 구현 전에 포착 |
| `implement` | 태스크, 인터랙션 체인, UX 행동 계약, API 호환성 | 구현이 검증된 계약을 따르고, 런타임 에러를 즉시 포착 |
| `verify` | 전체 교차 Feature 계약, SC 검증 매트릭스, 통합 계약 | 프로젝트 나머지와의 정합성을 확인하지 않고는 배포되지 않음 |

**선행 Feature 결과 우선 적용**: 의존하는 선행 Feature의 plan이 완료되었으면, 레지스트리 초안 대신 확정된 `data-model.md`와 `contracts/`를 우선 참조합니다.

#### 명령별 주입 소스

| 명령 | 주입 소스 |
|------|----------|
| `constitution` | `constitution-seed.md` |
| `specify` | `pre-context.md` + `business-logic-map.md` |
| `plan` | `pre-context.md` + `entity-registry.md` + `api-registry.md` |
| `tasks` | `plan.md` |
| `analyze` | `spec.md` + `plan.md` + `tasks.md` |
| `implement` | `tasks.md` + `plan.md` + `pre-context.md` |
| `verify` | `pre-context.md` + registries + `plan.md` |

## /reverse-spec — 상세 워크플로우

### 사용법

```bash
/reverse-spec [target-directory] [--scope core|full] [--stack same|new] [--name new-project-name]
```

| 옵션 | 설명 |
|------|------|
| `--scope core` | 핵심 Feature만 (Tier 분류 활성) |
| `--scope full` | 전체 Feature (순수 의존성 순서) |
| `--stack same` | 기존과 동일한 기술 스택 |
| `--stack new` | 새 기술 스택으로 마이그레이션 |
| `--name <name>` | 프로젝트 이름 변경 (예: "Cherry Studio" → "Angdu Studio") |

### Phase 0 — 전략 질문

**구현 범위**: Core (기반 기능, 학습/프로토타이핑용) vs Full (전체 기능 세트)

**기술 스택 전략**: Same Stack (기존 구현 패턴 재사용) vs New Stack (로직만 추출, 새 스택의 관용 패턴 사용)

**프로젝트 아이덴티티** (재구축만): 이름 접두사 매핑

### Phase 1 — 프로젝트 스캔

- 디렉토리 구조 탐색: `**/*.{py,js,ts,jsx,tsx,java,go,rs,...}`
- 설정 파일에서 기술 스택 자동 감지
- 프로젝트 타입 분류: backend, frontend, fullstack, mobile, library
- 모듈/패키지 경계 식별

### Phase 1.5 — 런타임 탐색 (선택)

Playwright(CLI 기본, MCP 선택)를 통해 원본 앱을 실제로 실행하고 탐색. UI 레이아웃, 사용자 흐름, 실제 상태를 관찰. Electron 앱은 CLI의 `_electron.launch()` 사용 (CDP 불필요) — [Playwright 설정 가이드](PLAYWRIGHT-GUIDE.md) 참고.

### Phase 2 — 심층 분석

코드베이스에서 데이터 모델, API 엔드포인트, 비즈니스 로직, 모듈 간 의존성, Source Behavior Inventory, UI 컴포넌트 Feature를 자동 추출합니다.

**지원 프레임워크** (자동 감지): Django, FastAPI/SQLAlchemy, Express/Fastify, Spring, Next.js/Nuxt, Rails, Go (Gin/Echo), TypeORM/Prisma, JPA/Hibernate, Mongoose 등.

#### 프레임워크별 스캔 대상

**데이터 모델 추출**:

| 기술 | 스캔 대상 |
|------|----------|
| Django | `models.py`, migrations |
| SQLAlchemy/FastAPI | Model 클래스, Alembic migrations |
| TypeORM/Prisma | Entity 클래스, `schema.prisma` |
| JPA/Hibernate | `@Entity` 클래스 |
| Mongoose | Schema 정의 |
| Rails | `app/models/`, migrations |
| Go | Struct 정의 + DB 태그 (GORM, sqlx) |

**API 엔드포인트 추출**:

| 기술 | 스캔 대상 |
|------|----------|
| Express/Fastify | Router 파일, `router.get()` 등 |
| Django/DRF | `urls.py`, ViewSet, APIView |
| FastAPI | `@app.get()`, `@router.post()` 데코레이터 |
| Spring | `@RequestMapping`, `@GetMapping` 등 |
| Next.js/Nuxt | `pages/api/`, `app/api/` 디렉토리 |
| Rails | `config/routes.rb`, controllers |
| Go (net/http, Gin, Echo) | Router 등록, handler 함수 |

### Phase 3 — Feature 분류 및 중요도 분석

논리적 Feature 경계 식별 → 2-3개 세분화 옵션 제시 (Coarse/Standard/Fine).

**Tier 분류 (Core Scope만)** — 5축 평가:

| 축 | 기준 |
|----|------|
| 구조적 기반 | 이 Feature 없이 다른 Feature가 존재할 수 없는가? |
| 도메인 핵심 | 프로젝트 존재 이유와 직접 연관되는가? |
| 데이터 소유 | 핵심 엔티티를 정의하고 관리하는가? |
| 통합 허브 | 다른 Feature/외부 시스템과의 연결점인가? |
| 비즈니스 복잡도 | 핵심 비즈니스 규칙이 집중되어 있는가? |

결과: Tier 1 (필수), Tier 2 (권장), Tier 3 (선택) 분류.

### Phase 4 — 아티펙트 생성

생성물: `roadmap.md`, `constitution-seed.md`, `entity-registry.md`, `api-registry.md`, `business-logic-map.md`, Feature별 `pre-context.md` 파일.

**소스 커버리지 베이스라인** (재구축만): 원본 소스의 커버리지 측정. 매핑되지 않은 항목을 대화형으로 분류 — 기존 Feature에 할당, 새 Feature 생성, 교차 관심사 플래그, 의도적 제외.

### 아티펙트 상세

**프로젝트 수준**:

| 아티펙트 | 역할 |
|----------|------|
| `roadmap.md` | Feature 진화 맵: Tier 기반 카탈로그, 의존성 그래프, 릴리스 그룹 |
| `constitution-seed.md` | 아키텍처 원칙, 기술 제약, 코딩 규약, Best Practices |
| `entity-registry.md` | 전체 엔티티 목록, 필드, 관계, 교차 Feature 매핑 |
| `api-registry.md` | 전체 API 엔드포인트 인덱스, 상세 계약, 교차 Feature 의존성 |
| `business-logic-map.md` | Feature별 비즈니스 규칙, 검증, 워크플로우 |
| `speckit-prompt.md` | smart-sdd 없이 spec-kit만 사용하기 위한 독립 프롬프트 — 명령별 컨텍스트 가이드 |

**Feature 수준 — `pre-context.md`**:

| 섹션 | 대상 커맨드 | 내용 |
|------|-----------|------|
| Source Reference | 전체 | 관련 원본 파일 + 스택별 참조 전략 |
| Source Behavior Inventory | specify, verify | 함수 수준 동작 목록 (P1/P2/P3) |
| UI Component Features | specify, plan, parity | 서드파티 UI 라이브러리 기능 |
| Static Resources | 전체 | 비코드 파일 (이미지, 폰트, i18n) |
| Environment Variables | 전체 | 필요한 런타임 변수 |
| For /speckit.specify | specify | Feature 요약, FR/SC 초안, 엣지 케이스 |
| For /speckit.plan | plan | 의존성, 엔티티/API 스키마 초안, 기술 결정 |
| For /speckit.analyze | analyze | 교차 Feature 검증 포인트, 영향 범위 |

## smart-sdd 없이 spec-kit 사용하기

`/reverse-spec` 실행 후 smart-sdd 대신 순수 spec-kit만으로 개발할 수 있습니다. 생성된 `speckit-prompt.md`가 smart-sdd가 자동으로 주입하는 교차 Feature 컨텍스트를 수동 가이드로 제공합니다.

**설정 방법:**

1. `/reverse-spec`으로 코드베이스를 분석합니다 — `specs/reverse-spec/`에 산출물 생성
2. `specs/reverse-spec/speckit-prompt.md`를 프로젝트의 `CLAUDE.md`에 복사합니다 (또는 세션 시작 시 에이전트에 전달)
3. spec-kit 명령(`specify`, `plan` 등)을 직접 실행합니다 — 프롬프트가 각 명령 전에 어떤 산출물을 읽어야 하는지 안내합니다

**프롬프트가 제공하는 내용:**
- **Artifact Map** — reverse-spec이 생성한 파일 목록과 각 파일의 역할
- **명령별 컨텍스트** — spec-kit 명령(specify / plan / implement / verify)마다 읽어야 할 산출물과 실행 후 확인 사항
- **교차 Feature 규칙** — 엔티티나 API가 여러 Feature에서 공유될 때 정합성을 유지하는 방법

**smart-sdd를 사용해야 하는 경우:**
- 컨텍스트 주입을 완전 자동화하고 싶을 때 (수동 단계 없음)
- 고급 검증이 필요할 때: SBI 교차 검증, CSS Value Map, Pattern Compliance Scan, Runtime Error Zero Gate
- Feature 간 상태 추적이 필요할 때 (`sdd-state.md` 자동 관리)

---

## /smart-sdd — 상세 워크플로우

### 전체 커맨드 레퍼런스

```bash
# 그린필드
/smart-sdd init "칸반 보드가 있는 작업 관리 앱 만들기"  # Proposal Mode (아이디어에서)
/smart-sdd init --prd path/to/prd.md     # PRD 기반 설정 (PRD가 풍부하면 Proposal Mode)
/smart-sdd init                          # 표준 대화형 설정

# Feature 추가 (범용)
/smart-sdd add                           # 대화형 정의
/smart-sdd add --prd path/to/req.md      # 요구사항 문서에서 추출
/smart-sdd add --gap                     # 갭 기반: 미매핑 SBI/패리티 갭 커버

# 도입
/smart-sdd adopt                         # 도입 파이프라인: specify → plan → analyze → verify
/smart-sdd adopt --from ./path           # 지정 경로에서 아티펙트 읽기

# 파이프라인 (기본: Feature 하나씩)
/smart-sdd pipeline                      # 다음 단일 Feature (자동 선택)
/smart-sdd pipeline F003                 # F003 지정 처리
/smart-sdd pipeline --start verify       # 다음 Feature, verify부터 재실행
/smart-sdd pipeline F003 --start verify  # F003, verify부터 재실행
/smart-sdd pipeline --all                # 전체 Feature 일괄 처리 (배치)
/smart-sdd pipeline --from ./path        # 지정 경로에서 아티펙트 읽기

# Constitution (독립 실행)
/smart-sdd constitution                  # Constitution 확정

# 관리
/smart-sdd expand T2                     # Tier 2 Feature 활성화
/smart-sdd expand full                   # 나머지 모든 Feature 활성화
/smart-sdd reset F007                    # Feature 진행 초기화 (specify부터 재실행)
/smart-sdd reset F007 --from plan        # 특정 단계부터 초기화 (이전 결과 보존)
/smart-sdd reset                         # 전체 파이프라인 초기화
/smart-sdd reset --delete F007           # Feature 영구 삭제
/smart-sdd status                        # 진행 상태 개요
/smart-sdd coverage                      # SBI 커버리지 확인
/smart-sdd parity                        # 원본 소스 대비 패리티 확인
```

### 네 가지 프로젝트 모드

| 측면 | 그린필드 | 점진적 추가 | 재구축 | 도입 |
|------|---------|-----------|-------|------|
| 사용 사례 | 새 프로젝트 | 기존에 추가 | 재구현 (스택 교체, 프레임워크 전환 등) | 기존 코드 문서화 |
| 진입점 | `init` → `add` | `add` | `reverse-spec` → `pipeline` | `reverse-spec --adopt` → `adopt` |
| 엔티티/API 레지스트리 | 비어 있음 → 성장 | 이미 존재 | 미리 채워짐 | 미리 채워짐 |
| FR/SC 초안 | 처음부터 생성 | N/A | 코드에서 추출 | 코드에서 추출 |
| 파이프라인 | 전체 (specify→verify) | 대기 중인 Feature만 | 전체 | implement 단계 없음 |

### Feature 정의 흐름 (`add`)

6단계 구조화 컨설테이션:

```
Phase 1: Feature 정의      — 적응형 (문서 / 대화 / 갭 기반)
Phase 2: 중복 & 영향        — 기존 Feature + constitution 검사
Phase 3: 범위 협상          — 단일 vs 분할, Tier 할당
Phase 4: SBI 매칭 + 확장    — 소스 동작 매핑 (재구축/도입만)
Phase 5: 데모 그룹          — 데모 그룹 할당
Phase 6: 확정              — 아티펙트 생성, roadmap/sdd-state 갱신
```

**세 가지 진입 타입**: 문서 기반 (`--prd`), 대화형 (기본), 갭 기반 (`--gap`)

### 파이프라인 흐름

```
Phase 0: Constitution 확정
Foundation Gate (첫 번째 Feature만 — 프로젝트 인프라를 한 번 검증):
   - 빌드 검사 (차단), Toolchain Pre-flight (lint/test 도구 가용성),
     CSS 테마, 상태 관리, IPC 브릿지, 레이아웃 검증
   - 결과를 sdd-state.md에 캐시 — 이후 Feature에서는 건너뜀
Phase 1~N: Feature별 (Release Group 순서):
   0. pre-flight → main 브랜치 확인
   1. specify    → (pre-context + 비즈니스 로직 주입) → /speckit-specify
   2. clarify    → [NEEDS CLARIFICATION] 있을 때만
   3. plan       → (pre-context + 레지스트리 주입) → /speckit-plan
   4. tasks      → /speckit-tasks
   5. analyze    → /speckit-analyze (일관성 검사)
   6. implement  → 환경 변수 확인 (HARD STOP) → /speckit-implement → 런타임 검증 + 수정 루프
   7. verify     → 4단계 검증 (+ Phase 3b 버그 예방)
   8. merge      → 체크포인트 (HARD STOP) → main에 머지
```

### 4단계 검증

merge 전에 verify가 잡아내는 것들:

| 항목 | 방지하는 문제 |
|------|-------------|
| 테스트, 빌드, 린트 통과 | 깨진 코드가 main에 합쳐지는 것 |
| Feature A↔B 데이터 형태 호환 확인 | 런타임 통합 실패 (예: Feature 간 필드명 불일치) |
| 모든 시나리오(SC) 분류 | 조용히 테스트되지 않은 시나리오 — 검증된 것과 스킵 사유가 투명하게 보임 |
| 런타임 동작 실제 확인 (다중 백엔드: Playwright, curl, CLI) | "빌드는 통과하지만 기능이 동작하지 않는" 문제 |
| verify 중 변경 사항 기록 | verify 중 숨겨진 소스 수정 — 모든 변경이 state에 투명하게 기록 |
| 컨텍스트 압축 복구 | 긴 세션 중 에이전트가 verify 진행을 잊는 것 |

```
Phase 1:  실행 검증 (테스트, 빌드, 린트) — 실패 시 차단
Phase 2:  교차 Feature 일관성 — 엔티티/API 호환, 인터랙션 체인,
          UX 행동 계약, API 호환성 매트릭스, 활성화 스모크 테스트,
          통합 계약 형태 검증 (Provider↔Consumer 형태 + 브리지)
Phase 3:  Demo-Ready — SC 검증 매트릭스 (커버리지 < 50% 시 경고),
          VERIFY_STEPS 기능 테스트, 비주얼 충실도 (재구축),
          내비게이션 전환 검사, 인터랙티브 런타임 검증
          (인터페이스별: GUI는 Playwright, API는 curl, CLI는 shell),
          소스 앱 비교 (재구축)
Phase 3b: 버그 예방 — 빈 상태 스모크 테스트 (데이터 존재 확인),
          스모크 런치 기준
Phase 4:  Global Evolution 갱신 (레지스트리, sdd-state)
```

### 단계 사이에 자동으로 일어나는 것

각 파이프라인 단계 후, smart-sdd가 안전 검사를 수행하고 글로벌 상태를 동기화합니다 — 수동으로 업데이트할 필요가 없습니다.

| 시점 | 일어나는 것 | 이유 |
|------|-----------|------|
| plan 후 | 엔티티·API 레지스트리 갱신 | 다음 Feature가 이 Feature의 데이터 모델을 인식 |
| implement 후 | 콘솔 에러 검사 — 에러 시 **차단** | 런타임 버그를 verify 전에 포착 |
| implement 후 | 후속 Feature pre-context 재평가 | 다음 Feature가 실제 구현 결과와 정렬 유지 |
| verify 후 | sdd-state.md + roadmap.md에 결과 기록 | 진행 대시보드가 최신 상태 유지 |
| verify 후 | 머지 확인 (**HARD STOP**) | main에 코드를 합칠지 사용자가 결정 |

### Source Behavior Coverage (SBI)

End-to-end 추적: `reverse-spec SBI (B###) → specify FR (FR-###) → implement → verify → coverage update`

### 패리티 확인 (재구축)

5단계 파이프라인 완료 후 확인: 구조적 패리티 → 로직 패리티 → 갭 리포트 → 개선 계획 → 완료 리포트

### 상태 추적 (`sdd-state.md`)

```
Feature         | Tier | specify | plan | tasks | analyze | implement | verify | merge | Status
----------------|------|---------|------|-------|---------|-----------|--------|-------|----------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |   ✅    |    ✅     |   ✅   |  ✅  | completed
F002-product    | T1   |   ✅    |  🔄  |       |         |           |        |      | in_progress
F003-order      | T2   |         |      |       |         |           |        |      | 🔒 deferred
```

### 프로젝트 상태 확인

`.claude/skills/smart-sdd/scripts/`의 셸 스크립트로 언제든 프로젝트 진행 상황을 확인할 수 있습니다:

| 알고 싶은 것 | 스크립트 |
|-------------|---------|
| 전체 파이프라인 진행률 | `pipeline-status.sh` |
| Feature / 엔티티 / API 요약 | `context-summary.sh` |
| 원본 동작 커버리지 현황 | `sbi-coverage.sh` |
| 데모 그룹 준비 상태 | `demo-status.sh` |
| 교차 파일 일관성 | `validate.sh` |

## End-to-End 워크플로우 예시

### 시나리오 1: 아이디어에서 시작 (Proposal Mode)

```
1. /smart-sdd init "칸반 보드와 팀 워크스페이스가 있는 태스크 관리 앱 만들기"
   +-- 신호 추출: "태스크 관리" → Core Purpose, "칸반 보드" → gui,
   |   "팀 워크스페이스" → auth + async-state
   +-- Clarity Index: 58% (Medium 등급) → 2개 타겟 질문
   +-- Proposal: 5개 Feature, Domain Profile [gui, http-api] + [auth, async-state]
   +-- 사용자 승인 → constitution + add + pipeline으로 자동 연결

2. /smart-sdd pipeline (자동 연결됨)
   +-- Phase 0: Constitution 확정 (Proposal에서 추론된 원칙 적용)
   +-- CI 전파: "Target Users" 저신뢰 → specify에서 사용자 역할 프롬프트 추가
   +-- F001-auth → F002-workspace → F003-task → F004-board → F005-notification
```

### 시나리오 1b: 그린필드 — 표준 Q&A

```
1. /smart-sdd init
   +-- 프로젝트 정의: "TaskFlow", TypeScript + Next.js + Prisma
   +-- Constitution seed + 6 Best Practices
   +-- 빈 아티펙트 생성
   +-- /smart-sdd add 체이닝...
       +-- 정의: F001-auth, F002-workspace, F003-task, F004-board, F005-notification
       +-- 데모 그룹 할당, Feature별 pre-context 생성

2. /smart-sdd pipeline
   +-- Phase 0: Constitution 확정
   +-- Release 1 (Foundation):
   |   F001-auth → specify → plan → ... → verify
   |   갱신: User, Session 엔티티 → entity-registry
   +-- Release 2 (Core):
   |   F002-workspace (F001의 User 엔티티 참조)
   |   F003-task ...
   +-- Release 3 (Enhancement): F004-board, F005-notification
```

### 시나리오 2: 브라운필드 재구축 — 레거시 이커머스를 React + FastAPI로

```
1. /reverse-spec ./legacy-ecommerce --scope core --stack new
   +-- Phase 1: Django + jQuery 스택 감지
   +-- Phase 2: 12 엔티티, 45 API, 78 비즈니스 규칙 추출
   +-- Phase 3: Standard 세분화 선택 (8 Feature)
   |   Tier 1: Auth, Product, Order
   |   Tier 2: Cart, Payment, Search
   |   Tier 3: Review, Notification
   +-- Phase 4: 전체 아티펙트 생성

2. /smart-sdd pipeline
   +-- Scope: Core (Tier 1만)
   +-- F001-auth → F002-product → F003-order
   +-- Tier 2/3은 deferred 상태 유지

3. /smart-sdd expand T2     → Cart, Payment, Search 활성화
4. /smart-sdd expand full   → Review, Notification 활성화
```

### 시나리오 3: 점진적 추가 — 기존 프로젝트에 알림 추가

```
1. /smart-sdd add
   +-- "태스크 업데이트를 위한 실시간 알림이 필요합니다"
   +-- 중복 검사: 기존 Feature와 충돌 없음
   +-- ⚠️ Constitution 영향: WebSocket (새 기술)
   +-- F005-notification은 F001-auth, F003-task에 의존

2. /smart-sdd pipeline
   +-- 완료된 Feature 건너뜀
   +-- F005-notification: specify → plan → ... → verify
   +-- 갱신: Notification 엔티티 → entity-registry
```

## 레퍼런스

### 설치 — 대안 방법

**프로젝트 로컬 설치**:

```bash
mkdir -p .claude/skills
cp -r /path/to/spec-kit-skills/.claude/skills/reverse-spec .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/smart-sdd .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/speckit-diff .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/case-study .claude/skills/
```

**수동 심링크**:

```bash
ln -s /path/to/spec-kit-skills/.claude/skills/reverse-spec ~/.claude/skills/reverse-spec
ln -s /path/to/spec-kit-skills/.claude/skills/smart-sdd ~/.claude/skills/smart-sdd
ln -s /path/to/spec-kit-skills/.claude/skills/speckit-diff ~/.claude/skills/speckit-diff
ln -s /path/to/spec-kit-skills/.claude/skills/case-study ~/.claude/skills/case-study
```

### 경로 규약

| 대상 | 경로 |
|------|------|
| reverse-spec 아티펙트 | `specs/reverse-spec/` |
| spec-kit Feature 아티펙트 | `specs/{NNN-feature}/` |
| spec-kit constitution | `.specify/memory/constitution.md` |
| smart-sdd 상태 파일 | `specs/reverse-spec/sdd-state.md` |
| 결정 이력 | `history.md` |
| 실패 패턴 & 대응책 | `lessons-learned.md` |

### Feature 네이밍 규약

| 시스템 | 형식 | 예시 |
|--------|------|------|
| smart-sdd (pre-context, roadmap, state) | `F{NNN}-{short-name}` | `F001-auth` |
| spec-kit (specs/ 디렉토리, git 브랜치) | `{NNN}-{short-name}` | `001-auth` |

### 아티펙트 구조

```
history.md
lessons-learned.md
specs/
└── reverse-spec/
    ├── roadmap.md
    ├── constitution-seed.md
    ├── entity-registry.md
    ├── api-registry.md
    ├── business-logic-map.md           # 재구축만
    ├── stack-migration.md              # 재구축 + 새 스택만
    ├── coverage-baseline.md            # 재구축만
    ├── parity-report.md                # 재구축만 (/smart-sdd parity)
    ├── sdd-state.md
    └── features/
        ├── F001-auth/pre-context.md
        ├── F002-product/pre-context.md
        └── ...
```

### Constitution Best Practices

| 원칙 | 핵심 |
|------|------|
| **I. Test-First** | 테스트를 먼저 작성. 테스트 없는 코드는 미완성 |
| **II. Think Before Coding** | 가정 금지. 불명확한 항목은 `[NEEDS CLARIFICATION]` 표시 |
| **III. Simplicity First** | 스펙에 있는 것만 구현 |
| **IV. Surgical Changes** | 인접 코드 "개선" 금지 |
| **V. Goal-Driven Execution** | 검증 가능한 완료 기준 필수 |
| **VI. Demo-Ready Delivery** | 각 Feature는 실행 가능한 데모 스크립트와 함께 제공 |

### spec-kit과의 관계

| 측면 | spec-kit | spec-kit-skills |
|------|----------|-----------------|
| 역할 | Feature 로컬 SDD 프레임워크 | Global Evolution Layer 보강 |
| 범위 | 개별 Feature 일관성 | 교차 Feature 의존성과 진화 |
| 관계 | 독립 | spec-kit을 래핑 (대체하지 않음) |
| 결합도 | spec-kit-skills 없이 동작 | spec-kit 필요 |

---

## 파일 맵

이 저장소의 모든 파일을 스킬별로 그룹핑한 전체 목록입니다.

### 루트

| 파일 | 설명 |
|------|------|
| `CLAUDE.md` | Claude Code 에이전트용 프로젝트 규칙 (불변 규칙, 규약, 리뷰 프로토콜) |
| `README.md` | 영문 문서 |
| `README.ko.md` | 한국어 문서 |
| `PLAYWRIGHT-GUIDE.md` | Playwright 설정 가이드 — 브라우저 자동화 및 Electron CDP 설정 |
| `TODO.md` | 프로젝트 작업 추적기 (2026-03-08 기준 모든 계획 작업 완료) |
| `history.md` | git 이력에서 추출한 설계 결정 이력 |
| `lessons-learned.md` | 실제 파이프라인 실행에서 발견된 실패 패턴(G1–G11)과 대응책 |
| `install.sh` | 설치 스크립트 — `~/.claude/skills/`에 심링크 생성 |
| `uninstall.sh` | 제거 스크립트 — `~/.claude/skills/`에서 심링크 제거 |

### reverse-spec (`.claude/skills/reverse-spec/`)

| 파일 | 설명 |
|------|------|
| `SKILL.md` | 스킬 라우터 — reverse-spec 진입점 및 필수 규칙 |
| `commands/analyze.md` | 소스코드 분석 및 Global Evolution Layer 아티펙트 생성 다단계 워크플로우 |
| **Domains** | |
| `domains/_core.md` | 범용 분석 프레임워크 (R1–R6 분석 섹션) |
| `domains/_schema.md` | 도메인 프로필 스키마 템플릿 (Detection Signals, Analysis Axes, Feature Registry 등) |
| `domains/app.md` | 애플리케이션 도메인 프로필 — backend/frontend/fullstack/mobile/library 감지 및 분석 |
| `domains/data-science.md` | 데이터 사이언스 도메인 프로필 템플릿 (미구현 — 의도적 TODO 스캐폴딩) |
| `domains/interfaces/gui.md` | GUI 인터페이스 — 런타임 탐색, 시각적 동작 분석 |
| `domains/interfaces/http-api.md` | HTTP API 인터페이스 — 엔드포인트 탐색, 요청/응답 분석 |
| `domains/interfaces/cli.md` | CLI 인터페이스 — 커맨드 파싱, 인자 분석 |
| `domains/interfaces/data-io.md` | Data I/O 인터페이스 — 파이프라인 탐색, 데이터 플로우 분석 |
| `domains/concerns/async-state.md` | Async state concern — 로딩/스트리밍/에러 상태 감지 |
| `domains/concerns/auth.md` | Authentication concern — 인증 플로우 감지 |
| `domains/concerns/external-sdk.md` | External SDK concern — 서드파티 API 통합 감지 |
| `domains/concerns/i18n.md` | Internationalization concern — 로케일 키 감지 |
| `domains/concerns/ipc.md` | IPC concern — 프로세스간 통신 감지 (Electron/Tauri) |
| `domains/concerns/realtime.md` | Realtime concern — WebSocket/SSE 감지 |
| `reference/speckit-compatibility.md` | reverse-spec 출력물을 spec-kit 커맨드에 매핑하는 호환성 가이드 |
| **Templates** | |
| `templates/roadmap-template.md` | 프로젝트 로드맵 아티펙트 템플릿 |
| `templates/constitution-seed-template.md` | 초기 constitution 문서 템플릿 |
| `templates/entity-registry-template.md` | 데이터 엔티티 레지스트리 템플릿 |
| `templates/api-registry-template.md` | API 엔드포인트 레지스트리 템플릿 |
| `templates/business-logic-map-template.md` | 비즈니스 규칙 문서 템플릿 |
| `templates/stack-migration-template.md` | 스택 마이그레이션 계획 템플릿 (재구축 + 새 스택) |
| `templates/coverage-baseline-template.md` | 소스 커버리지 메트릭 베이스라인 템플릿 |
| `templates/pre-context-template.md` | 런타임 탐색에서 추출한 Feature별 컨텍스트 템플릿 |
| `templates/speckit-prompt-template.md` | smart-sdd 없이 spec-kit 단독 사용을 위한 독립 프롬프트 템플릿 |

### smart-sdd (`.claude/skills/smart-sdd/`)

| 파일 | 설명 |
|------|------|
| **SKILL.md** | **스킬 라우터 — 진입점, 필수 규칙, 커맨드 라우팅 테이블** |
| **Commands** | |
| `commands/add.md` | 6단계 Feature 정의 프로세스 (문서 / 대화 / 갭 기반) |
| `commands/adopt.md` | SDD 도입 파이프라인 — 기존 코드를 재작성 없이 문서로 래핑 |
| `commands/coverage.md` | SBI 커버리지 체커 — 미매핑 동작 식별 및 갭 해소 |
| `commands/expand.md` | Tier 확장 — core scope 프로젝트에서 deferred Feature Tier 활성화 |
| `commands/init.md` | 그린필드 프로젝트 초기화 — 프로젝트 아이덴티티 및 개발 원칙 |
| `commands/parity.md` | 소스 패리티 체커 — 원본 코드 vs 구현 Feature 비교 |
| `commands/pipeline.md` | 파이프라인 실행기 — Common Protocol (Assemble → Checkpoint → Execute+Review → Update) |
| `commands/reset.md` | 파이프라인 상태 초기화 — reverse-spec 아티펙트 보존하며 클린 환경 복원 |
| `commands/status.md` | 상태 표시 — sdd-state.md에서 프로젝트 진행 상태 읽기 |
| `commands/verify-phases.md` | 4단계 검증 워크플로우 (Test/Build/Lint → 교차 Feature → Demo-Ready → Global Update) |
| **Domains** | |
| `domains/_core.md` | 범용 규칙 (S1–S7) — demo-ready 딜리버리, 버그 방지 인덱스, 조건부 규칙 |
| `domains/_resolver.md` | 프로필 해석 프로토콜 — 프로필 확장, 하위 호환성, 모듈 로딩 순서 |
| `domains/_schema.md` | 도메인 프로필 스키마 — 데모 패턴, 패리티 차원, 검증 동작 |
| `domains/app.md` | 애플리케이션 도메인 프로필 — 데모 패턴, 린트 감지 규칙, UI 테스팅, 버그 방지 |
| `domains/data-science.md` | 데이터 사이언스 도메인 프로필 템플릿 (미구현 — 의도적 TODO 스캐폴딩) |
| `domains/interfaces/gui.md` | GUI 인터페이스 — CSS 렌더링 버그, UI 인터랙션 서피스 감사, 시각적 충실도 |
| `domains/interfaces/http-api.md` | HTTP API 인터페이스 — API 호환성 매트릭스, 런타임 검증 |
| `domains/interfaces/cli.md` | CLI 인터페이스 — CLI 검증, 프로세스 러너 백엔드 |
| `domains/interfaces/data-io.md` | Data I/O 인터페이스 — 파이프라인 검증, 데이터 플로우 테스팅 |
| `domains/concerns/async-state.md` | Async state — 로딩/스트리밍 패턴, UX 동작 계약 |
| `domains/concerns/auth.md` | Authentication — 인증 플로우 패턴, 세션 관리 |
| `domains/concerns/external-sdk.md` | External SDK — 타입 신뢰 분류, API 계약 갭 감지 |
| `domains/concerns/i18n.md` | Internationalization — 완성도 검사, 로케일 키 커버리지 |
| `domains/concerns/ipc.md` | IPC — 경계 안전성, 반환값 방어 (Electron/Tauri) |
| `domains/concerns/realtime.md` | Realtime — WebSocket/SSE 연결 관리 |
| `domains/profiles/fullstack-web.md` | 프리셋: [http-api, gui] + [async-state, auth, i18n] |
| `domains/profiles/web-api.md` | 프리셋: [http-api] + [auth] |
| `domains/profiles/desktop-app.md` | 프리셋: [gui] + [async-state, ipc] |
| `domains/profiles/cli-tool.md` | 프리셋: [cli] |
| `domains/scenarios/greenfield.md` | 신규 프로젝트 — 기존 코드 없이 처음부터 파이프라인 실행 |
| `domains/scenarios/rebuild.md` | 리빌드 — preservation_level, change_scope, migration_strategy 파라미터 |
| `domains/scenarios/incremental.md` | 점진적 추가 — 기존 SDD 프로젝트에 Feature 추가 |
| `domains/scenarios/adoption.md` | SDD 도입 — 기존 코드에 SDD 문서 래핑 |
| **Reference** | |
| `reference/branch-management.md` | Git 브랜치 워크플로우 — Feature 격리 및 머지 검증 |
| `reference/clarity-index.md` | 교차 참조 명확성 메트릭 및 시그널 추출 |
| `reference/context-injection-rules.md` | 공유 패턴 — HARD STOP 체크포인트, 누락 콘텐츠 처리, 출력 억제 |
| `reference/demo-standard.md` | Demo-ready 딜리버리 표준 — 스크립트 요구사항, VERIFY_STEPS 형식, 3-tier UI 액션 |
| `reference/feature-elaboration-framework.md` | 6 관점 Feature 평가 프레임워크 — 갭 식별용 |
| `reference/restructure-guide.md` | Feature 구조 변경 체크리스트 (분할, 병합, 이동, 순서 변경, 삭제) |
| `reference/runtime-verification.md` | 런타임 검증 백엔드 레지스트리 — Playwright CLI/MCP 감지, 백엔드 분류 |
| `reference/state-schema.md` | `sdd-state.md` 스키마 — Feature 상태, Toolchain, Demo Groups, Special Flags |
| `reference/ui-testing-integration.md` | Playwright MCP 통합 가이드 — UI 검증용 |
| `reference/user-cooperation-protocol.md` | HARD STOP 인터랙션을 위한 사용자 협력 패턴 |
| **Context Injection** | |
| `reference/injection/adopt-plan.md` | Adopt plan 단계 — 기존 아키텍처를 있는 그대로 문서화 |
| `reference/injection/adopt-specify.md` | Adopt specify 단계 — 기존 코드의 SDD 문서 래핑 |
| `reference/injection/adopt-verify.md` | Adopt verify 단계 — 테스트 실패를 비차단 기존 이슈로 처리 |
| `reference/injection/analyze.md` | Analyze 단계 — implement 전 교차 아티펙트 일관성 검증 |
| `reference/injection/constitution.md` | Constitution 단계 — 시스템 원칙 및 아키텍처 결정 |
| `reference/injection/implement.md` | Implement 단계 — 소스 주입, 런타임 검증, auto-fix 루프, CSS 값 맵 |
| `reference/injection/parity.md` | Parity 커맨드 — 소스 비교를 위한 다단계 워크플로우 |
| `reference/injection/plan.md` | Plan 단계 — 인터랙션 체인, UX 동작 계약, API 호환성 매트릭스 |
| `reference/injection/specify.md` | Specify + clarify 단계 — 요구사항, SBI 교차 검증, 엣지 케이스 커버리지 |
| `reference/injection/tasks.md` | Tasks 단계 — 10개 주입 검사 (데모, 패턴 감사, 인터랙션 체인 등) |
| `reference/injection/verify.md` | Verify 단계 — 체크포인트/리뷰 표시, 파이프라인 회귀 처리 |
| **Scripts** | |
| `scripts/context-summary.sh` | 대시보드 — Feature/Entity/API/DemoGroup 요약 |
| `scripts/demo-status.sh` | 대시보드 — 데모 그룹 진행 상태 |
| `scripts/pipeline-status.sh` | 대시보드 — 파이프라인 진행 개요 |
| `scripts/sbi-coverage.sh` | 대시보드 — SBI 커버리지 매핑 |
| `scripts/validate.sh` | 교차 파일 일관성 검증기 (종료 코드로 pass/fail 표시) |

### speckit-diff (`.claude/skills/speckit-diff/`)

| 파일 | 설명 |
|------|------|
| `SKILL.md` | 스킬 라우터 — 버전 호환성 분석기 진입점 |
| `commands/diff.md` | 다단계 워크플로우 — spec-kit 소스 획득, 비교, 호환성 판정 생성 |
| `reference/integration-surface.md` | 베이스라인 참조 — 알려진 spec-kit 스킬 및 구조적 시그니처 |

### case-study (`.claude/skills/case-study/`)

| 파일 | 설명 |
|------|------|
| `SKILL.md` | 스킬 라우터 — 케이스 스터디 리포트 생성기 진입점 |
| `commands/generate.md` | 리포트 생성 — 아티펙트에서 메트릭 추출, 관찰 로그와 결합 |
| `reference/recording-protocol.md` | M1-M8 마일스톤 자동 관찰 기록 프로토콜 |
| `templates/case-study-log-template.md` | 시간순 마일스톤 기록용 관찰 로그 템플릿 |
