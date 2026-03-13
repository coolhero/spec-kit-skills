# Interface: gui (reverse-spec)

> UI component analysis axes. Loaded when project has user-facing GUI.
> Module type: interface (reverse-spec analysis)

---

## R3. Analysis Axes — UI Component Feature Extraction (Phase 2-7)

> Skip this step entirely for backend-only, library, or CLI projects.

Third-party UI libraries (editors, charts, form builders, calendars, etc.) provide user-facing capabilities through **configuration and plugins**, not through exported functions. These capabilities are invisible to function-level analysis but represent significant functionality that must be reproduced.

**Step 1 — Identify UI library dependencies**:
Scan `package.json` (or equivalent) for UI component libraries. Common categories:

| Category | Example Libraries |
|----------|-------------------|
| Rich text editors | Toast UI Editor, TipTap, ProseMirror, Slate, Quill, CodeMirror, Monaco |
| Charts/visualization | Chart.js, D3, ECharts, Recharts, Nivo |
| Form builders | Formik, React Hook Form (with complex UI), Ant Design Form |
| Drag & drop | dnd-kit, react-beautiful-dnd, SortableJS |
| Calendars | FullCalendar, react-big-calendar |
| Maps | Leaflet, Mapbox GL, Google Maps |
| Media players | Video.js, Plyr, Howler |

**Step 2 — Extract activated features per library**:
For each identified UI library, read the initialization/configuration code to extract:
- **Activated features**: Toolbar items, plugins, modes, options enabled in the config
- **Custom extensions**: Custom plugins, overrides, hooks built on top of the library
- **User interaction patterns**: Keyboard shortcuts, drag-drop behavior, paste handling, mode toggles

**Step 3 — Record as UI Component Features**:
For each component, produce a feature inventory:

| Component | Library | Feature | Category |
|-----------|---------|---------|----------|
| `NoteEditor` | `@toast-ui/editor 3.2` | Bold/Italic/Strikethrough toolbar | text-formatting |
| `NoteEditor` | `@toast-ui/editor 3.2` | Markdown <-> WYSIWYG mode toggle | editing-mode |
| `NoteEditor` | custom plugin | Wiki-link autolink `[[title]]` | navigation |

This inventory feeds into each Feature's `pre-context.md` "UI Component Features" section (Phase 4-2) and is compared during `/smart-sdd parity` UI Feature Parity.

---

## R4. Analysis Axes — Micro-Interaction Pattern Extraction (Phase 2-7b)

> Skip this step entirely for backend-only, library, or CLI projects.

Custom-built micro-interactions (tooltips, hover effects, keyboard shortcuts, animations, drag-and-drop, focus management, context menus, scroll behaviors) represent **behavioral contracts** with users that must be preserved during rebuild. These behaviors are often implemented via CSS pseudo-classes, inline event handlers, or small utility components — invisible to both function-level analysis (R3 SBI) and library-level analysis (R3 UI Components).

### Detection Heuristics

#### Hover Behaviors
| Signal | Pattern | Extraction |
|--------|---------|------------|
| CSS `:hover` | `selector:hover { ... }` | Property changes (color, bg, opacity, transform, shadow) |
| React event | `onMouseEnter={...}` / `onMouseLeave={...}` | Handler logic → state change → UI effect |
| Vue event | `@mouseenter` / `@mouseleave` | Same as React |
| Tooltip component | `<Tooltip>`, `<Tippy>`, `data-tooltip`, `title=` | Tooltip text content, position, delay |
| Tooltip library | `tippy.js`, `react-tooltip`, `@radix-ui/tooltip`, `@floating-ui` | Configuration options, themes |
| Popover/HoverCard | `<Popover>`, `<HoverCard>`, `*Popover*` components | Trigger, content, placement |

