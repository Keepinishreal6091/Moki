# Milestone 3 Review

Status: **implemented; awaiting Swift compiler/Xcode validation and owner review**

Milestone 2 was accepted provisionally with Swift compiler/Xcode validation deferred. Before Milestone 3 implementation began, the existing future-architecture document was extended in place with the confirmed progression, move, party, collection, and prototype-limitation requirements. The previously approved battle-stat, `1...50` individual-potential, breeding/inheritance, and original rare-variant requirements were preserved.

## Delivered pet-room experience

- The app now launches directly into a simple portrait SwiftUI room.
- Hunger, Happiness, Energy, and Bond appear as four labeled `0...100` meters with numeric values.
- Feed, Play, Care, and context-sensitive Sleep/Wake controls all call the existing `PetSession` and pure domain action engine; views do not duplicate stat rules.
- Applied actions update the displayed authoritative state and continue through the Milestone 2 persistence path.
- Rejected actions show calm, actionable feedback, including sleeping-state and insufficient-Energy explanations.
- Foreground display state refreshes every 60 seconds, while launch, scene activation, backgrounding, and action timestamps remain authoritative.
- Persistence failures show a non-destructive notice rather than silently presenting success.

## Placeholder Moki and reactions

- Added code-native placeholder artwork informed by the approved cream, charcoal, gold, long-ear, forehead-tuft, and neck-ruff visual direction.
- The character reference was not cut into sprites or shipped as production artwork.
- Awake idle behavior includes subtle breathing, periodic blinking, and tail movement.
- Sleeping closes the eyes, stops the tail, and presents a sleep indicator.
- Feed, Play, Care, Sleep, and Wake each map their domain reaction to distinct short visual motion and feedback text.
- Feedback is cancelable and replaced when a new action occurs.

## Accessibility and presentation

- Primary controls have a minimum 52-point content height, exceeding the approved 44-point minimum.
- Every care control has a VoiceOver label, contextual hint, and stable UI-test identifier.
- Each stat meter exposes a single label and a value such as “80 out of 100.”
- Placeholder Moki exposes state- and reaction-specific accessibility descriptions instead of its decorative drawing hierarchy.
- Reduce Motion removes continuous breathing, blinking, tail swing, jumps, and rotations; reactions use restrained scale/opacity feedback.
- The room palette adapts for light and dark appearance while keeping the placeholder character's approved colors stable.
- User-facing Milestone 3 strings are recorded in the English String Catalog.

## Project and test integration

- Added `PetRoomView.swift`, `MokiPlaceholderView.swift`, `StatMetersView.swift`, and `PetActionBar.swift` to the app target and Xcode project groups.
- Updated the app entry point to present the room while retaining the Milestone 2 scene lifecycle hooks.
- Extended `PetSession` with transient, non-persisted reaction/rejection presentation state.
- Corrected the malformed closing delimiter in the pre-existing app-test Debug build configuration while updating the project file.
- Replaced the old shell UI test with a room/control launch test and added a care-feedback interaction test.
- Existing package coverage remains 49 tests: 27 domain and 22 persistence/lifecycle tests. The app target has one configuration test and the UI target now has two tests.

## Explicitly not implemented

- Spark Catch or any other mini-game.
- A WidgetKit target or widget UI.
- Production sprite assets.
- Evolution, battles, wild encounters, maps, gyms, Championship, trading, accounts, networking, analytics, or backend work.
- XP, levels, species growth curves, moves, move unlocks, training items, party slots, capturing, collection/box storage, cloud sync, hidden potential, breeding/inheritance mechanics, or rare-variant generation.

## Windows validation performed

- Parsed the workspace/scheme XML, asset JSON, and String Catalog JSON.
- Checked balanced and unique Xcode project object definitions and confirmed all room sources are in the app Sources phase.
- Checked balanced delimiters and trailing whitespace across Swift sources and tests.
- Verified required room, meter, care-control, reaction, idle-animation, Reduce Motion, VoiceOver, control-size, dark-mode, and UI-test markers.
- Confirmed the app launches `PetRoomView` and retains active/background lifecycle integration.
- Confirmed future-system identifiers and Milestone 4-or-later dependencies are absent from production Swift code.
- Confirmed 49 package tests, one app test, and two UI tests are authored.

This Windows environment has no `swift`, `swiftc`, `xcodebuild`, or iOS Simulator. The Swift sources and tests could not be compiled, executed, rendered, or visually inspected on an Apple simulator here.

## Required deferred validation

On a Mac with Xcode:

1. Run `swift test` from `Packages/MokiCore`.
2. Open `Moki.xcodeproj`, configure the owner's signing team and App Group, and build/test the shared `Moki` scheme on an iOS 17-or-later iPhone simulator.
3. Launch on a compact and a large iPhone simulator in light and dark appearance.
4. Confirm each meter updates after Feed, Play, and Care, and that Sleep changes to Wake.
5. Confirm sleeping and insufficient-Energy attempts show friendly rejection feedback.
6. Confirm breathing, blinking, tail movement, and every action reaction; then enable Reduce Motion and confirm continuous/large movement stops.
7. Audit the room and controls with VoiceOver.
8. Background, foreground, terminate, and relaunch to confirm state persistence and elapsed-time updates.

## Review gate

Milestone 3 stops here. Do not begin Spark Catch, the widget target, production artwork, or any documented future system until Milestone 3 is accepted.
