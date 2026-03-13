# React Native Foundation

## F0. Detection Signals

- `react-native` in package.json `dependencies`
- `metro.config.js` or `metro.config.ts` present
- `app.json` or `app.config.js` with Expo configuration
- `ios/` and `android/` directories (bare workflow)
- `expo` in package.json dependencies (Expo managed)

---

## F1. Foundation Categories

| Category Code | Category Name | Item Count | Description |
|--------------|---------------|------------|-------------|
| BST | App Bootstrap | 5 | Development approach, Expo SDK, RN architecture, JS engine, navigation |
| SEC | Security | 3 | Biometric auth, encrypted storage, environment config |
| PRM | Permissions | 2 | Permission strategy, permission request UX |
| PSH | Push Notifications | 2 | Push service, notification handling |
| STO | App Store & Distribution | 4 | Code signing iOS, Android, build tool, store submission |
| HWR | Hardware Access | 5 | Camera, file system, maps, in-app purchases, gestures |
| OFL | Offline & Background | 4 | Offline storage, background tasks, background location, OTA updates |
| STM | State Management | 3 | Global state, server state, networking |
| STY | Styling | 3 | Styling approach, fonts, status bar |
| ERR | Error Handling | 3 | Crash reporting, analytics, error boundary |
| LOG | Logging & Monitoring | 2 | Debug tools, Hermes bytecode |
| TST | Testing | 2 | Testing framework, component testing |
| DXP | Developer Experience | 7 | Navigation structure, deep linking, splash screen, app icon, safe area, orientation, animations |
| ENV | Environment Config | 5 | Native module linking, adaptive icon, edge-to-edge, WebSocket, monorepo |

<!-- TODO: Full itemization — 50 items across 14 categories -->
<!-- See _foundation-core.md for Foundation file format specification -->
<!-- Refer to research data for complete React Native Foundation item enumeration -->
<!-- Note: Requires future `mobile-app` profile to be fully functional -->
