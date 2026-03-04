# Domain Profile: app

> Default domain. Covers application software development: backend, frontend, fullstack, mobile, and library projects.

---

## 1. Detection Signals

- Configuration files: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`, `Gemfile`, `composer.json`
- Directory patterns: `routes/`, `controllers/`, `views/`, `models/`, `src/`, `app/`, `lib/`
- HTTP framework imports: Express, Fastify, Django, FastAPI, Spring, Rails, Next.js, Nuxt

---

## 2. Project Type Classification

| Type | Description |
|------|-------------|
| **backend** | API server, service |
| **frontend** | SPA, SSR web app |
| **fullstack** | Backend + Frontend integrated |
| **mobile** | iOS/Android app |
| **library** | Reusable library/package |

---

## 3. Analysis Axes

### 3-1. Tech Stack Detection (Phase 1-2)

Read configuration files to identify the tech stack:

| Detection Target | Files to Search |
|------------------|-----------------|
| Language/Version | `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `build.gradle`, `pom.xml`, `Gemfile`, `composer.json`, `.python-version`, `.nvmrc`, `.tool-versions` |
| Framework | Identify frameworks from dependency lists (React, Next.js, Django, FastAPI, Spring, Express, Rails, etc.) |
| DB/Storage | ORM configuration, migration files, connection settings |
| Testing | Test framework configuration, test directory structure |
| Build/Deploy | Dockerfile, docker-compose, CI/CD configuration, Makefile |

### 3-2. Data Model Extraction (Phase 2-1)

Extract entities from appropriate sources depending on the tech stack:

| Technology | Search Targets |
|------------|----------------|
| Django | `models.py`, migrations |
| SQLAlchemy/FastAPI | Model classes, Alembic migrations |
| TypeORM/Prisma | Entity classes, `schema.prisma` |
| Sequelize | Model definitions, migrations |
| JPA/Hibernate | `@Entity` classes |
| Mongoose | Schema definitions |
| Go | struct definitions + DB tags |
| Rails | `app/models/`, migrations |

Information to extract from each entity:
- Entity name, fields (name, type, constraints)
- Relationships (1:1, 1:N, M:N, target entity)
- Validation rules
- State transitions (enum, state machine)
- Indexes, unique constraints

### 3-3. API Endpoint Extraction (Phase 2-2)

Extract APIs from appropriate sources depending on the tech stack:

| Technology | Search Targets |
|------------|----------------|
| Express/Fastify | Router files, `app.use()`, `router.get()`, etc. |
| Django/DRF | `urls.py`, ViewSet, APIView |
| FastAPI | `@app.get()`, `@router.post()`, etc. decorators |
| Spring | `@RequestMapping`, `@GetMapping`, etc. |
| Rails | `config/routes.rb`, controllers |
| Next.js/Nuxt | `pages/api/`, `app/api/` directories |
| Go (net/http, Gin, Echo) | Router registration, handler functions |

Information to extract from each endpoint:
- HTTP method, path
- Request parameters, body schema
- Response schema (per status code)
- Authentication/authorization requirements
- Middleware/interceptors

### 3-4. Business Logic Extraction (Phase 2-3)

Extract from the service layer, utilities, and domain logic:
- **Business Rules**: Conditional logic, policy enforcement, calculation logic
- **Validation**: Input validation, state transition conditions, business constraints
- **Workflows**: Multi-step processes, state machines, event chains
- **External Integrations**: External API calls, message queues, event publishing/subscribing

### 3-5. Inter-Module Dependency Mapping (Phase 2-4)

- Analyze import/require statements to identify dependencies between modules
- Service call relationships (dependency injection, direct calls)
- Shared utilities, common type usage relationships
- Event/message-based coupling relationships

### 3-6. Test Coverage Scan (Phase 2-5 — Environment Variables)

Scan the codebase for environment variable usage to identify runtime configuration requirements.

| Detection Target | Search Patterns |
|-----------------|-----------------|
| Env files | `.env`, `.env.example`, `.env.local`, `.env.development`, `.env.production` |
| Node.js | `process.env.VARIABLE_NAME` |
| Python | `os.environ`, `os.getenv()`, `settings.py` env reads, `python-dotenv` usage |
| Go | `os.Getenv()` |
| Java/Spring | `@Value("${...}")`, `application.properties`, `application.yml` env references |
| Ruby/Rails | `ENV["..."]`, `ENV.fetch(...)`, `credentials.yml.enc` |
| Generic | `dotenv` config files, Docker Compose `environment:` sections |

For each discovered environment variable, extract:
- **Variable name** (e.g., `DATABASE_URL`, `OPENAI_API_KEY`)
- **Category**: `secret` (API keys, passwords, tokens) | `config` (URLs, ports, modes) | `feature-flag` (toggle switches)
- **Required/Optional**: Whether the app fails without it
- **Source file(s)**: Where it is referenced
- **Feature association**: Determined during Phase 4 (pre-context generation), based on file-to-Feature mapping from Phase 3
- **Example value**: From `.env.example` if available (NEVER extract actual values from `.env`)

### 3-7. Source Behavior Inventory (Phase 2-6)

