# TODO — Runtime Interaction & Quality Enhancement

> spec-kit-skills 파이프라인의 핵심 개선 영역 정리.
> 이전 TODO (Parts 0-11)를 재구성. MCP 조사 결과 반영.

---

## 핵심 문제

현재 파이프라인은 **코드를 한 번도 실행하지 않고** 스펙 추출 → 구현 → 검증을 수행한다:

```
reverse-spec:  코드만 읽음  → 앱을 써본 적 없이 스펙 추출
implement:     코드만 씀   → 한 번도 실행 안 하고 다음 feature로
verify:        빌드+테스트  → 서버 뜨는지만 확인하고 "통과"
```

**근본 해결**: 에이전트가 앱을 실제로 실행하고 인터랙션하는 능력 — 같은 메커니즘(Playwright MCP)을 세 시점에 적용.

---

## MCP 구성 (확정)

| 플랫폼 | MCP | 비고 |
|--------|-----|------|
| 웹앱 | Playwright MCP | 기본 |
| Electron | Playwright MCP (`--electron-app` 또는 `--cdp-endpoint`) | 동일 MCP |
| Tauri v2 | Tauri MCP (향후 확장) | 현재 미지원 |

상세: [MCP-GUIDE.md](MCP-GUIDE.md)

보조: Claude Preview (dev server 실행/관리, CSS 정밀 검사)

---

## A. Runtime Interaction (핵심)

에이전트가 앱을 실행하고 인터랙션하여 동작을 확인하는 능력. 세 시점에 적용.

### A-1. reverse-spec Runtime Exploration ✅ 구현 완료

> 원본 Part 6 (UI Fidelity) 대체. rebuild 시 원본 앱을 실제로 돌려보며 파악.

**구현 완료** (2026-03-08):
- `reverse-spec/commands/analyze.md` — Phase 1.5 전체 삽입 (Step 0~6: MCP 확인, 환경 진단, 체크리스트, 자동 셋업, 앱 실행, 탐색, 기록)
- `reverse-spec/templates/pre-context-template.md` — Runtime Exploration Results 섹션 추가 (Screens, Flows, Observations)
- Phase 2, Phase 4-2에 Phase 1.5 참조 가이드 추가

**미완료 (downstream 연결)**:
- `smart-sdd/reference/injection/specify.md` — UI 관찰 정보 주입
- `smart-sdd/reference/injection/plan.md` — 컴포넌트 설계 시 UI 참조

---

### A-2. implement 중 Feature 런타임 검증

> 원본 Part 8 강화. "빌드 확인"에서 "SC 실행 확인"으로 격상.

**문제**: implement가 코드만 생성하고 한 번도 실행하지 않음. verify에서 처음 실행 → 버그 폭발.

**해결**: 태스크 완료 후 실제로 앱을 띄워서 동작 확인.

```
Task 1 (로그인 폼) → 코드 작성
  → 앱 실행 → /login 이동 → 폼이 보이는지? → ✅
  → 이메일/비밀번호 입력 → 제출 → 리다이렉트 되는지? → ❌ 500 에러
  → 에러 분석 → API 라우트 누락 발견 → 수정 → 재확인 → ✅
```

**검증 수준** (태스크 완료 후):
- Level 1: 빌드 성공 + 서버 시작 (최소)
- Level 2: + 해당 태스크 관련 SC 실행 (표준, 권장)
- Level 3: + 이전 태스크 SC 회귀 확인 (강화)

**implement 완료 후** (Review 전):
- 전체 SC 실행 → 실패 시 자동 Fix (최대 3회)
- 동일 에러 반복 시 중단 → 에러 리포트와 함께 Review

**자동 Fix 루프**:
1. stdout/stderr 에러 메시지 분석
2. 에러 유형 분류 (import, 설정, 타입, API 불일치 등)
3. 관련 소스 수정 → 재실행
4. 같은 에러 반복 시 루프 중단, 사용자에게 리포트

