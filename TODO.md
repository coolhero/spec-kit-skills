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
Playwright MCP 있음?
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

### Playwright MCP 감지 방식

감지 로직:
1. Playwright MCP tools (`browser_navigate`, `browser_click`, etc.) 확인
2. 없으면 → Part 3 (수동 체크리스트) fallback

### 구현 우선순위: 높음 (verify 개선의 핵심)

---

## Part 3: 수동 검증 체크리스트 (fallback)

### 개요

Playwright MCP가 없을 때, SC-### 기반 수동 검증 체크리스트를 생성하여 유저가 직접 확인.

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

### 구현 우선순위: 높음 (Playwright MCP 없는 환경에서 즉시 활용 가능)

---

## Part 4: Browser Console Error Scan

### 개요

Playwright MCP로 페이지 접근 후, JS 콘솔 에러를 스캔하여 런타임 이슈 조기 발견.

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

## Part 0: Playwright MCP 사용 여부 확인 시점

### 문제

Playwright MCP는 사용자가 별도로 설치해야 하는 도구.
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

   - "Playwright MCP 자동 검증" — Playwright MCP 브라우저 자동화 사용 (설치 필요)
   - "수동 체크리스트" — SC-### 기반 체크리스트로 직접 확인
   - "자동 감지" (Recommended) — verify 시점에 Playwright MCP 가용성을 자동 판단하여 결정
   ```
   - 선택 결과를 `sdd-state.md`에 기록: `UI Verify Mode: auto | playwright-mcp | manual`
   - "자동 감지"가 default → 대부분의 유저는 이것을 선택

2. **verify Phase 3 실행 시 (런타임 감지)**:
   - `UI Verify Mode`가 `auto`인 경우:
     - 세션에서 Playwright MCP tools (`browser_navigate`, `browser_click`, etc.) 탐색
     - 있으면 → Part 2 (자동 검증) 실행
     - 없으면 → Part 3 (수동 체크리스트) 실행
     - **첫 verify에서만** 결과를 알림:
     ```
     ℹ️ Playwright MCP detected.
        UI verification will use automated browser interaction.
     ```
     또는:
     ```
     ℹ️ Playwright MCP not detected.
        UI verification will use manual checklist mode.
        To enable automated UI verification, install Playwright MCP.
     ```
   - `UI Verify Mode`가 `playwright-mcp`인 경우:
     - Playwright MCP 탐색 → 없으면 경고 + fallback to manual
   - `UI Verify Mode`가 `manual`인 경우:
     - 탐색 없이 바로 수동 체크리스트

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

- [ ] SC interaction 실패를 BLOCK으로 승격할 조건이 있는가? (예: 3개 이상 실패 시)
- [ ] 스크린샷 저장 위치 (프로젝트 내 `demos/screenshots/`? 임시 파일?)
- [ ] Demo script Coverage 헤더에 UI action을 필수로 할지 optional로 할지
- [ ] 수동 체크리스트 실패 시 limited verification과 동일하게 처리할지 별도 상태로 할지
- [ ] UI Verify Mode 질문을 constitution 단계에서 할지, 별도 설정 커맨드로 할지
- [ ] Demo-Ready Delivery 미채택 프로젝트에서도 UI 검증을 제공할지 (Phase 1 테스트로 충분?)

---

## Part 5: Spec Artifact Back-Propagation (코드 변경 → spec 역반영)

### 문제

파이프라인의 spec 아티팩트 흐름은 **단방향**:

```
spec.md → plan.md → tasks.md → 코드 구현 → verify
```

사용자가 파이프라인 도중 별도 요청으로 코드를 수정하면 (예: implement 단계에서 "OAuth도 추가해줘"),
코드는 변경되지만 상위 spec 아티팩트에는 반영되지 않음:

- `spec.md` — OAuth 관련 FR/SC 없음
- `plan.md` — OAuth 관련 설계 없음
- `tasks.md` — 해당 태스크 없음

**결과**: verify에서 cross-artifact consistency check가 불일치를 감지할 수 있지만,
자동으로 spec을 업데이트하지는 않음. spec과 코드가 점점 괴리됨.

### 시나리오별 분석

| 시나리오 | 현재 처리 | 문제 |
|----------|-----------|------|
| implement 중 사용자가 "이것도 추가해줘" | 코드만 수정됨 | spec/plan/tasks에 기록 안 됨 |
| implement 중 사용자가 기존 동작 변경 요청 | 코드만 수정됨 | spec의 FR/SC와 불일치 |
| verify 후 사용자가 UI 수정 요청 | 코드만 수정됨 | verify 결과와 실제 코드 불일치 |
| 파이프라인 외부에서 별도 세션으로 수정 | 코드만 수정됨 | smart-sdd가 변경 사실 자체를 모름 |

### 잠재적 접근 방식

**A. Post-Implement Drift Detection (verify 확장)**

verify Phase 2에서 코드 vs spec 불일치를 적극적으로 감지:
1. 구현된 코드를 스캔하여 spec.md의 FR/SC 목록과 비교
2. spec에 없는 기능이 코드에 있으면 → drift 경고
3. 경고 시 선택지:
   - "spec에 추가" → spec.md에 FR/SC 자동 생성 + plan.md/tasks.md 역갱신
   - "의도적 추가" → 다음 Feature로 분리 (add)
   - "무시" → 기록만 남김

**B. Implement Review 강화**

implement 단계의 Review에서 "Request modifications" 시:
1. 수정 요청 내용을 파싱
2. 기존 FR/SC에 매핑되지 않는 새 기능이면 경고
3. spec.md에 FR 추가할지 물어봄
4. 추가하면 plan.md, tasks.md도 연쇄 업데이트

**C. Spec Sync Command (새 커맨드)**

`/smart-sdd sync F001` — 코드 기준으로 spec 아티팩트를 역동기화:
1. 구현된 코드를 분석하여 기능 목록 추출
2. spec.md의 FR/SC와 비교
3. 차이점 리포트 생성
4. 사용자 승인 후 spec/plan/tasks 업데이트

### 수정 대상 (예상)

- `commands/verify-phases.md` — Phase 2에 drift detection 추가 (접근 A)
- `reference/injection/implement.md` — Review 시 새 기능 감지 로직 (접근 B)
- `commands/sync.md` — 새 커맨드 (접근 C)
- `SKILL.md` — sync 커맨드 라우팅 추가 (접근 C)
- `reference/state-schema.md` — drift 기록 필드 추가

### 구현 우선순위: 미정 (접근 방식 결정 필요)

### 미결정 사항

- [ ] A/B/C 중 어떤 접근 방식이 가장 실용적인가?
- [ ] 복수 접근 방식 조합 가능? (예: B + A)
- [ ] 역전파 시 spec의 기존 FR 번호 체계를 어떻게 유지할지
- [ ] plan.md, tasks.md의 역갱신 범위 — 전체 재생성 vs 부분 추가
- [ ] 파이프라인 외부 세션 수정은 감지 자체가 가능한가? (git diff 기반?)

---

## Part 6: Rebuild UI Fidelity (원본 소스 UI와 리빌드 UI의 시각적 괴리)

### 문제

Brownfield rebuild 시, 기능적으로는 동일하게 구현되더라도 **UI의 모양새(레이아웃, 스타일, 컴포넌트 배치)가 원본과 크게 달라지는** 경우가 빈번함.

현재 파이프라인에서 UI 외형을 보존하는 메커니즘:
- `pre-context.md` → Source Reference에 원본 파일 목록은 있지만 **시각적 정보 없음**
- `spec.md` → FR/SC는 기능 요구사항이지 **UI 레이아웃 명세가 아님**
- `plan.md` → 데이터 모델/API 설계이지 **컴포넌트 배치/스타일 설계가 아님**
- `business-logic-map.md` → 비즈니스 로직이지 **UI 구조가 아님**

**근본 원인**: SDD 파이프라인은 "무엇을 하는가(What)"에 집중하고, "어떻게 보이는가(How it looks)"를 체계적으로 전달하지 않음.

### 시나리오별 영향

| 상황 | stack=same | stack=new |
|------|-----------|----------|
| 같은 컴포넌트 라이브러리 사용 | 배치/스타일만 달라짐 | 완전히 다른 UI (프레임워크도 다름) |
| 원본에 커스텀 CSS/테마 있음 | 테마 정보 유실 | 테마 정보 유실 + 프레임워크 전환 |
| 원본에 반응형 레이아웃 있음 | 반응형 동작 누락 가능 | 반응형 패턴 자체가 다름 |

### 잠재적 접근 방식

**A. UI Reference Screenshot 캡처 (reverse-spec 확장)**

`/reverse-spec` Phase 2에서 원본 소스의 주요 페이지 스크린샷을 캡처:
1. 원본 앱을 로컬에서 실행 (사용자 지원 필요)
2. Playwright MCP로 주요 라우트 순회 → 스크린샷 캡처
3. 각 Feature의 `pre-context.md`에 스크린샷 참조 추가
4. implement 시 에이전트가 스크린샷을 참조하여 유사한 레이아웃 구현

장점: 직관적, 시각 정보 직접 전달
단점: 원본 앱 실행 필요, Playwright MCP 의존, 스크린샷 저장/관리 비용

**B. UI Structure Extraction (reverse-spec 확장)**

`/reverse-spec` Phase 2 Deep Analysis에서 UI 구조 정보를 추가 추출:
1. 컴포넌트 트리 구조 (페이지 → 섹션 → 컴포넌트 계층)
2. 레이아웃 패턴 (sidebar + main, header + content + footer 등)
3. 사용 중인 UI 라이브러리/테마 (Tailwind 클래스 패턴, MUI 테마 설정 등)
4. 반응형 브레이크포인트
5. 색상 팔레트 / 타이포그래피 시스템

추출 결과를 `pre-context.md`의 새 섹션 "UI Structure" 또는 별도 `ui-reference.md`에 기록.
`plan.md` 작성 시 이 정보를 참조하여 컴포넌트 설계에 반영.

장점: 코드 분석만으로 가능 (원본 실행 불필요), 정형화된 정보
단점: 정적 분석 한계 (실제 렌더링 결과와 다를 수 있음), 추출 복잡도

**C. Visual Parity Check (verify/parity 확장)**

구현 후 원본과의 시각적 비교:
1. 원본 앱과 리빌드 앱을 동시에 실행
2. Playwright MCP로 동일 페이지를 순회하며 스크린샷 비교
3. 차이점 리포트 생성 → 사용자에게 수용/수정 선택지 제공

장점: 결과 기반 검증으로 정확
단점: 양쪽 앱 동시 실행 필요, Playwright MCP 의존, 리소스 비용 높음

**D. UI Spec Section (specify 확장)**

`spec.md`에 기능 요구사항과 별도로 **UI 요구사항 섹션** 추가:
1. reverse-spec에서 추출한 UI 구조를 `pre-context.md` "For /speckit.specify"에 포함
2. specify 시 FR/SC와 함께 UI 레이아웃 요구사항 생성 (예: "sidebar에 네비게이션, main 영역에 컨텐츠")
3. plan.md에서 이를 참조하여 컴포넌트 설계

장점: 기존 파이프라인 흐름에 자연스럽게 통합
단점: 텍스트 기반 UI 명세의 한계 (시각 정보 전달력 부족)

### 권장: B + D 조합 (+ 선택적 A)

1. **B** (UI Structure Extraction): reverse-spec에서 UI 구조 정보 추출 → pre-context에 기록
2. **D** (UI Spec Section): specify에서 UI 레이아웃 요구사항 생성 → plan에 반영
3. **A** (선택적): Playwright MCP 있으면 스크린샷도 캡처하여 참조 자료로 활용

### 수정 대상 (예상)

- `commands/analyze.md` (reverse-spec) — Phase 2에 UI 구조 추출 추가
- `templates/pre-context-template.md` — "UI Structure" 섹션 추가
- `reference/injection/specify.md` — UI 구조 정보 주입 규칙 추가
- `reference/injection/plan.md` — 컴포넌트 설계 시 UI 참조 규칙 추가
- `domains/app.md` — UI 추출 패턴 정의 (프레임워크별)

### 구현 우선순위: 미정 (접근 방식 결정 필요)

### 미결정 사항

- [ ] stack=new인 경우 UI 보존이 의미 있는가? (프레임워크 자체가 다른데)
- [ ] UI 구조 추출의 정확도를 어떻게 보장할지 (CSS-in-JS vs CSS Modules vs Tailwind 등)
- [ ] 스크린샷 캡처 시 인증/데이터 문제 (로그인 필요한 페이지는?)
- [ ] "모양새 보존" vs "현대적 리디자인" — 사용자 의도를 어느 시점에 물어볼지
- [ ] UI Component Features (기존 추출 항목)와의 중복/통합 범위
- [ ] 반응형 디자인 — 어느 뷰포트를 기준으로 삼을지

---

## Part 7: Playwright MCP 플랫폼 한계 — 데스크톱 앱 UI 검증

### 문제

Playwright MCP는 **브라우저 자동화** 도구로 설계되어, 데스크톱 앱 프레임워크에서는 제한적이거나 동작하지 않음.

| 플랫폼 | Playwright 자체 | Playwright MCP | 비고 |
|--------|----------------|----------------|------|
| **웹앱** (브라우저) | ✅ 완전 지원 | ✅ 바로 동작 | 설계 의도에 부합 |
| **Electron** | ⚠️ 실험적 (`_electron.launch()`, CDP) | ❌ MCP가 Electron launch API 미지원 | Chromium 기반이라 이론적으로 가능하나 MCP 서버가 감싸지 않음 |
| **Tauri** | ❌ 시스템 WebView 미지원 | ❌ 불가 | WKWebView/WebView2/WebKitGTK — Playwright 연결 API 없음 |
| **Flutter Desktop** | ❌ 자체 렌더링 엔진 | ❌ 불가 | WebView 아님 |
| **React Native (macOS/Windows)** | ❌ 네이티브 컴포넌트 | ❌ 불가 | WebView 아님 |

### 현재 영향

"demo가 아무 동작도 안 하고 멈춰있는데 verify 통과" 문제:
- **웹앱**: Playwright MCP로 SC-### 인터랙션 검증 시 개선됨 (클릭 → timeout → ⚠️ warning)
- **데스크톱 앱**: Playwright MCP 자체가 동작하지 않으므로, **Part 3 (수동 체크리스트)만이 유일한 UI 검증 수단**

### 잠재적 접근 방식

**A. 플랫폼별 자동 모드 결정**

constitution 또는 런타임에서 프로젝트 스택을 감지하여 자동 분기:
```
프로젝트 스택 감지:
  ├─ 웹앱 (React, Vue, Next.js, ...) → Playwright MCP 가용 시 자동 검증
  ├─ Electron → 수동 체크리스트 (+ Electron 특화 검증 힌트)
  ├─ Tauri → 수동 체크리스트 (+ Tauri 특화 검증 힌트)
  └─ 기타 데스크톱 → 수동 체크리스트
