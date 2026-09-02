import XCTest
@testable import MokiCore

final class MokiBalanceTests: XCTestCase {
    func testApprovedBoundsInitialValuesAndFloors() {
        let balance = MokiBalance.approvedV01

        XCTAssertEqual(balance.minimumStat, 0)
        XCTAssertEqual(balance.maximumStat, 100)
        assertStats(
            balance.initialStats,
            hunger: 80,
            happiness: 80,
            energy: 75,
            bond: 10
        )
        assertStats(
            balance.unattendedFloors,
            hunger: 10,
            happiness: 20,
            energy: 15,
            bond: 0
        )
    }

    func testApprovedElapsedTimeRatesAreCentralized() {
        let balance = MokiBalance.approvedV01

        assertDelta(
            balance.awakeHourlyDelta,
            hunger: -1.5,
            happiness: -0.5,
            energy: -1,
            bond: 0
        )
        assertDelta(
            balance.sleepingHourlyDelta,
            hunger: -0.75,
            happiness: 0,
            energy: 10,
            bond: 0
        )
        XCTAssertEqual(balance.maximumCatchUpInterval, 72 * 60 * 60)
    }

    func testApprovedActionValuesAreCentralized() {
        let balance = MokiBalance.approvedV01

        assertDelta(
            balance.feedDelta,
            hunger: 25,
            happiness: 2,
            energy: 0,
            bond: 1
        )
        assertDelta(
            balance.playDelta,
            hunger: -5,
            happiness: 18,
            energy: -12,
            bond: 2
        )
        assertDelta(
            balance.careDelta,
            hunger: 0,
            happiness: 10,
            energy: 2,
            bond: 4
        )
        XCTAssertEqual(balance.minimumEnergyToPlay, 15)
    }
}