**수정 대상**:
- `smart-sdd/reference/injection/implement.md` — 태스크별 런타임 검증 + Fix 루프
- `smart-sdd/commands/pipeline.md` — implement → verify 전이 조건 (빌드 게이트)
- `smart-sdd/reference/demo-standard.md` — 데모 사전 실행 가이드

**구현 우선순위**: 높음 (가장 큰 실사용 문제)

---

### A-3. verify SC 기반 UI 검증

> 원본 Parts 2+4 통합. verify Phase 3를 SC-### 인터랙션 검증으로 강화.

**문제**: verify Phase 3가 "서버 시작 + health check"에서 멈춤. "유저가 실제로 쓸 수 있는가"를 검증하지 않음.

**해결**: SC-###의 UI action 시나리오를 Playwright MCP로 자동 실행.

```
확장된 verify Phase 3 Step 2b:
1. Parse demo script → URL 추출
2. browser_navigate → 페이지 이동
3. 페이지 로드 확인
4. ★ browser_console_messages → JS 에러/경고 수집
5. ★ SC-### interaction verification:
   - Coverage header에서 SC + UI action 읽기
   - 각 SC: action 수행 → 결과 확인 → 스크린샷
   - pass/fail 기록
6. 최종 리포트
```

**결과 분류**:
- SC 인터랙션 실패: ⚠️ warning (false positive 가능, BLOCK 아님)
- JS 콘솔 에러 (TypeError/ReferenceError): ⚠️ warning + 강조
- 페이지 로드 실패: ⚠️ warning

**Playwright 없는 경우**: 수동 체크리스트 생성 (A-4)

**수정 대상**:
- `smart-sdd/commands/verify-phases.md` — Step 2b 확장
- `smart-sdd/reference/ui-testing-integration.md` — Phase A+ 상세
- `smart-sdd/reference/demo-standard.md` — Coverage 헤더 포맷 확장

**구현 우선순위**: 높음

---

### A-4. 수동 검증 체크리스트 (fallback)

> 원본 Part 3. Playwright MCP 없을 때의 fallback.

**동작**: SC-### 기반 수동 검증 체크리스트를 생성하여 유저가 직접 확인.

```
📋 UI Manual Verification Checklist for F001-auth

□ SC-001: /login 이동 → email/password 입력 → "Sign In" 클릭
  → Expected: /dashboard로 리다이렉트, 유저명 표시
□ SC-002: /login → 잘못된 이메일 → "Sign In" 클릭
  → Expected: "Invalid email format" 에러 메시지
```

**HARD STOP**: "All passed" / "Some failed" / "Skip UI verification"

**수정 대상**:
- `smart-sdd/commands/verify-phases.md` — Step 2b fallback 분기
- `smart-sdd/reference/demo-standard.md` — 체크리스트 생성 가이드

**구현 우선순위**: 높음 (도구 의존 없이 즉시 활용 가능)

---

### A-5. SC→UI Action 매핑 (spec/plan 단계)

> 원본 Part 1. A-2, A-3, A-4의 데이터 소스.

**목적**: UI Feature의 SC-###에서 검증 가능한 UI 액션을 추출. verify 시점에 자동/수동 검증의 소스로 활용.

```
Coverage header 포맷 (demo script 또는 plan.md):
  FR-001 (Login):
    SC-001: ✅ navigate /login → fill email/password → click "Sign In" → verify redirect /dashboard
    SC-002: ✅ navigate /login → fill invalid email → click "Sign In" → verify error visible
    SC-004: ⬜ (requires WebSocket — manual verify)
```

**수정 대상**:
- `smart-sdd/reference/injection/specify.md` — SC 작성 시 UI verifiability 기준
- `smart-sdd/reference/injection/plan.md` — UI Feature에 SC별 UI action hint 생성
- `smart-sdd/reference/demo-standard.md` — Coverage 헤더 SC-### 매핑에 UI action 컬럼

