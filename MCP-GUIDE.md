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

또는 `.claude/settings.json`에 직접 추가:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

설치 후 Claude Code를 재시작합니다.

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

MCP 서버는 Claude Code가 별도 자식 프로세스로 직접 실행하므로 `.zshrc`/`.bashrc`의 PATH 설정이 적용되지 않을 수 있습니다. 특히 Node.js가 `/usr/local/bin`에 설치되어 있지만 MCP 프로세스의 PATH에 포함되지 않는 경우 발생합니다.

**진단:**

```bash
# Node.js 위치 확인
which node    # 또는: ls /usr/local/bin/node
node --version
```

**해결:** PATH 환경변수를 포함해서 MCP를 등록합니다.

```bash
# 기존 제거
claude mcp remove playwright -s local   # 또는 -s user, -s project (현재 스코프에 맞게)

# PATH 포함해서 재등록
claude mcp add --scope user playwright \
  -e PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  -- npx @playwright/mcp@latest
```

> **Tip**: `--scope user`로 등록하면 모든 프로젝트에서 사용 가능합니다. 특정 프로젝트에서만 사용하려면 `--scope project`를 사용하세요.

#### nvm / fnm 사용 시

Node.js 버전 매니저를 사용하는 경우, 해당 매니저가 설정하는 경로를 포함해야 합니다:

```bash
# nvm 사용 시 (경로 예시 — 실제 버전에 맞게 수정)
claude mcp add --scope user playwright \
  -e PATH=$HOME/.nvm/versions/node/v20.x.x/bin:/usr/bin:/bin \
  -- npx @playwright/mcp@latest

# fnm 사용 시
claude mcp add --scope user playwright \
  -e PATH=$HOME/.fnm/node-versions/v20.x.x/installation/bin:/usr/bin:/bin \
  -- npx @playwright/mcp@latest
```

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
3. Playwright MCP: browser_snapshot → DOM 구조 파악
4. Playwright MCP: browser_click / browser_type → 인터랙션
5. Playwright MCP: browser_console_messages → 에러 확인
6. Playwright MCP: browser_take_screenshot → 시각적 확인
```

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

### Runtime Exploration 시 임시 CDP 전환

Playwright MCP는 일반적으로 웹 브라우저용으로 설정됩니다. Electron 앱을 탐색하려면 `--cdp-endpoint`를 추가해야 하는데, 이 설정은 **일반 웹 탐색과 양립 불가**합니다. 따라서 Electron 탐색 전후로 전환이 필요합니다.

**Electron 탐색 시작 전 — CDP 모드로 전환:**

```bash
claude mcp remove playwright
claude mcp add playwright \
  -e PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  -- npx @playwright/mcp@latest --cdp-endpoint http://127.0.0.1:9222
# → Claude Code 재시작
```

**Electron 탐색 완료 후 — 일반 모드로 원복:**

```bash
claude mcp remove playwright
claude mcp add playwright \
  -e PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  -- npx @playwright/mcp@latest
# → Claude Code 재시작
```

> **Tip**: `/reverse-spec` Phase 1.5에서 Electron 앱을 탐색할 때 에이전트가 이 전환을 안내합니다. 탐색이 끝나면 반드시 원복하세요.

---

## Playwright MCP 제공 기능

| 기능 | 도구 | 용도 |
|------|------|------|
| 페이지 이동 | `browser_navigate` | URL 이동, 앞/뒤 |
| DOM 구조 | `browser_snapshot` | 접근성 트리 기반 — 텍스트, role, 요소 구조 |
| 클릭 | `browser_click` | 요소 클릭 |
| 텍스트 입력 | `browser_type` | 필드에 텍스트 입력 |
| 호버 | `browser_hover` | 마우스 오버 |
| 드래그 | `browser_drag` | 드래그앤드롭 |
| 셀렉트 | `browser_select_option` | 드롭다운 선택 |
| 키 입력 | `browser_press_key` | Enter, Escape 등 |
| 대기 | `browser_wait_for` | 요소 출현/조건 대기 |
| 스크린샷 | `browser_take_screenshot` | 시각적 확인 |
| 콘솔 로그 | `browser_console_messages` | JS 에러/경고 수집 |
| 네트워크 | `browser_network_requests` | API 요청 모니터링 |
| 파일 업로드 | `browser_file_upload` | 파일 입력 |
| 다이얼로그 | `browser_handle_dialog` | alert/confirm/prompt 처리 |
| 탭 관리 | `browser_tab_*` | 멀티탭 시나리오 |
| PDF 저장 | `browser_pdf_save` | 페이지를 PDF로 저장 |
| 테스트 생성 | `browser_generate_playwright_test` | 인터랙션을 Playwright 테스트 코드로 변환 |

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
