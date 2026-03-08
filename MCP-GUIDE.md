# MCP Setup Guide

spec-kit-skills의 런타임 검증 기능(reverse-spec 원본 탐색, implement 중 동작 확인, verify UI 검증)을 활용하려면 MCP를 설정해야 합니다.

---

## 권장 구성

**Playwright MCP**를 기본 MCP로 사용합니다. 웹앱과 Electron을 하나의 MCP로 커버합니다.

| 플랫폼 | MCP | 설치 난이도 |
|--------|-----|-----------|
| **웹앱** (React, Vue, Next.js 등) | Playwright MCP | 낮음 (`npx` 한 줄) |
| **Electron** | Playwright MCP (`--electron-app`) | 낮음 |
| **Tauri v2** | Tauri MCP *(향후 확장 예정)* | — |

> **Claude Preview**는 dev server 실행/관리 용도로 보조 사용합니다 (내장, 별도 설치 불필요).

---

## Playwright MCP 설치

- GitHub: [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp)
- 요구사항: **Node.js 18+**

### 설치 명령

```bash
claude mcp add playwright -- npx @playwright/mcp@latest
```

설치 후 Claude Code를 재시작합니다.

> **참고**: `claude mcp add`로 설치하면 Claude Code가 자체적으로 설정을 관리합니다. 설정 파일 위치는 설치 방법(CLI, 플러그인 마켓플레이스 등)에 따라 다르므로 직접 편집할 필요 없습니다.

### 설치 확인

```bash
# 등록 상태 확인
claude mcp get playwright

# 기대 출력:
# playwright:
#   Status: ✓ Connected
#   Type: stdio
#   Command: npx
#   Args: @playwright/mcp@latest
```

`Status: ✗ Failed to connect`가 표시되면 아래 트러블슈팅을 참고하세요.

### 트러블슈팅

#### `Failed to connect` — npx/node를 찾지 못하는 경우

`claude mcp get playwright`에서 `Status: ✗ Failed to connect`가 표시되면 Node.js/npx가 시스템 PATH(`/usr/local/bin` 또는 `/opt/homebrew/bin`)에 설치되어 있는지 확인하세요.

```bash
which npx
# ✓ /opt/homebrew/bin/npx 또는 /usr/local/bin/npx → 정상
# ✗ ~/.nvm/... 또는 ~/.fnm/... → 아래 참고
```

**원인**: MCP 서버는 Claude Code가 자식 프로세스로 직접 spawn하므로 `.zshrc`/`.bashrc`를 읽지 않습니다. nvm/fnm은 셸 초기화 파일에서 PATH를 동적으로 설정하기 때문에 MCP 프로세스에서는 npx를 찾을 수 없습니다.

**해결**: Homebrew로 설치하면 시스템 PATH(`/opt/homebrew/bin`)에 자동 등록되어 추가 설정 없이 동작합니다:

```bash
brew install node
```

> **Tip**: `--scope user`로 등록하면 모든 프로젝트에서 사용 가능합니다. 특정 프로젝트에서만 사용하려면 `--scope project`를 사용하세요.

---

## 웹앱 설정

Playwright MCP 설치만으로 바로 사용할 수 있습니다. 에이전트가 브라우저를 실행하고 `localhost`에 접속하여 인터랙션합니다.

### Dev Server 실행 (Claude Preview 보조 사용)

dev server 라이프사이클 관리에는 Claude Preview를 사용합니다. 프로젝트 루트에 `.claude/launch.json`을 생성합니다:

```json
{
  "version": "0.0.1",
  "configurations": [
    {
      "name": "dev",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 3000
    }
  ]
}
```

#### 프레임워크별 예시

**Next.js:**
```json
{ "name": "dev", "runtimeExecutable": "npm", "runtimeArgs": ["run", "dev"], "port": 3000 }
```

**Vite (React/Vue/Svelte):**
```json
{ "name": "dev", "runtimeExecutable": "npm", "runtimeArgs": ["run", "dev"], "port": 5173 }
```

**Create React App:**
```json
{ "name": "dev", "runtimeExecutable": "npm", "runtimeArgs": ["start"], "port": 3000 }
```

### 동작 흐름

```
1. Claude Preview: preview_start → dev server 실행
2. Playwright MCP: browser_navigate → localhost 접속
3. Playwright MCP: browser_snapshot → 접근성 트리로 UI 구조 파악
4. Playwright MCP: browser_click / browser_type → 인터랙션
5. Playwright MCP: browser_console_messages → 에러 확인
```

