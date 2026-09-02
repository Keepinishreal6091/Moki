import XCTest
@testable import MokiCore

final class MokiCoreTests: XCTestCase {
    func testConfigurationMatchesMilestoneZeroContract() {
        XCTAssertEqual(MokiCoreConfiguration.version, "0.1.0")
        XCTAssertEqual(MokiCoreConfiguration.domainModelVersion, 1)
        XCTAssertTrue(
            MokiCoreConfiguration.defaultAppGroupIdentifier.hasPrefix("group.")
        )
    }
}
