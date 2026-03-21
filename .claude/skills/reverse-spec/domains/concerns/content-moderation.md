# Concern: content-moderation (reverse-spec)

> Content moderation detection. Identifies classification pipelines, review queues, and policy enforcement patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/content-moderation.md`](../../../shared/domains/concerns/content-moderation.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Content types moderated (text, image, video, audio, user profiles)
- Classification method (ML model, third-party API, rule-based, hybrid)
- Confidence thresholds and action mapping (auto-approve, flag, auto-reject)
- Human review queue implementation and reviewer assignment
- Appeal workflow and decision tracking
- Trust scoring and user reputation system
