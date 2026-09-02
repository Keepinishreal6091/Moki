import Foundation
import XCTest
import MokiCore
@testable import MokiPersistence

final class FilePetStoreTests: XCTestCase {
    private var directoryURL: URL!
    private var store: FilePetStore!

    override func setUpWithError() throws {
        directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        store = FilePetStore(directoryURL: directoryURL)
    }

    override func tearDownWithError() throws {
        if let directoryURL,
           FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.removeItem(at: directoryURL)
        }
        store = nil
        directoryURL = nil
    }

    func testMissingSnapshotLoadsAsNil() throws {
        XCTAssertNil(try store.load())
    }

    func testSaveCreatesDirectoryAndRoundTripsState() throws {
        let state = makePersistenceTestState()

        try store.save(state)

        XCTAssertTrue(
            FileManager.default.fileExists(atPath: store.primaryFileURL.path)
        )
        XCTAssertEqual(try store.load(), state)
    }

    func testSecondSaveRetainsPreviousStateAsBackup() throws {
        let first = makePersistenceTestState()
        var second = first
        second.stats.happiness = 99

        try store.save(first)
        try store.save(second)

        XCTAssertTrue(
            FileManager.default.fileExists(atPath: store.backupFileURL.path)
        )
        XCTAssertEqual(try store.load(), second)
    }

    func testCorruptedPrimaryRecoversPreviousBackupAndRepairsPrimary() throws {
        let first = makePersistenceTestState()
        var second = first
        second.stats.bond = 88
        try store.save(first)
        try store.save(second)
        try Data("corrupt-primary".utf8).write(to: store.primaryFileURL)

        let recovered = try store.load()
        let repaired = try store.load()

        XCTAssertEqual(recovered, first)
        XCTAssertEqual(repaired, first)
    }

    func testMissingPrimaryRecoversBackupInsteadOfCreatingANewPet() throws {
        let first = makePersistenceTestState()
        var second = first
        second.stats.bond = 88
        try store.save(first)
        try store.save(second)
        try FileManager.default.removeItem(at: store.primaryFileURL)

        let recovered = try store.load()

        XCTAssertEqual(recovered, first)
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: store.primaryFileURL.path)
        )
    }

    func testCorruptedPrimaryWithoutBackupReportsFailure() throws {
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        try Data("corrupt-primary".utf8).write(to: store.primaryFileURL)

        XCTAssertThrowsError(try store.load()) { error in
            XCTAssertEqual(
                error as? FilePetStoreError,
                .corruptedPrimary
            )
        }
    }

    func testCorruptedPrimaryAndBackupReportUnrecoverableFailure() throws {
        let first = makePersistenceTestState()
        var second = first
        second.stats.energy = 22
        try store.save(first)
        try store.save(second)
        try Data("corrupt-primary".utf8).write(to: store.primaryFileURL)
        try Data("corrupt-backup".utf8).write(to: store.backupFileURL)

        XCTAssertThrowsError(try store.load()) { error in
            XCTAssertEqual(
                error as? FilePetStoreError,
                .corruptedPrimaryAndBackup
            )
        }
    }

    func testAtomicSaveLeavesNoTemporaryArtifacts() throws {
        try store.save(makePersistenceTestState())

        let names = try FileManager.default.contentsOfDirectory(
            atPath: directoryURL.path
        )

        XCTAssertEqual(names, ["pet-state.json"])
    }
}
