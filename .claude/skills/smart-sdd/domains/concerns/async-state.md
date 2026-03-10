# Concern: async-state

> Reactive state management patterns (Zustand, Redux, MobX, Pinia, etc.).
> Applies when the project uses a state management library with selectors or reactive subscriptions.
> Module type: concern

---

## S1. SC Generation Rules

### Required SC Patterns
- State transitions: specify initial state -> action -> expected state
- Async flows: specify loading -> success/error/stale -> final state (complete lifecycle including timeout)
- Selector outputs: specify input state shape -> expected derived value

### SC Anti-Patterns (reject)
- "State updates correctly" — must specify before/after state shapes
- "Loading is shown" — must specify the complete async lifecycle (loading -> success/error/stale -> cleanup)
- "Stream updates in real-time" — must specify what happens when the stream goes silent (no events for N seconds)

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **State library** | Which state management? Global vs local? |
| **Async patterns** | Loading/error/success states? Optimistic updates? |
| **Subscriptions** | What components subscribe to what state slices? |

---

## S7. Bug Prevention Rules

When this concern is active, enforce:
- Selector reference instability: creating new object/array references per render causes infinite re-renders. See `injection/implement.md` § Pattern Compliance Scan
- Unbatched state updates in async flows: multiple setState calls without batching. See `injection/implement.md` § Pattern Compliance Scan
- UX Behavior Contract: async UI flows must define complete lifecycle. See `injection/implement.md` § UX Behavior Contract Injection
