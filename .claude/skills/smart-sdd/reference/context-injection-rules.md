# Context Injection Rules

이 문서는 smart-sdd가 각 spec-kit 커맨드 실행 전에 어떤 파일의 어떤 섹션을 읽어 컨텍스트로 주입하는지 정의한다.

**BASE_PATH**: `specs/reverse-spec/` (또는 `--from`으로 지정된 경로)
**SPEC_PATH**: `specs/` (spec-kit 피처 산출물 경로. `specs/{NNN-feature}/` 형태)

---

## 1. Constitution

### 읽기 대상

| 파일 | 섹션 | 필터링 |
|------|------|--------|
| `BASE_PATH/constitution-seed.md` | 전체 | 없음 (전체 로드) |

### 주입 내용

constitution-seed.md의 모든 내용을 `/speckit.constitution` 실행 시 컨텍스트로 제공:
- 기존 소스코드 참조 원칙 (스택 전략에 맞는 섹션만)
- 추출된 아키텍처 원칙
- 추출된 기술 제약
- 추출된 코딩 컨벤션
- 권장 개발 원칙 (Best Practices)
- Global Evolution Layer 운영 원칙

### Checkpoint 표시 내용

```
📋 Constitution 확정을 위한 컨텍스트:

소스 참조 전략: [동일 스택 / 신규 스택]
아키텍처 원칙: [N]개 추출
기술 제약: [N]개 항목
코딩 컨벤션: [N]개 항목
Best Practices: Test-First, Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution
Global Evolution 운영 원칙: Cross-Feature Consistency

수정할 내용이 있으면 알려주세요. 승인하시면 /speckit.constitution을 실행합니다.
```

---

## 2. Specify

### 읽기 대상

| 파일 | 섹션 | 필터링 |
|------|------|--------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.specify" 섹션 | 해당 Feature만 |
| `BASE_PATH/business-logic-map.md` | 해당 Feature 섹션 | Feature ID로 필터링 |
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "Source Reference" 섹션 | 원본 파일 목록 참조 |

### Feature 섹션 필터링 규칙 (business-logic-map.md)

1. `business-logic-map.md`에서 `## F[ID]` 헤딩으로 시작하는 섹션을 찾는다
2. 해당 Feature의 Core Rules, Validation Logic, Workflows 섹션을 추출한다
3. Cross-Feature Rules 섹션에서 해당 Feature가 관련된 규칙을 추출한다

### 주입 내용

