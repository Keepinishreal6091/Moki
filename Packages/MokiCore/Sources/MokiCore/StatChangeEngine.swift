import Foundation

/// Applies elapsed real time to a pet without timers, storage, or side effects.
public struct StatChangeEngine: Sendable {
    public let balance: MokiBalance

    public init(balance: MokiBalance = .approvedV01) {
        self.balance = balance
    }

    public func advance(_ state: PetState, to date: Date) -> PetState {
        let elapsed = date.timeIntervalSince(state.lastCalculatedAt)
        guard elapsed > 0 else {
            return state
        }

        let effectiveElapsed = min(
            elapsed,
            balance.maximumCatchUpInterval
        )
        let hours = effectiveElapsed / 3_600
        let hourlyDelta = state.isSleeping
            ? balance.sleepingHourlyDelta
            : balance.awakeHourlyDelta
        let totalDelta = hourlyDelta.scaled(by: hours)

        var advanced = state
        advanced.stats = PetStats(
            hunger: applyingTimedChange(
                current: state.stats.hunger,
                change: totalDelta.hunger,
                floor: balance.unattendedFloors.hunger
            ),
            happiness: applyingTimedChange(
                current: state.stats.happiness,
                change: totalDelta.happiness,
                floor: balance.unattendedFloors.happiness
            ),
            energy: applyingTimedChange(
                current: state.stats.energy,
                change: totalDelta.energy,
                floor: balance.unattendedFloors.energy
            ),
            bond: applyingTimedChange(
                current: state.stats.bond,
                change: totalDelta.bond,
                floor: balance.unattendedFloors.bond
            )
        )
        advanced.lastCalculatedAt = date
        return advanced
    }

    private func applyingTimedChange(
        current: Double,
        change: Double,
        floor: Double
    ) -> Double {
        let boundedCurrent = min(
            max(current, balance.minimumStat),
            balance.maximumStat
        )

        if change < 0 {
            // Never raise a stat that was already below its unattended floor.
            let effectiveFloor = min(boundedCurrent, floor)
            return max(effectiveFloor, boundedCurrent + change)
        }

        return min(balance.maximumStat, boundedCurrent + change)
    }
}
