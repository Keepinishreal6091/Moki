import Foundation
import SwiftUI
import MokiCore

/// Code-native placeholder art informed by the approved character reference.
/// It is intentionally not a production sprite or an extraction from the sheet.
struct MokiPlaceholderView: View {
    let isSleeping: Bool
    let reaction: PetReaction?
    let reduceMotion: Bool

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0,
                paused: reduceMotion
            )
        ) { context in
            let seconds = context.date.timeIntervalSinceReferenceDate
            let idleScale: CGFloat = reduceMotion
                ? 1.0
                : 1.0 + CGFloat(sin(seconds * 2.1)) * 0.018
            let tailSwing = reduceMotion || isSleeping
                ? 0.0
                : sin(seconds * 4.0) * 10.0
            let isBlinking = isSleeping || (
                !reduceMotion
                    && seconds.truncatingRemainder(dividingBy: 4.1) < 0.13
            )

            ZStack(alignment: .bottom) {
                Ellipse()
                    .fill(MokiRoomPalette.shadow.opacity(0.16))
                    .frame(width: 190, height: 24)
                    .blur(radius: 3)
                    .offset(y: 2)

                MokiCharacterArt(
                    isSleeping: isSleeping,
                    isBlinking: isBlinking,
                    tailAngle: tailSwing
                )
                .scaleEffect(idleScale * reactionScale)
                .offset(y: reduceMotion ? 0 : reactionOffset)
                .rotationEffect(reduceMotion ? .zero : reactionRotation)
                .animation(reactionAnimation, value: reaction)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityDescription))
        .accessibilityIdentifier("moki.placeholder")
    }

    private var reactionScale: CGFloat {
        switch reaction {
        case .enjoyedFood: return 1.04
        case .enjoyedPlay: return 1.06
        case .appreciatedCare: return 1.08
        case .fellAsleep: return 0.97
        case .wokeUp: return 1.04
        case nil: return 1.0
        }
    }

    private var reactionOffset: CGFloat {
        switch reaction {
        case .enjoyedPlay, .wokeUp: return -14
        case .appreciatedCare: return -5
        case .enjoyedFood, .fellAsleep, nil: return 0
        }
    }

    private var reactionRotation: Angle {
        switch reaction {
        case .enjoyedPlay: return .degrees(-4)
        case .appreciatedCare: return .degrees(3)
        default: return .zero
        }
    }

    private var reactionAnimation: Animation {
        reduceMotion
            ? .easeInOut(duration: 0.15)
            : .spring(response: 0.3, dampingFraction: 0.55)
    }

    private var accessibilityDescription: LocalizedStringKey {
        if isSleeping {
            return "Moki is sleeping peacefully."
        }

        switch reaction {
        case .enjoyedFood: return "Moki happily eats."
        case .enjoyedPlay: return "Moki bounces with excitement."
        case .appreciatedCare: return "Moki leans in affectionately."
        case .fellAsleep: return "Moki settles down to sleep."
        case .wokeUp: return "Moki wakes up and stretches."
        case nil: return "Moki is awake and gently breathing."
        }
    }
}

private struct MokiCharacterArt: View {
    let isSleeping: Bool
    let isBlinking: Bool
    let tailAngle: Double

    var body: some View {
        ZStack {
            Capsule()
                .fill(MokiRoomPalette.charcoal)
                .frame(width: 88, height: 35)
                .rotationEffect(.degrees(-28 + tailAngle), anchor: .leading)
                .offset(x: 82, y: 48)

            Ellipse()
                .fill(MokiRoomPalette.cream)
                .frame(width: 146, height: 118)
                .offset(y: 45)

            legs
            neckRuff
            ears

            Circle()
                .fill(MokiRoomPalette.lightCream)
                .frame(width: 132, height: 132)
                .offset(y: -42)

            foreheadTuft
            face

            if isSleeping {
                Text("Z")
                    .font(.title2.bold())
                    .foregroundStyle(MokiRoomPalette.gold)
                    .offset(x: 78, y: -98)
                    .accessibilityHidden(true)
            }
        }
        .frame(width: 260, height: 250)
    }

    private var legs: some View {
        HStack(spacing: 62) {
            leg
            leg
        }
        .offset(y: 93)
    }

    private var leg: some View {
        Capsule()
            .fill(MokiRoomPalette.cream)
            .frame(width: 36, height: 76)
            .overlay(alignment: .bottom) {
                Capsule()
                    .fill(MokiRoomPalette.charcoal)
                    .frame(height: 22)
            }
    }

    private var neckRuff: some View {
        HStack(spacing: -8) {
            ForEach(0..<5, id: \.self) { _ in
                Circle()
                    .fill(MokiRoomPalette.charcoal)
                    .frame(width: 38, height: 38)
            }
        }
        .offset(y: 20)
    }

    private var ears: some View {
        HStack(spacing: 64) {
            Capsule()
                .fill(MokiRoomPalette.charcoal)
                .frame(width: 54, height: 118)
                .rotationEffect(.degrees(25))

            Capsule()
                .fill(MokiRoomPalette.charcoal)
                .frame(width: 54, height: 118)
                .rotationEffect(.degrees(-25))
        }
        .offset(y: -36)
    }

    private var foreheadTuft: some View {
        HStack(spacing: -8) {
            Capsule()
                .fill(MokiRoomPalette.cream)
                .frame(width: 25, height: 62)
                .rotationEffect(.degrees(-25))
            Capsule()
                .fill(MokiRoomPalette.lightCream)
                .frame(width: 24, height: 72)
            Capsule()
                .fill(MokiRoomPalette.cream)
                .frame(width: 25, height: 58)
                .rotationEffect(.degrees(27))
        }
        .offset(y: -105)
    }

    private var face: some View {
        VStack(spacing: 8) {
            HStack(spacing: 38) {
                MokiEye(isClosed: isBlinking)
                MokiEye(isClosed: isBlinking)
            }

            VStack(spacing: 1) {
                Ellipse()
                    .fill(MokiRoomPalette.charcoal)
                    .frame(width: 22, height: 15)

                Capsule()
                    .stroke(MokiRoomPalette.charcoal, lineWidth: 3)
                    .frame(width: 34, height: isSleeping ? 6 : 12)
            }
        }
        .offset(y: -35)
    }
}

private struct MokiEye: View {
    let isClosed: Bool

    var body: some View {
        if isClosed {
            Capsule()
                .fill(MokiRoomPalette.charcoal)
                .frame(width: 24, height: 4)
        } else {
            Ellipse()
                .fill(MokiRoomPalette.charcoal)
                .frame(width: 25, height: 33)
                .overlay(alignment: .topLeading) {
                    Circle()
                        .fill(.white)
                        .frame(width: 8, height: 8)
                        .padding(5)
                }
        }
    }
}
