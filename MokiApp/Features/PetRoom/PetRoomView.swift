import SwiftUI
import UIKit
import MokiCore

struct PetRoomView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let session: PetSession

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoomBackgroundView()

                VStack(spacing: 12) {
                    roomHeader

                    StatMetersView(stats: session.state.stats)

                    Spacer(minLength: 2)

                    MokiPlaceholderView(
                        isSleeping: session.state.isSleeping,
                        reaction: session.reaction,
                        reduceMotion: reduceMotion
                    )
                    .frame(
                        height: min(max(proxy.size.height * 0.32, 190), 270)
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
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
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

    private var roomHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Moki's Room")
                    .font(.title2.bold())
                    .foregroundStyle(MokiRoomPalette.ink)
                    .accessibilityIdentifier("pet-room.title")

                Text(roomSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(MokiRoomPalette.ink.opacity(0.7))
            }

            Spacer()

            Image(systemName: session.state.isSleeping ? "moon.stars.fill" : "heart.fill")
                .font(.title2)
                .foregroundStyle(MokiRoomPalette.gold)
                .accessibilityHidden(true)
        }
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
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        MokiRoomPalette.wallTop,
                        MokiRoomPalette.wallBottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.55))
                    .overlay {
                        VStack(spacing: 0) {
                            Color.clear
                            Rectangle()
                                .fill(MokiRoomPalette.sky.opacity(0.5))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .overlay {
                        HStack(spacing: 0) {
                            Rectangle().frame(width: 3)
                            Color.clear
                            Rectangle().frame(width: 3)
                        }
                        .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(width: 104, height: 116)
                    .position(x: proxy.size.width * 0.78, y: proxy.size.height * 0.27)
                    .shadow(color: MokiRoomPalette.shadow.opacity(0.08), radius: 8, y: 4)

                Rectangle()
                    .fill(MokiRoomPalette.baseboard)
                    .frame(height: 8)
                    .offset(y: -proxy.size.height * 0.27)

                LinearGradient(
                    colors: [MokiRoomPalette.floorTop, MokiRoomPalette.floorBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: proxy.size.height * 0.28)
            }
            .ignoresSafeArea()
        }
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
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: MokiRoomPalette.shadow.opacity(0.1), radius: 5, y: 2)
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
    static let shadow = Color.black
    static let gold = Color(red: 0.72, green: 0.48, blue: 0.17)
    static let wallTop = adaptiveColor(
        light: (0.96, 0.91, 0.82),
        dark: (0.22, 0.18, 0.16)
    )
    static let wallBottom = adaptiveColor(
        light: (0.90, 0.82, 0.70),
        dark: (0.14, 0.11, 0.10)
    )
    static let baseboard = adaptiveColor(
        light: (0.67, 0.50, 0.34),
        dark: (0.31, 0.23, 0.18)
    )
    static let floorTop = adaptiveColor(
        light: (0.76, 0.59, 0.41),
        dark: (0.25, 0.18, 0.14)
    )
    static let floorBottom = adaptiveColor(
        light: (0.60, 0.43, 0.29),
        dark: (0.13, 0.09, 0.08)
    )
    static let sky = adaptiveColor(
        light: (0.52, 0.75, 0.86),
        dark: (0.12, 0.24, 0.34)
    )

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
