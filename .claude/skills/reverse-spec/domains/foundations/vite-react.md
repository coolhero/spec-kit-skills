# Vite + React Foundation

## F0. Detection Signals

- `vite` in package.json `dependencies` or `devDependencies`
- `react` and `react-dom` in package.json `dependencies`
- No `next` in dependencies (distinguishes from Next.js)
- `vite.config.ts` or `vite.config.js` present
- `@vitejs/plugin-react` or `@vitejs/plugin-react-swc` in devDependencies

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | 4 | Vite version, React transform, build target, dev server |
| ROU | Routing | 3 | Router library, router type, SPA fallback |
| STM | State Management | 4 | Global state, server state, form handling, schema validation |
| STY | Styling | 5 | CSS strategy, Tailwind version, preprocessor, component library, SVG handling |
| SEC | Security | 2 | Authentication, analytics |
| ERR | Error Handling | 2 | Error boundary, error boundary library |
| LOG | Logging & Monitoring | 2 | Source maps, bundle size monitoring |
| ENV | Environment Config | 3 | Environment variables, dev proxy, path aliases |
| BLD | Build & Deploy | 3 | Code splitting, lazy loading, PWA |
| TST | Testing | 3 | Unit testing, component testing, E2E testing |
| DXP | Developer Experience | 7 | Linting, formatting, TypeScript strictness, API layer, date handling, i18n, pre-commit hooks |
| DTA | Data & Assets | 5 | Image optimization, asset handling, API layer, monorepo, service worker strategy |

---

## F2. Foundation Items

### BST: App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-BST-01 | Vite version | Vite major version to use | config | Critical |
| VR-BST-02 | React compiler / transform | Which React transform to use | choice (swc / babel) | Critical |
| VR-BST-03 | Build target | Browser targets for production build | config | Important |
| VR-BST-04 | Dev server port | Development server port and proxy configuration | config | Important |

### ROU: Routing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-ROU-01 | Routing library | Client-side routing library | choice (react-router / tanstack-router / wouter / custom) | Critical |
| VR-ROU-02 | Router type | Routing style within chosen library | choice (browser-router / hash-router / memory-router) | Important |
| VR-ROU-03 | SPA fallback | Configure server/hosting to serve index.html for all routes | binary | Important |

### STM: State Management

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-STM-01 | Global state management | Global state management approach | choice (zustand / jotai / redux-toolkit / mobx / context / valtio / none) | Critical |
| VR-STM-02 | Server state management | Data fetching and caching library | choice (tanstack-query / swr / rtk-query / custom / none) | Critical |
| VR-STM-03 | Form handling | Form management library | choice (react-hook-form / formik / tanstack-form / custom / none) | Important |
| VR-STM-04 | Schema validation | Runtime validation for forms and API responses | choice (zod / yup / valibot / none) | Important |

### STY: Styling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-STY-01 | CSS strategy | Styling approach | choice (css-modules / tailwind / styled-components / emotion / sass / vanilla-extract / stylex) | Critical |
| VR-STY-02 | Tailwind CSS version | If using Tailwind, version and config approach | choice (v3 / v4) | Important |
| VR-STY-03 | CSS preprocessor | Whether to use a CSS preprocessor | choice (sass / less / postcss-only / none) | Important |
| VR-STY-04 | Component library | UI component framework | choice (shadcn-ui / mui / chakra / mantine / ant-design / headless-ui / none) | Important |
| VR-STY-05 | SVG handling | How SVGs are imported and used | choice (svgr / url-import / inline / sprite) | Important |

### SEC: Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-SEC-01 | Authentication | Client-side auth token management strategy | choice (cookie / localstorage / memory / auth-provider) | Critical |
| VR-SEC-02 | Analytics | Analytics integration | choice (google-analytics / mixpanel / posthog / plausible / none) | Optional |

### ERR: Error Handling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-ERR-01 | Error boundary | Whether to implement React Error Boundaries | binary | Critical |
| VR-ERR-02 | Error boundary library | Error boundary implementation | choice (react-error-boundary / custom) | Important |

### LOG: Logging & Monitoring

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-LOG-01 | Source maps | Whether to generate source maps for production | binary | Important |
| VR-LOG-02 | Bundle size monitoring | Whether to monitor and limit bundle sizes | binary | Important |

### ENV: Environment Config

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-ENV-01 | Environment variables | Env var strategy using `.env.*` files and `VITE_` prefix | config | Critical |
| VR-ENV-02 | Dev server proxy | Proxy configuration for API requests during development | config | Important |
| VR-ENV-03 | Path aliases | Import path alias configuration (e.g., `@/` -> `src/`) | config | Important |

