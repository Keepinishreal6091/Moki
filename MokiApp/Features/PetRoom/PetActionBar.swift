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
                tint: .orange,
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
                tint: .pink,
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
                tint: .purple,
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
                tint: .indigo,
                hint: isSleeping
                    ? "Wake Moki up."
                    : "Put Moki to sleep to recover Energy.",
                identifier: "action.sleep"
            ) {
                _ = perform(isSleeping ? .wakeUp : .sleep)
            }
        }
        .padding(8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: MokiRoomPalette.ink.opacity(0.12), radius: 8, y: 3)
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
                    .accessibilityHidden(true)

                Text(title)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 13))
            .contentShape(RoundedRectangle(cornerRadius: 13))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(hint))
        .accessibilityIdentifier(identifier)
    }
}
