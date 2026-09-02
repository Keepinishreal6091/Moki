import SwiftUI
import UIKit
import MokiCore

struct PetRoomView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let session: PetSession

    var body: some View {
        GeometryReader { proxy in
            let usesCompactSpacing = proxy.size.height < 700

            ZStack {
                RoomBackgroundView()

                VStack(spacing: usesCompactSpacing ? 8 : 12) {
                    roomHeader

                    StatMetersView(stats: session.state.stats)

                    Spacer(minLength: 2)

                    MokiPlaceholderView(
                        isSleeping: session.state.isSleeping,
                        reaction: session.reaction,
                        reduceMotion: reduceMotion
                    )
                    .frame(
                        height: mokiStageHeight(
                            availableHeight: proxy.size.height,
                            usesCompactSpacing: usesCompactSpacing
                        )
                    )

                    feedbackArea

                    if session.lastPersistenceIssue != nil {
                        persistenceNotice
                    }

                    PetActionBar(
                        isSleeping: session.state.isSleeping,
                        perform: session.apply
                    )
                }
                .padding(.horizontal, usesCompactSpacing ? 12 : 16)
                .padding(.top, usesCompactSpacing ? 6 : 8)
                .padding(.bottom, usesCompactSpacing ? 8 : 12)
            }
        }
        .task {
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 60_000_000_000)
                } catch {
                    return
                }
                session.refreshForActiveScene()
            }
        }
    }

    private func mokiStageHeight(
        availableHeight: CGFloat,
        usesCompactSpacing: Bool
    ) -> CGFloat {
        if usesCompactSpacing {
            return min(max(availableHeight * 0.26, 160), 210)
        }

        return min(max(availableHeight * 0.32, 190), 270)
    }

    private var roomHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Moki's Room")
                    .font(.title2.bold())
                    .foregroundStyle(MokiRoomPalette.ink)
                    .accessibilityIdentifier("pet-room.title")

                Text(roomSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(MokiRoomPalette.secondaryInk)
            }

            Spacer()

            Image(systemName: session.state.isSleeping ? "moon.stars.fill" : "heart.fill")
                .font(.title2)
                .foregroundStyle(MokiRoomPalette.gold)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            MokiRoomPalette.panel.opacity(0.94),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(MokiRoomPalette.panelBorder, lineWidth: 1)
        }
        .shadow(color: MokiRoomPalette.shadow.opacity(0.14), radius: 10, y: 4)
    }

    private var roomSubtitle: LocalizedStringKey {
        session.state.isSleeping
            ? "Dreaming peacefully"
            : "Your little companion"
    }

    @ViewBuilder
    private var feedbackArea: some View {
        ZStack {
            if let reaction = session.reaction {
                PetFeedbackBubble(
                    symbol: reaction.symbolName,
                    message: reaction.message
                )
                .transition(feedbackTransition)
            } else if let rejection = session.rejection {
                PetFeedbackBubble(
                    symbol: "info.circle.fill",
                    message: rejection.message
                )
                .transition(feedbackTransition)
            }
        }
        .frame(height: 38)
        .animation(
            reduceMotion ? .easeInOut(duration: 0.15) : .spring(response: 0.3),
            value: session.reaction
        )
        .animation(
            reduceMotion ? .easeInOut(duration: 0.15) : .spring(response: 0.3),
            value: session.rejection
        )
    }

    private var feedbackTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .scale(scale: 0.9).combined(with: .opacity),
                removal: .opacity
            )
    }

    private var persistenceNotice: some View {
        Label(
            "Moki's progress could not be saved. We'll try again.",
            systemImage: "exclamationmark.triangle.fill"
        )
        .font(.caption)
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("persistence.notice")
    }
}

