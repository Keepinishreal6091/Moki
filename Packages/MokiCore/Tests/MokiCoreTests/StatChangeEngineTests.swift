import XCTest
@testable import MokiCore

final class StatChangeEngineTests: XCTestCase {
    private let engine = StatChangeEngine()

    func testAwakeStatsChangeForElapsedHours() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let result = engine.advance(initial, to: hoursAfter(2))

        assertStats(
            result.stats,
            hunger: 77,
            happiness: 79,
            energy: 73,
            bond: 10
        )
        XCTAssertEqual(result.lastCalculatedAt, hoursAfter(2))
    }

    func testSleepingRecoversEnergyAndSlowsOtherDecay() {
        var initial = PetState.initial(id: testPetID, at: testDate)
        initial.isSleeping = true

        let result = engine.advance(initial, to: hoursAfter(2))

        assertStats(
            result.stats,
            hunger: 78.5,
            happiness: 80,
            energy: 95,
            bond: 10
        )
    }

    func testSleepingEnergyClampsAtMaximum() {
        var initial = PetState.initial(id: testPetID, at: testDate)
        initial.isSleeping = true
        initial.stats.energy = 99

        let result = engine.advance(initial, to: hoursAfter(2))

        XCTAssertEqual(result.stats.energy, 100, accuracy: 0.000_001)
    }

    func testLongAbsenceUsesMaximumCatchUpAndSafeFloors() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let result = engine.advance(initial, to: hoursAfter(10_000))

        // Only the configured 72-hour catch-up window is applied.
        assertStats(
            result.stats,
            hunger: 10,
            happiness: 44,
            energy: 15,
            bond: 10
        )
        XCTAssertEqual(result.lastCalculatedAt, hoursAfter(10_000))
    }

    func testUnattendedDecayStopsAtSafeFloors() {
        var initial = PetState.initial(id: testPetID, at: testDate)
        initial.stats = PetStats(
            hunger: 10,
            happiness: 20,
            energy: 15,
            bond: 10
        )

        let result = engine.advance(initial, to: hoursAfter(24))

        assertStats(
            result.stats,
            hunger: 10,
            happiness: 20,
            energy: 15,
            bond: 10
        )
    }

    func testDecayDoesNotRaiseAStatAlreadyBelowItsSafeFloor() {
        var initial = PetState.initial(id: testPetID, at: testDate)
        initial.stats.hunger = 5

        let result = engine.advance(initial, to: hoursAfter(24))

        XCTAssertEqual(result.stats.hunger, 5, accuracy: 0.000_001)
    }

    func testBondNeverDecays() {
        var initial = PetState.initial(id: testPetID, at: testDate)
        initial.stats.bond = 73

        let awake = engine.advance(initial, to: hoursAfter(48))
        var sleepingState = initial
        sleepingState.isSleeping = true
        let sleeping = engine.advance(sleepingState, to: hoursAfter(48))

        XCTAssertEqual(awake.stats.bond, 73, accuracy: 0.000_001)
        XCTAssertEqual(sleeping.stats.bond, 73, accuracy: 0.000_001)
    }

    func testClockRollbackLeavesStateAndTimestampUnchanged() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let result = engine.advance(initial, to: hoursAfter(-5))

        XCTAssertEqual(result, initial)
    }

    func testZeroElapsedTimeLeavesStateUnchanged() {
        let initial = PetState.initial(id: testPetID, at: testDate)

        let result = engine.advance(initial, to: testDate)

        XCTAssertEqual(result, initial)
    }
}
