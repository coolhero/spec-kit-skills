## Phase 2 — Deep Analysis

> **Domain Profile**: Read `domains/_core.md` § R3 + active interface modules § R3 for the domain-specific extraction targets used throughout this Phase.

Perform deep analysis using patterns appropriate to the tech stack identified in Phase 1. For large codebases, leverage parallel sub-agents via the Task tool.

> **F9 Scan Target Loading**: If the active Foundation file(s) declare an `### F9. Scan Targets` section (see `domains/foundations/_foundation-core.md` § F9), load those scan targets and MERGE them with the universal scan targets from `_core.md`. F9 targets supplement — not replace — universal targets. This ensures framework-specific patterns (e.g., Drizzle ORM `table()` for Bun, `createSignal()` for Solid.js, Hono route handlers) are included in Phase 2-1 (Data Model), 2-2 (API Endpoint), and 2-6 (SBI) extraction without modifying `_core.md`.

> **Phase 1.5 Completeness Gate (rebuild mode)**: Before starting Phase 2, verify that Phase 1.5 produced UI Flow Specs. Check if `specs/_global/runtime-exploration.md` contains at least one `### Flow:` section. If absent AND mode is rebuild → 🚫 **BLOCKING**: "Phase 1.5 Runtime Exploration did not produce UI Flow Specs. Return to Phase 1.5 or acknowledge limited spec quality."
>
> **Phase 1.5 Cross-Reference**: If `specs/_global/runtime-exploration.md` exists, read the file and use the observations to enrich analysis:
> - Validate route definitions against actually observed screens (Screen Inventory)
> - Enrich entity extraction with observed data display patterns — tables, forms, card views (UI Patterns)
> - Cross-reference API endpoints with observed user interactions (User Flows Observed)
> - Note discrepancies between code structure and runtime behavior — e.g., routes defined in code but not reachable in UI (Screen Inventory vs code routes)

### 2-1. Data Model Extraction
Extract entities from appropriate sources depending on the tech stack identified in Phase 1. See `domains/_core.md` § R3 (Data Model Extraction) for the technology-to-search-target mapping and extraction details.

### 2-2. API Endpoint Extraction
Extract APIs from appropriate sources depending on the tech stack identified in Phase 1. See `domains/interfaces/http-api.md` § R3 (API Endpoint Extraction) for the technology-to-search-target mapping and extraction details. Note: only applies when http-api interface is active.

### 2-3. Business Logic Extraction
Extract business rules, validation, workflows, and external integrations from the service layer and domain logic. See `domains/_core.md` § R3 (Business Logic Extraction) for extraction categories.

### 2-4. Inter-Module Dependency Mapping
Analyze import/require statements, service call relationships, shared utilities, and event-based coupling. See `domains/_core.md` § R3 (Inter-Module Dependency Mapping) for details.

### 2-5. Environment Variable Extraction
Scan the codebase for environment variable usage to identify runtime configuration requirements. See `domains/_core.md` § R3 (Environment Variable Extraction) for the technology-to-search-pattern mapping and per-variable extraction details.

⚠️ NEVER read or record actual secret values from `.env` files. Only read `.env.example` or detect variable names from code patterns.

### 2-6. Source Behavior Inventory

For each source file identified in Phase 1, extract a **function-level inventory** of exported/public behaviors (P1 core / P2 important / P3 nice-to-have). This captures discrete units of functionality that structural extraction (entities, APIs) may miss. See `domains/_core.md` § R3 (Source Behavior Inventory) for extraction targets, priority classification, and scan patterns.

- Group by Feature association (determined in Phase 3 when Feature boundaries are identified)
- Skip internal/private helpers that are implementation details, not behaviors

#### Infrastructure-as-Product SBI Rule

When the project's core product IS infrastructure management (detected by: Archetype signals for VM/container/sandbox lifecycle, Dockerfile as product output rather than deployment):

- Container/VM/sandbox **lifecycle methods** (create, start, stop, destroy, snapshot) → **P1** (core product behavior, not infrastructure)
- Resource allocation/deallocation (memory, CPU, network) → **P1** (performance-critical product behavior)
- Health checks, monitoring hooks → **P2**
- Deployment/packaging of the infrastructure tool itself → **P3** (meta-infrastructure)

Detection signal: if `Dockerfile` or `docker-compose.yml` exists AND the project's main module CREATES/MANAGES containers (not just runs inside one), classify as infrastructure-as-product.

- WRONG: microVM create/destroy classified as P3 "infrastructure" → core product behavior undocumented
- RIGHT: microVM lifecycle classified as P1 → documented as core Feature requirements

