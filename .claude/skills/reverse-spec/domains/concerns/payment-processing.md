# Concern: payment-processing (reverse-spec)

> Payment processing detection. Identifies gateway integrations, tokenization, and transaction flow patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/payment-processing.md`](../../../shared/domains/concerns/payment-processing.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Payment gateway(s) used (Stripe, PayPal, Square, Adyen) and integration method
- PCI scope and tokenization strategy
- Idempotency key generation and storage
- Webhook handling and signature verification
- Refund and chargeback flow implementation
- Currency handling (multi-currency, smallest-unit representation)
