# TODO — Feature 개발 완결성 확보

> 파이프라인 전체를 추적하여 발견한 정보 흐름 단절(Gap)을 해소하고,
> 런타임 실행 기반 검증을 추가하여 Feature 기능 재현의 정확도를 확보한다.

---

## 핵심 목표: Feature 기능 재현의 정확도

원본 앱의 Feature를 새 프로젝트에서 **동일하게 재현**하려면, 파이프라인 전반에 걸쳐 기능 손실을 방지해야 한다.

```
              입력 품질                구현 검증               출력 검증
         (reverse-spec)           (implement)              (verify)
         ┌──────────┐            ┌──────────┐           ┌──────────┐
         │ 코드 분석  │            │ 코드 작성  │           │ 빌드+테스트│
    현재  │ (Phase 2) │  ───────→  │ (실행 안함) │  ──────→  │ (서버만)  │
         └──────────┘            └──────────┘           └──────────┘
                ↓                       ↓                      ↓
         ┌──────────┐            ┌──────────┐           ┌──────────┐
         │ + 런타임   │            │ + 태스크별  │           │ + SC 기반  │
    개선  │   탐색    │  ───────→  │   실행 확인 │  ──────→  │  UI 검증  │
         │ (Ph 1.5) │            │ + Fix 루프 │           │ + Parity  │
         └──────────┘            └──────────┘           └──────────┘
```

**이미 구현된 기능 재현 메커니즘** (코드 분석 기반):

| 메커니즘 | 무엇을 잡는가 | 상태 |
|----------|-------------|------|
| SBI (Source Behavior Inventory) | 함수 레벨 기능 손실 — exported function 전수 추적 | ✅ |
| UI Component Features (Phase 2-7) | 라이브러리 config/plugin 기반 기능 | ✅ |
| FR ↔ SBI 매핑 (specify + verify) | B### → FR-### 추적으로 스펙 누락 방지 | ✅ |
| Parity Check | 구현 완료 후 원본과 구조/로직/UI 대비 | ✅ |
| Runtime Exploration (Phase 1.5) | 시각/행동 컨텍스트 수집 — 코드만 읽어서는 알 수 없는 UI/UX | ✅ |

---

## 파이프라인 Gap 분석

> 2026-03-08 전체 파이프라인 추적 결과. reverse-spec 산출물 → smart-sdd 소비까지 정보 흐름 단절 지점.

```
reverse-spec                          smart-sdd
┌─────────────┐                    ┌──────────┐
│ Phase 1.5   │──runtime-exploration.md──→│ specify  │ ❌ G1: 미소비
│ Runtime     │                    │          │
│ Exploration │──→ pre-context.md ──→│          │ ✅ 소비 (SBI, 드래프트 FR/SC)
└─────────────┘                    └──────────┘
       │                                │
       │                           ┌──────────┐
       │                           │  plan    │ ❌ G2: runtime-exploration 미소비
       │                           └──────────┘
       │                                │
       │                           ┌──────────┐
       │                           │implement │ ❌ G4: 런타임 검증 전무
       │                           └──────────┘
       │                                │
       │                           ┌──────────┐
       └───────────────────────────→│ verify   │ ⚠️ G5: UI 검증 silent-skip
                                   └──────────┘

Phase 4-2: ❌ G3 — 라우트→Feature 매핑 알고리즘 미정의
Phase 1.5: ❌ G6 — Electron 크래시 복구 없음
Phase 2-6→4-2: ⚠️ G7 — SBI Feature별 필터링 시점 모호
```

| Gap | 심각도 | 설명 |
|-----|--------|------|
| **G1** | High | runtime-exploration.md가 specify(injection/specify.md)에서 미소비. UI 관찰이 FR/SC에 반영 안 됨 |
| **G2** | High | runtime-exploration.md가 plan(injection/plan.md)에서 미소비. 컴포넌트 설계 시 실제 UI 패턴 참조 불가 |
| **G3** | Medium | Phase 4-2에서 "라우트→Feature 매핑으로 분배"라고 명시하지만 매핑 알고리즘이 정의되지 않음 |
| **G4** | Critical | implement가 코드만 생성하고 한 번도 실행하지 않음. verify에서 처음 실행 → 버그 폭발 |
| **G5** | Medium | verify Phase 3 UI 검증이 MCP 없으면 경고 없이 silent-skip. MCP 필수 정책 미반영 |
| **G6** | Low | Electron 앱이 Runtime Exploration 중 크래시하면 복구 메커니즘 없음 |
| **G7** | Low | SBI가 Phase 2에서 글로벌 생성 → Phase 3에서 Feature 분류 → Phase 4-2에서 필터. 과정이 암묵적 |

