# Moki iPhone Prototype v0.1 - Proposed Implementation Plan

Status: **approved on 2026-09-01; Milestone 3 implemented and awaiting Swift compiler/Xcode validation and owner review**

## 1. Scope boundary

The GDD is product context, not a request to implement Season One. v0.1 proves one thing: that caring for an expressive Moki in a small room is enjoyable and reliable after the app has been closed.

### Included

- One Moki in one room.
- Hunger, Happiness, Energy, and Bond meters, each clamped to `0...100`.
- Feed, Play, Care, and Sleep actions.
- Deterministic stat changes based on elapsed wall-clock time.
- Local persistence.
- Idle motion and short action reactions.
- One short tap-based mini-game.
- A reusable mini-game result contract for future games, including chess.
- Shared snapshot design suitable for a WidgetKit extension.
- Placeholder SwiftUI/vector artwork based on the character reference's silhouette and palette.

### Explicitly excluded

- Evolution and hidden evolution scoring.
- Combat, moves, battles, teams, and training builds.
- Wild creatures, catching, maps, location, steps, HealthKit, or Core Motion.
- Gyms, Championship, Legendary/Mythical content, trading, friends, accounts, backend, networking, or monetization.
- Production sprite extraction from the supplied character sheet.
- Battle stats, hidden innate potential generation, breeding, inheritance, leveling, combat calculations, and rare-variant generation. Their future architectural requirements are recorded separately and remain unimplemented.

## 2. Proposed technical baseline

- Native iPhone app using Swift and SwiftUI.
- Minimum deployment target: iOS 17, allowing Swift Observation and modern SwiftUI APIs.
- No third-party runtime dependencies for v0.1.
- A small pure-Swift `MokiCore` package for domain rules and deterministic unit tests.
- A versioned `Codable` snapshot stored in an App Group container. This is deliberately simpler than a database for a single pet, is easy to migrate, and can be read by a future widget target.
- An app-layer `@Observable` session coordinates UI state, persistence, reactions, and scene lifecycle; views do not own pet rules.

The App Group identifier and signing team remain placeholders until the project is opened under the owner's Apple Developer account.

## 3. Proposed repository and Xcode structure

