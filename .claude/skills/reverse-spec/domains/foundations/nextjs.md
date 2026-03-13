# Next.js Foundation

## F0. Detection Signals

- `next` in package.json `dependencies`
- `next.config.js`, `next.config.mjs`, or `next.config.ts` present
- `app/` directory (App Router) or `pages/` directory (Pages Router)
- `.next/` build output directory
- `@next/` scoped packages in dependencies

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| REN | Rendering Strategy | 5 | Router type, default rendering, ISR, output mode, Edge Runtime |
| ROU | Routing | 5 | API routes, middleware, parallel routes, intercepting routes, route groups |
| STM | State Management | 3 | Data fetching, caching strategy, cache handler |
| STY | Styling | 2 | CSS strategy, component library |
| SEO | SEO & Metadata | 4 | Metadata strategy, OG images, sitemap, robots.txt |
| SEC | Security | 4 | Auth pattern, auth middleware, security headers, CSP |
| BST | App Bootstrap | 4 | Server Actions, loading states, layout system, custom server |
| ERR | Error Handling | 1 | Error boundary strategy |
| LOG | Logging & Monitoring | 2 | Instrumentation, bundle analyzer |
| ENV | Environment Config | 4 | Environment variables, rewrite rules, redirect rules, deployment target |
| BLD | Build & Deploy | 2 | Turbopack, output mode |
| TST | Testing | 1 | Testing setup |
| DXP | Developer Experience | 7 | Image optimization, font optimization, font provider, i18n, i18n library, state management, content layer |

---

## F2. Foundation Items

### REN: Rendering Strategy

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-REN-01 | Router type | App Router (recommended) or Pages Router | choice (app-router / pages-router / hybrid) | Critical |
| NX-REN-02 | Rendering strategy (default) | Default rendering approach per route | choice (SSR / SSG / ISR / CSR / mixed) | Critical |
| NX-REN-03 | ISR revalidation interval | Default revalidation time in seconds for ISR | config | Important |
| NX-REN-04 | Edge Runtime | Whether to use Edge Runtime for specific routes/middleware | binary | Important |
| NX-REN-05 | Edge vs Node per route | Which routes use Edge vs Node.js runtime | config | Optional |

### ROU: Routing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-ROU-01 | API routes structure | How API routes are organized (Route Handlers vs API routes) | config | Critical |
| NX-ROU-02 | Middleware | Whether to use Edge Middleware for request interception | binary | Important |
| NX-ROU-03 | Middleware scope | Which routes the middleware applies to (matcher pattern) | config | Important |
| NX-ROU-04 | Parallel routes | Whether to use parallel routes (@folder) for complex layouts | binary | Optional |
| NX-ROU-05 | Intercepting routes | Whether to use intercepting routes for modals | binary | Optional |

### STM: State Management

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-STM-01 | Data fetching strategy | Primary data fetching pattern | choice (server-fetch / swr / react-query / trpc / mixed) | Critical |
| NX-STM-02 | Caching strategy | Next.js caching behavior (full route, data cache, router cache) | config | Important |
| NX-STM-03 | Cache handler | Custom cache handler for production | choice (in-memory / redis / custom / default) | Important |

### STY: Styling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-STY-01 | CSS strategy | Styling approach | choice (css-modules / tailwind / styled-components / emotion / sass / vanilla-extract) | Critical |
| NX-STY-02 | Component library | UI component library | choice (shadcn-ui / mui / chakra / mantine / radix / none) | Important |

### SEO: SEO & Metadata

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-SEO-01 | Metadata / SEO strategy | Strategy for page metadata | choice (static / dynamic / mixed) | Important |
| NX-SEO-02 | Open Graph / social cards | Whether to generate OG images and social cards | binary | Important |
| NX-SEO-03 | Sitemap generation | Whether to auto-generate sitemap.xml | binary | Important |
| NX-SEO-04 | robots.txt | Whether to configure robots.txt via metadata API | binary | Important |

### SEC: Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-SEC-01 | Authentication pattern | Auth strategy for protecting pages and API routes | choice (next-auth / clerk / custom-jwt / session / iron-session / none) | Critical |
| NX-SEC-02 | Auth middleware integration | How auth state is checked in middleware for route protection | config | Important |
| NX-SEC-03 | Security headers | Custom security headers in next.config.js (CSP, HSTS) | config | Important |
| NX-SEC-04 | Content Security Policy | CSP header configuration | config | Important |

### BST: App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-BST-01 | Server Actions | Whether to use React Server Actions for mutations | binary | Critical |
| NX-BST-02 | Loading states | Whether to use loading.tsx for automatic loading UI | binary | Important |
| NX-BST-03 | Layout system | Root layout and nested layout architecture | config | Important |
| NX-BST-04 | Custom server | Whether to use a custom Node.js server | binary | Important |