private struct RoomBackgroundView: View {
    var body: some View {
        GeometryReader { proxy in
            Image("MokiRoomBackground")
                .resizable()
                .interpolation(.high)
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct PetFeedbackBubble: View {
    let symbol: String
    let message: LocalizedStringKey

    var body: some View {
        Label(message, systemImage: symbol)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(MokiRoomPalette.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(MokiRoomPalette.panel.opacity(0.96), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(MokiRoomPalette.panelBorder, lineWidth: 1)
            }
            .shadow(color: MokiRoomPalette.shadow.opacity(0.16), radius: 6, y: 3)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier("pet.feedback")
    }
}

extension PetReaction {
    fileprivate var symbolName: String {
        switch self {
        case .enjoyedFood: return "carrot.fill"
        case .enjoyedPlay: return "sparkles"
        case .appreciatedCare: return "heart.fill"
        case .fellAsleep: return "moon.zzz.fill"
        case .wokeUp: return "sun.max.fill"
        }
    }

    fileprivate var message: LocalizedStringKey {
        switch self {
        case .enjoyedFood: return "Moki loved that snack!"
        case .enjoyedPlay: return "That was fun!"
        case .appreciatedCare: return "Moki feels cared for."
        case .fellAsleep: return "Sweet dreams, Moki."
        case .wokeUp: return "Moki is ready for the day!"
        }
    }
}

extension PetActionRejection {
    fileprivate var message: LocalizedStringKey {
        switch self {
        case .unavailableWhileSleeping, .alreadySleeping:
            return "Moki is sleeping. Wake Moki up first."
        case .insufficientEnergy:
            return "Moki needs more Energy before playing."
        case .alreadyAwake:
            return "Moki is already awake."
        }
    }
}

enum MokiRoomPalette {
    static let cream = Color(red: 0.91, green: 0.79, blue: 0.60)
    static let lightCream = Color(red: 0.98, green: 0.91, blue: 0.78)
    static let charcoal = Color(red: 0.14, green: 0.13, blue: 0.12)
    static let ink = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.96, green: 0.92, blue: 0.84, alpha: 1)
                : UIColor(red: 0.18, green: 0.16, blue: 0.13, alpha: 1)
        }
    )
    static let secondaryInk = adaptiveColor(
        light: (0.36, 0.29, 0.21),
        dark: (0.78, 0.71, 0.62)
    )
    static let shadow = Color.black
    static let gold = adaptiveColor(
        light: (0.66, 0.42, 0.14),
        dark: (0.91, 0.69, 0.34)
    )
    static let panel = adaptiveColor(
        light: (0.98, 0.94, 0.85),
        dark: (0.14, 0.12, 0.10)
    )
    static let controlSurface = adaptiveColor(
        light: (0.94, 0.87, 0.74),
        dark: (0.20, 0.17, 0.14)
    )
    static let panelBorder = adaptiveColor(
        light: (0.70, 0.55, 0.34),
        dark: (0.48, 0.36, 0.22)
    )
    static let meterTrack = adaptiveColor(
        light: (0.79, 0.71, 0.60),
        dark: (0.31, 0.27, 0.23)
    )
    static let hunger = Color(red: 0.77, green: 0.40, blue: 0.18)
    static let happiness = Color(red: 0.74, green: 0.31, blue: 0.36)
    static let energy = Color(red: 0.78, green: 0.57, blue: 0.13)
    static let bond = Color(red: 0.51, green: 0.35, blue: 0.58)
    static let rest = Color(red: 0.30, green: 0.42, blue: 0.56)

    private static func adaptiveColor(
        light: (red: CGFloat, green: CGFloat, blue: CGFloat),
        dark: (red: CGFloat, green: CGFloat, blue: CGFloat)
    ) -> Color {
        Color(
            uiColor: UIColor { traits in
                let components = traits.userInterfaceStyle == .dark
                    ? dark
                    : light
                return UIColor(
                    red: components.red,
                    green: components.green,
                    blue: components.blue,
                    alpha: 1
                )
            }
        )
    }
}

#Preview {
    PetRoomView(session: AppContainer().petSession)
}
