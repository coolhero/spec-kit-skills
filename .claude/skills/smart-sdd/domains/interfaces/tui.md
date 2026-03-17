# Interface: tui

> Terminal User Interface. Applies when the project renders interactive UIs in the terminal (not browser).
> Module type: interface

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/tui.md`](../../../shared/domains/interfaces/tui.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Every view: renders correctly in standard terminal (80×24 minimum) + handles resize
- Keyboard navigation: all interactive elements reachable via keyboard (no mouse-only paths)
- Input handling: specific key → specific action (e.g., "Ctrl+C exits gracefully with cleanup")
- Color/theme: renders acceptably in both dark and light terminal backgrounds
- Graceful degradation: behavior when terminal lacks features (no mouse, no truecolor, no unicode)

### SC Anti-Patterns (reject)
- "TUI displays correctly" — must specify terminal dimensions + content verification
- "User can navigate" — must specify key bindings + expected focus transitions
- "Colors work" — must specify color mode detection + fallback behavior

### SC Measurability Criteria
- Render time for complex views (list with 1000+ items)
- Terminal state after operation (cursor position, screen content)
- Cleanup on exit (raw mode restored, alternate screen cleared)

---

## S1. Demo Pattern (override)

- **Type**: Script-based (launches app in terminal)
- **Default mode**: Start TUI → automated key sequence → screenshot/snapshot → exit
- **CI mode**: Start app → verify it renders without crash → exit
- **"Try it" instructions**: Terminal command to launch + key sequence to navigate

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Rendering** | Framework? (Ink/Blessed/OpenTUI/bubbletea/custom) Custom renderer? |
| **Input** | Mouse support? Vim-like bindings? Command palette? Fuzzy search? |
| **Layout** | Responsive to terminal resize? Split panes? Tab panels? |
| **Theming** | Color mode detection (dark/light)? 256-color vs truecolor? |
| **Terminal compat** | Minimum terminal requirements? Windows Terminal support? SSH session support? |

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| At least one view or screen | View name + what it displays stated |
| Input handling approach | Key bindings or mouse interactions described |
| Terminal framework choice | Framework identified (Ink, bubbletea, Blessed, custom) or "TBD — decide in plan" |

---

## S7. Bug Prevention — TUI-Specific

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| TUI-001 | Raw mode leak | Process exits without restoring terminal mode | Ensure cleanup handler registered for SIGINT/SIGTERM/uncaughtException |
| TUI-002 | Alternate screen leak | App crashes without clearing alternate screen buffer | Register beforeExit handler to write `\x1b[?1049l` |
| TUI-003 | Terminal dimension race | Layout calculated before terminal reports dimensions | Debounce resize handler, use initial dimensions from `process.stdout.columns/rows` |
| TUI-004 | Unicode width miscalculation | East Asian characters or emoji treated as single-width | Use `string-width` or equivalent for display width calculation |
| TUI-005 | Color detection failure | Hard-coded colors without checking terminal capabilities | Probe `COLORTERM`, `TERM` env vars; provide monochrome fallback |
| TUI-006 | stdin conflict | Multiple components competing for raw stdin | Single input dispatcher pattern — one reader, event bus distribution |

---

## S8. Runtime Verification Strategy

> Cross-references [reference/runtime-verification.md](../../reference/runtime-verification.md)

| Field | Value |
|-------|-------|
| **Start method** | Spawn app in PTY (pseudoterminal) — `node-pty`, `bun-pty`, or OS-level PTY allocation |
| **Verify method** | Send keystrokes to PTY stdin → read PTY stdout → compare terminal output snapshots. Backend: PTY runner (terminal snapshot comparison) |
| **Stop method** | Send Ctrl+C (SIGINT) to PTY → verify graceful cleanup (raw mode restored, alternate screen cleared) |
| **SC classification extensions** | `tui-auto` — TUI SCs verifiable via PTY snapshot without human visual inspection |

**TUI-specific verification**:
- Step 3d Interactive Runtime Verification: spawn app in PTY → send key sequences → capture terminal output snapshots → compare against expected patterns
- Resize verification: change PTY dimensions → verify layout reflows correctly
- Cleanup verification: kill process → verify terminal is in normal state (echo on, canonical mode, main screen)
- Fallback: if PTY spawn unavailable, fall back to process runner (limited — no terminal state inspection)
