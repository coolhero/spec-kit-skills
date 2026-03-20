# Foundation: Android Native (Kotlin/Java)

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `build.gradle` or `build.gradle.kts` with `com.android.application` or `com.android.library` plugin
- `AndroidManifest.xml` present
- No React Native or Flutter markers (those have dedicated Foundations)

## Architecture Notes (for SBI extraction)
- **Language**: Kotlin (preferred), Java (legacy)
- **UI**: Jetpack Compose (`@Composable`), XML layouts (legacy)
- **Architecture**: ViewModel + LiveData/StateFlow, Room DB, Hilt DI
- **Build**: Gradle with Android Gradle Plugin (AGP)
- **Lifecycle**: Activity/Fragment lifecycle, LifecycleObserver
- **Testing**: JUnit, Espresso (UI), Robolectric (unit)
- **Modules**: Multi-module Gradle (`:app`, `:core`, `:feature-*`)
