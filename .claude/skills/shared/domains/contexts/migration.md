# Context: migration

> Change context for modernization, migration, and version upgrades — from security hotfixes to platform-level rewrites.

**Context modules differ from Concerns**: Concerns describe what the app *does* (auth, i18n, real-time). Contexts describe what you're *doing to* the app (migrating, optimizing, securing). Contexts modify pipeline depth and activate relevant Concern/Foundation modules dynamically.

---

## M0: Migration Signal Detection

Signals that indicate a migration or modernization task is in progress or needed.

### Dependency Signals

- **Version bump in lockfile**: `package-lock.json`, `yarn.lock`, `Gemfile.lock`, `poetry.lock`, `go.sum`, `Cargo.lock` show major version changes
- **Deprecated API usage**: compiler warnings, `@deprecated` annotations, `console.warn("deprecated")` patterns
- **EOL runtime**: Node.js < LTS, Python 2.x, Java 8 (Oracle EOL), Ruby < 3.0
- **Security advisory match**: CVE references in `npm audit`, `pip-audit`, `cargo audit`, `bundler-audit`, Dependabot alerts

### Infrastructure Signals

- **DB version mismatch**: `docker-compose.yml` image tags vs production version
- **Cloud SDK deprecation**: AWS SDK v2 → v3, GCP client library updates
- **Build tool age**: Webpack 4 (EOL), Gulp, Grunt, legacy Babel configs
- **CI/CD deprecation**: Travis CI, CircleCI 2.0, deprecated GitHub Actions

### Code Signals

- **Compatibility shims**: polyfills, version-conditional code (`if (version >= X)`), adapter layers
- **Mixed patterns**: old and new API usage coexisting (e.g., class components + hooks, Options API + Composition API)
- **Migration TODOs**: `// TODO: migrate`, `# FIXME: deprecated`, `@deprecated` in own code

---

## M1: Scale Classification

Classify migration scale to determine pipeline depth.

| Scale | Trigger | Time Pressure | Pipeline Depth | Examples |
|-------|---------|---------------|----------------|----------|
| **Hotfix** | CVE, security audit, critical bug in dependency | Hours | Impact analysis + targeted fix only | log4j 2.14→2.17, lodash prototype pollution, OpenSSL patch |
| **Patch** | Bug fix, minor version bump, type fix | Days | Lightweight specify + implement + verify | React 18.2→18.3, axios 1.6→1.7, TypeScript patch |
| **Minor** | Feature addition in dep, deprecation warning response | Weeks | specify + plan + implement + verify | Next.js 14→15, TypeScript 5.3→5.5, Node 18→20 |
| **Major** | Breaking changes, major version, framework swap | Months | Full pipeline (specify → plan → tasks → implement → verify) | React 16→18, Vue 2→3, Python 2→3, AngularJS→Angular |
| **Platform** | Infrastructure/platform wholesale replacement | Quarters | Full pipeline + phased rollout plan | Heroku→AWS, on-prem→k8s, REST→GraphQL, monolith→microservice |

### Scale Detection Heuristics

```
IF security advisory OR CVE → Hotfix
ELSE IF same major version, patch/minor bump only → Patch
ELSE IF same major version, new features/deprecations → Minor
ELSE IF major version change OR library swap (same purpose) → Major
ELSE IF infrastructure/platform change OR architecture change → Platform
```

---

## M2: Target Layer Classification

What is being changed. Each layer has different impact patterns.

| Target Layer | Impact Pattern | Data Migration? | Rollback Complexity |
|-------------|---------------|-----------------|---------------------|
| **Library/Package** | Import paths, API calls, type signatures | No | Low — revert lockfile |
| **Framework** | Component patterns, lifecycle hooks, config files | No | Medium — code patterns changed |
| **Language/Runtime** | Syntax, stdlib, build chain, type system | No | Medium — build chain change |
| **ORM/Query Layer** | Repository/DAO code, query syntax, model definitions | Schema possible | Medium — data access rewrite |
| **DB Engine (same vendor)** | Config, deprecated features, query optimizer behavior | Usually no | Low — version rollback |
| **DB Engine (vendor swap)** | Schema translation, query rewrite, driver change | Yes — full | High — data conversion needed |
| **Cache/Queue** | Client code, config, serialization format | State loss possible | Medium — stateful rollback |
| **Auth/Security** | Token format, middleware, redirect flows, TLS config | Token invalidation | High — security-critical |
| **Build/Tooling** | Config files, plugin ecosystem, CI scripts | No | Low — config-only |
| **OS/Container** | Dockerfile, system deps, CI images, runtime behavior | No | Low — image tag revert |
| **Cloud Service** | SDK calls, IAM, deployment scripts, architecture patterns | Possible | High — vendor lock-in |

