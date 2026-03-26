# File Map — spec-kit-skills

> Complete file inventory + relationship diagrams for the spec-kit-skills project.
> Complete file inventory + relationship diagrams across 4 skills + 1 shared module.

---

## 1. Architecture Overview

```mermaid
graph TB
    subgraph "Root"
        README["README.md / .ko.md"]
        ARCH["ARCHITECTURE-EXTENSIBILITY.md / .ko.md"]
        HIST["history.md"]
        LL["lessons-learned.md"]
        PG["PLAYWRIGHT-GUIDE.md"]
        CM["CLAUDE.md"]
        FM["FILE-MAP.md"]
    end

    subgraph "shared/"
        subgraph "shared/domains/"
            STAX["_taxonomy.md"]
            STPL["_TEMPLATE.md"]
            SI["interfaces/ (10)"]
            SC["concerns/ (47)"]
            SA["archetypes/ (15)"]
            SCX["contexts/ (1)"]
        end
        subgraph "shared/runtime/"
            SRI["_index.md"]
            SRL["app-launch.md"]
            SRD["data-storage-map.md"]
            SRP["playwright-detection.md"]
            SRU["user-assisted-setup.md"]
            SRO["observation-protocol.md"]
        end
        SCR["reference/completion-report.md"]
    end

    subgraph "reverse-spec/"
        RS_SKILL["SKILL.md"]
        RS_CMD["commands/ (6)"]
        RS_DOM["domains/ (120)"]
        RS_REF["reference/ (1)"]
        RS_TPL["templates/ (10)"]
    end

    subgraph "smart-sdd/"
        SS_SKILL["SKILL.md"]
        SS_CMD["commands/ (16)"]
        SS_DOM["domains/ (98)"]
        SS_REF["reference/ (28)"]
        SS_TPL["templates/ (3)"]
        SS_SCR["scripts/ (7)"]
    end

    subgraph "code-explore/"
        CE_SKILL["SKILL.md"]
        CE_CMD["commands/ (4)"]
    end

    subgraph "domain-extend/"
        DE_SKILL["SKILL.md"]
        DE_CMD["commands/ (6)"]
        DE_REF["reference/ (2)"]
        DE_TPL["templates/ (7)"]
    end

    %% Key relationships
    SS_CMD -->|"loads domain modules"| SI & SC & SA & SCX
    RS_CMD -->|"loads domain modules"| SI & SC & SA & SCX
    SS_CMD -->|"reads foundations"| RS_DOM
    SS_CMD -->|"loads runtime"| SRL & SRP & SRD
    RS_CMD -->|"loads runtime"| SRL & SRP
    SS_CMD -->|"generates report"| SCR
    RS_CMD -->|"generates report"| SCR
    CE_CMD -->|"feeds into"| RS_CMD
    RS_CMD -->|"feeds into"| SS_CMD
    DE_CMD -->|"manages modules"| SI & SC & SA
    DE_CMD -->|"reads taxonomy"| STAX
```

---

## 2. Pipeline Execution Flow

```mermaid
flowchart LR
    subgraph "Phase 1: Analysis"
        CE["/code-explore"] --> RS["/reverse-spec"]
        RS --> |"analyze-scan → analyze-deep → analyze-classify → analyze-runtime → analyze-generate"| ARTS["specs/_global/ artifacts"]
    end

    subgraph "Phase 2: Setup"
        ARTS --> INIT["/smart-sdd init"]
        INIT --> ADD["/smart-sdd add"]
        ARTS --> ADOPT["/smart-sdd adopt"]
    end

    subgraph "Phase 3: Pipeline"
        ADD --> PIPE["/smart-sdd pipeline"]
        ADOPT --> PIPE
        PIPE --> |"constitution → specify → plan → tasks → implement → verify"| DONE["Features completed"]
    end

    subgraph "Phase 4: Report"
        DONE --> RPT["Auto-Report"]
        RS --> |"Phase 4-5"| RPT2["completion-report.md"]
    end
```

### Per-Feature Pipeline Detail

