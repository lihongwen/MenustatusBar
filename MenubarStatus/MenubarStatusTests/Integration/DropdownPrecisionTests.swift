//
//  DropdownPrecisionTests.swift
//  MenubarStatusTests
//
//  Test dropdown exact values (Scenario 6)
//  EXPECTED: PASS - dropdown already shows decimals
//

import XCTest
@testable import MenubarStatus

final class DropdownPrecisionTests: XCTestCase {
    
    func testDropdown_ShowsDecimalPrecision() {
        // Test: Dropdown should show decimal precision
        // Menubar: "45%", Dropdown: "45.23%"
        
        let metrics = TestHelpers.mockSystemMetrics(cpuUsage: 45.23)
        
        let settings = AppSettings()
        let summary = MenubarSummaryBuilder.build(from: metrics, settings: settings)
        
        // Menubar shows integer
        XCTAssertEqual(summary.items[0].primaryText, "45%")
        
        // Percentage stored with precision for dropdown
        XCTAssertEqual(summary.items[0].percentage, 45.23, accuracy: 0.01)
    }
}

