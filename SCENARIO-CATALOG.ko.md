# 시나리오 카탈로그 — spec-kit-skills

> 사용자 시나리오의 전체 카탈로그. 전체 파일 리뷰 시 검증 체크리스트로 사용됩니다 (CLAUDE.md § Review Protocol 참조).
> 각 시나리오는 커맨드 흐름, 전제 조건, 기대 결과를 명시합니다.

---

## 카탈로그 읽는 법

| 열 | 의미 |
|--------|---------|
| **ID** | `S{카테고리}{번호}` — 고유하고 안정적인 참조 식별자 |
| **흐름** | 사용자가 실행하는 커맨드 순서 |
| **전제 조건** | 시작 전 존재해야 하는 것 |
| **결과** | 완료 시 사용자가 얻는 것 |
| **상태** | ✅ 완전 지원 · 🟡 부분 지원 · ❌ 미지원 |

---

## 카테고리 A: 학습 및 탐색 (code-explore)

| ID | 시나리오 | 흐름 | 전제 조건 | 결과 | 상태 |
|----|----------|------|-----------|------|------|
| SA01 | 낯선 OSS 코드베이스 학습 | `code-explore [path]` → 트레이스 → 종합 | 소스 코드 존재 | 아키텍처 맵 + 트레이스 문서 | ✅ |
| SA02 | 특정 모듈만 학습 | `code-explore [path] --scope src/auth` | 소스 코드 존재 | 범위 한정 오리엔테이션 + 트레이스 | ✅ |
| SA03 | 단일 흐름 빠른 트레이스 | `code-explore [path]` → `trace "login flow"` | 소스 코드 존재 | 단일 트레이스 문서 | ✅ |
| SA04 | 신규 팀원 온보딩 | `code-explore .` → 트레이스 → 종합 | 팀 프로젝트 | 온보딩용 아키텍처 문서 | ✅ |
| SA05 | 두 프로젝트 비교 | `code-explore A` → `code-explore B` → 종합 (비교 모드) | 두 개의 소스 디렉토리 | 비교 테이블 + 아키텍처 차이점 | ✅ |
| SA06 | adopt 후 심층 탐색 | `adopt` → `code-explore .` (Context-Aware) | sdd-state.md 존재 | 기존 SDD 컨텍스트로 강화된 탐색 | ✅ |
| SA07 | Pipeline 중간 조사 | Pipeline 진행 중 → `code-explore . --scope src/module --no-branch` | 활성 Pipeline | Pipeline 중단 없이 특정 영역 이해 | ✅ |
| SA08 | Pipeline 완료 후 아키텍처 문서 | Pipeline 완료 → `code-explore .` (Context-Aware) | 모든 Feature 완료 | 스펙과 교차 참조된 아키텍처 문서 | ✅ |
| SA09 | 디버그 조사 | 버그 발견 → `code-explore . --scope src/buggy` → 트레이스 → 수정 | 실행 중인 프로젝트 | 관찰 사항이 포함된 버그 흐름 트레이스 | ✅ |
| SA10 | 보안 감사 탐색 | `code-explore .` → 인증/암호화 흐름 중심 트레이스 | 소스 코드 존재 | 보안 관찰 사항 카탈로그 | ✅ |

## 카테고리 B: 그린필드 프로젝트 (smart-sdd init + add + pipeline)

| ID | 시나리오 | 흐름 | 전제 조건 | 결과 | 상태 |
|----|----------|------|-----------|------|------|
| SB01 | 아이디어에서 새 프로젝트 시작 | `init "Build a chat app"` → add 자동 연결 → pipeline | 없음 | Feature가 구현된 전체 프로젝트 | ✅ |
| SB02 | OSS 학습 후 새 프로젝트 | `code-explore A` → `init B --from-explore` → add → pipeline | 소스 A 학습 완료 | A의 아키텍처를 참고한 새 프로젝트 B | ✅ |
| SB03 | 특정 프로필로 새 프로젝트 | `init --profile grpc-service` → add → pipeline | 없음 | 도메인 프로필이 사전 설정된 프로젝트 | ✅ |
| SB04 | 단일 Feature 추가 | `add "user authentication"` → pipeline | init 완료 | 하나의 Feature 명세 + 구현 완료 | ✅ |
| SB05 | 다수 Feature 일괄 추가 | `add` → F001-F005 정의 → `pipeline` | init 완료 | 순차적으로 다수 Feature 처리 | ✅ |
| SB06 | 탐색 결과에서 Feature 추가 | `code-explore` → 종합 → `add --from-explore` → pipeline | 탐색 완료 | 트레이스에서 도출된 Feature 후보 | ✅ |
| SB07 | T1 전용 MVP Pipeline | `pipeline --tier 1` | Feature 정의 완료 | Tier 1 Feature만 빌드 | ✅ |
| SB08 | 단일 Feature Pipeline | `pipeline F003` | F003 정의 완료 | F003만 빌드 | ✅ |
| SB09 | 중단된 Pipeline 재개 | `pipeline --continue` | Pipeline 중단됨 | 마지막 체크포인트에서 재개 | ✅ |
| SB10 | 실패한 프로젝트 재초기화 | specs/ 삭제 → `init` 재실행 | 이전 시도 실패 | 새로 시작 | ✅ |