```
pipeline F00X
  │
  ├── 1. constitution ──→ injection/constitution.md ──→ .specify/memory/constitution.md
  ├── 2. specify ───────→ injection/specify.md ──────→ specs/{FID}/spec.md
  ├── 3. plan ──────────→ injection/plan.md ─────────→ specs/{FID}/plan.md
  ├── 4. tasks ─────────→ injection/tasks.md ────────→ specs/{FID}/tasks.md
  ├── 5. implement ─────→ injection/implement.md ────→ source code
  └── 6. verify ────────→ injection/verify.md ───────→ verify-phases.md → sub-phases
                                                        ├── verify-preflight.md
                                                        ├── verify-build-test.md
                                                        ├── verify-sc-verification.md
                                                        ├── verify-sc-rebuild.md
                                                        ├── verify-cross-feature.md
                                                        └── verify-evidence-update.md
```

---

## 3. Domain Module Hierarchy

```mermaid
graph TB
    DP["Domain Profile<br/>(5 axes)"]

    DP --> A1["Axis 1: Interface"]
    DP --> A2["Axis 2: Concern"]
    DP --> A3["Axis 3: Archetype"]
    DP --> A4["Axis 4: Foundation"]
    DP --> A5["Axis 5: Context"]

    A1 --> I1["gui"] & I2["http-api"] & I3["cli"] & I4["data-io"] & I5["tui"] & I6["mobile"] & I7["library"] & I8["embedded"] & I9["grpc"] & I10["k8s-api"]

    A2 --> C_GRP1["Core: auth, authorization, async-state, audit-logging, i18n, ipc, offline-sync, realtime, graceful-lifecycle, observability"]
    A2 --> C_GRP2["Integration: external-sdk, message-queue, task-worker, plugin-system, connection-pool, push-notification"]
    A2 --> C_GRP3["Code: codegen, polyglot, multi-tenancy, infra-as-code, compliance"]
    A2 --> C_GRP4["Protocol: protocol-integration, llm-agents, hardware-io, webrtc, tls-management, schema-registry, cryptography, udp-transport, iot-protocol"]
    A2 --> C_GRP5["Domain: cqrs, distributed-consensus, dag-orchestration, ecs, wire-protocol, k8s-operator, gpu-compute, resilience, content-moderation, geospatial, media-streaming, payment-processing, scheduling-algorithm, search-engine, simulation-engine, speech-processing, stream-processing"]

    A3 --> AR1["ai-assistant"] & AR2["public-api"] & AR3["microservice"] & AR4["sdk-framework"]
    A3 --> AR5["database-engine"] & AR6["network-server"] & AR7["message-broker"]
    A3 --> AR8["game-engine"] & AR9["browser-extension"] & AR10["infra-tool"]
    A3 --> AR11["cache-server"] & AR12["compiler"] & AR13["inference-server"] & AR14["media-server"] & AR15["workflow-engine"]

    A4 --> F_GRP["40 Foundation files<br/>(framework-specific rules)"]

    A5 --> CM["Context Modes"]
    A5 --> CS["Context Scale"]
    A5 --> CMod["Context Modifiers"]

    CM --> S1["greenfield"] & S2["rebuild"] & S3["incremental"] & S4["adoption"]
    CMod --> CX["migration<br/>(M0-M4 framework)"]
```

### Module File Distribution

