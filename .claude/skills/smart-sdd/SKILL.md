---
name: smart-sdd
description: reverse-spec 산출물을 기반으로 spec-kit SDD 워크플로우를 오케스트레이션합니다. 각 단계에 교차 Feature 컨텍스트를 자동 주입하고 Global Evolution Layer를 유지합니다.
argument-hint: <command> [feature-id] [--from path]
disable-model-invocation: true
allowed-tools: [Read, Grep, Glob, Bash, Write, Task, Skill, AskUserQuestion]
---

# Smart-SDD: spec-kit 워크플로우 오케스트레이터

reverse-spec 산출물을 기반으로 spec-kit 커맨드를 감싸서(wrapping), 각 단계에 교차 Feature 컨텍스트를 자동 주입하고 Global Evolution Layer를 유지보수한다.

spec-kit 커맨드를 대체하지 않고, **컨텍스트 조립 → 사용자 확인 → spec-kit 실행 → Global Evolution 업데이트**의 4단계 프로토콜로 감싼다.

---

## 사용법

```
/smart-sdd pipeline                    # 전체 파이프라인 실행
/smart-sdd pipeline --from ./path      # 지정 경로에서 reverse-spec 산출물 읽기
/smart-sdd constitution                # constitution 확정 (최초 1회)
/smart-sdd specify F001                # F001 Feature specify
/smart-sdd plan F001                   # F001 Feature plan
/smart-sdd tasks F001                  # F001 Feature tasks
/smart-sdd implement F001             # F001 Feature implement
/smart-sdd verify F001                 # F001 Feature 검증
/smart-sdd status                      # 전체 진행 상태 확인
```

---

## 경로 규약

| 대상 | 경로 | 비고 |
|------|------|------|
| reverse-spec 산출물 | `specs/reverse-spec/` | `--from` 인자로 변경 가능 |
| spec-kit 피처 산출물 | `specs/{NNN-feature}/` | spec-kit 고유 경로. smart-sdd가 건드리지 않음 |
| spec-kit constitution | `.specify/memory/constitution.md` | spec-kit 고유 경로 |
| 상태 파일 | `specs/reverse-spec/sdd-state.md` | smart-sdd가 생성/관리 |

### reverse-spec 산출물 구조

```
specs/reverse-spec/
├── roadmap.md
├── constitution-seed.md
├── entity-registry.md
├── api-registry.md
├── business-logic-map.md
├── stack-migration.md              # (신규 스택 시에만)
├── sdd-state.md                    # smart-sdd가 생성/관리하는 상태 파일
└── features/
    ├── F001-auth/pre-context.md
    ├── F002-product/pre-context.md
    └── ...
```

---

## 인자 파싱

`$ARGUMENTS`를 파싱하여 command, feature-id, options를 추출한다.

```
$ARGUMENTS 파싱 규칙:
  첫 번째 토큰 → command (pipeline | constitution | specify | plan | tasks | implement | verify | status)
  두 번째 토큰 → feature-id (F001 형태, command가 specify/plan/tasks/implement/verify일 때 필수)
  --from <path> → reverse-spec 산출물 경로 (미지정 시 ./specs/reverse-spec/)
```

**BASE_PATH** 결정:
- `--from` 지정 시: 해당 경로
- 미지정 시: `./specs/reverse-spec/`

**사전 검증**: BASE_PATH에 `roadmap.md`가 존재하는지 확인한다. 없으면 오류 메시지와 함께 `/reverse-spec`을 먼저 실행하라고 안내한다.

---

## 공통 프로토콜: Assemble → Checkpoint → Execute → Update

모든 spec-kit 커맨드 실행은 이 4단계 프로토콜을 따른다.

### 1. Assemble — 컨텍스트 조립

- BASE_PATH에서 해당 커맨드에 필요한 파일/섹션을 읽는다
- [context-injection-rules.md](reference/context-injection-rules.md)에 따라 커맨드별 필요 정보를 필터링하여 조립한다
- 선행 Feature의 실제 구현 결과 (`specs/` 하위)가 있으면 함께 참조한다

### 2. Checkpoint — 사용자 확인

조립된 컨텍스트를 **요약 형태**로 사용자에게 보여준다:

```
📋 [command] 실행을 위한 컨텍스트:

Feature: [Feature ID] - [Feature Name]
주입할 정보:
  - [소스 1]: [요약]
  - [소스 2]: [요약]
  - ...

선행 조건: [충족 여부]
교차 Feature 참고: [관련 Feature 목록]

이 컨텍스트로 /speckit.[command]를 실행하시겠습니까?
수정할 내용이 있으면 알려주세요.
```

AskUserQuestion으로 사용자의 승인/수정을 받는다.

