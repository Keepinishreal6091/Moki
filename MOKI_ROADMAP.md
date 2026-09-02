# Moki Project Roadmap

Last updated: 2026-09-02

This document is the source of truth for Moki's current project status, locked product decisions, milestone sequence, and continuation rules. Older milestone reviews remain useful historical records; when their status wording differs from this file, use this roadmap and the current Git history.

## Status legend

- ✅ Complete
- 🚧 In Progress
- ⏭️ Next
- 📋 Planned
- 🔮 Post-MVP
- ⚠️ Needs Mac/iPhone verification

## Project vision

Moki is an iPhone-first virtual-pet and creature game centered on raising, caring for, and forming a bond with a creature. The experience should begin as a warm, expressive, reliable virtual-pet loop and later expand into progression, evolution, collecting, mini-games, and other original Moki gameplay systems.

The immediate product goal is an offline-first MVP that can be installed and played on iPhones. The larger game-design document provides product context, but it is not authorization to implement every future system at once.

## Locked product decisions

### Base Moki

The current base Moki design and visual identity are approved as the starting creature. Preserve the current artwork, cream/charcoal/gold palette, long ears, forehead tuft, neck ruff, and expressive identity unless a future milestone explicitly authorizes a change. Additional poses, animations, and production assets may extend this identity; they must not silently redesign it.

### Evolution structure

Moki begins as **Normal** type. There are five mutually exclusive primary evolution paths and 25 locked final form combinations. Do not redesign this type structure unless the owner explicitly changes it.

| Primary path | Locked final forms |
|---|---|
| Fire | Pure Fire; Fire/Fairy; Fire/Steel; Fire/Fighting; Fire/Dragon |
| Water | Pure Water; Water/Fairy; Water/Ghost; Water/Psychic; Water/Ice |
| Nature | Pure Nature; Nature/Fairy; Nature/Ground; Nature/Bug; Nature/Poison |
| Electric | Pure Electric; Electric/Steel; Electric/Psychic; Electric/Flying; Electric/Ice |
| Dark | Pure Dark; Dark/Ghost; Dark/Psychic; Dark/Fighting; Dark/Poison |

The complete 25-form content rollout is post-MVP. MVP evolution work may establish data, save compatibility, conditions, and a deliberately limited owner-approved content slice, but it must preserve all 25 locked identities.

### Approved prototype architecture

- Swift and SwiftUI, iPhone-only, portrait-first, minimum iOS 17.
- Apple frameworks only; no third-party runtime dependencies in the prototype.
- Offline-first care loop with no account or backend in v0.1.
- One local Moki is a prototype limitation, not a permanent architecture constraint.
- Stable individual identity and explicit versioned save migrations.
- Hunger, Happiness, Energy, and Bond are care meters; future battle stats and progression are separate.
- Low-anxiety care: Moki cannot die, disappear, or permanently lose progress; Bond does not decay; unattended decay stops at safe floors.
- Views do not own balance rules. Balance values remain centralized in `MokiBalance.approvedV01`.

## Current status

| Item | Status |
|---|---|
| Current branch | `milestone-3.1` |
| Latest implementation commit | `935d66f03ebc2599b22c5937c0e772527bfe735b` — Milestone 3.1 room presentation |
| Last completed milestone | ✅ Milestone 3.1 — illustrated room and cohesive game UI |
| Current implementation milestone | None; Milestone 3.2 has not started |
| Next milestone | ⏭️ Milestone 3.2 — care-interaction and presentation polish |
| Local uncommitted work | None after this roadmap commit |
| Commits not pushed | None after this roadmap commit is published to `origin/milestone-3.1` |
| Main branches | Local `main` intentionally retains `935d66f`; remote `origin/main` remains at `150893a`; no merge is authorized by this roadmap update |

### What currently works

