import SwiftUI

@main
@MainActor
struct MokiApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var session: PetSession

    init() {
        let container = AppContainer()
        _session = State(initialValue: container.petSession)
    }

    var body: some Scene {
        WindowGroup {
            PetRoomView(session: session)
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        session.refreshForActiveScene()
                    case .background:
                        session.saveForBackground()
                    case .inactive:
                        break
                    @unknown default:
                        break
                    }
                }
        }
    }
}
