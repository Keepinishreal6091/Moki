import Observation
import MokiCore
import MokiPersistence

/// Observable app-layer adapter around the testable lifecycle controller.
/// Room presentation and interaction controls remain deferred to Milestone 3.
@MainActor
@Observable
final class PetSession {
    private(set) var state: PetState
    private(set) var lastPersistenceIssue: PetLifecycleIssue?
    private(set) var reaction: PetReaction?
    private(set) var rejection: PetActionRejection?

    @ObservationIgnored
    private let controller: PetLifecycleController
    @ObservationIgnored
    private var feedbackClearTask: Task<Void, Never>?

    init(controller: PetLifecycleController) {
        self.controller = controller
        state = controller.state
        lastPersistenceIssue = controller.lastIssue
    }

    func refreshForActiveScene() {
        state = controller.refreshForActiveScene()
        lastPersistenceIssue = controller.lastIssue
    }

    func saveForBackground() {
        state = controller.saveForBackground()
        lastPersistenceIssue = controller.lastIssue
    }

    @discardableResult
    func apply(_ action: PetAction) -> PetActionResult {
        let result = controller.apply(action)
        state = result.state
        lastPersistenceIssue = controller.lastIssue

        switch result.outcome {
        case let .applied(reaction):
            self.reaction = reaction
            rejection = nil
        case let .rejected(reason):
            reaction = nil
            rejection = reason
        }

        scheduleFeedbackClear()
        return result
    }

    private func scheduleFeedbackClear() {
        feedbackClearTask?.cancel()
        feedbackClearTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            guard !Task.isCancelled else { return }
            self?.reaction = nil
            self?.rejection = nil
        }
    }
}