- An iOS 17 SwiftUI app project, shared scheme, app tests, UI tests, and local pure-Swift packages exist.
- A fresh profile creates one stable individual Moki with approved initial care stats.
- Hunger, Happiness, Energy, and Bond use deterministic centralized rules and remain within `0...100`.
- Awake and sleeping time passage, safe floors, 72-hour catch-up, clock rollback, and action validation are modeled without real waiting.
- Feed, Play, Care, Sleep, and Wake flow through one action engine.
- Versioned local JSON persistence supports atomic writes, one-generation backup recovery, schema migration, corruption handling, and lifecycle saves.
- The app launches into a portrait pet room with four readable stats, care controls, action/rejection feedback, persistence warnings, and a code-native Moki representation based on the approved design.
- Moki breathes, blinks, moves its tail, sleeps, and visibly reacts while respecting Reduce Motion.
- VoiceOver labels, values, hints, minimum touch sizing, and 12 stable interaction/accessibility identifiers are present.
- Milestone 3.1 supplies matching illustrated light/day and dark/night room assets through one adaptive resource, cohesive warm stat/control styling, responsive spacing, and proportional Moki fitting on compact iPhones.
- The app remains offline and contains no account, analytics, advertising, or backend dependency.

### Incomplete work

- Milestone 3.2 and every later milestone remain unimplemented.
- Spark Catch, the generic mini-game result boundary, and chess are not implemented.
- No WidgetKit target or widget UI exists yet.
- Inventory, items, XP, levels, evolution, notifications, audio, settings, onboarding, and release packaging are not implemented.
- Placeholder Apple signing identifiers and App Group values still need an owner-controlled Apple Developer namespace.
- Final production animation coverage and additional Moki poses/assets remain future work; the approved base identity must be preserved.
- There has been no successful full Xcode build, asset-catalog compilation, simulator run, device run, TestFlight build, or App Store archive from the current repository state.

### Known technical debt and risks

- The Xcode project was authored and statically inspected on Windows, so project-file, SwiftUI, entitlement, signing, and asset-catalog behavior still require Apple-toolchain verification.
- `AppGroupPetStore` uses a development Application Support fallback while placeholder signing identifiers remain configured.
- The current save schema intentionally represents one local individual. Multiple-pet, party, collection, account, and cloud structures must arrive through explicit later migrations rather than ad hoc fields.
- Day/night artwork currently follows light/dark appearance selection. A later milestone must explicitly decide whether in-world time, sleep state, or player settings should control room time of day.
- Older status text in `README.md` and milestone review files records the state at the time each milestone stopped. This roadmap is the current status authority.
- No automated visual regression test exists. Compact/tall aspect crops were inspected on Windows, but actual SwiftUI composition still needs simulator/device review.

### Testing status

- The pure-Swift package currently contains **50 authored tests**: 28 domain tests and 22 persistence/lifecycle tests.
- The app target contains **2 authored tests**, including distinct light/dark adaptive-room asset resolution.
- The UI target contains **2 authored tests** for room launch/control presence and visible care feedback.
- A real macOS `swift test` run previously compiled successfully and executed the then-current 49-test suite. Five assertions failed because two tests incorrectly expected Energy to decay below the approved safe floor. Production behavior was correct; the fixtures were corrected and an exact-threshold test was added in commit `150893a09df447bc11394105fa56f336c6140de8`.
- The corrected 50-test package suite has not yet been rerun on macOS.
- Windows checks have covered JSON/XML parsing, Xcode-project references, balanced delimiters, test inventory, asset decoding, adaptive asset registration, accessibility identifiers, and scope boundaries.
- ⚠️ Mac/Xcode/iPhone verification is deferred, not a prerequisite for documenting, planning, or implementing independently testable work. Every affected milestone must clearly retain its Apple-platform verification flag until that verification becomes practical.

## Completed work

### Milestone 0 — Project bootstrap

1. **Goal:** Establish a minimal iPhone project and testable package structure.
2. **User-facing result:** A launchable SwiftUI app shell and stable project foundation.
3. **Major implementation tasks:** Added `Moki.xcodeproj`, shared scheme, app/test/UI-test targets, `MokiCore`, asset catalog, string extraction, signing placeholders, App Group configuration, and widget-reserved documentation.
4. **Completion criteria:** Repository structure and targets exist with no feature systems implemented prematurely.
5. **Testing/verification:** Windows structural checks passed. ⚠️ Native Xcode opening, signing, build, and scheme tests remain deferred.
6. **Current status:** ✅ Complete; accepted provisionally.

### Milestone 1 — Pet rules

