# Moki v0.1 Implementation Brief

Read `docs/Moki_Game_Design_Document_v0.1.docx` for overall product context and `docs/references/Moki_Character_Reference_v0.1.png` for visual direction.

We are **not** building the entire game yet. Build only the first iPhone prototype (v0.1) using Swift and SwiftUI.

The first milestone is a virtual-pet experience:

- Moki lives in a simple room.
- Moki has Hunger, Happiness, Energy, and Bond.
- Stats persist when the app closes and change based on elapsed real time.
- The player can Feed, Play, Care, and put Moki to Sleep.
- Moki visibly reacts to interactions.
- Moki has simple idle movement so it feels alive.
- Include one very simple mini-game.
- Keep the mini-game boundary open so chess can be added later.
- Prepare shared data and project structure for a WidgetKit Home Screen widget, but prioritize the main pet experience.
- Use placeholder Moki artwork initially. The supplied character sheet is a reference, not a production sprite.

Do not implement evolution, battles, wild creatures, exploration/maps, gyms, Championship, trading, backend accounts, social systems, or other later GDD systems.

Before writing feature code, review and confirm `docs/Moki_v0.1_Implementation_Plan.md`. Implement one milestone at a time, with tests for pet rules, time passage, and persistence.
