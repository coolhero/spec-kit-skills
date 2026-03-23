# Foundation: Erlang/OTP
<!-- Format: _foundation-core.md | ID prefix: ER (see § F4) -->

## F0. Detection Signals

- `rebar.config` in root (rebar3 build tool)
- OR `.app.src` files + `-behaviour(application)` declarations
- `.erl` source files present
- No Mix/Elixir files (those use `phoenix.md` or future `elixir.md`)

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | 3 | OTP application tree, project structure, boot sequence |
| SEC | Security | 3 | TLS config, node security, cookie management |
| PKG | Package Management | 3 | rebar3, hex deps, Elixir interop |
| TST | Testing | 3 | EUnit, Common Test, property-based testing |
| BLD | Build & Release | 3 | Release assembly, sys.config, vm.args |
| SUP | Supervision | 3 | Supervision trees, restart strategies, child specs |
| MSG | Message Passing | 3 | gen_server, gen_statem, process registries |
| DIS | Distribution | 3 | Distributed Erlang, global registry, net_kernel |
| FMT | Code Quality | 3 | Dialyzer, elvis, xref |
| LOG | Logging | 2 | Logger module, handler configuration |
| DXP | Developer Experience | 3 | Observer, recon, hot code loading |

---

## F2. Foundation Items

### BST: App Bootstrap

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-BST-01 | Application structure | OTP application callback module layout | choice (single-app / umbrella / release) | Critical |
| ER-BST-02 | Project structure | Directory layout convention | choice (rebar3-default / custom-apps / umbrella-apps) | Critical |
| ER-BST-03 | Boot sequence | How the application starts | choice (application-start / release-boot / escript) | Important |

### SEC: Security

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-SEC-01 | TLS configuration | SSL/TLS settings for distribution and listeners | config | Critical |
| ER-SEC-02 | Node security | Erlang cookie and distribution access control | config | Critical |
| ER-SEC-03 | Cookie management | How Erlang cookies are distributed and rotated | choice (static-file / env-var / vault) | Important |

### PKG: Package Management

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-PKG-01 | Build tool | Primary build tool | choice (rebar3 / erlang.mk / mix) | Critical |
| ER-PKG-02 | Dependency source | Where dependencies come from | choice (hex.pm / git / path) | Important |
| ER-PKG-03 | Elixir interop | Whether Elixir dependencies are used | binary | Important |

### TST: Testing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-TST-01 | Unit testing | Primary unit test framework | choice (eunit / common-test) | Critical |
| ER-TST-02 | Integration testing | System-level test approach | choice (common-test-suites / shell-scripts / none) | Important |
| ER-TST-03 | Property testing | Property-based testing tool | choice (proper / triq / none) | Important |

### BLD: Build & Release

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-BLD-01 | Release tool | Release assembly method | choice (relx / rebar3-release / systools) | Critical |
| ER-BLD-02 | Runtime config | Runtime configuration format | choice (sys.config / config-provider / custom) | Critical |
| ER-BLD-03 | VM arguments | vm.args configuration strategy | config | Important |

### SUP: Supervision

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-SUP-01 | Supervision tree | Top-level supervisor structure | config | Critical |
| ER-SUP-02 | Restart strategy | Default supervisor restart strategy | choice (one_for_one / one_for_all / rest_for_one / simple_one_for_one) | Critical |
| ER-SUP-03 | Child spec defaults | Default child spec intensity and period | config | Important |

### MSG: Message Passing

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-MSG-01 | Server pattern | Primary behaviour for stateful processes | choice (gen_server / gen_statem / custom) | Critical |
| ER-MSG-02 | Event handling | Event notification pattern | choice (gen_event / pg-pubsub / custom) | Important |
| ER-MSG-03 | Process registry | How processes are named/found | choice (local-registered / global / gproc / pg) | Important |