1. **Goal:** Implement deterministic care-state and action rules outside the UI.
2. **User-facing result:** Moki has reliable Hunger, Happiness, Energy, and Bond behavior for Feed, Play, Care, Sleep, and Wake.
3. **Major implementation tasks:** Added `PetStats`, `PetState`, centralized balance, replaceable clocks, elapsed-time advancement, safe floors, clamping, catch-up limits, action validation, reactions, and rejections.
4. **Completion criteria:** Approved initial values and balance rules are centralized and covered by deterministic tests.
5. **Testing/verification:** 28 current domain tests are authored. The earlier Mac run exposed stale test fixtures, which were corrected without changing production balance. ⚠️ Corrected suite rerun remains deferred.
6. **Current status:** ✅ Complete; accepted provisionally.

### Milestone 2 — Persistence and lifecycle

1. **Goal:** Preserve authoritative Moki state safely across sessions and lifecycle transitions.
2. **User-facing result:** Closing, reopening, backgrounding, and returning advance and retain the pet instead of resetting it.
3. **Major implementation tasks:** Added the `MokiPersistence` boundary, versioned snapshot codec, schema migration, atomic primary/backup writes, recovery behavior, lifecycle controller, observable `PetSession`, and App Group/development storage adapter.
4. **Completion criteria:** Healthy saves round-trip; elapsed time advances on lifecycle events; corruption and future schemas fail safely; applied and rejected actions save authoritative state.
5. **Testing/verification:** 22 persistence/lifecycle tests are authored and Windows structural checks passed. ⚠️ Current suite and app lifecycle still need Mac/Xcode execution.
6. **Current status:** ✅ Complete; accepted provisionally.

### Milestone 3 — Main pet experience

1. **Goal:** Turn the domain and persistence layers into a usable virtual-pet room.
2. **User-facing result:** Players can view Moki and all four stats, perform care actions, see reactions or rejections, and observe idle/sleep behavior.
3. **Major implementation tasks:** Added the room, stat presentation, care bar, code-native approved-design Moki, transient reaction state, foreground refresh, persistence notice, Reduce Motion behavior, VoiceOver semantics, and UI tests.
4. **Completion criteria:** Every care action uses the domain engine; state changes remain persistent; feedback is readable; accessibility identifiers are stable.
5. **Testing/verification:** Windows source/project checks passed; 2 UI tests are authored. ⚠️ SwiftUI compilation, simulator interaction, VoiceOver, Reduce Motion, and lifecycle behavior need Mac/iPhone verification.
6. **Current status:** ✅ Complete; implementation accepted as the foundation for visual polish.

### Milestone 3.1 — Illustrated room and cohesive UI

1. **Goal:** Replace the prototype-looking room and generic controls with a cohesive indie-game presentation.
2. **User-facing result:** Moki appears in a warm illustrated room with matching light/day and dark/night artwork, custom stat meters, coordinated controls, and better compact-iPhone composition.
3. **Major implementation tasks:** Added adaptive illustrated backgrounds, removed geometric room drawing, restyled panels/meters/buttons/feedback, added compact-height spacing, proportionally fitted Moki, preserved all behavior and 12 identifiers, and added an adaptive-asset app test.
4. **Completion criteria:** One named resource resolves distinct light and dark art; no code-drawn room remains; Moki's approved identity and all care/accessibility behavior remain unchanged.
5. **Testing/verification:** PNG decoding, catalog JSON, resource-phase inclusion, representative aspect crops, identifiers, and source scope passed on Windows. ⚠️ Xcode asset compilation, small/large simulator composition, light/dark rendering, and interaction tests remain deferred.
6. **Current status:** ✅ Complete at implementation commit `935d66f03ebc2599b22c5937c0e772527bfe735b`; preserved on the `milestone-3.1` branch.

## MVP roadmap

### Milestone 3.2 — Care-interaction and presentation polish