### 3. Execute — spec-kit 커맨드 실행

승인된 컨텍스트와 함께 해당 spec-kit 커맨드를 실행한다:
- Skill 도구로 `speckit.[command]`를 호출한다
- 조립된 컨텍스트 내용을 대화에 포함하여 spec-kit이 참조할 수 있게 한다
- spec-kit 커맨드가 생성/수정하는 피처 산출물은 `specs/{NNN-feature}/` 하위에 위치한다

### 4. Update — Global Evolution Layer 갱신

커맨드 실행 결과를 반영하여 글로벌 산출물을 업데이트한다:

| 완료 단계 | 업데이트 대상 | 내용 |
|-----------|-------------|------|
| plan | `entity-registry.md` | plan에서 확정된 `data-model.md`의 새 엔티티/변경사항 반영 |
| plan | `api-registry.md` | plan에서 확정된 `contracts/`의 새 API/변경사항 반영 |
| implement | `roadmap.md` | Feature 상태를 completed로 변경 |
| implement | 후속 Feature `pre-context.md` | 변경된 엔티티/API로 영향받는 pre-context 갱신 |
| verify | `sdd-state.md` | 검증 결과 기록 |

업데이트 후 사용자에게 변경 사항을 보고한다.

---

## Pipeline 모드

`/smart-sdd pipeline` 실행 시 전체 워크플로우를 순차적으로 진행한다.

### Phase 0: Constitution 확정

1. `BASE_PATH/constitution-seed.md`를 읽는다
2. 사용자에게 constitution-seed 내용 요약을 보여주고 수정/보완 기회를 준다 (Checkpoint)
3. `/speckit.constitution` 실행 시 constitution-seed의 내용을 컨텍스트로 제공한다
4. `sdd-state.md`를 초기화하고 constitution 완료를 기록한다

### Phase 1~N: Release Group 순서대로 Feature 진행

`BASE_PATH/roadmap.md`의 Release Groups 순서를 따른다.

각 Feature에 대해 아래 단계를 순서대로 실행한다:

```
1. specify  → Assemble → Checkpoint → /speckit.specify → Update
2. clarify  → (spec에 [NEEDS CLARIFICATION]이 있을 때만 /speckit.clarify 실행)
3. plan     → Assemble → Checkpoint → /speckit.plan → Update (entity-registry, api-registry)
4. tasks    → /speckit.tasks 실행
5. implement → /speckit.implement 실행
6. verify   → 실행 검증 → Cross-Feature 검증 → Global Evolution 업데이트
```

#### Feature 완료 후 처리

Feature의 모든 단계가 완료되면:

1. **entity-registry.md 갱신**: plan에서 확정된 data-model.md의 엔티티를 반영
2. **api-registry.md 갱신**: plan에서 확정된 contracts/의 API를 반영
3. **roadmap.md 업데이트**: 해당 Feature 상태를 `completed`로 변경
4. **후속 Feature pre-context.md 영향 분석**:
   - 변경/추가된 엔티티를 참조하는 후속 Feature의 pre-context.md를 찾는다
   - 변경/추가된 API를 소비하는 후속 Feature의 pre-context.md를 찾는다
   - 영향받는 pre-context.md의 관련 섹션을 갱신한다
   - 갱신 내용을 사용자에게 보고한다
5. **sdd-state.md 업데이트**: 각 단계의 완료 시각과 결과를 기록

---

## Step 모드

단일 커맨드만 실행한다. 선행 조건을 검증한 후 공통 프로토콜(Assemble → Checkpoint → Execute → Update)을 실행한다.

### 선행 조건 검증

| 커맨드 | 선행 조건 | 검증 방법 |
|--------|----------|-----------|
| `constitution` | reverse-spec 산출물 존재 | `BASE_PATH/constitution-seed.md` 존재 확인 |
| `specify` | pre-context 존재 | `BASE_PATH/features/[FID]/pre-context.md` 존재 확인 |
| `plan` | spec.md 존재 | `specs/[NNN-feature-name]/spec.md` 존재 확인 |
| `tasks` | plan.md 존재 | `specs/[NNN-feature-name]/plan.md` 존재 확인 |
| `implement` | tasks.md 존재 | `specs/[NNN-feature-name]/tasks.md` 존재 확인 |
| `verify` | implement 완료 | `sdd-state.md`에서 implement 완료 확인 |

선행 조건이 미충족이면 오류 메시지와 함께 필요한 이전 단계를 안내한다.

### Feature ID → spec-kit Feature Name 매핑

`sdd-state.md`의 Feature 매핑 테이블 또는 `roadmap.md`의 Feature Catalog에서 Feature ID(F001)를 spec-kit이 사용하는 Feature Name(예: `001-auth`)으로 변환한다.

