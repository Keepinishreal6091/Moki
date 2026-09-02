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
                    tint: MokiRoomPalette.hunger,
                    identifier: "stat.hunger"
                )
                StatMeter(
                    title: "Happiness",
                    symbol: "face.smiling.fill",
                    value: stats.happiness,
                    tint: MokiRoomPalette.happiness,
                    identifier: "stat.happiness"
                )
            }

            GridRow {
                StatMeter(
                    title: "Energy",
                    symbol: "bolt.fill",
                    value: stats.energy,
                    tint: MokiRoomPalette.energy,
                    identifier: "stat.energy"
                )
                StatMeter(
                    title: "Bond",
                    symbol: "heart.fill",
                    value: stats.bond,
                    tint: MokiRoomPalette.bond,
                    identifier: "stat.bond"
                )
            }
        }
        .padding(12)
        .background(
            MokiRoomPalette.panel.opacity(0.94),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(MokiRoomPalette.panelBorder, lineWidth: 1)
        }
        .shadow(color: MokiRoomPalette.shadow.opacity(0.14), radius: 10, y: 4)
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
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)
                    .frame(width: 22, height: 22)
                    .background(tint.opacity(0.14), in: Circle())
                    .accessibilityHidden(true)

                Text(title)
                    .font(.caption.weight(.semibold))

                Spacer(minLength: 2)

                Text(displayValue, format: .number)
                    .font(.caption.monospacedDigit().weight(.bold))
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(MokiRoomPalette.meterTrack)

                    Capsule()
                        .fill(tint)
                        .frame(
                            width: proxy.size.width * CGFloat(boundedValue / 100)
                        )
                }
                .overlay {
                    Capsule()
                        .stroke(MokiRoomPalette.panelBorder.opacity(0.55), lineWidth: 0.5)
                }
            }
            .frame(height: 8)
            .accessibilityHidden(true)
        }
        .foregroundStyle(MokiRoomPalette.ink)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text("\(displayValue) out of 100"))
        .accessibilityIdentifier(identifier)
    }
}
