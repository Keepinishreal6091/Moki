import Foundation

/// Applies the approved v0.1 care actions through one deterministic rule path.
public struct PetActionEngine: Sendable {
    public let balance: MokiBalance
    private let statChangeEngine: StatChangeEngine

    public init(balance: MokiBalance = .approvedV01) {
        self.balance = balance
        statChangeEngine = StatChangeEngine(balance: balance)
    }

    public func apply(
        _ action: PetAction,
        to state: PetState,
        at date: Date
    ) -> PetActionResult {
        var updated = statChangeEngine.advance(state, to: date)

        if let rejection = rejection(for: action, state: updated) {
            return PetActionResult(
                state: updated,
                outcome: .rejected(reason: rejection)
            )
        }

        let reaction: PetReaction
        switch action {
        case .feed:
            updated.stats = applyingActionDelta(
                balance.feedDelta,
                to: updated.stats
            )
            reaction = .enjoyedFood
        case .play:
            updated.stats = applyingActionDelta(
                balance.playDelta,
                to: updated.stats
            )
            reaction = .enjoyedPlay
        case .care:
            updated.stats = applyingActionDelta(
                balance.careDelta,
                to: updated.stats
            )
            reaction = .appreciatedCare
        case .sleep:
            updated.isSleeping = true
            reaction = .fellAsleep
        case .wakeUp:
            updated.isSleeping = false
            reaction = .wokeUp
        }

        // A device clock rollback must never move domain timestamps backward.
        let interactionDate = max(date, updated.lastCalculatedAt)
        updated.lastCalculatedAt = interactionDate
        updated.lastInteractionAt = interactionDate

        return PetActionResult(
            state: updated,
            outcome: .applied(reaction: reaction)
        )
    }

    private func rejection(
        for action: PetAction,
        state: PetState
    ) -> PetActionRejection? {
        if state.isSleeping {
            switch action {
            case .wakeUp:
                return nil
            case .sleep:
                return .alreadySleeping
            case .feed, .play, .care:
                return .unavailableWhileSleeping(action: action)
            }
        }

        switch action {
        case .wakeUp:
            return .alreadyAwake
        case .play where state.stats.energy < balance.minimumEnergyToPlay:
            return .insufficientEnergy(
                required: balance.minimumEnergyToPlay,
                available: state.stats.energy
            )
        case .feed, .play, .care, .sleep:
            return nil
        }
    }

    private func applyingActionDelta(
        _ delta: StatDelta,
        to stats: PetStats
    ) -> PetStats {
        stats.applying(delta).clamped(
            minimum: balance.minimumStat,
            maximum: balance.maximumStat
        )
    }
}