```

- 스택 정보는 이미 `sdd-state.md`에 기록됨 (constitution에서 결정)
- Part 0의 UI Verify Mode 질문에 "데스크톱 앱은 수동 체크리스트만 지원됩니다" 안내 추가

**B. 데스크톱 앱 특화 수동 체크리스트**

Part 3의 수동 체크리스트를 데스크톱 앱에 맞게 확장:
- Electron: "앱 창이 정상 렌더링되는가", "메뉴바 동작", "IPC 통신 확인"
- Tauri: "시스템 WebView 렌더링", "Rust ↔ JS bridge 동작", "네이티브 메뉴"
- 공통: "앱 실행 → 메인 화면 표시 → 핵심 인터랙션" 기본 시나리오

**C. 향후 Electron CDP 연결 (장기)**

Playwright MCP가 Electron의 CDP(Chrome DevTools Protocol) 연결을 지원하게 되면:
- Electron 앱의 Chromium 인스턴스에 연결하여 웹앱과 동일한 자동 검증 가능
- 현재는 Playwright MCP 측 지원이 필요하므로 우리가 해결할 수 있는 범위 밖

### 수정 대상 (예상)

- `commands/pipeline.md` Phase 0-3 (constitution) — 데스크톱 앱 스택 시 UI Verify Mode 안내 추가
- `commands/verify-phases.md` — 스택 기반 자동 모드 분기 (접근 A)
- `reference/demo-standard.md` — 데스크톱 앱 체크리스트 템플릿 (접근 B)
- `domains/app.md` — 데스크톱 앱 프레임워크별 검증 힌트

### 구현 우선순위: 중 (Part 0, 3 구현 후 확장)

### 미결정 사항

- [ ] Electron CDP 연결이 Playwright MCP에서 지원될 가능성/시기
- [ ] Tauri v2의 WebView 접근 방식이 달라질 가능성
- [ ] 데스크톱 앱 체크리스트에 스크린샷 첨부를 요구할지 (사용자가 수동 캡처)
- [ ] Flutter/RN Desktop 등 비-WebView 프레임워크까지 고려할 범위

---

## Part 8: Implement-time Incremental Verification (구현 중 점진적 검증)

### 문제

현재 파이프라인에서 **코드가 처음 실행되는 시점은 verify Phase 3** (데모 --ci 실행).
implement 단계에서는 코드를 한 번도 실행하지 않고, verify에서 실패하면 자동 수정 루프도 없음.

```
현재 흐름:
implement                              verify
┌─────────────────────────┐      ┌─────────────────────────┐
│ Task 1 → 코드 작성       │      │ Phase 1: 테스트/빌드     │
│ Task 2 → 코드 작성       │      │ Phase 3: 데모 --ci 실행  │
│ ...                     │      │ → 여기서 처음 실행됨!     │
│ Task N → 코드 작성       │      │ → 실패 시 사용자 수동 fix │
│ 데모 스크립트 생성        │ ──→  │ → 자동 fix 루프 없음     │
│ Review (파일 목록 확인)   │      │                         │
│ ❌ 코드를 실행하지 않음    │      │                         │
└─────────────────────────┘      └─────────────────────────┘
```

**결과**:
- 데모가 보여주려는 동작이 전혀 동작하지 않음
- 런타임 에러 (TypeError, import 오류, 설정 누락 등) 다수 발생
- verify에서 실패해도 에이전트가 자동으로 수정/재시도하지 않음
- 태스크 N개를 한꺼번에 구현한 후 처음 실행하므로 누적된 버그가 한꺼번에 터짐

### 근본 원인 분석

| 원인 | 설명 | 영향 |
|------|------|------|
| **implement 중 실행 없음** | speckit-implement가 코드만 생성, 실행하지 않음 | 컴파일/빌드 에러가 쌓인 채 verify까지 감 |
| **태스크 일괄 구현** | Task 1~N을 연속 구현 후 한 번에 Review | Task 2의 버그가 Task 5에서 복합적으로 터짐 |
| **데모 스크립트 후순위** | 데모 스크립트는 마지막 태스크로 생성 | 데모가 실제 구현과 맞지 않을 가능성 높음 |
| **자동 fix 루프 부재** | verify 실패 → "Fix and re-verify" (사용자 수동) | 에이전트가 에러를 보고도 자동 수정하지 않음 |
| **Review = 정적 검사** | Review에서 파일 목록/변경 사항만 표시 | 런타임 동작 검증 없이 승인 가능 |

### 제안 흐름

```
개선된 흐름:
implement
┌─────────────────────────────────────────────────────┐
│ Task 1 → 코드 작성 → 빌드 확인 ──┐                  │
│ Task 2 → 코드 작성 → 빌드 확인    │ 실패 시 즉시 수정 │
│ ...                              │                  │
│ Task N → 코드 작성 → 빌드 확인 ──┘                  │
│                                                     │
│ ★ 데모 사전 실행 (Pre-flight Demo Run)               │
│   데모 --ci 실행 → 성공? ──→ Review 진입            │
│                    └─ 실패 → 에러 분석 → 자동 수정   │
│                              (최대 3회)              │
│                              └─ 3회 실패 → Review    │
│                                 (에러 리포트 포함)    │
└─────────────────────────────────────────────────────┘
         ↓