---

## MCP 정책 (확정)

| 플랫폼 | MCP | 비고 |
|--------|-----|------|
| 웹앱 | Playwright MCP | 기본 |
| Electron | Playwright MCP (`--cdp-endpoint`) | CDP 임시 전환 필요 |
| Tauri v2 | Tauri MCP (향후 확장) | 현재 미지원 |

**MCP 필수 정책**: reverse-spec, verify 모두 Playwright MCP 필수. 없으면 설치 안내 또는 Skip.

상세: [MCP-GUIDE.md](MCP-GUIDE.md)

---

## 과업 목록

### 1. G1+G2 해소: runtime-exploration → specify/plan 주입

> **Gap**: runtime-exploration.md 데이터가 수집만 되고 specify/plan에서 소비되지 않음.

**specify 주입** (`smart-sdd/reference/injection/specify.md`):
- pre-context의 Runtime Exploration Results 섹션을 Checkpoint 주입 컨텐츠에 포함
- UI 레이아웃, 사용자 플로우, 관찰된 에러를 FR/SC 초안에 반영하도록 가이드 추가
- 예: 화면에서 관찰된 "API auth failure 인라인 알림" → SC에 에러 핸들링 시나리오 포함

**plan 주입** (`smart-sdd/reference/injection/plan.md`):
- Runtime Exploration의 Layout 패턴, Component Library 정보를 컴포넌트 설계 참조로 주입
- 예: "Three-column layout (sidebar + chat + input)" → plan에서 컴포넌트 분할 시 참조

**수정 대상**: `injection/specify.md`, `injection/plan.md`
**난이도**: 낮음
**의존**: —

---

### 2. G3 해소: 라우트→Feature 매핑 알고리즘 명시

> **Gap**: Phase 4-2가 "라우트→Feature 매핑으로 분배"라고만 명시. HOW가 없음.

**알고리즘 정의** (`reverse-spec/commands/analyze.md` Phase 4-2):
- Phase 3-1에서 Feature 경계를 파일/모듈 기반으로 결정함
- Phase 1에서 라우트 파일/페이지 컴포넌트가 어떤 모듈에 속하는지 이미 파악됨
- 따라서: **라우트 → 페이지 컴포넌트 → 모듈 → Feature** 의 추이적 관계로 매핑
- 공유 라우트(예: Settings)는 primary owner Feature에 포함, 다른 Feature에서 참조
- Phase 4-2에 이 알고리즘을 명시적으로 기술

**수정 대상**: `reverse-spec/commands/analyze.md` (Phase 4-2)
**난이도**: 낮음
**의존**: —

---

### 3. G5 해소: verify MCP 필수 정책 반영

> **Gap**: verify Phase 3 UI 검증이 MCP 없으면 silent-skip. MCP 필수 정책과 불일치.

**변경**:
- verify Phase 3 Step 2b: MCP 감지 → 없으면 경고 메시지 + "MCP 설치 후 재시도" / "UI 검증 Skip" HARD STOP
- silent-skip 제거
- `sdd-state.md`에 `UI Verify Mode` 필드 불필요 (항상 auto → MCP 있으면 실행, 없으면 HARD STOP)

**수정 대상**: `smart-sdd/commands/verify-phases.md`
**난이도**: 낮음
**의존**: —

---

### 4. G4 해소: implement 런타임 검증 + Fix 루프

> **Gap**: implement가 코드만 생성하고 한 번도 실행하지 않음. verify에서 처음 실행 → 버그 폭발.
> **가장 큰 실사용 문제.**

**태스크 완료 후 런타임 검증**:
```
Task 완료 → 앱 실행 → 해당 화면 이동 → 정상 렌더링 확인
  → ✅ 다음 태스크
  → ❌ 에러 분석 → 수정 → 재확인 (최대 3회)
```

**검증 수준**:
- Level 1: 빌드 성공 + 서버/앱 시작 (최소)
- Level 2: + 해당 태스크 관련 SC 실행 확인 (표준, 권장)
- Level 3: + 이전 태스크 SC 회귀 확인 (강화)

**implement 완료 후** (Review 전):
- 전체 SC 실행 → 실패 시 자동 Fix (최대 3회)
- 동일 에러 반복 시 중단 → 에러 리포트와 함께 Review

