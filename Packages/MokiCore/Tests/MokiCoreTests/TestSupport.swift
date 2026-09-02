import Foundation
import XCTest
@testable import MokiCore

let testDate = Date(timeIntervalSince1970: 2_000_000_000)
let testPetID = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!

func hoursAfter(_ hours: Double, date: Date = testDate) -> Date {
    date.addingTimeInterval(hours * 3_600)
}

func assertStats(
    _ stats: PetStats,
    hunger: Double,
    happiness: Double,
    energy: Double,
    bond: Double,
    accuracy: Double = 0.000_001,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(stats.hunger, hunger, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(
        stats.happiness,
        happiness,
        accuracy: accuracy,
        file: file,
        line: line
    )
    XCTAssertEqual(stats.energy, energy, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(stats.bond, bond, accuracy: accuracy, file: file, line: line)
}

func assertDelta(
    _ delta: StatDelta,
    hunger: Double,
    happiness: Double,
    energy: Double,
    bond: Double,
    accuracy: Double = 0.000_001,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(delta.hunger, hunger, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(
        delta.happiness,
        happiness,
        accuracy: accuracy,
        file: file,
        line: line
    )
    XCTAssertEqual(delta.energy, energy, accuracy: accuracy, file: file, line: line)
    XCTAssertEqual(delta.bond, bond, accuracy: accuracy, file: file, line: line)
}

struct FixedMokiClock: MokiClock {
    let now: Date
}
