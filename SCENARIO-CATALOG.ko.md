# 시나리오 카탈로그 — spec-kit-skills

> "나는 지금 이 상황인데, 뭘 해야 하지?"에 대한 답입니다.
> 영문 버전: [SCENARIO-CATALOG.md](SCENARIO-CATALOG.md)

---

## A. 코드 이해하기

> 💡 "이 코드가 어떻게 돌아가는지 이해하고 싶어요"

| ID | 이런 상황일 때 | 이렇게 하세요 | 얻는 것 |
|----|---------------|-------------|---------|
| SA01 | 처음 보는 프로젝트의 전체 구조를 파악하고 싶을 때 | `code-explore [path]` 실행 → 궁금한 흐름을 하나씩 `trace` → 분석이 충분하면 `synthesis` | 전체 아키텍처 맵 + 주요 흐름 문서 |
| SA02 | 인증 모듈처럼 특정 영역만 집중해서 보고 싶을 때 | `code-explore [path] --scope src/auth` — 범위를 지정하면 해당 영역만 분석합니다 | 해당 영역의 집중 분석 문서 |
| SA03 | 두 프로젝트의 설계를 비교하고 싶을 때 | `code-explore A` → `code-explore B` → `synthesis` (비교 모드 자동 활성) | 기술 스택·구조·패턴 비교표 |
| SA04 | adopt이나 pipeline 후에 특정 영역을 더 깊이 분석하고 싶을 때 | `code-explore .` — SDD 문서가 있으면 Context-Aware 모드가 자동으로 켜져서 기존 문서와 연계됩니다 | 기존 SDD 문서와 교차 참조된 심층 분석 |
| SA05 | 보안·성능 관점에서 코드를 점검하고 싶을 때 | `code-explore .` → 인증·암호화·성능 관련 흐름 위주로 `trace` | 🔒📊 관찰 사항 카탈로그 |

## B. 새 프로젝트 시작하기

> 💡 "아이디어나 기획서가 있고, 처음부터 새로 만들고 싶어요"

| ID | 이런 상황일 때 | 이렇게 하세요 | 얻는 것 |
|----|---------------|-------------|---------|
| SB01 | 아이디어만 있고 코드는 아무것도 없을 때 | `init "채팅 앱 만들기"` — 한 줄이면 됩니다. add와 pipeline이 자동으로 이어집니다 | Feature별로 구현된 전체 프로젝트 |
| SB02 | 기존 프로젝트를 참고해서 더 나은 버전을 만들고 싶을 때 | `code-explore A` → `init B --from-explore` → add → pipeline | 참고 프로젝트의 장점을 살린 새 프로젝트 |
| SB03 | 기획서나 요구사항 문서가 이미 있을 때 | `init 기획서.md` 또는 `add 요구사항.md` — 파일을 넘기면 자동으로 Feature를 추출합니다. 텍스트와 파일을 섞어도 됩니다 | 문서에서 추출된 Feature 구현 |
| SB04 | Feature를 정의한 후 특정 Feature만, 또는 핵심만 먼저 구현하고 싶을 때 | `pipeline F003` (특정 Feature) 또는 `pipeline --tier 1` (핵심만 MVP) | 선택한 범위만 구현 |
| SB05 | pipeline이 중간에 끊겼거나, 처음부터 다시 시작하고 싶을 때 | `pipeline --continue` (이어서) 또는 specs/ 삭제 → `init` (처음부터) | 재개 또는 새 시작 |

## C. 기존 코드에 SDD 적용하기

> 💡 "이미 동작하는 코드가 있는데, SDD 문서를 씌우고 싶어요"