```
shared/domains/           ← Signal keywords (S0/A0) + Code patterns (R1)
  interfaces/ (10)          gui, http-api, cli, data-io, tui, mobile, library, embedded, grpc, k8s-api
  concerns/ (47)            auth, async-state, i18n, ... webrtc, cryptography, udp-transport
  archetypes/ (15)          ai-assistant, public-api, ... inference-server, workflow-engine
  contexts/ (1)             migration
  _taxonomy.md              Single source of truth for all modules

reverse-spec/domains/     ← Analysis rules (R3-R5)
  interfaces/ (10)          R3 analysis axes per interface
  concerns/ (48)            R3 Feature boundary + R4 data flow rules
  archetypes/ (15)          R3 extraction patterns
  contexts/ (1)             R3 migration Feature boundary + R5 scope estimation
  foundations/ (40+2)       Framework-specific detection stubs (F0-F9)
  _core.md                  R2 project types, R5 Feature boundary heuristics

smart-sdd/domains/        ← Pipeline rules (S1/S5/S7)
  interfaces/ (10)          SC rules, elaboration probes, bug prevention
  concerns/ (48)            SC rules, elaboration probes, bug prevention
  archetypes/ (15)          Domain philosophy, elaboration probes
  profiles/ (15)            Pre-configured axis combinations
  contexts/modes/ (4)       greenfield, rebuild, incremental, adoption
  contexts/modifiers/ (1)   migration (S1/S3/S5/S7 pipeline rules)
  _resolver.md              7-step module loading order

specs/domains/              ← Project-local custom modules (created by /domain-extend)
  {name}.md                   Single-file format (all S/A/R/F sections in one file)
                              Committed to git, isolated per project
                              Resolver scans at Step 6b (after built-in, before org)
```

---

## 4. File Inventory

### Root Files

| File | Purpose |
|------|---------|
| `README.md` | English project introduction, Scenario Guide (S1-S9), architecture overview |
| `README.ko.md` | Korean mirror of README.md |
| `ARCHITECTURE-EXTENSIBILITY.md` | Detailed extensibility guide, cross-reference map |
| `ARCHITECTURE-EXTENSIBILITY.ko.md` | Korean mirror |
| `FILE-MAP.md` | This file — complete file inventory and relationship diagrams |
| `CLAUDE.md` | Project rules, design principles, review protocol |
| `history.md` | Design decision history |
| `lessons-learned.md` | Failure patterns and countermeasures |
| `PLAYWRIGHT-GUIDE.md` | Playwright setup guide for UI verification |
| `SCENARIO-CATALOG.md` | Scenario catalog (EN) — 38 scenarios across 10 categories |
| `SCENARIO-CATALOG.ko.md` | Scenario catalog (KO) — Korean mirror |
| `SOFTWARE-CATALOG.md` | Target project types catalog with code-explore simulation results |
| `.gitignore` | Git ignore rules (worktrees, LaTeX artifacts, .DS_Store) |
| `install.sh` | Symlink installer for skills → ~/.claude/skills/ |
| `publications/` | Medium articles (part1-4, EN/KO) + Technical Reference Manual (EN/KO PDF) |

### reverse-spec (98 files)

| Category | Files | Description |
|----------|-------|-------------|
| **Entry** | `SKILL.md` | Skill router — argument parsing, phase dispatch |
| **Commands** | | |
| `commands/analyze.md` | Phase orchestrator — routes to sub-phases |
| `commands/analyze-scan.md` | Phase 1: File extension scan, language detection |
| `commands/analyze-deep.md` | Phase 2: Deep analysis, SBI extraction, multi-language table |
| `commands/analyze-classify.md` | Phase 3: Feature boundary detection, Tier classification |
| `commands/analyze-runtime.md` | Phase 1.5: Runtime exploration (Playwright), UI flow capture |
| `commands/analyze-generate.md` | Phase 4-5: Artifact generation, completion report |
| **Domains — Core** | | |
| `domains/_core.md` | R2 project types, R5 Feature boundary heuristics |
| `domains/_schema.md` | Module file format specification |
| `domains/app.md` | Domain Profile for analysis (reverse-spec-specific) |
| `domains/data-science.md` | Data science domain extensions (TODO scaffolding) |
| **Domains — Interfaces** (10) | `domains/interfaces/{gui,http-api,cli,data-io,tui,mobile,library,embedded,grpc,k8s-api}.md` | R3 analysis axes per interface type |
| **Domains — Concerns** (47) | `domains/concerns/*.md` | R3 Feature boundary + R4 data flow per concern |
| **Domains — Archetypes** (15) | `domains/archetypes/*.md` | R3 extraction patterns |
| **Domains — Contexts** (1) | `domains/contexts/migration.md` | R3-R5 migration impact analysis |
| **Domains — Foundations** (40+2) | `domains/foundations/*.md` | Framework-specific F0-F9 detection rules |
| ↳ Full frameworks | `actix-web, bun, django, dotnet, electron, erlang-otp, express, fastapi, flask, flutter, go, go-chi, hono, laravel, nestjs, nextjs, phoenix, python, rails, react-native, rust-cargo, solidjs, spring-boot, tauri, vite-react` | Comprehensive F1-F9 rules |
| ↳ Detection stubs | `android-native, angular, chrome-extension, cmake, gtk, makefile, nuxt, qt, remix, spring-framework, svelte, swift-spm, symfony, typescript, wordpress` | F0 detection + Architecture Notes |
| ↳ Meta | `_foundation-core.md, _TEMPLATE.md` | Core detection signals, contributor template |
| **Reference** (1) | `reference/speckit-compatibility.md` | reverse-spec → spec-kit command mapping |
| **Templates** (10) | `templates/*.md` | Artifact templates: roadmap, constitution-seed, entity/api/business-logic registries, coverage-baseline, pre-context, spec-draft, speckit-prompt, stack-migration |

