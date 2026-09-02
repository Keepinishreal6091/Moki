import Foundation
import MokiCore

public enum PetSnapshotCodecError: Error, Equatable {
    case invalidData
    case unsupportedSchemaVersion(Int)
}

/// Converts the domain state to and from a versioned persistence envelope.
///
/// The snapshot intentionally contains only Milestones 1-2 state. Future
/// individual traits must arrive through an explicit later schema migration.
public struct PetSnapshotCodec {
    public static let currentSchemaVersion = 1

    public init() {}

    public func encode(
        _ state: PetState,
        savedAt: Date? = nil
    ) throws -> Data {
        let envelope = SnapshotEnvelopeV1(
            schemaVersion: Self.currentSchemaVersion,
            savedAt: savedAt ?? state.lastCalculatedAt,
            pet: PetSnapshotV1(state: state)
        )

        do {
            return try Self.makeEncoder().encode(envelope)
        } catch {
            throw PetSnapshotCodecError.invalidData
        }
    }

    public func decode(_ data: Data) throws -> PetState {
        let decoder = Self.makeDecoder()
        let header: SnapshotHeader

        do {
            header = try decoder.decode(SnapshotHeader.self, from: data)
        } catch {
            throw PetSnapshotCodecError.invalidData
        }

        do {
            switch header.schemaVersion {
            case 0:
                let legacy = try decoder.decode(
                    LegacySnapshotEnvelopeV0.self,
                    from: data
                )
                return legacy.pet.migratedState()
            case Self.currentSchemaVersion:
                let current = try decoder.decode(
                    SnapshotEnvelopeV1.self,
                    from: data
                )
                return current.pet.state()
            default:
                throw PetSnapshotCodecError.unsupportedSchemaVersion(
                    header.schemaVersion
                )
            }
        } catch let error as PetSnapshotCodecError {
            throw error
        } catch {
            throw PetSnapshotCodecError.invalidData
        }
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
}

private struct SnapshotHeader: Decodable {
    let schemaVersion: Int
}

private struct SnapshotEnvelopeV1: Codable {
    let schemaVersion: Int
    let savedAt: Date
    let pet: PetSnapshotV1
}

private struct PetSnapshotV1: Codable {
    let id: UUID
    let modelVersion: Int
    let stats: PetStatsSnapshotV1
    let isSleeping: Bool
    let createdAt: Date
    let lastCalculatedAt: Date
    let lastInteractionAt: Date?

    init(state: PetState) {
        id = state.id
        modelVersion = state.modelVersion
        stats = PetStatsSnapshotV1(stats: state.stats)
        isSleeping = state.isSleeping
        createdAt = state.createdAt
        lastCalculatedAt = state.lastCalculatedAt
        lastInteractionAt = state.lastInteractionAt
    }

    func state() -> PetState {
        PetState(
            id: id,
            modelVersion: modelVersion,
            stats: stats.stats(),
            isSleeping: isSleeping,
            createdAt: createdAt,
            lastCalculatedAt: lastCalculatedAt,
            lastInteractionAt: lastInteractionAt
        )
    }
}

private struct PetStatsSnapshotV1: Codable {
    let hunger: Double
    let happiness: Double
    let energy: Double
    let bond: Double

    init(stats: PetStats) {
        hunger = stats.hunger
        happiness = stats.happiness
        energy = stats.energy
        bond = stats.bond
    }

    func stats() -> PetStats {
        PetStats(
            hunger: hunger,
            happiness: happiness,
            energy: energy,
            bond: bond
        )
    }
}

/// Pre-release schema used only to prove the migration path. It predates the
/// explicit domain model version and last-interaction timestamp.
private struct LegacySnapshotEnvelopeV0: Decodable {
    let schemaVersion: Int
    let pet: LegacyPetSnapshotV0
}

private struct LegacyPetSnapshotV0: Decodable {
    let id: UUID
    let stats: PetStatsSnapshotV1
    let isSleeping: Bool
    let createdAt: Date
    let lastUpdatedAt: Date

    func migratedState() -> PetState {
        PetState(
            id: id,
            modelVersion: MokiCoreConfiguration.domainModelVersion,
            stats: stats.stats(),
            isSleeping: isSleeping,
            createdAt: createdAt,
            lastCalculatedAt: lastUpdatedAt,
            lastInteractionAt: nil
        )
    }
}
