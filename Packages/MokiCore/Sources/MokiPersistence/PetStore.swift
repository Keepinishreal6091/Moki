import MokiCore

/// Minimal persistence boundary used by lifecycle orchestration.
public protocol PetStore {
    func load() throws -> PetState?
    func save(_ state: PetState) throws
}