For each source file identified in Phase 1, extract a **function-level inventory** of exported/public behaviors. This captures discrete units of functionality that structural extraction (entities, APIs) may miss.

**What to extract**:
- Exported functions, public methods, request handlers, event listeners, middleware, CLI commands
- For each: function/method name, one-line behavior description, priority classification

**Priority classification**:
- **P1 (core)**: Behaviors directly tied to the Feature's primary purpose. Must be implemented
- **P2 (important)**: Supporting behaviors that complete the Feature's functionality. Should be implemented
- **P3 (nice-to-have)**: Utility functions, convenience methods, edge-case handlers. Can be deferred

**How to extract efficiently**:
- Scan for `export function`, `export class`, `module.exports`, public methods, route handlers, decorated functions, etc. (adapt patterns to the detected tech stack)
- Group by Feature association (determined in Phase 3 when Feature boundaries are identified)
- Skip internal/private helpers that are implementation details, not behaviors

This inventory feeds into each Feature's `pre-context.md` "Source Behavior Inventory" section (Phase 4-2) and is used by `/smart-sdd verify` for Feature-level completeness checking.

### 3-8. UI Component Feature Extraction (Phase 2-7 — Frontend/Fullstack Projects Only)

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

## 4. Registries

| Registry | File | Purpose | Template |
|----------|------|---------|----------|
| Entity Registry | `entity-registry.md` | Complete entity list, fields, relationships, validation rules, cross-Feature sharing mapping | `templates/entity-registry-template.md` |
| API Registry | `api-registry.md` | Complete API endpoint index, detailed contracts, cross-Feature dependencies | `templates/api-registry-template.md` |
| Business Logic Map | `business-logic-map.md` | Business rules per Feature, validation, workflows, cross-Feature rules | `templates/business-logic-map-template.md` |

---

## 5. Feature Boundary Heuristics

Identify logical functional units (Features) based on the Phase 2 analysis results:
- **Domain module boundaries** (e.g., auth, product, order, payment)
- **Service boundaries** (in the case of microservice architectures)
- **Route groups** (based on API path prefixes)
- **Entity clusters** (groups of closely related entities)

Define the following for each Feature:
- Feature name (concise English name)
- Description (1-2 sentences)
- List of associated files
- Owned entities
- Provided APIs

---

## 6. Tier Classification Axes

Evaluate each Feature comprehensively across 5 analysis axes (core scope only):

**Analysis Axis 1 -- Structural Foundation**
- Can other Features not exist without this Feature?
- Basis for judgment: Number of reverse dependencies, import depth, number of shared entities owned

**Analysis Axis 2 -- Domain Core**
- Is this feature directly tied to the project's reason for existence?
- Basis for judgment: Role within the project domain (e.g., for e-commerce, products/orders are core)

**Analysis Axis 3 -- Data Ownership**
- Does this feature define and manage core entities?
- Basis for judgment: Number of owned entities, ratio of entities referenced by other Features

**Analysis Axis 4 -- Integration Hub**
- Is this a connection point with other Features/external systems?
- Basis for judgment: Role as API provider, number of external integrations, number of events published

**Analysis Axis 5 -- Business Complexity**
- Are core business rules concentrated in this feature?
- Basis for judgment: Number of business rules, number of state transitions, validation complexity

Assign each Feature to a Tier based on the comprehensive evaluation results:

| Tier | Meaning | Criteria |
|------|---------|----------|
| **Tier 1 (Essential)** | Foundation of the project. The system cannot function without it | Must be included in redevelopment |
| **Tier 2 (Recommended)** | Features that complete the core user experience | System works without them but core value is significantly diminished |
| **Tier 3 (Optional)** | Supplementary features, admin tools, convenience features | Can be added in later phases |

For each Feature, a **specific rationale** for the assigned Tier must be provided.
Examples:
- "Auth recommended as Tier 1: 7 Features directly depend on it, owns the User entity, used as middleware for all APIs"
- "Notification recommended as Tier 3: Independent module with no reverse dependencies, loosely coupled via event subscription"

---

## 7. Demo Pattern

- **Type**: Server-based
- **Default mode**: Launch dev server, print accessible URLs, wait for user interaction
- **CI mode**: Start server, run automated health-check requests against key endpoints, exit with pass/fail
- **Script location**: `demos/F00N-name.sh`

---

## 8. Parity Dimensions

| Dimension | Type | Compare |
|-----------|------|---------|
| API endpoints | Structural | Method + path coverage between source and rebuilt |
| DB entities | Structural | Entity names, field counts, relationship types |
| Test files | Structural | Test file count and naming correspondence |
| UI components | Structural | Component count and library feature coverage |
| Business rules | Logic | Rule-by-rule match of conditions and outcomes |
| State transitions | Logic | State machine states, transitions, and guard conditions |

---

## 9. Verify Steps

| Step | Required | Description |
|------|----------|-------------|
| Test | Yes (BLOCKING) | Run test suite; failure blocks pipeline progression |
| Build | Yes (BLOCKING) | Run build command; failure blocks pipeline progression |
| Lint | Yes (BLOCKING) | Run linter; failure blocks pipeline progression |
| Demo-ready | Conditional | If constitution Best Practice VI (Demo-Ready Delivery) is active, verify demo script exists and runs successfully |
