/// Player-initiated actions included in the v0.1 care loop.
public enum PetAction: Equatable, Sendable {
    case feed
    case play
    case care
    case sleep
    case wakeUp
}

/// Transient domain signal for later UI feedback. It is not persisted state.
public enum PetReaction: Equatable, Sendable {
    case enjoyedFood
    case enjoyedPlay
    case appreciatedCare
    case fellAsleep
    case wokeUp
}

public enum PetActionRejection: Equatable, Sendable {
    case unavailableWhileSleeping(action: PetAction)
    case insufficientEnergy(required: Double, available: Double)
    case alreadySleeping
    case alreadyAwake
}

public enum PetActionOutcome: Equatable, Sendable {
    case applied(reaction: PetReaction)
    case rejected(reason: PetActionRejection)
}

/// The state returned here always includes elapsed-time calculation, even when
/// the requested action is rejected.
public struct PetActionResult: Equatable, Sendable {
    public let state: PetState
    public let outcome: PetActionOutcome

    public init(state: PetState, outcome: PetActionOutcome) {
        self.state = state
        self.outcome = outcome
    }

    public var wasApplied: Bool {
        if case .applied = outcome {
            return true
        }
        return false
    }
}
