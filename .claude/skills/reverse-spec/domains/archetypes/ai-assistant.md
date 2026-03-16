# Archetype: ai-assistant (reverse-spec)

> AI-powered assistant application analysis. Loaded when project uses LLM APIs, streaming patterns, or prompt management.
> Module type: archetype (reverse-spec analysis)

---

## A0. Signal Keywords

> See [`shared/domains/archetypes/ai-assistant.md`](../../../shared/domains/archetypes/ai-assistant.md) § Signal Keywords

---

## A1. Analysis Axes — Philosophy Extraction

For each detected AI assistant pattern, extract:

| Principle | Extraction Targets | Output Format |
|-----------|--------------------|---------------|
| **Streaming-First** | Response delivery pattern (streaming vs batch), SSE/WebSocket usage, chunk handling | Whether streaming is primary UX pattern; how partial responses are displayed |
| **Model Agnosticism** | Provider abstraction layers, model switching capability, provider-specific vs generic SDK usage | Degree of provider coupling; abstraction layer presence |
| **Offline Resilience** | Fallback behavior when API is unavailable, cached responses, graceful degradation | Offline strategy (cache/queue/error) |
| **Token Awareness** | Token counting, context window management, conversation truncation strategy, cost tracking | Token budget strategy; context window policy |
| **Prompt Versioning** | Prompt storage (inline vs file vs DB), prompt template patterns, A/B testing, version history | Prompt management maturity level |
| **RAG Pipeline** | Document ingestion, embedding generation, vector store usage, retrieval strategy | RAG architecture if present; retrieval patterns |

---

### Coding Agent Sub-Pattern Detection
When the AI assistant specifically generates/modifies code and executes system tools:
- **Tool abstraction layer**: Identify tool registry, tool interface definitions, tool permission model
- **Agent role system**: Detect different agent types (build/plan/review) with different capabilities
- **Context management**: Identify message truncation, context window management, token counting
- **Safety mechanisms**: Detect permission gates, workspace boundaries, doom loop prevention
- **Persistence**: Identify session storage, conversation history, state management
