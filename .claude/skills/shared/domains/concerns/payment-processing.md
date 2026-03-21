# Concern: payment-processing

> Payment gateway integration (Stripe/PayPal/Square), idempotency keys, webhook signature verification, refund/chargeback flows, PCI scope reduction, tokenization.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: payment, Stripe, PayPal, payment gateway, checkout, billing, subscription, invoice, refund, chargeback

**Secondary**: idempotency key, webhook signature, tokenization, PCI scope, payment intent, payment method, card tokenization, recurring billing, proration, dunning, Square, Adyen, Braintree, payment processor, settlement

### Code Patterns (R1 — for source analysis)

- Gateways: `stripe`, `@stripe/stripe-js`, `paypal-rest-sdk`, `@paypal/checkout-server-sdk`, `square`, `adyen-api`, `braintree`
- Patterns: `PaymentIntent`, `checkout.session`, `Charge`, `Refund`, `Subscription`, `Invoice`, `WebhookEndpoint`
- Webhook: `stripe.webhooks.constructEvent`, `webhook_secret`, HMAC signature verification
- Idempotency: `Idempotency-Key` header, `idempotency_key` parameter, deduplication logic
- Tokenization: `pm_`, `tok_`, `cus_`, `card_` token prefixes, vault references

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: auth, cryptography, compliance
- **Profiles**: —
