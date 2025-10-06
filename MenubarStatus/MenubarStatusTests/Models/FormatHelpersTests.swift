//
//  FormatHelpersTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025/10/05.
//

import XCTest
@testable import MenubarStatus

final class FormatHelpersTests: XCTestCase {
    func testPercentageFormatting() {
        XCTAssertEqual(FormatHelpers.formatPercentage(42.0, decimals: 0), "42%")
        XCTAssertEqual(FormatHelpers.formatPercentageCompact(42.0), "42%")
        XCTAssertEqual(FormatHelpers.formatPercentageCompact(42.5), "42.5%")
    }
    
    func testBytesFormatting() {
        let oneMB: UInt64 = 1_048_576
        let formatted = FormatHelpers.formatBytes(oneMB)
        XCTAssertTrue(formatted.contains("MB"))
    }
    
    func testLocaleAwareUnitsPlaceholder() {
        // Placeholder: validate en/zh numerics and units once localization integrated
        XCTAssertTrue(true)
    }
}
