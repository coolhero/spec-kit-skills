# Foundation: Swift (SPM / Xcode)

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `Package.swift` in root (Swift Package Manager)
- OR `.xcodeproj`/`.xcworkspace` + `.swift` source files (Xcode project)
- Optional: `*.podspec` (CocoaPods library), `Podfile` (CocoaPods consumer)

## Architecture Notes (for SBI extraction)
- **Package manager**: SPM (Package.swift), CocoaPods (Podfile), Carthage (Cartfile)
- **Concurrency**: Swift Concurrency (`async`/`await`, `actor`, `Task`, `AsyncSequence`)
- **UI frameworks**: SwiftUI, UIKit, AppKit — detect from imports
- **Testing**: XCTest, Swift Testing (@Test macro)
- **Build**: `swift build`/`swift test` (SPM), `xcodebuild` (Xcode)
- **Code style**: SwiftLint, SwiftFormat
- **Paradigm**: Protocol-Oriented Programming, value types (struct/enum preferred over class)
