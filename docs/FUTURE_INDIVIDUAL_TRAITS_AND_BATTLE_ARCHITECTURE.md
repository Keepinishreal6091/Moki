# Future Individual Traits, Battle Stats, and Breeding Architecture

Status: **architectural requirements only; implementation explicitly deferred**

This document records future requirements that the v0.1 identity and persistence architecture must be able to accommodate. It does not authorize their implementation during the current prototype milestones.

## Future battle-stat model

The future battle system uses exactly six battle stats:

1. HP
2. Attack
3. Defense
4. Special Attack
5. Special Defense
6. Speed

These are separate from the v0.1 care meters Hunger, Happiness, Energy, and Bond.

Future calculated battle-stat formulas may combine:

- Species or form base stats.
- Level or another progression value.
- Individual hidden innate potential.
- Other explicitly designed modifiers added in later milestones.

No formula, leveling system, combat behavior, move calculation, or balance value is defined by this requirement.

## Hidden innate potential

Every individual Moki will eventually have one hidden innate potential value corresponding to each of the six battle stats.

- Each value uses an inclusive `1...50` range.
- The values belong to the individual Moki, not to its species or form.
- Two Mokis of the same species may have different hidden potential values.
- Hidden potential is not a replacement for species/base stats or progression; future formulas may combine all three.
- Generation odds, distributions, visibility, appraisal, rerolling, and balance implications remain intentionally undefined.

## Future identity-model compatibility

The stable individual Moki identity is the architectural anchor. Future innate potential and rare-variant state must attach to that individual identity rather than to a species catalog record, UI view, battle instance, or save-file location.

Persistence remains versioned so a later schema can add an individual-traits component through an explicit migration. Milestone 2 must not add placeholder battle values, generate random potential, or reserve meaningless fields in the current snapshot. Forward compatibility comes from stable identity plus versioned migration, not from prematurely implementing the mechanic.

## Breeding and inheritance

Future breeding may allow offspring to inherit some innate potential values from their parents.

- Exact inheritance rules are intentionally undefined.
- The number of inherited values, parent-selection rules, randomness, mutation, caps, items, guarantees, and player-facing presentation are all deferred.
- Parent/offspring relationships and breeding records are not part of v0.1.
- The future data model should be able to reference individual parents and copy or derive individual-trait values without restructuring the core individual identity model.

## Extremely rare alternate visual variant

An individual Moki may eventually receive an extremely rare alternate visual variant when that individual is created or hatched.

- The property belongs to the individual Moki.
- Mokis of the same species may therefore differ in rare-variant status.
- Future breeding rules may interact with the property if desired.
- Odds, inheritance, visual treatment, naming, discovery presentation, and asset production remain undefined.
- This must be an original Moki rare-variant system. Do not use franchise-specific terminology, presentation, copied mechanics, or assets.

## Future progression

Each individual Moki will eventually have both an underlying XP or experience value and a derived level in the inclusive `1...100` range.

- Level and XP belong to the individual Moki and remain attached to its stable identity.
- Level and XP are separate from the v0.1 care meters Hunger, Happiness, Energy, and Bond.
- XP thresholds and growth curves must be data-driven and configurable rather than embedded in UI or battle code.
- Different species may eventually reference different growth curves.
- Future calculated battle stats may scale with level.
- Reaching a configured level may be one possible future evolution requirement, but no evolution rule is defined here.

XP sources, curve shapes, level-up presentation, maximum-XP behavior, rewards, and migration rules remain intentionally undefined.

## Future moves and generic unlock requirements

Each species will eventually define a pool of moves its members can learn. An individual Moki may learn or unlock more than four moves over time, while its active battle loadout is limited to four equipped moves.

Possible future unlock sources include:

- Automatic learning at configured levels.
- Collectible or consumable training items.
- Generic achievement, progression, participation, rank, or score-threshold requirements.
- A result produced by a future mini-game. For example, a configured achievement or score in a future chess mini-game may satisfy a move-unlock requirement.

The move system must consume generic requirement or achievement identifiers and values. It must not import, own, or directly couple itself to a specific mini-game implementation. Move definitions, effects, types, costs, item behavior, replacement rules, duplicate handling, and exact unlock conditions remain undefined.

## Future party and collection

Players will eventually manage an active ordered party containing up to four individual Mokis.

- Party order is meaningful; slot 1 is the lead or primary Moki.
- The main app will eventually support viewing and managing all four active Mokis.
- The widget will display only the lead Moki in slot 1.
- Future wild encounters may add captured Mokis to the party when a slot is available.
- When all four party slots are occupied, additional captured Mokis go to a separate collection or box.
- Players will eventually be able to move Mokis between the ordered party and the collection.
- The collection or box should eventually support cloud persistence and cross-device synchronization.
- An individual Moki's identity, care state, progression, learned moves, equipped moves, and other individual state must remain attached to that Moki when it moves between party slots and storage.

Party editing, capture rules, collection capacity, conflict resolution, accounts, cloud provider, synchronization semantics, and offline reconciliation remain undefined.

## Prototype limitation versus permanent architecture

“One local Moki, no account” is a v0.1 prototype limitation, not the permanent Moki architecture. Current prototype code may operate on one locally persisted Moki, but it should keep individual identity distinct from save-file location and avoid unnecessary assumptions that permanently prevent multiple Mokis, an ordered party, collection storage, or future account-backed synchronization.

This clarification does not authorize a collection, party wrapper, account abstraction, cloud layer, multiple-pet UI, or speculative compatibility fields in v0.1. Stable individual identity, clear boundaries, and versioned migrations are sufficient for the current implementation.

## Explicit non-implementation boundary

Do not implement any of the following during the current prototype milestone unless a later milestone explicitly authorizes it:

- Battle-stat properties or calculations.
- Hidden potential properties, generation, display, appraisal, or randomization.
- Breeding, parent records, offspring creation, or inheritance.
- Rare-variant properties, odds, generation, inheritance, presentation, or assets.
- Leveling or progression formulas.
- Combat, moves, damage, teams, or battle calculations.
- XP, levels, growth curves, learnable-move pools, learned moves, or active move loadouts.
- Training items or move unlocks from achievements, ranks, scores, or mini-games.
- Multiple-pet parties, lead-slot behavior, capturing, collections/boxes, swapping, accounts, cloud persistence, or cross-device synchronization.

These requirements guide future migrations and identity ownership only.