### smart-sdd (107 files)

| Category | Files | Description |
|----------|-------|-------------|
| **Entry** | `SKILL.md` | Skill router — command dispatch, MANDATORY RULES |
| **Commands** | | |
| `commands/init.md` | Project initialization, Domain Profile setup |
| `commands/add.md` | Feature addition, 6-Phase Briefing |
| `commands/adopt.md` | SDD adoption of existing code, 4-step workflow |
| `commands/pipeline.md` | Pipeline orchestrator — 6-step Feature execution |
| `commands/status.md` | Pipeline status display |
| `commands/coverage.md` | SBI coverage analysis |
| `commands/parity.md` | Structural/logic parity check |
| `commands/expand.md` | Feature expansion (split/merge) |
| `commands/reset.md` | Pipeline state reset |
| **Verify Sub-commands** (7) | | |
| `commands/verify-phases.md` | Verify phase orchestrator (Phase 0-4) |
| `commands/verify-preflight.md` | Phase 0: Playwright availability check |
| `commands/verify-build-test.md` | Phase 1: Build + TypeScript + Lint |
| `commands/verify-sc-verification.md` | Phase 2: SC verification against running app |
| `commands/verify-sc-rebuild.md` | Phase 3: Rebuild-specific SC verification |
| `commands/verify-cross-feature.md` | Phase 3e: Cross-Feature interface verification |
| `commands/verify-evidence-update.md` | Phase 4: Evidence collection + state update |
| **Domains — Core** | | |
| `domains/_core.md` | smart-sdd-specific core rules |
| `domains/_resolver.md` | 7-step module loading order |
| `domains/_schema.md` | Module file format specification |
| `domains/app.md` | Domain Profile for execution (smart-sdd-specific) |
| `domains/data-science.md` | Data science domain extensions (TODO scaffolding) |
| **Domains — Interfaces** (10) | `domains/interfaces/{gui,http-api,cli,data-io,tui,mobile,library,embedded,grpc,k8s-api}.md` | SC rules, elaboration probes, bug prevention |
| **Domains — Concerns** (47) | `domains/concerns/*.md` | SC rules, elaboration probes, bug prevention |
| **Domains — Archetypes** (15) | `domains/archetypes/*.md` | Domain philosophy (A1), SC extensions (A2), probes (A3), constitution (A4), brief criteria (A5) |
| **Domains — Profiles** (15) | `domains/profiles/*.md` | Pre-configured axis combinations |
| **Domains — Context Modes** (4) | `domains/contexts/modes/{greenfield,rebuild,incremental,adoption}.md` | Context mode-specific pipeline rules |
| **Reference** | | |
| `reference/context-injection-rules.md` | Master injection rules — loading order, Scale/Cross-Concern enforcement |
| `reference/context-injection-degradation.md` | Missing/Sparse artifact handling table (lazy-loaded) |
| `reference/context-injection-budget.md` | Context budget protocol — priority tiers, overflow, heuristics (lazy-loaded) |
| `reference/pipeline-integrity-guards.md` | 7 guards (G1-G7) for pipeline safety |
| `reference/state-schema.md` | sdd-state.md schema definition |
| `reference/cascading-update.md` | Cross-Feature cascading update rules |
| `reference/clarity-index.md` | Spec clarity scoring system |
| `reference/demo-standard.md` | Demo-ready delivery standards |
| `reference/branch-management.md` | Git branch management for Features |
| `reference/restructure-guide.md` | Feature split/merge procedures |
| `reference/runtime-verification.md` | Runtime verification procedures |
| `reference/ui-flow-spec.md` | UI Flow Specification format |
| `reference/ui-testing-integration.md` | UI testing integration guide |
| `reference/user-cooperation-protocol.md` | User cooperation protocol |
| `reference/feature-elaboration-framework.md` | 6-perspective Feature evaluation |
| `reference/archetype-verify-strategies.md` | Per-archetype verify extensions (start pre-conditions, health checks, SC categories) |
| `reference/known-limitations.md` | Known limitations (L1-L7) with recovery paths |
| **Injection Files** (11) | | |
| `reference/injection/constitution.md` | Constitution step context injection |
| `reference/injection/specify.md` | Specify step context injection |
| `reference/injection/plan.md` | Plan step context injection |
| `reference/injection/tasks.md` | Tasks step context injection |
| `reference/injection/implement.md` | Implement step context injection |
| `reference/injection/verify.md` | Verify step context injection |
| `reference/injection/analyze.md` | Analyze step context injection |
| `reference/injection/adopt-specify.md` | Adoption specify injection |
| `reference/injection/adopt-plan.md` | Adoption plan injection |
| `reference/injection/adopt-verify.md` | Adoption verify injection |
| `reference/injection/parity.md` | Parity check injection |
| **Scripts** (7) | | |
| `scripts/context-summary.sh` | Context window usage summary |
| `scripts/sbi-coverage.sh` | SBI coverage calculator |
| `scripts/demo-status.sh` | Demo group progress tracker |
| `scripts/pipeline-status.sh` | Pipeline progress display |
| `scripts/validate.sh` | Artifact validation |
| `scripts/semantic-stub-check.sh` | Semantic stub detector (Math.random, placeholder text) |
| `scripts/wiring-check.sh` | Wiring integrity checker (IPC/API audit) |
| **Templates** (3) | | |
| `templates/domain-profile-instance-template.md` | Domain Profile Instance artifact template (4th GEL registry) |
| `templates/project-domains-readme.md` | Project-local domains README template (specs/domains/ listing) |
| `templates/verify-report-template.md` | Verify report template — per-SC evidence, demo execution, merge readiness (generated at verify completion) |

