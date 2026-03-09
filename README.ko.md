# spec-kit-skills

[![GitHub](https://img.shields.io/badge/GitHub-coolhero%2Fspec--kit--skills-blue?logo=github)](https://github.com/coolhero/spec-kit-skills)

[English README](README.md) | [MCP 설정 가이드](MCP-GUIDE.md) | Last updated: 2026-03-10 08:35 KST

**[spec-kit](https://github.com/github/spec-kit)의 Feature-local 한계를 넘어 AI 통제 가능한 계약 기반 개발을 실현하는 Claude Code 스킬**

- **Reverse-Spec** — 브라운필드 코드베이스에서 암묵적 계약(동작·인터페이스·데이터 모델)을 역추출해 Spec으로 정렬하고, 레거시를 계약 기반 체계에 편입시킵니다. Rebuild(원본 참조, 새로 작성)과 Adopt(기존 코드 유지, SDD 문서 추가) 두 접근을 지원하며, smart-sdd 없이 spec-kit만 사용할 수 있도록 독립 프롬프트(`speckit-prompt.md`)도 함께 생성합니다.
- **Smart-SDD** — spec-kit 명령 실행 시 관련 Feature의 계약·상태를 자동 주입하고, 변경이 기존 계약을 위반하지 않는지 검증하여 Feature 간 정합성을 유지합니다.

---

## 빠른 시작

### 사전 요구사항

- [Claude Code](https://claude.ai/claude-code) CLI
- [spec-kit](https://github.com/github/spec-kit) 스킬 (`/smart-sdd` 사용 시)
- [Playwright MCP](https://github.com/microsoft/playwright-mcp) — `claude mcp add --scope user playwright -- npx @playwright/mcp@latest` — Electron CDP 설정은 [MCP 설정 가이드](MCP-GUIDE.md) 참고

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
| 기존 코드 재구축 | `/reverse-spec ./path/to/source` |
| 새 프로젝트 | `/smart-sdd init` → `/smart-sdd add` |
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

## 사용자 여정

```
── 신규 프로젝트 ─────────────────────────────────────────────────
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

### 커맨드별 컨텍스트 주입

| 커맨드 | 주입 소스 | 주입 내용 |
|--------|----------|-----------|
| `constitution` | `constitution-seed.md` | 전체 내용 (아키텍처 원칙, Best Practices, Global Evolution 운영 원칙) |
| `specify` | `pre-context.md` + `business-logic-map.md` | 기능 요약, FR/SC 초안, 비즈니스 규칙, 엣지 케이스, 소스 참조 |
| `plan` | `pre-context.md` + `entity-registry.md` + `api-registry.md` | 의존성 정보, 엔티티/API 스키마 초안 (또는 선행 Feature 확정 스키마) |
| `tasks` | `plan.md` | plan 기반 자동 실행 |
| `analyze` | `spec.md` + `plan.md` + `tasks.md` | 교차 산출물 일관성 분석 |
| `implement` | `tasks.md` + `plan.md` + `pre-context.md` | 인터랙션 체인, UX 행동 계약, API 호환성 매트릭스, 환경 변수 검증, 네이밍 리매핑, 런타임 검증 + 수정 루프 |
| `verify` | `pre-context.md` + registries + `plan.md` | 교차 Feature 엔티티/API 일관성, 인터랙션 체인 완전성, UX 행동 계약, API 호환성 매트릭스, 활성화 스모크 테스트, 영향 범위 |

**선행 Feature 결과 우선 적용**: 의존하는 선행 Feature의 plan이 완료되었으면, 레지스트리 초안 대신 확정된 `data-model.md`와 `contracts/`를 우선 참조합니다.

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

Playwright MCP를 통해 원본 앱을 실제로 실행하고 탐색. UI 레이아웃, 사용자 흐름, 실제 상태를 관찰. Electron 앱은 CDP 사전 설정 필요 — [MCP 설정 가이드](MCP-GUIDE.md) 참고.

### Phase 2 — 심층 분석

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

추가 추출: 비즈니스 로직, 모듈 간 의존성, Source Behavior Inventory, UI 컴포넌트 Feature

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
/smart-sdd init                          # 프로젝트 설정
/smart-sdd init --prd path/to/prd.md     # PRD 기반 설정

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
/smart-sdd reset                         # 파이프라인 상태 초기화
/smart-sdd status                        # 진행 상태 개요
/smart-sdd coverage                      # SBI 커버리지 확인
/smart-sdd parity                        # 원본 소스 대비 패리티 확인
```

### 네 가지 프로젝트 모드

| 측면 | 그린필드 | 점진적 추가 | 재구축 | 도입 |
|------|---------|-----------|-------|------|
| 사용 사례 | 새 프로젝트 | 기존에 추가 | 재구현 | 기존 코드 문서화 |
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
Foundation Gate (첫 번째 Feature만):
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

```
Phase 1:  실행 검증 (테스트, 빌드, 린트) — 실패 시 차단
          에코시스템별 린트 도구 감지 (미설치 시 자동 설치 제안)
Phase 2:  교차 Feature 일관성 — 엔티티/API 호환, 인터랙션 체인,
          UX 행동 계약, API 호환성 매트릭스, 활성화 스모크 테스트
Phase 3:  Demo-Ready 검증 — 실패 시 차단
          + VERIFY_STEPS 기능 테스트, 비주얼 충실도 (재구축)
Phase 3b: 버그 예방 — 빈 상태 스모크 테스트, 스모크 런치 기준
Phase 4:  Global Evolution 갱신 (레지스트리, sdd-state)
```

### Feature 완료 후 처리

| 시점 | 처리 |
|------|------|
| plan 후 | entity-registry.md, api-registry.md 갱신 |
| implement 후 | Runtime Error Zero Gate — 콘솔 에러 감지 시 차단 |
| implement 후 | 후속 Feature pre-context 영향 분석 |
| verify 후 | sdd-state.md에 결과 기록, roadmap.md 상태 갱신 |
| verify 후 | Feature 브랜치를 main에 머지 (HARD STOP) |

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

### 집계 스크립트

`.claude/skills/smart-sdd/scripts/`에 위치. smart-sdd 파이프라인 컨텍스트 내에서 사용.

| 스크립트 | 목적 |
|---------|------|
| `context-summary.sh` | Feature/Entity/API/DemoGroup 요약 |
| `sbi-coverage.sh` | SBI 커버리지 대시보드 |
| `demo-status.sh` | 데모 그룹 진행 상태 |
| `pipeline-status.sh` | 파이프라인 진행 개요 |
| `validate.sh` | 교차 파일 일관성 검사 |

## End-to-End 워크플로우 예시

### 시나리오 1: 그린필드 — 새 태스크 관리 앱

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
| 결정 이력 | `specs/history.md` |

### Feature 네이밍 규약

| 시스템 | 형식 | 예시 |
|--------|------|------|
| smart-sdd (pre-context, roadmap, state) | `F{NNN}-{short-name}` | `F001-auth` |
| spec-kit (specs/ 디렉토리, git 브랜치) | `{NNN}-{short-name}` | `001-auth` |

### 아티펙트 구조

```
specs/
├── history.md
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

### smart-sdd 없이 reverse-spec 아티펙트 사용

| 커맨드 | 호출 전 붙여넣을 내용 |
|--------|---------------------|
| `/speckit-constitution` | `constitution-seed.md` 전체 |
| `/speckit-specify` | `pre-context.md` "For /speckit.specify" + `business-logic-map.md` |
| `/speckit-plan` | `pre-context.md` "For /speckit.plan" + 레지스트리 |
| `/speckit-tasks`, `/speckit-implement` | `pre-context.md`의 Static Resources, Environment Variables 확인 |
| `/speckit-analyze` | `pre-context.md` "For /speckit.analyze" + 레지스트리 |

### 도메인 프로필

현재 **애플리케이션 개발** (backend, frontend, fullstack, mobile, library)에 최적화. 데이터 사이언스, AI/ML, 임베디드 시스템 프로필은 계획 중.

```
Core Workflow (도메인 불가지)      ← Phases, 체크포인트, 파이프라인 오케스트레이션
    ↓ reads
Domain Profile (교체 가능)        ← 분석 축, 추출 패턴, 데모/검증 규약
    ↓ applies to
Tech Stack (런타임 감지)          ← 프레임워크별 파일 패턴, ORM 타입, API 스타일
```

`--domain`으로 프로필 선택 (기본: `app`). 커스텀 프로필 생성은 `domains/_schema.md` 참고.
