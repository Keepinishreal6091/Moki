# Milestone 2 Review

Status: **accepted provisionally; Swift compiler/Xcode validation deferred by owner**

Milestone 1 was accepted provisionally with Mac/Xcode validation deferred. Before Milestone 2 implementation began, the approved future battle-stat, individual-potential, breeding/inheritance, and original rare-variant requirements were recorded in `docs/FUTURE_INDIVIDUAL_TRAITS_AND_BATTLE_ARCHITECTURE.md`. Those systems remain documentation only.

## Delivered persistence boundary

- `MokiPersistence`, a pure-Swift package library that depends on `MokiCore` and has no SwiftUI or WidgetKit dependency.
- `PetStore`, the minimal load/save boundary used by lifecycle orchestration and test doubles.
- `PetSnapshotCodec`, a versioned JSON envelope with schema version `1`.
- Explicit decoding and migration of the documented pre-release schema version `0`.
- Rejection of unknown future schema versions rather than guessing how to decode them.
- `FilePetStore`, using atomic primary-file and backup writes with a one-generation recovery backup.
- Corrupt-primary recovery from the last valid backup, including repair of the primary file.
- Missing-primary recovery from an existing backup instead of treating the pet as a fresh install.
- Safe errors when the primary has no backup, both files are unusable, or a future schema is encountered.

The current snapshot contains only the stable individual ID, domain model version, four care stats, sleep state, creation timestamp, last-calculated timestamp, and last-interaction timestamp. It does not contain battle stats, hidden potential, breeding data, leveling, combat data, or rare-variant state.

## Delivered lifecycle integration

- `PetLifecycleController` restores or creates the pet at launch, applies elapsed-time rules, and saves the resulting state.
- Scene activation advances elapsed time and saves.
- Background entry advances elapsed time and saves.
- Applied and rejected actions both persist their authoritative resulting state.
- Load failures preserve the suspect files and create only an in-memory safe initial state, avoiding automatic destruction of recovery evidence.
- Save failures are exposed as a small lifecycle issue state and clear after a later successful save.
- `PetSession` provides the iOS 17 Observation adapter without moving domain or persistence rules into SwiftUI.
- `AppGroupPetStore` resolves the configured App Group container. While placeholder signing identifiers are still in use, it falls back to an explicitly named Application Support development directory.
- The app shell responds to active/background scene transitions. The room UI remains deferred to Milestone 3.

## Unit-test coverage

The Swift package contains 49 test methods in total: the 27 Milestone 1 domain tests plus 22 Milestone 2 persistence/lifecycle tests. Milestone 2 coverage includes:

- Current-schema JSON round trips and schema declaration.
- Explicit version `0` migration.
- Unknown-future-version and malformed-data rejection.
- Proof that snapshots contain no prematurely implemented future-trait fields.
- Missing-file behavior and first save.
- Directory creation and state round trip.
- Backup retention on subsequent saves.
- Corrupted-primary recovery and repair.
- Missing-primary recovery and repair when a backup remains.
- Unrecoverable primary/backup corruption reporting.
- Atomic-write artifact checks.
- Fresh launch creation and save.
- Existing-state restore, elapsed-time advancement, and resave.
- Active-scene and background-scene saves.
- Applied-action and rejected-action persistence.
- Load-failure evidence preservation.
- Save-failure reporting and recovery.

## Windows validation performed

- Verified the package product/target graph for `MokiCore` and `MokiPersistence`.
- Verified the app target links `MokiPersistence` and includes the App Group store and observable session sources.
- Verified versioned encoding, explicit migration routing, unknown-version rejection, atomic-write use, and backup recovery paths.
- Parsed the Xcode project, scheme, workspace XML, asset JSON, and string-catalog JSON as applicable.
- Checked balanced delimiters and trailing whitespace across Swift sources and tests.
- Confirmed 49 test methods and required persistence/lifecycle coverage markers.
- Confirmed production Swift sources contain no battle-stat, hidden-potential, breeding/inheritance, leveling/combat, or rare-variant implementation.
- Confirmed Milestone 2 adds no room UI, widget target, Spark Catch, account, networking, or backend work.

This Windows environment has no `swift`, `swiftc`, `xcodebuild`, or iOS Simulator. The authored tests could not be compiled or executed here.

## Required deferred validation

On a Mac with Xcode, run:

```bash
cd Packages/MokiCore
swift test
```

Then open `Moki.xcodeproj`, select an iOS 17-or-later iPhone simulator, configure the owner's signing team and App Group, and build/test the shared `Moki` scheme. Confirm that background/foreground transitions do not produce persistence failures. The former Milestone 2 infrastructure shell was superseded by the Milestone 3 room; current visual validation steps are recorded in `docs/MILESTONE_3_REVIEW.md`.

## Review gate

The owner authorized Milestone 3 with Swift compiler/Xcode validation still deferred. The SwiftUI room experience may proceed; Spark Catch, the widget target, and all documented future systems remain gated by their own milestone reviews.
