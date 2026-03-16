# Archetype: ai-assistant

> AI-powered assistant application. Applies when the project integrates LLM APIs for conversational AI, content generation, or intelligent assistance.
> Module type: archetype

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/ai-assistant.md`](../../../shared/domains/archetypes/ai-assistant.md) § Signal Keywords

---

## A1. Philosophy Principles

| Principle | Description | Implication |
|-----------|-------------|-------------|
| **Streaming-First** | Responses should stream to the user as they are generated, not wait for completion | SCs must specify streaming behavior; UX must handle partial responses; error handling mid-stream |
| **Model Agnosticism** | Application logic should not be tightly coupled to a single LLM provider | Provider abstraction layer required; model switching should not require code changes beyond config |
| **Offline Resilience** | The app must degrade gracefully when LLM APIs are unavailable | Fallback strategies (cached responses, queued requests, offline mode) must be specified |
| **Token Awareness** | Every interaction must respect token budgets for both cost and context window limits | Token counting, conversation truncation, and cost estimation are first-class concerns |
| **Prompt Versioning** | Prompts are a critical part of the application — they must be versioned and manageable | Prompts stored as versioned assets (not inline strings); A/B testing capability considered |

---

## A2. SC Generation Extensions

### Required SC Patterns
- **Model response handling**: Every SC involving AI output must specify whether the response is streamed or batched, and how partial/incomplete responses are handled
- **Token budget**: SCs that involve LLM calls must specify the expected token range (input + output) or reference the project's token budget policy
- **Fallback behavior**: SCs must specify what happens when the LLM provider returns an error, times out, or is rate-limited
- **Prompt reference**: SCs involving AI behavior must reference the specific prompt template being used (not describe the prompt inline)

### SC Anti-Patterns (reject)
- "AI generates a response" — must specify streaming/batch, token budget, fallback, and quality criteria
- "The model answers the question" — must specify which model, response format, and error handling
- "Chat works correctly" — must specify message flow, context management, and edge cases (empty input, max length, rate limiting)

---

## A3. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Model integration** | Which LLM provider(s)? Single or multi-provider? Abstraction layer needed? |
| **Streaming strategy** | Real-time streaming to UI? SSE or WebSocket? How are partial responses rendered? |
| **Context management** | How is conversation history managed? Truncation strategy? Summarization? |
| **Prompt management** | Where are prompts stored? How are they versioned? A/B testing? |
| **Cost & limits** | Token budget per request? Rate limiting? Cost tracking? |
| **RAG pipeline** | Document ingestion needed? Vector store? Retrieval strategy? Chunk size/overlap? |

---

## A4. Constitution Injection

Principles to inject into constitution-seed when this archetype is active:

| Principle | Rationale |
|-----------|-----------|
| All LLM interactions must use the provider abstraction layer — never call provider SDKs directly from business logic | Enables model switching without business logic changes; centralizes retry/error handling |
| Streaming is the default response delivery mode — batch mode is the exception that must be explicitly justified | User experience in AI apps depends on perceived responsiveness; streaming reduces time-to-first-token |
| Token budgets must be enforced at the application layer, not delegated to the provider | Provider limits cause hard failures; application-level enforcement enables graceful degradation |
| Prompts are versioned assets stored outside of source code (or in dedicated prompt files) — never inline strings in business logic | Enables prompt iteration without code deployment; supports A/B testing and rollback |
| Every LLM call site must have a defined fallback behavior (cached response, queued retry, or graceful error) | LLM APIs have variable availability; users must never see raw API errors |

---

## A2b. Coding Agent Sub-Pattern

> When the AI assistant is specifically a coding agent (generates/modifies code, executes tools, manages files), these additional patterns apply.

### Detection Keywords
- "coding agent", "code generation", "file modification", "tool execution", "agentic coding"
- Tool abstractions: `Tool.execute()`, tool registry, tool permission model
- Agent role system: different agents with different capabilities/permissions

### Additional Philosophy Principles

| Principle | Description | Impact |
|-----------|-------------|--------|
| **Tool Safety** | Every tool execution must be permission-gated — no tool runs without explicit or rule-based authorization | SC must verify permission check before tool execution; unauthorized tool calls must be denied |
| **Context Budget** | Total context sent to LLM must be managed — truncation strategy for long conversations | SC for message truncation: verify important context (system prompt, recent messages) preserved; old messages gracefully dropped |
| **Agent Role Isolation** | Different agents (build, plan, review) have different tool access and behavioral constraints | SC per agent role: verify role-specific tool access (plan agent cannot write files), verify role switching preserves conversation |
| **Doom Loop Prevention** | Agent repeatedly failing the same action must be detected and halted | SC for retry limit: verify exponential backoff or circuit breaker on repeated tool failures |

### Additional SC Rules
- **File modification safety**: All file writes must go through a controlled path (not arbitrary `fs.writeFileSync`)
- **Workspace boundary**: Agent cannot modify files outside designated workspace (prevent writing to system dirs)
- **Conversation persistence**: Session state survives process restart — verify SQLite/file persistence
- **Multi-provider graceful degradation**: If primary LLM provider fails, agent degrades gracefully (not crash)