- **기능 요약**: pre-context의 기능 설명과 범위
- **요구사항 초안 (FR-###)**: pre-context에서 추출한 Functional Requirements 초안
- **수용 기준 초안 (SC-###)**: pre-context에서 추출한 Success Criteria / Acceptance Scenario 초안
- **비즈니스 규칙**: business-logic-map에서 해당 Feature의 규칙 목록
- **엣지 케이스**: pre-context와 business-logic-map에서 발견된 엣지 케이스
- **원본 소스 참조**: Source Reference의 파일 목록 (spec-kit이 원본을 읽어 기존 구현을 확인할 수 있도록)

### 선행 Feature 결과 참조

이미 완료된 선행 Feature가 있고 현재 Feature가 그에 의존하는 경우:
1. `BASE_PATH/roadmap.md`에서 의존 관계를 확인한다
2. 선행 Feature의 `SPEC_PATH/[feature-name]/spec.md`가 있으면 관련 요구사항을 참조한다
3. Checkpoint에서 "선행 Feature [FID]의 spec 참조" 정보를 표시한다

### Checkpoint 표시 내용

```
📋 Specify 실행을 위한 컨텍스트:

Feature: [FID] - [Feature Name]
주입할 정보:
  - pre-context "For /speckit.specify": FR-### [N]개, SC-### [N]개
  - business-logic-map: 비즈니스 규칙 [N]개
  - 원본 소스: [N]개 파일
  - [선행 Feature 참조: F00X의 spec.md]

수정할 내용이 있으면 알려주세요.
```

---

## 3. Plan

### 읽기 대상

| 파일 | 섹션 | 필터링 |
|------|------|--------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.plan" 섹션 | 해당 Feature만 |
| `BASE_PATH/entity-registry.md` | 관련 엔티티 섹션 | 아래 규칙 참조 |
| `BASE_PATH/api-registry.md` | 관련 API 섹션 | 아래 규칙 참조 |
| `SPEC_PATH/[feature-name]/spec.md` | 전체 | 현재 Feature의 확정된 spec |

### Entity Registry 필터링 규칙

1. `pre-context.md`의 "For /speckit.plan" 섹션에서 **관련 엔티티 초안** 목록을 확인한다
2. `entity-registry.md`에서 해당 엔티티명으로 `### [Entity Name]` 헤딩을 찾는다
3. 해당 Feature가 **소유**하는 엔티티: 전체 스키마(Fields, Relationships, Validation Rules, State Transitions, Indexes) 추출
4. 해당 Feature가 **참조**하는 엔티티: 요약 스키마(Fields, Relationships만) 추출

### API Registry 필터링 규칙

1. `pre-context.md`의 "For /speckit.plan" 섹션에서 **관련 API** 목록을 확인한다
2. `api-registry.md`에서 해당 API 경로로 섹션을 찾는다
3. 해당 Feature가 **제공(Provider)**하는 API: 전체 계약 추출
4. 해당 Feature가 **소비(Consumer)**하는 API: 요약 계약(Method, Path, Request/Response 스키마만) 추출

### 선행 Feature 실제 구현 참조

의존하는 선행 Feature의 실제 구현 결과를 참조한다:
1. `BASE_PATH/roadmap.md`에서 의존 관계를 확인한다
2. 선행 Feature의 `SPEC_PATH/[feature-name]/plan.md`가 존재하면:
   - `data-model.md`에서 공유 엔티티의 확정된 스키마를 읽는다
   - `contracts/`에서 소비할 API의 확정된 계약을 읽는다
3. 이 정보는 entity-registry/api-registry의 초안보다 **우선 적용**된다

### 주입 내용

- **의존성 정보**: 선행 Feature 목록과 의존 유형
- **엔티티 스키마 초안**: entity-registry에서 필터링한 관련 엔티티 (또는 선행 Feature의 확정 스키마)
- **API 계약 초안**: api-registry에서 필터링한 관련 API (또는 선행 Feature의 확정 계약)
- **기술적 결정사항**: pre-context의 기술 결정 초안
- **선행 Feature 실제 결과**: 이미 plan 완료된 Feature의 data-model, contracts 참조

### Checkpoint 표시 내용

```
📋 Plan 실행을 위한 컨텍스트:

Feature: [FID] - [Feature Name]
주입할 정보:
  - pre-context "For /speckit.plan": 의존성 [N]개, 기술 결정 [N]개
  - entity-registry: 소유 엔티티 [N]개, 참조 엔티티 [N]개
  - api-registry: 제공 API [N]개, 소비 API [N]개
  - [선행 Feature: F00X plan 결과 반영 (확정 스키마 우선)]

수정할 내용이 있으면 알려주세요.
```

---

## 4. Tasks

### 읽기 대상

| 파일 | 섹션 | 필터링 |
|------|------|--------|
| `SPEC_PATH/[feature-name]/plan.md` | 전체 | 현재 Feature |

### 주입 내용

- plan.md를 기반으로 `/speckit.tasks`를 자동 실행한다
- 추가 컨텍스트 주입 없음 (plan에 이미 모든 정보가 포함됨)

### Checkpoint

간소화된 체크포인트만 표시:
```
📋 Tasks 생성: [FID] - [Feature Name]
plan.md 기반으로 /speckit.tasks를 실행합니다. 진행하시겠습니까?
```

---

## 5. Implement

### 읽기 대상

| 파일 | 섹션 | 필터링 |
|------|------|--------|
| `SPEC_PATH/[feature-name]/tasks.md` | 전체 | 현재 Feature |

### 주입 내용

- tasks.md를 기반으로 `/speckit.implement`를 자동 실행한다
- 추가 컨텍스트 주입 없음

### Checkpoint

간소화된 체크포인트만 표시:
```
📋 Implement 실행: [FID] - [Feature Name]
tasks.md 기반으로 /speckit.implement를 실행합니다. 진행하시겠습니까?
```

---

## 6. Verify / Analyze

### 읽기 대상

| 파일 | 섹션 | 필터링 |
|------|------|--------|
| `BASE_PATH/features/[FID]-[name]/pre-context.md` | "For /speckit.analyze" 섹션 | 해당 Feature만 |
| `BASE_PATH/entity-registry.md` | 해당 Feature가 변경한 엔티티 | 변경 추적 |
| `BASE_PATH/api-registry.md` | 해당 Feature가 변경한 API | 변경 추적 |
| `SPEC_PATH/[feature-name]/` | data-model.md, contracts/ | 실제 구현 결과 |

### 주입 내용

- **교차 Feature 검증 포인트**: pre-context의 교차 검증 체크리스트
- **영향 범위 분석**: 변경된 엔티티/API를 참조하는 다른 Feature 목록
- **정합성 검증**: entity-registry/api-registry와 실제 구현의 일치 여부

### Checkpoint 표시 내용

```
📋 Verify 실행: [FID] - [Feature Name]

검증 항목:
  1단계: 실행 검증 (테스트/빌드/린트)
  2단계: Cross-Feature 검증 ([N]개 교차 검증 포인트)
  3단계: Global Evolution 업데이트 (entity-registry, api-registry 정합성)

진행하시겠습니까?
```

---

## Post-Step 업데이트 규칙 상세

### Plan 완료 후

1. `SPEC_PATH/[NNN-feature-name]/data-model.md`를 읽는다
2. `BASE_PATH/entity-registry.md`와 비교한다:
   - 새로 정의된 엔티티 → entity-registry에 추가
   - 기존 엔티티의 필드/관계 변경 → entity-registry 갱신
   - "Used by Features" 컬럼 업데이트
3. `SPEC_PATH/[NNN-feature-name]/contracts/`를 읽는다
4. `BASE_PATH/api-registry.md`와 비교한다:
   - 새로 정의된 API → api-registry에 추가
   - 기존 API의 계약 변경 → api-registry 갱신
   - "Cross-Feature Consumers" 정보 업데이트

### Implement 완료 후

1. `BASE_PATH/roadmap.md`에서 해당 Feature의 Status를 `completed`로 변경한다
2. 후속 Feature 영향 분석:
   - `roadmap.md`의 Dependency Graph에서 현재 Feature에 의존하는 Feature 목록을 찾는다
   - 각 후속 Feature의 `pre-context.md`를 검사한다
   - "For /speckit.plan" 섹션의 엔티티/API 초안이 실제 구현과 다르면 갱신한다
   - 변경 사항을 사용자에게 보고한다

### Verify 완료 후

1. `BASE_PATH/sdd-state.md`에 검증 결과를 기록한다:
   - 테스트 결과 (통과/실패, 실행 시각)
   - 빌드 결과
   - Cross-Feature 검증 결과
   - 전체 검증 상태 (pass/fail)
