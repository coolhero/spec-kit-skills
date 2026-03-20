# Foundation: Nuxt

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `nuxt` in package.json dependencies
- `nuxt.config.ts` or `nuxt.config.js` in root
- `pages/` + `server/` directory structure

## Architecture Notes (for SBI extraction)
- **Vue 3**: Composition API (`setup()`, `<script setup>`), reactivity (`ref`, `computed`)
- **Routing**: File-based (`pages/` directory), dynamic routes (`[id].vue`)
- **Server**: Nitro engine, `server/api/` for API routes, `defineEventHandler`
- **Data fetching**: `useFetch`, `useAsyncData`, `$fetch`
- **Auto-imports**: components, composables, utils auto-imported
- **Modules**: Nuxt module ecosystem (`modules/` directory, `nuxt.config` modules array)
- **Rendering**: SSR (default), SSG (`nuxt generate`), SPA mode, hybrid per-route
