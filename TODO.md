# TODO — UI Verification Enhancement

> Phase A+ 계획: verify Phase 3에서 UI 동작을 실질적으로 검증하는 메커니즘 추가.
> 현재 문제: verify 통과 (health check OK, tests pass) → 실제 UI에서 동작 안 됨.

---

## 문제 분석

현재 verify가 놓치는 것들:

| 검증 단계 | 커버 | 누락 |
|-----------|------|------|
| Phase 1 (Tests) | 코드 로직, 유닛 테스트 | UI 렌더링, 컴포넌트 인터랙션 |
| Phase 3 (Demo CI) | 서버 시작, health 200, stability window | 버튼 클릭, 폼 제출, 페이지 전환, 상태 변경 |
| Step 2b (Playwright hook) | 페이지 로드, 요소 존재 확인 | 실제 사용자 시나리오 (클릭→결과, 폼→응답) |

**근본 원인**: "서버 응답 + 테스트 통과" ≠ "유저가 실제로 쓸 수 있음"
- curl health check는 서버 프로세스만 확인
- unit test는 개별 함수/컴포넌트만 확인
- 현재 Playwright hook은 페이지 로드 + 요소 존재만 확인 (인터랙션 없음)

---

## 구현 방향: Playwright MCP 강화 + 수동 체크리스트 fallback

### 전략

```
Browser MCP 있음?
  ├─ YES → 자동 UI 검증 (SC-### 기반 인터랙션 테스트)
  │        + 콘솔 에러 스캔
  │        + 스크린샷 에비던스
  └─ NO  → 수동 검증 체크리스트 생성 (SC-### 기반)
           유저가 직접 확인 후 pass/fail 마킹
```

---

## Part 1: SC-### → UI Action 매핑 (spec/plan 단계)

### 개요

UI Feature의 SC-###에서 검증 가능한 UI 액션을 추출. verify 시점에 자동/수동 검증의 소스로 활용.

### 수정 대상

- `reference/injection/specify.md` — SC-### 작성 가이드에 UI 검증 가능성(verifiability) 기준 추가
- `reference/injection/plan.md` — UI Feature 식별 시 SC-### 별 UI action hint 생성
- `reference/demo-standard.md` — Coverage 헤더의 SC-### 매핑에 UI action 컬럼 추가

### 상세 설계

**SC-### UI Action Hint 포맷** (plan.md 또는 demo script Coverage 헤더에 기록):

```
# Coverage:
#   FR-001 (Login):
#     SC-001: ✅ navigate /login → fill email/password → click "Sign In" → verify redirect to /dashboard
#     SC-002: ✅ navigate /login → fill invalid email → click "Sign In" → verify error message visible
#   FR-002 (Dashboard):
#     SC-003: ✅ navigate /dashboard → verify user-list table has rows → click first row → verify detail panel
#     SC-004: ⬜ (requires WebSocket — manual verify)
```

각 SC에 대해:
- **navigate**: 이동할 URL
- **action**: 수행할 행동 (click, fill, hover, scroll)
- **verify**: 기대 결과 (element visible, text contains, redirect to, error message)

### 구현 우선순위: 중 (spec/plan 수정 → 다음 파이프라인 실행부터 적용)

---

## Part 2: Playwright MCP 자동 검증 강화 (verify Phase 3)

### 개요

현재 Step 2b를 "페이지 로드 확인"에서 "SC-### 기반 인터랙션 검증"으로 확장.

### 수정 대상

- `commands/verify-phases.md` — Step 2b 확장
- `reference/ui-testing-integration.md` — Phase A+ 상세 추가
- `reference/demo-standard.md` — `# Playwright` 헤더 포맷 확장

### 현재 Step 2b (Phase A)

```
1. Parse demo script stdout for URLs
2. Navigate to each URL
3. Verify page loads (no error state, page title present)
4. If # Playwright header: run listed assertions (element existence, clickability)
5. Take screenshot
6. Report
```

### 확장된 Step 2b (Phase A+)

```
1. Parse demo script stdout for URLs
2. Navigate to each URL
3. Verify page loads (no error state, page title present)
4. ★ Browser console error scan — JS 에러/경고 수집
5. ★ SC-### interaction verification:
   a. Read Coverage header from demo script → SC-### with UI actions
   b. For each SC with a UI action chain:
      - Execute action sequence (navigate → fill → click → ...)
      - Verify expected result (element visible, text match, redirect)
      - Take screenshot as evidence
      - Record pass/fail per SC
6. Take final screenshot
7. ★ Enhanced report:
   UI verification: ✅ [N] pages verified
   SC interaction: ✅ [passed]/[total] scenarios passed
   Console errors: [0 errors | ⚠️ N errors found]
   Screenshots: [N] captured for review
```

### 핵심 변경: blocking vs warning