### BLD: Build & Deploy

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-BLD-01 | Code splitting strategy | How to split bundles | choice (auto / manual-chunks / vendor-split / route-based) | Important |
| VR-BLD-02 | Lazy loading | Whether to use React.lazy + Suspense for route-level splitting | binary | Important |
| VR-BLD-03 | PWA configuration | Whether to make the app a Progressive Web App | binary | Optional |

### TST: Testing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-TST-01 | Unit testing | Unit and component testing framework | choice (vitest / jest) | Important |
| VR-TST-02 | Component testing | Component testing library | choice (testing-library / enzyme / none) | Important |
| VR-TST-03 | E2E testing | End-to-end testing tool | choice (playwright / cypress / none) | Important |

### DXP: Developer Experience

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-DXP-01 | Linting | Linting configuration | choice (eslint / biome / oxlint) | Important |
| VR-DXP-02 | Formatting | Code formatting tool | choice (prettier / biome / dprint) | Important |
| VR-DXP-03 | TypeScript strictness | TypeScript configuration strictness level | choice (strict / normal / lenient) | Important |
| VR-DXP-04 | API layer | How API calls are structured | choice (axios / fetch / ky / openapi-codegen / graphql / custom) | Important |
| VR-DXP-05 | Date handling | Date utility library | choice (date-fns / dayjs / luxon / temporal / none) | Optional |
| VR-DXP-06 | i18n | Internationalization library | choice (react-i18next / formatjs / lingui / none) | Optional |
| VR-DXP-07 | Pre-commit hooks | Whether to use pre-commit hooks (husky + lint-staged) | binary | Optional |

### DTA: Data & Assets

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| VR-DTA-01 | Image optimization | Image optimization strategy | choice (vite-imagetools / sharp / cdn / none) | Important |
| VR-DTA-02 | Asset handling | Strategy for static assets (public dir, import, URL) | config | Important |
| VR-DTA-03 | PWA plugin | PWA implementation | choice (vite-plugin-pwa / custom / workbox) | Optional |
| VR-DTA-04 | Service worker strategy | Caching strategy for offline support | choice (cache-first / network-first / stale-while-revalidate) | Optional |
| VR-DTA-05 | Monorepo support | Whether the project is part of a monorepo | binary | Optional |

---

## F3. Extraction Rules (reverse-spec)

| Category | Extraction Method |
|----------|------------------|
| BST | Read `vite.config.*` for plugin selection (SWC vs Babel). Check `build.target` in Vite config. Read `server.port` and `server.proxy` config. |
| ROU | Search for `react-router-dom`, `@tanstack/router`, or `wouter` in dependencies. Check for `BrowserRouter`, `HashRouter` usage. Look for SPA fallback config in deployment files. |
| STM | Search for `zustand`, `jotai`, `@reduxjs/toolkit`, `@tanstack/react-query`, `swr` in dependencies. Look for form library imports. Check for zod/yup validation schemas. |
| STY | Check for `tailwind.config.*`, CSS module files (`.module.css`), styled-components/emotion imports. Look for component library packages (shadcn, MUI, etc.). Check for SVGR plugin in Vite config. |
| SEC | Search for auth token storage patterns (localStorage, cookies, context). Look for auth provider components. Check for analytics script tags or imports. |
| ERR | Search for `ErrorBoundary` components or `react-error-boundary` imports. Check for fallback UI components. |
| LOG | Check `vite.config.*` for `build.sourcemap` setting. Look for bundle analyzer plugins. |
| ENV | Read `.env*` files for `VITE_` prefixed variables. Check `vite.config.*` for `server.proxy` and `resolve.alias` config. |
| BLD | Check `vite.config.*` for `build.rollupOptions.output.manualChunks`. Search for `React.lazy()` usage. Look for PWA plugin configuration. |
| TST | Read test configuration (vitest.config, jest.config). Check for testing-library or Playwright in devDependencies. |
| DXP | Check for ESLint/Biome config files. Read `tsconfig.json` for strict mode. Search for axios/fetch wrapper modules. Check for husky config. |
| DTA | Look for `vite-imagetools` or image CDN config. Check public directory structure. Look for service worker files. Check for workspace configuration (pnpm-workspace.yaml, etc.). |

---

## F4. T0 Feature Grouping

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-app-bootstrap-env | BST + ENV | 7 |
| F000-routing-state | ROU + STM | 7 |
| F000-styling | STY | 5 |
| F000-security-error | SEC + ERR | 4 |
| F000-build-deploy | BLD + DTA | 8 |
| F000-testing-devexp | TST + DXP + LOG | 12 |
