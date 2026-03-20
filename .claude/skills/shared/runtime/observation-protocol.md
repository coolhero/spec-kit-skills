# Runtime Observation Protocol

> **Shared module** — structured observation framework for runtime exploration.
> Defines WHAT to observe, organized by Domain Profile axis.
> Used by: code-explore (orient), reverse-spec (Phase 1.5), smart-sdd (verify).

---

## 3-Layer Architecture

```
Layer 1: COMMON — every runtime session captures these (skill-agnostic)
Layer 2: DOMAIN-AWARE — observations guided by Domain Profile axes (skill-agnostic)
Layer 3: SKILL-SPECIFIC — additional observations per skill's purpose (skill-specific)
```

Layer 1 + 2 are defined here. Layer 3 is defined in each skill's command file.

---

## Layer 1: Common Observations (always captured)

Every runtime exploration session, regardless of skill, captures:

### 1a. Screen Inventory

Navigate all discoverable routes/views and record:

| Screen | Route/URL | Screenshot | Layout Pattern |
|--------|-----------|------------|---------------|
| [name] | [route] | [filename] | [e.g., 3-column, sidebar+main, fullscreen modal] |

**How to discover routes**: Check router config, navigation menus, sidebar links, tab bars.
Capture **every distinct screen** — not just the landing page.

### 1b. Accessibility Tree Snapshots

For each screen, capture the accessibility tree (Playwright `page.accessibility.snapshot()`).
This reveals the **actual UI component hierarchy** — what exists, what's interactive, what's hidden.

### 1c. Console Output

Record all console messages during exploration:
- Errors (red) — potential bugs or missing config
- Warnings (yellow) — deprecated APIs, missing keys
- Info (blue) — helpful for understanding data flow

### 1d. Basic Interaction Test

For each screen, try:
- Click all visible buttons → note which ones are interactive vs decorative
- Open all menus/dropdowns → note options available
- Check for modals/dialogs → note trigger and content
- Check empty states → note placeholder text and CTAs

---

## Layer 2: Domain-Aware Observations

Based on the detected Domain Profile (from orient Step 3 or sdd-state.md), observe axis-specific patterns. **Only observe axes that are active** — skip irrelevant axes.

### Axis 1: Interface Observations

#### If `gui` is active:

| Observation | What to check | Record as |
|------------|---------------|-----------|
| **Layout structure** | How many columns/panels? Responsive? | `layout: 3-column (sidebar, main, controls)` |
| **Navigation pattern** | Tab bar? Sidebar? Top nav? Breadcrumbs? | `nav: top-tab-bar (7 tabs)` |
| **Component library** | Ant Design? Material? shadcn? Custom? | `ui-lib: Ant Design (detected from class names)` |
| **Theme system** | Light/dark toggle? CSS variables? | `theme: light+dark, 141 CSS variables` |
| **Form patterns** | Input types — text, dropdown, slider, toggle, auto-fill | Per-form table (see below) |
| **Modal/dialog patterns** | How dialogs open, what controls they contain | `dialogs: [{trigger, fields, actions}]` |
| **Empty states** | What shows when data is missing | `empty: "No items yet" + CTA button` |
| **Error display** | Toast? Inline? Modal? Actionable? | `errors: toast, not actionable` |

**Form Field Inventory** (critical for rebuild):
For each form/dialog discovered, record:

| Form | Field | Control Type | Options/Validation | Auto-fill? |
|------|-------|-------------|-------------------|------------|
| Create KB | Name | TextInput | required | no |
| Create KB | Model | Dropdown | configured providers only | no |
| Create KB | Dimensions | NumberInput | readonly | yes (from model) |

#### If `http-api` is active:

| Observation | What to check | Record as |
|------------|---------------|-----------|
| **Endpoint discovery** | Swagger UI? /docs? /api? | `api-docs: /swagger available` |
| **Auth headers** | What auth does the API expect? | `auth: Bearer token in Authorization header` |
| **Response format** | JSON envelope? Pagination? Error format? | `response: {data, error, meta}` |
| **Health endpoint** | Does GET /health or /api/status exist? | `health: GET /health → 200` |

#### If `cli` is active:

| Observation | What to check | Record as |
|------------|---------------|-----------|
| **Help output** | `--help` flag output | `commands: [list]` |
| **Config file** | Where does it store config? | `config: ~/.config/[app]/config.json` |
| **Interactive mode** | Does it have a REPL or interactive prompts? | `interactive: yes (TUI with Bubble Tea)` |

### Axis 2: Concern Observations

For each active concern, check:

| Concern | Runtime observation | How to check |
|---------|-------------------|--------------|
| `auth` | Login screen exists? OAuth flow? Session persistence? | Navigate to login, check form fields, try auth flow |
| `async-state` | Loading spinners? Error recovery? Retry buttons? | Trigger slow operations, observe loading states |
| `realtime` | Live updates visible? WebSocket in Network tab? Streaming text? | Open chat/feed, watch for live content |
| `i18n` | Language switcher? RTL support? Missing translation keys? | Switch language if available, check console for missing keys |
| `external-sdk` | API key setup UI? Provider selection? | Check Settings for third-party integrations |
| `ipc` | Multi-window? Process communication visible? | Open DevTools, check IPC calls in console |
| `llm-agents` | Chat interface? Model selector? Token counter? | Send a message, observe response flow |

### Axis 3: Archetype Observations

| Archetype | Runtime observation |
|-----------|-------------------|
| `ai-assistant` | Streaming response display? Token usage display? Model switching? Multi-turn context? Citation/reference display? |
| `public-api` | API documentation UI? Rate limit headers? Versioning visible? |
| `microservice` | Service health dashboard? Inter-service communication visible? |
| `sdk-framework` | Extension/plugin management UI? Marketplace? API playground? |

