import Foundation

/// All tunable v0.1 pet-rule values.
///
/// Product tuning should change this configuration rather than placing numeric
/// balance values in views, action handlers, or persistence code.
public struct MokiBalance: Equatable, Sendable {
    public var minimumStat: Double
    public var maximumStat: Double
    public var initialStats: PetStats
    public var unattendedFloors: PetStats
    public var awakeHourlyDelta: StatDelta
    public var sleepingHourlyDelta: StatDelta
    public var maximumCatchUpInterval: TimeInterval
    public var feedDelta: StatDelta
    public var playDelta: StatDelta
    public var careDelta: StatDelta
    public var minimumEnergyToPlay: Double

    public init(
        minimumStat: Double,
        maximumStat: Double,
        initialStats: PetStats,
        unattendedFloors: PetStats,
        awakeHourlyDelta: StatDelta,
        sleepingHourlyDelta: StatDelta,
        maximumCatchUpInterval: TimeInterval,
        feedDelta: StatDelta,
        playDelta: StatDelta,
        careDelta: StatDelta,
        minimumEnergyToPlay: Double
    ) {
        self.minimumStat = minimumStat
        self.maximumStat = maximumStat
        self.initialStats = initialStats
        self.unattendedFloors = unattendedFloors
        self.awakeHourlyDelta = awakeHourlyDelta
        self.sleepingHourlyDelta = sleepingHourlyDelta
        self.maximumCatchUpInterval = maximumCatchUpInterval
        self.feedDelta = feedDelta
        self.playDelta = playDelta
        self.careDelta = careDelta
        self.minimumEnergyToPlay = minimumEnergyToPlay
    }

    /// Approved initial state plus conservative working action/decay values.
    /// The working values are intentionally centralized for play-test tuning.
    public static let approvedV01 = MokiBalance(
        minimumStat: 0,
        maximumStat: 100,
        initialStats: PetStats(
            hunger: 80,
            happiness: 80,
            energy: 75,
            bond: 10
        ),
        unattendedFloors: PetStats(
            hunger: 10,
            happiness: 20,
            energy: 15,
            bond: 0
        ),
        awakeHourlyDelta: StatDelta(
            hunger: -1.5,
            happiness: -0.5,
            energy: -1,
            bond: 0
        ),
        sleepingHourlyDelta: StatDelta(
            hunger: -0.75,
            happiness: 0,
            energy: 10,
            bond: 0
        ),
        maximumCatchUpInterval: 72 * 60 * 60,
        feedDelta: StatDelta(
            hunger: 25,
            happiness: 2,
            energy: 0,
            bond: 1
        ),
        playDelta: StatDelta(
            hunger: -5,
            happiness: 18,
            energy: -12,
            bond: 2
        ),
        careDelta: StatDelta(
            hunger: 0,
            happiness: 10,
            energy: 2,
            bond: 4
        ),
        minimumEnergyToPlay: 15
    )
}
