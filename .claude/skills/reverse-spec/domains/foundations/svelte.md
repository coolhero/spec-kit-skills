# Foundation: Svelte

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `.svelte` files in source directories
- `svelte.config.js` or `svelte.config.ts`
- Dependencies: `svelte`, `@sveltejs/kit`, `@sveltejs/vite-plugin-svelte`
- Keywords in code: `$:` (reactive), `{#if}`, `{#each}`, `<script>`, `$state`, `$derived`

## Architecture Notes (for SBI extraction)
- **Components**: `.svelte` files — template + script + style in one file
- **Reactivity**: `$:` declarations (Svelte 4), `$state`/`$derived` runes (Svelte 5)
- **Stores**: `writable()`, `readable()`, `derived()` — shared state management
- **SvelteKit**: File-based routing (`+page.svelte`, `+layout.svelte`, `+server.ts`)
- **No Virtual DOM**: Compiles to imperative DOM updates — trace compilation output for behavior verification
