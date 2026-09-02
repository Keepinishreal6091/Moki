# Milestone 3.1 Visual Review

Status: **implemented; awaiting Xcode build, simulator visual QA, and owner review**

Milestone 3.1 replaces the code-drawn placeholder room presentation without changing pet behavior, persistence, interaction identifiers, or the approved Moki character drawing.

## Illustrated room

- Added a full-bleed, portrait daytime room illustration with warm plaster, natural wood, soft textiles, curated pet-scale details, and a clear central character stage.
- Added a matching night illustration derived from the same composition, with warm interior light and restrained moonlight.
- Registered both variants as one adaptive `MokiRoomBackground` asset. The asset catalog selects the night artwork for dark appearance.
- The image uses aspect-fill framing so every supported iPhone remains full bleed. Essential room architecture and the character stage remain centered while narrow or tall devices crop only peripheral detail.
- Removed the previous gradient wall, geometric window, baseboard, and flat floor drawing entirely.

## Cohesive game interface

- Replaced generic system material panels with warm parchment and charcoal surfaces, antique-gold borders, and restrained shadows.
- Replaced the system progress bars with custom compact meters using the shared room palette.
- Restyled stat icons, action icons, and care controls with coordinated, muted accent colors.
- Restyled the title and feedback surfaces to use the same visual language.
- Preserved every existing accessibility label, hint, value, and UI-test identifier.

## Responsive behavior

- Compact-height iPhones use reduced spacing, margins, and a smaller character stage.
- Moki now scales proportionally into the available stage instead of overflowing its layout frame; the character artwork itself is unchanged.
- Standard and tall phones retain a larger stage while respecting the existing control and feedback regions.
- Light and dark appearances use paired artwork plus adaptive foreground, panel, border, text, and meter colors.

## Validation status

Windows validation confirms that both PNGs decode successfully at `853 x 1844`, the asset-catalog JSON is valid, the day and dark variants are uniquely registered, the named image is referenced by the room view, and all existing interaction/accessibility identifiers remain present.

This environment does not provide `swift`, `swiftc`, `xcodebuild`, `actool`, an iOS Simulator, or SwiftUI previews. Compilation, asset-catalog compilation, automated test execution, and final pixel-level simulator inspection therefore remain required on macOS before final acceptance.

## macOS review checklist

1. Build and test the shared `Moki` scheme on an iOS 17-or-later simulator.
2. Launch on the smallest supported iPhone and a current large iPhone in light and dark appearances.
3. Confirm the daytime and night room variants load with no missing-asset indicator.
4. Confirm Moki remains fully visible above the circular rug and does not overlap the stat or action panels.
5. Confirm title, stats, feedback, persistence warning, and all four care buttons remain readable in both appearances.
6. Exercise Feed, Play, Care, Sleep, Wake, and rejected-action feedback; confirm behavior and identifiers are unchanged.
7. Repeat with Reduce Motion and VoiceOver enabled.

Milestone 3.2 has not begun.
