# Moki

Moki is an iPhone-first virtual-pet project. **Milestone 3 is implemented and awaiting Swift compiler/Xcode validation and owner review.** The pet rules, versioned local persistence, lifecycle coordination, and first SwiftUI room experience are in place; the mini-game, widget target, and later systems have not yet been implemented.

## Current milestone

Build only the first iPhone prototype:

- A simple room where Moki lives.
- Hunger, Happiness, Energy, and Bond.
- Local persistence and real-time stat changes while the app is closed.
- Feed, Play, Care, and Sleep interactions.
- Visible reactions and simple idle movement.
- One small mini-game.
- A mini-game boundary that can support chess later.
- A WidgetKit-ready shared-data design, with the main pet loop delivered first.
- Placeholder artwork informed by the approved visual reference.

The full vision is preserved in `docs/Moki_Game_Design_Document_v0.1.docx`, but it is not the implementation scope for this milestone.

## Milestone status

Review `docs/MILESTONE_3_REVIEW.md` for the delivered room, stat presentation, interaction feedback, placeholder Moki animation, accessibility behavior, deferred Xcode validation, and the stop condition before Milestone 4. `docs/Moki_v0.1_Implementation_Plan.md` records the approved architecture, later milestones, acceptance criteria, and explicit exclusions.

## Repository references

- `docs/Moki_Game_Design_Document_v0.1.docx` - overall product context.
- `docs/references/Moki_Character_Reference_v0.1.png` - visual direction only; not a production sprite.
- `docs/Moki_v0.1_Implementation_Plan.md` - proposed prototype architecture and build order.
- `docs/V0_1_IMPLEMENTATION_BRIEF.md` - tightly scoped build instruction for the next implementation pass.
- `docs/MILESTONE_0_REVIEW.md` - Milestone 0 delivery summary and Mac validation checklist.
- `docs/MILESTONE_1_REVIEW.md` - Milestone 1 domain rules, balance values, test coverage, and validation status.
- `docs/MILESTONE_2_REVIEW.md` - Milestone 2 persistence, lifecycle integration, recovery behavior, and validation status.
- `docs/MILESTONE_3_REVIEW.md` - Milestone 3 room experience, reactions, accessibility, UI-test coverage, and validation status.
- `docs/FUTURE_INDIVIDUAL_TRAITS_AND_BATTLE_ARCHITECTURE.md` - deferred individual potential, battle, progression, moves, party/collection, breeding, and original rare-variant requirements.
