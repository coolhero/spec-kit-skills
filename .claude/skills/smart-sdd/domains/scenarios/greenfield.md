# Scenario: greenfield

> Building a new project from scratch. No existing system to preserve.
> Module type: scenario

---

## SC Rules (extends _core)

- Standard SC generation from requirements
- No behavioral parity needed
- Focus on completeness: every FR should have at least one SC

## Verification Strategy

- Standard: test + build + lint + demo
- No regression against prior system
- Demo shows the real thing running (not mocked)

## Elaboration Probes

- (Standard elaboration from _core — no scenario-specific additions)