| ID | 이런 상황일 때 | 이렇게 하세요 | 얻는 것 |
|----|---------------|-------------|---------|
| SC01 | 기존 프로젝트에 SDD 문서 체계를 입히고 싶을 때 | `adopt --lang ko` — reverse-spec이 자동으로 먼저 실행됩니다. 코드는 변경되지 않습니다 | 모든 Feature가 문서화된 상태 |
| SC02 | 문서화한 후 새 기능을 추가하고 싶을 때 | `adopt` → `add "new feature"` → `pipeline` — 필요하면 중간에 `code-explore`로 깊이 분석해도 됩니다 | 기존 코드 보존 + 새 Feature 구현 |
| SC03 | 기존 코드의 버그나 설계 문제를 체계적으로 수정하고 싶을 때 | `adopt` → `pipeline` | 기존 Feature의 이슈가 체계적으로 수정됨 |
| SC04 | 모노레포에서 특정 서비스만 문서화하고 싶을 때 | `adopt --scope services/api` — 서비스별로 반복 가능 | 해당 서비스만 독립 문서화 |
| SC05 | 레거시 코드를 현대적 기술로 마이그레이션하고 싶을 때 | `adopt` → 마이그레이션 대상 식별 → `pipeline --migration` | 현대화 계획 + 단계별 실행 |

## D. 코드 전면 재작성

> 💡 "기존 코드를 분석해서, 처음부터 새로 작성하고 싶어요"

| ID | 이런 상황일 때 | 이렇게 하세요 | 얻는 것 |
|----|---------------|-------------|---------|
| SD01 | 같은 스택이든 다른 스택이든, 코드를 처음부터 다시 쓰고 싶을 때 | `reverse-spec .` → `init --from-reverse-spec` (리뷰 포함) 또는 `pipeline` (바로 진행) — 다른 스택으로 바꾸려면 `init --stack new`를 중간에 넣으세요 | 깨끗하게 재작성된 코드 |
| SD02 | 코드를 충분히 이해한 후 재작성하고 싶을 때 | `code-explore` → `reverse-spec --from-explore` → `pipeline` | 충분한 이해를 바탕으로 한 재작성 |
| SD03 | 핵심 기능만 먼저, 또는 별도 디렉토리에 재작성하고 싶을 때 | `reverse-spec` → `pipeline --tier 1` (핵심만) 또는 디렉토리 B에서 `reverse-spec A` (별도 프로젝트) | 선택적 재작성 |

## E. 수정하고 다시 하기

> 💡 "이미 진행한 결과를 수정하거나, 기존 Feature를 보강하고 싶어요"

| ID | 이런 상황일 때 | 이렇게 하세요 | 얻는 것 |
|----|---------------|-------------|---------|
| SE01 | 스펙·계획·구현 결과가 마음에 안 들어서 이전 단계로 돌아가고 싶을 때 | 각 단계의 HARD STOP에서 "Reject" 또는 "back to ..." 선택 — 어느 단계에서든 이전 단계로 되돌릴 수 있습니다 | 피드백이 반영된 수정 결과 |
| SE02 | verify에서 버그가 발견되어 수정 후 다시 검증하고 싶을 때 | 버그 수정 → `pipeline F001 --start verify`로 재검증 | 버그 수정 + verify 통과 |
| SE03 | 이미 완료된 Feature를 다시 열어서 개선하고 싶을 때 | `pipeline F001 --step specify` — 해당 단계부터 다시 진행합니다 | F001이 다시 열려서 재작업 |
| SE04 | 이미 정의한 Feature에 새 요구사항을 추가하고 싶을 때 | `add --to F001 "add OAuth"` 또는 `add --to F001 요구사항.md` — 텍스트와 파일 모두 가능. 이후 `pipeline F001`로 재명세 | 기존 SC는 유지 + 새 SC 추가 |
| SE05 | Feature가 너무 커서 나누거나, 겹치는 Feature를 합치고 싶을 때 | 나누기: add 중 분할 결정. 합치기: `pipeline merge F003 F004` | 적절한 크기의 Feature |
| SE06 | 구현 없이 스펙과 계획만 만들고 싶을 때 (문서 목적) | `pipeline F001 --step specify,plan` — 원하는 단계만 골라서 실행 가능 | spec.md + plan.md (구현 없음) |

## F. 여러 Feature 관리하기

> 💡 "Feature 간의 순서와 의존성을 관리하고 싶어요"