#### Multi-Language SBI Extraction

When Language Composition Analysis (Phase 1-2a) detected multiple languages with ≥5% presence:

1. **Load language-specific scan patterns** for each qualifying language:
   | Language | Function Pattern | Export/Public Marker |
   |----------|-----------------|---------------------|
   | Python | `def`, `async def`, `class` methods | Module-level functions, `__all__` exports |
   | JavaScript/TypeScript | `function`, `export`, `class` methods | `export`, `module.exports` |
   | C/C++ | Function definitions, class methods | Header declarations, `extern "C"`, `__attribute__((visibility))` |
   | CUDA | `__global__`, `__device__`, `__host__` functions | Kernel launch wrappers |
   | Go | `func` declarations | Capitalized names (exported) |
   | Rust | `fn` declarations | `pub fn`, `pub struct` |
   | Java | Method declarations, `@Bean` factory methods | `public`, `protected`, Spring stereotype annotations (`@Service`, `@Repository`, `@Controller`) |
   | Kotlin | `fun`/`suspend fun` declarations, `data class`, `object`/`companion object` | `public` (default), Spring stereotypes. Note: `suspend fun` = coroutine, `sealed class` = state machine, `Flow<T>` = reactive stream |
   | Swift | `func`/`static func`/`init()` declarations, `class`/`struct`/`enum`/`protocol`/`extension` | `public`/`open` access (default `internal`); `@objc` = ObjC-interop |
   | Objective-C | `-`/`+` method declarations in `@interface`/`@implementation` | Header file (`.h`) declarations = public API; categories = extensions |
   | Dart | `class` + method declarations, top-level functions | No `_` prefix = public; `_` prefix = private; `Widget build()` = UI component |
   | PHP | `function`/`class` method declarations | `public`/`protected`/`private` visibility; namespace declarations |
   | Ruby | `def` method, `class`/`module` definitions | `public` section (above `private`/`protected` keywords); `include`/`extend` |
   | C# | Method declarations, `async Task`, `class`/`struct`/`interface`/`record` | `public`/`internal`/`protected`; Unity: `MonoBehaviour` lifecycle methods |
   | Erlang | `-module`, `-export` functions, `-callback` behaviors | `-export([func/arity])` list; GenServer: `handle_call/3`, `handle_cast/2` |
   | Elixir | `def`/`defp`, `defmodule` declarations | `def` (public), `defp` (private); `@callback`, `use GenServer` |
   | Scala | `def`, `val`, `object`/`class`/`trait` declarations | Public by default; `private`/`protected` modifiers; `case class`, `sealed trait` |
   | GDScript | `func` declarations, `signal` definitions | `class_name`, `export var`, `extends` (public by default; `_` prefix = private) |
   | Clojure | `defn`, `defmethod`, `defprotocol`, `defrecord` | Namespace-level public functions (no `-` prefix = public) |
   | HCL | `resource`, `data`, `variable`, `output`, `module`, `provider` blocks | Top-level block declarations |

#### Spring/Java Enterprise SBI Extension (when Foundation = Spring Boot or Spring Framework)

When the detected Foundation includes Spring Boot or Spring Framework, apply these additional SBI extraction rules alongside standard Java/Kotlin method scanning:

**1. Annotation-Driven Bean Discovery**:
Spring applications are assembled via annotation scanning, not just method visibility. Identify behavioral units by these stereotype annotations:
- `@Service` — business logic beans (P1: core domain behavior)
- `@Repository` — data access beans (P1: data persistence)
- `@Controller` / `@RestController` — request handler beans (P1: API surface)
- `@Component` — general-purpose beans (P2 unless used as infrastructure)
- `@Configuration` + `@Bean` methods — infrastructure/wiring (P2-P3 depending on what they create)
- `@Conditional*` — profile/condition-activated beans (note activation condition in SBI Notes column)

For each Spring bean class, the SBI entry should be the **class** (not individual methods), with its stereotype and key public methods listed in Notes.

**2. AOP/Proxy-Based Cross-Cutting Behaviors**:
Spring AOP annotations add invisible runtime behavior through proxies. When these annotations appear on a method, record the proxy behavior as part of the SBI entry's Notes:
- `@Transactional` → "TX boundary: commits on success, rolls back on exception [isolation level if specified]"
- `@Cacheable` / `@CacheEvict` → "Cache: reads/writes cache [cache name] with key [key expression]"
- `@Async` → "Runs in thread pool [executor name if specified]"
- `@Retryable` → "Retries [N] times on [exception types]"
- `@Scheduled` → "Scheduled: [cron/fixedRate expression]"
- `@PreAuthorize` / `@Secured` → "Auth: requires [role/expression]"
- `@EventListener` → "Listens for [event type]"

