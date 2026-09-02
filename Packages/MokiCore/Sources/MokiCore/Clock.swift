import Foundation

/// Time dependency boundary for deterministic domain tests and app lifecycle use.
public protocol MokiClock: Sendable {
    var now: Date { get }
}

public struct SystemMokiClock: MokiClock {
    public init() {}

    public var now: Date {
        Date()
    }
}
