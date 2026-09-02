import Foundation
import MokiCore
import MokiPersistence

/// Composition root for app-wide dependencies.
///
/// Milestone 2 composes the clock, versioned store, and lifecycle controller.
/// User-facing pet-room services remain deferred to later milestones.
@MainActor
final class AppContainer {
    let appGroupIdentifier: String
    let coreVersion: String
    let petSession: PetSession
    let usesDevelopmentPersistenceFallback: Bool

    init(
        bundle: Bundle = .main,
        fileManager: FileManager = .default,
        clock: any MokiClock = SystemMokiClock()
    ) {
        let resolvedAppGroupIdentifier = bundle.object(
            forInfoDictionaryKey: "MokiAppGroupIdentifier"
        ) as? String ?? MokiCoreConfiguration.defaultAppGroupIdentifier
        appGroupIdentifier = resolvedAppGroupIdentifier
        coreVersion = MokiCoreConfiguration.version

        let store = AppGroupPetStore(
            appGroupIdentifier: resolvedAppGroupIdentifier,
            fileManager: fileManager
        )
        usesDevelopmentPersistenceFallback = store.usesDevelopmentFallback
        petSession = PetSession(
            controller: PetLifecycleController(
                store: store,
                clock: clock
            )
        )
    }
}
