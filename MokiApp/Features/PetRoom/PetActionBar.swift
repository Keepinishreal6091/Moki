import SwiftUI
import MokiCore

struct PetActionBar: View {
    let isSleeping: Bool
    let perform: (PetAction) -> PetActionResult

    var body: some View {
        HStack(spacing: 8) {
            PetActionButton(
                title: "Feed",
                symbol: "carrot.fill",
                tint: MokiRoomPalette.hunger,
                hint: isSleeping
                    ? "Wake Moki before feeding."
                    : "Give Moki a snack.",
                identifier: "action.feed"
            ) {
                _ = perform(.feed)
            }

            PetActionButton(
                title: "Play",
                symbol: "balloon.2.fill",
                tint: MokiRoomPalette.happiness,
                hint: isSleeping
                    ? "Wake Moki before playing."
                    : "Play together using Energy.",
                identifier: "action.play"
            ) {
                _ = perform(.play)
            }

            PetActionButton(
                title: "Care",
                symbol: "hands.sparkles.fill",
                tint: MokiRoomPalette.bond,
                hint: isSleeping
                    ? "Wake Moki before giving care."
                    : "Spend a quiet moment caring for Moki.",
                identifier: "action.care"
            ) {
                _ = perform(.care)
            }

            PetActionButton(
                title: isSleeping ? "Wake" : "Sleep",
                symbol: isSleeping ? "sun.max.fill" : "moon.zzz.fill",
                tint: MokiRoomPalette.rest,
                hint: isSleeping
                    ? "Wake Moki up."
                    : "Put Moki to sleep to recover Energy.",
                identifier: "action.sleep"
            ) {
                _ = perform(isSleeping ? .wakeUp : .sleep)
            }
        }
        .padding(8)
        .background(
            MokiRoomPalette.panel.opacity(0.96),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(MokiRoomPalette.panelBorder, lineWidth: 1)
        }
        .shadow(color: MokiRoomPalette.shadow.opacity(0.18), radius: 10, y: 4)
    }
}

private struct PetActionButton: View {
    let title: LocalizedStringKey
    let symbol: String
    let tint: Color
    let hint: LocalizedStringKey
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 30)
                    .background(tint.opacity(0.14), in: Circle())
                    .accessibilityHidden(true)

                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MokiRoomPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                MokiRoomPalette.controlSurface,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(MokiRoomPalette.panelBorder.opacity(0.7), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(hint))
        .accessibilityIdentifier(identifier)
    }
}
