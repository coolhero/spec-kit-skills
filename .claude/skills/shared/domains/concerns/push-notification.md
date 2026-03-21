# Concern: push-notification

> FCM/APNS/WNS integration, topic subscription, notification batching, delivery tracking, user preferences, quiet hours.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: push notification, FCM, APNS, Firebase Cloud Messaging, notification service, mobile notification, web push, WNS

**Secondary**: device token, topic subscription, notification channel, notification payload, delivery receipt, quiet hours, notification preferences, badge count, sound, vibration, deep link, notification batching, silent notification

### Code Patterns (R1 — for source analysis)

- Services: `firebase-admin` (FCM), `apn` (APNS), `web-push`, `@react-native-firebase/messaging`, `expo-notifications`, `OneSignal`
- Patterns: `sendNotification()`, `subscribe(topic)`, `deviceToken`, `registrationToken`, `NotificationPayload`, `NotificationChannel`
- Preferences: `notification_preferences`, `quiet_hours`, `opt_in`, `unsubscribe`, `frequency_cap`
- Tracking: `delivery_status`, `read_receipt`, `notification_analytics`, `open_rate`, `click_through`

---

## Module Metadata

- **Axis**: Concern
- **Common pairings**: mobile, message-queue
- **Profiles**: —
