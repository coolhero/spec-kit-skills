# Concern: push-notification (reverse-spec)

> Push notification detection. Identifies FCM/APNS integration, subscription management, and delivery tracking patterns.

## R1. Detection Signals

> See [`shared/domains/concerns/push-notification.md`](../../../shared/domains/concerns/push-notification.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Push platforms used (FCM, APNS, WNS, Web Push, OneSignal, Expo)
- Device token registration and lifecycle management
- Topic/channel subscription model
- Notification payload structure and platform-specific differences
- User preference and quiet hours implementation
- Delivery tracking and analytics
