# Foundation: Remix

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `@remix-run/react` or `@remix-run/node` in package.json deps
- `remix.config.js` or Remix Vite plugin in `vite.config.ts`

## Architecture Notes (for SBI extraction)
- **Routing**: File-based nested routes, `Outlet` for child routes
- **Data flow**: `loader` (GET data), `action` (mutations), `useLoaderData`/`useActionData`
- **Forms**: `<Form>` component for progressive enhancement (works without JS)
- **Streaming**: `defer` + `Await` for streamed responses
- **Error handling**: `ErrorBoundary` per route, `CatchBoundary`
- **Philosophy**: Use the Web Platform, Progressive Enhancement, Server-First Data
