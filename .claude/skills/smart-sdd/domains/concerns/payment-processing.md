# Concern: payment-processing

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Payment gateway integration, idempotency keys, webhook signature verification, refund/chargeback flows, PCI scope reduction, tokenization.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/payment-processing.md`](../../../shared/domains/concerns/payment-processing.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Payment flow: customer initiates payment → payment intent/session created with idempotency key → customer provides payment method (tokenized, never raw card) → gateway charges → webhook confirms success/failure → order status updated → receipt generated
- Webhook handling: webhook received → signature verified using shared secret → event type parsed → idempotent processing (check if already handled) → business logic executed → 200 returned promptly → retry on failure handled
- Refund flow: refund requested → eligibility checked (time window, order status) → refund initiated via gateway API with idempotency key → webhook confirms refund → order status updated → customer notified → accounting entry created
- Subscription billing: subscription created → recurring schedule established → payment attempted on cycle date → on success: extend access → on failure: retry with backoff → after max retries: dunning email → after grace period: suspend access

### SC Anti-Patterns (reject if seen)
- "Payments are processed" — must specify gateway, idempotency strategy, webhook verification, and error handling for declined/failed payments
- "Credit card data is stored" — PCI scope violation; must use tokenization and specify that raw card data never touches the server
- "Refunds work" — must specify eligibility rules, partial refund support, and how refund status is communicated to user

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Gateway** | Stripe? PayPal? Square? Adyen? Multiple gateways? Fallback strategy? |
| **PCI Scope** | SAQ A (hosted checkout)? SAQ A-EP (client-side tokenization)? How is PCI scope minimized? |
| **Idempotency** | How are idempotency keys generated? Where stored? TTL? |
| **Webhooks** | Which events subscribed? Signature verification method? Retry handling? Ordering guarantees? |
| **Currencies** | Multi-currency? Currency conversion? Smallest unit handling (cents vs units)? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| PAY-001 | Missing idempotency key | Payment request retried without idempotency key → double charge → customer dispute → chargeback | Generate unique idempotency key per payment attempt; store and check before processing; gateway-level idempotency support |
| PAY-002 | Webhook signature bypass | Webhook endpoint processes events without verifying signature → attacker sends fake payment confirmations → unauthorized access | Always verify webhook signature before processing; reject unsigned/invalid webhooks; log verification failures |
| PAY-003 | Floating-point currency | Currency amounts stored/calculated as floats → rounding errors accumulate → financial discrepancy | Use integer smallest-unit representation (cents); use Decimal/BigDecimal for calculations; never use float/double for money |
| PAY-004 | Race condition on payment status | Webhook and polling both update payment status concurrently → inconsistent state → order fulfilled twice or not at all | Use database-level locking or compare-and-swap on status transitions; make status updates idempotent |
| PAY-005 | Raw card data in logs | Card number, CVV, or expiry logged in request/error logs → PCI-DSS violation → breach liability | Never log card data; use tokenized references only; implement log sanitizer; scan logs for card number patterns (Luhn check) |