**자동 Fix 루프**:
1. stdout/stderr 에러 메시지 분석
2. 에러 유형 분류 (import, 설정, 타입, API 불일치 등)
3. 관련 소스 수정 → 재실행
4. 같은 에러 반복 시 루프 중단, 사용자에게 리포트

**수정 대상**: `injection/implement.md`, `pipeline.md`, `demo-standard.md`
**난이도**: 중간
**의존**: —

---

### 5. SC→UI Action 매핑 (specify/plan 단계)

> A-3 (verify SC 검증)의 데이터 소스. runtime-exploration의 User Flows를 검증 가능한 UI 액션으로 변환.

**목적**: UI Feature의 SC-###에서 검증 가능한 UI 액션을 추출. verify 시점에 자동 검증의 소스.

```
Coverage header 포맷 (demo script):
  FR-001 (Chat):
    SC-001: navigate / → fill input → click Send → verify message appears
    SC-002: navigate / → click model selector → verify dropdown visible
    SC-003: ⬜ (requires WebSocket — skip auto-verify)
```

**수정 대상**: `injection/specify.md`, `injection/plan.md`, `demo-standard.md`
**난이도**: 중간
**의존**: 과업 1 (specify/plan에 runtime 주입) 완료 후

---

### 6. verify SC 기반 자동 UI 검증

> verify Phase 3를 SC-### 인터랙션 검증으로 강화.

**확장된 verify Phase 3 Step 2b**:
1. Parse demo script → URL 추출
2. `browser_navigate` → 페이지 이동
3. 페이지 로드 확인
4. `browser_console_messages` → JS 에러/경고 수집
5. SC-### interaction verification:
   - Coverage header에서 SC + UI action 읽기
   - 각 SC: action 수행 → 결과 확인
   - pass/fail 기록
6. 최종 리포트

**결과 분류**:
- SC 인터랙션 실패: ⚠️ warning (false positive 가능, BLOCK 아님)
- JS 콘솔 에러 (TypeError/ReferenceError): ⚠️ warning + 강조
- 페이지 로드 실패: ⚠️ warning

**수정 대상**: `verify-phases.md`, `demo-standard.md`
**난이도**: 중간
**의존**: 과업 5 (SC→UI Action 매핑)

---

### 7. G6 해소: Electron 크래시 핸들링

> **Gap**: Runtime Exploration 중 Electron 앱이 크래시하면 이미 탐색한 데이터가 손실됨.

**변경** (`reverse-spec/commands/analyze.md` Phase 1.5-5):
- 탐색 중 Playwright 연결 끊김/프로세스 종료 감지
- 이미 수집한 화면 데이터 보존 (탐색 완료된 화면까지 runtime-exploration.md에 기록)
- HARD STOP: "앱 재시작 후 이어서 탐색" / "현재까지 수집한 데이터로 진행" / "Skip"

**수정 대상**: `reverse-spec/commands/analyze.md` (Phase 1.5-5)
**난이도**: 낮음
**의존**: —

---

### 8. G7 해소: SBI Feature별 필터링 프로세스 명시

> **Gap**: SBI가 Phase 2에서 글로벌 생성 → Phase 4-2에서 Feature별 필터. 과정이 암묵적.

**변경** (`reverse-spec/commands/analyze.md`):
- Phase 2-6: "글로벌 SBI를 생성한다. Feature 분류는 Phase 3 이후 Phase 4-2에서 수행" 명시
- Phase 4-2: "Phase 2-6의 글로벌 SBI에서 이 Feature의 소스 파일에 속하는 행동만 필터한다. B### ID는 Feature ID 순서로 전체 프로젝트에서 유일하게 부여" 명시

**수정 대상**: `reverse-spec/commands/analyze.md` (Phase 2-6, Phase 4-2)
**난이도**: 낮음
**의존**: —

---

### 9. Bug Prevention — 단계별 버그 예방 규칙

> "실행해서 잡자" (A) 외에, "애초에 발생을 막자" (B).

**B-1. plan 단계**:
- Target Runtime Compatibility (JS/CSS 제약)
- State Management Anti-patterns
- Async Race Condition Analysis
- Store Dependency Graph
- Downgrade Compatibility

**B-2. analyze 단계**:
- Cross-Feature Data Flow (Feature 간 데이터 의존성 + 초기화 순서)
- Nullable Field Tracking (공유 인터페이스 optional 필드 안전성)

**B-3. implement 단계**:
- IPC Boundary Safety
- Platform CSS Constraints
- Cross-Feature Integration Checklist
- Module Import Graph Validation
- Persistence Layer Write-Through

