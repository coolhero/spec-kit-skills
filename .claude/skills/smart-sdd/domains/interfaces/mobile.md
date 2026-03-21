# Interface: mobile

> Mobile applications (iOS, Android, cross-platform). Native or hybrid apps with device-specific lifecycle.
> Module type: interface

---

## S0. Signal Keywords

> See [`shared/domains/interfaces/mobile.md`](../../../shared/domains/interfaces/mobile.md) § Signal Keywords

---

## S1. SC Generation Rules

### Required SC Patterns
- App lifecycle: launch → foreground → background → terminate. Specify what happens at each transition (save state, pause tasks, release resources)
- Push notifications: specify registration, permission request, notification receipt (foreground vs background), tap action (deep link or screen navigation)
- Deep linking: specify URL scheme or universal link → target screen mapping → fallback when app not installed
- Permissions: specify which permissions (camera, location, contacts, etc.), request timing (first use, not on launch), denial handling (graceful degradation, rationale dialog)
- Offline behavior: specify which features work offline, data sync strategy (queue mutations, resolve conflicts), offline indicator

### SC Anti-Patterns (reject)
- "App works on mobile" — must specify platform (iOS, Android, both), lifecycle handling, and permission model
- "Push notifications are supported" — must specify registration flow, foreground/background behavior, and tap navigation
- "Works offline" — must specify which features, sync strategy, and conflict resolution

### SC Measurability Criteria
- App launch time threshold (cold start < N seconds)
- Navigation transition smoothness (no dropped frames)
- Offline-to-online sync completion time

---

## S1. Demo Pattern (override)

- **Type**: Emulator/simulator-based or device-based
- **Default mode**: Launch app → navigate key flows → verify state persistence across background/foreground cycle
- **CI mode**: Build APK/IPA → install on emulator → run UI test suite → capture screenshots
- **"Try it" instructions**: Platform-specific build + launch commands

---

## S5. Elaboration Probes

| Sub-domain | Probe Questions |
|------------|----------------|
| **Platform** | iOS only? Android only? Both? Cross-platform framework? Minimum OS version? |
| **Navigation** | Tab-based? Stack-based? Drawer? Modal? Deep link routing? |
| **Storage** | SQLite? Realm? AsyncStorage? Keychain/Keystore for secrets? |
| **Networking** | REST? GraphQL? gRPC? Offline queue? Background sync? |
| **Device Features** | Camera? Location? Biometrics? Sensors? Bluetooth? |

---

## S9. Brief Completion Criteria

| Required Element | Completion Signal |
|-----------------|-------------------|
| Target platforms | iOS, Android, or both specified |
| Core navigation flow | Main screens and navigation pattern (tab/stack/drawer) identified |
| Lifecycle handling | Background/foreground behavior described |

---

## S8. Runtime Verification Strategy

> Cross-references [reference/runtime-verification.md](../../reference/runtime-verification.md) § 6c.

| Field | Value |
|-------|-------|
| **Start method** | Build and install on emulator/simulator (or delegate to user for physical device) |
| **Verify method** | UI automation (Detox for React Native, Flutter integration test, XCUITest, Espresso) or delegate interactive verification to user |
| **Stop method** | Terminate emulator/simulator process |
| **SC classification extensions** | `mobile-auto` — SCs verifiable via emulator UI automation; `mobile-manual` — SCs requiring physical device (camera, GPS, biometrics) → delegate to user |

**Mobile-specific verification**:
- Lifecycle SCs: automate background/foreground transitions via emulator commands
- Permission SCs: grant/deny permissions via test framework → verify UI behavior
- Deep link SCs: send URL intent/scheme → verify correct screen opens
- Device-dependent SCs (camera, GPS, biometrics): AskUserQuestion to delegate manual verification
