# Domain Profile: data-science (smart-sdd)

> Data science, ML pipelines, feature stores, and AI/ML platform projects.
> For reverse-spec analysis profiles, see `../../reverse-spec/domains/data-science.md`.

---

## 1. Demo Pattern

- **Pipeline/modeling type**: Script-based (not server)
  - **Default mode**: Run pipeline/inference with sample data → display results + metrics + visualizations → keep output visible
  - **CI mode**: Run with sample data → validate output format + metrics within threshold → exit
- **Platform type**: Server-based
  - **Default mode**: Start feature server → run sample retrieval → display latency + results → keep running
  - **CI mode**: Start → health check → sample query → validate response → stop
- **NL-interface type**: Server-based
  - **Default mode**: Start server → submit sample NL query → display generated SQL + results → keep running
  - **CI mode**: Start → submit known query → validate SQL output matches expected → stop
- **Script location**: `demos/F00N-name.sh` (or `.py`)
- **"Try it" instructions**: Commands to run, expected output files, metrics to check, sample queries

---

## 2. Parity Dimensions

### Structural Parity

| Category | What to Compare |
|----------|----------------|
| Data schemas | Input/output data schemas, column definitions, feature types, entity definitions |
| Pipeline stages | Processing steps, DAG structure, stage ordering, materialization configuration |
| Model architecture | Layer definitions, hyperparameters, feature inputs, output format |
| Store configuration | Online/offline store type, connection config, serialization, indexing strategy |
| Provider configuration | Active providers, model IDs, API endpoints, embedding dimensions, vector store backends |

### Logic Parity

| Category | What to Compare |
|----------|----------------|
| Transformations | Data transformation logic, feature engineering steps, aggregation windows |
| Model behavior | Prediction accuracy, metric thresholds, edge case handling, confidence scores |
| Query generation | NL-to-SQL accuracy, SQL dialect correctness, result formatting |

---

## 3. Verify Steps

| Step | Required | Detection | Description |
|------|----------|-----------|-------------|
| **Test** | Yes (BLOCKING) | pytest, unittest, data validation frameworks (Great Expectations, pandera) | Data validation + unit tests |
| **Pipeline Run** | Yes (BLOCKING) | Pipeline runner (Airflow, DVC, Prefect, Dagster, custom) | End-to-end pipeline with sample data |
| **Metrics Check** | Yes (BLOCKING) | Evaluation script output, experiment tracking (MLflow, W&B) | Output metrics within acceptable threshold |
| **Store Health** | Conditional (BLOCKING for platform type) | Feature store health endpoint, online store latency probe | Online/offline store responds correctly |
| **Example Execution** | Conditional (BLOCKING for platform/SDK type) | `examples/` scripts, quickstart notebooks | All examples run without error |
| **Lint** | Optional | ruff, flake8, black, mypy | Code style + type check |

---

## 4. LLM Agent Testing Patterns

> When the data-science project includes LLM-based agents, activate the `llm-agents` concern module (`domains/concerns/llm-agents.md`) for comprehensive LLM testing patterns, SC rules, and bug prevention. The patterns below are data-science-specific extensions.
>
> **Cross-reference**: `concerns/llm-agents.md` — S1 (SC patterns), S5 (probes), S7 (bug prevention), S3 (verify steps), S9 (Brief criteria)

> Applies when the data-science project includes LLM-based agents (LangChain, LangGraph, custom agent frameworks).

### The Non-Determinism Challenge

LLM agents produce different outputs for identical inputs. Traditional testing assumes `f(x) = y` always. LLM testing assumes `f(x)` produces `y1, y2, y3...` that are all *structurally valid and behaviorally correct* but *textually different*.

### Testing Strategy: Structure + Behavior, Not Content

| Test Level | What to Verify | How | Example |
|-----------|---------------|-----|---------|
| **Structural** | Generated code is syntactically valid | Parse/compile check | `ast.parse(generated_code)` must not raise |
| **Behavioral** | Generated code produces correct output TYPE | Execute + check output schema | DataFrame with expected columns and types |
| **Threshold** | Output metrics within acceptable range | Execute + compare metrics | accuracy ≥ 0.8, not accuracy == 0.847 |
| **Contract** | Agent state transitions follow schema | Validate TypedDict at each node | State has `messages`, `datasets`, `code` keys after each step |
| **Idempotent side effects** | Same logical result despite different code | Execute twice → same output shape | Both runs produce DataFrame with same columns |

