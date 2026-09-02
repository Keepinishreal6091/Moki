import Foundation
import XCTest
import MokiCore
@testable import MokiPersistence

let persistenceTestDate = Date(timeIntervalSince1970: 2_000_000_000)
let persistenceTestID = UUID(
    uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
)!

func persistenceHoursAfter(
    _ hours: Double,
    date: Date = persistenceTestDate
) -> Date {
    date.addingTimeInterval(hours * 3_600)
}

func makePersistenceTestState(
    lastCalculatedAt: Date = persistenceTestDate,
    lastInteractionAt: Date? = persistenceTestDate
) -> PetState {
    PetState(
        id: persistenceTestID,
        modelVersion: MokiCoreConfiguration.domainModelVersion,
        stats: PetStats(
            hunger: 61,
            happiness: 72,
            energy: 83,
            bond: 24
        ),
        isSleeping: true,
        createdAt: persistenceTestDate,
        lastCalculatedAt: lastCalculatedAt,
        lastInteractionAt: lastInteractionAt
    )
}

enum StubStoreError: Error {
    case requestedFailure
}

final class MemoryPetStore: PetStore {
    var storedState: PetState?
    var loadShouldFail = false
    var saveShouldFail = false
    private(set) var saveCount = 0

    init(storedState: PetState? = nil) {
        self.storedState = storedState
    }

    func load() throws -> PetState? {
        if loadShouldFail {
            throw StubStoreError.requestedFailure
        }
        return storedState
    }

    func save(_ state: PetState) throws {
        if saveShouldFail {
            throw StubStoreError.requestedFailure
        }
        storedState = state
        saveCount += 1
    }
}

final class MutableMokiClock: MokiClock, @unchecked Sendable {
    var now: Date

    init(now: Date) {
        self.now = now
    }
}
