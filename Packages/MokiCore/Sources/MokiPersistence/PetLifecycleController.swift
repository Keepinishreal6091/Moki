import MokiCore

public enum PetLifecycleIssue: Equatable, Sendable {
    case loadFailed
    case saveFailed
}

/// Coordinates domain rules with persistence at app lifecycle boundaries.
/// This type has no SwiftUI dependency and is testable with in-memory stores.
public final class PetLifecycleController {
    public private(set) var state: PetState
    public private(set) var lastIssue: PetLifecycleIssue?

    private let store: any PetStore
    private let clock: any MokiClock
    private let statChangeEngine: StatChangeEngine
    private let actionEngine: PetActionEngine

    public init(
        store: any PetStore,
        clock: any MokiClock = SystemMokiClock(),
        balance: MokiBalance = .approvedV01
    ) {
        let localStatChangeEngine = StatChangeEngine(balance: balance)
        let localActionEngine = PetActionEngine(balance: balance)
        self.store = store
        self.clock = clock
        statChangeEngine = localStatChangeEngine
        actionEngine = localActionEngine

        let now = clock.now
        var shouldSaveInitialState = false

        do {
            if let restored = try store.load() {
                state = localStatChangeEngine.advance(restored, to: now)
                shouldSaveInitialState = true
            } else {
                state = PetState.initial(at: now, balance: balance)
                shouldSaveInitialState = true
            }
            lastIssue = nil
        } catch {
            state = PetState.initial(at: now, balance: balance)
            lastIssue = .loadFailed
        }

        if shouldSaveInitialState {
            saveCurrentState()
        }
    }

    @discardableResult
    public func refreshForActiveScene() -> PetState {
        state = statChangeEngine.advance(state, to: clock.now)
        saveCurrentState()
        return state
    }

    @discardableResult
    public func saveForBackground() -> PetState {
        state = statChangeEngine.advance(state, to: clock.now)
        saveCurrentState()
        return state
    }

    @discardableResult
    public func apply(_ action: PetAction) -> PetActionResult {
        let result = actionEngine.apply(action, to: state, at: clock.now)
        state = result.state
        saveCurrentState()
        return result
    }

    private func saveCurrentState() {
        do {
            try store.save(state)
            lastIssue = nil
        } catch {
            lastIssue = .saveFailed
        }
    }
}
