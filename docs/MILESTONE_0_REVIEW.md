# Milestone 0 Review

Status: **accepted provisionally; Mac/Xcode validation deferred by owner**

## Delivered

- `Moki.xcodeproj` with an iPhone-only SwiftUI app target targeting iOS 17.
- Shared `Moki` scheme.
- Local `MokiCore` Swift package with a library target and package test target.
- `MokiAppTests` unit-test target.
- `MokiUITests` UI-test target with a launch smoke test.
- Minimal launchable app shell; no virtual-pet feature implementation.
- Placeholder bundle identifiers and automatic signing configuration.
- App Group entitlement backed by the `MOKI_APP_GROUP_IDENTIFIER` build setting.
- Widget-reserved folder documenting the deferred `systemSmall` target.
- Initial asset catalog and localization-string extraction enabled.

## Approved defaults represented in the project

- iOS 17 minimum and iPhone-only target.
- Portrait-only presentation.
- Apple frameworks only; no third-party dependencies.
- Local/offline architecture with no accounts, networking, analytics, notifications, HealthKit, location, or cloud services.
- Widget target deferred until the main pet loop passes review.
- Placeholder identifiers: `com.example.Moki` and `group.com.example.moki`.

Pet statistics, balance values, time passage, persistence implementation, room UI, accessibility behavior, and mini-game code remain intentionally unimplemented.

## Required Mac validation

This repository was scaffolded in a Windows workspace, which cannot run Xcode or an iOS Simulator. On a Mac:

1. Open `Moki.xcodeproj` in Xcode.
2. Select the `Moki` scheme and an iPhone simulator running iOS 17 or later.
3. Set the Development Team under Signing & Capabilities.
4. Replace `com.example.Moki` and `group.com.example.moki` with identifiers owned by that team.
5. Enable the same App Group for the app target.
6. Build the app and run the `Moki` scheme's tests.

Expected shell result: a paw icon, “Moki v0.1,” and “Milestone 0 project shell.”

## Deferred validation note

The owner authorized Milestone 1 to proceed before Mac validation. Project opening, signing, app launch, and scheme tests remain required before device or distribution work.