> **Screenshot (`browser_take_screenshot`)은 사용하지 않습니다.** `browser_snapshot`(접근성 트리)이 컴포넌트 구조, 텍스트, 인터랙티브 요소를 정확히 반환하며 Feature 추출에 충분합니다. Screenshot은 시각적 외관만 제공하고 컨텍스트 윈도우를 크게 소모합니다.

---

## Electron 설정

Electron 앱 연결에는 두 가지 방법이 있습니다.

### 방법 A: `--electron-app` 플래그 (권장)

Electron 지원이 PR [#1291](https://github.com/microsoft/playwright-mcp/pull/1291)로 공식 머지되었습니다.

> **Note**: 머지되었으나 최신 릴리스(v0.0.68)에 아직 미포함일 수 있습니다. `@next` 태그 또는 최신 버전을 확인하세요.

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--electron-app", "./path/to/electron-app",
        "--caps=electron"
      ]
    }
  }
}
```

Electron 전용 CLI 옵션:

| 옵션 | 설명 |
|------|------|
| `--electron-app` | Electron 앱 진입점 경로 |
| `--electron-cwd` | Electron 앱의 작업 디렉토리 |
| `--electron-executable` | Electron 바이너리 경로 |
| `--electron-timeout` | 앱 시작 타임아웃 |
| `--caps=electron` | Electron 전용 기능 활성화 |

### 방법 B: CDP 연결 (현재 안정 버전에서 사용 가능)

Electron 앱을 remote debugging 포트와 함께 실행하고, Playwright MCP가 CDP(Chrome DevTools Protocol)로 연결합니다:

```bash
# Electron 앱을 remote debugging 포트와 함께 실행
./your-electron-app --remote-debugging-port=9222
```

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--cdp-endpoint", "http://localhost:9222"
      ]
    }
  }
}
```

> 방법 B는 Electron이 Chromium 기반이라는 점을 활용합니다. `--electron-app`이 안정 릴리스에 포함될 때까지의 검증된 대안입니다.

### Electron 빌드 도구별 CDP 실행 방법

Electron 앱에 `--remote-debugging-port`를 전달하는 방법은 빌드 도구마다 다릅니다:

| 빌드 도구 | CDP 실행 명령 |
|-----------|-------------|
| **electron-vite** | `npx electron-vite dev -- --remote-debugging-port=9222` |
| **electron-forge** | `ELECTRON_ARGS='--remote-debugging-port=9222' npm run start` |
| **electron-builder** | `ELECTRON_ARGS='--remote-debugging-port=9222' npm run dev` |
| **Direct electron** | `npx electron . --remote-debugging-port=9222` |

> ⚠️ **electron-vite는 `--` separator가 필수**입니다. `ELECTRON_ARGS` 환경변수를 지원하지 않으므로, `--` 뒤에 Electron 플래그를 직접 전달해야 합니다. 이것이 CDP 연결 실패의 가장 흔한 원인입니다.

> **방법 선택 가이드**: CDP (방법 B) → 업계 표준, 세션 시작 전 사전 설정 권장. `--electron-app` (방법 A) → 공식 지원 안정화 후 사용.

### CDP 사전 설정 방식 (권장 — 세션 시작 전 준비)

Electron 앱의 Runtime Exploration을 사용하려면 세션 시작 **전에** CDP를 미리 설정합니다:

```bash
# 1. Electron 앱을 CDP 포트와 함께 실행 (별도 터미널)
cd /path/to/electron-project
npx electron-vite dev -- --remote-debugging-port=9222

# 2. Playwright MCP를 CDP 모드로 등록
claude mcp add --scope user playwright -- npx @playwright/mcp@latest --cdp-endpoint http://localhost:9222

# 3. Claude Code 시작 → /reverse-spec 실행
```

**주의사항**:
- Electron 앱이 Claude Code 시작 **전에** 실행 중이어야 함
- CDP 모드에서는 **일반 웹 브라우징 불가** (해당 CDP 엔드포인트에만 연결)
- 분석 완료 후 일반 모드로 원복 필요 (아래 참고)

### Electron 분석 완료 후 — 일반 모드로 원복

```bash
claude mcp remove playwright
claude mcp add --scope user playwright -- npx @playwright/mcp@latest
# → Claude Code 재시작
```

---

## MCP Capability Map

> 에이전트가 런타임 인터랙션 시 사용하는 capability와 MCP별 도구 매핑.
> 새 MCP 추가 시 이 테이블에 열을 추가하면 된다. 각 스킬의 instruction은 **Capability 이름**으로 작성되므로 수정 불필요.

