# Foundation: Rails
<!-- Format: _foundation-core.md | ID prefix: RL (see § F4) -->

> Server framework Foundation for Ruby projects using Ruby on Rails.
> Convention-over-configuration framework with MVC, ActiveRecord, and rich CLI generators.

---

## F0. Detection Signals

| Signal | Confidence |
|--------|-----------|
| `rails` in Gemfile | HIGH |
| `config/application.rb` with `Rails::Application` | HIGH |
| `bin/rails` executable | HIGH |
| `config/routes.rb` with `draw do` block | MEDIUM |

---

## F1. Categories

| Code | Category | Description |
|------|----------|-------------|
| BST | App Bootstrap | application.rb, initializers, Zeitwerk autoloading |
| SEC | Security | Devise, has_secure_password, CSRF, credentials.yml.enc |
| MID | Middleware | Rack middleware stack, before_action callbacks, concerns |
| API | API Design | routes.rb resources, API-only mode, serializers (jbuilder/Alba/AMS) |
| DBS | Database | ActiveRecord, multi-DB, migration strategy, connection pool |
| PRC | Process Management | Puma config, Sidekiq/GoodJob integration, Procfile |
| HLT | Health Check | Rails health endpoint, custom health checks |
| ERR | Error Handling | rescue_from, exception handler middleware, error pages |
| LOG | Logging | Rails.logger, tagged logging, Lograge for structured logs |
| TST | Testing | RSpec vs Minitest, FactoryBot, fixtures, system tests, VCR |
| BLD | Build & Deploy | Asset pipeline (Propshaft/Sprockets), Docker, Kamal, Capistrano |
| ENV | Environment Config | Rails environments, credentials, dotenv-rails |
| DXP | Developer Experience | Rails console, generators, Hotwire/Turbo/Stimulus |

---

## F2. Decision Items

### BST — App Bootstrap
| ID | Item | Priority | Question |
|----|------|----------|----------|
| RL-BST-01 | Rails mode | Critical | Full Rails or API-only (`rails new --api`)? |
| RL-BST-02 | Ruby version | Critical | Ruby version? `.ruby-version` management? |
| RL-BST-03 | Autoloading | Important | Zeitwerk (default) conventions followed? Custom inflections? |

### SEC — Security
| ID | Item | Priority | Question |
|----|------|----------|----------|
| RL-SEC-01 | Auth gem | Critical | Devise? has_secure_password? OmniAuth? |
| RL-SEC-02 | Credentials | Important | `credentials.yml.enc` or ENV variables? Per-environment credentials? |
| RL-SEC-03 | CSRF | Important | Standard CSRF? Token-based API auth exempt? |

### API — API Design
| ID | Item | Priority | Question |
|----|------|----------|----------|
| RL-API-01 | Route style | Critical | `resources` RESTful? Namespace versioning (`/api/v1/`)? |
| RL-API-02 | Serializer | Important | jbuilder? Alba? ActiveModel::Serializer? Blueprinter? |
| RL-API-03 | Pagination | Important | Kaminari? Pagy? will_paginate? |

### DBS — Database
| ID | Item | Priority | Question |
|----|------|----------|----------|
| RL-DBS-01 | Database | Critical | PostgreSQL? MySQL? SQLite? |
| RL-DBS-02 | Multi-DB | Optional | Read replica? Multiple databases? |
| RL-DBS-03 | Migration naming | Important | Timestamp-based (default)? Squash policy? |

### TST — Testing
| ID | Item | Priority | Question |
|----|------|----------|----------|
| RL-TST-01 | Framework | Critical | RSpec or Minitest? |
| RL-TST-02 | Fixtures | Important | FactoryBot? Rails fixtures? Faker? |
| RL-TST-03 | System tests | Optional | Capybara + Selenium? Playwright? |

### BLD — Build & Deploy
| ID | Item | Priority | Question |
|----|------|----------|----------|
| RL-BLD-01 | Deploy tool | Important | Kamal? Capistrano? Docker? Heroku? |
| RL-BLD-02 | Asset pipeline | Important | Propshaft (default 7+)? Sprockets? Vite Ruby? |

---

## F7. Philosophy

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Convention over Configuration** | File naming, directory structure, database table names follow conventions | Don't rename tables to match custom preferences; follow Rails naming |
| **MVC by Default** | Models, Views, Controllers is the expected separation | Keep business logic in models/services, not controllers |
| **The Rails Doctrine** | DHH's 9 pillars: programmer happiness, convention, beautiful code, sharp knives, etc. | Prefer Rails-way solutions over generic patterns; leverage generators |
| **Programmer Happiness** | DX is a first-class priority; Rails console, hot reload, easy generators | Use `rails generate` for scaffolding; prefer `bin/rails` commands |

---

## F8. Toolchain Commands

| Field | Command |
|-------|---------|
| `build` | `bundle exec rails assets:precompile` (if applicable) |
| `test` | `bundle exec rspec` or `bundle exec rails test` |
| `lint` | `bundle exec rubocop` |
| `package_manager` | `bundle` |
| `install` | `bundle install` |

---

## F9. Scan Targets

#### Data Model
| Pattern | Description |
|---------|-------------|
| `class X < ApplicationRecord` in `app/models/*.rb` | ActiveRecord model definitions |
| `db/migrate/*.rb` migration files | Schema evolution (add_column, create_table, etc.) |
| `has_many`, `belongs_to`, `has_one`, `has_and_belongs_to_many` | Relationship declarations |
| `db/schema.rb` or `db/structure.sql` | Current schema snapshot |

#### API Endpoints
| Pattern | Description |
|---------|-------------|
| `config/routes.rb` with `resources`, `get`, `post`, `put`, `delete` | Route definitions |
| `namespace :api` blocks | API versioning boundaries |
| `app/controllers/**/*_controller.rb` public methods | Controller actions |