**구현 우선순위**: 중 (다음 파이프라인 실행부터 적용)

---

### A-6. MCP 감지 + 모드 결정

> 원본 Part 0 간소화. Playwright MCP 통일로 단순화됨.

**감지 로직** (verify Phase 3 실행 시):
1. Playwright MCP 도구 (`browser_navigate`, `browser_click` 등) 존재 확인
2. 있으면 → A-3 (자동 검증)
3. 없으면 → A-4 (수동 체크리스트)

**선호도 기록** (선택적, constitution 단계):
- `sdd-state.md`에 `UI Verify Mode: auto | playwright-mcp | manual`
- 기본값: `auto` (런타임 감지)

**수정 대상**:
- `smart-sdd/commands/verify-phases.md` — Phase 3 Step 2b MCP 분기
- `smart-sdd/reference/state-schema.md` — UI Verify Mode 필드

**구현 우선순위**: 높음 (A-3, A-4의 전제조건)

---

## B. Bug Prevention (단계별 버그 예방)

> 원본 Parts 9+10 통합. F006 post-mortem 기반.
> A가 "실행해서 잡자"라면, B는 "애초에 발생을 막자".

### B-1. plan 단계 강화

**추가할 검증/규칙**:

1. **Target Runtime Compatibility**: 타겟 런타임의 JS/CSS 제약 (예: WKWebView에서 `\p{...}` 미지원)
2. **State Management Anti-patterns**: 라이브러리별 함정 (예: Zustand selector referential stability)
3. **Async Race Condition Analysis**: 비동기 상태 충돌 가능성 분석
4. **Store Dependency Graph**: 스토어 간 의존 + 초기화 순서 명시
5. **Downgrade Compatibility**: 패키지 다운그레이드 시 타입/API 호환성

> 구체적 예시 (Zustand `?? []`, WKWebView CSS 등)는 `domains/app.md`에 프레임워크별 pitfall로 관리.

**수정 대상**:
- `smart-sdd/reference/injection/plan.md`
- `smart-sdd/domains/app.md`

---

### B-2. analyze 단계 강화

**추가할 검증**:

1. **Cross-Feature Data Flow**: Feature 간 데이터 의존성 + 초기화 순서 검증
2. **Nullable Field Tracking**: 공유 인터페이스의 optional 필드가 안전하게 사용되는지

**수정 대상**:
- `smart-sdd/reference/injection/analyze.md`

---

### B-3. implement 단계 강화

**추가할 규칙**:

1. **IPC Boundary Safety**: IPC/API 경계에서 optional chaining + null check 강제
2. **Platform CSS Constraints**: 타겟 플랫폼 CSS 제약 주입
3. **Cross-Feature Integration Checklist**: 다른 Feature 스토어 참조 시 필수 확인
4. **Module Import Graph Validation**: side-effect import가 import chain에 포함되는지
5. **Persistence Layer Write-Through**: write-back 라이브러리의 save/flush 호출 확인

> 구체적 규칙 (Tauri IPC, WKWebView CSS 등)은 `domains/app.md`에서 관리.

**수정 대상**:
- `smart-sdd/reference/injection/implement.md`
- `smart-sdd/domains/app.md`

---

### B-4. verify 단계 강화

**추가할 검증**:

1. **Empty State Smoke Test**: 모든 스토어 초기 상태에서 크래시 없이 렌더링되는지
2. **Smoke Launch Criteria**: 프로세스 시작 + 메인 화면 렌더링 + Error Boundary 미트리거 + JS 에러 없음

> A-2 (implement 런타임 검증)과 A-3 (verify SC 검증)이 이 항목들의 실행 메커니즘.

**수정 대상**:
- `smart-sdd/commands/verify-phases.md`

---

## C. Spec-Code Drift (독립)

