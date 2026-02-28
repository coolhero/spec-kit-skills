# SDD State Schema

이 문서는 `sdd-state.md` 파일의 포맷을 정의한다. smart-sdd가 이 파일을 자동으로 생성하고 관리한다.

**파일 위치**: `specs/reverse-spec/sdd-state.md` (또는 `--from`으로 지정된 BASE_PATH 하위)

---

## 파일 구조

```markdown
# SDD State

**Project**: [프로젝트 이름]
**Created**: [최초 생성 일시]
**Last Updated**: [최종 갱신 일시]
**Constitution Version**: [버전]

---

## Constitution

| 항목 | 값 |
|------|-----|
| Status | [pending / completed] |
| Version | [MAJOR.MINOR.PATCH] |
| Completed At | [ISO 8601 일시] |
| Updates | [증분 업데이트 횟수] |

---

## Feature Progress

| Feature ID | Feature Name | Tier | specify | plan | tasks | implement | verify | Status |
|------------|-------------|------|---------|------|-------|-----------|--------|--------|
| F001 | auth | T1 | ✅ 01-15 | ✅ 01-16 | ✅ 01-16 | ✅ 01-17 | ✅ 01-17 | completed |
| F002 | product | T1 | ✅ 01-18 | 🔄 | | | | in_progress |
| F003 | order | T2 | | | | | | pending |

### 상태 아이콘
- ✅ : 완료 (뒤에 완료 날짜 MM-DD)
- 🔄 : 진행 중
- ❌ : 실패
- ⏭️ : 스킵
- (빈칸) : 미시작

---

## Feature Detail Log

### F001-auth

| 단계 | 상태 | 시작 | 완료 | 비고 |
|------|------|------|------|------|
| specify | completed | 2024-01-15T10:00:00 | 2024-01-15T10:30:00 | FR 5개, SC 8개 |
| plan | completed | 2024-01-16T09:00:00 | 2024-01-16T11:00:00 | 엔티티 3개, API 5개 |
| tasks | completed | 2024-01-16T11:30:00 | 2024-01-16T12:00:00 | 태스크 12개 |
| implement | completed | 2024-01-17T09:00:00 | 2024-01-17T16:00:00 | |
| verify | completed | 2024-01-17T16:30:00 | 2024-01-17T17:00:00 | 테스트 24/24 통과 |

### F002-product

| 단계 | 상태 | 시작 | 완료 | 비고 |
|------|------|------|------|------|
| specify | completed | 2024-01-18T09:00:00 | 2024-01-18T10:00:00 | FR 8개, SC 12개 |
| plan | in_progress | 2024-01-18T10:30:00 | | |

---

## Feature Mapping

Feature ID와 spec-kit Feature Name(디렉토리명)의 매핑 테이블.

| Feature ID | spec-kit Name | spec-kit Path |
|------------|---------------|---------------|
| F001 | 001-auth | specs/001-auth/ |
| F002 | 002-product | specs/002-product/ |

---

## Global Evolution Log

Global Evolution Layer 파일의 업데이트 이력.

| 일시 | 트리거 Feature | 대상 파일 | 변경 내용 |
|------|---------------|-----------|-----------|
| 2024-01-16 | F001-auth (plan) | entity-registry.md | User, Session 엔티티 확정 반영 |
| 2024-01-16 | F001-auth (plan) | api-registry.md | POST /auth/register, POST /auth/login 확정 반영 |
| 2024-01-17 | F001-auth (implement) | roadmap.md | F001 status → completed |
| 2024-01-17 | F001-auth (implement) | F002 pre-context.md | User 엔티티 참조 스키마 갱신 |

---

## Constitution Update Log

Constitution 증분 업데이트 이력.

| 버전 | 일시 | 트리거 | 변경 내용 |
|------|------|--------|-----------|
| 1.0.0 | 2024-01-15 | 최초 확정 | constitution-seed 기반 확정 |
| 1.1.0 | 2024-01-17 | F001-auth implement | 인증 미들웨어 패턴 원칙 추가 |
```

---

## 초기 상태 생성

smart-sdd 최초 실행 시 (sdd-state.md가 없을 때) 아래 절차로 초기 상태를 생성한다:

1. `BASE_PATH/roadmap.md`를 읽어 Feature 목록과 Tier를 추출한다
2. 모든 Feature의 모든 단계를 `pending`(빈칸)으로 초기화한다
3. Feature Mapping 테이블은 비워두고, 각 Feature의 specify 완료 시 spec-kit Name을 매핑한다
4. Constitution은 `pending`으로 초기화한다

---

## 상태 업데이트 규칙

### 단계 시작 시
- 해당 셀을 🔄로 변경
- Feature Detail Log에 시작 시각 기록
- Feature Progress의 Status를 `in_progress`로 변경

### 단계 완료 시
- 해당 셀을 ✅ MM-DD로 변경
- Feature Detail Log에 완료 시각과 비고 기록
- `Last Updated` 갱신

### 단계 실패 시
- 해당 셀을 ❌로 변경
- Feature Detail Log에 실패 사유 기록
- Feature Progress의 Status는 `in_progress` 유지 (재시도 가능)

### Feature 완료 시 (모든 단계 ✅)
- Feature Progress의 Status를 `completed`로 변경
- Global Evolution Log에 업데이트 이력 추가

### 단계 스킵 시 (예: clarify 불필요)
- 해당 셀을 ⏭️로 변경
- Feature Detail Log에 스킵 사유 기록

---

## 검증 결과 기록

verify 단계 완료 시 Feature Detail Log의 비고에 아래 정보를 기록:

```
테스트: [통과 수]/[전체 수] 통과
빌드: [성공/실패]
린트: [성공/실패/미설정]
Cross-Feature: [검증 포인트 수]개 확인, [이슈 수]개 이슈
```