1. **Goal:** Finish the moment-to-moment care presentation before adding a separate game mode.
2. **User-facing result:** Feeding, play entry, care, sleep, wake, and room-state transitions feel intentional and readable while the approved Moki remains the focus.
3. **Major implementation tasks:** Confirm the owner-approved day/night control rule; refine direct action staging and animation layering; improve sleep/rest presentation; audit rejection and save-error presentation; preserve identifiers, Reduce Motion, VoiceOver, and compact layouts.
4. **Completion criteria:** Every existing care action has clear input, response, and state feedback without introducing inventory, evolution, networking, or other later systems.
5. **Testing/verification:** Add focused view/session tests where practical; repeat Windows static checks; ⚠️ defer final motion, layout, light/dark, VoiceOver, and device review to Mac/iPhone validation.
6. **Current status:** ⏭️ Next; not started and requires explicit owner authorization before code changes.

### Milestone 4 — Spark Catch and reusable mini-game boundary

1. **Goal:** Add the first short game without coupling pet rules to one mini-game.
2. **User-facing result:** Players can complete a brief tap-based Spark Catch round and receive bounded Happiness/Bond rewards with an Energy cost.
3. **Major implementation tasks:** Define `MiniGameOutcome`; implement Spark Catch timing, safe tap area, score, accessibility alternative, result presentation, and domain-level reward application; keep the contract generic enough for future chess results.
4. **Completion criteria:** Completing, canceling, or replaying cannot bypass action limits or persistence; rewards are deterministic and bounded; no chess rules are implemented.
5. **Testing/verification:** Unit-test reward mapping and limits; UI-test entry/result flow; ⚠️ verify timing, touch targets, motion, and compact layouts on iPhone later.
6. **Current status:** 📋 Planned; original implementation-plan Milestone 4 preserved.

### Milestone 5 — Widget shell

1. **Goal:** Deliver the prepared Home Screen companion without moving game authority into WidgetKit.
2. **User-facing result:** A nonconfigurable `systemSmall` widget shows the lead/current Moki's mood and most urgent need and opens the room.
3. **Major implementation tasks:** Add WidgetKit target and App Group entitlements, define compact shared snapshot writing, implement timeline provider, static widget UI, and deep link.
4. **Completion criteria:** Widget reads only shared display data; the main app remains authoritative; stale/missing data degrades safely; no widget-only care actions.
5. **Testing/verification:** Test snapshot encoding and timeline fallback; ⚠️ App Group signing, widget gallery, timeline refresh, and device deep-link behavior require Xcode/iPhone.
6. **Current status:** 📋 Planned; original implementation-plan Milestone 5 preserved.

### Milestone 6 — Prototype QA and stabilization

1. **Goal:** Stabilize the original v0.1 prototype feature set before broadening the MVP.
2. **User-facing result:** The core room, care loop, persistence, mini-game, and widget behave predictably across ordinary and failure scenarios.
3. **Major implementation tasks:** Test fresh install, relaunch, long absence, sleep, clock rollback, corrupt saves, backup recovery, small screens, dark mode, Reduce Motion, VoiceOver, and offline behavior; resolve defects without adding unrelated systems.
4. **Completion criteria:** No known data-loss path; core loop remains usable offline; high-priority defects are closed or documented with safe workarounds.
5. **Testing/verification:** Complete all Windows-capable tests continuously. ⚠️ Apple-only build, simulator, entitlement, widget, accessibility, and device checks remain explicit deferred items until a practical environment is available.
6. **Current status:** 📋 Planned; original implementation-plan Milestone 6 preserved.

### Milestone 7 — Basic inventory, items, and progression foundation

1. **Goal:** Add a small data-driven ownership and progression layer without introducing combat or a large economy.
2. **User-facing result:** Players can earn, view, and use a limited set of care/training items and see Moki accumulate XP and levels from approved activities.
3. **Major implementation tasks:** Version inventory and individual XP/level state; define configurable item catalog and species growth curves; make rewards generic; preserve identity when saving; migrate earlier snapshots safely.
4. **Completion criteria:** Items cannot duplicate or disappear through relaunch; XP thresholds are configurable; level remains separate from care meters; old saves migrate explicitly.
5. **Testing/verification:** Unit-test inventory transactions, XP boundaries, migration, rollback/error behavior, and configuration decoding; ⚠️ verify presentation and accessibility on iPhone later.
6. **Current status:** 📋 Planned; scope and balance require owner approval.

### Milestone 8 — Evolution foundations and MVP content slice

