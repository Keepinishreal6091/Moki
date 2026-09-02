import XCTest
import MokiCore

final class MokiAppTests: XCTestCase {
    func testCoreConfigurationUsesApprovedPrototypeDefaults() {
        XCTAssertEqual(MokiCoreConfiguration.version, "0.1.0")
        XCTAssertEqual(
            MokiCoreConfiguration.defaultAppGroupIdentifier,
            "group.com.example.moki"
        )
    }
}
