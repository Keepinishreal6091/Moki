import Foundation

/// The authoritative in-memory state for the single v0.1 Moki.
///
/// This type has no storage, UI, networking, account, evolution, or battle
/// behavior. Those concerns remain outside Milestone 1.
public struct PetState: Equatable, Sendable {
    public let id: UUID
    public let modelVersion: Int
    public var stats: PetStats
    public var isSleeping: Bool
    public let createdAt: Date
    public var lastCalculatedAt: Date
    public var lastInteractionAt: Date?

    public init(
        id: UUID,
        modelVersion: Int,
        stats: PetStats,
        isSleeping: Bool,
        createdAt: Date,
        lastCalculatedAt: Date,
        lastInteractionAt: Date?
    ) {
        self.id = id
        self.modelVersion = modelVersion
        self.stats = stats
        self.isSleeping = isSleeping
        self.createdAt = createdAt
        self.lastCalculatedAt = lastCalculatedAt
        self.lastInteractionAt = lastInteractionAt
    }

    public static func initial(
        id: UUID = UUID(),
        at date: Date = Date(),
        balance: MokiBalance = .approvedV01
    ) -> PetState {
        PetState(
            id: id,
            modelVersion: MokiCoreConfiguration.domainModelVersion,
            stats: balance.initialStats.clamped(
                minimum: balance.minimumStat,
                maximum: balance.maximumStat
            ),
            isSleeping: false,
            createdAt: date,
            lastCalculatedAt: date,
            lastInteractionAt: nil
        )
    }
}
