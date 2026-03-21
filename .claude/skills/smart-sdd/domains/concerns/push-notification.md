# Concern: push-notification

<!-- Format defined in smart-sdd/domains/_schema.md § Concern Section Schema. -->

> FCM/APNS/WNS integration, topic subscription, notification batching, delivery tracking, user preferences, quiet hours.
> Module type: concern

---

## S0. Signal Keywords

> See [`shared/domains/concerns/push-notification.md`](../../../shared/domains/concerns/push-notification.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- Notification send: event triggers notification → recipient resolved → user preferences checked (opted-in, not in quiet hours) → notification payload constructed (title, body, data, action) → sent via platform service (FCM/APNS) → delivery status tracked
- Device registration: app installed → push permission requested → user grants permission → device token obtained → token sent to server → token stored with user ID and platform → token refreshed on change → stale tokens cleaned up
- Topic subscription: user subscribes to topic/channel → subscription recorded → notification sent to topic → all subscribed devices receive → unsubscribe removes from topic → topic notification respects per-user preferences
- Quiet hours: user configures quiet hours (time range + timezone) → notification arrives during quiet hours → notification queued (not dropped) → delivered at quiet hours end → urgent/critical notifications bypass quiet hours if user allows

### SC Anti-Patterns (reject if seen)
- "Notifications are sent" — must specify platform (FCM/APNS/WNS), payload structure, and delivery tracking
- "Users can opt out" — must specify granularity (per-channel, per-type, all), how preferences are stored, and how they're enforced
- "Notifications are batched" — must specify batching window, max batch size, and how urgency bypasses batching

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Platforms** | FCM? APNS? WNS? Web Push? All? Platform-specific payload differences? |
| **Preferences** | Per-channel opt-in/out? Quiet hours? Frequency caps? Notification categories? |
| **Delivery** | Delivery receipt tracking? Retry on failure? TTL for notifications? |
| **Payload** | Rich notifications (images, actions)? Deep links? Silent/data notifications? Localized content? |
| **Scale** | Peak notification volume? Batching strategy? Rate limiting per user/topic? |

---

## S7. Bug Prevention

| ID | Pattern | Detection | Prevention |
|----|---------|-----------|------------|
| PN-001 | Stale device token | User uninstalls app but token not removed → send failures accumulate → delivery rate drops → provider rate-limits account | Handle token invalidation responses from FCM/APNS; remove tokens that fail consistently; periodic token validation |
| PN-002 | Notification flood | Bug or event storm sends hundreds of notifications to same user → user disables notifications entirely → permanent opt-out | Implement per-user rate limiting; deduplicate similar notifications within time window; alert on abnormal send volume |
| PN-003 | Quiet hours timezone error | Quiet hours stored without timezone → applied in server timezone → notifications arrive at wrong local time → user disturbed | Always store quiet hours with user's timezone; convert to UTC for comparison; handle DST transitions |
| PN-004 | Missing notification permission check | Notification sent without checking user's opt-in status → unwanted notification → user reports spam → app penalized by platform | Check user preferences before every send; respect platform-level permission status; honor unsubscribe immediately |
| PN-005 | Silent notification payload too large | Data payload exceeds platform limit (4KB FCM, varies APNS) → notification silently dropped → no error feedback → feature appears broken | Validate payload size before send; truncate or split large payloads; log and alert on size violations |
