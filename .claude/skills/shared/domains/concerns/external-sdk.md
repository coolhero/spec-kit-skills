# Concern: external-sdk

> Third-party API and SDK integrations.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: OpenAI, Anthropic, Stripe, AWS SDK, Google Cloud, Firebase, Twilio, SendGrid, third-party API, AI SDK, Vercel AI SDK, LangChain, payment SDK, cloud SDK

**Secondary**: API key, SDK version, rate limit, quota, webhook callback, SDK wrapper

### Code Patterns (R1 — for source analysis)

- AI SDKs: `openai`, `@anthropic-ai/sdk`, `ai` (Vercel AI SDK), `@google/generative-ai`
- Payment SDKs: `stripe`, `@paypal/checkout-server-sdk`
- Cloud SDKs: `@aws-sdk/*`, `@google-cloud/*`, `@azure/*`
- Any dependency with complex configuration objects or callback-based APIs

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: ai-assistant (archetype)
- **Profiles**: —
