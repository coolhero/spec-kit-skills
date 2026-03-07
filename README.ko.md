# spec-kit-skills

[![GitHub](https://img.shields.io/badge/GitHub-coolhero%2Fspec--kit--skills-blue?logo=github)](https://github.com/coolhero/spec-kit-skills)

[English README](README.md) | Last updated: 2026-03-07 20:49 KST

**spec-kit 기반 Spec-Driven Development(SDD) 워크플로우를 보강하는 Claude Code 커스텀 스킬 모음**

---

## 개요

[spec-kit](https://github.com/github/spec-kit) SDD 워크플로우에 **Global Evolution Layer**를 추가하는 Claude Code 커스텀 스킬 모음.

spec-kit은 강력한 SDD 프레임워크이지만, 한 번에 하나의 Feature만 처리합니다 — Feature 간 공유 엔티티 추적, API 계약 관리, 프로젝트 전체 로드맵을 이해하는 내장 메커니즘이 없습니다. **Global Evolution Layer**가 이 부재를 채웁니다: spec-kit의 Feature별 범위 위에 위치하는 프로젝트 수준의 아티펙트 세트입니다.

| 아티펙트 | 추적하는 것 |
|----------|------------|
| **Roadmap** | Feature 의존성 그래프 + 실행 순서 |
| **Entity Registry** | Feature 간 공유 데이터 모델 |
| **API Registry** | Feature 간 API 계약 및 엔드포인트 |
| **Feature별 Pre-context** | 각 Feature가 프로젝트의 나머지에 대해 알아야 할 것 |
| **Source Behavior Inventory** | 함수 수준 커버리지 추적 (기존 코드베이스용) |
| **Constitution** | 프로젝트 전역 원칙 및 아키텍처 결정 *(spec-kit 내장 — 교차 Feature 규칙으로 확장)* |

`/reverse-spec`이 기존 소스코드에서 이 아티펙트들을 **생성**하고, `/smart-sdd`가 매 spec-kit 커맨드 실행 시 이들을 **읽고 갱신**합니다.

### `/reverse-spec` — 기존 소스 → SDD-Ready 아티펙트

이미 동작하는 코드가 있는 상태에서 SDD를 적용하려 할 때, 첫 번째 난관은 **하나의 코드베이스를 어떻게 명확한 경계를 가진 Feature 단위로 쪼개는가**입니다.

`/reverse-spec`이 이 문제를 해결합니다. 기존 소스코드를 읽고 SDD에 필요한 기반을 만들어냅니다:

- **Feature 분해** — 소스 구조에서 논리적 Feature 경계를 식별하고, Feature 간 관계를 보여주는 의존성 그래프를 구성합니다
- **교차 Feature 레지스트리** — 여러 Feature에서 공유하는 엔티티(데이터 모델), API 계약(Feature 간 통신 방식), 비즈니스 로직 규칙을 프로젝트 수준의 레지스트리로 추출합니다
- **Feature별 pre-context** — 각 Feature가 소유하는 엔티티, 노출/소비하는 API, 의존하는 다른 Feature를 정리한 컨텍스트 문서를 생성합니다
- **소스 커버리지 베이스라인** — 추출된 Feature들이 원본 소스의 얼마나 많은 부분을 커버하는지 측정하여, 빠뜨린 기능이 없도록 합니다

결과물은 `/smart-sdd`가 교차 Feature 컨텍스트를 완벽하게 인식하며 spec-kit 파이프라인을 실행할 수 있게 하는 SDD-ready 아티펙트 세트입니다.

### `/smart-sdd` — 교차 Feature 컨텍스트를 갖춘 spec-kit

spec-kit은 한 번에 하나의 Feature만 처리합니다. 단일 Feature라면 문제없지만, 실제 프로젝트에서는 Feature들이 데이터 모델을 공유하고, 서로의 API를 호출하며, 순서 의존성을 갖습니다. Feature 3에 대해 `/speckit-plan`을 실행할 때, Feature 1이 정의한 데이터 모델이나 Feature 2가 기대하는 API 계약을 알 방법이 없습니다.

`/smart-sdd`는 모든 spec-kit 커맨드를 **4단계 프로토콜**로 래핑합니다:

1. **Assemble** — spec-kit 커맨드 실행 전, 관련 컨텍스트를 수집: 엔티티/API 레지스트리, 선행 Feature의 결정 사항, 의존성 제약
2. **Checkpoint** — 수집된 컨텍스트를 사용자에게 보여주고 실행 전 확인
3. **Execute + Review** — 주입된 컨텍스트와 함께 spec-kit 커맨드를 실행하고, 출력물의 교차 Feature 정합성을 검토
4. **Update** — 실행 후 새로 생성된 엔티티, API, 결정 사항으로 글로벌 레지스트리와 상태를 갱신

이로써 Feature 3의 `/speckit-plan`은 Feature 1의 `User` 엔티티에 `email`과 `role` 필드가 있다는 것과, Feature 2의 `/api/orders` 엔드포인트가 `userId` 파라미터를 기대한다는 것을 자동으로 알게 됩니다. 수동으로 교차 참조할 필요가 없습니다.

### 유틸리티

| 스킬 | 목적 |
|------|------|
| `/speckit-diff` | spec-kit 버전을 저장된 베이스라인과 비교하고 호환성 판정 + 영향 리포트를 생성합니다. spec-kit 업데이트 후 실행. |
| `/case-study` | 실행 아티펙트에서 Case Study 보고서(메트릭 + 정성적 관찰)를 생성합니다. 워크플로우 완료 후 실행. |

### 다섯 가지 사용자 여정

```
-- 신규 프로젝트 ---------------------------------------------------------------
신규 프로젝트        --> /smart-sdd init --> /smart-sdd add --> /smart-sdd pipeline
                        (프로젝트 설정)     (Feature 정의)      (구현)

-- SDD 도입 -------------------------------------------------------------------
기존 소스코드        --> /reverse-spec   --> Global Evolution Layer --> /smart-sdd adopt
(CWD에서 실행)         --adopt             (roadmap, registries,        (기존 코드 문서화)
                                          pre-context 등)

-- 재구축 (Core/Full) ----------------------------------------------------------
기존 소스코드        --> /reverse-spec   --> Global Evolution Layer --> /smart-sdd pipeline
                       (역분석)           (roadmap, registries,        (코드 재구축)
                                          pre-context 등)

-- 점진적 추가 (정상 상태) ------------------------------------------------------
기존 smart-sdd      --> /smart-sdd add  --> 갱신된 Global Evolution --> /smart-sdd pipeline
프로젝트                                    Layer
```

모든 여정은 **점진적 추가 모드**로 수렴합니다.

---

## 빠른 시작

### 사전 요구사항

- [Claude Code](https://claude.ai/claude-code) CLI 설치 필요
- [spec-kit](https://github.com/github/spec-kit) 스킬 설치 필요 (`/smart-sdd` 사용 시)

### 설치

**방법 1: 글로벌 설치 (모든 프로젝트에서 사용)**

```bash
# 레포지토리 클론
git clone https://github.com/coolhero/spec-kit-skills.git
cd spec-kit-skills

# 설치 스크립트 실행 (모든 스킬의 심볼릭 링크 자동 생성)
./install.sh
```

또는 수동으로 심볼릭 링크 생성:

```bash
ln -s /path/to/spec-kit-skills/.claude/skills/reverse-spec ~/.claude/skills/reverse-spec
ln -s /path/to/spec-kit-skills/.claude/skills/smart-sdd ~/.claude/skills/smart-sdd
ln -s /path/to/spec-kit-skills/.claude/skills/speckit-diff ~/.claude/skills/speckit-diff
ln -s /path/to/spec-kit-skills/.claude/skills/case-study ~/.claude/skills/case-study
```

**방법 2: 프로젝트 로컬 설치 (특정 프로젝트에서만 사용)**

```bash
# 프로젝트 루트에서
mkdir -p .claude/skills
cp -r /path/to/spec-kit-skills/.claude/skills/reverse-spec .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/smart-sdd .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/speckit-diff .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/case-study .claude/skills/
```

### 설치 확인

Claude Code에서 아래 명령으로 스킬이 인식되는지 확인합니다:

```
/reverse-spec --help
/smart-sdd status
```

### 첫 번째 커맨드

| 모드 | 커맨드 |
|------|--------|
| 새 프로젝트 | `/smart-sdd init` → `/smart-sdd add` |
| 기존 코드베이스 재구축 | `/reverse-spec ./path/to/source` |
| SDD 도입 | `/reverse-spec --adopt` → `/smart-sdd adopt` (소스 디렉토리에서 실행) |
| 기존 프로젝트에 추가 | `/smart-sdd add` |
| spec-kit 호환성 검사 | `/speckit-diff` |
| Case Study 보고서 생성 | `/case-study` (관찰 기록은 워크플로우 중 자동 기록) |

---

## 작동 방식

Global Evolution Layer 아티펙트([개요](#개요)에서 설명)는 아래 프로토콜을 통해 유지됩니다:

### 공통 프로토콜: Assemble → Checkpoint → Execute+Review → Update

모든 spec-kit 커맨드 실행은 이 4단계 프로토콜을 따릅니다:

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────────┐     ┌─────────────┐
│  1. Assemble │────▶│ 2. Checkpoint│────▶│  3. Execute + Review │────▶│  4. Update  │
│  컨텍스트 조립 │     │ 실행 전 확인   │     │ spec-kit 실행 + 검토  │     │ 글로벌 갱신  │
└─────────────┘     └──────────────┘     └──────────────────────┘     └─────────────┘
```

| 단계 | 설명 |
|------|------|
| **Assemble** | `specs/reverse-spec/`에서 해당 커맨드에 필요한 파일/섹션을 읽고, 커맨드별 주입 규칙에 따라 필터링하여 조립. 선행 Feature의 실제 구현 결과(`specs/{NNN-feature}/` 하위)도 함께 참조. **Graceful degradation**: 소스 파일이 없거나 섹션에 플레이스홀더("N/A", "none yet")만 있는 경우 해당 소스는 건너뜀 |
| **Checkpoint** | 조립된 컨텍스트를 **실제 내용**과 함께 사용자에게 보여주고 실행 전 승인/수정 기회 제공. 사용자가 수정을 요청하면 반영 후 재확인 |
| **Execute+Review** | 해당 spec-kit 커맨드를 실행한 후 **멈추지 않고 즉시** 생성/수정된 산출물을 사용자에게 보여줌. 승인, 수정 요청(재실행), 또는 직접 편집 가능. **HARD STOP** — Checkpoint과 동일한 규칙 적용. Execute와 Review는 하나의 연속 동작으로, 에이전트가 그 사이에서 멈추는 것을 방지 |
| **Update** | 실행 결과를 반영하여 Global Evolution Layer 파일을 갱신. `sdd-state.md`에 진행 상태 기록 |

### 커맨드별 컨텍스트 주입

각 spec-kit 커맨드 실행 전에 어떤 정보가 자동으로 주입되는지 정리합니다:

| 커맨드 | 주입 소스 | 주입 내용 |
|--------|----------|-----------|
| `constitution` | `constitution-seed.md` | 전체 내용 (소스 참조 원칙, 아키텍처 원칙, Best Practices, Global Evolution 운영 원칙) |
| `specify` | `pre-context.md` "For /speckit.specify" + `business-logic-map.md` | 기능 요약, FR-### 초안, SC-### 초안, 비즈니스 규칙, 엣지 케이스, 원본 소스 참조. **business-logic-map.md가 없으면 (greenfield/add) 비즈니스 로직 주입 생략** |
| `plan` | `pre-context.md` "For /speckit.plan" + `entity-registry.md` + `api-registry.md` | 의존성 정보, 엔티티/API 스키마 초안 (또는 선행 Feature의 확정 스키마), 기술 결정. **레지스트리가 비어 있으면 (초기 greenfield) 레지스트리 주입 생략** |
| `tasks` | `plan.md` (spec-kit 산출물) | plan 기반 자동 실행. 추가 주입 없음 |
| `analyze` | `spec.md` + `plan.md` + `tasks.md` (spec-kit 산출물) | 교차 산출물 일관성 분석 (갭, 중복, 모호성). implement 전에 실행 |
| `implement` | `tasks.md` + `pre-context.md` (Static Resources, Environment Variables, Naming Remapping) | tasks 기반 자동 실행. 사전 확인: 정적 리소스 복사, 환경 변수 존재 검증 (미설정 시 HARD STOP), 네이밍 리매핑 컨텍스트. Demo-Ready Delivery 활성 시 데모 스크립트 생성 |
| `verify` | `pre-context.md` "For /speckit.analyze" + registries | 교차 Feature 엔티티/API 일관성, 영향 범위 분석 |

**선행 Feature 결과 우선 적용**: 의존하는 선행 Feature의 plan이 이미 완료되었으면, entity-registry/api-registry의 초안 대신 `specs/{NNN-feature}/`에 있는 **확정된 data-model.md와 contracts/**를 우선 참조합니다.

---

## 스킬 상세

### 1. `/reverse-spec` --- 기존 소스코드 역분석 및 Global Evolution Layer 추출

기존 소스코드를 분석하여, spec-kit 기반 SDD 재개발에 필요한 **프로젝트 수준의 글로벌 컨텍스트**를 추출하는 스킬입니다.

#### 핵심 가치

- 기존 코드의 엔티티, API, 비즈니스 로직, 모듈 의존성을 **자동 역추출**
- **Core scope**: Feature 단위로 분류하고, **5축 분석 기반 Tier 자동 추천** (Tier 1 필수 / Tier 2 권장 / Tier 3 선택)으로 점진적 개발
- **Full scope**: Tier 분류 없이 **순수 의존성 기반 순서**로 모든 Feature를 동등하게 처리
- spec-kit 각 커맨드에서 바로 활용 가능한 **계층형 산출물** 생성

#### 사용법

```bash
/reverse-spec [target-directory] [--scope core|full] [--stack same|new] [--name new-project-name]
```

인자를 생략하면 현재 디렉토리를 대상으로 분석합니다.

| 옵션 | 설명 |
|------|------|
| `--scope core` | 구현 범위를 Core로 설정 (대화형 프롬프트 생략) |
| `--scope full` | 구현 범위를 Full로 설정 (대화형 프롬프트 생략) |
| `--stack same` | 기존과 동일한 기술 스택 사용 (대화형 프롬프트 생략) |
| `--stack new` | 신규 기술 스택으로 전환 (대화형 프롬프트 생략) |
| `--name <name>` | 신규 프로젝트명 설정 (기존 프로젝트명 → 새 브랜드명으로 리네이밍) |

#### 실행 워크플로우

##### Pre-Phase --- Git 저장소 세팅

분석 시작 전 출력 디렉토리(CWD)에 git 저장소가 있는지 확인합니다. git repo가 없으면 프로젝트 기술 스택에 맞는 `.gitignore`와 함께 초기화합니다. 선택적으로 SDD 작업을 위한 별도 브랜치(예: `sdd-setup`)를 생성할 수 있습니다. 이미 git repo가 있으면 초기화를 건너뛰고 브랜치 옵션만 제공합니다.

##### Phase 0 --- 전략 질문

스킬 실행 시 두 가지 전략적 질문을 통해 산출물의 방향을 결정합니다. 대화형으로 답하거나 CLI 인자(`--scope`, `--stack`)로 미리 지정할 수 있습니다:

**질문 1: 구현 범위**

| 옵션 | 설명 |
|------|------|
| **Core** | 프로젝트의 근간이 되는 핵심 기능만 재개발. 학습/프로토타이핑 목적 |
| **Full** | 기존과 동일한 전체 기능을 재개발 |

**질문 2: 기술 스택 전략**

| 옵션 | 설명 | 소스코드 참조 방식 |
|------|------|-------------------|
| **Same** (동일 스택) | 기존과 동일한 언어, 프레임워크, 라이브러리 사용 | **Implementation Reference** --- 기존 구현 패턴을 적극 재활용. 다르게 설계 시 변경 사유를 명시 |
| **New** (신규 스택) | 최적의 현대적 기술 스택으로 전환 | **Logic-Only Reference** --- What/Why만 추출. How(구현 방식)는 무시하고 신규 스택의 관용적 패턴을 우선 |

**Question 3: 프로젝트 아이덴티티** (rebuild 전용) -- 새 프로젝트 이름이 원본과 다른 경우(예: "Cherry Studio" → "Angdu Studio"), 네이밍 접두어 매핑을 수집하여 모든 산출물에 적용합니다. 커버리지 베이스라인 분류 시 원본 프로젝트 고유 이름이 표시되어 리네이밍 대상으로 안내됩니다.

##### Phase 1 --- 프로젝트 스캔

대상 디렉토리의 전체 구조와 기술 스택을 자동 파악합니다.

- **디렉토리 구조 탐색**: 주요 소스 파일 패턴 (`**/*.{py,js,ts,jsx,tsx,java,go,rs,...}`) 탐색
- **기술 스택 자동 감지**: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `build.gradle` 등 설정 파일에서 언어/프레임워크/DB/테스트/빌드 도구 식별
- **프로젝트 타입 판별**: backend, frontend, fullstack, mobile, library
- **모듈/패키지 경계 식별**: 논리적 모듈 경계, 모노레포 워크스페이스 인식

##### Phase 2 --- 심층 분석

기술 스택에 맞는 패턴으로 코드를 심층 분석합니다. 대규모 코드베이스의 경우 병렬 서브에이전트를 활용합니다.

**데이터 모델 추출**:

| 기술 | 탐색 대상 |
|------|-----------|
| Django | `models.py`, migrations |
| SQLAlchemy/FastAPI | 모델 클래스, Alembic migrations |
| TypeORM/Prisma | 엔티티 클래스, `schema.prisma` |
| JPA/Hibernate | `@Entity` 클래스 |
| Mongoose | Schema 정의 |
| Sequelize | 모델 정의, 마이그레이션 |
| Rails | `app/models/`, migrations |
| Go | 구조체 정의 + DB 태그 (GORM, sqlx) |

각 엔티티에서 추출하는 정보: 필드(이름, 타입, 제약조건), 관계(1:1, 1:N, M:N), 유효성 검증 규칙, 상태 전이, 인덱스

**API 엔드포인트 추출**:

| 기술 | 탐색 대상 |
|------|-----------|
| Express/Fastify | 라우터 파일, `router.get()` 등 |
| Django/DRF | `urls.py`, ViewSet, APIView |
| FastAPI | `@app.get()`, `@router.post()` 데코레이터 |
| Spring | `@RequestMapping`, `@GetMapping` 등 |
| Next.js/Nuxt | `pages/api/`, `app/api/` 디렉토리 |
| Rails | `config/routes.rb`, 컨트롤러 |
| Go (net/http, Gin, Echo) | 라우터 등록, 핸들러 함수 |

각 엔드포인트에서 추출하는 정보: HTTP 메서드/경로, 요청/응답 스키마, 인증/인가 요구사항, 미들웨어

**비즈니스 로직 추출**: 비즈니스 규칙, 유효성 검증, 다단계 워크플로우, 외부 연동

**모듈 간 의존성 매핑**: import/require 분석, 서비스 호출 관계, 공유 유틸리티, 이벤트 기반 결합

**소스 행위 인벤토리**: 소스 파일별 export/public 함수, 메서드, 핸들러를 우선순위(P1 핵심 / P2 중요 / P3 선택)와 함께 기록. specify 시 모든 주요 행위가 FR-###에 매핑되도록 보장하여 기능 누락 방지

**UI 컴포넌트 기능 추출** (프론트엔드/풀스택 전용): 서드파티 UI 라이브러리(에디터, 차트, 캘린더 등)가 제공하는 사용자 대면 기능(툴바 항목, 플러그인, 편집 모드)을 추출. 이러한 기능은 라이브러리 설정/옵션으로 활성화되어 함수 수준 분석에서는 보이지 않지만, 상당한 사용자 대면 기능을 구현함

##### Phase 3 --- Feature 분류 및 중요도 분석

분석 결과를 기반으로 논리적 기능 단위(Feature)를 식별합니다.

**Feature 세분화 수준 선택**: Feature 경계를 식별한 후, `/reverse-spec`은 2~3가지 세분화 수준(Coarse/Standard/Fine)을 각 수준별 구체적인 Feature 목록과 함께 제시합니다. 사용자는 프로젝트 목표, 팀 규모, 원하는 반복 속도에 따라 적절한 분해 수준을 선택합니다. 이를 통해 Feature 수와 범위가 프로젝트의 요구에 맞게 조정됩니다.

의존성 그래프를 구성한 후 **Feature ID(F001, F002, ...)**는 scope에 따라 배정됩니다:

- **Full scope**: 순수 위상정렬 순서(의존성 기반) — Tier 분류 없음
- **Core scope**: Tier별로 그룹화(Tier 1 → Tier 2 → Tier 3)한 뒤 각 Tier 내에서 위상정렬 순서

**Tier 분류 (Core Scope 전용)**:

> Full scope에서는 이 단계가 완전히 생략됩니다. 모든 Feature를 동등하게 취급하고 의존성 토폴로지 순서로 정렬합니다.

Core scope에서는 각 Feature를 **5가지 분석 축**으로 종합 평가합니다:

| 분석 축 | 판단 기준 |
|---------|-----------|
| **구조적 근간** | 다른 Feature들이 이 Feature 없이 존재할 수 없는가. 피의존 횟수, import 깊이, 공유 엔티티 소유 수 |
| **도메인 핵심** | 프로젝트의 존재 이유와 직결되는 기능인가. 프로젝트 도메인에서의 역할 (예: e-commerce면 상품/주문이 핵심) |
| **데이터 소유권** | 핵심 엔티티를 정의하고 관리하는 기능인가. 소유 엔티티 수, 다른 Feature에서 참조되는 비율 |
| **통합 허브** | 다른 Feature/외부 시스템과의 연결 지점인가. API provider 역할, 외부 연동 수 |
| **비즈니스 복잡도** | 핵심 비즈니스 규칙이 집중된 기능인가. 비즈니스 규칙 수, 상태 전이, 유효성 검증 복잡도 |

종합 평가 결과로 각 Feature를 **Tier 3단계**로 분류합니다:

| Tier | 의미 | 기준 |
|------|------|------|
| **Tier 1 (필수)** | 프로젝트의 근간. 이것 없이는 시스템이 성립하지 않음 | 재개발 시 반드시 포함 |
| **Tier 2 (권장)** | 핵심 사용자 경험을 완성하는 기능 | 없어도 동작하지만 핵심 가치가 크게 저하 |
| **Tier 3 (선택)** | 부가 기능, 관리 도구, 편의 기능 | 이후 단계에서 추가 가능 |

각 Feature에 대해 해당 Tier로 분류한 **구체적 이유**를 반드시 제시합니다. 예:
- "인증(Auth)을 Tier 1로 추천: 7개 Feature가 직접 의존, User 엔티티의 소유자, 모든 API의 미들웨어로 사용됨"
- "알림(Notification)을 Tier 3으로 추천: 독립적 모듈로 다른 Feature에 피의존 없음, 이벤트 구독 방식으로 느슨하게 결합"

##### Phase 4 --- 산출물 생성

확정된 분석 결과로 계층형 산출물을 생성합니다: `roadmap.md`, `constitution-seed.md`, 레지스트리, Feature별 `pre-context.md` 파일 등.

**소스 커버리지 베이스라인 (Phase 4-3, rebuild 전용)**:

산출물 생성 후, `/reverse-spec`는 원본 소스 코드가 추출된 Feature들에 얼마나 반영되었는지 측정합니다. 소스 파일, API 엔드포인트, DB 엔티티, 테스트 파일을 자동 스캔하여 커버리지 비율을 계산합니다:

| 항목 | 원본 | 매핑됨 | 커버리지 |
|------|------|--------|----------|
| 소스 파일 | 1,720 | 812 | 47.2% |
| API 엔드포인트 | 24 | 25 | 96.0% |
| DB 테이블 | 12 | 12 | 100% |
| 테스트 파일 | 214 | 0 | 0% |

*(실제 프로젝트 예시)*

매핑되지 않은 항목은 논리적 카테고리(예: 공유 UI 컴포넌트, 유틸리티, 훅)별로 그룹화되어 **대화형 분류**로 제시됩니다 — 사용자가 각 그룹에 대해 결정합니다:
- **횡단 관심사**로 표시 (constitution에 기록)
- **기존 Feature에 할당**
- **새 Feature 생성**
- **의도적 제외**로 표시 (사유 코드 포함)

결과는 `coverage-baseline.md`로 저장되며, 파이프라인 완료 후 [패리티 검사](#패리티-검사-brownfield-rebuild)에서 구현 누락을 감지하는 데 활용됩니다.

#### 산출물 구조

전체 디렉토리 구조는 아래 [Global Evolution Layer 산출물 구조](#global-evolution-layer-산출물-구조) 참조. 주요 산출물: `roadmap.md`, `constitution-seed.md`, `entity-registry.md`, `api-registry.md`, `business-logic-map.md`, Feature별 `pre-context.md` (`features/` 하위).

#### 산출물 상세

**프로젝트 수준 산출물:**

| 산출물 | 역할 | spec-kit 활용 |
|--------|------|--------------|
| `roadmap.md` | 전체 Feature 진화 맵. Tier별 Feature Catalog, Dependency Graph, Release Groups, Cross-Feature 의존성 매핑 | Feature 진행 순서 결정, 의존성 확인 |
| `constitution-seed.md` | 기존 코드에서 추출한 아키텍처 원칙, 기술 제약, 코딩 컨벤션 + 프로젝트 특성 기반 추천 원칙 (도메인/아키텍처/스케일 특성에서 도출) + 권장 Best Practices (TDD, Simplicity First 등) + 소스코드 참조 전략 (스택별 분기) | `/speckit-constitution` 실행 시 초안으로 사용 |
| `entity-registry.md` | 전체 엔티티 목록, 필드, 관계, 유효성 규칙, Feature 간 공유 매핑. Mermaid 상태 다이어그램 포함 | `/speckit-plan` 시 `data-model.md` 작성의 교차 참조 |
| `api-registry.md` | 전체 API 엔드포인트 인덱스, 상세 계약 (Request/Response 스키마), Cross-Feature 의존성 | `/speckit-plan` 시 `contracts/` 작성의 교차 참조 |
| `business-logic-map.md` | Feature별 비즈니스 규칙, 유효성 검증, 워크플로우 (순서도), Cross-Feature 규칙 | `/speckit-specify` 시 요구사항/수용 기준 누락 방지 |

**Feature 수준 산출물 --- `pre-context.md`:**

각 Feature별로 spec-kit의 3개 핵심 커맨드에 필요한 정보를 섹션별로 미리 준비합니다:

| 섹션 | 대상 커맨드 | 내용 |
|------|-----------|------|
| Source Reference | 전체 | 관련 원본 파일 목록 + 스택 전략별 참조 가이드 (Implementation Reference vs Logic-Only Reference) |
| Source Behavior Inventory | `/speckit-specify`, verify | 함수 수준 행위 목록 (P1/P2/P3 우선순위) — FR-### 커버리지 보장 |
| UI Component Features | `/speckit-specify`, `/speckit-plan`, parity | 서드파티 UI 라이브러리 기능 (툴바, 플러그인, 편집 모드) |
| Static Resources (정적 리소스) | 전체 | 이 Feature가 사용하는 비코드 파일 (이미지, 폰트, i18n 등)의 소스/타겟 경로 |
| Environment Variables (환경 변수) | 전체 | 이 Feature가 런타임에 필요한 변수 (Feature 소유 + 공유) |
| For /speckit.specify | `/speckit-specify` | 기존 기능 요약, 사용자 시나리오, 요구사항 초안 (FR-###), 수용 기준 초안 (SC-###), 엣지 케이스 |
| For /speckit.plan | `/speckit-plan` | 선행 Feature 의존성, 소유/참조 엔티티 스키마 초안, 제공/소비 API 계약 초안, 기술적 결정사항 |
| For /speckit.analyze | `/speckit-analyze` | 교차 Feature 검증 포인트 (엔티티 호환성, API 계약 호환성, 비즈니스 규칙 일관성), 변경 시 영향 범위 |

---

### 2. `/smart-sdd` --- spec-kit SDD 워크플로우 오케스트레이터

spec-kit 커맨드를 **감싸서(wrapping)** 실행하며, 각 단계에 교차 Feature 컨텍스트를 자동 주입하고 Global Evolution Layer를 유지보수하는 스킬입니다. 네 가지 프로젝트 모드를 지원합니다:

- **Greenfield**: `/smart-sdd init`으로 신규 프로젝트를 처음부터 구성
- **Brownfield (incremental)**: `/smart-sdd add`로 기존 smart-sdd 프로젝트에 Feature 추가
- **Brownfield (rebuild)**: `/reverse-spec` 산출물 기반으로 `/smart-sdd pipeline` 실행
- **Brownfield (adoption)**: `/reverse-spec --adopt` → `/smart-sdd adopt`으로 기존 코드를 SDD 문서로 래핑

#### 핵심 가치

- spec-kit 커맨드를 **대체하지 않고 감싸는** 방식으로, spec-kit의 업데이트에 영향받지 않음
- **다섯 가지 사용자 여정**: 신규(`init`), SDD 도입(`adopt`), 점진적 추가(`add`), 코어 재구축(`pipeline --scope core`), 전체 재구축(`pipeline`)
- 각 커맨드 실행 전에 필요한 교차 Feature 정보를 **자동 조립하여 주입**
- Feature 완료 시 Global Evolution Layer (entity-registry, api-registry, roadmap, 후속 pre-context)를 **자동 갱신**
- 전체 진행 상태를 `sdd-state.md`로 **체계적 추적**

#### 사용법

```bash
# Greenfield --- 신규 프로젝트 구성 + Feature 정의
/smart-sdd init                          # 프로젝트 설정 → add로 Feature 정의 안내
/smart-sdd init --prd path/to/prd.md     # PRD 기반: 프로젝트 메타 추출 후 add에서 Feature 추출

# Feature 추가 (범용 --- 모든 모드에서 사용)
/smart-sdd add                           # 대화형으로 새 Feature 정의 및 추가
/smart-sdd add --prd path/to/req.md      # 요구사항 문서에서 Feature 정의
/smart-sdd add --gap                     # 갭 커버: 미매핑 SBI/패리티 갭에서 Feature 제안

# SDD 도입 -- 기존 코드를 SDD 아티펙트로 문서화
/smart-sdd adopt                        # 도입 파이프라인: specify → plan → analyze → verify
/smart-sdd adopt --from ./path          # 지정된 경로에서 아티펙트 읽기

# Pipeline 모드 --- 전체 순차 진행 (init, add, reverse-spec 이후 실행)
/smart-sdd pipeline                      # 매 단계 확인
/smart-sdd pipeline --from ./path        # 지정 경로에서 산출물 읽기
/smart-sdd pipeline --start implement    # implement 단계부터 시작 (전체 Feature)
/smart-sdd pipeline --start verify       # verify 단계부터 시작 (전체 Feature)

# Step 모드 --- 특정 Feature의 특정 단계만 실행
/smart-sdd constitution                  # constitution 확정 (최초 1회)
/smart-sdd specify F001                  # F001 Feature specify
/smart-sdd plan F001                     # F001 Feature plan
/smart-sdd tasks F001                    # F001 Feature tasks
/smart-sdd analyze F001                  # F001 교차 산출물 일관성 분석 (implement 전)
/smart-sdd implement F001               # F001 Feature implement
/smart-sdd verify F001                   # F001 Feature 검증

# Feature 구조 변경 --- 파이프라인 중 Feature 정의 수정
/smart-sdd restructure                   # 대화형: Feature 분할, 병합, 이동, 순서 변경, 삭제

# Scope 확장 (brownfield rebuild에서 scope=core 사용 시)
/smart-sdd expand                        # 대화형: 활성화할 Tier 선택
/smart-sdd expand T2                     # Tier 2 Feature 활성화
/smart-sdd expand T2,T3                  # Tier 2, Tier 3 Feature 활성화
/smart-sdd expand full                   # 보류된 모든 Feature 활성화

# 파이프라인 상태 초기화 (smart-sdd를 처음부터 다시 시작)
/smart-sdd reset                         # 파이프라인 초기화, reverse-spec 산출물 + 로그 보존
/smart-sdd reset --all                   # 전체 초기화 (case-study-log + history.md 파이프라인 항목 포함)

# 상태 확인
/smart-sdd status                        # 전체 진행 상태 조회

# SBI 커버리지 확인 (rebuild/adoption 전용)
/smart-sdd coverage                      # SBI 커버리지 확인 및 갭 대화형 해소

# 패리티 검사 (brownfield rebuild 전용 — 파이프라인 완료 후)
/smart-sdd parity                        # 원본 소스 대비 패리티 검사
/smart-sdd parity --source ./old-project # 소스 경로 명시적 지정

# spec-kit 호환성 검사 (독립 실행 — 어떤 세션에서든 가능)
/speckit-diff                            # GitHub에서 최신 spec-kit을 자동 clone하여 비교
/speckit-diff --local ./spec-kit-repo    # 로컬 spec-kit 소스와 비교
/speckit-diff --output report.md         # 리포트를 파일로 저장

```

#### 네 가지 프로젝트 모드

| 모드 | 커맨드 | 사용 시점 | Global Evolution Layer 생성 방식 | Feature 세분화 | Scope | 다음 단계 |
|------|--------|----------|--------------------------------|--------------|-------|----------|
| **Greenfield** | `/smart-sdd init` → `/smart-sdd add` | 신규 프로젝트를 처음부터 시작할 때 | init으로 프로젝트 설정 + constitution, add로 Feature 정의 | add에서 Feature별 정의 | 항상 Full | `/smart-sdd pipeline` |
| **Brownfield (incremental)** | `/smart-sdd add` | 기존 smart-sdd 프로젝트에 새 기능을 추가할 때 | 기존 산출물에 새 Feature 추가. roadmap, pre-context 갱신 | N/A (기존 Feature에 추가) | 기존 scope 유지 | `/smart-sdd pipeline` 또는 `/smart-sdd specify F00N` |
| **Brownfield (rebuild)** | `/reverse-spec` | 기존 소스코드를 전체 재개발할 때 | 기존 코드 역분석으로 전체 산출물 자동 생성 | Coarse/Standard/Fine 중 선택 | Core 또는 Full. `/smart-sdd expand`로 확장 가능 | `/smart-sdd pipeline` |
| **Brownfield (adoption)** | `/reverse-spec --adopt` → `/smart-sdd adopt` | 기존 코드를 유지하면서 SDD 거버넌스 문서로 래핑할 때 | `--adopt` 플래그로 역분석 후 문서 자동 생성 | N/A (기존 코드 그대로) | 항상 Full | `/smart-sdd adopt` (specify→plan→analyze→verify, tasks/implement 없음) |

#### 모드별 실제 차이점

네 가지 모드의 핵심적인 차이는 **시작 시점에 얼마나 많은 컨텍스트가 준비되어 있는가**입니다:

- **Brownfield (rebuild)**는 가장 풍부한 초기 컨텍스트를 가집니다. `/reverse-spec`가 기존 코드베이스 전체를 분석하여 엔티티, API, 비즈니스 규칙, Feature 간 의존성을 Global Evolution Layer에 추출합니다. 파이프라인 실행 시 각 단계에 처음부터 초안 요구사항, 스키마 참조, 교차 Feature 컨텍스트가 주입됩니다. 이것은 **정제 기반(refinement-based)** 워크플로우입니다 --- spec-kit이 미리 채워진 초안을 정제합니다.

- **Greenfield**는 최소한의 컨텍스트에서 시작합니다. `/smart-sdd init`이 빈 엔티티/API 레지스트리와 간소화된 pre-context 파일(FR/SC 초안 없음, business logic map 없음)로 프로젝트 구조를 생성합니다. 파이프라인은 **생성 기반(generative)**입니다 --- spec-kit이 요구사항, 스키마, 계약을 처음부터 만듭니다. 각 Feature의 `plan` 단계가 완료될 때마다 레지스트리가 확장되어 후속 Feature에 컨텍스트를 제공합니다. 따라서 greenfield에서는 Feature 순서가 더 중요합니다.

- **Brownfield (incremental)**은 기존 프로젝트의 컨텍스트를 상속합니다. `/smart-sdd add`로 새 Feature를 생성하면 이미 채워진 레지스트리와 완료된 Feature 산출물을 즉시 참조할 수 있습니다. 가장 간단한 모드입니다.

- **Brownfield (adoption)**은 기존 코드를 그대로 유지하면서 SDD 거버넌스 문서로 래핑합니다. `/reverse-spec --adopt`로 Global Evolution Layer를 추출한 뒤 `/smart-sdd adopt`이 문서 전용 파이프라인(specify → plan → analyze → verify, tasks/implement 없음)을 실행합니다. 테스트 실패는 기존 이슈로 기록되며 비차단입니다. Feature 상태는 `completed`가 아닌 `adopted`로 표시됩니다.

실제 차이 요약:

| 항목 | Greenfield | Brownfield (rebuild) |
|------|-----------|---------------------|
| 시작 시 엔티티/API 레지스트리 | 비어 있음 --- Feature plan 완료 시 점진적으로 채워짐 | 코드베이스 분석에서 미리 채워짐 |
| pre-context의 FR/SC 초안 | 없음 --- spec-kit이 처음부터 생성 | 기존 코드에서 추출 --- spec-kit이 정제 |
| Business logic map | 사용 불가 | 사용 가능 --- specify 시 주입 |
| 초기 Feature의 교차 Feature 컨텍스트 | 제한적 --- 의존성 정보만 | 풍부 --- 레지스트리의 전체 엔티티/API 스키마 |
| 파이프라인 순서 민감도 | 높음 --- 후속 Feature는 선행 Feature의 plan 완료 필요 | 낮음 --- 레지스트리가 이미 존재 |

#### Feature 정의 흐름 (`add`)

`/smart-sdd add`는 모든 모드(greenfield, incremental, rebuild)에서 사용하는 **범용 Feature 정의 커맨드**입니다. 구조화된 6-Phase 컨설팅으로 사용자를 안내합니다:

```
Phase 1: Feature 정의        — 사용자 준비도에 맞춘 적응형 컨설팅
Phase 2: 중첩 & 영향 분석     — 기존 Feature와의 중복 검사 + constitution 영향 체크
Phase 3: 범위 협의            — 단일/분할 Feature, Tier 할당 (core scope)
Phase 4: SBI 매칭 + 확장      — 소스 행위 매핑/생성 (rebuild/adoption만)
Phase 5: Demo Group          — Demo Group 배정
Phase 6: 확정                — 아티펙트 생성, roadmap/sdd-state 갱신
```

**3가지 진입 유형** (Phase 1): Feature 정의를 시작하는 방식에 맞춰 조정합니다:
- **Type 1 — 문서 기반**: `--prd path/to/doc.md` → 문서 파싱, Feature 후보 추출
- **Type 2 — 대화형**: 기본값 → 대화형 Q&A, 막연한 아이디어에서 구체적 정의까지 점진적 구체화
- **Type 3 — 갭 커버**: `--gap` → 미매핑 SBI/패리티 갭 분석, 클러스터링으로 Feature 후보 자동 제안

세 가지 유형 모두 **공통 Elaboration 단계**로 수렴합니다. [Feature Elaboration Framework](/.claude/skills/smart-sdd/reference/feature-elaboration-framework.md)의 6가지 관점(사용자 & 목적, 기능, 데이터, 인터페이스, 품질, 경계)으로 정의를 평가합니다. 도메인별 추가 질문은 `domains/{domain}.md` § 5에서 로드됩니다.

**자동 갭 감지**: rebuild/adoption 프로젝트에서 `--prd`나 `--gap`이 지정되지 않았을 때 미매핑 소스 행위가 발견되면, 갭 커버 모드로 전환을 자동 제안합니다.

**중첩 보호** (Phase 2): Feature 기능 중복, 엔티티 소유권 충돌, API 경로 충돌을 방지합니다. 새 Feature가 constitution에 포함되지 않은 기술을 도입하는지도 체크합니다. "기존 Feature 확장" 감지도 여기서 흡수합니다 (이전에는 별도 유형이었음).

**SBI 확장** (Phase 4): rebuild/adoption 프로젝트에서 미매핑 소스 행위를 새 Feature에 매핑합니다. 사용자가 원본 소스에 없는 **NEW 행위**(Origin=`new`)를 정의할 수도 있습니다 — 이 항목은 원본 커버리지 메트릭을 오염시키지 않도록 별도 추적됩니다. Type 3 Feature는 사전 매핑 상태로 도착합니다.

**Init 체이닝**: `init`이 프로젝트 설정을 완료한 후 "Feature를 지금 정의하시겠습니까?"를 묻습니다. Yes면 add 흐름으로 직접 진입하여 `/smart-sdd add`를 별도로 실행할 필요가 없습니다.

**세션 복원력**: 초안 파일(`specs/add-draft.md`)이 Phase 1-5 동안 유지됩니다. 세션이 중단되면 다음 `add` 호출 시 초안을 감지하여 이어가기 또는 새로 시작을 제안합니다.

#### 소스 행위 커버리지 (SBI 추적)

재구축 및 도입 프로젝트에서 `/reverse-spec`는 Source Behavior Inventory의 각 행위에 고유 ID(B001, B002, ...)를 할당합니다. 이 ID를 통해 파이프라인 전체에서 추적이 가능합니다:

```
reverse-spec SBI (B###) → specify FR (FR-###) → implement → verify → 커버리지 갱신
```

`spec.md`의 각 FR에는 소스 태그가 포함됩니다 (예: `FR-001: 이메일 로그인 [source: B001]`). verify 후 `sdd-state.md`에서 커버리지를 추적합니다: P1 행위는 scope 모드와 관계없이 100% 매핑이 필수입니다.

**무엇이 추출되나?** 도메인 프로필(`domains/app.md` § Source Behavior Inventory)이 추출 대상, 우선순위 분류 규칙(P1/P2/P3), 기술 스택별 스캔 패턴을 정의합니다. 기본 `app` 프로필은 exported functions, public methods, request handlers, event listeners, middleware, CLI commands를 추출합니다.

**SBI 추출 확장**: 도메인 프로필을 편집하여 프로젝트 패턴에 맞는 추출 대상을 추가하세요. 예를 들어, `GraphQL resolvers`, `WebSocket handlers`, `cron jobs`, `database triggers`, `state machine transitions`, `authorization policies` 등을 추가하면 `/reverse-spec`가 소스 분석 시 해당 패턴도 스캔합니다. 새 도메인용 프로필을 만들려면 `domains/_schema.md`의 스키마를 따르세요.

`/smart-sdd coverage`로 언제든 현재 SBI 커버리지를 확인하고 갭을 대화형으로 해결할 수 있습니다.

#### 데모 계층화

Feature들은 다중 Feature 통합 테스트를 위해 Demo Group으로 그룹화됩니다:

| 계층 | 트리거 | 범위 |
|------|--------|------|
| **Feature 데모** | 각 Feature verify 완료 시 | 단일 Feature 기능 |
| **Integration 데모** | Demo Group 내 모든 Feature verify 완료 시 | 사용자 시나리오 — 다중 Feature 여정 |

Demo Group은 `/reverse-spec` Phase 3에서 정의되며 `roadmap.md`에 저장됩니다. 그룹 내 마지막 Feature가 verify를 완료하면 Integration Demo가 트리거됩니다.

#### 집계 스크립트

5개의 읽기 전용 bash 스크립트가 아티펙트 데이터를 사전 집계하여 에이전트 컨텍스트 소모를 줄입니다:

| 스크립트 | 목적 | 사용처 |
|----------|------|--------|
| `context-summary.sh` | Feature/Entity/API/DemoGroup 요약 | `add` Phase 2 |
| `sbi-coverage.sh` | SBI 커버리지 대시보드 + `--filter` | `add` Phase 4, verify 후처리 |
| `demo-status.sh` | Demo Group 진행 현황 | `add` Phase 5, verify 후처리 |
| `pipeline-status.sh` | 파이프라인 진행 개요 | 세션 시작 시 |
| `validate.sh` | 교차 파일 일관성 검사 | 아티펙트 갱신 후 |

#### Feature 구조 변경

파이프라인 실행 중 Feature 정의를 수정해야 할 때 `/smart-sdd restructure`를 사용합니다. 분할, 병합, 요구사항 이동, 의존성 변경, 삭제를 지원하며, 모든 변경사항은 관련 아티펙트(roadmap, 레지스트리, pre-context, sdd-state)에 자동 전파됩니다. 실행 전 사용자 승인을 받습니다.

#### Pipeline 모드 상세

`/smart-sdd pipeline` 실행 시 전체 워크플로우를 순차적으로 진행합니다:

```
Phase 0: Constitution 확정
    └─ constitution-seed.md 기반으로 /speckit-constitution 실행

Phase 1~N: Release Group 순서대로 Feature 진행
    └─ 각 Feature마다:
       0. pre-flight → main 브랜치 확인 (클린 상태)
       1. specify  → (pre-context + business-logic-map 주입) → /speckit-specify
                     (spec-kit이 Feature 브랜치 자동 생성: {NNN}-{short-name})
       2. clarify  → spec에 [NEEDS CLARIFICATION]이 있을 때만 /speckit-clarify
       3. plan     → (pre-context + entity-registry + api-registry 주입) → /speckit-plan
       4. tasks    → /speckit-tasks (+ Demo-Ready 활성화 시 데모 작업 주입 체크)
       5. analyze  → /speckit-analyze (implement 전 교차 산출물 일관성 검증)
       6. implement → Feature별 환경 변수 확인 (필수 변수 누락 시 HARD STOP) → /speckit-implement
       7. verify   → 4단계 검증 (실행 검증 + 교차-Feature 일관성 + Demo-Ready 검증 + Global Evolution 갱신)
       8. merge    → Checkpoint (HARD STOP) → Feature 브랜치를 main에 머지
```

> **`add` (incremental) 모드 참고**: `/smart-sdd add` 이후 pipeline을 실행하면 constitution이 이미 존재하므로 Phase 0을 건너뛰고 pending 상태의 Feature부터 바로 진행합니다.

#### Feature 진행 중 자동 처리

각 파이프라인 단계 완료 시 smart-sdd가 자동으로 수행하는 작업:

| 시점 | 처리 항목 | 내용 |
|------|-----------|------|
| **plan 이후** | entity-registry.md 갱신 | plan에서 확정된 `data-model.md`의 새 엔티티/변경사항 반영 |
| **plan 이후** | api-registry.md 갱신 | plan에서 확정된 `contracts/`의 새 API/변경사항 반영 |
| **implement 이후** | roadmap.md 업데이트 | 해당 Feature 구현 상태 반영 |
| **implement 이후** | 후속 Feature pre-context.md 영향 분석 | 변경/추가된 엔티티/API로 영향받는 후속 Feature의 pre-context를 자동 갱신하고 사용자에게 보고 |
| **verify 이후** | entity-registry/api-registry 검증 | 실제 구현과 레지스트리의 정합성 확인 및 갱신 |
| **verify 이후** | sdd-state.md 업데이트 | 검증 결과 기록 |
| **merge** | sdd-state.md 완료 기록 | Feature 상태를 `completed`로 변경, 각 단계의 완료 시각과 결과 기록 |
| **merge** | Feature 브랜치 머지 | 모든 업데이트를 Feature 브랜치에 커밋한 후, 사용자 확인(HARD STOP)을 받고 main에 머지. 다음 Feature는 main에서 시작 |

#### 구현 전 분석 (analyze 단계)

tasks 생성 후, `speckit-analyze`가 spec.md, plan.md, tasks.md 간의 READ-ONLY 일관성 분석을 수행합니다. CRITICAL 이슈가 있으면 implement를 차단하고, 그 외 발견사항은 참고용입니다.

#### Verify 4단계 검증 (verify 단계)

```
1단계: 실행 검증 — 실패 시 BLOCK
    └─ 테스트 실행, 빌드 확인, 린트 체크
    └─ 하나라도 실패 → 차단, 또는 사용자가 "제한 검증 인정" 선택 가능 (⚠️)

2단계: 교차-Feature 일관성 + 행위 완전성
    └─ pre-context.md의 검증 포인트 확인
    └─ 변경된 공유 엔티티/API가 다른 Feature에 영향을 주는지 분석
    └─ 소스 행위 완전성 체크: P1/P2 행위 vs FR-### 커버리지 (rebuild 전용)

3단계: Demo-Ready 검증 (constitution에 VI. Demo-Ready Delivery가 있는 경우만) — 실패 시 BLOCK
    └─ 데모 스크립트가 실제 Feature를 실행하는지 확인 (테스트만 돌리는 스크립트 거부)
    └─ 사용자를 위한 구체적 "이렇게 써보세요" 안내 존재 확인 (URL, 명령어 ≥ 2개)
    └─ --ci 헬스체크 실행 및 통과 확인
    └─ Demo Components 헤더 및 컴포넌트 마커 (@demo-only, @demo-scaffold) 확인
    └─ 하나라도 실패 → 차단, 또는 사용자가 "제한 검증 인정" 선택 가능 (⚠️)

4단계: Global Evolution 업데이트
    └─ entity-registry/api-registry 검증 및 갱신
    └─ sdd-state.md에 검증 결과 기록 (상태: success / limited / failure)
```

#### Constitution 증분 업데이트

Feature 진행 중 새로운 아키텍처 원칙이 발견되면:
1. 사용자에게 "Constitution 업데이트 제안" 체크포인트 제공
2. 승인 시 `/speckit-constitution`으로 MINOR 버전 업데이트
3. 이미 완료된 Feature에 영향이 있으면 경고 표시

#### 상태 추적 (`sdd-state.md`)

```
📊 Smart-SDD 진행 상태

Origin: [greenfield | rebuild | adoption]
Scope: core | Active Tiers: T1
Constitution: ✅ v1.0.0 (2026-01-15)

Feature         | Tier | specify | plan | tasks | analyze | implement | verify | merge | Status
----------------|------|---------|------|-------|---------|------|--------|-------|----------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |   ✅    |  ✅  |   ✅   |  ✅  | completed
F002-product    | T1   |   ✅    |  🔄  |       |         |      |        |      | in_progress
F003-order      | T2   |         |      |       |         |      |        |      | 🔒 deferred
F004-payment    | T2   |         |      |       |         |      |        |      | 🔒 deferred

Active: 1/4 completed, 1/4 in progress | Deferred: 2 (Tier 2)
💡 Use /smart-sdd expand to activate deferred Features
```

상태 파일에는 Feature Progress, Feature Detail Log, Feature Mapping (Feature ID <-> spec-kit Name), Global Evolution Log, Restructure Log, Constitution Update Log가 포함됩니다. `scope=core`일 때 Active Tiers 밖의 Feature는 `deferred`로 표시되어 pipeline에서 건너뛰며, `/smart-sdd expand`로 활성화할 때까지 보류됩니다. `/smart-sdd restructure`로 수정된 Feature는 `restructured`로 표시되며, 영향받는 단계에 재실행 마크(🔀)가 설정됩니다.

#### 패리티 검사 (Brownfield Rebuild)

Brownfield rebuild 모드에서 모든 Feature가 파이프라인을 완료한 후, `/smart-sdd parity`를 실행하여 원본 소스 대비 구현 패리티를 검증합니다.

패리티 검사는 두 가지 유형의 gap을 다룹니다:
- **Gap A (추출 누락)**: `/reverse-spec` 분석 시 원본 소스에서 놓친 항목. `/reverse-spec` 분석 완료 시(Phase 4-3) 생성되는 `coverage-baseline.md`로 완화.
- **Gap B (구현 누락)**: `/reverse-spec`이 정확히 추출했으나 파이프라인에서 완전히 구현되지 않은 항목. `/smart-sdd parity` 명령어로 감지.

parity 명령어는 5개 페이즈로 실행됩니다:
1. **구조적 패리티** (자동) — 원본 소스에서 엔드포인트, 엔티티, 라우트, 테스트, 소스 행위, UI 컴포넌트 기능을 파싱. 레지스트리, 행위 인벤토리 및 구현된 코드와 비교. `coverage-baseline.md`의 의도적 제외 항목 필터링.
2. **로직 패리티** (반자동) — `business-logic-map.md` 규칙을 구현된 FR-### 매핑과 비교. 원본 테스트 케이스를 새 테스트와 비교.
3. **Gap 리포트** — gap 테이블과 자동 그룹핑이 포함된 `parity-report.md` 생성.
4. **보완 계획** (그룹별 HARD STOP) — 사용자가 그룹별로 결정: 새 Feature 생성(`/smart-sdd add` 연계), 의도적 제외(6가지 사유 코드: `deprecated`, `replaced`, `third-party`, `deferred`, `out-of-scope`, `covered-differently`), 유예, 또는 기존 Feature에 추가.
5. **완료 리포트** — 최종 패리티 백분율 및 다음 단계 표시.

횡단 관심사 gap(예: rate limiting, CORS)은 이중 처리: constitution 업데이트(아키텍처 원칙) + 인프라 Feature(실제 구현 코드).

#### Catch-Up 워크플로우: 원본 소스 업데이트 대응

Rebuild 중 원본 소스가 업데이트된 경우 (새 기능, 버그 수정 등), **Complete + Catch-up** 워크플로우를 사용합니다:

```
1. /smart-sdd pipeline                      # 현재 파이프라인 먼저 완료
2. /smart-sdd parity --source /path/to/updated-original  # 새로운 gap 감지
3. /smart-sdd add --gap                     # gap에서 Feature 생성
4. /smart-sdd pipeline                      # gap 커버 Feature 구현
5. /smart-sdd parity --source ...           # 재검증 → 100%에 가까워짐
```

이전 parity 결정(제외, 유예)은 보존됩니다 — 새로운 gap만 표시됩니다. 원본 소스에 대규모 변경(대규모 리팩터링, 새 모듈)이 있었다면, catch-up 전에 `/reverse-spec`을 다시 실행하여 SBI 항목을 갱신하는 것을 권장합니다.

### 3. `/speckit-diff` -- Spec-Kit 버전 호환성 분석기

현재 spec-kit-skills가 최신 spec-kit 버전과 호환되는지 확인하는 유틸리티 스킬입니다. reverse-spec, smart-sdd, 또는 활성 프로젝트에 대한 의존성 없이 **독립적으로 실행** 가능합니다.

**작동 방식**: GitHub에서 최신 spec-kit을 자동 clone하여 구조적 서명(스킬 섹션, 템플릿 포맷, 스크립트 인터페이스, CLI 플래그, 디렉토리 규약)을 저장된 baseline과 비교합니다. 명확한 **COMPATIBLE / NOT COMPATIBLE** 판정을 먼저 출력한 후, 각 변경사항을 spec-kit-skills의 특정 파일에 매핑한 우선순위별 영향 리포트를 생성합니다.

**5가지 분석 차원**: 스킬 변경, 템플릿 포맷 변경, 스크립트 인터페이스 변경, 워크플로우 순서 변경, 디렉토리 구조 변경

**우선순위 수준**: P1 (Breaking — 반드시 수정), P2 (Compatibility — 수정 권장), P3 (Enhancement — 선택적)

---

## 전체 워크플로우 예시

### 시나리오 1 (Greenfield): 신규 태스크 관리 앱

```
1. /smart-sdd init
   ├─ Pre-Phase: Git 저장소 설정 (init 또는 기존 확인)
   ├─ Phase 1: 프로젝트 정의
   │   ├─ 프로젝트명: TaskFlow
   │   ├─ 설명: 팀 협업 태스크 관리 앱
   │   ├─ 도메인: SaaS / Project Management
   │   └─ 기술 스택: TypeScript, Next.js, Prisma, PostgreSQL
   ├─ Phase 2: Constitution Seed 정의
   │   └─ 6개 Best Practices 전체 채택 + 프로젝트 컨벤션 추가
   ├─ Phase 3: 산출물 생성
   │   └─ specs/reverse-spec/ 하위에 roadmap(빈 Feature Catalog),
   │      constitution-seed, entity-registry(빈), api-registry(빈), sdd-state 생성
   └─ Phase 4: "Feature를 지금 정의하시겠습니까?" → Yes, add로 체이닝...

   /smart-sdd add (init에서 체이닝)
   ├─ Phase 1: Feature 정의 (Type 2 — 대화형)
   │   ├─ 초기 Feature 브레인스토밍
   │   └─ Elaboration: 6가지 관점으로 정의 품질 평가
   ├─ Phase 2: 중첩 & 영향 분석 (생략 — 첫 greenfield Feature)
   ├─ Phase 3: 범위 협의
   │   ├─ F001-auth: 사용자 인증 및 팀 관리
   │   ├─ F002-workspace: 팀 워크스페이스, 멤버 관리
   │   ├─ F003-task: 태스크 CRUD, 담당자 배정, 상태 추적
   │   ├─ F004-board: 칸반 보드 뷰, 드래그 앤 드롭
   │   └─ F005-notification: 태스크 변경 알림
   ├─ Phase 4: SBI 매칭 (생략 — greenfield, 소스 행위 없음)
   ├─ Phase 5: Demo Group 배정
   └─ Phase 6: Feature별 pre-context.md 생성, roadmap + sdd-state 갱신

2. /smart-sdd pipeline
   ├─ Phase 0: constitution-seed 기반으로 /speckit-constitution 확정
   ├─ Release 1 (Foundation):
   │   └─ F001-auth → specify → plan → tasks → implement → verify
   │       └─ Update: entity-registry에 User, Team 확정 반영
   ├─ Release 2 (Core):
   │   ├─ F002-workspace → (User 참조) → specify → ... → verify
   │   └─ F003-task → (Workspace 참조) → specify → ... → verify
   ├─ Release 3 (Enhancement):
   │   ├─ F004-board → specify → ... → verify
   │   └─ F005-notification → specify → ... → verify
   └─ 전체 완료
```

### 시나리오 2 (Brownfield incremental): 기존 smart-sdd 프로젝트에 알림 Feature 추가

```
1. /smart-sdd add
   ├─ Phase 1: Feature 정의 (Type 2 — 대화형)
   │   ├─ "주문 상태 변경 시 알림이 필요합니다"
   │   └─ Elaboration: 6가지 관점 → 사용자, 기능, 데이터, 인터페이스...
   ├─ Phase 2: 중첩 & 영향 분석
   │   ├─ 현재 상태: 4 Features (모두 완료), 8 entities, 23 APIs
   │   ├─ 기존 Feature와 중첩 없음
   │   └─ ⚠️ Constitution 영향: WebSocket (새 기술)
   ├─ Phase 3: 범위 협의
   │   ├─ F005-notification: 주문 상태 변경 시 이메일/푸시 알림
   │   │   └─ 의존: F001-auth (User), F003-order (Order 이벤트)
   ├─ Phase 4: SBI 매칭 (생략 — incremental, 소스 행위 없음)
   ├─ Phase 5: Demo Group → DG-01 (주문 처리 흐름)에 합류
   └─ Phase 6: pre-context.md 생성, roadmap + sdd-state 갱신

2. /smart-sdd pipeline
   ├─ (Constitution 이미 존재 → Phase 0 생략)
   ├─ (F001~F004 이미 완료 → 건너뜀)
   ├─ F005-notification:
   │   ├─ Assemble: pre-context + entity-registry(User, Order 참조) + api-registry 조립
   │   └─ specify → plan → tasks → implement → verify
   └─ 완료
```

### 시나리오 3 (Brownfield rebuild): 레거시 e-commerce 시스템을 React + FastAPI로 재개발

```
1. /reverse-spec ./legacy-ecommerce --scope core --stack new
   ├─ Phase 0: "Core" 범위 + "New" 스택 선택
   ├─ Phase 1: Django + jQuery 기술 스택 감지
   ├─ Phase 2: 12개 엔티티, 45개 API, 78개 비즈니스 규칙, 15개 환경 변수 추출
   ├─ Phase 3: Feature 경계 식별 + 세분화 수준 선택
   │   ├─ 세분화 옵션:
   │   │   A. Coarse (4 Features): auth, catalog, commerce, admin
   │   │   B. Standard (8 Features) — 권장 ← 선택됨
   │   │   C. Fine (14 Features): register, login, product-crud, ...
   │   ├─ Tier 분류 + 추천 이유 제시:
   │   ├─ Tier 1: Auth, Product, Order (근간 기능)
   │   ├─ Tier 2: Cart, Payment, Search (핵심 UX)
   │   └─ Tier 3: Review, Notification (부가 기능)
   └─ Phase 4: 전체 8개 Feature의 산출물 생성 (scope에 관계없이)
              + 탐지된 환경 변수로 .env.example 생성

2. /smart-sdd pipeline
   ├─ Scope: "Core — Tier 1만 진행. 보류: Cart, Payment, Search (T2), Review, Notification (T3)"
   ├─ Phase 0: constitution-seed 기반으로 /speckit-constitution 확정
   ├─ Tier 1 Feature만 진행 (scope=core):
   │   ├─ F001-auth:
   │   │   ├─ Assemble: pre-context + business-logic-map에서 auth 관련 정보 조립
   │   │   ├─ Checkpoint: "FR-5개, SC-8개, 비즈니스 규칙 4개 주입. 진행?" → 승인
   │   │   ├─ Execute: /speckit-specify 실행
   │   │   ├─ (plan, tasks, implement, verify 순차 진행)
   │   │   └─ Update: entity-registry에 User, Session 확정 반영
   │   └─ F002-product, F003-order 동일하게 진행
   └─ Pipeline 완료 (Tier 1 완료). Tier 2/3는 보류 상태 유지.

3. (이후) /smart-sdd expand T2
   ├─ Cart, Payment, Search → pending으로 활성화
   └─ /smart-sdd pipeline → 새로 활성화된 Tier 2 Feature 진행

4. (이후) /smart-sdd expand full
   ├─ Review, Notification → pending으로 활성화
   └─ /smart-sdd pipeline → 남은 모든 Feature 완료
```

---

## 참고 자료

### 경로 규약

| 대상 | 경로 | 비고 |
|------|------|------|
| 결정 이력 | `specs/history.md` | 자동 생성. `/reverse-spec`과 `/smart-sdd` 공유 |
| Global Evolution 산출물 | `specs/reverse-spec/` | CWD 기준 상대 경로. `/smart-sdd --from`으로 변경 가능 |
| spec-kit 피처 산출물 | `specs/{NNN-feature}/` | spec-kit 고유 경로. smart-sdd가 건드리지 않음 |
| spec-kit constitution | `.specify/memory/constitution.md` | spec-kit 고유 작업 경로 |
| smart-sdd 상태 파일 | `specs/reverse-spec/sdd-state.md` | smart-sdd가 자동 생성/관리 |

#### Feature 네이밍 규약

smart-sdd와 spec-kit은 약간 다른 네이밍 형식을 사용하지만, **short-name**은 항상 동일합니다:

| 시스템 | 형식 | 예시 |
|--------|------|------|
| smart-sdd (pre-context, roadmap, state) | `F{NNN}-{short-name}` | `F001-auth` |
| spec-kit (specs/ 디렉토리, git branch) | `{NNN}-{short-name}` | `001-auth` |

변환: `F` prefix를 제거하거나 추가. 매핑은 `sdd-state.md` → Feature Mapping 테이블에서 추적됩니다.

#### Global Evolution Layer 산출물 구조

```
specs/
├── history.md                          # 결정 이력 (자동 생성, 양 스킬 공유)
└── reverse-spec/
    ├── roadmap.md
    ├── constitution-seed.md
    ├── entity-registry.md
    ├── api-registry.md
    ├── business-logic-map.md           # (rebuild 모드에서만)
    ├── stack-migration.md              # (rebuild + 신규 스택에서만)
    ├── coverage-baseline.md            # (rebuild 전용 — /reverse-spec Phase 4-3이 생성)
    ├── parity-report.md                # (rebuild 전용 — /smart-sdd parity가 생성)
    ├── sdd-state.md                    # smart-sdd가 자동 생성/관리하는 상태 파일
    └── features/
        ├── F001-auth/pre-context.md
        ├── F002-product/pre-context.md
        └── ...
```

> 환경 변수가 탐지된 경우 프로젝트 루트에 `.env.example`도 생성됩니다.

### Constitution Best Practices

`constitution-seed.md`에 포함되는 6가지 권장 개발 원칙입니다 (`/reverse-spec` 또는 `/smart-sdd init`이 생성):

| 원칙 | 핵심 | 검증 기준 |
|------|------|-----------|
| **I. Test-First (NON-NEGOTIABLE)** | 테스트 먼저 작성. 테스트 없는 코드는 완료 불인정. spec.md의 Acceptance Scenario가 테스트의 원천 | 모든 테스트 통과 |
| **II. Think Before Coding** | 가정 금지. 불명확하면 `[NEEDS CLARIFICATION]`으로 명시. 트레이드오프를 명시적으로 기록 | 모든 결정에 "왜?" 답변 존재 |
| **III. Simplicity First** | spec 범위만 구현. 추측적 기능 추가/조기 추상화 금지 | 모든 코드가 요구사항으로 추적 가능 |
| **IV. Surgical Changes** | 인접 코드 개선 금지. 자기 변경으로 발생한 고아 코드만 정리 | 변경 줄이 task로 추적 가능 |
| **V. Goal-Driven Execution** | 검증 가능한 완료 기준 필수. "구현한다" → "테스트가 통과한다" | 자동화 검증 통과 |
| **VI. Demo-Ready Delivery** | 각 Feature 완료 시 **실행 가능한 데모 스크립트** (`demos/F00N-name.sh`)로 제공. 서비스 시작 → "이렇게 써보세요" 안내 출력 → Ctrl+C까지 유지. `--ci` 플래그로 자동화 헬스체크. 데모 코드는 `@demo-only` / `@demo-scaffold` 마커로 분류. 외부 의존성으로 Phase 1/3 통과 불가 시 ⚠️ 제한 검증 인정 가능 | `./demos/F00N-name.sh` 실행으로 Feature 실물 체험 — 보고, 쓰고, 상호작용 |

### spec-kit과의 관계

| 구분 | spec-kit | spec-kit-skills |
|------|----------|-----------------|
| **역할** | Feature-local SDD 실행 프레임워크 | Global Evolution Layer 보강 |
| **범위** | 개별 Feature 내 Spec<->Plan<->Tasks 정합성 | Feature 간 의존성, 릴리즈 진화, 교차 참조 |
| **관계** | 독립적으로 동작 | spec-kit을 감싸서(wrapping) 동작. spec-kit 커맨드를 대체하지 않음 |
| **결합도** | spec-kit-skills 없이도 완전히 동작 | spec-kit이 반드시 필요 |
| **호환성** | spec-kit 업데이트에 영향 없음 | Constitution 원칙 + 산출물로 보완하는 방식이므로 spec-kit 버전에 독립적 |

#### reverse-spec 산출물을 spec-kit 단독으로 사용하기 (smart-sdd 없이)

smart-sdd 없이도 reverse-spec 산출물을 spec-kit 커맨드에 직접 활용할 수 있습니다. 관련 섹션을 대화에 붙여넣은 뒤 spec-kit 커맨드를 호출하면 Claude가 해당 컨텍스트를 참조합니다.

| 커맨드 | 호출 전 붙여넣을 내용 |
|--------|---------------------|
| `/speckit-constitution` | `constitution-seed.md` 전체 내용 |
| `/speckit-specify` | `pre-context.md` "For /speckit.specify" 섹션 + `business-logic-map.md` Feature 섹션 + Source Reference 섹션 |
| `/speckit-plan` | `pre-context.md` "For /speckit.plan" 섹션 + `entity-registry.md` + `api-registry.md` + 선행 Feature의 확정 `data-model.md` / `contracts/` (있는 경우) |
| `/speckit-tasks`, `/speckit-implement` | 추가 컨텍스트 불필요 (spec-kit 자체 산출물로 동작). `pre-context.md`에서 Static Resources와 Environment Variables 확인 |
| `/speckit-analyze` | `pre-context.md` "For /speckit.analyze" 섹션 + `entity-registry.md` + `api-registry.md` |

**잃는 것**: 자동 컨텍스트 조립/필터링, 레지스트리·roadmap 자동 갱신, 파이프라인 상태 추적(`sdd-state.md`), 선행 Feature 결과 우선 적용, Feature별 환경 변수 검증, Feature 브랜치 관리.

### 도메인 프로필 (계획)

현재 **애플리케이션 개발** (backend, frontend, fullstack, mobile, library)에 최적화되어 있습니다. **데이터 사이언스**, **AI/ML**, **임베디드 시스템** 등 전문 도메인 특화 분석 프로필을 확장할 계획입니다.

**설계 철학**: 스킬 아키텍처는 관심사를 세 계층으로 분리합니다:

```
Core Workflow (도메인 무관)          ← Phase, 체크포인트, 파이프라인 오케스트레이션
    ↓ reads
Domain Profile (교체 가능)          ← 분석 축, 추출 패턴, 데모/검증 규약
    ↓ applies to
Tech Stack (런타임 감지)            ← 프레임워크별 파일 패턴, ORM 유형, API 스타일
```

도메인 프로필을 바꾸면 *무엇을* 분석하고 산출물을 *어떻게* 구성하는지가 변경되며, 기저의 워크플로우 엔진은 영향받지 않습니다. 각 프로젝트는 하나의 도메인 프로필만 사용합니다 — 하이브리드 도메인(예: AI-serving 앱)은 복수 프로필 합성이 아닌 전용 프로필로 대응합니다.

각 스킬의 `domains/` 디렉토리에 프로필 스키마(`_schema.md`)와 기존 프로필이 있습니다. `--domain`으로 프로필을 선택합니다 (기본값: `app`).

### UI 테스트 통합 (Playwright MCP)

Claude Code 환경에서 Playwright MCP (또는 유사한 브라우저 자동화)를 사용할 수 있을 때, `/smart-sdd verify`가 자동화된 UI 검증을 수행할 수 있습니다:

- **데모 UI 검사**: 데모 스크립트가 서버를 시작한 후, Playwright가 데모 URL로 이동하여 페이지 로딩과 주요 UI 요소를 확인
- **스크린샷 증거**: 검증 중 스크린샷을 캡처하여 리뷰에 활용
- **우아한 폴백**: Playwright MCP를 사용할 수 없으면 기존과 동일하게 동작 (health 엔드포인트 검사만)

데모 스크립트에 선택적으로 `# Playwright` 헤더 코멘트를 포함하여 URL과 요소 어설션을 자동 검증에 활용할 수 있습니다.

**현재 (Phase A)**: verify Phase 3에 데모 UI 검증 hook point. **향후**: 시각적 패리티 비교 (Phase B), UI 행동 추출 (Phase C). 자세한 가이드와 로드맵은 `reference/ui-testing-integration.md`를 참조하세요.

### 프로젝트 구조

```
spec-kit-skills/
└── .claude/
    └── skills/
        ├── reverse-spec/
        │   ├── SKILL.md                                 # 메인 스킬 정의 (개요 + 라우팅)
        │   ├── commands/
        │   │   └── analyze.md                           # Pre-Phase + 5-Phase 분석 워크플로우
        │   ├── domains/                                 # 도메인별 분석 프로필
        │   │   ├── _schema.md                           # 도메인 프로필 스키마
        │   │   ├── app.md                               # 애플리케이션 도메인 (기본값)
        │   │   └── data-science.md                      # 데이터 사이언스 도메인 (템플릿)
        │   ├── templates/
        │   │   ├── roadmap-template.md                  # Feature 진화 맵 템플릿
        │   │   ├── entity-registry-template.md           # 공유 엔티티 레지스트리 템플릿
        │   │   ├── api-registry-template.md              # API 계약 레지스트리 템플릿
        │   │   ├── business-logic-map-template.md        # 비즈니스 로직 맵 템플릿
        │   │   ├── constitution-seed-template.md         # Constitution 초안 템플릿
        │   │   ├── coverage-baseline-template.md        # 소스 커버리지 베이스라인 템플릿
        │   │   ├── pre-context-template.md               # Feature별 교차참조 정보 템플릿
        │   │   └── stack-migration-template.md           # 스택 마이그레이션 계획 템플릿
        │   └── reference/
        │       └── speckit-compatibility.md              # spec-kit 연계 가이드
        ├── smart-sdd/
        │   ├── SKILL.md                                 # 메인 스킬 정의 (오케스트레이터)
        │   ├── commands/                                # 커맨드별 워크플로우 상세
        │   │   ├── init.md                              # Greenfield 설정 워크플로우
        │   │   ├── add.md                               # Brownfield incremental 워크플로우
        │   │   ├── adopt.md                             # SDD 도입 워크플로우
        │   │   ├── coverage.md                          # SBI 커버리지 확인 및 갭 해소
        │   │   ├── pipeline.md                          # 파이프라인 + step 모드 워크플로우
        │   │   ├── restructure.md                       # Feature 구조 변경 워크플로우
        │   │   ├── expand.md                            # Tier 확장 워크플로우
        │   │   ├── parity.md                            # 소스 패리티 검증
        │   │   ├── verify-phases.md                     # 검증 Phase 실행 상세
        │   │   └── status.md                            # 진행 상태 표시
        │   ├── scripts/                                 # 아티펙트 집계 스크립트
        │   │   ├── context-summary.sh                   # Feature/Entity/API/DemoGroup 요약
        │   │   ├── sbi-coverage.sh                      # SBI 커버리지 대시보드
        │   │   ├── demo-status.sh                       # Demo Group 진행 현황
        │   │   ├── pipeline-status.sh                   # 파이프라인 진행 개요
        │   │   └── validate.sh                          # 교차 파일 일관성 검사
        │   ├── domains/                                 # 도메인별 행동 프로필
        │   │   ├── _schema.md                           # 도메인 프로필 스키마
        │   │   ├── app.md                               # 애플리케이션 도메인 (기본값)
        │   │   └── data-science.md                      # 데이터 사이언스 도메인 (템플릿)
        │   └── reference/
        │       ├── context-injection-rules.md            # 공유 주입 패턴
        │       ├── injection/                            # 커맨드별 컨텍스트 주입 규칙
        │       │   ├── constitution.md
        │       │   ├── specify.md                       # Clarify 포함
        │       │   ├── plan.md
        │       │   ├── tasks.md
        │       │   ├── analyze.md
        │       │   ├── implement.md
        │       │   ├── verify.md
        │       │   ├── parity.md
        │       │   ├── adopt-specify.md                # 도입 모드 specify 주입 규칙
        │       │   ├── adopt-plan.md                    # 도입 모드 plan 주입 규칙
        │       │   └── adopt-verify.md                  # 도입 모드 verify 주입 규칙
        │       ├── state-schema.md                      # sdd-state.md 스키마 정의
        │       ├── branch-management.md                 # Git 브랜치 관리 참조
        │       ├── feature-elaboration-framework.md     # Feature 정의 품질 평가
        │       ├── demo-standard.md                    # 데모 스크립트 표준 및 템플릿
        │       └── ui-testing-integration.md            # Playwright MCP 통합 가이드
        ├── speckit-diff/
        │   ├── SKILL.md                                 # 호환성 분석 스킬 (개요 + 라우팅)
        │   ├── commands/
        │   │   └── diff.md                              # 4-Phase 비교 워크플로우
        │   └── reference/
        │       └── integration-surface.md               # Spec-kit baseline (구조적 서명)
        └── case-study/
            ├── SKILL.md                                 # Case Study 생성 스킬 (개요 + 라우팅)
            ├── commands/
            │   ├── init.md                              # 자동 초기화 로직 (다른 스킬에서 내부적으로 사용)
            │   └── generate.md                          # Case Study 보고서 생성
            ├── reference/
            │   └── recording-protocol.md                # 마일스톤별 기록 가이드
            └── templates/
                └── case-study-log-template.md            # 관찰 로그 템플릿
```

### 유지보수

#### Spec-Kit 호환성 Baseline

spec-kit-skills(smart-sdd, reverse-spec 또는 참조 파일)를 수정할 때, 해당 변경이 spec-kit 연동 지점에 영향을 미치는지 항상 확인하세요. spec-kit 자체가 업데이트된 경우 `/speckit-diff`를 실행하여 필요한 변경사항을 파악하세요.

새 spec-kit 버전에 대한 변경사항 적용 후 **baseline을 업데이트**합니다:
1. `/speckit-diff`를 실행하여 모든 변경이 적용되었는지 확인 (판정: COMPATIBLE)
2. `.claude/skills/speckit-diff/reference/integration-surface.md`를 새 spec-kit 버전에 맞게 업데이트
3. 업데이트된 baseline을 spec-kit-skills 변경사항과 함께 커밋

#### 설계 결정 이력 (`history.md`)

`history.md` 파일은 프로젝트 개발 과정에서 내린 아키텍처 및 설계 결정을 기록합니다. 두 가지 용도로 활용됩니다:

**1. spec-kit-skills 개발 기여자용**

프로젝트가 *왜* 현재와 같은 구조로 되어 있는지를 이해할 수 있습니다. 각 항목은 결정 사항, 선택한 방향, 그리고 근거를 기록하여 — 새 기능 추가나 기존 동작 수정 시 일관성을 유지하기 쉽게 합니다.

**2. spec-kit-skills를 프로젝트에 적용하는 사용자용**

스킬의 동작 방식에 담긴 설계 철학을 이해할 수 있습니다. 예를 들어, HARD STOP이 왜 회피 불가능한지, 데모 스크립트가 왜 마크다운이 아닌 실행 가능한 형태여야 하는지, 5축 Tier 분류가 왜 더 단순한 방식 대신 채택되었는지 등을 확인할 수 있습니다.

주요 기록 항목:

| 날짜 | 주제 |
|------|------|
| 2026-02-28 | 초기 아키텍처, HARD STOP 철학, 네 가지 프로젝트 모드 |
| 2026-03-01 | 데모 기반 전달, 스코프 시스템 (core/full), Feature 세분화 |
| 2026-03-02 | 파이프라인 강화, Feature 재구성 프로토콜 |
| 2026-03-03 | 리뷰 시스템 개편, 패리티 검증 시스템 |
| 2026-03-04 | speckit-diff 유틸리티, 도메인 프로필 시스템, 컨텍스트 최적화 |
| 2026-03-05 | commands/ 구조 통일, case-study 스킬 |
| 2026-03-06 | **v2 재설계**: 사용자 의도 모델, adopt 커맨드, 데모 레이어링, SBI 커버리지 추적, 스크립트 아키텍처 |

> 중요한 설계 결정을 내릴 때마다 `history.md`에 항목을 추가하여 향후 참조를 위한 근거를 보존하세요.

---

### Case Study 워크플로우

`/case-study` 스킬은 SDD 워크플로우 실행 결과에서 구조화된 보고서를 생성합니다.

> `case-study-log.md` (정성적 관찰 기록)는 프로젝트 루트에 자동 생성됩니다. 마일스톤 항목(M1-M8)은 워크플로우 실행 중 자동 기록됩니다. 로그가 없으면 정량 데이터만으로 보고서를 생성합니다.

```
Step 1: SDD 워크플로우 실행 (case-study-log.md가 프로젝트 루트에 자동 생성)
  /reverse-spec ./source-code         → M1-M4 마일스톤 자동 기록
  /smart-sdd pipeline                 → M5-M8 마일스톤 Feature별 자동 기록

Step 2: 보고서 생성 (타임스탬프 파일명으로 자동 저장)
  /case-study                                      → 영어 → case-study-YYYYMMDD-HHMM.md
  /case-study --lang ko                            → 한국어 → case-study-YYYYMMDD-HHMM.md
```

보고서는 **정량 데이터** (sdd-state.md, 레지스트리, spec-kit 아티펙트에서 자동 추출)와 **정성적 관찰** (실행 중 8개 마일스톤에서 수동 기록)을 결합합니다. 관찰 기록이 없어도 아티펙트에서 메트릭만으로 보고서를 생성할 수 있습니다.
