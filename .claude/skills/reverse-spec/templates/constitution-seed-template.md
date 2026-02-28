# [PROJECT_NAME] Constitution (Seed)

**Source**: [원본 소스 경로]
**Generated**: [DATE]
**Strategy**: Stack: [same|new]

> 이 문서는 기존 소스 코드 분석에서 추출된 constitution 초안입니다.
> /speckit.constitution 실행 시 이 문서를 입력으로 사용하여 constitution을 확정하세요.
> 초안의 내용을 검토하고, 재개발 프로젝트에 맞게 수정/보완하세요.

---

## 기존 소스코드 참조 원칙

> 아래 두 전략 중 Phase 0에서 선택한 전략에 해당하는 섹션만 constitution에 포함하세요.

### [동일 스택 전략] Source as Implementation Reference

- **원본 소스 위치**: [경로]
- 각 Feature의 spec/plan 작성 시 `pre-context.md`의 Source Reference 섹션에 명시된 원본 파일을 **반드시** 읽고 참조한다
- 기존 구현 패턴(디자인 패턴, 에러 처리, 테스트 구조)을 **우선 재활용**한다
- 기존 구현과 다르게 설계할 경우 `plan.md`의 Complexity Tracking에 변경 사유를 **반드시** 명시한다
- 기존 코드의 테스트 케이스를 참조하여 동등한 테스트 커버리지를 보장한다

### [신규 스택 전략] Source as Logic Reference Only

- **원본 소스 위치**: [경로]
- 각 Feature의 spec/plan 작성 시 `pre-context.md`의 Source Reference 섹션에 명시된 원본 파일을 읽어 **비즈니스 로직과 요구사항**을 파악한다
- 기존 코드의 구현 패턴(프레임워크 사용법, 라이브러리 API)은 **참조하지 않는다**
- **추출 대상**: What(기능), Why(이유), 비즈니스 규칙, 엣지 케이스
- **무시 대상**: How(구현 방식), 기술 의존적 패턴
- 신규 스택의 관용적(idiomatic) 패턴을 우선한다

---

## 추출된 아키텍처 원칙

> 기존 코드에서 일관되게 관찰된 아키텍처 패턴을 원칙으로 정리합니다.

### I. [원칙 이름]
- **규칙**: [구체적 규칙 설명]
- **근거**: [기존 코드에서 이 패턴이 적용된 이유]
- **관찰 근거**: [어떤 코드에서 관찰되었는지]

### II. [원칙 이름]
- **규칙**: [구체적 규칙 설명]
- **근거**: [기존 코드에서 이 패턴이 적용된 이유]
- **관찰 근거**: [어떤 코드에서 관찰되었는지]

### III. [원칙 이름]
- **규칙**: [구체적 규칙 설명]
- **근거**: [기존 코드에서 이 패턴이 적용된 이유]
- **관찰 근거**: [어떤 코드에서 관찰되었는지]

---

## 추출된 기술 제약

| 영역 | 제약 | 출처 |
|------|------|------|
| 성능 | [예: API 응답 시간 200ms 이내] | [관찰된 위치/설정] |
| 보안 | [예: 모든 API에 인증 필수] | [미들웨어 구성] |
| 호환성 | [예: IE11 미지원, 최신 브라우저만] | [빌드 설정] |
| 확장성 | [예: 수평 확장 가능한 stateless 설계] | [아키텍처 패턴] |

---

## 추출된 코딩 컨벤션

| 영역 | 컨벤션 | 예시 |
|------|--------|------|
| 네이밍 | [예: camelCase for variables, PascalCase for classes] | [코드 예시 위치] |
| 프로젝트 구조 | [예: feature-based directory structure] | [디렉토리 구조] |
| 에러 처리 | [예: centralized error handler with error codes] | [코드 예시 위치] |
| 로깅 | [예: structured JSON logging with correlation ID] | [코드 예시 위치] |
| 테스트 | [예: AAA pattern, integration tests with test DB] | [테스트 구조] |

---

## 권장 개발 원칙 (Best Practices)

> 재개발 시 적용을 권장하는 원칙입니다. 프로젝트 특성에 맞게 수정/보완하세요.

### I. Test-First (NON-NEGOTIABLE)
- 모든 기능 구현 전에 테스트를 먼저 작성한다
- spec.md의 Acceptance Scenario(Given/When/Then)가 테스트 케이스의 원천이다
- tasks.md에서 테스트 태스크가 구현 태스크보다 반드시 선행한다
- 테스트 없는 코드는 완료로 인정하지 않는다
- 버그 수정 시: 먼저 버그를 재현하는 테스트를 작성한 후 수정한다
- **검증 기준**: `implement 완료 시 모든 테스트가 통과해야 한다`

### II. Think Before Coding
- 가정하지 말 것. 불명확하면 spec의 `[NEEDS CLARIFICATION]`으로 명시한다
- 여러 구현 방식이 가능하면 plan.md의 Complexity Tracking에 대안과 선택 이유를 기록한다
- 트레이드오프를 숨기지 말고 명시적으로 드러낸다
- **검증 기준**: `모든 설계 결정에 "왜?"에 대한 답이 있어야 한다`

### III. Simplicity First
- spec에 명시된 범위만 구현한다. 추측적 기능 추가 금지
- 단일 사용 코드에 대한 조기 추상화를 하지 않는다
- "나중에 필요할 것 같다"는 이유의 추상화/래퍼/유틸리티 금지
- 200줄로 된 것이 50줄로 가능하면 다시 작성한다
- **검증 기준**: `모든 코드가 spec의 요구사항으로 직접 추적 가능해야 한다`

### IV. Surgical Changes
- 기존 코드 수정 시 인접 코드/주석/포맷 "개선" 금지
- 작동하는 것을 리팩토링하지 않는다
- 자신의 변경으로 미사용된 import/변수/함수만 정리한다
- 기존 코드 스타일을 존중하고 일관성을 유지한다
- **검증 기준**: `변경된 모든 줄이 현재 task로 직접 추적 가능해야 한다`

### V. Goal-Driven Execution
- 모든 task는 검증 가능한 완료 기준을 포함한다
- "구현한다" 대신 "테스트가 통과한다"를 완료 기준으로 설정한다
- 다단계 작업은 각 단계의 검증 방법을 미리 정의한다
- **검증 기준**: `각 task 완료 시 자동화된 검증(테스트, 빌드, 린트)이 통과해야 한다`

---

## Global Evolution Layer 운영 원칙

> 아래 원칙을 constitution에 포함하여, spec-kit 진행 시 Global Evolution Layer를 참조하도록 강제합니다.

### Cross-Feature Consistency
- 모든 Feature의 /speckit.specify 실행 전에 `specs/reverse-spec/roadmap.md`와 해당 Feature의 `pre-context.md`를 반드시 읽는다
- 모든 Feature의 /speckit.plan 실행 시 `specs/reverse-spec/entity-registry.md`와 `specs/reverse-spec/api-registry.md`를 참조하여 엔티티/API 호환성을 보장한다
- 새로운 엔티티나 API를 정의할 경우, entity-registry.md와 api-registry.md를 업데이트한다
- Feature 간 의존성 변경 시 roadmap.md의 Dependency Graph를 업데이트한다

---

**Version**: 0.1.0-seed | **Generated**: [DATE]
