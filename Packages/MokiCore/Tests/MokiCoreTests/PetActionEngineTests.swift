import XCTest
@testable import MokiCore

final class PetActionEngineTests: XCTestCase {
    private let engine = PetActionEngine()

    func testFeedAppliesCentralizedDeltaAndClampsHunger() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let result = engine.apply(.feed, to: initial, at: testDate)

        XCTAssertEqual(result.outcome, .applied(reaction: .enjoyedFood))
        assertStats(
            result.state.stats,
            hunger: 100,
            happiness: 82,
            energy: 75,
            bond: 11
        )
        XCTAssertEqual(result.state.lastInteractionAt, testDate)
        XCTAssertTrue(result.wasApplied)
    }

    func testPlayAppliesCostAndReward() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let result = engine.apply(.play, to: initial, at: testDate)

        XCTAssertEqual(result.outcome, .applied(reaction: .enjoyedPlay))
        assertStats(
            result.state.stats,
            hunger: 75,
            happiness: 98,
            energy: 63,
            bond: 12
        )
    }

    func testCareAppliesDistinctReward() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let result = engine.apply(.care, to: initial, at: testDate)

        XCTAssertEqual(result.outcome, .applied(reaction: .appreciatedCare))
        assertStats(
            result.state.stats,
            hunger: 80,
            happiness: 90,
            energy: 77,
            bond: 14
        )
    }

    func testSleepAndWakeUpChangeStateWithoutChangingStats() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let sleeping = engine.apply(.sleep, to: initial, at: testDate)
        let awake = engine.apply(.wakeUp, to: sleeping.state, at: testDate)

        XCTAssertTrue(sleeping.state.isSleeping)
        XCTAssertEqual(sleeping.outcome, .applied(reaction: .fellAsleep))
        XCTAssertEqual(sleeping.state.stats, initial.stats)
        XCTAssertFalse(awake.state.isSleeping)
        XCTAssertEqual(awake.outcome, .applied(reaction: .wokeUp))
        XCTAssertEqual(awake.state.stats, initial.stats)
    }

    func testActionsOtherThanWakeUpAreRejectedWhileSleeping() {
        var sleeping = PetState.initial(id: testPetID, at: testDate)
        sleeping.isSleeping = true

        for action in [PetAction.feed, .play, .care] {
            let result = engine.apply(action, to: sleeping, at: testDate)

            XCTAssertEqual(
                result.outcome,
                .rejected(
                    reason: .unavailableWhileSleeping(action: action)
                )
            )
            XCTAssertEqual(result.state, sleeping)
            XCTAssertFalse(result.wasApplied)
        }
    }

    func testRepeatedSleepAndWakeUpAreRejected() {
        let awake = PetState.initial(id: testPetID, at: testDate)
        var sleeping = awake
        sleeping.isSleeping = true

        let sleepResult = engine.apply(.sleep, to: sleeping, at: testDate)
        let wakeResult = engine.apply(.wakeUp, to: awake, at: testDate)

        XCTAssertEqual(
            sleepResult.outcome,
            .rejected(reason: .alreadySleeping)
        )
        XCTAssertEqual(
            wakeResult.outcome,
            .rejected(reason: .alreadyAwake)
        )
    }

    func testPlayIsRejectedBelowMinimumEnergy() {
        var initial = PetState.initial(id: testPetID, at: testDate)
        let requiredEnergy = MokiBalance.approvedV01.minimumEnergyToPlay
        let unavailableEnergy = requiredEnergy - 1
        initial.stats.energy = unavailableEnergy

        let result = engine.apply(.play, to: initial, at: testDate)

        XCTAssertEqual(
            result.outcome,
            .rejected(
                reason: .insufficientEnergy(
                    required: requiredEnergy,
                    available: unavailableEnergy
                )
            )
        )
        XCTAssertEqual(result.state, initial)
    }

    func testPlayIsAllowedAtMinimumEnergy() {
        var initial = PetState.initial(id: testPetID, at: testDate)
        let minimumEnergy = MokiBalance.approvedV01.minimumEnergyToPlay
        initial.stats.energy = minimumEnergy

        let result = engine.apply(.play, to: initial, at: testDate)

        XCTAssertEqual(result.outcome, .applied(reaction: .enjoyedPlay))
        XCTAssertEqual(
            result.state.stats.energy,
            minimumEnergy + MokiBalance.approvedV01.playDelta.energy,
            accuracy: 0.000_001
        )
    }

    func testActionAdvancesElapsedTimeBeforeApplyingItsDelta() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let result = engine.apply(.feed, to: initial, at: hoursAfter(1))

        assertStats(
            result.state.stats,
            hunger: 100,
            happiness: 81.5,
            energy: 74,
            bond: 11
        )
        XCTAssertEqual(result.state.lastCalculatedAt, hoursAfter(1))
        XCTAssertEqual(result.state.lastInteractionAt, hoursAfter(1))
    }

    func testRejectedActionStillReturnsTimeAdvancedState() {
        var initial = PetState.initial(id: testPetID, at: testDate)
        let requiredEnergy = MokiBalance.approvedV01.minimumEnergyToPlay
        let unavailableEnergy = requiredEnergy - 1
        initial.stats.energy = unavailableEnergy

        let result = engine.apply(.play, to: initial, at: hoursAfter(1))

        XCTAssertEqual(
            result.outcome,
            .rejected(
                reason: .insufficientEnergy(
                    required: requiredEnergy,
                    available: unavailableEnergy
                )
            )
        )
        assertStats(
            result.state.stats,
            hunger: 78.5,
            happiness: 79.5,
            energy: unavailableEnergy,
            bond: 10
        )
        XCTAssertEqual(result.state.lastCalculatedAt, hoursAfter(1))
        XCTAssertNil(result.state.lastInteractionAt)
    }

    func testActionDuringClockRollbackNeverMovesTimestampsBackward() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let result = engine.apply(.care, to: initial, at: hoursAfter(-2))

        XCTAssertEqual(result.outcome, .applied(reaction: .appreciatedCare))
        XCTAssertEqual(result.state.lastCalculatedAt, testDate)
        XCTAssertEqual(result.state.lastInteractionAt, testDate)
    }
}