---

## M3: Impact Assessment Framework

### M3-a: Code Impact

- **Direct dependencies**: Files that directly import/use the migrating component
- **Transitive dependencies**: Files that depend on direct dependents (call chain depth)
- **Configuration impact**: Config files, environment variables, build scripts
- **Test impact**: Which test suites exercise the affected code paths

### M3-b: Data Impact

Activated when Target Layer involves data (DB, ORM, Cache, Queue, Auth).

| Aspect | Questions |
|--------|-----------|
| **Schema compatibility** | Does the target version support current schema? Type mapping differences? |
| **Data transformation** | Is data format conversion needed? Lossy or lossless? |
| **Migration strategy** | Big-bang vs dual-write vs CDC (Change Data Capture)? |
| **Volume & downtime** | Data volume? Acceptable downtime window? Online migration feasible? |
| **Rollback data path** | Can data be converted back? Point-in-time recovery available? |
| **Referential integrity** | Foreign keys, indexes, constraints preserved? |

### M3-c: Infrastructure Impact

- **Deployment change**: New deploy steps, config changes, environment variables
- **Monitoring**: New metrics, changed log formats, alert threshold adjustments
- **Dependency chain**: Other services that depend on the component being migrated
- **Rollback mechanism**: Blue/green, canary, feature flags, DNS cutover

### M3-d: Risk Matrix

```
             Low Data Impact          High Data Impact
           ┌──────────────────────┬──────────────────────┐
Low Code   │ GREEN                │ YELLOW               │
Impact     │ Config-only changes  │ Data migration needed │
           │ Patch, Build/Tool    │ DB minor version      │
           ├──────────────────────┼──────────────────────┤
High Code  │ YELLOW               │ RED                  │
Impact     │ Framework swap       │ DB vendor swap +      │
           │ Language upgrade     │ ORM rewrite           │
           └──────────────────────┴──────────────────────┘
```

---

## M4: Pipeline Depth Modifier

Migration Context modifies pipeline behavior based on Scale (M1).

### Hotfix Mode (specify-only)

```
Skip: plan, tasks (no time for detailed planning)
Focus:
  1. Impact analysis — what files/functions use the vulnerable component
  2. Targeted spec — minimal change definition
  3. Implement — apply fix
  4. Targeted verify — test affected code paths only
Record: Log in history.md for future full-pipeline alignment
```

### Patch Mode (lightweight pipeline)

```
Reduce: plan is a single paragraph, tasks is a flat checklist
Focus:
  1. Specify — migration scope + breaking change checklist
  2. Plan — simple before/after comparison
  3. Implement — apply changes
  4. Verify — regression test on affected Features
```

### Minor/Major/Platform Mode (full pipeline)

```
Full pipeline with migration-specific additions:
  specify — Include migration impact assessment (M3)
  plan    — Include migration strategy, phased rollout if applicable
  tasks   — Include data migration steps if M3-b applies
  implement — Standard implementation
  verify  — Include rollback verification, data integrity checks
```

### SDD State Modifier

When no SDD documentation exists (Case B), prepend a documentation phase:

| Scale + SDD State | Pre-pipeline Action |
|-------------------|-------------------|
| Hotfix + No SDD | Targeted scan only (affected component + its callers). Record findings for future adopt. |
| Patch + No SDD | Partial adopt (affected scope). Document only impacted Features. |
| Minor + No SDD | Partial adopt (affected scope + adjacent Features for context). |
| Major + No SDD | Full adopt first, then migration Features via add --gap. |
| Platform + No SDD | Full reverse-spec + adopt, then phased migration Features. |

---

## Module Metadata

- **Type**: Context (change context, not app characteristic)
- **Activates Concerns**: Depends on Target Layer — DB migration activates `data-io`, auth migration activates `auth`, infra migration activates `infra-as-code` + `k8s-operator`
- **Activates Foundations**: Target framework's Foundation module (e.g., migrating to Angular activates `angular.md`)
- **Common scenarios**: S6 (Modernization / Migration)
- **Future contexts**: `performance` (optimization), `compliance` (regulatory), `security-hardening` (proactive security)
