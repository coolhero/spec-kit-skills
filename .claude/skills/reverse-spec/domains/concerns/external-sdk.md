# Concern: external-sdk (reverse-spec)

> External SDK integration detection. Identifies third-party SDK usage.

## R1. Detection Signals
- AI SDKs: `openai`, `@anthropic-ai/sdk`, `ai` (Vercel AI SDK), `@google/generative-ai`
- Payment SDKs: `stripe`, `@paypal/checkout-server-sdk`
- Cloud SDKs: `@aws-sdk/*`, `@google-cloud/*`, `@azure/*`
- Any dependency with complex configuration objects or callback-based APIs

### Large-Scale Provider Detection
When 5+ external providers are detected through a unified abstraction layer:
- Identify the abstraction layer itself as a key architectural component
- Map provider-specific configurations (API keys, model names, endpoints)
- Detect provider fallback chains and retry strategies
- Flag provider-specific constraints (token limits, rate limits, response format differences)