### Capability 감지

에이전트는 각 단계(reverse-spec Phase 1.5, implement 검증, verify SC 검증) 시작 시 **한 번** 감지를 수행한다:

1. **사용 가능한 도구 목록에서** 아래 Detect 행의 도구가 존재하는지 확인 (도구명에 `browser_navigate`가 포함되어 있으면 Playwright MCP 활성)
2. 감지된 MCP의 도구명을 사용하여 이후 instruction 실행
3. **어떤 MCP도 감지되지 않으면** → 설치 안내 + Skip 옵션 (HARD STOP)

> **⚠️ 주의**: MCP 설정 파일(`settings.json`, `settings.local.json` 등)을 직접 읽어서 감지하지 않는다. 설치 방법(CLI `claude mcp add`, 플러그인 마켓플레이스, 수동 설정)에 따라 설정 저장 위치가 다르므로 파일 기반 감지는 신뢰할 수 없다. **사용 가능한 도구 목록 확인이 유일하게 신뢰할 수 있는 감지 방법이다.**

### Capability Table

| Capability | 용도 | Playwright MCP | Tauri MCP (향후) |
|-----------|------|---------------|-----------------|
| **Detect** | MCP 가용성 판별 | `browser_navigate` 존재 여부 | `webview_navigate` 존재 여부 |
| **Navigate** | URL/라우트 이동 | `browser_navigate` | `webview_navigate` |
| **Snapshot** | 페이지 구조 캡처 (접근성 트리) | `browser_snapshot` | `webview_snapshot` |
| **Click** | 요소 클릭 | `browser_click` | `webview_click` |
| **Type** | 텍스트 입력 | `browser_type` | `webview_type` |
| **Select** | 드롭다운 선택 | `browser_select_option` | `webview_select` |
| **Press** | 키보드 입력 | `browser_press_key` | `webview_press_key` |
| **Wait** | 요소/조건 대기 | `browser_wait_for` | `webview_wait` |
| **Console** | JS 콘솔 메시지 수집 | `browser_console_messages` | `webview_console` |
| **Network** | 네트워크 요청 모니터링 | `browser_network_requests` | — |
| **Dialog** | alert/confirm/prompt 처리 | `browser_handle_dialog` | — |

> **사용 방법**: 각 스킬의 instruction에서 "**Navigate** capability로 URL 이동" 등으로 기술.
> 에이전트는 감지된 MCP에 따라 위 테이블에서 구체적 도구명을 확인하여 호출.

### 사용 시점별 필요 Capability

| 시점 | 필수 Capability | 선택 Capability |
|------|----------------|----------------|
| **reverse-spec Phase 1.5** (원본 앱 탐색) | Detect, Navigate, Snapshot | Console, Wait |
| **implement 런타임 검증** (태스크별 확인) | Detect, Navigate, Snapshot, Console | — |
| **verify SC UI 검증** (SC 액션 실행) | Detect, Navigate, Snapshot, Click, Type, Console | Select, Press, Wait |

### 앱 세션 관리 원칙

MCP는 Claude Code 세션 내내 상주하지만, **앱(dev server)의 시작/종료는 비용이 크다**. 따라서:

- **implement**: 첫 태스크 검증 시 앱 기동 → 이후 태스크는 Navigate로 화면 전환만 → Review 완료 후 종료
- **verify**: demo script가 앱 기동 → SC 검증 전부 같은 세션 → Phase 완료 후 종료
- **reverse-spec**: Phase 1.5 시작 시 앱 기동 → 전체 탐색 → Phase 1.5 종료 시 cleanup

> ⚠️ 태스크마다 앱을 재시작하지 않는다. Navigate capability로 화면 전환하여 검증.

### Runtime Exploration 탐색 전략

**Snapshot 기반 탐색** — Screenshot은 사용하지 않음:

| 도구 | 반환값 | Feature 추출 기여 | 컨텍스트 비용 |
|------|--------|------------------|-------------|
| `browser_snapshot` | 접근성 트리 (컴포넌트 구조, 텍스트, role, 인터랙티브 요소) | **높음** — 구조적 정보 직접 제공 | 낮음 (텍스트) |
| `browser_take_screenshot` | 시각적 외관 (색상, 레이아웃, 아이콘) | **없음** — Feature 정의와 무관 | 높음 (이미지) |

**End-to-end 탐색 흐름** (reverse-spec Phase 1.5):

