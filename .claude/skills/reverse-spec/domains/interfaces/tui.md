# Interface: tui (reverse-spec)

> Terminal UI analysis axes. Loaded when project renders interactive terminal interfaces (not browser GUI).
> Module type: interface (reverse-spec analysis)

---

## R1. Detection Signals

> See [`shared/domains/interfaces/tui.md`](../../../shared/domains/interfaces/tui.md) § Code Patterns

## R3. Analysis Axes — TUI Component Extraction

For each TUI component/view, extract:
- Component name and purpose
- Input handling (keyboard shortcuts, mouse events, focus management)
- Layout behavior (flex, grid, absolute positioning within terminal)
- Color/theme handling (ANSI colors, 256-color, truecolor, dark/light detection)
- Responsive behavior (terminal resize handling)
- State management (reactive signals, stores)

Detection patterns by framework:

| Technology | Search Targets |
|------------|----------------|
| Ink (React) | `<Box>`, `<Text>`, `useInput()`, `useApp()`, `render()` |
| Blessed | `blessed.screen()`, `blessed.box()`, key binding handlers |
| OpenTUI (Solid.js) | Solid.js components with terminal render targets, `createSignal()` for TUI state |
| bubbletea (Go) | `tea.Model` interface, `Init()`, `Update()`, `View()` methods |
| Ratatui (Rust) | `Frame::render_widget()`, `Layout::default()`, terminal backend setup |
| Textual (Python) | `class App(textual.app.App)`, `compose()`, CSS-like styling |

## R4. Analysis Axes — TUI Interaction Patterns

- Keyboard navigation: tab order, arrow key behavior, vim-like bindings
- Focus management: which component receives input, focus transitions
- Modal dialogs: overlay rendering, input capture during modal
- Command palette: fuzzy search, command registration, shortcut display
- Scrolling: virtual scrolling in lists, scroll indicators
- Clipboard: terminal clipboard access (OSC 52, pbcopy/xclip fallback)
- Terminal capabilities: graceful degradation when features unavailable (no mouse, no color, no unicode)
