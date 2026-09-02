import Foundation
import XCTest
@testable import MokiCore

final class InitialPetStateTests: XCTestCase {
    func testApprovedInitialState() {
        let state = PetState.initial(id: testPetID, at: testDate)

        XCTAssertEqual(state.id, testPetID)
        XCTAssertEqual(
            state.modelVersion,
            MokiCoreConfiguration.domainModelVersion
        )
        assertStats(
            state.stats,
            hunger: 80,
            happiness: 80,
            energy: 75,
            bond: 10
        )
        XCTAssertFalse(state.isSleeping)
        XCTAssertEqual(state.createdAt, testDate)
        XCTAssertEqual(state.lastCalculatedAt, testDate)
        XCTAssertNil(state.lastInteractionAt)
    }

    func testInitialStateClampsCustomOutOfRangeValues() {
        var balance = MokiBalance.approvedV01
        balance.initialStats = PetStats(
            hunger: 120,
            happiness: -10,
            energy: 75,
            bond: 500
        )

        let state = PetState.initial(
            id: testPetID,
            at: testDate,
            balance: balance
        )

        assertStats(
            state.stats,
            hunger: 100,
            happiness: 0,
            energy: 75,
            bond: 100
        )
    }

    func testPetStatsApplyDeltaAndClampAllValues() {
        let stats = PetStats(
            hunger: 95,
            happiness: 5,
            energy: 50,
            bond: 99
        )
        let delta = StatDelta(
            hunger: 10,
            happiness: -20,
            energy: 75,
            bond: 5
        )

        let result = stats
            .applying(delta)
            .clamped(minimum: 0, maximum: 100)

        assertStats(
            result,
            hunger: 100,
            happiness: 0,
            energy: 100,
            bond: 100
        )
    }

    func testClockBoundaryCanBeReplacedDeterministically() {
        let clock = FixedMokiClock(now: testDate)

        XCTAssertEqual(clock.now, testDate)
    }
}
