# Archetype: browser-extension

> Browser extensions and add-ons — Chrome, Firefox, Safari, Edge extensions with multi-context architecture.
> Module type: archetype

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/browser-extension.md`](../../../shared/domains/archetypes/browser-extension.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Minimal Permissions** | Request only permissions actually needed. Prefer `activeTab` over broad host permissions. Optional permissions for non-core features. | Every Feature must justify its permissions in the spec. Plan must flag permission escalations. Verify checks manifest permissions against actual usage. |
| **Content Script Isolation** | Content scripts run in an isolated world. Communication with the page requires explicit message passing. Never trust page-injected data. | SCs must specify message passing direction (content→background, background→content) and data validation at each boundary. |
| **Background Lifecycle Awareness** | MV3 service workers are ephemeral — terminated at any time. All state must be persisted to storage, not held in memory. | Every Feature touching background must handle service worker termination. No in-memory state assumed to persist across events. |
| **Storage-First State** | Extension state lives in `chrome.storage`, not in-memory variables. Every state change is persisted before acknowledging success. | SCs must specify storage key, sync vs local, and persistence timing. Verify checks no state is memory-only. |
| **Cross-Browser Compatibility** | Use WebExtension APIs (`browser.*`) where possible. Abstract browser-specific APIs behind a compatibility layer. | Plan must identify browser-specific code paths. Verify tests in target browsers or polyfill coverage confirmed. |

---

## A2. SC Generation Extensions

### Required SC Patterns (append to S1)
- **Permission justification**: SC specifies which permissions are needed and why — no blanket `<all_urls>`
- **Message passing contract**: SC specifies message type, payload schema, sender context (content/background/popup), and response format
- **Storage schema**: SC specifies storage keys, data shapes, and sync vs local vs session storage choice
- **Service worker resilience**: SC specifies how the feature survives service worker restart (state recovery from storage)

### SC Anti-Patterns (reject)
- "Extension communicates with page" — must specify message passing direction, data validation, and trust boundary
- "State is saved" — must specify storage type (sync/local/session), key schema, and migration strategy
- "Background handles request" — must specify service worker lifecycle awareness and state recovery on restart

---

## A3. Elaboration Probes (append to S5)

| Sub-domain | Probe Questions |
|------------|----------------|
| **Manifest version** | MV2 or MV3? Migration planned? Which browsers must be supported? |
| **Contexts** | Which contexts are used? (background, content script, popup, options, devtools, side panel) |
| **Permissions** | Which permissions are required? Optional permissions? Host permissions scope? |
| **Storage** | What data is persisted? sync vs local? Migration strategy for schema changes? |
| **Communication** | Message passing patterns? Port-based long-lived connections? External messaging? |
| **Content script injection** | Programmatic or declarative? Which pages? DOM mutation handling? |

---

## A4. Constitution Injection

| Principle | Rationale |
|-----------|-----------|
| Request minimal permissions — prefer `activeTab` and optional permissions over broad host permissions | Excessive permissions trigger user distrust and store review friction; principle of least privilege |
| All state must be persisted to `chrome.storage` before acknowledging success — no memory-only state | MV3 service workers are terminated unpredictably; memory state is lost on every restart |
| Content scripts must validate all data received from page context — treat page DOM as untrusted input | Malicious pages can inject data into content script message handlers; input validation prevents XSS/injection |
| Message passing between contexts must use typed message contracts with explicit sender/receiver | Untyped messages create hidden coupling; typed contracts catch breaking changes at development time |
| Cross-browser compatibility via WebExtension API abstraction — browser-specific code behind adapter layer | Single codebase targeting multiple browsers reduces maintenance burden and prevents vendor lock-in |

---

## A5. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Manifest version | MV2 or MV3 stated; target browsers listed |
| Extension contexts | Which contexts (background, content, popup, etc.) are used and why |
| Permission model | Required vs optional permissions justified |
| Storage strategy | What data is stored, where (sync/local/session), and schema |