> 원본 Part 5. implement 도중/이후 코드 변경 시 spec 아티팩트 역동기화.

**문제**: 파이프라인 도중 "OAuth도 추가해줘" → 코드는 변경, spec/plan/tasks에 미반영.

**잠재 접근**:
- A. verify에서 drift 감지 (코드 vs spec 비교)
- B. implement Review에서 새 기능 감지 + spec 추가 제안
- C. 별도 `sync` 커맨드

**상태**: 미결정 — 접근 방식 결정 필요

**구현 우선순위**: 낮음 (A, B 완료 후)

---

## D. Structural Gap Reference (Part 11)

> F006에서 발견된 5가지 구조적 공백. A, B의 근거 문서.

| # | 공백 | 해결 항목 |
|---|------|----------|
| 1 | Runtime Verification 부재 | A-2, A-3 |
| 2 | Integration Contract 부재 | B-2, B-3 |
| 3 | Runtime Constraints 무인식 | B-1 |
| 4 | Behavioral Contract 누락 | B-1, B-3 |
| 5 | Module Dependency Graph 부재 | B-3 |

---

## 구현 순서

| 순서 | 항목 | 파일 수정 | 난이도 | 의존 |
|------|------|-----------|--------|------|
| 1 | A-6: MCP 감지 | verify-phases.md, state-schema.md | 낮음 | — |
| 2 | A-4: 수동 체크리스트 | verify-phases.md, demo-standard.md | 낮음 | A-6 |
| 3 | A-3: SC 자동 검증 | verify-phases.md, ui-testing-integration.md | 중간 | A-6 |
| 4 | A-5: SC→UI Action 매핑 | injection/specify.md, injection/plan.md | 중간 | — |
| 5 | A-2: implement 런타임 검증 | injection/implement.md, pipeline.md | 중간 | — |
| ~~6~~ | ~~A-1: reverse-spec 탐색~~ | ~~analyze.md (reverse-spec), pre-context-template.md~~ | ~~중간~~ | ✅ 완료 |
| 7 | B-1~4: 버그 예방 규칙 | injection/*.md, domains/app.md | 낮~중 | — |
| 8 | C: Spec-Code Drift | 미정 | 미정 | A, B |

---

## 미결정 사항

### A 관련
- [ ] SC 인터랙션 실패를 BLOCK으로 승격할 조건이 있는가?
- [ ] 스크린샷 저장 위치 (프로젝트 내? 임시?)
- [ ] Coverage 헤더 UI action을 필수로 할지 optional로 할지
- [ ] 수동 체크리스트 실패 시 limited verification과 동일 처리할지
- [ ] 자동 Fix 루프 최대 횟수 (3회? 5회?)
- [ ] 빌드 게이트를 강제할지 override 가능하게 할지
- [ ] 데스크톱 앱에서 빌드 게이트의 "서버 시작" 조건 적용 방법

### B 관련
- [ ] plan 단계 검증 항목의 context window 소모량
- [ ] domains/app.md에 플랫폼별 제약 상세도
- [ ] State Management Anti-pattern을 라이브러리별로 할지 공통 원칙만 할지
- [ ] Cross-Feature Data Flow Analysis를 analyze에 넣을지 implement에 넣을지

### C 관련
- [ ] A/B/C 접근 방식 중 가장 실용적인 것
- [ ] 역전파 시 기존 FR 번호 체계 유지 방법

---

## Tauri 확장 (향후)

> Tauri MCP (hypothesi/mcp-server-tauri) 안정화 후 추가.

**추가할 내용**:
- A-6에 Tauri MCP 분기 (webview_interact, webview_screenshot 등)
- A-3에 Tauri 자동 검증 흐름 (IPC 검증 포함)
- A-4에 데스크톱 앱 특화 수동 체크리스트
- B-3에 Tauri IPC Safety Rules, Platform CSS Constraints
- MCP Bridge Plugin 자동 설치 (신규 프로젝트)
