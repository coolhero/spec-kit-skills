# spec-kit-skills

[English README](README.md) | Last updated: 2026-03-03 06:28:47 KST

**spec-kit 기반 Spec-Driven Development(SDD) 워크플로우를 보강하는 Claude Code 커스텀 스킬 모음**

---

## 목적

[spec-kit](https://github.com/github/spec-kit)은 Spec-Driven Development(SDD)를 실제 워크플로우로 구현하기 위한 Git 기반 실행 프레임워크입니다. 그러나 spec-kit에는 다음과 같은 전역 수준의 한계가 존재합니다.

### spec-kit의 한계

spec-kit은 **Feature-local governance**(기능 단위 내부 통제)에 최적화되어 있으나, 아래와 같은 전역 수준의 관리 메커니즘이 기본 제공되지 않습니다:

| 한계 | 영향 |
|------|------|
| Feature 간 교차 참조 부재 | `/speckit-plan`이 선행 Feature의 data-model, API 계약을 자동 참조하지 않아 호환 불가한 설계 발생 가능 |
| Cross-Feature 분석 한계 | `/speckit-analyze`가 Feature 내부만 분석하여 Feature 간 엔티티/인터페이스 충돌 점검 불가 |
| 에이전트 컨텍스트 부족 | "Recent Changes" 섹션이 최근 3개 Feature의 한 줄 요약만 누적. 데이터 모델/API/비즈니스 로직 수준의 맥락 미포함 |
| 릴리즈 단위 관리 부재 | Feature 간 의존성, 우선순위, 릴리즈 그룹핑 관리 산출물이 없어 통합 계획이 프레임워크 외부에 의존 |

### 이 프로젝트의 해결 방안: Global Evolution Layer

spec-kit의 커맨드 템플릿 자체를 수정하지 않고, **Constitution 원칙 + 프로젝트 수준 산출물 + 운영 스킬**로 한계를 보완합니다.

프로젝트 상황에 따라 세 가지 경로로 Global Evolution Layer를 구성합니다:

```
── Greenfield ───────────────────────────────────────────────────
신규 프로젝트 → /smart-sdd init → Global Evolution Layer → /smart-sdd pipeline

── Brownfield (incremental) ─────────────────────────────────────
기존 smart-sdd 프로젝트 → /smart-sdd add → 새 Feature pipeline 진행

── Brownfield (rebuild) ─────────────────────────────────────────
기존 소스 코드 → /reverse-spec → Global Evolution Layer → /smart-sdd pipeline
```

---

## 스킬 구성

### 1. `/reverse-spec` --- 기존 소스코드 역분석 및 Global Evolution Layer 추출

기존 소스코드를 분석하여, spec-kit 기반 SDD 재개발에 필요한 **프로젝트 수준의 글로벌 컨텍스트**를 추출하는 스킬입니다.

#### `/reverse-spec`은 언제 사용하는가

`/reverse-spec`은 **기존 시스템의 전체 재개발(Brownfield rebuild)** 시나리오를 위한 도구입니다. 기존 소스코드를 역분석하여 엔티티, API 계약, 비즈니스 로직, Feature 간 의존성을 추출하고, 이 정보를 기반으로 smart-sdd가 각 Feature의 spec-kit 커맨드 실행 시 **교차 Feature 컨텍스트를 정확하게 주입**할 수 있게 합니다.

기존 구현을 재현하고 테스트하는 것이 재구축 접근의 핵심입니다. 추출된 드래프트 요구사항(FR-###)과 성공 기준(SC-###)은 기존 시스템이 실제로 하는 것에서 파생되어, 재개발된 시스템이 원래 기능을 정확히 재현하는지 검증하기 위한 테스트 기준을 제공합니다.

신규 프로젝트(Greenfield)나 기존 smart-sdd 프로젝트에 기능을 추가하는 경우(Brownfield incremental)에는 `/reverse-spec` 대신 `/smart-sdd init` 또는 `/smart-sdd add`를 사용합니다.

#### 핵심 가치

- 기존 코드의 엔티티, API, 비즈니스 로직, 모듈 의존성을 **자동 역추출**
- **Core scope**: Feature 단위로 분류하고, **5축 분석 기반 Tier 자동 추천** (Tier 1 필수 / Tier 2 권장 / Tier 3 선택)으로 점진적 개발
- **Full scope**: Tier 분류 없이 **순수 의존성 기반 순서**로 모든 Feature를 동등하게 처리
- spec-kit 각 커맨드에서 바로 활용 가능한 **계층형 산출물** 생성

#### 사용법

```bash
/reverse-spec [target-directory] [--scope core|full] [--stack same|new]
```

인자를 생략하면 현재 디렉토리를 대상으로 분석합니다.

| 옵션 | 설명 |
|------|------|
| `--scope core` | 구현 범위를 Core로 설정 (대화형 프롬프트 생략) |
| `--scope full` | 구현 범위를 Full로 설정 (대화형 프롬프트 생략) |
| `--stack same` | 기존과 동일한 기술 스택 사용 (대화형 프롬프트 생략) |
| `--stack new` | 신규 기술 스택으로 전환 (대화형 프롬프트 생략) |

> **참고**: `--dangerously-skip-permissions` 모드로 실행 시 대화형 프롬프트(AskUserQuestion)가 자동 건너뛰기될 수 있습니다. 이런 환경에서는 반드시 `--scope`와 `--stack` 인자를 지정하여 올바른 전략이 선택되도록 해야 합니다.

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

확정된 분석 결과로 계층형 산출물을 생성합니다.

#### 산출물 구조

```
[current-working-directory]/
├── .env.example                                # 탐지된 환경 변수 템플릿 (rebuild 시 자동 생성)
└── specs/reverse-spec/
    ├── roadmap.md                              # Feature 진화 맵 + Tier 분류 + 릴리즈 계획
    ├── constitution-seed.md                    # constitution 초안 (소스 참조 원칙 + Best Practices)
    ├── entity-registry.md                      # 공유 엔티티 레지스트리
    ├── api-registry.md                         # API 계약 레지스트리
    ├── business-logic-map.md                   # 비즈니스 로직 맵
    ├── stack-migration.md                      # 스택 마이그레이션 계획 (신규 스택 시에만)
    └── features/
        ├── F001-auth/pre-context.md            # Feature별 spec-kit 교차참조 정보
        ├── F002-product/pre-context.md
        └── ...
```

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
| Static Resources (정적 리소스) | 전체 | 이 Feature가 사용하는 비코드 파일 (이미지, 폰트, i18n 등)의 소스/타겟 경로 |
| Environment Variables (환경 변수) | 전체 | 이 Feature가 런타임에 필요한 변수 (Feature 소유 + 공유) |
| For /speckit.specify | `/speckit-specify` | 기존 기능 요약, 사용자 시나리오, 요구사항 초안 (FR-###), 수용 기준 초안 (SC-###), 엣지 케이스 |
| For /speckit.plan | `/speckit-plan` | 선행 Feature 의존성, 소유/참조 엔티티 스키마 초안, 제공/소비 API 계약 초안, 기술적 결정사항 |
| For /speckit.analyze | `/speckit-analyze` | 교차 Feature 검증 포인트 (엔티티 호환성, API 계약 호환성, 비즈니스 규칙 일관성), 변경 시 영향 범위 |

---

### 2. `/smart-sdd` --- spec-kit SDD 워크플로우 오케스트레이터

spec-kit 커맨드를 **감싸서(wrapping)** 실행하며, 각 단계에 교차 Feature 컨텍스트를 자동 주입하고 Global Evolution Layer를 유지보수하는 스킬입니다. 세 가지 프로젝트 모드를 지원합니다:

- **Greenfield**: `/smart-sdd init`으로 신규 프로젝트를 처음부터 구성
- **Brownfield (incremental)**: `/smart-sdd add`로 기존 smart-sdd 프로젝트에 Feature 추가
- **Brownfield (rebuild)**: `/reverse-spec` 산출물 기반으로 `/smart-sdd pipeline` 실행

#### 핵심 가치

- spec-kit 커맨드를 **대체하지 않고 감싸는** 방식으로, spec-kit의 업데이트에 영향받지 않음
- 세 가지 프로젝트 진입점 지원 (greenfield, brownfield incremental, brownfield rebuild)
- 각 커맨드 실행 전에 필요한 교차 Feature 정보를 **자동 조립하여 주입**
- Feature 완료 시 Global Evolution Layer (entity-registry, api-registry, roadmap, 후속 pre-context)를 **자동 갱신**
- 전체 진행 상태를 `sdd-state.md`로 **체계적 추적**

#### 사용법

```bash
# Greenfield --- 신규 프로젝트 구성
/smart-sdd init                          # 대화형으로 신규 프로젝트 설정
/smart-sdd init --prd path/to/prd.md     # PRD 문서 기반 설정

# Brownfield (incremental) --- 기존 smart-sdd 프로젝트에 새 Feature 추가
/smart-sdd add                           # 대화형으로 새 Feature 정의 및 추가

# Pipeline 모드 --- 전체 순차 진행 (init, add, reverse-spec 이후 실행)
/smart-sdd pipeline                      # 매 단계 확인
/smart-sdd pipeline --auto               # 확인 없이 전체 자동 실행
/smart-sdd pipeline --from ./path        # 지정 경로에서 산출물 읽기

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

# 상태 확인
/smart-sdd status                        # 전체 진행 상태 조회

# --auto는 모든 커맨드와 조합 가능 (확인 단계 생략)
/smart-sdd specify F001 --auto
/smart-sdd pipeline --from ./path --auto
```

#### 세 가지 프로젝트 모드

| 모드 | 커맨드 | 사용 시점 | Global Evolution Layer 생성 방식 | Feature 세분화 | Scope | 다음 단계 |
|------|--------|----------|--------------------------------|--------------|-------|----------|
| **Greenfield** | `/smart-sdd init` | 신규 프로젝트를 처음부터 시작할 때 | 대화형 Q&A (또는 PRD 문서)로 Feature, 의존성, 원칙 정의 | Coarse/Standard/Fine 중 선택 | 항상 Full | `/smart-sdd pipeline` |
| **Brownfield (incremental)** | `/smart-sdd add` | 기존 smart-sdd 프로젝트에 새 기능을 추가할 때 | 기존 산출물에 새 Feature 추가. roadmap, pre-context 갱신 | N/A (기존 Feature에 추가) | 기존 scope 유지 | `/smart-sdd pipeline` 또는 `/smart-sdd specify F00N` |
| **Brownfield (rebuild)** | `/reverse-spec` | 기존 소스코드를 전체 재개발할 때 | 기존 코드 역분석으로 전체 산출물 자동 생성 | Coarse/Standard/Fine 중 선택 | Core 또는 Full. `/smart-sdd expand`로 확장 가능 | `/smart-sdd pipeline` |

#### 모드별 실제 차이점

세 가지 모드의 핵심적인 차이는 **시작 시점에 얼마나 많은 컨텍스트가 준비되어 있는가**입니다:

- **Brownfield (rebuild)**는 가장 풍부한 초기 컨텍스트를 가집니다. `/reverse-spec`가 기존 코드베이스 전체를 분석하여 엔티티, API, 비즈니스 규칙, Feature 간 의존성을 Global Evolution Layer에 추출합니다. 파이프라인 실행 시 각 단계에 처음부터 초안 요구사항, 스키마 참조, 교차 Feature 컨텍스트가 주입됩니다. 이것은 **정제 기반(refinement-based)** 워크플로우입니다 --- spec-kit이 미리 채워진 초안을 정제합니다.

- **Greenfield**는 최소한의 컨텍스트에서 시작합니다. `/smart-sdd init`이 빈 엔티티/API 레지스트리와 간소화된 pre-context 파일(FR/SC 초안 없음, business logic map 없음)로 프로젝트 구조를 생성합니다. 파이프라인은 **생성 기반(generative)**입니다 --- spec-kit이 요구사항, 스키마, 계약을 처음부터 만듭니다. 각 Feature의 `plan` 단계가 완료될 때마다 레지스트리가 확장되어 후속 Feature에 컨텍스트를 제공합니다. 따라서 greenfield에서는 Feature 순서가 더 중요합니다.

- **Brownfield (incremental)**은 기존 프로젝트의 컨텍스트를 상속합니다. `/smart-sdd add`로 새 Feature를 생성하면 이미 채워진 레지스트리와 완료된 Feature 산출물을 즉시 참조할 수 있습니다. 가장 간단한 모드입니다.

실제 차이 요약:

| 항목 | Greenfield | Brownfield (rebuild) |
|------|-----------|---------------------|
| 시작 시 엔티티/API 레지스트리 | 비어 있음 --- Feature plan 완료 시 점진적으로 채워짐 | 코드베이스 분석에서 미리 채워짐 |
| pre-context의 FR/SC 초안 | 없음 --- spec-kit이 처음부터 생성 | 기존 코드에서 추출 --- spec-kit이 정제 |
| Business logic map | 사용 불가 | 사용 가능 --- specify 시 주입 |
| 초기 Feature의 교차 Feature 컨텍스트 | 제한적 --- 의존성 정보만 | 풍부 --- 레지스트리의 전체 엔티티/API 스키마 |
| 파이프라인 순서 민감도 | 높음 --- 후속 Feature는 선행 Feature의 plan 완료 필요 | 낮음 --- 레지스트리가 이미 존재 |

#### Feature 구조 변경

파이프라인 실행 중 Feature 정의를 수정해야 할 때 `/smart-sdd restructure`를 사용합니다. 분할, 병합, 요구사항 이동, 의존성 변경, 삭제를 지원하며, 모든 변경사항은 관련 아티펙트(roadmap, 레지스트리, pre-context, sdd-state)에 자동 전파됩니다. 실행 전 사용자 승인을 받습니다.

#### 공통 프로토콜: Assemble → Checkpoint → Execute → Review → Update

모든 spec-kit 커맨드 실행은 이 5단계 프로토콜을 따릅니다:

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐     ┌────────────┐     ┌─────────────┐
│  1. Assemble │────▶│ 2. Checkpoint│────▶│  3. Execute  │────▶│  4. Review │────▶│  5. Update  │
│  컨텍스트 조립 │     │ 실행 전 확인   │     │ spec-kit 실행│     │ 산출물 검토 │     │ 글로벌 갱신  │
└─────────────┘     └──────────────┘     └─────────────┘     └────────────┘     └─────────────┘
```

| 단계 | 설명 |
|------|------|
| **Assemble** | `specs/reverse-spec/`에서 해당 커맨드에 필요한 파일/섹션을 읽고, 커맨드별 주입 규칙에 따라 필터링하여 조립. 선행 Feature의 실제 구현 결과(`specs/{NNN-feature}/` 하위)도 함께 참조. **Graceful degradation**: 소스 파일이 없거나 섹션에 플레이스홀더("N/A", "none yet")만 있는 경우 해당 소스는 건너뜀 |
| **Checkpoint** | 조립된 컨텍스트를 **실제 내용**과 함께 사용자에게 보여주고 실행 전 승인/수정 기회 제공. 사용자가 수정을 요청하면 반영 후 재확인. **`--auto` 모드에서만 생략** (요약은 표시하되 즉시 실행 진행). `--dangerously-skip-permissions` 환경에서는 AskUserQuestion 대신 일반 텍스트 메시지로 확인 요청 |
| **Execute** | 승인된 컨텍스트와 함께 해당 spec-kit 커맨드(`/speckit-specify`, `/speckit-plan` 등)를 실행. 실제 작업은 spec-kit이 수행 |
| **Review** | 실행 후 생성/수정된 산출물을 사용자에게 보여주고 검토 기회 제공. 승인, 수정 요청(재실행), 또는 직접 편집 가능. **HARD STOP** — Checkpoint과 동일한 규칙 적용. **`--auto` 모드에서만 생략** |
| **Update** | 실행 결과를 반영하여 Global Evolution Layer 파일을 갱신. `sdd-state.md`에 진행 상태 기록 |

#### 커맨드별 컨텍스트 주입

각 spec-kit 커맨드 실행 전에 어떤 정보가 자동으로 주입되는지 정리합니다:

| 커맨드 | 주입 소스 | 주입 내용 |
|--------|----------|-----------|
| `constitution` | `constitution-seed.md` | 전체 내용 (소스 참조 원칙, 아키텍처 원칙, Best Practices, Global Evolution 운영 원칙) |
| `specify` | `pre-context.md` "For /speckit.specify" + `business-logic-map.md` | 기능 요약, FR-### 초안, SC-### 초안, 비즈니스 규칙, 엣지 케이스, 원본 소스 참조. **business-logic-map.md가 없으면 (greenfield/add) 비즈니스 로직 주입 생략** |
| `plan` | `pre-context.md` "For /speckit.plan" + `entity-registry.md` + `api-registry.md` | 의존성 정보, 엔티티/API 스키마 초안 (또는 선행 Feature의 확정 스키마), 기술 결정. **레지스트리가 비어 있으면 (초기 greenfield) 레지스트리 주입 생략** |
| `tasks` | `plan.md` (spec-kit 산출물) | plan 기반 자동 실행. 추가 주입 없음 |
| `analyze` | `spec.md` + `plan.md` + `tasks.md` (spec-kit 산출물) | 교차 산출물 일관성 분석 (갭, 중복, 모호성). implement 전에 실행 |
| `implement` | `tasks.md` (spec-kit 산출물) | tasks 기반 자동 실행. 추가 주입 없음 |
| `verify` | `pre-context.md` "For /speckit.analyze" + registries | 교차 Feature 엔티티/API 일관성, 영향 범위 분석 |

**선행 Feature 결과 우선 적용**: 의존하는 선행 Feature의 plan이 이미 완료되었으면, entity-registry/api-registry의 초안 대신 `specs/{NNN-feature}/`에 있는 **확정된 data-model.md와 contracts/**를 우선 참조합니다.

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
       4. tasks    → /speckit-tasks
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
1단계: 실행 검증
    └─ 테스트 실행, 빌드 확인, 린트 체크

2단계: 교차-Feature 일관성
    └─ pre-context.md의 검증 포인트 확인
    └─ 변경된 공유 엔티티/API가 다른 Feature에 영향을 주는지 분석

3단계: Demo-Ready 검증 (constitution에 VI. Demo-Ready Delivery가 있는 경우만)
    └─ demos/F00N-name.md 존재 여부
    └─ 데모 표면 구현 확인
    └─ Demo Components 테이블 확인
    └─ 컴포넌트 마커 (@demo-only, @demo-scaffold) 확인

4단계: Global Evolution 업데이트
    └─ entity-registry/api-registry 검증 및 갱신
    └─ sdd-state.md에 검증 결과 기록
```

#### Constitution 증분 업데이트

Feature 진행 중 새로운 아키텍처 원칙이 발견되면:
1. 사용자에게 "Constitution 업데이트 제안" 체크포인트 제공
2. 승인 시 `/speckit-constitution`으로 MINOR 버전 업데이트
3. 이미 완료된 Feature에 영향이 있으면 경고 표시

#### 상태 추적 (`sdd-state.md`)

```
📊 Smart-SDD 진행 상태

Origin: [greenfield | reverse-spec]
Scope: core | Active Tiers: T1
Constitution: ✅ v1.0.0 (2024-01-15)

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

---

## 경로 규약

| 대상 | 경로 | 비고 |
|------|------|------|
| Global Evolution 산출물 | `specs/reverse-spec/` | CWD 기준 상대 경로. `/smart-sdd --from`으로 변경 가능 |
| spec-kit 피처 산출물 | `specs/{NNN-feature}/` | spec-kit 고유 경로. smart-sdd가 건드리지 않음 |
| spec-kit constitution | `.specify/memory/constitution.md` | spec-kit 고유 작업 경로 |
| smart-sdd 상태 파일 | `specs/reverse-spec/sdd-state.md` | smart-sdd가 자동 생성/관리 |

### Feature 네이밍 규약

smart-sdd와 spec-kit은 약간 다른 네이밍 형식을 사용하지만, **short-name**은 항상 동일합니다:

| 시스템 | 형식 | 예시 |
|--------|------|------|
| smart-sdd (pre-context, roadmap, state) | `F{NNN}-{short-name}` | `F001-auth` |
| spec-kit (specs/ 디렉토리, git branch) | `{NNN}-{short-name}` | `001-auth` |

변환: `F` prefix를 제거하거나 추가. 매핑은 `sdd-state.md` → Feature Mapping 테이블에서 추적됩니다.

### Global Evolution Layer 산출물 구조

```
specs/reverse-spec/
├── roadmap.md
├── constitution-seed.md
├── entity-registry.md
├── api-registry.md
├── business-logic-map.md           # (rebuild 모드에서만)
├── stack-migration.md              # (rebuild + 신규 스택에서만)
├── sdd-state.md                    # smart-sdd가 자동 생성/관리하는 상태 파일
└── features/
    ├── F001-auth/pre-context.md
    ├── F002-product/pre-context.md
    └── ...
```

---

## Constitution Best Practices

`constitution-seed.md`에 포함되는 6가지 권장 개발 원칙입니다 (`/reverse-spec` 또는 `/smart-sdd init`이 생성):

| 원칙 | 핵심 | 검증 기준 |
|------|------|-----------|
| **I. Test-First (NON-NEGOTIABLE)** | 테스트 먼저 작성. 테스트 없는 코드는 완료 불인정. spec.md의 Acceptance Scenario가 테스트의 원천 | 모든 테스트 통과 |
| **II. Think Before Coding** | 가정 금지. 불명확하면 `[NEEDS CLARIFICATION]`으로 명시. 트레이드오프를 명시적으로 기록 | 모든 결정에 "왜?" 답변 존재 |
| **III. Simplicity First** | spec 범위만 구현. 추측적 기능 추가/조기 추상화 금지 | 모든 코드가 요구사항으로 추적 가능 |
| **IV. Surgical Changes** | 인접 코드 개선 금지. 자기 변경으로 발생한 고아 코드만 정리 | 변경 줄이 task로 추적 가능 |
| **V. Goal-Driven Execution** | 검증 가능한 완료 기준 필수. "구현한다" → "테스트가 통과한다" | 자동화 검증 통과 |
| **VI. Demo-Ready Delivery** | 각 Feature 완료 시 데모 가능한 형태로 제공. "테스트 통과"만으로는 불충분 — 최소한의 데모 표면(CLI 명령, 데모 스크립트, 데모 페이지)을 구현하고 `demos/F00N-name.md`에 문서화. 데모 코드는 **Demo-only** (`// @demo-only`, 추후 삭제)와 **Promotable** (`// @demo-scaffold`, 추후 확장)로 분류 | 비개발자도 `demos/F00N-name.md`를 따라 Feature 동작을 확인 가능 |

---

## 전체 워크플로우 예시

### 시나리오 1 (Greenfield): 신규 태스크 관리 앱

```
1. /smart-sdd init
   ├─ Phase 1: 프로젝트 정의
   │   ├─ 프로젝트명: TaskFlow
   │   ├─ 설명: 팀 협업 태스크 관리 앱
   │   ├─ 도메인: SaaS / Project Management
   │   └─ 기술 스택: TypeScript, Next.js, Prisma, PostgreSQL
   ├─ Phase 2: Feature 정의 (대화형 Q&A)
   │   ├─ 초기 Feature 브레인스토밍
   │   ├─ 세분화 수준 선택:
   │   │   A. Coarse (3 Features): auth, core-app, admin
   │   │   B. Standard (5 Features) — 권장 ← 선택됨
   │   │   C. Fine (9 Features): register, login, workspace, task-crud, ...
   │   ├─ F001-auth: 사용자 인증 및 팀 관리
   │   ├─ F002-project: 프로젝트 CRUD 및 멤버 관리
   │   ├─ F003-task: 태스크 CRUD, 상태 전이, 담당자 배정
   │   ├─ F004-dashboard: 프로젝트/태스크 현황 대시보드
   │   └─ F005-notification: 태스크 변경 알림
   ├─ Phase 3: Constitution Seed 정의
   │   └─ 6개 Best Practices 전체 채택 + 프로젝트 컨벤션 추가
   ├─ Phase 4: 산출물 생성
   │   └─ specs/reverse-spec/ 하위에 roadmap, constitution-seed,
   │      entity-registry(빈), api-registry(빈), pre-context 생성
   └─ 완료 보고: "다음: /smart-sdd pipeline"

2. /smart-sdd pipeline
   ├─ Phase 0: constitution-seed 기반으로 /speckit-constitution 확정
   ├─ Release 1 (Foundation):
   │   └─ F001-auth → specify → plan → tasks → implement → verify
   │       └─ Update: entity-registry에 User, Team 확정 반영
   ├─ Release 2 (Core):
   │   ├─ F002-project → (User 참조) → specify → ... → verify
   │   └─ F003-task → (Project 참조) → specify → ... → verify
   ├─ Release 3 (Enhancement):
   │   ├─ F004-dashboard → specify → ... → verify
   │   └─ F005-notification → specify → ... → verify
   └─ 전체 완료
```

### 시나리오 2 (Brownfield incremental): 기존 smart-sdd 프로젝트에 알림 Feature 추가

```
1. /smart-sdd add
   ├─ Phase 1: 현재 프로젝트 상태 확인
   │   ├─ Features: 4개 (F001-auth ✅, F002-product ✅, F003-order ✅, F004-payment ✅)
   │   ├─ Entities: 8개 정의, APIs: 23개 정의
   │   └─ 현재 상태 요약 표시
   ├─ Phase 2: 새 Feature 정의 (대화형 Q&A)
   │   ├─ F005-notification (Tier 2): 주문 상태 변경 시 이메일/푸시 알림
   │   │   └─ 의존: F001-auth (User), F003-order (Order 이벤트)
   │   └─ F006-analytics (Tier 3): 주문/매출 통계 대시보드
   │       └─ 의존: F002-product, F003-order
   ├─ Phase 3: Checkpoint — 새 Feature + 의존성 그래프 + Release Group 확인
   ├─ Phase 4: 산출물 갱신
   │   ├─ roadmap.md에 F005, F006 추가
   │   ├─ features/F005-notification/pre-context.md 생성
   │   ├─ features/F006-analytics/pre-context.md 생성
   │   └─ sdd-state.md에 새 Feature 추가 (pending)
   └─ 완료 보고: "다음: /smart-sdd specify F005"

2. /smart-sdd pipeline
   ├─ (Constitution 이미 존재 → Phase 0 생략)
   ├─ (F001~F004 이미 완료 → 건너뜀)
   ├─ F005-notification:
   │   ├─ Assemble: pre-context + entity-registry(User, Order 참조) + api-registry 조립
   │   └─ specify → plan → tasks → implement → verify
   └─ F006-analytics: ...
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

## spec-kit과의 관계

| 구분 | spec-kit | spec-kit-skills |
|------|----------|-----------------|
| **역할** | Feature-local SDD 실행 프레임워크 | Global Evolution Layer 보강 |
| **범위** | 개별 Feature 내 Spec<->Plan<->Tasks 정합성 | Feature 간 의존성, 릴리즈 진화, 교차 참조 |
| **관계** | 독립적으로 동작 | spec-kit을 감싸서(wrapping) 동작. spec-kit 커맨드를 대체하지 않음 |
| **결합도** | spec-kit-skills 없이도 완전히 동작 | spec-kit이 반드시 필요 |
| **호환성** | spec-kit 업데이트에 영향 없음 | Constitution 원칙 + 산출물로 보완하는 방식이므로 spec-kit 버전에 독립적 |

### reverse-spec 산출물을 spec-kit 단독으로 사용하기 (smart-sdd 없이)

smart-sdd 오케스트레이터 없이 reverse-spec 산출물을 spec-kit 커맨드에 직접 활용할 수 있습니다. smart-sdd가 자동화하는 컨텍스트 조립을 수동으로 수행하면 됩니다.

**동작 원리**: spec-kit 커맨드는 CLI 인자가 아닌 **대화 스레드**를 통해 컨텍스트를 받습니다. reverse-spec 산출물의 관련 섹션을 읽어 메시지에 포함한 뒤 spec-kit 커맨드를 호출하면, Claude가 해당 컨텍스트를 참조하여 커맨드를 실행합니다.

#### 커맨드별 컨텍스트 가이드

**`/speckit-constitution`**
```
아래 파일을 읽고 constitution의 기초로 사용해줘:
[specs/reverse-spec/constitution-seed.md 내용 붙여넣기]

/speckit-constitution
```

**`/speckit-specify` (특정 Feature)**
```
Feature F001-auth를 specify 하려고 해. reverse-spec에서 추출된 컨텍스트:

## 요구사항 및 수용 기준 초안
[specs/reverse-spec/features/F001-auth/pre-context.md의 "For /speckit.specify" 섹션 붙여넣기]

## 비즈니스 규칙
[specs/reverse-spec/business-logic-map.md에서 F001-auth 섹션 붙여넣기]

## 원본 소스 참조
[pre-context.md의 "Source Reference" 섹션 — 나열된 소스 파일을 읽어 구현 컨텍스트 확인]

/speckit-specify
```

**`/speckit-plan` (특정 Feature)**
```
Feature F002-product를 plan 하려고 해. 교차 Feature 컨텍스트:

## 의존성 및 엔티티/API 초안
[specs/reverse-spec/features/F002-product/pre-context.md의 "For /speckit.plan" 섹션 붙여넣기]

## 공유 엔티티 레지스트리
[specs/reverse-spec/entity-registry.md에서 관련 엔티티 붙여넣기]

## API 레지스트리
[specs/reverse-spec/api-registry.md에서 관련 API 붙여넣기]

## 선행 Feature 결과 (F001이 이미 완료된 경우)
[specs/001-auth/plan/data-model.md와 contracts/ 붙여넣기 — 확정 스키마가 레지스트리 초안보다 우선]

/speckit-plan
```

**`/speckit-tasks`** 및 **`/speckit-implement`**
- spec-kit 자체 산출물(`plan.md`, `tasks.md`)을 기반으로 동작하므로 추가 reverse-spec 컨텍스트 불필요.
- implement 시: 해당 Feature의 `pre-context.md`에서 Static Resources와 Environment Variables를 확인하여 사전 설정.

**`/speckit-analyze` (교차 산출물 일관성 검증 — tasks 후, implement 전 실행)**
```
Feature F002-product의 교차 산출물 일관성을 분석해줘:

## 추가 Cross-Feature 검증 컨텍스트
[specs/reverse-spec/features/F002-product/pre-context.md의 "For /speckit.analyze" 섹션 붙여넣기]

## 현재 엔티티 레지스트리
[specs/reverse-spec/entity-registry.md 붙여넣기]

## 현재 API 레지스트리
[specs/reverse-spec/api-registry.md 붙여넣기]

/speckit-analyze
```

#### smart-sdd 없이 잃는 것

| 기능 | smart-sdd | 수동 spec-kit |
|-----|-----------|--------------|
| 커맨드별 컨텍스트 조립 | 자동 | 관련 섹션을 직접 읽고 붙여넣기 |
| 교차 Feature 컨텍스트 필터링 | Feature별 자동 필터링 | 직접 필터링 |
| Global Evolution Layer 갱신 | 각 단계 후 자동 갱신 | 레지스트리 직접 수동 갱신 |
| Pipeline 상태 추적 | `sdd-state.md` | 직접 진행 상태 관리 |
| 선행 Feature 결과 우선 적용 | 확정 스키마 자동 감지 | 직접 확인 후 참조 |
| Feature별 환경 변수 검증 | 각 Feature의 implement 단계에서 HARD STOP | `.env` 직접 확인 |
| Feature 브랜치 관리 | 자동 생성/머지 | git 브랜치 직접 관리 |

---

## 설치 및 설정

### 사전 요구사항

- [Claude Code](https://claude.ai/claude-code) CLI가 설치되어 있어야 합니다
- [spec-kit](https://github.com/github/spec-kit) 스킬이 설치되어 있어야 합니다 (`/smart-sdd` 사용 시)

### 설치

**방법 1: 글로벌 설치 (모든 프로젝트에서 사용)**

```bash
# 레포지토리 클론
git clone https://github.com/coolhero/spec-kit-skills.git

# 심볼릭 링크 생성
ln -s /path/to/spec-kit-skills/.claude/skills/reverse-spec ~/.claude/skills/reverse-spec
ln -s /path/to/spec-kit-skills/.claude/skills/smart-sdd ~/.claude/skills/smart-sdd
```

**방법 2: 프로젝트 로컬 설치 (특정 프로젝트에서만 사용)**

```bash
# 프로젝트 루트에서
mkdir -p .claude/skills
cp -r /path/to/spec-kit-skills/.claude/skills/reverse-spec .claude/skills/
cp -r /path/to/spec-kit-skills/.claude/skills/smart-sdd .claude/skills/
```

### 설치 확인

Claude Code에서 아래 명령으로 스킬이 인식되는지 확인합니다:

```
/reverse-spec --help
/smart-sdd status
```

---

## 프로젝트 구조

```
spec-kit-skills/
└── .claude/
    └── skills/
        ├── reverse-spec/
        │   ├── SKILL.md                                 # 메인 스킬 정의 (5-Phase 워크플로우)
        │   ├── templates/
        │   │   ├── roadmap-template.md                  # Feature 진화 맵 템플릿
        │   │   ├── entity-registry-template.md           # 공유 엔티티 레지스트리 템플릿
        │   │   ├── api-registry-template.md              # API 계약 레지스트리 템플릿
        │   │   ├── business-logic-map-template.md        # 비즈니스 로직 맵 템플릿
        │   │   ├── constitution-seed-template.md         # Constitution 초안 템플릿
        │   │   └── pre-context-template.md               # Feature별 교차참조 정보 템플릿
        │   └── reference/
        │       └── speckit-compatibility.md              # spec-kit 연계 가이드
        └── smart-sdd/
            ├── SKILL.md                                 # 메인 스킬 정의 (오케스트레이터)
            └── reference/
                ├── context-injection-rules.md            # 커맨드별 컨텍스트 주입 규칙
                └── state-schema.md                      # sdd-state.md 스키마 정의
```
