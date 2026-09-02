# Milestone 1 Review

Status: **accepted provisionally; Swift compiler/Mac validation deferred by owner**

Milestone 0 was accepted provisionally with Mac/Xcode validation deferred. Milestone 1 changes are confined to the pure-Swift `MokiCore` package, its unit tests, and status documentation.

## Delivered domain model

- `PetStats`: Hunger, Happiness, Energy, and Bond as `Double` values with shared clamping and delta operations.
- `PetState`: stable ID, model version, stats, sleeping state, creation time, last-calculated time, and last-interaction time.
- `MokiBalance`: the single location for initial values, stat bounds, safe floors, hourly rates, catch-up limit, action effects, and Play's minimum Energy.
- `MokiClock` and `SystemMokiClock`: replaceable time boundary for deterministic tests and later app lifecycle use.
- `StatChangeEngine`: side-effect-free elapsed-time calculation with sleep modifiers, safe floors, maximum catch-up, absolute clamping, and clock-rollback protection.
- `PetActionEngine`: one deterministic path for Feed, Play, Care, Sleep, and Wake Up.
- `PetReaction`, `PetActionRejection`, and `PetActionResult`: explicit applied/rejected outcomes without UI dependencies.

## Working v0.1 balance

These values are intentionally centralized in `MokiBalance.approvedV01` for play-test tuning:

| Rule | Hunger | Happiness | Energy | Bond |
|---|---:|---:|---:|---:|
| Initial | 80 | 80 | 75 | 10 |
| Unattended floor | 10 | 20 | 15 | 0 |
| Awake change/hour | -1.5 | -0.5 | -1 | 0 |
| Sleeping change/hour | -0.75 | 0 | +10 | 0 |
| Feed | +25 | +2 | 0 | +1 |
| Play | -5 | +18 | -12 | +2 |
| Care | 0 | +10 | +2 | +4 |

- Absolute range: `0...100`.
- Hunger uses `100 = well fed` and `0 = extremely hungry` so every meter follows “higher is better.”
- Bond never decays in v0.1.
- Unattended negative changes stop at their safe floors and never raise a stat already below its floor.
- Catch-up calculation is capped at 72 hours; `lastCalculatedAt` still advances to the actual supplied date.
- Play requires at least 15 Energy before its cost is applied.
- Feed, Play, and Care are unavailable while sleeping.
- Sleep/Wake are explicit actions; repeated Sleep or Wake is rejected.
- Rejected actions still return elapsed-time-updated state, but do not set `lastInteractionAt`.
- Clock rollback never generates time-based benefits or moves timestamps backward.

## Unit-test coverage

The Swift package contains 27 test methods covering:

- Approved initial state and model version.
- Custom initial-value clamping.
- Stat delta and absolute-bound behavior.
- Replaceable clock boundary.
- Centralized balance contract.
- Awake decay and sleeping recovery.
- Maximum stat clamping.
- 72-hour catch-up behavior and long absence.
- Safe floors, including values already below a floor.
- Bond stability while awake and asleep.
- Zero elapsed time and clock rollback.
- Feed, Play, and Care effects.
- Sleep/Wake transitions and invalid repetitions.
- Sleeping action restrictions.
- Minimum Energy validation for Play.
- Elapsed-time-before-action ordering.
- Rejected-action state advancement.
- Action timestamp monotonicity during clock rollback.

## Windows validation performed

- Verified all required public domain APIs are present.
- Verified package library/test target structure.
- Checked balanced delimiters and trailing whitespace across Swift sources/tests.
- Confirmed the domain package does not import or reference SwiftUI, WidgetKit, persistence APIs, networking, analytics, accounts, location, HealthKit, maps, Firebase, or Supabase.
- Confirmed required coverage markers and counted 27 test methods.

This Windows environment has no `swift`, `swiftc`, `xcodebuild`, or iOS Simulator. The test suite could not be compiled or executed here.

## Required deferred validation

On a Mac with Xcode, run:

```bash
cd Packages/MokiCore
swift test
```

Then build and test the shared `Moki` Xcode scheme to confirm the app target still resolves the local package.

## Review gate

The owner authorized Milestone 2 with Swift compiler/Mac validation still deferred. Persistence and lifecycle integration may proceed; SwiftUI room work and all later systems remain gated by their own milestone reviews.