```text
Moki/
|-- Moki.xcodeproj/
|-- MokiApp/
|   |-- App/
|   |   |-- MokiApp.swift
|   |   `-- AppContainer.swift
|   |-- Features/
|   |   |-- PetRoom/
|   |   |   |-- PetRoomView.swift
|   |   |   |-- MokiPlaceholderView.swift
|   |   |   |-- StatMetersView.swift
|   |   |   `-- PetActionBar.swift
|   |   `-- MiniGames/
|   |       |-- MiniGamePickerView.swift
|   |       `-- SparkCatch/
|   |           |-- SparkCatchGame.swift
|   |           `-- SparkCatchView.swift
|   |-- State/
|   |   `-- PetSession.swift
|   |-- Persistence/
|   |   |-- AppGroupPetStore.swift
|   |   `-- WidgetSnapshotWriter.swift
|   `-- Resources/
|       `-- Assets.xcassets/
|-- MokiWidget/
|   |-- MokiWidgetBundle.swift
|   |-- MokiWidget.swift
|   `-- MokiTimelineProvider.swift
|-- Packages/
|   `-- MokiCore/
|       |-- Package.swift
|       |-- Sources/MokiCore/
|       |   |-- PetState.swift
|       |   |-- PetStats.swift
|       |   |-- PetAction.swift
|       |   |-- PetReaction.swift
|       |   |-- StatChangeEngine.swift
|       |   |-- PetSnapshot.swift
|       |   |-- PetStore.swift
|       |   |-- Clock.swift
|       |   `-- MiniGameOutcome.swift
|       `-- Tests/MokiCoreTests/
|           |-- StatChangeEngineTests.swift
|           |-- PetActionTests.swift
|           |-- PetSnapshotTests.swift
|           `-- ClockBoundaryTests.swift
|-- MokiUITests/
|-- docs/
`-- README.md
```

The widget files are added only after the main pet loop is working. `MokiCore` and the versioned snapshot are created first so adding the extension does not require rewriting the model.

## 4. Domain design

### Pet state

`PetState` is the single source of truth and contains:

- Stable pet ID and schema version.
- Four stats.
- Sleep state.
- Current mood and transient reaction identifier.
- Creation date, last-calculated date, and last-interaction date.

The stable individual ID is the future attachment point for individual-specific traits. Future hidden innate potential and rare-variant state belong to an individual Moki rather than its species. They must be introduced through a later versioned migration, not as placeholder fields in v0.1. See `docs/FUTURE_INDIVIDUAL_TRAITS_AND_BATTLE_ARCHITECTURE.md`.

The Hunger meter uses `100 = well fed` and `0 = very hungry`, matching the other meters' "higher is better" presentation. The implementation should document this semantic to avoid inverted decay bugs.

### Time passage

`StatChangeEngine` is a pure function:

```text
updatedState = engine.advance(state, from: lastCalculatedAt, to: now)
```

It applies elapsed-time rates, sleep modifiers, caps the maximum catch-up interval, clamps every stat, and advances `lastCalculatedAt`. No countdown timer is persisted. Foreground timers are only a display refresh mechanism; authoritative changes are calculated from timestamps when the app launches, becomes active, enters background, or performs an action.

Clock rollback is handled conservatively: negative elapsed time produces no stat reward and updates nothing until time catches up. Exact rates live in one balance configuration so they can be tuned without changing views.

### Actions and reactions

Each `PetAction` passes through one reducer/service that:

1. Advances elapsed time to `now`.
2. Validates the action (for example, Play requires enough Energy).
3. Applies stat changes.
4. Emits a short `PetReaction` for animation and accessibility text.
5. Saves the state and refreshes the widget snapshot.

This prevents buttons, mini-games, and future widget deep links from implementing different rules.

## 5. UI proposal

The first screen is a portrait room scene with three visual layers:

1. A simple room background.
2. A centered placeholder Moki made from SwiftUI shapes or a dedicated placeholder asset.
3. A HUD with four stat meters and a bottom action bar.

Idle movement is subtle breathing, blinking, ear/tail motion, and occasional position drift. Feed, Play, Care, and Sleep trigger short, cancelable reactions. Reduce Motion replaces large movement with opacity/scale changes. VoiceOver labels report both the stat name and value.

The supplied character sheet informs cream, charcoal, warm-gold, and off-white colors; long dark ears; forehead tuft; neck ruff; and expressive eyes. It remains in `docs/references` and is not cut up or shipped as a game asset.

## 6. Mini-game boundary

The v0.1 game is **Spark Catch**: during a short timed round, the player taps a spark that relocates within a safe play area. The outcome contains score, duration, and normalized reward values.

`MiniGameOutcome` is independent of Spark Catch and returns domain-level effects such as Happiness, Energy cost, and Bond gain. A future chess feature can supply the same outcome type without changing `PetSession` or the room screen. Chess rules, AI, networking, and boards are not part of v0.1.

## 7. Widget preparation

The main app writes a compact `PetSnapshot` to an App Group container after every meaningful state change and when entering background. The snapshot contains only data needed by a widget: display stats, mood, sleep state, last update, and placeholder-art state.

After the main loop passes its acceptance checks, add a small WidgetKit target that reads this snapshot and renders one static small-system widget. Timeline policy stays conservative because WidgetKit controls refresh frequency. Tapping the widget deep-links to the room. Widget animation is not a v0.1 requirement.

## 8. Milestones

### Milestone 0 - Project bootstrap

- Create the app target, local `MokiCore` package, and test targets.
- Add bundle/signing placeholders and the future App Group constant.
- Confirm a clean build and unit-test run on a Mac with Xcode.

### Milestone 1 - Pet rules

- Implement state, actions, balance configuration, clock abstraction, and time engine.
- Cover decay, sleep modifiers, clamping, clock rollback, and long absence with unit tests.

### Milestone 2 - Persistence and lifecycle

- Implement atomic, versioned App Group snapshot storage.
- Restore/advance state at launch and scene activation; save at backgrounding and after actions.
- Add corruption fallback and migration tests.

### Milestone 3 - Main pet experience

- Build the room, stats, actions, placeholder Moki, idle motion, and reactions.
- Add accessibility labels, Reduce Motion behavior, and interaction feedback.

### Milestone 4 - Spark Catch

- Add the short mini-game and route its outcome through the same action pipeline.
- Verify that rewards and energy costs cannot bypass domain limits.

### Milestone 5 - Widget shell

- Add the WidgetKit target and App Group entitlement.
- Read the shared snapshot, render a basic widget, and deep-link to the room.

### Milestone 6 - Prototype QA

- Test fresh install, background/foreground, force quit/relaunch, sleep across an absence, clock rollback, corrupted persistence, small screens, dark mode, VoiceOver, and Reduce Motion.

## 9. v0.1 acceptance criteria

- A fresh install creates exactly one Moki with valid default stats.
- Closing and reopening the app never resets healthy saved state.
- Returning after an absence changes stats according to elapsed time and never leaves `0...100`.
- Feed, Play, Care, and Sleep have distinct stat effects and visible reactions.
- Sleep changes Energy recovery and can be entered/exited without trapping the pet.
- Moki visibly idles while respecting Reduce Motion.
- Spark Catch completes, reports a score, and applies a bounded reward.
- Domain behavior is unit-tested without SwiftUI or real waiting.
- The app works offline.
- A widget can be added without changing the persisted state schema or pet rules.
- No excluded GDD system appears in the app or data model.

## 10. Approved architecture defaults

The owner approved these defaults on 2026-09-01:

- iOS 17 minimum deployment target.
- Portrait-only first prototype.
- One local pet and no account.
- Versioned Codable/App Group persistence rather than SwiftData for the single-pet prototype.
- Spark Catch as the first mini-game.
- Placeholder vector artwork rather than extracting sprites from the reference sheet.
- Add the WidgetKit target after the main room loop passes acceptance checks.

Additional approved defaults:

- Use Apple frameworks only, with no third-party runtime dependencies.
- Use no networking, accounts, analytics, ads, notifications, HealthKit, location, or cloud sync in v0.1.
- Support common iPhone sizes, light mode, and dark mode.
- Include VoiceOver labels, 44-point primary controls, and Reduce Motion behavior from the first feature UI.
- Ship English only initially while keeping user-facing strings in a String Catalog.
- Use low-anxiety rules: Moki cannot die, disappear, or permanently lose progress; Bond does not decay in v0.1; unattended decay stops at safe floors.
- Start Hunger at 80, Happiness at 80, Energy at 75, and Bond at 10, with tuning values centralized outside views.
- Save after meaningful interactions and lifecycle transitions, use atomic persistence, retain recovery data, and handle corruption safely.
- Begin WidgetKit work with one nonconfigurable `systemSmall` widget showing mood and the most urgent need.
- Use `Moki` as the working display name and placeholder identifiers until the owner's Apple Developer Team namespace is available.

Milestone 0 must stop for review before Milestone 1 begins.

## 11. Apple platform references

- [Managing model data in your app](https://developer.apple.com/documentation/SwiftUI/Managing-model-data-in-your-app)
- [Developing a WidgetKit strategy](https://developer.apple.com/documentation/WidgetKit/Developing-a-WidgetKit-strategy)
- [ModelContainer](https://developer.apple.com/documentation/swiftdata/modelcontainer)

## 12. Deferred individual and collection architecture

The future battle-stat set is HP, Attack, Defense, Special Attack, Special Defense, and Speed. Each individual Moki will eventually have a corresponding hidden innate potential value in the inclusive `1...50` range. Future calculated stats may combine species/base stats, level or progression, and individual potential.

Innate potential belongs to the individual and may differ between Mokis of the same species. Future breeding may inherit some values from individual parents, but every inheritance rule remains undefined. An extremely rare original Moki alternate visual variant may also be assigned at creation or hatching; that property likewise belongs to the individual and may interact with future breeding if later approved.

None of these properties or mechanics are implemented in v0.1. The stable individual ID and versioned persistence migration path provide the required forward compatibility without adding premature fields. Full requirements and exclusions are in `docs/FUTURE_INDIVIDUAL_TRAITS_AND_BATTLE_ARCHITECTURE.md`.

That same document also records the approved future level/XP model, configurable species growth curves, species move pools, generic move-unlock requirements, four-active-move loadouts, ordered four-Moki party, lead-Moki widget rule, collection/box, and eventual cloud synchronization. “One local Moki, no account” remains a v0.1 limitation rather than a permanent architecture decision. None of those future systems are authorized for implementation in Milestone 3.