| 항목 | 현재 | Phase A+ |
|------|------|----------|
| 페이지 로드 실패 | ⚠️ warning | ⚠️ warning (변경 없음) |
| SC 인터랙션 실패 | (검증 안 함) | ⚠️ warning + 유저에게 실패 SC 리스트 표시 |
| JS 콘솔 에러 | (검증 안 함) | ⚠️ warning (TypeError/ReferenceError는 강조) |

**원칙**: UI 자동 검증 실패는 BLOCK하지 않음 (false positive 가능성). 대신 명확한 리포트로 유저 판단 지원.

### Browser MCP 감지 방식

현재 Playwright MCP 이외에도 Claude in Chrome 등 다양한 browser automation MCP가 존재.
감지 로직:
1. Playwright MCP tools (`browser_navigate`, `browser_click`, etc.) 확인
2. 없으면 → 다른 browser MCP tools (예: Claude in Chrome `computer`, `find`, `read_page`) 확인
3. 어떤 browser MCP도 없으면 → Part 3 (수동 체크리스트) fallback

### 구현 우선순위: 높음 (verify 개선의 핵심)

---

## Part 3: 수동 검증 체크리스트 (fallback)

### 개요

Browser MCP가 없을 때, SC-### 기반 수동 검증 체크리스트를 생성하여 유저가 직접 확인.

### 수정 대상

- `commands/verify-phases.md` — Step 2b에 fallback 분기 추가
- `reference/demo-standard.md` — 체크리스트 생성 가이드 추가

### 동작 흐름

```
Demo script --ci 성공 후:

📋 UI Manual Verification Checklist for [FID]-[name]

Demo is running at: http://localhost:3000

── Verification Steps ──────────────────────────

□ SC-001: Navigate to /login
  → Fill email: test@example.com, password: password123
  → Click "Sign In"
  → Expected: Redirected to /dashboard, user name visible in header

□ SC-002: Navigate to /login
  → Fill email: invalid, password: (empty)
  → Click "Sign In"
  → Expected: Error message "Invalid email format" visible

□ SC-003: Navigate to /dashboard
  → Expected: User list table with at least 1 row
  → Click first row
  → Expected: Detail panel appears on the right

□ SC-004: (Cannot auto-verify — requires WebSocket)
  → Manual: Open browser DevTools → Network → WS tab
  → Expected: Active WebSocket connection to /ws

──────────────────────────────────────────────────
```

HARD STOP (AskUserQuestion):
- "All checks passed" — 전체 통과
- "Some checks failed — show details" — 실패 항목 기록
- "Skip UI verification" — limited verification (⚠️ UI-LIMITED 기록)

### 체크리스트 소스

1. **Demo script Coverage 헤더** — SC-### → UI action 매핑이 있는 경우 (Part 1)
2. **spec.md SC-### 섹션** — Coverage 헤더가 없는 경우, SC-### 텍스트에서 UI 관련 시나리오 추출
3. **quickstart.md** — "Try it" 지침이 있는 경우 참조

### 결과 기록

sdd-state.md Feature Detail Log → verify Notes에 추가:
- `UI: ✅ manual — [N]/[N] SC passed` (전체 통과)
- `UI: ⚠️ manual — [M]/[N] SC passed, failed: SC-002, SC-004` (부분 실패)
- `UI: ⚠️ UI-LIMITED — [reason]` (스킵)

### 구현 우선순위: 높음 (Browser MCP 없는 환경에서 즉시 활용 가능)

---

## Part 4: Browser Console Error Scan

### 개요

Browser MCP로 페이지 접근 후, JS 콘솔 에러를 스캔하여 런타임 이슈 조기 발견.

### 수정 대상

- `commands/verify-phases.md` — Step 2b에 콘솔 에러 스캔 추가
- `reference/ui-testing-integration.md` — 콘솔 에러 패턴 목록

### 스캔 대상 패턴

```
Critical (강조 표시):
- TypeError, ReferenceError, SyntaxError
- Uncaught (in promise)
- Unhandled rejection
- ChunkLoadError (번들링 문제)
- hydration mismatch (SSR 문제)

Warning (정보 표시):
- Failed to fetch / NetworkError
- 404 리소스 로드 실패
- Deprecation warning
```

### 리포트 포맷

```
🔍 Browser Console Scan:
  ❌ TypeError: Cannot read properties of undefined (reading 'map')
     at Dashboard.tsx:45
  ❌ Uncaught (in promise) Error: API endpoint /api/users returned 500
  ⚠️ Failed to load resource: /favicon.ico (404)

  2 errors, 1 warning found.
```

### 구현 우선순위: 중 (Part 2와 함께 구현)

---

## Part 0: Browser MCP 사용 여부 확인 시점

### 문제

Playwright MCP (또는 다른 Browser MCP)는 사용자가 별도로 설치해야 하는 도구.
smart-sdd가 이를 활용하려면, **적절한 시점에 사용 여부를 확인**하고 설정에 반영해야 함.

