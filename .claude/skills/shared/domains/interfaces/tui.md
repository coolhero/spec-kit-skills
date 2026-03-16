# Interface: tui

> Terminal UI — interactive terminal interfaces (not browser GUI).

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: TUI, terminal UI, terminal interface, Ink, Blessed, OpenTUI, bubbletea, Ratatui, Textual, Rich, ncurses, curses

**Secondary**: raw mode, ANSI escape, terminal rendering, PTY, pseudoterminal, terminal app, console UI

### Code Patterns (R1 — for source analysis)

- TUI framework imports: Ink, Blessed, OpenTUI, tui-rs, bubbletea, Ratatui, Textual, Rich
- Terminal rendering patterns: raw mode toggling, ANSI escape sequence generation, cursor positioning
- Solid.js/React rendering to terminal (non-browser JSX targets)
- PTY management: `node-pty`, `bun-pty`, pseudoterminal handling
- Terminal detection: `process.stdout.isTTY`, `isatty()`, terminal dimension queries

---

## Module Metadata

- **Axis**: Interface
- **Common pairings**: —
- **Profiles**: —