```
1. Playwright MCP 가용성 감지 (사용 가능한 도구 목록에서 browser_navigate 확인)
2. Electron인 경우: browser_snapshot으로 CDP 연결 상태 확인 (앱 콘텐츠 표시 = CDP 활성)
3. 앱 유형별 dev server 실행:
   - 웹앱: 기존 dev 명령 (npm run dev)
   - Electron (CDP 사전 설정): 이미 실행 중이므로 launch 스킵
   - Electron (CDP 미설정): CDP 설정 안내 또는 코드 분석만 진행
4. browser_navigate → dev server URL 접속 (Electron은 CDP를 통해 연결)
5. browser_snapshot → 현재 화면 접근성 트리 수집
6. browser_click → 네비게이션 링크/탭 클릭으로 화면 전환
7. browser_snapshot → 전환된 화면 구조 수집
8. 4-7 반복하며 모든 주요 화면과 흐름 탐색
9. 결과를 Phase 2 Deep Analysis의 입력으로 전달
```

> **핵심 원칙**: Snapshot으로 **무엇이 있는지**(구조)를 파악하고, Phase 2 코드 분석으로 **어떻게 동작하는지**(로직)를 추출한다. Screenshot으로 **어떻게 보이는지**(외관)를 확인하는 것은 Feature 추출 목적에 불필요하다.

### Playwright MCP 전체 도구 목록

Capability Map에 포함되지 않은 Playwright 전용 도구:

| 도구 | 용도 |
|------|------|
| `browser_hover` | 마우스 오버 |
| `browser_drag` | 드래그앤드롭 |
| `browser_file_upload` | 파일 입력 |
| `browser_tab_*` | 멀티탭 시나리오 |
| `browser_take_screenshot` | 시각적 확인 |
| `browser_pdf_save` | 페이지를 PDF로 저장 |
| `browser_generate_playwright_test` | 인터랙션을 Playwright 테스트 코드로 변환 |

## Claude Preview 보조 기능

dev server 관리와 정밀 검사에 사용합니다 (내장, 별도 설치 불필요):

| 기능 | 도구 | 용도 |
|------|------|------|
| 서버 시작/중지 | `preview_start`, `preview_stop` | dev server 라이프사이클 |
| 서버 로그 | `preview_logs` | 서버 stdout/stderr (빌드 에러 확인) |
| CSS 정밀 검사 | `preview_inspect` | computed style, bounding box |
| 네트워크 body | `preview_network` | API 응답 body까지 조회 |
| 반응형 테스트 | `preview_resize` | mobile/tablet/desktop 프리셋 + 다크모드 |

---

## 주요 CLI 옵션

| 옵션 | 설명 | 예시 |
|------|------|------|
| `--browser` | 브라우저 종류 | `chrome`, `firefox`, `webkit`, `msedge` |
| `--headless` | 헤드리스 모드 | (플래그만) |
| `--viewport-size` | 뷰포트 크기 | `"1280x720"` |
| `--cdp-endpoint` | CDP 연결 (Electron용) | `"http://localhost:9222"` |
| `--storage-state` | 인증 상태 파일 로드 | `"auth.json"` |
| `--user-data-dir` | 영구 브라우저 프로필 | `"./profile"` |
| `--caps` | 추가 기능 활성화 | `tabs`, `pdf`, `history`, `wait`, `files`, `electron` |
| `--isolated` | 격리 모드 (메모리 전용 프로필) | (플래그만) |

---

## MCP 없이 사용하기 (수동 fallback)

MCP를 설치할 수 없는 환경에서도 spec-kit-skills를 사용할 수 있습니다. 런타임 검증 단계에서 에이전트가 앱을 실행한 후 사용자에게 수동 확인을 요청합니다:

```
📋 UI Manual Verification
앱이 http://localhost:3000 에서 실행 중입니다.

아래 항목을 확인해주세요:
□ SC-001: /login 이동 → 로그인 폼이 보이는가?
□ SC-002: 이메일/비밀번호 입력 → 제출 → 대시보드로 이동하는가?
□ SC-003: /dashboard → 데이터 테이블이 렌더링되는가?

결과를 알려주세요 (전체 통과 / 실패 항목 번호).
```

---

## 향후 확장 예정

### Tauri v2 — Tauri MCP

- GitHub: [hypothesi/mcp-server-tauri](https://github.com/hypothesi/mcp-server-tauri)
- 현재 베타 (v0.9.0), 안정화 후 가이드 추가 예정
- 앱에 Bridge Plugin 설치 필요 (Rust 빌드)
- IPC(Rust ↔ JS) 경계 검증, WebView DOM 검사, 시스템 로그 수집 등 Tauri 특화 기능 제공