### 확인 시점 후보

| 시점 | 장점 | 단점 |
|------|------|------|
| **A. constitution 단계** | 프로젝트 초기에 결정, VI. Demo-Ready 채택 여부와 함께 묻기 좋음 | MCP 설치 상태가 나중에 변할 수 있음 |
| **B. 첫 verify 실행 시** (런타임 감지) | 실제 도구 가용성 기반 결정, 사전 설정 불필요 | verify 시작 후 알게 되면 이미 늦을 수 있음 |
| **C. pipeline 시작 시** (Pipeline Initialization) | 전체 흐름 시작 전 확인, 모든 Feature에 일괄 적용 | pipeline 재실행 시 매번 물어야 하나? |

### 권장: B (런타임 감지) + A (선호도 기록)

**2단계 접근**:

1. **constitution 단계 (선호도 질문)**:
   - VI. Demo-Ready Delivery 채택 시, 추가 질문:
   ```
   🧪 UI Verification Mode:
   UI가 있는 Feature의 검증 방식을 선택하세요.

   - "Browser MCP 자동 검증" — Playwright MCP 등 브라우저 자동화 도구 사용 (설치 필요)
   - "수동 체크리스트" — SC-### 기반 체크리스트로 직접 확인
   - "자동 감지" (Recommended) — verify 시점에 MCP 가용성을 자동 판단하여 결정
   ```
   - 선택 결과를 `sdd-state.md`에 기록: `UI Verify Mode: auto | browser-mcp | manual`
   - "자동 감지"가 default → 대부분의 유저는 이것을 선택

2. **verify Phase 3 실행 시 (런타임 감지)**:
   - `UI Verify Mode`가 `auto`인 경우:
     - 세션에서 사용 가능한 browser MCP tools를 탐색
     - 있으면 → Part 2 (자동 검증) 실행
     - 없으면 → Part 3 (수동 체크리스트) 실행
     - **첫 verify에서만** 결과를 알림:
     ```
     ℹ️ Browser MCP detected: Playwright MCP
        UI verification will use automated browser interaction.
     ```
     또는:
     ```
     ℹ️ No browser MCP detected.
        UI verification will use manual checklist mode.
        To enable automated UI verification, install Playwright MCP.
     ```
   - `UI Verify Mode`가 `browser-mcp`인 경우:
     - MCP 탐색 → 없으면 경고 + fallback to manual
   - `UI Verify Mode`가 `manual`인 경우:
     - MCP 탐색 없이 바로 수동 체크리스트

### 수정 대상

- `commands/pipeline.md` Phase 0-3 (constitution) — Demo-Ready 채택 시 UI Verify Mode 질문 추가
- `reference/state-schema.md` — `UI Verify Mode` 필드 추가
- `commands/verify-phases.md` — Phase 3 Step 2b에 모드 분기 로직 추가

### 구현 우선순위: 높음 (Part 2, 3의 전제 조건)

---

## 구현 순서

| 순서 | 항목 | 파일 수정 | 난이도 |
|------|------|-----------|--------|
| 1 | Part 0: MCP 확인 시점 + state 필드 | pipeline.md, state-schema.md, verify-phases.md | 낮음 |
| 2 | Part 3: 수동 체크리스트 | verify-phases.md, demo-standard.md | 낮음 |
| 3 | Part 2: Playwright 강화 | verify-phases.md, ui-testing-integration.md, demo-standard.md | 중간 |
| 4 | Part 4: 콘솔 에러 스캔 | verify-phases.md, ui-testing-integration.md | 낮음 |
| 5 | Part 1: SC → UI Action 매핑 | injection/specify.md, injection/plan.md, demo-standard.md | 중간 |

**이유**: Part 0이 전제 조건 (모드 결정). Part 3이 가장 빠르게 효과를 볼 수 있음 (도구 의존 없음). Part 2+4는 함께 구현. Part 1은 다음 파이프라인 사이클부터 적용.

---

## 미결정 사항

- [ ] Browser MCP 종류별 tool name 표준화 (Playwright vs Claude in Chrome vs 기타)
- [ ] SC interaction 실패를 BLOCK으로 승격할 조건이 있는가? (예: 3개 이상 실패 시)
- [ ] 스크린샷 저장 위치 (프로젝트 내 `demos/screenshots/`? 임시 파일?)
- [ ] Demo script Coverage 헤더에 UI action을 필수로 할지 optional로 할지
- [ ] 수동 체크리스트 실패 시 limited verification과 동일하게 처리할지 별도 상태로 할지
- [ ] UI Verify Mode 질문을 constitution 단계에서 할지, 별도 설정 커맨드로 할지
- [ ] Demo-Ready Delivery 미채택 프로젝트에서도 UI 검증을 제공할지 (Phase 1 테스트로 충분?)