---

## Constitution 증분 업데이트

Feature 진행 중 새로운 아키텍처 원칙이나 컨벤션이 발견되면:

1. **체크포인트 표시**: "Constitution 업데이트를 제안합니다: [원칙 내용]"
2. **사용자 승인**: AskUserQuestion으로 승인 여부를 확인한다
3. **업데이트 실행**: 승인 시 `/speckit.constitution`으로 MINOR 버전 업데이트
4. **영향 분석**: 이미 완료된 Feature에 영향이 있으면 경고를 표시한다

---

## Status 커맨드

`/smart-sdd status` 실행 시 `sdd-state.md`를 읽어 전체 진행 상황을 표시한다.

[state-schema.md](reference/state-schema.md)에 정의된 스키마를 따른다.

출력 형식:

```
📊 Smart-SDD 진행 상태

Constitution: ✅ v1.0.0 (2024-01-15)

Feature         | Tier | specify | plan | tasks | impl | verify
----------------|------|---------|------|-------|------|-------
F001-auth       | T1   |   ✅    |  ✅  |  ✅   |  ✅  |   ✅
F002-product    | T1   |   ✅    |  🔄  |       |      |
F003-order      | T2   |         |      |       |      |
F004-payment    | T2   |         |      |       |      |

전체 진행률: 1/4 Features 완료 (25%)
현재 진행: F002-product → plan 단계
```

---

## Verify 커맨드

`/smart-sdd verify [FID]` 실행 시 3단계 검증을 수행한다.

### 1단계: 실행 검증
- 테스트 실행: `sdd-state.md`에서 프로젝트의 테스트 명령을 확인하고 실행
- 빌드 확인: 빌드 명령을 실행하여 에러가 없는지 확인
- 린트 확인: 린트 도구가 설정되어 있으면 실행

### 2단계: Cross-Feature 검증
- `/speckit.analyze` 실행하여 Feature 분석을 수행
- `pre-context.md`의 "For /speckit.analyze" 섹션의 교차 검증 포인트를 확인
- 해당 Feature가 변경한 공유 엔티티/API가 다른 Feature에 영향을 주는지 분석

### 3단계: Global Evolution 업데이트
- entity-registry.md: 실제 구현된 엔티티 스키마와 registry가 일치하는지 확인, 불일치 시 갱신
- api-registry.md: 실제 구현된 API 계약과 registry가 일치하는지 확인, 불일치 시 갱신
- sdd-state.md: 검증 결과(성공/실패, 테스트 결과, 검증 시각) 기록

---

## 커맨드별 컨텍스트 주입 상세

커맨드별로 주입하는 컨텍스트 소스와 내용은 [context-injection-rules.md](reference/context-injection-rules.md)에 정의되어 있다. 아래는 요약이다.

| 커맨드 | 주입 소스 | 주입 내용 |
|--------|----------|-----------|
| constitution | `constitution-seed.md` | 전체 내용 (소스 참조 원칙, 아키텍처 원칙, best practices, Global Evolution 운영 원칙) |
| specify | `pre-context.md` → "For /speckit.specify" + `business-logic-map.md` (해당 Feature 섹션) | 기능 요약, FR-### 초안, SC-### 초안, 엣지 케이스, 비즈니스 규칙 |
| plan | `pre-context.md` → "For /speckit.plan" + `entity-registry.md` (관련 엔티티) + `api-registry.md` (관련 API) | 의존성, 엔티티/API 초안, 기술 결정, 선행 Feature 결과 |
| tasks | `plan.md` (spec-kit 산출물) | plan 기반 자동 실행 |
| implement | `tasks.md` (spec-kit 산출물) | tasks 기반 자동 실행 |
| verify/analyze | `pre-context.md` → "For /speckit.analyze" | 교차 Feature 검증 포인트, 영향 범위 |

---

## 주의사항

- spec-kit 커맨드의 동작을 변경하거나 오버라이드하지 않는다. 컨텍스트를 주입하고 결과를 활용할 뿐이다.
- spec-kit이 관리하는 파일(`specs/{NNN-feature}/`, `.specify/`)을 직접 수정하지 않는다. spec-kit 커맨드를 통해서만 변경한다.
- Global Evolution Layer 파일(`entity-registry.md`, `api-registry.md`, `roadmap.md`)은 Update 단계에서만 수정한다.
- `sdd-state.md`가 없으면 최초 실행으로 간주하고 초기 상태 파일을 생성한다.
- 컨텍스트 주입 상세 규칙은 반드시 [context-injection-rules.md](reference/context-injection-rules.md)를 참조한다.
- 상태 파일 스키마는 [state-schema.md](reference/state-schema.md)를 참조한다.