## 카테고리 C: 기존 코드 채택 (smart-sdd adopt)

| ID | 시나리오 | 흐름 | 전제 조건 | 결과 | 상태 |
|----|----------|------|-----------|------|------|
| SC01 | 기존 코드베이스 채택 | `adopt --lang ko` | 소스 코드 존재, SDD 산출물 없음 | reverse-spec 자동 연결 → 모든 Feature 문서화 (채택) | ✅ |
| SC02 | 사전 탐색 후 채택 | `code-explore` → `adopt --from-explore` | 탐색 완료 | 트레이스로 강화된 채택 | ✅ |
| SC03 | 채택 → 새 Feature 추가 | `adopt` → `add "new feature"` → `pipeline` | 소스 코드 | 기존 코드 래핑 + 새 Feature 빌드 | ✅ |
| SC04 | 채택 → 기존 이슈 수정 | `adopt` → `pipeline` | 소스 코드 | 기존 Feature를 수정 포함하여 재구현 | ✅ |
| SC05 | 채택 → 탐색 → 추가 | `adopt` → `code-explore` (Context-Aware) → `add` → `pipeline` | 소스 코드 | 심층 이해 → 대상 지정 새 Feature | ✅ |
| SC06 | 모노레포 서비스 채택 | `adopt --scope services/api` | 모노레포 | 단일 서비스 문서화 | ✅ |
| SC07 | 마이그레이션 의도로 채택 | `adopt` → 마이그레이션 대상 식별 → `pipeline --migration` | 레거시 코드 | 현대화 계획 + 실행 | ✅ |

## 카테고리 D: 재빌드 (reverse-spec + pipeline)

| ID | 시나리오 | 흐름 | 전제 조건 | 결과 | 상태 |
|----|----------|------|-----------|------|------|
| SD01 | 동일 스택으로 전체 재빌드 | `reverse-spec . --adopt` → `pipeline` | 소스 코드 | 동일 기술 스택으로 완전 재작성 | ✅ |
| SD02 | 다른 스택으로 재빌드 | `reverse-spec .` → `init --stack new` → `pipeline` | 소스 코드 | 새 기술 스택으로 재작성 | ✅ |
| SD03 | 탐색 후 재빌드 | `code-explore` → `reverse-spec --from-explore` → `pipeline` | 소스 학습 완료 | 충분한 이해를 바탕으로 한 재빌드 | ✅ |
| SD04 | 부분 재빌드 (T1만) | `reverse-spec` → `pipeline --tier 1` | 소스 코드 | 핵심 Feature만 재빌드, 나머지 보류 | ✅ |
| SD05 | 프로젝트 간 재빌드 | `reverse-spec A` (디렉토리 B에서) → `pipeline` | 소스 A, 대상 디렉토리 B | A의 Feature를 B에서 재빌드 | ✅ |

## 카테고리 E: Pipeline 반복 및 수정

| ID | 시나리오 | 흐름 | 전제 조건 | 결과 | 상태 |
|----|----------|------|-----------|------|------|
| SE01 | 스펙 거부 → 수정 | specify HARD STOP에서 "reject" → 재명세 | Feature가 specify 단계 | 수정된 spec.md | ✅ |
| SE02 | specify로 되돌리기 → plan | plan HARD STOP에서 → "back to specify" | Feature가 plan 단계 | 새로운 이해를 반영하여 재명세 | ✅ |
| SE03 | plan으로 되돌리기 → implement | implement 중 → "back to plan" | Feature가 implement 단계 | 수정된 plan.md | ✅ |
| SE04 | verify 실패 → 수정 → 재검증 | verify에서 버그 발견 → 수정 → 재검증 | Feature가 verify 단계 | 버그 수정됨, verify 통과 | ✅ |
| SE05 | 기존 Feature 보완 | Feature 완료 → `pipeline F001 --step specify` | F001 완료 | F001을 개선을 위해 다시 열기 | ✅ |
| SE06 | 과대 Feature 분할 | add 중 → 너무 크다고 판단 → F001a + F001b로 분할 | Feature가 너무 큼 | 두 개의 작은 Feature | ✅ |
| SE07 | 관련 Feature 병합 | `pipeline merge F003 F004` | 겹치는 두 Feature | 하나로 통합된 Feature | ✅ |
| SE08 | implement 건너뛰기 (스펙 전용) | `pipeline F001 --step specify,plan` | Feature 정의 완료 | 구현 없이 스펙 + 계획만 | ✅ |
| SE09 | 기존 Feature 증강 | `add --to F001 "add OAuth"` → `pipeline F001` | F001 정의 또는 완료 | F001 pre-context 증강 → SC 보존하며 재명세 | ✅ |
| SE10 | 파일에서 증강 | `add --to F001 oauth-spec.md` | F001 존재 + 파일 | SE09와 동일하나 문서에서 입력 | ✅ |

## 카테고리 F: 다중 Feature 조율

