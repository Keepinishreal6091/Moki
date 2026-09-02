import Foundation
import MokiCore
import MokiPersistence

/// Resolves the shared App Group container for the production path and uses a
/// clearly identified Application Support fallback while placeholder signing
/// identifiers are still in use.
final class AppGroupPetStore: PetStore {
    let resolvedDirectoryURL: URL
    let usesDevelopmentFallback: Bool

    private let fileStore: FilePetStore

    init(
        appGroupIdentifier: String,
        fileManager: FileManager = .default
    ) {
        let directoryURL: URL
        let isFallback: Bool

        if let groupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            directoryURL = groupURL.appendingPathComponent(
                "MokiState",
                isDirectory: true
            )
            isFallback = false
        } else {
            let applicationSupport = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first ?? fileManager.temporaryDirectory
            directoryURL = applicationSupport
                .appendingPathComponent("Moki", isDirectory: true)
                .appendingPathComponent(
                    "DevelopmentAppGroupFallback",
                    isDirectory: true
                )
            isFallback = true
        }

        resolvedDirectoryURL = directoryURL
        usesDevelopmentFallback = isFallback
        fileStore = FilePetStore(
            directoryURL: directoryURL,
            fileManager: fileManager
        )
    }

    func load() throws -> PetState? {
        try fileStore.load()
    }

    func save(_ state: PetState) throws {
        try fileStore.save(state)
    }
}
