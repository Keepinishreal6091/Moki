import SwiftUI
import MokiCore

struct StatMetersView: View {
    let stats: PetStats

    var body: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 10) {
            GridRow {
                StatMeter(
                    title: "Hunger",
                    symbol: "fork.knife",
                    value: stats.hunger,
                    tint: .orange,
                    identifier: "stat.hunger"
                )
                StatMeter(
                    title: "Happiness",
                    symbol: "face.smiling.fill",
                    value: stats.happiness,
                    tint: .pink,
                    identifier: "stat.happiness"
                )
            }

            GridRow {
                StatMeter(
                    title: "Energy",
                    symbol: "bolt.fill",
                    value: stats.energy,
                    tint: .yellow,
                    identifier: "stat.energy"
                )
                StatMeter(
                    title: "Bond",
                    symbol: "heart.fill",
                    value: stats.bond,
                    tint: .purple,
                    identifier: "stat.bond"
                )
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: MokiRoomPalette.ink.opacity(0.08), radius: 8, y: 3)
    }
}

private struct StatMeter: View {
    let title: LocalizedStringKey
    let symbol: String
    let value: Double
    let tint: Color
    let identifier: String

    private var displayValue: Int {
        Int(value.rounded())
    }

    private var boundedValue: Double {
        min(max(value, 0), 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                    .foregroundStyle(tint)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.caption.weight(.semibold))

                Spacer(minLength: 2)

                Text(displayValue, format: .number)
                    .font(.caption.monospacedDigit().weight(.bold))
            }

            ProgressView(value: boundedValue, total: 100)
                .tint(tint)
                .accessibilityHidden(true)
        }
        .foregroundStyle(MokiRoomPalette.ink)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text("\(displayValue) out of 100"))
        .accessibilityIdentifier(identifier)
    }
}
