/// Moki's four v0.1 care statistics.
///
/// Every value uses the same presentation direction: higher is better.
/// In particular, `hunger` means how well-fed Moki is, where 100 is fully fed
/// and 0 is extremely hungry.
public struct PetStats: Equatable, Sendable {
    public var hunger: Double
    public var happiness: Double
    public var energy: Double
    public var bond: Double

    public init(
        hunger: Double,
        happiness: Double,
        energy: Double,
        bond: Double
    ) {
        self.hunger = hunger
        self.happiness = happiness
        self.energy = energy
        self.bond = bond
    }

    public func applying(_ delta: StatDelta) -> PetStats {
        PetStats(
            hunger: hunger + delta.hunger,
            happiness: happiness + delta.happiness,
            energy: energy + delta.energy,
            bond: bond + delta.bond
        )
    }

    public func clamped(minimum: Double, maximum: Double) -> PetStats {
        PetStats(
            hunger: hunger.clamped(to: minimum...maximum),
            happiness: happiness.clamped(to: minimum...maximum),
            energy: energy.clamped(to: minimum...maximum),
            bond: bond.clamped(to: minimum...maximum)
        )
    }
}

/// A signed change applied to all care statistics as one domain operation.
public struct StatDelta: Equatable, Sendable {
    public var hunger: Double
    public var happiness: Double
    public var energy: Double
    public var bond: Double

    public init(
        hunger: Double,
        happiness: Double,
        energy: Double,
        bond: Double
    ) {
        self.hunger = hunger
        self.happiness = happiness
        self.energy = energy
        self.bond = bond
    }

    public static let zero = StatDelta(
        hunger: 0,
        happiness: 0,
        energy: 0,
        bond: 0
    )

    public func scaled(by multiplier: Double) -> StatDelta {
        StatDelta(
            hunger: hunger * multiplier,
            happiness: happiness * multiplier,
            energy: energy * multiplier,
            bond: bond * multiplier
        )
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
