# Interface: mobile

> Mobile applications (iOS, Android, cross-platform). Native or hybrid apps with device-specific lifecycle.

---

## Signal Keywords

### Semantic (S0 — for init inference)

**Primary**: mobile app, iOS, Android, React Native, Flutter, SwiftUI, Kotlin, Expo, Capacitor, Ionic

**Secondary**: push notification, deep link, app lifecycle, background task, offline-first, app store, APK, IPA, bundle ID, provisioning profile

### Code Patterns (R1 — for source analysis)

- React Native: `react-native`, `expo`, `AppRegistry`, `NavigationContainer`, `AsyncStorage`, `@react-navigation`
- Flutter: `pubspec.yaml`, `MaterialApp`, `StatefulWidget`, `StatelessWidget`, `lib/main.dart`, `build.gradle` (android)
- iOS Native: `AppDelegate`, `SceneDelegate`, `UIApplication`, `Info.plist`, `@main`, `UIKit`, `SwiftUI`
- Android Native: `AndroidManifest.xml`, `MainActivity`, `Application`, `build.gradle.kts`, `Activity`, `Fragment`
- Cross-platform: `capacitor.config.ts`, `ionic.config.json`, `.NET MAUI`, `Xamarin`
- Features: `Notifications`, `Permissions`, `Geolocation`, `Camera`, `Biometrics`, `Keychain`, `SecureStorage`

---

## Module Metadata

- **Axis**: Interface
- **Common pairings**: auth, async-state, realtime, i18n, external-sdk
- **Profiles**: mobile-app