| ID | 시나리오 | 흐름 | 전제 조건 | 결과 | 상태 |
|----|----------|------|-----------|------|------|
| SF01 | 의존 Feature (F002가 F001 필요) | `pipeline F001` → `pipeline F002` | F002가 F001에 의존 | F001의 기반 위에 F002 빌드 | ✅ |
| SF02 | 독립적인 병렬 Feature | `pipeline F001` → `pipeline F002` (의존성 없음) | 상호 의존성 없음 | 둘 다 독립적으로 빌드, main에 병합 | ✅ |
| SF03 | 이전 Feature로 복귀 | F001+F002 완료 → `pipeline F001 --step specify` | F001 개선 필요 | main에서 새 브랜치로 F001 재개 | ✅ |
| SF04 | Feature 간 엔티티 공유 | F001이 User 정의 → F002가 User 사용 | 공유 엔티티 | entity-registry.md가 일관성 보장 | ✅ |
| SF05 | Feature 의존성 체인 | F001 → F002 → F003 (선형) | 체인 의존성 | Pipeline이 순서를 준수 | ✅ |

## 카테고리 G: 커버리지 및 상태

| ID | 시나리오 | 흐름 | 전제 조건 | 결과 | 상태 |
|----|----------|------|-----------|------|------|
| SG01 | SBI 커버리지 확인 | `coverage` | adopt 완료 | SBI 커버리지 보고서 | ✅ |
| SG02 | 스펙-코드 동등성 확인 | `parity` | Feature 구현 완료 | 동등성 보고서 | ✅ |
| SG03 | Pipeline 상태 확인 | `status` | Pipeline 활성 | 상태 대시보드 | ✅ |
| SG04 | 탐색 상태 확인 | `code-explore status` | 탐색 활성 | 커버리지 + 트레이스 인덱스 | ✅ |

## 카테고리 H: 특수 모드 및 고급

| ID | 시나리오 | 흐름 | 전제 조건 | 결과 | 상태 |
|----|----------|------|-----------|------|------|
| SH01 | 다중 언어 프로젝트 | `init`, 여러 언어 감지됨 | 다중 언어 코드베이스 | polyglot + codegen concern 활성화 | ✅ |
| SH02 | 플러그인/확장 개발 | `init --profile sdk-library` → add → pipeline | 프레임워크 존재 | 확장 포인트가 있는 플러그인 | ✅ |
| SH03 | OSS 포크 후 확장 | OSS `adopt` → 커스텀 Feature `add` → `pipeline` | 포크된 저장소 | SDD 문서를 갖춘 확장된 OSS | ✅ |
| SH04 | 마이그레이션/현대화 | `adopt` → `pipeline --migration` | 레거시 코드 | 현대화된 코드베이스 | ✅ |
| SH05 | 다른 산출물 언어 | `init --lang ko` 또는 `adopt --lang ja` | 아무거나 | 모든 산출물이 지정된 언어로 생성 | ✅ |
| SH06 | 대규모 코드베이스 (1000+ 파일) | `reverse-spec .`, 병렬 하위 에이전트 사용 | 대형 저장소 | 분산 분석 | ✅ |
| SH07 | 모노레포 다중 서비스 | 서비스별 `adopt --scope services/api` | 모노레포 | 서비스별 SDD 문서 | ✅ |
| SH08 | CI/CD 통합 | CI 환경에서 `pipeline` (Playwright 없음) | CI 러너 | verify의 우아한 퇴보 | ✅ |

---

## 시나리오 수 요약

| 카테고리 | 수 | 설명 |
|----------|-----|------|
| A: 학습 및 탐색 | 10 | code-explore 시나리오 |
| B: 그린필드 | 10 | init + add + pipeline |
| C: 채택 | 7 | 기존 코드 문서화 |
| D: 재빌드 | 5 | 전체 재작성 |
| E: Pipeline 반복 | 10 | 수정, 롤백, 증강 |
| F: 다중 Feature | 5 | Feature 간 조율 |
| G: 커버리지 및 상태 | 4 | 모니터링 |
| H: 특수 모드 | 8 | 고급 사용 사례 |
| **합계** | **59** | |

### 상태별 커버리지

| 상태 | 수 | 비율 |
|------|-----|------|
| ✅ 완전 지원 | 59 | 100% |
| 🟡 부분 지원 | 0 | 0% |
| ❌ 미지원 | 0 | 0% |

---

## 리뷰 시 활용법

이 카탈로그는 전체 파일 리뷰 시 참조됩니다 (CLAUDE.md § Review Protocol, Check 13).
각 변경사항에 대해 해당 수정으로 인해 깨지는 시나리오가 없는지 확인합니다:

1. 수정된 파일에 관련된 시나리오 식별
2. 흐름을 추적하여 여전히 작동하는지 확인
3. 시나리오가 깨질 경우, 변경을 수정하거나 시나리오 상태를 업데이트

## 변경 이력

| 날짜 | 변경 사항 |
|------|-----------|
| 2026-03-22 | 최초 생성 — 8개 카테고리에 걸쳐 57개 시나리오 |
| 2026-03-22 | 5개 부분 지원 시나리오 해소 (SA05, SC06, SE07, SE08, SH07) → 57/57 완전 지원 |
