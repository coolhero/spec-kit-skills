# Concern: external-sdk (reverse-spec)

> External SDK integration detection. Identifies third-party SDK usage.

## R1. Detection Signals
- AI SDKs: `openai`, `@anthropic-ai/sdk`, `ai` (Vercel AI SDK), `@google/generative-ai`
- Payment SDKs: `stripe`, `@paypal/checkout-server-sdk`
- Cloud SDKs: `@aws-sdk/*`, `@google-cloud/*`, `@azure/*`
- Any dependency with complex configuration objects or callback-based APIs
