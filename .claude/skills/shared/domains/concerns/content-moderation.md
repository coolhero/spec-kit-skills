# Concern: content-moderation

> Text/image/video moderation, policy enforcement, appeal workflows, automated classification, human review queue, trust scoring.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: content moderation, moderation queue, content policy, trust and safety, abuse detection, content filtering, NSFW detection, toxicity scoring

**Secondary**: appeal workflow, human review, automated classification, content flag, report, ban, mute, trust score, content policy enforcement, safe search, profanity filter, spam detection, hate speech, community guidelines

### Code Patterns (R1 — for source analysis)

- Services: `perspectiveapi`, `@google-cloud/vision` (SafeSearch), AWS Rekognition, Azure Content Moderator, OpenAI moderation endpoint
- Libraries: `bad-words`, `profanity-filter`, `text-classifier`, `image-classifier`
- Patterns: `moderationQueue`, `ContentFlag`, `ReviewDecision`, `AppealRequest`, `TrustScore`, `ContentPolicy`, `isApproved`, `isRejected`
- Database: `moderation_decisions`, `content_reports`, `user_sanctions`, `appeal_history`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: auth, llm-agents
- **Profiles**: —