1. **Goal:** Implement an original, data-driven evolution framework that preserves the locked five-path/25-form structure while limiting initial content to an owner-approved MVP slice.
2. **User-facing result:** Players can understand progress toward evolution and, for the approved MVP subset, evolve one individual without losing identity, care state, progression, or rare-individual compatibility.
3. **Major implementation tasks:** Define species/form identifiers; encode Normal origin, five primary paths, 25 locked outcomes, generic evolution conditions, mutually exclusive path selection, secondary-outcome resolution, migration/versioning, and reversible development diagnostics. Do not invent final art or balance without approval.
4. **Completion criteria:** The type matrix exactly matches this roadmap; conditions are data-driven; one individual cannot enter conflicting primary paths; old and evolved saves decode safely; the full 25-form art rollout is not falsely marked complete.
5. **Testing/verification:** Exhaustively test path exclusivity, all 25 identifiers, condition evaluation, deterministic selection, migration, and save round trips; ⚠️ evolution presentation and assets require later iPhone review.
6. **Current status:** 📋 Planned; no evolution code or content is currently authorized.

### Milestone 9 — Notifications, sound, music, and settings foundations

1. **Goal:** Add optional platform polish without creating anxiety or requiring constant engagement.
2. **User-facing result:** Players can control sound/music, accessibility preferences, and a small set of respectful local reminders.
3. **Major implementation tasks:** Add settings persistence, audio session/service boundaries, initial sound/music assets, independent volume/toggles, local-notification permission education, opt-in scheduling, and cancellation when needs are resolved.
4. **Completion criteria:** The app works fully with notifications denied and audio muted; reminders are sparse, local, and never imply death or permanent loss; settings survive relaunch.
5. **Testing/verification:** Unit-test scheduling decisions and settings; inspect audio interruption behavior; ⚠️ permission prompts, notification delivery, hardware mute, and device audio require iPhone verification.
6. **Current status:** 📋 Planned; notifications remain excluded until this milestone is explicitly approved.

### Milestone 10 — Onboarding, launch experience, resilience, and accessibility audit

1. **Goal:** Make the MVP understandable and trustworthy from first launch through recoverable errors.
2. **User-facing result:** A new player meets Moki, learns the care loop, sees a polished app icon/launch experience, and receives clear recovery guidance when something fails.
3. **Major implementation tasks:** Add concise onboarding, first-run state, app icon, launch screen, terminology review, save/permission error presentation, settings entry, Dynamic Type audit, contrast audit, VoiceOver order, Reduce Motion coverage, and localization readiness.
4. **Completion criteria:** Onboarding is skippable and replayable; no error silently discards data; primary flows remain accessible; all placeholder branding required for release is replaced.
5. **Testing/verification:** Add onboarding/error UI tests and accessibility assertions where possible; ⚠️ final icon, launch, Dynamic Type, VoiceOver, contrast, and motion review require Apple devices/tools.
6. **Current status:** 📋 Planned.

### Milestone 11 — Apple-platform verification and TestFlight preparation

1. **Goal:** Turn the statically validated repository into a signed, installable external-test build when a practical Mac environment becomes available.
2. **User-facing result:** The owner can install and test Moki through TestFlight on real iPhones.
3. **Major implementation tasks:** Configure owner bundle/App Group identifiers and signing; build all targets; compile assets; run package/app/UI tests; fix Apple-toolchain defects; test supported iPhone sizes; produce archive; configure privacy metadata and TestFlight notes.
4. **Completion criteria:** Clean release build and archive, passing required tests, working persistence/App Group/widget, no blocker defects, and successful TestFlight installation.
5. **Testing/verification:** ⚠️ This milestone is inherently Mac/Xcode/iPhone-dependent. It may be deferred without blocking earlier documentation or Windows-testable implementation work.
6. **Current status:** 📋 Planned; environment currently unavailable or impractical.

### Milestone 12 — App Store MVP readiness

