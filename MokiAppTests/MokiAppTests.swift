import XCTest
import UIKit
import MokiCore

final class MokiAppTests: XCTestCase {
    func testCoreConfigurationUsesApprovedPrototypeDefaults() {
        XCTAssertEqual(MokiCoreConfiguration.version, "0.1.0")
        XCTAssertEqual(
            MokiCoreConfiguration.defaultAppGroupIdentifier,
            "group.com.example.moki"
        )
    }

    func testRoomBackgroundProvidesDistinctLightAndDarkArtwork() throws {
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        let lightImage = try XCTUnwrap(
            UIImage(
                named: "MokiRoomBackground",
                in: Bundle.main,
                compatibleWith: lightTraits
            )
        )
        let darkImage = try XCTUnwrap(
            UIImage(
                named: "MokiRoomBackground",
                in: Bundle.main,
                compatibleWith: darkTraits
            )
        )

        XCTAssertNotEqual(lightImage.pngData(), darkImage.pngData())
    }
}
