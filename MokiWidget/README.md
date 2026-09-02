# Moki Widget target (deferred)

The WidgetKit target is intentionally deferred until the main pet-room loop passes its acceptance checks.

Milestone 0 reserves this folder and the shared App Group identifier. Later widget work should:

- Add a nonconfigurable `systemSmall` widget target.
- Import `MokiCore`.
- Read a compact, versioned pet snapshot from the shared App Group container.
- Show Moki's mood and most urgent need.
- Deep-link to the main room.
- Avoid networking, location, animation requirements, or duplicated pet rules.

Do not add the widget target during Milestones 1-4 unless the approved plan changes.