### ERR: Error Handling

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-ERR-01 | Error boundary strategy | How to handle errors (error.tsx, global-error.tsx, custom pages) | config | Critical |

### LOG: Logging & Monitoring

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-LOG-01 | Instrumentation | Whether to use instrumentation.ts for monitoring/tracing | binary | Important |
| NX-LOG-02 | Bundle analyzer | Whether to use @next/bundle-analyzer | binary | Optional |

### ENV: Environment Config

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-ENV-01 | Environment variables | Env var strategy (build-time vs runtime, NEXT_PUBLIC_ prefix) | config | Critical |
| NX-ENV-02 | Rewrite rules | URL rewrite rules in next.config.js | config | Important |
| NX-ENV-03 | Redirect rules | URL redirect rules in next.config.js | config | Important |
| NX-ENV-04 | Deployment target | Where the app will be deployed | choice (vercel / self-hosted-node / docker / static-export / aws / cloudflare) | Important |

### BLD: Build & Deploy

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-BLD-01 | Turbopack | Whether to use Turbopack for dev builds | binary | Optional |
| NX-BLD-02 | Output mode | Next.js output configuration | choice (standalone / export / default) | Important |

### TST: Testing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-TST-01 | Testing setup | Testing framework | choice (jest / vitest / playwright / cypress / combination) | Important |

### DXP: Developer Experience

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| NX-DXP-01 | Image optimization | next/image configuration (loader, domains, remote patterns, formats) | config | Important |
| NX-DXP-02 | Font optimization | Whether to use next/font for self-hosted fonts | binary | Important |
| NX-DXP-03 | Font provider | Font source | choice (google / local / custom) | Important |
| NX-DXP-04 | i18n / internationalization | Whether to support multiple languages and routing strategy | choice (subpath / domain / middleware-based / none) | Important |
| NX-DXP-05 | i18n library | Internationalization library | choice (next-intl / react-i18next / next-i18n-router / built-in) | Important |
| NX-DXP-06 | Client state management | Client-side state management | choice (zustand / jotai / redux / context / none) | Important |
| NX-DXP-07 | Content layer | How content is managed | choice (headless-cms / mdx / file-based / database) | Important |

---

## F3. Extraction Rules (reverse-spec)

| Category | Extraction Method |
|----------|------------------|
| REN | Check for `app/` directory (App Router) vs `pages/` (Pages Router). Read `next.config.*` for output mode. Search for `revalidate` exports in page files. Check for `runtime = 'edge'` exports. |
| ROU | Check `app/api/` for Route Handlers or `pages/api/` for API routes. Look for `middleware.ts` file. Search for `@` prefixed folders (parallel routes) and `(..)` patterns (intercepting routes). |
| STM | Search for `fetch()` in Server Components, SWR/React Query imports. Read `next.config.*` for cache configuration. |
| STY | Check for CSS modules (`.module.css`), Tailwind (`tailwind.config.*`), styled-components, or Emotion imports. Check `next.config.*` for compiler options. |
| SEO | Look for `metadata` exports or `generateMetadata` functions. Check for `sitemap.ts`, `robots.ts` files. Search for OG image generation. |
| SEC | Search for next-auth, clerk, or custom auth imports. Read `middleware.ts` for auth checks. Check `next.config.*` headers for CSP/HSTS. |
| BST | Search for `'use server'` directives (Server Actions). Check for `loading.tsx` files. Read root `layout.tsx`. |
| ERR | Check for `error.tsx`, `global-error.tsx`, `not-found.tsx` files in app directory. |
| LOG | Check for `instrumentation.ts` in project root. Search for @next/bundle-analyzer in dependencies. |
| ENV | Read `.env*` files for NEXT_PUBLIC_ prefix usage. Check `next.config.*` for rewrites, redirects. |
| BLD | Check `package.json` scripts for `--turbo` flag. Read `next.config.*` output field. |
| TST | Read test configuration files. Check for testing libraries in devDependencies. |
| DXP | Check for `next/image`, `next/font` usage. Search for i18n configuration. Check for state management imports. |

---

## F4. T0 Feature Grouping

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-rendering-routing | REN + ROU | 10 |
| F000-security-bootstrap | SEC + BST | 8 |
| F000-state-data | STM + DXP(state) | 4 |
| F000-styling-seo | STY + SEO | 6 |
| F000-error-logging | ERR + LOG | 3 |
| F000-env-build | ENV + BLD | 6 |
| F000-testing-devexp | TST + DXP(rest) | 7 |
