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