**B-4. verify 단계**:
- Empty State Smoke Test (모든 스토어 초기 상태에서 크래시 없이 렌더링)
- Smoke Launch Criteria (프로세스 시작 + 메인 화면 렌더링 + Error Boundary 미트리거 + JS 에러 없음)

**수정 대상**: `injection/plan.md`, `injection/analyze.md`, `injection/implement.md`, `verify-phases.md`, `domains/app.md`
**난이도**: 낮~중
**의존**: —

---

### 10. Spec-Code Drift

> implement 도중/이후 코드 변경 시 spec 아티팩트 역동기화.

**문제**: 파이프라인 도중 "OAuth도 추가해줘" → 코드는 변경, spec/plan/tasks에 미반영.

**잠재 접근**:
- A. verify에서 drift 감지 (코드 vs spec 비교)
- B. implement Review에서 새 기능 감지 + spec 추가 제안
- C. 별도 `sync` 커맨드

**상태**: 미결정 — 접근 방식 결정 필요
**구현 우선순위**: 낮음 (과업 1~9 완료 후)

---

## 구현 순서

| 순서 | 과업 | Gap | 수정 파일 | 난이도 | 의존 |
|------|------|-----|-----------|--------|------|
| 1 | runtime-exploration → specify/plan 주입 | G1+G2 | injection/specify.md, injection/plan.md | 낮음 | — |
| 2 | 라우트→Feature 매핑 알고리즘 | G3 | analyze.md (Phase 4-2) | 낮음 | — |
| 3 | verify MCP 필수 정책 | G5 | verify-phases.md | 낮음 | — |
| 4 | implement 런타임 검증 + Fix 루프 | G4 | injection/implement.md, pipeline.md | 중간 | — |
| 5 | SC→UI Action 매핑 | — | injection/specify.md, injection/plan.md, demo-standard.md | 중간 | 과업 1 |
| 6 | verify SC 자동 UI 검증 | — | verify-phases.md, demo-standard.md | 중간 | 과업 5 |
| 7 | Electron 크래시 핸들링 | G6 | analyze.md (Phase 1.5-5) | 낮음 | — |
| 8 | SBI 필터링 프로세스 명시 | G7 | analyze.md (Phase 2-6, 4-2) | 낮음 | — |
| 9 | Bug Prevention (B-1~4) | — | injection/*.md, verify-phases.md, domains/app.md | 낮~중 | — |
| 10 | Spec-Code Drift | — | 미정 | 미정 | 과업 1~9 |

> 과업 1~3, 7, 8은 독립적이므로 **병렬 진행 가능**.
> 과업 4는 독립적이지만 가장 큰 변경이므로 별도 집중.
> 과업 5→6은 순서 의존.

---

## 미결정 사항

- [ ] SC 인터랙션 실패를 BLOCK으로 승격할 조건이 있는가?
- [ ] Coverage 헤더 UI action을 필수로 할지 optional로 할지
- [ ] 자동 Fix 루프 최대 횟수 (3회? 5회?)
- [ ] 빌드 게이트를 강제할지 override 가능하게 할지
- [ ] 데스크톱 앱에서 빌드 게이트의 "서버 시작" 조건 적용 방법
- [ ] B-1 plan 단계 검증 항목의 context window 소모량
- [ ] B-1 State Management Anti-pattern을 라이브러리별로 할지 공통 원칙만 할지
- [ ] Spec-Code Drift A/B/C 접근 방식 결정

---

## Structural Gap Reference

> F006에서 발견된 5가지 구조적 공백. 과업과의 매핑.

| # | 공백 | 해결 과업 |
|---|------|----------|
| 1 | Runtime Verification 부재 | 과업 4, 6 |
| 2 | Integration Contract 부재 | 과업 9 (B-2, B-3) |
| 3 | Runtime Constraints 무인식 | 과업 9 (B-1) |
| 4 | Behavioral Contract 누락 | 과업 9 (B-1, B-3) |
| 5 | Module Dependency Graph 부재 | 과업 9 (B-3) |

---

## Tauri 확장 (향후)

> Tauri MCP (hypothesi/mcp-server-tauri) 안정화 후 추가.

**추가할 내용**:
- 과업 3에 Tauri MCP 분기 (webview_interact, webview_screenshot 등)
- 과업 6에 Tauri 자동 검증 흐름 (IPC 검증 포함)
- 과업 9 (B-3)에 Tauri IPC Safety Rules, Platform CSS Constraints
- MCP Bridge Plugin 자동 설치 (신규 프로젝트)
