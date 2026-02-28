---
name: reverse-spec
description: 기존 소스 코드를 역분석하여 spec-kit SDD 재개발을 위한 Global Evolution Layer(roadmap.md + 보조 산출물)를 추출합니다. 기존 구현에서 스펙을 역추출하는 Reverse Specification 스킬입니다.
argument-hint: [target-directory]
disable-model-invocation: true
allowed-tools: [Read, Grep, Glob, Bash, Write, Task, AskUserQuestion]
---

# Reverse-Spec: 기존 소스코드 → spec-kit Global Evolution Layer 역추출

기존 소스 코드를 분석하여 spec-kit 기반 SDD(Spec-Driven Development) 재개발에 필요한 프로젝트 수준의 글로벌 컨텍스트를 추출한다.

**대상 디렉토리**: `$ARGUMENTS` (미지정 시 현재 디렉토리)

아래 5개 Phase를 순서대로 실행한다. 각 Phase 완료 후 진행 상황을 사용자에게 보고한다.

---

## Phase 0 — 전략 질문

산출물의 방향을 결정하기 위해 사용자에게 두 가지를 질문한다.

### 질문 1: 구현 범위
사용자에게 AskUserQuestion으로 질문:
- **핵심만 구현 (Core)**: 프로젝트의 근간이 되는 핵심 기능만 재개발. 학습/프로토타이핑 목적
- **전체 구현 (Full)**: 기존과 동일한 전체 기능을 재개발

### 질문 2: 기술 스택 전략
사용자에게 AskUserQuestion으로 질문:
- **동일 스택 (Same)**: 기존과 동일한 언어, 프레임워크, 라이브러리 사용
- **신규 스택 (New)**: 최적의 현대적 기술 스택으로 전환

두 응답을 기록하고 이후 모든 Phase에서 참조한다.

---

## Phase 1 — 프로젝트 스캔

대상 디렉토리의 전체 구조와 기술 스택을 파악한다.

### 1-1. 디렉토리 구조 탐색
- Glob으로 주요 파일 패턴 탐색: `**/*.{py,js,ts,jsx,tsx,java,go,rs,rb,php,cs,kt,swift}` 등
- 최상위 디렉토리 구조 파악
- `.gitignore`, `node_modules/`, `venv/` 등 제외 대상 식별

### 1-2. 기술 스택 감지
설정 파일을 읽어 기술 스택을 식별한다:

| 감지 대상 | 탐색 파일 |
|-----------|-----------|
| 언어/버전 | `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `build.gradle`, `pom.xml`, `Gemfile`, `composer.json`, `.python-version`, `.nvmrc`, `.tool-versions` |
| 프레임워크 | 의존성 목록에서 프레임워크 식별 (React, Next.js, Django, FastAPI, Spring, Express, Rails 등) |
| DB/스토리지 | ORM 설정, 마이그레이션 파일, 연결 설정 |
| 테스트 | 테스트 프레임워크 설정, 테스트 디렉토리 구조 |
| 빌드/배포 | Dockerfile, docker-compose, CI/CD 설정, Makefile |

### 1-3. 프로젝트 타입 판별
수집한 정보로 프로젝트 타입을 판별:
- **backend**: API 서버, 서비스
- **frontend**: SPA, SSR 웹앱
- **fullstack**: 백엔드 + 프론트엔드 통합
- **mobile**: iOS/Android 앱
- **library**: 재사용 가능한 라이브러리/패키지

### 1-4. 모듈/패키지 경계 식별
- 디렉토리 구조에서 논리적 모듈 경계 파악
- 모노레포의 경우 워크스페이스/패키지 경계 식별
- 각 모듈의 역할 추정

Phase 1 완료 시 사용자에게 감지된 기술 스택과 프로젝트 구조를 요약 보고한다.

---

## Phase 2 — 심층 분석

Phase 1에서 파악한 기술 스택에 맞는 패턴으로 심층 분석을 수행한다. 대규모 코드베이스의 경우 Task 도구로 병렬 서브에이전트를 활용한다.

### 2-1. 데이터 모델 추출
기술 스택에 따라 적절한 소스에서 엔티티를 추출:

| 기술 | 탐색 대상 |
|------|-----------|
| Django | `models.py`, migrations |
| SQLAlchemy/FastAPI | 모델 클래스, Alembic migrations |
| TypeORM/Prisma | 엔티티 클래스, `schema.prisma` |
| Sequelize | 모델 정의, migrations |
| JPA/Hibernate | `@Entity` 클래스 |
| Mongoose | Schema 정의 |
| Go | struct 정의 + DB 태그 |
| Rails | `app/models/`, migrations |

각 엔티티에서 추출할 정보:
- 엔티티명, 필드(이름, 타입, 제약조건)
- 관계(1:1, 1:N, M:N, 대상 엔티티)
- 유효성 검증 규칙
- 상태 전이(enum, state machine)
- 인덱스, 유니크 제약

### 2-2. API 엔드포인트 추출
기술 스택에 따라 적절한 소스에서 API를 추출:

| 기술 | 탐색 대상 |
|------|-----------|
| Express/Fastify | 라우터 파일, `app.use()`, `router.get()` 등 |
| Django/DRF | `urls.py`, ViewSet, APIView |
| FastAPI | `@app.get()`, `@router.post()` 등 데코레이터 |
| Spring | `@RequestMapping`, `@GetMapping` 등 |
| Rails | `config/routes.rb`, controllers |
| Next.js/Nuxt | `pages/api/`, `app/api/` 디렉토리 |
| Go (net/http, Gin, Echo) | 라우터 등록, 핸들러 함수 |

각 엔드포인트에서 추출할 정보:
- HTTP 메서드, 경로
- 요청 파라미터, 바디 스키마
- 응답 스키마 (상태코드별)
- 인증/인가 요구사항
- 미들웨어/인터셉터

### 2-3. 비즈니스 로직 추출
서비스 레이어, 유틸리티, 도메인 로직에서 추출:
- **비즈니스 규칙**: 조건부 로직, 정책 적용, 계산 로직
- **유효성 검증**: 입력 검증, 상태 전이 조건, 비즈니스 제약
- **워크플로우**: 다단계 프로세스, 상태 머신, 이벤트 체인
- **외부 연동**: 외부 API 호출, 메시지 큐, 이벤트 발행/구독

### 2-4. 모듈 간 의존성 매핑
- import/require 분석으로 모듈 간 의존 관계 파악
- 서비스 호출 관계 (의존성 주입, 직접 호출)
- 공유 유틸리티, 공통 타입 사용 관계
- 이벤트/메시지 기반 결합 관계

Phase 2 완료 시 발견된 엔티티 수, API 수, 비즈니스 규칙 수를 요약 보고한다.

---

## Phase 3 — Feature 분류 및 중요도 분석

### 3-1. Feature 경계 식별
Phase 2의 분석 결과를 기반으로 논리적 기능 단위(Feature)를 식별한다:
- 도메인 모듈 경계 (예: auth, product, order, payment)
- 서비스 경계 (마이크로서비스 구조의 경우)
- 라우트 그룹 (API 경로 prefix 기반)
- 엔티티 클러스터 (밀접하게 관련된 엔티티 그룹)

각 Feature에 대해 정의:
- Feature 이름 (간결한 영문 이름)
- 설명 (1-2문장)
- 소속 파일 목록
- 소유 엔티티
- 제공 API

> 이 시점에서는 아직 Feature ID를 부여하지 않는다. 3-2에서 의존성 그래프를 구성한 후 위상정렬 기반으로 번호를 배정한다.

### 3-2. 의존성 그래프 구성 및 Feature ID 배정
Feature 간 의존 관계를 도출한다:
- **직접 의존**: import/require로 다른 Feature의 모듈을 사용
- **API 의존**: 다른 Feature가 제공하는 API를 호출
- **엔티티 의존**: 다른 Feature가 소유하는 엔티티를 참조
- **이벤트 의존**: 다른 Feature가 발행하는 이벤트를 구독

의존성 방향과 유형을 기록하고 Mermaid 다이어그램으로 시각화한다.

**Feature ID 배정 규칙**:
의존성 그래프의 위상정렬(topological sort) 결과 순서로 Feature ID를 배정한다.
- 의존하는 Feature가 없는(선행 의존성 0개) Feature가 가장 낮은 번호를 받는다
- 동일 레벨의 Feature는 Tier가 높은 순서(Tier 1 → 2 → 3)로 배정한다
- 결과적으로 F001, F002, ... 순서가 곧 **구현 가능 순서**가 된다
- 이 번호는 spec-kit의 `specs/{NNN-feature}/` 디렉토리명과도 일치시킨다 (예: F001-auth → `specs/001-auth/`)

### 3-3. 중요도 분석 및 Tier 분류

먼저 프로젝트 도메인을 파악한다: 프로젝트가 어떤 종류의 시스템인지(e-commerce, SaaS, CMS, 교육 플랫폼, 금융 서비스 등) 이해하고, 해당 도메인에서 근간이 되는 기능이 무엇인지 판단한다.

각 Feature를 5가지 분석 축으로 종합 평가한다:

**분석 축 1 — 구조적 근간**
- 다른 Feature들이 이 Feature 없이 존재할 수 없는가
- 판단 근거: 피의존 횟수, import 깊이, 공유 엔티티 소유 수

**분석 축 2 — 도메인 핵심**
- 이 프로젝트의 존재 이유와 직결되는 기능인가
- 판단 근거: 프로젝트 도메인에서의 역할 (예: e-commerce라면 상품/주문이 핵심)

**분석 축 3 — 데이터 소유권**
- 핵심 엔티티를 정의하고 관리하는 기능인가
- 판단 근거: 소유 엔티티 수, 다른 Feature에서 참조되는 엔티티 비율

**분석 축 4 — 통합 허브**
- 다른 Feature/외부 시스템과의 연결 지점인가
- 판단 근거: API provider 역할, 외부 연동 수, 이벤트 발행 수

**분석 축 5 — 비즈니스 복잡도**
- 핵심 비즈니스 규칙이 집중된 기능인가
- 판단 근거: 비즈니스 규칙 수, 상태 전이 수, 유효성 검증 복잡도

종합 평가 결과로 각 Feature를 Tier에 배정한다:

| Tier | 의미 | 기준 |
|------|------|------|
| **Tier 1 (필수)** | 프로젝트의 근간. 이것 없이는 시스템이 성립하지 않음 | 재개발 시 반드시 포함 |
| **Tier 2 (권장)** | 핵심 사용자 경험을 완성하는 기능 | 없어도 동작하지만 핵심 가치가 크게 저하 |
| **Tier 3 (선택)** | 부가 기능, 관리 도구, 편의 기능 | 이후 단계에서 추가 가능 |

각 Feature에 대해 해당 Tier로 분류한 **구체적 이유**를 반드시 제시한다.
예시:
- "인증(Auth)을 Tier 1로 추천: 7개 Feature가 직접 의존, User 엔티티의 소유자, 모든 API의 미들웨어로 사용됨"
- "알림(Notification)을 Tier 3으로 추천: 독립적 모듈로 다른 Feature에 피의존 없음, 이벤트 구독 방식으로 느슨하게 결합"

분류 결과를 사용자에게 AskUserQuestion으로 제시하고 승인/조정을 받는다.

### 3-4. 스택 전략 상세화 (Phase 0에서 "신규 스택"을 선택한 경우에만)
- 현재 기술 요소별 현대적 대안 제안
- 각 대안의 장단점, 마이그레이션 복잡도, 학습 비용 평가
- 사용자에게 확인 후 확정

---

## Phase 4 — 산출물 생성

확정된 분석 결과로 계층형 산출물을 생성한다. 대상 디렉토리 내에 `specs/reverse-spec/` 디렉토리를 생성한다.

### 4-1. 프로젝트 수준 산출물

아래 파일들을 순서대로 생성한다. 각 파일은 이 스킬의 `templates/` 디렉토리에 있는 템플릿 구조를 따른다.

1. **`specs/reverse-spec/roadmap.md`** — [roadmap-template.md](templates/roadmap-template.md) 참조
   - Project Overview, Rebuild Strategy, Feature Catalog (Tier별), Dependency Graph, Release Groups, Cross-Feature Dependencies

2. **`specs/reverse-spec/entity-registry.md`** — [entity-registry-template.md](templates/entity-registry-template.md) 참조
   - 전체 엔티티 목록, 필드, 관계, 유효성 규칙, Feature 간 공유 매핑

3. **`specs/reverse-spec/api-registry.md`** — [api-registry-template.md](templates/api-registry-template.md) 참조
   - 전체 API 엔드포인트 인덱스, 상세 계약, Cross-Feature 의존성

4. **`specs/reverse-spec/business-logic-map.md`** — [business-logic-map-template.md](templates/business-logic-map-template.md) 참조
   - Feature별 비즈니스 규칙, 유효성 검증, 워크플로우, Cross-Feature 규칙

5. **`specs/reverse-spec/constitution-seed.md`** — [constitution-seed-template.md](templates/constitution-seed-template.md) 참조
   - 소스코드 참조 원칙 (스택 전략별 분기), 추출된 아키텍처 원칙, 기술 제약, 코딩 컨벤션

6. **`specs/reverse-spec/stack-migration.md`** (신규 스택 전략 시에만)
   - 기술 요소별 현재 → 신규 매핑, 마이그레이션 계획

### 4-2. Feature 수준 산출물

각 Feature에 대해 `specs/reverse-spec/features/[Feature-ID]-[feature-name]/pre-context.md`를 생성한다. [pre-context-template.md](templates/pre-context-template.md) 참조.

각 pre-context.md에 포함할 내용:
- **Source Reference**: 관련 원본 파일 목록 + 스택 전략별 참조 가이드
- **For /speckit.specify**: 기존 기능 요약, 요구사항 초안 (FR-###), 수용 기준 초안 (SC-###)
- **For /speckit.plan**: 선행 Feature 의존성, 관련 엔티티/API 계약 초안, 기술적 결정사항
- **For /speckit.analyze**: 교차 Feature 검증 포인트

### 4-3. 완료 보고

생성된 전체 산출물 목록과 다음 단계 안내를 사용자에게 보고한다:

```
생성 완료:
- specs/reverse-spec/roadmap.md
- specs/reverse-spec/constitution-seed.md
- specs/reverse-spec/entity-registry.md
- specs/reverse-spec/api-registry.md
- specs/reverse-spec/business-logic-map.md
- specs/reverse-spec/features/F001-xxx/pre-context.md
- specs/reverse-spec/features/F002-xxx/pre-context.md
- ...

다음 단계:
1. /smart-sdd pipeline으로 전체 파이프라인을 실행하거나, 아래 단계를 수동으로 진행하세요
2. specs/reverse-spec/constitution-seed.md를 검토하고 /speckit.constitution으로 constitution을 확정하세요
3. specs/reverse-spec/roadmap.md의 Release Group 순서대로 /speckit.specify를 실행하세요
   - 각 Feature의 pre-context.md를 참조하면 기존 기능이 빠짐없이 반영됩니다
```

---

## 주의사항

- 대규모 코드베이스(파일 1000개 이상)의 경우, Phase 2에서 Task 도구로 모델/API/로직 추출을 병렬 서브에이전트로 분산 처리한다.
- 바이너리 파일, 빌드 결과물, node_modules, venv 등은 분석에서 제외한다.
- 각 Phase 완료 시 진행 상황을 사용자에게 요약 보고한다.
- 산출물의 엔티티/API 포맷은 spec-kit의 data-model.md, contracts/ 스타일과 호환되도록 작성한다.
- spec-kit 연계 가이드는 [speckit-compatibility.md](reference/speckit-compatibility.md)를 참조한다.
