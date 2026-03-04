# [PROJECT_NAME] Constitution (Seed)

**Source**: [Original source path]
**Generated**: [DATE]
**Strategy**: Stack: [same|new]

> This document is a constitution draft extracted from existing source code analysis.
> Use this document as input when running /speckit.constitution to finalize the constitution.
> Review the draft content and modify/supplement it as needed for the redevelopment project.

---

## Source Code Reference Principles

> Include only the section that matches the strategy selected in Phase 0.

### [Same Stack Strategy] Source as Implementation Reference

- **Original source location**: [path]
- When writing spec/plan for each Feature, **always** read and reference the original files specified in the Source Reference section of `pre-context.md`
- **Prioritize reusing** existing implementation patterns (design patterns, error handling, test structure)
- If designing differently from the existing implementation, **always** document the reason for the change in `plan.md`'s Complexity Tracking
- Reference existing code's test cases to ensure equivalent test coverage

### [New Stack Strategy] Source as Logic Reference Only

- **Original source location**: [path]
- When writing spec/plan for each Feature, read the original files specified in the Source Reference section of `pre-context.md` to **understand the business logic and requirements**
- **Do not reference** existing code's implementation patterns (framework usage, library APIs)
- **Extract**: What (functionality), Why (rationale), business rules, edge cases
- **Ignore**: How (implementation approach), technology-dependent patterns
- Prioritize idiomatic patterns of the new stack

---

## Extracted Architecture Principles

> Architecture patterns consistently observed in the existing code, organized as principles.

### I. [Principle Name]
- **Rule**: [Specific rule description]
- **Rationale**: [Why this pattern was applied in the existing code]
- **Evidence**: [Which code this was observed in]

### II. [Principle Name]
- **Rule**: [Specific rule description]
- **Rationale**: [Why this pattern was applied in the existing code]
- **Evidence**: [Which code this was observed in]

### III. [Principle Name]
- **Rule**: [Specific rule description]
- **Rationale**: [Why this pattern was applied in the existing code]
- **Evidence**: [Which code this was observed in]

---

## Extracted Technical Constraints

| Area | Constraint | Source |
|------|-----------|--------|
| Performance | [e.g., API response time under 200ms] | [Observed location/setting] |
| Security | [e.g., Authentication required for all APIs] | [Middleware configuration] |
| Compatibility | [e.g., No IE11 support, modern browsers only] | [Build configuration] |
| Scalability | [e.g., Stateless design for horizontal scaling] | [Architecture pattern] |

---

## Extracted Coding Conventions

| Area | Convention | Example |
|------|-----------|---------|
| Naming | [e.g., camelCase for variables, PascalCase for classes] | [Code example location] |
| Project Structure | [e.g., feature-based directory structure] | [Directory structure] |
| Error Handling | [e.g., centralized error handler with error codes] | [Code example location] |
| Logging | [e.g., structured JSON logging with correlation ID] | [Code example location] |
| Testing | [e.g., AAA pattern, integration tests with test DB] | [Test structure] |

---

## Project-Specific Recommended Principles

> Principles recommended based on characteristics observed in the existing source code.
> These are suggestions derived from the project's domain, architecture patterns, and technical traits.
> Review and adopt/modify as appropriate for the redevelopment project.

### [Recommended Principle Name]
- **Observed Trait**: [What was observed in the source that triggers this recommendation — e.g., "Payment processing with external gateway integration", "Real-time WebSocket connections for chat"]
- **Recommended Rule**: [Specific principle to adopt — e.g., "All payment operations must be idempotent", "Implement optimistic UI updates with server reconciliation"]
- **Rationale**: [Why this principle is important for this type of project]

### [Recommended Principle Name]
- **Observed Trait**: [...]
- **Recommended Rule**: [...]
- **Rationale**: [...]

<!--
Recommendation categories to consider based on source analysis:

Domain-driven:
- Financial/Payment → Idempotency, Audit Trail, Decimal Precision
- Multi-tenant SaaS → Tenant Isolation, Data Partitioning
- Healthcare/PII → Data Encryption at Rest, Access Logging
- Real-time → Optimistic Updates, Conflict Resolution, Graceful Degradation
- E-commerce → Inventory Consistency, Cart Expiry, Price Integrity

Architecture-driven:
- Event-driven/Message queues → Event Idempotency, Dead Letter Handling, Eventual Consistency
- Microservices → Circuit Breaker, Bulkhead, Distributed Tracing
- Heavy async/background jobs → Job Idempotency, Retry Strategy, Timeout Policy
- File/media handling → Streaming Upload, CDN Strategy, Cleanup Policy

Scale/Performance-driven:
- High-traffic APIs → Rate Limiting, Caching Strategy, Connection Pooling
- Large datasets → Pagination Mandate, Query Optimization, Index Strategy
- Search-heavy → Search Index Sync Strategy, Denormalization Policy

Quality-driven:
- No existing tests → Behavioral Characterization Tests (capture existing behavior before refactoring)
- Complex state machines → State Transition Diagram Requirement
- Heavy external integrations → Mock/Stub Strategy, Contract Testing
-->

---

## Recommended Development Principles (Best Practices)

> Standard principles for redevelopment. Modify/supplement as needed for your project.

### I. Test-First (NON-NEGOTIABLE)
- Write tests before implementing any feature
- Acceptance Scenarios (Given/When/Then) from spec.md are the source of test cases
- In tasks.md, test tasks must always precede implementation tasks
- Code without tests is not considered complete
- For bug fixes: write a test that reproduces the bug first, then fix it
- **Verification criterion**: `All tests must pass upon implement completion`

### II. Think Before Coding
- Do not assume. If unclear, mark it as `[NEEDS CLARIFICATION]` in the spec
- If multiple implementation approaches are possible, document alternatives and selection rationale in plan.md's Complexity Tracking
- Expose trade-offs explicitly rather than hiding them
- **Verification criterion**: `Every design decision must have an answer to "why?"`

### III. Simplicity First
- Implement only what is specified in the spec. No speculative feature additions
- No premature abstraction for single-use code
- No abstractions/wrappers/utilities justified by "might need it later"
- If something done in 200 lines can be done in 50, rewrite it
- **Verification criterion**: `All code must be directly traceable to a spec requirement`

### IV. Surgical Changes
- No "improving" adjacent code/comments/formatting when modifying existing code
- Do not refactor what already works
- Only clean up imports/variables/functions that became unused due to your changes
- Respect existing code style and maintain consistency
- **Verification criterion**: `Every changed line must be directly traceable to the current task`

### V. Goal-Driven Execution
- Every task includes verifiable completion criteria
- Set completion criteria as "tests pass" instead of "implemented"
- For multi-step work, define verification methods for each step in advance
- **Verification criterion**: `Automated verification (tests, build, lint) must pass upon each task completion`

### VI. Demo-Ready Delivery
- Each Feature must be demonstrable upon completion — not just passing tests, but **the user must be able to see and use the real, working Feature**
- A demo is NOT a test suite. Tests belong in `verify` Phase 1. A demo **launches the Feature** so the user can experience it firsthand
- Maintain a centralized `demos/` directory at the project root with **executable demo scripts** per Feature:
  ```
  demos/
  ├── README.md              # Demo Hub — index of all Feature demos
  ├── F001-auth.sh           # Launches auth Feature for the user to try
  ├── F002-product.sh
  └── ...
  ```