### shared (50 files)

| Category | Files | Description |
|----------|-------|-------------|
| **Domains — Taxonomy** | `domains/_taxonomy.md` | Single source of truth for all module listings |
| **Domains — Schema** | `domains/_schema.md` | Shared module section schema (S0/A0 keywords, R1 code patterns, M0-M4 modifiers) |
| **Domains — Template** | `domains/_TEMPLATE.md` | Contributor template for new modules |
| **Domains — Interfaces** (10) | `domains/interfaces/{gui,http-api,cli,data-io,tui,mobile,library,embedded,grpc,k8s-api}.md` | S0 keywords + R1 code patterns |
| **Domains — Concerns** (47) | `domains/concerns/*.md` | S0 keywords + R1 code patterns |
| **Domains — Archetypes** (15) | `domains/archetypes/*.md` | A0 semantic + code patterns |
| **Domains — Contexts** (1) | `domains/contexts/migration.md` | M0-M4 migration framework |
| **Runtime** (6) | `runtime/*.md` | Cross-skill runtime modules |
| **Reference** (1) | `reference/completion-report.md` | Auto-Report template (3 modes, 10 sections) |

### code-explore (5 files)

| File | Description |
|------|-------------|
| `SKILL.md` | Skill router — interactive exploration dispatch |
| `commands/orient.md` | Codebase orientation — entry points, architecture |
| `commands/trace.md` | Feature flow tracing with Mermaid diagrams |
| `commands/synthesis.md` | Understanding synthesis — architecture map, Feature candidates |
| `commands/status.md` | Exploration progress display |

