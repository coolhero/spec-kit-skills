# Foundation: Solid.js
<!-- Format: _foundation-core.md | ID prefix: SO (see § F4) -->

> Frontend framework Foundation for projects using Solid.js.
> Covers Solid.js-specific patterns that differ from React.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `solid-js` in package.json dependencies | HIGH |
| `createSignal`, `createEffect` imports from `solid-js` | HIGH |
| `solid-start` in dependencies | HIGH |
| `.tsx` files with `createSignal()` (not `useState()`) | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | Entry point, render target (browser DOM / terminal / custom), hydration |
| RCT | Reactivity | Signal/memo/effect system, store management, context |
| CMP | Components | Component patterns, props, children, ref forwarding |
| STY | Styling | CSS strategy, CSS-in-JS, Tailwind, component library |
| ROU | Routing | SolidStart vs @solidjs/router, file-based vs config-based |
| BLD | Build & Bundle | Vite plugin, custom Babel transform, tree shaking |
| TST | Testing | solid-testing-library, test utilities, render testing |
| DXP | Developer Experience | DevTools, hot reload, TypeScript integration |

---

## F2. Decision Items

### RCT — Reactivity
| ID | Item | Priority | Question |
|----|------|----------|----------|
| RCT-01 | State management | Critical | Signals + Context vs Solid Store vs external (e.g., Zustand adapter)? |
| RCT-02 | Derived state | Important | `createMemo` vs inline computation? Granularity guidelines? |
| RCT-03 | Side effects | Important | `createEffect` cleanup patterns? onCleanup registration? |
| RCT-04 | Batch updates | Optional | `batch()` for grouped signal updates? |

### CMP — Components
| ID | Item | Priority | Question |
|----|------|----------|----------|
| CMP-01 | Component convention | Critical | Function components (only option in Solid) — naming, file organization? |
| CMP-02 | Props pattern | Important | Destructuring props (loses reactivity!) vs `props.x` access? `splitProps()`? `mergeProps()`? |
| CMP-03 | Children handling | Important | `props.children` vs `children()` helper for reactive children? |
| CMP-04 | Ref forwarding | Optional | `ref` prop pattern? |

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| BST-01 | Render target | Critical | Browser DOM (`render()`) vs Terminal (OpenTUI) vs Custom renderer? |
| BST-02 | SSR/Hydration | Important | SolidStart SSR? Client-only? Hydration strategy? |
| BST-03 | Entry point | Important | `index.tsx` → `render()` vs SolidStart `entry-server`/`entry-client`? |

### STY — Styling
| ID | Item | Priority | Question |
|----|------|----------|----------|
| STY-01 | CSS strategy | Important | Tailwind? CSS Modules? vanilla-extract? Styled components? |
| STY-02 | Component library | Optional | Solid-specific UI library? Kobalte? Ark UI? |

### BLD — Build & Bundle
| ID | Item | Priority | Question |
|----|------|----------|----------|
| BLD-01 | Bundler | Critical | Vite (default) vs custom? SolidStart? |
| BLD-02 | Babel transform | Important | `babel-preset-solid` for JSX transform (required) |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| TST-01 | Test library | Important | `@solidjs/testing-library`? Direct render testing? |
| TST-02 | Signal testing | Important | How to test reactive state? `createRoot()` wrapping? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Fine-Grained Reactivity** | Solid tracks dependencies at the signal level, not component level — no re-renders, only targeted DOM updates | Don't think in "component re-renders" — think in "which signal changed, which DOM node updates" |
| **No Virtual DOM** | Solid compiles JSX to real DOM operations — there is no diffing step | Performance patterns differ from React — fewer memoization needs, but destructuring props breaks reactivity |
| **Compile-Time Optimization** | Solid's Babel transform optimizes reactive expressions at build time | JSX must go through babel-preset-solid — raw JSX won't work |
| **Props Are Proxies** | Props object is a proxy — destructuring loses reactivity. Use `props.x` or `splitProps()` | This is the #1 migration trap from React. Flag any destructured props access |

---

## F9. Scan Targets

#### Component Patterns
| Pattern | Description |
|---------|-------------|
| `createSignal()` | Reactive state primitive |
| `createEffect()` | Side effect with automatic dependency tracking |
| `createMemo()` | Derived/computed value |
| `createStore()` | Nested reactive state |
| `createResource()` | Async data fetching with Suspense |
| `<Show>`, `<For>`, `<Switch>/<Match>` | Solid control flow components |