### Axis 4: Foundation Observations

| Observation | How to detect at runtime |
|------------|------------------------|
| **Component library** | Inspect DOM class names (ant-, mui-, shadcn, etc.) |
| **CSS framework** | Check `<style>` tags or CSS files (Tailwind utilities, CSS modules, styled-components) |
| **State management** | Redux DevTools? Zustand stores in window? |
| **Routing** | Hash routing (#/) or path routing (/page)? SPA or MPA? |
| **Build system** | Check page source for build artifacts (vite, webpack, turbopack) |

### Scale Observations

| Observation | Implication |
|------------|-------------|
| **Error UX quality** | Generic "Error" vs actionable "API key not configured. Go to Settings > Provider" |
| **Empty state quality** | Blank page vs helpful "No items yet. Create your first [X]" with CTA |
| **Loading state quality** | No feedback vs spinner vs skeleton vs progress bar |
| **Onboarding flow** | Drops you in cold vs guided setup wizard |
| **Keyboard shortcuts** | None vs basic (Ctrl+S) vs comprehensive (vim-like) |

→ High quality across these = `production` maturity signal
→ Generic/missing = `prototype` or `mvp` signal

---

## Output Format

Runtime observations are recorded in a structured section that ALL downstream consumers can parse:

```markdown
## Runtime Observations

> Captured: [timestamp]
> Method: [Playwright CLI / MCP / Manual]
> Screens explored: [N]
> Screenshots: [path]

### Screen Inventory
| Screen | Route | Screenshot | Layout |
|--------|-------|------------|--------|
| ... | ... | ... | ... |

### Domain Profile Observations

#### Interface (Axis 1)
- Layout: [pattern]
- Navigation: [pattern]
- UI Library: [name]
- Theme: [details]
- Forms: [count] forms inventoried (see Form Field Inventory below)

#### Concerns (Axis 2)
- auth: [observed / not observed / N/A]
- realtime: [observed / not observed / N/A]
- i18n: [observed / not observed / N/A]
- ...

#### Archetype (Axis 3)
- [observations]

#### Foundation (Axis 4)
- Component library: [detected]
- CSS: [detected]
- State management: [detected]

#### Scale
- Error UX: [quality level]
- Empty states: [quality level]
- Onboarding: [exists / none]

### Form Field Inventory
| Form | Field | Control Type | Options | Auto-fill |
|------|-------|-------------|---------|-----------|
| ... | ... | ... | ... | ... |

### Console Summary
- Errors: [N] ([summary])
- Warnings: [N] ([summary])
```

---

## Skill-Specific Extensions (Layer 3)

Each skill adds its own observations on top of Layer 1 + 2:

### code-explore Layer 3
- **Data flow observation**: When tracing a specific flow, observe the UI state at each step
- **Cross-module observation**: How do different modules' UIs connect?
- Added in: `code-explore/commands/trace.md` § Step 2.5

### reverse-spec Layer 3
- **Form field precision**: Every form field with exact control type, validation, auto-fill behavior
- **Interaction patterns**: Drag-and-drop zones, keyboard shortcuts, context menus, tooltips
- **Data pipeline visibility**: How does data processing status display? Progress bars? Status badges?
- **CSS token extraction**: All CSS custom properties for theme reconstruction
- Added in: `reverse-spec/commands/analyze-runtime.md` § 1.5-5

### smart-sdd verify Layer 3
- **SC-specific verification**: For each SC, execute the planned test scenario and record result
- **Regression detection**: Compare current behavior against expected (from spec.md SC)
- **Wiring verification**: Verify IPC channels, store hydration, UI entry points are connected
- Added in: `smart-sdd/commands/verify-sc-verification.md` § Step 3

---

## Consumers — How Each Skill Uses Observations

| Skill | Consumes | Purpose |
|-------|----------|---------|
| **code-explore orient** | Writes Layer 1 + 2 to orientation.md | Module map enrichment, Domain Profile validation |
| **code-explore trace** | Reads orientation.md observations | Reference screenshots, cross-check code vs runtime |
| **code-explore synthesis** | Reads all observations | Feature candidates include UI patterns, Domain Profile derivation |
| **reverse-spec Phase 1.5** | Writes Layer 1 + 2 + Layer 3 (form fields, interactions) | Full UI inventory for spec-draft generation |
| **reverse-spec Phase 4** | Reads Phase 1.5 observations | spec-draft FR/SC include exact control types, auto-fill, error messages |
| **smart-sdd specify** | Reads pre-context (which includes runtime observations) | FR describes actual UI controls, not abstract "input" |
| **smart-sdd plan** | Reads pre-context | Interaction Chains include runtime-observed patterns |
| **smart-sdd implement** | Reads pre-context | Source-First Implementation follows observed patterns |
| **smart-sdd verify** | Executes Layer 1 + 2 + Layer 3 (SC verification) on TARGET app | SC pass/fail based on runtime evidence |

---

## Domain Profile Feedback Loop

Runtime observations can **update** the Domain Profile detected during static analysis:

```
Static analysis (orient Step 3):
  Detected: gui, async-state, ipc

Runtime observation (orient Step 1.5):
  New: realtime (streaming responses observed in chat)
  New: external-sdk (API key setup UI in Settings)
  Confirm: auth (login screen exists)
  Update: Scale = production (comprehensive error UX, onboarding flow)

Updated Domain Profile:
  Interfaces: gui
  Concerns: async-state, ipc, realtime, external-sdk, auth (+ 3 from runtime)
  Scale: production (upgraded from mvp)
```

After runtime exploration, **update orientation.md § Detected Domain Profile** with runtime evidence. This ensures traces and synthesis use the most accurate profile.