```
❌ WRONG: assert generated_code == "df.dropna()" (content equality — will break)
✅ RIGHT: assert ast.parse(generated_code) is not None (structural validity)
✅ RIGHT: result = exec(generated_code); assert isinstance(result, pd.DataFrame) (behavioral)
✅ RIGHT: assert result.shape[0] > 0 and set(result.columns) >= {"id", "name"} (schema)
```

### Golden Fixture Pattern

For integration tests that call actual LLMs:
1. Run once with real LLM → capture output → save as fixture
2. Subsequent tests use the fixture (no LLM call)
3. Periodically re-capture to detect LLM behavior drift
4. Mark drift-sensitive tests with `@pytest.mark.llm_golden`

### Sandbox Execution Testing

When agents generate and execute code in sandboxes:

| Aspect | What to Test |
|--------|-------------|
| **Timeout enforcement** | Code that sleeps/loops → terminated within limit |
| **Memory limits** | Code that allocates large arrays → killed |
| **Output capture** | stdout/stderr properly redirected and accessible |
| **Error propagation** | Non-zero exit code → meaningful error in agent state |
| **Cleanup** | No lingering child processes after execution |
| **Isolation** | Code cannot access parent process memory or filesystem beyond sandbox |

### Multi-Agent Coordination Testing

When multiple agents coordinate (supervisor + specialized agents):

| Aspect | What to Test |
|--------|-------------|
| **Routing correctness** | Supervisor routes intent to correct agent |
| **Message contract** | Agent input/output matches expected schema |
| **State consistency** | Shared registry (datasets, artifacts) stays consistent |
| **Loop prevention** | No infinite routing loops (max steps enforced) |
| **Composition** | 2+ agents in sequence produce valid combined result |
| **Fallback** | What happens when an agent fails? Supervisor handles gracefully? |

```
# Routing test — deterministic, no LLM needed
def test_supervisor_routes_cleaning():
    result = supervisor.route("clean the missing values")
    assert result.next_agent == "data_cleaning_agent"

# Composition test
def test_clean_then_visualize():
    state = supervisor.invoke("clean then visualize data")
    assert "cleaned_df" in state
    assert "chart_html" in state
```

---

## 5. Streamlit App Testing Patterns

> Applies when the data-science project uses Streamlit for UI.

### Testing Challenges

Streamlit apps use `st.session_state` for state management and `st.` widgets for UI. Unlike browser-based apps (Playwright), Streamlit testing requires:

| Approach | Tool | Use Case |
|----------|------|----------|
| **Script mode** | `streamlit run --headless` + health check | App starts without errors |
| **Session state unit tests** | Direct Python testing (import + manipulate) | Business logic in callbacks |
| **App testing** | `streamlit.testing.v1.AppTest` (built-in) | Widget interaction simulation |
| **E2E** | Playwright/Selenium against running app | Full UI verification |

### Verify Protocol for Streamlit

```
Phase 1: Static
  - pytest (unit tests for agent logic, data processing)
  - mypy/ruff (type + lint)

Phase 2: App Launch
  - streamlit run app.py --headless → health check (HTTP 200 on port)
  - No Python errors in server log

Phase 3: Widget Interaction (using AppTest or Playwright)
  - File upload → data appears in session state
  - Button click → agent invoked → result displayed
  - Sidebar navigation → page switch → state preserved
  - For each SC: simulate the user action → verify the outcome

Phase 4: State Persistence
  - Save project → file exists with correct schema
  - Load project → state restored → UI reflects loaded data
  - Undo/redo → state rolls back/forward correctly
```

---

## 6. Python-Specific Implement Rules

### Virtual Environment Verification

Before implementing Python Features:
- Verify `pyproject.toml` or `requirements.txt` exists
- Verify virtual environment is active (`which python` points to venv)
- All new dependencies → add to dependency file AND `pip install`

### Import Order & Dependency Hygiene

- New imports must follow project convention (isort/ruff format)
- No circular imports (Python-specific — not caught by type checker until runtime)
- Type hints required for public functions (mypy --strict or pyright)

### Data Validation

For data pipeline Features:
- Input data schema validation (pandera, pydantic, or manual checks)
- Output data schema validation (column names, types, ranges)
- Edge cases: empty DataFrame, single row, all NaN column