- Each demo script (`demos/F00N-name.sh` or `.ts`/`.py`/etc. matching the project's language) must be:
  - **Interactive by default**: Running the script starts the Feature, prints "Try it" instructions (real URLs, commands), and keeps running until Ctrl+C
  - **`--ci` flag for automation**: `./demos/F00N-name.sh --ci` runs setup + health check and exits cleanly. Used by `verify` Phase 3
  - **Executable**: `chmod +x` and self-contained — sets up everything needed (demo data, server start, etc.)
  - **Coverage-mapped**: Include a Coverage header comment mapping each FR-###/SC-### from spec.md to what the user can see/try in the demo (✅ demonstrated / ⬜ not demoed with reason):
    ```bash
    # Coverage (maps to spec.md):
    #   ✅ FR-001 [Requirement name]   → Demonstrated: [how the user sees this]
    #   ✅ FR-002 [Requirement name]   → Demonstrated: [how the user sees this]
    #   ⬜ FR-003 [Requirement name]   → Not demoed: [reason]
    ```
  - **Concrete instructions**: Print at least 2 things the user can actually DO — real URLs to open, real commands to run, real interactions to try
  - Include a **Demo Components** header listing each component as Demo-only or Promotable
- "Demo-ready" means: `./demos/F00N-name.sh` starts the Feature and the user can **see it, use it, interact with it** — not just read a "3/3 passed" message
- **What the demo implements** (by Feature type):
  - Has UI → Start server with demo data, user opens real pages in browser and interacts
  - Backend/API → Start server with demo data, user calls real API endpoints with curl/httpie
  - CLI/Library → Provide pre-configured sandbox, user runs real commands
  - Data layer / Store → Provide seeded database, user performs real CRUD operations
  - Pipeline / Engine → Provide sample input, user runs the pipeline and sees real output
- **Demo artifacts**: During `implement`, create the surfaces users will interact with — demo routes, demo pages, demo data fixtures, demo CLI wrappers. These are what make the demo real, not assertions
- **Demo tasks in tasks.md**: Every Feature's `tasks.md` must include demo-related tasks (demo data preparation, demo surface creation, demo script writing). Demo work is done incrementally during `implement` — not deferred to the end
- **Demo code separation strategy**: Clearly distinguish demo-only code from production code
  - **Demo-only code** (mock data, temporary UI scaffolding): Place under `demos/` directory. Mark with `// @demo-only` comment. Will be removed or replaced when the real Feature is implemented
  - **Promotable code** (minimal but real implementation that future Features will extend): Place in the regular source tree. Mark with `// @demo-scaffold — will be extended by F00N-[feature]` comment. Not deleted, but evolved
  - Each demo script must declare component categories in its header comment:
    ```bash
    # Demo Components:
    #   Mock provider data | demos/fixtures/providers.json | Demo-only | Remove after F002-provider UI
    #   Demo CLI runner | demos/scripts/demo-F001.ts | Demo-only | Remove after full UI
    #   Settings page shell | src/pages/settings.tsx | Promotable | Extended by F005-settings
    ```
  - During subsequent Feature implementation, check `demos/` for demo-only components marked for removal and clean them up
- **Limited verification**: If a Feature cannot be fully verified (e.g., tests depend on unmerged Feature, no frontend for pure library), the user may acknowledge "limited verification" with a mandatory reason. This is recorded as ⚠️ in progress tracking — merge is allowed, but re-verification is expected when the limitation is resolved
- **Verification criterion**: `Running ./demos/F00N-name.sh launches the Feature and the user can experience it — "npm test passes" alone does NOT satisfy this criterion`

---

## Global Evolution Layer Operational Principles

> Include these principles in the constitution to enforce referencing the Global Evolution Layer during spec-kit progression.

### Cross-Feature Consistency
- Before running /speckit.specify for any Feature, always read `specs/reverse-spec/roadmap.md` and the Feature's `pre-context.md`
- When running /speckit.plan for any Feature, reference `specs/reverse-spec/entity-registry.md` and `specs/reverse-spec/api-registry.md` to ensure entity/API compatibility
- When defining new entities or APIs, update entity-registry.md and api-registry.md
- When cross-Feature dependencies change, update the Dependency Graph in roadmap.md

---

**Version**: 0.1.0-seed | **Generated**: [DATE]