### DIS: Distribution

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-DIS-01 | Distribution mode | Whether distributed Erlang is used | choice (distributed / standalone) | Critical |
| ER-DIS-02 | Node discovery | How nodes find each other | choice (static-config / dns / epmd / k8s-headless) | Important |
| ER-DIS-03 | Global registry | Cross-node process registry | choice (global / pg / partisan / none) | Important |

### FMT: Code Quality

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-FMT-01 | Dialyzer | Whether Dialyzer is used for type analysis | binary | Critical |
| ER-FMT-02 | Style checker | Code style enforcement | choice (elvis / erlfmt / none) | Important |
| ER-FMT-03 | Cross-reference | Whether xref is used for dead code detection | binary | Important |

### LOG: Logging

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-LOG-01 | Logger backend | Logging module and handlers | choice (kernel-logger / lager / custom) | Important |
| ER-LOG-02 | Log format | Log output format | choice (default / json / custom-formatter) | Important |

### DXP: Developer Experience

| ID | Item | Description | Decision Type | Priority |
|----|------|-------------|--------------|----------|
| ER-DXP-01 | Runtime inspection | Production debugging tools | choice (observer / recon / redbug) | Important |
| ER-DXP-02 | Hot code loading | Whether hot code upgrade is supported | choice (relup / manual / disabled) | Important |
| ER-DXP-03 | Shell tools | Development shell enhancements | choice (user_default / rebar3-shell / none) | Important |

---

## F3. Extraction Rules (reverse-spec)

| Category | Extraction Method |
|----------|------------------|
| BST | Read rebar.config for app structure. Check for `_app.erl` callback modules. Look for release config. |
| SEC | Search for ssl options in sys.config. Check for `-setcookie` in vm.args. |
| PKG | Read rebar.config deps section. Check for `{plugins, [{rebar3_hex}]}`. Look for mix.exs interop. |
| TST | Search for `-include_lib("eunit/include/eunit.hrl")`. Check test/ for ct suites. Look for PropEr imports. |
| BLD | Read relx config in rebar.config. Check sys.config and vm.args files. |
| SUP | Search for `-behaviour(supervisor)` modules. Read init/1 return for strategy. Check child specs. |
| MSG | Search for `-behaviour(gen_server)` and `-behaviour(gen_statem)`. Check process registration calls. |
| DIS | Check vm.args for `-name`/`-sname`. Search for `net_kernel`, `global`, `pg` usage. |
| FMT | Check rebar.config for dialyzer and elvis plugins. Search for xref in CI config. |
| LOG | Read sys.config for `kernel` logger config. Search for lager imports. |
| DXP | Check for appup/relup files. Search for observer/recon in deps. |

---

## F4. T0 Feature Grouping

| T0 Feature | Foundation Categories | Items |
|------------|----------------------|-------|
| F000-otp-bootstrap-pkg | BST + PKG | 6 |
| F000-supervision-messaging | SUP + MSG | 6 |
| F000-security-distribution | SEC + DIS | 6 |
| F000-build-release | BLD | 3 |
| F000-testing-quality | TST + FMT | 6 |
| F000-logging-devexp | LOG + DXP | 5 |

---

## F7. Framework Philosophy

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Let it crash** | Processes are designed to fail and restart cleanly — defensive coding inside a process is minimized in favor of supervisor recovery | Don't catch unexpected errors; let the supervisor restart the process; design processes to recover from a clean initial state; crash reports are primary debugging artifacts |
| **Isolation through processes** | Each process has its own heap, mailbox, and failure domain — no shared mutable state | All inter-process communication via message passing; no global mutable state; process failure cannot corrupt another process; design around process boundaries |
| **Fault tolerance by design** | The supervision tree is the architectural backbone — every process has a supervisor with a defined restart strategy | one_for_one for independent children; rest_for_one for dependent chains; set restart intensity to prevent cascading failures; supervision is not optional |
| **Hot code upgrades** | Running systems can be upgraded without stopping — appup/relup files describe state migration | Design gen_server state to be version-aware; test code_change/3 callbacks; plan for mixed-version clusters during rolling deploys |
