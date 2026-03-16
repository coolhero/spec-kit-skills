# Archetype: ai-assistant

> LLM-powered applications — chatbots, AI assistants, RAG systems.

---

## Signal Keywords

### Semantic (A0 — for init inference)

**Primary**: LLM, GPT, Claude API, OpenAI, Anthropic, langchain, llamaindex, AI assistant, chatbot, conversational AI, RAG, retrieval-augmented generation, prompt engineering

**Secondary**: embeddings, vector database, token limit, context window, streaming response, model provider, fine-tuning, AI agent

### Code Patterns (A0 — for source analysis)

- **Libraries**: `openai`, `anthropic`, `@anthropic-ai/sdk`, `langchain`, `llamaindex`, `llama-index`, `huggingface`, `transformers`, `ollama`, `ai` (Vercel AI SDK)
- **Code patterns**: `stream()`, `ReadableStream`, `SSE`, `text/event-stream`, token counting, `ChatCompletion`, `messages.create`, embedding generation, vector store queries
- **Config files**: `.env` with `*_API_KEY` for LLM providers, `prompts/` directory, model configuration files, RAG pipeline configs

### Coding Agent Sub-Pattern

Additional keywords for coding/IDE assistant variants:
- **Libraries**: `tree-sitter`, `@anthropic-ai/claude-code`, AST parsing libraries
- **Patterns**: file system tool use, code generation, diff application, LSP integration

---

## Module Metadata

- **Axis**: Archetype
- **Typical interfaces**: gui, http-api
- **Common pairings**: external-sdk, async-state, realtime