verify (재검증 — implement에서 이미 1차 통과)
┌─────────────────────────────────────────────────────┐
│ Phase 1: 테스트/빌드 (이미 통과했을 가능성 높음)      │
│ Phase 3: 데모 --ci 재실행                            │
│   실패 시 → ★ 자동 Fix 루프 (최대 3회)              │
│              에러 분석 → 코드 수정 → 재실행           │
│              같은 에러 반복 시 중단 → 사용자 판단     │
└─────────────────────────────────────────────────────┘
```

### 세부 메커니즘

#### A. 태스크 레벨 빌드 검증 (implement 중)

각 태스크 구현 후 최소 검증:
1. **빌드 성공 여부** — 컴파일/트랜스파일 에러 없음
2. **기존 테스트 통과** — 새 코드가 기존 테스트를 깨뜨리지 않음
3. 실패 시 → 다음 태스크로 넘어가지 않고 즉시 수정

검증 수준 (구현 복잡도 순):
- **최소**: 빌드만 확인 (낮은 비용)
- **표준**: 빌드 + 기존 테스트 (중간 비용)
- **강화**: 빌드 + 테스트 + 서버 시작 가능 여부 (높은 비용)

#### B. 데모 사전 실행 (implement Review 전)

implement의 모든 태스크 완료 후, Review 진입 전에 데모를 1회 실행:
1. `demos/F00N-name.sh --ci` 실행
2. 성공 → Review 진입 (데모 통과 사실 표시)
3. 실패 → 에러 분석 → 자동 수정 시도 (최대 3회)
   - 수정 성공 → Review 진입
   - 3회 실패 → 에러 리포트와 함께 Review 진입 (사용자 판단)

#### C. 자동 Fix 루프 (verify 실패 시)

verify Phase 1/3 실패 시 에이전트가 자동으로:
1. stdout/stderr 에러 메시지 분석
2. 에러 유형 분류 (import 오류, 설정 누락, 타입 에러, API 불일치 등)
3. 관련 소스 코드 수정
4. 재실행
5. 같은 에러 반복 시 → 루프 중단, 사용자에게 에러 리포트 표시

루프 제한:
- 최대 3회 시도
- 동일 에러 패턴 반복 시 즉시 중단
- 각 시도마다 변경 사항 기록 (rollback 가능)

#### D. 빌드 게이트 (implement → verify 전이 조건)

implement에서 verify로 넘어가기 위한 필수 조건:
- [ ] 빌드 성공 (컴파일 에러 없음)
- [ ] 서버 시작 가능 (프로세스 crash 없음)
- [ ] 데모 --ci 최소 1회 성공 (또는 에러 리포트와 함께 사용자 승인)

미충족 시 → verify 진입 차단, implement Review에서 해결 요구

### 수정 대상 (예상)

- `reference/injection/implement.md` — 태스크 레벨 빌드 검증 + 데모 사전 실행 추가
- `commands/pipeline.md` — implement → verify 전이 조건 (빌드 게이트) 추가
- `commands/verify-phases.md` — Phase 1/3 실패 시 자동 Fix 루프 추가
- `reference/demo-standard.md` — 데모 사전 실행 가이드 추가
- `reference/context-injection-rules.md` — 자동 Fix 루프 공통 패턴 추가
- `reference/state-schema.md` — implement 빌드 게이트 상태 필드 추가

### 구현 우선순위: 높음 (현재 가장 큰 실사용 문제)

### 미결정 사항

- [ ] 태스크 레벨 검증의 기본 수준 (최소/표준/강화 중 default)
- [ ] 자동 Fix 루프 최대 횟수 (3회? 5회?)
- [ ] 빌드 게이트를 강제할지, 사용자가 override할 수 있게 할지
- [ ] 데모 사전 실행 실패 시 Review를 차단할지, 경고만 할지
- [ ] 자동 Fix 시 변경 사항의 rollback 메커니즘 필요 여부
- [ ] speckit-implement 내부 동작과의 충돌 가능성 (spec-kit이 자체 테스트를 실행하는 경우)
- [ ] 태스크 레벨 검증이 context window를 과도하게 소모하지 않는지
- [ ] 데스크톱 앱(Electron/Tauri)에서 빌드 게이트의 "서버 시작" 조건을 어떻게 적용할지
