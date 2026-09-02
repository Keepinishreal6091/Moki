import XCTest
import MokiCore
@testable import MokiPersistence

final class PetLifecycleControllerTests: XCTestCase {
    func testFreshLaunchCreatesAndSavesApprovedInitialState() {
        let store = MemoryPetStore()
        let clock = MutableMokiClock(now: persistenceTestDate)

        let controller = PetLifecycleController(
            store: store,
            clock: clock
        )

        XCTAssertEqual(controller.state, store.storedState)
        XCTAssertEqual(controller.state.stats, MokiBalance.approvedV01.initialStats)
        XCTAssertEqual(controller.state.createdAt, persistenceTestDate)
        XCTAssertEqual(store.saveCount, 1)
        XCTAssertNil(controller.lastIssue)
    }

    func testLaunchRestoresAdvancesAndResavesExistingState() {
        var stored = PetState.initial(
            id: persistenceTestID,
            at: persistenceTestDate
        )
        stored.stats = MokiBalance.approvedV01.initialStats
        let store = MemoryPetStore(storedState: stored)
        let clock = MutableMokiClock(now: persistenceHoursAfter(2))

        let controller = PetLifecycleController(
            store: store,
            clock: clock
        )

        XCTAssertEqual(controller.state.stats.hunger, 77, accuracy: 0.000_001)
        XCTAssertEqual(controller.state.stats.happiness, 79, accuracy: 0.000_001)
        XCTAssertEqual(controller.state.stats.energy, 73, accuracy: 0.000_001)
        XCTAssertEqual(controller.state.lastCalculatedAt, persistenceHoursAfter(2))
        XCTAssertEqual(store.storedState, controller.state)
        XCTAssertEqual(store.saveCount, 1)
    }

    func testActiveSceneRefreshAdvancesAndSaves() {
        let store = MemoryPetStore()
        let clock = MutableMokiClock(now: persistenceTestDate)
        let controller = PetLifecycleController(store: store, clock: clock)
        clock.now = persistenceHoursAfter(1)

        let refreshed = controller.refreshForActiveScene()

        XCTAssertEqual(refreshed.stats.hunger, 78.5, accuracy: 0.000_001)
        XCTAssertEqual(refreshed.lastCalculatedAt, persistenceHoursAfter(1))
        XCTAssertEqual(store.storedState, refreshed)
        XCTAssertEqual(store.saveCount, 2)
    }

    func testBackgroundTransitionAdvancesAndSaves() {
        let store = MemoryPetStore()
        let clock = MutableMokiClock(now: persistenceTestDate)
        let controller = PetLifecycleController(store: store, clock: clock)
        clock.now = persistenceHoursAfter(3)

        let saved = controller.saveForBackground()

        XCTAssertEqual(saved.lastCalculatedAt, persistenceHoursAfter(3))
        XCTAssertEqual(store.storedState, saved)
        XCTAssertEqual(store.saveCount, 2)
    }

    func testAppliedActionUpdatesAndSavesState() {
        let store = MemoryPetStore()
        let clock = MutableMokiClock(now: persistenceTestDate)
        let controller = PetLifecycleController(store: store, clock: clock)

        let result = controller.apply(.care)

        XCTAssertTrue(result.wasApplied)
        XCTAssertEqual(result.state.stats.bond, 14, accuracy: 0.000_001)
        XCTAssertEqual(store.storedState, result.state)
        XCTAssertEqual(store.saveCount, 2)
    }

    func testRejectedActionStillSavesTimeAdvancedState() {
        var stored = PetState.initial(
            id: persistenceTestID,
            at: persistenceTestDate
        )
        let requiredEnergy = MokiBalance.approvedV01.minimumEnergyToPlay
        let unavailableEnergy = requiredEnergy - 1
        stored.stats.energy = unavailableEnergy
        let store = MemoryPetStore(storedState: stored)
        let clock = MutableMokiClock(now: persistenceHoursAfter(1))
        let controller = PetLifecycleController(store: store, clock: clock)

        let result = controller.apply(.play)

        XCTAssertFalse(result.wasApplied)
        XCTAssertEqual(
            result.outcome,
            .rejected(
                reason: .insufficientEnergy(
                    required: requiredEnergy,
                    available: unavailableEnergy
                )
            )
        )
        XCTAssertEqual(result.state.stats.hunger, 78.5, accuracy: 0.000_001)
        XCTAssertEqual(result.state.stats.happiness, 79.5, accuracy: 0.000_001)
        XCTAssertEqual(
            result.state.stats.energy,
            unavailableEnergy,
            accuracy: 0.000_001
        )
        XCTAssertEqual(
            result.state.lastCalculatedAt,
            persistenceHoursAfter(1)
        )
        XCTAssertNil(result.state.lastInteractionAt)
        XCTAssertEqual(store.storedState, result.state)
        XCTAssertEqual(store.saveCount, 2)
    }

    func testLoadFailureUsesInMemoryInitialStateWithoutOverwritingEvidence() {
        let store = MemoryPetStore()
        store.loadShouldFail = true
        let clock = MutableMokiClock(now: persistenceTestDate)

        let controller = PetLifecycleController(store: store, clock: clock)

        XCTAssertEqual(controller.lastIssue, .loadFailed)
        XCTAssertEqual(controller.state.stats, MokiBalance.approvedV01.initialStats)
        XCTAssertEqual(store.saveCount, 0)
    }

    func testSaveFailureIsReportedAndLaterSuccessfulSaveClearsIssue() {
        let store = MemoryPetStore()
        store.saveShouldFail = true
        let clock = MutableMokiClock(now: persistenceTestDate)
        let controller = PetLifecycleController(store: store, clock: clock)

        XCTAssertEqual(controller.lastIssue, .saveFailed)

        store.saveShouldFail = false
        _ = controller.apply(.feed)

        XCTAssertNil(controller.lastIssue)
        XCTAssertEqual(store.saveCount, 1)
    }
}