| ID | 이런 상황일 때 | 이렇게 하세요 | 얻는 것 |
|----|---------------|-------------|---------|
| SF01 | Feature 간 순서가 중요할 때 (F002가 F001을 필요로 함) | `pipeline F001` 완료 → `pipeline F002` — 의존성이 없으면 순서 무관하게 실행해도 됩니다 | 올바른 순서로 구현됨 |
| SF02 | 완료한 Feature를 다시 개선하고 싶을 때 | `pipeline F001 --step specify` — main에서 새 브랜치가 만들어지고 F001이 재작업됩니다 | 이전 Feature 다시 열기 |

## G. 상태 확인하기

> 💡 "지금 어디까지 진행됐는지 확인하고 싶어요"

| ID | 이런 상황일 때 | 이렇게 하세요 | 얻는 것 |
|----|---------------|-------------|---------|
| SG01 | 전체 진행 상태를 한눈에 보고 싶을 때 | `status` (pipeline) 또는 `code-explore status` (탐색) | Feature별 진행 대시보드 |
| SG02 | 스펙 대로 구현되었는지, 커버리지를 확인하고 싶을 때 | `parity` (스펙-코드 일치) 또는 `coverage` (SBI 커버리지) | 일치도·커버리지 보고서 |

## H. 고급 & 커스터마이징

> 💡 "특수한 프로젝트 유형이거나, 커스텀 도메인 규칙이 필요하거나, 조직 전체 컨벤션을 적용하고 싶어요"

| ID | 이런 상황일 때 | 이렇게 하세요 | 얻는 것 |
|----|---------------|-------------|---------|
| SH01 | VS Code 확장이나 플러그인을 만들고 싶을 때 | `init --profile sdk-library` → add → pipeline | 확장 포인트가 설계된 플러그인 |
| SH02 | 레거시 코드를 현대적으로 탈바꿈하고 싶을 때 | `adopt` → `pipeline --migration` | 현대화된 코드베이스 |
| SH03 | 모든 문서를 한국어나 일본어로 생성하고 싶을 때 | `init --lang ko` 또는 `adopt --lang ja` | 모든 산출물이 지정 언어 |
| SH04 | 모노레포에서 서비스별로 각각 SDD를 적용하고 싶을 때 | 서비스별 `adopt --scope services/api` 반복 | 서비스별 독립 SDD 문서 |
| SH05 | 어떤 도메인 모듈이 있는지 보고 싶을 때 | `domain-extend browse` 또는 `domain-extend browse concerns` | 파일 경로 포함 전체 모듈 목록 |
| SH06 | 내 프로젝트 패턴이 기존 모듈에 없을 때 | `domain-extend detect` → `domain-extend extend concern "video-encoding"` | 새 concern 모듈 (3파일 세트) |
| SH07 | 팀 ADR이나 스타일 가이드를 도메인 규칙으로 바꾸고 싶을 때 | `domain-extend import ./docs/adr/` | ADR이 S1/S7 규칙으로 변환된 모듈 |
| SH08 | 조직 전체 코딩 컨벤션을 적용하고 싶을 때 | `domain-extend customize org` | 모든 프로젝트에 적용되는 org-convention.md |
| SH09 | code-explore가 미커버 패턴을 발견했을 때 | `domain-extend detect --from-explore ./specs/explore/` → `extend` | 탐색 갭에서 생성된 새 모듈 |
| SH10 | 커스텀 모듈을 파이프라인에서 사용하기 전에 검증하고 싶을 때 | `domain-extend validate` | 검증 리포트: 스키마 준수, 택소노미 동기화, 크로스-컨선 규칙 |

---

## 요약

| 카테고리 | 수 |
|----------|-----|
| A: 코드 이해하기 | 5 |
| B: 새 프로젝트 시작하기 | 5 |
| C: 기존 코드에 SDD 적용 | 5 |
| D: 코드 전면 재작성 | 3 |
| E: 수정하고 다시 하기 | 6 |
| F: 여러 Feature 관리 | 2 |
| G: 상태 확인 | 2 |
| H: 고급 & 커스터마이징 | 10 |
| **합계** | **38** |

---

## 변경 이력

| 날짜 | 변경 사항 |
|------|-----------|
| 2026-03-22 | 최초 생성 |
| 2026-03-22 | 사용자 관점 설명으로 재작성 + 유사 시나리오 통합 (59 → 32) |
