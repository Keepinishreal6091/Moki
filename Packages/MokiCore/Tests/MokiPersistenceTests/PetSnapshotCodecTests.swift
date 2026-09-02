import Foundation
import XCTest
import MokiCore
@testable import MokiPersistence

final class PetSnapshotCodecTests: XCTestCase {
    private let codec = PetSnapshotCodec()

    func testCurrentSnapshotRoundTripsAllMilestoneTwoState() throws {
        let state = makePersistenceTestState()

        let data = try codec.encode(state)
        let decoded = try codec.decode(data)

        XCTAssertEqual(decoded, state)
    }

    func testEncodedSnapshotDeclaresCurrentSchemaVersion() throws {
        let data = try codec.encode(makePersistenceTestState())
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        XCTAssertEqual(
            object["schemaVersion"] as? Int,
            PetSnapshotCodec.currentSchemaVersion
        )
    }

    func testLegacyVersionZeroMigratesToCurrentDomainState() throws {
        let legacyObject: [String: Any] = [
            "schemaVersion": 0,
            "pet": [
                "id": persistenceTestID.uuidString,
                "stats": [
                    "hunger": 45,
                    "happiness": 55,
                    "energy": 65,
                    "bond": 12
                ],
                "isSleeping": false,
                "createdAt": persistenceTestDate.timeIntervalSince1970 * 1_000,
                "lastUpdatedAt": persistenceHoursAfter(3).timeIntervalSince1970 * 1_000
            ]
        ]
        let data = try JSONSerialization.data(withJSONObject: legacyObject)

        let migrated = try codec.decode(data)

        XCTAssertEqual(migrated.id, persistenceTestID)
        XCTAssertEqual(
            migrated.modelVersion,
            MokiCoreConfiguration.domainModelVersion
        )
        XCTAssertEqual(migrated.stats.hunger, 45)
        XCTAssertEqual(migrated.stats.happiness, 55)
        XCTAssertEqual(migrated.stats.energy, 65)
        XCTAssertEqual(migrated.stats.bond, 12)
        XCTAssertFalse(migrated.isSleeping)
        XCTAssertEqual(migrated.createdAt, persistenceTestDate)
        XCTAssertEqual(migrated.lastCalculatedAt, persistenceHoursAfter(3))
        XCTAssertNil(migrated.lastInteractionAt)
    }

    func testFutureSchemaVersionIsRejectedWithoutGuessing() {
        let data = Data("{\"schemaVersion\":99}".utf8)

        XCTAssertThrowsError(try codec.decode(data)) { error in
            XCTAssertEqual(
                error as? PetSnapshotCodecError,
                .unsupportedSchemaVersion(99)
            )
        }
    }

    func testMalformedSnapshotIsRejected() {
        let data = Data("not-json".utf8)

        XCTAssertThrowsError(try codec.decode(data)) { error in
            XCTAssertEqual(
                error as? PetSnapshotCodecError,
                .invalidData
            )
        }
    }

    func testCurrentSnapshotDoesNotPrematurelyContainFutureTraits() throws {
        let data = try codec.encode(makePersistenceTestState())
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertFalse(json.contains("battle"))
        XCTAssertFalse(json.contains("potential"))
        XCTAssertFalse(json.contains("breeding"))
        XCTAssertFalse(json.contains("variant"))
    }
}
