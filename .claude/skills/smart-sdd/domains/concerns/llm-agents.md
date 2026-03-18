# Concern: llm-agents

> Cross-cutting patterns for projects that use LLM-based agents (LangChain, LangGraph, OpenAI SDK, Anthropic SDK, custom agent frameworks).
> Module type: concern
> Applicable to: any project with LLM-driven code generation, multi-agent coordination, or AI-assisted workflows.

---

## S0. Signal Keywords

### Primary
- `langchain`, `langgraph`, `openai`, `anthropic`, `ollama`, `agent`, `llm`, `chat_model`, `tool_calling`, `function_calling`, `state_graph`, `supervisor`, `multi-agent`

### Secondary
- `prompt`, `completion`, `embedding`, `vector_store`, `rag`, `retrieval`, `chain`, `runnable`, `invoke`, `stream`, `token`, `context_window`

---

## S1. SC Generation Rules

### Required SC Patterns

**LLM output SCs must be structural, not content-based:**
- ✅ "Generated code is valid Python that executes without error"
- ✅ "Agent response contains a DataFrame with columns [X, Y, Z]"
- ✅ "Chat response completes within 30s without timeout"
- ❌ "Agent generates `df.dropna()`" — content-specific SCs will break

**Agent workflow SCs must cover state transitions:**
- "Agent state after step N contains [required keys] with [expected types]"
- "Error in step N triggers retry (max 3) then graceful failure with error message"
- "Supervisor routes 'clean data' intent to data_cleaning_agent"

**External API dependency SCs must have fallback/mock path:**
- "When API key is not configured, agent returns actionable error message"
- "When API call fails, agent retries [N] times then reports failure"
- "When running in test mode, agent uses cached/mock responses"

### SC Anti-Patterns (reject)
- "Agent produces correct output" — must specify correctness criteria (schema, type, threshold)
- "LLM generates good code" — must specify structural validity + behavioral test
- "Multi-agent workflow completes" — must specify intermediate state validation

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **LLM provider** | Which LLM provider? (OpenAI, Anthropic, Ollama, Azure) API key management? Fallback provider? |
| **Agent framework** | LangChain/LangGraph? Custom? State management pattern? |
| **Code generation** | Does the agent generate executable code? How is it sandboxed? Timeout/memory limits? |
| **Multi-agent** | Supervisor pattern? How many agents? Routing strategy (intent-based, LLM-based)? |
| **Non-determinism** | How is testing handled? Golden fixtures? Structural validation? Threshold-based? |
| **Token budget** | Context window management? Conversation truncation? Message compression? |
| **Error recovery** | Retry strategy for LLM errors? Code fix loops? Max attempts? |
| **Streaming** | Streaming responses? Partial result handling? Backpressure? |

---

## S7. Bug Prevention Rules

### B-1 (Plan phase)
- **Token budget accounting**: Plan must account for context window limits. If agent sends large datasets to LLM, plan must include truncation/summarization strategy.
- **Sandbox isolation design**: If agent generates executable code, plan must specify isolation mechanism (subprocess, container, serverless).
- **Agent routing completeness**: If supervisor routes to agents, plan must map ALL possible intents → agents. Unhandled intents = explicit error path, not silent drop.

### B-3 (Implement phase)
- **LLM call error handling**: Every LLM API call must have try/except with meaningful error message. Raw API errors (rate limit, timeout, invalid key) must NOT propagate to user as-is.
- **Infinite loop prevention**: Multi-agent workflows must have `max_steps` or `max_iterations` enforcement. Agent fix-loops must have `max_retries`.
- **Prompt injection defense**: If user input is included in prompts, must sanitize or use structured tool calls (not string concatenation).
- **Temperature consistency**: LLM calls for deterministic tasks (code generation, SQL) should use temperature=0. Creative tasks may use higher temperatures.

### B-4 (Verify phase)
- **Non-determinism tolerance**: Verify tests for LLM outputs must NOT use exact string matching. Use structural/behavioral validation.
- **Cost awareness**: Integration tests calling real LLMs must be opt-in (not default). Use `@pytest.mark.llm` or similar marker.
- **Timeout enforcement**: All LLM calls in tests must have explicit timeout. Hanging LLM call = test failure, not infinite wait.

---

## S3. Verify Steps

| Step | Required | Detection | Description |
|------|----------|-----------|-------------|
| **Unit tests** | Yes (BLOCKING) | pytest | Agent logic, tool functions, state management (mock LLM) |
| **Structural LLM tests** | Yes (BLOCKING) | pytest + ast.parse / json.loads | Generated output is valid (parseable, executable) |
| **Behavioral LLM tests** | Conditional (BLOCKING for core features) | pytest + execution | Generated code/output produces expected TYPE and SHAPE |
| **Integration tests** | Optional | pytest + real LLM (@pytest.mark.llm) | Full agent workflow with actual LLM (expensive, slow) |
| **Multi-agent routing** | Conditional (BLOCKING for supervisor) | pytest | Supervisor routes correctly for ALL defined intents |
| **Sandbox safety** | Conditional (BLOCKING for code execution) | pytest | Timeout, memory limit, cleanup verified |
| **Lint** | Optional | ruff, mypy | Code style + type check |

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| LLM provider + model specified | "Uses GPT-4 via OpenAI" or "Ollama llama3" |
| Agent pattern defined | "State graph with 6 nodes" or "Tool-calling agent" |
| Non-determinism strategy stated | "Golden fixture testing" or "Structural validation" |
| Error recovery strategy stated | "3 retries with fix loop" or "Graceful failure with message" |
| Sandbox strategy (if code gen) | "Subprocess with 10s timeout, 512MB limit" |