#### Keyboard Shortcuts
| Signal | Pattern | Extraction |
|--------|---------|------------|
| DOM event | `addEventListener('keydown'/'keyup')` | Key combination, handler action |
| React event | `onKeyDown={...}` / `onKeyUp={...}` | Key check in handler, action |
| Keyboard library | `hotkeys-js`, `mousetrap`, `react-hotkeys-hook`, `tinykeys` | Binding definition, action |
| Key string literals | `'Mod+K'`, `'Ctrl+S'`, `'Meta+Enter'` | Shortcut map |
| useHotkeys hook | `useHotkeys('ctrl+k', ...)` | Scope, key, callback |

#### Animations & Transitions
| Signal | Pattern | Extraction |
|--------|---------|------------|
| CSS transition | `transition: prop duration easing` | Properties, timing |
| CSS animation | `@keyframes name { ... }`, `animation: name duration` | Keyframes, duration, iteration |
| Tailwind motion | `animate-spin`, `transition-all`, `duration-300` | Utility class mapping |
| Framer Motion | `<motion.div animate={...}>`, `useAnimation` | Variants, spring config |
| React Spring | `useSpring`, `useTransition` | Spring config, from/to |
| GSAP | `gsap.to()`, `gsap.from()`, `gsap.timeline()` | Tween config |

#### Focus Management
| Signal | Pattern | Extraction |
|--------|---------|------------|
| CSS focus | `:focus`, `:focus-visible`, `:focus-within` | Focus ring style |
| Programmatic focus | `.focus()`, `autoFocus`, `ref.current.focus()` | Focus target, timing |
| Tab order | `tabIndex=`, `tabindex=` | Custom tab order |
| Focus trap | `focus-trap-react`, `@headlessui`, `react-focus-lock` | Trap scope, escape key |
| Skip link | `"skip to"`, `"skip nav"`, `#main-content` | Target section |

#### Drag-and-Drop
| Signal | Pattern | Extraction |
|--------|---------|------------|
| DnD library | `dnd-kit`, `react-beautiful-dnd`, `@hello-pangea/dnd` | Sortable areas, constraints |
| HTML5 native | `draggable="true"`, `onDragStart`, `onDrop` | Source, target, data transfer |
| Custom DnD | `mousedown`+`mousemove`+`mouseup` pattern | Drag area, constraints |
| SortableJS | `Sortable.create()`, `vue.draggable` | Sort config, groups |

#### Context Menus
| Signal | Pattern | Extraction |
|--------|---------|------------|
| Right-click | `onContextMenu`, `contextmenu` event | Menu items, actions |
| Library | `react-contexify`, `@radix-ui/context-menu` | Menu definition |
| Custom | Element with `onContextMenu` + dropdown state | Items, separator pattern |

#### Scroll Behaviors
| Signal | Pattern | Extraction |
|--------|---------|------------|
| Scroll event | `onScroll`, `addEventListener('scroll')` | Handler action |
| Smooth scroll | `scroll-behavior: smooth`, `scrollTo({behavior:'smooth'})` | Target, trigger |
| Infinite scroll | `IntersectionObserver` + data loading | Threshold, loading indicator |
| Sticky | `position: sticky`, `position: fixed` + scroll logic | Offset, element |
| Scroll snap | `scroll-snap-type`, `scroll-snap-align` | Direction, alignment |
| Virtual scroll | `react-virtuoso`, `@tanstack/virtual`, `react-window` | Item count, overscan |

### Priority Classification

| Priority | Scope | During Rebuild |
|----------|-------|---------------|
| P1 — Core interaction | Hover/focus styles visible on every screen, primary keyboard shortcuts (Ctrl+S, Ctrl+Z), drag-and-drop for core workflows | Must reproduce |
| P2 — Enhancement | Screen-specific hover effects, secondary keyboard shortcuts, decorative animations, context menus | Should reproduce |
| P3 — Polish | Micro-animations (transition timing fine-tuning), scroll snap, advanced focus management | Can defer |

### Output Format

Results are written to `specs/reverse-spec/micro-interactions.md` (see `commands/analyze.md` Phase 2-7b for file structure) and distributed to per-Feature `pre-context.md` → "Interaction Behavior Inventory" section during Phase 4-2.