These are NOT separate SBI entries — they are behavioral modifiers recorded in the Notes of the method's existing SBI entry.

**3. Dependency Injection Graph**:
Spring's `@Autowired` / constructor injection reveals the bean dependency graph. For each `@Service`/`@Component` class, note its injected dependencies in the SBI Notes column (e.g., "Injects: UserRepository, EmailService, CacheManager"). This feeds into Phase 3-2 Feature dependency analysis.

2. **Run SBI extraction per language** using the appropriate patterns
3. **Add Language column** to the SBI table: `| B### | Language | Source File | Function | Behavior | Priority |`
4. **Cross-language call graph consideration**: If a secondary-language function (e.g., C++ via FFI) is called by primary-language code and the callee is P2, elevate to P1 (it's a critical integration point)
5. **Merge into unified SBI table** sorted by Feature association, then by B### ID
6. **Template/Generic Instantiation Rule**: When a single function template, generic class, or macro generates multiple concrete variants (e.g., C++ `Marlin<FP8>`, `Marlin<INT4>`, `Marlin<BF16>`; Rust generic `impl<T>`; CUDA kernel template instantiations):
   - Assign **ONE B### ID** to the template/generic definition itself
   - Record all known instantiation variants in the Notes column: `variants: FP8, INT4, BF16`
   - Do NOT create separate B### entries per variant — they share the same behavioral logic
   - **Exception**: If a template specialization has meaningfully different behavior (not just type substitution), it gets its own B### with a note linking to the base template

   This prevents SBI explosion in heavily templated codebases (e.g., CUDA kernels with 10+ dtype variants).

This is a **universal protocol** — the language table above is extensible. For unlisted languages, use the general pattern: "exported/public function definitions."

#### Large-Scale SBI Processing (scale = Large)

When Scale Detection (Phase 1-4a) classified the project as Large:

1. **Use domain-prefixed B### IDs** (see Phase 1-4a § Domain-Prefixed SBI Numbering)
2. **Process one domain group at a time**: For each group, extract SBI → write to temporary accumulation → merge after all groups complete
3. **P3 summary mode**: Extract function name + one-line description only (no detailed behavioral analysis)
4. **SBI table includes Domain column**: `| B-INF-001 | inference | engine/scheduler.py | schedule_batch | ... | P1 |`
5. **Cross-domain integration points**: If a function in domain A calls a function in domain B, flag as cross-domain interaction (elevate to P1 if either is P2, record in both domains' SBI)

#### UI Control-Level Resolution Rule

File-level SBI ("Settings page renders") misses individual controls. Apply finer granularity for UI-dense files:

1. **UI-dense file detection**: If a source file's render function contains **5+ interactive form controls** (Switch, Select, Input, Button, Slider, RadioGroup, Checkbox, Toggle, ColorPicker, etc.) → activate control-level extraction
2. **Per-control SBI**: Each interactive control becomes its own SBI entry with a unique B### ID:
   - `B056 Settings page renders` → split into `B056a Theme selector (dark/light/system)`, `B056b Font size slider`, `B056c Spell check toggle`, `B056d Hardware acceleration toggle`, etc.
3. **Phase 1.5 cross-verification**: After code-based SBI extraction, if Phase 1.5 runtime exploration was performed → compare extracted UI control count against actually rendered controls. Flag any controls visible at runtime but missing from code-based SBI
4. **Applies to**: Settings pages, form-heavy pages, dashboard widgets, admin panels, preference dialogs — any page where a single component file produces multiple independent user interactions

This inventory feeds into each Feature's `pre-context.md` → "Source Behavior Inventory" section (Phase 4-2) and is used by `/smart-sdd verify` for Feature-level completeness checking.

> **SBI Generation Timing**: Phase 2-6 generates the project-wide global SBI. At this point, Feature classification has not yet been performed (done in Phase 3), so no per-Feature filtering is applied. Per-Feature filtering and B### ID assignment are performed in Phase 4-2.

#### SBI UX Flow Extension (GUI Features)

> **Why this extension exists (SKF-074)**: Function-level SBI captures "what the code does" but not "how the user experiences the result." `B171: Search knowledge base (RAG query)` describes the search function but loses the 8-stage rendering pipeline (inject → AI cite → extract → filter → renumber → embed → tooltip → click-to-open). This missing UX context causes specify to write vague SCs and implement to use minimal rendering patterns.

After function-level SBI extraction, for each P1/P2 SBI entry that produces **user-visible output** (GUI Features only):

1. **Trace the rendering path**: Follow the function's return value → through store/state → to the component that renders it → to the DOM element the user sees
2. **Identify user interactions**: If the rendered output has clickable/hoverable/draggable elements, trace the interaction handler
3. **Add `-UX` suffix SBI entries**: For each significant UX step discovered in the trace, add a companion SBI entry

```
BEFORE (function-level only):
  B171  Search knowledge base (RAG query)          P1  KnowledgeService.search()

AFTER (with UX Flow):
  B171  Search knowledge base (RAG query)          P1  KnowledgeService.search()
  B171a Inject search results into AI prompt       P1  useChatStore.buildPrompt()
  B171b Extract citation numbers from AI response  P1  citation.ts:extractCitations()
  B171c Filter to cited-only + renumber by order   P2  citation.ts:processCitations()
  B171d Render citation badges in message text     P1  TextBlock → CitationBadge
  B171e Citation click opens source file           P1  Link.tsx:onCitationClick()
```

**When to apply**: SBI entry output is rendered in UI AND has user interaction (click, hover, drag) on the rendered element.
**When to skip**: SBI entry is backend-only, or output is displayed as plain text with no interaction.

This extension feeds into specify (each `-UX` entry becomes an FR candidate) and plan (Interaction Chain rows derived from the UX trace).

#### Integration Architecture Extraction (all Features)

> **Why this matters (SKF-075)**: SBI extracts service-level functions (MemoryService.search, KnowledgeService.query) but misses HOW these services integrate with the main application flow. Source app may use Plugin hooks, AI Tool registration, Event/PubSub, or Middleware — patterns invisible at the service file level. Missing integration patterns → implement uses "simplest method" (if-statements + system message injection) → architecture mismatch.

After function-level SBI extraction, for each Feature that **integrates with another Feature's processing pipeline**:

1. **Identify integration files**: Search for files that connect services to the application lifecycle:
   - Plugin/Hook systems: `*plugin*.ts`, `*hook*.ts`, `*middleware*.ts`, `*orchestrat*.ts`
   - AI Tool registration: files that add tools to `params.tools`, `function_declarations`, `tool_choice`
   - Event systems: `*event*.ts`, `*bus*.ts`, `*emitter*.ts`
   - Interceptors: `*interceptor*.ts`, request/response transformers

2. **Read integration files**: For each integration file, extract:
   - Integration pattern: Plugin Hook / AI Tool / Direct Import / Event / Middleware
   - Hook points: When in the lifecycle does integration happen? (request start, params build, response end)
   - Control: Who decides when to use the Feature? (AI decides via Tool, app forces via injection, user toggles)

3. **Add `-INT` suffix SBI entries**:
   ```
   B194     Search relevant memories        P1  MemoryService.search()
   B194-INT Memory as AI Tool via Plugin    P1  searchOrchestrationPlugin.transformParams()
            → "Memory provided as builtin_memory_search tool.
               AI decides when to invoke. Plugin hook on requestStart."
   ```

4. **Integration Pattern Summary**: For the project as a whole, record the dominant integration pattern:
   ```
   Integration Architecture: Plugin Hook Pattern
   - Memory, Knowledge, WebSearch all registered as AI Tools via plugin hooks
   - AI request lifecycle: onRequestStart → transformParams → onRequestEnd
   - NOT direct injection — AI has agency over tool usage
   ```

This feeds into specify (FR must use correct integration verbs) and plan (Integration Contract must specify architecture pattern).

#### UI Screen Inventory (GUI Features — rebuild)

> **Skip if**: Not GUI interface, or not rebuild mode.
> **Why this matters (SKF-076)**: Function-level SBI tells you "what the code does." UI Screen Inventory tells you "what the user sees." Without it, implement produces "functionally correct but visually unrecognizable" results — 857-line source component becomes 200-line simplified version.

For each GUI Feature, inventory **every distinct screen/page/view** the user encounters:

1. **Screen identification**: Find all routes/pages/views in the Feature's source files
2. **For each screen**, document in layout order (top to bottom, left to right):

```markdown
## Screen: [Screen Name]
- **Access path**: [How the user reaches this screen — e.g., "Settings → Memory sidebar link"]
- **Source file(s)**: [Component file(s) + total line count]
- **Layout sections** (top to bottom):
  1. [Header/toolbar]: [elements — toggles, icons, buttons]
  2. [Selector/filter area]: [elements — dropdown, search input, tabs]
  3. [Content area]: [list/grid/form — scroll method (pagination/infinite/all)]
  4. [Footer/actions]: [buttons, menus]
- **Modals/Dialogs** triggered from this screen:
  - [Modal name]: [trigger element] → [modal content summary]
- **Key interactions**:
  - [element] → [action] (e.g., "gear icon → opens settings modal")
  - [element] → [action] (e.g., "dropdown change → refreshes list")
```

3. **Output location**: Stored in pre-context.md `## UI Screen Inventory` section (new section, after Source Behavior Inventory)

This inventory feeds into:
- **specify**: Each screen section/modal/interaction becomes FR candidates
- **plan**: Source→Target Mapping includes UI Pattern Summary from this inventory
- **implement**: Source-First UI Implementation uses this as the structural reference
- **verify**: Source UI Parity Check compares target against this inventory

### 2-7. UI Component Feature Extraction (Frontend/Fullstack Projects Only)

> Skip this step entirely for backend-only, library, or CLI projects.

Third-party UI libraries provide user-facing capabilities through **configuration and plugins**, not through exported functions — invisible to function-level analysis but significant functionality that must be reproduced. See `domains/interfaces/gui.md` § R3 (UI Component Feature Extraction) for the 3-step process (identify → extract → record) and library category mapping. Note: only applies when gui interface is active.

This inventory feeds into each Feature's `pre-context.md` → "UI Component Features" section (Phase 4-2) and is compared during `/smart-sdd parity` → UI Feature Parity.

### 2-7b. UI Micro-Interaction Pattern Extraction (Frontend/Fullstack Projects Only)

> Skip this step entirely for backend-only, library, or CLI projects.
> This step captures interaction-level behaviors (tooltips, hover states, keyboard shortcuts, animations, drag-and-drop, focus management, context menus) that are invisible to both function-level analysis (Phase 2-6) and library-level analysis (Phase 2-7). These behaviors are often implemented via CSS pseudo-classes, event listeners, or small utility components.

See `domains/interfaces/gui.md` § R4 (Micro-Interaction Pattern Extraction) for detection heuristics and extraction rules.

**Two-pronged approach**: Source code analysis (always) + Optional runtime probing (when Playwright is available).

#### A. Source Code Analysis (always executed)

Scan the project's source files for micro-interaction patterns in 7 categories:

**1. Hover Behaviors**:
- CSS: grep for `:hover` pseudo-class rules → record which elements have hover styles and what changes (color, background, opacity, transform, box-shadow)
- React/Vue: grep for `onMouseEnter`, `onMouseLeave`, `onMouseOver`, `@mouseenter`, `@mouseleave` → record handler target and behavior
- Tooltip components: grep for tooltip-related patterns:
  - Library usage: `<Tooltip`, `<Tippy`, `data-tooltip`, `data-tip`, `v-tooltip`
  - HTML native: `title=` attribute on interactive elements
  - Custom: components named `*Tooltip*`, `*Popover*`, `*HoverCard*`
- Record: `{ element, trigger, behavior, content (for tooltips), delay (if specified) }`

**2. Keyboard Shortcuts**:
- Event listeners: grep for `addEventListener('keydown')`, `addEventListener('keyup')`, `addEventListener('keypress')`
- React/Vue: grep for `onKeyDown`, `onKeyUp`, `@keydown`, `@keyup`
- Library usage: grep for keyboard shortcut libraries (hotkeys-js, mousetrap, react-hotkeys-hook, tinykeys, @mantine/hooks useHotkeys)
- Global shortcuts: grep for `Mod+`, `Ctrl+`, `Meta+`, `Alt+`, `Shift+` key combinations in string literals
- Record: `{ shortcut, scope (global/component), action, modifier keys }`

**3. Animations & Transitions**:
- CSS transitions: grep for `transition:` and `transition-*:` properties → record which properties animate, duration, easing
- CSS animations: grep for `animation:`, `animation-name:`, `@keyframes` → record animation names, duration, iteration
- JS animations: grep for `requestAnimationFrame`, `.animate()`, animation libraries (framer-motion, react-spring, GSAP, anime.js, motion)
- Tailwind: grep for `animate-`, `transition-`, `duration-`, `ease-` utility classes
- Record: `{ element/selector, type (transition/animation/JS), properties, duration, trigger }`

**4. Focus Management**:
- Focus styles: grep for `:focus`, `:focus-visible`, `:focus-within` CSS rules
- Focus control: grep for `.focus()`, `autoFocus`, `tabIndex`, `tabindex`
- Focus trapping: grep for focus trap libraries (focus-trap-react, @headlessui, react-focus-lock) or custom `keydown` handlers checking `Tab` key
- Skip links: grep for "skip to content", "skip navigation" patterns
- Record: `{ element, focus-style, focus-control (auto/programmatic/trapped), tab-order }`

**5. Drag-and-Drop**:
- Library detection: grep for drag-and-drop libraries (dnd-kit, react-beautiful-dnd, react-dnd, SortableJS, @hello-pangea/dnd, vuedraggable)
- Native HTML5: grep for `draggable=`, `onDragStart`, `onDragOver`, `onDrop`, `ondragstart`, `ondragover`, `ondrop`
- Custom: grep for `mousedown`+`mousemove`+`mouseup` handler patterns on the same element
- Record: `{ source-element, drop-targets, behavior (reorder/transfer/sort), feedback (placeholder/preview/ghost) }`

**6. Context Menus & Right-click**:
- grep for `onContextMenu`, `addEventListener('contextmenu')`, `@contextmenu`
- grep for context menu components or libraries (react-contexify, @radix-ui/context-menu)
- Record: `{ trigger-element, menu-items, behavior }`

**7. Scroll Behaviors**:
- Scroll events: grep for `onScroll`, `addEventListener('scroll')`, `@scroll`
- Scroll control: grep for `scrollIntoView`, `scrollTo`, `scrollTop`, `scroll-behavior: smooth`
- Infinite scroll: grep for `IntersectionObserver`, infinite scroll libraries
- Sticky elements: grep for `position: sticky`, `position: fixed` with scroll-dependent logic
- Scroll snap: grep for `scroll-snap-type`, `scroll-snap-align`
- Record: `{ element, behavior (infinite-scroll/scroll-snap/sticky/smooth-scroll), trigger }`

#### B. Runtime Probing (optional, when Playwright available)

> **When**: `playwright_cli = true` OR `playwright_mcp = true`, AND app was explored in Phase 1.5.
> **Skip if**: No Playwright available, or Phase 1.5 runtime exploration was skipped.
> **Budget**: Max 3 minutes, max 10 elements per category.

After source code extraction, selectively probe runtime to confirm key findings:

1. **Tooltip verification** (from source analysis results):
   - Hover over elements identified as having tooltips → wait 1s → snapshot → check for new tooltip element
   - Record: actual tooltip text content, position, delay

2. **Keyboard shortcut testing** (from source analysis results):
   - For each identified shortcut: press key combination → observe result
   - Record: confirmed working / not triggered / unexpected behavior

3. **Animation observation**:
   - Navigate between screens → observe if transitions occur
   - Interact with elements that have CSS transitions → observe visual changes
   - Record: confirmed animations, approximate timing

> **Note**: Runtime probing ENRICHES source analysis — it does not replace it. Source code analysis captures the full inventory; runtime probing adds confirmation and actual behavior details (tooltip text, animation timing, etc.).

#### C. Output

Write findings to `specs/_global/micro-interactions.md`.

**ID Format**: Use category-prefixed sequential IDs — `H001`/`H002` for Hover, `K001` for Keyboard, `A001` for Animation, `F001` for Focus, `D001` for Drag-and-Drop, `C001` for Context Menu, `S001` for Scroll. These IDs carry into per-Feature `pre-context.md` Interaction Behavior Inventory tables.

```markdown
# Micro-Interaction Inventory

> Generated by `/reverse-spec` Phase 2-7b — [ISO timestamp]
> Source analysis: [N] patterns detected across [M] files
> Runtime probing: [confirmed/skipped]

## Hover Behaviors
| ID | Element/Component | Trigger | Behavior | Content | Source File |
|----|-------------------|---------|----------|---------|-------------|

## Keyboard Shortcuts
| ID | Shortcut | Scope | Action | Source File |
|----|----------|-------|--------|-------------|

## Animations & Transitions
| ID | Element/Selector | Type | Properties | Duration | Trigger | Source File |
|----|------------------|------|------------|----------|---------|-------------|

## Focus Management
| ID | Element | Focus Style | Control | Tab Order | Source File |
|----|---------|-------------|---------|-----------|-------------|

## Drag-and-Drop
| ID | Source Element | Drop Targets | Behavior | Feedback | Source File |
|----|---------------|--------------|----------|----------|-------------|

## Context Menus
| ID | Trigger Element | Menu Items | Source File |
|----|-----------------|------------|-------------|

## Scroll Behaviors
| ID | Element | Behavior | Trigger | Source File |
|----|---------|----------|---------|-------------|
```

This inventory feeds into each Feature's `pre-context.md` → "Interaction Behavior Inventory" section (Phase 4-2) and is used by `/smart-sdd verify` for micro-interaction completeness checking.

**micro-interactions.md Generation Gate (MANDATORY for frontend/fullstack projects)**:

After completing source code analysis (Part A) and optional runtime probing (Part B):
1. `specs/_global/micro-interactions.md` MUST be written, even if no patterns were detected. If no patterns found, write the template header with empty tables and note: "No micro-interaction patterns detected in source analysis."
2. Verify the file exists before proceeding to Phase 2-8.
3. If this step was skipped (e.g., backend-only project), record: `micro-interactions.md: skipped (backend-only project)` in Phase 2 summary.

This file is a required input for Phase 4-2 (Interaction Behavior Inventory section of each pre-context.md). Its absence causes the Interaction Behavior Inventory section to be silently omitted.

### 2-7c. Component Tree Extraction (Frontend/Fullstack Projects Only)

> (See [pipeline-integrity-guards.md](../../smart-sdd/reference/pipeline-integrity-guards.md) § Guard 4: Granularity Alignment, § Guard 7: Rebuild Fidelity Chain)

For each GUI Feature, extract the **hierarchical component structure** of every page/route. This captures parent-child relationships, conditional rendering branches, and panel systems that are invisible to file-level SBI extraction.

**Why**: SKF-037/044 showed that file-level SBI ("renders HomePage") misses critical sub-components (SelectModelButton, TopicSidebar toggle). The Component Tree gives plan/implement a structural baseline to match.

**Extraction procedure**:

1. **Identify route entry points**: For each Feature, find the root component rendered by the router (e.g., `HomePage.tsx`, `SettingsPage.tsx`)

2. **Walk the import tree**: From the root, follow child component imports to build the hierarchy. Stop at leaf components (no further child components) or third-party library components.

3. **Mark conditional branches**: If a child renders conditionally based on a setting/mode/state, annotate the condition:
   ```
   ├── TopicSidebar (conditional: topicPosition='right')
   ```

4. **Mark interactive hotspots**: Components that contain interactive elements (dropdowns, modals, popovers, selectors) get a note:
   ```
   ├── ChatNavBar
   │   ├── AssistantName (click → settings popup)
   │   ├── SelectModelButton (model selector dropdown ← INTERACTIVE)
   │   └── ToolButtons (settings, search)
   ```

5. **Mark panel/layout systems**: Components that manage dynamic layout (resizable panels, tab switchers, collapsible sections):
   ```
   ├── HomeTabs (tab switcher: Assistants | Topics)
   ```

**Output format** — Add a `## Component Tree` section to each Feature's `pre-context.md`:

```markdown
## Component Tree

> Hierarchical component structure extracted from source code.
> Conditional branches are marked. Interactive hotspots are tagged.
> This tree is the structural baseline for plan (Source Component Mapping)
> and implement (Source-First Implementation).

[PageName/RoutePath]
├── [ComponentA]
│   ├── [SubComponentA1] (conditional: [condition])
│   └── [SubComponentA2] (interactive: [type])
├── [ComponentB] (tab switcher: [Tab1] | [Tab2])
│   ├── [Tab1Content]
│   └── [Tab2Content]
└── [ComponentC]
    ├── [SubComponentC1]
    └── [SubComponentC2] (conditional: [condition])
```

**UI Control Density Check** (per Guard 4a):
While building the tree, count interactive form controls (Switch, Select, Input, Button, Slider, etc.) per component. If a single component contains **5+ controls**, decompose each control as a separate SBI entry (not just "renders component").

**Component Tree Generation Gate (MANDATORY for frontend/fullstack)**:
1. After completing Phase 2-7c, each GUI Feature's pre-context draft must include a `## Component Tree` section
2. If no components were found (e.g., backend-only Feature), record: `Component Tree: N/A — backend-only Feature`
3. Verify the tree exists before proceeding to Phase 2-8

This tree feeds into:
- `/speckit.plan` → Source Component Mapping Table (see injection/plan.md)
- `/smart-sdd implement` → Source-First Implementation Gate (see injection/implement.md)
- `/smart-sdd verify` → Source App Comparison (see verify-phases.md Phase 3e)

### 2-7d. Data Lifecycle Pattern Extraction (All Project Types)

> (See [pipeline-integrity-guards.md](../../smart-sdd/reference/pipeline-integrity-guards.md) § Guard 7: Rebuild Fidelity Chain)

Source apps embed **data lifecycle paradigms** — the rules governing how entities are created, activated, deactivated, and deleted. These paradigms are invisible to component-tree or file-level analysis but fundamentally shape UX behavior. If not explicitly captured, downstream stages default to the simplest paradigm (often opt-out / auto-enable-all), producing functionally correct but behaviorally wrong implementations.

**Trigger**: For each entity type discovered in Phase 2 (SBIs, stores, DB tables, config objects), check if any of these **lifecycle signal components** exist in the source:

| Signal Pattern | Component Name Examples | Indicates |
|---|---|---|
| Manage / Admin | `ManageModelsPopup`, `AdminPanel` | Curated collection — not all items are active |
| Add / Create | `AddModelPopup`, `CreateAssistant` | Explicit opt-in — user adds items individually |
| Enable / Disable / Toggle | `ToggleProvider`, `EnablePlugin` | Selective activation — items exist but may be inactive |
| Import / Export | `ImportConfig`, `ExportData` | External lifecycle — data originates outside the app |
| Archive / Soft-delete | `ArchiveChat`, `TrashFolder` | Retention lifecycle — deleted ≠ destroyed |

**Extraction procedure** (for each entity with lifecycle signals):

1. **Identify the entry paradigm**:
   - **opt-in**: Items don't exist until user explicitly adds them (e.g., fetch models → display in "available" list → user clicks (+) to add)
   - **opt-out**: Items auto-appear and user removes/disables unwanted ones (e.g., fetch models → all enabled by default → user disables)
   - **curated**: Admin/system provides a set, user selects from it (e.g., preset assistants, template library)
   - **import-driven**: Data enters via file/API import, not manual creation

2. **Trace the CRUD flow**: Document the exact sequence the source app uses
   - Example (opt-in): `API fetch → ManageModelsPopup (browse available) → user (+) → addModel() → model appears in selector`
   - Example (opt-out): `API fetch → all models auto-added with enabled:true → user can disable individually`

3. **Record evidence**: List the source components that implement this lifecycle

**Output format** (in pre-context.md `### Data Lifecycle Patterns`):

```
| Entity | Paradigm | CRUD Flow | Evidence Components |
|--------|----------|-----------|-------------------|
| Model | opt-in | Fetch → Browse(ManageModelsPopup) → UserAdd(+) → Active | ManageModelsPopup, AddModelPopup |
| Assistant | curated | Presets loaded → User selects/customizes → Save | AssistantPresets, EditAssistant |
| Chat | opt-in | User creates → Messages append → Archive/Delete | NewChatButton, ArchiveChat |
```

**Data Lifecycle Generation Gate (MANDATORY when lifecycle signals found)**:
1. After completing Phase 2-7d, each entity with lifecycle signals must have an entry in `### Data Lifecycle Patterns`
2. If no lifecycle signals found → record: `Data Lifecycle Patterns: N/A — no managed entities detected`
3. Verify the section exists before proceeding to Phase 2-8

This feeds into:
- `/speckit.plan` → Data Lifecycle Mapping Table (see injection/plan.md)
- `/smart-sdd implement` → Source-First Implementation Gate uses lifecycle paradigm to validate data flow logic
- `/smart-sdd verify` → Round-trip verification checks that lifecycle matches source paradigm

### 2-8. Foundation Decision Extraction

For each identified framework (from Phase 1-2b):

1. Load `domains/foundations/{framework}.md`
   - If Foundation file exists (Case A): Load full F2 items
   - If no Foundation file but framework known (Case B): Load universal categories from `domains/foundations/_foundation-core.md` § F1
   - If framework is `custom` (Case D): Skip this step entirely

2. For each Foundation item marked **Critical** or **Important**:
   - Apply F3 Extraction Rules to determine current decision in code
   - Record: `decided` / `not-configured` / `ambiguous`

3. Output: Foundation Decision Table per framework

| ID | Item | Detected Value | Confidence | Source File |
|----|------|---------------|------------|-------------|

4. Flag `ambiguous` items for user clarification during `smart-sdd init` Step 3b or `smart-sdd pipeline` pre-phase review

**Foundation Migration** (rebuild with framework change only):
If `change_scope = "framework"` or `"stack"`, apply the Migration Protocol from `domains/foundations/_foundation-core.md` § F5:
- Load OLD framework Foundation from extracted code decisions
- Load NEW framework Foundation from target framework file
- Classify each item: carry-over / equivalent / irrelevant / new
- Output: Foundation Migration Table (see § F5 for format)

Upon completing Phase 2, report a summary of the number of entities, APIs, business rules, environment variables, source behaviors, UI component features, and Foundation decisions discovered.

---

