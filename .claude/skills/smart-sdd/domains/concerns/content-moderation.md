# Concern: content-moderation

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> Text/image/video moderation, policy enforcement, appeal workflows, automated classification, human review queue, trust scoring.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/content-moderation.md`](../../../shared/domains/concerns/content-moderation.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Automated moderation: content submitted → content analyzed by classifier(s) (text toxicity, image safety, spam detection) → confidence score returned → above threshold: auto-action (approve/reject/flag) → below threshold: routed to human review queue
- Human review: flagged content enters review queue → reviewer sees content + context + classification scores → reviewer decides (approve/reject/escalate) → decision recorded with reason → content status updated → decision feeds back into classifier training data
- Appeal workflow: user notified of moderation decision → user submits appeal with justification → appeal queued for different reviewer (not original) → appeal reviewed → decision (uphold/overturn) → user notified → appeal record linked to original decision
- Trust scoring: user actions tracked (posts, flags received, appeals won/lost) → trust score computed → score determines moderation tier (pre-approved / standard / enhanced scrutiny) → score updated on each moderation event

### SC Anti-Patterns (reject if seen)
- "Content is moderated" — must specify what types (text/image/video), classification method, and threshold/action mapping
- "Users can appeal" — must specify appeal eligibility, review assignment (different reviewer), and decision notification
- "Spam is filtered" — must specify detection signals, false positive handling, and how legitimate content is rescued

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Content types** | Text? Images? Video? Audio? User profiles? What moderation pipeline per type? |
| **Classification** | ML model? Third-party API (Perspective, AWS Rekognition)? Rule-based? Confidence thresholds? |
| **Queue** | Priority in queue? SLA for review? Reviewer assignment? Reviewer agreement metrics? |
| **Policies** | What content policies exist? How are they versioned? Regional policy differences? |
| **Feedback** | How do moderation decisions improve the classifier? Labeling pipeline? Active learning? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| CM-001 | Moderator sees harmful content without warning | Graphic/disturbing content shown to human reviewer without content warning → reviewer trauma → liability | Always blur/redact by default; require explicit "reveal" action; implement reviewer well-being controls (shift limits, break reminders) |
| CM-002 | Appeal reviewed by same moderator | Original moderator assigned to review their own decision appeal → bias → unfair process | Exclude original decision-maker from appeal pool; track reviewer ID in decision chain; enforce in assignment logic |
| CM-003 | False positive rate unmeasured | Legitimate content removed but no feedback loop → users leave → silent community damage | Track appeal success rate as false positive proxy; sample auto-moderated content for quality review; alert on appeal rate spike |
| CM-004 | Moderation decision without reason | Content rejected with no reason code → user cannot understand why → cannot improve → files vague appeal → reviewer cannot evaluate | Require reason code on every moderation decision; map reason codes to policy sections; show user-facing explanation |
| CM-005 | Classifier bias | Model trained on biased data → disproportionate moderation of certain dialects/demographics → discrimination | Audit classifier decisions across demographic segments; test with diverse content; monitor per-group false positive rates |