1. **Goal:** Prepare the verified MVP for an App Store submission decision.
2. **User-facing result:** A coherent, stable, clearly described Moki release suitable for public download if approved by the owner.
3. **Major implementation tasks:** Finalize store metadata/screenshots, support/privacy pages, age rating, review notes, accessibility statement, content rights review, crash/error audit, versioning, release checklist, and rollout/rollback plan.
4. **Completion criteria:** No unresolved release blocker; store assets match the app; privacy declarations match actual behavior; owner approves the submitted feature/content scope.
5. **Testing/verification:** Final regression on TestFlight and representative supported devices; verify clean install, upgrade/migration, offline use, and recovery paths.
6. **Current status:** 📋 Planned.

## Post-MVP and future features

These ideas are not required for the first App Store MVP and must not be pulled into an active milestone without explicit approval:

- 🔮 Full production artwork, animation, balance, and content rollout for all 25 locked final evolution forms.
- 🔮 Additional base-Moki poses, expressions, animation sets, and rare individual visual variants.
- 🔮 Expanded rooms, environments, furniture, cosmetics, collectibles, and personalization.
- 🔮 More mini-games and a future chess mini-game using generic achievement/result contracts rather than coupling moves directly to chess.
- 🔮 Expanded XP, levels, species growth curves, learnable move pools, more-than-four learned moves, four equipped moves, training items, achievements, and ranks.
- 🔮 Battles using HP, Attack, Defense, Special Attack, Special Defense, and Speed.
- 🔮 Individual hidden innate potential values in the locked inclusive `1...50` range, attached to stable individual identity.
- 🔮 Breeding, parent/offspring records, inheritance of some innate potential, and possible original rare-variant inheritance rules.
- 🔮 An ordered active party of up to four Mokis, lead Moki in slot 1, capturing, collection/box storage, and movement between party and storage without losing individual state.
- 🔮 Accounts, cloud persistence, cross-device synchronization, conflict resolution, social features, and potential multiplayer features.
- 🔮 Additional creatures, species, regions, encounters, maps, exploration, gyms, Championship, and other large content systems.
- 🔮 Expanded soundtracks, voiced/animated presentation, seasonal content, and live content operations.
- 🔮 Optional monetization or content systems only after separate ethical, product, platform, and child-safety review; none is currently approved.

Future individual-trait, progression, move, party, collection, breeding, and rare-variant constraints are detailed in `docs/FUTURE_INDIVIDUAL_TRAITS_AND_BATTLE_ARCHITECTURE.md` and remain authoritative alongside this roadmap.

## Testing without a practical Mac environment

Lack of a practical Mac is a verification constraint, not a reason to lose roadmap continuity or stop all development. For every milestone:

1. Keep pure domain logic independent of SwiftUI and Apple-only runtime state where practical.
2. Add deterministic package tests for rules, migrations, configuration, and persistence boundaries.
3. Run Windows-capable structural checks, JSON/XML validation, asset decoding, source-scope checks, and Git hygiene.
4. Record exact Apple-only checks with the ⚠️ marker instead of claiming they passed.
5. Avoid stacking speculative Xcode-project changes when a simpler testable boundary is available.
6. When Mac access becomes practical, validate accumulated Apple-only items in priority order: compile/package tests, app build, persistence, asset catalog, compact/large layouts, light/dark, accessibility, widget/App Group, archive, then device/TestFlight.

## How to continue this project

Every future Codex session should:

1. Read `MOKI_ROADMAP.md` first.
2. Inspect the current Git branch, working-tree status, recent history, and remote tracking state.
3. Determine the next incomplete milestone and confirm the requested scope against this roadmap.
4. Work only on the requested milestone unless the owner explicitly authorizes broader work.
5. Update `MOKI_ROADMAP.md` whenever a milestone completes, its status changes, or a project decision changes.
6. Commit code and its corresponding roadmap/status update together when appropriate.
7. Never silently change locked game-design decisions, including the approved base Moki identity and evolution matrix.
8. Clearly identify every result that still requires Mac/Xcode/iPhone testing; do not claim unavailable validation passed.
9. Preserve unrelated user changes and stop rather than force-pushing, rewriting history, or overwriting remote work.
10. Do not infer authorization for the next milestone from completion of the current one.

## Documentation maintenance rule

When project state changes, update the **Current status**, affected milestone, testing counts/results, known issues, and remote/branch notes in this file. Preserve historical milestone review files rather than rewriting them to look current. If a new locked design decision conflicts with this roadmap, record the owner's explicit decision and date before implementation.