### domain-extend (16 files)

| Category | Files | Description |
|----------|-------|-------------|
| **Entry** | `SKILL.md` | Skill router — command dispatch, MANDATORY RULES |
| **Commands** | | |
| `commands/browse.md` | Interactive exploration of the module system (overview, axis, keyword, detail, compare, active) |
| `commands/detect.md` | Auto-detect domain profile from existing codebase |
| `commands/extend.md` | Create new domain modules (interface, concern, archetype, foundation, context modifier) |
| `commands/import.md` | Import external documents (ADR, style guide, postmortem) as org-conventions |
| `commands/customize.md` | Create project-level or org-level convention overrides |
| `commands/validate.md` | Validate module structure, taxonomy sync, cross-concern rules |
| **Reference** (2) | | |
| `reference/import-mappings.md` | Document type detection signals and extraction rules for import |
| `reference/module-templates.md` | Detailed module authoring guide with section-by-section instructions |
| **Templates** (7) | | |
| `templates/interface-template.md` | Template for new Interface modules (S0-S9) |
| `templates/concern-template.md` | Template for new Concern modules (S0-S9) |
| `templates/archetype-template.md` | Template for new Archetype modules (A0-A5) |
| `templates/foundation-template.md` | Template for new Foundation modules (F0-F9) |
| `templates/context-modifier-template.md` | Template for new Context Modifier modules (M0-M4) |
| `templates/profile-template.md` | Template for new Profile manifests |
| `templates/org-convention-template.md` | Template for organization-level conventions |

---

## 5. Cross-Skill Dependencies

```
shared/domains/          ← Read by both reverse-spec and smart-sdd
  ├── S0/A0 keywords     ← smart-sdd init (inference)
  └── R1 code patterns   ← reverse-spec analyze (source scan)

reverse-spec/domains/    ← Read by smart-sdd for Foundation data
  └── foundations/*.md   ← smart-sdd _resolver.md Step 4b (F2+F3 rules)

shared/runtime/          ← Read by both skills for app lifecycle
  ├── playwright-detection.md  ← verify-preflight.md
  ├── app-launch.md            ← verify-phases.md, analyze-runtime.md
  └── data-storage-map.md      ← verify-sc-verification.md

shared/reference/        ← Read by pipeline endpoints
  └── completion-report.md  ← analyze-generate.md, pipeline.md, adopt.md

domain-extend/           ← Manages shared/domains/ module lifecycle
  ├── browse              ← reads _taxonomy.md, module files
  ├── extend              ← writes new modules to shared/, reverse-spec/, smart-sdd/
  ├── validate            ← checks taxonomy sync, schema compliance
  └── import/customize    ← creates org-convention, domain-custom files

code-explore/ → reverse-spec/ → smart-sdd/  (data flows left to right)
  explore artifacts → reverse-spec artifacts → smart-sdd pipeline
```

---

## 6. Injection File Loading Order

When a Feature enters a pipeline step, `context-injection-rules.md` orchestrates loading:

```
Step: specify F001
  │
  ├── P0: Always load
  │   ├── roadmap.md
  │   ├── sdd-state.md
  │   └── constitution.md
  │
  ├── P1: Domain Profile modules
  │   ├── shared/domains/interfaces/{active}.md
  │   ├── shared/domains/concerns/{active}.md
  │   ├── shared/domains/archetypes/{active}.md
  │   └── reverse-spec/domains/foundations/{framework}.md
  │
  ├── P2: Feature context
  │   ├── pre-context.md (Feature-specific sections)
  │   ├── business-logic-map.md (relevant rules)
  │   ├── preceding Feature stubs/interaction-surfaces
  │   └── stack-migration.md (if rebuild+new-stack)
  │
  └── P3: Step-specific injection
      └── reference/injection/specify.md
```
