# Reverse-Spec ↔ Spec-Kit 호환성 가이드

이 문서는 `/reverse-spec` 스킬의 산출물을 spec-kit 워크플로우에서 어떻게 활용하는지 설명합니다.

---

## 산출물 ↔ Spec-Kit 커맨드 매핑

| Reverse-Spec 산출물 | Spec-Kit 커맨드 | 사용 방법 |
|--------------------|-----------------|-----------|
| `constitution-seed.md` | `/speckit.constitution` | 초안으로 로딩하여 원칙 수립. 기존 코드에서 추출한 아키텍처 원칙과 소스 참조 전략을 constitution에 반영 |
| `roadmap.md` Feature Catalog | `/speckit.specify` | Feature 설명의 입력 소스. Tier별 Feature 목록에서 구현 대상을 선택하고 설명을 입력값으로 사용 |
| `pre-context.md` → For /speckit.specify | `/speckit.specify` | spec.md의 Requirements(FR-###)와 Success Criteria(SC-###) 초안으로 활용 |
| `entity-registry.md` | `/speckit.plan` | data-model.md 작성 시 전역 엔티티 참조. 교차 Feature 엔티티 충돌 방지 |
| `api-registry.md` | `/speckit.plan` | contracts/ 작성 시 전역 API 계약 참조. 교차 Feature API 일관성 보장 |
| `pre-context.md` → For /speckit.plan | `/speckit.plan` | 선행 Feature 의존성, 관련 엔티티/API 초안, 기술적 결정사항 참조 |
| `business-logic-map.md` | `/speckit.specify` | 기존 비즈니스 규칙 누락 방지. spec 작성 시 모든 규칙이 반영되었는지 체크 |
| `pre-context.md` → For /speckit.analyze | `/speckit.analyze` | 교차 Feature 검증 포인트로 Feature 간 일관성 검증 |

---

## 워크플로우: Pre-Extract → Spec-Kit 진행 순서

### Step 1: Constitution 확정

```
1. specs/reverse-spec/constitution-seed.md를 읽는다
2. /speckit.constitution 실행 시 constitution-seed.md의 내용을 입력으로 제공한다
3. 스택 전략에 맞는 소스코드 참조 원칙을 선택하여 constitution에 포함시킨다
4. Global Evolution Layer 운영 원칙을 constitution에 포함시킨다
5. 추출된 아키텍처 원칙을 검토하고 재개발에 맞게 수정/보완한다
```

### Step 2: Feature 순서대로 Specify → Plan → Tasks → Implement

```
roadmap.md의 Release Group 순서를 따른다:
  Release 1 (Foundation) → Release 2 (Core Business) → Release 3 (Enhancement) → ...

각 Feature 진행 시:
  1. specs/reverse-spec/features/F00N-xxx/pre-context.md를 읽는다
  2. /speckit.specify 실행:
     - pre-context.md의 "For /speckit.specify" 섹션을 참조
     - Source Reference의 원본 파일을 읽어 기존 구현 확인
     - 기존 요구사항 초안(FR-###)과 수용 기준 초안(SC-###)을 활용
  3. /speckit.plan 실행:
     - pre-context.md의 "For /speckit.plan" 섹션을 참조
     - entity-registry.md에서 관련 엔티티 스키마 확인
     - api-registry.md에서 관련 API 계약 확인
     - 선행 Feature 의존성을 반영한 설계
  4. /speckit.tasks → /speckit.implement
  5. 완료 후: entity-registry.md, api-registry.md를 최신 상태로 업데이트
```

---

## 포맷 호환성 상세

### Entity Registry → Spec-Kit data-model.md

| Entity Registry 필드 | data-model.md 대응 |
|----------------------|-------------------|
| Fields 테이블 | Entities → Fields 섹션 |
| Relationships 테이블 | Entities → Relationships 섹션 |
| Validation Rules 테이블 | Entities → Validation Rules 섹션 |
| State Transitions 다이어그램 | Entities → State Transitions 섹션 |
| Indexes 테이블 | Entities → Indexes 섹션 |

**변환 방법**: Entity Registry에서 해당 Feature가 소유하는 엔티티 섹션을 발췌하여 data-model.md에 배치한다. 참조 엔티티는 "External Entity" 주석과 함께 스키마를 포함한다.

### API Registry → Spec-Kit contracts/

| API Registry 필드 | contracts/ 대응 |
|-------------------|----------------|
| Method + Path | Contract 파일명 (예: `post-auth-register.md`) |
| Request Body/Parameters | Request Schema 섹션 |
| Response (상태코드별) | Response Schema 섹션 |
| Auth | Authentication 섹션 |
| Dependencies | Dependencies 섹션 |

**변환 방법**: API Registry에서 해당 Feature가 제공하는 API 섹션을 발췌하여 contracts/ 디렉토리의 개별 파일로 분리한다.

### Business Logic Map → Spec-Kit spec.md

| Business Logic Map 필드 | spec.md 대응 |
|-------------------------|-------------|
| Core Rules | Requirements (FR-###) |
| Validation Logic | Acceptance Scenarios (Given/When/Then) |
| Workflows | User Scenarios & Testing |
| Cross-Feature Rules | Requirements + Edge Cases |

**변환 방법**: Business Logic Map의 규칙들을 spec-kit의 요구사항 형식(FR-###)과 수용 시나리오(Given/When/Then)로 변환한다.

---

## Global Evolution Layer 유지보수

spec-kit으로 Feature를 구현한 후, 글로벌 산출물을 최신 상태로 유지해야 한다:

### 업데이트 시점

| 이벤트 | 업데이트 대상 |
|--------|-------------|
| Feature plan 완료 | entity-registry.md (새 엔티티 추가), api-registry.md (새 API 추가) |
| Feature implement 완료 | roadmap.md (Feature 상태 업데이트), pre-context.md (실제 구현 반영) |
| Feature 간 의존성 변경 | roadmap.md Dependency Graph, 관련 pre-context.md 의존성 섹션 |
| 새 Feature 추가 | roadmap.md Feature Catalog, 새 pre-context.md 생성 |

### 업데이트 규칙

1. **엔티티 스키마 변경 시**: entity-registry.md에서 해당 엔티티를 업데이트하고, 참조 Feature의 pre-context.md에서 교차 검증 포인트를 확인한다
2. **API 계약 변경 시**: api-registry.md에서 해당 API를 업데이트하고, Consumer Feature의 pre-context.md에서 호환성을 검증한다
3. **Feature 추가/삭제 시**: roadmap.md의 Feature Catalog, Dependency Graph, Release Groups를 업데이트한다
