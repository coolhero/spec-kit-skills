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

## Recommended Development Principles (Best Practices)

> Recommended principles for redevelopment. Modify/supplement as needed for your project.

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
- Each Feature must be demonstrable upon completion — not just passing tests, but runnable and visually/functionally verifiable
- Include a demo script or instructions in the Feature's tasks.md that describes how to launch and interact with the completed Feature
- "Demo-ready" means: the Feature can be started, exercised through its core user flows, and the results observed — without requiring other incomplete Features
- If the Feature has no UI, provide a CLI command, API call sequence, or script that exercises the core functionality and displays results
- **Verification criterion**: `A non-developer stakeholder can follow the demo instructions and verify the Feature works`

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
