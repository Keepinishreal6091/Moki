import Foundation
import MokiCore

public enum FilePetStoreError: Error, Equatable {
    case corruptedPrimary
    case corruptedPrimaryAndBackup
    case unsupportedSchemaVersion(Int)
}

/// Atomic JSON-file storage with one-generation backup recovery.
public final class FilePetStore: PetStore {
    public let directoryURL: URL
    public let primaryFileURL: URL
    public let backupFileURL: URL

    private let fileManager: FileManager
    private let codec: PetSnapshotCodec

    public init(
        directoryURL: URL,
        fileName: String = "pet-state.json",
        fileManager: FileManager = .default,
        codec: PetSnapshotCodec = PetSnapshotCodec()
    ) {
        self.directoryURL = directoryURL
        primaryFileURL = directoryURL.appendingPathComponent(fileName)
        backupFileURL = directoryURL.appendingPathComponent(
            "\(fileName).backup"
        )
        self.fileManager = fileManager
        self.codec = codec
    }

    public func load() throws -> PetState? {
        guard fileManager.fileExists(atPath: primaryFileURL.path) else {
            guard fileManager.fileExists(atPath: backupFileURL.path) else {
                return nil
            }
            return try recoverFromBackup()
        }

        do {
            return try decodeFile(at: primaryFileURL)
        } catch let error as PetSnapshotCodecError {
            if case let .unsupportedSchemaVersion(version) = error {
                throw FilePetStoreError.unsupportedSchemaVersion(version)
            }
            return try recoverFromBackup()
        } catch {
            return try recoverFromBackup()
        }
    }

    public func save(_ state: PetState) throws {
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let data = try codec.encode(
            state,
            savedAt: state.lastCalculatedAt
        )

        if fileManager.fileExists(atPath: primaryFileURL.path) {
            let previousData = try Data(contentsOf: primaryFileURL)
            try previousData.write(to: backupFileURL, options: .atomic)
        }

        try data.write(to: primaryFileURL, options: .atomic)
    }

    private func decodeFile(at url: URL) throws -> PetState {
        let data = try Data(contentsOf: url)
        return try codec.decode(data)
    }

    private func recoverFromBackup() throws -> PetState {
        guard fileManager.fileExists(atPath: backupFileURL.path) else {
            throw FilePetStoreError.corruptedPrimary
        }

        do {
            let backupData = try Data(contentsOf: backupFileURL)
            let recovered = try codec.decode(backupData)
            try backupData.write(to: primaryFileURL, options: .atomic)
            return recovered
        } catch let error as PetSnapshotCodecError {
            if case let .unsupportedSchemaVersion(version) = error {
                throw FilePetStoreError.unsupportedSchemaVersion(version)
            }
            throw FilePetStoreError.corruptedPrimaryAndBackup
        } catch {
            throw FilePetStoreError.corruptedPrimaryAndBackup
        }
    }
}
