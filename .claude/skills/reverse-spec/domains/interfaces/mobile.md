# Interface: mobile (reverse-spec)

> Mobile application detection. Identifies iOS/Android/cross-platform app patterns.

## R1. Detection Signals

> See [`shared/domains/interfaces/mobile.md`](../../../shared/domains/interfaces/mobile.md) § Code Patterns

## R3. Analysis Depth Modifiers

When detected, include in analysis:
- Platform targets (iOS, Android, both) and framework (React Native, Flutter, native)
- Navigation architecture and screen hierarchy
- App lifecycle handling (background/foreground transitions)
- Push notification implementation and deep link routing
- Permission usage and request patterns
- Offline data strategy and sync mechanism
- Native module bridges and platform-specific code
